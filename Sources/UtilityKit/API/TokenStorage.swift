//
//  SwiftUIView.swift
//  UtilityKit
//
//  Created by Jagdeep Singh on 18/06/25.
//

import Foundation

public final class TokenStorage: Sendable{
    static let shared = TokenStorage()
    private init() {}

    var accessToken: String? {
        get { UserDefaults.standard.string(forKey: "accessToken") }
        set { UserDefaults.standard.set(newValue, forKey: "accessToken") }
    }

    var refreshToken: String? {
        get { UserDefaults.standard.string(forKey: "refreshToken") }
        set { UserDefaults.standard.set(newValue, forKey: "refreshToken") }
    }
}
