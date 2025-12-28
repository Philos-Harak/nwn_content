/*/////////////////////////////////////////////////////////////////////////////////////////////////////
 Script Name: 0e_use_db_chest
 Programmer: Philos
//////////////////////////////////////////////////////////////////////////////////////////////////////
 OnUse Event script that pulls a persistant chest for the player.
*/////////////////////////////////////////////////////////////////////////////////////////////////////
#include "nwnx_player"
#include "0i_database"
void main()
{
    object oPC = GetLastUsedBy ();
    string sTag = GetTag (OBJECT_SELF);
    // Get location to safely create creatures and objects.
    location lLocation = GetLocation (GetWaypointByTag (WP_CREATURE_SPAWN));
    object oChest = GetServerDatabaseObject (oPC, OBJECT_TABLE, lLocation, OBJECT_INVALID, sTag);
    if (oChest == OBJECT_INVALID) oChest = CreateObject(OBJECT_TYPE_PLACEABLE, "0_secure_chest", lLocation);
    SetLocalString (oChest, "0_Tag", sTag);
    NWNX_Player_ForcePlaceableInventoryWindow (oPC, oChest);
}

