//
//  ResultViewController.swift
//  SAAMClient
//
//  Created by Xiaoyi Wang on 2020-02-28.
//  Copyright © 2020 SAAM. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore

class ResultViewController: UIViewController {
    
    var uid:String?
    var TimeChoice:String?
    var Recommendations:[String] = []
    var Question:[String] = []
    var Q_A:[String:String] = [:]
    var Q_body:[String:String] = [:]
    var Q_Abody: [String:String] = [:]
    var Recommendations_dic:[String:[String]] = [:]
    
    @IBOutlet weak var Result_label: UILabel!
    @IBOutlet weak var TextView: UITextView!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.TextView.backgroundColor = UIColor.white.withAlphaComponent(0.5)
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
                            }
                        }
                    print(self.Question)
                    for question in self.Question{
                        if self.Recommendations_dic[question] != nil{
                            self.Recommendations.append(contentsOf: self.Recommendations_dic[question]!)
                        }
                    }
                    self.RecommendationProcessing()
                    }
                }
            }
        
    }
    
    func RecommendationProcessing(){
        var level = 0
        if self.Recommendations.count != 0{
            var index = 1
            for recommendation in self.Recommendations{
                if recommendation.contains("Severe") || recommendation.contains("Bad")  {
                    level = 2
                }else if recommendation.contains("Moderate"){
                    if level == 0{
                        level = 1
                    }
                }else if recommendation.contains("Mild") || recommendation.contains("good"){
                }else{
                    self.TextView.text = self.TextView.text + "\n" + String(index)+". " + recommendation + "\n"
                    index += 1
                }
            }
        }
        
        if(level == 0){
            self.Result_label.text =  "Please continue with self-care strategies and medication use"
            self.Result_label.textColor = UIColor.init(displayP3Red: 34/255, green: 139/255, blue: 34/255, alpha: 1)
        }else if(level == 1){
            self.Result_label.text =  "Please call your medical team in 1-2 days if any symptoms worsen, new symptoms occur, or no improvements on any symptoms"
            self.Result_label.textColor = UIColor.init(displayP3Red: 95/255, green: 158/255, blue: 160/255, alpha: 1)
        }else{
            self.Result_label.text =  "Please seek medical attention immediately"
            self.Result_label.textColor = UIColor.init(displayP3Red: 199/255, green: 21/255, blue: 133/255, alpha: 1)
        }
        

        self.TextView.text =  "Self-management tips:" + "\n" + self.TextView.text
        
        
    }
    
    @IBAction func BacktoProfile(_ sender: Any) {
        let temp = self.parent as! QuestionGenerator
        self.view.removeFromSuperview()
        temp.BackToProfile()
    }
    
}
