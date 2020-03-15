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
    var recommendations:[String] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        //get questionaire name by setting it to a timestamp
        //Go to the first question
        //QuestionProcess(Questionid: "1")
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        //get the user's uid
        if let uid = Auth.auth().currentUser?.uid {
            self.uid = uid;
        }
        
        Set_Temp(self.questionaire_name!)
        Ask_from_queue()
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
            let ElevenChoices = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ElevenChoices") as! ElevenChoicesViewController
            self.addChild(ElevenChoices)
            ElevenChoices.view.frame = self.view.frame
            self.view.addSubview(ElevenChoices.view)
            ElevenChoices.didMove(toParent: self )
            ElevenChoices.Questionid = Questionid
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
        Set_next_q(self.next_q)
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
                let Result = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "Result") as! ResultViewController
                self.addChild(Result)
                Result.view.frame = self.view.frame
                self.view.addSubview(Result.view)
                Result.didMove(toParent: self )
            }
        }else{
            self.QuestionProcess(Questionid: next)
        }
    }
    
    func Set_Temp(_ ID: String){
        let ref = self.db.collection("logs").document(self.uid!)
        ref.setData(["Current": ID], merge: true)
    }
    
    func Set_next_q(_ next_q: [String]){
        let ref = self.db.collection("logs").document(self.uid!)
        ref.setData(["next_q": next_q], merge: true)
    }
    
    func BackToProfile(){
        Set_Temp("None")
        let ref = self.db.collection("logs").document(self.uid!)
        ref.getDocument{(document,error)in
            if let document = document{
                if let data = document.data(){
                    if let Completed = data["Completed_Assessments"]{
                        (Completed as AnyObject).append(self.questionaire_name!)
                        ref.setData(["Completed_Assessments":Completed], merge: true)
                        
                    }else{
                        let Completed = [self.questionaire_name!]
                        ref.setData(["Completed_Assessments":Completed], merge: true)
                    }
                }else{
                    print("here")
                    let Completed = [self.questionaire_name!]
                    ref.setData(["Completed_Assessments":Completed], merge: true)
                }
            }
        }
        let log = self.db.collection("logs").document(self.uid!).collection(self.questionaire_name!).document("Recommendations")
        log.setData(["Recommendations":self.recommendations], merge: true)
        
        performSegue(withIdentifier: "BackToProfile", sender: self)
    }
    
    func AddRecommendations(_ recommendation:String){
        if self.recommendations.contains(recommendation){
            print("recommendation ignored")
        }else{
            self.recommendations.append(recommendation)
            print(self.recommendations)
        }
    }
    

}
