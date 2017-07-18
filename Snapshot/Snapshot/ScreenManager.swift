//
//  ScreenManager.swift
//  Snapshot
//
//  Created by Jacob Mendelowitz on 7/17/17.
//  Copyright © 2017 Jacob Mendelowitz. All rights reserved.
//

import UIKit

class ScreenManager: NSObject {
    
    internal static func show(_ screen: String, from target: UIViewController, modal: Bool) {
        if let viewController = target.storyboard?.instantiateViewController(withIdentifier: screen) {
            if modal {
                target.navigationController?.present(viewController, animated: true, completion: nil)
            } else {
                target.navigationController?.pushViewController(viewController, animated: true)
            }
        }
    }
    
    internal static func show<T>(_ screen: String, from target: UIViewController, modal: Bool, setup: (_ viewController: T) -> Void) {
        if let viewController = target.storyboard?.instantiateViewController(withIdentifier: screen) {
            setup(viewController as! T)
            if modal {
                target.navigationController?.present(viewController, animated: true, completion: nil)
            } else {
                target.navigationController?.pushViewController(viewController, animated: true)
            }
        }
    }
    
    internal static func back(from target: UIViewController) {
        target.navigationController?.popViewController(animated: true)
    }
    
    internal static func backTo<T>(_ screen: T.Type, from target: UIViewController) {
        if let viewControllers = target.navigationController?.viewControllers {
            for viewController in viewControllers {
                if viewController is T {
                    target.navigationController?.popToViewController(viewController, animated: true)
                }
            }
        }
    }
    
    internal static func close(modal: UIViewController) {
        modal.navigationController?.dismiss(animated: true, completion: nil)
    }

}
