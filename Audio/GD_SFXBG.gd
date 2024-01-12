extends Node

var musicRandom = RandomNumberGenerator.new()

# Called when the node enters the scene tree for the first time.
func _ready():
	randomize()
	var randomMusicLoopStart = musicRandom.randf_range(0.0, $Music.get_stream().get_length())
	$Music.play(randomMusicLoopStart)
	
	$Ambience.play()
