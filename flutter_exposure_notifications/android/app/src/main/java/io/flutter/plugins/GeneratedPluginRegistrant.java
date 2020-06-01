package io.flutter.plugins;

import io.flutter.plugin.common.PluginRegistry;
import pl.pszklarska.beaconbroadcast.BeaconBroadcastPlugin;
import com.tekartik.sqflite.SqflitePlugin;
import org.webpatient.flutter_exposure_notifications.FlutterExposureNotificationsPlugin;

/**
 * Generated file. Do not edit.
 */
public final class GeneratedPluginRegistrant {
  public static void registerWith(PluginRegistry registry) {
    if (alreadyRegisteredWith(registry)) {
      return;
    }
    BeaconBroadcastPlugin.registerWith(registry.registrarFor("pl.pszklarska.beaconbroadcast.BeaconBroadcastPlugin"));
    SqflitePlugin.registerWith(registry.registrarFor("com.tekartik.sqflite.SqflitePlugin"));
    FlutterExposureNotificationsPlugin.registerWith(registry.registrarFor("org.webpatient.flutter_exposure_notifications.FlutterExposureNotificationsPlugin"));
  }

  private static boolean alreadyRegisteredWith(PluginRegistry registry) {
    final String key = GeneratedPluginRegistrant.class.getCanonicalName();
    if (registry.hasPlugin(key)) {
      return true;
    }
    registry.registrarFor(key);
    return false;
  }
}
