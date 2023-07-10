// You have generated a new plugin project without specifying the `--platforms`
// flag. A plugin project with no platform support was generated. To add a
// platform, run `flutter create -t plugin --platforms <platforms> .` under the
// same directory. You can also find a detailed instruction on how to add
// platforms in the `pubspec.yaml` at
// https://flutter.dev/docs/development/packages-and-plugins/developing-packages#plugin-platforms.

import 'package:flutter/services.dart';

import 'file_type.dart';

//export file type enum
export 'package:flutter_social_platform_share_plugin/file_type.dart';

typedef OnCancelHandler = Future<void> Function();
typedef OnErrorHandler = Future<void> Function(String error);
typedef OnSuccessHandler = Future<void> Function(String postId);

class FlutterSocialPlatformSharePlugin {
  final MethodChannel _channel = const MethodChannel('flutter_social_platform_share_plugin');

  static const String _methodWhatsApp = 'whatsapp_share';
  static const String _methodWhatsAppPersonal = 'whatsapp_personal';
  static const String _methodWhatsAppBusiness = 'whatsapp_business_share';
  static const String _methodFaceBook = 'facebook_share';
  static const String _methodFaceBookURL = 'facebook_share_url';
  static const String _methodMessenger = 'messenger_share';
  static const String _methodTwitter = 'twitter_share';
  static const String _methodInstagramShare = 'instagram_share';
  static const String _methodSystemShare = 'system_share';
  static const String _methodTelegramShare = 'telegram_share';

  ///share to WhatsApp
  /// [imagePath] is local image
  /// [phoneNumber] enter phone number with counry code
  /// For ios
  /// If include image then text params will be ingored as there is no current way in IOS share both at the same.
  Future<String?> shareToWhatsApp({String msg = '', String imagePath = '', FileType? fileType = FileType.image}) async {
    final Map<String, dynamic> arguments = <String, dynamic>{};
    arguments.putIfAbsent('msg', () => msg);
    arguments.putIfAbsent('url', () => imagePath);
    if (fileType == FileType.image) {
      arguments.putIfAbsent('fileType', () => 'image');
    } else {
      arguments.putIfAbsent('fileType', () => 'video');
    }

    String? result;
    try {
      result = await _channel.invokeMethod<String>(_methodWhatsApp, arguments);
    } catch (e) {
      return e.toString();
    }

    return result;
  }

  ///share to WhatsApp
  /// [phoneNumber] phone number with counry code
  /// [msg] message text you want on whatsapp
  Future<String?> shareWhatsAppPersonalMessage({required String message, required String phoneNumber}) async {
    final Map<String, dynamic> arguments = <String, dynamic>{};
    arguments.putIfAbsent('msg', () => message);
    arguments.putIfAbsent('phoneNumber', () => phoneNumber);

    String? result;
    try {
      result = await _channel.invokeMethod<String>(_methodWhatsAppPersonal, arguments);
    } catch (e) {
      return e.toString();
    }

    return result;
  }

  ///share to Telegram
  /// [msg] message text you want on telegram
  Future<String?> shareToTelegram({required String msg}) async {
    final Map<String, dynamic> arguments = <String, dynamic>{};
    arguments.putIfAbsent('msg', () => msg);
    String? result;
    try {
      result = await _channel.invokeMethod<String>(_methodTelegramShare, arguments);
    } catch (e) {
      return e.toString();
    }
    return result;
  }

  ///share to WhatsApp4Biz
  ///[imagePath] is local image
  /// For ios
  /// If include image then text params will be ingored as there is no current way in IOS share both at the same.
  Future<String?> shareToWhatsApp4Biz({String msg = '', String? imagePath = ''}) async {
    final Map<String, dynamic> arguments = <String, dynamic>{};

    arguments.putIfAbsent('msg', () => msg);
    arguments.putIfAbsent('url', () => imagePath);
    String? result;
    try {
      result = await _channel.invokeMethod<String>(_methodWhatsAppBusiness, arguments);
    } catch (e) {
      return 'false';
    }

    return result;
  }

