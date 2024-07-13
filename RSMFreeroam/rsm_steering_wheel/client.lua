Config = {}

Config.gears = {
    [1] = {0.90},--1
    [2] = {3.33, 0.90},--2
    [3] = {3.33, 1.57, 0.90},--3
    [4] = {3.33, 1.83, 1.22, 0.90},--4
    [5] = {3.33, 1.92, 1.36, 1.05, 0.90},--5
    [6] = {3.33, 1.95, 1.39, 1.09, 0.95, 0.90},--6
    [7] = {4.00, 2.34, 1.67, 1.31, 1.14, 1.08, 0.90},--7
    [8] = {5.31, 3.11, 2.22, 1.74, 1.51, 1.43, 1.20, 0.90},--8
    [9] = {7.70, 4.51, 3.22, 2.52, 2.20, 2.08, 1.73, 1.31, 0.90}--9
}

Config.vehicles = {}

Citizen.CreateThread(function()
    Wait(2000)
	SendNUIMessage({
	    vehicle = true,
		pad = t
	})
end)

Config.enginebrake = true -- brakes the car if you downshift the wrong way

local vehicle = nil
local numgears = nil
local topspeedGTA = nil
local topspeedms = nil
local acc = nil
local hash = nil
local selectedgear = 0 
local hbrake = nil
local manualon = false
local incar = false
local currspeedlimit = nil
local ready = false
local accelerate = false
local brakePedal = false
local patinage = false
local patinageWrong = false
local wheel = 0.0
local acceleration = 0.0
local brake = 0.0
local activeTurnDroit = false
local activeTurnGauche = false
local clignoDroit = 0
local clignoGauche = 0
local clignoDroitActive = false
local clignoGaucheActive = false
local nitro = false
local nitroEnable = false
local handBrakeActive = false
local UIvehicle = false
local hGear = false
local Sequential = false
local Automatic = false
local Up = false
local Down = false
local IndexMenu

local RuntimeTXD = CreateRuntimeTxd('Custom_Menu_Head_Transmission')
local Object = CreateDui("https://i.imgur.com/WXtNRN0.png", 1024, 256)
_G.Object = Object
local TextureThing = GetDuiHandle(Object)
local Texture = CreateRuntimeTextureFromDuiHandle(RuntimeTXD, 'Custom_Menu_Head_Transmission', TextureThing)
Menuthing = "Custom_Menu_Head_Transmission"
mainMenu = RageUI.CreateMenu("",  "Configuration", 1400, 0, Menuthing, Menuthing)

RegisterCommand('+menutransmission', function()
    Wait(150)
    RageUI.Visible(mainMenu, not RageUI.Visible(mainMenu))
end, false)
RegisterCommand('-menutransmission', function() end, false)
RegisterKeyMapping('+menutransmission', 'Manual Transmission', 'keyboard', 'J')

--MENU TRANSIMISSION
local waitMenuTr = 1000

Citizen.CreateThread(function()
    while (true) do
        Citizen.Wait(waitMenuTr)
        RageUI.IsVisible(mainMenu, function()
            RageUI.Checkbox("Enable Manual Transmission", "", manualon, {}, {
			    onChecked = function()
                end,
                onUnChecked = function()
                    resetvehicle()
                end,
                onSelected = function(Index)
				    if not Automatic then
                        manualon = Index
					end
                end
            })
			
			RageUI.List("Gearbox", {
                    { Name = "~b~H Gear~s~"},
                    { Name = "~b~Sequential~s~"},
					{ Name = "~b~Automatic~s~"},
                }, IndexMenu or 1, "", {}, true, {
                    onListChange = function(Index, Item)
                        IndexMenu = Index;
                    end,

                    onSelected = function(Index, Item)
                        if Index == 1 then  --> H Gear
                            hGear = true
                            Sequential = false
                            Automatic = false
                        elseif Index == 2 then --> Sequential
                            hGear = false
                            Sequential = true
                            Automatic = false
						elseif Index == 3 then --> Automatic
						    hGear = false
                            Sequential = false
                            Automatic = true
                            manualon = false
							if vehicle ~= nil then
							    SetVehicleHandbrake(vehicle, false)
							end
                        end
                end,
            })
			
			RageUI.Checkbox("Enable UI", "", UIvehicle, {}, {
			    onChecked = function()
                    SendNUIMessage({ UI = true })
                end,
                onUnChecked = function()
                    SendNUIMessage({ UI = false })
                end,
                onSelected = function(Index)
                    UIvehicle = Index
                end
            })
			
        end, function()end)
		if RageUI.Visible(mainMenu) then
		    waitMenuTr = 1
            DisableControlAction(0, 140, true) 
            DisableControlAction(0, 172, true) 
		else
		    waitMenuTr = 100
        end
	end
end)

