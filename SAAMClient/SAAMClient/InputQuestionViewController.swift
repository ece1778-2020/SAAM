//
//  InputQuestionViewController.swift
//  SAAMClient
//
//  Created by Xiaoyi Wang on 2020-02-27.
//  Copyright © 2020 SAAM. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore

class InputQuestionViewController: UIViewController {

    //for question text and Textview of user's input
    @IBOutlet weak var body: UILabel!
    @IBOutlet weak var Textview: UITextView!
    
    //define the Question id and the next question
    var Questionid:String?
    var Next:String?
    @IBOutlet weak var History_button: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        Textview.delegate = self
        //init for background
        self.view.backgroundColor = UIColor.black.withAlphaComponent(0.3)
        //init for Textview
        Textview.text = "Answer Here"
        Textview.textColor = UIColor.lightGray
        // Do any additional setup after loading the view.
    }
    
    //init firestore and firebase storage
    let db = Firestore.firestore()

    
    override func viewDidAppear(_ animated: Bool) {
        //get question db referenece
        let Question_ref = db.collection("Questions").document("ESSAS_Main").collection("Questions").document(Questionid!)
            
        //Get question text and the id of the next question
        Question_ref.getDocument { (DocumentSnapshot, error) in
            if let Document = DocumentSnapshot{
                if let data = Document.data(){
                    self.body.text = data["body"] as! String
                    self.Next = data["next"] as! String
                }
            }
        }
    }
    
    //submit the question with answer
    @IBAction func Submit(_ sender: Any) {
        if let next = Next{
            //save answer to DB
            if (self.parent as? QuestionGenerator) != nil{
            let temp = self.parent as! QuestionGenerator
            self.db.collection("logs").document(temp.uid!).collection(temp.questionaire_name!).document(self.Questionid!).setData(["Type":"Input","answer":self.Textview.text, "AnswerBody":self.Textview.text, "QuestionBody":self.body.text])
            //Go to the next question by going back to the question generator
            self.view.removeFromSuperview()
            print(self.Textview.text)
            temp.next(next)
            }else if(self.parent as? GoBackViewController) != nil{
                let temp = self.parent as! GoBackViewController
                self.db.collection("logs").document(temp.uid!).collection(temp.TimeChoice!).document(self.Questionid!).setData(["Type":"Input","answer":self.Textview.text, "AnswerBody":self.Textview.text, "QuestionBody":self.body.text])
                //Go to the next question by going back to the question generator
                self.view.removeFromSuperview()
                print(self.Textview.text)
            }
        }
    }
    
    @IBAction func History(_ sender: UIButton) {
        let temp = self.parent as! QuestionGenerator
        self.view.removeFromSuperview()
        temp.To_history()
    }
    

}

//Helper function for textfields
extension InputQuestionViewController : UITextViewDelegate{
    
    func textViewShouldReturn(_ textView: UITextView) -> Bool {
        textView.resignFirstResponder()
        return true
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == UIColor.lightGray {
            textView.text = nil
            textView.textColor = UIColor.black
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = "Answer Here"
            textView.textColor = UIColor.lightGray
        }
    }
}
