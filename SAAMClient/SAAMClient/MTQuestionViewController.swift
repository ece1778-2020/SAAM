//
//  MTQuestionViewController.swift
//  SAAMClient
//
//  Created by Xiaoyi Wang on 2020-02-26.
//  Copyright © 2020 SAAM. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore


class MTQuestionViewController: UIViewController {
    
    //define the body
    @IBOutlet weak var body: UILabel!
    @IBOutlet weak var StackView: UIStackView!
    
    var buttons:[UIButton] = []
    var buttonmap: [String:String] = [:]
    var ClassDic:[String:[String:Any]] = [:]
    
    var Questionid:String?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    //init firestore and firebase storage
    let db = Firestore.firestore()
    
    override func viewDidAppear(_ animated: Bool) {
        let Question_ref = db.collection("Questions").document("ESSAS_Main").collection("Questions").document(Questionid!)
            
        Question_ref.getDocument { (DocumentSnapshot, error) in
            if let Document = DocumentSnapshot{
                if let data = Document.data(){
                    self.body.text = data["body"] as! String
                }
            }
        }
        Question_ref.collection("Options").getDocuments{(snapshot,error)in
            if let error = error{
                print(error.localizedDescription)
            }else{
                if snapshot != nil{
                    var index = 0
                    //define each button for each options
                    for document in snapshot!.documents{
                        print(document.documentID)
                        let data = document.data()
                        let button = UIButton()
                        button.translatesAutoresizingMaskIntoConstraints = false
                        index += 1
                        button.backgroundColor = .gray
                        button.setTitle(data["body"] as! String, for: .normal)
                        button.addTarget(self, action: #selector(self.buttonAction), for: .touchUpInside)
                        button.layer.cornerRadius = 10
                        button.layer.masksToBounds = true
                        self.buttons.append(button)
                        self.buttonmap[data["body"] as! String] = document.documentID
                        self.ClassDic[document.documentID] = data
                    }
                    
                    //add all buttons into the stackview
                    for button in self.buttons{
                        self.StackView.addArrangedSubview(button)
                        self.StackView.spacing = 20
                        self.StackView.distribution = .fillEqually
                    }
                
                }
            }
        }
    }
    
    //Asking if user want to go the sub questions
    func Asking_alert(_ Asking:String, _ dic: [String:Any]){
        let alert = UIAlertController(title: "Asking", message: Asking, preferredStyle: .alert)
        let True_action = UIAlertAction(title: "Accept", style: .default){(action)in
            let temp = self.parent as! QuestionGenerator
            self.view.removeFromSuperview()
            temp.Ask_processing(dic["True_next"] as! String, dic["False_next"]as! String)
        }
        let False_action = UIAlertAction(title: "Refuse", style: .default){(action)in
            let temp = self.parent as! QuestionGenerator
            self.view.removeFromSuperview()
            temp.next(dic["False_next"] as! String)
        }
        alert.addAction(True_action)
        alert.addAction(False_action)
        present(alert,animated: true, completion: nil)
    }
    
    //process answers for subquestions
    func AnswerProcessing(_ answer:String){
        let temp = self.parent as! QuestionGenerator
        self.db.collection("logs").document(temp.uid!).collection(temp.questionaire_name!).document(self.Questionid!).setData(["Type":"MC","answer":answer])
        let clsDic = self.ClassDic[answer]
        if let recommendations = clsDic!["Recommendations"]{
            for recommendation in recommendations as! [String]{
                temp.AddRecommendations(recommendation)
            }
        }
        if let Ask = clsDic!["Ask"]{
            let Ask = Ask as! Bool
            if Ask == true{
                self.Asking_alert(clsDic!["Asking"] as! String, clsDic!)
            }else{
                let temp = self.parent as! QuestionGenerator
                self.view.removeFromSuperview()
                temp.next(clsDic!["next"] as! String)
            }
        }
    }
    
    //button press on each option
    @objc func buttonAction(sender: UIButton!) {
        let answer = self.buttonmap[sender.currentTitle!]!
        self.AnswerProcessing(answer)
    }

}
