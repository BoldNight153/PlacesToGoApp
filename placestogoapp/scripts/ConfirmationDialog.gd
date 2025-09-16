extends Window

# Signal to be emitted that returns true or false
signal confirmation_dialog_result(value: bool)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var dialog_message_panel_container = $VBoxContainer/VBoxContainer/PanelContainer/Message
	var button1_button = $VBoxContainer/HBoxContainer/Button1
	var button2_button = $VBoxContainer/HBoxContainer/Button2
	
	var stylebox = StyleBoxFlat.new()
	stylebox.content_margin_left = 10
	stylebox.content_margin_right = 10
	stylebox.content_margin_top = 5
	stylebox.content_margin_bottom = 5
	
	dialog_message_panel_container.add_theme_stylebox_override("normal", stylebox)
	
	button1_button.pressed.connect(_on_button1_button_pressed)
	button2_button.pressed.connect(_on_button2_button_pressed)
	
	close_requested.connect(func(): hide())

# A function to configure the dialog's text.
func configure_dialog(title_text: String, message_text: String, button1_text: String = "", button2_text: String = "", text_to_show: String = "") -> void:
	# Get the nodes using the corrected paths.
	var dialog_message = $VBoxContainer/VBoxContainer/PanelContainer/Message
	var button1_button = $VBoxContainer/HBoxContainer/Button1
	var button2_button = $VBoxContainer/HBoxContainer/Button2
	
	# Configure the text.
	title = title_text
	dialog_message.text = message_text
	if button1_text.length() > 0:
		button1_button.text = button1_text
	if button2_text.length() > 0:
		button2_button.text = button2_text

func _on_button1_button_pressed() -> void:
	confirmation_dialog_result.emit(true) # Emit 'true' for continue
	close_requested.emit()

func _on_button2_button_pressed() -> void:
	confirmation_dialog_result.emit(false) # Emit 'false' for cancel
	close_requested.emit()
