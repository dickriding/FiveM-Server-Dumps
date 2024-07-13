exports('GetDiamondCasinoObject', function()
    return DiamondCasino
end)

local function CreateNamedRenderTargetForModel(name, model)
	local handle = 0
	if not IsNamedRendertargetRegistered(name) then
		RegisterNamedRendertarget(name, 0)
	end
	if not IsNamedRendertargetLinked(model) then
		LinkNamedRendertarget(model)
	end
	if IsNamedRendertargetRegistered(name) then
		handle = GetNamedRendertargetRenderId(name)
	end

	return handle
end

local function setTvData(video)
    SetTvChannelPlaylist(0, video, true)
    SetTvAudioFrontend(true)
    SetTvVolume(-100.0)
    SetTvChannel(0)
end

local casinoVideos = {
    "CASINO_SNWFLK_PL",
    "CASINO_HLW_PL",
    "CASINO_DIA_PL"
}

DiamondCasino = {
    Ipl = {
        Building = {
            ipl = {
                "hei_dlc_windows_casino",
                "hei_dlc_casino_aircon",
                "vw_dlc_casino_door",
                "hei_dlc_casino_door"
            },
            Load = function() EnableIpl(DiamondCasino.Ipl.Building.ipl, true) end,
            Remove = function() EnableIpl(DiamondCasino.Ipl.Building.ipl, false) end
        },
        Main = {
            ipl = "vw_casino_main",
            Load = function() EnableIpl(DiamondCasino.Ipl.Main.ipl, true) end,
            Remove = function() EnableIpl(DiamondCasino.Ipl.Main.ipl, false) end
        },
        Garage = {
            ipl = "vw_casino_garage",
            Load = function() EnableIpl(DiamondCasino.Ipl.Garage.ipl, true) end,
            Remove = function() EnableIpl(DiamondCasino.Ipl.Garage.ipl, false) end
        },
        Carpark = {
            ipl = "vw_casino_carpark",
            Load = function() EnableIpl(DiamondCasino.Ipl.Carpark.ipl, true) end,
            Remove = function() EnableIpl(DiamondCasino.Ipl.Carpark.ipl, false) end
        }
    },

    LoadDefault = function()
        DiamondCasino.Ipl.Building.Load()
        DiamondCasino.Ipl.Main.Load()
        DiamondCasino.Ipl.Carpark.Load()
        DiamondCasino.Ipl.Garage.Load()

        local inInterior = false

        AddEventHandler("interior:enter", function(interior)
            if interior ~= 275201 then return end
            inInterior = true

            local mainScreen = CreateNamedRenderTargetForModel("CasinoScreen_01", 1800987616)
            --local horseScreen = CreateNamedRenderTargetForModel("CasinoScreen_02", -214651601)

            RequestStreamedTextureDict("Prop_Screen_Vinewood", false)
            while not HasStreamedTextureDictLoaded("Prop_Screen_Vinewood") do Wait(0) end

            local video = casinoVideos[math.random(#casinoVideos)]

            setTvData(video)
            local vidStartTime = GetGameTimer()

            while inInterior do
                Wait(0)

                if GetGameTimer() - vidStartTime > 42666 then
                    setTvData(video)
                    vidStartTime = GetGameTimer()
                end

                mainScreen = CreateNamedRenderTargetForModel("CasinoScreen_01", 1800987616)
                
                SetTextRenderId(mainScreen)
                SetScriptGfxDrawOrder(4)
                SetScriptGfxDrawBehindPausemenu(true)
                DrawInteractiveSprite("Prop_Screen_Vinewood", "BG_Wall_Colour_4x4", 0.25, 0.5, 0.5, 1.0, 0.0, 255, 255, 255, 255)
                DrawTvChannel(0.5, 0.5, 1.0, 1.0, 0.0, 255, 255, 255, 255)
                SetTextRenderId(GetDefaultScriptRendertargetRenderId())
            end
        end)

        AddEventHandler("interior:exit", function(interior)
            if interior ~= 275201 then return end
            inInterior = false
            if IsNamedRendertargetRegistered("CasinoScreen_01") then
                ReleaseNamedRendertarget("CasinoScreen_01")
            end
            
            SetStreamedTextureDictAsNoLongerNeeded("Prop_Screen_Vinewood")
        end)
    end
}