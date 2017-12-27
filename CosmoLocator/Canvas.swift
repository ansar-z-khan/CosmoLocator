//
//  Canvas.swift
//  CosmoLocator
//
//  Created by Ansar Khan on 2017-12-26.
//  Copyright © 2017 Ansar Khan. All rights reserved.
//

import Foundation
import UIKit;

class Canvas:UIImageView{
    
    var touch : UITouch!
    var lastPoint : CGPoint!
    var currentPoint : CGPoint!
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        print("Running")
       // drawLineFrom(fromPoint: CGPoint(0,0), toPoint:  CGPoint(50,50))
        let firstTouch = touches.first
        let firstTouchPos = firstTouch?.location(in: self)
        drawLineFrom(fromPoint: CGPoint(x: 0,y: 0), toPoint: CGPoint(x:(firstTouchPos?.x)! ,y: (firstTouchPos?.y)!))
    }
    
    func drawLineFrom(fromPoint: CGPoint, toPoint: CGPoint) {
        
        // 1
        var view: UIView = self
        UIGraphicsBeginImageContext(view.frame.size)
        let context = UIGraphicsGetCurrentContext()
        
        self.image?.draw(in: CGRect(x: 0, y: 0, width: view.frame.size.width, height: view.frame.size.height))
        
        
        // 2
        context?.move(to: CGPoint(x:fromPoint.x, y: fromPoint.y ))
        context?.addLine(to: CGPoint(x:toPoint.x, y: toPoint.y ))
        
        // 3
        context?.setLineCap(CGLineCap.round)
        context?.setLineWidth(5)
       // CGContextSetRGBStrokeColor(context, red, green, blue, 1.0)
        context?.setStrokeColor(red: 1, green: 0.5, blue: 0.5, alpha: 0.5)
     //   CGContextSetBlendMode(context, kCGBlendModeNormal)
        
        // 4
        //CGContextStrokePath(context)
        context?.strokePath();
        
        // 5
        self.image = UIGraphicsGetImageFromCurrentImageContext()
        //self.alpha = opacity
        UIGraphicsEndImageContext()
        
    }
    
}
