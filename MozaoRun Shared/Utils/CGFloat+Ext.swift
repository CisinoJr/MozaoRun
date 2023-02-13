//
//  CGFloat+Ext.swift
//  MozaoRun iOS
//
//  Created by Cisino Junior on 12/02/23.
//

import CoreGraphics

public let π = CGFloat.pi

extension CGFloat {
	
	func radiansToDegree() -> CGFloat {
		return self * 180.0 / π
	}
	
	func degreesToRadians() -> CGFloat {
		return self * π / 180.0
	}
	
	static func random() -> CGFloat {
		return CGFloat(Float(arc4random()) / Float(0xFFFFFFFF))
	}
	
	static func random(min: CGFloat, max: CGFloat) -> CGFloat {
		assert(min < max)
		return CGFloat.random() * (max - min) + min
	}
}
