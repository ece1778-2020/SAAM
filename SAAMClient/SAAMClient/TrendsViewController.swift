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
    
    var chart_array:[LineChartView] = []
    var String_dic:[LineChartView:String] = [:]
    
    var uid:String?
    var FormatTime:String?
    var assessments:[String] = []
    var ind_ass:[Int:String] = [:]
    var Format_time:[String:String] = [:]
    var Questions:[String:[String:String]] = [:]
    let Questions_id:[String] = ["1","2","3","4","5","6","7"]
    
    let amount = 7
    
    //init firestore and firebase storage
    let db = Firestore.firestore()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let uid = Auth.auth().currentUser?.uid{
            self.uid = uid
            Get_All_Assessments(){
                self.assessments.sort(by: <)
                var count = 0
                for assessment in self.assessments{
                    self.ind_ass[count] = assessment
                    count = count + 1
                }
                self.get_answers(index: 0) {
                    print(self.Questions)
                    self.load_plots()
                }
            }
        }
        
        
    }
    
    func load_plots(){
        self.chart_array = [self.G1, self.G2, self.G3, self.G4, self.G5, self.G6, self.G7]
        self.String_dic = [self.G1:"SAAM Pain Score Line Chart", self.G2:"SAAM Tiredness Score Line Chart", self.G3:"SAAM Nausea Score Line Chart", self.G4:"SAAM Appetite Score Line Chart", self.G5:"SAAM Shortness of Breadth Score Line Chart", self.G6:"SAAM Depression of Breadth Score Line Chart", self.G7:"SAAM Anxiety Score Line Chart"]
        
        var count = 1
        for chart in chart_array{
            set_chart(chart: chart)
            setData(chart: chart, count: 5, Label: self.String_dic[chart]!, index: count)
            count = count + 1
        }
    }
    
    
    func get_answers(index:Int, completion:@escaping ()->()){
        let Collection_ref = db.collection("logs").document(self.uid!).collection(self.ind_ass[index]!)
        Collection_ref.getDocuments{(snapshot,error)in
        if let error = error{
            print(error.localizedDescription)
        }else{
            if snapshot != nil{
                var assessments_Q:[String:String] = [:]
                    for document in snapshot!.documents{
                        let data = document.data()
                        
                        if self.Questions_id.contains(document.documentID){
                            if (data["Type"] as! String) != "skipped"{
                                assessments_Q[document.documentID] = data["answer"] as! String
                            }
                        }
                    }
                
                self.Questions[self.ind_ass[index]!] = assessments_Q
                }
            }
            
            if index == (self.ind_ass.count-1){
                completion()
            }else{
                self.get_answers(index: index+1) {
                    print("here")
                    completion()
                }
            }
        }
        
    }
    
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
                            Completed_Assessments.sort(by: >)
                            
                            var count = 0
                            for Assessment in Completed_Assessments{
                                let FormatTimeStamp = self.TimeStampFormatter(StrTimeStamp: Assessment)
                                self.assessments.append(Assessment)
                                self.Format_time[Assessment] = FormatTimeStamp
                                count = count + 1
                                if count >= self.amount{
                                    break
                                }
                            }
                            
                            
                        }
                    }else{
                        print("You don't have any completed assessments")
                    }
                }
                completion()
            }
        }
    }
    
    var xx1 = [Double]()
    var yy1 = [Double]()
    // count is the number of answer of that question!
    // the default is 4 answers
    // we just need to change the input of ChartDataEntry(x: xx1[i], y:yy1[i]) now
    func setData(chart:LineChartView, count : Int, Label:String, index:Int) {
        
        
        var count = 0
        var x_label:[Int:Double] = [:]
        var y_label:[Int:Double] = [:]
        for assessment in self.assessments{
            let q_a = self.Questions[assessment]!
            if let answer = q_a[String(index)]{
                print("[INFO] assessment: \(assessment), Question: \(String(index)), Answer: \(answer) ")
                x_label[count] = self.X_formatter(StrTimeStamp: assessment)
                y_label[count] = Double(answer) as! Double
                count = count + 1
            }
        }
        
        let values = (0..<count).map{(i) -> ChartDataEntry in // here i is an array but how can wet
            
            return ChartDataEntry(x: Double(i), y:y_label[i]!)
            //return ChartDataEntry(x: x_label[i]!, y:y_label[i]!)
        }
        // values are what we are going to plot
        // label is the problem body
        let set1 = LineChartDataSet(entries: values, label: Label)
        set1.drawCirclesEnabled = false
        set1.mode = .linear
        set1.lineWidth = 1
        set1.setColor(.white)
        set1.fill = Fill(color: .white)
        set1.fillAlpha = 0.8
        set1.drawFilledEnabled = true
        set1.drawHorizontalHighlightIndicatorEnabled = true
        set1.highlightColor = .systemRed
        let data = LineChartData(dataSet: set1)
        //data.setDrawValues(false)
        chart.data = data
        chart.xAxis.axisMinimum = 0
        chart.xAxis.axisMaximum = Double(count-1)
        chart.xAxis.setLabelCount(count, force: true)
    }

    func set_chart(chart:LineChartView){
        chart.backgroundColor = .systemBlue
        chart.rightAxis.enabled = false
        chart.leftAxis.labelFont = .boldSystemFont(ofSize: 12)
        chart.leftAxis.setLabelCount(10, force: true) // how many labels we present in y axis
        chart.leftAxis.axisMinimum = 0
        chart.leftAxis.axisMaximum = 10
        chart.leftAxis.labelTextColor = .white
        chart.leftAxis.axisLineColor = .white
        chart.leftAxis.labelPosition = .outsideChart
        chart.leftAxis.drawLabelsEnabled = true
        chart.xAxis.labelPosition = .bottom
        chart.xAxis.labelFont = .boldSystemFont(ofSize: 12)
        chart.xAxis.axisLineColor = .systemBlue
        chart.animate(xAxisDuration: 0.5) //time effect
    }



    
    @IBAction func GetBack(_ sender: Any) {
        performSegue(withIdentifier: "TrendBackProfile", sender: self)
    }
    
    
    
    func TimeStampFormatter(StrTimeStamp:String) -> String{
        let date = Date(timeIntervalSince1970: Double(StrTimeStamp)!)
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone.current //Set timezone that you want
        dateFormatter.locale = NSLocale.current
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm" //Specify your format that you want
        let strDate = dateFormatter.string(from: date)
        return strDate
    }
    
    func X_formatter(StrTimeStamp:String) -> Double{
        let date = Date(timeIntervalSince1970: Double(StrTimeStamp) as! TimeInterval)
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone.current //Set timezone that you want
        dateFormatter.locale = NSLocale.current
        dateFormatter.dateFormat = "dd" //Specify your format that you want
        let strDate = dateFormatter.string(from: date)
        return Double(strDate)!
    }
}
