//
//  simd+Extensions.swift
//  ARWindow
//
//  Created by Oliver Dew on 18/05/2018.
//  Copyright © 2018 saltpig. All rights reserved.
//

import simd
import CoreGraphics

extension CGPoint {
	var toFloat2: float2 {
		return float2(Float(x), Float(y))
	}
	
	static func + (lhs: CGPoint, rhs: CGPoint) -> CGPoint {
		return CGPoint(x: lhs.x + rhs.x, y: lhs.y + rhs.y)
	}
	
	static func * (lhs: CGPoint, scalar: CGFloat) -> CGPoint {
		return CGPoint(x: lhs.x * scalar, y: lhs.y * scalar)
	}
}

extension CGSize {
	var toFloat2: float2 {
		return float2(Float(width), Float(height))
	}
}

extension Float {
	func clamp(lower: Float, upper: Float) -> Float {
		return max(lower, min(upper, self))
	}
}

extension float2 {
	var cgSize: CGSize {
		return CGSize(width: CGFloat(x), height: CGFloat(y))
	}
	
	var cgPoint: CGPoint {
		return CGPoint(x: CGFloat(x), y: CGFloat(y))
	}
}

extension float3 {
	var xz: float2 {
		return float2(x, z)
	}
}

extension float4 {
	var xyz: float3 {
		get {
			return float3(x, y, z)
		}
		set {
			self = float4(newValue, w)
		}
	}
	
	init(_ vec3: float3, _ w: Float) {
		self = float4(vec3.x, vec3.y, vec3.z, w)
	}
}

extension float4x4 {
	static let identity = matrix_identity_float4x4
	
	var up: float3 {
		return self[1].xyz
	}
	
	var translation: float3 {
		get {
			return self[3].xyz
		}
		set {
			self[3].xyz = newValue
		}
	}
	
	func translating(by vec3: float3) -> float4x4 {
		var result = self
		result.translation = vec3
		return result
	}
}
