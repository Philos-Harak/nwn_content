/*////////////////////////////////////////////////////////////////////////////////////////////////////
 Script Name: 0e_quest_o_store
 Programmer: Philos
//////////////////////////////////////////////////////////////////////////////////////////////////////
 Runs the script for opening a store near the placeable and checking for a quest.
 Use in onclick
*/////////////////////////////////////////////////////////////////////////////////////////////////////
#include "0i_quest"
void CheckStoreQuest(object oClicker)
{
    object oStore = OBJECT_SELF;
    // Check to see if the quest has already been done on this placeable.
    string sName = RemoveIllegalCharacters(GetName(oClicker));
    if(GetLocalInt(oStore, GetObjectUUID(oClicker) + "_Quest")) return;
    // Check to see if they are on a quest to click on this object.
    string sQuestID = GetQuestIDByPlaceable(OBJECT_SELF, oClicker);
    // If we are on the quest.
    if(sQuestID == "") return;
    // Set the quest done on the placeable.
    SetLocalInt(oStore, GetObjectUUID(oClicker) + "_Quest", TRUE);
    // Increment tasks done.
    string sStateArray = GetServerDatabaseString(oClicker, QUEST_TABLE, "state", sQuestID);
    int nState = StringToInt(GetStringArray(sStateArray, 10, "-")) + 1;
    SetQuestState(oClicker, sQuestID, 10, nState);
    string sQuestArray = GetServerDatabaseString(oClicker, QUEST_TABLE, "quest", sQuestID);
    int nTasks = StringToInt(GetStringArray(sQuestArray, 4, "-"));
    string sMessage = " " + GetName(oStore) + " task " + IntToString(nState) + " completed.";
    QuestUpdate(oClicker, sQuestID, sMessage, TRUE);
    if(nState < nTasks) return;
    string sQuestName = GetStringArray(sQuestArray, 0, "-");
    sMessage = " " + sQuestName + " tasks completed!";
    QuestUpdate(oClicker, sQuestID, sMessage, TRUE);
}

void WaitToOpen(object oClicker, object oObject, object oStore, int i = 0)
{
    //Debug ("0e_quest_o_store", "43", GetName (oClicker) + " to " + GetName (oObject) + " (" + IntToString (iCounter) + ")");
    float fDistance;
    // if we have run this script more than 10 times then exit.
    if(i < 10)
    {
        // Get the distance from the transition
        fDistance = GetDistanceBetween(oClicker, oObject);
        // if its more than 2.5 meters then move them closer and wait.
        if(fDistance > 2.5f)
        {
            // Increase counter and wait another cycle.
            DelayCommand(1.0, WaitToOpen (oClicker, oObject, oStore, ++ i));
        }
        // We are close enough so lets check the store.
        else
        {
            if(GetIsObjectValid(oStore) == TRUE)
            {
                CheckStoreQuest(oClicker);
                OpenStore(oStore, oClicker);
            }
            else SetModuleError("STORE", "0e_quest_o_store", "62", GetName (OBJECT_SELF) + " does not have a store near it!");
        }
    }
}

void main()
{
    object oStore = GetNearestObject(OBJECT_TYPE_STORE);
    object oClicker = GetPlaceableLastClickedBy();
    float fDistance = GetDistanceBetween(oClicker, OBJECT_SELF);
    if(fDistance > 2.5f)
    {
        ActionMoveToObject(OBJECT_SELF, TRUE, 15.0f);
        WaitToOpen(oClicker, OBJECT_SELF, oStore);
    }
    else
    {
        if(oStore != OBJECT_SELF)
        {
            CheckStoreQuest(oClicker);
            OpenStore(oStore, oClicker);
        }
        else SetModuleError("STORE", "0e_quest_o_store", "84", GetName (OBJECT_SELF) + " does not have a store near it!");
    }
}

