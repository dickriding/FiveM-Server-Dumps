RenderTarget = {}
RenderTarget.__index = RenderTarget

function RenderTarget.Create(objectName, targetName)
    local data = { targetName = targetName }
    data.targetHandle = 0

    local hash = GetHashKey(objectName)

    if not IsNamedRendertargetRegistered(targetName) then
        RegisterNamedRendertarget(targetName, false)
    end

    if not IsNamedRendertargetLinked(hash) then
        LinkNamedRendertarget(hash)
    end

    if IsNamedRendertargetRegistered(targetName) then
        data.targetHandle = GetNamedRendertargetRenderId(targetName)
    end

    return setmetatable(data, RenderTarget)
end

function RenderTarget:Draw(txd, txn)
    SetTextRenderId(self.targetHandle)
    SetScriptGfxDrawOrder(4)
    SetScriptGfxDrawBehindPausemenu(true)

    DrawSprite(txd, txn,  0.5, 0.5, 1.0, 1.0, 0.0, 255, 255, 255, 255)
    SetTextRenderId(GetDefaultScriptRendertargetRenderId())
    SetScriptGfxDrawBehindPausemenu(false)
end

function RenderTarget:Dispose()
    if self.targetHandle > 0 then
        ReleaseNamedRendertarget(self.targetName)
    end
end