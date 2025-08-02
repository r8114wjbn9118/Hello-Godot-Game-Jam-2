extends Node

var audio_stream_player: AudioStreamPlayer

func _ready():
	audio_stream_player = AudioStreamPlayer.new()
	add_child(audio_stream_player)

func play_music(music: AudioStream):
	if not audio_stream_player:
		print("AudioStreamPlayer not initialized")
		return
	print("Now playing:", music)
	audio_stream_player.stream = music
	audio_stream_player.play()

func stop_music():
	audio_stream_player.stop()
