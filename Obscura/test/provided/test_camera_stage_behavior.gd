extends GdUnitTestSuite

const CameraTestSupport = preload("res://test/provided/camera_test_support.gd")

var _world: Node


func before() -> void:
	_world = CameraTestSupport.instantiate_world(self)
	assert_that(_world).is_not_null()


func after() -> void:
	if _world != null:
		_world.queue_free()


func test_five_distinct_cameras_are_registered_and_bound_to_the_vessel() -> void:
	var cameras := CameraTestSupport.get_cameras(_world)
	assert_that(cameras.size()).is_equal(5)
	if cameras.size() != 5:
		return

	var seen := {}
	for camera in cameras:
		assert_that(camera).is_not_null()
		if camera == null:
			continue
		assert_that(camera.target).is_not_null()
		seen[camera.get_instance_id()] = true
	assert_that(seen.size()).is_equal(5)


func test_registered_cameras_enable_debug_logic_by_default() -> void:
	var cameras := CameraTestSupport.get_cameras(_world)
	for camera in cameras:
		if camera != null:
			assert_that(camera.draw_camera_logic).is_true()


func test_stage_1_camera_tracks_horizontal_and_vertical_target_motion() -> void:
	var camera := CameraTestSupport.position_lock_camera(_world)
	assert_that(camera).is_not_null()
	if camera == null or camera.target == null:
		return
	CameraTestSupport.reset_camera(camera)

	camera.target.global_position = Vector3(7.0, 0.0, -3.0)
	camera._process(1.0)

	assert_that(camera.global_position.x).is_equal_approx(7.0, 0.01)
	assert_that(camera.global_position.z).is_equal_approx(-3.0, 0.01)


func test_stage_2_scrolls_at_configured_speed_and_ignores_vertical_speed() -> void:
	var camera := CameraTestSupport.camera_with_fields(
		_world, ["top_left", "bottom_right", "autoscroll_speed"]
	)
	assert_that(camera).is_not_null()
	if camera == null or camera.target == null:
		return
	CameraTestSupport.reset_camera(camera)

	camera.set("top_left", Vector2(-100.0, -100.0))
	camera.set("bottom_right", Vector2(100.0, 100.0))
	camera.set("autoscroll_speed", Vector3(8.0, 100.0, -4.0))
	camera._process(0.25)

	assert_that(camera.global_position.x).is_equal_approx(2.0, 0.05)
	assert_that(camera.global_position.z).is_equal_approx(-1.0, 0.05)
	assert_that(camera.global_position.y).is_equal_approx(camera.dist_above_target, 0.05)


func test_stage_2_scroll_distance_is_consistent_across_frame_rates() -> void:
	var camera := CameraTestSupport.camera_with_fields(
		_world, ["top_left", "bottom_right", "autoscroll_speed"]
	)
	assert_that(camera).is_not_null()
	if camera == null or camera.target == null:
		return
	CameraTestSupport.reset_camera(camera)

	camera.set("top_left", Vector2(-100.0, -100.0))
	camera.set("bottom_right", Vector2(100.0, 100.0))
	camera.set("autoscroll_speed", Vector3(8.0, 0.0, 0.0))
	for _frame in range(60):
		camera._process(1.0 / 60.0)
	var position_after_60_frames := camera.global_position.x

	CameraTestSupport.reset_camera(camera)
	camera.set("top_left", Vector2(-100.0, -100.0))
	camera.set("bottom_right", Vector2(100.0, 100.0))
	camera.set("autoscroll_speed", Vector3(8.0, 0.0, 0.0))
	for _frame in range(30):
		camera._process(1.0 / 30.0)

	assert_that(position_after_60_frames).is_equal_approx(camera.global_position.x, 0.1)
	assert_that(camera.global_position.x).is_equal_approx(8.0, 0.1)


