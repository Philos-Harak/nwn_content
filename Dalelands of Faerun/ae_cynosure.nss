/*/////////////////////////////////////////////////////////////////////////////////////////////////////
 Script Name: ae_cynosure
 Programmer: Philos
//////////////////////////////////////////////////////////////////////////////////////////////////////
 Event script that runs on_enter for area Cynosure.
 - Adds up each time they jump to Cynosure and saves to db for character.
*/////////////////////////////////////////////////////////////////////////////////////////////////////
#include "0i_master"
#include "0i_database"
void main()
{
    if (GetIsCharacter (OBJECT_SELF))
    {
        IncreaseServerDatabaseCounter (OBJECT_SELF, PLAYER_TABLE, "cynosurejumps");
        IncreaseObjectDatabaseCounter (OBJECT_SELF, CHARACTER_TABLE, "cynosurejumps");
    }
}

