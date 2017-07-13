//
//  SaveDateViewController.swift
//  Snapshot
//
//  Created by Jacob Mendelowitz on 7/10/17.
//  Copyright © 2017 Jacob Mendelowitz. All rights reserved.
//

import UIKit
import Photos

class SaveDateViewController: UIViewController {

    @IBOutlet weak var cancelButton: UIBarButtonItem!
    
    @IBOutlet weak var datePicker: UIDatePicker!
    
    @IBOutlet weak var confirmButton: UIButton!
    
    internal override func viewDidLoad() {
        super.viewDidLoad()
        setupActions()
        formatButtons()
    }
    
    private func setupActions() {
        cancelButton.target = self
        cancelButton.action = #selector(cancelButtonPress(_:))
        confirmButton.addTarget(self, action: #selector(confirmButtonPress(_:)), for: .touchDown)
    }
    
    private func formatButtons() {
        confirmButton.layer.cornerRadius = 10
        confirmButton.clipsToBounds = true
    }

    internal func cancelButtonPress(_ sender: UIBarButtonItem) {
        navigationController?.popViewController(animated: true)
    }
    
    internal func confirmButtonPress(_ sender: UIButton) {
        if let image = DataManager.capturedImage {
            UIImageWriteToSavedPhotosAlbum(image, self, #selector(completeImageSave(_:error:contextInfo:)), nil)
        }
    }
    
    internal func storeSavedImage() {
        let photoOptions = PHFetchOptions()
        photoOptions.fetchLimit = 1
        photoOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        let imageResult = PHAsset.fetchAssets(with: .image, options: photoOptions)
        if let image = imageResult.firstObject {
            let savedImage = SavedImage(id: image.localIdentifier, expireDate: datePicker.date)
            DataManager.savedImages += [savedImage]
            DataManager.saveData()
        } else {
            print("Error saving image.")
        }
    }
    
    internal func completeImageSave(_ image: UIImage, error: Error?, contextInfo: UnsafeRawPointer) {
        if error == nil {
            storeSavedImage()
        } else {
            print("Error saving image.")
        }
        if let viewControllers = navigationController?.viewControllers {
            for viewController in viewControllers {
                if viewController is CameraViewController {
                    navigationController?.popToViewController(viewController, animated: true)
                }
            }
        }
    }
    
}
