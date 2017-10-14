//
//  SavedImage.swift
//  Snapshot
//
//  Created by Jacob Mendelowitz on 7/12/17.
//  Copyright © 2017 Jacob Mendelowitz. All rights reserved.
//

import UIKit

/**
 * A class to represent a saved image.
 */
class SavedImage: NSObject {
    
    // The filename the image will be saved as.
    internal var fileName: String
    
    // The image to be saved.
    internal var image: UIImage
    
    // The date and time the image expires.
    internal var expireDate: Date
    
    // Whether or not the saved image is highlighted.
    internal var selected: Bool = false
    
    // Initialize a saved image from a UIImage.
    internal init(image: UIImage, expireDate: Date) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd-HH-mm-ss"
        self.fileName = "image-" + dateFormatter.string(from: Date()) + ".jpg"
        self.image = image
        self.expireDate = expireDate
    }
    
    // Initialize a saved image from file.
    internal init(file: String, expireDate: String) {
        self.fileName = file
        do {
            let fileURL = DataManager.baseURL.appendingPathComponent("/images/" + file)
            let imageData = try Data(contentsOf: fileURL)
            self.image = UIImage(data: imageData)!
        } catch {
            self.image = UIImage()
            print("SAVED IMAGE: Failed to load file: \(file)")
        }
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd/yyyy h:mm a"
        self.expireDate = dateFormatter.date(from: expireDate)!
    }
    
    // Gets a string for a more readable expire time.
    internal func getReadableExpireText() -> String {
        var expireTime = 0
        var units = ""
        if expireDate.years(from: Date()) > 0 {
            expireTime = expireDate.years(from: Date())
            units = "years"
        } else if expireDate.months(from: Date()) > 0 {
            expireTime = expireDate.months(from: Date())
            units = "months"
        } else if expireDate.days(from: Date()) > 0 {
            expireTime = expireDate.days(from: Date())
            units = "days"
        } else if expireDate.hours(from: Date()) > 0 {
            expireTime = expireDate.hours(from: Date())
            units = "hours"
        } else {
            expireTime = expireDate.minutes(from: Date())
            units = "minutes"
        }
        return "- Expires in \(expireTime) \(units) -"
    }
    
    // Saves the image to the device disk.
    internal func saveToDisk() {
        if let imageJPEG = UIImageJPEGRepresentation(image, 1.0) {
            do {
                let fileURL = DataManager.baseURL.appendingPathComponent("/images/" + fileName)
                try imageJPEG.write(to: fileURL)
            } catch {
                print("SAVED IMAGE: Failed to save file: \(fileName)")
            }
        }
    }
    
    // Deletes an image from the device disk.
    internal func deleteFromDisk() {
        do {
            let fileURL = DataManager.baseURL.appendingPathComponent("/images/" + fileName)
            try FileManager.default.removeItem(at: fileURL)
        } catch {
            print("SAVED IMAGE: Failed to delete file: \(fileName)")
        }
    }

}
