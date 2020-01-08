//
//  UserManagement.swift
//  StreetTagged
//
//  Created by John O'Sullivan on 9/22/19.
//  Copyright © 2019 John O'Sullivan. All rights reserved.
//

import Foundation
import UIKit
import AWSMobileClient
import AWSCore

// Enum for the different state managament
enum UserAuthState {
    case userGuest
    case userSignedIn
    case userSignedOut
    case userSignedOutUserPoolsTokenInvalid
    case userSignedOutFederatedTokensInvalid
    case userStateUnknown
}

// Globals for the iOS App
var userGlobalState: UserAuthState = .userGuest
var isLogs = true

typealias GetTokenCompletionHandler = (_ token:Optional<String>) -> Void
typealias GetSubCompletionHandler = (_ sub:Optional<String>) -> Void

func userStateInitialize(enabledLogs: Bool, responder: UIResponder) {
    isLogs = enabledLogs
    if (isLogs) {
        AWSDDLog.sharedInstance.logLevel = .verbose
        AWSDDLog.sharedInstance.logLevel = .error
    }
    AWSMobileClient.default().initialize({ (state, error) in
        switch (state) {
            case .guest:
                userGlobalState = .userGuest
            case .signedOut:
                userGlobalState = .userSignedOut
            case .signedIn:
                userGlobalState = .userSignedIn
            case .signedOutUserPoolsTokenInvalid:
                userGlobalState = .userSignedOutUserPoolsTokenInvalid
            case .signedOutFederatedTokensInvalid:
                userGlobalState = .userSignedOutFederatedTokensInvalid
            default:
                userGlobalState = .userStateUnknown
        }
    })
    AWSMobileClient.default().addUserStateListener(responder) { (state, error) in
        switch (state) {
            case .guest:
                userGlobalState = .userGuest
            case .signedOut:
                userGlobalState = .userSignedOut
            case .signedIn:
                userGlobalState = .userSignedIn
            case .signedOutUserPoolsTokenInvalid:
                userGlobalState = .userSignedOutUserPoolsTokenInvalid
            case .signedOutFederatedTokensInvalid:
                userGlobalState = .userSignedOutFederatedTokensInvalid
            default:
                userGlobalState = .userStateUnknown
        }
        if (isLogs) {
            print("AWSMobileClient-State-Change: ", userGlobalState)
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: GLOBAL_SIGNIN_REFRESH), object: nil)
        }
    }
}

func getUserAWSAccessToken(completionHandler: @escaping GetTokenCompletionHandler) {
    AWSMobileClient.default().getTokens { (tokens, error) in
        if (userGlobalState == .userSignedIn) {
            if let error = error {
                completionHandler(Optional.none)
                if (isLogs) {
                    print("getUserAWSAccessTokenError: ", error)
                }
            } else if let tokens = tokens {
                completionHandler(Optional(tokens.accessToken!.tokenString!))
            }
        } else {
            completionHandler(Optional.none)
        }
    }
}

func getUserAWSUserSub(completionHandler: @escaping GetSubCompletionHandler) {
    AWSMobileClient.default().getTokens { (tokens, error) in
        if (userGlobalState == .userSignedIn) {
            if let error = error {
                completionHandler(Optional.none)
                if (isLogs) {
                    print("getUserAWSUserSub: ", error)
                }
            } else if let tokens = tokens {
                let sub = tokens.idToken?.claims?["sub"] as! String
                completionHandler(Optional(sub))
            }
        } else {
            completionHandler(Optional.none)
        }
    }
}

func userSignIn(navController: UINavigationController) {
    print("userSignIn->handler")
    let signInUIOptions = SignInUIOptions(canCancel: true, logoImage: UIImage(named: "Icon-86"), backgroundColor:  UIColor.darkGray)
    AWSMobileClient.default().showSignIn(navigationController: navController, signInUIOptions: signInUIOptions, { (state, error) in
        switch (state) {
            case .guest:
                userGlobalState = .userGuest
            case .signedOut:
                userGlobalState = .userSignedOut
            case .signedIn:
                userGlobalState = .userSignedIn
            case .signedOutUserPoolsTokenInvalid:
                userGlobalState = .userSignedOutUserPoolsTokenInvalid
            case .signedOutFederatedTokensInvalid:
                userGlobalState = .userSignedOutFederatedTokensInvalid
            default:
                userGlobalState = .userStateUnknown
        }
    })
}

func userSignInWithCreds(username: String, password: String) {
    AWSMobileClient.default().signIn(username: username, password: password, completionHandler: { (state, error) in
        print(error)
    })
}

func userSignOut() {
    AWSMobileClient.default().signOut()
     firstName = ""
     lastName = ""
     bio = ""
     avatarImage = ""
     location = ""
     username = ""
    
}

