extends GdUnitTestSuite

const CameraTestSupport = preload("res://test/provided/camera_test_support.gd")

var _world: Node


func before() -> void:
	_world = CameraTestSupport.instantiate_world(self)
	assert_that(_world).is_not_null()


func after() -> void:
	if _world != null:
		_world.queue_free()


func test_stage_1_immediately_repositions_camera_on_both_axes() -> void:
	var camera := CameraTestSupport.position_lock_camera(_world)
	assert_that(camera).is_not_null()
	if camera == null or camera.target == null:
		return
	CameraTestSupport.reset_camera(camera)

	camera.target.global_position = Vector3(-12.0, 3.0, 7.0)
	camera._process(1.0 / 60.0)

	assert_that(camera.global_position.x).is_equal_approx(-12.0, 0.01)
	assert_that(camera.global_position.z).is_equal_approx(7.0, 0.01)


func test_stage_2_allows_target_movement_inside_frame_while_scrolling() -> void:
	var camera := CameraTestSupport.camera_with_fields(
		_world, ["top_left", "bottom_right", "autoscroll_speed"]
	)
	assert_that(camera).is_not_null()
	if camera == null or camera.target == null:
		return
	CameraTestSupport.reset_camera(camera)

	camera.set("top_left", Vector2(-100.0, -100.0))
	camera.set("bottom_right", Vector2(100.0, 100.0))
	camera.set("autoscroll_speed", Vector3(2.0, 50.0, -3.0))
	camera.target.global_position = Vector3(10.0, 0.0, -10.0)
	camera._process(0.5)

	assert_that(camera.target.global_position).is_equal_approx(
		Vector3(10.0, 0.0, -10.0), Vector3(0.01, 0.01, 0.01)
	)
	assert_that(camera.global_position.x).is_equal_approx(1.0, 0.01)
	assert_that(camera.global_position.z).is_equal_approx(-1.5, 0.01)


func test_stage_2_keeps_target_inside_trailing_frame_boundary() -> void:
	var camera := CameraTestSupport.camera_with_fields(
		_world, ["top_left", "bottom_right", "autoscroll_speed"]
	)
	assert_that(camera).is_not_null()
	if camera == null or camera.target == null:
		return
	CameraTestSupport.reset_camera(camera)

	camera.set("top_left", Vector2(-5.0, -5.0))
	camera.set("bottom_right", Vector2(5.0, 5.0))
	camera.set("autoscroll_speed", Vector3.ZERO)
	camera.target.global_position.x = -8.0
	camera._process(0.1)

	assert_that(camera.target.global_position.x).is_greater_equal(-4.51)


func test_stage_3_follow_distance_is_consistent_across_frame_rates() -> void:
	var camera := CameraTestSupport.camera_with_fields(
		_world, ["follow_speed", "catchup_speed", "leash_distance"]
	)
	assert_that(camera).is_not_null()
	if camera == null or camera.target == null:
		return
	CameraTestSupport.reset_camera(camera)

	camera.set("follow_speed", 2.0)
	camera.set("catchup_speed", 4.0)
	camera.set("leash_distance", 100.0)
	camera.target.global_position.x = 20.0
	camera.target.velocity.x = 10.0
	for _frame in range(60):
		camera._process(1.0 / 60.0)
	var position_at_60_fps := camera.global_position.x

	CameraTestSupport.reset_camera(camera)
	camera.set("follow_speed", 2.0)
	camera.set("catchup_speed", 4.0)
	camera.set("leash_distance", 100.0)
	camera.target.global_position.x = 20.0
	camera.target.velocity.x = 10.0
	for _frame in range(30):
		camera._process(1.0 / 30.0)

	assert_that(position_at_60_fps).is_equal_approx(camera.global_position.x, 0.1)


func test_stage_4_leads_in_input_direction_not_velocity_direction() -> void:
	var camera := CameraTestSupport.camera_with_fields(
		_world, ["lead_speed", "catchup_delay_duration", "catchup_speed", "leash_distance"]
	)
	assert_that(camera).is_not_null()
	if camera == null or camera.target == null:
		return
	CameraTestSupport.reset_camera(camera)

	camera.set("lead_speed", 4.0)
	camera.set("catchup_delay_duration", 1.0)
	camera.set("catchup_speed", 4.0)
	camera.set("leash_distance", 20.0)
	camera.target.velocity.x = 10.0
	Input.action_press("ui_left")
	camera._process(0.25)
	Input.action_release("ui_left")

	assert_that(camera.global_position.x).is_less(0.0)


func test_stage_5_camera_does_not_push_target_back_toward_inner_zone() -> void:
	var camera := _stage_5_camera()
	assert_that(camera).is_not_null()
	if camera == null or camera.target == null:
		return
	_configure_stage_5(camera)

	camera.target.global_position.x = 6.0
	camera.target.velocity.x = -4.0
	camera._process(0.25)

	assert_that(camera.global_position.x).is_equal_approx(0.0, 0.01)


func test_stage_5_outer_edge_pushes_fully_while_other_axis_uses_ratio() -> void:
	var camera := _stage_5_camera()
	assert_that(camera).is_not_null()
	if camera == null or camera.target == null:
		return
	_configure_stage_5(camera)

	camera.target.global_position = Vector3(9.5, 0.0, 6.0)
	camera.target.velocity = Vector3(4.0, 0.0, 4.0)
	camera._process(0.25)

	assert_that(camera.global_position.x).is_greater(0.5)
	assert_that(camera.global_position.z).is_equal_approx(0.5, 0.05)


func _stage_5_camera() -> CameraControllerBase:
	return CameraTestSupport.camera_with_fields(
		_world,
		[
			"push_ratio",
			"pushbox_top_left",
			"pushbox_bottom_right",
			"speedup_zone_top_left",
			"speedup_zone_bottom_right",
		]
	)


func _configure_stage_5(camera: CameraControllerBase) -> void:
	CameraTestSupport.reset_camera(camera)
	camera.set("push_ratio", 0.5)
	camera.set("pushbox_top_left", Vector2(-10.0, -10.0))
	camera.set("pushbox_bottom_right", Vector2(10.0, 10.0))
	camera.set("speedup_zone_top_left", Vector2(-4.0, -4.0))
	camera.set("speedup_zone_bottom_right", Vector2(4.0, 4.0))