RegisterNUICallback('updateGamepad', function(data)
    if vehicle ~= nil then
	    if not Automatic then
	        if round((GetEntitySpeed(vehicle)*3.6),0) == 0.0 then
		        if not Sequential then
		    		if data.clignotantGauche ~= nil or data.clignotantDroit ~= nil then
		    	        if data.clignotantGauche == 1 then
		    	    	    if clignoGaucheActive then
		    	    		    clignoGauche = 0
		    	    	        clignoDroit = 0
		    	    		    clignoGaucheActive = false
		    	    	        clignoDroitActive = false
		    	    			
		    	    		else
		    	    		    clignoGauche = 1
		    	    	        clignoDroit = 0
		    	    		    clignoGaucheActive = false
		    	    	        clignoDroitActive = false
		    	    		end
		    	    		Wait(100)
		    	    	elseif data.clignotantDroit == 1 then
		    	    	    if clignoDroitActive then
		    	    		    clignoGauche = 0
		    	    	        clignoDroit = 0
		    	    		    clignoGaucheActive = false
		    	    	        clignoDroitActive = false
		    	    		else
		    	    	        clignoGauche = 0
		    	    	        clignoDroit = 1
		    	    		    clignoGaucheActive = false
		    	    	        clignoDroitActive = false
		    	    		end
		    	    		Wait(100)
		    	    	end
		    	    else
		    	        if clignoGauche == 1 and clignoDroit == 0 then
		    	    	    clignoGaucheActive = true
		    	    	    clignoDroitActive = false
		    	    		clignoGauche = 0
		    	    		clignoDroit = 0
		    	    	elseif clignoGauche == 0 and clignoDroit == 1 then
		    	    	    clignoGaucheActive = false
		    	    	    clignoDroitActive = true
		    	    		clignoGauche = 0
		    	    		clignoDroit = 0
		    	    	end
		    	    end
		    	    if clignoDroitActive then
		    	        SetVehicleIndicatorLights(vehicle, 1, false)
		    	        SetVehicleIndicatorLights(vehicle, 0, true)
		    	    elseif clignoGaucheActive then
		    	        SetVehicleIndicatorLights(vehicle, 1, true)
		    	        SetVehicleIndicatorLights(vehicle, 0, false)
		    	    else
		    	        SetVehicleIndicatorLights(vehicle, 1, false)
		    	        SetVehicleIndicatorLights(vehicle, 0, false)
		    	    end    
		    	end
		        if data.wheel ~= nil then
		    		if tonumber(data.wheel) < 0.0 then
		    	        wheel = tonumber(data.wheel) - 0.02
		    	    else
		    	        wheel = tonumber(data.wheel) + 0.02
		    	    end
		    		if wheel >= 0.02 then
		    			if clignoDroit == 1 then
		    			    activeTurnDroit = true
		    			end
		    		elseif wheel <= -0.02 then
		    		    if clignoGauche == 1 then
		    			    activeTurnGauche = true
		    			end
		    		else
		    		    if activeTurnGauche or activeTurnDroit then
		    			    clignoGauche = 0
		    			    clignoDroit = 0
		    			    activeTurnDroit = false
		    			    activeTurnGauche = false
		    			    clignoDroitActive = false
		    			    clignoGaucheActive = false
		    			end
		    		end
	            end
		    	if data.brake ~= nil then 
	                if tonumber(data.brake) > 0.0 then
		    			brakePedal = false
	            	    brake = 0.0
	            	end
	            end
		    	if selectedgear > 0 then
		    	    if not Sequential and tonumber(data.clutch) == 0.0 then
		    		    SetVehicleEngineOn(vehicle,false,true,false)
		    	        patinage = false
		    	        patinageWrong = false
		    		    acceleration = 0.0
		    		    accelerate = false
		    		end
		    	else
		    	    SetVehicleHandbrake(vehicle, true)
		    	end
		        if data.clutch ~= nil and data.throttle ~= nil and data.gear ~= nil then
		    	    if not Sequential then
		                if tonumber(data.clutch) > 0.5 and tonumber(data.throttle) == 0.0 then
		    	            if data.gear ~= nil and tonumber(data.gear) <= numgears or data.gear ~= nil and tonumber(data.gear) == 7 then
		    	        	    selectedgear = tonumber(data.gear)
		    	        		if selectedgear == 1 or selectedgear == 2 or selectedgear == 3 or selectedgear == 7 then
		    	        		    patinage = true
		    		    			patinageWrong = false
		    		    			SetVehicleHandbrake(vehicle, false)
		    	        		elseif selectedgear > 3 and selectedgear < 7 then
		    	        		    patinageWrong = true
		    		    			patinage = false
		    		    			SetVehicleHandbrake(vehicle, false)
		    	        		end
		    	        	end
		    		    else
		    		        if patinage and tonumber(data.clutch) < 0.5 and tonumber(data.throttle) > 0.0 then
		    		    	    if selectedgear == 7 then
		    		    		    brake = 0.5
		    	                    brakePedal = true
		    		    			acceleration = 0.0
		    	                    accelerate = false
		    		        	    patinage = false
		    		        	    patinageWrong = false
		    		    		else
		    		    		    acceleration = 0.5
		    	                    accelerate = true
		    		    			brake = 0.0
		    	                    brakePedal = false
		    		        	    patinage = false
		    		        	    patinageWrong = false
		    		    		end
		    		        elseif patinageWrong and tonumber(data.clutch) < 0.5 then
		    		            SetVehicleEngineOn(vehicle,false,true,false)
		    	                patinage = false
		    	                patinageWrong = false
		    		        	acceleration = 0.0
		    		        	accelerate = false
		    		    	end
		    		        if tonumber(data.throttle) > 0.0 and selectedgear == 0 then
		    		    	    accelerate = true
		    		            acceleration = tonumber(data.throttle) + .0
		    		    	end
		    	        end
		    		else
		    		    if tonumber(data.brake) > 0.0 then
		    		        if data.paletteDown ~= nil or data.paletteUp ~= nil then
		    				    
		    	                if not Up and data.paletteUp == true then
		    						Up = true
		    						Down = false
		    					elseif not Down and data.paletteDown == true then
		    						Up = false
		    						Down = true
		    					elseif Up and data.paletteUp == false then
		    					    if selectedgear <= numgears then
		    						    selectedgear = selectedgear + 1
		    						end
		    						Up = false
		    						Down = false
		    					elseif Down and data.paletteDown == false then
		    					    if selectedgear > 0 then
		    					        selectedgear = selectedgear - 1
		    						end
		    						Up = false
		    						Down = false
		    					end
		    			    end
		    			else
		    			    if selectedgear > 3 then
		    				    SetVehicleEngineOn(vehicle,false,true,false)
		    	                patinage = false
		    	                patinageWrong = true
		    		        	acceleration = 0.0
		    		        	accelerate = false
		    				    selectedgear = 0
		    			    else
		    				    acceleration = 0.5
		    	                accelerate = true
		    		    		brake = 0.0
		    	                brakePedal = false
		    		        	patinage = false
		    		        	patinageWrong = false
		    				end
		    			end
		    		end
		    	end
		    else
		    	if data.nitro ~= nil then
		    	    if data.nitro == 1 then
		    			if not nitro and nitroEnable then
		    			    SetVehicleBoostActive(vehicle, 1, 0)
		    	            SetVehicleForwardSpeed(vehicle, 80.0)
		    	            StartScreenEffect("RaceTurbo", 0, 0)
		    	            SetVehicleBoostActive(vehicle, 0, 0)
		    			    nitro = true
		    			end
		    		end 
		    	end
		    	if data.handBrake == 1 then
		    	    if not handBrakeActive then
		    			handBrakeActive = true
		    		end
				elseif data.handBrake == 0 then
				    if handBrakeActive then
		    			handBrakeActive = false
		    		end
		    	end
		        if not Sequential then
		    		if data.clignotantGauche ~= nil or data.clignotantDroit ~= nil then
		    	        if data.clignotantGauche == 1 then
		    	    	    if clignoGaucheActive then
		    	    		    clignoGauche = 0
		    	    	        clignoDroit = 0
		    	    		    clignoGaucheActive = false
		    	    	        clignoDroitActive = false
		    	    			
		    	    		else
		    	    		    clignoGauche = 1
		    	    	        clignoDroit = 0
		    	    		    clignoGaucheActive = false
		    	    	        clignoDroitActive = false
		    	    		end
		    	    		Wait(100)
		    	    	elseif data.clignotantDroit == 1 then
		    	    	    if clignoDroitActive then
		    	    		    clignoGauche = 0
		    	    	        clignoDroit = 0
		    	    		    clignoGaucheActive = false
		    	    	        clignoDroitActive = false
		    	    		else
		    	    	        clignoGauche = 0
		    	    	        clignoDroit = 1
		    	    		    clignoGaucheActive = false
		    	    	        clignoDroitActive = false
		    	    		end
		    	    		Wait(100)
		    	    	end
		    	    else
		    	        if clignoGauche == 1 and clignoDroit == 0 then
		    	    	    clignoGaucheActive = true
		    	    	    clignoDroitActive = false
		    	    		clignoGauche = 0
		    	    		clignoDroit = 0
		    	    	elseif clignoGauche == 0 and clignoDroit == 1 then
		    	    	    clignoGaucheActive = false
		    	    	    clignoDroitActive = true
		    	    		clignoGauche = 0
		    	    		clignoDroit = 0
		    	    	end
		    	    end
		    	    if clignoDroitActive then
		    	        SetVehicleIndicatorLights(vehicle, 1, false)
		    	        SetVehicleIndicatorLights(vehicle, 0, true)
		    	    elseif clignoGaucheActive then
		    	        SetVehicleIndicatorLights(vehicle, 1, true)
		    	        SetVehicleIndicatorLights(vehicle, 0, false)
		    	    else
		    	        SetVehicleIndicatorLights(vehicle, 1, false)
		    	        SetVehicleIndicatorLights(vehicle, 0, false)
		    	    end 
		    	end
		        if data.wheel ~= nil then
		    		if round((GetEntitySpeed(vehicle)*3.6),0) > 50.0 then
		    		    if tonumber(data.wheel) > 0.0 then
		    		        wheel = tonumber(data.wheel) + 0.025
		    			else
		    			    wheel = tonumber(data.wheel) - 0.025
		    			end
		    		else
		    	        if tonumber(data.wheel) > 0.0 then
		    		        wheel = tonumber(data.wheel) + 0.02
		    			else
		    			    wheel = tonumber(data.wheel) - 0.02
		    			end
		    		end
		    		if wheel >= 0.02 then
		    			if clignoDroit == 1 then
		    			    activeTurnDroit = true
		    			end
		    		elseif wheel <= -0.02 then
		    		    if clignoGauche == 1 then
		    			    activeTurnGauche = true
		    			end
		    		else
		    		    if activeTurnGauche or activeTurnDroit then
		    			    clignoGauche = 0
		    			    clignoDroit = 0
		    			    activeTurnDroit = false
		    			    activeTurnGauche = false
		    			    clignoDroitActive = false
		    			    clignoGaucheActive = false
		    			end
		    		end
	            end
		    	if data.brake ~= nil then 
	                if tonumber(data.brake) > 0.0 then
		    		    if selectedgear == 7 then
		    			    SetVehicleHandbrake(vehicle, true)
		    			else
		    			    brakePedal = true
	            		    brake = tonumber(data.brake) + .0
		    			end
	            	else
	            	    brakePedal = false
	            	    brake = 0.0
	            	end
	            end
		        if data.throttle ~= nil and data.clutch ~= nil then
		    	    if patinage then
		    		    if tonumber(data.throttle) > 0.0 then
		    			    if selectedgear == 7 then
		    				    brakePedal = true
		    				    brake = tonumber(data.throttle) + .0
		    					accelerate = false
		    				    acceleration = 0.0
		    				    patinage = false
		    				    patinageWrong = false
		    				else
		    				    accelerate = true
		    				    acceleration = tonumber(data.throttle) + .0
		    					brakePedal = false
		    				    brake = 0.0
		    				    patinage = false
		    				    patinageWrong = false
		    				end
		    			else
		    			    SetVehicleEngineOn(vehicle,false,true,false)
		    				patinage = false
		    	        	patinageWrong = false
		    				acceleration = 0.0
		    				accelerate = false
		    			end
		    		else
		    		    if not Sequential then
		    		        if tonumber(data.clutch) > 0.5 then
		    			        acceleration = 0.0
		    			    	if data.gear ~= nil and tonumber(data.gear) <= numgears then
		    			    		if tonumber(data.gear) == 7 then
		    			    			SetVehicleEngineOn(vehicle,false,true,false)
		    			    		    patinage = false
		    	            	        patinageWrong = false
		    			    			acceleration = 0.0
		    			    	        accelerate = false
		    			    		else
		    			    		    selectedgear = tonumber(data.gear)
		    			    		end
		    		            end
		    			    else
		    			        if tonumber(data.throttle) > 0.0 then
		    			    	    if selectedgear == 7 then
		    			    	        brakePedal = true
		    			    	        brake = tonumber(data.throttle) + .0
		    			    			accelerate = false
		    			    	        acceleration = 0.0
		    			    		else
		    			    		    accelerate = true
		    			    	        acceleration = tonumber(data.throttle) + .0
		    			    			brakePedal = false
		    			    	        brake = 0.0
		    			    		end
		    			    	end
		    			    end
		    			else
		    			    if tonumber(data.throttle) > 0.0 then
		    			        if selectedgear == 7 then
		    			            brakePedal = true
		    			            brake = tonumber(data.throttle) + .0
		    			    		accelerate = false
		    			            acceleration = 0.0
		    			    	else
		    			    	    accelerate = true
		    			            acceleration = tonumber(data.throttle) + .0
		    			    		brakePedal = false
		    			            brake = 0.0
		    			    	end
		    			    end
		    			    if data.paletteDown ~= nil or data.paletteUp ~= nil then
		    	                if not Up and data.paletteUp == true then
		    						Up = true
		    						Down = false
		    					elseif not Down and data.paletteDown == true then
		    						Up = false
		    						Down = true
		    					elseif Up and data.paletteUp == false then
		    					    if selectedgear <= numgears then
		    						    selectedgear = selectedgear + 1
		    						end
		    						Up = false
		    						Down = false
		    					elseif Down and data.paletteDown == false then
		    					    if selectedgear > 0 then
		    					        selectedgear = selectedgear - 1
		    						end
		    						Up = false
		    						Down = false
		    					end
		    			    end
		    			end
		    		end
		    	end
		    end
		else
		    if data.handBrake == 1 then
		        if not handBrakeActive then
		    		handBrakeActive = true
		    	end
			elseif data.handBrake == 0 then
			    if handBrakeActive then
		    		handBrakeActive = false
		    	end
		    end
		    if data.clignotantGauche ~= nil or data.clignotantDroit ~= nil then
		        if data.clignotantGauche == 1 then
		    	    if clignoGaucheActive then
		    		    clignoGauche = 0
		    	        clignoDroit = 0
		    		    clignoGaucheActive = false
		    	        clignoDroitActive = false
		    			
		    		else
		    		    clignoGauche = 1
		    	        clignoDroit = 0
		    		    clignoGaucheActive = false
		    	        clignoDroitActive = false
		    		end
		    		Wait(100)
		    	elseif data.clignotantDroit == 1 then
		    	    if clignoDroitActive then
		    		    clignoGauche = 0
		    	        clignoDroit = 0
		    		    clignoGaucheActive = false
		    	        clignoDroitActive = false
		    		else
		    	        clignoGauche = 0
		    	        clignoDroit = 1
		    		    clignoGaucheActive = false
		    	        clignoDroitActive = false
		    		end
		    		Wait(100)
		    	end
		    else
		        if clignoGauche == 1 and clignoDroit == 0 then
		    	    clignoGaucheActive = true
		    	    clignoDroitActive = false
		    		clignoGauche = 0
		    		clignoDroit = 0
		    	elseif clignoGauche == 0 and clignoDroit == 1 then
		    	    clignoGaucheActive = false
		    	    clignoDroitActive = true
		    		clignoGauche = 0
		    		clignoDroit = 0
		    	end
		    end
			if data.wheel ~= nil then
		    	if round((GetEntitySpeed(vehicle)*3.6),0) > 50.0 then
		    	    if tonumber(data.wheel) > 0.0 then
		    	        wheel = tonumber(data.wheel) + 0.025
		    		else
		    		    wheel = tonumber(data.wheel) - 0.025
		    		end
		    	else
		            if tonumber(data.wheel) > 0.0 then
		    	        wheel = tonumber(data.wheel) + 0.02
		    		else
		    		    wheel = tonumber(data.wheel) - 0.02
		    		end
		    	end
		    	if wheel >= 0.02 then
		    		if clignoDroit == 1 then
		    		    activeTurnDroit = true
		    		end
		    	elseif wheel <= -0.02 then
		    	    if clignoGauche == 1 then
		    		    activeTurnGauche = true
		    		end
		    	else
		    	    if activeTurnGauche or activeTurnDroit then
		    		    clignoGauche = 0
		    		    clignoDroit = 0
		    		    activeTurnDroit = false
		    		    activeTurnGauche = false
		    		    clignoDroitActive = false
		    		    clignoGaucheActive = false
		    		end
		    	end
	        end
		    if clignoDroitActive then
		        SetVehicleIndicatorLights(vehicle, 1, false)
		        SetVehicleIndicatorLights(vehicle, 0, true)
		    elseif clignoGaucheActive then
		        SetVehicleIndicatorLights(vehicle, 1, true)
		        SetVehicleIndicatorLights(vehicle, 0, false)
		    else
		        SetVehicleIndicatorLights(vehicle, 1, false)
		        SetVehicleIndicatorLights(vehicle, 0, false)
		    end
		    if tonumber(data.throttle) > 0.0 then
		    	accelerate = true
		        acceleration = tonumber(data.throttle) + .0
		    	brakePedal = false
		        brake = 0.0
		    end
			if data.brake ~= nil then 
	            if tonumber(data.brake) > 0.0 then
		    		brakePedal = true
	        		brake = tonumber(data.brake) + .0
	        	else
	        	    brakePedal = false
	        	    brake = 0.0
	        	end
	        end
		end
	end
end)

