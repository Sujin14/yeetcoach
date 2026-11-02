package com.sujin.yeetcoach

import android.util.Log
import com.google.firebase.messaging.RemoteMessage
import com.sujin.yeetcoach.call.AppState
import com.sujin.yeetcoach.call.CallNotificationManager
import io.flutter.plugins.firebase.messaging.FlutterFirebaseMessagingService

/// Incoming / cancelled calls use [CallNotificationManager]. Token refresh is
/// forwarded to Dart via [FlutterFirebaseMessagingService.onNewToken].
class YeetFirebaseMessagingService : FlutterFirebaseMessagingService() {
    override fun onNewToken(token: String) {
        super.onNewToken(token)
    }

    override fun onMessageReceived(message: RemoteMessage) {
        val type = message.data["type"]
        val data = message.data
        Log.d(TAG, "FCM received | type=$type")

        if (type == "incoming_call") {
            val callId = data["callId"].orEmpty()
            if (callId.isEmpty()) {
                Log.e(TAG, "incoming_call without callId")
                return
            }
            CallNotificationManager.showIncomingCall(
                context = this,
                callId = callId,
                callerId = data["callerId"].orEmpty(),
                callerName = data["callerName"].orEmpty().ifBlank { "Client" },
                callerPhoto = data["callerPhotoUrl"].orEmpty(),
                callType = data["callType"] ?: "audio",
                appInForeground = AppState.isForeground(this),
            )
            return
        }

        if (type == "call_cancelled") {
            val callId = data["callId"].orEmpty()
            Log.d(TAG, "FCM call_cancelled for $callId reason=${data["reason"]}")
            CallNotificationManager.dismissIncomingCall(this, callId.ifEmpty { null })
            if (
                data["showMissed"] != "false" &&
                callId.isNotEmpty() &&
                !callId.startsWith("test_")
            ) {
                CallNotificationManager.showMissedCall(
                    context = this,
                    callId = callId,
                    callerName = data["callerName"].orEmpty().ifBlank { "Client" },
                    callType = data["callType"] ?: "audio",
                )
            }
            return
        }

        Log.d(TAG, "Non-call FCM — forwarding to FlutterFirebaseMessagingService")
        super.onMessageReceived(message)
    }

    companion object {
        private const val TAG = "YeetCall"
    }
}
