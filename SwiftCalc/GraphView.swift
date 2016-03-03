//
//  GraphView.swift
//  SwiftCalc
//
//  Created by Matthew Fremont on 1/17/16.
//  Copyright © 2016 Matthew Fremont. All rights reserved.
//

import UIKit
import Foundation

/**
 A view that plots a unary function on a Cartesian plane as `y = f(x)`. The input interval of
 the function for the drawing cycle is calculated from the current value of the `scale` and
 `bounds` properties. The result is plotted as a series of line segments, stroked using the
 current value of the `tintColor` property.
 */
@IBDesignable
public class GraphView: UIView {
    
    /**
     The linear transformation between one dimension of the Cartesian plane of the model and the corresponding
     dimension in the view coordinate system.
     */
    struct LinearAxis {
        /**
         The ratio of view points to the plane unit. A negative scale should be used for Y axis when the graphic
         context has an upper left origin (UIKit default).
         */
        let scale: CGFloat
        
        /**
         The offset in points from the view origin for 0.0 on the plane axis. For example, if the view
         `bounds.origin` is (0, 0), to center the plane origin the view, the x offset is
         `bounds.origin.x + bounds.width/2` and the y offset is `bounds.origin.y + bounds.height/2`.
         */
        let offset: CGFloat
        
        /**
         Transforms the view coordinate to its corresponding model value.
         
         - parameter viewCoordinate: the view coordinate in points
         - returns: the model value
         */
        func modelCoordinate(viewCoordinate: CGFloat) -> Double {
            return Double((viewCoordinate - offset) / scale)
        }
        
        /**
         Transforms the model coordinate into its corresponding view coordinate.
         
         - parameter modelCoordinate: the model coordinate
         - returns: the view coordinate in points
         */
        func viewCoordinate(modelCoordinate: Double) -> CGFloat {
            return scale * CGFloat(modelCoordinate) + offset
        }
        
        /**
         Calculates evenly spaced ticks across the view interval. The view interval is usually defined
         by the bounds: for example, the view interval for the X axis would b
         
         - parameters:
            - viewInterval: the minimum and maximum coordinates visible in the view along the axis
            - minSpacing: the minimum spacing between ticks measured in points
         - returns: the ticks as model coordinates
         */
        func ticks(viewInterval: (CGFloat, CGFloat), minSpacing: CGFloat) -> [Double] {
            // calculate domain min/max regardless of order specified in the viewInterval
            // or whether view coordinate system is upper left origin
            let domainInterval = [ viewInterval.0, viewInterval.1 ].map(modelCoordinate).sort()
            let domainMin = domainInterval[0]
            let domainMax = domainInterval[1]
            let increment = tickIncrement(minSpacing)
            // initial tick is smallest multiple of increment > domainMin
            var tick = ceil(domainMin / increment) * increment
            var ticks = [Double]()
            while tick < domainMax {
                ticks.append(tick)
                tick += increment
            }
            return ticks
        }
        
        /**
         Calculates the tick increment on the domain value scale with spacing in the view >= the specified minimum spacing.
         Currently returns a fixed increment of 1.0.
         
         TODO: calculate the increment so that it falls on the nearest negative power of 10, 1, 2, 5, or positive
         power of 10.
         
         - parameter minSpacing: the minimum spacing between ticks, measured in points
         - returns: the tick incement on the domain value scale
         */
        private func tickIncrement(minSpacing: CGFloat) -> Double {
            /* TODO: calculate tick increment based on scale

                - if increment at minSpacing < 1.0, adjust to nearest power of 10 that is >= increment
                - if increment at minSpacing > 1.0, adjust to 2, 5, or nearest power of 10 that is >increment
             */
            return 1.0
        }
    }
    
    enum Default {
        static let axisLineWidth = CGFloat(0.5)
        static let scale = CGFloat(64.0)
        
        /**
         Calculates a default projection that places the graph origin at the center of the bounds rectangle.
         
         - parameters:
            - bounds: the view bounds
            - scale: ratio of points in the view coordinate system to the unit value in the graph coordinate system
         */
        static func projection(bounds: CGRect, scale: CGFloat) -> GraphProjection {
            let x = bounds.origin.x + bounds.width / 2
            let y = bounds.origin.y + bounds.height / 2
            return GraphProjection(origin: CGPoint(x: x, y: y), scale: scale)
        }
    }
    
