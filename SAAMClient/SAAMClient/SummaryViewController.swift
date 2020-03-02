//
//  SummaryViewController.swift
//  SAAMClient
//
//  Created by Xiaoyi Wang on 2020-03-02.
//  Copyright © 2020 SAAM. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore

class SummaryViewController: UIViewController {

    var uid:String?
    var TimeChoice:String?
    var FormatTime:String?
    var Recommendations:[String] = []
    var Question:[String] = []
    var Q_A:[String:String] = [:]
    var Q_body:[String:String] = [:]
    var Q_Abody: [String:String] = [:]
    
    @IBOutlet weak var Assessment_Time: UILabel!
    @IBOutlet weak var TextView: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        Assessment_Time.text = FormatTime
    }
    
    //init firestore and firebase storage
    let db = Firestore.firestore()
    
    override func viewDidAppear(_ animated: Bool) {
        let Collection_ref = db.collection("logs").document(self.uid!).collection(self.TimeChoice!)
        
        Collection_ref.getDocuments{(snapshot,error)in
            if let error = error{
                print(error.localizedDescription)
            }else{
                if snapshot != nil{
                        for document in snapshot!.documents{
                            let data = document.data()
                            if document.documentID == "Recommendations"{
                                self.Recommendations = data["Recommendations"] as! [String]
                            }else{
                                self.Question.append(document.documentID)
                                self.Q_body[document.documentID] = data["QuestionBody"] as! String
                                self.Q_A[document.documentID] = data["AnswerBody"] as! String
                            }
                        }
                    self.Question.sort(by: <)
                    print("Questions:")
                    print(self.Question)
                    self.RecommendationProcessing()
                    self.QAProcessing()
                    }
                }
            }
        
    }
    
    func RecommendationProcessing(){
        if self.Recommendations.count != 0{
            self.TextView.text = self.TextView.text + "Recommendations:" + "\n"
            var index = 1
            for recommendation in self.Recommendations{
                self.TextView.text = self.TextView.text + "\n" + String(index)+". " + recommendation + "\n"
                index += 1
            }
        }
    }
    
    @IBAction func Back(_ sender: Any) {
        performSegue(withIdentifier: "ToIndex", sender: self)
    }
    
    func QAProcessing(){
        self.TextView.text = self.TextView.text + "\n" + "Your Answers:" + "\n"
        for id in self.Question{
            let A = id + ". " + self.Q_body[id]! + "\n \n" + self.Q_A[id]!
            self.TextView.text = self.TextView.text + "\n" + A + "\n"
        }
    }
    
    @IBAction func DocButton(_ sender: Any) {
        performSegue(withIdentifier: "SummaryToPDF", sender: self)
    }
    
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
      if segue.identifier == "SummaryToPDF" {
        guard let vc = segue.destination as? PDFPreviewViewController else { return }
        
        if let title =  FormatTime{
            print("here")
            if let body = TextView.text{
                print("there")
                let pdfCreator = PDFCreator(title: title, Body: body)
                vc.documentData = pdfCreator.createFlyer()
            }
        }
        }
      }
    
}
