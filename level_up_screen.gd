extends CanvasLayer

signal upgrade_selected(upgrade: Car.Weapons)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func set_upgrades(options):
	# clear old options
	for c in $Control/VBoxContainer.get_children():
		$Control/VBoxContainer.remove_child(c)
		c.queue_free()

	print("Creating buttons from options", options)
	for option in options:
		var button = Button.new()
		button.text = option.action + " " + option.name
		var cb = func():
			upgrade_selected.emit(option)

		button.connect("pressed", cb)

		$Control/VBoxContainer.add_child(button)

func visibility(visible: bool):
	if visible:
		show()
		$Control/VBoxContainer.get_child(0).grab_focus()
	else:
		hide()
