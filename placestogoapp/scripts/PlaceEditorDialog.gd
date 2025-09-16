# Script for the Add/Edit Place dialog.
extends Window

signal save_requested(place_data, index)

var place_index: int = -1

func _ready():
	_populate_categories()
	
	var add_hour_button = $VBoxContainer/AddHourButton
	var ok_button = $VBoxContainer/HBoxContainer/OKButton
	var cancel_button = $VBoxContainer/HBoxContainer/CancelButton

	add_hour_button.pressed.connect(_on_add_hour_pressed)
	ok_button.pressed.connect(_on_ok_pressed)
	cancel_button.pressed.connect(hide)

func _populate_categories():
	var category_option_button = $VBoxContainer/CategoryOptionButton
	category_option_button.clear()
	for category in Data.categories:
		category_option_button.add_item(category)
	
func set_data_for_edit(data: Dictionary, index: int):
	var name_line_edit = $VBoxContainer/NameLineEdit
	var category_option_button = $VBoxContainer/CategoryOptionButton
	var notes_text_edit = $VBoxContainer/NotesTextEdit
	var tags_line_edit = $VBoxContainer/TagsLineEdit
	var hours_list = $VBoxContainer/HoursList
	
	place_index = index
	name_line_edit.text = str(data.place_name)
	
	_populate_categories() # Populate categories to ensure they exist for selection
	category_option_button.select(Data.categories.find(data.place_category))

	notes_text_edit.text = str(data.place_notes)
	tags_line_edit.text = ", ".join(data.place_tags)
	
	for child in hours_list.get_children():
		child.queue_free()
		
	for hour in data.place_hours:
		var hour_entry = SCENES.PLACE_HOUR_ENTRY_SCENE.instantiate()
		hour_entry.set_data(hour)
		hours_list.add_child(hour_entry)

func _on_add_hour_pressed():
	var hours_list = $VBoxContainer/HoursList
	var hour_entry = SCENES.PLACE_HOUR_ENTRY_SCENE.instantiate()
	hours_list.add_child(hour_entry)

func _on_ok_pressed():
	var dialog = DialogLoaders._get_or_create_confirmation_dialog()
	
	var dialog_ready = dialog.dialog_ready
	
	if dialog_ready:
		dialog.configure_dialog(
			"Confirm Delete", 
			"Are you sure you want to permanently delete this place?",
			"Delete",
			"Cancel"
		)
	
	dialog.popup_centered()
	
	var dialog_result = await dialog.confirmation_dialog_result
	
	if dialog_result:
		var name_line_edit = $VBoxContainer/NameLineEdit
		var category_option_button = $VBoxContainer/CategoryOptionButton
		var notes_text_edit = $VBoxContainer/NotesTextEdit
		var tags_line_edit = $VBoxContainer/TagsLineEdit
		var hours_list = $VBoxContainer/HoursList

		var place_data = {
			"place_name": name_line_edit.text,
			"place_category": category_option_button.get_item_text(category_option_button.get_selected_id()),
			"place_notes": notes_text_edit.text,
			"place_tags": [],
			"place_hours": []
		}
		
		var tag_strings = tags_line_edit.text.split(",", false)
		for tag in tag_strings:
			place_data.place_tags.append(tag.strip_edges())
		
		for child in hours_list.get_children():
			place_data.place_hours.append(child.get_data())
		
		save_requested.emit(place_data, place_index)
		hide()
