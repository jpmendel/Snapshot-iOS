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
    
    @IBOutlet weak var photoLibraryBarButton: UIBarButtonItem!
    
    @IBOutlet weak var takePhotoBarButton: UIBarButtonItem!
    
    @IBOutlet weak var photoLibraryButton: UIButton!
    
    @IBOutlet weak var takePhotoButton: UIButton!
    
    internal override func viewDidLoad() {
        super.viewDidLoad()
        setupActions()
        formatButtons()
    }
    
    internal override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        DataManager.checkExpiredImages()
    }
    
    private func setupActions() {
        takePhotoBarButton.target = self
        takePhotoBarButton.action = #selector(takePhotoButtonPress(_:))
        photoLibraryBarButton.target = self
        photoLibraryBarButton.action = #selector(photoLibraryButtonPress(_:))
        takePhotoButton.addTarget(self, action: #selector(takePhotoButtonPress(_:)), for: .touchDown)
        photoLibraryButton.addTarget(self, action: #selector(photoLibraryButtonPress(_:)), for: .touchDown)
    }
    
    private func formatButtons() {
        takePhotoButton.layer.cornerRadius = 10
        takePhotoButton.clipsToBounds = true
        photoLibraryButton.layer.cornerRadius = 10
        photoLibraryButton.clipsToBounds = true
    }
    
    internal func photoLibraryButtonPress(_ sender: UIBarButtonItem) {
        show(screen: "photoLibraryViewController")
    }
    
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
    
    internal func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        DataManager.capturedImage = info[UIImagePickerControllerOriginalImage] as? UIImage
        show(screen: "saveOptionsViewController")
        picker.dismiss(animated: true, completion: nil)
    }
    
    internal func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
}
