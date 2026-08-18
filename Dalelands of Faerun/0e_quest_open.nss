/*////////////////////////////////////////////////////////////////////////////////////////////////////
 Script Name: 0e_quest_open
 Programmer: Philos
//////////////////////////////////////////////////////////////////////////////////////////////////////
 OnOpen Event script that runs when a creature opens a treasure map quest chest.

 Used to remove the quest paper once an item is found.
*/////////////////////////////////////////////////////////////////////////////////////////////////////
#include "0i_itemproperty"
#include "0i_quest"
void main()
{
    // Check the items within the chest. If one is a quest item find the player it goes to.
    int nQuality, nBaseItemType, nIndex = 1;
    string sItemQuestID, sDBQuestID, sPlot, sName;
    itemproperty ipProperty;
    object oPC;
    object oChest = OBJECT_SELF;
    object oItem = GetFirstItemInInventory(oChest);
    while(oItem != OBJECT_INVALID)
    {
        sItemQuestID = GetLocalString(oItem, "0_QUEST_ID");
        if(sItemQuestID != "")
        {
            oPC = GetNearestCreature(CREATURE_TYPE_PLAYER_CHAR, PLAYER_CHAR_IS_PC, oChest, nIndex);
            while(oPC != OBJECT_INVALID)
            {
                sDBQuestID = GetQuestIDByItem(oItem, oPC);
                sPlot = GetServerDatabaseString(oPC, QUEST_TABLE, "plot", sDBQuestID);
                if(sDBQuestID != "" && sPlot == "11")
                {
                    IncreaseServerDatabaseCounter(oPC, PLAYER_TABLE, "mapquests");
                    IncreaseObjectDatabaseCounter(oPC, CHARACTER_TABLE, "mapquests");
                    QuestUpdate(oPC, sDBQuestID, "You have found the " + GetName(oItem) + " from your treasure map!", FALSE, FALSE, 0, "gui_quest_done");
                    SaveQuestPaperToPC(oPC, sDBQuestID);
                    DestroyObject(GetLocalObject(oPC, "0_QUEST_PAPER"));
                    DeleteLocalString(oItem, "0_QUEST_ID");
                    DeleteServerDatabaseObject(oPC, QUEST_TABLE, sDBQuestID);
                    DeleteLocalObject(oPC, "0_QUEST_PAPER");
                }
                oPC = GetNearestCreature(CREATURE_TYPE_PLAYER_CHAR, PLAYER_CHAR_IS_PC, oChest, ++nIndex);
            }
        }
        oItem = GetNextItemInInventory(oChest);
    }
}
