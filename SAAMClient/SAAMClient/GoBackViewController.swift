//
//  GoBackViewController.swift
//  SAAMClient
//
//  Created by Xiaoyi Wang on 2020-03-15.
//  Copyright © 2020 SAAM. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore

class GoBackViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate{

    @IBOutlet weak var CollectionView: UICollectionView!
    @IBOutlet weak var Button: UIButton!
    
    @IBOutlet weak var Label: UILabel!
    var uid:String?
    var TimeChoice:String?
    var Recommendations:[String] = []
    var Question:[String] = []
    var Q_A:[String:String] = [:]
    var Q_body:[String:String] = [:]
    var Q_index:[Int:String] = [:]
    var celllist:[Int:Bool] = [:]
    var skippingList:[String:Bool] = [:]
    
    //collection View
    var collectionViewFlowLayout: UICollectionViewFlowLayout!
    
    //collection view cell identifier
    let cellIdentifier = "cell"
    
    var end_flag:Bool?
    
    var user_ignoring:Bool = false
    var user_skip_Comfirm_period = 4
    var user_skip_period = 4
    
    //init firestore and firebase storage
    let db = Firestore.firestore()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let uid = Auth.auth().currentUser?.uid{
            self.uid = uid
            get_skipper_para(user_id: uid)
        }
        
        
        
        if self.end_flag == true{
            self.Button.setTitle("Submit!", for: .normal)
        }
        
