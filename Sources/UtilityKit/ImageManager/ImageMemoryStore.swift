//
//  ImageMemoryStore.swift
//  UtilityKit
//
//  Created by Jagdeep Singh on 20/05/25.
//


import SwiftUI

@available(iOS 17, *)
/// A configurable, singleton-based in-memory image cache using `NSCache`.
///
/// `ImageMemoryStore` allows clients to cache frequently accessed images (e.g., thumbnails)
/// in memory with optional limits on item count and memory cost.
/// The cache is auto-managed and purged under memory pressure.
@MainActor
public final class ImageMemoryStore {

    // MARK: - Singleton

    /// Shared global instance.
    @MainActor public static let shared = ImageMemoryStore()

    // MARK: - Internal Cache

    private let cache = NSCache<NSString, UIImage>()

    // MARK: - Initialization

    /// Private initializer to enforce singleton pattern.
    private init() { configure() }

    // MARK: - Configuration

    /// Configure cache limits.
    ///
    /// - Parameters:
    ///   - countLimit: Maximum number of items to store. Default is `nil` (no limit).
    ///   - totalCostLimit: Maximum memory (in bytes) the cache should hold. Default is `nil` (no limit).
    ///
    /// Example: `ImageMemoryStore.shared.configure(countLimit: 100, totalCostLimit: 50 * 1024 * 1024)`
    public func configure(countLimit: Int = 100, totalCostLimit: Int = (50 * 1024 * 1024)) {
        cache.countLimit = countLimit
        cache.totalCostLimit = totalCostLimit
    }

    // MARK: - Public Methods

    /// Caches an image in memory.
    ///
    /// - Parameters:
    ///   - image: Image to cache.
    ///   - key: Unique key (usually URL string).
    public func setImage(_ image: UIImage, forKey key: String) {
        let cost = image.pngData()?.count ?? 0
        cache.setObject(image, forKey: key as NSString, cost: cost)
    }

    /// Retrieves an image for the given URL string.
    /// If the image is not cached, it will be downloaded and cached before returning.
    ///
    /// - Parameter key: A URL string used as the cache key.
    /// - Returns: The cached or downloaded `UIImage`.
    /// - Throws: An error if the image could not be downloaded or decoded.
    public func getImage(forKey key: String) async throws -> UIImage {
        if let cached = cache.object(forKey: key as NSString) {
            print("got from cache")
            return cached
        }
        
        guard let url = URL(string: key) else {
            throw URLError(.badURL)
        }
        
        let (data, _) = try await URLSession.shared.data(from: url)
        
        guard let image = UIImage(data: data) else {
            throw URLError(.cannotDecodeContentData)
        }
        
        setImage(image, forKey: key)
        print("got from url")
        return image
    }

    /// Removes a specific cached image.
    ///
    /// - Parameter key: Key of the image to remove.
    public func removeImage(forKey key: String) {
        cache.removeObject(forKey: key as NSString)
    }

    /// Clears all cached images from memory.
    public func clearCache() {
        cache.removeAllObjects()
    }
}
