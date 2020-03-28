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

public struct ImageViewExtensionsTaskBuilder {
    let imageTaskBuilder: ImageTaskBuilder
    let view: ImageDisplayingView

    var options: ImageLoadingOptions = .shared

    init(_ builder: ImageTaskBuilder, _ view: ImageDisplayingView) {
        self.imageTaskBuilder = builder
        self.view = view
    }

    @discardableResult
    public func load(progress: ImageTask.ProgressHandler? = nil, completion: ImageTask.Completion? = nil) -> ImageTask? {
        Nuke.loadImage(with: imageTaskBuilder.request, options: options, into: view, progress: progress, completion: completion)
    }
}

// MARK: - Options

public extension ImageLoadingOptions {
    enum ImageType {
        case success, placeholder, failure
    }
}

public extension ImageViewExtensionsTaskBuilder {
    func placeholder(_ image: PlatformImage) -> ImageViewExtensionsTaskBuilder {
        var copy = self
        copy.options.placeholder = image
        return copy
    }

    func failureImage(_ image: PlatformImage) -> ImageViewExtensionsTaskBuilder {
        var copy = self
        copy.options.failureImage = image
        return copy
    }

    func transition(_ transition: ImageLoadingOptions.Transition, for type: ImageLoadingOptions.ImageType = .success) -> ImageViewExtensionsTaskBuilder {
        var copy = self
        switch type {
        case .success: copy.options.transition = transition
        case .failure: copy.options.failureImageTransition = transition
        case .placeholder: break // Nott supported
        }
        return copy
    }

    func alwaysTransition() -> ImageViewExtensionsTaskBuilder {
        var copy = self
        copy.options.alwaysTransition = true
        return copy
    }

    func prepareForReuse(enabled: Bool = true) -> ImageViewExtensionsTaskBuilder {
        var copy = self
        copy.options.isPrepareForReuseEnabled = true
        return copy
    }

    #if os(iOS) || os(tvOS)

    /// Changes content mode for the image with the given type.
    func contentMode(_ contentMode: UIView.ContentMode, for type: ImageLoadingOptions.ImageType = .success) -> ImageViewExtensionsTaskBuilder {
        var copy = self
        var contentModes = copy.options.contentModes ?? ImageLoadingOptions.ContentModes(success: view.contentMode, failure: view.contentMode, placeholder: view.contentMode)
        switch type {
        case .success: contentModes.success = contentMode
        case .failure: contentModes.failure = contentMode
        case .placeholder: contentModes.placeholder = contentMode
        }
        copy.options.contentModes = contentModes
        return copy
    }

    #endif
}
