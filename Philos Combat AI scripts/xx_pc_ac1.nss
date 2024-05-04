/*//////////////////////////////////////////////////////////////////////////////
 Script: nw_ch_ac1
 Programmer: Philos
////////////////////////////////////////////////////////////////////////////////
  Associate(Summons, Familiar, Companion) OnHeart beat script when out of combat;
  This will usually fire every 6 seconds (1 game round).
  An area must have the variable Int: "AI_CIVILIZED_AREA" set to TRUE if using
  the NPC pickup treasure system and you don't want them to loot the area.
*///////////////////////////////////////////////////////////////////////////////
//#include "0i_associates"
#include "0i_assoc_debug"
#include "nw_i0_generic"
void ai_ContinueAssociateRetrievingItems(object oCreature);
int ai_AssociateRetrievingItems(object oCreature);
void main()
{
    object oCreature = OBJECT_SELF;
    //ai_Debug("nw_ch_ac1", "17", GetName(oCreature) + " Heartbeat out of combat." +
    //       " MODE_FOLLOW: " + IntToString(ai_GetAssociateMode(oCreature, AI_MODE_FOLLOW)) +
    //       " Searching: " + IntToString(GetLocalInt(oCreature, AI_AM_I_SEARCHING)));
    if(ai_GetIsBusy(oCreature) || ai_Disabled(oCreature)) return;
    // Seek out and disable traps.
    object oTrap = GetNearestTrapToObject();
    if(oTrap != OBJECT_INVALID && ai_AttemptToDisarmTrap(oCreature, oTrap)) return;
    if(ai_AssociateRetrievingItems(oCreature)) return;
    if(ai_GetAssociateMode(oCreature, AI_MODE_SCOUT_AHEAD))
    {
        ai_ScoutAhead(oCreature);
        return;
    }
}
int ai_ShouldIPickItUp(object oCreature, object oItem)
{
    if(ai_GetAssociateMode(oCreature, AI_MODE_PICKUP_GEMS_ITEMS))
    {
        if(GetBaseItemType(oItem) == BASE_ITEM_GEM) return TRUE;
        if(ai_GetNumberOfProperties(oItem) > 0) return TRUE;
        return FALSE;
    }
    if(ai_GetAssociateMode(oCreature, AI_MODE_PICKUP_MAGIC_ITEMS))
    {
        if(ai_GetNumberOfProperties(oItem) > 0) return TRUE;
        return FALSE;
    }
    return TRUE;
}
void ai_SearchObject(object oCreature, object oObject, object oMaster, int nAssociateType)
{
    AssignCommand(oObject, ActionWait(1.25f));
    AssignCommand(oObject, ActionPlayAnimation(ANIMATION_PLACEABLE_CLOSE));
    int nItemType, nGold;
    object oItem = GetFirstItemInInventory(oObject);
    //ai_Debug("nw_ch_ac1", "123", "Found: " + GetName(oItem) + " ResRef: " + GetResRef(oItem) +
    //         " in " + GetName(oObject));
    while(oItem != OBJECT_INVALID)
    {
       //ai_Debug("nw_ch_ac1", "127", "Found: " + GetName(oItem) + " ResRef: " + GetResRef(oItem));
       if(GetResRef(oItem) == "nw_it_gold001")
       {
            nGold = GetNumStackedItems(oItem);
            GiveGoldToCreature(oMaster, nGold);
            DestroyObject(oItem);
       }
       else if(ai_ShouldIPickItUp(oCreature, oItem))
       {
           if(nAssociateType == ASSOCIATE_TYPE_HENCHMAN) ActionTakeItem(oItem, oObject);
           else AssignCommand(oObject, ActionGiveItem(oItem, oMaster));
       }
       oItem = GetNextItemInInventory(oObject);
    }
    string sAssociateName = ai_RemoveIllegalCharacters(GetName(oCreature));
    SetLocalInt(oObject, "AI_LOOTED_" + sAssociateName, TRUE);
    DelayCommand(0.5, ai_ContinueAssociateRetrievingItems(oCreature));
}
int ai_IsContainerLootable(object oCreature, object oObject, string sAssociateName)
{
    //ai_Debug("nw_ch_ac1", "162", GetName(oObject) + " (sTag " + GetTag(oObject) + ") " +
    //         "has inventory: " + IntToString(GetHasInventory(oObject)) + " Has been looted: " +
    //           IntToString(GetLocalInt(oObject, "AI_LOOTED_" + sAssociateName)));
    if(!GetHasInventory(oObject)) return FALSE;
    // This associate has already looted this object, skip.
    if(GetLocalInt(oObject, "AI_LOOTED_" + sAssociateName) ||
       ai_GetIsCharacter(oObject)) return FALSE;
    if(GetTrapDetectedBy(oObject, oCreature))
    {
        if(!GetLocalInt(oObject, "AI_TRAP_SEEN_" + sAssociateName))
        {
            PlayVoiceChat(VOICE_CHAT_STOP, oCreature);
            SpeakString("That " + GetName(oObject) + " is trapped!");
            SetLocalInt(oObject, "AI_TRAP_SEEN_" + sAssociateName, TRUE);
        }
        if(ai_GetAssociateMode(oCreature, AI_MODE_DISARM_TRAPS) &&
           !GetLocalInt(oObject, "AI_TRAP_DISARM_" + sAssociateName))
        {
           SetLocalInt(oObject, "AI_TRAP_DISARM_" + sAssociateName, TRUE);
           if(ai_AttemptToDisarmTrap(oCreature, oObject, TRUE)) return 2;
        }
        return FALSE;
    }
    else if(GetLocked(oObject))
    {
        if(!GetLocalInt(oObject, "AI_SEE_LOCK_" + sAssociateName))
        {
            SpeakString("That " + GetName(oObject) + " is locked!");
            SetLocalInt(oObject, "AI_SEE_LOCK_" + sAssociateName, TRUE);
            SetLocalInt(oObject, "AI_LOOTED_" + sAssociateName, TRUE);
        }
        if(ai_GetAssociateMode(oCreature, AI_MODE_OPEN_LOCKS) &&
           ai_AttemptToByPassLock(oCreature, oObject)) return 2;
        return FALSE;
    }
    return TRUE;
}
void ai_ContinueAssociateRetrievingItems(object oCreature)
{
    if(ai_GetIsBusy(oCreature)) return;
    location lLocation = GetLocation(oCreature);
    string sAssociateName = ai_RemoveIllegalCharacters(GetName(oCreature));
    object oMaster = GetMaster();
    int nAction, nAssociateType = GetAssociateType(oCreature);
    // Fix for AI to be used on a player.
    if(oMaster == OBJECT_INVALID)
    {
        oMaster = oCreature;
        nAssociateType = ASSOCIATE_TYPE_HENCHMAN;
    }
    int nIndex = 1;
    object oObject = GetNearestObject(OBJECT_TYPE_PLACEABLE, oCreature, nIndex);
    while(oObject != OBJECT_INVALID && GetDistanceBetween(oCreature, oObject) < AI_LOOT_DISTANCE)
    {
        nAction = ai_IsContainerLootable(oCreature, oObject, sAssociateName);
        if(nAction == TRUE)
        {
            ai_ClearCreatureActions(oCreature);
            ActionMoveToObject(oObject, TRUE, 1.0f);
            DoPlaceableObjectAction(oObject, PLACEABLE_ACTION_USE);
            ActionDoCommand(ai_SearchObject(oCreature, oObject, oMaster, nAssociateType));
            return;
        }
        if(nAction == 2) return;
        oObject = GetNearestObject(OBJECT_TYPE_PLACEABLE, oCreature, ++nIndex);
    }
}
int ai_AssociateRetrievingItems(object oCreature)
{
    if(!ai_GetAssociateMode(oCreature, AI_MODE_PICKUP_ITEMS)) return FALSE;
    int nAction, nAssociateType = GetAssociateType(oCreature);
    string sAssociateName = ai_RemoveIllegalCharacters(GetName(oCreature));
    object oMaster = GetMaster();
    // Fix for AI to be used on a player.
    if(oMaster == OBJECT_INVALID)
    {
        oMaster = oCreature;
        nAssociateType = ASSOCIATE_TYPE_HENCHMAN;
    }
    int nIndex = 1;
    object oObject = GetNearestObject(OBJECT_TYPE_PLACEABLE, oCreature, nIndex);
    while(oObject != OBJECT_INVALID && GetDistanceBetween(oCreature, oObject) < AI_LOOT_DISTANCE)
    {
        nAction = ai_IsContainerLootable(oCreature, oObject, sAssociateName);
        if(nAction == TRUE)
        {
            ai_ClearCreatureActions(oCreature);
            ActionMoveToObject(oObject, TRUE, 1.0f);
            DoPlaceableObjectAction(oObject, PLACEABLE_ACTION_USE);
            ActionDoCommand(ai_SearchObject(oCreature, oObject, oMaster, nAssociateType));
            return TRUE;
        }
        if(nAction == 2) return TRUE;
        oObject = GetNearestObject(OBJECT_TYPE_PLACEABLE, oCreature, ++nIndex);
    }
    return FALSE;
}





