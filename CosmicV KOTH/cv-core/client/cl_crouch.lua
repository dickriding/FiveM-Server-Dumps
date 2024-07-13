local isCrouching = false
local stanceCooldown = 0

function Crouch()
	if stanceCooldown < GetGameTimer() then
		stanceCooldown = GetGameTimer() + 600
		local ply = PlayerPedId()
		isCrouching = not isCrouching
		if isCrouching then
			Citizen.CreateThread(function()
				RequestAnimSet('move_ped_crouched')
				SetPedCanPlayAmbientAnims(ply, false)
				SetPedCanPlayAmbientBaseAnims(ply, false)
				while not HasAnimSetLoaded('move_ped_crouched') do
					Wait(0)
					RequestAnimSet('move_ped_crouched')
				end
				SetPedMovementClipset(ply, 'move_ped_crouched', 0.35)
				SetPedStrafeClipset(ply, 'move_ped_crouched_strafing')
				SetWeaponAnimationOverride(ply, "Ballistic")
				while isCrouching do
					Citizen.Wait(0)
					SetPedCanPlayAmbientAnims(ply, false)
					SetPedCanPlayAmbientBaseAnims(ply, false)
					SetPedMovementClipset(ply, 'move_ped_crouched', 0.35)
					SetPedStrafeClipset(ply, 'move_ped_crouched_strafing')
					ClearFacialIdleAnimOverride(ply)
					if IsPlayerFreeAiming(player) then
						SetPedMaxMoveBlendRatio(ply, 0.2)
					else
						if IsAimCamActive() or IsAimCamThirdPersonActive() then
							SetPedMaxMoveBlendRatio(ply, 0.2)
						else
							SetPedMaxMoveBlendRatio(ply, 10.0)
						end
					end
				end
				ResetPedStrafeClipset(ply)
				SetPedCanPlayAmbientAnims(ply, true)
				SetPedCanPlayAmbientBaseAnims(ply, true)
				ResetPedWeaponMovementClipset(ply)
				ResetPedMovementClipset(ply, 0.55)
			end)
		end
	end
end

Citizen.CreateThread(function()
	KeyMapping("cv-core:crouch", "Player", "Crouch", "crouch", 'LCONTROL')
	RegisterCommand('+crouch', Crouch, false)
end)