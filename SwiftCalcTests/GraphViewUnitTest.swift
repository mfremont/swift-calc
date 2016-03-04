//
//  GraphViewUnitTest.swift
//  SwiftCalc
//
//  Created by Matthew Fremont on 2/26/16.
//  Copyright © 2016 Matthew Fremont. All rights reserved.
//

import XCTest
import Nimble

@testable import SwiftCalc

class GraphViewUnitTest: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testLinearAxisPositiveScale() {
        // Given the X axis in an upper left origin view coordinate system
        let axis = GraphView.LinearAxis(scale: 64.0, offset: 100.0)
        
        // Then the 0 coordinate in the model plane is the offset
        expect(axis.viewCoordinate(0.0)) == axis.offset
        
        // and a negative model value has a view coordinate > offset
        expect(axis.viewCoordinate(-2.0)) == axis.offset - CGFloat(128.0)
        
        // and a positive model value has a view coordinate > offset
        expect(axis.viewCoordinate(2.0)) == axis.offset + CGFloat(128.0)
        
        // and the model and view transforms are inverses for positive model values
        let v0 = 3.1
        expect(axis.modelCoordinate(axis.viewCoordinate(v0))).to(beCloseTo(v0, within: 1e-10))
        
        // and the model and view transforms are inverses for negative model values
        let v1 = -1.1
        expect(axis.modelCoordinate(axis.viewCoordinate(v1))).to(beCloseTo(v1, within: 1e-10))
    }
    
    func testLinearAxisNegativeScale() {
        // Given the Y axis in an upper left origin view coordinate system
        let axis = GraphView.LinearAxis(scale: -64.0, offset: 220.0)
        
        // Then the 0 coordinate in the model plane is the offset
        expect(axis.viewCoordinate(0.0)) == axis.offset
        
        // and a negative model value has a view coordinate < offset
        expect(axis.viewCoordinate(-2.0)) == axis.offset + CGFloat(128.0)
        
        // and a positive model value has a view coordinate > offset
        expect(axis.viewCoordinate(2.0)) == axis.offset - CGFloat(128.0)
        
        // and the model and view transforms are inverses for positive model values
        let v0 = 3.1
        expect(axis.modelCoordinate(axis.viewCoordinate(v0))).to(beCloseTo(v0, within: 1e-10))
        
        // and the model and view transforms are inverses for negative model values
        let v1 = -1.1
        expect(axis.modelCoordinate(axis.viewCoordinate(v1))).to(beCloseTo(v1, within: 1e-10))
    }
    
    func testLinearAxisPositiveScaleSymmetricUnitTicks() {
        // Given the X axis with a scale of 64.0 centered in the view width of 320 points
        let viewWidth = CGFloat(320.0)
        let scale = CGFloat(64.0)
        let axis = GraphView.LinearAxis(scale: scale, offset: viewWidth/2)

        // When ticks are generated with unit spacing
        let ticks = axis.ticks((0.0, viewWidth), minSpacing: scale)
        
        // Then five ticks are generated symmetric about the axis center
        expect(ticks) == [ -2.0, -1.0, 0.0, 1.0, 2.0 ]
    }
    
    func testLinerAxisPositiveScaleAssymeticUnitTicks() {
        // Given the X axis with a scale of 64.0 offset right in view width of 320 points
        let viewWidth = CGFloat(320.0)
        let scale = CGFloat(64.0)
        let axis = GraphView.LinearAxis(scale: scale, offset: 200.0)
        
        // When ticks are generated with unit spacing
        let ticks = axis.ticks((0.0, viewWidth), minSpacing: scale)
        
        // Then five ticks are generated asymmetric about the axis center
        expect(ticks) == [ -3.0, -2.0, -1.0, 0.0, 1.0 ]
    }
    
    func testLinearAxisNegativeScaleSymmetricUnitTicks() {
        // Given the Y axis with a scale of 64.0 offset down in the view height of 320 points
        let viewHeight = CGFloat(320.0)
        let scale = CGFloat(64.0)
        let axis = GraphView.LinearAxis(scale: -scale, offset: viewHeight/2)
        
        // When ticks are generated with unit spacing
        let ticks = axis.ticks((0.0, viewHeight), minSpacing: scale)
        
        // Then five ticks are generated symmetric about the axis center
        expect(ticks) == [ -2.0, -1.0, 0.0, 1.0, 2.0 ]
    }
    
    func testLinerAxisNegativeScaleAssymeticUnitTicks() {
        // Given the X axis with a scale of 64.0 offset right in view height of 568 points
        let viewHeight = CGFloat(568.0)
        let scale = CGFloat(64.0)
        let axis = GraphView.LinearAxis(scale: -scale, offset: 400.0)
        
        // When ticks are generated with unit spacing
        let ticks = axis.ticks((0.0, viewHeight), minSpacing: scale)
        
        // Then 9 ticks are generated asymmetric about the axis center
        expect(ticks) == [ -2.0, -1.0, 0.0, 1.0, 2.0, 3.0, 4.0, 5.0, 6.0 ]
    }
    
    func testSetScaleUpdatesProjection() {
        // Given the default graph view
        let view = GraphView()
        view.bounds = CGRect(x: 0, y: 0, width: 240, height: 320)
        
        // When the scale is changed to 128.0
        let newScale = CGFloat(128.0)
        view.scale = newScale
        
        // Then the projection is updated
        expect(view.projection!.scale) == newScale
    }
}
