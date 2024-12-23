import Foundation
import simd

public extension SIMD2 where Scalar == Double {
	// MARK: - Distance Convenience
	/**
	 Calculates distance to another `Self`. 
	 Precise variants are accurate to a few units in the last place (ULPs). Faster variants are available, but may dip as
	 low as 11 bits of accuracy for Float values and 22 for Double values. The default variant is determined by a compiler
	 flag, defaulting to the precise variant. However, if you pass `-ffast-math` as a compiler flag, the default variant 
	 will be faster.
	 */
	@inline(__always)
	func distance(to other: Self) -> Scalar {
		simd.distance(self, other)
	}

	/**
	 Calculates distance to another `Self`.
	 Precise variants are accurate to a few units in the last place (ULPs). Faster variants are available, but may dip as
	 low as 11 bits of accuracy for Float values and 22 for Double values. The default variant is determined by a compiler
	 flag, defaulting to the precise variant. However, if you pass `-ffast-math` as a compiler flag, the default variant
	 will be faster.
	 */
	@inline(__always)
	func distanceFast(to other: Self) -> Scalar {
		simd_fast_distance(self, other)
	}

	/**
	 Calculates distance to another `Self`.
	 Precise variants are accurate to a few units in the last place (ULPs). Faster variants are available, but may dip as
	 low as 11 bits of accuracy for Float values and 22 for Double values. The default variant is determined by a compiler
	 flag, defaulting to the precise variant. However, if you pass `-ffast-math` as a compiler flag, the default variant
	 will be faster.
	 */
	@inline(__always)
	func distancePrecise(to other: Self) -> Scalar {
		simd_precise_distance(self, other)
	}

	/**
	 Calculates squared distance to another `Self`.
	 */
	@inline(__always)
	func distanceSquared(to other: Self) -> Scalar {
		simd.distance_squared(self, other)
	}

	/**
	 Determines if distance to another `Self` is less than or equal to `value`
	 */
	@inline(__always)
	func distance(to other: Self, isWithin value: Scalar) -> Bool {
		distanceSquared(to: other) <= value * value
	}

	/**
	 Determines if distance to another `Self` is exactly (with a little slop) a given `value`.

	 Since float values are sloppy, it's highly likely two values that can be considered equal will not be EXACTLY equal. Adjust the `slop` to your liking or set to `0` to disable.
	 */
	@inline(__always)
	func distance(to other: Self, is value: Scalar, slop: Scalar = 0.000001) -> Bool {
		let distanceIsh = distanceSquared(to: other)
		let valueIsh = value * value
		return abs(valueIsh - distanceIsh) <= slop
	}

	// MARK: - Length Convenience
	/**
	 Calculates the length of the current value from the origin.
	 Precise variants are accurate to a few units in the last place (ULPs). Faster variants are available, but may dip as
	 low as 11 bits of accuracy for Float values and 22 for Double values. The default variant is determined by a compiler
	 flag, defaulting to the precise variant. However, if you pass `-ffast-math` as a compiler flag, the default variant
	 will be faster.
	 */
	@inline(__always)
	var length: Scalar {
		simd.length(self)
	}

	/**
	 Calculates the length of the current value from the origin.
	 Precise variants are accurate to a few units in the last place (ULPs). Faster variants are available, but may dip as
	 low as 11 bits of accuracy for Float values and 22 for Double values. The default variant is determined by a compiler
	 flag, defaulting to the precise variant. However, if you pass `-ffast-math` as a compiler flag, the default variant
	 will be faster.
	 */
	@inline(__always)
	var lengthFast: Scalar {
		simd_fast_length(self)
	}

	/**
	 Calculates the length of the current value from the origin.
	 Precise variants are accurate to a few units in the last place (ULPs). Faster variants are available, but may dip as
	 low as 11 bits of accuracy for Float values and 22 for Double values. The default variant is determined by a compiler
	 flag, defaulting to the precise variant. However, if you pass `-ffast-math` as a compiler flag, the default variant
	 will be faster.
	 */
	@inline(__always)
	var lengthPrecise: Scalar {
		simd_precise_length(self)
	}

	/// Calculates the squared length of the current value from the origin.
	@inline(__always)
	var lengthSquared: Scalar {
		simd_length_squared(self)
	}

	/**
	 Determines if the length from the origin is less than or equal to `value`
	 */
	@inline(__always)
	func lengthIsWithin(_ value: Scalar) -> Bool {
		lengthSquared <= value * value
	}

	/**
	 Determines if length to the origin is exactly (with a little slop) a given `value`.

	 Since float values are sloppy, it's highly likely two values that can be considered equal will not be EXACTLY equal. Adjust the `slop` to your liking or set to `0` to disable.
	 */
	@inline(__always)
	func lengthIs(_ value: Scalar, slop: Scalar = 0.000001) -> Bool {
		let lengthIsh = lengthSquared
		let valueIsh = value * value
		return abs(valueIsh - lengthIsh) <= slop
	}

