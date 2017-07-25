//
//  PhotoLibraryViewController.swift
//  Snapshot
//
//  Created by Jacob Mendelowitz on 7/11/17.
//  Copyright © 2017 Jacob Mendelowitz. All rights reserved.
//

import UIKit
import AudioToolbox

class PhotoLibraryViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout, UIGestureRecognizerDelegate {
    
    // The back button in the top left corner.
    @IBOutlet weak var backButton: UIBarButtonItem!
    
    // The collection of saved photos.
    @IBOutlet var photoCollection: UICollectionView!
    
    // A timer to check for expired photos.
    private var timer: Timer = Timer()
    
    // Whether or not an alert box is showing.
    private var alertShowing: Bool = false
    
    // Runs when the view controller first loads.
    internal override func viewDidLoad() {
        super.viewDidLoad()
        setupActions()
    }
    
    // Runs each time the view controller appears.
    internal override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        DataManager.checkExpiredImages()
        timer = Timer.scheduledTimer(timeInterval: 5, target: self, selector: #selector(checkForExpiredPhotos),
                                     userInfo: nil, repeats: true)
    }
    
    // Sets up the actions for any interactive objects on the screen.
    private func setupActions() {
        backButton.target = self
        backButton.action = #selector(backButtonPress(_:))
    }
    
    // Stop the timer and go back to the main screen when the button is pressed.
    internal func backButtonPress(_ sender: UIBarButtonItem) {
        timer.invalidate()
        back()
    }
    
    // Show an enlarged view of the photo when it is tapped.
    internal func photoTapGesture(_ sender: UITapGestureRecognizer) {
        show(screen: "modalImageViewController", modal: true) {
            viewController in
            let modalImageViewController = viewController as! ModalImageViewController
            modalImageViewController.modalPresentationStyle = .overFullScreen
            modalImageViewController.modalTransitionStyle = .crossDissolve
            if let imageView = sender.view as? UIImageView {
                modalImageViewController.presenter = self.navigationController
                modalImageViewController.selectedImage = DataManager.savedImages[imageView.tag]
            }
        }
    }
    
    // Prompt to delete a photo when it is long pressed.
    internal func photoLongPressGesture(_ sender: UILongPressGestureRecognizer) {
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
                    DataManager.savedImages.remove(at: imageView.tag)
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
    
    // Loop through photos and check for any past their date set to remove.
    internal func checkForExpiredPhotos() {
        DataManager.checkExpiredImages()
        photoCollection.reloadData()
    }
    
    // Return the number of items in the photo collection.
    internal override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return DataManager.savedImages.count
    }
    
    // Set the size of each of the photos in the collection view.
    internal func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = view.frame.width
        return CGSize(width: width * 0.33, height: width * 0.33)
    }
    
    // Populate the collection view with saved photos.
    internal override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
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
            var y: CGFloat = 0.0
            var width: CGFloat = 0.0
            var height: CGFloat = 0.0
            if imageWidth < imageHeight {
                x = (imageHeight - imageWidth) / 2.0
                width = imageWidth
                height = imageWidth
            } else if imageWidth > imageHeight {
                y = (imageWidth - imageHeight) / 2.0
                width = imageHeight
                height = imageHeight
            }
            let imageRect = CGRect(x: x, y: y, width: width, height: height)
            let imageRef = image.cgImage!.cropping(to: imageRect)
            photo.image = UIImage(cgImage: imageRef!, scale: image.scale, orientation: image.imageOrientation)
        }
    }
    
    // Set up gesture recognizers for this screen.
    private func setupGestureRecognizers(for photo: UIImageView) {
        let photoTapGesture = UITapGestureRecognizer(target: self, action: #selector(photoTapGesture(_:)))
        photoTapGesture.delegate = self
        photo.addGestureRecognizer(photoTapGesture)
        let photoLongPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(photoLongPressGesture(_:)))
        photoLongPressGesture.delegate = self
        photo.addGestureRecognizer(photoLongPressGesture)
    }

}
