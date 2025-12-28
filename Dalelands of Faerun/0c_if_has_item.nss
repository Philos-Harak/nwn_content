/*//////////////////////////////////////////////////////////////////////////////
 Script: 0c_if_has_item
 Programmer: Philos
////////////////////////////////////////////////////////////////////////////////
 Text Appears When script that checks to see if PCSpeaker has the item.
 Param:
 sTag - tag of the item to check.
*///////////////////////////////////////////////////////////////////////////////
#include "0i_quest"
int StartingConditional()
{
    string sQuestTag, sArray, sQuestName;
    object oItem;
    object oPC = GetPCSpeaker ();
    // First check to see if the NPC is looking for a specific item.
    string sItemTag = GetScriptParam("sTag");
    if(sItemTag != "")
    {
        oItem = GetCreatureHasItem(oPC, sItemTag, TRUE);
        if(oItem != OBJECT_INVALID) return TRUE;
        int nIndex;
        for(nIndex = 1; nIndex <= 5; nIndex++)
        {
            oItem = GetCreatureHasItem(oPC, GetScriptParam("sTag" + IntToString(nIndex)));
            if(oItem != OBJECT_INVALID) return TRUE;
        }
    }
    // Now check to see if they have a quest item.
    else
    {
        string sQuestID = GetLocalString(oPC, "0_QUEST_ID");
        if(sQuestID == "") return FALSE;
        if(GetHasQuestItem(oPC, sQuestID)) return TRUE;
    }
    return FALSE;
}
