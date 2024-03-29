extends Spatial

export (NodePath) var block_map = null setget set_block_map
export (int) var view_distance = 12 setget set_view_distance
export (int) var chunk_size = 16

var chunks := {}
var noise := OpenSimplexNoise.new() # Declare and initialize the noise object

func set_block_map(val):
	block_map = val
	if is_inside_tree():
		generate_terrain()

func set_view_distance(val):
	view_distance = val
	if is_inside_tree():
		generate_terrain()

func _ready():
	if is_inside_tree():
		generate_terrain()

func generate_terrain():
	if !is_inside_tree():
		return

	var centre_offset = floor(view_distance / 2)
	var player_chunk_x = floor(global_transform.origin.x / chunk_size)
	var player_chunk_z = floor(global_transform.origin.z / chunk_size)

	for x in range(player_chunk_x - centre_offset, player_chunk_x + centre_offset + 1):
		for z in range(player_chunk_z - centre_offset, player_chunk_z + centre_offset + 1):
			if !chunks.has(x):
				chunks[x] = {}

			if !chunks[x].has(z):
				var chunk = generate_chunk(x, z)
				chunks[x][z] = chunk
				var block_map_node = get_node(block_map) # Access the Node from NodePath
				block_map_node.add_child(chunk) # Add chunk as a child to the Node

	for x in chunks.keys():
		for z in chunks[x].keys():
			if abs(x - player_chunk_x) > centre_offset or abs(z - player_chunk_z) > centre_offset:
				var chunk = chunks[x][z]
				chunk.queue_free()
				chunks[x].erase(z)

func generate_chunk(chunk_x, chunk_z):
	var chunk = MeshInstance.new()
	chunk.mesh = generate_chunk_mesh(chunk_x, chunk_z)
	chunk.translation = Vector3(chunk_x * chunk_size, 0, chunk_z * chunk_size)
	return chunk

func generate_chunk_mesh(chunk_x, chunk_z):
	var _vertices = PoolVector3Array() # Prefix unused variable with an underscore
	var _indices = PoolIntArray() # Prefix unused variable with an underscore
	var height_bias = 1
	var height = 1

	for x in range(chunk_x * chunk_size, (chunk_x + 1) * chunk_size + 1):
		for z in range(chunk_z * chunk_size, (chunk_z + 1) * chunk_size + 1):
			var h = noise.get_noise_2d(x, z) * height_bias
			var is_negative = sign(h)
			h *= h
			h *= height * is_negative
