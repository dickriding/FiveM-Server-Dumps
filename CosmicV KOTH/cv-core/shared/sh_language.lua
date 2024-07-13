LANGUAGE = {}
LANGUAGES = {["en"] = { "English", "us"}}

local function formatLanguages(lang, key, value)
    if type(value) == 'table' then
        for key2, value2 in pairs(value) do
            formatLanguages(lang, key2, value2)
        end
    else
        LANGUAGE[lang] = LANGUAGE[lang] or {}
        LANGUAGE[lang][key] = value
    end
end

Citizen.CreateThread(function()
    local languages = json.decode(LoadResourceFile(GetCurrentResourceName(), 'lang/lang.json'))
    for _, language in pairs(languages) do
        local langFile = json.decode(LoadResourceFile(GetCurrentResourceName(), ('lang/%s.json'):format(language)))
        LANGUAGES[language] = {langFile["language-title"], langFile["language-flag"]}
        for key, value in pairs(langFile) do
            formatLanguages(language, key, value)
        end
    end
end)

if IsDuplicityVersion() then -- Is server
    LANGUAGE.translate = function(key, source, ...)
        local currLanguage = Player(source).state.language or "en"
        if not LANGUAGE[currLanguage] then
            LOGGER.error(("Non-existent language, %s, falling back to english."):format(currLanguage))
            return LANGUAGE['en'][key]:format(...) or ("%s is missing translation"):format(key)
        elseif not LANGUAGE[currLanguage][key] then
            LOGGER.error(("Non-existent key, %s, for language, %s."):format(key,currLanguage))
            if not LANGUAGE['en'][key] then
                return LOGGER.error(("Non-existent key, %s, for ENGLISH EITHER!"):format(key))
            else
                return LANGUAGE['en'][key]:format(...) or ("%s is missing translation"):format(key)
            end
        end
        return LANGUAGE[currLanguage][key]:format(...) or ("%s is missing translation"):format(key)
    end
else -- Is client
    while not LANGUAGE['en'] do -- No more errors for language when loading in.
        Citizen.Wait(5)
        print("LANG: Awaiting language files.")
    end
    LANGUAGE.translate = function(key, ...)
        LOGGER.verbose( key, ... )
        local currLanguage = LocalPlayer.state.language or "en"
        if not LANGUAGE[currLanguage] then
            --LOGGER.error(("Non-existent language, %s, falling back to english."):format(currLanguage))
            return LANGUAGE['en'][key]:format(...) or ("%s is missing translation"):format(key)
        elseif not LANGUAGE[currLanguage][key] then
            --LOGGER.error(("Non-existent key, %s, for language, %s."):format(key,currLanguage))
            if not LANGUAGE['en'][key] then
                return LOGGER.error(("Non-existent key, %s, for ENGLISH EITHER!"):format(key))
            else
                return LANGUAGE['en'][key]:format(...) or ("%s is missing translation"):format(key)
            end
        end
        return LANGUAGE[currLanguage][key]:format(...) or ("%s is missing translation"):format(key)
    end
    RegisterNetEvent("koth-translate:toChat", function(template, translateKey, ...)
        TriggerEvent('chat:addMessage', {
            templateId = template,
            multiline = true,
            args = { LANGUAGE.translate(translateKey, ...) }
        })
    end)
end

function GetLanguages()
    return LANGUAGES
end

exports("translate", LANGUAGE.translate)
exports("getLanguages", GetLanguages)