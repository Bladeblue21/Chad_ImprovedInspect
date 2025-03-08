--New Raid checklist
    -- change numExpansionTiers 
    -- add to RAID_LIST_DROPDOWN
        -- set default instance to new tier
        -- get EJ_SelectInstance id
        -- update the background image with correct file
        -- get critera ids and update other file for each boss  



local currentComparePlayer = nil;
local numExpansionTiers = 2;

local raidDifficultyList = {
    [1] = "LFR",
    [2] = "Normal",
    [3] = "Heroic",
    [4] = "Mythic"
}

--List of all raids in current expansion
local RAID_LIST_DROPDOWN = {
    [1] = {
    name = "Nerubar Palace",
    numRaidBosses = 8,
    backgroundTexture = "Interface\\ENCOUNTERJOURNAL\\UI-EJ-BACKGROUND-NerubarPalace",
    EJInstanceID = 1273,
    criteriaIDList = NerubarPalaceID,
    raidProgress = {}
    };

    [2] = {
        name = "Liberation of Undermine",
        numRaidBosses = 8,
        backgroundTexture = "Interface\\ENCOUNTERJOURNAL\\UI-EJ-BACKGROUND-casino",
        EJInstanceID = 1296,
        criteriaIDList = UndermineID,
        raidProgress = {}
    };
};


function RaidProgressDropdown_Initialize()
	local info = UIDropDownMenu_CreateInfo();

    for raid, raidInfo in ipairs(RAID_LIST_DROPDOWN) do
        info.value = raid
        info.text = raidInfo.name;
        info.func = RaidProgressDropdown_SelectRaid
        info.checked = nil
		UIDropDownMenu_AddButton(info)
    end
end

function RaidProgressDropdown_SelectRaid(button)
    local selectedRaid = button.value;
    UIDropDownMenu_SetSelectedValue(RaidListDropDown, selectedRaid);

    II_RaidProgressFrame:SetupDifficultyDisplays(selectedRaid)
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
            currentTier = 2;
            UIDropDownMenu_SetSelectedValue(RaidListDropDown, currentTier);
            II_RaidProgressFrame.BG:SetTexture(RAID_LIST_DROPDOWN[currentTier].backgroundTexture);
            UIDropDownMenu_SetText(RaidListDropDown, RAID_LIST_DROPDOWN[currentTier].name)

            local selectedRaid = UIDropDownMenu_GetSelectedValue(RaidListDropDown)
            self:BuildRaidProgressTable()
            self:SetupDifficultyDisplays(selectedRaid)
        end
    end
end

function RaidProgressInspectLayoutMixin:OnShow()
    ClearAchievementComparisonUnit()
    SetAchievementComparisonUnit("target")
end

--Pulls the inspected players boss kill stats
function RaidProgressInspectLayoutMixin:BuildRaidProgressTable()
    for raidTier = 1, numExpansionTiers do
        -- Loads the EJ for the current raid instance
        EJ_SelectInstance(RAID_LIST_DROPDOWN[raidTier].EJInstanceID)

        for raidTypeIndex, raidDifficulty in ipairs (raidDifficultyList) do
            RAID_LIST_DROPDOWN[raidTier].raidProgress[raidDifficulty] = {};

            for i = 1, RAID_LIST_DROPDOWN[raidTier].numRaidBosses do
                local name = EJ_GetEncounterInfoByIndex(i, RAID_LIST_DROPDOWN[raidTier].EJInstanceID)
                local statKillInfo = GetComparisonStatistic(RAID_LIST_DROPDOWN[raidTier].criteriaIDList[name][raidDifficulty]);

                RAID_LIST_DROPDOWN[raidTier].raidProgress[raidDifficulty][name] = statKillInfo;
            end
        end
    end
end

--Creates a bar for each raid difficulty.
function RaidProgressInspectLayoutMixin:SetupDifficultyDisplays(selectedRaid)
    self.lastOption = nil
    self.InspectRaidDifficultyPool:ReleaseAll();

    for raidTypeIndex, raidDifficulty in ipairs (raidDifficultyList) do
        local inspectRaidDifficultyDisplay = self.InspectRaidDifficultyPool:Acquire(); 

        if (not self.lastOption) then 
            inspectRaidDifficultyDisplay:SetPoint("TOPLEFT", InspectRaidProgressBoxFrame); 
            self.previousRowOption = inspectRaidDifficultyDisplay; 
        else 
            inspectRaidDifficultyDisplay:SetPoint("TOP", self.lastOption, "BOTTOM", 0, -10);
        end	

        inspectRaidDifficultyDisplay:ProgressSetUp(raidDifficulty, selectedRaid);
        self.lastOption = inspectRaidDifficultyDisplay;
    end 
end


RaidProgressInspectDisplayMixin = {}

function RaidProgressInspectDisplayMixin:ProgressSetUp(raidDifficulty, selectedRaid)

    local totalBossKills = 0;

    for bossname, statValue in pairs(RAID_LIST_DROPDOWN[selectedRaid].raidProgress[raidDifficulty]) do
        if (statValue ~= "--") then
            totalBossKills = totalBossKills + 1
        end
    end

    self.bossProgressBar:SetMinMaxValues(0, RAID_LIST_DROPDOWN[selectedRaid].numRaidBosses);
    self.raidDifficultyLabel:SetText(raidDifficulty);
    self.raidCurrentProg:SetText(totalBossKills.."/"..RAID_LIST_DROPDOWN[selectedRaid].numRaidBosses);
    self.bossProgressBar:SetValue(totalBossKills);

    self:Show();
end