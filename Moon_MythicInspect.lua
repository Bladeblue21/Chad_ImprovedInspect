local storeMythicScoreInfo = {};

local function GetEntryByMapID(store, mapID)
    for k, v in pairs(store) do 
        if v.mapID == mapID then
            return k;
        end
    end
end

MythicScoreInspectLayoutMixin = {};

function MythicScoreInspectLayoutMixin:OnLoad()
    self:RegisterEvent("INSPECT_READY");
	self.InspectDungeonsPool = CreateFramePool("Frame", InspectScoreBoxFrame, "InspectDungeonIconFrameTemplate");
end

function MythicScoreInspectLayoutMixin:OnEvent(event, ...)
    if event == "INSPECT_READY" then
        self.guid = ...;
    end
end

function MythicScoreInspectLayoutMixin:OnShow()
    if not self.maps then
        self.maps = C_ChallengeMode.GetMapTable();
    end
    self:BuildMapTable();
end

--Table to hold inspected players m+ stats
function MythicScoreInspectLayoutMixin:BuildMapTable()
    self.lastOption = nil;
    self.InspectDungeonsPool:ReleaseAll();
    local unitToken = UnitTokenFromGUID(self.guid);

    local inspectMythicMapsInfo = C_PlayerInfo.GetPlayerMythicPlusRatingSummary(unitToken);

    if (not inspectMythicMapsInfo) then
        return
    end

    local playerTotalScore = inspectMythicMapsInfo.currentSeasonScore
    local inspectMapInfo = inspectMythicMapsInfo.runs

    for index, map in ipairs(self.maps) do
        storeMythicScoreInfo[index] = { mapID = map, timed = 0, keyLevel = 0, dungeonScore = 0 }
    end

    for index, inspectInfo in ipairs(inspectMapInfo) do
        local mapIndex = GetEntryByMapID(storeMythicScoreInfo, inspectInfo.challengeModeID)
        if mapIndex then
            storeMythicScoreInfo[mapIndex].mapID = inspectInfo.challengeModeID;
            storeMythicScoreInfo[mapIndex].timed = inspectInfo.finishedSuccess;
            storeMythicScoreInfo[mapIndex].keyLevel = inspectInfo.bestRunLevel;
            storeMythicScoreInfo[mapIndex].dungeonScore = inspectInfo.mapScore;
            storeMythicScoreInfo[mapIndex].bestRunTime = inspectInfo.bestRunDurationMS;
        end
    end

    for index, option in ipairs(storeMythicScoreInfo) do 
        self.lastOption = self:GetMythicScoreInfo(index, option);
    end

    self:ScoreRating(playerTotalScore)
end

--Creates the display for each dungeon
function MythicScoreInspectLayoutMixin:GetMythicScoreInfo(index, optionInfo)
    local MAX_DUNGEONS_IN_ROWS = 4;
	local inspectDungeonScoreDisplay = self.InspectDungeonsPool:Acquire(); 

    --Displays m+ dungeons in a 4x2 order
	if (not self.lastOption) then 
		inspectDungeonScoreDisplay:SetPoint("TOPLEFT", InspectScoreBoxFrame); 
		self.previousRowOption = inspectDungeonScoreDisplay; 
	elseif (mod(index - 1, MAX_DUNGEONS_IN_ROWS) == 0) then 
		inspectDungeonScoreDisplay:SetPoint("TOP", self.previousRowOption, "BOTTOM", 0, -15);
		self.previousRowOption = inspectDungeonScoreDisplay; 
	else 
		inspectDungeonScoreDisplay:SetPoint("LEFT", self.lastOption, "RIGHT", 15, 0);
	end	

	inspectDungeonScoreDisplay:IconSetUp(index, optionInfo);
	return inspectDungeonScoreDisplay;
end 

