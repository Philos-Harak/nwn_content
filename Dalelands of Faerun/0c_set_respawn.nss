/*/////////////////////////////////////////////////////////////////////////////////////////////////////
 Script: 0c_set_respawn
 Programmer: Philos
/////////////////////////////////////////////////////////////////////////////////////////////////////
 Action taken script that sets a characters respawn location.
 Param:
 sRespawn_Tag - is the waypoint tag saved to the characters database.
*/////////////////////////////////////////////////////////////////////////////////////////////////////
#include "0i_master"
#include "0i_database"
void main()
{
    string sRespawn, sTeleport;
    object oPC = GetPCSpeaker ();
    sRespawn = GetScriptParam ("sRespawn_Tag");
    json jTArray = GetObjectDatabaseJson (oPC, CHARACTER_TABLE, "teleport");
    jTArray = JsonArrayInsert (jTArray, JsonString (sRespawn), 0);
    SetObjectDatabaseJson (oPC, CHARACTER_TABLE, "teleport", jTArray);
}
