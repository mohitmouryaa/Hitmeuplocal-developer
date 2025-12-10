package com.hitme.up.local


import io.flutter.plugin.common.PluginRegistry
import io.flutter.plugin.common.PluginRegistry.PluginRegistrantCallback
import io.flutter.app.FlutterApplication



class Application : FlutterApplication() , PluginRegistrantCallback {

    override fun onCreate() {
        super.onCreate()

    }

    override fun registerWith(registry: PluginRegistry) {
        if (registry != null) {
            FirebaseCloudMessagingPluginRegistrant.registerWith(registry)
        };
    }
}