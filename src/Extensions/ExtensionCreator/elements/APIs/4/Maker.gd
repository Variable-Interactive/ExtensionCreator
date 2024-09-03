extends RefCounted


func make(
	save_path: String,
	extension_name: String,
	template := MainGd.ADD_PANNEL,
	current_theme: Theme = null
) -> int:
	var extension_path = save_path.path_join("src/Extensions/").path_join(extension_name)
	var project_path = save_path.path_join("project.godot")
	var export_cfg_path = save_path.path_join("export_presets.cfg")
	var main_tscn_path = extension_path.path_join("Main.tscn")
	var main_gd_path = extension_path.path_join("Main.gd")

	# Step 1 : make extension files first
	var file = FileAccess.open(project_path, FileAccess.WRITE)
	file.store_string(ProjectGodot.make(extension_name))
	file = FileAccess.open(export_cfg_path, FileAccess.WRITE)
	file.store_string(ExportCfg.make(extension_name))
	file = FileAccess.open(main_tscn_path, FileAccess.WRITE)
	file.store_string(MainTscn.make(extension_name))
	file = FileAccess.open(main_gd_path, FileAccess.WRITE)
	file.store_string(MainGd.make(template))
	file.close()

	if template == MainGd.ADD_THEME:
		ResourceSaver.save(current_theme, save_path.path_join("Theme.tres"))

#	# Step 2 : Now make Api Files
	return Api.generate_api_files(save_path)


class ProjectGodot:
	const text = (
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
run/main_scene="res://src/Extensions/Example/Main.tscn"
config/features=PackedStringArray("4.2", "GL Compatibility")
config/description="A pixelorama Extention (The Name and Description field are not related to extention system so they can be anything)"

[rendering]

renderer/rendering_method="gl_compatibility"
renderer/rendering_method.mobile="gl_compatibility"
"""
)

	static func make(extension_name: String) -> String:
		return text.replace("Example", extension_name)


class ExportCfg:
	const text = (
"""
[preset.0]

name="Export Extension (PCK)"
platform="Windows Desktop"
runnable=true
custom_features=""
export_filter="all_resources"
include_filter="*.json"
exclude_filter="<EXCLUDE_ME>"
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

	static func make(extension_name: String) -> String:
		return text.replace("Example", extension_name).replace("<EXCLUDE_ME>", "")
		#return text.replace("Example", extension_name).replace("<EXCLUDE_ME>", Api.exclude_filter)


class MainTscn:
	const text = (
"""
[gd_scene load_steps=2 format=3]

[ext_resource path="res://src/Extensions/%s/Main.gd" type="Script" id=1]

[node name="Main" type="Node"]
script = ExtResource( 1 )
"""
)

	static func make(extension_name: String) -> String:
		return text % extension_name


class MainGd:
	enum { BARE_MINIMUM, ADD_PANNEL, ADD_MENU_ITEM, ADD_THEME, PROJECT_MANIPULATOR, NEW_EXPORTER }
	const base_path = "res://src/Extensions/ExtensionCreator/elements/APIs/4"
	const scripts := {
		BARE_MINIMUM : "Files/Templates/bare_minimum.txt",
		ADD_PANNEL : "Files/Templates/add_pannel.txt",
		ADD_MENU_ITEM: "Files/Templates/add_menu_item.txt",
		ADD_THEME: "Files/Templates/add_theme.txt",
		PROJECT_MANIPULATOR: "Files/Templates/project_manipulator.txt",
		NEW_EXPORTER: "Files/Templates/add_exporter.txt",
	}

	static func make(idx: int) -> String:
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
	const base_path = "res://src/Extensions/ExtensionCreator/elements/APIs/4"
	const exclude_filter = "res://src/Autoload/*, res://src/Classes/*, res://src/UI/*"
	const scripts := [
		"Files/Autoload/ExtensionsApi.txt",
		"Files/Classes/AnimationExporters/GIFAnimationExporter.txt",
		"Files/Classes/Cels/BaseCel.txt",
		"Files/Classes/Cels/Cel3D.txt",
		"Files/Classes/Cels/PixelCel.txt",
		"Files/Classes/Cels/GroupCel.txt",
		"Files/Classes/Layers/BaseLayer.txt",
		"Files/Classes/Layers/GroupLayer.txt",
		"Files/Classes/Layers/Layer3D.txt",
		"Files/Classes/Layers/PixelLayer.txt",
		"Files/Classes/Tools/BaseSelectionTool.txt",
		"Files/Classes/Tools/BaseTool.txt",
		"Files/Classes/AnimationTag.txt",
		"Files/Classes/Cel3DObject.txt",
		"Files/Classes/Drawers.txt",
		"Files/Classes/Frame.txt",
		"Files/Classes/ImageEffect.txt",
		"Files/Classes/LayerEffect.txt",
		"Files/Classes/ObjParse.txt",
		"Files/Classes/Project.txt",
		"Files/Classes/SelectionMap.txt",
		"Files/Classes/ShaderImageEffect.txt",
		"Files/Classes/ShaderLoader.txt",
		"Files/Classes/Tiles.txt",
		"Files/UI/Nodes/ValueSlider.txt",
		"Files/UI/Nodes/ValueSliderV2.txt",
		"Files/UI/Nodes/ValueSliderV3.txt",
	]
	static func generate_api_files(res_dir_path: String) -> int:
		return OK  ## Disabling this feature
		for script_path: String in scripts:
			var src_path = res_dir_path.path_join("src")
			var path = script_path.replace("Files", src_path).replace(".txt", ".gd")
			var error := DirAccess.make_dir_recursive_absolute(path.get_base_dir())
			if error != OK:
				return error
			var file := FileAccess.open(base_path.path_join(script_path), FileAccess.READ)
			if FileAccess.get_open_error() != OK:
				return FileAccess.get_open_error()
			var text = file.get_as_text()
			file.close()
			file = FileAccess.open(path, FileAccess.WRITE)
			if FileAccess.get_open_error() != OK:
				return FileAccess.get_open_error()
			file.store_string(text)
			file.close()
		return OK
