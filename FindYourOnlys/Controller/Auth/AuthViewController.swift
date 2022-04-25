//
//  AuthViewController.swift
//  FindYourOnlys
//
//  Created by 鄭昭韋 on 2022/4/25.
//

import UIKit
import AuthenticationServices
import FirebaseAuth
import CryptoKit

class AuthViewController: UIViewController {
    
    // Unhashed nonce.
    fileprivate var currentNonce: String?
    
    @IBAction func signInWithApple(_ sender: UIButton) {
        
        performSignIn()
    }
    
    func performSignIn() {
        
        let request = createAppleIdRequest()
        
        let authorizationViewController = ASAuthorizationController(authorizationRequests: [request])
        
        authorizationViewController.delegate = self
        
        authorizationViewController.presentationContextProvider = self
        
        authorizationViewController.performRequests()
    }
    
    func createAppleIdRequest() -> ASAuthorizationAppleIDRequest {
        
        let appleIdProvider = ASAuthorizationAppleIDProvider()
        
        let request = appleIdProvider.createRequest()
        
        request.requestedScopes = [.fullName, .email]
        
        let nonce = randomNonceString()
        
        request.nonce = sha256(nonce)
        
        currentNonce = nonce
        
        return request
    }
    
    // Adapted from https://auth0.com/docs/api-auth/tutorials/nonce#generate-a-cryptographically-random-nonce
    private func randomNonceString(length: Int = 32) -> String {
        
      precondition(length > 0)
        
      let charset: [Character] =
        Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
        
      var result = ""
        
      var remainingLength = length

      while remainingLength > 0 {
          
        let randoms: [UInt8] = (0 ..< 16).map { _ in
            
          var random: UInt8 = 0
            
          let errorCode = SecRandomCopyBytes(kSecRandomDefault, 1, &random)
            
          if errorCode != errSecSuccess {
              
            fatalError(
              "Unable to generate nonce. SecRandomCopyBytes failed with OSStatus \(errorCode)"
            )
          }
          return random
        }

        randoms.forEach { random in
            
          if remainingLength == 0 {
              
            return
          }

          if random < charset.count {
              
            result.append(charset[Int(random)])
              
            remainingLength -= 1
          }
        }
      }

      return result
    }

    @available(iOS 13, *)
    private func sha256(_ input: String) -> String {
        
      let inputData = Data(input.utf8)
        
      let hashedData = SHA256.hash(data: inputData)
        
      let hashString = hashedData.compactMap {
          
        String(format: "%02x", $0)
          
      }.joined()

      return hashString
    }

}

extension AuthViewController: ASAuthorizationControllerDelegate {
    
    func authorizationController(
        controller: ASAuthorizationController,
        didCompleteWithAuthorization authorization: ASAuthorization) {
        if
            let appleIdCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
            
            guard
                let nonce = currentNonce
            
            else { fatalError("Error, a login callbacl was recevie, but no request was sent.")}
            
            guard
                let appleIdToken = appleIdCredential.identityToken
            
            else {
                    print("Can't fetch identity token.")
                    
                    return
                }
            
            guard
                let idTokenString = String(data: appleIdToken, encoding: .utf8)
                    
            else {
                print("Unable to encode appleIdToken: \(appleIdToken)")
                
                return
            }
            
            let credential = OAuthProvider.credential(
                withProviderID: "apple.com",
                idToken: idTokenString,
                rawNonce: nonce
            )
            
            Auth.auth().signIn(with: credential) { authDataResult, error in
                if
                    let user = authDataResult?.user {
                    
                    print("You have succeed to login, \(user.uid), \(String(describing: user.email))")
                } else {
                    
                    print("Fail to sign in with credential with error: \(String(describing: error))")
                }
            }
            
        }
    }
    
}

extension AuthViewController: ASAuthorizationControllerPresentationContextProviding {
    
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        
        return view.window!
    }
}

