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

        // Do any additional setup after loading the view.
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
            self.performSegue(withIdentifier: "InitToProfile", sender:self )
        }
    }

}
