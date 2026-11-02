package com.sujin.yeetcoach.call

object CallConstants {
    const val CHANNEL_ID = "yeetcoach_incoming_calls_v1"
    const val MISSED_CHANNEL_ID = "yeetcoach_missed_calls_v1"
    const val NOTIFICATION_ID = 7001
    const val RING_TIMEOUT_MS = 30_000L

    const val EXTRA_CALL_ID = "EXTRA_CALL_ID"
    const val EXTRA_CALLER_ID = "EXTRA_CALLER_ID"
    const val EXTRA_CALLER_NAME = "EXTRA_CALLER_NAME"
    const val EXTRA_CALLER_PHOTO = "EXTRA_CALLER_PHOTO"
    const val EXTRA_CALL_TYPE = "EXTRA_CALL_TYPE"
    const val EXTRA_PLAY_RINGTONE = "play_ringtone"

    const val ACTION_ACCEPT = "com.sujin.yeetcoach.call.ACCEPT"
    const val ACTION_DECLINE = "com.sujin.yeetcoach.call.DECLINE"
    const val ACTION_DISMISS = "com.sujin.yeetcoach.call.DISMISS"

    const val PREFS_NAME = "yeet_call_state"
    const val KEY_ACTIVE_CALL_ID = "active_call_id"
    const val KEY_HANDLED_CALL_IDS = "handled_call_ids"
}
