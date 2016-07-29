-- Copyright (C) 2015-2016  RevelatedDestiny

-- START OF VARIABLE INITIALIZATION --

local gracePeriod = 1 -- The grace period for theoretically instantaneous events. If this is too short or too long, the addon may bug.
local monsterSayFilterLocations = {} -- Keeps track of the zones in which to filter out CHAT_MSG_MONSTER_SAY.
local monsterSayFilterFollowers = {} -- Keeps track of the followers of which to always filter out CHAT_MSG_MONSTER_SAY (i.e. of bodyguards).
local blizzardSystemFilterStrings = {} -- Keeps track of the strings to filter out in CHAT_MSG_SYSTEM.
local timeSinceLevelUp = 0 -- Necessary to still allow you to see newly acquired skills upon leveling up, if filterSkillChange is enabled.
local whisperedPeople = {} -- Keeps track of who you have whispered and when. This allows filtering DND/AFK spam through whisperFilter.
local timeSinceLastWhisper = 0 -- Keeps track of when you last whispered, necessary for whisperFilter to work.
local scannedPeopleWow = {} -- Lazy scan of people who have been spotted going online and offline on WoW.
local scannedPeopleBnet = {} -- Lazy scan of people who have been spotted going online and offline on BNet.

-- END OF VARIABLE INITIALIZATION --
     
local function initialiseCore()
	local f = CreateFrame("Frame")
	f:RegisterEvent("PLAYER_LEVEL_UP")
	f:SetScript("OnEvent", timerUpdate) -- Needed to be able to show newly acquired skills after leveling up.
	ChatFrame_AddMessageEventFilter("CHAT_MSG_MONSTER_SAY", monsterSayFilter)
	ChatFrame_AddMessageEventFilter("CHAT_MSG_SYSTEM", blizzardSystemFilter)
	ChatFrame_AddMessageEventFilter("CHAT_MSG_DND", whisperFilter)
	ChatFrame_AddMessageEventFilter("CHAT_MSG_AFK", whisperFilter)
	ChatFrame_AddMessageEventFilter("CHAT_MSG_BN_INLINE_TOAST_ALERT", battleNetFilter)
	fillMonsterSayFilterLocations()
	fillMonsterSayFilterFollowers()
	fillBlizzardSystemFilterStrings()
end

-- Updates the timer when you level up
function timerUpdate()
	timeSinceLevelUp = GetTime()
end

-- Adds zones where NPC messages have to be filtered to monsterSayFilterLocations.
function fillMonsterSayFilterLocations()
	monsterSayFilterLocations["Warspear"] = 1011
	monsterSayFilterLocations["Stormshield"] = 1009
	monsterSayFilterLocations["Frostwall"] = 976
	monsterSayFilterLocations["Lunarfall"] = 971
end

function fillMonsterSayFilterFollowers()
	monsterSayFilterFollowers["Aeda Brightdawn"] = 0
	monsterSayFilterFollowers["Vivianne"] = 0
	monsterSayFilterFollowers["Defender Illona"] = 0
	monsterSayFilterFollowers["Delvar Ironfist"] = 0
	monsterSayFilterFollowers["Leorajh"] = 0
	monsterSayFilterFollowers["Talonpriest Ishaal"] = 0
	monsterSayFilterFollowers["Tormmok"] = 0
end

-- Removes NPC say messages from zones listed in monsterSayFilterLocations.
function monsterSayFilter(_, _, _, sender)
	-- Filter NPC messages in Warspear/Stormshield or in your garrison.
	local currentID = GetCurrentMapAreaID()
	if currentID == monsterSayFilterLocations["Warspear"] or currentID == monsterSayFilterLocations["Stormshield"] then
		return CCcheckboxes.filterWarshield
	end
	if currentID == monsterSayFilterLocations["Frostwall"] or currentID == monsterSayFilterLocations["Lunarfall"] then
		return CCcheckboxes.filterGarrison
	end
	-- Filter bodyguard messages.
	for name,_ in pairs(monsterSayFilterFollowers) do
		if name == sender then
			return CCcheckboxes.filterBodyguard
		end
	end
	return false
end

function whisperFilter(_, _, _, sender)
	-- Filter incessant DND/AFK spam in whispers.
	resetTime = 120 -- Time until a DND/AFK message is allowed again after receiving one.
	lastWhisper = whisperedPeople[sender] or 0
	whisperedPeople[sender] = GetTime() -- Update the time of the last sent whisper to someone.
	if GetTime() - lastWhisper > resetTime then
		return false
	end
	return true
end

function battleNetFilter(_, _, event, sender)
	-- Filter in case the message has already been shown.
	if event == "FRIEND_ONLINE" and scannedPeopleBnet[sender] == 1 
	   or event == "FRIEND_OFFLINE" and scannedPeopleBnet[sender] == 0 then
		return CCcheckboxes.filterDoubleOffline
	else -- Otherwise, scan the person.
		if event == "FRIEND_ONLINE" then
			scannedPeopleBnet[sender] = 1
		else
			scannedPeopleBnet[sender] = 0
		end
	end
	return false
