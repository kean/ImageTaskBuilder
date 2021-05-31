<br/>

<p align="left"><img src="https://cloud.githubusercontent.com/assets/1567433/13918338/f8670eea-ef7f-11e5-814d-f15bdfd6b2c0.png" height="180"/>

# ImageTaskBuilder

A fun and convenient way to use [Nuke](https://github.com/kean/Nuke).

> See [**API Reference**](https://kean-org.github.io/docs/image-task-builder/reference/0.5.0/index.html) for a complete list of available options.

## Usage

Downloading an image and applying processors.

```swift
ImagePipeline.shared.image(with: URL(string: "https://")!)
    .resize(width: 320)
    .blur(radius: 10)
    .priority(.high)
    .load { result in
        print(result)
    }
    
// Returns a discardable `ImageTask`.
```

You can take the same image that you described previously and automatically display in a view.

```swift
let image = ImagePipeline.shared.image(with: URL(string: "https://")!)
    .resize(width: 320)
    .blur(radius: 10)
    .priority(.high)
    
let imageView: UIImageView

image.display(in: imageView)
    .transition(.fadeIn(duration: 0.33))
    .placeholder(UIImage.placeholder)
    .contentMode(.center, for: .placeholder)
    .load()
```

When you call `display(in:)` method you get access to a variety of new options specific to the image view.

# License

ImageTaskBuilder is available under the MIT license. See the LICENSE file for more info.
