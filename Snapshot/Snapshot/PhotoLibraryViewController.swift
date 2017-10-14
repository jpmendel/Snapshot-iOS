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
    
    // The button used to delete saved images.
    @IBOutlet weak var deleteButton: UIBarButtonItem!
    
    // The collection of saved photos.
    @IBOutlet weak var photoCollection: UICollectionView!
    
    // The button to take a new photo.
    @IBOutlet weak var takePhotoButton: UIButton!
    
    // A timer to check for expired photos.
    private var timer: Timer = Timer()
    
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
        for image in DataManager.savedImages {
            image.selected = false
        }
        photoCollection.reloadData()
    }
    
    // Sets up the actions for any interactive objects on the screen.
    private func setupActions() {
        photoCollection.delegate = self
        photoCollection.dataSource = self
        deleteButton.target = self
        deleteButton.action = #selector(deleteButtonPress(_:))
        takePhotoButton.addTarget(self, action: #selector(takePhotoButtonPress(_:)), for: .touchDown)
    }
    
    // Formats the appearance of the buttons on the screen.
    private func formatButtons() {
        takePhotoButton.layer.cornerRadius = 10
        takePhotoButton.clipsToBounds = true
    }
    
    // Set up gesture recognizers for a specific photo on the screen.
    private func setupGestureRecognizers(for photo: UICollectionViewCell) {
        let photoTapGesture = UITapGestureRecognizer(target: self, action: #selector(photoTapGesture(_:)))
        photoTapGesture.delegate = self
        photo.addGestureRecognizer(photoTapGesture)
        let photoLongPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(photoLongPressGesture(_:)))
        photoLongPressGesture.delegate = self
        photoLongPressGesture.minimumPressDuration = 0.25
        photo.addGestureRecognizer(photoLongPressGesture)
    }
    
    // Show an enlarged view of the photo when it is tapped.
    @objc private func photoTapGesture(_ sender: UITapGestureRecognizer) {
        if let cell = sender.view as? UICollectionViewCell {
            let savedImage = DataManager.savedImages[cell.tag]
            if savedImage.selected {
                let highlightView = cell.contentView.subviews[0]
                UIView.animate(withDuration: 0.25, delay: 0.0, options: .curveEaseIn, animations: {
                    highlightView.transform = CGAffineTransform.identity.scaledBy(x: 0.1, y: 0.1)
                }, completion: {
                    complete in
                    highlightView.isHidden = true
                    savedImage.selected = false
                })
            } else {
                show(modal: "ModalImageViewController") {
                    viewController in
                    let modalImageViewController = viewController as! ModalImageViewController
                    modalImageViewController.modalPresentationStyle = .overFullScreen
                    modalImageViewController.modalTransitionStyle = .crossDissolve
                    modalImageViewController.presenter = self.navigationController
                    modalImageViewController.selectedIndex = cell.tag
                }
            }
        }
    }
    
    // Prompt to delete a photo when it is long pressed.
    @objc private func photoLongPressGesture(_ sender: UILongPressGestureRecognizer) {
        if let cell = sender.view as? UICollectionViewCell {
            let highlightView = cell.contentView.subviews[0]
            let savedImage = DataManager.savedImages[cell.tag]
            if !savedImage.selected {
                AudioServicesPlaySystemSound(kSystemSoundID_Vibrate)
                highlightView.isHidden = false
                UIView.animate(withDuration: 0.25, delay: 0.0, options: .curveEaseOut, animations: {
                    highlightView.transform = CGAffineTransform.identity
                }, completion: {
                    complete in
                    savedImage.selected = true
                })
            }
        }
    }
    
    // Open and set up the camera when the button is pressed.
    @objc private func takePhotoButtonPress(_ sender: UIButton) {
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
            let okAction = UIAlertAction(title: "OK", style: .default)
            alert.addAction(okAction)
            present(alert, animated: true, completion: nil)
        }
    }
    
    @objc private func deleteButtonPress(_ sender: UIBarButtonItem) {
        let selectedImageCount = DataManager.getSelectedImageCount()
        if selectedImageCount > 0 {
            let message = selectedImageCount == 1 ?
                "Delete \(selectedImageCount) image?" : "Delete \(selectedImageCount) images?"
            let alert = UIAlertController(title: "Snapshot", message: message, preferredStyle: .alert)
            let yesAction = UIAlertAction(title: "Yes", style: .default) {
                action in
                DataManager.deleteSelectedImages()
                self.photoCollection.reloadData()
            }
            let noAction = UIAlertAction(title: "No", style: .cancel)
            alert.addAction(yesAction)
            alert.addAction(noAction)
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
        let highlightView = cell.contentView.subviews[0]
        let imageView = cell.contentView.subviews[1] as! UIImageView
        imageView.image = DataManager.savedImages[indexPath.item].image
        formatPhoto(imageView)
        formatHighlight(highlightView, atIndex: indexPath.item)
        setupGestureRecognizers(for: cell)
        cell.isUserInteractionEnabled = true
        cell.tag = indexPath.item
        return cell
    }
    
    // Formats the highlight box on a cell.
    private func formatHighlight(_ highlight: UIView, atIndex index: Int) {
        highlight.layer.cornerRadius = 15
        highlight.clipsToBounds = true
        if DataManager.savedImages[index].selected {
            highlight.transform = CGAffineTransform.identity
            highlight.isHidden = false
        } else {
            highlight.transform = CGAffineTransform.identity.scaledBy(x: 0.1, y: 0.1)
            highlight.isHidden = true
        }
    }
    
    // Crop each photo to square dimensions for display and round corners.
    private func formatPhoto(_ photo: UIImageView) {
        photo.layer.cornerRadius = 10
        photo.clipsToBounds = true
        cropImage(photo)
    }
    
    // Crops an image from an image view to square dimensions.
    private func cropImage(_ imageView: UIImageView) {
        if let image = imageView.image {
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
            imageView.image = UIImage(cgImage: imageRef!, scale: image.scale, orientation: image.imageOrientation)
        }
    }
    
    // Loop through photos and check for any past their date set to remove.
    @objc internal func checkForExpiredPhotos() {
        DataManager.checkExpiredImages()
        photoCollection.reloadData()
    }
    
}
