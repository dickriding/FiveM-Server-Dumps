Scaleform = {}

local scaleform = {}
scaleform.__index = scaleform

function Scaleform.Request(Name)
	local ScaleformHandle = RequestScaleformMovie(Name)
	local StartTime = GetGameTimer()
	while not HasScaleformMovieLoaded(ScaleformHandle) do Citizen.Wait(0) 
		if GetGameTimer() - StartTime >= 5000 then
			print("loading failed")
			return
		end 
	end

	local data = {name = Name, handle = ScaleformHandle, isHud = false}
	return setmetatable(data, scaleform)
end

function Scaleform.RequestHud(id)
	local ScaleformHandle = RequestHudScaleform(id)
	local StartTime = GetGameTimer()
	while not HasHudScaleformLoaded(ScaleformHandle) do 
		Citizen.Wait(0) 
		if GetGameTimer() - StartTime >= 5000 then
			print("loading failed")
			return
		end
	end

	local data = {Name = id, handle = id, isHud = true}
	return setmetatable(data, scaleform)
end

function scaleform:CallFunction(theFunction, ...)
	if self.isHud then
		BeginScaleformMovieMethodHudComponent(self.handle, theFunction)
	else
		BeginScaleformMovieMethod(self.handle, theFunction)
	end

	local arg = {...}
	if arg ~= nil then
		for i=1,#arg do
			local sType = type(arg[i])
			if sType == "boolean" then
				PushScaleformMovieMethodParameterBool(arg[i])
			elseif sType == "number" then
				if math.type(arg[i]) == "integer" then
					PushScaleformMovieMethodParameterInt(arg[i])
				else
					PushScaleformMovieMethodParameterFloat(arg[i])
				end
			elseif sType == "string" then
				PushScaleformMovieMethodParameterString(arg[i])
			else
				PushScaleformMovieMethodParameterInt()
			end
		end
	end
	return EndScaleformMovieMethod()
end

function scaleform:Draw2D()
	DrawScaleformMovieFullscreen(self.handle, 255, 255, 255, 255)
end

function scaleform:Draw2DNormal(x, y, width, height)
	DrawScaleformMovie(self.handle, x, y, width, height, 255, 255, 255, 255)
end

function scaleform:Draw2DScreenSpace(locx, locy, sizex, sizey)
	local Width, Height = GetScreenResolution()
	local x = locy / Width
	local y = locx / Height
	local width = sizex / Width
	local height = sizey / Height
	DrawScaleformMovie(self.handle, x + (width / 2.0), y + (height / 2.0), width, height, 255, 255, 255, 255)
end

function scaleform:Render3D(x, y, z, rx, ry, rz, scalex, scaley, scalez)
	DrawScaleformMovie_3dNonAdditive(self.handle, x, y, z, rx, ry, rz, 2.0, 2.0, 1.0, scalex, scaley, scalez, 2)
end

function scaleform:Render3DAdditive(x, y, z, rx, ry, rz, scalex, scaley, scalez)
	DrawScaleformMovie_3d(self.handle, x, y, z, rx, ry, rz, 2.0, 2.0, 1.0, scalex, scaley, scalez, 2)
end

function scaleform:Dispose()
	if self.isHud then
		RemoveScaleformScriptHudMovie(self.handle)
	else
		SetScaleformMovieAsNoLongerNeeded(self.handle)
	end
	self = nil
end

function scaleform:DisposeAndWait()
	if self.isHud then
		RemoveScaleformScriptHudMovie(self.handle)

		while HasScaleformScriptHudMovieLoaded(self.handle) do
			Wait(0)
		end
	else
		SetScaleformMovieAsNoLongerNeeded(self.handle)

		while HasScaleformMovieLoaded(self.handle) do
			Wait(0)
		end
	end

	self = nil
end

function scaleform:IsValid()
	return self and true or false
end
