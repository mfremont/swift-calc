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
}
