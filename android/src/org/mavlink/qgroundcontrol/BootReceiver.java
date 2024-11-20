package org.mavlink.qgroundcontrol;

import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.util.Log;

public class BootReceiver extends BroadcastReceiver {

    private static final String TAG = "BootReceiver";

    @Override
    public void onReceive(Context context, Intent intent) {
        if (Intent.ACTION_BOOT_COMPLETED.equals(intent.getAction()) ||
            Intent.ACTION_USER_PRESENT.equals(intent.getAction())) {
            Log.d(TAG, "Boot or unlock detected, starting QGCBootService.");

            // Start the QGCBootService
            Intent serviceIntent = new Intent(context, QGCBootService.class);
            context.startService(serviceIntent);
        } else {
            Log.w(TAG, "Unexpected intent received: " + intent.getAction());
        }
    }
}
