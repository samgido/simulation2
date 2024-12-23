package main

import "vendor:raylib"

RenderFish :: proc(fishes: ^[dynamic]Fish) {
	for i := 0; i < len(fishes); i += 1{
		raylib.DrawCircle(cast(i32)fishes[i].position.x, cast(i32)fishes[i].position.y, FISH_SIZE, fishes[i].color)
	}	
}