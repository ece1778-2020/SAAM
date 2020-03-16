//
//  Profile.swift
//  SAAMClient
//
//  Created by AdamLi on 2020/2/22.
//  Modified by Xiaoyi Wang on 2020/2/27
//  Copyright © 2020 SAAM. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseDatabase
import FirebaseStorage

class Profile: UIViewController,UITextFieldDelegate {
    @IBOutlet weak var userNameShow: UILabel!
    let userDefault = UserDefaults.standard
    
    var next_q:[String] = ["1"]
    var uid:String?
    var questionaire_name:String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let someDate = Date()
        let timeInterval = someDate.timeIntervalSince1970
        self.questionaire_name = String(Int(timeInterval))
    }
    
    override func viewWillAppear(_ animated: Bool) {
        print(Auth.auth().currentUser?.uid)
        //Get the username of the current user
        if let user = Auth.auth().currentUser {
            self.uid = user.uid
            self.userNameShow.text = user.displayName
            print(user.uid)
        }
        print("...")
    }
    
    //init firestore and firebase storage
    let db = Firestore.firestore()
    
    @IBAction func Summaries(_ sender: UIButton) {
        
        performSegue(withIdentifier: "ToSummary", sender: self)
    }
    

    @IBAction func signoutButtonTapped(_ sender: Any) {
        do{
            try Auth.auth().signOut()
            //signout
            userDefault.removeObject(forKey: "usersignedin")
            userDefault.synchronize()
            performSegue(withIdentifier: "backtoSignIn", sender: self)
        } catch let error as NSError{
            print(error.localizedDescription)
        }
    }
    
    @IBAction func AssessmentButton(_ sender: UIButton) {
        //Go to Question Generator
        let ref = self.db.collection("logs").document(self.uid!)
        ref.getDocument{(document,error)in
            if let document = document{
                if let data = document.data(){
                    if let Current = data["Current"] as! String?{
                        if Current != "None"{
                            if let next = data["next_q"] as! [String]?{
                                self.Asking_alert("Do you want to continue your Assessment at \(self.TimeStampFormatter(StrTimeStamp: Current))?", next, Current)
                            }
                        }
                    }
                }
            }
            self.performSegue(withIdentifier: "ToQG", sender: self)
        }
    }
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
       if
         let _ =  userNameShow.text{
         return true
       }
       
       let alert = UIAlertController(title: "All Information Not Provided", message: "You must supply all information to create a flyer.", preferredStyle: .alert)
       alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
       present(alert, animated: true, completion: nil)
       
       return false
     }
    
    
      override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ToQG" {
          guard let vc = segue.destination as? QuestionGenerator else { return }
            vc.next_q = next_q
            vc.questionaire_name = self.questionaire_name
        }
      }
    
    //Asking if user want to go the sub questions
    func Asking_alert(_ Asking:String, _ next: [String], _ name: String){
        let alert = UIAlertController(title: "Asking", message: Asking, preferredStyle: .alert)
        let True_action = UIAlertAction(title: "Accept", style: .default){(action)in
            self.next_q = next
            self.questionaire_name = name
            self.performSegue(withIdentifier: "ToQG", sender: self)
        }
        let False_action = UIAlertAction(title: "Refuse", style: .default){(action)in
            self.performSegue(withIdentifier: "ToQG", sender: self)
        }
        alert.addAction(True_action)
        alert.addAction(False_action)
        present(alert,animated: true, completion: nil)
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
    

}

extension Profile: UINavigationControllerDelegate {
  // Not used, but necessary for compilation
}
