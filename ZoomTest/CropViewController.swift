//
//  CropViewController.swift
//  Preset
//
//  Created by Venkat Rao on 2/17/19.
//  Copyright © 2019 Venkat Rao. All rights reserved.
//

import UIKit

protocol CropViewControllerDelegate: class {
    func imageForCropView(cropView: CropViewController) -> UIImage
}

class CropViewController: UIViewController {

    let cropView: CropView = CropView(frame: .zero)
    weak var delegate: CropViewControllerDelegate?

    override func loadView() {
        view = cropView
    }

    init(delegate: CropViewControllerDelegate) {
        self.delegate = delegate
        super.init(nibName: nil, bundle: nil)
//        cropView.contentInset = UIEdgeInsets(top: 50, left: 25, bottom: 50, right: 25)
        cropView.delegate = self
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        guard let image = delegate?.imageForCropView(cropView: self) else { return }
        cropView.imageView.currentImage = image
    }
}

extension CropViewController: CropViewDelegate {
    func dismissPressed(cropView: CropView) {
        self.dismiss(animated: true, completion: nil)
    }
}
