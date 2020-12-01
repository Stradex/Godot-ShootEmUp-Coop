extends Area2D

var explosion_scene = preload("res://explosion.tscn");

export var move_speed: float = 100.0;
export var health: int = 1;
var score_emitted = false;
signal score;

func _process(delta):
	position-=Vector2(move_speed*delta, 0.0);
	if position.x <= -100:
		queue_free();

func destroy():
	score_emitted = true;
	emit_signal("score");
	queue_free();
	var stage_node = get_parent();
	var explosion_instance = explosion_scene.instance();
	explosion_instance.position = position;
	stage_node.add_child(explosion_instance);

func _on_asteroid_area_entered(area):
	if (area.is_in_group("shot") || area.is_in_group("player")):
		if area.is_in_group("shot"): 
			health-=1;
		else:
			health = 0;
			area.hit_by_asteroid();
		if !score_emitted && health <= 0:
			destroy();
