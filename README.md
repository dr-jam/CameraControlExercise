# Camera Control Exercise

## Adaptation Description

Add adaptation information here.

## Additional Competency Claims

Place claims here.

## Description

Your goal is to create several swappable camera control scripts for a top-down terraforming simulator.

The primary reference for this exercise is **Scroll Back: The Theory and Practice of Cameras in Side-Scrollers** by Itay Keren, covered in class.

## Due Date and Submission

The due date for this exercise is listed in Canvas.

We will evaluate the submitted `master` branch of your individual exercise repository as specified in Canvas. Make sure all work you want evaluated has been committed and pushed to GitHub.

Before submitting:

- Run the project.
- Make sure all five camera controllers can be selected through `CameraSelector`.
- Leave `draw_camera_logic` enabled.
- Make sure your adaptation is present and testable.
- Include the adaptation demonstration and explanation described below.

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
- Frame and zone bounds are offsets from the camera center. Use the vessel's full ground-plane footprint: `Vessel.WIDTH / 2` on either side of its center on `x`, and `Vessel.HEIGHT / 2` on `z`, as in `PushBoxCamera`.
- Camera-to-target distances and leash limits are measured in the `x-z` plane; differences in world `y` do not count. Controllers should preserve the base camera's vertical tracking/zoom behavior.
- Speeds are world units per second. Multiply by `delta`; clamp movement so a camera cannot pass its destination in a single frame.
- Use target velocity to determine whether the vessel is physically moving in Stages 3 and 5. Stage 4 is the exception: its lead direction comes from movement input.

---

## Stage 1 — Position Lock

Keep the camera centered on the `Vessel` in the `x-z` plane. This stage needs no additional exported fields.

When `draw_camera_logic` is true, draw a cross at the center of the camera.

This type of camera can be found in games such as *Terraria*  ©2011 Re-Logic.