        let Collection_ref = db.collection("logs").document(self.uid!).collection(self.TimeChoice!)
        
        
        Collection_ref.getDocuments{(snapshot,error)in
            if let error = error{
                print(error.localizedDescription)
            }else{
                if snapshot != nil{
                        for document in snapshot!.documents{
                            let data = document.data()
                            if(document.documentID != "Recommendations" && document.documentID != "Order"){
                                print(document.documentID)
                                self.Q_body[document.documentID] = data["QuestionBody"] as! String
                                self.Q_A[document.documentID] = data["AnswerBody"] as! String
                                if data["Type"] as! String == "skipped"{
                                    self.skippingList[document.documentID] = true
                                }else{
                                    self.skippingList[document.documentID] = false
                                }
                            }else if(document.documentID == "Order"){
                                self.Question = data["Order"] as! [String]
                            }
                        }
                    print("Questions:")
                    var count = 0
                    //self.Question.removeLast()
                    for index in self.Question{
                        self.Q_index[count] = index
                        print(index)
                        count+=1
                    }
                    
                    if(count == 0){
                        self.Label.text = "You haven't done any questions"
                    }
                    

                    self.setupCollectionView()
                    self.setupCollectionViewItemSize()

                    
                    
                    }
                }
            }
    }
    
    func get_skipper_para(user_id:String){
        let skipper_para = db.collection("logs").document(self.uid!)
        skipper_para.getDocument{(document,error)in
            if let document = document{
                if let data = document.data(){
                    self.user_ignoring = data["skip"] as! Bool
                    self.user_skip_Comfirm_period = data["skip_Conform_period"] as! Int
                    self.user_skip_period = data["skip_period"] as! Int
                }
            }
        }
    }
    
    func skip_updater(Questionid:String, Answer:String, next:String, Question_body:String){
        let Question_ref = db.collection("logs").document(self.uid!).collection("Q_ignore").document(Questionid)
        Question_ref.getDocument{(document,error)in
            if let document = document{
                if let data = document.data(){
                    let ignoring = data["ignoring"] as! Bool
                    let remaining = data["remaining"] as! Int
                    let Last_ans = data["Last_answer"] as! String
                    let Last_assessment = data["Last_assessment"] as! String
                    
                    if ignoring == false{
                        if Last_ans != Answer{
                            Question_ref.setData(["ignoring":false, "remaining":self.user_skip_Comfirm_period, "Last_answer":Answer, "Last_assessment":self.TimeChoice!,"next":next, "Question_body":Question_body])
                        }else{
                            if remaining > 0{
                                if self.TimeChoice == Last_assessment{
                                    Question_ref.setData(["ignoring":false, "remaining":remaining, "Last_answer":Answer, "Last_assessment":self.TimeChoice!,"next":next, "Question_body":Question_body])
                                }else{
                                    Question_ref.setData(["ignoring":false, "remaining":(remaining-1), "Last_answer":Answer, "Last_assessment":self.TimeChoice!,"next":next, "Question_body":Question_body])
                                }
                            }else{
                                Question_ref.setData(["ignoring":true, "remaining":self.user_skip_period, "Last_answer":Answer, "Last_assessment":self.TimeChoice!,"next":next, "Question_body":Question_body])
                            }
                        }
                    }else{
                        if Last_ans != Answer{
                            Question_ref.setData(["ignoring":false, "remaining":self.user_skip_Comfirm_period, "Last_answer":Answer, "Last_assessment":self.TimeChoice!,"next":next, "Question_body":Question_body])
                        }else{
                            if remaining > 0{
                                if self.TimeChoice == Last_assessment{
                                    Question_ref.setData(["ignoring":true, "remaining":remaining, "Last_answer":Answer, "Last_assessment":self.TimeChoice!,"next":next, "Question_body":Question_body])
                                }else{
                                    Question_ref.setData(["ignoring":true, "remaining":(remaining-1), "Last_answer":Answer, "Last_assessment":self.TimeChoice!,"next":next, "Question_body":Question_body])
                                }
                            }else{
                                Question_ref.setData(["ignoring":true, "remaining":self.user_skip_period, "Last_answer":Answer, "Last_assessment":self.TimeChoice!,"next":next, "Question_body":Question_body])
                            }
                        }
                    }
                }else{
                    Question_ref.setData(["ignoring":false, "remaining":self.user_skip_Comfirm_period, "Last_answer":Answer, "Last_assessment":self.TimeChoice!,"next":next, "Question_body":Question_body])
                    
                }
            }
        }
    }
    
    // Question generate Selector
    func QuestionProcess(Questionid:String){
        //Classify questions
        let Question_ref = db.collection("Questions").document("ESSAS_Main").collection("Questions").document(Questionid)
        Question_ref.getDocument{(document,error)in
            if let document = document{
                if let data = document.data(){
                    self.Type_selector(Questionid: document.documentID, Type: data["Type"] as! String)
                }
            }
        }
    }
    
    func Type_selector(Questionid:String, Type: String){
        //put question into different user interface
        if Type == "11choices"{
            let ElevenChoices = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ElevenChoices") as! ElevenChoicesViewController
            self.addChild(ElevenChoices)
            ElevenChoices.view.frame = self.view.frame
            self.view.addSubview(ElevenChoices.view)
            ElevenChoices.didMove(toParent: self )
            ElevenChoices.Questionid = Questionid
            ElevenChoices.History_button.titleLabel?.text = ""
            ElevenChoices.History_button.isEnabled = false
        }
        else if Type == "Input"{
            let inputQ = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "InputQuestion") as! InputQuestionViewController
            self.addChild(inputQ)
            inputQ.view.frame = self.view.frame
            self.view.addSubview(inputQ.view)
            inputQ.didMove(toParent: self )
            inputQ.Questionid = Questionid
            inputQ.History_button.titleLabel?.text = ""
            inputQ.History_button.isEnabled = false
        }else if Type == "MC"{
            let MTQ = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "MTQuestion") as! MTQuestionViewController
            self.addChild(MTQ)
            MTQ.view.frame = self.view.frame
            self.view.addSubview(MTQ.view)
            MTQ.didMove(toParent: self )
            MTQ.Questionid = Questionid
            MTQ.History_button.titleLabel?.text = ""
            MTQ.History_button.isEnabled = false
        }else if Type == "MS"{
            let MSQ = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "MTSelection") as! MTSelectionViewController
            self.addChild(MSQ)
            MSQ.view.frame = self.view.frame
            self.view.addSubview(MSQ.view)
            MSQ.didMove(toParent: self )
            MSQ.Questionid = Questionid
            MSQ.History_button.titleLabel?.text = ""
            MSQ.History_button.isEnabled = false
        }
        
    }
    
    

    @IBAction func GoBack(_ sender: UIButton) {
        let temp = self.parent as! QuestionGenerator
        self.view.removeFromSuperview()
        if self.end_flag == true{
            temp.result_page()
        }else{
            temp.from_history()
        }
    }
    
    //For collection View
    private func setupCollectionView(){
        CollectionView.delegate = self
        CollectionView.dataSource = self
    }
    
    //set parameters for collection view items
    private func setupCollectionViewItemSize(){
        if collectionViewFlowLayout == nil{
            let numberOfItemsForRow: CGFloat = 1
            let lineSpacing: CGFloat = 20
            let interItemSpacing: CGFloat = 5
            
            var width:CGFloat = (CollectionView.frame.width - (numberOfItemsForRow-1)*interItemSpacing)/numberOfItemsForRow
            var height:CGFloat = 300
            
            
            collectionViewFlowLayout = UICollectionViewFlowLayout()
            
            collectionViewFlowLayout.itemSize = CGSize(width: width, height: height)
            collectionViewFlowLayout.sectionInset = UIEdgeInsets.zero
            collectionViewFlowLayout.scrollDirection = .vertical
            collectionViewFlowLayout.minimumLineSpacing = lineSpacing
            collectionViewFlowLayout.minimumInteritemSpacing = interItemSpacing
            CollectionView.setCollectionViewLayout(collectionViewFlowLayout, animated: true)
            CollectionView.backgroundColor = UIColor.white.withAlphaComponent(0)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.Question.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! CollectionViewCell
        print(indexPath.item)
        print(self.Q_index[indexPath.item]!)
        cell.TextLabel.text = self.Q_body[self.Q_index[indexPath.item]!]! + "\n" + self.Q_A[self.Q_index[indexPath.item]!]!
        
        if self.skippingList[self.Q_index[indexPath.item]!]! == false{
            self.celllist[indexPath.item] = true
        }
        
        if let celltemp = self.celllist[indexPath.item]{
            if celltemp == true{
                cell.backgroundColor = UIColor.init(red: 62/255, green: 109/255, blue: 63/255, alpha: 1)
            }else{
                cell.backgroundColor = UIColor.gray.withAlphaComponent(0.5)
            }
        }else{
            cell.backgroundColor = UIColor.gray.withAlphaComponent(0.5)
        }
        cell.TextLabel.textColor = .black
        cell.TextLabel.halfTextColorChange(fullText: cell.TextLabel.text!, changeText: self.Q_A[self.Q_index[indexPath.item]!]!)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print(self.Q_index[indexPath.item]!)
        self.QuestionProcess(Questionid: self.Q_index[indexPath.item]!)
        collectionView.reloadItems(at: [indexPath])
        
    }
    


    
}

extension UILabel {
    func halfTextColorChange (fullText : String , changeText : String ) {
        let strNumber: NSString = fullText as NSString
        let range = (strNumber).range(of: changeText)
        let attribute = NSMutableAttributedString.init(string: fullText)
        attribute.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.init(red: 247/255, green: 227/255, blue: 219/255, alpha: 1) , range: range)
        self.attributedText = attribute
    }
}