func test_stage_2_pushes_a_target_that_reaches_the_trailing_edge() -> void:
	var camera := CameraTestSupport.camera_with_fields(
		_world, ["top_left", "bottom_right", "autoscroll_speed"]
	)
	assert_that(camera).is_not_null()
	if camera == null or camera.target == null:
		return
	CameraTestSupport.reset_camera(camera)

	camera.set("top_left", Vector2(-5.0, -5.0))
	camera.set("bottom_right", Vector2(5.0, 5.0))
	camera.set("autoscroll_speed", Vector3(10.0, 0.0, 0.0))
	camera.target.global_position.x = -4.5
	camera._process(0.1)

	assert_that(camera.target.global_position.x).is_greater(-4.5)


func test_stage_3_follows_a_moving_target_without_exceeding_the_leash() -> void:
	var camera := CameraTestSupport.camera_with_fields(
		_world, ["follow_speed", "catchup_speed", "leash_distance"]
	)
	assert_that(camera).is_not_null()
	if camera == null or camera.target == null:
		return
	CameraTestSupport.reset_camera(camera)

	camera.set("follow_speed", 2.0)
	camera.set("catchup_speed", 4.0)
	camera.set("leash_distance", 3.0)
	camera.target.global_position.x = 8.0
	camera.target.velocity.x = 20.0
	camera._process(0.25)

	assert_that(camera.global_position.x).is_greater(0.0)
	assert_that(camera.global_position.x).is_less(camera.target.global_position.x)
	assert_that(_horizontal_distance(camera)).is_less_equal(3.01)


func test_stage_3_catches_up_after_the_target_stops_without_overshooting() -> void:
	var camera := CameraTestSupport.camera_with_fields(
		_world, ["follow_speed", "catchup_speed", "leash_distance"]
	)
	assert_that(camera).is_not_null()
	if camera == null or camera.target == null:
		return
	CameraTestSupport.reset_camera(camera)

	camera.set("follow_speed", 2.0)
	camera.set("catchup_speed", 2.0)
	camera.set("leash_distance", 20.0)
	camera.target.global_position.x = 6.0
	camera.target.velocity = Vector3.ZERO
	camera._process(0.5)

	assert_that(camera.global_position.x).is_greater(0.0)
	assert_that(camera.global_position.x).is_less_equal(1.01)
	assert_that(camera.global_position.x).is_less(camera.target.global_position.x)


func test_stage_4_leads_toward_input_and_respects_the_leash() -> void:
	var camera := CameraTestSupport.camera_with_fields(
		_world, ["lead_speed", "catchup_delay_duration", "catchup_speed", "leash_distance"]
	)
	assert_that(camera).is_not_null()
	if camera == null or camera.target == null:
		return
	CameraTestSupport.reset_camera(camera)

	camera.set("lead_speed", 8.0)
	camera.set("catchup_delay_duration", 0.5)
	camera.set("catchup_speed", 4.0)
	camera.set("leash_distance", 2.0)
	Input.action_press("ui_right")
	camera._process(0.25)
	Input.action_release("ui_right")

	assert_that(camera.global_position.x).is_greater(0.0)
	assert_that(camera.global_position.z).is_equal_approx(0.0, 0.05)
	assert_that(_horizontal_distance(camera)).is_less_equal(2.01)


func test_stage_4_waits_before_catching_up_after_input_stops() -> void:
	var camera := CameraTestSupport.camera_with_fields(
		_world, ["lead_speed", "catchup_delay_duration", "catchup_speed", "leash_distance"]
	)
	assert_that(camera).is_not_null()
	if camera == null or camera.target == null:
		return
	CameraTestSupport.reset_camera(camera)

	camera.set("lead_speed", 8.0)
	camera.set("catchup_delay_duration", 0.5)
	camera.set("catchup_speed", 4.0)
	camera.set("leash_distance", 10.0)
	Input.action_press("ui_right")
	camera._process(0.25)
	Input.action_release("ui_right")
	var lead_position := camera.global_position
	camera._process(0.25)

	assert_that(camera.global_position).is_equal_approx(lead_position, Vector3(0.05, 0.05, 0.05))

	camera._process(0.5)
	assert_that(_horizontal_distance(camera)).is_less(
		Vector2(lead_position.x, lead_position.z).distance_to(
			Vector2(camera.target.global_position.x, camera.target.global_position.z)
		)
	)


