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
#include "nw_i0_generic"
int ai_AssociateRetrievedItems(object oCreature);
void main()
{
    object oCreature = OBJECT_SELF;
    //ai_Debug("nw_ch_ac1", "16", GetName(oCreature) + " Heartbeat out of combat." +
    //       " MODE_FOLLOW: " + IntToString(ai_GetAssociateMode(oCreature, AI_MODE_FOLLOW)) +
    //       " Searching: " + IntToString(GetLocalInt(oCreature, AI_AM_I_SEARCHING)));
    if(ai_GetIsBusy(oCreature) || ai_Disabled(oCreature)) return;
    if(ai_GetAssociateMode(oCreature, AI_MODE_STAND_GROUND)) return;
    object oMaster = GetMaster(oCreature);
    // If we don't have a master then we may want to do some animations.
    if(oMaster == OBJECT_INVALID)
    {
        if (GetSpawnInCondition(NW_FLAG_AMBIENT_ANIMATIONS) ||
            GetSpawnInCondition(NW_FLAG_AMBIENT_ANIMATIONS_AVIAN) ||
            GetIsEncounterCreature(oCreature))
        {
            PlayMobileAmbientAnimations();
        }
        else if (GetSpawnInCondition(NW_FLAG_IMMOBILE_AMBIENT_ANIMATIONS))
        {
            PlayImmobileAmbientAnimations();
        }
        return;
    }
    // If follow mode we do not want the NPC doing anything but follow.
    if(!ai_GetAssociateMode(oCreature, AI_MODE_FOLLOW))
    {
        // Civilized area that we do not want to loot or disarm traps in.
        if(GetLocalInt(GetArea(oCreature), "AI_CIVILIZED_AREA")) return;
        // Seek out and disable traps.
        object oTrap = GetNearestTrapToObject();
        if(oTrap != OBJECT_INVALID && ai_AttemptToDisarmTrap(oCreature, oTrap)) return;
        if(ai_AssociateRetrievedItems(oCreature)) return;
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
           //ai_Debug("nw_ch_ac1", "60", "Follow master: " +
           //         " Stealth: " + IntToString(ai_GetAssociateMode(oCreature, AI_MODE_AGGRESSIVE_STEALTH)) +
           //         " Search: " + IntToString(ai_GetAssociateMode(oCreature, AI_MODE_AGGRESSIVE_SEARCH)));
           if(ai_GetAssociateMode(oCreature, AI_MODE_AGGRESSIVE_STEALTH))
           {
              //ai_Debug("nw_ch_ac1_1", "65", "Going into stealth mode!");
              SetActionMode(oCreature, ACTION_MODE_STEALTH, TRUE);
           }
           else if(ai_GetAssociateMode(oCreature, AI_MODE_AGGRESSIVE_SEARCH))
           {
              //ai_Debug("nw_ch_ac1", "70", "Going into search mode!");
              SetActionMode(oCreature, ACTION_MODE_DETECT, TRUE);
           }
           ActionMoveToObject(oMaster, TRUE, ai_GetFollowDistance(oCreature));
       }
    }
}
int ai_GetLoot(object oCreature, object oObject)
{
    int bPickItUp = FALSE, bPickedItemUp = FALSE, nItemType;
    int nAssociateType = GetAssociateType(oCreature);
    object oMaster = GetMaster();
    object oItem = GetFirstItemInInventory(oObject);
    while(oItem != OBJECT_INVALID)
    {
       //ai_Debug("nw_ch_ac1", "85", "Looting: " + GetName(oItem));
       if(GetResRef(oItem) == "nw_it_gold001")
       {
          ai_SendMessages(GetName(oCreature) + " has retieved " + IntToString(GetGold(oObject)) + " gold from the " + GetName(oObject)+ ".", COLOR_GRAY, oMaster);
          DelayCommand(0.2f, AssignCommand(oObject, ActionGiveItem(oItem, oMaster)));
          bPickedItemUp = TRUE;
       }
       else if(GetDroppableFlag(oItem) || GetPlotFlag(oItem))
       {
           if(ai_GetAssociateMode(oCreature, AI_MODE_PICKUP_GEMS_ITEMS))
           {
               nItemType = GetBaseItemType(oItem);
               if(nItemType == BASE_ITEM_GEM) bPickItUp = TRUE;
           }
           else if(ai_GetAssociateMode(oCreature, AI_MODE_PICKUP_MAGIC_ITEMS))
           {
              if(ai_GetNumberOfProperties(oItem) > 0) bPickItUp = TRUE;
           }
           else bPickItUp = TRUE;
           if(bPickItUp)
           {
               bPickedItemUp = TRUE;
               if(nAssociateType == ASSOCIATE_TYPE_HENCHMAN) DelayCommand(0.2f, ActionTakeItem(oItem, oObject));
               else DelayCommand(0.2f, AssignCommand(oObject, ActionGiveItem(oItem, oMaster)));
               if(GetSkillRank(SKILL_LORE, oCreature, TRUE) > 0) ai_IdentifyItemVsKnowledge(oCreature, oItem);
               if(GetIdentified(oItem)) ai_SendMessages(GetName(oCreature) + " has found a " + GetName(oItem) + " from the " + GetName(oObject) + ".", COLOR_GRAY, oMaster);
               else
               {
                  string sBaseName = GetStringByStrRef(StringToInt(Get2DAString("baseitems", "name", GetBaseItemType(oItem))));
                  ai_SendMessages(GetName(oCreature) + " has found a " + sBaseName + " from the " + GetName(oObject) + ".", COLOR_GRAY, oMaster);
               }
               if(GetPlotFlag(oItem))
               {
                   if(!ai_GetAssociateMode(oCreature, AI_MODE_DO_NOT_SPEAK)) PlayVoiceChat(VOICE_CHAT_LOOKHERE, oCreature);
               }
           }
       }
       bPickItUp = FALSE;
       oItem = GetNextItemInInventory(oObject);
    }
    return bPickedItemUp;
}
int ai_CheckObjectIsLootable(object oCreature, object oObject, string sAssociateName)
{
    //ai_Debug("nw_ch_ac1", "129", GetName(oObject) + " being checked!" +
    //         " sTag: " + GetTag(oObject) + "Looted? " +
    //           IntToString(GetLocalInt(oObject, "AI_LOOTED_" + sAssociateName)));
    if(!GetHasInventory(oObject)) return FALSE;
    // This associate has already looted this object, skip.
    if(GetLocalInt(oObject, "AI_LOOTED_" + sAssociateName) ||
       ai_GetIsCharacter(oObject)) return FALSE;
    if(GetTrapDetectedBy(oObject, OBJECT_SELF))
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
           ai_AttemptToDisarmTrap(oCreature, oObject, TRUE);
        }
        return FALSE;
    }
    if(GetLocked(oObject))
    {
        if(!GetLocalInt(oObject, "AI_SEE_LOCK_" + sAssociateName))
        {
            SpeakString("That " + GetName(oObject) + " is locked!");
            SetLocalInt(oObject, "AI_SEE_LOCK_" + sAssociateName, TRUE);
        }
        if(ai_GetAssociateMode(oCreature, AI_MODE_OPEN_LOCKS)) ai_AttemptToByPassLock(oCreature, oObject);
        return FALSE;
    }
    return TRUE;
}
int ai_AssociateRetrievedItems(object oCreature)
{
    if(!ai_GetAssociateMode(oCreature, AI_MODE_PICKUP_ITEMS)) return FALSE;
    // Check area for creatures or chests that might have items.
    int nObjectType;
    string sAssociateName = ai_RemoveIllegalCharacters(GetName(oCreature));
    float fDistance = 0.0f;
    location lLocation = GetLocation(oCreature);
    object oObject = GetFirstObjectInShape(SHAPE_SPHERE, AI_RANGE_LONG, lLocation, TRUE, OBJECT_TYPE_PLACEABLE);
    while(oObject != OBJECT_INVALID)
    {
        if(ai_CheckObjectIsLootable(oCreature, oObject, sAssociateName))
        {
            SetLocalInt(oObject, "AI_LOOTED_" + sAssociateName, TRUE);
            ai_ClearCreatureActions(oCreature);
            DoPlaceableObjectAction(oObject, PLACEABLE_ACTION_USE);
            if(ai_GetLoot(oCreature, oObject))
            {
                AssignCommand(oObject, ActionPlayAnimation(ANIMATION_PLACEABLE_CLOSE));
                return TRUE;
            }
        }
        oObject = GetNextObjectInShape(SHAPE_SPHERE, 20.0f, lLocation, TRUE, OBJECT_TYPE_PLACEABLE);
    }
    return FALSE;
}





