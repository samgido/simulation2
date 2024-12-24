package main

import "vendor:raylib"
import "core:math/rand"
import "core:math"
import "core:fmt"

FISH_SIZE: f32 : 3

FISH_COMFORT_MIN : f32 : 10

FISH_TO_AVERAGE_COMFORT_RANGE : f32 = math.sqrt(((math.PI * FISH_COMFORT_MIN * FISH_COMFORT_MIN) * cast(f32)INITIAL_FISH_COUNT) / math.PI)

FISH_SHARK_DETECTION_RADIUS : f32 : 40

// pixels per second
FISH_MAX_SPEED : f32 : 300

FISH_SCARED_SPEED_MULTIPLIER : f32 : 100

Fish :: struct {
	position: raylib.Vector2,
	velocity: raylib.Vector2, 
	color: raylib.Color,
	comfort: f32,
	shark: bool
}

MakeNFish :: proc(fishes: ^[dynamic]Fish, n: int, spawn_pos: raylib.Vector2, max_variance: int) -> ^[dynamic]Fish {
	for len(fishes) < n {
		fish_x := cast(f32)spawn_pos.x + ( cast(f32)max_variance * 2 * (rand.float32() - 0.5) )
		fish_y := cast(f32)spawn_pos.y + ( cast(f32)max_variance * 2 * (rand.float32() - 0.5) )

		fish_pos := raylib.Vector2 { fish_x, fish_y }

		if IsOutOfBoundsX(fish_pos) || IsOutOfBoundsY(fish_pos) { continue }

		new_fish := Fish {
			raylib.Vector2 { fish_x, fish_y },
			raylib.Vector2 { 0, 0 },
			raylib.WHITE,
			0.0,
			false
		}

		append(fishes, new_fish)
	}

	return fishes
}