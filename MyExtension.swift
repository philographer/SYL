//
//  MyExtension.swift
//  syl
//
//  Created by 유호균 on 2016. 4. 14..
//  Copyright © 2016년 timeros. All rights reserved.
//

import Foundation
import UIKit

extension NSLayoutConstraint {
    /*
    override public var description: String {
        let id = self.identifier ?? "없어"
        
        return "id: \(id), constant: \(constant)" //you may print whatever you want here
    }
    */
}

extension UIViewController {
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.dismissKeyboard))
        view.addGestureRecognizer(tap)
    }
    
    func dismissKeyboard() {
        view.endEditing(true)
    }
}