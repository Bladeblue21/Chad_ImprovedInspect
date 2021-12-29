print("RaidProgress")

-- C_EncounterJournal.GetEncountersOnMap(1735)
-- 1193
-- EJ_GetEncounterInfoByIndex(1 , 2450)
-- 2435 Tarragrue EncounterID

-- Use this to find the amount of times a player has defeated a boss.
-- GetComparisonStatistic(achievementID)
-- GetComparisonStatistic(15136) LFR Tarragrue

-- I think this will set the inspect target and allow achievement comparison.
-- SetAchievementComparisonUnit(unit);

-- inspectraidprog.SoD[1].bossName
--                         RaidFinderKills
--                         NormalKills
--                         HeroicKills
--                         MythicKills


-- This will set the status bars value
-- II_RaidProgressFrame.LFRBossProgress:SetValue(##)

local inspectRaidProg = {}
local NUM_NATHRIA_BOSSES = 10
local NUM_SANCTUM_BOSSES = 10

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

local RAID_LIST_CASTLE_NATHRIA = 1;
local RAID_LIST_SANCTUM_OF_DOMINATION = 2

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
};



RaidDropdownMixin = {}

RaidProgressInspectLayoutMixin = {}

-- functions needed
-- handle toggling raids (dropdown)
-- button setup
-- bar setup
-- Set values

function RaidProgressInspectLayoutMixin:OnLoad()
	self.InspectRaidDifficultyPool = CreateFramePool("Frame", InspectRaidProgressBoxFrame, "RaidProgressButtonTemplate");
	-- self.InspectProgressBarPool = CreateFramePool("Frame", InspectScoreBoxFrame, "InspectDungeonIconFrameTemplate");
end

function RaidProgressInspectLayoutMixin:OnShow()
    -- self:BuildCastleTable()
    self:BuildSanctumTable()
end

function RaidProgressInspectLayoutMixin:BuildCastleTable()
    EJ_SelectInstance(1190)
    self.lastOption = nil
    self.InspectRaidDifficultyPool:ReleaseAll();

    -- for i = 1, NUM_NATHRIA_BOSSES do
    --     local name = EJ_GetEncounterInfoByIndex(i, true)
    --     inspectRaidProg.CastleNathria[name] = {}
    --     inspectRaidProg.CastleNathria[name].LFR = GetStatistic(CastleNathriaCriteriaID[name].LFR); -- GetComparisonStatistic(achievementID)
    --     inspectRaidProg.CastleNathria[name].Normal = GetStatistic(CastleNathriaCriteriaID[name].Normal);
    --     inspectRaidProg.CastleNathria[name].Heroic = GetStatistic(CastleNathriaCriteriaID[name].Heroic);
    --     inspectRaidProg.CastleNathria[name].Mythic = GetStatistic(CastleNathriaCriteriaID[name].Mythic);
    -- end

    for i = 1, NUM_NATHRIA_BOSSES do
        local name = EJ_GetEncounterInfoByIndex(i, true)
        inspectRaidProg.CastleNathria["LFR"][name] = GetStatistic(CastleNathriaCriteriaID[name].LFR); -- GetComparisonStatistic(achievementID)
        inspectRaidProg.CastleNathria["Normal"][name] = GetStatistic(CastleNathriaCriteriaID[name].Normal);
        inspectRaidProg.CastleNathria["Heroic"][name] = GetStatistic(CastleNathriaCriteriaID[name].Heroic);
        inspectRaidProg.CastleNathria["Mythic"][name] = GetStatistic(CastleNathriaCriteriaID[name].Mythic);
    end
    -- TestPrintMatrix()
end


