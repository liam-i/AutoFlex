# AutoFlex

<!-- [![CI Status](https://img.shields.io/travis/Liam/AutoFlex.svg?style=flat)](https://travis-ci.org/Liam/AutoFlex) -->
[![Swift](https://img.shields.io/badge/Swift-5.7_5.8_5.9_5.10-orange?style=flat-square)](https://img.shields.io/badge/Swift-5.7_5.8_5.9_5.10-Orange?style=flat-square)
[![Platforms](https://img.shields.io/badge/Platforms-iOS_tvOS_macOS-yellowgreen?style=flat-square)](https://img.shields.io/badge/Platforms-iOS_tvOS_macOS-Green?style=flat-square)
[![CocoaPods](https://img.shields.io/cocoapods/v/AutoFlex.svg?style=flat)](https://cocoapods.org/pods/AutoFlex)
[![SPM](https://img.shields.io/badge/SPM-supported-DE5C43.svg?style=flat)](https://swift.org/package-manager)
[![Carthage](https://img.shields.io/badge/Carthage-supported-4BC51D.svg?style=flat-square)](https://github.com/Carthage/Carthage)
[![License](https://img.shields.io/cocoapods/l/AutoFlex.svg?style=flat)](https://github.com/liam-i/AutoFlex/blob/main/LICENSE)
<!--[![Doc](https://img.shields.io/badge/Swift-Doc-DE5C43.svg?style=flat)](https://liam-i.github.io/AutoFlex/main/documentation/autoflex) -->

A Swift Autolayout Library for iOS, tvOS and macOS.

## Requirements

* iOS 12.0+
* tvOS 12.0+
* macOS 11.0+ 
* Xcode 14.1+
* Swift 5.7.1+

### Swift Package Manager

#### ...using `swift build`

If you are using the [Swift Package Manager](https://www.swift.org/documentation/package-manager), add a dependency to your `Package.swift` file and import the AutoFlex library into the desired targets:
```swift
dependencies: [
    .package(url: "https://github.com/liam-i/AutoFlex.git", from: "0.3.3")
],
targets: [
    .target(
        name: "MyTarget", dependencies: [
            .product(name: "AutoFlex", package: "AutoFlex")
        ])
]
```

#### ...using Xcode

If you are using Xcode, then you should:

- File > Swift Packages > Add Package Dependency
- Add `https://github.com/liam-i/AutoFlex.git`
- Select "Up to Next Minor" with "0.3.3"

> [!TIP]
> For detailed tutorials, see: [Apple Docs](https://developer.apple.com/documentation/xcode/adding-package-dependencies-to-your-app)

#### CocoaPods

If you're using [CocoaPods](https://cocoapods.org), add this to your `Podfile`:

```ruby
source 'https://github.com/CocoaPods/Specs.git'
# Or use CND source
# source 'https://cdn.cocoapods.org/'
platform :ios, '12.0'
use_frameworks!

target 'MyApp' do
  pod 'AutoFlex', '~> 0.3.3'
end
```

And run `pod install`.

> [!IMPORTANT]  
> CocoaPods 1.14.3 or newer is required.

### Carthage

If you're using [Carthage](https://github.com/Carthage/Carthage), add this to your `Cartfile`:

```ruby
github "liam-i/AutoFlex" ~> 0.3.3
```

And run `carthage update --platform iOS --use-xcframeworks`.

## Example

To run the example project, first clone the repo, then `cd` to the root directory and run `pod install`. Then open AutoFlex.xcworkspace in Xcode.

## License

AutoFlex is available under the MIT license. See the [LICENSE](./LICENSE) file for more info.
