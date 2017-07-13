//
//  SavedImage.swift
//  Snapshot
//
//  Created by Jacob Mendelowitz on 7/12/17.
//  Copyright © 2017 Jacob Mendelowitz. All rights reserved.
//

import UIKit

class SavedImage: NSObject, NSCoding {
    
    internal var image: UIImage
    
    internal var expireDate: Date
    
    internal init(_ image: UIImage, expireDate: Date) {
        self.image = image
        self.expireDate = expireDate
    }
    
    internal required init?(coder decoder: NSCoder) {
        image = decoder.decodeObject(forKey: "image") as! UIImage
        expireDate = decoder.decodeObject(forKey: "expireDate") as! Date
    }
    
    internal func encode(with coder: NSCoder) {
        coder.encode(image, forKey: "image")
        coder.encode(expireDate, forKey: "expireDate")
    }

}
