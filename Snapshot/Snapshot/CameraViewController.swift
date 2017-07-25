//
//  CameraViewController.swift
//  Snapshot
//
//  Created by Jacob Mendelowitz on 7/10/17.
//  Copyright © 2017 Jacob Mendelowitz. All rights reserved.
//

import UIKit
import AVKit

class CameraViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    // The button in the top left to access the photo library.
    @IBOutlet weak var photoLibraryBarButton: UIBarButtonItem!
    
    // The button in the top right to take a photo.
    @IBOutlet weak var takePhotoBarButton: UIBarButtonItem!
    
    // The button to access the photo library.
    @IBOutlet weak var photoLibraryButton: UIButton!
    
    // The button to take a photo to save.
    @IBOutlet weak var takePhotoButton: UIButton!
    
    // Runs when the view controller first loads.
    internal override func viewDidLoad() {
        super.viewDidLoad()
        setupActions()
        formatButtons()
    }
    
    // Runs each time the view controller appears.
    internal override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        DataManager.checkExpiredImages()
    }
    
    // Sets up the actions for any interactive objects on the screen.
    private func setupActions() {
        takePhotoBarButton.target = self
        takePhotoBarButton.action = #selector(takePhotoButtonPress(_:))
        photoLibraryBarButton.target = self
        photoLibraryBarButton.action = #selector(photoLibraryButtonPress(_:))
        takePhotoButton.addTarget(self, action: #selector(takePhotoButtonPress(_:)), for: .touchDown)
        photoLibraryButton.addTarget(self, action: #selector(photoLibraryButtonPress(_:)), for: .touchDown)
    }
    
    // Formats the appearance of the buttons on the screen.
    private func formatButtons() {
        takePhotoButton.layer.cornerRadius = 10
        takePhotoButton.clipsToBounds = true
        photoLibraryButton.layer.cornerRadius = 10
        photoLibraryButton.clipsToBounds = true
    }
    
    // Show the photo library when the button is pressed.
    internal func photoLibraryButtonPress(_ sender: UIBarButtonItem) {
        show(screen: "photoLibraryViewController")
    }
    
    // Open and set up the camera when the button is pressed.
    internal func takePhotoButtonPress(_ sender: UIButton) {
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.allowsEditing = false
            imagePicker.sourceType = .camera
            imagePicker.cameraFlashMode = .off
            present(imagePicker, animated: true, completion: nil)
        } else {
            let alert = UIAlertController(title: "Snapshot", message: "This device has no supported camera.", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "OK", style: .default) {
                action in
            }
            alert.addAction(okAction)
            present(alert, animated: true, completion: nil)
        }
    }
    
    // Show save options when the user has finished taking a photo.
    internal func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        DataManager.capturedImage = info[UIImagePickerControllerOriginalImage] as? UIImage
        show(screen: "saveOptionsViewController")
        picker.dismiss(animated: true, completion: nil)
    }
    
    // Dismiss the camera screen when the user hits cancel.
    internal func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
}
