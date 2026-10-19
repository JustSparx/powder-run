# Powder Run

A downhill snowboarding game built with **Godot 4.7**.

Right now it's a playable starter: a 600 m slope at 15°, a placeholder boarder that carves, skids and jumps, a chase camera, scattered pines and a speed readout.

## Run it

1. Open Godot 4.7 and choose **Import**, then select `project.godot` in this folder.
2. Press **F5**.

## Controls

| Action | Keyboard | Gamepad |
|---|---|---|
| Carve left / right | A / D or ← / → | Left stick |
| Brake (skid) | S or ↓ | — |
| Jump | Space | A / Cross |
| Reset to top | R | — |

## How the riding works

`scripts/boarder.gd` is a `CharacterBody3D`:

- **Gravity** is projected onto the slope, so steeper ground means faster acceleration.
- **Carving** rotates the board. Velocity that isn't along the board gets scrubbed off over time (`carve_grip`), so hard turns cost speed. Holding **brake** raises the grip, which skids you to a stop.
- The board keeps its own along-slope velocity (`_ride`). Godot's `move_and_slide()` flattens *and* shortens velocity on floors, which would otherwise cap the speed at about 1 m/s.

Every tuning value is an `@export`, so you can change them in the Inspector.

## Layout

```
scenes/main.tscn        slope, boarder, camera, lighting, HUD
scripts/boarder.gd      riding physics
scripts/chase_camera.gd smoothed follow camera
scripts/main.gd         tree scattering + HUD
```

## Ideas / next steps

- Real terrain (heightmap or a Blender-authored GLB) in place of the box slope
- Boarder model with lean/crouch animation tied to carve input
- Snow spray particles and carve trails
- Gates, timer, and a finish line
- Tricks and landing scoring
