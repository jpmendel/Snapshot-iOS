//
//  SaveTimeViewController.swift
//  Snapshot
//
//  Created by Jacob Mendelowitz on 7/10/17.
//  Copyright © 2017 Jacob Mendelowitz. All rights reserved.
//

import UIKit

class SaveTimeViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    
    @IBOutlet weak var cancelButton: UIBarButtonItem!
    
    @IBOutlet weak var timePicker: UIPickerView!
    
    @IBOutlet weak var confirmButton: UIButton!
    
    private let timeUnitStrings: [String] = ["minutes", "hours", "days", "months", "years"]
    
    private let timeUnitValues: [Calendar.Component] = [.minute, .hour, .day, .month, .year]
    
    private var timeSelected: Int = 1
    
    private var unitSelected: Calendar.Component = .minute

    internal override func viewDidLoad() {
        super.viewDidLoad()
        setupActions()
        setupPicker()
        formatButtons()
    }
    
    private func setupActions() {
        cancelButton.target = self
        cancelButton.action = #selector(cancelButtonPress(_:))
        confirmButton.addTarget(self, action: #selector(confirmButtonPress(_:)), for: .touchDown)
    }
    
    private func setupPicker() {
        timePicker.delegate = self
        timePicker.dataSource = self
    }
    
    private func formatButtons() {
        confirmButton.layer.cornerRadius = 10
        confirmButton.clipsToBounds = true
    }
    
    internal func cancelButtonPress(_ sender: UIBarButtonItem) {
        navigationController?.popViewController(animated: true)
    }
    
    internal func confirmButtonPress(_ sender: UIButton) {
        if let image = DataManager.capturedImage {
            let expireDate = Calendar.current.date(byAdding: unitSelected, value: timeSelected, to: Date())!
            let savedImage = SavedImage(image, expireDate: expireDate)
            DataManager.savedImages += [savedImage]
            DataManager.saveData()
        }
        if let viewControllers = navigationController?.viewControllers {
            for viewController in viewControllers {
                if viewController is CameraViewController {
                    navigationController?.popToViewController(viewController, animated: true)
                }
            }
        }
    }
    
    internal func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 2
    }
    
    internal func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if component == 0 {
            return 60
        } else {
            return timeUnitStrings.count
        }
    }
    
    internal func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if (component == 0) {
            return String(1 + row)
        } else {
            return timeUnitStrings[row]
        }
    }
    
    internal func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if component == 0 {
            timeSelected = 1 + row
        } else {
            unitSelected = timeUnitValues[row]
        }
    }

}
