extends SpotLight3D

var spectrum
var volume
var lastVolume = 0

func _ready():
	spectrum = AudioServer.get_bus_effect_instance(1, 0)

func _process(delta):
	volume = spectrum.get_magnitude_for_frequency_range(0, 10000).length() * 1000
	var volume1p = volume / 100
	
	light_energy = 1.0 - ((lastVolume / volume1p) / 500)
	lastVolume = volume
	#print(volume)
