/*////////////////////////////////////////////////////////////////////////////////////////////////////
// Script Name: 0i_specialevents
//////////////////////////////////////////////////////////////////////////////////////////////////////
    Functions to do check when the server is doing special events!
*/////////////////////////////////////////////////////////////////////////////////////////////////////
// Programmer: Philos
//////////////////////////////////////////////////////////////////////////////////////////////////////
#include "0i_spawn"


// We do 20% chance 1st week, 30% 2nd week, 50% 3rd week.
const int CHANCE_UNDEAD_CHART = 1;
const int CHANCE_SPAWN_GRAVEYARD = 100;

void CreateMist(location lLocation);
void CreateGraveYard(object oArea, location lLocation, string sSeed);

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

void CheckForSpecialEventEncounterChart(object oPC, object oArea, object oWaypoint)
{
    // The Halloween undead event has a % chance to change an encounter chart
    // to undead, lets not burn new players so don't do for level 1 characters!
    if(GetIsAreaInterior(oArea)) return;
    if(GetCharacterLevels(oPC) < 3) return;
    if(d100() <= CHANCE_UNDEAD_CHART && d10() == CHANCE_UNDEAD_CHART)
    {
        SetLocalString(oWaypoint, "0_Encounter_2da", "e_undead");
        SetAreaFog(oPC, oArea);
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
