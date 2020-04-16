//
//  File.swift
//  
//
//  Created by Michael Redig on 4/14/20.
//
#if os(macOS) || os(watchOS) || os(iOS) || os(tvOS)
import CoreGraphics

@available(OSX 10.13, iOS 11.0, tvOS 11.0, watchOS 4.0, *)
public extension CGPath {
	enum PathElement: Equatable {
		case moveTo(point: CGPoint)
		case addLineTo(point: CGPoint)
		case addQuadCurveTo(point: CGPoint, controlPoint: CGPoint)
		case addCurveTo(point: CGPoint, controlPoint1: CGPoint, controlPoint2: CGPoint)
		case close
	}

	class PathSection {
		public let element: PathElement
		var next: PathSection?
		var previous: PathSection?

		var endPoint: CGPoint? {
			switch element {
			case .addLineTo(point: let point):
				return point
			case .addCurveTo(point: let point, controlPoint1: _, controlPoint2: _):
				return point
			case .addQuadCurveTo(point: let point, controlPoint: _):
				return point
			case .moveTo(point: let point):
				return point
			default:
				return nil
			}
		}

		init(element: CGPath.PathElement, next: CGPath.PathSection? = nil, previous: CGPath.PathSection? = nil) {
			self.element = element
			self.next = next
			self.previous = previous
		}
	}

	var elements: [PathElement] {
		var store = [PathElement]()
		applyWithBlock { elementsPointer in
			let element = elementsPointer[0]
			switch element.type {
			case .moveToPoint:
				let point = element.points[0]
				store.append(.moveTo(point: point))
			case .addLineToPoint:
				let point = element.points[0]
				store.append(.addLineTo(point: point))
			case .addQuadCurveToPoint:
				let point = element.points[1]
				let control = element.points[0]
				store.append(.addQuadCurveTo(point: point, controlPoint: control))
			case .addCurveToPoint:
				let point = element.points[2]
				let control1 = element.points[0]
				let control2 = element.points[1]
				store.append(.addCurveTo(point: point, controlPoint1: control1, controlPoint2: control2))
			case .closeSubpath:
				store.append(.close)
			@unknown default:
				print("Unknown path element type: \(element.type) \(element.type.rawValue)")
			}
		}
		return store
	}

	var sections: [PathSection] {
		var store = [PathSection]()
		var previous: PathSection?
		for element in elements {
			let newSection = PathSection(element: element)
			newSection.previous = previous
			previous?.next = newSection
			previous = newSection
			store.append(newSection)
		}
		return store
	}

	var length: CGFloat { sections.length }

	var svgString: String {
		toSVGString()
	}

	private func toSVGString() -> String {
		let components = elements

		return components.reduce("") {
			switch $1 {
			case .moveTo(point: let point):
				return $0 + "M\(point.x),\(point.y) "
			case .addLineTo(point: let point):
				return $0 + "L\(point.x),\(point.y) "
			case .addQuadCurveTo(point: let point, controlPoint: let control):
				return $0 + "Q\(control.x),\(control.y) \(point.x),\(point.y) "
			case .addCurveTo(point: let point, controlPoint1: let control1, controlPoint2: let control2):
				return $0 + "C\(control1.x),\(control1.y) \(control2.x),\(control2.y) \(point.x),\(point.y) "
			case .close:
				return $0 + "z "
			}
		}
	}
}

@available(OSX 10.13, iOS 11.0, tvOS 11.0, watchOS 4.0, *)
extension CGPath.PathSection {

	/// used to calculate curve lengths
	static public var curveResolution = 100

	public var length: CGFloat {
		calculateLength()
	}

	/// Breaks each curve into `CGPath.PathSection.curveResolution` sections of straight lines and tallies up the total length
	private func calculateLength() -> CGFloat {
		guard let start = previous?.endPoint else { return 0 }
		switch element {
		case .addQuadCurveTo, .addCurveTo:
			let iterationSection = 1.0 / CGFloat(CGPath.PathSection.curveResolution)
			let length: CGFloat = (0..<CGPath.PathSection.curveResolution).reduce(0) {
				calculateCurveLengthForSpan(previousValue: $0, iterationStep: $1, iterationSection: iterationSection)
			}
			return length
		case .addLineTo(point: let end):
			return start.distance(to: end)
		default:
			return 0
		}
	}

