//
//  SummaryPlotViewController.swift
//  SAAMClient
//
//  Created by AdamLi on 2020/3/17.
//  Copyright © 2020 SAAM. All rights reserved.
//
// I don't add the mainboard yet, this is just the code itself
import UIKit
import Charts
import TinyConstraints

class SummaryPlotViewController: UIViewController, ChartViewDelegate{

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
        chartView.chartDescription?.text = "Y: Test Score  X: Day"
        chartView.legend.enabled = false
        //chartView.accessibilityLabel = "ddf"
        chartView.animate(xAxisDuration: 1) //time effect
        
        
        return chartView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(lineChartView)
        lineChartView.centerInSuperview()
        lineChartView.width(to: view)
        lineChartView.heightToWidth(of: view)
        setData()
        // Do any additional setup after loading the view.
    }
    func chartValueSelected(_ chartView: ChartViewBase, entry: ChartDataEntry, highlight: Highlight) {
        print(entry)
    }
    func setData() {
        let set1 = LineChartDataSet(entries: yValues, label: "Subscription")
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
    let yValues: [ChartDataEntry] = [
        ChartDataEntry(x: 0.0, y: 10.0),
        ChartDataEntry(x: 1.0, y: 5.0),
        ChartDataEntry(x: 2.0, y: 7.0),
        ChartDataEntry(x: 3.0, y: 5.0),
        ChartDataEntry(x: 4.0, y: 10.0),
        ChartDataEntry(x: 5.0, y: 6.0),
        ChartDataEntry(x: 6.0, y: 10.0),
        ChartDataEntry(x: 7.0, y: 5.0),
        ChartDataEntry(x: 8.0, y: 7.0),
        ChartDataEntry(x: 9.0, y: 5.0),
        ChartDataEntry(x: 10.0, y: 10.0),
        ChartDataEntry(x: 11.0, y: 6.0)
        
    ]


}
