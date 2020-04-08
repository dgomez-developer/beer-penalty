# Beer Penalty App

Flutter app for the beer penalty board (Android, iOS, Web)

## Trouble shooting

### Multidex support for androidx error.

[Fix](https://stackoverflow.com/questions/26763702/didnt-find-class-android-support-multidex-multidexapplication-on-path-dexpat)

```
java.lang.RuntimeException: Unable to instantiate application android.support.multidex.MultiDexApplication: java.lang.ClassNotFoundException: Didn't find class "android.support.multidex.MultiDexApplication" on path: DexPathList[[zip file "/data/app/me.myapp.main-2.apk"],nativeLibraryDirectories=[/data/app-lib/me..main-2, /vendor/lib, /system/lib]]
    at android.app.LoadedApk.makeApplication(LoadedApk.java:507)
    at android.app.ActivityThread.handleBindApplication(ActivityThread.java:4382)
    at android.app.ActivityThread.access$1500(ActivityThread.java:139)
    at android.app.ActivityThread$H.handleMessage(ActivityThread.java:1270)
    at android.os.Handler.dispatchMessage(Handler.java:102)
    at android.os.Looper.loop(Looper.java:136)
    at android.app.ActivityThread.main(ActivityThread.java:5086)
    at java.lang.reflect.Method.invokeNative(Native Method)
    at java.lang.reflect.Method.invoke(Method.java:515)
    at com.android.internal.os.ZygoteInit$MethodAndArgsCaller.run(ZygoteInit.java:785)
    at com.android.internal.os.ZygoteInit.main(ZygoteInit.java:601)
    at dalvik.system.NativeStart.main(Native Method)
Caused by: java.lang.ClassNotFoundException: Didn't find class "android.support.multidex.MultiDexApplication" on path: DexPathList[[zip file "/data/app/me.myapp.main-2.apk"],nativeLibraryDirectories=[/data/app-lib/me.myapp.main-2, /vendor/lib, /system/lib]]
    at dalvik.system.BaseDexClassLoader.findClass(BaseDexClassLoader.java:56)
    at java.lang.ClassLoader.loadClass(ClassLoader.java:497)
    at java.lang.ClassLoader.loadClass(ClassLoader.java:457)
    at android.app.Instrumentation.newApplication(Instrumentation.java:998)
    at android.app.LoadedApk.makeApplication(LoadedApk.java:502)
```

Multidex support setup:

 * `android/app/build.gradle`: Multidex is enabled
 
 ```
defaultConfig {
    ...
    multiDexEnabled true
    
}
dependencies {
    implementation "androidx.multidex:multidex:2.0.1"
}

 ``` 

 * `android/app/src/main/AndroidManifest.xml`: Your `Application` extends `MultidexApplication`
 
```
<application
        android:name="androidx.multidex.MultiDexApplication"
        android:label="beer_penalty"
        android:icon="@mipmap/ic_launcher">
```  

In case you need to implement a custom application, check [how to support multidex](https://developer.android.com/studio/build/multidex.html) in this case.

### Error while signing in with google account.

[GitHub issue 27599](https://github.com/flutter/flutter/issues/27599)

```
E/flutter ( 5068): [ERROR:flutter/shell/common/shell.cc(184)] Dart Error: Unhandled exception:
E/flutter ( 5068): PlatformException(sign_in_failed, com.google.android.gms.common.api.ApiException: 10: , null)
E/flutter ( 5068): #0      StandardMethodCodec.decodeEnvelope (package:flutter/src/services/message_codecs.dart:551:7)
E/flutter ( 5068): #1      MethodChannel.invokeMethod (package:flutter/src/services/platform_channel.dart:292:18)
E/flutter ( 5068): <asynchronous suspension>
E/flutter ( 5068): #2      GoogleSignIn._callMethod (package:google_sign_in/google_sign_in.dart:226:58)
E/flutter ( 5068): <asynchronous suspension>
E/flutter ( 5068): #3      GoogleSignIn._addMethodCall (package:google_sign_in/google_sign_in.dart:268:20)
E/flutter ( 5068): #4      GoogleSignIn.signIn (package:google_sign_in/google_sign_in.dart:339:48)
E/flutter ( 5068): #5      ThatsMyComponentState.theSignInFuction.<anonymous closure> (package:my_app/widgets/my_file.dart:666:45)
E/flutter ( 5068): <asynchronous suspension>
E/flutter ( 5068): #6      _InkResponseState._handleTap (package:flutter/src/material/ink_well.dart:507:14)
E/flutter ( 5068): #7      _InkResponseState.build.<anonymous closure> (package:flutter/src/material/ink_well.dart:562:30)
E/flutter ( 5068): #8      GestureRecognizer.invokeCallback (package:flutter/src/gestures/recognizer.dart:102:24)
E/flutter ( 5068): #9      TapGestureRecognizer._checkUp (package:flutter/src/gestures/tap.dart:242:9)
E/flutter ( 5068): #10     TapGestureRecognizer.acceptGesture (package:flutter/src/gestures/tap.dart:204:7)
E/flutter ( 5068): #11     GestureArenaManager.sweep (package:flutter/src/gestures/arena.dart:156:27)
E/flutter ( 5068): #12     _WidgetsFlutterBinding&BindingBase&GestureBinding.handleEvent (package:flutter/src/gestures/binding.dart:184:20)
E/flutter ( 5068): #13     _WidgetsFlutterBinding&BindingBase&GestureBinding.dispatchEvent (package:flutter/src/gestures/binding.dart:158:22)
E/flutter ( 5068): #14     _WidgetsFlutterBinding&BindingBase&GestureBinding._handlePointerEvent (package:flutter/src/gestures/binding.dart:138:7)
E/flutter ( 5068): #15     _WidgetsFlutterBinding&BindingBase&GestureBinding._flushPointerEventQueue (package:flutter/src/gestures/binding.dart:101:7)
E/flutter ( 5068): #16     _WidgetsFlutterBinding&BindingBase&GestureBinding._handlePointerDataPacket (package:flutter/src/gestures/binding.dart:85:7)
E/flutter ( 5068): #17     _invoke1 (dart:ui/hooks.dart:168:13)
E/flutter ( 5068): #18     _dispatchPointerDataPacket (dart:ui/hooks.dart:122:5)
```

Make sure you added your SHA1 and your SHA 256 to your firebase projects and download the new version of the `google-services.json`.

In case you are wondering how to get the debug keys:
```
keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android -keypass android
```
For the release flavor, please generate a [custom one](https://developer.android.com/studio/publish/app-signing.html)

## References

 * [Easy Push Notifications with Flutter and Firebase Cloud Messaging](https://medium.com/@SebastianEngel/easy-push-notifications-with-flutter-and-firebase-cloud-messaging-d96084f5954f)
