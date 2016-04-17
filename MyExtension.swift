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
    
    func viewUpByKeyboard(){
            print("workd")
            NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(self.keyBoardWiilUo(_:)), name:UIKeyboardWillShowNotification, object: nil);
            NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(self.keyboardWillDown(_:)), name:UIKeyboardWillHideNotification, object: nil);
            // Do any additional setup after loading the view.
    }
    
    func keyBoardWiilUo(sender: NSNotification) {
        self.view.frame.origin.y -= 200
    }
    func keyboardWillDown(sender: NSNotification) {
        self.view.frame.origin.y += 200
    }
}