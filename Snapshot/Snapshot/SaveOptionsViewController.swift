//
//  SaveOptionsViewController.swift
//  Snapshot
//
//  Created by Jacob Mendelowitz on 7/10/17.
//  Copyright © 2017 Jacob Mendelowitz. All rights reserved.
//

import UIKit

class SaveOptionsViewController: UIViewController {

    @IBOutlet weak var cancelButton: UIBarButtonItem!
    
    @IBOutlet weak var saveTimeButton: UIButton!
    
    @IBOutlet weak var saveDateButton: UIButton!
    
    internal override func viewDidLoad() {
        super.viewDidLoad()
        setupActions()
        formatButtons()
    }
    
    private func setupActions() {
        cancelButton.target = self
        cancelButton.action = #selector(cancelButtonPress(_:))
        saveTimeButton.addTarget(self, action: #selector(saveTimeButtonPress(_:)), for: .touchDown)
        saveDateButton.addTarget(self, action: #selector(saveDateButtonPress(_:)), for: .touchDown)
    }
    
    private func formatButtons() {
        saveTimeButton.layer.cornerRadius = 10
        saveTimeButton.clipsToBounds = true
        saveDateButton.layer.cornerRadius = 10
        saveDateButton.clipsToBounds = true
    }
    
    internal func cancelButtonPress(_ sender: UIBarButtonItem) {
        back()
    }
    
    internal func saveTimeButtonPress(_ sender: UIButton) {
        show(screen: "saveTimeViewController")
    }
    
    internal func saveDateButtonPress(_ sender: UIButton) {
        show(screen: "saveDateViewController")
    }

}
