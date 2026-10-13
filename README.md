# Camera Control Exercise

## Description

Build five swappable camera controllers for a top-down terraforming simulator, then adapt one of them. Try each controller while playing: notice what it lets you see ahead of the vessel and how it responds to stops and direction changes.

The primary reference for this exercise is **Scroll Back: The Theory and Practice of Cameras in Side-Scrollers** by Itay Keren, covered in class.

The project includes automated checks to help you verify your work.

## Due Date and Submission

The due date for this exercise is listed in Canvas.

We will evaluate the submitted `master` branch of your individual exercise repository as specified in Canvas. Make sure all work you want evaluated has been committed and pushed to GitHub.

Before submitting:

- Run the project.
- Run the supplied automated checks.
- Make sure all five camera controllers can be selected through `CameraSelector`.
- Leave `draw_camera_logic` enabled.
- Make sure your adaptation is present and testable.

# Exercise Stages

The following requirements apply to all five stages:

- Each controller should extend `CameraControllerBase`.
- Add each controller as a child of the `World` node.
- Bind the `Vessel` node to the `Target` exported field through the editor.
- Bind the controllers to the `Array[CameraControllerBase]` in `CameraSelector`.
- Expose the listed parameters in the editor.
- Camera speeds should use units per second where appropriate and account for `delta`.
- Controllers should behave consistently at different frame rates.
- Use an `ImmediateMesh` in `_draw_logic()` to visualize important camera logic when `draw_camera_logic` is true. Follow `PushBoxCamera` for the drawing pattern.
- Draw debug lines at the same vertical level as the `Vessel`.
- Leave `draw_camera_logic` enabled in the submitted project.

### Coordinate and Motion Conventions

- Camera behavior is evaluated on the ground plane: world `x` is horizontal and world `z` is vertical. `ui_up` moves toward negative `z`; `ui_down` moves toward positive `z`.
- In a `Vector2` used for a frame or zone, `.x` means world `x` and `.y` means world `z`. Thus `top_left` has smaller coordinates than `bottom_right` on both components.
- Frame and zone bounds are offsets from the camera center and apply to the target's center point, not its collision shape.
- Camera-to-target distances and leash limits are measured in the `x-z` plane; differences in world `y` do not count. Controllers should preserve the base camera's vertical tracking/zoom behavior.
- Speeds are world units per second. Multiply by `delta`; clamp movement so a camera cannot pass its destination in a single frame.
- Use target velocity to determine whether the vessel is physically moving in Stages 3 and 5. Stage 4 is the exception: its lead direction comes from movement input.

---

## Stage 1 — Position Lock

Implement a simple position-locking camera.

The camera should always be centered on the `Vessel` in the `x-z` plane.

There are no additional exported fields.

When `draw_camera_logic` is true, draw a cross at the center of the camera.

This type of camera can be found in games such as *Terraria*.

### Things to Verify

- Moving the vessel immediately moves the camera.
- The camera remains centered on the vessel.
- Horizontal and vertical movement both work.
- The debug cross follows the camera center.

---

## Stage 2 — Framing with Planar Auto-Scroll

In the grand tradition of shmups, this controller implements a frame-bound autoscroller.

The player should be able to move freely inside a rectangular frame. The camera and frame continuously move across the `x-z` plane according to `autoscroll_speed`. Despite the traditional term "horizontal autoscroller," this exercise allows scrolling on either or both ground-plane axes.

If the target's center reaches or crosses the trailing edge of the scrolling frame, move the target forward just enough to put it on that edge. The trailing edge is the side opposite the direction of scroll on each moving axis (for example, the left edge when scrolling toward positive `x`). Apply this independently on `x` and `z`; scrolling on one axis must not constrain the other axis. The camera continues at the configured scroll speed.

When `draw_camera_logic` is true, draw the frame border.

### Required Exported Fields

```gdscript
Vector2 top_left
Vector2 bottom_right
Vector3 autoscroll_speed
```

- `top_left` — top-left corner of the frame relative to the camera, in `(x, z)` coordinates.
- `bottom_right` — bottom-right corner of the frame relative to the camera, in `(x, z)` coordinates.
- `autoscroll_speed` — world units per second for each world axis. Use its `x` and `z` components; `y` is ignored.

The frame bounds are inclusive. Configure `top_left.x < bottom_right.x` and `top_left.y < bottom_right.y`. A zero speed on an axis disables scrolling and trailing-edge correction on that axis.

This type of camera can be found in games such as *Scramble*.

### Things to Verify

- The camera moves independently of player input.
- The target can move freely inside the frame.
- The target center stays on or inside the trailing edge.
- Changing `autoscroll_speed` changes the scrolling rate.
- Behavior remains consistent at different frame rates.

---

## Stage 3 — Position Lock with Smoothing

