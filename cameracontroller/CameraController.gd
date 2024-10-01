class_name CameraController

extends Camera3D

@export var target:Node3D
@export var draw_camera_logic:bool = true

var line:Line2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	line = Line2D.new()
	add_child(line)
	
	print(target)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	draw_logic()
	pass

func draw_logic() -> void:
	var mesh_instance := MeshInstance3D.new()
	var immediate_mesh := ImmediateMesh.new()
	var material := ORMMaterial3D.new()
	#print(target.position)
	
	mesh_instance.mesh = immediate_mesh
	mesh_instance.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF

	immediate_mesh.surface_begin(Mesh.PRIMITIVE_LINES, material)
	immediate_mesh.surface_add_vertex(Vector3(0.15, target.position.y, 0.15))
	immediate_mesh.surface_add_vertex(Vector3(0.15, target.position.y, -0.15))
	
	immediate_mesh.surface_add_vertex(Vector3(0.15, target.position.y, -0.15))
	immediate_mesh.surface_add_vertex(Vector3(-0.15, target.position.y, -0.15))
	
	immediate_mesh.surface_add_vertex(Vector3(-0.15, target.position.y, -0.15))
	immediate_mesh.surface_add_vertex(Vector3(-0.15, target.position.y, 0.15))
	
	immediate_mesh.surface_add_vertex(Vector3(-0.15, target.position.y, 0.15))
	immediate_mesh.surface_add_vertex(Vector3(0.15, target.position.y, 0.15))
	immediate_mesh.surface_end()

	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	material.albedo_color = Color.BLACK
	
	add_child(mesh_instance)
	mesh_instance.global_transform = Transform3D.IDENTITY
	mesh_instance.global_position = target.global_position
	await get_tree().physics_frame
	mesh_instance.queue_free()
	print("---")
	print(target.global_position)
	print(mesh_instance.global_position)
	print(mesh_instance.transform)
	#print(get_viewport().get_mouse_position())

	
	
