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
import Charts
import TinyConstraints

class TrendsViewController: UIViewController, ChartViewDelegate {
    
    lazy var lineChartView: LineChartView = {
        let chartView = LineChartView()
        chartView.backgroundColor = .systemBlue
        chartView.rightAxis.enabled = false
        let yAxis = chartView.leftAxis
        yAxis.labelFont = .boldSystemFont(ofSize: 12)
        yAxis.setLabelCount(6, force: false) // how many labels we present in y axis
        yAxis.labelTextColor = .white
        yAxis.axisLineColor = .white
        yAxis.labelPosition = .outsideChart
        yAxis.drawLabelsEnabled = true
        
        chartView.xAxis.labelPosition = .bottom
        chartView.xAxis.labelFont = .boldSystemFont(ofSize: 12)
        chartView.xAxis.axisLineColor = .systemBlue
        //chartView.chartDescription?.text = "Y: Test Score  X: Day"
        //chartView.legend.enabled = false
        //chartView.accessibilityLabel = "ddf"
        chartView.animate(xAxisDuration: 1) //time effect
        
        
        return chartView
    }()
    
    //define the uid and questionaire_name
    var uid:String?
    var buttons:[UIButton] = []
    var buttonmap: [String:String] = [:]
    var FormatTime:String?
    var assessments:[String] = []
    var Questions:[String:[String:String]] = [:] //[Assessment_timestamp:[Question_id:Answer]]
    // average value is of no use, we just need the max of every day
    // thus we have a value of seven days first!
    // we always set assessmentValue[6]
    lazy var asv1:Double? = 0
    lazy var asv2:Double? = 2
    lazy var asv3:Double? = 4
    lazy var asv4:Double? = 1
    lazy var asv5:Double? = 3
    lazy var asv6:Double? = 5
    lazy var asv7:Double? = 8
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        if let uid = Auth.auth().currentUser?.uid {
            self.uid = uid;
            print(uid)
            Get_All_Assessments(){
                print(self.Questions)
                // Everything should be implemented in here
                // I don't need to know how this appears but we just need to draw the pic
                // results are stored in questions!
               // assume we have the max map first, but how to gain the value?
                self.view.addSubview(self.lineChartView)
                self.lineChartView.centerInSuperview()
                self.lineChartView.width(to: self.view)
                //lineChartView.width = lineChartView.width - 20
                self.lineChartView.heightToWidth(of: self.view)
                self.setData() // hpw to get all timestamp??
                
            }
        }

    }
    /*
    override func viewWillAppear(_ animated: Bool) {
        //get the user's uid
        if let uid = Auth.auth().currentUser?.uid {
            self.uid = uid;
            print(uid)
            Get_All_Assessments(){
                print(self.Questions)
                // Everything should be implemented in here
                // I don't need to know how this appears but we just need to draw the pic
                // results are stored in questions!
               // assume we have the max map first, but how to gain the value?

                
            }
        }
    }*/
    
    
    @IBAction func BacktoProfile(_ sender: Any) {
        performSegue(withIdentifier: "TrendBackProfile", sender: self)
    }
    func setData() {
        var yValues: [ChartDataEntry] = [
            ChartDataEntry(x: 0.0, y: asv1!),
            ChartDataEntry(x: 1.0, y: asv2!),
            ChartDataEntry(x: 2.0, y: asv3!),
            ChartDataEntry(x: 3.0, y: asv4!),
            ChartDataEntry(x: 4.0, y: asv5!),
            ChartDataEntry(x: 5.0, y: asv6!),
            ChartDataEntry(x: 6.0, y: asv7!)
        ]
        let set1 = LineChartDataSet(entries: yValues, label: "SAAM Daily Highest Score Curve")
        set1.drawCirclesEnabled = false
        set1.mode = .cubicBezier
        set1.lineWidth = 3
        set1.setColor(.white)
        set1.fill = Fill(color: .white)
        set1.fillAlpha = 0.8
        set1.drawFilledEnabled = true
        
        set1.drawHorizontalHighlightIndicatorEnabled = true
        set1.highlightColor = .systemRed
        
        let data = LineChartData(dataSet: set1)
        //data.setDrawValues(false)
        lineChartView.data = data
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
                            
                            var count = Double(7.0)
                            var asss:Double?
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
                                                            // let me try it
                                                            /*
                                                            let asss = Double(data["answer"] as! String)
                                                            self.asv1 = Double(data["answer"] as! String)
                                                            print("Double is ")
                                        
                                                            print(asss)
                                                            print("asv1 is ")
                                                            print(self.asv1)
                                                            */
                                                            
                                                            if(count.isLess(than: 1.1)){
                                                                // do asv1
                                                                
                                                                asss = Double(data["answer"] as! String)
                                                                print("the first one")
                                                                print("asss is ")
                                                                print(asss)
                                                                print("asv1 is ")
                                                                print(self.asv1)
                                                                if(((self.asv1?.isLess(than: asss!))!)){
                                                                    self.asv1 = asss
                                                                    print("we got a bigger asv1 ")
                                                                    print(self.asv1)
                                                                }
                                                            }else if(count.isLess(than: 2.1)){
                                                                // do asv1
                                                                
                                                                asss = Double(data["answer"] as! String)
                                                                print("the first one")
                                                                print("asss is ")
                                                                print(asss)
                                                                print("asv1 is ")
                                                                print(self.asv1)
                                                                if(((self.asv2?.isLess(than: asss!))!)){
                                                                    self.asv2 = asss
                                                                    print("we got a bigger asv1 ")
                                                                    print(self.asv2)
                                                                }
                                                            }else if(count.isLess(than: 3.1)){
                                                                // do asv1
                                                                
                                                                asss = Double(data["answer"] as! String)
                                                                print("the first one")
                                                                print("asss is ")
                                                                print(asss)
                                                                print("asv1 is ")
                                                                print(self.asv1)
                                                                if(((self.asv3?.isLess(than: asss!))!)){
                                                                    self.asv3 = asss
                                                                    print("we got a bigger asv1 ")
                                                                    print(self.asv3)
                                                                }
                                                            }else if(count.isLess(than: 4.1)){
                                                                // do asv1
                                                                
                                                                asss = Double(data["answer"] as! String)
                                                                print("the first one")
                                                                print("asss is ")
                                                                print(asss)
                                                                print("asv1 is ")
                                                                print(self.asv4)
                                                                if(((self.asv4?.isLess(than: asss!))!)){
                                                                    self.asv4 = asss
                                                                    print("we got a bigger asv1 ")
                                                                    print(self.asv4)
                                                                }
                                                            }else if(count.isLess(than: 5.1)){
                                                                // do asv1
                                                                
                                                                asss = Double(data["answer"] as! String)
                                                                print("the first one")
                                                                print("asss is ")
                                                                print(asss)
                                                                print("asv1 is ")
                                                                print(self.asv5)
                                                                if(((self.asv5?.isLess(than: asss!))!)){
                                                                    self.asv5 = asss
                                                                    print("we got a bigger asv1 ")
                                                                    print(self.asv5)
                                                                }
                                                            }else if(count.isLess(than: 6.1)){
                                                                // do asv1
                                                                
                                                                asss = Double(data["answer"] as! String)
                                                                print("the first one")
                                                                print("asss is ")
                                                                print(asss)
                                                                print("asv1 is ")
                                                                print(self.asv6)
                                                                if(((self.asv6?.isLess(than: asss!))!)){
                                                                    self.asv6 = asss
                                                                    print("we got a bigger asv1 ")
                                                                    print(self.asv6)
                                                                }
                                                            }else if(count.isLess(than: 7.1)){
                                                                // do asv1
                                                                
                                                                asss = Double(data["answer"] as! String)
                                                                print("the first one")
                                                                print("asss is ")
                                                                print(asss)
                                                                print("asv1 is ")
                                                                print(self.asv7)
                                                                if(((self.asv7?.isLess(than: asss!))!)){
                                                                    self.asv7 = asss
                                                                    print("we got a bigger asv1 ")
                                                                    print(self.asv7)
                                                                }
                                                            }else{
                                                                print("compare falis count is ")
                                                                print(count)
                                                            }
                                                            
                                                        }
                                                    }
                                                    //print(answers)
                                                    self.Questions[Assessment] = answers
                                                }
                                            count = count - 1
                                            print("count is ")
                                            print(count)
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


}
