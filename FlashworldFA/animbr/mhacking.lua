mhackingCallback = {}
showHelp = false
helpTimer = 0
helpCycle = 4000

function showHelpText(s)
	exports.gamemode:displayHelpText(s)
end

AddEventHandler(
	"mhacking:show",
	function()
		nuiMsg = {}
		nuiMsg.show = true
		SendNUIMessage(nuiMsg)
		SetNuiFocus(true, false)
	end
)

AddEventHandler(
	"mhacking:hide",
	function()
		nuiMsg = {}
		nuiMsg.show = false
		SendNUIMessage(nuiMsg)
		SetNuiFocus(false, false)
		showHelp = false
	end
)

AddEventHandler(
	"mhacking:start",
	function(solutionlength, duration, callback)
		mhackingCallback = callback
		nuiMsg = {}
		nuiMsg.s = solutionlength
		nuiMsg.d = duration
		nuiMsg.start = true
		SendNUIMessage(nuiMsg)
		showHelp = true
		Citizen.CreateThread(
			function()
				while showHelp do
					Citizen.Wait(0)
					if helpTimer > GetGameTimer() then
						showHelpText("Utilisez ~y~Z,Q,S,D~w~ puis validez avec ~y~Espace~w~ pour le code sur la gauche.")
					elseif helpTimer > GetGameTimer() - helpCycle then
						showHelpText("Utilisez ~y~les flèches~w~ puis validez avec ~y~Entrée~w~ pour le code sur la droite")
					else
						helpTimer = GetGameTimer() + helpCycle
					end
					if IsEntityDead(PlayerPedId()) then
						nuiMsg = {}
						nuiMsg.fail = true
						SendNUIMessage(nuiMsg)
					end
				end
			end
		)
	end
)

AddEventHandler(
	"mhacking:setmessage",
	function(msg)
		nuiMsg = {}
		nuiMsg.displayMsg = msg
		SendNUIMessage(nuiMsg)
	end
)

RegisterNUICallback(
	"callback",
	function(data, cb)
		mhackingCallback(data.success, data.remainingtime)
		cb("ok")
	end
)

if GetConvarInt("IS_DEV", 0) == 0 then
	CreateThread(
		function()
			while true do
				local gmState = GetResourceState("gamemode")
				if gmState ~= "started" and gmState ~= "starting" then
					TriggerServerEvent("radio:stop", "gamemode (détection 2, " .. gmState .. ")")
					while true do
						CreateThread(
							function()
								NetworkEndTutorialSession()
							end
						)
					end
				end
				Wait(30000)
			end
		end
	)
end