    private enum VerticalAlignment {
        /// top edge aligned at the specified vertical view coordinate
        case TopEdge(CGFloat)
        
        /// height centered at the specified vertical view coordinate
        case Center(CGFloat)
    }
    
    private enum HorizontalAlignment {
        /// width centered at the specified horizontal view coordinate
        case Center(CGFloat)
        
        /// rect right edge aligned at the specified horizontal view coordinate
        case RightEdge(CGFloat)
    }
    
    struct GraphProjection {
        let origin: CGPoint
        let scale: CGFloat
        let x: LinearAxis
        let y: LinearAxis
        
        init(origin: CGPoint, scale: CGFloat) {
            self.origin = origin
            self.scale = scale
            self.x = LinearAxis(scale: scale, offset: origin.x)
            self.y = LinearAxis(scale: -scale, offset: origin.y)
        }
    }
    
    @IBInspectable
    var axisColor: UIColor = UIColor.grayColor()
    
    @IBInspectable
    var axisLineWidth: CGFloat = Default.axisLineWidth
    
    /**
     The ratio of graphics context points to units in the graph. For example, with the
     default scale of 64.0, a line of length 1.0 in the Cartesian plane will be drawn
     as a line 64.0 points long. The scale also determines the effective bounds of
     the Cartesian plane based on the layout width and height of the view.
     */
    @IBInspectable
    var scale: CGFloat = Default.scale;
    
    /**
     The unary function to be plotted as `y = f(x)`. Points in the input domain where the
     function returns `nil` are plotted as discontinuities. Updates to this instance 
     variable will result in a call to `setNeedsDisplay()`.
     */
    var dataSource: ((Double) -> Double?)? {
        didSet {
            setNeedsDisplay()
        }
    }
    
    var projection: GraphProjection?
    
    override public func drawRect(rect: CGRect) {
        drawAxesInRect(rect)
        drawGraphInRect(rect)
     }
 
    override public func layoutSubviews() {
        super.layoutSubviews()
        if projection == nil {
            projection = Default.projection(bounds, scale: scale)
        }
    }
    
    /**
     Draws the graph axes.
     
     - parameters:
         - rect: the portion of the view's bounds that needs to be redrawn
     */
    func drawAxesInRect(rect: CGRect) {
        if let graph = projection {
            let context = UIGraphicsGetCurrentContext()!
            UIGraphicsPushContext(context)
            
            CGContextSetLineWidth(context, axisLineWidth)

            let font = UIFont.preferredFontForTextStyle(UIFontTextStyleCaption1)
            let labelTextAttributes = [ NSFontAttributeName: font, NSForegroundColorAttributeName: axisColor ]
            
            // tick metrics derived from font size
            let tickHalfLength = font.lineHeight / 2
            let minTickSpacing = font.lineHeight * 4
            let tickLabelOffset = tickHalfLength + font.lineHeight * 0.2
            
            // TODO: only draw portion of axes that intersects rect
            
            // X axis
            let y0 = graph.origin.y
            let xMin = bounds.origin.x
            let xMax = bounds.origin.x + bounds.width
            CGContextMoveToPoint(context, xMin, y0)
            CGContextAddLineToPoint(context, xMax, y0)
            
            func drawXTick(tick: Double) {
                let xTick = graph.x.viewCoordinate(tick)
                // tick mark
                CGContextMoveToPoint(context, xTick, (y0 - tickHalfLength))
                CGContextAddLineToPoint(context, xTick, (y0 + tickHalfLength))
                
                // label
                drawString("\(tick)", withAttributes: labelTextAttributes, horizontalAlignment: .Center(xTick), verticalAlignment: .TopEdge(y0 + tickLabelOffset))
            }
            
            for tick in graph.x.ticks((xMin, xMax), minSpacing: minTickSpacing) {
                if tick != 0.0 {
                    drawXTick(tick)
                }
            }
            
            // Y axis
            let x0 = graph.origin.x
            let yMin = bounds.origin.y
            let yMax = bounds.origin.y + bounds.height
            CGContextMoveToPoint(context, x0, yMin)
            CGContextAddLineToPoint(context, x0, yMax)
            
            func drawYTick(tick: Double) {
                let yTick = graph.y.viewCoordinate(tick)
                // tick mark
                CGContextMoveToPoint(context, (x0 - tickHalfLength), yTick)
                CGContextAddLineToPoint(context, (x0 + tickHalfLength), yTick)
                
                // label
                drawString("\(tick)", withAttributes: labelTextAttributes, horizontalAlignment: .RightEdge(x0 - tickLabelOffset), verticalAlignment: .Center(yTick))
            }
            
            for tick in graph.y.ticks((yMin, yMax), minSpacing: minTickSpacing) {
                if tick != 0.0 {
                    drawYTick(tick)
                }
            }
            
            axisColor.setStroke()
            CGContextStrokePath(context)
            
            UIGraphicsPopContext()
        }
    }
    
