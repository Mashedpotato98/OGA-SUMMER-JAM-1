class_name PauseScreen
extends CanvasLayer


onready var bg: ColorRect = $BG
onready var interface: Screen = $Interface
onready var resume_button: Button = interface.get_node("Menu/ResumeButton")


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel") and not get_tree().paused:
		get_tree().paused = true
		interface.show()
		bg.show()
		resume_button.grab_focus()


func _on_ResumeButton_pressed() -> void:
	bg.hide()
	interface.hide()
	get_tree().paused = false


func _on_QuitButton_pressed() -> void:
	get_tree().quit()
