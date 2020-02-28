//
//  ProfileViewController.swift
//  SAAMClient
//
//  Created by AdamLi on 2020/2/21.
//  Modified by Xiaoyi Wang on 2020/2/27
//  Copyright © 2020 SAAM. All rights reserved.
//

import UIKit
import Firebase
import Foundation
import FirebaseAuth
import FirebaseDatabase
import FirebaseStorage


class ProfileViewController:  UIViewController, UITextFieldDelegate{

    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var repeatPasswordTextField: UITextField!
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var errorLabel: UILabel!
    let userDefault = UserDefaults.standard
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event:UIEvent?){
        self.view.endEditing(true)
    }
    func signInUser(email: String, password: String){
        
        Auth.auth().signIn(withEmail: email, password: password) {
            (user, error) in
            print("sign in loaded here")
            if error == nil{
                //signed in
                print("User Signed In")
                self.userDefault.set(true, forKey: "usersignedin")
                self.userDefault.synchronize()
                //To the profile page
                self.performSegue(withIdentifier: "profileView", sender: self)
                print("signed in performed")
            }else{
                print(error?.localizedDescription)
                print("sign in failed")
            }
        }
    }
    
    
    
    @IBAction func registerButtonTapped(_ sender: Any) {
        guard let username = usernameTextField.text else {return}
        guard let email = emailTextField.text else {return}
        guard let password = passwordTextField.text else {return}
        guard let repeatpass = repeatPasswordTextField.text else {return}
            
        //input varification
        if email == ""{
            self.errorLabel.text = "Please provide an email"
        }else if password == ""{
            self.errorLabel.text = "Please provide a password"
        }else if repeatpass == ""{
            self.errorLabel.text = "Please confirm the password"
        }else if username == ""{
            self.errorLabel.text = "Please provide a username"
        }else if password != repeatpass{
            self.errorLabel.text = "password inconsistent"
        }else{
            Auth.auth().createUser(withEmail: email, password: password){
            user, error in
                print("after creating user performed")
                if error == nil && user != nil{
                    //user created
                    print("user created")
                    //log in first
                    self.signInUser(email: email, password: password)
                    //Save the user's name
                    self.saveProfile(username: username) { success in
                        if success {
                            self.performSegue(withIdentifier: "profileView", sender: self)
                        }
                        else {print("saveProfile failed and per seguae fail")}
                    }
                }else{
                    self.errorLabel.text = error!.localizedDescription
                }
            }
        }
        
    }
    
    @IBAction func BackToLoginButtonTapped(_ sender: Any) {
        print("back to log in")
        //Go back to the login page
        self.dismiss(animated: true, completion: nil)
    }
    
    //Update the username
    func saveProfile(username:String, completion: @escaping ((_ success:Bool)->())) {
        
        //Change User's auth info
        if let u = Auth.auth().currentUser{
            let changeNameRequist = u.createProfileChangeRequest()
            //save username to auth displayname
            changeNameRequist.displayName = username
            changeNameRequist.commitChanges{(error) in
                if error != nil{
                    //display error on the screen
                    self.errorLabel.text = error?.localizedDescription
                }
            }
        }
    }
    
}