--Total season m+ score
function MythicScoreInspectLayoutMixin:ScoreRating(totalScore)
	local color;

    if(totalScore) then	
		color = C_ChallengeMode.GetDungeonScoreRarityColor(totalScore);
    else
		color = HIGHLIGHT_FONT_COLOR; 
	end

    self.Score:SetText(totalScore);
    self.Score:SetTextColor(color.r, color.g, color.b);
    self.Score:Show();
end

function MythicScoreInspectLayoutMixin:OnHide()
    for i, v in ipairs(storeMythicScoreInfo) do
        storeMythicScoreInfo[i] = nil;
    end
end


MythicScoreInspectDisplayMixin = {};

--Creates the box for each dungeon. Shows keyLevel and highest score of that dungeon.
function MythicScoreInspectDisplayMixin:IconSetUp(indes, mapInfo)
    local _, _, _, texture = C_ChallengeMode.GetMapUIInfo(mapInfo.mapID);
    self.mapID = mapInfo.mapID;

    if (texture == 0) then
        texture = "Interface\\Icons\\achievement_bg_wineos_underxminutes";
    end

    self.dungeonIcon:SetTexture(texture);
    self.dungeonIcon:SetDesaturated(mapInfo.keyLevel == 0);

	local overAllScore = mapInfo.dungeonScore;
	local color;
	if(overAllScore) then	
		color = C_ChallengeMode.GetSpecificDungeonOverallScoreRarityColor(overAllScore);
	end
	if(not color) then 
		color = HIGHLIGHT_FONT_COLOR; 
	end	

    if (mapInfo.keyLevel > 0) then
        self.inspectKeyLevel:SetText(mapInfo.keyLevel);
        self.inspectKeyLevel:SetTextColor(color.r, color.g, color.b);
        self.inspectKeyLevel:Show();

        self.inspectMapScore:SetText(mapInfo.dungeonScore);
        self.inspectMapScore:SetTextColor(color.r, color.g, color.b);
        self.inspectMapScore:Show();
    else
        self.inspectKeyLevel:Hide();
        self.inspectMapScore:Hide();
    end

    self:Show();
end

function MythicScoreInspectDisplayMixin:OnEnter()
    local name = C_ChallengeMode.GetMapUIInfo(self.mapID);
    GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
    GameTooltip:SetText(name, 1, 1, 1);

    for index, info in pairs(storeMythicScoreInfo) do
        if self.mapID == info.mapID then
            self.keyLevel = info.keyLevel;
            self.timed = info.timed;
            self.bestRunTime = info.bestRunTime;
            self.dungeonScore = info.dungeonScore;
            break;
        end
    end

    if self.keyLevel < 1 then
        GameTooltip:Show();
        return
    end

    local overAllScore = self.dungeonScore;
    local color;
    if(overAllScore) then
        color = C_ChallengeMode.GetSpecificDungeonOverallScoreRarityColor(overAllScore);
    end

    if (not color) then
        color = HIGHLIGHT_FONT_COLOR;
    end

    GameTooltip_AddBlankLineToTooltip(GameTooltip);
    GameTooltip_AddNormalLine(GameTooltip, DUNGEON_SCORE_TOTAL_SCORE:format(color:WrapTextInColorCode(self.dungeonScore)), GREEN_FONT_COLOR);
    GameTooltip_AddColoredLine(GameTooltip, MYTHIC_PLUS_POWER_LEVEL:format(self.keyLevel), HIGHLIGHT_FONT_COLOR);

    if (self.timed) then
        GameTooltip_AddColoredLine(GameTooltip, SecondsToClock(self.bestRunTime/1000, false), HIGHLIGHT_FONT_COLOR);
    else
        GameTooltip_AddColoredLine(GameTooltip, DUNGEON_SCORE_OVERTIME_TIME:format(SecondsToClock(self.bestRunTime/1000, false)), LIGHTGRAY_FONT_COLOR);
    end

    GameTooltip:Show();
end

function MythicScoreInspectDisplayMixin:OnLeave()
    GameTooltip:Hide();
end
