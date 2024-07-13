RegisterNetEvent("cv-ui:setAttachmentCategories", function(attachments)
    SetNuiFocus(true, true)
    SendNUIMessage({
		type = "setAttachmentCategories",
		data = attachments
	})
    SendNUIMessage({
		type = "setDisplayAttachments",
		data = true
	})
end)

local selectedAttachments = {}

RegisterNetEvent("cv-ui:setSelectedAttachment", function(category, hash)
	selectedAttachments[category] = hash
    SendNUIMessage({
		type = "setSelectedAttachments",
		data = selectedAttachments
	})
end)

RegisterNetEvent("cv-ui:closeAttachmentMenu", function()
    SetNuiFocus(false, false)
    SendNUIMessage({
		type = "setDisplayAttachments",
		data = false
	})
end)

RegisterNuiCallback('closeAttachmentsMenu', function(data, cb)
	TriggerEvent("cv-ui:closeAttachmentMenu")
	cb("OK")
end)

RegisterNuiCallback('selectAttachment', function(data, cb)
	if data.category == "tints" then
		return TriggerEvent("cv-koth:setWeaponTint", data.hash)
	end
	if data.oldHash ~= data.hash then
		TriggerEvent("cv-koth:removeAttachment", data.oldHash)
		TriggerEvent("cv-koth:selectAttachment", data.hash)
		TriggerEvent("cv-ui:setSelectedAttachment", data.category, data.hash)
	else
		if not HasPedGotWeaponComponent(PlayerPedId(), GetSelectedPedWeapon(PlayerPedId()), data.hash) then
			TriggerEvent("cv-koth:selectAttachment", data.hash)
			TriggerEvent("cv-ui:setSelectedAttachment", data.category, data.hash)
		else
			TriggerEvent("cv-koth:removeAttachment", data.oldHash)
			TriggerEvent("cv-ui:setSelectedAttachment", data.category, "none")
		end
	end

	cb("OK")
end)