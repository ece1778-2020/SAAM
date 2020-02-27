//
//  QuestionGenerator.swift
//  SAAMClient
//
//  Created by Xiaoyi Wang on 2020-02-26.
//  Copyright © 2020 SAAM. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore

class QuestionGenerator: UIViewController {
    

    override func viewDidLoad() {
        super.viewDidLoad()
        QuestionProcess(Questionid: "1")
        // Do any additional setup after loading the view.
    }
    
    //init firestore and firebase storage
    let db = Firestore.firestore()
    
    func QuestionProcess(Questionid:String){
        let Question_ref = db.collection("Questions").document("ESSAS_Main").collection("Questions").document(Questionid)
        Question_ref.getDocument{(document,error)in
            if let document = document{
                if let data = document.data(){
                    self.Type_selector(Questionid: document.documentID, Type: data["Type"] as! String)
                }
            }
        }
    }
    
    func Type_selector(Questionid:String, Type: String){
        if Type == "11choices"{
            let TenChoices = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "TenChoices") as! TenChoicesViewController
            self.addChild(TenChoices)
            TenChoices.view.frame = self.view.frame
            self.view.addSubview(TenChoices.view)
            TenChoices.didMove(toParent: self )
            TenChoices.Questionid = Questionid
        }
    }
    
    

}
