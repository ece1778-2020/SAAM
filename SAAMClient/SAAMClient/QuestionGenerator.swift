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
    
    //define the queue of branching questions
    var next_q:[String] = []
    //define the uid and questionaire_name
    var uid:String?
    var questionaire_name:String?

    override func viewDidLoad() {
        super.viewDidLoad()
        //get questionaire name by setting it to a timestamp
        let someDate = Date()
        let timeInterval = someDate.timeIntervalSince1970
        self.questionaire_name = String(Int(timeInterval))
        //Go to the first question
        QuestionProcess(Questionid: "1")
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        //get the user's uid
        if let uid = Auth.auth().currentUser?.uid {
            self.uid = uid;
        }
    }
    
    //init firestore and firebase storage
    let db = Firestore.firestore()
    
    func QuestionProcess(Questionid:String){
        //Classify questions
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
        //put question into different user interface
        if Type == "11choices"{
            let TenChoices = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "TenChoices") as! TenChoicesViewController
            self.addChild(TenChoices)
            TenChoices.view.frame = self.view.frame
            self.view.addSubview(TenChoices.view)
            TenChoices.didMove(toParent: self )
            TenChoices.Questionid = Questionid
        }
        else if Type == "Input"{
            let inputQ = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "InputQuestion") as! InputQuestionViewController
            self.addChild(inputQ)
            inputQ.view.frame = self.view.frame
            self.view.addSubview(inputQ.view)
            inputQ.didMove(toParent: self )
            inputQ.Questionid = Questionid
        }else if Type == "MC"{
            let MTQ = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "MTQuestion") as! MTQuestionViewController
            self.addChild(MTQ)
            MTQ.view.frame = self.view.frame
            self.view.addSubview(MTQ.view)
            MTQ.didMove(toParent: self )
            MTQ.Questionid = Questionid
        }else if Type == "MS"{
            let MSQ = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "MTSelection") as! MTSelectionViewController
            self.addChild(MSQ)
            MSQ.view.frame = self.view.frame
            self.view.addSubview(MSQ.view)
            MSQ.didMove(toParent: self )
            MSQ.Questionid = Questionid
        }
        
    }
    
    //Feedback dynamic answer processing for single choice questions (MC&11choices)
    func Ask_processing(_ True_next:String, _ False_next:String){
        self.next_q.append(True_next)
        self.next_q.append(False_next)
        Ask_from_queue()
    }
    
    //Feeback processing for multiple choice questions (MS)
    func Ask_processing_multi(nexts:[String]){
        self.next_q.insert(contentsOf: nexts, at: 0)
        Ask_from_queue()
    }
    
    //Process questions inside of the queue
    func Ask_from_queue(){
        //pop the first question of the queue
        let id = self.next_q[0]
        self.next_q.remove(at: 0)
        if id == "end"{
            self.next(id)
        }
        //go to the first question in the queue
        self.QuestionProcess(Questionid: id)
    }
    
    //directly go to the next question
    func next(_ next: String){
        if next == "end"{
            if self.next_q.count != 0{
                Ask_from_queue()
            }else{
                performSegue(withIdentifier: "BackToProfile", sender: self)
            }
        }else{
            self.QuestionProcess(Questionid: next)
        }
    }
    

}
