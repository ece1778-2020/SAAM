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
        if Auth.auth().currentUser != nil{
            guard let uid = Auth.auth().currentUser?.uid else{return}
        Database.database().reference().child("users").child(uid).observeSingleEvent(of: .value, with:{(SAAM) in
                guard let dict = SAAM.value as? [String: Any] else {return}
                self.userNameShow.text = dict["username"]as? String ?? ""
            }, withCancel: {(err) in
                print(err)
            })
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
    


}