	/// Breaks this curve into a `1 / CGPath.PathSection.curveResolution` section of the total curve and returns the length of a straight line between each point
	private func calculateCurveLengthForSpan(previousValue: CGFloat, iterationStep: Int, iterationSection: CGFloat) -> CGFloat {
		let iStart = CGFloat(iterationStep) * iterationSection
		let iEnd = iStart + iterationSection

		guard let pointStart = pointAlongCurve(at: iStart) else { return 0 }
		guard let pointEnd = pointAlongCurve(at: iEnd) else { return 0 }

		return previousValue + pointStart.distance(to: pointEnd)
	}

	/// finds the point at `t` progress along the curve. note that progress is NOT linear! `0.5` SHOULD result in halfway
	/// through the curve, but it's very unlikely that `0.25` will be a quarter of the way through the curve. Whether it's
	/// less than a quarter or more depends on whether the first control point is closer or further from the starting point.
	public func pointAlongCurve(at t: CGFloat) -> CGPoint? {
		guard let start = previous?.endPoint else { return nil }
		switch element {
		case .addCurveTo(point: let end, controlPoint1: let control1, controlPoint2: let control2):
			return cubicBezierPoint(t: t, start: start, control1: control1, control2: control2, end: end)
		case .addLineTo(point: let end):
			return linearBezierPoint(t: t, start: start, end: end)
		case .addQuadCurveTo(point: let end, controlPoint: let control):
			return quadBezierPoint(t: t, start: start, control: control, end: end)
		case .moveTo(point: _), .close:
			return nil
		}
	}

	// 2 dimensional linear calc
	private func linearBezierPoint(t: CGFloat, start: CGPoint, end: CGPoint) -> CGPoint {
		start.interpolation(to: end, location: t, clipped: true)
	}

	// 2 dimensional cubic bezier calc
	private func cubicBezierPoint(t: CGFloat, start: CGPoint, control1: CGPoint, control2: CGPoint, end: CGPoint) -> CGPoint {
		let x = cubicBeizer1d(t: t, start: start.x, control1: control1.x, control2: control2.x, end: end.x)
		let y = cubicBeizer1d(t: t, start: start.y, control1: control1.y, control2: control2.y, end: end.y)
		return CGPoint(x: x, y: y)
	}

	// 2 dimensional quad bezier calc
	private func quadBezierPoint(t: CGFloat, start: CGPoint, control: CGPoint, end: CGPoint) -> CGPoint {
		let x = quadBeizer1d(t: t, start: start.x, control: control.x, end: end.x)
		let y = quadBeizer1d(t: t, start: start.y, control: control.y, end: end.y)
		return CGPoint(x: x, y: y)
	}

	/// 1 dimensional cubic bezier calculation
	private func cubicBeizer1d(t: CGFloat, start: CGFloat, control1: CGFloat, control2: CGFloat, end: CGFloat) -> CGFloat {
		let tInvert = 1.0 - t
		let tInvertSquared = tInvert * tInvert
		let tInvertCubed = tInvert * tInvert * tInvert
		let tSquared = t * t
		let tCubed = t * t * t

		return start * tInvertCubed
			+ 3.0 * control1 * tInvertSquared * t
			+ 3.0 * control2 * tInvert * tSquared
			+ end * tCubed
	}
	/// 1 dimensional quad bezier calculation
	private func quadBeizer1d(t: CGFloat, start: CGFloat, control: CGFloat, end: CGFloat) -> CGFloat {
		let tInvert = 1.0 - t
		let tInvertSquared = tInvert * tInvert
		let tSquared = t * t

		return start * tInvertSquared
			+ 2.0 * control * tInvert * t
			+ end * tSquared
	}
}

@available(OSX 10.13, iOS 11.0, tvOS 11.0, watchOS 4.0, *)
extension Array where Element == CGPath.PathSection {
	public var length: CGFloat {
		reduce(0) { $0 + $1.length }
	}
}

#endif
