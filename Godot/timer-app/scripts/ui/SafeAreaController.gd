extends MarginContainer

## Applies iOS-style safe area insets (notch, home bar, rounded corners) via margins.
## Uses DisplayServer.get_display_safe_area() when available; falls back to configurable insets.
## Also provides a font scale factor for responsive text (viewport-height based).

const REFERENCE_VIEWPORT_HEIGHT := 800.0

var _fallback_insets: Dictionary = {
	"left": 0, "top": 0, "right": 0, "bottom": 0
}


func _ready() -> void:
	update_safe_area_margins()
	if get_viewport():
		get_viewport().size_changed.connect(update_safe_area_margins)


func _notification(what: int) -> void:
	if what == NOTIFICATION_RESIZED:
		update_safe_area_margins()


func update_safe_area_margins() -> void:
	var vp := get_viewport()
	if not vp:
		return

	var window_size := DisplayServer.window_get_size()
	if window_size.x <= 0 or window_size.y <= 0:
		_apply_margins(_fallback_insets)
		return

	var safe_rect := DisplayServer.get_display_safe_area()
	var viewport_size := vp.get_visible_rect().size

	var inv := vp.get_final_transform().affine_inverse()
	var safe_pos := inv * Vector2(safe_rect.position)
	var safe_end := inv * Vector2(safe_rect.position + safe_rect.size)

	var left := int(maxf(0.0, safe_pos.x))
	var top := int(maxf(0.0, safe_pos.y))
	var right := int(maxf(0.0, viewport_size.x - safe_end.x))
	var bottom := int(maxf(0.0, viewport_size.y - safe_end.y))

	add_theme_constant_override("margin_left", left)
	add_theme_constant_override("margin_top", top)
	add_theme_constant_override("margin_right", right)
	add_theme_constant_override("margin_bottom", bottom)


func _apply_margins(insets: Dictionary) -> void:
	add_theme_constant_override("margin_left", insets.get("left", 0))
	add_theme_constant_override("margin_top", insets.get("top", 0))
	add_theme_constant_override("margin_right", insets.get("right", 0))
	add_theme_constant_override("margin_bottom", insets.get("bottom", 0))


## Returns a scale factor for font sizes based on viewport height.
## Use with theme base font sizes for responsive, legible text.
func get_font_scale() -> float:
	var vp := get_viewport()
	if not vp:
		return 1.0
	var h := vp.get_visible_rect().size.y
	if h <= 0.0:
		return 1.0
	return clampf(h / REFERENCE_VIEWPORT_HEIGHT, 0.7, 1.5)