  Future<dynamic> shareToFeedFacebook({
    String? caption,
    required String path,
    OnSuccessHandler? onSuccess,
    OnCancelHandler? onCancel,
    OnErrorHandler? onError,
  }) async {
    _channel.setMethodCallHandler((call) {
      switch (call.method) {
        case "onSuccess":
          return onSuccess != null ? onSuccess(call.arguments) : Future.value();
        case "onCancel":
          return onCancel != null ? onCancel() : Future.value();
        case "onError":
          return onError != null ? onError(call.arguments) : Future.value();
        default:
          throw UnsupportedError("Unknown method called");
      }
    });
    final Map<String, dynamic> arguments = <String, dynamic>{};
    arguments.putIfAbsent('caption', () => caption);
    arguments.putIfAbsent('path', () => path);
    String? result;
    try {
      result = await _channel.invokeMethod(_methodFaceBook, arguments);
    } catch (e) {
      return e.toString();
    }
    return result;
  }

  Future<dynamic> shareToFeedFacebookLink({
    String? quote,
    required String url,
    OnSuccessHandler? onSuccess,
    OnCancelHandler? onCancel,
    OnErrorHandler? onError,
  }) async {
    _channel.setMethodCallHandler((call) {
      switch (call.method) {
        case "onSuccess":
          return onSuccess != null ? onSuccess(call.arguments) : Future.value();
        case "onCancel":
          return onCancel != null ? onCancel() : Future.value();
        case "onError":
          return onError != null ? onError(call.arguments) : Future.value();
        default:
          throw UnsupportedError("Unknown method called");
      }
    });
    final Map<String, dynamic> arguments = <String, dynamic>{};
    arguments.putIfAbsent('quote', () => quote);
    arguments.putIfAbsent('url', () => url);
    String? result;
    try {
      result = await _channel.invokeMethod(_methodFaceBookURL, arguments);
    } catch (e) {
      return e.toString();
    }
    return result;
  }

  ///share to messenger
  Future<String?> shareToMessenger({required String msg, String url = ''}) async {
    final Map<String, dynamic> arguments = <String, dynamic>{};
    arguments.putIfAbsent('msg', () => msg);
    arguments.putIfAbsent('url', () => url);
    String? result;
    try {
      result = await _channel.invokeMethod<String?>(_methodMessenger, arguments);
    } catch (e) {
      return e.toString();
    }
    return result;
  }

  ///share to twitter
  ///[msg] string that you want share.
  Future<String?> shareToTwitter({required String msg, String url = ''}) async {
    final Map<String, dynamic> arguments = <String, dynamic>{};
    arguments.putIfAbsent('msg', () => msg);
    arguments.putIfAbsent('url', () => url);
    String? result;
    try {
      result = await _channel.invokeMethod(_methodTwitter, arguments);
    } catch (e) {
      return e.toString();
    }
    return result;
  }

  ///use system share ui
  Future<String?> shareToSystem({required String msg}) async {
    String? result;
    try {
      result = await _channel.invokeMethod<String>(_methodSystemShare, {'msg': msg});
    } catch (e) {
      return 'false';
    }
    return result;
  }

  ///share file to instagram
  Future<String?> shareToInstagram({required String filePath, FileType fileType = FileType.image}) async {
    final Map<String, dynamic> arguments = <String, dynamic>{};
    arguments.putIfAbsent('url', () => filePath);
    if (fileType == FileType.image) {
      arguments.putIfAbsent('fileType', () => 'image');
    } else {
      arguments.putIfAbsent('fileType', () => 'video');
    }
    String? result;

    try {
      result = await _channel.invokeMethod<String>(_methodInstagramShare, arguments);
    } catch (e) {
      return e.toString();
    }
    return result;
  }
}
