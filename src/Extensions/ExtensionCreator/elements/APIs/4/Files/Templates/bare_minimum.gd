extends Node

# NOTE: (ExtensionsApi) and get_node_or_null("/root/ExtensionsApi") mean the same thing.

# This script acts as a setup for the extension
func _enter_tree() -> void:
	pass


func _exit_tree() -> void:  # Extension is being uninstalled or disabled
	# remember to remove things that you added using this extension
	pass
