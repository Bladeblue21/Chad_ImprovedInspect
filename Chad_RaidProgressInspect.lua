--For 9.2 Raid checklist
    -- add to RAID_LIST_DROPDOWN
         -- update the background image with correct file    
    -- add button to raid dropdowns
    -- get critera ids and update other file for each boss
    -- get EJ_SelectInstance id
    -- setup the build table
    -- add check in ProgressSetUp

local NUM_NATHRIA_BOSSES = 10
local NUM_SANCTUM_BOSSES = 10
local NUM_FIRSTONE_BOSSES = 12 --Placeholder for 9.2 Raid

local currentComparePlayer = nil;

local inspectRaidProg = {}
inspectRaidProg.CastleNathria = {
    ["LFR"] = {},
    ["Normal"] = {},
    ["Heroic"] = {},
    ["Mythic"] = {},
}

inspectRaidProg.Sanctum = {
    ["LFR"] = {},
    ["Normal"] = {},
    ["Heroic"] = {},
    ["Mythic"] = {},
}

--Placeholder for 9.2 Raid
inspectRaidProg.FirstOnes = {
    ["LFR"] = {},
    ["Normal"] = {},
    ["Heroic"] = {},
    ["Mythic"] = {},
}

local RAID_LIST_CASTLE_NATHRIA = 1;
local RAID_LIST_SANCTUM_OF_DOMINATION = 2
-- local RAID_LIST_FIRST_ONES = 3  --Placeholder for 9.2 Raid

local RAID_LIST_DROPDOWN = {
    [RAID_LIST_CASTLE_NATHRIA] = {
        name = "Castle Nathria",
        numRaidBosses = NUM_NATHRIA_BOSSES,
        backgroundTexture = "Interface\\ENCOUNTERJOURNAL\\UI-EJ-BACKGROUND-CastleNathria",
    };

    [RAID_LIST_SANCTUM_OF_DOMINATION] = {
        name = "Sanctum of Domination",
        numRaidBosses = NUM_SANCTUM_BOSSES,
        backgroundTexture = "Interface\\ENCOUNTERJOURNAL\\UI-EJ-BACKGROUND-SanctumofDomination",
    };

    --Placeholder for 9.2 Raid
    -- [RAID_LIST_FIRST_ONES] = {
    --     name = "The First Ones",
    --     numRaidBosses = NUM_FIRSTONES_BOSSES,
    --     backgroundTexture = "Interface\\ENCOUNTERJOURNAL\\UI-EJ-BACKGROUND-ShadowFangKeep"
    -- }
};


function RaidProgressDropdown_Initialize()
	local info = UIDropDownMenu_CreateInfo();

    for raid, stuff in pairs(RAID_LIST_DROPDOWN) do
        info.text = stuff.name;
        info.func = RaidProgressDropdown_SelectRaid
        info.checked = nil
		UIDropDownMenu_AddButton(info)
    end
end

function RaidProgressDropdown_SelectRaid(button)
    local selectedRaid = button.value;
    UIDropDownMenu_SetSelectedValue(RaidListDropDown, selectedRaid);

	if ( selectedRaid == "Castle Nathria" ) then
		II_RaidProgressFrame.BG:SetTexture(RAID_LIST_DROPDOWN[1].backgroundTexture);
    elseif(selectedRaid == "Sanctum of Domination") then
        II_RaidProgressFrame.BG:SetTexture(RAID_LIST_DROPDOWN[2].backgroundTexture);

    --Placeholder for 9.2 Raid
    -- elseif(selectedRaid == "The First Ones") then
    --     II_RaidProgressFrame.BG:SetTexture(RAID_LIST_DROPDOWN[3].backgroundTexture);
    end
end



RaidProgressInspectLayoutMixin = {}

function RaidProgressInspectLayoutMixin:OnLoad()
    self:RegisterEvent("INSPECT_ACHIEVEMENT_READY");
    UIDropDownMenu_Initialize(RaidListDropDown, RaidProgressDropdown_Initialize);
	self.InspectRaidDifficultyPool = CreateFramePool("Frame", InspectRaidProgressBoxFrame, "RaidProgressButtonTemplate");
end

function RaidProgressInspectLayoutMixin:OnEvent(event, ...)
    if event == "INSPECT_ACHIEVEMENT_READY" then
        local guid = ...;
        if currentComparePlayer ~= guid then
            currentComparePlayer = guid

            -- Current Tier set on load
            UIDropDownMenu_SetSelectedValue(RaidListDropDown, "Sanctum of Domination");
            II_RaidProgressFrame.BG:SetTexture(RAID_LIST_DROPDOWN[2].backgroundTexture);
            UIDropDownMenu_SetText(RaidListDropDown, "Sanctum of Domination")
        end
    end
end

function RaidProgressInspectLayoutMixin:OnShow()
    ClearAchievementComparisonUnit()
    SetAchievementComparisonUnit("target")
end

function RaidProgressInspectLayoutMixin:OnUpdate()
    local selectedRaid = UIDropDownMenu_GetSelectedValue(RaidListDropDown)
    self:BuildRaidProgressTable(selectedRaid)
