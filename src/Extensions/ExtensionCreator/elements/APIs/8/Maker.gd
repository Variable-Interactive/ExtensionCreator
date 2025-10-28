extends RefCounted


func make(
	save_path: String,
	extension_json: Dictionary,
	template := MainGd.ADD_PANNEL,
	_current_theme: Theme = null
) -> int:
	var extension_name: StringName = extension_json.get("name", "Example")
	var extension_path = save_path.path_join("src/Extensions").path_join(extension_name)
	var project_path = save_path.path_join("project.godot")
	var export_cfg_path = save_path.path_join("export_presets.cfg")
	var main_tscn_path = extension_path.path_join("Main.tscn")
	var main_gd_path = extension_path.path_join("Main.gd")

	# Step 1 : make extension files first
	var icon: Image = Image.load_from_file("res://icon.png")
	if icon:
		icon.save_png(save_path.path_join("icon.png"))
	var file = FileAccess.open(project_path, FileAccess.WRITE)
	file.store_string(ProjectGodot.make(extension_json))  # project.godot
	file = FileAccess.open(export_cfg_path, FileAccess.WRITE)
	file.store_string(ExportCfg.make(extension_name))  # export.cfg
	file = FileAccess.open(main_tscn_path, FileAccess.WRITE)
	file.store_string(MainTscn.make(extension_name))  # Main.tscn
	file = FileAccess.open(main_gd_path, FileAccess.WRITE)
	file.store_string(
		MainGd.make(template).replace(
			"<GDExtension>", (extension_name + "Files").capitalize().replace(" ", ""))
	)  # Main.gd
	file.close()

	# Since Api 8, we have a better way for manipulating themes
	#if template == MainGd.ADD_THEME:
	#	ResourceSaver.save(current_theme, save_path.path_join("Theme.tres"))

	return OK


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
config/features=PackedStringArray("4.5", "GL Compatibility")
config/description="A pixelorama Extention"
config/tags=PackedStringArray("pixelorama_extension")
config/icon="res://icon.png"

[rendering]

renderer/rendering_method="gl_compatibility"
renderer/rendering_method.mobile="gl_compatibility"
"""
)

	static func make(extension_json: Dictionary) -> String:
		return text.replace(
			"Example", extension_json.get("name", "Example")
		).replace(
			"A pixelorama Extention", extension_json.get("description", "A pixelorama Extention")
		)


class ExportCfg:
	const text = (
"""
[preset.0]

name="Export Extension (PCK)"
platform="Windows Desktop"
runnable=false
custom_features=""
export_filter="all_resources"
include_filter="*.json"
exclude_filter="<EXCLUDE_ME>"
export_path=""
script_export_mode=2
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


class MainTscn:
	const text = (
"""
[gd_scene load_steps=2 format=3]

[ext_resource type="Script" path="res://src/Extensions/%s/Main.gd" id=1]

[node name="Main" type="Node"]
script = ExtResource( 1 )
"""
)

	static func make(extension_name: String) -> String:
		return text % extension_name


class MainGd:
	enum {
		BARE_MINIMUM,
		ADD_PANNEL,
		ADD_MENU_ITEM,
		ADD_THEME,
		PROJECT_MANIPULATOR,
		NEW_EXPORTER,
		GD_EXTENSION
	}
	const base_path = "res://src/Extensions/ExtensionCreator/elements/APIs/6"
	const scripts := {
		BARE_MINIMUM : "Files/Templates/bare_minimum.txt",
		ADD_PANNEL : "Files/Templates/add_pannel.txt",
		ADD_MENU_ITEM: "Files/Templates/add_menu_item.txt",
		ADD_THEME: "Files/Templates/add_theme.txt",
		PROJECT_MANIPULATOR: "Files/Templates/project_manipulator.txt",
		NEW_EXPORTER: "Files/Templates/add_exporter.txt",
		GD_EXTENSION: "Files/Templates/gd_extension.txt",
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
