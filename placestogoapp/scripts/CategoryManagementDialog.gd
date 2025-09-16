# Script for managing categories.
extends Window

@onready var list = $VBoxContainer/List
@onready var category_line_edit = $VBoxContainer/HBoxContainer/CategoryLineEdit
@onready var add_button = $VBoxContainer/HBoxContainer/AddButton
@onready var close_button = $VBoxContainer/HBoxContainer2/CloseButton
@onready var remove_button = $VBoxContainer/HBoxContainer2/RemoveButton

signal data_changed

func _ready():
	populate_list()
	add_button.pressed.connect(_on_add_button_pressed)
	remove_button.pressed.connect(_on_remove_button_pressed)
	close_button.pressed.connect(hide)

func populate_list():
	list.clear()
	for category in Data.categories:
		list.add_item(category)

func _on_add_button_pressed():
	var new_category = category_line_edit.text.strip_edges()
	if new_category and not Data.categories.has(new_category):
		Data.add_category(new_category)
		populate_list()
		data_changed.emit()
		category_line_edit.clear()

func _on_remove_button_pressed():
	var dialog = DialogLoaders._get_or_create_confirmation_dialog()
	
	var dialog_ready = dialog.dialog_ready
	
	if dialog_ready:
		dialog.configure_dialog(
			"Confirm Delete", 
			"Are you sure you want to permanently delete this category?",
			"Delete",
			"Cancel"
		)
	
	dialog.popup_centered()
	
	var dialog_result = await dialog.confirmation_dialog_result
	
	if dialog_result:
		var selected_items = list.get_selected_items()
		if not selected_items.is_empty():
			var selected_index = selected_items[0]
			var category_to_remove = list.get_item_text(selected_index)
			
			if ["Eat", "Play", "Shop"].has(category_to_remove):
				print("Cannot remove default categories: Eat, Play, Shop.")
				return

			Data.remove_category(category_to_remove)
			populate_list()
			data_changed.emit()
