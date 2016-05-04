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
       
    // MARK: - Gestures
    
    /// Interprets a pinch gesture as a change in the graph scale
    public func pinch(gesture: UIPinchGestureRecognizer) {
        if gesture.state == .Changed || gesture.state == .Ended {
            // rescale graph by gesture
            graphView.scale *= gesture.scale
            // reset scale so that changes are a factor of current scale
            gesture.scale = 1
        }
    }
    
    /// Interprets a pan gesture as a change in the graph origin
    public func pan(gesture: UIPanGestureRecognizer) {
        if gesture.state == .Changed || gesture.state == .Ended {
            graphView.translateGraphOrigin(gesture.translationInView(graphView))
            // reset the translation so that future changes are incremental
            gesture.setTranslation(CGPointZero, inView: graphView)
        }
    }
    
    /// Interprets a double-tap gesture as a new position for the graph origin
    public func tapToSetOrigin(gesture: UITapGestureRecognizer) {
        if gesture.state == .Ended {
            graphView.origin = gesture.locationInView(graphView)
        }
    }
    
    private func setupGestureRecognizers() {
        graphView.addGestureRecognizer(UIPinchGestureRecognizer(target: self, action: #selector(GraphViewController.pinch(_:))))
        graphView.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(GraphViewController.pan(_:))))
        let doubleTap = UITapGestureRecognizer(target: self, action: #selector(GraphViewController.tapToSetOrigin(_:)))
        doubleTap.numberOfTapsRequired = 2
        graphView.addGestureRecognizer(doubleTap)
    }
}
