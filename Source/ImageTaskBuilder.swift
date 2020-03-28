// The MIT License (MIT)
//
// Copyright (c) 2020 Alexander Grebenyuk (github.com/kean).

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

public extension ImagePipeline {
    func image(with url: URL) -> ImageTaskBuilder {
        return ImageTaskBuilder(request: ImageRequest(url: url), pipeline: self)
    }

    func image(with urlRequest: URLRequest) -> ImageTaskBuilder {
        return ImageTaskBuilder(request: ImageRequest(urlRequest: urlRequest), pipeline: self)
    }
}

/// A convenience API for loading images.
public struct ImageTaskBuilder {
    /// The current request.
    public private(set) var request: ImageRequest

    private var queue: DispatchQueue?
    private let pipeline: ImagePipeline

    init(request: ImageRequest, pipeline: ImagePipeline) {
        self.request = request
        self.pipeline = pipeline
    }
}

// MARK: - Options

public extension ImageTaskBuilder {
    func priority(_ priority: ImageRequest.Priority) -> ImageTaskBuilder {
        var copy = self
        copy.request.priority = priority
        return copy
    }

    func options(_ options: ImageRequestOptions) -> ImageTaskBuilder {
        var copy = self
        copy.request.options = options
        return copy
    }

    func processors(_ processors: [ImageProcessing]) -> ImageTaskBuilder {
        var copy = self
        copy.request.processors += processors
        return copy
    }

    func process(_ processor: ImageProcessing) -> ImageTaskBuilder {
        var copy = self
        copy.request.processors.append(processor)
        return copy
    }

    func schedule(on queue: DispatchQueue) -> ImageTaskBuilder {
        var copy = self
        copy.queue = queue
        return copy
    }
}

// MARK: - Starter

public extension ImageTaskBuilder {
    @discardableResult
    func start(_ progress: ImageTask.ProgressHandler? = nil, _ completion: ImageTask.Completion? = nil) -> ImageTask {
        return pipeline.loadImage(with: request, queue: queue, progress: progress, completion: completion)
    }

    @discardableResult
    func display(in view: ImageDisplayingView, options: ImageLoadingOptions = ImageLoadingOptions.shared, progress: ImageTask.ProgressHandler? = nil, _ completion: ImageTask.Completion? = nil) -> ImageTask? {
        return Nuke.loadImage(with: request, options: options, into: view, progress: progress, completion: completion)
    }
}

// MARK: - Processing

public extension ImageTaskBuilder {
    func resize(size: CGSize, unit: ImageProcessor.Unit = .points, contentMode: ImageProcessor.Resize.ContentMode = .aspectFill, crop: Bool = false, upscale: Bool = false) -> ImageTaskBuilder {
        return process(ImageProcessor.Resize(size: size, unit: unit, contentMode: contentMode, crop: crop, upscale: upscale))
    }

    func fill(width: CGFloat, unit: ImageProcessor.Unit = .points, crop: Bool = false, upscale: Bool = false) -> ImageTaskBuilder {
        return process(ImageProcessor.Resize(size: CGSize(width: width, height: .greatestFiniteMagnitude), unit: unit, contentMode: .aspectFit, crop: crop, upscale: upscale))
    }

    func fill(height: CGFloat, unit: ImageProcessor.Unit = .points, crop: Bool = false, upscale: Bool = false) -> ImageTaskBuilder {
        return process(ImageProcessor.Resize(size: CGSize(width: .greatestFiniteMagnitude, height: height), unit: unit, contentMode: .aspectFit, crop: crop, upscale: upscale))
    }

    #if os(iOS) || os(tvOS) || os(watchOS)

    func circle(border: ImageProcessor.Border? = nil) -> ImageTaskBuilder {
        return process(ImageProcessor.Circle(border: border))
    }

    func roundedCorners(radius: CGFloat, unit: ImageProcessor.Unit = .points, border: ImageProcessor.Border? = nil) -> ImageTaskBuilder {
        return process(ImageProcessor.RoundedCorners(radius: radius, unit: unit, border: border))
    }

    #endif

    #if os(iOS) || os(tvOS)

    /// Applies CoreImage filter with the given name.
    func filter(name: String, parameters: [String: Any], identifier: String) -> ImageTaskBuilder {
        return process(ImageProcessor.CoreImageFilter(name: name, parameters: parameters, identifier: identifier))
    }

    /// Applies CoreImage filter with the given name.
    func filter(name: String) -> ImageTaskBuilder {
        return process(ImageProcessor.CoreImageFilter(name: name))
    }

    func blur(radius: Int = 8) -> ImageTaskBuilder {
        return process(ImageProcessor.GaussianBlur(radius: radius))
    }

    #endif

    func process(id: String, _ closure: @escaping (PlatformImage) -> PlatformImage?) -> ImageTaskBuilder {
        return process(ImageProcessor.Anonymous(id: id, closure))
    }
}
