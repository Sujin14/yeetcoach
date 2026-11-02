package com.sujin.yeetcoach

import android.content.Intent
import android.os.Build
import android.os.Bundle
import android.util.Log
import android.view.WindowManager
import com.sujin.yeetcoach.call.AppState
import com.sujin.yeetcoach.call.CallConstants
import com.sujin.yeetcoach.call.CallNotificationManager
import com.sujin.yeetcoach.call.CallReadiness
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private var callChannel: MethodChannel? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        callChannel = MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            CALL_CHANNEL,
        ).also { channel ->
            channel.setMethodCallHandler { call, result ->
                when (call.method) {
                    "consumePendingAcceptedCall" -> {
                        val pending = pendingAcceptedCall
                        pendingAcceptedCall = null
                        Log.d(TAG, "consumePendingAcceptedCall -> ${pending?.get("callId")}")
                        result.success(pending)
                    }
                    "dismissIncomingCall" -> {
                        val callId = call.arguments as? String
                        CallNotificationManager.dismissIncomingCall(this, callId)
                        result.success(null)
                    }
                    "getActiveRingingCallId" -> {
                        result.success(CallNotificationManager.getActiveCallId(this))
                    }
                    "clearLockScreenFlags" -> {
                        clearLockScreenFlags()
                        result.success(null)
                    }
                    "getCallReadiness" -> {
                        result.success(CallReadiness.status(this))
                    }
                    "openCallSetting" -> {
                        val which = call.arguments as? String ?: ""
                        result.success(CallReadiness.open(this, which))
                    }
                    "scheduleTestCall" -> {
                        val delayMs = when (val arg = call.arguments) {
                            is Int -> arg.toLong()
                            is Long -> arg
                            is Number -> arg.toLong()
                            else -> 10_000L
                        }
                        CallReadiness.scheduleTestCall(this, delayMs)
                        result.success(null)
                    }
                    "showIncomingCall" -> {
                        val args = call.arguments as? Map<*, *>
                        val callId = args?.get("callId") as? String
                        if (callId.isNullOrEmpty()) {
                            result.error("bad_args", "showIncomingCall requires callId", null)
                            return@setMethodCallHandler
                        }
                        CallNotificationManager.showIncomingCall(
                            context = this,
                            callId = callId,
                            callerId = args["callerId"] as? String ?: "",
                            callerName = (args["callerName"] as? String).orEmpty().ifBlank { "Client" },
                            callerPhoto = args["callerPhotoUrl"] as? String ?: "",
                            callType = args["callType"] as? String ?: "audio",
                            appInForeground = AppState.isForeground(this),
                        )
                        result.success(null)
                    }
                    else -> result.notImplemented()
                }
            }
        }
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        handleCallIntent(intent)
    }

    override fun onResume() {
        super.onResume()
        AppState.mainActivityResumed = true
    }

    override fun onPause() {
        AppState.mainActivityResumed = false
        super.onPause()
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        setIntent(intent)
        handleCallIntent(intent)
    }

    private fun handleCallIntent(intent: Intent?) {
        if (intent?.action != CallConstants.ACTION_ACCEPT) return
        val callId = intent.getStringExtra(CallConstants.EXTRA_CALL_ID).orEmpty()
        if (callId.isEmpty()) {
            Log.d(TAG, "handleCallIntent: empty callId — ignoring")
            return
        }
        Log.d(TAG, "handleCallIntent: ACTION_ACCEPT callId=$callId")
        CallNotificationManager.dismissIncomingCall(this, callId)

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O_MR1) {
            setShowWhenLocked(true)
        } else {
            @Suppress("DEPRECATION")
            window.addFlags(WindowManager.LayoutParams.FLAG_SHOW_WHEN_LOCKED)
        }

        pendingAcceptedCall = mapOf(
            "callId" to callId,
            "callerId" to intent.getStringExtra(CallConstants.EXTRA_CALLER_ID).orEmpty(),
            "callerName" to intent.getStringExtra(CallConstants.EXTRA_CALLER_NAME).orEmpty(),
            "callerPhotoUrl" to intent.getStringExtra(CallConstants.EXTRA_CALLER_PHOTO).orEmpty(),
            "callType" to intent.getStringExtra(CallConstants.EXTRA_CALL_TYPE).orEmpty(),
        )
        callChannel?.invokeMethod("callAccepted", callId)
        intent.action = null
    }

    private fun clearLockScreenFlags() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O_MR1) {
            setShowWhenLocked(false)
            setTurnScreenOn(false)
        } else {
            @Suppress("DEPRECATION")
            window.clearFlags(
                WindowManager.LayoutParams.FLAG_SHOW_WHEN_LOCKED or
                    WindowManager.LayoutParams.FLAG_TURN_SCREEN_ON,
            )
        }
        Log.d(TAG, "clearLockScreenFlags")
    }

    companion object {
        private const val TAG = "YeetCall"
        const val CALL_CHANNEL = "com.sujin.yeetcoach/incoming_call"

        @Volatile
        var pendingAcceptedCall: Map<String, String>? = null
    }
}
