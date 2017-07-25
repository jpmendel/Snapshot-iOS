//
//  SaveDateViewController.swift
//  Snapshot
//
//  Created by Jacob Mendelowitz on 7/10/17.
//  Copyright © 2017 Jacob Mendelowitz. All rights reserved.
//

import UIKit

class SaveDateViewController: UIViewController {

    // The cancel button in the top left.
    @IBOutlet weak var cancelButton: UIBarButtonItem!
    
    // The picker to select the date to save the image until.
    @IBOutlet weak var datePicker: UIDatePicker!
    
    // The button to confirm the save date.
    @IBOutlet weak var confirmButton: UIButton!
    
    // Runs when the view controller first loads.
    internal override func viewDidLoad() {
        super.viewDidLoad()
        setupActions()
        formatButtons()
    }
    
    // Sets up the actions for any interactive objects on the screen.
    private func setupActions() {
        cancelButton.target = self
        cancelButton.action = #selector(cancelButtonPress(_:))
        confirmButton.addTarget(self, action: #selector(confirmButtonPress(_:)), for: .touchDown)
    }
    
    // Formats the appearance of the buttons on the screen.
    private func formatButtons() {
        confirmButton.layer.cornerRadius = 10
        confirmButton.clipsToBounds = true
    }

    // Go back one screen when cancel is pressed.
    internal func cancelButtonPress(_ sender: UIBarButtonItem) {
        back()
    }
    
    // Save the image when the button is pressed and go back to the main screen.
    internal func confirmButtonPress(_ sender: UIButton) {
        if let image = DataManager.capturedImage {
            let savedImage = SavedImage(image, expireDate: datePicker.date)
            DataManager.savedImages += [savedImage]
            DataManager.saveData()
        }
        back(to: CameraViewController.self)
    }
    
}
