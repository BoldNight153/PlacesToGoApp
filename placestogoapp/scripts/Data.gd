# The singleton script for managing data.
extends Node

# data path constant
const DATA_PATH = "res://data/data.json"

# general variables
var categories: Array = ["Eat", "Play", "Shop"]
var tags: Array = []
var places: Array = []

# load data when ready
func _ready():
	load_data()

# fuction tha acturally loads the data from the data file in DATA_PATH
func load_data():
	if not FileAccess.file_exists(DATA_PATH):
		save_data()
		return

	var file = FileAccess.open(DATA_PATH, FileAccess.READ)
	if file:
		var content = JSON.parse_string(file.get_as_text())
		if content:
			categories = content.get("categories", ["Eat", "Play", "Shop"])
			tags = content.get("tags", [])
			
			var loaded_places = content.get("places", [])
			for place in loaded_places:
				if "category" in place and "name" in place:
					var new_place = {
						"place_name": place.get("name"),
						"place_category": place.get("category"),
						"place_notes": place.get("notes"),
						"place_tags": place.get("tags"),
						"place_hours": place.get("hours")
					}
					places.append(new_place)
				else:
					places.append(place)
		file.close()
	
	save_data()

# funtion that saves the data
func save_data():
	var file = FileAccess.open(DATA_PATH, FileAccess.WRITE)
	if file:
		var data_to_save = {
			"categories": categories,
			"tags": tags,
			"places": places
		}
		file.store_string(JSON.stringify(data_to_save, "\t"))
		file.close()

# function that adds a place
func add_place(place_data: Dictionary):
	places.append(place_data)
	save_data()
	for tag in place_data["place_tags"]:
		add_tag(tag)

 # function that updates a place
func update_place(index: int, place_data: Dictionary):
	if index >= 0 and index < places.size():
		places[index] = place_data
		save_data()
		for tag in place_data["place_tags"]:
			add_tag(tag)

# function that delets a place
func delete_place(index: int):
	if index >= 0 and index < places.size():
		places.remove_at(index)
		save_data()

# function that adds a category
func add_category(category: String):
	if not categories.has(category):
		categories.append(category)
		save_data()

# function that deletes a category
func remove_category(category: String):
	if categories.has(category):
		categories.erase(category)
		save_data()

# function that adds a tag
func add_tag(tag: String):
	if not tags.has(tag):
		tags.append(tag)
		save_data()

# function that delets a tag
func remove_tag(tag: String):
	# The fix: This function now recursively removes the tag from all places.
	if tags.has(tag):
		tags.erase(tag)
		for place in places:
			if place.place_tags.has(tag):
				place.place_tags.erase(tag)
		save_data()
