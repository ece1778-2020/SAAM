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
    
    var user_ignoring:Bool = false
    var user_skip_Comfirm_period = 4
    var user_skip_period = 4

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        //get the user's uid
        if let uid = Auth.auth().currentUser?.uid {
            self.uid = uid;
            get_skipper_para(user_id: uid)
        }
        
        Set_Temp(self.questionaire_name!)
        delete_Order()
    }
    
    //init firestore and firebase storage
    let db = Firestore.firestore()
    
    func QuestionProcess(Questionid:String){
//        if(Questionid != "end"){
//            self.add_Order(Questionid){
//                self.question_list.append(Questionid)
//            }
//        }
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
    
    func get_skipper_para(user_id:String){
        let skipper_para = db.collection("logs").document(self.uid!)
        skipper_para.getDocument{(document,error)in
            if let document = document{
                if let data = document.data(){
                    self.user_ignoring = data["skip"] as! Bool
                    self.user_skip_Comfirm_period = data["skip_Conform_period"] as! Int
                    self.user_skip_period = data["skip_period"] as! Int
                }
            }
        }
    }
    
    func skip_updater(Questionid:String, Answer:String, next:String, Question_body:String){
        print("[info skip_updater]: Answer:\(Answer)")
        let Question_ref = db.collection("logs").document(self.uid!).collection("Q_ignore").document(Questionid)
        Question_ref.getDocument{(document,error)in
            if let document = document{
                if let data = document.data(){
                    let ignoring = data["ignoring"] as! Bool
                    let remaining = data["remaining"] as! Int
                    let Last_ans = data["Last_answer"] as! String
                    let Last_assessment = data["Last_assessment"] as! String
                    
                    if ignoring == false{
                        if Last_ans != Answer{
                            Question_ref.setData(["ignoring":false, "remaining":self.user_skip_Comfirm_period, "Last_answer":Answer, "Last_assessment":self.questionaire_name!,"next":next, "Question_body":Question_body])
                        }else{
                            if remaining > 0{
                                if self.questionaire_name == Last_assessment{
                                    Question_ref.setData(["ignoring":false, "remaining":remaining, "Last_answer":Answer, "Last_assessment":self.questionaire_name!,"next":next, "Question_body":Question_body])
                                }else{
                                    Question_ref.setData(["ignoring":false, "remaining":(remaining-1), "Last_answer":Answer, "Last_assessment":self.questionaire_name!,"next":next, "Question_body":Question_body])
                                }
                            }else{
                                Question_ref.setData(["ignoring":true, "remaining":self.user_skip_period, "Last_answer":Answer, "Last_assessment":self.questionaire_name!,"next":next, "Question_body":Question_body])
                            }
                        }
                    }else{
                        if Last_ans != Answer{
                        print(Last_ans)
                        print(Answer)
                            Question_ref.setData(["ignoring":false, "remaining":self.user_skip_Comfirm_period, "Last_answer":Answer, "Last_assessment":self.questionaire_name!,"next":next, "Question_body":Question_body])
                        }else{
                            if remaining > 0{
                                if self.questionaire_name == Last_assessment{
                                    Question_ref.setData(["ignoring":true, "remaining":remaining, "Last_answer":Answer, "Last_assessment":self.questionaire_name!,"next":next, "Question_body":Question_body])
                                }else{
                                    Question_ref.setData(["ignoring":true, "remaining":(remaining-1), "Last_answer":Answer, "Last_assessment":self.questionaire_name!,"next":next, "Question_body":Question_body])
                                }
                            }else{
                                Question_ref.setData(["ignoring":true, "remaining":self.user_skip_period, "Last_answer":Answer, "Last_assessment":self.questionaire_name!,"next":next, "Question_body":Question_body])
                            }
                        }
                    }
                }else{
                    Question_ref.setData(["ignoring":false, "remaining":self.user_skip_Comfirm_period, "Last_answer":Answer, "Last_assessment":self.questionaire_name!,"next":next, "Question_body":Question_body])
                    
                }
            }
        }
    }
    
    func load_skipping(Questionid:String){
        print("add order: \(Questionid)")
        self.add_Order(Questionid){
            if Questionid != "end"{
                self.question_list.append(Questionid)
            }
        print(self.question_list)
            let Question_ref = self.db.collection("logs").document(self.uid!).collection("Q_ignore").document(Questionid)
        Question_ref.getDocument{(document,error)in
            if let document = document{
            if let data = document.data(){
                    let ignoring = data["ignoring"] as! Bool
                    let remaining = data["remaining"] as! Int
                    let Last_ans = data["Last_answer"] as! String
                    let Last_assessment = data["Last_assessment"] as! String
                    let next = data["next"] as! String
                    let Question_body = data["Question_body"] as! String
                
                    print("[info at load_skipping]: Questionid:\(Questionid), ignoring: \(ignoring), remaining: \(remaining)")
                if ignoring == true && remaining > 0{
                    self.db.collection("logs").document(self.uid!).collection(self.questionaire_name!).document(Questionid).setData(["Type":"skipped","QuestionBody":Question_body, "AnswerBody": Last_ans])
                    
                    self.skip_updater(Questionid: Questionid, Answer: Last_ans, next: next, Question_body: Question_body)
                    
                    if next == "end"{
                        self.next(next)
                    }else{
                        self.load_skipping(Questionid: next)
                    }
                }else{
                    self.QuestionProcess(Questionid: Questionid)
                }
            }else{
                print("[info at load_skipping]: Questionid:\(Questionid), Info not available")
                self.QuestionProcess(Questionid: Questionid)
                }
            }else{
                print("[info at load_skipping]: Questionid:\(Questionid), Info not available")
                self.QuestionProcess(Questionid: Questionid)
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
        self.load_skipping(Questionid: id)
    }
    
    func result_page(){
        let Result = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "Result") as! ResultViewController
        self.addChild(Result)
        Result.view.frame = self.view.frame
        Result.uid = self.uid
        Result.TimeChoice = self.questionaire_name
        self.view.addSubview(Result.view)
        Result.didMove(toParent: self )
    }
    

    
    //directly go to the next question
    func next(_ next: String){
        if next == "end"{
            if self.next_q.count != 0{
                Ask_from_queue()
            }else{
                let ToHistory = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "Goback") as! GoBackViewController
                ToHistory.uid = self.uid
                ToHistory.TimeChoice = self.questionaire_name!
                ToHistory.end_flag = true
                self.addChild(ToHistory)
                self.view.addSubview(ToHistory.view)
            }
        }else{
            self.next_q.insert(next, at: 0)
            Set_next_q(self.next_q)
            self.next_q.remove(at: 0)
            self.load_skipping(Questionid: next)
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
    

    func add_Order(_ order:String,completion:@escaping ()->()){
        if order != "end"{
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
            completion()
        }
        }else{
            completion()
        }
    }
    
    func delete_Order(){
        let ref = self.db.collection("logs").document(self.uid!).collection(self.questionaire_name!).document("Order")
        ref.getDocument{(document,error)in
            if let document = document{
                if let data = document.data(){
                    if var Order = data["Order"] as! [String]?{
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
