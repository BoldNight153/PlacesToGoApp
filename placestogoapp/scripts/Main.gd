# Main scene script for app logic and UI management.
extends Control

@onready var search_bar = $VBoxContainer/HBoxContainer/SearchBar
@onready var tag_filter_container = $VBoxContainer/TagFilterContainer
@onready var tab_container = $VBoxContainer/TabContainer
@onready var add_button = $VBoxContainer/HBoxContainer2/AddButton
@onready var manage_categories_button = $VBoxContainer/HBoxContainer2/ManageCategoriesButton
@onready var manage_tags_button = $VBoxContainer/HBoxContainer2/ManageTagssButton

var active_filters: Array = []
var search_text: String = ""

func _ready():
	setup_ui()
	connect_signals()
	update_ui()

func setup_ui():
	for category in Data.categories:
		var tab = Control.new()
		tab.name = category
		
		var scroll_container = ScrollContainer.new()
		scroll_container.name = "ScrollContainer"
		
		var list_container = VBoxContainer.new()
		list_container.name = "VBoxContainer"
		
		scroll_container.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		list_container.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		
		scroll_container.add_child(list_container)
		tab.add_child(scroll_container)
		
		tab_container.add_child(tab)
		tab_container.set_tab_title(tab_container.get_tab_count() - 1, category)

func connect_signals():
	add_button.pressed.connect(_on_add_button_pressed)
	manage_categories_button.pressed.connect(_on_manage_categories_button_pressed)
	manage_tags_button.pressed.connect(_on_manage_tags_button_pressed)
	search_bar.text_changed.connect(_on_search_bar_text_changed)
	tab_container.tab_changed.connect(update_ui)

func update_ui(index: int = -1):
	populate_tag_filters()
	if index == -1:
		populate_place_lists()
	else:
		populate_place_lists(index)

func populate_tag_filters():
	for child in tag_filter_container.get_children():
		child.queue_free()

	for tag in Data.tags:
		var button = Button.new()
		button.text = tag
		button.toggle_mode = true
		button.button_pressed = active_filters.has(tag)
		button.pressed.connect(_on_tag_filter_pressed.bind(tag))
		tag_filter_container.add_child(button)

func _on_tag_filter_pressed(tag: String):
	if active_filters.has(tag):
		active_filters.erase(tag)
	else:
		active_filters.append(tag)
	
	populate_place_lists()

func _on_search_bar_text_changed(text: String):
	search_text = text.to_lower()
	populate_place_lists()

func populate_place_lists(index: int = -1):
	var start_index = 0
	var end_index = tab_container.get_tab_count()
	
	if index != -1:
		start_index = index
		end_index = index + 1
		
	for i in range(start_index, end_index):
		var tab_name = tab_container.get_tab_title(i)
		var tab_node = tab_container.get_tab_control(i)
		
		if not is_instance_valid(tab_node):
			continue
		
		var list_container = tab_node.get_node("ScrollContainer/VBoxContainer")
		list_container.size_flags_horizontal = Control.SIZE_EXPAND | Control.SIZE_FILL
		list_container.size_flags_vertical = Control.SIZE_EXPAND | Control.SIZE_FILL
		
		if not is_instance_valid(list_container):
			continue
			
		for child in list_container.get_children():
			child.queue_free()
			
		var filtered_places = Data.places.filter(func(place):
			return place.place_category == tab_name and (search_text == "" or place.place_name.to_lower().find(search_text) != -1 or place.place_notes.to_lower().find(search_text) != -1) and (active_filters.is_empty() or has_common_elements(place.place_tags, active_filters))
		)
		
		for place in filtered_places:
			var place_item = SCENES.PLACE_ITEM_SCENE.instantiate()
			var original_index = Data.places.find(place)
			
			list_container.add_child(place_item)
			place_item.set_data(place, original_index)

			place_item.edit_requested.connect(_on_place_edit_requested)
			place_item.delete_requested.connect(_on_place_delete_requested)
			# This is the missing line to make the X button work
			place_item.tag_removed.connect(_on_tag_removed)

func has_common_elements(arr1: Array, arr2: Array) -> bool:
	for element in arr1:
		if arr2.has(element):
			return true
	return false

func _on_add_button_pressed():
	var editor_dialog = SCENES.PLACE_EDITOR_DIALOG_SCENE.instantiate()
	editor_dialog.save_requested.connect(_on_editor_dialog_save)
	get_tree().root.add_child(editor_dialog)
	editor_dialog.popup_centered()

func _on_manage_categories_button_pressed():
	var dialog = SCENES.CATEGORY_MANAGEMENT_DIALOG_SCENE.instantiate()
	get_tree().root.add_child(dialog)
	dialog.data_changed.connect(update_ui)
	dialog.popup_centered()
	
func _on_manage_tags_button_pressed():
	var dialog = SCENES.TAG_MANAGEMENT_DIALOG_SCENE.instantiate()
	get_tree().root.add_child(dialog)
	dialog.data_changed.connect(update_ui)
	dialog.popup_centered()

func _on_place_edit_requested(place_data: Dictionary, index: int):
	var editor_dialog = SCENES.PLACE_EDITOR_DIALOG_SCENE.instantiate()
	editor_dialog.set_data_for_edit(place_data, index)
	editor_dialog.save_requested.connect(_on_editor_dialog_save)
	get_tree().root.add_child(editor_dialog)
	editor_dialog.popup_centered()

func _on_place_delete_requested(index: int):
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
		Data.delete_place(index)
		update_ui()

func _on_editor_dialog_save(place_data: Dictionary, index: int = -1):
	if index == -1:
		Data.add_place(place_data)
	else:
		Data.update_place(index, place_data)
	update_ui()
	
# New function to handle tag removal
func _on_tag_removed(tag_name, place_data, place_index):
	if place_index != -1:
		Data.places[place_index].place_tags.erase(tag_name)
		Data.save_data()
		update_ui()
