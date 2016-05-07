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

    func testLinearAxisTicksLargeMultipleOf5() {
        // Given the X axis with a scale of 2 centered in the view width of 320 points
        let viewWidth = CGFloat(320.0)
        let scale = CGFloat(1.0)
        let axis = GraphView.LinearAxis(scale: scale, offset: viewWidth/2)
        
        // When ticks are generated with spacing 4.0 of a unit
        let ticks = axis.ticks((0.0, viewWidth), minSpacing: scale * 48)
        
        // Then seven ticks that are large multiples of 5 are generated symmetric about the axis center
        expect(ticks) == [ -150.0, -100.0, -50.0, 0.0, 50.0, 100.0, 150.0 ]
    }
    
    func testLinearAxisTicksMultipleOf5() {
        // Given the X axis with a scale of 10 centered in the view width of 320 points
        let viewWidth = CGFloat(320.0)
        let scale = CGFloat(10.0)
        let axis = GraphView.LinearAxis(scale: scale, offset: viewWidth/2)
        
        // When ticks are generated with spacing 4.0 of a unit
        let ticks = axis.ticks((0.0, viewWidth), minSpacing: scale * 4.0)
        
        // Then seven ticks that are multiples of 5 are generated symmetric about the axis center
        expect(ticks) == [ -15.0, -10.0, -5.0, 0.0, 5.0, 10.0, 15.0 ]
    }

    func testLinearAxisTicksMultipleOf2() {
        // Given the X axis with a scale of 24.0 centered in the view width of 320 points
        let viewWidth = CGFloat(320.0)
        let scale = CGFloat(24.0)
        let axis = GraphView.LinearAxis(scale: scale, offset: viewWidth/2)
        
        // When ticks are generated with spacing 1.5 of a unit
        let ticks = axis.ticks((0.0, viewWidth), minSpacing: scale * 1.5)
        
        // Then seven ticks that are multiples of 2 are generated symmetric about the axis center
        expect(ticks) == [ -6.0, -4.0, -2.0, 0.0, 2.0, 4.0, 6.0 ]
    }
    
    func testLinearAxisTicksRoundUpUnit() {
        // Given the X axis with a scale of 128.0 centered in the view width of 320 points
        let viewWidth = CGFloat(320.0)
        let scale = CGFloat(128.0)
        let axis = GraphView.LinearAxis(scale: scale, offset: viewWidth/2)
        
        // When ticks are generated with spacing 0.75 of a unit
        let ticks = axis.ticks((0.0, viewWidth), minSpacing: scale * 0.75)
        
        // Then three unit ticks are generated symmetric about the axis center
        expect(ticks) == [ -1.0, 0.0, 1.0 ]
    }
    
    func testLinearAxisTicksRoundUpHalfUnit() {
        // Given the X axis with a scale of 128.0 centered in the view width of 320 points
        let viewWidth = CGFloat(320.0)
        let scale = CGFloat(128.0)
        let axis = GraphView.LinearAxis(scale: scale, offset: viewWidth/2)
        
        // When ticks are generated with spacing 0.3 of a unit
        let ticks = axis.ticks((0.0, viewWidth), minSpacing: scale * 0.3)
        
        // Then five half unit ticks are generated symmetric about the axis center
        expect(ticks) == [ -1.0, -0.5, 0.0, 0.5, 1.0 ]
    }

    func testLinearAxisTicksRoundUpQuarterUnit() {
        // Given the X axis with a scale of 156.0 centered in the view width of 320 points
        let viewWidth = CGFloat(320.0)
        let scale = CGFloat(156.0)
        let axis = GraphView.LinearAxis(scale: scale, offset: viewWidth/2)
        
        // When ticks are generated with spacing 0.15 of a unit
        let ticks = axis.ticks((0.0, viewWidth), minSpacing: scale * 0.15)
        
        // Then five 0.25 unit ticks are generated symmetric about the axis center
        expect(ticks) == [ -1.0, -0.75, -0.5, -0.25, 0.0, 0.25, 0.5, 0.75, 1.0 ]
    }
    
    func testLinearAxisPositiveScaleAssymeticUnitTicks() {
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
    
    func testLinearAxisNegativeScaleAssymeticUnitTicks() {
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
    
    func testTranslateGraphOrigin() {
        // Given the default graph view
        let view = GraphView()
        view.bounds = CGRect(x: 0, y: 0, width: 240, height: 320)
        let originalOrigin = view.origin
        let originalScale = view.projection.scale
        
        // When the graph origin is translated by x: 10, y: -10
        let delta = CGPoint(x: 10.0, y: -10)
        view.translateGraphOrigin(delta)
        
        // Then the new graph origin is above and to the right of the view center by 10 points
        expect(view.projection.origin.x) == originalOrigin.x + delta.x
        expect(view.projection.origin.y) == originalOrigin.y + delta.y

        // and the scale is unchanged
        expect(view.projection.scale) == originalScale
    }
    
    func testTranslateGraphOriginNoChange() {
        // Given the default graph view
        let view = GraphView()
        view.bounds = CGRect(x: 0, y: 0, width: 240, height: 320)
        let originalOrigin = view.origin
        let originalScale = view.projection.scale
        
        // When the graph origin is translated by x: 0, y: 0
        let delta = CGPoint(x: 0, y: 0)
        view.translateGraphOrigin(delta)
        
        // Then the graph origin is unchanged
        expect(view.projection.origin) == originalOrigin
        
        // and the scale is unchanged
        expect(view.projection.scale) == originalScale
    }
    
    func testSetOrigin() {
       // Given the default graph view
        let view = GraphView()
        view.bounds = CGRect(x: 0, y: 0, width: 240, height: 320)
        let originalScale = view.projection.scale

        // When the origin is set to a new point
        let newOrigin = CGPoint(x: 10, y: 10)
        view.origin = newOrigin
        
        // Then the graph origin is updated
        expect(view.projection.origin) == newOrigin
        
        // and the scale is unchanges
        expect(view.projection.scale) == originalScale
    }
    
    let orientationChangeTestCases = [
        (
            description: "portrait to landscape; iPhone 6; upper right graph origin",
            initialBounds: CGRect(x:0, y:0, width: 375, height: 603),
            initialOrigin: CGPoint(x: 375.0/2 + 120, y: 603.0/2 - 100),
            newBounds: CGRect(x:0, y:0, width: 667, height: 343),
            expectedNewOrigin: CGPoint(x: 667.0/2 + 120, y: 343.0/2 - 100)
        ),
        (
            description: "landscape to portrait; iPhone 6; upper right graph origin",
            initialBounds: CGRect(x:0, y:0, width: 667, height: 343),
            initialOrigin: CGPoint(x: 667.0/2 + 120, y: 343.0/2 - 100),
            newBounds: CGRect(x:0, y:0, width: 375, height: 603),
            expectedNewOrigin: CGPoint(x: 375.0/2 + 120, y: 603.0/2 - 100)
        ),
        (
            description: "portrait to landscape; iPhone 6; lower right graph origin",
            initialBounds: CGRect(x:0, y:0, width: 375, height: 603),
            initialOrigin: CGPoint(x: 375.0/2 + 120, y: 603.0/2 + 100),
            newBounds: CGRect(x:0, y:0, width: 667, height: 343),
            expectedNewOrigin: CGPoint(x: 667.0/2 + 120, y: 343.0/2 + 100)
        ),
        (
            description: "landscape to portrait; iPhone 6; lower right graph origin",
            initialBounds: CGRect(x:0, y:0, width: 667, height: 343),
            initialOrigin: CGPoint(x: 667.0/2 + 120, y: 343.0/2 + 100),
            newBounds: CGRect(x:0, y:0, width: 375, height: 603),
            expectedNewOrigin: CGPoint(x: 375.0/2 + 120, y: 603.0/2 + 100)
        ),
        (
            description: "portrait to landscape; iPhone 6; lower left graph origin",
            initialBounds: CGRect(x:0, y:0, width: 375, height: 603),
            initialOrigin: CGPoint(x: 375.0/2 - 75, y: 603.0/2 + 91),
            newBounds: CGRect(x:0, y:0, width: 667, height: 343),
            expectedNewOrigin: CGPoint(x: 667.0/2 - 75, y: 343.0/2 + 91)
        ),
        (
            description: "landscape to portrait; iPhone 6; lower left graph origin",
            initialBounds: CGRect(x:0, y:0, width: 667, height: 343),
            initialOrigin: CGPoint(x: 667.0/2 - 75, y: 343.0/2 + 91),
            newBounds: CGRect(x:0, y:0, width: 375, height: 603),
            expectedNewOrigin: CGPoint(x: 375.0/2 - 75 , y: 603.0/2 + 91)
        ),
        (
            description: "portrait to landscape; iPhone 6; upper left graph origin",
            initialBounds: CGRect(x:0, y:0, width: 375, height: 603),
            initialOrigin: CGPoint(x: 375.0/2 - 86, y: 603.0/2 - 17),
            newBounds: CGRect(x:0, y:0, width: 667, height: 343),
            expectedNewOrigin: CGPoint(x: 667.0/2 - 86, y: 343.0/2 - 17)
        ),
        (
            description: "landscape to portrait; iPhone 6; upper left graph origin",
            initialBounds: CGRect(x:0, y:0, width: 667, height: 343),
            initialOrigin: CGPoint(x: 667.0/2 - 86, y: 343.0/2 - 17),
            newBounds: CGRect(x:0, y:0, width: 375, height: 603),
            expectedNewOrigin: CGPoint(x: 375.0/2 - 86 , y: 603.0/2 - 17)
        ),
        (
            description: "portrait to landscape; iPhone 6+; upper right graph origin",
            initialBounds: CGRect(x:0, y:0, width: 414, height: 672),
            initialOrigin: CGPoint(x: 414.0/2 + 65, y: 672.0/2 - 22),
            newBounds: CGRect(x:0, y:0, width: 736, height: 350),
            expectedNewOrigin: CGPoint(x: 736.0/2 + 65, y: 350.0/2 - 22)
        ),
        (
            description: "landscape to portrait; iPhone 6+; upper right graph origin",
            initialBounds: CGRect(x:0, y:0, width: 736, height: 350),
            initialOrigin: CGPoint(x: 736.0/2 + 66, y: 350.0/2 - 31),
            newBounds: CGRect(x:0, y:0, width: 414, height: 672),
            expectedNewOrigin: CGPoint(x: 414.0/2 + 66, y: 672.0/2 - 31)
        ),
        (
            description: "portrait to landscape; iPhone 6+; lower right graph origin",
            initialBounds: CGRect(x:0, y:0, width: 414, height: 672),
            initialOrigin: CGPoint(x: 414.0/2 + 65, y: 672.0/2 + 11),
            newBounds: CGRect(x:0, y:0, width: 736, height: 350),
            expectedNewOrigin: CGPoint(x: 736.0/2 + 65, y: 350.0/2 + 11)
        ),
        (
            description: "landscape to portrait; iPhone 6+; lower right graph origin",
            initialBounds: CGRect(x:0, y:0, width: 736, height: 350),
            initialOrigin: CGPoint(x: 736.0/2 + 32, y: 350.0/2 + 32),
            newBounds: CGRect(x:0, y:0, width: 414, height: 672),
            expectedNewOrigin: CGPoint(x: 414.0/2 + 32, y: 672.0/2 + 32)
        ),
        (
            description: "portrait to landscape; iPhone 6+; lower left graph origin",
            initialBounds: CGRect(x:0, y:0, width: 414, height: 672),
            initialOrigin: CGPoint(x: 414.0/2 - 17, y: 672.0/2 + 102),
            newBounds: CGRect(x:0, y:0, width: 736, height: 350),
            expectedNewOrigin: CGPoint(x: 736.0/2 - 17, y: 350.0/2 + 102)
        ),
        (
            description: "landscape to portrait; iPhone 6+; lower left graph origin",
            initialBounds: CGRect(x:0, y:0, width: 736, height: 350),
            initialOrigin: CGPoint(x: 736.0/2 - 116, y: 350.0/2 + 1),
            newBounds: CGRect(x:0, y:0, width: 414, height: 672),
            expectedNewOrigin: CGPoint(x: 414.0/2 - 116, y: 672.0/2 + 1)
        ),
        (
            description: "portrait to landscape; iPhone 6+; upper left graph origin",
            initialBounds: CGRect(x:0, y:0, width: 414, height: 672),
            initialOrigin: CGPoint(x: 414.0/2 - 34, y: 672.0/2 - 57),
            newBounds: CGRect(x:0, y:0, width: 736, height: 350),
            expectedNewOrigin: CGPoint(x: 736.0/2 - 34, y: 350.0/2 - 57)
        ),
        (
            description: "landscape to portrait; iPhone 6+; upper left graph origin",
            initialBounds: CGRect(x:0, y:0, width: 736, height: 350),
            initialOrigin: CGPoint(x: 736.0/2 - 1, y: 350.0/2 - 99),
            newBounds: CGRect(x:0, y:0, width: 414, height: 672),
            expectedNewOrigin: CGPoint(x: 414.0/2 - 1, y: 672.0/2 - 99)
        ),
        (
            description: "portrait to landscape; iPhone 6; centered graph origin",
            initialBounds: CGRect(x:0, y:0, width: 375, height: 603),
            initialOrigin: CGPoint(x: 375.0/2, y: 603.0/2),
            newBounds: CGRect(x:0, y:0, width: 667, height: 343),
            expectedNewOrigin: CGPoint(x: 667.0/2, y: 343.0/2)
        ),
        (
            description: "landscape to portrait; iPhone 6; centered graph origin",
            initialBounds: CGRect(x:0, y:0, width: 667, height: 343),
            initialOrigin: CGPoint(x: 667.0/2, y: 343.0/2),
            newBounds: CGRect(x:0, y:0, width: 375, height: 603),
            expectedNewOrigin: CGPoint(x: 375.0/2, y: 603.0/2)
        ),
        (
            description: "portrait to landscape; iPhone 6+; centered graph origin",
            initialBounds: CGRect(x:0, y:0, width: 414, height: 672),
            initialOrigin: CGPoint(x: 414.0/2, y: 672.0/2),
            newBounds: CGRect(x:0, y:0, width: 736, height: 350),
            expectedNewOrigin: CGPoint(x: 736.0/2, y: 350.0/2)
        ),
        (
            description: "landscape to portrait; iPhone 6+; centered graph origin",
            initialBounds: CGRect(x:0, y:0, width: 736, height: 350),
            initialOrigin: CGPoint(x: 736.0/2, y: 350.0/2),
            newBounds: CGRect(x:0, y:0, width: 414, height: 672),
            expectedNewOrigin: CGPoint(x: 414.0/2, y: 672.0/2)
        )
        ]
    
    func testOrientationChange() {
        for testCase in orientationChangeTestCases {
            // Given the graph view in the initial orientation
            let view = GraphView()
            view.bounds = testCase.initialBounds
            
            // and the initial origin
            view.origin = testCase.initialOrigin

            // When the orientation is changed
            view.bounds = testCase.newBounds
            
            // Then the graph view origin is updated
            XCTAssertEqual(view.origin, testCase.expectedNewOrigin, testCase.description)
        }
    }
}
