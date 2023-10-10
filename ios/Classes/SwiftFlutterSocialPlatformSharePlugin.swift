import Flutter
import UIKit
import FBSDKShareKit
import FBSDKCoreKit
import PhotosUI

public class SwiftFlutterSocialPlatformSharePlugin: NSObject, FlutterPlugin, SharingDelegate {
    
    let _methodWhatsApp = "whatsapp_share";
    let _methodWhatsAppPersonal = "whatsapp_personal";
    let _methodWhatsAppBusiness = "whatsapp_business_share";
    let _methodFaceBook = "facebook_share";
    let _methodFaceBookLink = "facebook_share_url";
    let _methodTwitter = "twitter_share";
    let _methodInstagram = "instagram_share";
    let _methodSystemShare = "system_share";
    let _methodTelegramShare = "telegram_share";
    // let _fbAppId = Bundle.main.object(forInfoDictionaryKey: "FacebookAppID") as? String
    
    var result: FlutterResult?
    var documentInteractionController: UIDocumentInteractionController?
    
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "flutter_social_platform_share_plugin", binaryMessenger: registrar.messenger())
        let instance = SwiftFlutterSocialPlatformSharePlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
    }
    
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        self.result = result
        switch call.method {
            case _methodWhatsApp:
                let args = call.arguments as? Dictionary<String,Any>
                if args!["url"] as! String == "" {
                    // if don't pass url then pass blank so if can strat normal whatsapp
                    shareWhatsApp(message: args!["msg"] as! String,imageUrl: "",type: args!["fileType"] as! String,result: result)
                }else{
                    // if user pass url then use that
                    shareWhatsApp(message: args!["msg"] as! String,imageUrl: args!["url"] as! String,type: args!["fileType"] as! String,result: result)
                }
            case _methodWhatsAppBusiness:
                // There is no way to open WB in IOS.
                result(FlutterMethodNotImplemented)
                
                //            let args = call.arguments as? Dictionary<String,Any>
                //
                //            if args!["url"]as! String == "" {
                //                // if don't pass url then pass blank so if can strat normal whatsapp
                //                shareWhatsApp4Biz(message: args!["msg"] as! String, result: result)
                //            }else{
                //                // if user pass url then use that
                //                // wil open share sheet and user can select open for there.
                //                //                shareWhatsApp(message: args!["msg"] as! String,imageUrl: args!["url"] as! String,result: result)
                //            }
            case _methodWhatsAppPersonal:
                let args = call.arguments as? Dictionary<String,Any>
                shareWhatsAppPersonal(message: args!["msg"]as! String, phoneNumber: args!["phoneNumber"]as! String, result: result)
            case _methodFaceBook:
                guard let args = call.arguments else {
                    result(false)
                    break
                }
                if let myArgs = args as? [String: Any],
                let path = myArgs["path"] as? String
                {
                    let fbURL = URL(string: "fbapi://")
                    if let fbURL = fbURL {
                        if UIApplication.shared.canOpenURL(fbURL) {
                            facebookShare(path, result: result)
                            // result(nil)
                        } else {
                            let fbLink = "itms-apps://itunes.apple.com/us/app/apple-store/id284882215"
                            if #available(iOS 10.0, *) {
                                if let url = URL(string: fbLink) {
                                    UIApplication.shared.open(url, options: [:]) { _ in
                                    }
                                }
                            } else {
                                if let url = URL(string: fbLink) {
                                    UIApplication.shared.openURL(url)
                                    result("Success")
                                }
                            }
                            result(false)
                        }
                    }
                } else {
                    result(false)
                }
                // let args = call.arguments as? Dictionary<String,Any>
                // sharefacebook(message: args!, result: result)
            case _methodFaceBookLink:
                guard let args = call.arguments else {
                    result(false)
                    break
                }
                if let myArgs = args as? [String: Any],
                let quote = myArgs["quote"] as? String,
                let url = myArgs["url"] as? String
                {
                    let fbURL = URL(string: "fbapi://")
                    if let fbURL = fbURL {
                        if UIApplication.shared.canOpenURL(fbURL) {
                            facebookShareLink(quote, url: url, result: result)
                        } else {
                            let fbSafariLink = "https://m.facebook.com/sharer/sharer.php?/" +"u=" + (url ?? "")
                            if let fbUrl = URL(string: fbSafariLink) {
                                if UIApplication.shared.canOpenURL(fbUrl) {
                                    UIApplication.shared.openURL(fbUrl)
                                    result("Success")
                                }
                            }
                            result(false)
                        }
                    }
                } else {
                    result(false)
                }
            case _methodTwitter:
                let args = call.arguments as? Dictionary<String,Any>
                shareTwitter(message: args!["msg"] as! String, url: args!["url"] as! String, result: result)
            case _methodInstagram:
                let args = call.arguments as? Dictionary<String,Any>
                shareInstagram(args: args!)
            case _methodTelegramShare:
                let args = call.arguments as? Dictionary<String,Any>
                shareToTelegram(message: args!["msg"] as! String, result: result )
            case _methodSystemShare:
                let args = call.arguments as? Dictionary<String,Any>
                systemShare(message: args!["msg"] as! String,result: result)
            default:
                break
        }
    }
    
    
    func shareWhatsApp(message:String, imageUrl:String,type:String,result: @escaping FlutterResult)  {
        // @ For ios
        // we can't set both if you pass image then text will ignore
        var whatsURL = ""
        if(imageUrl==""){
            whatsURL = "whatsapp://send?text=\(message)"
        }else{
            whatsURL = "whatsapp://app"
        }
        
        var characterSet = CharacterSet.urlQueryAllowed
        characterSet.insert(charactersIn: "?&")
        let whatsAppURL  = NSURL(string: whatsURL.addingPercentEncoding(withAllowedCharacters: characterSet)!)
        if UIApplication.shared.canOpenURL(whatsAppURL! as URL)
        {
            if(imageUrl==""){
                //mean user did not pass image url  so just got with text message
                result("Sucess");
                UIApplication.shared.openURL(whatsAppURL! as URL)
                
            }
            else{
                //this is whats app work around so will open system share and exclude other share types
                let viewController = UIApplication.shared.delegate?.window??.rootViewController
                let urlData:Data
                let filePath:URL
                if(type=="image"){
                    let image = UIImage(named: imageUrl)
                    if(image==nil){
                        result("File format not supported Please check the file.")
                        return;
                    }
                    //urlData=UIImageJPEGRepresentation(image!, 1.0)!
                    urlData = image!.jpegData(compressionQuality: 1.0)!
                    filePath=URL(fileURLWithPath:NSHomeDirectory()).appendingPathComponent("Documents/whatsAppTmp.wai")
                }else{
                    filePath=URL(fileURLWithPath:NSTemporaryDirectory()).appendingPathComponent("video.m4v")
                    urlData = NSData(contentsOf: URL(fileURLWithPath: imageUrl))! as Data
                }
                
                let tempFile = filePath
                do{
                    try urlData.write(to: tempFile, options: .atomic)
                    // image to be share
                    let imageToShare = [tempFile]
                    
                    let activityVC = UIActivityViewController(activityItems: imageToShare, applicationActivities: nil)
                    // we want to exlude most of the things so developer can see whatsapp only on system share sheet
                    activityVC.excludedActivityTypes = [UIActivity.ActivityType.airDrop,UIActivity.ActivityType.message, UIActivity.ActivityType.mail,UIActivity.ActivityType.postToTwitter,UIActivity.ActivityType.postToWeibo,UIActivity.ActivityType.print,UIActivity.ActivityType.openInIBooks,UIActivity.ActivityType.postToFlickr,UIActivity.ActivityType.postToFacebook,UIActivity.ActivityType.addToReadingList,UIActivity.ActivityType.copyToPasteboard,UIActivity.ActivityType.postToFacebook]
                    
                    viewController!.present(activityVC, animated: true, completion: nil)
                    result("Sucess");
                    
                }catch{
                    print(error)
                }
            }
            
        }
        else
        {
            result(FlutterError(code: "Not found", message: "WhatsApp is not found", details: "WhatsApp not intalled or Check url scheme."));
        }
    }
    
    
    // Send whatsapp personal message
    // @ message
    // @ phone with contry code.
    func shareWhatsAppPersonal(message:String, phoneNumber:String,result: @escaping FlutterResult)  {
        
        let whatsURL = "whatsapp://send?phone=\(phoneNumber)&text=\(message)"
        var characterSet = CharacterSet.urlQueryAllowed
        characterSet.insert(charactersIn: "?&")
        let whatsAppURL  = NSURL(string: whatsURL.addingPercentEncoding(withAllowedCharacters: characterSet)!)
        if UIApplication.shared.canOpenURL(whatsAppURL! as URL)
        {
            UIApplication.shared.openURL(whatsAppURL! as URL)
            result("Sucess");
        }else{
            result(FlutterError(code: "Not found", message: "WhatsApp is not found", details: "WhatsApp not intalled or Check url scheme."));
        }
    }
    
    func shareWhatsApp4Biz(message:String, result: @escaping FlutterResult)  {
        let whatsApp = "https://wa.me/?text=\(message)"
        var characterSet = CharacterSet.urlQueryAllowed
        characterSet.insert(charactersIn: "?&")
        
        let whatsAppURL  = NSURL(string: whatsApp.addingPercentEncoding(withAllowedCharacters: characterSet)!)
        if UIApplication.shared.canOpenURL(whatsAppURL! as URL)
        {
            result("Sucess");
            UIApplication.shared.openURL(whatsAppURL! as URL)
        }
        else
        {
            result(FlutterError(code: "Not found", message: "WhatsAppBusiness is not found", details: "WhatsAppBusiness not intalled or Check url scheme."));
        }
    }
    // share twitter
    // params
    // @ map conting meesage and url
    
    func sharefacebook(message:Dictionary<String,Any>, result: @escaping FlutterResult)  {
        let viewController = UIApplication.shared.delegate?.window??.rootViewController
        //let shareDialog = ShareDialog()
        let shareContent = ShareLinkContent()
        shareContent.contentURL = URL.init(string: message["url"] as! String)!
        shareContent.quote = message["msg"] as? String
        
        let shareDialog = ShareDialog(viewController: viewController, content: shareContent, delegate: self)
        shareDialog.mode = .automatic
        shareDialog.show()
        result("Sucess")
        
    }

    func facebookShare(_ imagePath: String?, result: @escaping FlutterResult) {
        // NSURL* path = [[NSURL alloc] initWithString:call.arguments[@"path"]];
        if let image = UIImage(contentsOfFile: imagePath ?? "") {
            let photo = SharePhoto(image: image, isUserGenerated: true)
            let content = SharePhotoContent()
            content.photos = [photo]
            let controller = UIApplication.shared.delegate?.window??.rootViewController
            ShareDialog.show(viewController: controller, content: content, delegate: self)
            result("Facebook Share Success")
        }
    }

    func facebookShareLink(_ quote: String, url: String, result: @escaping FlutterResult) {
        let content = ShareLinkContent()
        content.contentURL = URL(string: url)
        content.quote = quote as? String
        let controller = UIApplication.shared.delegate?.window??.rootViewController
        let shareDialog = ShareDialog(viewController: controller, content: content, delegate: self)
        shareDialog.mode = .automatic
        shareDialog.show()
        result("Facebook Share URL Success")
    }
    
    // share twitter params
    // @ message
    // @ url
    func shareTwitter(message:String,url:String, result: @escaping FlutterResult)  {
        let urlstring = url
        let twitterUrl =  "twitter://post?message=\(message)"
        
        let urlTextEscaped = urlstring.addingPercentEncoding(withAllowedCharacters: .urlFragmentAllowed)
        let url = URL(string: urlTextEscaped ?? "")
        
        let urlWithLink = twitterUrl + url!.absoluteString
        
        let escapedShareString = urlWithLink.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!
        // cast to an url
        let urlschme = URL(string: escapedShareString)
        // open in safari
        do {
            if UIApplication.shared.canOpenURL(urlschme! as URL){
                UIApplication.shared.openURL(urlschme!)
                result("Sucess")
            }else{
                result(FlutterError(code: "Not found", message: "Twitter is not found", details: "Twitter not intalled or Check url scheme."));
                
            }
        }
        
    }
    //share via telegram
    //@ text that you want to share.
    func shareToTelegram(message: String,result: @escaping FlutterResult )
    {
        let telegram = "tg://msg?text=\(message)"
        var characterSet = CharacterSet.urlQueryAllowed
        characterSet.insert(charactersIn: "?&")
        let telegramURL  = NSURL(string: telegram.addingPercentEncoding(withAllowedCharacters: characterSet)!)
        if UIApplication.shared.canOpenURL(telegramURL! as URL)
        {
            result("Sucess");
            UIApplication.shared.openURL(telegramURL! as URL)
        }
        else
        {
            result(FlutterError(code: "Not found", message: "telegram is not found", details: "telegram not intalled or Check url scheme."));
        }
    
    }

    //share via system native dialog
    //@ text that you want to share.
    func systemShare(message:String,result: @escaping FlutterResult)  {
        // find the root view controller
        let viewController = UIApplication.shared.delegate?.window??.rootViewController
        
        // set up activity view controller
        // Here is the message for for sharing
        let objectsToShare = [message] as [Any]
        let activityVC = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)
        /// if want to exlude anything then will add it for future support.
        //        activityVC.excludedActivityTypes = [UIActivity.ActivityType.airDrop, UIActivity.ActivityType.addToReadingList]
        if UIDevice.current.userInterfaceIdiom == .pad {
            if let popup = activityVC.popoverPresentationController {
                popup.sourceView = viewController?.view
                popup.sourceRect = CGRect(x: (viewController?.view.frame.size.width)! / 2, y: (viewController?.view.frame.size.height)! / 4, width: 0, height: 0)
            }
        }
        viewController!.present(activityVC, animated: true, completion: nil)
        result("Sucess");
        
        
    }
    
    // share image via instagram stories.
    // @ args image url
    func shareInstagram(args:Dictionary<String,Any>)  {
        let imageUrl=args["url"] as! String
    
        let image = UIImage(named: imageUrl)
        if(image==nil){
            self.result!("File format not supported Please check the file.")
            return;
        }
        guard let instagramURL = NSURL(string: "instagram://app") else {
            if let result = result {
                self.result?("Instagram app is not installed on your device")
                result(false)
            }
            return
        }
        
        do{
            try PHPhotoLibrary.shared().performChangesAndWait {
                let request = PHAssetChangeRequest.creationRequestForAsset(from: image!)
                let assetId = request.placeholderForCreatedAsset?.localIdentifier
                let instShareUrl:String? = "instagram://library?LocalIdentifier=" + assetId!
                
                //Share image
                if UIApplication.shared.canOpenURL(instagramURL as URL) {
                    if let sharingUrl = instShareUrl {
                        if let urlForRedirect = NSURL(string: sharingUrl) {
                            if #available(iOS 10.0, *) {
                                UIApplication.shared.open(urlForRedirect as URL, options: [:], completionHandler: nil)
                            }
                            else{
                                UIApplication.shared.openURL(urlForRedirect as URL)
                            }
                        }
                        self.result?("Success")
                    }
                } else{
                    self.result?("Instagram app is not installed on your device")
                }
            }
        
        } catch {
            print("Fail")
        }
    }
    
    //Facebook delegate methods
    public func sharer(_ sharer: Sharing, didCompleteWithResults results: [String : Any]) {
        print("Share: Success")
        
    }
    
    public func sharer(_ sharer: Sharing, didFailWithError error: Error) {
        print("Share: Fail")
        
    }
    
    public func sharerDidCancel(_ sharer: Sharing) {
        print("Share: Cancel")
    }
}
