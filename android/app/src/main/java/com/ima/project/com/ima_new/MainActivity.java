package com.ima.project.com.ima_new;

import android.util.Log;

import io.flutter.embedding.android.FlutterActivity;
import androidx.annotation.NonNull;
import androidx.multidex.MultiDex;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugins.GeneratedPluginRegistrant;

public class MainActivity extends FlutterActivity {
    @Override
    public void configureFlutterEngine(@NonNull FlutterEngine flutterEngine) {
        MultiDex.install(this);
        GeneratedPluginRegistrant.registerWith(flutterEngine);

        new MethodChannel(
            flutterEngine.getDartExecutor()
                    .getBinaryMessenger(),
            "com.ima.project.com.ima_new/urls"
        )
                .setMethodCallHandler((call, result) -> {
                    Log.d("TAG", "getDataThenInitPlayer:log2");
                    if (call.method.equals("urls")) {
                        String urlVidio = call.argument("urlVidio");
                        String urlAds = call.argument("urlAds");
                        Log.d("TAG", "getDataThenInitPlayer:urls"+urlVidio);

                        flutterEngine
                                .getPlatformViewsController()
                                .getRegistry()
                                .registerViewFactory("<platform-view-type>",
                                        new NativeViewFactory(flutterEngine
                                                .getDartExecutor()
                                                .getBinaryMessenger(),urlVidio,urlAds
                                        )
                                );

                    }
                    result.success("success");
                });
    }
}