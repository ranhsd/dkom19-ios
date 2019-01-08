//
//  RegisterViewController.swift
//  dkom-ios
//
//  Created by Ran Hassid on 08/01/2019.
//  Copyright © 2019 Trench Girls LTD. All rights reserved.
//

import UIKit
import Parse
import SVProgressHUD
import SwifterSwift

class RegisterViewController: UIViewController {
    
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var registerButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Register"

        // Do any additional setup after loading the view.
    }
    
    @IBAction func onRegisterButtonClicked(_ sender: UIButton) {
        
        if !self.formIsValid() {
            self.presentFormInvalidAlert()
            return
        }
 
        let user = TFUser()
        user.email = self.emailTextField.text
        user.username = self.emailTextField.text
        user.password = self.passwordTextField.text
        user.name = self.nameTextField.text
        
        SVProgressHUD.show()

        user.signUpInBackground {(success, error) in
        

            SVProgressHUD.dismiss()
            
            if success {
                NotificationCenter.default.post(name: .registered, object: nil)
            }
        }
    }
    
    private func formIsValid() -> Bool {
        
        guard let email = self.emailTextField.text, let password = self.passwordTextField.text, let name = self.nameTextField.text else {
            return false
        }
        
        
        if !email.isValidEmail || password.count < 4 || name.count < 2 {
            return false
        }
        
        return true
    }
    
    private func presentFormInvalidAlert() {
        let alert = UIAlertController(title: "Error", message: "Form is not valid", preferredStyle: .alert)
        
        let action = UIAlertAction(title: "Close", style: .cancel, handler: nil)
        alert.addAction(action)
        
        self.present(alert, animated: true, completion: nil)
    }

    private func presentHome() {
        
    }
}
