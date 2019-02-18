//
//  RSZoomableImageViewTests.swift
//  ZoomTestTests
//
//  Created by Venkat Rao on 2/18/19.
//  Copyright © 2019 Venkat Rao. All rights reserved.
//

import XCTest

import ZoomTest

class RSZoomableImageViewTests: XCTestCase {
    let sut = RSZoomableImageView()

    func testCenter() {
        sut.frame = CGRect(x: 0.0, y: 0.0, width: 200.0, height: 200.0)
        let image = UIImage(named: "transamerica_pyramid.jpg")!
        sut.update(image, shouldUpdateFrame: true)
        sut.layoutSubviews()
        XCTAssert(sut.imageViewFull.frame == CGRect(x: 0, y: 0, width: 0, height: 0))
    }

}
