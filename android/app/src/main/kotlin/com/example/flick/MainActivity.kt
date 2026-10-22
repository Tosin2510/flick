package com.example.flick
import android.content.pm.ApplicationInfo
import io.flutter.embedding.android.FlutterActivity
import android.content.pm.PackageManager
import android.os.Build
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
  private val channelName = "com.example.flick/apk_path"

  override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, channelName)
           .setMethodCallHandler {call, result -> 
           when(call.method) {
            "getApkPath" -> {
              val packageName = call.argument<String>("packageName")
              if (packageName.isNullOrEmpty()) {
                result.error("INVALID_ARGUMENT", "packageName is required", null)
                  return@setMethodCallHandler
              }

              try {
                val info = getAppInfo(packageName)
                val paths = mutableListOf(info.sourceDir)
                info.splitSourceDirs?.let { paths.addAll(it) }
                result.success(paths)
              } catch(e: PackageManager.NameNotFoundException) {
                result.error("NOT_FOUND", "App not found: $packageName", null)
              } catch (e : Exception) {
                result.error("ERROR", e.message, null)
              }
            }

            "getInstalledApps" -> {
              try {
                val apps = packageManager.getInstalledApplications(0)
                  .filter { (it.flags and ApplicationInfo.FLAG_SYSTEM) == 0 }
                  .map {
                     mapOf(
                      "name" to packageManager.getApplicationLabel(it).toString(),
                      "packageName" to it.packageName,
                      "path" to it.sourceDir
                  )
              }

              result.success(apps)
            } catch (e: Exception) {
              result.error("ERROR", e.message, null)
            }
           }
           else -> result.notImplemented()
           }
        }
  }

  private fun getAppInfo(packageName: String): ApplicationInfo {
    return if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
        packageManager.getApplicationInfo(
            packageName,
            PackageManager.ApplicationInfoFlags.of(0)
        )
    } else {
        @Suppress("DEPRECATION")
        packageManager.getApplicationInfo(packageName, 0)
    }
 }
}