func test_stage_5_camera_stays_still_inside_the_inner_zone() -> void:
	var camera := CameraTestSupport.camera_with_fields(
		_world,
		[
			"push_ratio",
			"pushbox_top_left",
			"pushbox_bottom_right",
			"speedup_zone_top_left",
			"speedup_zone_bottom_right",
		]
	)
	assert_that(camera).is_not_null()
	if camera == null or camera.target == null:
		return
	_configure_stage_5(camera)
	camera.target.velocity = Vector3(4.0, 0.0, 3.0)
	camera._process(0.25)

	assert_that(camera.global_position.x).is_equal_approx(0.0, 0.01)
	assert_that(camera.global_position.z).is_equal_approx(0.0, 0.01)


func test_stage_5_speedup_zone_moves_camera_by_a_fraction_of_target_speed() -> void:
	var camera := CameraTestSupport.camera_with_fields(
		_world,
		[
			"push_ratio",
			"pushbox_top_left",
			"pushbox_bottom_right",
			"speedup_zone_top_left",
			"speedup_zone_bottom_right",
		]
	)
	assert_that(camera).is_not_null()
	if camera == null or camera.target == null:
		return
	_configure_stage_5(camera)
	camera.target.global_position.x = 6.0
	camera.target.velocity.x = 4.0
	camera._process(0.25)

	assert_that(camera.global_position.x).is_greater(0.0)
	assert_that(camera.global_position.x).is_less(1.01)


func test_stage_5_outer_edge_uses_full_speed_on_that_axis() -> void:
	var camera := CameraTestSupport.camera_with_fields(
		_world,
		[
			"push_ratio",
			"pushbox_top_left",
			"pushbox_bottom_right",
			"speedup_zone_top_left",
			"speedup_zone_bottom_right",
		]
	)
	assert_that(camera).is_not_null()
	if camera == null or camera.target == null:
		return
	_configure_stage_5(camera)
	camera.target.global_position.x = 9.5
	camera.target.velocity.x = 4.0
	camera._process(0.25)

	assert_that(camera.global_position.x).is_greater(0.5)


func test_stage_5_outer_corner_uses_full_speed_on_both_axes() -> void:
	var camera := CameraTestSupport.camera_with_fields(
		_world,
		[
			"push_ratio",
			"pushbox_top_left",
			"pushbox_bottom_right",
			"speedup_zone_top_left",
			"speedup_zone_bottom_right",
		]
	)
	assert_that(camera).is_not_null()
	if camera == null or camera.target == null:
		return
	_configure_stage_5(camera)
	camera.target.global_position = Vector3(9.5, 0.0, 9.5)
	camera.target.velocity = Vector3(4.0, 0.0, 4.0)
	camera._process(0.25)

	assert_that(camera.global_position.x).is_greater(0.5)
	assert_that(camera.global_position.z).is_greater(0.5)


func _configure_stage_5(camera: CameraControllerBase) -> void:
	CameraTestSupport.reset_camera(camera)
	camera.set("push_ratio", 0.5)
	camera.set("pushbox_top_left", Vector2(-10.0, -10.0))
	camera.set("pushbox_bottom_right", Vector2(10.0, 10.0))
	camera.set("speedup_zone_top_left", Vector2(-4.0, -4.0))
	camera.set("speedup_zone_bottom_right", Vector2(4.0, 4.0))


func _horizontal_distance(camera: CameraControllerBase) -> float:
	return Vector2(
		camera.global_position.x - camera.target.global_position.x,
		camera.global_position.z - camera.target.global_position.z
	).length()
