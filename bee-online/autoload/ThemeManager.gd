extends Node

const BUILTIN_THEMES_DIR := "res://themes/"
const THEMES_DIR := "user://themes/"
const DEFAULT_THEME := "default"

var sprites: Dictionary = {}
var active_theme: String = DEFAULT_THEME
var theme_meta: Dictionary = {}

signal theme_loaded(theme_name)

func _ready():
    _ensure_default_dirs()
    var app_config = get_node("/root/AppConfig")
    active_theme = app_config.config_data["graphics"].get("theme", DEFAULT_THEME)
    load_theme(active_theme)

func _ensure_default_dirs():
    print("User theme directory:", OS.get_user_data_dir())

    var dir := DirAccess.open("user://")
    if dir == null:
        push_error("Unable to access user:// directory")
        return

    if not DirAccess.dir_exists_absolute(THEMES_DIR):
        _copy_directory_recursive(BUILTIN_THEMES_DIR, THEMES_DIR)

    var default_path := BUILTIN_THEMES_DIR + DEFAULT_THEME
    if not DirAccess.dir_exists_absolute(default_path):
        _copy_directory_recursive(BUILTIN_THEMES_DIR + DEFAULT_THEME, THEMES_DIR + DEFAULT_THEME)
        
func load_theme(theme_name: String) -> void:
    sprites.clear()
    theme_meta.clear()
    active_theme = theme_name

    # 1) Load built-in base (always available)
    var builtin_path := BUILTIN_THEMES_DIR + theme_name
    if not DirAccess.dir_exists_absolute(builtin_path):
        builtin_path = BUILTIN_THEMES_DIR + DEFAULT_THEME

    _load_theme_metadata(builtin_path)
    _load_directory_recursive(builtin_path)

    # 2) Apply user overrides (optional)
    var user_path := THEMES_DIR + theme_name
    if DirAccess.dir_exists_absolute(user_path):
        _load_theme_metadata(user_path) # let user override metadata too (or whitelist)
        _load_directory_recursive(user_path)

    print("Theme loaded:", active_theme)

    emit_signal("theme_loaded", active_theme)

func _load_directory_recursive(path: String):
    var dir := DirAccess.open(path)
    dir.list_dir_begin()

    var file_name := dir.get_next()
    while file_name != "":
        if file_name.begins_with("."):
            file_name = dir.get_next()
            continue

        var full_path := path + "/" + file_name

        if dir.current_is_dir():
            _load_directory_recursive(full_path)
        else:
            if _is_image(file_name):
                _load_sprite(full_path)

        file_name = dir.get_next()

    dir.list_dir_end()

func _is_image(file_name: String) -> bool:
    return file_name.get_extension().to_lower() in [
        "png", "jpg", "jpeg", "webp"
    ]

func _load_sprite(path: String):
    var img := Image.new()
    var err := img.load(path)

    if err != OK:
        push_warning("Failed to load image: " + path)
        return

    var tex := ImageTexture.create_from_image(img)

    # Generate a clean key, ex:
    # characters/monarch
    var key := path.replace(THEMES_DIR + active_theme + "/", "")
    key = key.get_basename()

    sprites[key] = tex

func _load_theme_metadata(theme_path: String) -> void:
    theme_meta.clear()

    var json_path := theme_path + "/theme.json"
    if not FileAccess.file_exists(json_path):
        return  # Themes don't have to define metadata

    var file := FileAccess.open(json_path, FileAccess.READ)
    if file == null:
        push_warning("Failed to open theme.json")
        return

    var content := file.get_as_text()
    file.close()

    var json := JSON.new()
    var err := json.parse(content)

    if err != OK:
        push_warning("Invalid theme.json")
        return

    if typeof(json.data) != TYPE_DICTIONARY:
        push_warning("theme.json must contain a JSON object")
        return

    theme_meta = json.data

func get_theme_meta(key: String, default_value = null):
    return theme_meta.get(key, default_value)

func has_theme_meta(key: String) -> bool:
    return theme_meta.has(key)

func _copy_directory_recursive(source_path: String, dest_path: String) -> void:
    var source_dir := DirAccess.open(source_path)
    if source_dir == null:
        push_warning("Cannot open source directory: " + source_path)
        return
    
    var dest_dir := DirAccess.open(dest_path)
    if dest_dir == null:
        DirAccess.make_dir_recursive_absolute(dest_path)
        dest_dir = DirAccess.open(dest_path)
        if dest_dir == null:
            push_warning("Cannot create destination directory: " + dest_path)
            return
    
    source_dir.list_dir_begin()
    var file_name := source_dir.get_next()
    
    while file_name != "":
        if file_name.begins_with("."):
            file_name = source_dir.get_next()
            continue
        
        var source_file := source_path + "/" + file_name
        var dest_file := dest_path + "/" + file_name
        
        if source_dir.current_is_dir():
            _copy_directory_recursive(source_file, dest_file)
        else:
            source_dir.copy(source_file, dest_file)
        
        file_name = source_dir.get_next()
    
    source_dir.list_dir_end()