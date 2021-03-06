//
//  SummaryViewController.swift
//  SAAMClient
//
//  Created by Xiaoyi Wang on 2020-03-02.
//  Copyright © 2020 SAAM. All rights reserved.
//

import UIKit
import PDFKit
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
    var Recommendations_dic:[String:[String]] = [:]
    var recommendations:String = ""
    var questions_and_answer = ""
    
    @IBOutlet weak var Assessment_Time: UILabel!
    @IBOutlet weak var TextView: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.TextView.backgroundColor = UIColor.white.withAlphaComponent(0.5)
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
                            }else if document.documentID == "Order"{
                                self.Question = data["Order"] as! [String]
                            }else{
                                if data["Recommendations"] != nil{
                                    self.Recommendations_dic[document.documentID] = data["Recommendations"] as! [String]
                                }
                                self.Question.append(document.documentID)
                                self.Q_body[document.documentID] = data["QuestionBody"] as! String
                                self.Q_A[document.documentID] = data["AnswerBody"] as! String
                            }
                        }
                    print("Questions:")
                    print(self.Question)
                    for question in self.Question{
                        if let recom = self.Recommendations_dic[question]{
                        self.Recommendations.append(contentsOf: recom)
                        }
                    }
                    self.RecommendationProcessing()
                    self.QAProcessing()
                    }
                }
            }
        
    }
    
    func RecommendationProcessing(){
        if self.Recommendations.count != 0{
            self.TextView.text = self.TextView.text   + "Recommendations:" + "\n"
            self.recommendations = self.recommendations  + "Recommendations:" + "\n"
            var index = 1
            for recommendation in self.Recommendations{
                self.TextView.text = self.TextView.text + "\n" + String(index)+". " + recommendation + "\n"
                self.recommendations = self.recommendations + "\n" + String(index)+". " + recommendation + "\n"
                index += 1
            }
            // add the segment
            self.TextView.text = self.TextView.text + "----------------------------------------"  + "\n"
        }
    }
    
    @IBAction func Back(_ sender: Any) {
        performSegue(withIdentifier: "ToIndex", sender: self)
    }
    
    func QAProcessing(){
        self.TextView.text = self.TextView.text + "\n" + "Your Answers:" + "\n"
        self.questions_and_answer = self.questions_and_answer + "\n" + "Your Answers:" + "\n"
        for id in self.Question{
            let A = id + ". " + self.Q_body[id]! + "\n \n" + self.Q_A[id]!
            self.questions_and_answer = self.questions_and_answer + "\n" + A + "\n"
            self.TextView.text = self.TextView.text + "\n" + A + "\n"
        }
    }
    
    @IBAction func DocButton(_ sender: Any) {
        performSegue(withIdentifier: "SummaryToPDF", sender: self)
    }
    
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
      if segue.identifier == "SummaryToPDF" {
        guard let vc = segue.destination as? PDFPreviewViewController else { return }
        
        let date = self.TimeStampFormatter(StrTimeStamp: self.TimeChoice!)
        
        let title = date
        if let body = TextView.text{
            print("there")
            let pdfCreator = PDFCreator(title: title, Recommendations:self.recommendations, Questions: self.questions_and_answer)
            vc.documentData = pdfCreator.createFlyer()
        }
        }
      }
    
    func TimeStampFormatter(StrTimeStamp:String) -> String{
        let date = Date(timeIntervalSince1970: Double(StrTimeStamp) as! TimeInterval)
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone.current //Set timezone that you want
        dateFormatter.locale = NSLocale.current
        dateFormatter.dateFormat = "yyyy-MM-dd" //Specify your format that you want
        let strDate = dateFormatter.string(from: date)
        return strDate
    }
    
}
