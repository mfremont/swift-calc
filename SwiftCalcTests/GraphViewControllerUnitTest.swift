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
    
    func testSetGraphView() {
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
        
        // and the gesture recognizers are registered on the view
        let expectedRecognizers = Set([ "UIPinchGestureRecognizer", "UIPanGestureRecognizer" ])
        let actualRecognizers = Set(graphView.gestureRecognizers!.map { $0.dynamicType.description() })
        expect(actualRecognizers) == expectedRecognizers
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
        
        // Then the graphView property is nil and no exeception is thrown when the property is set
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
        controller.pinch(gesture)
        
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
        controller.pinch(gesture)
        
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
        controller.pinch(gesture)
        
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
        controller.pinch(gesture)
        
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
        controller.pinch(gesture)
        
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
        controller.pinch(gesture)
        
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
        controller.pinch(gesture)
        
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
        controller.pinch(gesture)
        
        // Then the graph scale is unchanged
        expect(graphView.scale) == originalScale
    }
  
    func testPanBegan_doesNotUpdateOrigin() {
        // Given the controller with a default graph view and the bounds
        let controller = GraphViewController()
        let graphView = GraphView()
        graphView.bounds = CGRect(x: 0, y: 0, width: 320, height: 575)
        controller.graphView = graphView
        let originalGraphOrigin = graphView.origin
        let originalGraphScale = graphView.scale
        
        // When the pan gesture with .Began state and the translation is sent to the controller
        let delta = CGPoint(x: 10, y: -10)
        let gesture = MockUIPanGestureRecognizer(simulatedState: .Began, withTranslation: delta, inView: graphView)
        controller.pan(gesture)
        
        // Then the graph origin is not translated
        expect(graphView.origin) == originalGraphOrigin
        
        // and the scale is unchanged
        expect(graphView.scale) == originalGraphScale
    }

    func testPanEnded() {
        // Given the controller with a default graph view and the bounds
        let controller = GraphViewController()
        let graphView = GraphView()
        graphView.bounds = CGRect(x: 0, y: 0, width: 320, height: 575)
        controller.graphView = graphView
        let originalGraphOrigin = graphView.origin
        let originalGraphScale = graphView.scale
        
        // When the pan gesture with .Ended state and the translation is sent to the controller
        let delta = CGPoint(x: 10, y: -10)
        let gesture = MockUIPanGestureRecognizer(simulatedState: .Ended, withTranslation: delta, inView: graphView)
        controller.pan(gesture)
        
        // Then the graph origin is translated
        expect(graphView.origin.x) == originalGraphOrigin.x + delta.x
        expect(graphView.origin.y) == originalGraphOrigin.y + delta.y
        
        // and the translation is reset
        expect(gesture.translationInView(graphView)) == CGPointZero
        
        // and the scale is unchanged
        expect(graphView.scale) == originalGraphScale
    }
    
    func testPanChanged() {
        // Given the controller with a default graph view and the bounds
        let controller = GraphViewController()
        let graphView = GraphView()
        graphView.bounds = CGRect(x: 0, y: 0, width: 320, height: 575)
        controller.graphView = graphView
        let originalGraphOrigin = graphView.origin
        let originalGraphScale = graphView.scale
        
        // When the pan gesture with .Changed state and the translation is sent to the controller
        let delta = CGPoint(x: 10, y: -10)
        let gesture = MockUIPanGestureRecognizer(simulatedState: .Changed, withTranslation: delta, inView: graphView)
        controller.pan(gesture)
        
        // Then the graph origin is translated
        expect(graphView.origin.x) == originalGraphOrigin.x + delta.x
        expect(graphView.origin.y) == originalGraphOrigin.y + delta.y

        // and the translation is reset
        expect(gesture.translationInView(graphView)) == CGPointZero

        // and the scale is unchanged
        expect(graphView.scale) == originalGraphScale
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

private class MockUIPanGestureRecognizer: UIPanGestureRecognizer {
    let _simulatedState: UIGestureRecognizerState
    var _simulatedTranslation: CGPoint
    var _viewForTranslation: UIView?
    
    init(simulatedState: UIGestureRecognizerState, withTranslation translation: CGPoint, inView view: UIView) {
        _simulatedState = simulatedState
        _simulatedTranslation = translation
        _viewForTranslation = view
        super.init(target: nil, action: "")
    }
    
    override var state: UIGestureRecognizerState {
        return _simulatedState
    }
    
    override func translationInView(view: UIView?) -> CGPoint {
        if (_viewForTranslation == nil) || (view != nil && view! == _viewForTranslation) {
            return _simulatedTranslation
        } else {
            return super.translationInView(view)
        }
    }
    
    override func setTranslation(translation: CGPoint, inView view: UIView?) {
        _simulatedTranslation = translation
        _viewForTranslation = view
    }
}
