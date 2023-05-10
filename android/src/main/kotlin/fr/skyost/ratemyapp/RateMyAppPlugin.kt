package fr.skyost.ratemyapp

import android.app.Activity
import android.content.Context
import android.content.Intent
import android.content.pm.PackageManager
import android.net.Uri
import android.os.Build
import androidx.annotation.NonNull
import com.google.android.play.core.review.ReviewInfo
import com.google.android.play.core.review.ReviewManager
import com.google.android.play.core.review.ReviewManagerFactory
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result

/**
 * The Rate my app plugin main class.
 * A lot of thanks to https://github.com/britannio/in_app_review and its author (This class has been inspired by his work).
 */
public class RateMyAppPlugin : FlutterPlugin, MethodCallHandler, ActivityAware {
    private var activity: Activity? = null
    private var context: Context? = null
    private lateinit var channel: MethodChannel

    private var reviewInfo: ReviewInfo? = null

    override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        channel = MethodChannel(flutterPluginBinding.binaryMessenger, "rate_my_app")
        channel.setMethodCallHandler(this)
        context = flutterPluginBinding.applicationContext
    }

    override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: Result) {
        when (call.method) {
            "launchNativeReviewDialog" -> requestReview(result)
            "isNativeDialogSupported" -> {
                if (Build.VERSION.SDK_INT < Build.VERSION_CODES.LOLLIPOP || !isPlayStoreInstalled()) {
                    result.success(false)
                } else {
                    cacheReviewInfo(result)
                }
            }
            "launchStore" -> result.success(goToPlayStore(call.argument<String>("appId")))
            else -> result.notImplemented()
        }
    }

    override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
        context = null
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
     * Caches the review info that will be obtained.
     *
     * @param result The method channel result object.
     */

    private fun cacheReviewInfo(result: Result) {
        if (context == null) {
            result.error("context_is_null", "Android context not available.", null)
            return
        }
        val manager = ReviewManagerFactory.create(context!!)
        val request = manager.requestReviewFlow()
        request.addOnCompleteListener { task ->
            if (task.isSuccessful) {
                reviewInfo = task.result
                result.success(true)
            } else {
                result.success(false)
            }
        }
    }

    /**
     * Requests a review.
     *
     * @param result The method channel result object.
     */

    private fun requestReview(result: Result) {
        if (context == null) {
            result.error("context_is_null", "Android context not available.", null)
            return
        }
        if (activity == null) {
            result.error("activity_is_null", "Android activity not available.", null)
        }
        val manager = ReviewManagerFactory.create(context!!)
        if (reviewInfo != null) {
            launchReviewFlow(result, manager, reviewInfo!!)
            return
        }
        val request = manager.requestReviewFlow()
        request.addOnCompleteListener { task ->
            when {
                task.isSuccessful -> launchReviewFlow(result, manager, task.result)
                task.exception != null -> result.error(task.exception!!.javaClass.name, task.exception!!.localizedMessage, null)
                else -> result.success(false)
            }
        }
    }

    /**
     * Launches the review flow.
     *
     * @param result The method channel result object.
     * @param manager The review manager.
     * @param reviewInfo The review info object.
     */

    private fun launchReviewFlow(result: Result, manager: ReviewManager, reviewInfo: ReviewInfo) {
        val flow = manager.launchReviewFlow(activity!!, reviewInfo)
        flow.addOnCompleteListener { task ->
            run {
                this.reviewInfo = null
                result.success(task.isSuccessful)
            }
        }
    }

    /**
     * Returns whether the Play Store is installed on the current device.
     *
     * @return Whether the Play Store is installed on the current device.
     */

    private fun isPlayStoreInstalled(): Boolean {
        return try {
            activity!!.packageManager.getPackageInfo("com.android.vending", 0)
            true
        } catch (ex: PackageManager.NameNotFoundException) {
            false
        }
    }

    /**
     * Launches a Play Store instance.
     *
     * @param applicationId The application ID.
     *
     * @return 0 if everything is okay, 1 if the Play Store has not been opened, but the URL has been launched and 2 if it's not possible to open any of them.
     */

    private fun goToPlayStore(applicationId: String?): Int {
        if (activity == null) {
            return 2
        }

        val id: String = applicationId ?: activity!!.applicationContext.packageName

        val marketIntent = Intent(Intent.ACTION_VIEW, Uri.parse("market://details?id=$id"))
        if (marketIntent.resolveActivity(activity!!.packageManager) != null) {
            activity!!.startActivity(marketIntent)
            return 0
        }

        val browserIntent = Intent(Intent.ACTION_VIEW, Uri.parse("https://play.google.com/store/apps/details?id=$id"))
        if (browserIntent.resolveActivity(activity!!.packageManager) != null) {
            activity!!.startActivity(browserIntent)
            return 1
        }

        return 2
    }
}
