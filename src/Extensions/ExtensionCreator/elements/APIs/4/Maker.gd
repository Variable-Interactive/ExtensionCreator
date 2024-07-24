extends Node


static func make(save_path: String, extension_name: String, template := MainGd.ADD_PANNEL) -> int:
	var extension_path = save_path.path_join("src/Extensions/").path_join(extension_name)
	var project = ProjectGodot.new()
	var project_path = save_path.path_join("project.godot")
	var export_cfg = ExportCfg.new()
	var export_cfg_path = save_path.path_join("export_presets.cfg")
	var main_tscn = MainTscn.new()
	var main_tscn_path = extension_path.path_join("Main.tscn")
	var main_gd = MainGd.new()
	var main_gd_path = extension_path.path_join("Main.gd")
	var api = Api.new()
	var api_path = extension_path.path_join("API")

	# Step 1 : make extension files first
	var file = FileAccess.open(project_path, FileAccess.WRITE)
	file.store_string(project.make(extension_name))
	file.close()
	file = FileAccess.open(export_cfg_path, FileAccess.WRITE)
	file.store_string(export_cfg.make(extension_name))
	file.close()
	file = FileAccess.open(main_tscn_path, FileAccess.WRITE)
	file.store_string(main_tscn.make(extension_name))
	file.close()
	file = FileAccess.open(main_gd_path, FileAccess.WRITE)
	file.store_string(main_gd.make(template))
	file.close()
	if template == MainGd.ADD_THEME:
		var theme: Theme = ExtensionsApi.theme.get_theme()
		ResourceSaver.save(theme, save_path.path_join("Theme.tres"))

#	# Step 2 : Now make Api Files
	var err = api.generate_api_files(api_path)
	if err != OK:
		return err
	return 0


class ProjectGodot:
	var text = (
"""
; Engine configuration file.
; It's best edited using the editor UI and not directly,
; since the parameters that go here are not all obvious.
;
; Format:
;   [section] ; section goes between []
;   param=value ; assign values to parameters

config_version=5

[application]

config/name="Example"
config/description="A pixelorama Extention (The \"Name\" and \"Description\" field are not related to extention system so they can be anything)"
config/features=PackedStringArray("4.2", "GL Compatibility")
run/main_scene="res://src/Extensions/Example/Main.tscn"

[autoload]

ExtensionsApi="*res://src/Extensions/Example/API/ExtensionsApi.gd"

[rendering]

renderer/rendering_method="gl_compatibility"
renderer/rendering_method.mobile="gl_compatibility"
"""
)

	func make(extension_name: String):
		return text.replace("Example", extension_name)


class ExportCfg:
	var text = (
"""
[preset.0]

name="Export Extension (PCK)"
platform="Windows Desktop"
runnable=true
custom_features=""
export_filter="all_resources"
include_filter="*.json"
exclude_filter="res://src/Extensions/Example/API"
export_path=""
script_export_mode=1
script_encryption_key=""

[preset.0.options]

custom_template/debug=""
custom_template/release=""
binary_format/64_bits=true
binary_format/embed_pck=false
texture_format/bptc=false
texture_format/s3tc=true
texture_format/etc=false
texture_format/etc2=false
texture_format/no_bptc_fallbacks=true
codesign/enable=false
codesign/identity=""
codesign/password=""
codesign/timestamp=true
codesign/timestamp_server_url=""
codesign/digest_algorithm=1
codesign/description=""
codesign/custom_options=PackedStringArray(  )
application/icon=""
application/file_version=""
application/product_version=""
application/company_name=""
application/product_name=""
application/file_description=""
application/copyright=""
application/trademarks=""
"""
)

	func make(extension_name: String):
		return text.replace("Example", extension_name)


class MainTscn:
	var text = (
"""
[gd_scene load_steps=2 format=3]

[ext_resource path="res://src/Extensions/%s/Main.gd" type="Script" id=1]

[node name="Main" type="Node"]
script = ExtResource( 1 )
"""
)

	func make(extension_name: String):
		return text % extension_name


