extends Node

var confirmation_dialog = null

func _get_or_create_confirmation_dialog():
	if not is_instance_valid(confirmation_dialog):
		confirmation_dialog = SCENES.CONFIRMATION_DIALOG_SCENE.instantiate()
		get_tree().root.add_child(confirmation_dialog)
	return confirmation_dialog