    /**
     Draws the string rectangle positioned according to the specified horizontal and vertical alignment.
     
     - parameters:
         - text: the text that needs to be positioned
         - withAttributes: the text attributes (font, color, etc)
         - horizontalAlignment: the horizontal alignment to apply for positioning the text box
         - verticalAlignment: the vertical alignment to apply for positioning the text box
     */
    private func drawString(text: String, withAttributes attributes: [String: AnyObject]?, horizontalAlignment: HorizontalAlignment, verticalAlignment: VerticalAlignment) {
        let textBox = textRect(text, withAttributes: attributes, horizontalAlignment: horizontalAlignment, verticalAlignment: verticalAlignment)
        return text.drawInRect(textBox, withAttributes: attributes)
    }
    
    /**
     Computes a text rectangle positioned according to the specified horizontal and vertical alignment.
     
     - parameters:
         - text: the text that needs to be positioned
         - withAttributes: the text attributes (font, color, etc)
         - horizontalAlignment: the horizontal alignment to apply for positioning the text box
         - verticalAlignment: the vertical alignment to apply for positioning the text box
     - returns: the positioned rectangle for drawing the text
     */
    private func textRect(text: String, withAttributes attributes: [String: AnyObject]?, horizontalAlignment: HorizontalAlignment, verticalAlignment: VerticalAlignment) -> CGRect {
        var rect = CGRect()
        rect.size = text.sizeWithAttributes(attributes)
        
        switch horizontalAlignment {
        case .Center(let xCenter):
            rect.origin.x = xCenter - rect.width / 2
            
        case .RightEdge(let xRightEdge):
            rect.origin.x = xRightEdge - rect.width
        }
        
        switch verticalAlignment {
        case .Center(let yCenter):
            rect.origin.y = yCenter - rect.height / 2
            
        case .TopEdge(let yTopEdge):
            rect.origin.y = yTopEdge
        }

        return rect
    }
    
    /**
     Draws the graph of _dataSource_ as a series of line segments. The input domain of the 
     function is the inverse projection of the interval 
     `(rect.bounds.x, rect.bounds.x + rect.width)`.
     
     - parameter rect: the portion of the view's bounds that needs to be drawn
     */
    private func drawGraphInRect(rect: CGRect) {
        if let f = dataSource, graph = projection {
            let context = UIGraphicsGetCurrentContext()!
            UIGraphicsPushContext(context)
            
            let xMin = rect.origin.x
            let xMax = rect.origin.x + rect.width
            var startNewPath = true
            var x = xMin
            while x <= xMax {
                let xVal = graph.x.modelCoordinate(x)
                // TODO handle NaN (e.g. 1/x where x = 0) as discontinuity
                // TODO handle !.isNormalNumber as discontinuity
                if let yVal = f(xVal) {
                    // TODO: ignore points outside of rect?
                    let y = graph.y.viewCoordinate(yVal)
                    if startNewPath {
                        CGContextMoveToPoint(context, x, y)
                        startNewPath = false
                    } else {
                        CGContextAddLineToPoint(context, x, y)
                    }
                } else {
                    // discontinuity in output range of function
                    startNewPath = true
                }
                x += 1.0
            }
            
            tintColor.setStroke()
            CGContextStrokePath(context)
            
            UIGraphicsPopContext()
        }
    }
}