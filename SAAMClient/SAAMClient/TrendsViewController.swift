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
    
    @IBOutlet weak var G1: LineChartView!
    @IBOutlet weak var G2: LineChartView!
    @IBOutlet weak var G3: LineChartView!
    @IBOutlet weak var G4: LineChartView!
    @IBOutlet weak var G5: LineChartView!
    @IBOutlet weak var G6: LineChartView!
    @IBOutlet weak var G7: LineChartView!
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
    /*
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

    lazy var asv1:Double? = 0
    lazy var asv2:Double? = 2
    lazy var asv3:Double? = 4
    lazy var asv4:Double? = 1
    lazy var asv5:Double? = 3
    lazy var asv6:Double? = 5
    lazy var asv7:Double? = 8
    */
    override func viewDidLoad() {
        super.viewDidLoad()
        setG1()
        setG2()
        setG3()
        setG4()
        setG5()
        setG6()
        setG7()
        setData1()
        setData2()
        setData3()
        setData4()
        setData5()
        setData6()
        setData7()
        /*
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
        }*/

    }
//*******************____________*************************
    var xx1 = [Double]()
    var yy1 = [Double]()
    // count is the number of answer of that question!
    // the default is 4 answers
    // we just need to change the input of ChartDataEntry(x: xx1[i], y:yy1[i]) now
    func setData1(_ count : Int = 4) {
        let values = (0..<count).map{(i) -> ChartDataEntry in // here i is an array but how can we set i to be an array?
            let val = Double(arc4random_uniform(UInt32(count)) + 3) // val is now an array of 0<10(0-9 ones!) values
            xx1.append(Double("1.5") as! Double)
            xx1.append(Double(3))
            xx1.append(Double(4))
            xx1.append(Double(5))
            yy1.append(Double(1.0))
            yy1.append(Double(3))
            yy1.append(Double(6.0))
            yy1.append(Double("7.0") as! Double)
            return ChartDataEntry(x: xx1[i], y:yy1[i])
        }
        // values are what we are going to plot
        // label is the problem body
        let set1 = LineChartDataSet(entries: values, label: "SAAM Pain Score Line Chart")
        set1.drawCirclesEnabled = false
        set1.mode = .cubicBezier
        set1.lineWidth = 1
        set1.setColor(.white)
        set1.fill = Fill(color: .white)
        set1.fillAlpha = 0.8
        set1.drawFilledEnabled = true
        set1.drawHorizontalHighlightIndicatorEnabled = true
        set1.highlightColor = .systemRed
        let data = LineChartData(dataSet: set1)
        //data.setDrawValues(false)
        G1.data = data
    }
    
    
    func setData2(_ count : Int = 4) {
    let values = (0..<count).map{(i) -> ChartDataEntry in // here i is an array but how can we set i to be an array?
        let val = Double(arc4random_uniform(UInt32(count)) + 3) // val is now an array of 0<10(0-9 ones!) values
        xx1.append(Double("1.5") as! Double)
        xx1.append(Double(3))
        xx1.append(Double(4))
        xx1.append(Double(5))
        yy1.append(Double(1.0))
        yy1.append(Double(3))
        yy1.append(Double(6.0))
        yy1.append(Double("7.0") as! Double)
        return ChartDataEntry(x: xx1[i], y:yy1[i])
    }
    // values are what we are going to plot
    // label is the problem body
    let set1 = LineChartDataSet(entries: values, label: "SAAM Tiredness Score Line Chart")
    set1.drawCirclesEnabled = false
    set1.mode = .cubicBezier
    set1.lineWidth = 1
    set1.setColor(.white)
    set1.fill = Fill(color: .white)
    set1.fillAlpha = 0.8
    set1.drawFilledEnabled = true
    set1.drawHorizontalHighlightIndicatorEnabled = true
    set1.highlightColor = .systemRed
    let data = LineChartData(dataSet: set1)
    //data.setDrawValues(false)
    G2.data = data
    }
    
    
    func setData3(_ count : Int = 4) {
    let values = (0..<count).map{(i) -> ChartDataEntry in // here i is an array but how can we set i to be an array?
        let val = Double(arc4random_uniform(UInt32(count)) + 3) // val is now an array of 0<10(0-9 ones!) values
        xx1.append(Double("1.5") as! Double)
        xx1.append(Double(3))
        xx1.append(Double(4))
        xx1.append(Double(5))
        yy1.append(Double(1.0))
        yy1.append(Double(3))
        yy1.append(Double(6.0))
        yy1.append(Double("7.0") as! Double)
        return ChartDataEntry(x: xx1[i], y:yy1[i])
    }
    // values are what we are going to plot
    // label is the problem body
    let set1 = LineChartDataSet(entries: values, label: "SAAM Nausea Score Line Chart")
    set1.drawCirclesEnabled = false
    set1.mode = .cubicBezier
    set1.lineWidth = 1
    set1.setColor(.white)
    set1.fill = Fill(color: .white)
    set1.fillAlpha = 0.8
    set1.drawFilledEnabled = true
    set1.drawHorizontalHighlightIndicatorEnabled = true
    set1.highlightColor = .systemRed
    let data = LineChartData(dataSet: set1)
    //data.setDrawValues(false)
    G3.data = data
    }
    
    func setData4(_ count : Int = 4) {
    let values = (0..<count).map{(i) -> ChartDataEntry in // here i is an array but how can we set i to be an array?
        let val = Double(arc4random_uniform(UInt32(count)) + 3) // val is now an array of 0<10(0-9 ones!) values
        xx1.append(Double("1.5") as! Double)
        xx1.append(Double(3))
        xx1.append(Double(4))
        xx1.append(Double(5))
        yy1.append(Double(1.0))
        yy1.append(Double(3))
        yy1.append(Double(6.0))
        yy1.append(Double("7.0") as! Double)
        return ChartDataEntry(x: xx1[i], y:yy1[i])
    }
    // values are what we are going to plot
    // label is the problem body
    let set1 = LineChartDataSet(entries: values, label: "SAAM Appetite Score Line Chart")
    set1.drawCirclesEnabled = false
    set1.mode = .cubicBezier
    set1.lineWidth = 1
    set1.setColor(.white)
    set1.fill = Fill(color: .white)
    set1.fillAlpha = 0.8
    set1.drawFilledEnabled = true
    set1.drawHorizontalHighlightIndicatorEnabled = true
    set1.highlightColor = .systemRed
    let data = LineChartData(dataSet: set1)
    //data.setDrawValues(false)
    G4.data = data
    }
    
    func setData5(_ count : Int = 4) {
    let values = (0..<count).map{(i) -> ChartDataEntry in // here i is an array but how can we set i to be an array?
        let val = Double(arc4random_uniform(UInt32(count)) + 3) // val is now an array of 0<10(0-9 ones!) values
        xx1.append(Double("1.5") as! Double)
        xx1.append(Double(3))
        xx1.append(Double(4))
        xx1.append(Double(5))
        yy1.append(Double(1.0))
        yy1.append(Double(3))
        yy1.append(Double(6.0))
        yy1.append(Double("7.0") as! Double)
        return ChartDataEntry(x: xx1[i], y:yy1[i])
    }
    // values are what we are going to plot
    // label is the problem body
    let set1 = LineChartDataSet(entries: values, label: "SAAM Shortness of Breadth Score Line Chart")
    set1.drawCirclesEnabled = false
    set1.mode = .cubicBezier
    set1.lineWidth = 1
    set1.setColor(.white)
    set1.fill = Fill(color: .white)
    set1.fillAlpha = 0.8
    set1.drawFilledEnabled = true
    set1.drawHorizontalHighlightIndicatorEnabled = true
    set1.highlightColor = .systemRed
    let data = LineChartData(dataSet: set1)
    //data.setDrawValues(false)
    G5.data = data
    }
    
    func setData6(_ count : Int = 4) {
    let values = (0..<count).map{(i) -> ChartDataEntry in // here i is an array but how can we set i to be an array?
        let val = Double(arc4random_uniform(UInt32(count)) + 3) // val is now an array of 0<10(0-9 ones!) values
        xx1.append(Double("1.5") as! Double)
        xx1.append(Double(3))
        xx1.append(Double(4))
        xx1.append(Double(5))
        yy1.append(Double(1.0))
        yy1.append(Double(3))
        yy1.append(Double(6.0))
        yy1.append(Double("7.0") as! Double)
        return ChartDataEntry(x: xx1[i], y:yy1[i])
    }
    // values are what we are going to plot
    // label is the problem body
    let set1 = LineChartDataSet(entries: values, label: "SAAM Depression of Breadth Score Line Chart")
    set1.drawCirclesEnabled = false
    set1.mode = .cubicBezier
    set1.lineWidth = 1
    set1.setColor(.white)
    set1.fill = Fill(color: .white)
    set1.fillAlpha = 0.8
    set1.drawFilledEnabled = true
    set1.drawHorizontalHighlightIndicatorEnabled = true
    set1.highlightColor = .systemRed
    let data = LineChartData(dataSet: set1)
    //data.setDrawValues(false)
    G6.data = data
    }
    
    func setData7(_ count : Int = 4) {
    let values = (0..<count).map{(i) -> ChartDataEntry in // here i is an array but how can we set i to be an array?
        let val = Double(arc4random_uniform(UInt32(count)) + 3) // val is now an array of 0<10(0-9 ones!) values
        xx1.append(Double("1.5") as! Double)
        xx1.append(Double(3))
        xx1.append(Double(4))
        xx1.append(Double(5))
        yy1.append(Double(1.0))
        yy1.append(Double(3))
        yy1.append(Double(6.0))
        yy1.append(Double("7.0") as! Double)
        return ChartDataEntry(x: xx1[i], y:yy1[i])
    }
    // values are what we are going to plot
    // label is the problem body
    let set1 = LineChartDataSet(entries: values, label: "SAAM Anxiety Score Line Chart")
    set1.drawCirclesEnabled = false
    set1.mode = .cubicBezier
    set1.lineWidth = 1
    set1.setColor(.white)
    set1.fill = Fill(color: .white)
    set1.fillAlpha = 0.8
    set1.drawFilledEnabled = true
    set1.drawHorizontalHighlightIndicatorEnabled = true
    set1.highlightColor = .systemRed
    let data = LineChartData(dataSet: set1)
    //data.setDrawValues(false)
    G7.data = data
    }
    // set the input above!!!!!!!!!!!!!!!!!!
    //**********************************___________*************************
    func setG1(){
        G1.backgroundColor = .systemBlue
        G1.rightAxis.enabled = false
        G1.leftAxis.labelFont = .boldSystemFont(ofSize: 12)
        G1.leftAxis.setLabelCount(6, force: false) // how many labels we present in y axis
        G1.leftAxis.labelTextColor = .white
        G1.leftAxis.axisLineColor = .white
        G1.leftAxis.labelPosition = .outsideChart
        G1.leftAxis.drawLabelsEnabled = true
        G1.xAxis.labelPosition = .bottom
        G1.xAxis.labelFont = .boldSystemFont(ofSize: 12)
        G1.xAxis.axisLineColor = .systemBlue
        G1.animate(xAxisDuration: 0.5) //time effect
    }
    func setG2(){
        G2.backgroundColor = .systemBlue
        G2.rightAxis.enabled = false
        G2.leftAxis.labelFont = .boldSystemFont(ofSize: 12)
        G2.leftAxis.setLabelCount(6, force: false) // how many labels we present in y axis
        G2.leftAxis.labelTextColor = .white
        G2.leftAxis.axisLineColor = .white
        G2.leftAxis.labelPosition = .outsideChart
        G2.leftAxis.drawLabelsEnabled = true
        G2.xAxis.labelPosition = .bottom
        G2.xAxis.labelFont = .boldSystemFont(ofSize: 12)
        G2.xAxis.axisLineColor = .systemBlue
        G2.animate(xAxisDuration: 0.5) //time effect
    }
    func setG3(){
        G3.backgroundColor = .systemBlue
        G3.rightAxis.enabled = false
        G3.leftAxis.labelFont = .boldSystemFont(ofSize: 12)
        G3.leftAxis.setLabelCount(6, force: false) // how many labels we present in y axis
        G3.leftAxis.labelTextColor = .white
        G3.leftAxis.axisLineColor = .white
        G3.leftAxis.labelPosition = .outsideChart
        G3.leftAxis.drawLabelsEnabled = true
        G3.xAxis.labelPosition = .bottom
        G3.xAxis.labelFont = .boldSystemFont(ofSize: 12)
        G3.xAxis.axisLineColor = .systemBlue
        G3.animate(xAxisDuration: 0.5) //time effect
    }
    func setG4(){
        G4.backgroundColor = .systemBlue
        G4.rightAxis.enabled = false
        G4.leftAxis.labelFont = .boldSystemFont(ofSize: 12)
        G4.leftAxis.setLabelCount(6, force: false) // how many labels we present in y axis
        G4.leftAxis.labelTextColor = .white
        G4.leftAxis.axisLineColor = .white
        G4.leftAxis.labelPosition = .outsideChart
        G4.leftAxis.drawLabelsEnabled = true
        G4.xAxis.labelPosition = .bottom
        G4.xAxis.labelFont = .boldSystemFont(ofSize: 12)
        G4.xAxis.axisLineColor = .systemBlue
        G4.animate(xAxisDuration: 0.5) //time effect
    }
    func setG5(){
        G5.backgroundColor = .systemBlue
        G5.rightAxis.enabled = false
        G5.leftAxis.labelFont = .boldSystemFont(ofSize: 12)
        G5.leftAxis.setLabelCount(6, force: false) // how many labels we present in y axis
        G5.leftAxis.labelTextColor = .white
        G5.leftAxis.axisLineColor = .white
        G5.leftAxis.labelPosition = .outsideChart
        G5.leftAxis.drawLabelsEnabled = true
        G5.xAxis.labelPosition = .bottom
        G5.xAxis.labelFont = .boldSystemFont(ofSize: 12)
        G5.xAxis.axisLineColor = .systemBlue
        G5.animate(xAxisDuration: 0.5) //time effect
    }
    func setG6(){
        G6.backgroundColor = .systemBlue
        G6.rightAxis.enabled = false
        G6.leftAxis.labelFont = .boldSystemFont(ofSize: 12)
        G6.leftAxis.setLabelCount(6, force: false) // how many labels we present in y axis
        G6.leftAxis.labelTextColor = .white
        G6.leftAxis.axisLineColor = .white
        G6.leftAxis.labelPosition = .outsideChart
        G6.leftAxis.drawLabelsEnabled = true
        G6.xAxis.labelPosition = .bottom
        G6.xAxis.labelFont = .boldSystemFont(ofSize: 12)
        G6.xAxis.axisLineColor = .systemBlue
        G6.animate(xAxisDuration: 0.5) //time effect
    }
    func setG7(){
        G7.backgroundColor = .systemBlue
        G7.rightAxis.enabled = false
        G7.leftAxis.labelFont = .boldSystemFont(ofSize: 12)
        G7.leftAxis.setLabelCount(6, force: false) // how many labels we present in y axis
        G7.leftAxis.labelTextColor = .white
        G7.leftAxis.axisLineColor = .white
        G7.leftAxis.labelPosition = .outsideChart
        G7.leftAxis.drawLabelsEnabled = true
        G7.xAxis.labelPosition = .bottom
        G7.xAxis.labelFont = .boldSystemFont(ofSize: 12)
        G7.xAxis.axisLineColor = .systemBlue
        G7.animate(xAxisDuration: 0.5) //time effect
    }



    
    @IBAction func GetBack(_ sender: Any) {
        performSegue(withIdentifier: "TrendBackProfile", sender: self)
    }
    
/*
    @IBAction func BacktoProfile(_ sender: Any) {
        performSegue(withIdentifier: "TrendBackProfile", sender: self)
    }*/
    /*
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
 */


}
