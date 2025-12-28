/*////////////////////////////////////////////////////////////////////////////////////////////////////
 Script Name: 0e_ot_disarm_b
 Programmer: Philos
//////////////////////////////////////////////////////////////////////////////////////////////////////
 Event script that runs before a creature tries to disarm a trap.
*/////////////////////////////////////////////////////////////////////////////////////////////////////
#include "nwnx_events"
#include "0i_character"
void main()
{
    object oPC, oItem;
    oPC = OBJECT_SELF;
    if (!GetIsCharacter (oPC)) return;
    // Check to see if they have a tool.
    oItem = GetCreatureHasItem (oPC, "0_thief_tools");
    if (!GetIsObjectValid (oItem) && !GetIsDungeonMaster (oPC))
    {
        FloatingTextStringOnCreature ("You must have thieves tools to disarm traps!", oPC, FALSE);
        NWNX_Events_SkipEvent ();
    }
}

