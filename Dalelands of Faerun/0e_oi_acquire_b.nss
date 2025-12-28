/*////////////////////////////////////////////////////////////////////////////////////////////////////
 Script Name: 0e_oi_acquire_b
 Programmer: Philos
//////////////////////////////////////////////////////////////////////////////////////////////////////
 Event script that runs when a creature aquires an item before picking it up.
 Used to restrict quest items to the binded characters.

 NOTE: This only fires on items not owned by another object.
 i.e. on the ground or given via script!
 See 0e_oi_remove_b for quest items blocked via containers.
*/////////////////////////////////////////////////////////////////////////////////////////////////////
#include "0i_quest"
#include "nwnx_events"
void main()
{
    object oReceiver = OBJECT_SELF;
    // Run this only if it is a player.
    if(GetIsCharacter(oReceiver))
    {
        // Also must take care to not strip items from logging in characters.
        if(!GetLocalInt(oReceiver, "0_Character_Loaded")) return;
        object oItem = StringToObject(NWNX_Events_GetEventData("ITEM"));
        //object oGiver = StringToObject (NWNX_Events_GetEventData ("GIVER"));
        // Lets see if this has been bound to a player yet.
        string sBinded = GetLocalString(oItem, "0_Binded");
        string sQuestID = GetLocalString(oItem, "0_QUEST_ID");
        if(sQuestID != "")
        {
            // Only the quest pc can pickup the quest item.
            if(StripColorCodes(GetName(oReceiver)) == sBinded)
            {
                string sQuestID = GetQuestIDByItem(oItem, oReceiver);
                if(sQuestID != "")
                {
                    if(GetQuestState(oReceiver, sQuestID, 4) == 0) SetQuestState(oReceiver, sQuestID, 4, 1);
                    QuestUpdate(oReceiver, sQuestID, "You have acquired " + GetName(oItem), TRUE);
                }
            }
            else
            {
                SendMessages("This quest item (" + GetName (oItem) + ") belongs to " + sBinded + "! You cannot pick up other players quest items.", COLOR_RED, oReceiver, TRUE, TRUE);
                NWNX_Events_SkipEvent();
            }
        }
    }
    // This is where NPC, monster on aquire event code should go.
    else
    {
    }
}

