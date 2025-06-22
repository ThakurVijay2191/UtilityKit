//
//  HTTPMethod.swift
//  UtilityKit
//
//  Created by Apple on 22/06/25.
//

import Foundation

/// An enumeration representing the standard HTTP methods used in network requests.
///
/// `HTTPMethod` provides a type-safe alternative to raw string literals when specifying
/// the HTTP method for an `APIEndpoint`. It improves code readability and reduces the
/// likelihood of typos or invalid values.
///
/// Example usage:
/// ```swift
/// request.httpMethod = HTTPMethod.post.rawValue
/// ```
public enum HTTPMethod: String {

    /// The `GET` method is used to retrieve data from a server.
    ///
    /// Commonly used for fetching resources or performing queries.
    case get = "GET"

    /// The `POST` method is used to submit data to a server.
    ///
    /// Often used for creating new resources or triggering side effects.
    case post = "POST"

    /// The `PUT` method is used to update or replace an existing resource.
    ///
    /// Typically used when the client sends the full updated representation of the resource.
    case put = "PUT"

    /// The `DELETE` method is used to remove a resource from the server.
    ///
    /// Used when the client intends to delete a specific item.
    case delete = "DELETE"
}
