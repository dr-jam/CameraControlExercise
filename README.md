# Camera Control Exercise

## Description

Your goal is to create several swappable camera control scripts for a top-down terraforming simulator.

Camera systems are gameplay systems. A camera determines what information is available to the player, how player input is framed, and how movement feels. In this exercise you will implement several common 2D camera techniques and compare the behavior produced by each.

The primary reference for this exercise is **Scroll Back: The Theory and Practice of Cameras in Side-Scrollers** by Itay Keren, covered in class.

The exercise has four parts:

1. Implement five camera controllers.
2. Verify their behavior with automated tests.
3. Write tests of your own.
4. Adapt one of the controllers beyond the provided specification.

## Due Date and Submission

The due date for this exercise is listed in Canvas.

We will evaluate the submitted branch of your individual exercise repository as specified in Canvas. Make sure all work you want evaluated has been committed and pushed to GitHub.

Before submitting:

- Run the project.
- Run the complete public test suite.
- Make sure all five camera controllers can be selected through `CameraSelector`.
- Leave `draw_camera_logic` enabled.
- Commit your student-authored tests.
- Make sure your adaptation is present and testable.

## Assessment

You will implement, test, debug, and modify a gameplay system.

Automated tests will check much of the basic functionality. Some are included in the repository; additional tests may be used during evaluation. The tests check behavior rather than requiring one particular implementation.

Passing the supplied tests demonstrates basic correctness, but does not by itself establish Developed competency.

Your submission includes four parts:

### Camera Implementation

Implement and integrate the five controllers described below.

### Verification

Your implementation should pass the supplied tests and additional instructor tests.

Tests may check:

- controller position and movement;
- leash constraints;
- timing;
- zone boundaries;
- different target positions and velocities;
- frame-rate independence;
- exported parameters; and
- edge cases.

Do not write code that depends on particular values from the public tests. They are examples of required behavior, not a complete specification.

### Student-Written Tests

Add your own tests under:

```text
res://test/student/
```

Write at least:

1. one meaningful boundary or edge-case test for Stage 4 or Stage 5; and
2. one test for your adaptation.

A useful test establishes a condition, exercises the controller, and checks a meaningful result.

For Stage 5, possible cases include:

- just inside or outside the inner speedup zone;
- an outer pushbox edge;
- an outer pushbox corner; or
- diagonal movement while touching only one outer edge.

Tests that only check that an object exists, that a method can be called, or that a constant equals itself do not count as useful tests.

### Adaptation

After completing the five controllers, modify one of them in a small but meaningful way.

Choose **one**:

#### A. Axis-Specific Leash

Modify Stage 3 or Stage 4 so the horizontal and vertical leash distances can be tuned independently.

#### B. Distance-Sensitive Catchup

Modify Stage 3 so the camera catches up more aggressively when it is far from the target and settles more gently as it approaches.

#### C. Direction-Reversal Recentering

Modify Stage 4 so that reversing direction first brings the camera back toward the player before establishing a lead in the new direction.

Your adaptation should:

- remain designer-tunable where appropriate;
- preserve the original purpose of the controller;
- work at different frame rates;
- be visible while playing; and
- have at least one automated test.

Add a short comment near the relevant class declaration identifying the option you implemented:

```gdscript
# ADAPTATION: B - Distance-Sensitive Catchup
```

## Individual Competency Profile

This exercise can fill two competencies on the Individual Competency Profile:

| Competency | Evidence from this exercise |
| --- | --- |
| **Game Systems** | Implementing and integrating the five camera controllers; adapting one controller to satisfy a new requirement |
| **Debugging and Testing** | Using the supplied tests and debug visualization; writing meaningful tests for boundaries and the adaptation |

For **Game Systems**, completing the required controllers can support **Unlocked**. The adaptation provides the main evidence toward **Developed** because it requires changing an existing gameplay system rather than following the supplied specification.

For **Debugging and Testing**, using the supplied tests and debugging tools can support **Unlocked**. Writing useful tests of your own provides the main evidence toward **Developed**.

| Requirement | Game Systems | Debugging and Testing |
| --- | --- | --- |
| Stages 1–5 | Unlocked evidence | Supplied test evidence |
| Debug visualization | Supports system understanding | Debugging evidence |
| Passing supplied/instructor tests | Supports Unlocked | Supports Unlocked |
| Student-written edge-case test | — | Developed evidence |
| Adaptation | Developed evidence | — |
| Adaptation test | Supports adaptation | Developed evidence |

