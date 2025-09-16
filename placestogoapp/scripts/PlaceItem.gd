# Script for a single place item in the list.
extends HBoxContainer

signal edit_requested(place_data, index)
signal delete_requested(index)
signal tag_removed(tag_name, place_data, place_index)

var place_data: Dictionary
var place_index: int

@onready var place_name = $VBoxContainer/VBoxContainer/PlaceName
@onready var notes = $VBoxContainer/VBoxContainer/Notes
@onready var tags = $VBoxContainer/VBoxContainer/Tags
@onready var hours = $VBoxContainer/VBoxContainer/Hours
@onready var edit_button = $VBoxContainer/HBoxContainer/EditButton
@onready var delete_button = $VBoxContainer/HBoxContainer/DeleteButton

func _ready() -> void:
	# Diagnostic print statement
	print("Debug: PlaceItem has entered the tree. Value of place_name is: ", place_name)
	
	# This is where the error occurred before. The _ready() function ensures the nodes exist.
	edit_button.pressed.connect(func(): edit_requested.emit(place_data, place_index))
	delete_button.pressed.connect(func(): delete_requested.emit(place_index))

func set_data(data: Dictionary, index: int):
	self.place_data = data
	self.place_index = index
	
	place_name.text = str(data.place_name)
	notes.text = str(data.place_notes)
	
	for child in tags.get_children():
		child.queue_free()
	for tag in data.place_tags:
		# We will now use a PanelContainer to hold the style.
		var tag_panel_container = PanelContainer.new()
		
		# Create the tag's background style
		var stylebox = StyleBoxFlat.new()
		stylebox.bg_color = Color("#4a90e2")  # A nice blue color
		stylebox.corner_radius_top_left = 10
		stylebox.corner_radius_top_right = 10
		stylebox.corner_radius_bottom_left = 10
		stylebox.corner_radius_bottom_right = 10
		stylebox.content_margin_left = 16
		stylebox.content_margin_right = 16
		stylebox.content_margin_top = 8
		stylebox.content_margin_bottom = 8
		
		# The fix: Apply the style to the PanelContainer.
		tag_panel_container.add_theme_stylebox_override("panel", stylebox)
		
		var tag_container = HBoxContainer.new()
		tag_container.add_theme_constant_override("separation", 12)
		
		var tag_label = Label.new()
		tag_label.text = tag
		tag_label.add_theme_color_override("font_color", Color.WHITE)
		
		var separator = VSeparator.new()
		separator.add_theme_color_override("separator_color", Color.WHITE)
		
		var remove_button = Button.new()
		remove_button.text = "  X  "
		remove_button.flat = true
		remove_button.add_theme_color_override("font_color", Color.WHITE)
		remove_button.add_theme_color_override("font_hover_color", Color("#cccccc"))
		
		remove_button.pressed.connect(func(): tag_removed.emit(tag, place_data, place_index))
		
		# Add children to the HBoxContainer.
		tag_container.add_child(tag_label)
		tag_container.add_child(separator)
		tag_container.add_child(remove_button)
		
		# Add the HBoxContainer to the PanelContainer.
		tag_panel_container.add_child(tag_container)
		
		tags.add_child(tag_panel_container)

	for child in hours.get_children():
		child.queue_free()
	for hour_entry in data.place_hours:
		var hour_label = Label.new()
		hour_label.text = "%s: %s - %s" % [hour_entry.weekday, hour_entry.open, hour_entry.close]
		hours.add_child(hour_label)
