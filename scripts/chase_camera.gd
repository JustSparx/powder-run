extends Camera3D
## Smoothed third-person camera that sits behind and above its target.

@export var target: Node3D
@export var distance := 7.0
@export var height := 3.0
@export var smoothing := 6.0


func _physics_process(delta: float) -> void:
	if target == null:
		return
	var desired := target.global_position + target.global_basis.z * distance + Vector3.UP * height
	global_position = global_position.lerp(desired, 1.0 - exp(-smoothing * delta))
	look_at(target.global_position + Vector3.UP, Vector3.UP)
