
import AuthenticationServices
import Foundation
import UIKit

@available(iOS 17.0, *)
/// A helper class for implementing Sign In with Apple functionality, including user authentication and keychain management.
@MainActor public class SignInWithAppleHelper: NSObject {
    /// The shared singleton instance of the SignInWithAppleHelper.
    @MainActor public static let shared = SignInWithAppleHelper()
    /// The current nonce used for secure Apple ID token validation.
    private var currentNonce: String?
     /// A KeychainItem for securely storing the Apple user ID.
    private let keychain = KeychainItem(service: "com.utilitykit.appleUser", account: "appleUserId")
    
    /// A continuation to handle the async sign-in process.
    public var continuation: (AppleUser?, Error?)->() = { _, _ in }
 
    /// Initiates the Sign In with Apple process.
    /// - Returns: An `AppleUser` object containing the authenticated user's information.
    /// - Throws: An error if the sign-in process fails.
    public func signIn(){
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        let request = appleIDProvider.createRequest()
        request.requestedScopes = [.fullName, .email]
        
        let authorizationController = ASAuthorizationController(authorizationRequests: [request])
        authorizationController.delegate = self
        authorizationController.presentationContextProvider = self
        authorizationController.performRequests()
    }
  
}

@available(iOS 17.0, *)
extension SignInWithAppleHelper: ASAuthorizationControllerDelegate {
    /// - Tag: did_complete_authorization
    public func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        switch authorization.credential {
        case let appleIDCredential as ASAuthorizationAppleIDCredential:
            // Create an account in your system.
            if let fullName = appleIDCredential.fullName, let email = appleIDCredential.email{
                let userIdentifier = appleIDCredential.user
                self.saveUserInKeychain(userIdentifier, email: email, fullName: (fullName.givenName ?? "") + " " + (fullName.familyName ?? ""))
                let appleUser = AppleUser(userId: userIdentifier, email: email, fullName: (fullName.givenName ?? "") + " " + (fullName.familyName ?? ""))
                self.continuation(appleUser, nil)
            }else {
                let (userIdentifier, email, fullName) = self.getUserFromKeychain() ?? ("", "", "")
                let appleUser = AppleUser(userId: userIdentifier, email: email, fullName: fullName)
                self.continuation(appleUser, nil)
            }
            
        case let passwordCredential as ASPasswordCredential:
            break
        default:
            break
        }
    }
    
    private func getUserFromKeychain()->(String, String, String)?{
        do {
            let userIdentifier = try KeychainItem(service: "com.apple.utilityKit", account: "userIdentifier").readItem()
            let email = try KeychainItem(service: "com.apple.utilityKit", account: "email").readItem()
            let fullName = try KeychainItem(service: "com.apple.utilityKit", account: "fullName").readItem()
            return (userIdentifier, email, fullName)
        } catch {
            print("Unable to save userIdentifier to keychain.")
            return nil
        }
    }
    
    private func saveUserInKeychain(_ userIdentifier: String, email: String, fullName: String) {
        do {
            try KeychainItem(service: "com.apple.utilityKit", account: "userIdentifier").saveItem(userIdentifier)
            try KeychainItem(service: "com.apple.utilityKit", account: "email").saveItem(email)
            try KeychainItem(service: "com.apple.utilityKit", account: "fullName").saveItem(fullName)
        } catch {
            print("Unable to save userIdentifier to keychain.")
        }
    }
    
    private func showPasswordCredentialAlert(username: String, password: String) {
        let message = "The app has received your selected credential from the keychain. \n\n Username: \(username)\n Password: \(password)"
        let alertController = UIAlertController(title: "Keychain Credential Received",
                                                message: message,
                                                preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler: nil))
        //        self.present(alertController, animated: true, completion: nil)
    }
    
    /// - Tag: did_complete_error
    public func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        self.continuation(nil, error)
    }
}

extension SignInWithAppleHelper: ASAuthorizationControllerPresentationContextProviding {
    /// - Tag: provide_presentation_anchor
    public func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return (UIApplication.shared.connectedScenes.first as? UIWindowScene)?.keyWindow ?? .init()
    }
}
