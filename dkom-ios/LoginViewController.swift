//
//  LoginViewController.swift
//  dkom-ios
//
//  Created by Ran Hassid on 08/01/2019.
//  Copyright © 2019 Trench Girls LTD. All rights reserved.
//

import UIKit
import Parse
import SVProgressHUD

class LoginViewController: UIViewController  {
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    
    private var currentTextField: UITextField?
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Login"
    }

    @IBAction func onLoginClicked(_ sender: Any) {
        
        // hide keyboard
        self.currentTextField?.resignFirstResponder()
        
        // validate form 
        guard let email = self.emailTextField.text, let password = self.passwordTextField.text else {
            return
        }
        
        SVProgressHUD.show()
        
        TFUser.logInWithUsername(inBackground: email, password: password) {[weak self] (user, error) in
            
            SVProgressHUD.dismiss()
            
            guard let `self` = self else { return }
            
            guard error == nil else {
                self.presentServerError(error: error!)
                return
            }
            
            NotificationCenter.default.post(name: .loggedIn, object: nil)
        }
        
    }
    
    private func presentServerError(error: Error) {
        let alert = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
        
        let action = UIAlertAction(title: "Close", style: .cancel, handler: nil)
        alert.addAction(action)
        
        self.present(alert, animated: true, completion: nil)
    }
    
}

extension LoginViewController : UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        self.currentTextField = textField
    }
}
