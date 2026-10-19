extends Node3D
## Scatters placeholder pines over the slope and drives the HUD.

@export var tree_count := 80
@export var tree_seed := 1337
@export var clear_lane := 3.0        ## keep the spawn line free of trees

@onready var slope: StaticBody3D = $Slope
@onready var slope_shape: BoxShape3D = $Slope/Collision.shape
@onready var boarder: CharacterBody3D = $Boarder
@onready var speed_label: Label = $HUD/Speed


func _ready() -> void:
	_plant_trees()


func _process(_delta: float) -> void:
	speed_label.text = "%d km/h" % roundi(boarder.velocity.length() * 3.6)


func _plant_trees() -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = tree_seed
	var half := slope_shape.size * 0.5

	var trunk_mat := StandardMaterial3D.new()
	trunk_mat.albedo_color = Color(0.35, 0.24, 0.16)
	var needles_mat := StandardMaterial3D.new()
	needles_mat.albedo_color = Color(0.13, 0.32, 0.22)

	var trunk_mesh := CylinderMesh.new()
	trunk_mesh.top_radius = 0.15
	trunk_mesh.bottom_radius = 0.2
	trunk_mesh.height = 1.0
	trunk_mesh.material = trunk_mat
	var needles_mesh := CylinderMesh.new()
	needles_mesh.top_radius = 0.0
	needles_mesh.bottom_radius = 1.3
	needles_mesh.height = 4.0
	needles_mesh.material = needles_mat
	var shape := CylinderShape3D.new()
	shape.radius = 0.4
	shape.height = 5.0

	var trees := Node3D.new()
	trees.name = "Trees"
	add_child(trees)

	for i in tree_count:
		var x := rng.randf_range(-half.x + 1.0, half.x - 1.0)
		if absf(x) < clear_lane:
			x += signf(x if x != 0.0 else 1.0) * clear_lane
		var z := rng.randf_range(-half.z + 10.0, half.z - 40.0)
		var base := slope.global_transform * Vector3(x, half.y, z)

		var tree := StaticBody3D.new()
		tree.position = base
		var s := rng.randf_range(0.8, 1.4)
		tree.scale = Vector3.ONE * s
		trees.add_child(tree)

		var trunk := MeshInstance3D.new()
		trunk.mesh = trunk_mesh
		trunk.position.y = 0.5
		tree.add_child(trunk)
		var needles := MeshInstance3D.new()
		needles.mesh = needles_mesh
		needles.position.y = 3.0
		tree.add_child(needles)
		var col := CollisionShape3D.new()
		col.shape = shape
		col.position.y = 2.5
		tree.add_child(col)
