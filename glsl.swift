#! swift
import Foundation

typealias float = Float

class vec2 {
	var x: float
	var y: float

	init() { x = 0; y = 0 }
	init(_ v: float) { x = v; y = v }
	init(_ v: vec2) { x = v.x; y = v.y }
	init(_ v: float, _ w: float) { x = v; y = w }

	func op(_ f: (float, float) -> float, _ rhs: vec2) -> vec2 { vec2(f(x, rhs.x), f(y, rhs.y)) }
	func op(_ f: (float, float) -> float, _ rhs: float) -> vec2 { op(f, vec2(rhs)) }
	func op(_ f: (float) -> float) -> vec2 { vec2(f(x), f(y)) }
}

func *(lhs: vec2, rhs: vec2) -> vec2 { lhs.op({ $0 * $1 }, rhs) }
func *(lhs: vec2, rhs: float) -> vec2 { lhs.op({ $0 * $1 }, rhs) }
func +(lhs: vec2, rhs: vec2) -> vec2 { lhs.op({ $0 + $1 }, rhs) }
func +(lhs: vec2, rhs: float) -> vec2 { lhs.op({ $0 + $1 }, rhs) }
func -(lhs: vec2, rhs: vec2) -> vec2 { lhs.op({ $0 - $1 }, rhs) }
func -(lhs: vec2, rhs: float) -> vec2 { lhs.op({ $0 - $1 }, rhs) }

func fract(_ v: float) -> float { v.truncatingRemainder(dividingBy: 1) }

func fract(_ v: vec2) -> vec2 { v.op(fract) }

func sin(_ v: vec2) -> vec2 { v.op(sin) }

func floor(_ v: vec2 ) -> vec2 { v.op(floor) }

func print(_ v: vec2) { print("[", v.x, ",", v.y, "]") }

var i = vec2(5,17)

print(fract(sin(vec2(2983.239849232, 9823.219834983) * vec2(i) + vec2(272.123, 983.982)) * 9283.943498) - 0.5)
