//
//  Profile.swift
//  SAAMClient
//
//  Created by AdamLi on 2020/2/22.
//  Modified by Xiaoyi Wang on 2020/2/27
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
        //Get the username of the current user
        if let username = Auth.auth().currentUser?.displayName {
            self.userNameShow.text = username;
        }
    }
    
    
    @IBAction func Summaries(_ sender: UIButton) {
        performSegue(withIdentifier: "ToSummary", sender: self)
    }
    

    @IBAction func signoutButtonTapped(_ sender: Any) {
        do{
            try Auth.auth().signOut()
            //signout
            userDefault.removeObject(forKey: "usersignedin")
            userDefault.synchronize()
            performSegue(withIdentifier: "backtoSignIn", sender: self)
        } catch let error as NSError{
            print(error.localizedDescription)
        }
    }
    
    @IBAction func AssessmentButton(_ sender: UIButton) {
        //Go to Question Generator
        performSegue(withIdentifier: "ToQG", sender: self)
    }
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
       if
         let _ =  userNameShow.text{
         return true
       }
       
       let alert = UIAlertController(title: "All Information Not Provided", message: "You must supply all information to create a flyer.", preferredStyle: .alert)
       alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
       present(alert, animated: true, completion: nil)
       
       return false
     }
    
    
      override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "previewSegue" {
          guard let vc = segue.destination as? PDFPreviewViewController else { return }
          
          if let title =  userNameShow.text{
            var body = ""
            for i in 1...5{
                body = body + "\n" + String(i) + "\n"
            }
            let pdfCreator = PDFCreator(title: title, Body: body)
            vc.documentData = pdfCreator.createFlyer()
          }
        }
      }
    

}

extension Profile: UINavigationControllerDelegate {
  // Not used, but necessary for compilation
}
