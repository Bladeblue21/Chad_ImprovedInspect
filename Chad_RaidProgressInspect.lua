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

local inspectRaidProg = {}
local NUM_NATHRIA_BOSSES = 10
local NUM_SANCTUM_BOSSES = 10

inspectRaidProg.CastleNathria = {}
inspectRaidProg.Sanctum = {}

function RaidProg_OnLoad(self)
    BuildRaidBossTables()
end

function BuildRaidBossTables ()
    -- BuildCastleTable()
    BuildSanctumTable()
end

-- function BuildCastleTable()
--     EJ_SelectInstance(1190)
--     for i = 1, NUM_NATHRIA_BOSSES do
--         local name = EJ_GetEncounterInfoByIndex(i, true)
--         inspectRaidProg.CastleNathria[name] = {}
--         inspectRaidProg.CastleNathria[name]["LFR"] = GetStatistic(ImprovedInspectTable.CastleNathriaCriteriaID[name]["LFR"]);
--         inspectRaidProg.CastleNathria[name]["Normal"] = GetStatistic(ImprovedInspectTable.CastleNathriaCriteriaID[name]["Normal"]);
--         inspectRaidProg.CastleNathria[name]["Heroic"] = GetStatistic(ImprovedInspectTable.CastleNathriaCriteriaID[name]["Heroic"]);
--         inspectRaidProg.CastleNathria[name]["Mythic"] = GetStatistic(ImprovedInspectTable.CastleNathriaCriteriaID[name]["Mythic"]);
--     end
--     TestPrintMatrix()
-- end



function BuildSanctumTable ()
    EJ_SelectInstance(1193)
    for i = 1, NUM_SANCTUM_BOSSES do
        local name, _, encounterID = EJ_GetEncounterInfoByIndex(i, true)
        inspectRaidProg.Sanctum[name] = {}
        inspectRaidProg.Sanctum[name]["LFR"] = GetStatistic(SanctumOfDominationCriteriaID[name]["LFR"]);
        inspectRaidProg.Sanctum[name]["Normal"] = GetStatistic(SanctumOfDominationCriteriaID[name]["Normal"]);
        inspectRaidProg.Sanctum[name]["Heroic"] = GetStatistic(SanctumOfDominationCriteriaID[name]["Heroic"]);
        inspectRaidProg.Sanctum[name]["Mythic"] = GetStatistic(SanctumOfDominationCriteriaID[name]["Mythic"]);
    end
    TestPrintMatrix()
end

function TestPrintMatrix()
    for bossname, kills in pairs(inspectRaidProg.Sanctum) do
        print(bossname)
        for difficulty, blank in pairs(inspectRaidProg.Sanctum[bossname]) do
            print(difficulty, blank)
        end
    end
end