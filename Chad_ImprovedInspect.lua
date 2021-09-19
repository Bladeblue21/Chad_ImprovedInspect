local NUM_IMPROVEDINSPECT_TABS = 6;

IMPROVED_INSPECT_WINDOWS = {
	"Character",
	"PvP",
	"Talents",
	"Guild",
	"II_MythicScoreFrame",
	"II_RaidProgressFrame",
};

local currentTab = nil;

function ImprovedInspect_OnLoad(self)
	-- This fixes an issue where the INSPECT_HONOR_UPDATE was firing on log in which caused a lua error.
	INSPECTED_UNIT = "player";
end

function SwitchImprovedInspectTabs(id)
	local lastInspectTab = PanelTemplates_GetSelectedTab(InspectFrame)
	if (lastInspectTab ~= 0) then
		_G[INSPECTFRAME_SUBFRAMES[lastInspectTab]]:Hide();
		PanelTemplates_SetTab(InspectFrame, 0);
	end

	local newFrame = _G[IMPROVED_INSPECT_WINDOWS[id]]
	local oldFrame = _G[IMPROVED_INSPECT_WINDOWS[currentTab]];

	if ( newFrame ) then
		if ( oldFrame ) then
			oldFrame:Hide();
		end
		
		currentTab = id;
		newFrame:Show();
	end
end

function ImprovedInspect_OnClick (self, button)
	SwitchImprovedInspectTabs(self:GetID())
end

function ImprovedInspect_OnHide (self)
	II_MythicScoreFrame:Hide();
	ImprovedInspectFrameTab1:SetChecked(false);
	II_RaidProgressFrame:Hide();
	ImprovedInspectFrameTab2:SetChecked(false);
	currentTab = nil;
end

hooksecurefunc("InspectSwitchTabs", ImprovedInspect_OnHide);

