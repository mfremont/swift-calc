//
//  GraphViewController.swift
//  SwiftCalc
//
//  Created by Matthew Fremont on 1/17/16.
//  Copyright © 2016 Matthew Fremont. All rights reserved.
//

import UIKit

class GraphViewController: UIViewController {

    @IBOutlet weak var graphView: GraphView! {
        didSet {
            if graphView != nil {
                graphView.dataSource = dataSource
            }
        }
    }
    
    var dataSource: ((Double) -> Double?)! {
        didSet {
            if graphView != nil {
                graphView.dataSource = dataSource
            }
        }
    }
}
