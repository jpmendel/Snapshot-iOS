//
//  DataManager.swift
//  Snapshot
//
//  Created by Jacob Mendelowitz on 7/10/17.
//  Copyright © 2017 Jacob Mendelowitz. All rights reserved.
//

import UIKit

class DataManager: NSObject {
    
    // The image that was most recently captured by the camera.
    internal static var capturedImage: UIImage?
    
    // A list of images that has been saved by the user.
    internal static var savedImages: [SavedImage] = [SavedImage]()
    
    // Saves a list of images into device storage.
    internal static func saveData() {
        let userDefaults = UserDefaults.standard
        let encodedData = NSKeyedArchiver.archivedData(withRootObject: savedImages)
        userDefaults.set(encodedData, forKey: "SSSavedImages")
        userDefaults.synchronize()
    }
    
    // Loads a list of images from device storage.
    internal static func loadData() {
        let userDefaults = UserDefaults.standard
        if let decodedData = userDefaults.object(forKey: "SSSavedImages") as? Data {
            savedImages = NSKeyedUnarchiver.unarchiveObject(with: decodedData) as! [SavedImage]
        }
    }
    
    // Loops through saved images to check for expired ones.
    internal static func checkExpiredImages() {
        for i in stride(from: savedImages.count - 1, through: 0, by: -1) {
            if savedImages[i].expireDate < Date() {
                savedImages.remove(at: i)
            }
        }
    }

}
