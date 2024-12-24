package main

import "vendor:raylib"
import "core:math"
import "core:fmt"

StepSimulation :: proc(fishes: ^[dynamic]Fish, shark: ^Fish) {
	for i := 0; i < len(fishes); i += 1 {
		// Move fish
		MoveFish(&fishes[i])

		// Update velocity
		UpdateVelocity(i, fishes, shark)

		// Update Shark
	}
}

MoveFish :: proc(fish: ^Fish) {
	movement := (fish.velocity * raylib.GetFrameTime())
	new_pos := fish.position + movement
	magnitude := raylib.Vector2Length(movement)

	oob_x := IsOutOfBoundsX(new_pos)
	oob_y := IsOutOfBoundsY(new_pos)

	if !oob_x && !oob_y { 
		fish.position = new_pos 
		return
	}

	if oob_x {
		movement.x *= -1
	}
	if oob_y {
		movement.y *= -1
	}

	fish.position = fish.position + movement
}

UpdateVelocity :: proc(current_index: int, fishes: ^[dynamic]Fish, shark: ^Fish) {
	closest_fish: Fish
	closest_distance: f32 = 1000

	{ // Find closest fish / check for shark in radius
		distance_to_shark := raylib.Vector2Distance(fishes[current_index].position, shark.position)
		if distance_to_shark < cast(f32)FISH_SHARK_DETECTION_RADIUS {
			closest_distance = distance_to_shark	
			closest_fish = shark^
		}
		else {
			for i := 0; i < len(fishes); i += 1 {
				if i == current_index { continue }

				distance := raylib.Vector2Distance(fishes[current_index].position, fishes[i].position)

				if fishes[i].shark && distance < cast(f32)FISH_SHARK_DETECTION_RADIUS {
					closest_distance = distance
					closest_fish = fishes[i]
					break
				}

				// Was assigning closest_fish to shark even when it wasn't in detection radius
				// So; added condition
				if distance < closest_distance && !fishes[i].shark {
					closest_distance = distance
					closest_fish = fishes[i]
				}
			}
		}
		if (closest_distance == 1000) { return }
	}

	{ // Update fish velocity 
		fishes[current_index].velocity = 0

		average_position := FindAveragePosition(current_index, fishes)

		if closest_fish.shark {
			speed_ratio := 1 - (closest_distance / FISH_SHARK_DETECTION_RADIUS)

			fishes[current_index].velocity += -1 * raylib.Vector2Normalize(closest_fish.position - fishes[current_index].position) * (speed_ratio * FISH_MAX_SPEED) * FISH_SCARED_SPEED_MULTIPLIER
		} else if FISH_COMFORT_MIN - closest_distance > 0.1 { // too close, move away from average
			speed_ratio := 1 - (closest_distance / FISH_COMFORT_MIN)

			fishes[current_index].velocity += -1 * raylib.Vector2Normalize(closest_fish.position - fishes[current_index].position) * ( speed_ratio * FISH_MAX_SPEED )
		}

		if raylib.Vector2Distance(average_position, fishes[current_index].position) > FISH_TO_AVERAGE_COMFORT_RANGE {
			fishes[current_index].velocity += raylib.Vector2Normalize(average_position - fishes[current_index].position) * FISH_MAX_SPEED
		} else {
			fishes[current_index].velocity += raylib.Vector2Normalize(average_position - fishes[current_index].position) * FISH_MAX_SPEED * .2
		}
	}
}

UpdateShark :: proc(shark: ^Fish, fishes: ^[dynamic]Fish) {
	// school_position := FindAveragePosition(-1, fishes)
	school_position := raylib.Vector2 { cast(f32)raylib.GetScreenWidth() / 2, cast(f32)raylib.GetScreenHeight() / 2 } 
}

FindAveragePosition :: proc(excluded_index: int, fishes: ^[dynamic]Fish) -> raylib.Vector2 {
	average := raylib.Vector2 { 0, 0 }

	for i := 0; i < len(fishes); i += 1 {
		if i == excluded_index { continue }
		if fishes[i].shark { continue }

		average += fishes[i].position
	}

	return average / cast(f32)(len(fishes) - 1)
}

IsOutOfBoundsY :: proc(v: raylib.Vector2) -> bool {
	return v.y < 0 || v.y >= cast(f32)raylib.GetScreenHeight()
}

IsOutOfBoundsX :: proc(v: raylib.Vector2) -> bool {
	return v.x < 0 || v.x >= cast(f32)raylib.GetScreenWidth()
}	
