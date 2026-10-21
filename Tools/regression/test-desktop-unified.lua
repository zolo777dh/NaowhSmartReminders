local root=arg[1] or "."
local function read(file)local f=assert(io.open(root.."/"..file,"rb"));local s=f:read("*a"):gsub("\r\n","\n");f:close();return s end
local function run(code,env)setmetatable(env,{__index=_G});local f=assert(loadstring(code));setfenv(f,env);return f()end
local source=read("NaowhUI_SmartReminders_RaidReminders.lua")
local function slice(a,b)local p=assert(source:find(a,1,true));return source:sub(p,assert(source:find(b,p+#a,true))-1)end
local role,spec,diff="HEALER",264,15
local ns={NormalizeRaidReminderTarget=function(t)return t or {all=true}end,CurrentSpec=function()return spec end,PullContext=function()return 10,diff end}
local env={ns=ns,UnitName=function()return "Tester"end,UnitFullName=function()return "Tester","Other Realm"end,UnitGroupRolesAssigned=function()return role end,UnitClass=function()return "Shaman","SHAMAN"end}
run(slice("function ns.RaidReminderTargetsMe", "-------------------------------------------------------------------------------"),env)
run(slice("function ns.RaidReminderDifficultyMatches", "function ns.DisplayRaidReminder"),env)
assert(ns.RaidReminderTargetsMe({names={["Tester-OtherRealm"]=true}}))
assert(not ns.RaidReminderTargetsMe({names={["Tester-WrongRealm"]=true}}))
assert(not ns.RaidReminderTargetsMe({roles={TANK=true},specs={[264]=true}}))
assert(ns.RaidReminderTargetsMe({matchAny=true,roles={TANK=true},specs={[264]=true}}))
assert(not ns.RaidReminderTargetsMe({matchAny=true,roles={TANK=true},specs={[65]=true}}))
assert(ns.RaidReminderDifficultyMatches({difficulties={[15]=true}}))
assert(not ns.RaidReminderDifficultyMatches({difficulties={[16]=true}}))
diff=16;assert(ns.RaidReminderDifficultyMatches({difficulties={["16"]=true}}))
assert(ns.RaidReminderDifficultyMatches({}))
local loaded,db={}, {desktopReminders={schema=1}}
local spoken
ns.SpeakReminderTTS=function(_,value)spoken=value end
ns.DB=function()return db end;ns.IsReminderEnabled=function(e)return e.enabled~=false end;ns.Print=function()end
local events={};env._G={NaowhUITankReminder=ns};env.C_AddOns={IsAddOnLoaded=function(a)return loaded[a]end};env.CreateFrame=function()return {RegisterEvent=function()end,SetScript=function(_,_,fn)events[1]=fn end}end
run(read("NaowhUI_SmartReminders_Desktop.lua"),env)
assert(ns.IsReminderEnabled({enabled=true}));loaded.NorthernSkyRaidTools=true
assert(not ns.IsReminderEnabled({enabled=true}));assert(ns.IsReminderEnabled({enabled=true},true))
db.desktopReminders=nil;assert(ns.IsReminderEnabled({enabled=true}));events[1]()
ns.SpeakReminderTTS({ttsText="Custom"},"Visible");assert(spoken=="Custom")
ns.SpeakReminderTTS({ttsText=""},"Visible");assert(spoken=="Visible")
print("DESKTOP_UNIFIED_TARGETS_DIFFICULTY_AND_CONFLICTS_OK")
