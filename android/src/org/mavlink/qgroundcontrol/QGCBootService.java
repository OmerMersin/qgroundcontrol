package org.mavlink.qgroundcontrol;

import android.app.Service;
import android.content.Intent;
import android.os.IBinder;
import android.util.Log;

public class QGCBootService extends Service {

    private static final String TAG = "QGCBootService";

    @Override
    public int onStartCommand(Intent intent, int flags, int startId) {
        Log.d(TAG, "QGCBootService started.");

        // Start your main activity
        Intent activityIntent = new Intent(this, QGCActivity.class);
        activityIntent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
        startActivity(activityIntent);

        // Stop the service once the app is launched
        stopSelf();
        return START_NOT_STICKY;
    }

    @Override
    public IBinder onBind(Intent intent) {
        return null;
    }
}
