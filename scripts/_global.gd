extends Node

const SCR = Vector2(480, 320)
const HALF_SCR = Vector2(240, 160)

func s2z(input : float, sub : float) -> float: return max(0.0, input - sub)
# subtract to zero
