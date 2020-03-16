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
    
    var uid:String? = "Jg4vlNl6qyQ4Tb16QNWido1M9ZO2"
    var TimeChoice:String? = "1584268547"
    var Recommendations:[String] = []
    var Question:[String] = []
    var Q_A:[String:String] = [:]
    var Q_body:[String:String] = [:]
    var Q_Abody: [String:String] = [:]
    var Q_index:[Int:String] = [:]
    var celllist:[Int:Bool] = [:]
    
    //collection View
    var collectionViewFlowLayout: UICollectionViewFlowLayout!
    
    //collection view cell identifier
    let cellIdentifier = "cell"
    
    //init firestore and firebase storage
    let db = Firestore.firestore()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let uid = Auth.auth().currentUser?.uid
        
        let Collection_ref = db.collection("logs").document(self.uid!).collection(self.TimeChoice!)
        
        Collection_ref.getDocuments{(snapshot,error)in
            if let error = error{
                print(error.localizedDescription)
            }else{
                if snapshot != nil{
                        for document in snapshot!.documents{
                            let data = document.data()
                            if(document.documentID != "Recommendations" && document.documentID != "Order"){
                                self.Q_body[document.documentID] = data["QuestionBody"] as! String
                                self.Q_A[document.documentID] = data["AnswerBody"] as! String
                            }else if(document.documentID == "Order"){
                                self.Question = data["Order"] as! [String]
                            }
                        }
                    print("Questions:")
                    var count = 0
                    for index in self.Question{
                        self.Q_index[count] = index
                        count+=1
                        print("Question id: \(index), Question: \(self.Q_body[index]!)")
                    }
                    

                    self.setupCollectionView()
                    self.setupCollectionViewItemSize()

                    
                    
                    }
                }
            }
    }
    
    
    @objc func buttonAction(sender: UIButton!) {
    }

    @IBAction func GoBack(_ sender: UIButton) {
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

        if let celltemp = self.celllist[indexPath.item]{
            if celltemp == true{
                cell.backgroundColor = UIColor.init(red: 62/255, green: 109/255, blue: 63/255, alpha: 1)
            }else{
                cell.backgroundColor = UIColor.gray.withAlphaComponent(0.5)
            }
        }else{
            self.celllist[indexPath.item] = false
            cell.backgroundColor = UIColor.gray.withAlphaComponent(0.5)
        }
        cell.TextLabel.textColor = .black
        cell.TextLabel.halfTextColorChange(fullText: cell.TextLabel.text!, changeText: self.Q_A[self.Q_index[indexPath.item]!]!)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print(self.Q_index[indexPath.item]!)
        let cellTemp = self.celllist[indexPath.item]
        if cellTemp == true{
            self.celllist[indexPath.item] = false
        }else{
            self.celllist[indexPath.item] = true
        }
        
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


