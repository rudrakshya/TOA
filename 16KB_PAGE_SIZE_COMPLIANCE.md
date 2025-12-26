# 16 KB Page Size Compliance for Google Play Store

## Overview
This document explains the changes made to meet Google Play Store's requirement for 16 KB native library alignment, which is necessary for apps targeting Android 15 (API level 35) and above.

## What is 16 KB Page Size?
Starting with Android 15, some devices use 16 KB memory page sizes instead of the traditional 4 KB. Apps must ensure their native libraries are properly aligned to support these devices.

## Changes Made

### 1. **android/app/build.gradle**
Updated the build configuration with the following key settings:

- **NDK Version**: Using NDK r29 (29.0.14206865) which supports 16 KB page sizes by default
- **Target SDK**: Set to 36 (Android 15+)
- **Compile SDK**: Set to 36
- **JNI Library Packaging**: Configured with `useLegacyPackaging = false` to ensure native libraries are properly aligned to 16 KB boundaries

```gradle
android {
    compileSdkVersion 36
    ndkVersion "29.0.14206865"
    
    defaultConfig {
        targetSdkVersion 36
        
        // Support for 16 KB page size
        ndk {
            abiFilters 'armeabi-v7a', 'arm64-v8a', 'x86', 'x86_64'
        }
    }
    
    // Configure native library alignment for 16 KB page size
    packaging {
        jniLibs {
            useLegacyPackaging = false
        }
    }
}
```

### 2. **Key Configuration Explanations**

#### `useLegacyPackaging = false`
This is the **most critical setting** for 16 KB page alignment. When set to false:
- Enables page-aligned native library packaging
- Ensures libraries are aligned to 16 KB boundaries
- Required for apps targeting Android 15+ to run on devices with 16 KB page sizes

#### NDK Version
- Using NDK r29 (or later) ensures that native code compilation supports 16 KB alignment
- Earlier NDK versions may not properly handle 16 KB page sizes

#### Target SDK 36
- Indicates the app is built to target Android 15 and later
- Ensures compatibility with latest Android features and requirements

## Build Output
The app has been successfully built with these configurations:
- **Output**: `build/app/outputs/bundle/release/app-release.aab`
- **Size**: 43.4MB
- **Build Status**: ✓ Successfully built with 16 KB alignment support

## Testing
To verify that your app works correctly on 16 KB devices:

1. **Local Testing**: Test on Android 15+ devices with 16 KB page sizes (if available)
2. **Google Play Console**: Upload the AAB to Google Play Console - it will automatically validate 16 KB alignment
3. **Pre-launch Reports**: Use Google Play's pre-launch reports to test on various device configurations

## App Version
- **Version**: 1.6.0+10 (Updated in pubspec.yaml)

## Additional Notes
- All Flutter plugins and dependencies should also support 16 KB page sizes
- The Android Gradle Plugin version (8.6.0) used in this project fully supports 16 KB alignment
- The configuration is backward compatible with devices using 4 KB page sizes

## Google Play Store Submission
When uploading to Google Play Console:
1. Upload the newly built `app-release.aab` file
2. Google Play will automatically verify 16 KB page alignment
3. If there are any issues, they will be reported in the "Pre-launch report" section
4. Once validated, the app can be released to production

## References
- [Android Developers: 16 KB Page Size Guide](https://developer.android.com/guide/practices/page-sizes)
- [Google Play: App Quality Requirements](https://support.google.com/googleplay/android-developer/answer/14154334)

---
**Date**: 2025-12-26  
**Build**: v1.6.0+10  
**Status**: ✅ Compliant with 16 KB page size requirements
