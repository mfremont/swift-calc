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
     
     TODO: escalate to non-nested struct?
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
         Calculates evenly spaced ticks across the view interval. The view interval is usually
         defined by its bounds: for example, the view interval for the X axis is
         `(bounds.x, bounds.x + bounds.width)`. In order for the tick labels to not overlap,
         expecially on the X axis, `minSpacing` needs to be scaled relative to the font metrics
         and the visible domain of the graph. For tick values that can be displayed with three
         or fewer  digits, a reasonable hueristic is `minSpacing = 2.5 * font.lineHeight`.
         
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
            let tick0 = ceil(domainMin / increment) * increment
            return Array(tick0.stride(to: domainMax, by: increment))
        }
        
        /**
         Calculates the tick increment on the domain value scale with spacing in the view >= 
         the specified minimum spacing.
         
         - parameter minSpacing: the minimum spacing between ticks, measured in points
         - returns: the tick incement on the domain value scale
         
         TODO: simpler and more easily testable algorithm?
         */
        private func tickIncrement(minSpacing: CGFloat) -> Double {
            let increment = abs(Double(minSpacing / scale))
            if increment <= 0.25 {
                return 0.25
            } else if increment <= 0.5 {
                return 0.5
            } else if increment <= 1.0 {
                return 1.0
            } else if increment <= 2.0 {
                return 2.0
            } else {
                // nearest multiple of 5
                return ceil(increment / 5.0) * 5.0
            }
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
        static func projection(withBounds bounds: CGRect, scale: CGFloat) -> GraphProjection {
            // constrain origin to fall on an integral point
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
    public var axisColor: UIColor = UIColor.grayColor()
    
    @IBInspectable
    public var axisLineWidth: CGFloat = Default.axisLineWidth
    
    override public var bounds: CGRect {
        didSet {
             if let oldProjection = projection {
                let oldBounds = oldValue
                let dx = oldProjection.origin.x - CGRectGetMidX(oldBounds)
                let dy = oldProjection.origin.y - CGRectGetMidY(oldBounds)
                // preserve offset of origin from bounds center
                let newOrigin = CGPoint(x: CGRectGetMidX(bounds) + dx, y: CGRectGetMidY(bounds) + dy)
                origin = newOrigin
            } else {
                // calculate a default origin first time bounds are set
                projection = Default.projection(withBounds: bounds, scale: scale)
            }
        }
    }
    
    /// the graph origin in the view coordinate system
    public var origin: CGPoint {
        get { return projection.origin }
        set { projection = GraphProjection(origin: newValue, scale: projection.scale) }
    }
    
    /**
     The ratio of graphics context points to units in the graph. For example, with the
     default scale of 64.0, a line of length 1.0 in the Cartesian plane will be drawn
     as a line 64.0 points long. The scale also determines the effective bounds of
     the Cartesian plane based on the layout width and height of the view.
     
     TODO: determine desired behavior for scale == 0
     TODO: determine desired behavior for scale < 0
     */
    @IBInspectable
    public var scale: CGFloat = Default.scale {
        didSet {
            if let previous = projection {
                projection = GraphProjection(origin: previous.origin, scale: scale)
            }
        }
    }
    
    /**
     The unary function to be plotted as `y = f(x)`. Points in the input domain where the
     function returns `nil` are plotted as discontinuities. Updates to this instance 
     variable will result in a call to `setNeedsDisplay()`.
     */
    public var dataSource: ((Double) -> Double?)! {
        didSet {
            setNeedsDisplay()
        }
    }
    
    var projection: GraphProjection! {
        didSet {
            setNeedsDisplay()
        }
    }
    
    override public func drawRect(rect: CGRect) {
        drawAxesInRect(rect)
        drawGraphInRect(rect)
    }
    
    /**
     Moves the origin of the graph in the view coordinate system by the specified change in
     the X and Y coordinates. In the default upper left origin coordinate system of UIKit,
     a negative change in `delta.y` moves the origin towards the top of the view and a
     positive change moves it towards the bottom.
     
     - parameter delta: the change to the graph origin X and Y coordinates
     */
    public func translateGraphOrigin(delta: CGPoint) {
        let newOrigin = CGPoint(x: projection.origin.x + delta.x, y:projection.origin.y + delta.y)
        projection = GraphProjection(origin: newOrigin, scale: projection.scale)
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
            let minTickSpacing = font.lineHeight * 2.5
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
     
     TODO: improve testability (?) by refactoring as rect(withSize: CGSize, horizontalAlignment: HorizontalAlignment, verticalAlignment: VerticalAlignment)
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
            // step through x interval of rect in increment ~= 1 pixel
            for x in xMin.stride(through: xMax, by: (1 / contentScaleFactor)) {
                let xVal = graph.x.modelCoordinate(x)
                let yVal = f(xVal)
                if yVal != nil && yVal!.isFinite {
                    // TODO: ignore points outside of rect?
                    let y = graph.y.viewCoordinate(yVal!)
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
            }
            
            tintColor.setStroke()
            CGContextStrokePath(context)
            
            UIGraphicsPopContext()
        }
    }
}