//
//  RegisterViewController.swift
//  PeopleMon
//
//  Created by David  Bowen on 11/6/16.
//  Copyright © 2016 David  Bowen. All rights reserved.
//

import UIKit
import MBProgressHUD

class RegisterViewController: UIViewController {
    
    @IBOutlet weak var fullName: UITextField!
    @IBOutlet weak var emailAddress: UITextField!
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var confirmPassword: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func register(_ sender: Any) {
    
        let avatarBase64 = "Scott"

        guard let fullName = fullName.text, fullName != "" else {
            let alert = Utils.createAlert("Login Error", message: "Please provide a Full Name", dismissButtonTitle: "Dismiss")
            present(alert, animated: true, completion: nil)
            return
        }
        
        guard let email =  emailAddress.text, email != "" && Utils.isValidEmail(email) else {
            let alert = Utils.createAlert("Login Error", message: "Please provide an email", dismissButtonTitle: "Dismiss")
            present(alert, animated: true, completion: nil)
            return
        }
        
        guard let password = password.text, password != "" else {
            let alert = Utils.createAlert("Login Error", message: "Please provide a password", dismissButtonTitle: "Dismiss")
            present(alert, animated: true, completion: nil)
            return
        }
        
        guard let confirmPassword = confirmPassword.text, confirmPassword == password else {
            let alert = Utils.createAlert("Login Error", message: "Passwords do not match", dismissButtonTitle: "Dismiss")
            present(alert, animated: true, completion: nil)
            return
        }
        
        MBProgressHUD.showAdded(to: view, animated: true)
        
        let user = User(email: email, fullName: fullName, password: password, avatarBase64: avatarBase64)
        UserStore.shared.register(user) { (success, error) in
            MBProgressHUD.hide(for: self.view, animated: true)
            if success {
                self.dismiss(animated: true, completion: nil)
            } else if let error = error {
                self.present(Utils.createAlert(message: error), animated: true, completion: nil)
            } else {
                self.present(Utils.createAlert(message: Constants.JSON.unknownError), animated: true, completion: nil)
            }
        }
    }
}