function RaidProgressInspectLayoutMixin:BuildSanctumTable ()
    EJ_SelectInstance(1193)
    SetAchievementComparisonUnit("target")
    self.lastOption = nil
    self.InspectRaidDifficultyPool:ReleaseAll();

    -- for i = 1, NUM_SANCTUM_BOSSES do
    --     local name, _, encounterID = EJ_GetEncounterInfoByIndex(i, true)
    --     inspectRaidProg.Sanctum[name] = {}
    --     inspectRaidProg.Sanctum[name].LFR = GetStatistic(SanctumOfDominationCriteriaID[name].LFR);
    --     inspectRaidProg.Sanctum[name].Normal = GetStatistic(SanctumOfDominationCriteriaID[name].Normal);
    --     inspectRaidProg.Sanctum[name].Heroic = GetStatistic(SanctumOfDominationCriteriaID[name].Heroic);
    --     inspectRaidProg.Sanctum[name].Mythic = GetStatistic(SanctumOfDominationCriteriaID[name].Mythic);
    -- end

    for i = 1, NUM_SANCTUM_BOSSES do
        local name = EJ_GetEncounterInfoByIndex(i, true)
        -- inspectRaidProg.Sanctum["LFR"][name] = GetStatistic(SanctumOfDominationCriteriaID[name].LFR);
        -- inspectRaidProg.Sanctum["Normal"][name] = GetStatistic(SanctumOfDominationCriteriaID[name].Normal);
        -- inspectRaidProg.Sanctum["Heroic"][name] = GetStatistic(SanctumOfDominationCriteriaID[name].Heroic);
        -- inspectRaidProg.Sanctum["Mythic"][name] = GetStatistic(SanctumOfDominationCriteriaID[name].Mythic);

        inspectRaidProg.Sanctum["LFR"][name] = GetComparisonStatistic(SanctumOfDominationCriteriaID[name].LFR);
        inspectRaidProg.Sanctum["Normal"][name] = GetComparisonStatistic(SanctumOfDominationCriteriaID[name].Normal);
        inspectRaidProg.Sanctum["Heroic"][name] = GetComparisonStatistic(SanctumOfDominationCriteriaID[name].Heroic);
        inspectRaidProg.Sanctum["Mythic"][name] = GetComparisonStatistic(SanctumOfDominationCriteriaID[name].Mythic);

        -- /run SetAchievementComparisonUnit("target")
        -- /run AchievementFrameComparison_SetUnit("target")
        -- /dump GetComparisonStatistic(15137)
        -- local quantity = GetAchievementCriteriaInfo(15137)
        -- print (quantity)
        -- /dump GetAchievementComparisonInfo(15137)
    end

    -- for difficulty, option in pairs(inspectRaidProg.Sanctum) do
    --     inspectRaidProg.Sanctum[difficulty].bossProgress = -1
    -- end

    -- for bossname, option in pairs(inspectRaidProg.Sanctum["LFR"]) do
    --     if (inspectRaidProg.Sanctum["LFR"][bossname] ~= "--") then
    --         inspectRaidProg.Sanctum["LFR"].bossProgress = inspectRaidProg.Sanctum["LFR"].bossProgress + 1
    --     end
    -- end

    -- for bossname, option in pairs(inspectRaidProg.Sanctum["Normal"]) do 
    --     if (inspectRaidProg.Sanctum["Normal"][bossname] ~= "--") then
    --         inspectRaidProg.Sanctum["Normal"].bossProgress = inspectRaidProg.Sanctum["Normal"].bossProgress + 1
    --     end
    -- end

    -- for bossname, option in pairs(inspectRaidProg.Sanctum["Heroic"]) do 
    --     if (inspectRaidProg.Sanctum["Heroic"][bossname] ~= "--") then
    --         inspectRaidProg.Sanctum["Heroic"].bossProgress = inspectRaidProg.Sanctum["Heroic"].bossProgress + 1
    --     end
    -- end

    -- for bossname, option in pairs(inspectRaidProg.Sanctum["Mythic"]) do 
    --     if (inspectRaidProg.Sanctum["Mythic"][bossname] ~= "--") then
    --         inspectRaidProg.Sanctum["Mythic"].bossProgress = inspectRaidProg.Sanctum["Mythic"].bossProgress + 1
    --     end
    -- end

    -- for bossname, option in pairs(inspectRaidProg.Sanctum) do 
    --     if (inspectRaidProg.Sanctum[bossname].LFR > "0") then
    --         inspectRaidProg.Sanctum["BossProgress"].LFR = inspectRaidProg.Sanctum["BossProgress"].LFR + 1
    --     end
        -- if (inspectRaidProg.Sanctum["Normal"][bossname] > "0") then
        --     inspectRaidProg.Sanctum["Normal"].bossProgress = inspectRaidProg.Sanctum["Normal"].bossProgress + 1
        -- end
    --     if (inspectRaidProg.Sanctum[bossname].Heroic > "0") then
    --         inspectRaidProg.Sanctum["BossProgress"].Heroic = inspectRaidProg.Sanctum["BossProgress"].Heroic + 1
    --     end
    --     if (inspectRaidProg.Sanctum[bossname].Mythic > "0") then
    --         inspectRaidProg.Sanctum["BossProgress"].Mythic = inspectRaidProg.Sanctum["BossProgress"].Mythic + 1
    --     end
    -- end

    for index, option in pairs(inspectRaidProg.Sanctum) do
        self.lastOption = self:SetupDifficultyDisplays(index, option);
    end

    -- print(inspectRaidProg.Sanctum["Normal"].bossProgress)
    TestPrintMatrix()
end