end

function RaidProgressInspectLayoutMixin:BuildRaidProgressTable(selectedRaid)
    self.lastOption = nil
    self.InspectRaidDifficultyPool:ReleaseAll();

    if ( selectedRaid == "Castle Nathria" ) then
        EJ_SelectInstance(1190)
    
        for i = 1, NUM_NATHRIA_BOSSES do
            local name = EJ_GetEncounterInfoByIndex(i, true)
            inspectRaidProg.CastleNathria["LFR"][name] = GetComparisonStatistic(CastleNathriaCriteriaID[name].LFR); -- GetStatistic(achievementID)
            inspectRaidProg.CastleNathria["Normal"][name] = GetComparisonStatistic(CastleNathriaCriteriaID[name].Normal); --GetComparisonStatistic(achievementID)
            inspectRaidProg.CastleNathria["Heroic"][name] = GetComparisonStatistic(CastleNathriaCriteriaID[name].Heroic);
            inspectRaidProg.CastleNathria["Mythic"][name] = GetComparisonStatistic(CastleNathriaCriteriaID[name].Mythic);
        end
    
        for index, option in pairs(inspectRaidProg.CastleNathria) do
            self.lastOption = self:SetupDifficultyDisplays(index, option, selectedRaid);
        end

    elseif(selectedRaid == "Sanctum of Domination") then
        EJ_SelectInstance(1193)

        for i = 1, NUM_SANCTUM_BOSSES do
            local name = EJ_GetEncounterInfoByIndex(i, true)
    
            inspectRaidProg.Sanctum["LFR"][name] = GetComparisonStatistic(SanctumOfDominationCriteriaID[name].LFR); -- GetStatistic(achievementID)
            inspectRaidProg.Sanctum["Normal"][name] = GetComparisonStatistic(SanctumOfDominationCriteriaID[name].Normal); --GetComparisonStatistic(achievementID)
            inspectRaidProg.Sanctum["Heroic"][name] = GetComparisonStatistic(SanctumOfDominationCriteriaID[name].Heroic);
            inspectRaidProg.Sanctum["Mythic"][name] = GetComparisonStatistic(SanctumOfDominationCriteriaID[name].Mythic);
        end
    
        for index, option in pairs(inspectRaidProg.Sanctum) do
            self.lastOption = self:SetupDifficultyDisplays(index, option, selectedRaid);
        end
    end
end


function RaidProgressInspectLayoutMixin:SetupDifficultyDisplays(raidDifficulty, bossInfo, selectedRaid)
	local inspectRaidDifficultyDisplay = self.InspectRaidDifficultyPool:Acquire(); 

    if (not self.lastOption) then 
		inspectRaidDifficultyDisplay:SetPoint("TOPLEFT", InspectRaidProgressBoxFrame); 
		self.previousRowOption = inspectRaidDifficultyDisplay; 
	else 
		inspectRaidDifficultyDisplay:SetPoint("TOP", self.lastOption, "BOTTOM", 0, -10);
	end	

	inspectRaidDifficultyDisplay:ProgressSetUp(raidDifficulty, bossInfo, selectedRaid);
	return inspectRaidDifficultyDisplay;
end

function RaidProgressInspectLayoutMixin:OnHide()
    for i, v in ipairs(inspectRaidProg.CastleNathria) do 
        for boss, blank in pairs(inspectRaidProg.CastleNathria[i]) do
            inspectRaidProg.CastleNathria[i][boss] = nil
        end
    end
    for i, v in ipairs(inspectRaidProg.Sanctum) do 
        for boss, blank in pairs(inspectRaidProg.Sanctum[i]) do
            inspectRaidProg.Sanctum[i][boss] = nil
        end
    end
end

RaidProgressInspectDisplayMixin = {}

function RaidProgressInspectDisplayMixin:ProgressSetUp(raidDifficulty, bossInfo, selectedRaid)
    local totalBossKills = 0;
    
    if (selectedRaid == "Castle Nathria") then
        for bossname, option in pairs(inspectRaidProg.CastleNathria[raidDifficulty]) do
            if (option ~= "--") then
                totalBossKills = totalBossKills + 1
            end
        end
        self.bossProgressBar:SetMinMaxValues(0, NUM_NATHRIA_BOSSES);

    elseif (selectedRaid == "Sanctum of Domination") then
        for bossname, option in pairs(inspectRaidProg.Sanctum[raidDifficulty]) do
            if (option ~= "--") then
                totalBossKills = totalBossKills + 1
            end
        end
        self.bossProgressBar:SetMinMaxValues(0, NUM_SANCTUM_BOSSES);
    end

    self.raidDifficultyLabel:SetText(raidDifficulty);
    self.raidCurrentProg:SetText(totalBossKills);
    self.bossProgressBar:SetValue(totalBossKills);

    self:Show();
end

-- function TestPrintMatrix()
--     for difficulty, kills in pairs(inspectRaidProg.Sanctum) do
--         print(difficulty)
--         for bossname, blank in pairs(inspectRaidProg.Sanctum[difficulty]) do
--             print(bossname, blank)
--         end
--     end
-- end