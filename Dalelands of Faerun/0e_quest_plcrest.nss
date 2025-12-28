/*////////////////////////////////////////////////////////////////////////////////////////////////////
 Script Name: 0e_quest_plcrest
 Programmer: Philos
//////////////////////////////////////////////////////////////////////////////////////////////////////
 OnClick event that starts a players bed rest if they can rest from a placeable.
 Used for the tutorial quest for resting.
 0_PlaceableRest - sets the resting bonus per character level they get.
    999 = resting in an inn bed where you get all your hitpoints and don't use supplies.
 0_Key_Required - If they must purchase this rest then place a key tag here.
 0_Key_Message - If they do not have the proper key then send this message.
*/////////////////////////////////////////////////////////////////////////////////////////////////////
#include "0i_character"
#include "0i_creature"
#include "0i_quest"
void main ()
{
    string sMessage;
    object oItem, oPC = GetPlaceableLastClickedBy();
    // Check to make sure they are near the object.
    if(GetDistanceBetween(oPC, OBJECT_SELF) > 5.0f) return;
    // Now check to see if they need a key.
    string sKeyRequired = GetLocalString(OBJECT_SELF, "0_Key_Required");
    if(sKeyRequired != "")
    {
        oItem = GetCreatureHasItem(oPC, sKeyRequired);
        // Remove the key and continue.
        if(GetIsObjectValid(oItem)) DestroyObject(oItem);
        // They don't have the proper key to rest.
        else
        {
            // Get the message from the object.
            sMessage = GetLocalString (OBJECT_SELF, "0_Key_Message");
            if(sMessage == "") sMessage = "You need a key to rest here!";
            SendMessages(sMessage, COLOR_RED, oPC, FALSE, FALSE);
            return;
        }
    }
    // Check to see if the quest has already been done on this placeable.
    string sName = RemoveIllegalCharacters(GetName (oPC, TRUE));
    if(!GetLocalInt(OBJECT_SELF, sName + "_Quest"))
    {
        // Check to see if they are on a quest to click on this object.
        string sQuestID = GetQuestIDByPlaceable(OBJECT_SELF, oPC);
        // If we are on the quest.
        if(sQuestID != "")
        {
            // Set the quest done on the placeable.
            SetLocalInt(OBJECT_SELF, sName + "_Quest", TRUE);
            // Increment tasks done.
            string sStateArray = GetServerDatabaseString(oPC, QUEST_TABLE, "state", sQuestID);
            int nState = StringToInt(GetStringArray(sStateArray, 10, "-")) + 1;
            SetQuestState(oPC, sQuestID, 10, nState);
            string sQuestArray = GetServerDatabaseString(oPC, QUEST_TABLE, "quest", sQuestID);
            int nTasks = StringToInt(GetStringArray(sQuestArray, 4, "-"));
            sMessage = " " + GetName(OBJECT_SELF) + " task " + IntToString(nState) + " completed.";
            if(nState >= nTasks)
            {
                string sQuestName = GetStringArray(sQuestArray, 0, "-");
                QuestUpdate(oPC, sQuestID, sMessage, TRUE);
                sMessage = " " + sQuestName + " tasks completed!";
            }
            QuestUpdate(oPC, sQuestID, sMessage, TRUE);
        }
    }
    // Now have the character rest.
    AssignCommand(oPC, ActionRest (TRUE));
}

