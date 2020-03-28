<br/>

<p align="left"><img src="https://cloud.githubusercontent.com/assets/1567433/13918338/f8670eea-ef7f-11e5-814d-f15bdfd6b2c0.png" height="180"/>

# ImageTaskBuilder

A fun and convenient way to use [Nuke](https://github.com/kean/Nuke) inspired by SwiftUI.

## Usage

Downloading an image and applying processors.

```swift
ImagePipeline.shared.image(with: URL(string: "https://")!)
    .fill(width: 320)
    .blur(radius: 10)
    .priority(.high)
    .schedule(on: .global())
    .start { result in
        print(result) // Called on a global queue instead of the default main queue
    }
    
// Returns a discardable `ImageTask`.
```

Downloading an image and displaying it in an image view.

```swift
let imageView: UIImageView

ImagePipeline.shared.image(with: URL(string: "https://")!)
    .fill(width: imageView.size.width)
    .display(in: imageView)
```

# Requirements

| Nuke          | Swift           | Xcode           | Platforms                                         |
|---------------|-----------------|-----------------|---------------------------------------------------|
| Nuke 8.0      | Swift 5.0       | Xcode 10.2      | iOS 10.0 / watchOS 3.0 / macOS 10.12 / tvOS 10.0  |

# License

ImageTaskBuilder is available under the MIT license. See the LICENSE file for more info.
