//
//  CropView.swift
//  Preset
//
//  Created by Venkat Rao on 2/17/19.
//  Copyright © 2019 Venkat Rao. All rights reserved.
//

import UIKit

protocol CropViewDelegate: class {
    func dismissPressed(cropView: CropView)
}

class CropView: UIView {

    let imageView = RSZoomableImageView(frame: .zero)
    let buttonDismiss = UIButton(type: .system)

    let leftView = UIVisualEffectView(effect: UIBlurEffect(style: .dark))
    let rightView = UIVisualEffectView(effect: UIBlurEffect(style: .dark))
    let topView = UIVisualEffectView(effect: UIBlurEffect(style: .dark))
    let bottomView = UIVisualEffectView(effect: UIBlurEffect(style: .dark))

    var leftWidth: NSLayoutConstraint?
    var rightWidth: NSLayoutConstraint?
    var topHeight: NSLayoutConstraint?
    var bottomHeight: NSLayoutConstraint?

    let maskingView = UIView(frame: .zero)

    var contentInset: UIEdgeInsets = .zero {
        didSet {
            imageView.contentInset = contentInset
        }
    }

    weak var delegate: CropViewDelegate?

    override init(frame: CGRect) {
        super.init(frame: frame)

        imageView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(imageView)
        imageView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        imageView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        imageView.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        imageView.rightAnchor.constraint(equalTo: rightAnchor).isActive = true

        buttonDismiss.translatesAutoresizingMaskIntoConstraints = false
        buttonDismiss.setTitle("Dismiss", for: .normal)
        buttonDismiss.addTarget(self, action: #selector(dismissPressed), for: .touchUpInside)

        addSubview(buttonDismiss)

        safeAreaLayoutGuide.topAnchor.constraint(equalTo: buttonDismiss.topAnchor).isActive = true
        safeAreaLayoutGuide.trailingAnchor.constraint(equalTo: buttonDismiss.trailingAnchor).isActive = true

        leftView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(leftView)
        leftView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        leftView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        leftView.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        leftWidth = leftView.widthAnchor.constraint(equalToConstant: 100.0)

        rightView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(rightView)
        rightView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        rightView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        rightView.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        rightWidth = rightView.widthAnchor.constraint(equalToConstant: 100.0)

        topView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(topView)
        topView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        topView.rightAnchor.constraint(equalTo: rightView.leftAnchor).isActive = true
        topView.leftAnchor.constraint(equalTo: leftView.rightAnchor).isActive = true
        topHeight = topView.heightAnchor.constraint(equalToConstant: 50.0)

        bottomView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(bottomView)
        bottomView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        bottomView.rightAnchor.constraint(equalTo: rightView.leftAnchor).isActive = true
        bottomView.leftAnchor.constraint(equalTo: leftView.rightAnchor).isActive = true
        bottomHeight = bottomView.heightAnchor.constraint(equalToConstant: 50.0)

        NSLayoutConstraint.activate([topHeight!, bottomHeight!, leftWidth!, rightWidth!])

        maskingView.translatesAutoresizingMaskIntoConstraints = false
        maskingView.layer.borderColor = UIColor.white.cgColor
        maskingView.layer.borderWidth = 1.0
        maskingView.isUserInteractionEnabled = false
        addSubview(maskingView)
        
        topView.bottomAnchor.constraint(equalTo: maskingView.topAnchor).isActive = true
        bottomView.topAnchor.constraint(equalTo: maskingView.bottomAnchor).isActive = true
        leftView.rightAnchor.constraint(equalTo: maskingView.leftAnchor).isActive = true
        rightView.leftAnchor.constraint(equalTo: maskingView.rightAnchor).isActive = true
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        print("Crop View layoutSubview: \(imageView.adjustedContentInset)")

        topHeight?.constant = imageView.adjustedContentInset.top
        bottomHeight?.constant = imageView.adjustedContentInset.bottom
        leftWidth?.constant = imageView.adjustedContentInset.left
        rightWidth?.constant = imageView.adjustedContentInset.right
//        setBox()
    }

    func setBox() {
        guard let currentImage = imageView.currentImage else {
            return
        }

        let ratio = currentImage.size.width / currentImage.size.height

        if ratio > 1 {
            let imageWidth = (bounds.height - imageView.adjustedContentInset.top - imageView.adjustedContentInset.bottom) * ratio
            leftWidth?.constant = imageView.center.x - imageWidth / 2.0
            rightWidth?.constant = imageView.center.x - imageWidth / 2.0
        } else {
            let imageHeight = (bounds.width - imageView.adjustedContentInset.left - imageView.adjustedContentInset.right) / ratio
            topHeight?.constant = imageView.center.y - imageHeight / 2.0
            bottomHeight?.constant = imageView.center.y - imageHeight / 2.0
        }
    }

    @objc func dismissPressed(sender: UIButton) {
        delegate?.dismissPressed(cropView: self)
    }
}
