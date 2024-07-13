DuiWindow = {}
DuiWindow.__index = DuiWindow

function DuiWindow.Create(url, width, height)
    local data = { url = url, width = width, height = height,  }
   
    data.duiObj = CreateDui(url, width, height)
    data.duiHandle = GetDuiHandle(data.duiObj)

    return setmetatable(data, DuiWindow)
end

function DuiWindow:init()
   self:GetRuntimeTexture()
end

function DuiWindow:GetRuntimeTexture()
    if self.runtimeTexture then return self.runtimeTexture end

    self.runtimeTxdName = uuid()
    self.runtimeTxn = "meme"
    self.runtimeTxd = CreateRuntimeTxd(self.runtimeTxdName)


    self.runtimeTexture = CreateRuntimeTextureFromDuiHandle(self.runtimeTxd, self.runtimeTxn, self.duiHandle)

    return self.runtimeTexture
end

function DuiWindow:Dispose()
    if IsDuiAvailable(self.duiObj) then
        SetDuiUrl(self.duiObj, "about:blank") --? set the page to blank as otherwise audio can sometimes keep playing
        DestroyDui(self.duiObj)
    end
end