	// MARK: - Vectorization
	/// Caclulates the vector facing another point.
	@inline(__always)
	func vector(facing other: Self, normalized: Bool = true) -> Self {
		let direction = inverted + other
		return normalized ? direction.normalizedFast : direction
	}

	// MARK: - Normalization Convenience
	/**
	 Calculates the normalized (length of 1) vector of self
	 Precise variants are accurate to a few units in the last place (ULPs). Faster variants are available, but may dip as
	 low as 11 bits of accuracy for Float values and 22 for Double values. The default variant is determined by a compiler
	 flag, defaulting to the precise variant. However, if you pass `-ffast-math` as a compiler flag, the default variant
	 will be faster.
	 */
	@inline(__always)
	var normalized: Self {
		simd_normalize(self)
	}

	/**
	 Calculates the normalized (length of 1) vector of self and sets to self
	 Precise variants are accurate to a few units in the last place (ULPs). Faster variants are available, but may dip as
	 low as 11 bits of accuracy for Float values and 22 for Double values. The default variant is determined by a compiler
	 flag, defaulting to the precise variant. However, if you pass `-ffast-math` as a compiler flag, the default variant
	 will be faster.
	 */
	@inline(__always)
	mutating func normalize() {
		self = normalized
	}

	/**
	 Calculates the normalized (length of 1) vector of self
	 Precise variants are accurate to a few units in the last place (ULPs). Faster variants are available, but may dip as
	 low as 11 bits of accuracy for Float values and 22 for Double values. The default variant is determined by a compiler
	 flag, defaulting to the precise variant. However, if you pass `-ffast-math` as a compiler flag, the default variant
	 will be faster.
	 */
	@inline(__always)
	var normalizedFast: Self {
		simd_fast_normalize(self)
	}

	/**
	 Calculates the normalized (length of 1) vector of self and sets to self
	 Precise variants are accurate to a few units in the last place (ULPs). Faster variants are available, but may dip as
	 low as 11 bits of accuracy for Float values and 22 for Double values. The default variant is determined by a compiler
	 flag, defaulting to the precise variant. However, if you pass `-ffast-math` as a compiler flag, the default variant
	 will be faster.
	 */
	@inline(__always)
	mutating func normalizeFast() {
		self = normalizedFast
	}

	/**
	 Calculates the normalized (length of 1) vector of self
	 Precise variants are accurate to a few units in the last place (ULPs). Faster variants are available, but may dip as
	 low as 11 bits of accuracy for Float values and 22 for Double values. The default variant is determined by a compiler
	 flag, defaulting to the precise variant. However, if you pass `-ffast-math` as a compiler flag, the default variant
	 will be faster.
	 */
	@inline(__always)
	var normalizedPrecise: Self {
		simd_precise_normalize(self)
	}

	/**
	 Calculates the normalized (length of 1) vector of self and sets to self
	 Precise variants are accurate to a few units in the last place (ULPs). Faster variants are available, but may dip as
	 low as 11 bits of accuracy for Float values and 22 for Double values. The default variant is determined by a compiler
	 flag, defaulting to the precise variant. However, if you pass `-ffast-math` as a compiler flag, the default variant
	 will be faster.
	 */
	@inline(__always)
	mutating func normalizePrecise() {
		self = normalizedPrecise
	}

	// MARK: - linear interpolation convenience
	/// Performs linear interpolation between two points, weighted by location and sets the result as the current value.
	@inline(__always)
	mutating func mix(with other: Self, at tValue: Scalar, clamped: Bool = true) {
		let location = clamped ? Swift.max(0, Swift.min(1, tValue)) : tValue
		self = simd.mix(self, other, t: location)
	}

	/// Performs linear interpolation between two points, weighted by location.
	@inline(__always)
	func mixed(with other: Self, at tValue: Scalar, clamped: Bool = true) -> Self {
		var new = self
		new.mix(with: other, at: tValue, clamped: clamped)
		return new
	}

	// MARK: - common math conveniences
	@available(macOS 12.0, iOS 15.0, tvOS 15.0, *)
	@inline(__always)
	var cubeRoot: Self {
		simd.cbrt(self)
	}

	@inline(__always)
	var ceil: Self {
		simd.ceil(self)
	}

	@inline(__always)
	var floor: Self {
		simd.floor(self)
	}

	@available(macOS 12.0, iOS 15.0, tvOS 15.0, *)
	@inline(__always)
	var rounded: Self {
		simd.round(self)
	}

	@inline(__always)
	var inverted: Self {
		var new = self
		new *= -1
		return new
	}

	/// Clamps all values to be within or equal to the range bounds.
	@inline(__always)
	func clamped(to range: ClosedRange<Scalar>) -> Self {
		simd.clamp(self, min: range.lowerBound, max: range.upperBound)
	}
}
