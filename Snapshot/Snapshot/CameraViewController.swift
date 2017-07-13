//
//  CameraViewController.swift
//  Snapshot
//
//  Created by Jacob Mendelowitz on 7/10/17.
//  Copyright © 2017 Jacob Mendelowitz. All rights reserved.
//

import UIKit

class CameraViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var photoLibraryButton: UIBarButtonItem!
    
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
        photoLibraryButton.target = self
        photoLibraryButton.action = #selector(photoLibraryButtonPress(_:))
        takePhotoButton.addTarget(self, action: #selector(takePhotoButtonPress(_:)), for: .touchDown)
    }
    
    private func formatButtons() {
        takePhotoButton.layer.cornerRadius = 10
        takePhotoButton.clipsToBounds = true
    }
    
    internal func photoLibraryButtonPress(_ sender: UIBarButtonItem) {
        if let photoLibraryViewController =
            storyboard?.instantiateViewController(withIdentifier: "photoLibraryViewController") {
            navigationController?.pushViewController(photoLibraryViewController, animated: true)
        }
    }
    
    internal func takePhotoButtonPress(_ sender: UIButton) {
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.allowsEditing = true
            imagePicker.sourceType = .camera
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
        if let saveOptionsViewController =
            storyboard?.instantiateViewController(withIdentifier: "saveOptionsViewController") {
            DataManager.capturedImage = info[UIImagePickerControllerEditedImage] as? UIImage
            navigationController?.pushViewController(saveOptionsViewController, animated: true)
        }
        picker.dismiss(animated: true, completion: nil)
    }
    
    internal func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
}
