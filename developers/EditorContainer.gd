extends TabContainer

func change_to(new_page, target):
	get_parent().get_node("AcceptDialog").dialog_text = "TruthPedia® link to page '%s' section '%s' clicked" % [new_page, target]
	get_parent().get_node("AcceptDialog").popup_centered()
