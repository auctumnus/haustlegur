extends Node2D

export (int) var MAP_SIZE = 128

onready var tilemap = $TileMap
onready var treeysort = $TreeYSort

enum tiles {
	WATER,
	GRASS,
	NON_TILING_GRASS
}

onready var player = get_node("/root/Main/Player")
var noise1 = OpenSimplexNoise.new()
var noise2 = OpenSimplexNoise.new()
var tree = preload("res://tree/Tree.tscn")

onready var globals = get_node("/root/Globals")

var MAP_CENTER = floor(MAP_SIZE / 2) - 1

func remap(input, in_min, in_max, out_min, out_max):
	return ((input - in_min) / (in_max - in_min)) * (out_max - out_min) + out_min

func distanceToCenter(x: float, y: float):
	var dx = (MAP_CENTER - x) * (MAP_CENTER - x)
	var dy = (MAP_CENTER - y) * (MAP_CENTER - y)
	return sqrt(dx + dy)

func sumArray(arr):
	var accumulator = 0
	for i in arr:
		accumulator += i
	return accumulator

func weightedSum(nums: Array, weights: Array):
	var outputs = []
	for i in range(nums.size()):
		outputs.append(nums[i] * weights[i])
	return sumArray(outputs)

func setup_noise():
	randomize()
	var noiseSeed = randi()
	# more blobby, more weight
	noise1.seed = noiseSeed
	noise1.lacunarity = 0.5
	noise1.octaves = 6
	noise1.period = 15.0
	noise1.persistence = 0.5
	
	# more grainy, given less weight
	noise2.seed = hash(noiseSeed)
	noise2.lacunarity = 0.5
	noise2.octaves = 9
	noise2.period = 5.0
	noise2.persistence = 0.5

func generate_map():
	# var img = Image.new()
	# img.create(MAP_SIZE, MAP_SIZE, false, Image.FORMAT_RGB8)
	# img.lock()
	# img.fill(Color(0,0,0))
	setup_noise()
	# generate map
	for x in range(MAP_SIZE):
		for y in range(MAP_SIZE):
			var weighted_noise_result = weightedSum([noise1.get_noise_2d(x, y),
													noise2.get_noise_2d(x, y)],
													[0.75, 0.25])
			var noise_result = remap(weighted_noise_result, -1.0, 1.0, 0.0, 1.0)
			var distance = (distanceToCenter(x,y) / MAP_SIZE) + 0.5
			var generator_result = remap(noise_result * max(0, (1.0 - (distance * distance))), 0.0, 0.7, 0.0, 1.0)
			var tile = tiles.WATER
			if(generator_result > 0.4):
				tile = tiles.GRASS
				if(generator_result > 0.5 && globals.onein(15)):
					tile = tiles.NON_TILING_GRASS
					var generated_tree = tree.instance()
					generated_tree.set_position((Vector2(x,y) * 16) + Vector2(8,8))
					treeysort.add_child(generated_tree)
			tilemap.set_cell(x, y, tile)
			# img.lock()
			# img.set_pixel(x, y, Color(generator_result, generator_result, generator_result))
	# img.save_png("./noise.png")
	# update autotile
	tilemap.update_bitmask_region()
	

func _ready():
	generate_map()
	# put the player in a safe location
	var position = Vector2(MAP_CENTER, MAP_CENTER)
	while(tilemap.get_cellv(position) == 0):
		position = Vector2(randi() % MAP_SIZE, randi() % MAP_SIZE)
	player.set_position(position * 16)
	
