//
//  DataManager.swift
//  Snapshot
//
//  Created by Jacob Mendelowitz on 7/10/17.
//  Copyright © 2017 Jacob Mendelowitz. All rights reserved.
//

import UIKit

class DataManager: NSObject {
    
    internal static var capturedImage: UIImage?
    
    internal static var savedImages: [SavedImage] = [SavedImage]()
    
    internal static func saveData() {
        let userDefaults = UserDefaults.standard
        let encodedData = NSKeyedArchiver.archivedData(withRootObject: savedImages)
        userDefaults.set(encodedData, forKey: "SSSavedImages")
        userDefaults.synchronize()
    }
    
    internal static func loadData() {
        let userDefaults = UserDefaults.standard
        if let decodedData = userDefaults.object(forKey: "SSSavedImages") as? Data {
            savedImages = NSKeyedUnarchiver.unarchiveObject(with: decodedData) as! [SavedImage]
        }
    }
    
    internal static func checkExpiredImages() {
        for i in stride(from: savedImages.count - 1, through: 0, by: -1) {
            if savedImages[i].expireDate < Date() {
                savedImages.remove(at: i)
            }
        }
    }

}