onVehicle = false

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(100) 
		if manualon then
            local ped = PlayerPedId()
            local newveh = GetVehiclePedIsIn(ped,false)
            local class = GetVehicleClass(newveh)
            if newveh == vehicle then
		    
            elseif newveh == 0 and vehicle ~= nil then
                resetvehicle()
		    	SendNUIMessage({
	                startAxes = false,
		    		UI = UIvehicle
	            })
            else
                if GetPedInVehicleSeat(newveh,-1) == ped then
                    if class ~= 13 and class ~= 14 and class ~= 15 and class ~= 16 and class ~= 21 then
                        vehicle = newveh
		    			if not onVehicle then
		    			    SendNUIMessage({
	                            startAxes = true,
		    					UI = UIvehicle
	                        })
		    				onVehicle = true
		    			end
                        hash = GetEntityModel(newveh)
                        if GetVehicleMod(vehicle,13) < 0 then
                            numgears = GetVehicleHandlingInt(newveh, "CHandlingData", "nInitialDriveGears")
                        else
                            numgears = GetVehicleHandlingInt(newveh, "CHandlingData", "nInitialDriveGears") + 1
                        end
                        hbrake = GetVehicleHandlingFloat(newveh, "CHandlingData", "fHandBrakeForce")
                        topspeedGTA = GetVehicleHandlingFloat(newveh, "CHandlingData", "fInitialDriveMaxFlatVel")
                        topspeedms = (topspeedGTA * 1.32)/3.6
                        acc = GetVehicleHandlingFloat(newveh, "CHandlingData", "fInitialDriveForce")
                        Citizen.Wait(50)
                        ready = true
                    end
                end
            end
        end
    end
