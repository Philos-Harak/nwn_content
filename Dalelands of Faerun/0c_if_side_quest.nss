/*/////////////////////////////////////////////////////////////////////////////////////////////////////
 Script: 0c_if_side_quest
 Programmer: Philos
/////////////////////////////////////////////////////////////////////////////////////////////////////
 Conversation script that checks to see if they have a free quest slot
 and if they are on a quest for this quest giver.

 If they are on less than the max quests and not on a quest for this NPC
 then it also checks to see if they have the variable "0_Quest_Type" = TRUE (1).
*/////////////////////////////////////////////////////////////////////////////////////////////////////

#include "0i_master"

int StartingConditional()
{
    object oPC = GetPCSpeaker ();
    // First check to see if the NPC can give quests.
    if(GetLocalInt (OBJECT_SELF, "0_Quest_Type") == TRUE)
    {
        // ********** Check for Max quest papers.
        int nNumOfQuests;
        string sQuestID;
        string sQuery = "SELECT tag FROM QuestTable WHERE name = @name;";
        sqlquery sql = SqlPrepareQueryCampaign(SERVER_DATABASE, sQuery);
        SqlBindString(sql, "@name", GetName(oPC, TRUE));
        if(SqlStep(sql))  sQuestID = SqlGetString(sql, 0);
        while(sQuestID != "")
        {
            nNumOfQuests++;
            if(SqlStep(sql)) sQuestID = SqlGetString(sql, 0);
            else sQuestID = "";
        }
        if(nNumOfQuests >= MAX_QUESTS) return FALSE;
        else return TRUE;
    }
    return FALSE;
}
