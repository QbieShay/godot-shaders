extends Viewport

export var interactive_actor_path: NodePath
export var interactive_actor_footprint: NodePath
export var interactive_snow_size: Vector2 = Vector2(32,32)

func _ready():
	get_texture().set_flags(Texture.FLAG_FILTER)

func _process(delta):
	var player = get_node(interactive_actor_path)
	var player_pos = Vector2(player.global_transform.origin.x, player.global_transform.origin.z)
	player_pos += interactive_snow_size/2.0;
	get_node(interactive_actor_footprint).global_position = (player_pos/ interactive_snow_size) * size
