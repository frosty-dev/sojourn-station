/datum/objective/crusade

/datum/objective/crusade/update_explanation()
	explanation_text = "Let none hivemind atrocity survive!"

/datum/objective/crusade/check_completion()
	if (failed)
		return FALSE

	var/obj/machinery/hivemind_machine/HV = locate()
	if(HV)
		return FALSE
	return TRUE