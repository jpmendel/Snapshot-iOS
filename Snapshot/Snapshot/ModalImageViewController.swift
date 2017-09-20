//
//  ModalImageViewController.swift
//  Snapshot
//
//  Created by Jacob Mendelowitz on 7/23/17.
//  Copyright © 2017 Jacob Mendelowitz. All rights reserved.
//

import UIKit

class ModalImageViewController: UIViewController, UIScrollViewDelegate {

    // The photo to be displayed on the screen.
    @IBOutlet weak var photoView: UIImageView!
    
    // The view that scrolls the photo and allows for zooming.
    @IBOutlet weak var scrollView: UIScrollView!
    
    // The text below the photo displaying the expiration date.
    @IBOutlet weak var photoText: UILabel!
    
    // The button to close the photo modal.
    @IBOutlet weak var closeButton: UIButton!
    
    // The selected image to be displayed.
    internal var selectedImage: SavedImage?
    
    // The navigation controller that presented this modal.
    internal var presenter: UINavigationController?
    
    // Runs when the view controller first loads.
    internal override func viewDidLoad() {
        super.viewDidLoad()
        setupImage()
        setupActions()
        setupScrollView()
    }
    
    // Runs when the view controller is about to appear.
    internal override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        UIApplication.shared.isStatusBarHidden = true
    }
    
    // Runs when the view controller is about to disappear.
    internal override func viewWillDisappear(_ animated: Bool) {
        super.viewWillAppear(animated)
        UIApplication.shared.isStatusBarHidden = false
    }
    
    // Sets up the enlarged image view.
    private func setupImage() {
        if let savedImage = selectedImage {
            photoView.image = savedImage.image
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "MM/dd/yy - h:mm a"
            let expireDate = dateFormatter.string(from: savedImage.expireDate)
            photoText.text = "Expires: \(expireDate)"
        }
    }
    
    // Sets up the actions for any interactive objects on the screen.
    private func setupActions() {
        closeButton.addTarget(self, action: #selector(closeButtonPress(_:)), for: .touchDown)
    }
    
    // Sets up the scroll view to manipulate the image on the screen.
    private func setupScrollView() {
        scrollView.delegate = self
        scrollView.contentSize = view.frame.size
        scrollView.minimumZoomScale = 1.0
        scrollView.maximumZoomScale = 6.0
    }
    
    // This is the view that will be zoomed in the scroll view.
    internal func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return photoView
    }
    
    // This runs when the user zooms the view.
    internal func scrollViewDidZoom(_ scrollView: UIScrollView) {
        closeButton.isHidden = true
        photoText.isHidden = true
        repositionScrolledImage()
    }
    
    // This runs when the user ends a zoom.
    internal func scrollViewDidEndZooming(_ scrollView: UIScrollView, with view: UIView?, atScale scale: CGFloat) {
        if scrollView.zoomScale <= scrollView.minimumZoomScale {
            closeButton.isHidden = false
            photoText.isHidden = false
        }
    }
    
    
    // This runs when the user finishes scrolling.
    internal func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {

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
        
        let screenSize = scrollView.frame.size
        let ox = (screenSize.width > realImageSize.width) ? (screenSize.width - realImageSize.width) / 2 : 0
        let oy = (screenSize.height > realImageSize.height) ? (screenSize.height - realImageSize.height) / 2 : 0
        scrollView.contentInset = UIEdgeInsetsMake(oy, ox, oy, ox)
    }
    
    // Go back to the photo library when pressed.
    internal func closeButtonPress(_ sender: UIButton) {
        close(from: presenter)
    }

}
