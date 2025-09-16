# Script for a single hour entry.
# This script is attached to the root HBoxContainer node.
extends HBoxContainer

# Node references are retrieved locally within functions to avoid timing issues.
# Do not use @onready var.

func _ready():
	# Get node references here for signal connections
	var remove_button = $RemoveButton
	remove_button.pressed.connect(queue_free)
	
	# Pre-populate the weekday OptionButton on ready
	var weekday_option_button = $Weekday
	for day in ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"]:
		weekday_option_button.add_item(day)

func set_data(data: Dictionary):
	# Get node references here, where they are guaranteed to exist,
	# before trying to use them.
	var weekday_option_button = $Weekday
	var open_line_edit = $OpeningTime
	var close_line_edit = $ClosingTime
	
	# Corrected logic: find the index by looping through items.
	var weekday_index = -1
	for i in range(weekday_option_button.get_item_count()):
		if weekday_option_button.get_item_text(i) == data.weekday:
			weekday_index = i
			break
			
	if weekday_index != -1:
		weekday_option_button.select(weekday_index)
	
	open_line_edit.text = data.open
	close_line_edit.text = data.close

func get_data() -> Dictionary:
	var weekday_option_button = $Weekday
	var open_line_edit = $OpeningTime
	var close_line_edit = $ClosingTime
	
	return {
		"weekday": weekday_option_button.get_item_text(weekday_option_button.get_selected_id()),
		"open": open_line_edit.text,
		"close": close_line_edit.text
	}