end)

function resetvehicle()
    SetVehicleHandlingFloat(vehicle, "CHandlingData", "fInitialDriveForce", acc)
    SetVehicleHandlingFloat(vehicle, "CHandlingData", "fInitialDriveMaxFlatVel",topspeedGTA)
    SetVehicleHandlingFloat(vehicle, "CHandlingData", "fHandBrakeForce", hbrake)
    SetVehicleHighGear(vehicle, numgears)
    ModifyVehicleTopSpeed(vehicle,1.0)
    SetVehicleHandbrake(vehicle, false)
    vehicle = nil
    numgears = nil
    topspeedGTA = nil
    topspeedms = nil
    acc = nil
    hash = nil
    hbrake = nil
    selectedgear = 0
    currspeedlimit = nil
    ready = false
    onVehicle = false
	nitro = false
end


Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0) 
        if manualon == true and vehicle ~= nil then
		    if handBrakeActive then
			    SetControlNormal(0, 76, 1.0)
		        SetControlNormal(1, 76, 1.0)
		        SetControlNormal(2, 76, 1.0)
			end
		    if accelerate then
		        SetControlNormal(0, 71, acceleration)
		        SetControlNormal(1, 71, acceleration)
		        SetControlNormal(2, 71, acceleration)
		    end
		    if brakePedal then
			    if GetEntitySpeedVector(vehicle,true).y > 0.0 then  
		            SetControlNormal(0, 72, brake)
		            SetControlNormal(1, 72, brake)
		            SetControlNormal(2, 72, brake)
				end
		    end
			-- SetVehicleSteerBias(vehicle, wheel)
			
			SetControlNormal(0, 59, wheel*10.0)
		    SetControlNormal(1, 59, wheel*10.0)
		    SetControlNormal(2, 59, wheel*10.0)
            if selectedgear <= numgears - 1 then 
                SimulateGears()
            end
			if selectedgear < 7 then
				SimulateGears()
            end
		elseif not manualon and Automatic then
		    if handBrakeActive then
			    SetControlNormal(0, 76, 1.0)
		        SetControlNormal(1, 76, 1.0)
		        SetControlNormal(2, 76, 1.0)
			end
		    if accelerate then
		        SetControlNormal(0, 71, acceleration)
		        SetControlNormal(1, 71, acceleration)
		        SetControlNormal(2, 71, acceleration)
		    end
		    if brakePedal then
		        SetControlNormal(0, 72, brake)
		        SetControlNormal(1, 72, brake)
		        SetControlNormal(2, 72, brake)
		    end
			-- SetVehicleSteerBias(vehicle, wheel)
			
			SetControlNormal(0, 59, wheel*10.0)
		    SetControlNormal(1, 59, wheel*10.0)
		    SetControlNormal(2, 59, wheel*10.0)
        end
    end
