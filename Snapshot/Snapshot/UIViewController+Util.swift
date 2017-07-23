//
//  UIViewController+Util.swift
//  Snapshot
//
//  Created by Jacob Mendelowitz on 7/23/17.
//  Copyright © 2017 Jacob Mendelowitz. All rights reserved.
//

import UIKit

extension UIViewController {
    
    internal func show(screen: String, modal: Bool = false) {
        if let viewController = storyboard?.instantiateViewController(withIdentifier: screen) {
            if modal {
                navigationController?.present(viewController, animated: true, completion: nil)
            } else {
                navigationController?.pushViewController(viewController, animated: true)
            }
        }
    }
    
    internal func show<T>(screen: String, modal: Bool = false, setup: (_ viewController: T) -> Void) {
        if let viewController = storyboard?.instantiateViewController(withIdentifier: screen) {
            setup(viewController as! T)
            if modal {
                navigationController?.present(viewController, animated: true, completion: nil)
            } else {
                navigationController?.pushViewController(viewController, animated: true)
            }
        }
    }
    
    internal func back() {
        navigationController?.popViewController(animated: true)
    }
    
    internal func back<T>(to screen: T.Type) {
        if let viewControllers = navigationController?.viewControllers {
            for viewController in viewControllers {
                if viewController is T {
                    navigationController?.popToViewController(viewController, animated: true)
                }
            }
        }
    }
    
    internal func close() {
        navigationController?.dismiss(animated: true, completion: nil)
    }
    
}
