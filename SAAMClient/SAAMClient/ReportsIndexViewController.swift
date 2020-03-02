//
//  ReportsIndexViewController.swift
//  SAAMClient
//
//  Created by Xiaoyi Wang on 2020-03-02.
//  Copyright © 2020 SAAM. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore

class ReportsIndexViewController: UIViewController {

    //define the uid and questionaire_name
    var uid:String?
    var buttons:[UIButton] = []
    var buttonmap: [String:String] = [:]
    var TimeChoice:String?
    var FormatTime:String?
    
    @IBOutlet weak var Text: UILabel!
    @IBOutlet weak var StackView: UIStackView!
    @IBOutlet weak var Back: UIButton!
    
    //init firestore and firebase storage
    let db = Firestore.firestore()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        //get the user's uid
        if let uid = Auth.auth().currentUser?.uid {
            self.uid = uid;
            print(uid)
            Get_All_Assessments()
        }
    }
    
    func Get_All_Assessments(){
        if let uid = self.uid{
            let ref = self.db.collection("logs").document(uid)
            ref.getDocument{(document,error)in
                if let document = document{
                    if let data = document.data(){
                        var Completed_Assessments = data["Completed_Assessments"] as! [String]
                        if Completed_Assessments.count == 0{
                            self.Text.text = "You don't have any completed assessments"
                        }else{
                            self.Text.text = "Assessments you have completed:"
                            var index = 0
                            
                            Completed_Assessments.sort(by: >)
                            
                            for Assessment in Completed_Assessments{
                                let FormatTimeStamp = self.TimeStampFormatter(StrTimeStamp: Assessment)
                                print(FormatTimeStamp)
                                let button = UIButton()
                                button.translatesAutoresizingMaskIntoConstraints = false
                                index += 1
                                button.backgroundColor = .gray
                                button.setTitle(FormatTimeStamp, for: .normal)
                                button.addTarget(self, action: #selector(self.buttonAction), for: .touchUpInside)
                                button.layer.cornerRadius = 10
                                button.layer.masksToBounds = true
                                self.buttons.append(button)
                                self.buttonmap[FormatTimeStamp] = Assessment
                            }
                            
                            for button in self.buttons{
                                self.StackView.addArrangedSubview(button)
                                self.StackView.spacing = 20
                                self.StackView.distribution = .fillProportionally
                            }
                            
                        }
                    }else{
                        self.Text.text = "You don't have any completed assessments"
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
    
    @objc func buttonAction(sender: UIButton!) {
        self.FormatTime = sender.currentTitle!
        self.TimeChoice = self.buttonmap[sender.currentTitle!]!
        performSegue(withIdentifier: "ToSummary", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
      if segue.identifier == "ToSummary" {
        guard let vc = segue.destination as? SummaryViewController else { return }
        vc.uid = self.uid
        vc.TimeChoice = self.TimeChoice
        vc.FormatTime = self.FormatTime
      }
    }

}
