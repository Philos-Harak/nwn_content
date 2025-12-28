/* /////////////////////////////////////////////////////////////////////////////
 Script: 0c_tool_enc
 Programmer: Philos
////////////////////////////////////////////////////////////////////////////////
 Action Taken script that runs selections for DM Tools.
 Param:
 sInput - a specific selection for DM Tools.
    SaveDMEncounters
    LoadDMEncounters
    RemoveObjectsInArea
    ChangeFaction
    1-10) Summon Monsters from encounter areas 1 - 9.
*///////////////////////////////////////////////////////////////////////////////
#include "0i_database"
#include "0i_area"
#include "x2_inc_switches"
#include "nwnx_creature"
void main()
{
    int nFaction;
    string sFaction;
    object oCreature, oCreatureCopy;
    object oPC = GetPCSpeaker ();
    float fFacing;
    object oNeutralFaction = GetObjectByTag ("neutral_faction");
    location lTarget = GetLocalLocation (oPC, "0_Location_Target");
    string sInput = GetScriptParam ("sInput");
    if (sInput == "SaveDMEncounters") SaveDMEncounters (oPC);
    else if (sInput == "LoadDMEncounters") LoadDMEncounters (oPC);
    else if (sInput == "RemoveObjectsInArea") ClearArea (GetArea (oPC));
    // Summon the encounter.
    // Use sInput as the end string to select the correct waypoint;
    // i.e. Encounter_1 for sInput 1.
    else
    {
        nFaction = GetLocalInt (oPC, "0_Encounter_Faction");
        // Get the encounter using sInput.
        object oWaypoint = GetWaypointByTag ("Encounter_" + sInput);
        location lwaypoint = GetLocation (oWaypoint);
        // Summon the monsters.
        int i = 1;
        // Summon a max of 10 creatures.
        while (i < 11)
        {
            oCreature = GetNearestCreatureToLocation (CREATURE_TYPE_IS_ALIVE, TRUE, lwaypoint, i);
            if (oCreature != OBJECT_INVALID && (GetDistanceBetween (oWaypoint, oCreature) < 5.0))
            {
                oCreatureCopy = CopyObject (oCreature, lTarget);
                if (nFaction < 4) ChangeToStandardFaction (oCreatureCopy, nFaction);
                else ChangeFaction (oCreatureCopy, oNeutralFaction);
                // Check treasure.
                int iType = GetRacialType (oCreatureCopy);
                if (iType != RACIAL_TYPE_ANIMAL &&
                    iType != RACIAL_TYPE_OOZE &&
                    iType != RACIAL_TYPE_VERMIN &&
                    iType != RACIAL_TYPE_MAGICAL_BEAST &&
                    GetCreatureFlag (oCreature, CREATURE_VAR_IS_INCORPOREAL) == FALSE &&
                    GetLocalInt (oCreatureCopy, "0_Multiplier") != -1)
                {
                    RollTreasure (oCreatureCopy);
                }
                SetLocalInt (oCreatureCopy, "0_PermanentFaction", nFaction);
                SetLocalInt (oCreatureCopy, "0_CurrentFaction", nFaction);
                // Set to face the same direction as the DM.
                fFacing = GetFacing (oPC);
                AssignCommand (oCreatureCopy, SetFacing (fFacing));
                //Debug ("83", "0c_encounters", "iFaction " + IntToString (GetLocalInt (oCreatureCopy, "0_PermanentFaction")), FALSE);
            }
            i ++;
        }
    }
}
