//
//  SwiftUIView.swift
//  UtilityKit
//
//  Created by Vijay Thakur on 17/05/25.
//

import Foundation

@available(iOS 17.0, *)
/// A model representing a user authenticated through Sign In with Apple.
public struct AppleUser {
    /// The unique identifier for the Apple user.
    private let userId: String
    
    /// The email address associated with the Apple user, if available.
    private let email: String?
    
    /// The full name of the Apple user, if available.
    private let fullName: String?
    
    /// Initializes a new AppleUser instance.
    /// - Parameters:
    ///   - userId: The unique identifier for the Apple user.
    ///   - email: The email address of the Apple user, if available.
    ///   - fullName: The full name of the Apple user, if available.
    public init(userId: String, email: String?, fullName: String?) {
        self.userId = userId
        self.email = email
        self.fullName = fullName
    }
}