end

-- Adds Blizzard's system messages to be filtered to the blizzardSystemFilterStrings
-- array using a unique identifier wherever possible.
--  * "No player named": "No player named '%s' is currently playing."
--    If you aren't receiving this immediately after sending a whisper, it is unwanted.
--  * ERR_NOT_IN_RAID: "You are not in a raid group"
--    If you are receiving this while in a raid group, it is unwanted.
--  * ERR_NOT_IN_GROUP: "You aren't in a party."
--    If you are receiving this while in a party, it is unwanted.
--  * "has gone offline": "%s has gone offline."
--    If you are receiving this when someone goes offline and isn't in your guild or friends list,
--    it is unwanted if skillChangeCheckbox has been ticked.
--  * "You have unlearned": "You have unlearned %s."
--    This option is unwanted if skillChangeCheckbox has been ticked.
--  * "You have learned a new": "You have learned a new ability: %s.", "You have learned a new passive effect: %s.", "You have learned a new spell: %s."
--    This option is unwanted if skillChangeCheckbox has been ticked.
function fillBlizzardSystemFilterStrings()
	blizzardSystemFilterStrings["No player named"] =
		function(message)
			local startIndex = message:find("'")
			local endIndex = message:find("'", startIndex+1)
			local offlinePerson = message:sub(startIndex+1, endIndex-1)
			-- Only returns true if the person is yourself, your target, your focus target or
			-- in your party or raid, but seeing as this message usually pops up unwanted when you are in
			-- a party or raid thanks to unwanted side-effects of third party addons, this is no issue.
			return CCcheckboxes.filterNotPlaying and UnitIsConnected(offlinePerson)
		end
	blizzardSystemFilterStrings[ERR_NOT_IN_RAID] = 
		function()
			return CCcheckboxes.filterNotRaiding and IsInRaid()
		end
	blizzardSystemFilterStrings[ERR_NOT_IN_GROUP] = 
		function()
			return CCcheckboxes.filterNotInParty and IsInGroup()
		end
	blizzardSystemFilterStrings["has come online"] = 
		function(message)
			return doubleOfflineFilter(message)
		end
	blizzardSystemFilterStrings["has gone offline"] = 
		function(message)
			return unnecessaryOfflineMessage(message) or doubleOfflineFilter(message)
		end
	blizzardSystemFilterStrings["You have unlearned"] =
		function()
			return CCcheckboxes.filterSkillChange
		end
	blizzardSystemFilterStrings["You have learned a new"] =
		function()
			return CCcheckboxes.filterSkillChange and GetTime() - timeSinceLevelUp > gracePeriod
		end
end

-- Checks if the offline message is unneeded clutter.
function unnecessaryOfflineMessage(message)
	if message == ERR_ARENA_TEAM_NOT_FOUND then
			return false
	else
		local spaceLocation = message:find(" ")
		local offlinePerson = message:sub(1, spaceLocation-1)
		return CCcheckboxes.filterOffline and not (checkFriendsList(offlinePerson) or checkGuildList(offlinePerson))
	end
end

-- Checks if offlinePerson is in the user's friends list.
function checkFriendsList(offlinePerson)
	ShowFriends() -- Request updated friends information from the server.
	local amount = GetNumFriends()
	for i=1,amount do
		local name = GetFriendInfo(i)
		if name == offlinePerson then
			return true
		end
	end
	return false
end

-- Checks if offlinePerson is in the user's guild list.
function checkGuildList(offlinePerson)
	GuildRoster() -- Request updated guild roster information from the server.
	local amount = GetNumGuildMembers()
	for i=1,amount do
		local name = GetGuildRosterInfo(i)
		if name == offlinePerson or name:gsub("-.*","") == offlinePerson then
			return true
		end
	end
	return false
end

function doubleOfflineFilter(message)
	-- Check person's name.
	local spaceLocation = message:find(" ")
	local sender = message:sub(1, spaceLocation-1):gsub("[^ ]+[\[](%a*[-]?%a*)[\]][^ ]+","%1")
	-- Filter in case the message has already been shown.
	if message:find("online") and scannedPeopleWow[sender] == 1
	   or message:find("offline") and scannedPeopleWow[sender] == 0 then
		return CCcheckboxes.filterDoubleOffline
	else -- Otherwise, scan the person.
		if message:find("online") then
			scannedPeopleWow[sender] = 1
		else
			scannedPeopleWow[sender] = 0
		end
	end
	return false
end

-- Removes some of Blizzard's system messages, namely those that show up at unwanted times.
function blizzardSystemFilter(_, _, message)
	for key, funcResult in pairs(blizzardSystemFilterStrings) do
		if message:find(key) then
			return funcResult(message)
		end
	end
	return false
end

initialiseCore()