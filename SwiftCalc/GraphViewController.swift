//
//  CalculatorGraphViewController.swift
//  SwiftCalc
//
//  Created by Matthew Fremont on 1/17/16.
//  Copyright © 2016 Matthew Fremont. All rights reserved.
//

import UIKit

class GraphViewController: UIViewController {

    @IBOutlet weak var graphView: GraphView!
    
    var dataSource: ((Double) -> Double?)?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if dataSource != nil {
            graphView.dataSource = dataSource
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
