//
//  ElevenChoicesViewController.swift
//  SAAMClient
//
//  Created by Xiaoyi Wang on 2020-02-29.
//  Copyright © 2020 SAAM. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore

class ElevenChoicesViewController: UIViewController {

    

    @IBOutlet weak var Question: UILabel!
    @IBOutlet weak var TextView: UITextView!
    @IBOutlet weak var Slider: UISlider!
    @IBOutlet weak var Left: UILabel!
    @IBOutlet weak var Right: UILabel!
    @IBOutlet weak var SliderPosition: UILabel!
    @IBOutlet weak var History_button: UIButton!
    
    var Questionid:String?
    var LowerThan:[Int] = []
    var ClassDic:[Int:[String:Any]] = [:]
    var Class:Int = 0
    
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
                    self.Question.text = data["body"] as! String
                    if let left = data["Left"]{
                        self.Left.text = left as! String
                    }
                    if let right = data["Right"]{
                        self.Right.text = right as! String
                    }
                }
            }
        }
    Question_ref.collection("OptionsLowerThan").getDocuments{(snapshot,error)in
        if let error = error{
            print(error.localizedDescription)
        }else{
            if snapshot != nil{
                    for document in snapshot!.documents{
                    self.LowerThan.append(Int(document.documentID)!)
                        self.ClassDic[Int(document.documentID)!] = document.data()
                    }
                    self.LowerThan.sort(by: <)

                self.AnswerClassifier(0)

                }
            }
        }
        self.TextView.backgroundColor = UIColor.white.withAlphaComponent(0.5)
    }
    
    @IBAction func ValueChanged(_ sender: UISlider) {
        let newValue = Int(sender.value)
        sender.setValue(Float(newValue), animated: false)
        self.SliderPosition.text = String(newValue)
        AnswerClassifier(newValue)
    }
    
    
    func AnswerClassifier(_ answer:Int){
        print(answer)
        for item in LowerThan{
            if answer <= item{
                self.Class = item
                AnswerProcessing(answer, item)
                break
            }
        }
    }
    
    func AnswerProcessing(_ answer:Int, _ cls:Int){
        let clsDic = self.ClassDic[cls]
        self.TextView.text = ""
        if let explains = clsDic!["Explain"]{
            for explain in explains as! [String]{
                self.TextView.text += (explain + "\n"+"\n")
            }
        }
    }
    
    @IBAction func History(_ sender: UIButton) {
        let temp = self.parent as! QuestionGenerator
        self.view.removeFromSuperview()
        temp.To_history()
    }
    
    @IBAction func submit(_ sender: Any) {
        if (self.parent as? QuestionGenerator) != nil{
        let temp = self.parent as! QuestionGenerator
    self.db.collection("logs").document(temp.uid!).collection(temp.questionaire_name!).document(self.Questionid!).setData(["Type":"11choices","answer":self.SliderPosition.text,"QuestionBody":self.Question.text])

        let cls = self.Class
        let clsDic = self.ClassDic[cls]
        
        var explainText = "Your choices was: \(self.SliderPosition.text!) \n"
        if let explains = clsDic!["Explain"]{
            for explain in explains as! [String]{
                explainText += (explain + "\n")
            }
        }
        
        self.db.collection("logs").document(temp.uid!).collection(temp.questionaire_name!).document(self.Questionid!).setData(["AnswerBody":explainText], merge: true)
        
        if let recommendations = clsDic!["Recommendations"]{
            self.db.collection("logs").document(temp.uid!).collection(temp.questionaire_name!).document(self.Questionid!).setData(["Recommendations":recommendations], merge: true)
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
            
        }else if(self.parent as? GoBackViewController) != nil{
            let temp = self.parent as! GoBackViewController
            self.db.collection("logs").document(temp.uid!).collection(temp.TimeChoice!).document(self.Questionid!).setData(["Type":"11choices","answer":self.SliderPosition.text,"QuestionBody":self.Question.text])
            
            let cls = self.Class
            let clsDic = self.ClassDic[cls]
            if let recommendations = clsDic!["Recommendations"]{
                self.db.collection("logs").document(temp.uid!).collection(temp.TimeChoice!).document(self.Questionid!).setData(["Recommendations":recommendations], merge: true)
                for recommendation in recommendations as! [String]{
                }
            }
            
            var explainText = "Your choices was: \(self.SliderPosition.text!) \n"
            if let explains = clsDic!["Explain"]{
                for explain in explains as! [String]{
                    explainText += (explain + "\n")
                }
            }
            
        self.db.collection("logs").document(temp.uid!).collection(temp.TimeChoice!).document(self.Questionid!).setData(["AnswerBody":explainText], merge: true)
            
            temp.Q_A[self.Questionid!] = explainText
            temp.CollectionView.reloadData()
            self.view.removeFromSuperview()
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
    
    
    
}


