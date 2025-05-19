# UtilityKit

**UtilityKit** is a lightweight Swift package offering a collection of utility functions and extensions to streamline iOS/macOS development. It aims to simplify common tasks and promote code reusability across projects.

## ✨ Features

* Handy extensions for `String`, `Date`, `Array`, and more
* Convenient helpers for UI components and layout management
* Lightweight and modular design
* Fully compatible with Swift Package Manager

## 📦 Installation

### Swift Package Manager (SPM)

To integrate UtilityKit into your project using Swift Package Manager, add the following dependency to your `Package.swift` file:

```swift
dependencies: [
    .package(url: "https://github.com/ThakurVijay2191/UtilityKit.git", from: "1.1.0")
]
```

Then, include "UtilityKit" as a dependency for your target:

```swift
.target(
    name: "YourTargetName",
    dependencies: ["UtilityKit"]
)
```

### Xcode Integration

1. Open your project in Xcode.
2. Navigate to **File > Add Packages...**
3. Enter the repository URL: `https://github.com/ThakurVijay2191/UtilityKit.git`
4. Choose the desired version (e.g., **Up to Next Major Version** starting from `1.1.0`)
5. Click **Add Package** to complete the integration.

## 📚 Usage

After importing UtilityKit, you can access its utility functions and extensions.

```swift
import UtilityKit

// Example: Using a String extension
let originalString = "  Hello, World!  "
let trimmedString = originalString.trimmed()
```

For detailed usage examples and documentation, please refer to the [Documentation](#) section.

## 🚀 Roadmap

Planned enhancements for future releases include:

* Additional utility functions for data manipulation
* Support for asynchronous operations
* Comprehensive unit tests
* Expanded documentation and usage examples

## 🛠 Contributing

Contributions are welcome! To contribute:

1. Fork the repository
2. Create a new branch (`git checkout -b feature/YourFeature`)
3. Commit your changes (`git commit -m 'Add YourFeature'`)
4. Push to the branch (`git push origin feature/YourFeature`)
5. Open a Pull Request

Please ensure your code adheres to the existing coding standards and includes appropriate tests.

## 📄 License

UtilityKit is released under the [MIT License](LICENSE).

## 👤 Author

Developed by [Vijay Thakur](https://github.com/ThakurVijay2191).
