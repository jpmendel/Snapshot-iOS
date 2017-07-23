//
//  ModalImageViewController.swift
//  Snapshot
//
//  Created by Jacob Mendelowitz on 7/23/17.
//  Copyright © 2017 Jacob Mendelowitz. All rights reserved.
//

import UIKit

class ModalImageViewController: UIViewController {

    @IBOutlet weak var photoView: UIImageView!
    
    @IBOutlet weak var photoText: UILabel!
    
    @IBOutlet weak var photoBackground: UIView!
    
    @IBOutlet weak var closeButton: UIButton!
    
    internal var selectedImage: SavedImage?
    
    internal var presenter: UINavigationController?
    
    internal override func viewDidLoad() {
        super.viewDidLoad()
        setupImage()
        setupActions()
    }
    
    private func setupImage() {
        photoBackground.layer.cornerRadius = 10
        photoBackground.clipsToBounds = true
        closeButton.layer.cornerRadius = 10
        closeButton.clipsToBounds = true
        if let savedImage = selectedImage {
            photoView.image = savedImage.image
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "MM/dd/yy - h:mm a"
            let expireDate = dateFormatter.string(from: savedImage.expireDate)
            photoText.text = "Expires: \(expireDate)"
        }
    }
    
    private func setupActions() {
        closeButton.addTarget(self, action: #selector(closeButtonPress(_:)), for: .touchDown)
    }
    
    internal func closeButtonPress(_ sender: UIButton) {
        close(from: presenter)
    }

}
