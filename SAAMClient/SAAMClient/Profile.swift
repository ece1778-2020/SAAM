//
//  Profile.swift
//  SAAMClient
//
//  Created by AdamLi on 2020/2/22.
//  Copyright © 2020 SAAM. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseDatabase
import FirebaseStorage

class Profile: UIViewController,UITextFieldDelegate {
    @IBOutlet weak var userNameShow: UILabel!
    let userDefault = UserDefaults.standard
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        print(Auth.auth().currentUser?.uid)
        if let username = Auth.auth().currentUser?.displayName {
            self.userNameShow.text = username;
        }
    }
    
    @IBAction func signoutButtonTapped(_ sender: Any) {
        do{
            try Auth.auth().signOut()
            userDefault.removeObject(forKey: "usersignedin")
            userDefault.synchronize()
            //self.dismiss(animated: true, completion: nil)
            performSegue(withIdentifier: "backtoSignIn", sender: self)
        } catch let error as NSError{
            print(error.localizedDescription)
        }
    }
    
    @IBAction func AssessmentButton(_ sender: UIButton) {
        print(Auth.auth().currentUser?.displayName)
        //performSegue(withIdentifier: "AssessmentView", sender: self)
    }
    

}
