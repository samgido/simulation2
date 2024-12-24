package main

import "core:fmt"
import "vendor:raylib"

INITIAL_FISH_COUNT: int : 300
FISH_SPAWN_VARIANCE: int : INITIAL_FISH_COUNT * 3

main :: proc() {
	raylib.InitWindow(1280, 720, "Shart and Minus v2")

	fishes: [dynamic]Fish 
	shark: Fish

	{ // Initialization
		shark = Fish {
			raylib.Vector2(0),
			raylib.Vector2(0),
			raylib.BLUE,
			0,
			true
		}

		fishes = MakeNFish(&fishes, INITIAL_FISH_COUNT, raylib.Vector2 { cast(f32)(raylib.GetScreenWidth() / 2), cast(f32)(raylib.GetScreenHeight() / 2) }, FISH_SPAWN_VARIANCE)^
	}

	sim_paused := false

	for !raylib.WindowShouldClose() {
		raylib.BeginDrawing()
		raylib.ClearBackground(raylib.BLACK)

		{ // Input
			shark.position = raylib.Vector2 {cast(f32)raylib.GetMouseX(), cast(f32)raylib.GetMouseY() }

			if raylib.IsKeyPressed(raylib.KeyboardKey.Q) {
				sim_paused = ! sim_paused
			}

			if raylib.IsMouseButtonPressed(raylib.MouseButton.LEFT) {
				position := raylib.Vector2 { cast(f32)raylib.GetMouseX(), cast(f32)raylib.GetMouseY() }

				append(&fishes, Fish {
					position,
					raylib.Vector2(0),
					raylib.WHITE,
					0,
					false,
				})
			}	
		}

		{ // Process Fish
			if !sim_paused {
					StepSimulation(&fishes, &shark)
			}
		}

		{ // Rendering 
			raylib.DrawCircle(raylib.GetScreenWidth()/2, raylib.GetScreenHeight()/2, FISH_TO_AVERAGE_COMFORT_RANGE, raylib.RED)

			RenderFish(&fishes)

			sim_paused_label_x: i32 = 20
			sim_paused_label_y := sim_paused_label_x
			if sim_paused { raylib.DrawText("Simulation Paused", sim_paused_label_x, sim_paused_label_y, 12, raylib.WHITE) } 
			else { raylib.DrawText("Simulation Running", sim_paused_label_x, sim_paused_label_y, 12, raylib.WHITE) }
		}

		raylib.EndDrawing()
	}

	raylib.CloseWindow()
}
