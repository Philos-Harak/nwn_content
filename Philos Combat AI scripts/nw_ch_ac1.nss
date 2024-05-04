/*//////////////////////////////////////////////////////////////////////////////
 Script: nw_ch_ac1
 Programmer: Philos
////////////////////////////////////////////////////////////////////////////////
  Associate(Summons, Familiar, Companion) OnHeart beat script when out of combat;
  This will usually fire every 6 seconds (1 game round).
  An area must have the variable Int: "AI_CIVILIZED_AREA" set to TRUE if using
  the NPC pickup treasure system and you don't want them to loot the area.
*///////////////////////////////////////////////////////////////////////////////
#include "0i_associates"
//#include "0i_assoc_debug"
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
    if(ai_GetAssociateMode(oCreature, AI_MODE_STAND_GROUND)) return;
    object oMaster = GetMaster(oCreature);
    // If we don't have a master then we exit.
    if(oMaster == OBJECT_INVALID && !ai_GetIsCharacter(oCreature)) return;
    // If follow mode we do not want the NPC doing anything but follow.
    if(!ai_GetAssociateMode(oCreature, AI_MODE_FOLLOW))
    {
        // Civilized area that we do not want to loot or disarm traps in.
        if(GetLocalInt(GetArea(oCreature), "AI_CIVILIZED_AREA")) return;
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
    // Finally we check to make sure we are following our master.
    if(GetCurrentAction(oCreature) != ACTION_FOLLOW &&
       !GetLocalInt(oCreature, AI_AM_I_SEARCHING))
    {
       // Follow master.
       if(GetDistanceBetween(oCreature, oMaster) > ai_GetFollowDistance(oCreature))
       {
           ai_ClearCreatureActions(oCreature);
           //ai_Debug("nw_ch_ac1", "62", "Follow master: " +
           //         " Stealth: " + IntToString(ai_GetAssociateMode(oCreature, AI_MODE_AGGRESSIVE_STEALTH)) +
           //         " Search: " + IntToString(ai_GetAssociateMode(oCreature, AI_MODE_AGGRESSIVE_SEARCH)));
           if(ai_GetAssociateMode(oCreature, AI_MODE_AGGRESSIVE_STEALTH))
           {
              //ai_Debug("nw_ch_ac1_1", "67", "Going into stealth mode!");
              SetActionMode(oCreature, ACTION_MODE_STEALTH, TRUE);
           }
           else if(ai_GetAssociateMode(oCreature, AI_MODE_AGGRESSIVE_SEARCH))
           {
              //ai_Debug("nw_ch_ac1", "72", "Going into search mode!");
              SetActionMode(oCreature, ACTION_MODE_DETECT, TRUE);
           }
           ActionMoveToObject(oMaster, TRUE, ai_GetFollowDistance(oCreature));
       }
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
void ai_TakeItemMessage(object oCreature, object oObject, object oItem, object oMaster)
{
    string sBaseName = GetStringByStrRef(StringToInt(Get2DAString("baseitems", "name", GetBaseItemType(oItem))));
    if(GetSkillRank(SKILL_LORE, oCreature, TRUE) > 0) ai_IdentifyItemVsKnowledge(oCreature, oItem);
    if(GetIdentified(oItem))
    {
        ai_SendMessages(GetName(oCreature) + " has found a " + GetName(oItem) + " from the " + GetName(oObject) + ".", COLOR_GRAY, oMaster, FALSE, TRUE);
    }
    else
    {
       ai_SendMessages(GetName(oCreature) + " has found a " + sBaseName + " from the " + GetName(oObject) + ".", COLOR_GRAY, oMaster, FALSE, TRUE);
    }
    if(GetPlotFlag(oItem))
    {
        if(!ai_GetAssociateMode(oCreature, AI_MODE_DO_NOT_SPEAK)) PlayVoiceChat(VOICE_CHAT_LOOKHERE, oCreature);
    }
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
            ai_SendMessages(GetName(oCreature) + " has retrieved " + IntToString(nGold) + " gold from the " + GetName(oObject) + ".", COLOR_GRAY, oMaster, FALSE, TRUE);
            GiveGoldToCreature(oMaster, nGold);
            DestroyObject(oItem);
       }
       else if(ai_ShouldIPickItUp(oCreature, oItem))
       {
           //ai_Debug("nw_ch_ac1", "138", "Taking: " + GetName(oItem));
           if(nAssociateType == ASSOCIATE_TYPE_HENCHMAN)
           {
               ai_TakeItemMessage(oCreature, oObject, oItem, oMaster);
               ActionTakeItem(oItem, oObject);
           }
           else
           {
               //ai_Debug("nw_ch_ac1", "149", "Giving to master: " + GetName(oItem));
               ai_TakeItemMessage(oCreature, oObject, oItem, oMaster);
               AssignCommand(oObject, ActionGiveItem(oItem, oMaster));
           }
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
