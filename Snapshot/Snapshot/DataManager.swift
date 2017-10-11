//
//  DataManager.swift
//  Snapshot
//
//  Created by Jacob Mendelowitz on 7/10/17.
//  Copyright © 2017 Jacob Mendelowitz. All rights reserved.
//

import UIKit
import SQLite3

class DataManager: NSObject {
    
    // The image that was most recently captured by the camera.
    internal static var capturedImage: UIImage?
    
    // A list of images that has been saved by the user.
    internal static var savedImages: [SavedImage] = [SavedImage]()
    
    // A pointer to the SQLite3 database used to store data.
    internal static var database: OpaquePointer? = nil
    
    internal static func setup() {
        createDirectories()
        openDatabase()
        loadData()
    }
    
    internal static func createDirectories() {
        let appDirectory = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        let imageDirectoryPath = appDirectory + "/images"
        do {
            try FileManager.default.createDirectory(atPath: imageDirectoryPath, withIntermediateDirectories: true, attributes: nil)
        } catch {
            print("Failed to create image directory.")
        }
    }
    
    // Loads a list of images from device storage.
    internal static func loadData() {
        if database != nil {
            if createSavedImageTable() {
                if let images = getAllImageRecords() {
                    savedImages = images
                }
            }
        }
    }
    
    // Opens the SQL database.
    internal static func openDatabase() {
        let appDirectory = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        let databasePath = appDirectory + "/database.sqlite"
        print(databasePath)
        var openDB: OpaquePointer? = nil
        if sqlite3_open(databasePath, &openDB) == SQLITE_OK {
            database = openDB
        } else {
            print("Error opening database.")
        }
    }
    
    // Closes the SQL database.
    internal static func closeDatabase() {
        sqlite3_close(database)
    }
    
    // Creates a table to store data on saved images.
    internal static func createSavedImageTable() -> Bool {
        var success = false
        let createTableSQLCode = "CREATE TABLE IF NOT EXISTS saved_images (image_file TEXT, expire_date TEXT);"
        var createTableStatement: OpaquePointer? = nil
        if sqlite3_prepare_v2(database, createTableSQLCode, -1, &createTableStatement, nil) == SQLITE_OK {
            if sqlite3_step(createTableStatement) == SQLITE_DONE {
                success = true
            }
        }
        sqlite3_finalize(createTableStatement)
        return success
    }
    
    // Inserts a saved image into the database.
    internal static func saveImageRecord(_ savedImage: SavedImage) -> Bool {
        var success = false
        let insertImageSQLCode = "INSERT INTO saved_images (image_file, expire_date) VALUES (?, ?);"
        var insertImageStatement: OpaquePointer? = nil
        if sqlite3_prepare_v2(database, insertImageSQLCode, -1, &insertImageStatement, nil) == SQLITE_OK {
            let imageFile = savedImage.fileName as NSString
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "MM/dd/yy h:mm a"
            let dateString = dateFormatter.string(from: savedImage.expireDate) as NSString
            sqlite3_bind_text(insertImageStatement, 1, imageFile.utf8String, -1, nil)
            sqlite3_bind_text(insertImageStatement, 2, dateString.utf8String, -1, nil)
            if sqlite3_step(insertImageStatement) == SQLITE_DONE {
                success = true
            }
        }
        sqlite3_finalize(insertImageStatement)
        return success
    }
    
    // Gets all saved images from the database.
    internal static func getAllImageRecords() -> [SavedImage]? {
        var savedImages: [SavedImage]? = nil
        let readImagesSQLCode = "SELECT * FROM saved_images;"
        var readImagesStatement: OpaquePointer? = nil
        if sqlite3_prepare_v2(database, readImagesSQLCode, -1, &readImagesStatement, nil) == SQLITE_OK {
            savedImages = [SavedImage]()
            while sqlite3_step(readImagesStatement) == SQLITE_ROW {
                let imageFile = String(cString: sqlite3_column_text(readImagesStatement, 0))
                let expireDate = String(cString: sqlite3_column_text(readImagesStatement, 1))
                savedImages! += [SavedImage(file: imageFile, expireDate: expireDate)]
            }
        }
        sqlite3_finalize(readImagesStatement)
        return savedImages
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