This controller is based on Stage 1, but the camera should not immediately center itself on the target.

Instead, the camera approaches the target over time.

While the vessel has nonzero ground-plane velocity, the camera should move toward it at `follow_speed`. This should generally be slower than the vessel's movement speed, allowing some separation between the player and camera.

When the vessel's ground-plane velocity reaches zero, the camera should move toward it at `catchup_speed`. Deceleration still counts as movement until velocity reaches zero.

The `x-z` distance between the vessel and camera should never exceed `leash_distance`. If a step would exceed the leash, clamp the camera to the leash boundary. Motion toward the target must stop at the target rather than overshoot it.

You may implement the smoothing with interpolation or another reasonable method. The important part is the resulting behavior.

When `draw_camera_logic` is true, draw a cross at the center of the camera.

### Required Exported Fields

```gdscript
float follow_speed
float catchup_speed
float leash_distance
```

- `follow_speed` — speed at which the camera follows a moving target.
- `catchup_speed` — speed at which the camera catches up after the player stops.
- `leash_distance` — maximum distance between the vessel and camera center.

The scalar leash describes a circular limit on the `x-z` plane. The optional axis-specific leash adaptation replaces it with separate horizontal and vertical limits.

This type of camera behavior can be found in games such as *Super Meat Boy*.

### Things to Verify

- The camera trails a moving vessel.
- The camera catches up when movement stops.
- The camera never exceeds `leash_distance`.
- The camera does not overshoot the target.
- Behavior remains consistent at different frame rates.

---

## Stage 4 — Smoothed Target Focus

Create a variant of Stage 3 in which the camera **leads** the player in the direction of player input.

When movement input is provided through `ui_left`, `ui_right`, `ui_up`, or `ui_down`, the camera should move ahead of the player in that direction. Use the combined input vector (normalized for diagonal input) rather than vessel velocity. This gives the player additional screen space in the direction they are trying to travel.

The distance between camera and target may increase while the player is moving, but it must never exceed `leash_distance`.

When all movement input is released, the camera should remain in its lead position for `catchup_delay_duration`, then begin moving back toward the target at `catchup_speed`. While movement input is nonzero, reset the delay timer; catch-up starts only after input has remained zero continuously for the full duration. Input in the opposite direction changes the lead direction immediately; implementing a recenter-before-reversal rule is optional and belongs to Adaptation C.

When `draw_camera_logic` is true, draw a cross at the camera center.

### Required Exported Fields

```gdscript
float lead_speed
float catchup_delay_duration
float catchup_speed
float leash_distance
```

- `lead_speed` — speed at which the camera moves in the direction of player input.
- `catchup_delay_duration` — time between the player stopping and the camera beginning to recenter.
- `catchup_speed` — speed at which the camera moves back toward the vessel.
- `leash_distance` — maximum distance between the vessel and camera center.

As in Stage 3, the leash is an `x-z` distance. Clamp lead movement so the camera never crosses the leash boundary.

This type of camera can be found in games such as *Jazz Jackrabbit 2*.

### Things to Verify

- Input causes the camera to lead in the correct direction.
- The camera never exceeds the leash.
- Releasing input does not immediately recenter the camera.
- Catchup begins after the specified delay.
- Changing direction produces sensible behavior.
- Behavior remains consistent at different frame rates.

---

## Stage 5 — Four-Way Speedup Push Zone

Implement a four-directional version of the speedup-push-zone camera demonstrated in class.

This controller contains two rectangular regions:

1. an inner **speedup zone**
2. an outer **pushbox**

Treat horizontal and vertical movement independently. You can think of the system as four speedup-push zones operating together.

### Inside the Inner Zone

When the target's center is inside or on the inner speedup zone, the camera should remain stationary on the corresponding axis.

### Between the Inner and Outer Zones

For each axis independently, when the target is:

1. moving
2. outside the inner speedup zone
3. inside the outer pushbox
4. moving farther into the corresponding push region

the camera should move in that direction at the target's velocity on that axis multiplied by `push_ratio`. On a given axis, this rule applies only when the target is outside the inner zone on that axis and its velocity points farther away from the inner zone. Movement back toward the inner zone does not move the camera on that axis.

### Touching One Outer Edge

When the target's center reaches an outer pushbox edge while moving outward, the camera should move at the target's full velocity on that axis, keeping the target on the edge. If the target moves inward from an outer edge, use the normal rule for its position relative to the inner zone instead. If the target center passes an outer edge in a frame, move the camera just enough to bring it back to that edge.

Movement along the other axis should continue to use normal speedup-zone behavior.

For example, if the target touches the top edge while moving toward the upper-right, the camera should move at full target speed vertically while still using `push_ratio` horizontally when appropriate.

### Touching a Corner

