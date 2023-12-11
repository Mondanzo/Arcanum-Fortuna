extends Card

var isHovered := false
var selected := false
signal clicked

func _ready():
	mouse_entered.connect(mouse_entered_event)
	mouse_exited.connect(mouse_exited_event)


func _process(delta):
	if isHovered:
		scale = scale.lerp(Vector2.ONE * 1.1, 0.2)
	elif selected:
		scale = scale.lerp(Vector2.ONE * 1.05, 0.2)
	else:
		scale = scale.lerp(Vector2.ONE, 0.2)


func mouse_entered_event():
	isHovered = true
	$HoverSound.play()

func mouse_exited_event():
	isHovered = false


func _input(event):
	if isHovered and event.is_action_pressed("pickUpCard"):
		$ClickSound.play()
		clicked.emit(self)
