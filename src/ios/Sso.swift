import Foundation
import LineSDK
import TwitterKit

@objc(Sso) class Sso : CDVPlugin, LineSDKLoginDelegate {
    
    var callbackId:String?
    

    override func pluginInitialize() {

        LineSDKLogin.sharedInstance().delegate = self
        // let result = CDVPluginResult(status: CDVCommandStatus_OK)
        // commandDelegate.send(result, callbackId:command.callbackId)

        let consumerKey = self.commandDelegate.settings["twitterconsumerkey"] as? String)
        let consumerSecret = self.commandDelegate.settings["twitterconsumersecret"] as? String
        
        Twitter.sharedInstance().start(withConsumerKey: consumerKey!, consumerSecret: consumerSecret!);
    }

    func loginWithLine(_ command: CDVInvokedUrlCommand) {
        self.callbackId = command.callbackId
        LineSDKLogin.sharedInstance().start()
    }

    func loginWithTwitter(_ command: CDVInvokedUrlCommand) {
        self.callbackId = command.callbackId
        Twitter.sharedInstance().logIn(completion: { (session, error) in
            if (session != nil) {
                var data = ["userName": nil, "userId": nil, "secret": nil, "token": nil] as [String: Any?]
                if let userName = session?.userName {
                    data.updateValue(userName, forKey: "userName")
                }
                if let userID = session?.userID {
                    data.updateValue(userID, forKey: "userId")
                }
                if let secret = session?.authTokenSecret {
                    data.updateValue(secret, forKey: "secret")
                }
                if let token = session?.authToken {
                    data.updateValue(token, forKey: "token")
                }

                let result = CDVPluginResult(status: CDVCommandStatus_OK, messageAs: data)
                self.commandDelegate.send(result, callbackId:self.callbackId)
            } else {
                let result = CDVPluginResult(status: CDVCommandStatus_ERROR, messageAs: error.debugDescription)
                self.commandDelegate.send(result, callbackId:self.callbackId)
            }
        })
    }
    
    func didLogin(_ login: LineSDKLogin, credential: LineSDKCredential?, profile: LineSDKProfile?, error: Error?) {
        
        if error != nil {
            let result = CDVPluginResult(status: CDVCommandStatus_ERROR, messageAs: error.debugDescription)
            commandDelegate.send(result, callbackId:self.callbackId)
        } else {
            var data = ["userID":nil, "displayName":nil, "pictureURL":nil, "accessToken":nil] as [String : Any?]
            if let displayName = profile?.displayName {
                data.updateValue(displayName, forKey: "displayName")
            }
            if let userID = profile?.userID {
                data.updateValue(userID, forKey: "userID")
            }
            if let pictureURL = profile?.pictureURL {
                data.updateValue(String(describing: pictureURL), forKey: "pictureURL")
            }
            if let _acessToken = credential?.accessToken?.accessToken as? String {
                data.updateValue(_acessToken, forKey: "accessToken")
            }

            let result = CDVPluginResult(status: CDVCommandStatus_OK, messageAs:data)
            commandDelegate.send(result, callbackId:self.callbackId)
        }
    }
}
