//
//  RSZoomableImageViewTests.swift
//  ZoomTestTests
//
//  Created by Venkat Rao on 2/18/19.
//  Copyright © 2019 Venkat Rao. All rights reserved.
//

import XCTest

import ZoomTest


class UIImageMock: UIImage {
    override var size: CGSize {
        return CGSize(width: 400, height: 400)
    }

    override var scale: CGFloat {
        return 2.0
    }
}
class RSZoomableImageViewTests: XCTestCase {

    func testCenter() {
        let sut = RSZoomableImageView(frame: CGRect(x: 0.0, y: 0.0, width: 200.0, height: 200.0))
        let image = UIImageMock()
        sut.currentImage = image
        sut.layoutSubviews()
        XCTAssert(sut.imageViewFull.frame == CGRect(x: 0, y: 0, width: 0, height: 0))
    }

    func testMinimumZoomScale() {
        let sut = RSZoomableImageView(frame: CGRect(x: 0.0, y: 0.0, width: 200.0, height: 200.0), withScreenScale: 2.0)
        sut.currentImage = UIImageMock()
        XCTAssertEqual(sut.minimumZoomScale, 0.5, "must be equal")
    }

}
