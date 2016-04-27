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
        self.view.endEditing(false)
    }
    
    func viewUpByKeyboard(){
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(UIViewController.keyboardWillShow(_:)), name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(UIViewController.keyboardWillHide(_:)), name: UIKeyboardWillHideNotification, object: nil)
    }
    
    func keyboardWillShow(notification: NSNotification) {
        if self.view.tag == 0{
            if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.CGRectValue() {
                print("키보드 올라가기전 y\(self.view.frame.origin.y)")
                self.view.frame.origin.y -= keyboardSize.height
                self.view.tag = 1
            }
        }
        
    }
    
    func keyboardWillHide(notification: NSNotification) {
        if self.view.tag == 1{
            self.view.frame.origin.y = 0
            self.view.tag = 0
        }
    }
}

extension ViewController: UITextViewDelegate{
    func textViewDidChange(textView: UITextView) {
        print("텍스트뷰 바뀌었는데 왜 안 불리냐 --")
        tableView.beginUpdates()
        tableView.endUpdates()
    }
    func textViewDidEndEditing(textView: UITextView) {
        print("엔딩")
    }
}

extension ViewController: UITextFieldDelegate{
    
    func textFieldDidEndEditing(textField: UITextField) {
        print("아아")
    }
    
}
