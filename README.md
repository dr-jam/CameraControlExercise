# Camera Control Exercise

## Description

Your goal is to create several swappable camera control scripts for a top-down terraforming simulator.

Here is the document covered in class that details the type of camera controllers you are to implement for this exercise:  
[Scroll Back: The Theory and Practice of Cameras in Side-Scrollers](https://www.gamedeveloper.com/design/scroll-back-the-theory-and-practice-of-cameras-in-side-scrollers) by Itay Keren.  

The images in the *Exercise Stages* section are taken from Itay Karen's document.

### Grading

Stage 1, 2, 3, and 4 are worth 15 points each. Stages 5 is worth 10 points. The stages are worth a total of 70 points. The remaining 30 points are for your peer-review of another student's submission.

### Due Date and Submission Information

See Canvas for the due date. This exercise will be sumbitted on GitHub Classroom. The master branch as found on your individual exercise repository will be evaluated.

## Exercise Stages 

The following are basic criteria for each stage:
* Each stage requires you to implement a type of camera controller. 
* Each of your 5 controllers should inherit `AbstractCameraController` and be in the `Obscura` namespace. 
* Each of your camera controller implementations should be added as a component to the `Main Camera`  object in the hierarchy.
* You should bind the `Player` `GameObject` to the `Target` serialized field via the editor for each one of your cameras.
* Only one camera controller script on `Main Camera` should be enabled at any given time. (You can disable components of a `GameObject` by unchecking the box next to the component's name.)
* Most controllers will require you to expose fields to the Unity inspector to allow a designer to parameterize the controller's function (e.g. the size of a bounding box, the speed of scrolling, the speed of lerping, etc.). Each controller has its own list of required fields to serialize. Serialized variables should be `private` unless there is a particular need for them to have another access modifier. You can serialize any field in a C# class by prepending a `[SerializeField]` meta-tag before the field's declaration. This can be seen in the `AbstractCameraController` abstract class.
* Each camera controller should use the `LineRenderer` required component to visualize the camera controller's logic when the `DrawLogic` serialized field is true. The lines should be drawn at the same `z` value as the `Player` `GameObject`. See the `PushBoxCamera` class for an example.
* Your camera controllers should be immediately testable by your peer-reviewer and should have `DrawLogic` set to true by default and in your submitted project.

## Stage 1 - position lock: `PositionLockCameraController.cs`

This camera controller should always be centered on the Player `GameObject`. There are no additional fields to be serialized and usable in the inspector.

Your controller should draw a 5 by 5 unit cross in the center of the screen when `DrawLogic` is true. 

![position-locking](https://lh6.googleusercontent.com/Bh_vzER7pXFZgRMsi158LA_q3Dg9LnykuR1cW3f8K8hgSI-BlNKLfocuGAhHRxbrcaeadtay_MgS55CO4eD0jyDIy0QB9SvAPHFnWQlDMKfN9QQJkL4RxAKc28_ymrCz) as found in Terraria, ©2011 Re-Logic.

## Stage 2 - framing with horizontal auto-scroll: `FrameAutoScrollCameraController.cs`

In the grand tradition of [shmups](http://www.shmups.com/), this camera controller implements a frame-bound autoscroller. The player should be able to move inside of a box that is constantly moving along the positive x-axis. If the player is lagging behind and is touching the left edge of the box, the player should be pushed forward by that box edge.

Your controller should draw the frame border box when `DrawLogic` is true. 

Required serialized fields:
* `Vector3 topLeft` - the top left corner of the frame border box.
* `Vector3 bottomRight` - the bottom right corner of the frame border box.
* `float autoScrollSpeed` - the number of Unity units per second to scroll.

![auto-scroll](https://lh3.googleusercontent.com/ob8Z5bAdjxI6C9hgzL1-EcIPNeUCxCGHuOK7TaQoGtkq0iczuaSw3usLF9oYhqJfrRWQTmsRFTNqoYNoX9KjHTsuOC_auBY68C24FQEN-a3a11bM25xQdfAZ8Ls7RuxS) as found in Scramble, ©1981 Konami.

## Stage 3 - position lock with camera following: `PositionFollowCameraController.cs`

This camera controller generally behaves like the position lock controller from Stage 1. The major difference is that it does not immediately center on the player as the player moves. Instead, it moves the camera's position toward the player's position on `LateUpdate()` with the player's speed times the `followSpeedFactor` (see below). When the distance between the player and the camera reaches `leashDistance`, the camera should move a the same speed as the player. When the player is not moving, the camera should move toward the player with `catchUpSpeed`. The camera should not move when the player is not moving and the camera and the player are at the same position.

Your controller should draw a 5 by 5 unit cross in the center of the screen when `DrawLogic` is true.

You may use lerp to manage camera motion.

Required serialized fields:
* `float followSpeedFactor` - The fraction of the player's movement speed that is set to the camera's chasing speed.
* `float leashDistance` - The camera should move at the same speed as the player when they are `leashDsitance` apart.
* `float catchUpSpeed` - The camera should move `catchUpSpeed` toward the player when the player is not moving.

![position-locking with lerp-smoothing](https://lh3.googleusercontent.com/Lo1c9W3Yo0VQzf6mxAssaqXS7RoELziUwPbowklnCsI4BiqR46vYeejQPhjgZla3AR6INwVy6tCoXog4_Yc85DmlPcOapN_DjoRz6CRgD3nvTaGWkPm3cmaNpKj2tWiO) as found in Super Meat Boy, ©2010 Team Meat.

## Stage 4 - smoothing target focus: `TargetFocusCameraController.cs`

This stage requires you to create a variant of the position-lock focus-smoothing controller. The variation is that the center of the camera leads the player in the direction of the player's input. The position of the camera should move to the player's position. Much like stage 3's controller, this controller should update when movement input is given and the camera should only be settled on the player when the player has not moved for the `IdleDuration`. The camera should not exceed `leadMaxDistance` from the player.

Your controller should draw a 5 by 5 unit cross in the center of the screen when `DrawLogic` is true.

You may use lerp to manage camera motion.

Required serialized fields:
* `float idleDuration` - the time it should take for the camera to catch up to the player's location.
* `float leadSpeed` - the speed at which the camera moves toward the direction of the input. This should be faster than the `Player`'s movement speed.
*  `float leadMaxDistance` - the maxiumum distance the camera the player in the x and y plane. Do not include z plane values in this distance calculation.

![lerp-smoothing with target-focus](https://lh3.googleusercontent.com/-zeUJrdvmQnbB8stwBJ-P9spyZVEJIHtxDATQPkniX1hc35Y6oCLXQaqfcCmKn_Sd1cXSHN2MF2BWn1SLmoAvQbg6rCC6h_HQtqEkplanN3iaXjNgDdixCf5SSdw-YTm) as found in Jazz Jackrabbit 2, ©1998 Epic Games.

## Stage 5 - 4-way speedup push zone: `FourWaySpeedupPushZoneCameraController.cs`

This camera controller should implement a 4-directional version of the speedup push zone as seen in Super Mario Bros. The controller should move at the speed of the `Player` multiplied by the `PushRatio` required serialized field in the direction of player movement when the player is 1) moving and 2) not touching the outer push zone border box. When the player is touching one side of the push zone border box, the camera will move at the player's current movement speed in the direction of the touched side of the border box and at the `PushRatio` in the other direction (e.g. when the player is touching the top middle of the pushing box but is moving to the upper right, the camera will move at player speed in the y direction but at the `PushRatio` in the x direction). If the player is touching two sides of the speedup push box (i.e. the player is in the corner of the box), the camera will move at full player speed in both x and y directions. To get the current speed or direction of the player, call the `GetCurrentSpeed()` and `GetMovementDiection()` methods from the `PlayerController` respectively.

Your controller should draw the push zone border box when `DrawLogic` is true. 

Required serialized fields:
* `float pushRatio` - the ratio that the camera should move toward `Player` when it is not at the edge of the push zone border box.
* `Vector3 topLeft` - the top left corner of the push zone border box.
* `Vector3 bottomRight` - the bottom right corner of the push zone border box.

![1-way speedup push zone](https://lh6.googleusercontent.com/uuYbEkabfImuD-zi06EV57-pWfdrM7fcFsZxFXZVIfr5dFijpk_AXeRkR9K55wiqYl6IH7bMc15SEr8YzQFmHiBdvk6WntvSmkTvdDupe1y57R33AkxEXiDYif4AOUEY) as found in Super Mario Bros., ©1985 Nintendo.

## Resources and Hints

* [Unity Documentation for Vector3.Lerp](https://docs.unity3d.com/ScriptReference/Vector3.Lerp.html)
* [Additional interpolation methods](http://wiki.unity3d.com/index.php?title=Mathfx)
