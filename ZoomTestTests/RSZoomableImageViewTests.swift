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
    var mockSize: CGSize
    var mockScale: CGFloat

    init(size: CGSize, scale: CGFloat) {
        self.mockSize = size
        self.mockScale = scale
        super.init()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override var size: CGSize {
        return mockSize
    }

    override var scale: CGFloat {
        return mockScale
    }
}

// MARK: - UIImage Extension
extension UIImage {
    private convenience init!(failableImageLiteral name: String) {
        self.init(named: name)
    }

    public convenience init(imageLiteralResourceName name: String) {
        self.init(failableImageLiteral: name)
    }
}

public typealias _ImageLiteralType = UIImage

class RSZoomableImageViewTests: XCTestCase {

    func test2xImage() {
        let sut = RSZoomableImageView(frame: CGRect(x: 0.0, y: 0.0, width: 200.0, height: 200.0), withScreenScale: 2.0)
        let image = UIImageMock(size: CGSize(width: 400, height: 400), scale: 2.0)
        sut.currentImage = image
        sut.layoutSubviews()
        XCTAssertEqual(sut.imageViewFull.bounds, CGRect(x: 0.0, y: 0.0, width: 400.0, height: 400.0), "must be equal")
        XCTAssertEqual(sut.minimumZoomScale, 0.5, "must be equal")
        XCTAssertEqual(sut.maximumZoomScale, 1.0, "must be equal")
    }

    func testLandscapeImageinLandscapeView() {

    }

    func testPortraitImageinLandscapeView() {

    }

    func testPortraitImageinPortraitView() {

    }

    func testLanscapeImageinPortraitView() {

    }

    func testSmallImage() {
        let sut = RSZoomableImageView(frame: CGRect(x: 0.0, y: 0.0, width: 200.0, height: 200.0), withScreenScale: 2.0)
        let image = UIImageMock(size: CGSize(width: 100, height: 100), scale: 2.0)
        sut.currentImage = image
        sut.layoutSubviews()
        XCTAssertEqual(sut.imageViewFull.bounds, CGRect(x: 0.0, y: 0.0, width: 100.0, height: 100.0), "must be equal")
        XCTAssertEqual(sut.minimumZoomScale, 2.0, "must be equal")
        XCTAssertEqual(sut.maximumZoomScale, 4.0, "must be equal")
    }

    func testLoadingImageAsync() {
        let sut = RSZoomableImageView(frame: CGRect(x: 0.0, y: 0.0, width: 200.0, height: 200.0), withScreenScale: 2.0)

        sut.currentImage = UIImageMock(size: CGSize(width: 50, height: 50), scale: 2.0)

        sut.layoutSubviews()

        sut.currentImage = UIImageMock(size: CGSize(width: 400, height: 400), scale: 2.0)

        XCTAssertEqual(sut.imageViewFull.bounds, CGRect(x: 0.0, y: 0.0, width: 400.0, height: 400.0), "must be equal")
        XCTAssertEqual(sut.minimumZoomScale, 0.5, "must be equal")
        XCTAssertEqual(sut.maximumZoomScale, 1.0, "must be equal")
    }

}