end)

function SimulateGears()

    local engineup = GetVehicleMod(vehicle,11)      

    if selectedgear > 0 and selectedgear < 7 then
        local ratio 
        if Config.vehicles[hash] ~= nil then
            if selectedgear ~= 0 and selectedgear ~= nil  then
                if numgears ~= nil and selectedgear ~= nil then
                    ratio = Config.vehicles[hash][numgears][selectedgear] * (1/0.9)
                else
		            ratio = Config.gears[numgears][selectedgear] * (1/0.9)
                end
            end
        else
            if selectedgear ~= 0 and selectedgear ~= nil then
                if numgears ~= nil and selectedgear ~= nil then
                    ratio = Config.gears[numgears][selectedgear] * (1/0.9)
                end
            end
        end

        if ratio ~= nil then
    
            SetVehicleHighGear(vehicle,1)
            newacc = ratio * acc
            newtopspeedGTA = topspeedGTA / ratio
            newtopspeedms = topspeedms / ratio
            SetVehicleHandbrake(vehicle, false)
            SetVehicleHandlingFloat(vehicle, "CHandlingData", "fInitialDriveForce", newacc)
            SetVehicleHandlingFloat(vehicle, "CHandlingData", "fInitialDriveMaxFlatVel", newtopspeedGTA)
            SetVehicleHandlingFloat(vehicle, "CHandlingData", "fHandBrakeForce", hbrake)
            ModifyVehicleTopSpeed(vehicle,1.0)
            currspeedlimit = newtopspeedms
        end
    elseif selectedgear == 7 then
            SetVehicleHandbrake(vehicle, false)
            SetVehicleHighGear(vehicle,numgears)    
            SetVehicleHandlingFloat(vehicle, "CHandlingData", "fInitialDriveForce", acc)
            SetVehicleHandlingFloat(vehicle, "CHandlingData", "fInitialDriveMaxFlatVel", topspeedGTA)
            SetVehicleHandlingFloat(vehicle, "CHandlingData", "fHandBrakeForce", hbrake)
            ModifyVehicleTopSpeed(vehicle,1.0)
    end
