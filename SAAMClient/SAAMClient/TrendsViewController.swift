//
//  TrendsViewController.swift
//  SAAMClient
//
//  Created by Xiaoyi Wang on 2020-03-17.
//  Copyright © 2020 SAAM. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore

class TrendsViewController: UIViewController {

    //define the uid and questionaire_name
    var uid:String?
    var buttons:[UIButton] = []
    var buttonmap: [String:String] = [:]
    var FormatTime:String?
    var assessments:[String] = []
    var Questions:[String:[String:String]] = [:] //[Assessment_timestamp:[Question_id:Answer]]
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        //get the user's uid
        if let uid = Auth.auth().currentUser?.uid {
            self.uid = uid;
            print(uid)
            Get_All_Assessments(){
                print(self.Questions)
                // Everything should be implemented in here
            }
        }
    }
    
    //init firestore and firebase storage
    let db = Firestore.firestore()
    
    func Get_All_Assessments(completion:@escaping ()->()){
        if let uid = self.uid{
            let ref = self.db.collection("logs").document(uid)
            ref.getDocument{(document,error)in
                if let document = document{
                    if let data = document.data(){
                        var Completed_Assessments = data["Completed_Assessments"] as! [String]
                        if Completed_Assessments.count == 0{
                            print("You don't have any completed assessments")
                        }else{
                            print("Assessments you have completed:")
                            
                            Completed_Assessments.sort(by: >)
                            self.assessments = Completed_Assessments
                            
                            
                            for Assessment in Completed_Assessments{
                                var answers:[String:String] = [:]
                                let Collection_ref = self.db.collection("logs").document(self.uid!).collection(Assessment)
                                Collection_ref.getDocuments{(snapshot,error)in
                                    if let error = error{
                                        print(error.localizedDescription)
                                    }else{
                                        if snapshot != nil{
                                                for document in snapshot!.documents{
                                                    let data = document.data()
                                                    if document.documentID == "Recommendations"{
                                                    }else if document.documentID == "Order"{
                                                    }else{
                                                        if((data["Type"] as! String) == "11choices"){
                                                            answers[document.documentID] = data["answer"] as! String
                                                        }
                                                    }
                                                    //print(answers)
                                                    self.Questions[Assessment] = answers
                                                }
                                            
                                            }
                                        }
                                    completion()
                                    }

                            }
                            
                        }
                    }else{
                        print("You don't have any completed assessments")
                    }
                }
            }
        }
    }
    
    
    func TimeStampFormatter(StrTimeStamp:String) -> String{
        let date = Date(timeIntervalSince1970: Double(StrTimeStamp) as! TimeInterval)
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone.current //Set timezone that you want
        dateFormatter.locale = NSLocale.current
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm" //Specify your format that you want
        let strDate = dateFormatter.string(from: date)
        return strDate
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
