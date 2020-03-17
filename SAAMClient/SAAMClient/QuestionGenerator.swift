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
    var question_list:[String] = []
    var recommendations_list:[String:[String]] = [:]

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
        delete_Order()
    }
    
    //init firestore and firebase storage
    let db = Firestore.firestore()
    
    func QuestionProcess(Questionid:String){
        if(Questionid != "end"){
            self.add_Order(Questionid)
            self.question_list.append(Questionid)
        }
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
        while self.question_list.contains(id){
            self.next_q.remove(at: 0)
        }
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
                print("here")
                self.next_q.insert(next, at: 0)
                print(self.next_q)
                Set_next_q(self.next_q)
                self.next_q.remove(at: 0)
                let Result = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "Result") as! ResultViewController
                self.addChild(Result)
                Result.view.frame = self.view.frame
                Result.uid = self.uid
                Result.TimeChoice = self.questionaire_name
                self.view.addSubview(Result.view)
                Result.didMove(toParent: self )
            }
        }else{
            print("here")
            self.next_q.insert(next, at: 0)
            print(self.next_q)
            Set_next_q(self.next_q)
            self.next_q.remove(at: 0)
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
    
    func add_completed(){
        let ref = self.db.collection("logs").document(self.uid!)
        ref.getDocument{(document,error)in
            if let document = document{
                if let data = document.data(){
                    if var Completed = data["Completed_Assessments"] as! [String]?{
                        Completed.append(self.questionaire_name!)
                        ref.setData(["Completed_Assessments":Completed], merge: true)
                        
                    }else{
                        let Completed = [self.questionaire_name!]
                        ref.setData(["Completed_Assessments":Completed], merge: true)
                    }
                }else{
                    let Completed = [self.questionaire_name!]
                    ref.setData(["Completed_Assessments":Completed], merge: true)
                }
            }
        }
    }
    
    func add_Recommendations(_ Recommendation:String){
        let ref = self.db.collection("logs").document(self.uid!).collection(self.questionaire_name!).document("Recommendations")
        ref.getDocument{(document,error)in
            if let document = document{
                if let data = document.data(){
                    if var Completed = data["Recommendations"] as! [String]?{
                        Completed.append(Recommendation)
                        ref.setData(["Recommendations":Completed], merge: true)
                    }else{
                        let Completed = [Recommendation]
                        ref.setData(["Recommendations":Completed], merge: true)
                    }
                }else{
                    let Completed = [Recommendation]
                    ref.setData(["Recommendations":Completed], merge: true)
                }
            }
        }
    }
    

    func add_Order(_ order:String){
        let ref = self.db.collection("logs").document(self.uid!).collection(self.questionaire_name!).document("Order")
        ref.getDocument{(document,error)in
            if let document = document{
                if let data = document.data(){
                    if var Order = data["Order"] as! [String]?{
                        Order.append(order)
                        ref.setData(["Order":Order], merge: true)
                    }else{
                        let Order = [order]
                        ref.setData(["Order":Order], merge: true)
                    }
                }else{
                    let Order = [order]
                    ref.setData(["Order":Order], merge: true)
                }
            }
        }
    }
    
    func delete_Order(){
        let ref = self.db.collection("logs").document(self.uid!).collection(self.questionaire_name!).document("Order")
        ref.getDocument{(document,error)in
            if let document = document{
                if let data = document.data(){
                    if var Order = data["Order"] as! [String]?{
                        print(Order)
                        Order.removeLast()
                        ref.setData(["Order":Order], merge: true)
                    }
                }
            }
            self.Ask_from_queue()
        }
    }
    
    func BackToProfile(){
        Set_Temp("None")
        add_completed()
        performSegue(withIdentifier: "BackToProfile", sender: self)
    }
    
    func clean_recommendations(_ q_id:String){
        if self.recommendations_list[q_id] != nil{
            self.recommendations_list.removeValue(forKey: q_id)
        }
    }
    
    func AddRecommendations(_ q_id:String, _ recommendation:String){
        if self.recommendations_list[q_id] != nil{
            if self.recommendations_list[q_id]!.contains(recommendation){
            }else{
                self.recommendations_list[q_id]!.append(recommendation)
            }
        }else{
            self.recommendations_list[q_id] = [recommendation]
        }
    }
    
    
    func AddRecommendations(_ recommendation:String){
        if self.recommendations.contains(recommendation){
        }else{
            self.add_Recommendations(recommendation)
            self.recommendations.append(recommendation)
        }
    }
    
    func To_history(){
        let ToHistory = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "Goback") as! GoBackViewController
        ToHistory.uid = self.uid
        ToHistory.TimeChoice = self.questionaire_name!
        print(self.questionaire_name!)
        self.addChild(ToHistory)
        self.view.addSubview(ToHistory.view)
    }
    
    func from_history(){
        let ref = self.db.collection("logs").document(self.uid!)
        ref.getDocument{(document,error)in
            if let document = document{
                if let data = document.data(){
                    if let Current = data["Current"] as! String?{
                        if Current != "None"{
                            self.next_q = data["next_q"] as! [String]
                            self.delete_Order()
                        }
                    }
                }
            }
        }
    }
    

}
