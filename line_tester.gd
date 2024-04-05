extends Node3D

@export var line_particle : PackedScene;

const SPEED = 2
const GRAVITY = 10
const PARTICLE_CNT = 200
const STICK_CNT = PARTICLE_CNT - 1
const STICK_STIFFNESS = 20

class Stick extends Object:
	var particle_a;
	var particle_b;
	var length;

	func _init(pa, pb):
		particle_a = pa;
		particle_b = pb;
		length = (particle_b.now_pos - particle_a.now_pos).length()

var particles = []
var sticks = []

func _ready():
	var init_pos = $Pivot.position
	for _i in range(PARTICLE_CNT):
		var tmp_particle = line_particle.instantiate()
		tmp_particle.initialize(init_pos + Vector3(0, -_i * 0.05, 0), (_i == 0));
		particles.append(tmp_particle)
		if _i != 0:
			var tmp_stick = Stick.new(particles[_i - 1], tmp_particle)
			sticks.append(tmp_stick)
		add_child(tmp_particle)

func update_particle_pos(delta):
	for i in range(PARTICLE_CNT):
		var p = particles[i]
		if !p.locked:
			var tmp_pos = Vector3(p.now_pos)
			var new_pos = p.now_pos + (p.now_pos - p.old_pos) + delta * delta * Vector3(0, -GRAVITY, 0)
			p.update_pos(new_pos, tmp_pos)

	for _i in range(STICK_STIFFNESS):
		for j in range(STICK_CNT):
			var stick = sticks[j]
			var delta_vec = stick.particle_b.now_pos - stick.particle_a.now_pos
			var delta_vec_len = delta_vec.length()
			var diff = (delta_vec_len - stick.length) / delta_vec_len
			if !stick.particle_a.locked:
				var tmp_new_pos = stick.particle_a.now_pos + 0.5 * diff * delta_vec
				stick.particle_a.update_pos(tmp_new_pos, stick.particle_a.old_pos)
			if !stick.particle_b.locked:
				var tmp_new_pos = stick.particle_b.now_pos - 0.5 * diff * delta_vec
				stick.particle_b.update_pos(tmp_new_pos, stick.particle_b.old_pos)

func _process(delta):
	var direction_vector = Input.get_vector("left", "right", "forward", "backward")
	var direction = Vector3(direction_vector.x, 0, direction_vector.y)
	var new_pos = Vector3(particles[0].now_pos)
	if direction:
		new_pos.x += direction.x * delta * SPEED
		new_pos.z += direction.z * delta * SPEED
	if Input.is_action_pressed("jump"):
		new_pos.y += delta * SPEED
	if Input.is_action_pressed("down"):
		new_pos.y -= delta * SPEED
	particles[0].update_pos(new_pos, particles[0].now_pos)
	$Pivot.position = new_pos
	update_particle_pos(delta)
