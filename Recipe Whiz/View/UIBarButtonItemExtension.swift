//
//  UIBarButtonItemExtension.swift
//  TinyChef
//
//  Created by David Hsieh on 1/12/22.
//

import Foundation
import UIKit

extension UIBarButtonItem {
    func sendAction() {
        guard let target = target else { return }
        guard let action = action else { return }
        let control: UIControl = UIControl()
        control.sendAction(action, to: target, for: nil)
    }
}
