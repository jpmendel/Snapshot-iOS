//
//  SaveTimeViewController.swift
//  Snapshot
//
//  Created by Jacob Mendelowitz on 7/10/17.
//  Copyright © 2017 Jacob Mendelowitz. All rights reserved.
//

import UIKit

class SaveTimeViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    
    // The cancel button in the top left.
    @IBOutlet weak var cancelButton: UIBarButtonItem!
    
    // The picker to select the time to save for.
    @IBOutlet weak var timePicker: UIPickerView!
    
    // The button to confirm the save time.
    @IBOutlet weak var confirmButton: UIButton!
    
    // An array of the different types of units for time.
    private let timeUnitStrings: [String] = ["minutes", "hours", "days", "months", "years"]
    
    // The calendar values for each time unit.
    private let timeUnitValues: [Calendar.Component] = [.minute, .hour, .day, .month, .year]
    
    // The time value selected.
    private var timeSelected: Int = 1
    
    // The time unit selected.
    private var unitSelected: Calendar.Component = .minute

    // Runs when the view controller first loads.
    internal override func viewDidLoad() {
        super.viewDidLoad()
        setupActions()
        setupPicker()
        formatButtons()
    }
    
    // Sets up the actions for any interactive objects on the screen.
    private func setupActions() {
        cancelButton.target = self
        cancelButton.action = #selector(cancelButtonPress(_:))
        confirmButton.addTarget(self, action: #selector(confirmButtonPress(_:)), for: .touchDown)
    }
    
    // Setup the time value picker.
    private func setupPicker() {
        timePicker.delegate = self
        timePicker.dataSource = self
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
            let expireDate = Calendar.current.date(byAdding: unitSelected, value: timeSelected, to: Date())!
            let savedImage = SavedImage(image, expireDate: expireDate)
            DataManager.savedImages += [savedImage]
            DataManager.saveData()
        }
        back(to: CameraViewController.self)
    }
    
    // Set the number of components in the time value picker.
    internal func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 2
    }
    
    // Set the number of rows in the time value picker.
    internal func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if component == 0 {
            return 60
        } else {
            return timeUnitStrings.count
        }
    }
    
    // Set the title for each row of the time value picker.
    internal func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if (component == 0) {
            return String(1 + row)
        } else {
            return timeUnitStrings[row]
        }
    }
    
    // Action to perform when a value of the picker is landed on.
    internal func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if component == 0 {
            timeSelected = 1 + row
        } else {
            unitSelected = timeUnitValues[row]
        }
    }

}
