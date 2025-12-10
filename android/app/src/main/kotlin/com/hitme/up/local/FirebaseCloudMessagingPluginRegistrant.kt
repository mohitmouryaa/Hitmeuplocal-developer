package com.hitme.up.local

import io.flutter.plugin.common.PluginRegistry

class FirebaseCloudMessagingPluginRegistrant {

    companion object {
        fun registerWith(registry: PluginRegistry) {
            if (alreadyRegisteredWith(registry)) {
                return
            }
            registry.registrarFor("io.flutter.plugins.firebase.messaging.FlutterFirebaseMessagingPlugin")
        }

        fun alreadyRegisteredWith(registry: PluginRegistry): Boolean {
            val key = FirebaseCloudMessagingPluginRegistrant::class.java.canonicalName
            if (registry.hasPlugin(key)) {
                return true
            }
            registry.registrarFor(key)
            return false
        }
    }
}