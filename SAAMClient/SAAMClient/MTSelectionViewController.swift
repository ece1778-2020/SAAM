//
//  MTSelectionViewController.swift
//  SAAMClient
//
//  Created by Xiaoyi Wang on 2020-02-27.
//  Copyright © 2020 SAAM. All rights reserved.
//

import UIKit

import FirebaseAuth
import FirebaseFirestore

class MTSelectionViewController: UIViewController {

    @IBOutlet weak var body: UILabel!
    @IBOutlet weak var Stackview: UIStackView!
    
    @IBOutlet weak var History_button: UIButton!
    
    
    var buttons:[UIButton] = []
    var buttonmap: [String:String] = [:]
    var ClassDic:[String:[String:Any]] = [:]
    var nexts:[String] = []
    var not_next:[String] = []
    var answers_buffer:[String] = []
    
    var Questionid:String?
    var globalnext:String?
    
    
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
                    self.globalnext = data["next"] as! String
                }
            }
        }
    Question_ref.collection("Options").getDocuments{(snapshot,error)in
        if let error = error{
            print(error.localizedDescription)
        }else{
            if snapshot != nil{
                    var index = 0
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
                    
                    for button in self.buttons{
                        self.Stackview.addArrangedSubview(button)
                        self.Stackview.spacing = 20
                        self.Stackview.distribution = .fillEqually
                    }
                
                }
            }
        }
    }
    
    func Asking_alert(_ Asking:String, _ dic: [String:Any]){
        if self.nexts.contains(dic["next"] as! String){
            self.AnswerProcessing()
        }else if self.not_next.contains(dic["next"] as! String) {
            self.AnswerProcessing()
        }else{
            let alert = UIAlertController(title: "Asking", message: Asking, preferredStyle: .alert)
            let True_action = UIAlertAction(title: "Accept", style: .default){(action)in
                self.nexts.append(dic["next"] as! String)
                self.AnswerProcessing()
            }
            let False_action = UIAlertAction(title: "Refuse", style: .default){(action)in
                self.not_next.append(dic["next"] as! String)
                self.AnswerProcessing()
            }
            alert.addAction(True_action)
            alert.addAction(False_action)
            present(alert,animated: true, completion: nil)
        }
    }
    
    func AnswerProcessing(){
        if self.answers_buffer.count == 0{
            print(self.nexts)
            self.nexts.append(self.globalnext!)
            let temp = self.parent as! QuestionGenerator
            self.view.removeFromSuperview()
            temp.Ask_processing_multi(nexts: self.nexts)
        }else{
            print(self.answers_buffer)
            let answer = self.answers_buffer[0]
            let dic = self.ClassDic[answer]
            let temp = self.parent as! QuestionGenerator
            if let recommendations = dic!["Recommendations"]{
                for recommendation in recommendations as! [String]{
                    temp.AddRecommendations(recommendation)
                }
            }
            if (dic!["Ask"] as! Bool) == true{
                self.answers_buffer.remove(at: 0)
                Asking_alert(dic!["Asking"] as! String, dic!)
            }else{
                self.answers_buffer.remove(at: 0)
                AnswerProcessing()
            }
        }
    }
    
    
    @objc func buttonAction(sender: UIButton!) {
        let answer = self.buttonmap[sender.currentTitle!]!
        if sender.backgroundColor == UIColor.gray{
            sender.backgroundColor = UIColor.red
        }else if sender.backgroundColor == UIColor.red{
            sender.backgroundColor = UIColor.gray
        }
    }
    
    @IBAction func History(_ sender: UIButton) {
        let temp = self.parent as! QuestionGenerator
        self.view.removeFromSuperview()
        temp.To_history()
    }
    
    @IBAction func Submit(_ sender: UIButton) {

       
       if (self.parent as? QuestionGenerator) != nil{
            var selected:[String] = []
            let temp = self.parent as! QuestionGenerator
            var index = 0
            self.db.collection("logs").document(temp.uid!).collection(temp.questionaire_name!).document(self.Questionid!).setData(["Type":"MS", "QuestionBody":self.body.text])
            var answerbody = "You selected:"
            for button in self.buttons{
                if(button.backgroundColor == UIColor.red){
                    selected.append(self.buttonmap[button.currentTitle!]!)
                    //self.db.collection("logs").document(temp.uid!).collection(temp.questionaire_name!).document(self.Questionid!).setData(["\(index)":self.buttonmap[button.currentTitle!]!], merge: true)
                    self.db.collection("logs").document(temp.uid!).collection(temp.questionaire_name!).document(self.Questionid!).collection("Answers").document(String(index)).setData(["ID":self.buttonmap[button.currentTitle!]!], merge: true)
                        
                        answerbody += ("\n"+button.currentTitle!)
                    
                    index += 1
                }
            }
            self.db.collection("logs").document(temp.uid!).collection(temp.questionaire_name!).document(self.Questionid!).setData(["AnswerBody":answerbody], merge: true)
            self.answers_buffer = selected
            self.AnswerProcessing()
       }else if(self.parent as? GoBackViewController) != nil{
        var selected:[String] = []
        let temp = self.parent as! GoBackViewController
        var index = 0
        self.db.collection("logs").document(temp.uid!).collection(temp.TimeChoice!).document(self.Questionid!).setData(["Type":"MS", "QuestionBody":self.body.text])
        var answerbody = "You selected:"
        for button in self.buttons{
            if(button.backgroundColor == UIColor.red){
                selected.append(self.buttonmap[button.currentTitle!]!)
                //self.db.collection("logs").document(temp.uid!).collection(temp.questionaire_name!).document(self.Questionid!).setData(["\(index)":self.buttonmap[button.currentTitle!]!], merge: true)
                self.db.collection("logs").document(temp.uid!).collection(temp.TimeChoice!).document(self.Questionid!).collection("Answers").document(String(index)).setData(["ID":self.buttonmap[button.currentTitle!]!], merge: true)
                    
                    answerbody += ("\n"+button.currentTitle!)
                
                index += 1
            }
        }
        self.db.collection("logs").document(temp.uid!).collection(temp.TimeChoice!).document(self.Questionid!).setData(["AnswerBody":answerbody], merge: true)
        temp.Q_A[self.Questionid!] = answerbody
        temp.CollectionView.reloadData()
        self.view.removeFromSuperview()
        }
    }
    

}
