//
//  GraphViewControllerUnitTest.swift
//  SwiftCalc
//
//  Created by Matthew Fremont on 3/3/16.
//  Copyright © 2016 Matthew Fremont. All rights reserved.
//

import XCTest
import Nimble

@testable import SwiftCalc

class GraphViewControllerUnitTest: XCTestCase {
    
    func testSetGraphViewUpdatesViewDataSource() {
        // Given the function to use as a data source
        func f(x: Double) -> Double? {
            return x / 2
        }
        
        // and the controller with f as its dataSource
        let controller = GraphViewController()
        controller.dataSource = f
        
        // and the GraphView instance
        let graphView = GraphView()
        
        // When the controller graphView property is set
        controller.graphView = graphView
        
        // Then the GraphView dataSource is set to f
        let v = 2.0
        expect(graphView.dataSource!(v)) == f(v)
    }
    
    func testSetGraphViewIsNilSafe() {
        // Given the controller with f as its dataSource
        func f(x: Double) -> Double? {
            return x / 2
        }
        let controller = GraphViewController()
        controller.dataSource = f
        
        // When the controller graphView property is set to nil
        controller.graphView = nil
        
        // Then the graphView property is nil and no exeception is thrown
        expect(controller.graphView).to(beNil())
    }
    
    func testSetDataSourceUpdatesView() {
        // Given the function to use as a data source
        func f(x: Double) -> Double? {
            return x * x
        }
        
        // and the controller
        let controller = GraphViewController()
        
        // and the GraphView instance associated with the controller
        let graphView = GraphView()
        controller.graphView = graphView
        
        // When the dataSource property is set
        controller.dataSource = f
        
        // Then the GraphView dataSource is set to f
        let v = 2.0
        expect(graphView.dataSource!(v)) == f(v)
    }
    
    func testSetDataSourceSafeIfGraphViewIsNotSet() {
        // Given the function to use as a data source
        func f(x: Double) -> Double? {
            return x * x
        }
        
        // and the controller
        let controller = GraphViewController()

        // When the dataSource property is set while graphView is nil
        controller.dataSource = f
        
        // Then no exception is thrown
    }
    
    func testZoomInChanged() {
        // Given the controller with a default graph view
        let controller = GraphViewController()
        let graphView = GraphView()
        controller.graphView = graphView
        let originalScale = graphView.scale
        
        // When the gesture with a zoom factor of 1.5 and .Changed state is sent to the controller
        let scaleFactor = CGFloat(1.5)
        let gesture = MockUIPinchGestureRecognizer(simulatedState: .Changed, scale: scaleFactor)
        controller.handlePinchGesture(gesture)
        
        // Then the graph scale is adjusted by the zoom factor
        expect(graphView.scale) == originalScale * scaleFactor
    }
    
    func testZoomInEnded() {
        // Given the controller with a default graph view
        let controller = GraphViewController()
        let graphView = GraphView()
        controller.graphView = graphView
        let originalScale = graphView.scale
        
        // When the gesture with a zoom factor of 1.5 and .Ended state is sent to the controller
        let scaleFactor = CGFloat(1.5)
        let gesture = MockUIPinchGestureRecognizer(simulatedState: .Ended, scale: scaleFactor)
        controller.handlePinchGesture(gesture)
        
        // Then the graph scale is adjusted by the zoom factor
        expect(graphView.scale) == originalScale * scaleFactor
    }
    
    func testZoomInBegan() {
        // Given the controller with a default graph view
        let controller = GraphViewController()
        let graphView = GraphView()
        controller.graphView = graphView
        let originalScale = graphView.scale
        
        // When the gesture with a zoom factor of 1.5 and .Began state is sent to the controller
        let scaleFactor = CGFloat(1.5)
        let gesture = MockUIPinchGestureRecognizer(simulatedState: .Began, scale: scaleFactor)
        controller.handlePinchGesture(gesture)
        
        // Then the graph scale is unchanged
        expect(graphView.scale) == originalScale
    }
    
    func testZoomInPossible() {
        // Given the controller with a default graph view
        let controller = GraphViewController()
        let graphView = GraphView()
        controller.graphView = graphView
        let originalScale = graphView.scale
        
        // When the gesture with a zoom factor of 1.5 and .Possible state is sent to the controller
        let scaleFactor = CGFloat(1.5)
        let gesture = MockUIPinchGestureRecognizer(simulatedState: .Possible, scale: scaleFactor)
        controller.handlePinchGesture(gesture)
        
        // Then the graph scale is unchanged
        expect(graphView.scale) == originalScale
    }
    
    func testZoomOutChanged() {
        // Given the controller with a default graph view
        let controller = GraphViewController()
        let graphView = GraphView()
        controller.graphView = graphView
        let originalScale = graphView.scale
        
        // When the gesture with a zoom factor of 0.5 and .Changed state is sent to the controller
        let scaleFactor = CGFloat(0.5)
        let gesture = MockUIPinchGestureRecognizer(simulatedState: .Changed, scale: scaleFactor)
        controller.handlePinchGesture(gesture)
        
        // Then the graph scale is adjusted by the zoom factor
        expect(graphView.scale) == originalScale * scaleFactor
    }
    
    func testZoomOutEnded() {
        // Given the controller with a default graph view
        let controller = GraphViewController()
        let graphView = GraphView()
        controller.graphView = graphView
        let originalScale = graphView.scale
        
        // When the gesture with a zoom factor of 0.5 and .Ended state is sent to the controller
        let scaleFactor = CGFloat(0.5)
        let gesture = MockUIPinchGestureRecognizer(simulatedState: .Ended, scale: scaleFactor)
        controller.handlePinchGesture(gesture)
        
        // Then the graph scale is adjusted by the zoom factor
        expect(graphView.scale) == originalScale * scaleFactor
    }
    
    func testZoomOutBegan() {
        // Given the controller with a default graph view
        let controller = GraphViewController()
        let graphView = GraphView()
        controller.graphView = graphView
        let originalScale = graphView.scale
        
        // When the gesture with a zoom factor of 0.5 and .Began state is sent to the controller
        let scaleFactor = CGFloat(0.5)
        let gesture = MockUIPinchGestureRecognizer(simulatedState: .Began, scale: scaleFactor)
        controller.handlePinchGesture(gesture)
        
        // Then the graph scale is unchanged
        expect(graphView.scale) == originalScale
    }
    
    func testZoomOutPossible() {
        // Given the controller with a default graph view
        let controller = GraphViewController()
        let graphView = GraphView()
        controller.graphView = graphView
        let originalScale = graphView.scale
        
        // When the gesture with a zoom factor of 0.5 and .Possible state is sent to the controller
        let scaleFactor = CGFloat(0.5)
        let gesture = MockUIPinchGestureRecognizer(simulatedState: .Possible, scale: scaleFactor)
        controller.handlePinchGesture(gesture)
        
        // Then the graph scale is unchanged
        expect(graphView.scale) == originalScale
    }
    
    private func controllerWithDefaultView() -> GraphViewController {
        let controller = GraphViewController()
        let graphView = GraphView()
        controller.graphView = graphView
        return controller
    }
}

private class MockUIPinchGestureRecognizer: UIPinchGestureRecognizer {
    let _simulatedState: UIGestureRecognizerState
    
    init(simulatedState: UIGestureRecognizerState, scale: CGFloat) {
        _simulatedState = simulatedState
        super.init(target: nil, action: "")
        self.scale = scale
    }
    
    override var state: UIGestureRecognizerState {
        return _simulatedState
    }
}

