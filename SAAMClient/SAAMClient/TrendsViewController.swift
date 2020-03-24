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
    var buttons:[UIButton] = []
    var buttonmap: [String:String] = [:]
    var FormatTime:String?
    var assessments:[String] = []
    var Questions:[String:[String:String]] = [:] //[Assessment_timestamp:[Question_id:Answer]]
    /// <#Description#>
    override func viewDidLoad() {
        super.viewDidLoad()
        self.chart_array = [self.G1, self.G2, self.G3, self.G4, self.G5, self.G6, self.G7]
        self.String_dic = [self.G1:"SAAM Pain Score Line Chart", self.G2:"SAAM Tiredness Score Line Chart", self.G3:"SAAM Nausea Score Line Chart", self.G4:"SAAM Appetite Score Line Chart", self.G5:"SAAM Shortness of Breadth Score Line Chart", self.G6:"SAAM Depression of Breadth Score Line Chart", self.G7:"SAAM Anxiety Score Line Chart"]
        for chart in chart_array{
            set_chart(chart: chart)
            setData(chart: chart, count: 4, Label: self.String_dic[chart]!)
        }
    }
    
//*******************____________*************************
    var xx1 = [Double]()
    var yy1 = [Double]()
    // count is the number of answer of that question!
    // the default is 4 answers
    // we just need to change the input of ChartDataEntry(x: xx1[i], y:yy1[i]) now
    func setData(chart:LineChartView, count : Int, Label:String) {
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
        let set1 = LineChartDataSet(entries: values, label: Label)
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
        chart.data = data
    }

    func set_chart(chart:LineChartView){
        chart.backgroundColor = .systemBlue
        chart.rightAxis.enabled = false
        chart.leftAxis.labelFont = .boldSystemFont(ofSize: 12)
        chart.leftAxis.setLabelCount(6, force: false) // how many labels we present in y axis
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
        let date = Date(timeIntervalSince1970: Double(StrTimeStamp) as! TimeInterval)
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone.current //Set timezone that you want
        dateFormatter.locale = NSLocale.current
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm" //Specify your format that you want
        let strDate = dateFormatter.string(from: date)
        return strDate
    }
}
