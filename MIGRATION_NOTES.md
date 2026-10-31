# Fallen Princess — Godot 4.7 TileMap migration

This is a copy of your project with the level's legacy Godot 4.2-style TileMap converted into three Godot 4.7 `TileMapLayer` nodes.

## Changes

- `scenes/game.tscn`: changed the old `TileMap` into a `Node2D` container at exactly the original location (`Vector2(-1, 0)`).
- Rebuilt `Background` (5472 painted cells), `Zwischenlayer` (9 painted cells), and `Mid` (527 painted cells) as separate `TileMapLayer` nodes.
- Converted every original cell directly from legacy `PackedInt32Array` records to Godot 4.7 `PackedByteArray` records **without changing any coordinates, tile references, or transformations**.
- Preserved the original TileSet resource and its existing collision polygons. `Mid` (gameplay) physics is enabled; the other two layers have physics disabled because their painted tiles have no collision polygons.
- Left game scripts, camera, enemy, visuals, level layout, and player settings unchanged.

## How to check

1. Open `project.godot` using Godot 4.7 or 4.7.2 (4.7.2 is a compatible patch release).
2. Play the scene and use **Debug > Visible Collision Shapes** to inspect the sand ground after the slime.
3. In the scene tree, check **TileMap > Mid**. This is the gameplay tile layer. Its **Collision Enabled** property should be checked.
4. To inspect actual shapes: select **Mid**, select its TileSet and Physics Layer 0. The brown and sand tiles in the first three atlas rows have collision polygons.

Note: At the far right of the stretch with the slime (roughly tile X=46 onward), the original level has an unfilled gap before the next platform. A deliberate gap can still cause the player to fall if they don't jump. This migration keeps that layout intact.

## Validation notes

The byte-level conversion was round-trip validated for all 6008 cells. The TileMapLayer physics quadrant size was reduced from the default 16 to 1 to avoid the known engine error `decompose_many_polygons_in_convex: Convex decomposing failed!` (https://github.com/godotengine/godot/issues/104452). This uses a separate physics quadrant per tile, preventing failed chunk merges. The project was statically validated, but could not be run in Godot in this environment; please verify the sand collision during gameplay. If sand collision is still missing in your copy of Godot 4.7, please provide the exact location (screenshot with Debug > Visible Collision Shapes on) and Godot version (4.7.0 versus 4.7.2) for a more targeted change.

## HUD warnings corrected for Godot 4.7

- `GameManager/ScoreLabel`: added `custom_maximum_size = Vector2(90, -1)` to retain its original 90-pixel width and autowrapping, while giving Godot a positive width limit.
- `Control/UI/Panel/FPSMeter` and `Control/UI/Panel/CoinCounter`: removed their `clip_children = 2` settings. Their ancestor `Panel` still clips its children, and Godot does not support nested clipping.
- No gameplay, scripts, tile positions, or existing collision changes were modified by this HUD update.

## Godot 4.7: Scene root transform warning (fixed)

The Game root previously had `position = Vector2(0, 48)`, which triggers the Godot warning when a scene is instanced. The root is now at the identity transform. An unscaled `Node2D` child called `SceneOffset` holds exactly the old `(0, 48)` offset, and every existing node was reparented below it without changing any node-local position, script, tile data, or resources. Relative paths between gameplay nodes are unchanged (e.g. GameManager's player path). Do not change the `SceneOffset` position unless you want to shift the whole level.

## Shader cache error (requires cleaning Godot's local cache)

`shader_rd.cpp:633 - Condition "header != String(shader_file_header)" is true` means Godot tried reading a cached RenderingDevice shader, but the file's header was invalid. This cache lives outside the project ZIP, so repackaging the level cannot delete it on your machine.

1. Close Godot completely (including any running game).
2. In your project directory, delete the *generated* `.godot` folder (not `project.godot`, not any scene or asset files). The ZIP itself deliberately contains no `.godot` cache.
3. Also delete ONLY the `shader_cache` directory inside Godot's user data for `Fallen Princess`, if it exists:
   - Windows: `%APPDATA%\Godot\app_userdata\Fallen Princess\shader_cache`
   - macOS: `~/Library/Application Support/Godot/app_userdata/Fallen Princess/shader_cache`
   - Linux: `~/.local/share/godot/app_userdata/Fallen Princess/shader_cache`
   You can reach the user data folder from Godot: Project -> Open User Data Folder, then close Godot before deleting the cache.
4. Reopen `project.godot` using exactly your Godot 4.7 build. The first shader compile may take longer.
5. If the shader error persists, check the actual cache path and graphics driver, or try the Compatibility renderer as a diagnostic (don't switch renderer permanently unless needed).

Note: The cache error is an engine-side error, not evidence that any custom shader or gameplay code is broken. This project does not include custom shader files.
