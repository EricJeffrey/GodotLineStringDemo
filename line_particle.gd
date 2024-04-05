extends CharacterBody3D

var old_pos = Vector3.ZERO
var now_pos = Vector3.ZERO
var locked = false

func initialize(pos, lock):
	position = pos
	old_pos = pos
	now_pos = pos
	locked = lock

func update_pos(new_now_pos, new_old_pos):
	old_pos = new_old_pos
	now_pos = new_now_pos;
	position = new_now_pos

