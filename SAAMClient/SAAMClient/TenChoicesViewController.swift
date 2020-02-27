//
//  TenChoicesViewController.swift
//  SAAMClient
//
//  Created by Xiaoyi Wang on 2020-02-26.
//  Copyright © 2020 SAAM. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore

class TenChoicesViewController: UIViewController {

    var Questionid:String?
    var LowerThan:[Int] = []
    @IBOutlet weak var body: UILabel!
    
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
    Question_ref.collection("OptionsLowerThan").getDocuments{(snapshot,error)in
        if let error = error{
            print(error.localizedDescription)
        }else{
            if snapshot != nil{
                    for document in snapshot!.documents{
                    self.LowerThan.append(Int(document.documentID)!)
                    }
                    self.LowerThan.sort(by: <)
                    print(self.LowerThan)
                }
            }
        }
    }
    
    @IBAction func One(_ sender: UIButton) {
        AnswerClassifier(1)
    }
    
    @IBAction func Two(_ sender: UIButton) {
        AnswerClassifier(2)
    }
    
    @IBAction func Three(_ sender: UIButton) {
        AnswerClassifier(3)
    }
    
    @IBAction func Four(_ sender: UIButton) {
        AnswerClassifier(4)
    }
    
    @IBAction func Five(_ sender: UIButton) {
        AnswerClassifier(5)
    }
    
    @IBAction func Six(_ sender: UIButton) {
        AnswerClassifier(6)
    }
    
    @IBAction func Seven(_ sender: UIButton) {
        AnswerClassifier(7)
    }
    
    @IBAction func Eight(_ sender: UIButton) {
        AnswerClassifier(8)
    }
    
    @IBAction func Nine(_ sender: UIButton) {
        AnswerClassifier(9)
    }
    
    @IBAction func Zero(_ sender: UIButton) {
        AnswerClassifier(0)
    }
    
    @IBAction func Ten(_ sender: UIButton) {
        AnswerClassifier(10)
    }
    
    func AnswerClassifier(_ answer:Int){
        print(answer)
        for item in LowerThan{
            if answer <= item{
                print(item)
                break
            }
        }
    }
    
    
    
    
    
    @IBAction func Back(_ sender: UIButton) {
    }
    
}
