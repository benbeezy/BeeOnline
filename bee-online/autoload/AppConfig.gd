extends Node

const CONFIG_PATH = "user://config.json"

var config_data = {}
var default_config = {
	"graphics": {
		"resolution": "1920x1080",
		"fullscreen": false,
		"vsync": true,
		"fps_limit": 60,
        "theme": "default"
	},
	"audio": {
		"master_volume": 1.0,
		"music_volume": 0.8,
		"sfx_volume": 1.0
	}
}

func _ready():
    load_config()
    apply_graphics_settings()

func apply_graphics_settings():
    # Apply resolution
    var resolution_string = get_config("graphics.resolution", "1920x1080")
    var resolution_parts = resolution_string.split("x")
    if resolution_parts.size() == 2:
        var width = resolution_parts[0].to_int()
        var height = resolution_parts[1].to_int()
        DisplayServer.window_set_size(Vector2i(width, height))
    
    # Apply fullscreen
    var fullscreen = get_config("graphics.fullscreen", false)
    if fullscreen:
        DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
    else:
        DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
    
    # Apply vsync
    var vsync = get_config("graphics.vsync", true)
    DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_ENABLED if vsync else DisplayServer.VSYNC_DISABLED)
    
    # Apply FPS limit
    var fps_limit = get_config("graphics.fps_limit", 60)
    Engine.max_fps = fps_limit
    
func load_config():
    var file = FileAccess.open(CONFIG_PATH, FileAccess.READ)

    if file == null:
        print("Config file not found, creating default config at: ", OS.get_user_data_dir() + "/config.json")
        config_data = default_config.duplicate(true)
        save_config()
        return

    var json = JSON.new()
    var json_text = file.get_as_text()
    file.close()
	
    var parse_result = json.parse(json_text)
    if parse_result != OK:
        print("Error parsing config file, using default config")
        config_data = default_config.duplicate(true)
        save_config()
        return
	
    config_data = json.data
	
    # Merge with default config to ensure all keys exist
    merge_with_default(config_data, default_config)
	
    print("Config loaded successfully from: ", OS.get_user_data_dir() + "/config.json")

func save_config():
    var file = FileAccess.open(CONFIG_PATH, FileAccess.WRITE)
    if file == null:
        print("Error: Could not open config file for writing")
        return
	
    var json_string = JSON.stringify(config_data, "\t")
    file.store_string(json_string)
    file.close()
	
    print("Config saved to: ", OS.get_user_data_dir() + "/config.json")

func merge_with_default(target: Dictionary, source: Dictionary):
    for key in source:
        if not target.has(key):
            target[key] = source[key]
        elif typeof(target[key]) == TYPE_DICTIONARY and typeof(source[key]) == TYPE_DICTIONARY:
            merge_with_default(target[key], source[key])
            
func get_config(key_path: String, default_value = null):
    var keys = key_path.split(".")
    var current = config_data
	
    for key in keys:
        if typeof(current) == TYPE_DICTIONARY and current.has(key):
            current = current[key]
        else:
            current = default_value
	
    print("Loading config: ", key_path, " Value = ", current)
    return current

func set_config(key_path: String, value):
    var keys = key_path.split(".")
    var current = config_data
	
    for i in range(keys.size() - 1):
        var key = keys[i]
        if not current.has(key):
            current[key] = {}
        current = current[key]
	
    current[keys[-1]] = value
    save_config()
    print("Set config: ", key_path, " Value = ", value)