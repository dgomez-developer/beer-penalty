# Beer Penalty App

Flutter app for the beer penalty board (Android, iOS, Web)

## How to deploy web on Firebase Hosting Service

### Requeriments:

* [Firebase CLI](https://firebase.google.com/docs/cli?hl=vi)
* Firebase project with the [web client config setup](https://firebase.google.com/docs/web/setup).

### Steps:

Create a file `FirebaseConfig.js` in the folder `web` and fill in the file with the json provided by firebase for your web client:
```
var firebase_config =
{
  "apiKey": <YOUR_API_KEY>,
  "authDomain": <YOUR_AUTH_DOMAIN>,
  "databaseURL": <YOUR_DB_URL>,
  "projectId": <YOUR_PROJECT_ID>,
  "storageBucket": <YOUR_STORAGE_ID>,
  "messagingSenderId": <YOUR_SENDER_ID>,
  "appId": <YOUR_APP_ID>,
  "measurementId": <YOUR_MEASUREMENT_ID>
};
```

Login in firebase:

```
firebase login (--reauth)
```

Init firebase in the root folder:

```
firebase init
```

Select the hosting option, your existing project & set the folder build/web as root folder for the deployments.

```
flutter build web
```

This will create abuild/web folder where all the files will be located.

```
firebase deploy
```

Click on the link provided when the deployment is finished to check your web =)

**DO NOT FORGET**: to add the `FirebaseConfig.js` file to your `.gitignore` if you do not want to push your client credentials.

## Distributing BETAs via Firebase

### Requirements:

* [Fastlane](https://docs.fastlane.tools/)
* Firebase project with [Android & iOS clients config setup](https://firebase.google.com/docs/flutter/setup?platform=android)
* Apple developer account (only iOS distribution)

### Android

Enter in the `android` folder & execute:
```
fastlane init
```
You can either choose to already specify your package name or skip it and do it later manually. You can check it in the `AndroidManifest.xml` file.

This will generate a folder `fastlane` under the `android` folder.

Install the firebase distribution plugin:
```
fastlane add_plugin firebase_app_distribution
```

**TROUBLE SHOOTING**: If you get an error saying that there are packages missing, execute the following comand to download the missing packages:
```
bundle install
```

Go to the firebase console and click on the **Distribution** section and with the Android app selected, click on the **Get started** button.

Remove the initial configuration provided in the `Fastfile` and copy the following:

```
default_platform(:android)

platform :android do
    desc "Script to automate app distribution"
    gradle(
        task: 'assemble',
        build_type: 'Release'
    )
    lane :android_beta_app do
        firebase_app_distribution(
            app: ENV['APP_ID'],
            groups: "<YOUR_GROUPS>",
            release_notes: "First version",
            firebase_cli_path: "/usr/local/bin/firebase",
            apk_path: "../build/app/outputs/apk/release/app-release.apk"
        )
    end
end
```
As you can see the `APP_ID` is an environment variable. I choose to use the [dotenv](https://docs.fastlane.tools/best-practices/keys/) fastlane plugin.

Install the gem:
```
gem install dotenv
```

Create a `.env` file with your `APP_ID` specified:

```
APP_ID="<YOUR_APP_ID"
```

Execute the following command to distribute a BETA:

```
bundle exec fastlane android_beta_app
```

**DO NOT FORGET**: to add the `.env` file to your `.gitignore` if you do not want to push your client credentials.

## iOS

Enter in the `ios` folder & execute:
```
fastlane init
```
You can either choose to already specify your bundle ID & apple account or skip it and do it later manually. You can check it by opening the project in xcode and clicking on Runner target > General > Identifity section.

This will generate a folder `fastlane` under the `android` folder.

Install the firebase distribution plugin:
```
fastlane add_plugin firebase_app_distribution
```

**TROUBLE SHOOTING**: If you get an error saying that there are packages missing, execute the following comand to download the missing packages:
```
bundle install
```

Go to the firebase console and click on the **Distribution** section and with the iOS app selected, click on the **Get started** button.

Remove the initial configuration provided in the `Fastfile` and copy the following:

```
default_platform(:ios)

platform :ios do
  desc "Script to automate app distribution"
    lane :ios_beta_app do
        build_app(
            scheme: "Runner",
            archive_path: "./build/Runner.xcarchive",
            export_method: "development",
            output_directory: "./build/Runner"
        )
        firebase_app_distribution(
            app: ENV['APP_ID'],
            groups: "<YOUR_GROUPS>",
            release_notes: "Initial test version of the app",
            firebase_cli_path: "/usr/local/bin/firebase",
            ipa_path: "./build/Runner/Runner.ipa"
        )
    end
end
```
As you can see the `APP_ID` is an environment variable. I choose to use the [dotenv](https://docs.fastlane.tools/best-practices/keys/) fastlane plugin.

Install the gem:
```
gem install dotenv
```

Create a `.env` file with your `APP_ID` specified:

```
APP_ID="<YOUR_APP_ID"
```

Open the project in xcode and specify your Apple Development team under the **target Runner > Signing & Capabilities > Signing > Team**

You can follow [this article](https://medium.com/multinetinventiv/introduction-to-firebase-app-distribution-in-ios-93298d59c658) if it is the first time you set this up.

Execute the following command to distribute a BETA:

```
bundle exec fastlane ios_beta_app
```

**DO NOT FORGET**: to add the `.env` file to your `.gitignore` if you do not want to push your client credentials.

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
 * [Introduction to Firebase App Distribution in iOS](https://medium.com/multinetinventiv/introduction-to-firebase-app-distribution-in-ios-93298d59c658)
 * [Deploying Flutter app to Firebase App Distribution using Fastlane](https://blog.codemagic.io/deploying-flutter-app-to-firebase-app-distribution-using-fastlane/)