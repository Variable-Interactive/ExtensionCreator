extends Node

# NOTE: (ExtensionsApi) and get_node_or_null("/root/ExtensionsApi") mean the same thing.

var id: int
func _enter_tree() -> void:
	var exporter_info := {"extension": ".png", "description": "Only Alternate Frames"}
	id = ExtensionsApi.export.add_export_option(
		exporter_info, self, ExtensionsApi.export.ExportTab.IMAGE, false
	)  # 2nd argument (in this case "self") must have "override_export()" in it's script


func _exit_tree() -> void:
	# remember to remove things that you added using this extension
	ExtensionsApi.export.remove_export_option(id)


func override_export(details: Dictionary) -> bool:
	# in this function you take control of image processing and saving from pixelorama
	# return true for SUCCESS, false for FAILURE

	# the (details) include everything you could possibly need for exporting
	# keys of (details) are:
	# "processed_images", "export_dialog", "export_paths", "project"
	# (Note: processed_images is an array of ProcessedImage resource which further has parameters
	# called image and duration)
	for i in range(0, details["processed_images"].size(), 2):
		var image: Image = details["processed_images"][i].image
		var error = image.save_png(details["export_paths"][i])
		if error != OK:
			return false
	return true
