/*//////////////////////////////////////////////////////////////////////////////
 Script: 0c_if_questcheck
 Programmer: Philos
////////////////////////////////////////////////////////////////////////////////
 Text Appears When script that checks a quest type and/or state.
 Param:
 nPlot - Plot of quest to check for.
     blank - skips and does not check for type.
     1 - Destroy Object         5 - Kill creature        9 - Talk to NPC
     2 - Deliver item           6 - Deliver creature     10 - Do X special tasks
     3 - Retrieve item          7 - NPC taken to Finisher
     4 - Retrieve creature      8 - Clear area
 nState/nNotState - state to check for or not that state.
     blank - skips and does not check for state.
     1 - Object Destroyed.      6 - Area found with NPC.
     2 - Villain Killed.        7 - NPC taken to Finisher.
     3 - Creature Killed.       8 - Area Cleared.
     4 - Item Picked up.        9 - Escorted NPC is dead.
     5 - NPC Picked up.         10 - Finished X number of tasks.
*///////////////////////////////////////////////////////////////////////////////
#include "0i_quest"

int StartingConditional()
{
    string sQuestPlot;
    object oPC = GetPCSpeaker ();
    // Get quest saved from 0c_if_q_finisher script.
    string sQuestID = GetLocalString(oPC, "0_QUEST_ID");
    string sQueryPlot = "SELECT plot, state, strref FROM QuestTable WHERE name = @name AND tag = @tag;";
    sqlquery sqlplot = SqlPrepareQueryCampaign(SERVER_DATABASE, sQueryPlot);
    SqlBindString(sqlplot, "@name", GetName(oPC, TRUE));
    SqlBindString(sqlplot, "@tag", sQuestID);
    if(SqlStep(sqlplot)) sQuestPlot = SqlGetString(sqlplot, 0);
    else
    {
        DeleteLocalString(oPC, "0_QUEST_ID");
        return FALSE;
    }
    int bPlot, bState, bNotState;
    string sPlot = GetScriptParam("nPlot");
    // If Plots match or if Plot was not set to be checked.
    if (sQuestPlot == sPlot || sPlot == "") bPlot = TRUE;
    string sQuestState = SqlGetString(sqlplot, 1);
    string sState = GetScriptParam("nState");
    int nState = StringToInt(sState);
    // If the quest state is 1 (Done) or if state was not set to be checked.
    if(GetStringArray(sQuestState, nState, "-") == "1" || sState == "") bState = TRUE;
    // Specific check Plot #2 (Deliver Item)
    else if(sPlot == "2")
    {
        if(GetHasQuestItem(oPC, sQuestID)) bState = TRUE;
        else bState = FALSE;
    }
    // Specific check Plot #6 (Deliver Creature)
    else if(sPlot == "6")
    {
        if(GetIsInQuestFinishArea(oPC, sQuestID)) bState = TRUE;
        else bState = FALSE;
    }
    string sNotState = GetScriptParam("nNotState");
    int nNotState = StringToInt(sNotState);
    if (GetStringArray(sQuestState, nNotState, "-") == "0" || sNotState == "") bNotState = TRUE;
    //Debug ("0c_if_questcheck", "47", "sQuestType:" + sQuestType + " sQuestState:" + sQuestState);
    //Debug ("0c_if_questcheck", "48", "bType:" + IntToString (bType) +
    //                                 " bState:" + IntToString (bState) +
    //                                 " bNotState:" + IntToString (bNotState));
    // Get PC's "the NPC is dead!" reply.
    if(sPlot == "4" && sState == "9")
    {
        int nQuestStrRef = StringToInt(SqlGetString(sqlplot, 2));
        string sQuestText = GetStringByStrRef(nQuestStrRef + 6);
        sQuestText = ParseQuestTextByDatabase(sQuestText, sQuestID, oPC);
        SetCustomToken(506, sQuestText);
    }
    if (bPlot && bState && bNotState)
    {
        DelayCommand(0.0f, SaveQuestPaperToPC(oPC, sQuestID));
        return TRUE;
    }
    DeleteLocalString(oPC, "0_QUEST_ID");
    return FALSE;
}
