/*//////////////////////////////////////////////////////////////////////////////
 Script: 0c_set_tool_enc
 Programmer: Philos
////////////////////////////////////////////////////////////////////////////////
 Text Appears When script that sets the conversations Custom tokens for DM
 encounters.
*///////////////////////////////////////////////////////////////////////////////
#include "0i_creature"
int StartingConditional()
{
    object oCreature, oWaypoint, oPC = GetPCSpeaker ();
    location lTarget = GetSpellTargetLocation ();
    int nFaction = GetLocalInt (oPC, "0_Encounter_Faction");
    SetCustomToken (411, GetFactionName (nFaction));
    // Get monsters at encounter locations and set encounter names based on closest monster.
    int i = 1;
    for (i = 1; i < 11; i++)
    {
        oWaypoint = GetWaypointByTag ("Encounter_" + IntToString (i));
        oCreature = GetNearestCreatureToLocation (CREATURE_TYPE_IS_ALIVE, TRUE, GetLocation(oWaypoint));
        if (GetIsObjectValid (oCreature) && (GetDistanceBetween (oWaypoint, oCreature) < 5.0))
        {
            SetCustomToken (400 + i, GetName (oCreature));
        }
        else SetCustomToken (400 + i, "-----");
    }
    return TRUE;
}
