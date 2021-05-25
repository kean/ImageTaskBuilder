//
//  File.swift
//  
//
//  Created by Alexander Grebenyuk on 24.05.2021.
//

import Foundation
import Nuke
import ImageTaskBuilder
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