If the target reaches two outer edges at once, apply full target velocity on both affected axes. If it reaches an edge on only one axis, continue applying the inner/outer-zone rule independently on the other axis.

When `draw_camera_logic` is true, draw both the pushbox and speedup-zone boundaries.

### Required Exported Fields

```gdscript
float push_ratio
Vector2 pushbox_top_left
Vector2 pushbox_bottom_right
Vector2 speedup_zone_top_left
Vector2 speedup_zone_bottom_right
```

- `push_ratio` — fraction of target movement applied to the camera while the target is in a speedup region but has not reached the outer edge.
- `pushbox_top_left` — top-left corner of the outer pushbox.
- `pushbox_bottom_right` — bottom-right corner of the outer pushbox.
- `speedup_zone_top_left` — top-left corner of the inner speedup zone.
- `speedup_zone_bottom_right` — bottom-right corner of the inner speedup zone.

All four corners are offsets from the camera center in `(x, z)` coordinates. The speedup zone must be inside the pushbox on all sides. Treat both rectangles as inclusive at their boundaries; the outer-edge rule takes precedence over the speedup rule on that axis. `push_ratio` must be between `0` and `1`, inclusive.

For example, with a zero camera offset, an inner-zone right edge at `x = 4`, a target at `x = 6` moving at `+4` units/second, `push_ratio = 0.5`, and `delta = 0.25`, the camera moves `+0.5` units on `x`. If the target is at the outer right edge and continues moving outward at the same speed, the camera moves `+1` unit on `x`.

The one-directional version of this technique is famously used in *Super Mario Bros.*

### Things to Verify

Pay particular attention to boundaries:

- center of the inner zone
- just inside an inner-zone edge
- just outside an inner-zone edge
- middle of each speedup region
- each outer pushbox edge
- each outer pushbox corner
- diagonal movement
- movement back toward the inner zone
- different values of `push_ratio`

---

# Debug Visualization

Implement `_draw_logic()` using `PushBoxCamera` as an example. Draw the cross or boundaries required by each stage at the vessel's height. You can also draw the leash or other state if it helps you diagnose movement.

## Adaptation

After completing the five controllers, make **one** of these changes:

#### A. Axis-Specific Leash

Modify Stage 3 or Stage 4 so the horizontal and vertical leash distances can be tuned independently.

#### B. Distance-Sensitive Catchup

Modify Stage 3 so the camera catches up more aggressively when it is far from the target and settles more gently as it approaches.

#### C. Direction-Reversal Recentering

Modify Stage 4 so that reversing direction first brings the camera back toward the player before establishing a lead in the new direction.

Your adaptation should:

- remain designer-tunable where appropriate
- preserve the original purpose of the controller
- work at different frame rates
- be visible while playing

Add a short comment near the relevant class declaration identifying the option you implemented:

```gdscript
# ADAPTATION: B - Distance-Sensitive Catchup
```

## Individual Competency Profile

This exercise provides evidence for **Game Systems** and **Debugging and Testing**:

| Work | Competency and level it can support |
| --- | --- |
| Implementing and integrating Stages 1–5 | Game Systems: Unlocked |
| Completing the adaptation | Game Systems: Developed |
| Using the supplied checks and debug drawing to investigate behavior | Debugging and Testing: Unlocked |
| Adding your own tests or diagnostics | Debugging and Testing: Developed (optional) |

These levels depend on the work you submit; completing the checklist does not automatically establish Mastery.

---

# Automated Checks

Run the GdUnit4 checks while developing. They cover some, but not all, of the requirements. Grading may include additional cases, so passing the supplied checks is not a substitute for testing the rest of the specification.

The student-authored suite in [Obscura/test/test_camera_stage_requirements.gd](Obscura/test/test_camera_stage_requirements.gd) adds checks for frame boundaries, frame-rate consistency, input-directed camera leading, and independent pushbox-axis behavior.

From a command prompt, run the following from the `Obscura` project directory. Replace the executable path with the location of your Godot 4 executable:

```text
addons\gdUnit4\runtest.cmd --godot_binary "C:\Path\To\Godot.exe" -a res://test
```

This runs every GdUnit suite under `res://test`, including the provided and student-authored tests.

---

# Terminology and Useful Concepts

You will encounter the following ideas throughout the exercise.

## `delta`

`delta` is the amount of time, in seconds, since the previous frame.

If a camera should move at 10 units per second, the distance it should move during the current frame is:

```gdscript
distance = 10.0 * delta
```

Using `delta` correctly keeps movement approximately consistent when the frame rate changes.

## Linear Interpolation (`lerp`)

Linear interpolation finds a value between two other values.

Conceptually:

```text
lerp(a, b, t) = a + t * (b - a)
```

When:

- `t = 0`, the result is `a`
- `t = 1`, the result is `b`
- `t = 0.5`, the result is halfway between them

For example:

