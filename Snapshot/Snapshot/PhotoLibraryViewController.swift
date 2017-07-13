//
//  PhotoLibraryViewController.swift
//  Snapshot
//
//  Created by Jacob Mendelowitz on 7/11/17.
//  Copyright © 2017 Jacob Mendelowitz. All rights reserved.
//

import UIKit
import Photos
import AudioToolbox

class PhotoLibraryViewController: UICollectionViewController, UIGestureRecognizerDelegate {
    
    @IBOutlet weak var backButton: UIBarButtonItem!
    
    @IBOutlet var photoCollection: UICollectionView!
    
    private var photoManager: PHCachingImageManager = PHCachingImageManager()
    
    private var photoResults: PHFetchResult<PHAsset>!
    
    internal override func viewDidLoad() {
        super.viewDidLoad()
        setupPhotoLibrary()
        setupActions()
    }
    
    private func setupPhotoLibrary() {
        let photoOptions = PHFetchOptions()
        photoOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: true)]
        var localIdentifiers = [String]()
        for image in DataManager.savedImages {
            localIdentifiers += [image.id]
        }
        photoResults = PHAsset.fetchAssets(withLocalIdentifiers: localIdentifiers, options: photoOptions)
    }
    
    private func setupActions() {
        backButton.target = self
        backButton.action = #selector(backButtonPress(_:))
    }
    
    internal func backButtonPress(_ sender: UIBarButtonItem) {
        navigationController?.popViewController(animated: true)
    }
    
    internal func photoTapGesture(_ sender: UITapGestureRecognizer) {
        if let imageView = sender.view {
            AudioServicesPlaySystemSound(kSystemSoundID_Vibrate)
            let savedImage = DataManager.savedImages[imageView.tag]
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "MM/dd/yy - h:mm a"
            let expireDate = dateFormatter.string(from: savedImage.expireDate)
            let alert = UIAlertController(title: "Snapshot", message: "Expires: \(expireDate)", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "OK", style: .default) {
                alertAction in
            }
            alert.addAction(okAction)
            present(alert, animated: true, completion: nil)
        }
    }
    
    internal func photoLongPressGesture(_ sender: UILongPressGestureRecognizer) {
        if let imageView = sender.view {
            AudioServicesPlaySystemSound(kSystemSoundID_Vibrate)
            let alert = UIAlertController(title: "Snapshot", message: "Delete now?", preferredStyle: .alert)
            let yesAction = UIAlertAction(title: "Yes", style: .default) {
                action in
                let savedImage = DataManager.savedImages.remove(at: imageView.tag)
                self.setupPhotoLibrary()
                self.photoCollection.reloadData()
                let photoOptions = PHFetchOptions()
                photoOptions.fetchLimit = 1
                let assetToDelete = PHAsset.fetchAssets(withLocalIdentifiers: [savedImage.id], options: photoOptions)
                PHPhotoLibrary.shared().performChanges({PHAssetChangeRequest.deleteAssets(assetToDelete)}) {
                    success, error in
                    if error != nil {
                        print("Error deleting image.")
                    }
                }
            }
            let noAction = UIAlertAction(title: "No", style: .cancel) {
                action in
            }
            alert.addAction(yesAction)
            alert.addAction(noAction)
            present(alert, animated: true, completion: nil)
        }
    }
    
    internal override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if photoResults != nil {
            return photoResults.count
        } else {
            return 0
        }
    }
    
    internal override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "imageCell", for: indexPath)
        let imageView = cell.contentView.subviews[0] as! UIImageView
        imageView.image = nil
        photoManager.requestImage(for: photoResults[indexPath.item], targetSize: imageView.frame.size, contentMode: .aspectFill, options: nil) {
            image, info in
            imageView.image = image
        }
        setupGestureRecognizers(for: imageView)
        imageView.isUserInteractionEnabled = true
        imageView.tag = indexPath.item
        return cell
    }
    
    private func setupGestureRecognizers(for photo: UIImageView) {
        let photoTapGesture = UITapGestureRecognizer(target: self, action: #selector(photoTapGesture(_:)))
        photoTapGesture.delegate = self
        photo.addGestureRecognizer(photoTapGesture)
        let photoLongPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(photoLongPressGesture(_:)))
        photoLongPressGesture.delegate = self
        photo.addGestureRecognizer(photoLongPressGesture)
    }

}
