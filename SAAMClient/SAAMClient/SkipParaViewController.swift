//
//  SkipParaViewController.swift
//  SAAMClient
//
//  Created by Xiaoyi Wang on 2020-03-23.
//  Copyright © 2020 SAAM. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore

class SkipParaViewController: UIViewController {

    
    @IBOutlet weak var skip_period: UITextField!
    
    @IBOutlet weak var skip_Conform_period: UITextField!
    
    
    var uid:String?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let uid = Auth.auth().currentUser?.uid {
            self.uid = uid;
        }
        skip_period.delegate = self
        skip_Conform_period.delegate = self
        print("here")
        skip_period.text = String(10)
        skip_Conform_period.text = String(10)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(false)
    }
    
    //init firestore and firebase storage
    let db = Firestore.firestore()
    
    @IBAction func submit(_ sender: Any) {
        self.db.collection("logs").document(self.uid!).setData(["skip":true, "skip_Conform_period": Int(self.skip_Conform_period.text!)!, "skip_period": Int(self.skip_period.text!)!], merge: true)

        self.view.removeFromSuperview()
    }
    
    @IBAction func Not_skip(_ sender: Any) {
        self.db.collection("logs").document(self.uid!).setData(["skip":false, "skip_Conform_period":10, "skip_period": 10], merge: true)

        self.view.removeFromSuperview()
    }
    
}

//Helper function for textfields
extension SkipParaViewController : UITextFieldDelegate{
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        
        if textField.text == ""{
            textField.text = String(10)
        }else if let num = Int(textField.text!){
            if num > 10{
                textField.text = String(10)
            }else if num < 1{
                textField.text = String(1)
            }
        }else{
            textField.text = String(10)
        }
    }
}
