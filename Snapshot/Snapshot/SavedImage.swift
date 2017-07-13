//
//  SavedImage.swift
//  Snapshot
//
//  Created by Jacob Mendelowitz on 7/12/17.
//  Copyright © 2017 Jacob Mendelowitz. All rights reserved.
//

import UIKit

class SavedImage: NSObject, NSCoding {
    
    internal var id: String
    
    internal var expireDate: Date
    
    internal init(id: String, expireDate: Date) {
        self.id = id
        self.expireDate = expireDate
    }
    
    internal required init?(coder decoder: NSCoder) {
        id = decoder.decodeObject(forKey: "id") as! String
        expireDate = decoder.decodeObject(forKey: "expireDate") as! Date
    }
    
    internal func encode(with coder: NSCoder) {
        coder.encode(id, forKey: "id")
        coder.encode(expireDate, forKey: "expireDate")
    }

}
