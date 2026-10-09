extends RefCounted

const STAGE_FIELDS := [
	"top_left",
	"bottom_right",
	"autoscroll_speed",
	"follow_speed",
	"catchup_speed",
	"leash_distance",
	"lead_speed",
	"catchup_delay_duration",
	"push_ratio",
	"pushbox_top_left",
	"pushbox_bottom_right",
	"speedup_zone_top_left",
	"speedup_zone_bottom_right",
	"box_width",
	"box_height",
]

static func instantiate_world(parent: Node) -> Node:
	var packed_scene := load("res://scenes/world.tscn") as PackedScene
	if packed_scene == null:
		return null

	var world := packed_scene.instantiate()
	parent.add_child(world)
	return world


static func get_cameras(world: Node) -> Array:
	if world == null:
		return []
	var selector := world.get_node_or_null("CameraSelector")
	if selector == null:
		return []
	return selector.cameras


static func camera_with_fields(world: Node, required_fields: Array[String]) -> CameraControllerBase:
	for camera in get_cameras(world):
		if camera == null:
			continue
		var matches := true
		for field_name in required_fields:
			if not _has_exported_property(camera, field_name):
				matches = false
				break
		if matches:
			return camera
	return null


static func position_lock_camera(world: Node) -> CameraControllerBase:
	for camera in get_cameras(world):
		if camera == null:
			continue
		var property_names := _property_names(camera)
		var has_stage_fields := false
		for field_name in STAGE_FIELDS:
			if property_names.has(field_name):
				has_stage_fields = true
				break
		if not has_stage_fields:
			return camera
	return null


static func reset_camera(camera: CameraControllerBase) -> void:
	if camera == null:
		return

	for action in ["ui_left", "ui_right", "ui_up", "ui_down"]:
		Input.action_release(action)

	for other_camera in get_cameras(camera.get_parent()):
		if other_camera != null:
			other_camera.current = false
			other_camera.set_process(false)

	camera.current = true
	camera.set_process(false)
	camera.set_physics_process(false)
	camera.draw_camera_logic = false
	camera.global_position = Vector3(0.0, camera.dist_above_target, 0.0)

	var target := camera.target
	if target != null:
		target.set_process(false)
		target.set_physics_process(false)
		target.global_position = Vector3.ZERO
		target.velocity = Vector3.ZERO


static func _property_names(object: Object) -> Dictionary:
	var names := {}
	for property in object.get_property_list():
		names[property.name] = true
	return names


static func _has_exported_property(object: Object, field_name: String) -> bool:
	for property in object.get_property_list():
		if property.name == field_name and property.usage & PROPERTY_USAGE_EDITOR != 0:
			return true
	return false
