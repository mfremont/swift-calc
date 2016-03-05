//
//  GraphViewController.swift
//  SwiftCalc
//
//  Created by Matthew Fremont on 1/17/16.
//  Copyright © 2016 Matthew Fremont. All rights reserved.
//

import UIKit

public class GraphViewController: UIViewController {

    @IBOutlet weak var graphView: GraphView! {
        didSet {
            if graphView != nil {
                graphView.dataSource = dataSource
                setupGestureRecognizers()
            }
        }
    }
    
    public var dataSource: ((Double) -> Double?)! {
        didSet {
            if graphView != nil {
                graphView.dataSource = dataSource
            }
        }
    }
    
    // MARK: - Gesture Handlers
    
    /// Interprets a pinch gesture as a change in the graph scale
    public func pinch(gesture: UIPinchGestureRecognizer) {
        if gesture.state == .Changed || gesture.state == .Ended {
            // rescale graph by gesture
            graphView.scale *= gesture.scale
            // reset scale so that changes are a factor of current scale
            gesture.scale = 1
        }
    }
    
    private func setupGestureRecognizers() {
        graphView.addGestureRecognizer(UIPinchGestureRecognizer(target: self, action: "pinch:"))
    }
}
