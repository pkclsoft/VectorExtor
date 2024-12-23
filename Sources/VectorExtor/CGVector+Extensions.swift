//CoreGraphics isn't available on Linux, but there's partial support for CGPoint and some of its siblings.
//In this extension, CGVector is the most important omission from Linux, so I've covered a basic reimplementation.

import Foundation
#if canImport(CoreGraphics)
import CoreGraphics
#endif

public extension CGVector {
	@inline(__always)
	var normalized: CGVector {
		guard !(dx == dy && dx == 0) else { return CGVector(dx: 0, dy: 1) }
		var new = self
		new.simd = simd.normalized
		return new
	}

	@inline(__always)
	var inverted: CGVector {
		var new = self
		new.simd = new.simd.inverted
		return new
	}

	@inline(__always)
	var isNormal: Bool {
		CGPoint.zero.distance(to: self.point, is: 1.0)
	}

	@inline(__always)
	var speed: Double {
		get {
			guard self != .zero else { return 0 }
			return CGPoint.zero.distance(to: self.point)
		}
		set {
			guard self != .zero else { return }
			self = normalized * newValue
		}
	}

	/// 0 is facing right (towards 3 o'Clock). Moves CCW
	@inline(__always)
	init(fromRadian radian: CGFloat) {
		self.init(dx: cos(radian), dy: sin(radian))
	}

	/// 0 is facing right (towards 3 o'Clock). Moves CCW
	@inline(__always)
	init(fromDegree degree: CGFloat) {
		self.init(fromRadian: degree * (CGFloat.pi / 180))
	}

	@inline(__always)
	init<IntNumber: BinaryInteger>(scalar: IntNumber) {
		let value = CGFloat(scalar)
		self.init(dx: value, dy: value)
	}

	@inline(__always)
	init<FloatNumber: BinaryFloatingPoint>(scalar: FloatNumber) {
		let value = CGFloat(scalar)
		self.init(dx: value, dy: value)
	}
}

extension CGVector: @retroactive Hashable {
	public func hash(into hasher: inout Hasher) {
		hasher.combine(dx)
		hasher.combine(dy)
	}
}

#if os(Linux)
public struct CGVector {
	@inline(__always)
	public var dx: CGFloat
	@inline(__always)
	public var dy: CGFloat
}

extension CGVector {
	@inline(__always)
	public static let zero = CGVector(dx: 0, dy: 0)
	@inline(__always)
	public init(dx: Int, dy: Int) {
		self.init(dx: CGFloat(dx), dy: CGFloat(dy))
	}
	@inline(__always)
	public init(dx: Double, dy: Double) {
		self.init(dx: CGFloat(dx), dy: CGFloat(dy))
	}
}

extension CGVector: Equatable, CustomDebugStringConvertible {
	public var debugDescription: String {
		"(dx: \(dx), dy: \(dy))"
	}
}

extension CGVector: Codable {
	public init(from decoder: Decoder) throws {
		var container = try decoder.unkeyedContainer()
		self.dx = try container.decode(CGFloat.self)
		self.dy = try container.decode(CGFloat.self)
	}

	public func encode(to encoder: Encoder) throws {
		var container = encoder.unkeyedContainer()
		try container.encode(dx)
		try container.encode(dy)
	}
}
#endif
