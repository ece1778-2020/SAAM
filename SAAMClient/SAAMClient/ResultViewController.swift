//
//  ResultViewController.swift
//  SAAMClient
//
//  Created by Xiaoyi Wang on 2020-02-28.
//  Copyright © 2020 SAAM. All rights reserved.
//

import UIKit

class ResultViewController: UIViewController {

    @IBOutlet weak var TextView: UITextView!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.TextView.backgroundColor = UIColor.white.withAlphaComponent(0.5)
        let temp = self.parent as! QuestionGenerator
        if temp.recommendations.count != 0{
            self.TextView.text = self.TextView.text + "Recommendations: \n"
            var index = 1
            for recommendation in temp.recommendations{
                self.TextView.text = self.TextView.text + "\n" + String(index)+". " + recommendation + "\n"
                index += 1
            }
        }
        // Do any additional setup after loading the view.
    }
    
    @IBAction func BacktoProfile(_ sender: Any) {
        let temp = self.parent as! QuestionGenerator
        self.view.removeFromSuperview()
        temp.BackToProfile()
    }
    
}
