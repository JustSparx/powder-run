extends CharacterBody3D
## Placeholder snowboarder. Gravity pulls it down the slope; carving rotates
## the board and bleeds sideways velocity into the new heading, so turning
## hard (or braking) scrubs speed the way skidding does.

@export var gravity := 20.0
@export var turn_speed := 2.2        ## rad/s of heading change at full input
@export var carve_grip := 3.0        ## how fast velocity aligns to the board
@export var brake_grip := 8.0        ## sideways scrub while braking
@export var drag := 0.04             ## air + snow resistance, per second
@export var jump_velocity := 6.0
@export var max_speed := 40.0        ## m/s (~144 km/h)
@export var fall_limit := -250.0     ## respawn below this height

var heading := 0.0                   ## yaw in radians; 0 faces -Z (downhill)
var _spawn: Transform3D
## Our own copy of the velocity. On floors move_and_slide() hands velocity
## back flattened *and* shortened (~3%/tick on this slope), which caps the
## speed, so the board keeps its own state and only takes the engine's
## result when it actually hits something.
var _ride := Vector3.ZERO


func _ready() -> void:
	_spawn = global_transform
	floor_stop_on_slope = false
	floor_snap_length = 0.6


func _physics_process(delta: float) -> void:
	if Input.is_action_just_pressed("reset") or global_position.y < fall_limit:
		respawn()
		return

	heading += Input.get_axis("carve_right", "carve_left") * turn_speed * delta
	rotation.y = heading

	if is_on_floor():
		var n := get_floor_normal()
		# Landing drops the into-the-slope part of the velocity.
		var planar := _ride.slide(n)
		# Downhill component of gravity, i.e. gravity projected onto the slope.
		planar += (Vector3.DOWN * gravity).slide(n) * delta

		var fwd := (-global_basis.z).slide(n).normalized()
		var grip := brake_grip if Input.is_action_pressed("brake") else carve_grip
		# Keep only the along-board part of the velocity; the sideways part
		# is scrubbed off over time (skid).
		var aligned := fwd * planar.dot(fwd)
		planar = planar.lerp(aligned, 1.0 - exp(-grip * delta))
		planar *= 1.0 - drag * delta
		_ride = planar.limit_length(max_speed)
		velocity = _ride

		if Input.is_action_just_pressed("jump"):
			velocity += n * jump_velocity
	else:
		velocity.y -= gravity * delta

	if not is_on_floor():
		_ride = velocity
	move_and_slide()
	if is_on_wall():
		_ride = velocity


func respawn() -> void:
	global_transform = _spawn
	velocity = Vector3.ZERO
	_ride = Vector3.ZERO
	heading = 0.0
