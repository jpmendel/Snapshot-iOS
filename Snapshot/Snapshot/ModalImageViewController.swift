//
//  ModalImageViewController.swift
//  Snapshot
//
//  Created by Jacob Mendelowitz on 7/23/17.
//  Copyright © 2017 Jacob Mendelowitz. All rights reserved.
//

import UIKit
import AudioToolbox

/**
 * A class to control the screen that allows a user to view a saved image.
 */
class ModalImageViewController: UIViewController, UIScrollViewDelegate, UIGestureRecognizerDelegate {

    // The photo to be displayed on the screen.
    @IBOutlet weak var photoView: UIImageView!
    
    // The view that scrolls the photo and allows for zooming.
    @IBOutlet weak var scrollView: UIScrollView!
    
    // The text below the photo displaying the expiration date.
    @IBOutlet weak var expireDateText: UILabel!
    
    // The button to export the photo to another app.
    @IBOutlet weak var sendButton: UIButton!
    
    // The button to delete the current photo.
    @IBOutlet weak var deleteButton: UIButton!
    
    // The button to close the photo modal.
    @IBOutlet weak var closeButton: UIButton!
    
    // The index of the selected image to be displayed.
    internal var selectedIndex: Int = 0
    
    // The navigation controller that presented this modal.
    internal var presenter: UINavigationController?
    
    // Runs when the view controller first loads.
    internal override func viewDidLoad() {
        super.viewDidLoad()
        setupActions()
        setupScrollView()
        setupImage()
        setImageSizeForOrientation()
    }
    
