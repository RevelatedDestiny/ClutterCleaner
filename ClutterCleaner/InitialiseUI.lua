-- Copyright (C) 2015-2016  RevelatedDestiny

-- Load the user's saved settings. If ClutterCleaner is run for the first time,
-- enable everything by default.
local function checkFirstRuntime()
	CCcheckboxes = CCcheckboxes or {
		filterWarshield = true,
		filterGarrison = true,
		filterNotRaiding = true,
		filterNotInParty = true,
		filterNotPlaying = true,
		filterSkillChange = true,
		filterOffline = true,
		filterBodyguard = true,
		filterWhisper = true,
		filterDoubleOffline = true
	}
end

-- Create ClutterCleaner's UI.
local function createUI()
	-- Adds a panel to Interface/AddOns.
	local panel = CreateFrame("Frame", "ClutterCleanerInterface", UIParent)
	panel.name = "ClutterCleaner"
	InterfaceOptions_AddCategory(panel)
	
	-- Adds a checkbox for filtering chat spam of NPCs in Warspear/Stormshield.
	local warshieldCheckbox = CreateFrame("CheckButton", "warshieldCheckbox", panel, "UICheckButtonTemplate")
	warshieldCheckbox:SetPoint("TOPLEFT", 20, -20)
	warshieldCheckbox:SetScript("OnClick", 
		function()
			CCcheckboxes.filterWarshield = not CCcheckboxes.filterWarshield
		end
	)
	warshieldCheckbox:SetChecked(CCcheckboxes.filterWarshield)
	_G[warshieldCheckbox:GetName() .. "Text"]:SetText(" Filter chat spam of NPCs in Warspear/Stormshield.")
	_G[warshieldCheckbox:GetName() .. "Text"]:SetJustifyH("LEFT")
	
	-- Adds a checkbox for filtering chat spam of NPCs in your garrison.
	local garrisonCheckbox = CreateFrame("CheckButton", "garrisonCheckbox", panel, "UICheckButtonTemplate")
	garrisonCheckbox:SetPoint("TOPLEFT", 20, -60)
	garrisonCheckbox:SetScript("OnClick", 
		function()
			CCcheckboxes.filterGarrison = not CCcheckboxes.filterGarrison
		end
	)
	garrisonCheckbox:SetChecked(CCcheckboxes.filterGarrison)
	_G[garrisonCheckbox:GetName() .. "Text"]:SetText(" Filter chat spam of NPCs in your garrison.")
	_G[garrisonCheckbox:GetName() .. "Text"]:SetJustifyH("LEFT")
	
	-- Adds a checkbox for filtering system messages of "You are not in a raid group".
	local notRaidingCheckbox = CreateFrame("CheckButton", "notRaidingCheckbox", panel, "UICheckButtonTemplate")
	notRaidingCheckbox:SetPoint("TOPLEFT", 20, -100)
	notRaidingCheckbox:SetScript("OnClick", 
		function()
			CCcheckboxes.filterNotRaiding = not CCcheckboxes.filterNotRaiding
		end
	)
	notRaidingCheckbox:SetChecked(CCcheckboxes.filterNotRaiding)
	_G[notRaidingCheckbox:GetName() .. "Text"]:SetText(" Filter system messages of \"You are not in a raid group\".")
	_G[notRaidingCheckbox:GetName() .. "Text"]:SetJustifyH("LEFT")
	
	-- Adds a checkbox for filtering system messages of "You aren't in a party.".
	local notInPartyCheckbox = CreateFrame("CheckButton", "notInPartyCheckbox", panel, "UICheckButtonTemplate")
	notInPartyCheckbox:SetPoint("TOPLEFT", 20, -140)
	notInPartyCheckbox:SetScript("OnClick", 
		function()
			CCcheckboxes.filterNotInParty = not CCcheckboxes.filterNotInParty
		end
	)
	notInPartyCheckbox:SetChecked(CCcheckboxes.filterNotInParty)
	_G[notInPartyCheckbox:GetName() .. "Text"]:SetText(" Filter system messages of \"You aren't in a party.\".")
	_G[notInPartyCheckbox:GetName() .. "Text"]:SetJustifyH("LEFT")
	
	-- Adds a checkbox for filtering system messages of "No player named '%s' is currently playing.".
	local notPlayingCheckbox = CreateFrame("CheckButton", "notPlayingCheckbox", panel, "UICheckButtonTemplate")
	notPlayingCheckbox:SetPoint("TOPLEFT", 20, -180)
	notPlayingCheckbox:SetScript("OnClick", 
		function()
			CCcheckboxes.filterNotPlaying = not CCcheckboxes.filterNotPlaying
		end
	)
	notPlayingCheckbox:SetChecked(CCcheckboxes.filterNotPlaying)
	_G[notPlayingCheckbox:GetName() .. "Text"]:SetText(" Filter system messages of \"No player named '%s' is currently playing.\".")
	_G[notPlayingCheckbox:GetName() .. "Text"]:SetJustifyH("LEFT")
	
	-- Adds a checkbox for filtering chat spam when you switch talents.
	local skillChangeCheckbox = CreateFrame("CheckButton", "skillChangeCheckbox", panel, "UICheckButtonTemplate")
	skillChangeCheckbox:SetPoint("TOPLEFT", 20, -220)
	skillChangeCheckbox:SetScript("OnClick", 
		function()
			CCcheckboxes.filterSkillChange = not CCcheckboxes.filterSkillChange
		end
	)
	skillChangeCheckbox:SetChecked(CCcheckboxes.filterSkillChange)
	_G[skillChangeCheckbox:GetName() .. "Text"]:SetText(" Filter chat spam when you switch talents.")
	_G[skillChangeCheckbox:GetName() .. "Text"]:SetJustifyH("LEFT")
	
	-- Adds a checkbox for filtering system messages of people going offline if they are not in your guild or friends list.
	local offlineCheckbox = CreateFrame("CheckButton", "offlineCheckbox", panel, "UICheckButtonTemplate")
	offlineCheckbox:SetPoint("TOPLEFT", 20, -260)
	offlineCheckbox:SetScript("OnClick", 
		function()
			CCcheckboxes.filterOffline = not CCcheckboxes.filterOffline
		end
	)
	offlineCheckbox:SetChecked(CCcheckboxes.filterOffline)
	_G[offlineCheckbox:GetName() .. "Text"]:SetText(" Filter system messages of people going offline if they are not in your guild or friends list.")
	_G[offlineCheckbox:GetName() .. "Text"]:SetJustifyH("LEFT")
	
	-- Adds a checkbox for filtering bodyguard messages outside of your garrison.
	local bodyguardCheckbox = CreateFrame("CheckButton", "bodyguardCheckbox", panel, "UICheckButtonTemplate")
	bodyguardCheckbox:SetPoint("TOPLEFT", 20, -300)
	bodyguardCheckbox:SetScript("OnClick", 
		function()
			CCcheckboxes.filterBodyguard = not CCcheckboxes.filterBodyguard
		end
	)
	bodyguardCheckbox:SetChecked(CCcheckboxes.filterBodyguard)
	_G[bodyguardCheckbox:GetName() .. "Text"]:SetText(" Filter bodyguard messages outside of your garrison.")
	_G[bodyguardCheckbox:GetName() .. "Text"]:SetJustifyH("LEFT")
	
	-- Adds a checkbox for filtering incessant DND/AFK spam in whispers.
	local whisperCheckbox = CreateFrame("CheckButton", "whisperCheckbox", panel, "UICheckButtonTemplate")
	whisperCheckbox:SetPoint("TOPLEFT", 20, -340)
	whisperCheckbox:SetScript("OnClick", 
		function()
			CCcheckboxes.filterWhisper = not CCcheckboxes.filterWhisper
		end
	)
	whisperCheckbox:SetChecked(CCcheckboxes.filterWhisper)
	_G[whisperCheckbox:GetName() .. "Text"]:SetText(" Filter incessant DND/AFK spam in whispers.")
	_G[whisperCheckbox:GetName() .. "Text"]:SetJustifyH("LEFT")
	
	-- Adds a checkbox for fixing the double offline message bug.
	local doubleOfflineCheckbox = CreateFrame("CheckButton", "doubleOfflineCheckbox", panel, "UICheckButtonTemplate")
	doubleOfflineCheckbox:SetPoint("TOPLEFT", 20, -380)
	doubleOfflineCheckbox:SetScript("OnClick", 
		function()
			CCcheckboxes.filterDoubleOffline = not CCcheckboxes.filterDoubleOffline
		end
	)
	doubleOfflineCheckbox:SetChecked(CCcheckboxes.filterDoubleOffline)
	_G[doubleOfflineCheckbox:GetName() .. "Text"]:SetText(" Filter incessant DND/AFK spam in whispers.")
	_G[doubleOfflineCheckbox:GetName() .. "Text"]:SetJustifyH("LEFT")
end

local f = CreateFrame("Frame")

-- Initialises ClutterCleaner when the AddOn gets loaded.   
local function initialise(_, _, loadedAddOnName)
	-- Check if ClutterCleaner's saved variables are loaded.
	if loadedAddOnName == "ClutterCleaner" then
		f:UnregisterEvent("ADDON_LOADED") -- Unnecessary, but provides a minuscule speed-up.
		checkFirstRuntime()
		createUI()
	end
end

f:RegisterEvent("ADDON_LOADED")
f:SetScript("OnEvent", initialise)