//
//  UIViewController+Util.swift
//  Snapshot
//
//  Created by Jacob Mendelowitz on 7/23/17.
//  Copyright © 2017 Jacob Mendelowitz. All rights reserved.
//

import UIKit

extension UIViewController {
    
    internal func show(screen: String, animated: Bool = true, modal: Bool = false, setup: ((_ viewController: UIViewController) -> Void)? = nil) {
        if let viewController = storyboard?.instantiateViewController(withIdentifier: screen) {
            if let setupFunction = setup {
                setupFunction(viewController)
            }
            if modal {
                navigationController?.present(viewController, animated: animated, completion: nil)
            } else {
                navigationController?.pushViewController(viewController, animated: animated)
            }
        }
    }
    
    internal func back(animated: Bool = true) {
        navigationController?.popViewController(animated: animated)
    }
    
    internal func back<T>(to screen: T.Type, animated: Bool = true) {
        if let viewControllers = navigationController?.viewControllers {
            for viewController in viewControllers {
                if viewController is T {
                    navigationController?.popToViewController(viewController, animated: animated)
                }
            }
        }
    }
    
    internal func close(from navController: UINavigationController? = nil, animated: Bool = true) {
        if let nav = navController {
            nav.dismiss(animated: animated, completion: nil)
        } else {
            navigationController?.dismiss(animated: animated, completion: nil)
        }
    }
    
}
