package com.ima.project.com.ima_new;
import android.content.Context;

import androidx.annotation.Nullable;
import androidx.annotation.NonNull;
import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.common.StandardMessageCodec;
import io.flutter.plugin.platform.PlatformView;
import io.flutter.plugin.platform.PlatformViewFactory;
import java.util.Map;

class NativeViewFactory extends PlatformViewFactory {
    @NonNull private final BinaryMessenger messenger;
    private final String urlVidio;
    private final String urlAds;
    NativeViewFactory(@NonNull BinaryMessenger messenger, String urlVidio, String urlAds) {
        super(StandardMessageCodec.INSTANCE);
        this.messenger = messenger;
        this.urlVidio = urlVidio;
        this.urlAds=urlAds;
    }

    @NonNull
    @Override
    public PlatformView create(@NonNull Context context, int id, @Nullable Object args) {
        final Map<String, Object> creationParams = (Map<String, Object>) args;
        return new NativeView(context, id, creationParams,messenger,urlVidio,urlAds);
    }
}