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

func load_config():
	var file = FileAccess.open(CONFIG_PATH, FileAccess.READ)
	
	if file == null:
		print("Config file not found, creating default config at: ", CONFIG_PATH)
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
	
	print("Config loaded successfully from: ", CONFIG_PATH)

func save_config():
	var file = FileAccess.open(CONFIG_PATH, FileAccess.WRITE)
	if file == null:
		print("Error: Could not open config file for writing")
		return
	
	var json_string = JSON.stringify(config_data, "\t")
	file.store_string(json_string)
	file.close()
	
	print("Config saved to: ", CONFIG_PATH)

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
			return default_value
	
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
