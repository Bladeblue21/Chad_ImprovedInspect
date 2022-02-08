--For 9.2 Raid checklist
    -- add to RAID_LIST_DROPDOWN
        -- get EJ_SelectInstance id
        -- update the background image with correct file
        -- get critera ids and update other file for each boss  

local currentComparePlayer = nil;

local raidDifficultyList = {
    [1] = "LFR",
    [2] = "Normal",
    [3] = "Heroic",
    [4] = "Mythic"
}

local RAID_LIST_DROPDOWN = {
    ["Castle Nathria"] = {
        name = "Castle Nathria",
        numRaidBosses = 10,
        backgroundTexture = "Interface\\ENCOUNTERJOURNAL\\UI-EJ-BACKGROUND-CastleNathria",
        EJInstanceID = 1190,
        criteriaIDList = CastleNathriaCriteriaID,
        raidProgress = {}
    };

    ["Sanctum of Domination"] = {
        name = "Sanctum of Domination",
        numRaidBosses = 10,
        backgroundTexture = "Interface\\ENCOUNTERJOURNAL\\UI-EJ-BACKGROUND-SanctumofDomination",
        EJInstanceID = 1193,
        criteriaIDList = SanctumOfDominationCriteriaID,        
        raidProgress = {}
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

    for raid, raidInfo in pairs(RAID_LIST_DROPDOWN) do
        info.text = raidInfo.name;
        info.func = RaidProgressDropdown_SelectRaid
        info.checked = nil
		UIDropDownMenu_AddButton(info)
    end
end

function RaidProgressDropdown_SelectRaid(button)
    local selectedRaid = button.value;
    UIDropDownMenu_SetSelectedValue(RaidListDropDown, selectedRaid);

    II_RaidProgressFrame:BuildRaidProgressTable(selectedRaid)
    II_RaidProgressFrame.BG:SetTexture(RAID_LIST_DROPDOWN[selectedRaid].backgroundTexture);
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
            II_RaidProgressFrame.BG:SetTexture(RAID_LIST_DROPDOWN["Sanctum of Domination"].backgroundTexture);
            UIDropDownMenu_SetText(RaidListDropDown, "Sanctum of Domination")

            local selectedRaid = UIDropDownMenu_GetSelectedValue(RaidListDropDown)
            self:BuildRaidProgressTable(selectedRaid)
        end
    end
end

function RaidProgressInspectLayoutMixin:OnShow()
    ClearAchievementComparisonUnit()
    SetAchievementComparisonUnit("target")
end

function RaidProgressInspectLayoutMixin:BuildRaidProgressTable(selectedRaid)
    self.lastOption = nil
    self.InspectRaidDifficultyPool:ReleaseAll();

    for raidTypeIndex, raidTypeName in ipairs (raidDifficultyList) do 
        RAID_LIST_DROPDOWN[selectedRaid].raidProgress[raidTypeName] = {};

        for i = 1, RAID_LIST_DROPDOWN[selectedRaid].numRaidBosses do
            local name = EJ_GetEncounterInfoByIndex(i, RAID_LIST_DROPDOWN[selectedRaid].EJInstanceID)
            local statKillInfo = GetComparisonStatistic(RAID_LIST_DROPDOWN[selectedRaid].criteriaIDList[name][raidTypeName]);
            RAID_LIST_DROPDOWN[selectedRaid].raidProgress[raidTypeName][name] = statKillInfo;
        end

        self.lastOption = self:SetupDifficultyDisplays(raidTypeName, RAID_LIST_DROPDOWN[selectedRaid].raidProgress[raidTypeName], selectedRaid);
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


RaidProgressInspectDisplayMixin = {}

function RaidProgressInspectDisplayMixin:ProgressSetUp(raidDifficulty, bossInfo, selectedRaid)
    local totalBossKills = 0;

    for bossname, statValue in pairs(RAID_LIST_DROPDOWN[selectedRaid].raidProgress[raidDifficulty]) do
        if (statValue ~= "--") then
            totalBossKills = totalBossKills + 1
        end
    end

    self.bossProgressBar:SetMinMaxValues(0, RAID_LIST_DROPDOWN[selectedRaid].numRaidBosses);
    self.raidDifficultyLabel:SetText(raidDifficulty);
    self.raidCurrentProg:SetText(totalBossKills);
    self.bossProgressBar:SetValue(totalBossKills);

    self:Show();
end