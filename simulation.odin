package main

import "vendor:raylib"
import "core:math"
import "core:fmt"

StepSimulation :: proc(fishes: ^[dynamic]Fish) {
	for i := 0; i < len(fishes); i += 1 {
		// Move fish
		MoveFish(&fishes[i])

		// Update velocity
		UpdateVelocity(i, fishes)
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

UpdateVelocity :: proc(current_index: int, fishes: ^[dynamic]Fish) {
	closest_fish: Fish
	closest_distance: f32 = 1000

	{ // Find closest fish / check for shark in radius
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
		if (closest_distance == 1000) { return }
	}

	{ // Update fish velocity 
		average_position := FindAveragePosition(current_index, fishes)

		if closest_fish.shark {
			fishes[current_index].velocity = -1 * (closest_fish.position - fishes[current_index].position) * FISH_SCARED_SPEED_MULTIPLIER
		} else if closest_distance < FISH_COMFORT_MIN { // too close, move away from average
			speed_ratio := FISH_COMFORT_MIN / closest_distance	

			fishes[current_index].velocity = -1 * raylib.Vector2Normalize(closest_fish.position - fishes[current_index].position) * ( speed_ratio * FISH_MAX_SPEED )
		} else if math.abs(raylib.Vector2Distance(average_position, fishes[current_index].position)) > FISH_TO_AVERAGE_COMFORT_RANGE / 3  {
			fishes[current_index].velocity = raylib.Vector2Normalize(average_position - fishes[current_index].position) * FISH_MAX_SPEED
		}
		else { fishes[current_index].velocity = 0 }
	}
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