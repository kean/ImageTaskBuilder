// The MIT License (MIT)
//
// Copyright (c) 2020-2021 Alexander Grebenyuk (github.com/kean).

import Foundation
import NukeBuilder
import XCTest

class NukeBuilderTests: XCTestCase {
    func testBasics() {
        let _ = ImagePipeline.shared
            .image(with: "https://example.com/image.jpeg")
            .priority(.high)
            .resize(width: 100)
            .publisher
    }
}
