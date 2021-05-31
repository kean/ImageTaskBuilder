// The MIT License (MIT)
//
// Copyright (c) 2020-2021 Alexander Grebenyuk (github.com/kean).

import Nuke
import Foundation

#if os(iOS) || os(tvOS) || os(watchOS)
import UIKit
#endif

#if os(watchOS)
import WatchKit
#endif

#if os(macOS)
import Cocoa
#endif

public typealias ImagePipeline = Nuke.ImagePipeline
public typealias ImageRequest = Nuke.ImageRequest

public extension ImagePipeline {
    func image(with request: ImageRequestConvertible) -> ImageTaskBuilder {
        return ImageTaskBuilder(request: request, pipeline: self)
    }
}

/// A convenience API for loading images.
public struct ImageTaskBuilder {
    /// The current request.
    public private(set) var request: ImageRequest

    private var queue: DispatchQueue?
    private let pipeline: ImagePipeline

    init(request: ImageRequestConvertible, pipeline: ImagePipeline) {
        self.request = request.asImageRequest()
        self.pipeline = pipeline
    }
}

// MARK: - Options

public extension ImageTaskBuilder {
    /// Set the relative priority of the image task. The priority affects the order
    /// in which the image requests are executed.`.normal` by default.
    func priority(_ priority: ImageRequest.Priority) -> ImageTaskBuilder {
        map { $0.priority = priority  }
    }

    /// Set the advanced request options. See `ImageRequest.Options` for more info.
    func options(_ options: ImageRequest.Options) -> ImageTaskBuilder {
        map { $0.options = options  }
    }

    /// Append the given processor to the request. The processor is going to be
    /// applied after all of the previously added procesors.
    func process(_ processor: ImageProcessing) -> ImageTaskBuilder {
        map { $0.processors.append(processor) }
    }

    /// Sets processors for the request.
    func processors(_ processors: [ImageProcessing]) -> ImageTaskBuilder {
        map { $0.processors = processors }
    }

    /// Sets user info for the request.
    func userInfo(_ userInfo: [ImageRequest.UserInfoKey: Any]) -> ImageTaskBuilder {
        map { $0.userInfo = userInfo }
    }

    /// Change the queue on which to deliver progress and completion callbacks.
    func schedule(on queue: DispatchQueue) -> ImageTaskBuilder {
        var copy = self
        copy.queue = queue
        return copy
    }

    private func map(_ closure: (inout ImageRequest) -> Void) -> ImageTaskBuilder {
        var copy = self
        closure(&copy.request)
        return copy
    }
}

// MARK: - Starter

public extension ImageTaskBuilder {
    /// Starts an image task and returns it.
    @discardableResult
    func load(_ progress: ((_ response: ImageResponse?, _ completed: Int64, _ total: Int64) -> Void)? = nil,
              _ completion: @escaping (_ result: Result<ImageResponse, ImagePipeline.Error>) -> Void) -> ImageTask {
        pipeline.loadImage(with: request, queue: queue, progress: progress, completion: completion)
    }

    /// Returns publisher for the given request.
    var publisher: ImagePublisher {
        pipeline.imagePublisher(with: request)
    }

    /// Returns a builder with a variety of options for loading and dispaying the
    /// image in the given view.s
    func display(in view: ImageDisplayingView) -> ImageViewExtensionsTaskBuilder {
        ImageViewExtensionsTaskBuilder(self, view)
    }
}

// MARK: - Processing

public extension ImageTaskBuilder {
    /// Resizes the image to a specified size.
    ///
    /// - parameter size: The target size.
    /// - parameter unit: Unit of the target size, `.points` by default.
    /// - parameter contentMode: `.aspectFill` by default.
    /// - parameter crop: If `true` will crop the image to match the target size. `false` by default.
    /// - parameter upscale: `false` by default.
    func resize(size: CGSize, unit: ImageProcessingOptions.Unit = .points, contentMode: ImageProcessors.Resize.ContentMode = .aspectFill, crop: Bool = false, upscale: Bool = false) -> ImageTaskBuilder {
        process(ImageProcessors.Resize(size: size, unit: unit, contentMode: contentMode, crop: crop, upscale: upscale))
    }

