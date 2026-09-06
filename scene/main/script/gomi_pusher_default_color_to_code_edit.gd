class_name GomiPusherDefaultColorToCodeEdit
extends Node

## Applies a default dark color theme to one or more [CodeEdit] nodes.
##
## Useful for keeping embedded GDScript editing panels visually consistent
## at runtime. Colors are exposed as exports so the theme can be tweaked
## per-instance without editing the script.

@export var _code_edits: Array[CodeEdit] = []

## If [code]true[/code], the theme is applied automatically in [_ready].
@export var _apply_at_ready: bool = true

# --- Theme colors (VS Code Dark+ inspired) ---
@export_group("Theme Colors")
@export var background_color: Color = Color("#1E1E1E")
@export var keyword_color:    Color = Color("#FF7085")
@export var string_color:     Color = Color("#FFEDA1")
@export var number_color:     Color = Color("#A1FFE0")
@export var comment_color:    Color = Color("#5F6975")
@export var function_color:   Color = Color("#57D6C7")
@export var type_color:       Color = Color("#8DA5F3")

@export var exception_color:     Color = Color("#FFB86C")	

@export_multiline var exception_keywords:String = "timeout"



func _ready() -> void:
	if _apply_at_ready:
		apply_theme_to_all()


## Applies the theme to every valid [CodeEdit] in [_code_edits].
func apply_theme_to_all() -> void:
	for code_edit in _code_edits:
		apply_theme_to(code_edit)


## Applies the theme to a single [CodeEdit]. Safe to call with [code]null[/code].
func apply_theme_to(code_edit: CodeEdit) -> void:
	if not is_instance_valid(code_edit):
		return

	code_edit.add_theme_color_override("background_color", background_color)

	var highlighter := CodeHighlighter.new()
	highlighter.number_color = number_color
	highlighter.symbol_color = type_color
	highlighter.function_color = function_color
	highlighter.add_color_region('"', '"', string_color)
	highlighter.add_color_region("'", "'", string_color)
	highlighter.add_color_region("#", "", comment_color, true)

	for keyword in [
		"if", "elif", "else", "for", "while", "match", "break", "continue",
		"pass", "return", "class", "class_name", "extends", "is", "in",
		"as", "self", "func", "static", "const", "enum", "var",
		"breakpoint", "preload", "yield", "await", "assert", "void",
		"PI", "TAU", "INF", "NAN", "not", "and", "or", "true", "false", "null",
	]:
		highlighter.add_keyword_color(keyword, keyword_color)

	for keyword in exception_keywords.split(","):
		highlighter.add_keyword_color(keyword.strip_edges(), exception_color)

	code_edit.syntax_highlighter = highlighter


## Re-applies the theme to all configured [CodeEdit] nodes.
func refresh() -> void:
	apply_theme_to_all()
