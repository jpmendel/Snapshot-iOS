//
//  SavedImage.swift
//  Snapshot
//
//  Created by Jacob Mendelowitz on 7/12/17.
//  Copyright © 2017 Jacob Mendelowitz. All rights reserved.
//

import UIKit

class SavedImage: NSObject {
    
    // The filename the image will be saved as.
    internal var fileName: String
    
    // The image to be saved.
    internal var image: UIImage
    
    // The date and time the image expires.
    internal var expireDate: Date
    
    // Initialize a saved image from a UIImage.
    internal init(image: UIImage, expireDate: Date) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd-HH-mm-ss"
        self.fileName = "image-" + dateFormatter.string(from: Date()) + ".png"
        self.image = image
        self.expireDate = expireDate
    }
    
    // Initialize a saved image from file.
    internal init(file: String, expireDate: String) {
        self.fileName = file
        let appDirectory = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        let filePath = appDirectory + "/images/" + file
        self.image = UIImage(contentsOfFile: filePath) ?? UIImage()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd/yyyy h:mm a"
        self.expireDate = dateFormatter.date(from: expireDate) ?? Date()
    }
    
    // Saves the image to the device disk.
    internal func saveToDisk() {
        if let imagePNG = UIImagePNGRepresentation(image) {
            do {
                let appDirectory = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
                let filePath = appDirectory + "/images/" + fileName
                try imagePNG.write(to: URL(fileURLWithPath: filePath))
            } catch {
                print("Failed to save image: \(fileName)")
            }
        }
    }

}
