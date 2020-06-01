package org.webpatient.flutter_exposure_notifications;

import android.app.Activity;
import android.app.AlertDialog;
import android.app.Dialog;
import android.content.Context;
import android.content.DialogInterface;

import androidx.annotation.NonNull;

import io.flutter.Log;
import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.embedding.engine.plugins.activity.ActivityAware;
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.PluginRegistry.Registrar;
import io.flutter.plugin.common.BinaryMessenger;

/** FlutterExposureNotificationsPlugin */
public class FlutterExposureNotificationsPlugin implements FlutterPlugin, MethodCallHandler, ActivityAware {
  /// The MethodChannel that will the communication between Flutter and native Android
  ///
  /// This local reference serves to register the plugin with the Flutter Engine and unregister it
  /// when the Flutter Engine is detached from the Activity
  private MethodChannel channel;
  private Context applicationContext;
  private Activity mainActivity;

  private void onAttachedToEngine(Context context, BinaryMessenger binaryMessenger) {
    this.applicationContext = context;
    this.channel = new MethodChannel(binaryMessenger, "flutter_exposure_notifications");
    this.channel.setMethodCallHandler(this);
  }

  @Override
  public void onAttachedToEngine(@NonNull FlutterPluginBinding flutterPluginBinding) {
    Log.d("DEBUG","onAttachedToEngine2");
    onAttachedToEngine(flutterPluginBinding.getApplicationContext(), flutterPluginBinding.getBinaryMessenger());
  }

  // This static function is optional and equivalent to onAttachedToEngine. It supports the old
  // pre-Flutter-1.12 Android projects. You are encouraged to continue supporting
  // plugin registration via this function while apps migrate to use the new Android APIs
  // post-flutter-1.12 via https://flutter.dev/go/android-project-migration.
  //
  // It is encouraged to share logic between onAttachedToEngine and registerWith to keep
  // them functionally equivalent. Only one of onAttachedToEngine or registerWith will be called
  // depending on the user's project. onAttachedToEngine or registerWith must both be defined
  // in the same class.


  public static void registerWith(Registrar registrar) {
    Log.d("DEBUG","registerWith");
  }

  @Override
  public void onMethodCall(@NonNull MethodCall call, @NonNull Result result) {
    Log.d("DEBUG","onMethodCall");

    if (call.method.equals("getPlatformVersion")) {
      result.success("Android ver: " + android.os.Build.VERSION.RELEASE);
      Log.d("DEBUG","Android ver: " + android.os.Build.VERSION.RELEASE);
    } else if (call.method.equals("turnOnExposureNotifications")) {
      Log.d("DEBUG","turnOnExposureNotifications");
    } else if (call.method.equals("showContactInfo")) {
      Log.d("DEBUG","showContactInfo->contactID: " + call.argument("contactID"));
    } else if (call.method.equals("showAlertDialog")) {
      result.success("showAlertDialog!");
      Log.d("DEBUG","showAlertDialog");

      if (mainActivity == null){
        Log.d("DEBUG","mainActivity == NULL");
      }
      else {
        Log.d("DEBUG","mainActivity != NULL");
      }
      Dialog dialog = new Dialog(mainActivity);
      dialog.setTitle("Dialog: Dialog(java)");
      dialog.show();

        AlertDialog alertDialog = new AlertDialog.Builder(mainActivity).create();
        alertDialog.setTitle("Dialog: AlertDialog(java)");
        alertDialog.setMessage("AlertDialog in java!");
        alertDialog.setButton(AlertDialog.BUTTON_NEUTRAL, "OK",
                new DialogInterface.OnClickListener() {
                    public void onClick(DialogInterface dialog, int which) {
                        dialog.dismiss();
                    }
                });
        alertDialog.show();


    } else {
      result.notImplemented();
    }
  }

  @Override
  public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
    Log.d("DEBUG","onDetachedFromEngine");

    channel.setMethodCallHandler(null);
  }

  @Override
  public void onAttachedToActivity(ActivityPluginBinding binding) {
   this.mainActivity = binding.getActivity();
  }

  @Override
  public void onDetachedFromActivityForConfigChanges() {

  }

  @Override
  public void onReattachedToActivityForConfigChanges(ActivityPluginBinding binding) {

  }

  @Override
  public void onDetachedFromActivity() {

  }
}
