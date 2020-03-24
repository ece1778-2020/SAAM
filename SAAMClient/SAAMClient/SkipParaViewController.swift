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
        skip_period.text = String(10)
        skip_Conform_period.text = String(10)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event:UIEvent?){
        self.view.endEditing(true)
    }
    
    //init firestore and firebase storage
    let db = Firestore.firestore()
    
    @IBAction func submit(_ sender: Any) {
        self.db.collection("logs").document(self.uid!).setData(["skip":true, "skip_Conform_period": Int(self.skip_Conform_period.text!)!, "skip_period": Int(self.skip_period.text!)!], merge: true)
    }
    
    @IBAction func Not_skip(_ sender: Any) {
        self.db.collection("logs").document(self.uid!).setData(["skip":false, "skip_Conform_period":10, "skip_period": 10], merge: true)
    }
    
}

//Helper function for textfields
extension SkipParaViewController : UITextViewDelegate{
    
    func textViewShouldReturn(_ textView: UITextView) -> Bool {
        textView.resignFirstResponder()
        return true
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == UIColor.lightGray {
            textView.text = nil
            textView.textColor = UIColor.black
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.textColor = UIColor.lightGray
        }
    }
}
