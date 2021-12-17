package com.ima.project.com.ima_new;

import androidx.annotation.NonNull;
import io.flutter.embedding.engine.plugins.FlutterPlugin;

public class PlatformViewPlugin implements FlutterPlugin {
    @Override
    public void onAttachedToEngine(@NonNull FlutterPluginBinding binding) {
        binding
                .getPlatformViewRegistry()
                .registerViewFactory("<platform-view-type>", new NativeViewFactory(binding.getBinaryMessenger(), "urlVidio", "urlAds"));
    }

    @Override
    public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {}
}