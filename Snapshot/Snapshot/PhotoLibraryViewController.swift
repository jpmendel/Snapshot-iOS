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
    
    @IBOutlet weak var backButton: UIBarButtonItem!
    
    @IBOutlet var photoCollection: UICollectionView!
    
    private var alertShowing: Bool = false
    
    internal override func viewDidLoad() {
        super.viewDidLoad()
        setupActions()
    }
    
    internal override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        DataManager.checkExpiredImages()
    }
    
    private func setupActions() {
        backButton.target = self
        backButton.action = #selector(backButtonPress(_:))
    }
    
    internal func backButtonPress(_ sender: UIBarButtonItem) {
        navigationController?.popViewController(animated: true)
    }
    
    internal func photoTapGesture(_ sender: UITapGestureRecognizer) {
        if alertShowing {
            return
        }
        if let imageView = sender.view {
            AudioServicesPlaySystemSound(kSystemSoundID_Vibrate)
            let savedImage = DataManager.savedImages[imageView.tag]
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "MM/dd/yy - h:mm a"
            let expireDate = dateFormatter.string(from: savedImage.expireDate)
            let alert = UIAlertController(title: "Snapshot", message: "Expires: \(expireDate)", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "OK", style: .default) {
                alertAction in
                self.alertShowing = false
            }
            alert.addAction(okAction)
            present(alert, animated: true, completion: nil)
            alertShowing = true
        }
    }
    
    internal func photoLongPressGesture(_ sender: UILongPressGestureRecognizer) {
        if alertShowing {
            return
        }
        if let imageView = sender.view {
            AudioServicesPlaySystemSound(kSystemSoundID_Vibrate)
            let alert = UIAlertController(title: "Snapshot", message: "Delete now?", preferredStyle: .alert)
            let yesAction = UIAlertAction(title: "Yes", style: .default) {
                action in
                DataManager.savedImages.remove(at: imageView.tag)
                self.photoCollection.reloadData()
                self.alertShowing = false
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
    
    internal override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return DataManager.savedImages.count
    }
    
    internal func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = view.frame.width
        return CGSize(width: width * 0.33, height: width * 0.33)
    }
    
    internal override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "imageCell", for: indexPath)
        let imageView = cell.contentView.subviews[0] as! UIImageView
        imageView.image = DataManager.savedImages[indexPath.item].image
        formatPhoto(imageView)
        setupGestureRecognizers(for: imageView)
        imageView.isUserInteractionEnabled = true
        imageView.tag = indexPath.item
        return cell
    }
    
    private func formatPhoto(_ photo: UIImageView) {
        photo.layer.cornerRadius = 10
        photo.clipsToBounds = true
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
