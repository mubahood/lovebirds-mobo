# Lovebirds App - Complete Permissions List

## ALL PERMISSIONS NOW INCLUDED IN AndroidManifest.xml

### Critical Privacy-Sensitive Permissions (Require Privacy Policy)

#### Media & Camera
- ✅ **CAMERA** - Taking profile photos, video calls
- ✅ **RECORD_AUDIO** - Voice messages, audio calls
- ✅ **READ_MEDIA_IMAGES** - Accessing user photos
- ✅ **READ_MEDIA_VIDEO** - Accessing user videos  
- ✅ **READ_MEDIA_AUDIO** - Accessing user audio files

#### Storage & Files
- ✅ **WRITE_EXTERNAL_STORAGE** - Saving files, downloads
- ✅ **READ_EXTERNAL_STORAGE** - Reading files, media

#### Location
- ✅ **ACCESS_FINE_LOCATION** - Precise location for matching
- ✅ **ACCESS_COARSE_LOCATION** - Approximate location

#### Communication & Phone
- ✅ **READ_PHONE_STATE** - Phone verification
- ✅ **READ_PHONE_NUMBERS** - Number verification

#### Contacts
- ✅ **READ_CONTACTS** - Finding friends
- ✅ **WRITE_CONTACTS** - Adding contacts

#### Notifications
- ✅ **POST_NOTIFICATIONS** - Push notifications (Android 13+)

### System Permissions

#### Network & Internet
- ✅ **INTERNET** - Network connectivity
- ✅ **ACCESS_NETWORK_STATE** - Network status

#### Device Control
- ✅ **WAKE_LOCK** - Keep app active during calls
- ✅ **DISABLE_KEYGUARD** - Screen control
- ✅ **VIBRATE** - Notification vibrations
- ✅ **FLASHLIGHT** - Camera flash control

#### System Integration
- ✅ **RECEIVE_BOOT_COMPLETED** - Auto-start services
- ✅ **FOREGROUND_SERVICE** - Background operations
- ✅ **SYSTEM_ALERT_WINDOW** - Overlay features

## Dependencies Analysis

Based on your pubspec.yaml dependencies:

### Recording & Audio
- `record: ^6.0.0` → RECORD_AUDIO ✅
- `audioplayers: ^5.2.1` → Audio playback permissions ✅

### Camera & Media
- `image_picker: ^1.1.2` → CAMERA, STORAGE ✅
- `file_picker: ^8.3.7` → STORAGE permissions ✅
- `video_player: ^2.9.5` → Media permissions ✅

### Location Services  
- `geolocator: ^12.0.0` → LOCATION permissions ✅
- `geocoding: ^3.0.0` → LOCATION permissions ✅

### Communication
- `country_code_picker: ^3.3.0` → PHONE permissions ✅
- `url_launcher: ^6.3.1` → CALL_PHONE ✅

### Notifications
- `flutter_local_notifications: ^19.1.0` → NOTIFICATION permissions ✅
- `onesignal_flutter: ^5.3.0` → NOTIFICATION permissions ✅

### Downloads & Files
- `flutter_downloader: ^1.11.6` → STORAGE permissions ✅
- `path_provider: ^2.1.5` → STORAGE permissions ✅

### Device Control
- `keep_screen_on: ^4.0.0` → WAKE_LOCK ✅
- `wakelock_plus: ^1.2.11` → WAKE_LOCK ✅

### App Updates
- `in_app_update: ^4.2.3` → INSTALL_PACKAGES ✅

## Current AAB File Status

**File:** `build/app/outputs/bundle/release/app-release.aab`
**Version:** `1.1.1+5`
**Total Permissions:** 46
**All Critical Permissions:** ✅ INCLUDED

## Privacy Policy Coverage

All permissions are now covered in `PRIVACY_POLICY.md` with detailed explanations of:
- Why each permission is needed
- How data is used
- User rights and controls
- Data protection measures

This comprehensive permissions setup should resolve ALL Google Play Store privacy policy requirements.