SetVehicleMod(vehicle,11,engineup,false)
	
end

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        if manualon == true and vehicle ~= nil then
            if selectedgear == 7 then
                if GetVehicleCurrentGear(vehicle) == 1 then
                    DisableControlAction(0, 71, true)
                end
            elseif selectedgear > 0 and selectedgear < 7 then
                if GetEntitySpeedVector(vehicle,true).y < 0.0 then   
                    DisableControlAction(0, 72, true)
                end
            end
        else
            Citizen.Wait(100) 
        end
    end
end)

local waitBreak = 100

Citizen.CreateThread(function()
    while true do
            
        Citizen.Wait(waitBreak)
        if manualon == true and vehicle ~= nil and selectedgear ~= 0 then 
		    waitBreak = 1
            local speed = GetEntitySpeed(vehicle) 
            
            if currspeedlimit ~= nil then
                
                if speed >= currspeedlimit then
                    
                    if Config.enginebrake == true then
                        if speed / currspeedlimit > 1.1 then
                        local tempSpeed = speed / currspeedlimit
                        SetVehicleCurrentRpm(vehicle,tempSpeed)
                        SetVehicleCheatPowerIncrease(vehicle,-100.0)
                        else
                        SetVehicleCheatPowerIncrease(vehicle,0.0)
                        end
                    else
                        SetVehicleCheatPowerIncrease(vehicle,0.0)
                    end
                end
            else
                if speed >= topspeedms then
                    SetVehicleCheatPowerIncrease(vehicle,0.0)
                end
            end
        else    
            waitBreak = 100
        end
    end
end)


function getinfo(gea)
    if gea == 0 then
        return "N"
    elseif gea == 7 then
        return "R"
    else
        return gea
    end
end

function round(value, numDecimalPlaces)
	if numDecimalPlaces then
		local power = 10^numDecimalPlaces
		return math.floor((value * power) + 0.5) / (power)
	else
		return math.floor(value + 0.5)
	end
end

AddEventHandler('onResourceStop', function(resourceName)
    if resourceName == GetCurrentResourceName() then
        SendNUIMessage({startAxes = false, UI = false})
    end
end)

exports("getCarGear",function(playerCar)
    return manualon and getinfo(selectedgear) or false
end)

exports("getCarManual", function() return manualon end)