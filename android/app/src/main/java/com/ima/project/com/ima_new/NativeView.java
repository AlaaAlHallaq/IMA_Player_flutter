package com.ima.project.com.ima_new;

import android.content.Context;
import android.graphics.Color;
import android.graphics.SurfaceTexture;
import android.net.Uri;
import android.os.Build;
import android.view.Surface;
import android.view.View;
import android.webkit.WebView;
import android.webkit.WebViewClient;
import android.widget.TextView;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import com.google.android.exoplayer2.C;
import com.google.android.exoplayer2.ExoPlayer;
import com.google.android.exoplayer2.MediaItem;
import com.google.android.exoplayer2.SimpleExoPlayer;
import com.google.android.exoplayer2.analytics.AnalyticsListener;
import com.google.android.exoplayer2.ext.ima.ImaAdsLoader;
import com.google.android.exoplayer2.source.DefaultMediaSourceFactory;
import com.google.android.exoplayer2.source.MediaSource;
import com.google.android.exoplayer2.source.MediaSourceFactory;
import com.google.android.exoplayer2.source.dash.DashMediaSource;
import com.google.android.exoplayer2.source.dash.DefaultDashChunkSource;
import com.google.android.exoplayer2.ui.PlayerView;
import com.google.android.exoplayer2.upstream.DataSource;
import com.google.android.exoplayer2.upstream.DefaultDataSource;
import com.google.android.exoplayer2.upstream.DefaultDataSourceFactory;
import com.google.android.exoplayer2.util.Util;

import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.platform.PlatformView;

import java.util.Map;

class NativeView implements PlatformView {
    private PlayerView playerView;
    private ExoPlayer player;
    private ImaAdsLoader adsLoader;
    Context context;

    NativeView(@NonNull Context context, int id, @Nullable Map<String, Object> creationParams, BinaryMessenger messenger, String urlVidio, String urlAds) {

        playerView = new PlayerView(context);
        adsLoader = new ImaAdsLoader.Builder(context).build();
        this.context = context;
        if (Util.SDK_INT > 23) {
            initializePlayer(context,urlVidio,urlAds);
            if (playerView != null) {
                playerView.onResume();
            }
        }

    }

//    private void getDataThenInitPlayer(Context context, BinaryMessenger messenger) {
//        new MethodChannel(messenger, "com.ima.project.com.ima_new/urls")
//                .setMethodCallHandler((call, result) -> {
//                    if (call.method.equals("urls")) {
//                        String urlVidio = call.argument("urlVidio");
//                        String urlAds = call.argument("urlAds");
//                        initializePlayer(context, urlVidio, urlAds);
//                    }
//                    result.success("success");
//
//                });
//    }

    private void releasePlayer() {
        adsLoader.setPlayer(null);
        playerView.setPlayer(null);
        player.release();
        player = null;
    }

    private void initializePlayer(Context context, String urlVidio, String urlAds) {

        // Set up the factory for media sources, passing the ads loader and ad view providers.
        DataSource.Factory dataSourceFactory =
                new DefaultDataSourceFactory(context, Util.getUserAgent(context, context.getString(R.string.app_name)));

        MediaSourceFactory mediaSourceFactory =
                new DefaultMediaSourceFactory(dataSourceFactory)
                        .setAdsLoaderProvider(unusedAdTagUri -> adsLoader)
                        .setAdViewProvider(playerView);

        // Create a SimpleExoPlayer and set it as the player for content and ads.
        player = new ExoPlayer.Builder(context).setMediaSourceFactory(mediaSourceFactory).build();
        playerView.setPlayer(player);
        adsLoader.setPlayer(player);
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            player.setVideoSurface(new Surface(new SurfaceTexture(true)));
        }
        // Create the MediaItem to play, specifying the content URI and ad tag URI.
//        Uri contentUri = Uri.parse(context.getString(R.string.content_url));
//        Uri adTagUri = Uri.parse(context.getString(R.string.ad_tag_url));

        Uri contentUri = Uri.parse(urlVidio);
        Uri adTagUri = Uri.parse(urlAds);
        MediaItem mediaItem = new MediaItem.Builder().setUri(contentUri).setAdTagUri(adTagUri).build();

        // Prepare the content and ad to be played with the SimpleExoPlayer.
        player.setMediaItem(mediaItem);
        player.prepare();
        playerView.requestFocus();
        playerView.setKeepContentOnPlayerReset(true);

        // Set PlayWhenReady. If true, content and ads will autoplay.
        player.setPlayWhenReady(true);
    }


    @NonNull
    @Override
    public View getView() {
        return playerView;
    }

    @Override
    public void dispose() {
        if (Util.SDK_INT <= 23) {
            if (playerView != null) {
                playerView.onPause();
            }
            releasePlayer();
        }
    }


}