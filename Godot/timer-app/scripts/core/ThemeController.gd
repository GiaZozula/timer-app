extends Node

## Standard font sizes (points) shared across all themes. Not theme-specific.
const FONT_SIZE_TITLE := 28
const FONT_SIZE_BODY := 18
const FONT_SIZE_TIMER := 96

var theme_data: Dictionary = {}

func load_theme(path: String):
	if not FileAccess.file_exists(path):
		push_error("Theme file not found: " + path)
		return

	var file = FileAccess.open(path, FileAccess.READ)
	var content = file.get_as_text()
	file.close()

	var json = JSON.new()
	var result = json.parse(content)

	if result != OK:
		push_error("Failed to parse theme JSON")
		return

	theme_data = json.data


func get_idle_animation() -> String:
	return theme_data.get("idle", "")


func get_outro_animation() -> String:
	return theme_data.get("outro", "")


func get_event_animations() -> Array:
	return theme_data.get("events", [])


func get_random_event_animation() -> String:
	var events = get_event_animations()
	if events.is_empty():
		return ""
	return events[randi() % events.size()]


func get_event_interval_min() -> float:
	return theme_data.get("event_interval", {}).get("min", 30.0)


func get_event_interval_max() -> float:
	return theme_data.get("event_interval", {}).get("max", 60.0)


func get_audio_bg() -> String:
	return theme_data.get("audio", {}).get("bg", "")


func get_audio_outro() -> String:
	return theme_data.get("audio", {}).get("outro", "")


func get_font_size(font_key: String) -> int:
	match font_key:
		"title":
			return FONT_SIZE_TITLE
		"body":
			return FONT_SIZE_BODY
		"timer":
			return FONT_SIZE_TIMER
		_:
			return FONT_SIZE_BODY
