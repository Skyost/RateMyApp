package fr.skyost.rate_my_app;

import android.app.Activity;
import android.content.Intent;
import android.net.Uri;

import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.PluginRegistry.Registrar;

/**
 * RateMyAppPlugin
 */
public class RateMyAppPlugin implements MethodCallHandler {

	/**
	 * Plugin registrar.
	 */

	private final Registrar registrar;

	/**
	 * Plugin registration.
	 */

	public static void registerWith(Registrar registrar) {
		final MethodChannel channel = new MethodChannel(registrar.messenger(), "rate_my_app");
		channel.setMethodCallHandler(new RateMyAppPlugin(registrar));
	}

	/**
	 * Creates a new Rate my app plugin instance.
	 *
	 * @param registrar The registrar.
	 */

	public RateMyAppPlugin(final Registrar registrar) {
		this.registrar = registrar;
	}

	@Override
	public void onMethodCall(MethodCall call, Result result) {
		final String method = call.method;
		if(method.equals("launchStore")) {
			goToPlayStore(call.argument("appId") == null ? registrar.activity().getApplicationContext().getPackageName() : call.argument("appId").toString());
			result.success(true);
			return;
		}

		result.notImplemented();
	}

	/**
	 * Launches a Play Store instance.
	 *
	 * @param applicationId The application ID.
	 */

	private void goToPlayStore(final String applicationId) {
		final Activity activity = registrar.activity();
		try {
			activity.startActivity(new Intent(Intent.ACTION_VIEW, Uri.parse("market://details?id=" + applicationId)));
		}
		catch(android.content.ActivityNotFoundException ex) {
			activity.startActivity(new Intent(Intent.ACTION_VIEW, Uri.parse("https://play.google.com/store/apps/details?id=" + applicationId)));
		}
	}

}
