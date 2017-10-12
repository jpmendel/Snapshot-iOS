//
//  SaveOptionsViewController.swift
//  Snapshot
//
//  Created by Jacob Mendelowitz on 7/10/17.
//  Copyright © 2017 Jacob Mendelowitz. All rights reserved.
//

import UIKit

/**
 * A class to control the screen that shows the user their options for setting the time to save an image.
 */
class SaveOptionsViewController: UIViewController {

    // The cancel button in the top left.
    @IBOutlet weak var cancelButton: UIBarButtonItem!
    
    // The button to save an image for a certain amount of time.
    @IBOutlet weak var saveTimeButton: UIButton!
    
    // The button to save an image until a certain date.
    @IBOutlet weak var saveDateButton: UIButton!
    
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
        saveTimeButton.addTarget(self, action: #selector(saveTimeButtonPress(_:)), for: .touchDown)
        saveDateButton.addTarget(self, action: #selector(saveDateButtonPress(_:)), for: .touchDown)
    }
    
    // Formats the appearance of the buttons on the screen.
    private func formatButtons() {
        saveTimeButton.layer.cornerRadius = 10
        saveTimeButton.clipsToBounds = true
        saveDateButton.layer.cornerRadius = 10
        saveDateButton.clipsToBounds = true
    }
    
    // Go back to the main view controller when cancel is pressed.
    @objc private func cancelButtonPress(_ sender: UIBarButtonItem) {
        back()
    }
    
    // Go to the screen to select a time value for how long to save an image.
    @objc private func saveTimeButtonPress(_ sender: UIButton) {
        show(screen: "SaveTimeViewController")
    }
    
    // Go to the screen to select a date to save an image until.
    @objc private func saveDateButtonPress(_ sender: UIButton) {
        show(screen: "SaveDateViewController")
    }

}
