//
//  SavedImage.swift
//  Snapshot
//
//  Created by Jacob Mendelowitz on 7/12/17.
//  Copyright © 2017 Jacob Mendelowitz. All rights reserved.
//

import UIKit

class SavedImage: NSObject, NSCoding {
    
    // The image to be saved.
    internal var image: UIImage
    
    // The date and time the image expires.
    internal var expireDate: Date
    
    // Initialize a saved image.
    internal init(_ image: UIImage, expireDate: Date) {
        self.image = image
        self.expireDate = expireDate
    }
    
    // Initialize a saved image from stored data.
    internal required init?(coder decoder: NSCoder) {
        image = decoder.decodeObject(forKey: "image") as! UIImage
        expireDate = decoder.decodeObject(forKey: "expireDate") as! Date
    }
    
    // Encode a saved image into storable data.
    internal func encode(with coder: NSCoder) {
        coder.encode(image, forKey: "image")
        coder.encode(expireDate, forKey: "expireDate")
    }

}
