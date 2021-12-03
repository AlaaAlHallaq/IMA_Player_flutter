package com.ima.project.com.ima_new;

import io.flutter.embedding.android.FlutterActivity;
import androidx.annotation.NonNull;
import androidx.multidex.MultiDex;

import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.plugins.GeneratedPluginRegistrant;
import io.flutter.plugins.connectivity.ConnectivityPlugin;

public class MainActivity extends FlutterActivity {
    @Override
    public void configureFlutterEngine(@NonNull FlutterEngine flutterEngine) {
        MultiDex.install(this);
        flutterEngine
                .getPlatformViewsController()
                .getRegistry()
                .registerViewFactory("<platform-view-type>", new NativeViewFactory(flutterEngine.getDartExecutor().getBinaryMessenger()));
    }
}