Completing this exercise does not automatically establish Mastered competency. Competency levels depend on the quality of the submitted evidence.

---

# Automated Testing

This project uses **GdUnit4**.

The same tests can be run from inside Godot while developing and headlessly during automated evaluation.

## Running Tests

Use the GdUnit4 Test Inspector inside Godot to run the supplied tests.

Run tests throughout development rather than waiting until the end.

The test directory is organized approximately as follows:

```text
test/
├── provided/
│   └── ...
└── student/
    └── ...
```

`test/provided/` contains tests supplied with the exercise.

`test/student/` contains tests written by you.

Additional instructor tests may be added during evaluation.

## What the Tests Check

The tests focus on behavior.

They generally should not care whether you use:

- `lerp`;
- `move_toward`;
- explicit velocity calculations;
- helper methods;
- additional state; or
- another reasonable implementation.

Different implementations are acceptable if they produce the required behavior.

The debug visualizations produced through `draw_logic()` are inspected by running the project rather than through image comparison.

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

- `t = 0`, the result is `a`;
- `t = 1`, the result is `b`;
- `t = 0.5`, the result is halfway between them.

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

When the target reaches one of the outer boundaries, further movement in that direction pushes the camera along with it.

Stage 2 uses a moving frame with this general behavior. Stage 5 uses an outer pushbox together with an inner speedup zone.

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
target remains inside the autoscroll frame
```

and:

```text
camera remains stationary while target is inside
the Stage 5 inner zone
```

Thinking in terms of invariants is useful both for implementation and for writing tests.

## Boundary and Edge-Case Testing

Many errors happen where behavior changes from one rule to another.

For example, Stage 5 behaves differently:

- inside the speedup zone;
- just outside the speedup zone;
- at the outer pushbox edge; and
- at a corner.

Testing positions immediately on both sides of these boundaries is often more useful than testing arbitrary positions in the middle of a region.

## `ImmediateMesh`

The supplied camera infrastructure uses an `ImmediateMesh` to draw debugging lines.

You are not expected to learn the entire `ImmediateMesh` API for this exercise. Use `PushBoxCamera` as the example for how to draw the required lines.

These lines make otherwise invisible camera state visible while debugging.

---

# Exercise Stages

The following requirements apply to all five stages:

- Each controller should extend `CameraControllerBase`.
- Add each controller as a child of the `World` node.
- Bind the `Vessel` node to the `Target` exported field through the editor.
- Bind the controllers to the `Array[CameraControllerBase]` in `CameraSelector`.
- Expose the listed parameters in the editor.
- Camera speeds should use units per second where appropriate and account for `delta`.
- Controllers should behave consistently at different frame rates.
- Use the supplied `ImmediateMesh` through `draw_logic()` to visualize important camera logic when `draw_camera_logic` is true.
- Draw debug lines at the same vertical level as the `Vessel`.
- `PushBoxCamera` provides an example.
- Leave `draw_camera_logic` enabled in the submitted project.

The debug display should make the controller easier to understand. It is a debugging tool, not decoration.

---

## Stage 1 — Position Lock

Implement a simple position-locking camera.

The camera should always be centered on the `Vessel`.

There are no additional exported fields.

When `draw_camera_logic` is true, draw a **20 by 20 unit cross** at the center of the camera.

This type of camera can be found in games such as *Terraria*.

### Things to Verify

- Moving the vessel immediately moves the camera.
- The camera remains centered on the vessel.
- Horizontal and vertical movement both work.
- The debug cross follows the camera center.

---

## Stage 2 — Framing with Horizontal Auto-Scroll

In the grand tradition of shmups, this controller implements a frame-bound autoscroller.

The player should be able to move freely inside a rectangular frame. The camera and frame continuously move across the `x-z` plane according to `autoscroll_speed`.

If the player falls behind the scrolling frame and reaches its trailing edge, the frame should push the player forward so the player cannot leave through that edge.

When `draw_camera_logic` is true, draw the frame border.

### Required Exported Fields

```gdscript
Vector2 top_left
Vector2 bottom_right
Vector3 autoscroll_speed
```

- `top_left` — top-left corner of the frame relative to the camera.
- `bottom_right` — bottom-right corner of the frame relative to the camera.
- `autoscroll_speed` — units per second that the camera scrolls along each axis. For this exercise, movement should be limited to the `x` and `z` axes.

This type of camera can be found in games such as *Scramble*.

### Things to Verify

- The camera moves independently of player input.
- The target can move freely inside the frame.
- The target cannot fall behind the trailing edge.
- Changing `autoscroll_speed` changes the scrolling rate.
- Behavior remains consistent at different frame rates.

---

## Stage 3 — Position Lock with Smoothing

This controller is based on Stage 1, but the camera should not immediately center itself on the target.

Instead, the camera approaches the target over time.

While the player is moving, the camera should follow at `follow_speed`. This should generally be slower than the player's movement speed, allowing some separation between the player and camera.

When the player stops, the camera should move toward the player at `catchup_speed`.

The distance between the vessel and camera should never exceed `leash_distance`.

You may implement the smoothing with interpolation or another reasonable method. The important part is the resulting behavior.

When `draw_camera_logic` is true, draw a **20 by 20 unit cross** at the center of the camera.

### Required Exported Fields

```gdscript
float follow_speed
float catchup_speed
float leash_distance
```

- `follow_speed` — speed at which the camera follows a moving target.
- `catchup_speed` — speed at which the camera catches up after the player stops.
- `leash_distance` — maximum distance between the vessel and camera center.

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

When movement input is provided, the camera should move ahead of the player in that direction. This gives the player additional screen space in the direction they are trying to travel.

The distance between camera and target may increase while the player is moving, but it must never exceed `leash_distance`.

When movement stops, the camera should remain in its lead position. After `catchup_delay_duration`, it should begin moving back toward the target at `catchup_speed`.

When `draw_camera_logic` is true, draw a **20 by 20 unit cross** at the camera center.

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

1. an inner **speedup zone**; and
2. an outer **pushbox**.

Treat horizontal and vertical movement independently. You can think of the system as four speedup-push zones operating together.

### Inside the Inner Zone

When the target is inside the inner speedup zone, the camera should remain stationary.

### Between the Inner and Outer Zones

When the target is:

1. moving;
2. outside the inner speedup zone;
3. inside the outer pushbox; and
4. moving farther into the corresponding push region,

the camera should move in that direction at the target's movement speed multiplied by `push_ratio`.

### Touching One Outer Edge

When the target reaches one side of the outer pushbox, the camera should move at the target's full speed along that axis.

Movement along the other axis should continue to use normal speedup-zone behavior.

For example, if the target touches the top edge while moving toward the upper-right, the camera should move at full target speed vertically while still using `push_ratio` horizontally when appropriate.

### Touching a Corner

If the target reaches two outer edges at once, the camera should move at the target's full movement speed on both affected axes.

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

The one-directional version of this technique is famously used in *Super Mario Bros.*

### Things to Verify

Pay particular attention to boundaries:

- center of the inner zone;
- just inside an inner-zone edge;
- just outside an inner-zone edge;
- middle of each speedup region;
- each outer pushbox edge;
- each outer pushbox corner;
- diagonal movement;
- movement back toward the inner zone; and
- different values of `push_ratio`.

---

# Student-Written Tests

Your tests belong in:

```text
res://test/student/
```

Do not modify the supplied tests simply to make a failing implementation pass.

## Required Edge-Case Test

Write at least one meaningful test for an edge or boundary condition in Stage 4 or Stage 5 that is not already covered by the supplied tests.

The test should make clear:

- what condition is being established;
- what behavior is expected; and
- what property is being checked.

## Required Adaptation Test

Write at least one test demonstrating the behavior added by your adaptation.

The test should fail if the adaptation is removed.

---

# Debug Visualization

Camera controllers contain important state that is otherwise invisible.

Use `draw_logic()` to expose that state.

Depending on the controller, useful things to draw include:

- camera center;
- frame boundaries;
- leash distance;
- speedup-zone boundaries;
- pushbox boundaries; or
- other positions that affect camera behavior.

Someone inspecting the controller should be able to understand why the camera is moving by looking at the debug representation.

Do not spend time making it decorative.

---

# Some Advice

## Work Incrementally

Do not implement all five controllers before testing.

A better process is:

```text
Implement a small behavior
        ↓
