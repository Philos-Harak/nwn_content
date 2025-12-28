/*////////////////////////////////////////////////////////////////////////////////////////////////////
 Script Name: 0e_oo_unlock_b
 Programmer: Philos
//////////////////////////////////////////////////////////////////////////////////////////////////////
 Event script that runs before a creature tries to unlock a door or placeable.
*/////////////////////////////////////////////////////////////////////////////////////////////////////
#include "nwnx_events"
#include "0i_character"
void main()
{
    object oPC = OBJECT_SELF;
    if (!GetIsCharacter (oPC)) return;
    // Get the object they are unlocking.
    object oObject = StringToObject (NWNX_Events_GetEventData ("DOOR"));
    // Check to see if they have a tool.
    object oItem = StringToObject (NWNX_Events_GetEventData ("THIEVES_TOOL"));
    if (!GetIsObjectValid (oItem) && !GetIsDungeonMaster (oPC))
    {
        FloatingTextStringOnCreature ("You must use thieves tools to unlock this " + GetName (oObject) + "!", oPC, FALSE);
        NWNX_Events_SkipEvent ();
    }
}

