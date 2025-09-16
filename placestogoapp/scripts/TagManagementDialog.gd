# Script for managing tags.
extends Window

@onready var list = $VBoxContainer/ItemList
@onready var close_button = $VBoxContainer/HBoxContainer/CloseButton
@onready var remove_button = $VBoxContainer/HBoxContainer/RemoveButton

signal data_changed

func _ready():
	populate_list()
	remove_button.pressed.connect(_on_remove_button_pressed)
	close_button.pressed.connect(hide)

func populate_list():
	list.clear()
	for tag in Data.tags:
		list.add_item(tag)

func _on_remove_button_pressed():
	var dialog = DialogLoaders._get_or_create_confirmation_dialog()
	
	var dialog_ready = dialog.dialog_ready
	
	if dialog_ready:
		dialog.configure_dialog(
			"Confirm Delete", 
			"Are you sure you want to permanently delete this Tag?
			
			This will also remove the tag from all places that had the tag.",
			"Delete",
			"Cancel"
		)
	
	dialog.popup_centered()
	
	var dialog_result = await dialog.confirmation_dialog_result
	
	if dialog_result:
		var selected_items = list.get_selected_items()
		if not selected_items.is_empty():
			var selected_index = selected_items[0]
			var tag_to_remove = list.get_item_text(selected_index)
			Data.remove_tag(tag_to_remove)
			populate_list()
			data_changed.emit()