![position-locking](https://lh6.googleusercontent.com/Bh_vzER7pXFZgRMsi158LA_q3Dg9LnykuR1cW3f8K8hgSI-BlNKLfocuGAhHRxbrcaeadtay_MgS55CO4eD0jyDIy0QB9SvAPHFnWQlDMKfN9QQJkL4RxAKc28_ymrCz)


### Things to Verify

- Moving the vessel immediately moves the camera.
- The camera remains centered on the vessel.
- Horizontal and vertical movement both work.
- The debug cross follows the camera center.

---

## Stage 2 — Framing with Planar Auto-Scroll

In the grand tradition of shmups, this controller implements a frame-bound autoscroller.

Scroll the camera and its rectangular frame at `autoscroll_speed`, on either or both ground-plane axes. The player can move freely inside the frame.

After scrolling the camera, push a lagging target just far enough to keep its trailing side inside the frame. For positive `x` scrolling, check the target's left side against the frame's left edge; for negative `x`, check its right side against the frame's right edge. Apply the same rule independently on `z`. Do not constrain an axis with zero scroll speed, or change the camera's scroll speed to follow the target.

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

The frame bounds are inclusive. Configure `top_left.x < bottom_right.x` and `top_left.y < bottom_right.y`, with enough room for the vessel's footprint. A zero speed on an axis disables scrolling and trailing-edge correction on that axis. Only trailing edges are enforced; leading and non-scrolling edges do not constrain the target.

This type of camera can be found in games such as *Scramble*  ©1981 Konami..

![auto-scroll](https://lh3.googleusercontent.com/ob8Z5bAdjxI6C9hgzL1-EcIPNeUCxCGHuOK7TaQoGtkq0iczuaSw3usLF9oYhqJfrRWQTmsRFTNqoYNoX9KjHTsuOC_auBY68C24FQEN-a3a11bM25xQdfAZ8Ls7RuxS)

### Things to Verify

- The camera moves independently of player input.
- The target can move freely inside the frame.
- The target's trailing side stays on or inside the trailing edge.
- Changing `autoscroll_speed` changes the scrolling rate.
- Behavior remains consistent at different frame rates.

---

## Stage 3 — Position Lock with Smoothing

Unlike Stage 1, move the camera toward the target over time rather than centering it immediately.

While the vessel has nonzero velocity, the camera should move toward it at `follow_speed`. This should generally be slower than the vessel's movement speed, allowing some separation between the player and camera.

When the vessel's ground-plane velocity reaches zero, the camera should move toward it at `catchup_speed`. Deceleration still counts as movement until velocity reaches zero.

After the normal follow or catch-up step, enforce `leash_distance` on the `x-z` plane. If the camera is too far away, move it to the nearest point on the leash boundary around the target. This correction takes precedence over the normal speed and may move the camera faster than `follow_speed` or `catchup_speed`. Motion toward the target must stop at the target rather than overshoot it.

Use fixed-speed movement, such as `move_toward()` with a step of `speed * delta`. Ordinary repeated lerp uses a fraction of the remaining distance, not a speed in units per second, so it does not implement these parameters.

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

Speeds and leash distance must be nonnegative. The scalar leash describes a circular limit on the `x-z` plane. Adaptation A adds separate horizontal and vertical limits; Adaptation B changes the fixed-speed catch-up rule.

This is a simplified smooth-follow exercise inspired by the discussion of *Super Meat Boy*  ©2010 Team Meat.

![position-locking with lerp-smoothing](https://lh3.googleusercontent.com/Lo1c9W3Yo0VQzf6mxAssaqXS7RoELziUwPbowklnCsI4BiqR46vYeejQPhjgZla3AR6INwVy6tCoXog4_Yc85DmlPcOapN_DjoRz6CRgD3nvTaGWkPm3cmaNpKj2tWiO)

### Things to Verify

- The camera trails a moving vessel.
- The camera catches up when movement stops.
- The camera never exceeds `leash_distance`.
- The camera does not overshoot the target.
- Behavior remains consistent at different frame rates.

---

## Stage 4 — Smoothed Target Focus

Create a variant of Stage 3 in which the camera **leads** the player in the direction of player input.

Maintain an `x-z` focus offset relative to the target, initially zero. Use `ui_left`, `ui_right`, `ui_up`, and `ui_down` to determine the lead direction, not vessel velocity. Normalize nonzero input so diagonal input does not produce a faster lead.

While input is nonzero, move the offset toward `input_direction * leash_distance` at `lead_speed`, without overshooting. Place the camera's ground-plane center at the target's current position plus this offset. The camera therefore tracks target movement even when the vessel moves faster than `lead_speed`; that speed controls the change in look-ahead, not world-space camera speed.

On release, hold the offset relative to the target for `catchup_delay_duration`, then move it toward zero at `catchup_speed`, without overshooting. Reset the timer whenever movement input is nonzero. If a frame crosses the delay threshold, use only the part of `delta` after the threshold for recentering. Reversing input changes the desired offset immediately, but the actual offset still moves at `lead_speed`; Adaptation C adds a recentering step before the new lead.

When `draw_camera_logic` is true, draw a cross at the camera center.

### Required Exported Fields

```gdscript
float lead_speed
float catchup_delay_duration
float catchup_speed
float leash_distance
```

- `lead_speed` — rate of change of the target-relative offset, in world units per second.
- `catchup_delay_duration` — seconds of zero movement input before recentering starts.
- `catchup_speed` — rate at which the offset returns to zero, in world units per second.
- `leash_distance` — intended full lead distance and maximum offset length.

All four fields must be nonnegative. Use fixed-speed offset movement, not ordinary repeated lerp. Keep the offset within the circular `x-z` leash, including when its limit is reduced in the editor.

The input-directed focus is inspired by *Jazz Jackrabbit 2* ©1998 Epic Games. 

![lerp-smoothing with target-focus](https://lh3.googleusercontent.com/-zeUJrdvmQnbB8stwBJ-P9spyZVEJIHtxDATQPkniX1hc35Y6oCLXQaqfcCmKn_Sd1cXSHN2MF2BWn1SLmoAvQbg6rCC6h_HQtqEkplanN3iaXjNgDdixCf5SSdw-YTm)

### Things to Verify

- Input causes the camera to lead in the correct direction.
- The camera keeps its target-relative lead when the vessel moves faster than `lead_speed`.
- The camera never exceeds the leash.
- Releasing input does not immediately recenter the camera.
- Catchup begins after the specified delay.
- Changing direction produces sensible behavior.
- Behavior remains consistent at different frame rates.

---

## Stage 5 — Four-Way Speedup Push Zone
Adapt the one-directional speedup-push-zone technique demonstrated in class to work left, right, up, and down. Use an inner **speedup zone** and an outer **pushbox**, with the exported fields listed below.

Your controller must produce these behaviors:

- When the vessel's extent is inside the inner zone on an axis, the camera remains stationary on that axis.
- Between the inner and outer boundaries, the camera follows outward movement at the vessel's velocity on that axis multiplied by `push_ratio`.
- At an outer boundary, the camera follows outward movement at full speed on that axis.
- Movement back toward the inner zone does not cause following on that axis.
- Horizontal and vertical behavior operate independently. Contact with one outer edge must not force full-speed following on the other axis.
- After each camera update, the vessel's full footprint must be inside the outer pushbox, including after a large movement step or teleport.

Choose how to organize the rules and enforce containment. Do not move the vessel to satisfy the pushbox; this controller moves the camera.

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

All four corners are offsets from the camera center in `(x, z)` coordinates. On each axis, require `outer_min < inner_min < inner_max < outer_max`; both boxes must fit the vessel's footprint. Contact with an inner boundary does not trigger fractional following; contact with an outer boundary triggers full following for outward movement. `push_ratio` must be between `0` and `1`, inclusive.

This is a simplified four-directional adaptation of the speedup-before-the-push-boundary idea discussed for *Super Mario Bros.* ©1985 Nintendo.

![1-way speedup push zone](https://lh6.googleusercontent.com/uuYbEkabfImuD-zi06EV57-pWfdrM7fcFsZxFXZVIfr5dFijpk_AXeRkR9K55wiqYl6IH7bMc15SEr8YzQFmHiBdvk6WntvSmkTvdDupe1y57R33AkxEXiDYif4AOUEY)

### Evidence

Provide a short recording or reproducible demonstration showing:

1. Full-speed following on one axis and fractional following on the other.
2. Outward movement on one axis and inward movement on the other at a corner.
3. Recovery when the vessel passes outside the pushbox.

Explain how your implementation combines the axis rules, how it handles boundary crossings, and one limitation or tradeoff. Compare the same movement sequence at two frame rates and report any differences.

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

### Adaptation Evidence

Include a short explanation in your submission:

- Which controller and adaptation did you choose?
- Show a movement sequence where the adapted controller behaves differently from the original. Use a short recording or reproducible steps with parameter values.
- Explain why you chose the change and one drawback or limitation.
- Describe how you checked it, including a boundary, timing, or direction-change case.

Supplied tests, debug drawing, recorded demonstrations, and your own tests are all useful ways to verify the change. You do not need to write additional automated tests.

## Individual Competency Profile

### Baseline Competencies

| Stage / required work | Baseline competency | Evidence |
| --- | --- | --- |
| Stage 1: Position Lock, scene binding, and debug drawing | Engine Usage — Unlocked | Uses the camera base class, scene references, and `ImmediateMesh` to implement and inspect camera behavior. |
| Stage 2: Planar Auto-Scroll | System Interrelations — Unlocked | Coordinates camera scrolling and vessel position while preserving independent player movement. |
| Stage 3: Position Lock with Smoothing | Game Systems — Unlocked | Implements movement-dependent following, catch-up, and a distance limit. |
| Stage 4: Smoothed Target Focus | Further evidence for Game Systems — Unlocked | Combines input-directed focus, target tracking, and delayed recentering. |
| Stage 5: Four-Way Speedup Push Zone, including its explanation and demonstrations | Game Systems — Developed | Generalizes the one-directional technique, combines independent axis rules, and verifies boundary crossings and frame-rate behavior. |
| Required adaptation and its evidence | Further evidence for Game Systems — Developed | Changes an existing controller to meet a new requirement and explains and verifies the result. |

The suggestions at the end of this document offer other ways to demonstrate Developed or Mastery. Claims are evaluated against the course competency criteria, not the number of features or tests added.

# Terminology and Useful Concepts

## `delta`

`delta` is the time in seconds since the previous frame. At 10 units per second, one frame's movement is:

```gdscript
distance = 10.0 * delta
```

## Linear Interpolation (`lerp`)

`lerp(a, b, t)` returns a point between `a` and `b`: `t = 0` gives `a`, `t = 1` gives `b`, and `t = 0.5` gives the midpoint.

```text
lerp(a, b, t) = a + t * (b - a)
```

Calling `position.lerp(target_position, 0.1)` moves 10% of the remaining distance each time. That is not 0.1 units per second, and repeating it once per frame makes the response frame-rate dependent. For a speed in units per second, consider `move_toward()` with a step of `speed * delta`.

## Leash

A **leash** limits camera-to-target distance on the ground plane. With `leash_distance = 10`, that distance must stay at or below 10 units even when normal following would let the target move farther away.

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

The camera stays still inside the inner zone, follows outward movement at a fraction of target speed in the surrounding region, and enforces containment at the outer boundary.

## Target Focus

A target-focus camera shows more space in the direction the player intends to travel. Stage 4 uses input for this; input and current velocity can point in different directions.

## Invariant

An **invariant** is a condition that must remain true during play. For a leashed camera:

```text
distance(camera, target) <= leash_distance
```

Other examples are keeping the target ahead of Stage 2's trailing edge and keeping Stage 5's camera still while the target is inside the inner zone. Check these conditions throughout a movement sequence, not just at the end.

## Boundary and Edge-Case Testing

For Stages 2 and 5, put the vessel's side exactly on a boundary and just to either side. In Stage 5, try outward and inward movement at the same position, then compare single-edge and corner contact. These cases exercise the rule changes that a test in the middle of a region can miss.

## `ImmediateMesh`

`ImmediateMesh` lets you build the debug lines in code. Each controller must call its `_draw_logic()` method when debug drawing is enabled; the base class declares the method but does not call it for you. Follow the mesh creation and cleanup pattern in `PushBoxCamera`.

## Tuning

Once a controller works, change its exported parameters and play it again. Try slow movement, hyper-speed movement, stops, and reversals. Check it at different frame rates as well as with the automated tests.

# Ideas for Developed or Mastery

These are optional directions, not additional requirements or automatic awards:

- **Game Systems:** For Developed, add camera behavior for a particular area or game state. For Mastery, combine several camera rules and show how they handle transitions and conflicting demands.
- **Game Design Reasoning:** For Developed, compare two camera configurations for a problem such as seeing hazards at hyper-speed. For Mastery, compare alternative designs, build one, and evaluate its benefits and drawbacks in play.
- **Engine Usage / System Interrelations:** For Developed, handle camera switches or target changes without stale offsets or timers. For Mastery, design and verify a reusable transition system that also handles interruptions.
- **Evaluation and Iteration:** For Developed, use playtesting to identify and improve a framing or timing problem. For Mastery, evaluate under several play conditions, revise the design, and show both the improvement and remaining limitations.

For a claim, identify the competency and level, link to your work, and explain how the results meet the course criteria.
