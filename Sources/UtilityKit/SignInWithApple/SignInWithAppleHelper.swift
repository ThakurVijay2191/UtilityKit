
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
    /// A continuation to handle the async sign-in process.
    private var continuation: CheckedContinuation<AppleUser, Error>?
    /// A KeychainItem for securely storing the Apple user ID.
    private let keychain = KeychainItem(service: "com.utilitykit.appleUser", account: "appleUserId")
    
    /// Initiates the Sign In with Apple process.
    /// - Returns: An `AppleUser` object containing the authenticated user's information.
    /// - Throws: An error if the sign-in process fails.
    public func signIn() async throws -> AppleUser {
        return try await withCheckedThrowingContinuation { continuation in
            let request = ASAuthorizationAppleIDProvider().createRequest()
            request.requestedScopes = [.fullName, .email]
            self.currentNonce = UUID().uuidString
            
            let controller = ASAuthorizationController(authorizationRequests: [request])
            controller.delegate = self
            controller.presentationContextProvider = self
            controller.performRequests()
            
            self.continuation = continuation
        }
    }
    
    /// Checks if the user is currently signed in using Sign In with Apple.
    /// - Returns: A Boolean value indicating whether a user is signed in.
    public func isSignedIn() -> Bool {
        return (try? keychain.read()) != nil
    }
    
    /// Signs the user out by deleting their Apple user ID from the keychain.
    /// - Throws: An error if the keychain item cannot be deleted.
    public func signOut() throws {
        try keychain.delete()
    }
}

@available(iOS 17.0, *)
extension SignInWithAppleHelper: ASAuthorizationControllerDelegate, ASAuthorizationControllerPresentationContextProviding {
    /// Handles successful completion of the authorization request.
    /// - Parameters:
    ///   - controller: The authorization controller managing the request.
    ///   - authorization: The authorization object containing the credentials.
    public func authorizationController(
        controller: ASAuthorizationController,
        didCompleteWithAuthorization authorization: ASAuthorization
    ) {
        guard let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential else {
            continuation?.resume(throwing: SignInWithAppleError.invalidCredentials)
            return
        }
        
        guard let identityToken = appleIDCredential.identityToken,
              let tokenString = String(data: identityToken, encoding: .utf8) else {
            continuation?.resume(throwing: SignInWithAppleError.missingIdentityToken)
            return
        }
        
        do {
            try keychain.save(appleIDCredential.user)
            let user = AppleUser(
                userId: appleIDCredential.user,
                email: appleIDCredential.email,
                fullName: appleIDCredential.fullName?.formatted()
            )
            continuation?.resume(returning: user)
        } catch {
            continuation?.resume(throwing: SignInWithAppleError.keychainError(error.localizedDescription))
        }
        continuation = nil
    }
    
    /// Handles authorization errors, including user cancellation and unknown errors.
    /// - Parameters:
    ///   - controller: The authorization controller managing the request.
    ///   - error: The error encountered during authorization.
    public func authorizationController(
        controller: ASAuthorizationController,
        didCompleteWithError error: Error
    ) {
        if (error as NSError).code == ASAuthorizationError.canceled.rawValue {
            continuation?.resume(throwing: SignInWithAppleError.cancelled)
        } else {
            continuation?.resume(throwing: SignInWithAppleError.unknown(error))
        }
        continuation = nil
    }
    
    /// Provides the presentation anchor for the authorization controller.
    /// - Parameter controller: The authorization controller requesting the anchor.
    /// - Returns: The window to use as the presentation anchor.
    public func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        if let window = UIApplication.shared.connectedScenes.first as? UIWindowScene {
            return UIWindow(windowScene: window)
        } else {
            return UIWindow()
        }
    }
}