    // Runs when the view controller is about to appear.
    internal override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        UIApplication.shared.statusBarStyle = .default
    }
    
    // Runs when the view controller first appears.
    internal override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        UIApplication.shared.isStatusBarHidden = true
    }
    
    // Runs when the view controller is about to disappear.
    internal override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        UIApplication.shared.isStatusBarHidden = false
        UIApplication.shared.statusBarStyle = .lightContent
    }
    
    // Sets up the enlarged image view.
    private func setupImage() {
        if selectedIndex >= 0 && selectedIndex < DataManager.savedImages.count {
            let savedImage = DataManager.savedImages[selectedIndex]
            photoView.image = savedImage.image
            expireDateText.text = savedImage.getReadableExpireText()
        }
    }
    
    // Sets up the actions for any interactive objects on the screen.
    private func setupActions() {
        closeButton.addTarget(self, action: #selector(closeButtonPress(_:)), for: .touchDown)
        sendButton.addTarget(self, action: #selector(sendButtonPress(_:)), for: .touchDown)
        deleteButton.addTarget(self, action: #selector(deleteButtonPress(_:)), for: .touchDown)
    }
    
    // Sets up the scroll view to manipulate the image on the screen.
    private func setupScrollView() {
        scrollView.delegate = self
        scrollView.contentSize = view.frame.size
        scrollView.minimumZoomScale = 0.1
        scrollView.maximumZoomScale = 6.0
    }
    
    // This is the view that will be zoomed in the scroll view.
    internal func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return photoView
    }
    
    // This runs when the scroll view will start decellerating after being dragged.
    internal func scrollViewWillBeginDecelerating(_ scrollView: UIScrollView) {
        handleScrollOffScreen()
    }
    
    // This runs when the user stops dragging the view.
    internal func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
       handleScrollOffScreen()
    }
    
    // Handles an event where the user drags the photo off screen.
    private func handleScrollOffScreen() {
        if scrollView.zoomScale == 1.0 {
            let margin = photoView.frame.width / 3.0
            if scrollView.contentOffset.x < -margin || scrollView.contentOffset.x > margin {
                close(from: presenter)
            } else {
                scrollView.setContentOffset(CGPoint(x: 0.0, y: scrollView.contentOffset.y), animated: true)
            }
        }
    }
    
    // This runs when the user zooms the view.
    internal func scrollViewDidZoom(_ scrollView: UIScrollView) {
        UIView.animate(withDuration: 0.25, animations: {
            self.closeButton.alpha = 0.0
            self.expireDateText.alpha = 0.0
            self.sendButton.alpha = 0.0
            self.deleteButton.alpha = 0.0
        }, completion: {
            complete in
            self.closeButton.isUserInteractionEnabled = false
            self.expireDateText.isUserInteractionEnabled = false
            self.sendButton.isUserInteractionEnabled = false
            self.deleteButton.isUserInteractionEnabled = false
        })
        repositionScrolledImage()
    }
    
    // This runs when the user ends a zoom.
    internal func scrollViewDidEndZooming(_ scrollView: UIScrollView, with view: UIView?, atScale scale: CGFloat) {
        if scrollView.zoomScale < 0.6 {
            close(from: presenter)
        } else if scrollView.zoomScale < 1.0 {
            scrollView.setZoomScale(1.0, animated: true)
        }
        if scrollView.zoomScale == 1.0 {
            UIView.animate(withDuration: 0.25, animations: {
                self.closeButton.alpha = 1.0
                self.expireDateText.alpha = 1.0
                self.sendButton.alpha = 1.0
                self.deleteButton.alpha = 1.0
            }, completion: {
                complete in
                self.closeButton.isUserInteractionEnabled = true
                self.expireDateText.isUserInteractionEnabled = true
                self.sendButton.isUserInteractionEnabled = true
                self.deleteButton.isUserInteractionEnabled = true
            })
        }
    }
    
    // Keeps the image being viewed steady on the screen as the user zooms.
    private func repositionScrolledImage() {
        let imageViewSize = photoView.frame.size
        let imageSize = photoView.image!.size
        var realImageSize: CGSize
        if (imageSize.width / imageSize.height) > (imageViewSize.width / imageViewSize.height) {
            let heightTimesRatio = (imageViewSize.width / imageSize.width) * imageSize.height
            realImageSize = CGSize(width: imageViewSize.width, height: heightTimesRatio)
        } else {
            let widthTimesRatio = (imageViewSize.height / imageSize.height) * imageSize.width
            realImageSize = CGSize(width: widthTimesRatio, height: imageViewSize.height)
        }
        var frame = CGRect(x: 0, y: 0, width: 0, height: 0)
        frame.size = realImageSize
        photoView.frame = frame
        
        let screenSize: CGSize
        if scrollView.zoomScale == 1.0 {
            screenSize = CGSize(width: scrollView.frame.size.width * 3.0, height: scrollView.frame.size.height)
        } else {
            screenSize = scrollView.frame.size
        }
        let ox = (screenSize.width > realImageSize.width) ? (screenSize.width - realImageSize.width) / 2 : 0
        let oy = (screenSize.height > realImageSize.height) ? (screenSize.height - realImageSize.height) / 2 : 0
        scrollView.contentInset = UIEdgeInsetsMake(oy, ox, oy, ox)
    }
    
    // Sets the proper size and position of an image if it is horizontal.
    private func setImageSizeForOrientation() {
        let imageWidth = photoView.image!.size.width
        let imageHeight = photoView.image!.size.height
        let finalWidth = scrollView.frame.width
        let finalHeight = scrollView.frame.width * (imageHeight / imageWidth)
        let y = photoView.frame.minY + (photoView.frame.height - finalHeight) / 2
        photoView.frame = CGRect(x: 0.0, y: y, width: finalWidth, height: finalHeight)
        scrollView.contentInset = UIEdgeInsetsMake(0.0, scrollView.frame.width, 0.0, scrollView.frame.width)
    }
    
    // Options to export the photo to various different activities when pressed.
    @objc private func sendButtonPress(_ sender: UIButton) {
        if let image = photoView.image {
            let shareMenu = UIActivityViewController.init(activityItems: [image], applicationActivities: nil)
            shareMenu.excludedActivityTypes = [.postToVimeo, .postToWeibo, .postToTencentWeibo, .openInIBooks]
            present(shareMenu, animated: true, completion: nil)
        }
    }
    
    // Delete the photo when pressed.
    @objc private func deleteButtonPress(_ sender: UIButton) {
        if photoView.image != nil {
            AudioServicesPlaySystemSound(kSystemSoundID_Vibrate)
            let alert = UIAlertController(title: "Snapshot", message: "Delete now?", preferredStyle: .alert)
            let yesAction = UIAlertAction(title: "Yes", style: .default) {
                action in
                let savedImage = DataManager.savedImages[self.selectedIndex]
                DataManager.deleteImageRecord(savedImage)
                if let photoLibraryViewController = self.presenter?.topViewController as? PhotoLibraryViewController {
                    photoLibraryViewController.checkForExpiredPhotos()
                    self.close(from: self.presenter)
                }
            }
            let noAction = UIAlertAction(title: "No", style: .cancel)
            alert.addAction(yesAction)
            alert.addAction(noAction)
            present(alert, animated: true, completion: nil)
        }
    }
    
    // Go back to the photo library when pressed.
    @objc private func closeButtonPress(_ sender: UIButton) {
        close(from: presenter)
    }

}
