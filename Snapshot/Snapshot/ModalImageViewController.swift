//
//  ModalImageViewController.swift
//  Snapshot
//
//  Created by Jacob Mendelowitz on 7/23/17.
//  Copyright © 2017 Jacob Mendelowitz. All rights reserved.
//

import UIKit

class ModalImageViewController: UIViewController {

    // The photo to be displayed on the screen.
    @IBOutlet weak var photoView: UIImageView!
    
    // The text below the photo displaying the expiration date.
    @IBOutlet weak var photoText: UILabel!
    
    // The white background behind the photo.
    @IBOutlet weak var photoBackground: UIView!
    
    // The button to close the photo modal.
    @IBOutlet weak var closeButton: UIButton!
    
    // The selected image to be displayed.
    internal var selectedImage: SavedImage?
    
    // The navigation controller that presented this modal.
    internal var presenter: UINavigationController?
    
    // Runs when the view controller first loads.
    internal override func viewDidLoad() {
        super.viewDidLoad()
        setupImage()
        setupActions()
    }
    
    // Sets up the enlarged image view.
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
    
    // Sets up the actions for any interactive objects on the screen.
    private func setupActions() {
        closeButton.addTarget(self, action: #selector(closeButtonPress(_:)), for: .touchDown)
    }
    
    // Go back to the photo library when pressed.
    internal func closeButtonPress(_ sender: UIButton) {
        close(from: presenter)
    }

}