    /// Resizes the image to the given width maintaining aspect ratio.
    ///
    /// - parameter width: The target width.
    /// - parameter unit: Unit of the target size, `.points` by default.
    /// - parameter contentMode: `.aspectFill` by default.
    /// - parameter crop: If `true` will crop the image to match the target size. `false` by default.
    /// - parameter upscale: `false` by default.
    func resize(width: CGFloat, unit: ImageProcessingOptions.Unit = .points, crop: Bool = false, upscale: Bool = false) -> ImageTaskBuilder {
        process(ImageProcessors.Resize(size: CGSize(width: width, height: 4096), unit: unit, contentMode: .aspectFit, crop: crop, upscale: upscale))
    }

    /// Resizes the image to the given height maintaining aspect ratio.
    ///
    /// - parameter height: The target height.
    /// - parameter unit: Unit of the target size, `.points` by default.
    /// - parameter contentMode: `.aspectFill` by default.
    /// - parameter crop: If `true` will crop the image to match the target size. `false` by default.
    /// - parameter upscale: `false` by default.
    func resize(height: CGFloat, unit: ImageProcessingOptions.Unit = .points, crop: Bool = false, upscale: Bool = false) -> ImageTaskBuilder {
        process(ImageProcessors.Resize(size: CGSize(width: 4096, height: height), unit: unit, contentMode: .aspectFit, crop: crop, upscale: upscale))
    }

    #if os(iOS) || os(tvOS) || os(watchOS)

    /// Rounds the corners of an image into a circle.
    func circle(border: ImageProcessingOptions.Border? = nil) -> ImageTaskBuilder {
        process(ImageProcessors.Circle(border: border))
    }

    /// Rounds the corners of an image to the specified radius.
    ///
    /// - parameter radius: The radius of the corners.
    /// - parameter unit: Unit of the radius, `.points` by default.
    /// - parameter border: An optional border drawn around the image.
    func roundedCorners(radius: CGFloat, unit: ImageProcessingOptions.Unit = .points, border: ImageProcessingOptions.Border? = nil) -> ImageTaskBuilder {
        process(ImageProcessors.RoundedCorners(radius: radius, unit: unit, border: border))
    }

    #endif

    #if os(iOS) || os(tvOS)

    /// Applies CoreImage filter with the given name.
    func filter(name: String, parameters: [String: Any], identifier: String) -> ImageTaskBuilder {
        process(ImageProcessors.CoreImageFilter(name: name, parameters: parameters, identifier: identifier))
    }

    /// Applies Core Image filter (`CIFilter`) to the image.
    ///
    /// # Performance Considerations.
    ///
    /// Prefer chaining multiple `CIFilter` objects using `Core Image` facilities
    /// instead of using multiple instances of `ImageProcessors.CoreImageFilter`.
    ///
    /// # References
    ///
    /// - [Core Image Programming Guide](https://developer.apple.com/library/ios/documentation/GraphicsImaging/Conceptual/CoreImaging/ci_intro/ci_intro.html)
    /// - [Core Image Filter Reference](https://developer.apple.com/library/prerelease/ios/documentation/GraphicsImaging/Reference/CoreImageFilterReference/index.html)
    func filter(name: String) -> ImageTaskBuilder {
        process(ImageProcessors.CoreImageFilter(name: name))
    }

    /// Blurs an image using `CIGaussianBlur` filter.
    ///
    /// - parameter radius: Blur radius, 8 by default.
    func blur(radius: Int = 8) -> ImageTaskBuilder {
        process(ImageProcessors.GaussianBlur(radius: radius))
    }

    #endif

    /// Processed an image using a specified closure.
    ///
    /// - parameter id: Identifier that uniquely identifies the transformation.s
    func process(id: String, _ closure: @escaping (PlatformImage) -> PlatformImage?) -> ImageTaskBuilder {
        process(ImageProcessors.Anonymous(id: id, closure))
    }
}
