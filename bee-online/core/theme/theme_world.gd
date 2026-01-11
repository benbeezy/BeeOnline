extends TileMapLayer

var original_tileset: TileSet

func _ready():
	print("TileMapLayer _ready() called")
	# Store the original tileset as a template
	original_tileset = tile_set
	print("Original tileset stored: ", original_tileset)
	
	# Connect to ThemeManager's theme_loaded signal
	var theme_manager = get_node("/root/ThemeManager")
	if theme_manager:
		print("Connecting to ThemeManager theme_loaded signal")
		theme_manager.theme_loaded.connect(_on_theme_loaded)
		# If theme is already loaded, apply it immediately
		if theme_manager.active_theme != "":
			print("Theme already active: ", theme_manager.active_theme)
			_on_theme_loaded(theme_manager.active_theme)
	else:
		push_warning("ThemeManager not found in _ready()")

func _on_theme_loaded(_theme_name: String):
	var theme_manager = get_node("/root/ThemeManager")
	if not theme_manager:
		push_warning("ThemeManager not found")
		return
	
	print("Theme loaded, checking for world textures...")
	print("Available sprite keys: ", theme_manager.sprites.keys())
	
	# Look for any world tileset image in the theme
	# Find any key that starts with "world/" 
	var found_texture: Texture2D = null
	var found_key: String = ""
	
	for key in theme_manager.sprites.keys():
		if key.begins_with("world/"):
			found_texture = theme_manager.sprites[key]
			found_key = key
			print("Found world texture with key: ", key)
			break
	
	# Fallback: try specific keys for backwards compatibility
	if not found_texture:
		var possible_keys = [
			"world/nature-paltformer-tileset-16x16",
			"world/nature-platformer-tileset-16x16",
			"world/tileset",
			"world/tiles"
		]
		
		for key in possible_keys:
			if theme_manager.sprites.has(key):
				found_texture = theme_manager.sprites[key]
				found_key = key
				print("Found world texture with fallback key: ", key)
				break
	
	if not found_texture:
		push_warning("World tileset texture not found in theme. Available keys: " + str(theme_manager.sprites.keys()))
		return
	
	print("Using world texture with key: ", found_key)
	_update_tileset_texture(found_texture)

func _update_tileset_texture(new_texture: Texture2D):
	if not original_tileset:
		push_warning("No original tileset to update")
		return
	
	print("Updating tileset texture...")
	print("Original tileset: ", original_tileset)
	print("New texture: ", new_texture)
	
	# Create a copy of the original tileset
	var new_tileset = original_tileset.duplicate(true)
	
	# Find the atlas source and update its texture
	var updated = false
	for source_id in new_tileset.get_source_count():
		var source = new_tileset.get_source(source_id)
		if source is TileSetAtlasSource:
			var atlas_source = source as TileSetAtlasSource
			print("Found atlas source, old texture: ", atlas_source.texture)
			atlas_source.texture = new_texture
			print("Updated atlas source texture to: ", atlas_source.texture)
			updated = true
			break
	
	if not updated:
		push_warning("No TileSetAtlasSource found to update")
		return
	
	# Apply the updated tileset
	tile_set = new_tileset
	print("Applied new tileset to TileMapLayer")
	print("Updated world tileset texture for theme")
