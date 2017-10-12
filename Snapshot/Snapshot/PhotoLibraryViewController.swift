//
//  PhotoLibraryViewController.swift
//  Snapshot
//
//  Created by Jacob Mendelowitz on 7/10/17.
//  Copyright © 2017 Jacob Mendelowitz. All rights reserved.
//

import UIKit
import AVKit
import AudioToolbox

/**
 * A class to control the main screen that displays the user's photos and the button to take a new photo.
 */
class PhotoLibraryViewController: UIViewController, UINavigationControllerDelegate, UIGestureRecognizerDelegate, UIImagePickerControllerDelegate, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    // The collection of saved photos.
    @IBOutlet weak var photoCollection: UICollectionView!
    
    // The button to take a new photo.
    @IBOutlet weak var takePhotoButton: UIButton!
    
    // A timer to check for expired photos.
    private var timer: Timer = Timer()
    
    // Whether or not an alert box is showing.
    private var alertShowing: Bool = false
    
    // Runs when the view controller first loads.
    internal override func viewDidLoad() {
        super.viewDidLoad()
        setupActions()
        formatButtons()
    }
    
    // Runs each time the view controller appears.
    internal override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        checkForExpiredPhotos()
        timer = Timer.scheduledTimer(timeInterval: 10, target: self, selector: #selector(checkForExpiredPhotos),
                                     userInfo: nil, repeats: true)
    }
    
    // Runs when the view is about to disappear.
    internal override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        timer.invalidate()
    }
    
    // Sets up the actions for any interactive objects on the screen.
    private func setupActions() {
        photoCollection.delegate = self
        photoCollection.dataSource = self
        takePhotoButton.addTarget(self, action: #selector(takePhotoButtonPress(_:)), for: .touchDown)
    }
    
    // Formats the appearance of the buttons on the screen.
    private func formatButtons() {
        takePhotoButton.layer.cornerRadius = 10
        takePhotoButton.clipsToBounds = true
    }
    
    // Set up gesture recognizers for a specific photo on the screen.
    private func setupGestureRecognizers(for photo: UIImageView) {
        let photoTapGesture = UITapGestureRecognizer(target: self, action: #selector(photoTapGesture(_:)))
        photoTapGesture.delegate = self
        photo.addGestureRecognizer(photoTapGesture)
        let photoLongPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(photoLongPressGesture(_:)))
        photoLongPressGesture.delegate = self
        photo.addGestureRecognizer(photoLongPressGesture)
    }
    
    // Show an enlarged view of the photo when it is tapped.
    @objc internal func photoTapGesture(_ sender: UITapGestureRecognizer) {
        show(modal: "ModalImageViewController") {
            viewController in
            let modalImageViewController = viewController as! ModalImageViewController
            modalImageViewController.modalPresentationStyle = .overFullScreen
            modalImageViewController.modalTransitionStyle = .crossDissolve
            if let imageView = sender.view as? UIImageView {
                modalImageViewController.presenter = self.navigationController
                modalImageViewController.selectedIndex = imageView.tag
            }
        }
    }
    
    // Prompt to delete a photo when it is long pressed.
    @objc internal func photoLongPressGesture(_ sender: UILongPressGestureRecognizer) {
        if alertShowing {
            return
        }
        if let imageView = sender.view {
            AudioServicesPlaySystemSound(kSystemSoundID_Vibrate)
            let alert = UIAlertController(title: "Snapshot", message: "Delete now?", preferredStyle: .alert)
            let yesAction = UIAlertAction(title: "Yes", style: .default) {
                action in
                UIView.animate(withDuration: 0.25, animations: {
                    imageView.alpha = 0.0
                }, completion: {
                    complete in
                    let savedImage = DataManager.savedImages[imageView.tag]
                    DataManager.deleteImageRecord(savedImage)
                    self.photoCollection.reloadData()
                    self.alertShowing = false
                })
            }
            let noAction = UIAlertAction(title: "No", style: .cancel) {
                action in
                self.alertShowing = false
            }
            alert.addAction(yesAction)
            alert.addAction(noAction)
            present(alert, animated: true, completion: nil)
            alertShowing = true
        }
    }
    
    // Open and set up the camera when the button is pressed.
    @objc internal func takePhotoButtonPress(_ sender: UIButton) {
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            timer.invalidate()
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
        show(screen: "SaveOptionsViewController")
        picker.dismiss(animated: true, completion: nil)
    }
    
    // Dismiss the camera screen when the user hits cancel.
    internal func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    // Return the number of items in the photo collection.
    internal func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return DataManager.savedImages.count
    }
    
    // Set the size of each of the photos in the collection view.
    internal func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = photoCollection.frame.width
        return CGSize(width: width * 0.33, height: width * 0.33)
    }
    
    // Populate the collection view with saved photos.
    internal func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "imageCell", for: indexPath)
        let imageView = cell.contentView.subviews[0] as! UIImageView
        imageView.image = DataManager.savedImages[indexPath.item].image
        formatPhoto(imageView)
        setupGestureRecognizers(for: imageView)
        imageView.isUserInteractionEnabled = true
        imageView.alpha = 1.0
        imageView.tag = indexPath.item
        return cell
    }
    
    // Crop each photo to square dimensions for display and round corners.
    private func formatPhoto(_ photo: UIImageView) {
        photo.layer.cornerRadius = 10
        photo.clipsToBounds = true
        if let image = photo.image {
            let imageWidth = image.size.width
            let imageHeight = image.size.height
            var x: CGFloat = 0.0
            let y: CGFloat = 0.0
            var width: CGFloat
            var height: CGFloat
            if imageWidth == imageHeight {
                return
            } else if imageWidth < imageHeight {
                x = (imageHeight - imageWidth) / 2.0
                width = imageWidth
                height = imageWidth
            } else {
                x = (imageWidth - imageHeight) / 2.0
                width = imageHeight
                height = imageHeight
            }
            let imageRect = CGRect(x: x, y: y, width: width, height: height)
            let imageRef = image.cgImage!.cropping(to: imageRect)
            photo.image = UIImage(cgImage: imageRef!, scale: image.scale, orientation: image.imageOrientation)
        }
    }
    
    // Loop through photos and check for any past their date set to remove.
    @objc internal func checkForExpiredPhotos() {
        DataManager.checkExpiredImages()
        photoCollection.reloadData()
    }
    
}
