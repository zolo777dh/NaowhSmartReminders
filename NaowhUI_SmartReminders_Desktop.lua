-- Desktop-authored unified profiles use the existing NSR runtime and pack format.
local ns = _G.NaowhUITankReminder
if not ns then return end

function ns.DesktopReminderConflict()
    local loaded = C_AddOns and C_AddOns.IsAddOnLoaded or IsAddOnLoaded
    if not loaded then return nil end
    for _, addon in ipairs({ "NorthernSkyRaidTools", "TimelineReminders" }) do
        if loaded(addon) then return addon end
    end
end

local enabled = ns.IsReminderEnabled
function ns.IsReminderEnabled(entry, preview)
    if not preview and (ns.DB().desktopReminders and tonumber(ns.DB().desktopReminders.schema) == 1) and ns.DesktopReminderConflict() then return false end
    return enabled(entry, preview)
end

local warned
local watcher = CreateFrame("Frame")
watcher:RegisterEvent("PLAYER_ENTERING_WORLD")
watcher:RegisterEvent("ADDON_LOADED")
watcher:SetScript("OnEvent", function()
    local conflict = (ns.DB().desktopReminders and tonumber(ns.DB().desktopReminders.schema) == 1) and ns.DesktopReminderConflict()
    if conflict and warned ~= conflict then
        warned = conflict
        ns.Print("Unified reminder profile paused: disable " .. conflict .. " to avoid duplicate reminders, then /reload.")
    elseif not conflict then warned = nil end
end)

local speak = ns.SpeakReminderTTS
if speak then
    function ns.SpeakReminderTTS(display, formattedText, preview)
        return speak(display, (type(display.ttsText) == "string" and display.ttsText ~= "" and display.ttsText) or formattedText, preview)
    end
end

local play = ns.PlayReminderSound
if play then
    function ns.PlayReminderSound(display)
        local sound = display and display.sound
        if type(sound) == "string" and sound:match("^Interface[\\/]") then
            local extension = sound:lower():match("%.(%w+)$")
            if extension == "ogg" or extension == "mp3" or extension == "wav" then
                return ns.UI._PlayLSMSound(sound)
            end
        end
        return play(display)
    end
end
