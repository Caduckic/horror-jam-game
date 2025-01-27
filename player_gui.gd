extends Control


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$Label.visible = false
	$Note.visible = false

func _read_note(text : String):
	$Note.visible = true
	$Note/Text.text = text

func _close_note():
	$Note.visible = false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	$FPS.text = "FPS: %s" % Engine.get_frames_per_second()

func _set_label(text : String) -> void:
	$Label.visible = true
	$Label.text = text
