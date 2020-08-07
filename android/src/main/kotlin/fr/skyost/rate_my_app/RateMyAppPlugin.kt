package fr.skyost.rate_my_app

import android.app.Activity
import android.content.Intent
import android.content.pm.PackageManager
import android.net.Uri
import android.os.Build
import androidx.annotation.NonNull
import com.google.android.play.core.review.ReviewInfo
import com.google.android.play.core.review.ReviewManager
import com.google.android.play.core.review.ReviewManagerFactory
import com.google.android.play.core.tasks.Task
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import io.flutter.plugin.common.PluginRegistry.Registrar

public class RateMyAppPlugin: FlutterPlugin, MethodCallHandler, ActivityAware {
  companion object {
    @JvmStatic
    fun registerWith(registrar: Registrar) {
      val channel = MethodChannel(registrar.messenger(), "rate_my_app")
      channel.setMethodCallHandler(RateMyAppPlugin())
    }
  }

  private var activity: Activity? = null
  private lateinit var channel : MethodChannel

  override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
    channel = MethodChannel(flutterPluginBinding.flutterEngine.dartExecutor, "rate_my_app")
    channel.setMethodCallHandler(this);
  }

  override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: Result) {
    if(activity == null) {
      result.error("activity_is_null", "Activity is null.", null);
      return;
    }

    val activity: Activity = this.activity!!
    when(call.method) {
      "launchNativeReviewDialog" -> {
        val manager: ReviewManager = ReviewManagerFactory.create(activity)
        val request: Task<ReviewInfo> = manager.requestReviewFlow()
        request.addOnCompleteListener { task ->
          if (task.isSuccessful) {
            val reviewInfo: ReviewInfo = task.result
            val flow: Task<Void> = manager.launchReviewFlow(activity, reviewInfo)
            flow.addOnCompleteListener { result.success(true) }
          } else {
            result.success(false)
          }
        }
      }
      "isNativeDialogSupported" -> result.success(Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP && isPlayStoreInstalled(activity))
      "launchStore" -> {
        goToPlayStore(activity, if (call.hasArgument("appId")) call.argument<String>("appId")!! else activity.applicationContext.packageName)
        result.success(true)
      }
      else -> result.notImplemented()
    }
  }

  override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
    channel.setMethodCallHandler(null)
  }

  override fun onAttachedToActivity(binding: ActivityPluginBinding) {
    activity = binding.activity
  }

  override fun onDetachedFromActivityForConfigChanges() {
    onDetachedFromActivity()
  }

  override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
    onAttachedToActivity(binding)
  }

  override fun onDetachedFromActivity() {
    activity = null
  }

  /**
   * Returns whether the Play Store is installed on the current device.
   *
   * @param activity The activity.
   *
   * @return Whether the Play Store is installed on the current device.
   */

  private fun isPlayStoreInstalled(activity: Activity): Boolean {
    return try {
      activity.packageManager.getPackageInfo("com.android.vending", 0);
      true
    } catch (ex: PackageManager.NameNotFoundException) {
      false
    }
  }

  /**
   * Launches a Play Store instance.
   *
   * @param activity The activity.
   * @param applicationId The application ID.
   */

  private fun goToPlayStore(activity: Activity, applicationId: String) {
    try {
      activity.startActivity(Intent(Intent.ACTION_VIEW, Uri.parse("market://details?id=$applicationId")));
    }
    catch(ex: android.content.ActivityNotFoundException) {
      activity.startActivity(Intent(Intent.ACTION_VIEW, Uri.parse("https://play.google.com/store/apps/details?id=$applicationId")));
    }
  }
}