Run the relevant tests
        ↓
Play the controller
        ↓
Inspect the debug visualization
        ↓
Fix problems
        ↓
Continue
```

Automated tests and playing the game answer different questions. Use both.

## Think in Terms of Invariants

Many camera requirements can be expressed as statements that should always remain true.

For example:

```text
distance(camera, target) <= leash_distance
```

or:

```text
target remains inside the autoscroll frame
```

or:

```text
camera remains stationary while target is inside the Stage 5 inner zone
```

Thinking this way often makes both the implementation and tests simpler.

## Be Careful with `delta`

Camera speeds in this assignment are generally expressed in units per second.

A controller that works at one frame rate but moves twice as fast at another is not correct.

Test your code under different conditions rather than assuming the frame rate will remain constant.

## Tune the Cameras

The exported variables are there for a reason.

After a controller works, change its parameters and play the result. Two correct camera systems can create very different experiences depending on their tuning.

The goal is not just to make the camera move, but to understand why you would choose one behavior over another.

---

---

# Optional Competency Claims

You may make up to two additional competency claims at Developed or Mastery. Point to specific files, tests, commits, or features. Say what you changed, why it matters, and how it goes beyond the default exercise requirements.

For each claim, add:

```text
Competency:
Level: Developed or Mastery
Evidence:
Explanation:
```

These claims are optional. The required work already provides the competency evidence described earlier in this document.

## Developed and Mastery

A **Developed** claim should show that you can use the competency in a changed or less-guided situation. Make a meaningful implementation or design decision, go beyond the supplied example or required minimum, verify that the result works, deal with at least one nontrivial case, and explain your approach.

A **Mastery** claim should show independent technical judgment. Identify a real problem or limitation yourself, design and implement a solution, consider credible alternatives, test normal and failure cases, and explain the tradeoffs.

More code does not automatically mean Mastery.

## Likely Competencies for This Exercise

**Debugging and Testing**  
Developed: Add tests or diagnostics beyond the required checks. Useful cases include timing, frame-rate dependence, boundary behavior, overshoot, or unusual target movement.  
Mastery: Build a testing or diagnostic setup that helps you reason about camera behavior across several controllers or conditions.

**Engine Usage**  
Developed: Use Godot systems deliberately to solve a new camera problem. Input handling, node lifecycle, exported properties, scene structure, physics processing, and debug drawing are all reasonable places to look.  
Mastery: Make a larger architectural decision about camera ownership, updates, targets, configuration, or reuse, and justify it from the behavior of your project.

**Game Systems**  
Developed: Add or substantially revise camera rules, state, or behavior so that the game plays differently. Do not just add another controller that follows one of the existing templates.  
Mastery: Build a camera system with enough interacting rules that movement, input, location, or game state produce meaningfully different camera behavior, then explain those interactions.

**System Interrelations**  
Developed: Show that the camera, player movement, input, world state, and other gameplay systems cooperate correctly at their boundaries.  
Mastery: Restructure or extend those interactions without muddying responsibilities. Changes of target, interruptions, transitions between camera behaviors, and unusual movement states are good places to look.

**Game Design Reasoning**  
Developed: Use camera design principles to make and explain a change to framing, focus, smoothing, anticipation, or player visibility.  
Mastery: Compare credible camera approaches, choose one for a particular gameplay problem, implement it, and explain why its tradeoffs are preferable in that context.

**Interaction Design**  
Developed: Improve camera timing, framing, responsiveness, or visual focus in a noticeable way.  
Mastery: Make a substantial interaction change, evaluate it in play, and revise it based on what you find.

**Evaluation and Iteration**  
Developed: Identify a camera problem through play, make a targeted change, and show that the revision improved the intended behavior.  
Mastery: Evaluate a camera system under several relevant play conditions, make a substantial revision, and explain both the improvement and the remaining tradeoffs.

## Tests and Competency Levels

Passing the supplied tests shows that the required behavior works. Completing the required adaptation and student-written tests also counts toward the default competencies described earlier.

Optional higher-level claims should come from work you added beyond the guided path: additional adaptations, tests, diagnostics, design decisions, evaluations, or extensions.