function RaidProgressInspectLayoutMixin:SetupDifficultyDisplays(raidDifficulty, bossInfo)
	local inspectRaidDifficultyDisplay = self.InspectRaidDifficultyPool:Acquire(); 

    if (not self.lastOption) then 
		inspectRaidDifficultyDisplay:SetPoint("TOPLEFT", InspectRaidProgressBoxFrame); 
		self.previousRowOption = inspectRaidDifficultyDisplay; 
	else 
		inspectRaidDifficultyDisplay:SetPoint("TOP", self.lastOption, "BOTTOM", 0, -10);
	end	

	inspectRaidDifficultyDisplay:ProgressSetUp(raidDifficulty, bossInfo);
	return inspectRaidDifficultyDisplay;
end

RaidProgressInspectDisplayMixin = {}

function RaidProgressInspectDisplayMixin:ProgressSetUp(raidDifficulty, bossInfo)
    local totalBossKills = 0;

    for bossname, option in pairs(inspectRaidProg.Sanctum[raidDifficulty]) do
        if (option ~= "--") then
            totalBossKills = totalBossKills + 1
        end
    end

    self.raidDifficultyLabel:SetText(raidDifficulty);
    self.raidCurrentProg:SetText(totalBossKills);

    self.bossProgressBar:SetMinMaxValues(0, NUM_SANCTUM_BOSSES);
    self.bossProgressBar:SetValue(totalBossKills);

    self:Show();
end

function TestPrintMatrix()
    for difficulty, kills in pairs(inspectRaidProg.Sanctum) do
        print(difficulty)
        for bossname, blank in pairs(inspectRaidProg.Sanctum[difficulty]) do
            print(bossname, blank)
        end
    end
end



-- Stuff for when I get to doing the raid dropdown      ----
-- local RaidProgressInspectDropdown;

-- function RaidProgressInspectDropdown_OnEvent (self, event, ...)
-- 	if ( event == "PLAYER_ENTERING_WORLD" ) then
-- 		self.value = "CN";
-- 		self.tooltip = _G["OPTION_TOOLTIP_AUTO_SELF_CAST_"..self.value.."_KEY"];

-- 		UIDropDownMenu_SetWidth(self, 200);
--         print(self.value);

-- 		UIDropDownMenu_Initialize(self, RaidProgressInspectDropdown_Initialize);
-- 		UIDropDownMenu_SetSelectedValue(self, self.value);

-- 		self.SetValue =
-- 			function (self, value)
-- 				self.value = value;
-- 				UIDropDownMenu_SetSelectedValue(self, value);
-- 				-- SetModifiedClick("SELFCAST", value);
-- 				-- SaveBindings(GetCurrentBindingSet());
-- 				self.tooltip = _G["OPTION_TOOLTIP_AUTO_SELF_CAST_"..value.."_KEY"];
-- 			end;
-- 		self.GetValue =
-- 			function (self)
-- 				return UIDropDownMenu_GetSelectedValue(self);
-- 			end
-- 		self.RefreshValue =
-- 			function (self)
-- 				UIDropDownMenu_Initialize(self, RaidProgressInspectDropdown_Initialize);
-- 				UIDropDownMenu_SetSelectedValue(self, self.value);
-- 			end

-- 		self:UnregisterEvent(event);
-- 	end
-- end

-- function RaidProgressInspectDropdown_OnClick(self)
-- 	RaidProgressInspectDropdown:SetValue(self.value);
-- end

-- function RaidProgressInspectDropdown_Initialize()
--     local selectedValue = UIDropDownMenu_GetSelectedValue(RaidProgressInspectDropdown);
-- 	local info = UIDropDownMenu_CreateInfo();

--     info.text = RAID_LIST_DROPDOWN[RAID_LIST_CASTLE_NATHRIA].name;
-- 	info.func = RaidProgressInspectDropdown_OnClick;
-- 	info.value = "CN";
-- 	if ( info.value == selectedValue ) then
-- 		info.checked = 1;
-- 	else
-- 		info.checked = nil;
-- 	end
-- 	info.tooltipTitle = RAID_LIST_DROPDOWN[RAID_LIST_CASTLE_NATHRIA].name;
-- 	info.tooltipText = OPTION_TOOLTIP_AUTO_SELF_CAST_ALT_KEY;
-- 	UIDropDownMenu_AddButton(info);

--     info.text = RAID_LIST_DROPDOWN[RAID_LIST_SANCTUM_OF_DOMINATION].name;
-- 	info.func = RaidProgressInspectDropdown_OnClick;
-- 	info.value = "SoD";
-- 	if ( info.value == selectedValue ) then
-- 		info.checked = 1;
-- 	else
-- 		info.checked = nil;
-- 	end
-- 	info.tooltipTitle = RAID_LIST_DROPDOWN[RAID_LIST_SANCTUM_OF_DOMINATION].name;
-- 	info.tooltipText = OPTION_TOOLTIP_AUTO_SELF_CAST_ALT_KEY;
-- 	UIDropDownMenu_AddButton(info);
-- end
