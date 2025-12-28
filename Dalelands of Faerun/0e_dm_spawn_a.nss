/*////////////////////////////////////////////////////////////////////////////////////////////////////
 Script Name: 0e_dm_spawn_a
 Programmer: Philos
//////////////////////////////////////////////////////////////////////////////////////////////////////
 Event script that runs when a DM spawns an object (after).
*/////////////////////////////////////////////////////////////////////////////////////////////////////
#include "nwnx_events"
#include "0i_items"
void main()
{
    object oObject = StringToObject (NWNX_Events_GetEventData ("OBJECT"));
    // Tag the placeable as spawned. Used for cleanup scripts and area saving.
    int nObjectType = GetObjectType (oObject);
    if (nObjectType == OBJECT_TYPE_PLACEABLE) SetLocalInt (oObject, "0_Spawned", TRUE);
}

