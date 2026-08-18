/*////////////////////////////////////////////////////////////////////////////////////////////////////
// Script Name: 0i_specialevents
//////////////////////////////////////////////////////////////////////////////////////////////////////
    Functions to do check when the server is doing special events!
*/////////////////////////////////////////////////////////////////////////////////////////////////////
// Programmer: Philos
//////////////////////////////////////////////////////////////////////////////////////////////////////
#include "0i_spawn"
#include "0i_checks"

// We do 20% chance 1st week, 30% 2nd week, 50% 3rd week.
const int CHANCE_UNDEAD_CHART = 1;
const int CHANCE_SPAWN_GRAVEYARD = 100;
// Auril's Winter cold special event!
const int CHANCE_AURIL_CHART = 1;
// Used to track the current year for Auril altars destroyed.
const string AURIL_CURRENT_YEAR = "2026";

// Functions for the Myrkul Halloween Event.
void SetAreaFog(object oPC, object oArea);
void CreateMist(location lLocation);
void CreateGraveYard(object oArea, location lLocation, string sSeed);
// Function to create Auril's Winter Event.
void CreateAurilShrine(object oArea, object oPC);
void CreateAurilVillain(object oPC);

void CheckForSpecialEventEncounterChart(object oPC, object oArea, object oWaypoint)
{
    // The Halloween undead event has a % chance to change an encounter chart
    // to undead, lets not burn new players so don't do for level 1 characters!
    if(GetIsAreaInterior(oArea)) return;
    if(GetCharacterLevels(oPC) < 3) return;
    int nTemp = GetServerDatabaseInt(GetModule(), SERVER_TABLE, "temperature");
    // If it is cold enough we have a chance of a cold chart encounter!
    if(nTemp < 30 && d100() <= CHANCE_AURIL_CHART && d100() == CHANCE_AURIL_CHART)
    {
        string sEncounter = GetLocalString(oWaypoint, "0_Encounter_2da");
        if(sEncounter != "" && sEncounter != "e_auril_cold") SetLocalString(oWaypoint, "0_Original_Encounter_2da", sEncounter);
        SetLocalString(oWaypoint, "0_Encounter_2da", "e_auril_cold");
        CreateAurilShrine(oArea, oPC);
    }
    else if(d100() <= CHANCE_UNDEAD_CHART && d100() == CHANCE_UNDEAD_CHART)
    {
        string sEncounter = GetLocalString(oWaypoint, "0_Encounter_2da");
        if(sEncounter != "" && sEncounter != "e_undead") SetLocalString(oWaypoint, "0_Original_Encounter_2da", sEncounter);
        SetLocalString(oWaypoint, "0_Encounter_2da", "e_undead");
        SetAreaFog(oPC, oArea);
    }
    else
    {
        // Ensure we reset any changed encounter charts.
        string sOriginalEncounter = GetLocalString(oWaypoint, "0_Original_Encounter_2da");
        if(sOriginalEncounter != "")
        {
            SetLocalString(oWaypoint, "0_Encounter_2da", sOriginalEncounter);
            DeleteLocalString(oWaypoint, "0_Original_Encounter_2da");
        }
    }
}
// Creates mist on the ground. x3_plc_mist
void SetAreaFog(object oPC, object oArea)
{
    int nSpawnGraveyard, nIndex = 1;
    object oMist;
    location lLocation;
    // Chance to spawn a graveyard in the area.
    if(d100() < CHANCE_SPAWN_GRAVEYARD) nSpawnGraveyard = d4();
    // Get the area's objects to setup the area.
    object oWaypoint = GetObjectInArea(oArea, nIndex, OBJECT_TYPE_WAYPOINT);
    while(oWaypoint != OBJECT_INVALID)
    {
        int nObjectType = GetObjectType(oWaypoint);
        if(nObjectType == OBJECT_TYPE_WAYPOINT)
        {
            lLocation = GetLocation(oWaypoint);
            DelayCommand(0.0f, CreateMist(lLocation));
            if(GetTag(oWaypoint) == "ip_encounter")
            {
                if(nSpawnGraveyard > 0)
                {
                    nSpawnGraveyard--;
                    if(nSpawnGraveyard == 0)
                    {
                        Debug("0i_specialevents", "42", "Creating graveyard: nSpawnGraveyard: " + IntToString(nSpawnGraveyard));
                        string sSeed = RemoveIllegalCharacters(GetStringLeft(GetName(oPC), 5)) + IntToString(Random(10000));
                        // Instance the area.
                        object oCatacomb = CreateArea("myrkul_catacomb", sSeed);
                        // Set the Waypoint in the Catacombs you jumpto to the correct instanced tag.
                        object oObject = GetObjectInAreaByTag(oCatacomb, "catacomb_to_graveyard", 1, OBJECT_TYPE_WAYPOINT, TRUE);
                        SetTag(oObject, "catacomb_to_graveyard" + sSeed);
                        oObject = GetObjectInAreaByTag(oCatacomb, "portal_return", 1, OBJECT_TYPE_PLACEABLE, TRUE);
                        SetLocalString(oObject, "0_TransitionTag", "catacomb_to_graveyard" + sSeed);
                        // Set the Ladder in the Catacombs transition to the correct instanced tag.
                        oObject = GetObjectInAreaByTag(oCatacomb, "myrkul_ladder", 1, OBJECT_TYPE_PLACEABLE, TRUE);
                        SetLocalString(oObject, "0_TransitionTag", "graveyard_to_catacomb" + sSeed);
                        DelayCommand(0.0f, CreateGraveYard(oArea, lLocation, sSeed));
                        // Generate Villain spawn point.
                        object oVillainWP = CreateObject(OBJECT_TYPE_WAYPOINT, "ip_encounter", lLocation);
                        SetLocalString(oVillainWP, "0_Name", "Minion of Myrkul");
                        SetLocalInt(oVillainWP, "0_Villain", TRUE);
                        SetLocalInt(oVillainWP, "0_Power", TRUE);
                    }
                }
            }
        }
        // Should we spawn a graveyard.
        nIndex ++;
        oWaypoint = GetObjectInArea(oArea, nIndex, OBJECT_TYPE_WAYPOINT);
    }
}
void CreateMist(location lLocation)
{
    object oMist = CreateObject(OBJECT_TYPE_PLACEABLE, "x3_plc_mist", lLocation);
    SetLocalInt(oMist, "0_Spawned", TRUE);
}
void CreateGraveYard(object oArea, location lLocation, string sSeed)
{
    // Make graveyard.
    CreateGroupPlaceable("GRAVEYARD", lLocation);
    // Create entrance to Catacombs
    vector vPos = GetPositionFromLocation(lLocation);
    lLocation = Location(oArea, Vector(vPos.x, vPos.y - 5.0f, vPos.z), 90.0f);
    object oObject = CreateObject(OBJECT_TYPE_PLACEABLE, "0_grave_7", lLocation, FALSE, "graveyard_to_catacomb" + sSeed);
    SetLocalInt(oObject, "0_Spawned", TRUE);
    SetName(oObject, "Cracked Tomb");
    SetDescription(oObject, "The lid to the tomb has been cracked and you should be able to move it and enter!");
    SetLocalString(oObject, "0_TransitionTag", "catacomb_to_graveyard" + sSeed);
    SetUseableFlag(oObject, TRUE);
    SetEventScript(oObject, EVENT_SCRIPT_PLACEABLE_ON_LEFT_CLICK, "0e_transition");
}
void CreateAurilShrine(object oArea, object oPC)
{
    // Get the area's objects to randomly add a shrine to Auril.
    int nIndex = 1, nNumOfWaypoints;
    object oWaypoint = GetObjectInArea(oArea, nIndex, OBJECT_TYPE_WAYPOINT);
    while(oWaypoint != OBJECT_INVALID)
    {
        int nObjectType = GetObjectType(oWaypoint);
        if(nObjectType == OBJECT_TYPE_WAYPOINT)
        {
            if(GetTag(oWaypoint) == "ip_encounter") nNumOfWaypoints++;
        }
        nIndex ++;
        oWaypoint = GetObjectInArea(oArea, nIndex, OBJECT_TYPE_WAYPOINT);
    }
    if(nNumOfWaypoints > 0)
    {
        oWaypoint = GetNearestObjectByTag("ip_encounter", oPC, Random(nNumOfWaypoints) + 1);
        // Create Auril's Shrine
        location lLocation = GetLocation(oWaypoint);
        vector vPos = GetPositionFromLocation(lLocation);
        object oObject = CreateObject(OBJECT_TYPE_PLACEABLE, "0_altar_auril", lLocation);
        SetLocalInt(oObject, "0_Spawned", TRUE);
    }
}
void CreateAurilVillain(object oPC)
{
    object oArea = GetArea(oPC);
    // Get the area's encounter waypoint used for all encounters in area.
    object oWPEncounter = GetObjectInAreaByTag(oArea, "ip_area_level", 1, OBJECT_TYPE_WAYPOINT, TRUE);
    // Get area difficulty level to get the 2da row then add 2 for a boss.
    // Check for CR increase.
    int nLevel = GetCharacterLevels(oPC) + 2;
    if(nLevel < 1) nLevel = 1;
    else if(nLevel > 40) nLevel = 40;
    // Get the 2da encounter to use.
    string sEncounter = GetLocalString(oWPEncounter, "0_Encounter_2da");
    if(sEncounter == "off") return;
    // Calculate row in the 2da (each level gets 5 entries thus ((ilevel - 1) * 5) + Random (5) + 1)
    int nRow = ((nLevel - 1) * 5) + Random (5) + 1;
    // Get the resref of the creature to spawn.
    string sResRef = Get2DAString(sEncounter, "ResRef", nRow);
    // Spawn one boss for the encounter.
    location lLocation = GetLocation(GetWaypointByTag(WP_CREATURE_SPAWN));
    object oCreature = CreateObject(OBJECT_TYPE_CREATURE, sResRef, lLocation);
    // If we have an error find out what type of spawn and report.
    if(!GetIsObjectValid (oCreature)) SetModuleError("RESREF", "0i_specialevents", "185", "Encounter2da (" + sEncounter + ") 2da Row:(" + IntToString (nRow) + ") has an invalid ResRef (" +  sResRef + ")");
    // All villains cannot be dispelled.
    SetLocalInt(oCreature, "0_IMMUNE_TO_DISPEL", TRUE);
    SetLocalInt(oCreature, "0_VILLAIN", TRUE);
    // Color name based on creature CR.
    string sName = ColorVillainName(oCreature, "Champion of Auril");
    SetName(oCreature, sName);
    nLevel = FloatToInt(GetChallengeRating (oCreature));
    if(nLevel > 3) nLevel -= 4;
    if(nLevel > 3) GiveVillianSpecialPower(oCreature, nLevel);
    // Give an additional damage shield based on CR.
    int nDmgType = DAMAGE_TYPE_COLD;
    int nDmgBonus = (nLevel / 4) + 1;
    int nRndDamage = DAMAGE_BONUS_1d4;
    if(nDmgBonus < 3) nRndDamage = DAMAGE_BONUS_1d8;
    if(nDmgBonus < 4) nRndDamage = DAMAGE_BONUS_2d4;
    if(nDmgBonus < 5) nRndDamage = DAMAGE_BONUS_2d8;
    else nRndDamage = DAMAGE_BONUS_2d12;
    int nEffect = VFX_DUR_IOUNSTONE_BLUE;
    effect eEffect = EffectDamageShield (nDmgBonus, nRndDamage, nDmgType);
    effect eVisual = EffectVisualEffect (nEffect);
    eEffect = EffectLinkEffects (eVisual, eEffect);
    ApplyEffectToObject (DURATION_TYPE_PERMANENT, eEffect, oCreature);
    // Set all bosses to use battlecries.
    SetLocalInt(oCreature, "0_Battlecry", TRUE);
    // Slightly increase the size of the boss.
    SetObjectVisualTransform(oCreature, OBJECT_VISUAL_TRANSFORM_SCALE, 1.25f);
    // Random Villains drop a maxamized magic item.
    SetLocalInt(oCreature, "0_MaxNumOfPowers", TRUE);
     // Give villians a base set of items.
    GiveMagicalEquipment(oCreature, FloatToInt(GetChallengeRating(oCreature)));
    SetupCreature(oCreature, OBJECT_INVALID, oPC, TRUE);
    ClearAllActions(TRUE, oCreature);
    lLocation = GetLocation(oPC);
    vector vPos = GetPositionFromLocation(lLocation);
    float fX = -10.0, fY = -10.0;
    if(vPos.x < 10.0) fX + 10.0;
    if(vPos.y < 10.0) fY + 10.0;
    lLocation = Location(oArea, Vector(vPos.x + fX, vPos.y + fY, vPos.z), 0.0);
    effect eSummon = EffectVisualEffect(32, FALSE, 0.0);
    ApplyEffectAtLocation(DURATION_TYPE_INSTANT, eSummon, lLocation);
    DelayCommand(2.0, AssignCommand(oCreature, JumpToLocation(lLocation)));
}
