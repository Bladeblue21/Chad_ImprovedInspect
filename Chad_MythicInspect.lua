-- ==================== Save this to sort maps by key level later!!!!!! ====================
-- table.sort(inspectMythicMaps.runs, function(a, b) return a.bestRunLevel > b.bestRunLevel end);

local storedInspectGUIDMythicInfo = 0;
local storeMythicScoreInfo = {};

MythicScoreInspectLayoutMixin = {};

function MythicScoreInspectLayoutMixin:OnLoad()
    --TODO:
    -- There is a bug here. The map table does not load upon first time logging into the game. This will cause the dungeon frames to not display on the inspect tab. 
    -- Reloading the UI will fix this. I imagine I need to load the list of dungeon maps but I couldn't find an event or function that did this for me.
    -- self.maps = C_ChallengeMode.GetMapTable();
	self.InspectDungeonsPool = CreateFramePool("Frame", InspectScoreBoxFrame, "InspectDungeonIconFrameTemplate");
end

function MythicScoreInspectLayoutMixin:OnShow()
    if not self.maps then
        self.maps = C_ChallengeMode.GetMapTable();
    end
    self:BuildMapTable();
end

function MythicScoreInspectLayoutMixin:BuildMapTable()
    self.lastOption = nil
    self.InspectDungeonsPool:ReleaseAll();
    local inspectMythicMapsInfo = C_PlayerInfo.GetPlayerMythicPlusRatingSummary("target");

    local playerTotalScore = inspectMythicMapsInfo.currentSeasonScore
    local inspectMapInfo = inspectMythicMapsInfo.runs

    for index, map in ipairs(self.maps) do
        storeMythicScoreInfo[index] = { mapID = map, timed = 0, keyLevel = 0, dungeonScore = 0 }
    end

    for index, scoreInfo in ipairs(inspectMapInfo) do
        storeMythicScoreInfo[index].mapID = scoreInfo.challengeModeID;
        storeMythicScoreInfo[index].timed = scoreInfo.finishedSuccess;
        storeMythicScoreInfo[index].keyLevel = scoreInfo.bestRunLevel;
        storeMythicScoreInfo[index].dungeonScore = scoreInfo.mapScore;
    end

    -- for k=1, #self.maps do
    --     table.insert(storeMythicScoreInfo, k, { mapID = map, timed = 0, keyLevel = 0, dungeonScore = 0 })

    --     storeMythicScoreInfo[k].mapID = self.maps[k];
    --     for l=1, #inspectMapInfo do
    --         if (storeMythicScoreInfo[k].mapID == inspectMapInfo[l].challengeModeID) then
    --             storeMythicScoreInfo[k].timed = inspectMapInfo[l].finishedSuccess;
    --             storeMythicScoreInfo[k].keyLevel = inspectMapInfo[l].bestRunLevel;
    --             storeMythicScoreInfo[k].dungeonScore = inspectMapInfo[l].mapScore;
    --         end
    --     end
    -- end

    -- for m=1, #storeMythicScoreInfo do
    --     print("MapID: "..storeMythicScoreInfo[m].mapID.." Level: "..storeMythicScoreInfo[m].keyLevel.." Score: "..storeMythicScoreInfo[m].dungeonScore);
    -- end

    for index, option in pairs(storeMythicScoreInfo) do 
        self.lastOption = self:GetMythicScoreInfo(index, option);
    end

    self:ScoreRating(playerTotalScore)
end

function MythicScoreInspectLayoutMixin:GetMythicScoreInfo(index, optionInfo)
    local MAX_DUNGEONS_IN_ROWS = 4;
	local inspectDungeonScoreDisplay = self.InspectDungeonsPool:Acquire(); 

	if (not self.lastOption) then 
		inspectDungeonScoreDisplay:SetPoint("TOPLEFT", InspectScoreBoxFrame); 
		self.previousRowOption = inspectDungeonScoreDisplay; 
	elseif (mod(index - 1, MAX_DUNGEONS_IN_ROWS) == 0) then 
		inspectDungeonScoreDisplay:SetPoint("TOP", self.previousRowOption, "BOTTOM", 0, -20);
		self.previousRowOption = inspectDungeonScoreDisplay; 
	else 
		inspectDungeonScoreDisplay:SetPoint("LEFT", self.lastOption, "RIGHT", 15, 0);
	end	

	inspectDungeonScoreDisplay:IconSetUp(optionInfo);
	return inspectDungeonScoreDisplay;
end 

function MythicScoreInspectLayoutMixin:ScoreRating(totalScore)
	local color;

    if(totalScore) then	
		color = C_ChallengeMode.GetDungeonScoreRarityColor(totalScore);
    else
		color = HIGHLIGHT_FONT_COLOR; 
	end

    self.Score:SetText(totalScore);
    self.Score:SetTextColor(color.r, color.g, color.b);
    self.Score:Show()
end


MythicScoreInspectDisplayMixin = {};

function MythicScoreInspectDisplayMixin:IconSetUp(mapInfo)
    local _, _, _, texture = C_ChallengeMode.GetMapUIInfo(mapInfo.mapID);

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

function MythicInspect_OnHide()
    for i, v in ipairs(storeMythicScoreInfo) do 
        storeMythicScoreInfo[i] = nil 
    end
end