class MainGd:
	enum { BARE_MINIMUM, ADD_PANNEL, ADD_MENU_ITEM, ADD_THEME, PROJECT_MANIPULATOR, NEW_EXPORTER }
	var base_path = "res://src/Extensions/ExtensionCreator/elements/APIs/4"
	var scripts := {
		BARE_MINIMUM : "Files/Templates/bare_minimum.gd",
		ADD_PANNEL : "Files/Templates/add_pannel.gd",
		ADD_MENU_ITEM: "Files/Templates/add_menu_item.gd",
		ADD_THEME: "Files/Templates/add_theme.gd",
		PROJECT_MANIPULATOR: "Files/Templates/project_manipulator.gd",
		NEW_EXPORTER: "Files/Templates/add_exporter.gd",
	}

	func make(idx: int) -> String:
		var script_path = scripts[BARE_MINIMUM]
		if idx in scripts.keys():
			script_path = scripts[idx]
		var file := FileAccess.open(base_path.path_join(script_path), FileAccess.READ)
		if FileAccess.get_open_error() == OK:
			var text = file.get_as_text()
			file.close()
			return text
		return ""


class Api:
	var base_path = "res://src/Extensions/ExtensionCreator/elements/APIs/4"
	var scripts := {
		"ExtensionsApi.gd" : "Files/ExtensionsApi.gd",
		"EmptyClasses/GIFAnimationExporter.gd": "Files/Classes/AnimationExporters/GIFAnimationExporter.gd",
		"EmptyClasses/BaseCel.gd": "Files/Classes/Cels/BaseCel.gd",
		"EmptyClasses/Cel3D.gd": "Files/Classes/Cels/Cel3D.gd",
		"EmptyClasses/PixelCel.gd": "Files/Classes/Cels/PixelCel.gd",
		"EmptyClasses/GroupCel.gd": "Files/Classes/Cels/GroupCel.gd",
		"EmptyClasses/BaseLayer.gd": "Files/Classes/Layers/BaseLayer.gd",
		"EmptyClasses/GroupLayer.gd": "Files/Classes/Layers/GroupLayer.gd",
		"EmptyClasses/Layer3D.gd": "Files/Classes/Layers/Layer3D.gd",
		"EmptyClasses/PixelLayer.gd": "Files/Classes/Layers/PixelLayer.gd",
		"EmptyClasses/BaseSelectionTool.gd": "Files/Classes/Tools/BaseSelectionTool.gd",
		"EmptyClasses/BaseTool.gd": "Files/Classes/Tools/BaseTool.gd",
		"EmptyClasses/AnimationTag.gd": "Files/Classes/AnimationTag.gd",
		"EmptyClasses/Cel3DObject.gd": "Files/Classes/Cel3DObject.gd",
		"EmptyClasses/Drawers.gd": "Files/Classes/Drawers.gd",
		"EmptyClasses/Frame.gd": "Files/Classes/Frame.gd",
		"EmptyClasses/ImageEffect.gd": "Files/Classes/ImageEffect.gd",
		"EmptyClasses/LayerEffect.gd": "Files/Classes/LayerEffect.gd",
		"EmptyClasses/ObjParse.gd": "Files/Classes/ObjParse.gd",
		"EmptyClasses/Project.gd": "Files/Classes/Project.gd",
		"EmptyClasses/SelectionMap.gd": "Files/Classes/SelectionMap.gd",
		"EmptyClasses/ShaderImageEffect.gd": "Files/Classes/ShaderImageEffect.gd",
		"EmptyClasses/Tiles.gd": "Files/Classes/Tiles.gd",
	}
	func generate_api_files(api_path: String) -> int:
		DirAccess.make_dir_recursive_absolute(api_path)
		if DirAccess.get_open_error() != OK:
			return DirAccess.get_open_error()
		DirAccess.make_dir_recursive_absolute(api_path.path_join("EmptyClasses"))
		if DirAccess.get_open_error() != OK:
			return DirAccess.get_open_error()
		for script in scripts.keys():
			var file = FileAccess.open(base_path.path_join(scripts[script]), FileAccess.READ)
			if FileAccess.get_open_error() != OK:
				return FileAccess.get_open_error()
			var text = file.get_as_text()
			file.close()
			file = FileAccess.open(api_path.path_join(script), FileAccess.WRITE)
			if FileAccess.get_open_error() != OK:
				return FileAccess.get_open_error()
			file.store_string(text)
			file.close()
		return 0
