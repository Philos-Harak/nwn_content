/*/////////////////////////////////////////////////////////////////////////////////////////////////////
 Script Name: 0e_closedbchest
 Programmer: Philos
//////////////////////////////////////////////////////////////////////////////////////////////////////
 OnClose event script that closes a persistant chest for the player.
*/////////////////////////////////////////////////////////////////////////////////////////////////////
#include "nwnx_player"
#include "0i_database"
#include "0i_character"
#include "0i_henchmen"
void main()
{
    object oChest = OBJECT_SELF;
    object oPC = GetLastClosedBy();
    string sTag = GetLocalString(oChest, "0_Tag");
    CheckServerDataAndInitialize(oPC, OBJECT_TABLE, sTag);
    SetServerDatabaseObject(oPC, OBJECT_TABLE, oChest, sTag);
    DestroyObject(oChest, 1.0f);
    AssignCommand(oPC, ClearAllActions ());
    SaveCharacterData(oPC, TRUE);
    SaveAssociatesToDatabase(oPC, FALSE);
}

