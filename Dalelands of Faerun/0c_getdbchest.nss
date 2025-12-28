/*/////////////////////////////////////////////////////////////////////////////////////////////////////
 Script Name: 0c_getdbchest
 Programmer: Philos
//////////////////////////////////////////////////////////////////////////////////////////////////////
 Actions taken conversation script that pulls a persistant chest for the player.
 sTag - opens a players uniquely tagged persistant chest.
 sPurchase - give unique tag to create and save new persistant chest.
*/////////////////////////////////////////////////////////////////////////////////////////////////////
#include "nwnx_player"
#include "0i_database"
#include "0i_items"
void main()
{
    string sTag = GetScriptParam ("sTag");
    string sPurchase = GetScriptParam ("sPurchase");
    object oChest, oPC = GetPCSpeaker ();
    object oPlayersHandBook = GetCreatureHasItem (oPC, "players_book");
    // Get location to safely create creatures and objects.
    location lLocation = GetLocation (GetWaypointByTag (WP_CREATURE_SPAWN));
    if (sPurchase != "")
    {
        oChest = CreateObject(OBJECT_TYPE_PLACEABLE, "0_secure_chest", lLocation);
        SetLocalString (oChest, "0_Tag", sPurchase);
        SetLocalInt (oPlayersHandBook, sPurchase, TRUE);
        NWNX_Player_ForcePlaceableInventoryWindow (oPC, oChest);
    }
    else
    {
        oChest = GetServerDatabaseObject (oPC, OBJECT_TABLE, lLocation, OBJECT_INVALID, sTag);
        SetLocalString (oChest, "0_Tag", sTag);
        NWNX_Player_ForcePlaceableInventoryWindow (oPC, oChest);
    }
}

