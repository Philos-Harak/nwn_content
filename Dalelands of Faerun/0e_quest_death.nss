/*//////////////////////////////////////////////////////////////////////////////
 Script: 0e_quest_death
 Programmer: Philos
////////////////////////////////////////////////////////////////////////////////
 Script that checks to see if an object has been destroyed for a quest.
*///////////////////////////////////////////////////////////////////////////////
#include "0i_quest"
void main()
{
    string sState, sQuestID;
    int i = 1;
    object oArea = GetArea (OBJECT_SELF);
    object oPC = GetObjectInArea (oArea, i, OBJECT_TYPE_CREATURE);
    while (oPC != OBJECT_INVALID)
    {
        // Check for quest start area location.
        sQuestID = GetQuestIDByPlaceable(OBJECT_SELF, oPC);
        if (sQuestID != "")
        {
            // Set State 1 to TRUE (Object Destroyed).
            SetQuestState(oPC, sQuestID, 1, 1);
            // Give feedback!
            QuestUpdate(oPC, sQuestID, GetName (OBJECT_SELF) + " has been destroyed!", TRUE);
        }
        oPC = GetObjectInArea (oArea, ++i, OBJECT_TYPE_CREATURE);
    }
}
