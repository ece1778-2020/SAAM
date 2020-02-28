//
//  InitViewController.swift
//  SAAMClient
//
//  Created by Xiaoyi Wang on 2020-02-26.
//  Copyright © 2020 SAAM. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore

class InitViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

    }
    

    //init Firestore and Firebase Storage
    let db = Firestore.firestore()
    
    //if view has appearred
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        
        //if no one log in or the current user has logged out
        if Auth.auth().currentUser == nil{
            //go to the log in page
            performSegue(withIdentifier: "InitToLogin", sender:self )
        }else{
            //go to the profile page of the current user
            self.performSegue(withIdentifier: "InitToProfile", sender:self )
        }
    }

}
