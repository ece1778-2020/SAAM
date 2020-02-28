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
    @IBOutlet weak var StackView: UIStackView!
    
    var buttons:[UIButton] = []
    var buttonmap: [String:String] = [:]
    var ClassDic:[String:[String:Any]] = [:]
    var nexts:[String] = []
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
                        self.StackView.addArrangedSubview(button)
                        self.StackView.spacing = 20
                        self.StackView.distribution = .fillEqually
                    }
                
                }
            }
        }
    }
    
    func Asking_alert(_ Asking:String, _ dic: [String:Any]){
        if self.nexts.contains(dic["next"] as! String){
            self.AnswerProcessing()
        }else{
            let alert = UIAlertController(title: "Asking", message: Asking, preferredStyle: .alert)
            let True_action = UIAlertAction(title: "Accept", style: .default){(action)in
                self.nexts.append(dic["next"] as! String)
                self.AnswerProcessing()
            }
            let False_action = UIAlertAction(title: "Refuse", style: .default){(action)in
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
    
    @IBAction func Submit(_ sender: UIButton) {
        var selected:[String] = []
        let temp = self.parent as! QuestionGenerator
        var index = 0
        self.db.collection("logs").document(temp.uid!).collection(temp.questionaire_name!).document(self.Questionid!).setData(["Type":"MS"])
        for button in self.buttons{
            if(button.backgroundColor == UIColor.red){
                selected.append(self.buttonmap[button.currentTitle!]!)
                self.db.collection("logs").document(temp.uid!).collection(temp.questionaire_name!).document(self.Questionid!).setData(["\(index)":self.buttonmap[button.currentTitle!]!])
            }
        }
        self.answers_buffer = selected
        self.AnswerProcessing()
    }
    

}
