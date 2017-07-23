//
//  SaveDateViewController.swift
//  Snapshot
//
//  Created by Jacob Mendelowitz on 7/10/17.
//  Copyright © 2017 Jacob Mendelowitz. All rights reserved.
//

import UIKit

class SaveDateViewController: UIViewController {

    @IBOutlet weak var cancelButton: UIBarButtonItem!
    
    @IBOutlet weak var datePicker: UIDatePicker!
    
    @IBOutlet weak var confirmButton: UIButton!
    
    internal override func viewDidLoad() {
        super.viewDidLoad()
        setupActions()
        formatButtons()
    }
    
    private func setupActions() {
        cancelButton.target = self
        cancelButton.action = #selector(cancelButtonPress(_:))
        confirmButton.addTarget(self, action: #selector(confirmButtonPress(_:)), for: .touchDown)
    }
    
    private func formatButtons() {
        confirmButton.layer.cornerRadius = 10
        confirmButton.clipsToBounds = true
    }

    internal func cancelButtonPress(_ sender: UIBarButtonItem) {
        back()
    }
    
    internal func confirmButtonPress(_ sender: UIButton) {
        if let image = DataManager.capturedImage {
            let savedImage = SavedImage(image, expireDate: datePicker.date)
            DataManager.savedImages += [savedImage]
            DataManager.saveData()
        }
        back(to: CameraViewController.self)
    }
    
}
