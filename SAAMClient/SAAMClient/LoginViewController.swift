//
//  LoginViewController.swift
//  SAAMClient
//
//  Created by AdamLi on 2020/2/21.
//  Copyright © 2020 SAAM. All rights reserved.
//

import UIKit
import Firebase

class LoginViewController: UIViewController, UITextFieldDelegate {

    
    
    @IBOutlet weak var usernameText: UITextField!
    @IBOutlet weak var userPasswordText: UITextField!
    
    //Constants
    let userDefault = UserDefaults.standard
    
    override func viewDidAppear(_ animated: Bool){
        if userDefault.bool(forKey: "usersignedin"){
           // performSegue(withIdentifier: "signinToProfile", sender: self)
        }
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event:UIEvent?){
        self.view.endEditing(true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    func signInUser(email: String, password: String){
        Auth.auth().signIn(withEmail: email, password: password) {
            (user, error) in
            if error == nil{
                //signed in
                print("User Signed In")
                self.userDefault.set(true, forKey: "usersignedin")
                self.userDefault.synchronize()
                self.performSegue(withIdentifier: "signinToProfile", sender: self)
            }
            else{
                print(error)
                print(error?.localizedDescription)
            }
        }
    }
    @IBAction func signinButtonTapped(_ sender: Any) {
        print("Sign in button tapped.");
            signInUser(email: usernameText.text!, password: userPasswordText.text!)
    }
    
    @IBAction func signupButtonTapped(_ sender: Any) {
        print("Sign up button tapped.");
        performSegue(withIdentifier: "signinToProfile", sender: self)
    }
    
}