```gdscript
position = position.lerp(target_position, 0.1)
```

moves the position 10% of the remaining distance toward the target each time it is called.

Be careful: `0.1` here is **not a speed in units per second**. Repeated lerping produces a smooth approach whose speed depends on the remaining distance and, if used once per frame without accounting for time, can also depend on frame rate.

If the specification says that something moves at a particular number of **units per second**, `move_toward()` or an explicit speed calculation may be easier to reason about.

## Leash

A **leash** limits how far the camera may get from its target.

For example, if:

```text
leash_distance = 10
```

then the distance between the camera center and target should never exceed 10 units.

The leash can be useful even when the normal camera behavior would otherwise allow the target to drift farther away.

## Pushbox

A **pushbox**, also called a camera window, is a region around the camera in which the target can move without forcing the camera to follow exactly.

When the target reaches an outer boundary, the system responds to keep the target in the intended region. Stage 2 corrects the target at the trailing edge; Stage 5 moves the camera at the outer pushbox edge.

## Speedup Zone

Stage 5 uses two nested regions:

```text
Outer Pushbox
┌─────────────────────────────┐
│       Speedup Region        │
│     ┌─────────────────┐     │
│     │   Inner Zone    │     │
│     │ camera does not │     │
│     │      move       │     │
│     └─────────────────┘     │
│       Speedup Region        │
└─────────────────────────────┘
```

Inside the inner zone, the camera stays still.

Between the inner zone and outer pushbox, the camera moves at a fraction of the target's movement.

At the outer pushbox boundary, the camera moves enough to prevent the target from leaving the box.

## Target Focus

A target-focus camera moves ahead of the player to show more of the space the player is trying to move toward.

In Stage 4, use the **player's movement input** to determine the lead direction rather than simply using the vessel's current velocity. Input and velocity are not always the same thing.

## Invariant

An **invariant** is a condition that should remain true while the system operates.

For example:

```text
distance(camera, target) <= leash_distance
```

is an invariant for a leashed camera.

Other useful invariants in this exercise include:

```text
target cannot cross the trailing edge of the autoscroll frame
```

and:

```text
camera remains stationary while target is inside
the Stage 5 inner zone
```

Thinking in terms of invariants is useful both for implementation and debugging.

## Boundary and Edge-Case Testing

Many errors happen where behavior changes from one rule to another.

For example, Stage 5 behaves differently:

- inside the speedup zone
- just outside the speedup zone
- at the outer pushbox edge
- at a corner

Testing positions immediately on both sides of these boundaries is often more useful than testing arbitrary positions in the middle of a region.

For Stages 2 and 5, test the target center exactly on a boundary and just to either side. In Stage 5, also test movement both farther into and back toward the inner zone, and test one-axis edge contact separately from corner contact.

## `ImmediateMesh`

`ImmediateMesh` lets you build the debug lines in code. Each controller must call its `_draw_logic()` method when debug drawing is enabled; the base class declares the method but does not call it for you. Follow the mesh creation and cleanup pattern in `PushBoxCamera`.

## Tuning

Once a controller works, change its exported parameters and play it again. Try slow movement, hyper-speed movement, stops, and reversals. Check it at different frame rates as well as with the automated tests.

# Optional Competency Claims

You may make up to two additional competency claims at Developed or Mastery. Point to specific files, tests, commits, or features. Say what you changed, why it matters, and how it goes beyond the default exercise requirements.

For each claim, add:

```text
Competency:
Level: Developed or Mastery
Evidence:
Explanation:
```

## Developed and Mastery

A **Developed** claim needs work beyond the supplied example or required minimum. Explain your design decision and show how you tested it, including a case that was not straightforward.

For **Mastery**, identify a problem yourself, compare possible solutions, and implement and evaluate one. Include normal and failure cases, and explain what your solution does not handle.

## Likely Competencies for This Exercise

Some possible evidence:

- **Debugging and Testing:** Test delay timing, overshoot, boundaries, or frame-rate differences. For a larger claim, build a setup that compares several controllers under the same movement sequence.
- **Engine Usage:** Solve a camera update or lifecycle problem using Godot's input, node, or physics systems. Explain why you chose that update order or scene structure.
- **Game Systems:** Add camera rules beyond the supplied stages, such as behavior that changes with location or game state. Show how the rules interact.
- **System Interrelations:** Handle target changes, controller transitions, or interruptions without breaking player movement or camera state.
- **Game Design Reasoning:** Compare camera approaches for a specific gameplay problem, such as seeing hazards during hyper-speed travel, and explain your choice.
- **Interaction Design:** Change camera timing or framing, playtest it, and revise it based on what players could see or control.
- **Evaluation and Iteration:** Record a problem during play, make a targeted revision, and compare the result under the same conditions.

Choose the level based on the evidence, not the number of features you added.