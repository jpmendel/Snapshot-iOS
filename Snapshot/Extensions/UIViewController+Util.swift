//
//  UIViewController+Util.swift
//  Snapshot
//
//  Created by Jacob Mendelowitz on 7/23/17.
//  Copyright © 2017 Jacob Mendelowitz. All rights reserved.
//

import UIKit

/**
 * Utility extensions for the UIViewController.
 */
extension UIViewController {
    
    // Shows a new app stack screen.
    internal func show(screen: String, animated: Bool = true, setup: ((_ viewController: UIViewController) -> Void)? = nil) {
        if let viewController = storyboard?.instantiateViewController(withIdentifier: screen) {
            if let setupFunction = setup {
                setupFunction(viewController)
            }
            navigationController?.pushViewController(viewController, animated: animated)
        }
    }
    
    // Shows a new modal screen.
    internal func show(modal: String, animated: Bool = true, setup: ((_ viewController: UIViewController) -> Void)? = nil) {
        if let viewController = storyboard?.instantiateViewController(withIdentifier: modal) {
            if let setupFunction = setup {
                setupFunction(viewController)
            }
            navigationController?.present(viewController, animated: animated, completion: nil)
        }
    }
    
    // Goes back to the last viewed screen.
    internal func back(animated: Bool = true) {
        navigationController?.popViewController(animated: animated)
    }
    
    // Goes back to a screen of a specific type.
    internal func back<T>(to screen: T.Type, animated: Bool = true) {
        if let viewControllers = navigationController?.viewControllers {
            for viewController in viewControllers {
                if viewController is T {
                    navigationController?.popToViewController(viewController, animated: animated)
                }
            }
        }
    }
    
    // Closes a modal screen.
    internal func close(from navController: UINavigationController? = nil, animated: Bool = true) {
        if let nav = navController {
            nav.dismiss(animated: animated, completion: nil)
        } else {
            navigationController?.dismiss(animated: animated, completion: nil)
        }
    }
    
}
