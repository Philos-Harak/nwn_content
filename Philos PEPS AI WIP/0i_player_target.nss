/*//////////////////////////////////////////////////////////////////////////////
// Script Name: 0i_player_target
////////////////////////////////////////////////////////////////////////////////
 Include script for handling player targeting functions.

*///////////////////////////////////////////////////////////////////////////////
#include "0i_associates"
// Setup an AI OnPlayerTarget Event script while allowing any module onplayer
// target event script to still work.
void ai_SetupPlayerTarget(object oCreature);
// Selects a target for oAssocite to follow.
void ai_AllSelectTarget(object oPC, object oAssociate, object oTarget);
// Removes the Cutscene ghosts and variables from all associates. For original AI scripts.
void ai_OriginalRemoveAllActionMode(object oPC);
// Removes the Cutscene ghosts and Command mode from all associates.
void ai_RemoveAllActionMode(object oPC);
// Once a trap has been selected from the associates inventory move to placing the trap.
void ai_SelectTrap(object oPC, object oAssociate, object oItem);
// Place the selected trap at the location selected by the player for OBJECT_SELF.
void ai_PlaceTrap(object oPC, location lLocation);

void ai_SetupPlayerTarget(object oCreature)
{
    object oModule = GetModule();
    string sModuleTargetEvent = GetEventScript(oModule, EVENT_SCRIPT_MODULE_ON_PLAYER_TARGET);
    if(sModuleTargetEvent != "")
    {
        if(sModuleTargetEvent != "0e_player_target") SetLocalString(oModule, AI_MODULE_TARGET_EVENT, sModuleTargetEvent);
    }
    SetEventScript(oModule, EVENT_SCRIPT_MODULE_ON_PLAYER_TARGET, "0e_player_target");
}
void ai_OriginalActionAssociate(object oPC, object oTarget, location lLocation)
{
    object oAssociate = OBJECT_SELF;
    if(!GetLocalInt(oAssociate, sGhostModeVarname) && GetLocalInt(oPC, sGhostModeVarname))
    {
        effect eGhost = EffectCutsceneGhost();
        ApplyEffectToObject(DURATION_TYPE_PERMANENT, eGhost, oAssociate);
        SetLocalInt(oAssociate, sGhostModeVarname, TRUE);
    }
    int nObjectType = GetObjectType(oTarget);
    ai_ClearCreatureActions(TRUE);
    if(oTarget == GetArea(oPC))
    {
        ActionMoveToLocation(lLocation, TRUE);
        if(GetLocalObject(oPC, AI_FOLLOW_TARGET) == oAssociate)
        {
            float fFollowDistance = 3.0;
            AssignCommand(oPC, ai_ClearCreatureActions());
            AssignCommand(oPC, ActionForceFollowObject(oAssociate, fFollowDistance));
        }
    }
    else if(nObjectType == OBJECT_TYPE_CREATURE)
    {
        if(oTarget != GetLocalObject(oPC, AI_TARGET_ASSOCIATE))
        {
            if(GetMaster(oTarget) == oPC)
            {
                SetLocalString(oPC, AI_TARGET_MODE, "ASSOCIATE_ACTION");
                SetLocalObject(oPC, AI_TARGET_ASSOCIATE, oTarget);
                ai_SendMessages(GetName(oTarget) + " is now in Action Mode.", AI_COLOR_YELLOW, oPC);
            }
            else ActionMoveToObject(oTarget, TRUE);
        }
    }
    else if(nObjectType == OBJECT_TYPE_DOOR)
    {
        if(GetIsTrapped(oTarget) && GetAssociateState(NW_ASC_DISARM_TRAPS, oAssociate))
        {
            if(GetTrapDetectedBy(oTarget, oPC)) SetTrapDetectedBy(oTarget, oAssociate);
            if(GetTrapDetectedBy(oTarget, oAssociate))
            {
                bkAttemptToDisarmTrap(oTarget);
                EnterTargetingMode(oPC, OBJECT_TYPE_ALL, MOUSECURSOR_ACTION, MOUSECURSOR_NOWALK);
                return;
            }
            else if(GetLocked(oTarget)) bkAttemptToOpenLock(oTarget);
        }
        if(GetIsOpen(oTarget))
        {
            ActionCloseDoor(oTarget, TRUE);
        }
        else ActionOpenDoor(oTarget, TRUE);
    }
    else if(nObjectType == OBJECT_TYPE_ITEM)
    {
        ActionPickUpItem(oTarget);
    }
    else if(nObjectType == OBJECT_TYPE_PLACEABLE)
    {
        ActionMoveToObject(oTarget, TRUE);
        if(GetHasInventory(oTarget))
        {
            if(GetIsTrapped(oTarget) && GetAssociateState(NW_ASC_RETRY_OPEN_LOCKS, oAssociate))
            {
                if(GetTrapDetectedBy(oTarget, oPC)) SetTrapDetectedBy(oTarget, oAssociate);
                if(GetTrapDetectedBy(oTarget, oAssociate))
                {
                    bkAttemptToDisarmTrap(oTarget);
                    EnterTargetingMode(oPC, OBJECT_TYPE_ALL, MOUSECURSOR_ACTION, MOUSECURSOR_NOWALK);
                    return;
                }
                if(GetLocked(oTarget))
                {
                    if(GetAssociateState(NW_ASC_RETRY_OPEN_LOCKS, oAssociate))
                    {
                        bkAttemptToOpenLock(oTarget);
                    }
                    else AssignCommand(oAssociate, SpeakString("This " + GetName(oTarget) + " is locked!"));
                    EnterTargetingMode(oPC, OBJECT_TYPE_ALL, MOUSECURSOR_ACTION, MOUSECURSOR_NOWALK);
                    return;
                }
                DoPlaceableObjectAction(oTarget, PLACEABLE_ACTION_USE);
            }
            else if(GetLocked(oTarget))
            {
                if(GetAssociateState(NW_ASC_RETRY_OPEN_LOCKS, oAssociate))
                {
                    bkAttemptToOpenLock(oTarget);
                }
                else AssignCommand(oAssociate, SpeakString("This " + GetName(oTarget) + " is locked!"));
                EnterTargetingMode(oPC, OBJECT_TYPE_ALL, MOUSECURSOR_ACTION, MOUSECURSOR_NOWALK);
                return;
            }
            DoPlaceableObjectAction(oTarget, PLACEABLE_ACTION_USE);
        }
        DoPlaceableObjectAction(oTarget, PLACEABLE_ACTION_USE);
    }
    else if(nObjectType == OBJECT_TYPE_TRIGGER)
    {
        if(GetIsTrapped(oTarget) && GetAssociateState(NW_ASC_RETRY_OPEN_LOCKS, oAssociate))
        {
            if(GetTrapDetectedBy(oTarget, oPC)) SetTrapDetectedBy(oTarget, oAssociate);
            if(GetTrapDetectedBy(oTarget, oAssociate)) bkAttemptToDisarmTrap(oTarget);
        }
    }
    EnterTargetingMode(oPC, OBJECT_TYPE_ALL, MOUSECURSOR_ACTION, MOUSECURSOR_NOWALK);
}
void ai_OriginalActionAllAssociates(object oPC, object oTarget, location lLocation)
{
    object oAssociate;
    int nIndex;
    for(nIndex = 1; nIndex <= AI_MAX_HENCHMAN; nIndex++)
    {
       oAssociate = GetAssociate(ASSOCIATE_TYPE_HENCHMAN, oPC, nIndex);
       if(oAssociate != OBJECT_INVALID) AssignCommand(oAssociate, ai_OriginalActionAssociate(oPC, oTarget, lLocation));
    }
    for(nIndex = 2; nIndex < 6; nIndex++)
    {
        oAssociate = GetAssociate(nIndex, oPC);
        if(oAssociate != OBJECT_INVALID) AssignCommand(oAssociate, ai_OriginalActionAssociate(oPC, oTarget, lLocation));
    }
}
void ai_ActionAssociate(object oPC, object oTarget, location lLocation)
{
    object oAssociate = OBJECT_SELF;
    if(!GetLocalInt(oAssociate, sGhostModeVarname) && ai_GetAIMode(oPC, AI_MODE_GHOST))
    {
        effect eGhost = EffectCutsceneGhost();
        ApplyEffectToObject(DURATION_TYPE_PERMANENT, eGhost, oAssociate);
        SetLocalInt(oAssociate, sGhostModeVarname, TRUE);
    }
    int nObjectType = GetObjectType(oTarget);
    ai_SetAIMode(oAssociate, AI_MODE_COMMANDED, TRUE);
    ai_ClearCreatureActions(TRUE);
    if(oTarget == GetArea(oPC))
    {
        ActionMoveToLocation(lLocation, TRUE);
        if(GetLocalObject(oPC, AI_FOLLOW_TARGET) == oAssociate)
        {
            float fFollowDistance = ai_GetFollowDistance(oPC);
            if(GetDistanceBetween(oAssociate, oPC) <= fFollowDistance)
            {
                DelayCommand(fFollowDistance, AssignCommand(oPC, ActionMoveToObject(oAssociate, TRUE, fFollowDistance)));
            }
            else AssignCommand(oPC, ActionMoveToObject(oAssociate, TRUE, fFollowDistance));
        }
    }
    else if(nObjectType == OBJECT_TYPE_CREATURE)
    {
        if(GetIsEnemy(oTarget, oAssociate))
        {
            // This resets a henchmens failed Moral save in combat.
            ai_SetAssociateAIScript(oAssociate);
            if(!ai_GetIsBusy(oAssociate))
            {
                ai_HaveCreatureSpeak(oAssociate, 5, ":0:1:2:3:6:");
                ai_SetCreatureTalents(oAssociate, FALSE);
                ai_DoAssociateCombatRound(oAssociate, oTarget);
            }
            ai_SendMessages(GetName(oAssociate) + " is attacking " + GetName(oTarget), AI_COLOR_RED, oPC);
        }
        else
        {
            ActionMoveToObject(oTarget, TRUE);
        }
    }
    else if(nObjectType == OBJECT_TYPE_DOOR)
    {
        if(GetIsTrapped(oTarget) && ai_GetAIMode(oAssociate, AI_MODE_DISARM_TRAPS))
        {
            if(GetTrapDetectedBy(oTarget, oPC)) SetTrapDetectedBy(oTarget, oAssociate);
            if(GetTrapDetectedBy(oTarget, oAssociate))
            {
                ai_AttemptToDisarmTrap(oAssociate, oTarget, TRUE);
                EnterTargetingMode(oPC, OBJECT_TYPE_ALL, MOUSECURSOR_ACTION, MOUSECURSOR_NOWALK);
                return;
            }
            else if(GetLocked(oTarget)) ai_AttemptToByPassLock(oAssociate, oTarget);
        }
        else if(GetLocked(oTarget)) ai_AttemptToByPassLock(oAssociate, oTarget);
        else if(GetIsOpen(oTarget))
        {
            ActionCloseDoor(oTarget, TRUE);
        }
        else ActionOpenDoor(oTarget, TRUE);
    }
    else if(nObjectType == OBJECT_TYPE_ITEM)
    {
        ActionPickUpItem(oTarget);
    }
    else if(nObjectType == OBJECT_TYPE_PLACEABLE)
    {
        ActionMoveToObject(oTarget, TRUE);
        if(GetHasInventory(oTarget))
        {
            if(GetIsTrapped(oTarget) && ai_GetAIMode(oAssociate, AI_MODE_DISARM_TRAPS))
            {
                if(GetTrapDetectedBy(oTarget, oPC)) SetTrapDetectedBy(oTarget, oAssociate);
                if(GetTrapDetectedBy(oTarget, oAssociate))
                {
                    ai_AttemptToDisarmTrap(oAssociate, oTarget, TRUE);
                    EnterTargetingMode(oPC, OBJECT_TYPE_ALL, MOUSECURSOR_ACTION, MOUSECURSOR_NOWALK);
                    return;
                }
                if(GetLocked(oTarget))
                {
                    if(ai_GetAIMode(oAssociate, AI_MODE_PICK_LOCKS) ||
                       ai_GetAIMode(oAssociate, AI_MODE_BASH_LOCKS))
                    {
                        ai_AttemptToByPassLock(oAssociate, oTarget);
                    }
                    else AssignCommand(oAssociate, SpeakString("This " + GetName(oTarget) + " is locked!"));
                    EnterTargetingMode(oPC, OBJECT_TYPE_ALL, MOUSECURSOR_ACTION, MOUSECURSOR_NOWALK);
                    return;
                }
                DoPlaceableObjectAction(oTarget, PLACEABLE_ACTION_USE);
            }
            else if(GetLocked(oTarget))
            {
                if(ai_GetAIMode(oAssociate, AI_MODE_PICK_LOCKS) ||
                   ai_GetAIMode(oAssociate, AI_MODE_BASH_LOCKS))
                {
                    ai_AttemptToByPassLock(oAssociate, oTarget);
                }
                else AssignCommand(oAssociate, SpeakString("This " + GetName(oTarget) + " is locked!"));
                EnterTargetingMode(oPC, OBJECT_TYPE_ALL, MOUSECURSOR_ACTION, MOUSECURSOR_NOWALK);
                return;
            }
            AssignCommand(oAssociate, ActionDoCommand(ai_SearchObject(oAssociate, oTarget, oPC, GetAssociateType(oAssociate), TRUE)));
        }
        DoPlaceableObjectAction(oTarget, PLACEABLE_ACTION_USE);
    }
    else if(nObjectType == OBJECT_TYPE_TRIGGER)
    {
        if(GetIsTrapped(oTarget) && ai_GetAIMode(oAssociate, AI_MODE_DISARM_TRAPS))
        {
            if(GetTrapDetectedBy(oTarget, oPC)) SetTrapDetectedBy(oTarget, oAssociate);
            if(GetTrapDetectedBy(oTarget, oAssociate)) ai_AttemptToDisarmTrap(oAssociate, oTarget, TRUE);
        }
    }
    EnterTargetingMode(oPC, OBJECT_TYPE_ALL, MOUSECURSOR_ACTION, MOUSECURSOR_NOWALK);
}
void ai_ActionAllAssociates(object oPC, object oTarget, location lLocation)
{
    object oAssociate;
    int nIndex;
    for(nIndex = 1; nIndex <= AI_MAX_HENCHMAN; nIndex++)
    {
       oAssociate = GetAssociate(ASSOCIATE_TYPE_HENCHMAN, oPC, nIndex);
       if(oAssociate != OBJECT_INVALID) AssignCommand(oAssociate, ai_ActionAssociate(oPC, oTarget, lLocation));
    }
    for(nIndex = 2; nIndex < 6; nIndex++)
    {
        oAssociate = GetAssociate(nIndex, oPC);
        if(oAssociate != OBJECT_INVALID) AssignCommand(oAssociate, ai_ActionAssociate(oPC, oTarget, lLocation));
    }
}
void ai_SelectTarget(object oPC, object oAssociate, object oTarget)
{
    string sAssociateType = ai_GetAssociateType(oPC, oAssociate);
    int nToken = NuiFindWindow(oPC, sAssociateType + "_widget");
    float fRange = GetLocalFloat(oAssociate, AI_FOLLOW_RANGE) +
                   StringToFloat(Get2DAString("appearance", "PREFATCKDIST", GetAppearanceType(oAssociate)));
    string sRange = FloatToString(fRange, 0, 0);
    if(oAssociate == oTarget)
    {
        ai_SetAIMode(oAssociate, AI_MODE_FOLLOW, FALSE);
        DeleteLocalObject(oAssociate, AI_FOLLOW_TARGET);
        string sTarget;
        if(ai_GetIsCharacter(oAssociate))
        {
            sTarget = "nobody";
            ai_SendMessages(GetName(oAssociate) + " is not following anyone now!", AI_COLOR_YELLOW, oPC);
        }
        else
        {
            sTarget = GetName(oPC);
            ai_SendMessages(GetName(oAssociate) + " is now following " + sTarget + "!", AI_COLOR_YELLOW, oPC);
        }
        ai_UpdateToolTipUI(oPC, sAssociateType + "_cmd_menu", sAssociateType + "_widget", "btn_follow_target_tooltip", "  " + GetName(oAssociate) + " following " + sTarget + " [" + sRange + " meters]");
    }
    else
    {
        ai_SetAIMode(oAssociate, AI_MODE_FOLLOW, TRUE);
        SetLocalObject(oAssociate, AI_FOLLOW_TARGET, oTarget);
        ai_SendMessages(GetName(oAssociate) + " is now following " + GetName(oTarget) + ".", AI_COLOR_YELLOW, oPC);
        AssignCommand(oAssociate, ActionMoveToObject(oTarget, TRUE, ai_GetFollowDistance(oAssociate)));
        ai_UpdateToolTipUI(oPC, sAssociateType + "_cmd_menu", sAssociateType + "_widget", "btn_follow_target_tooltip", "  " + GetName(oAssociate) + " following " + GetName(oTarget) + " [" + sRange + " meters]");
    }
    aiSaveAssociateAIModesToDb(oPC, oAssociate);
}
void ai_OriginalRemoveAllActionMode(object oPC)
{
    object oAssociate;
    int nIndex;
    for(nIndex = 1; nIndex <= AI_MAX_HENCHMAN; nIndex++)
    {
       oAssociate = GetAssociate(ASSOCIATE_TYPE_HENCHMAN, oPC, nIndex);
       if(oAssociate != OBJECT_INVALID && ai_GetAIMode(oPC, AI_MODE_GHOST))
       {
            ai_RemoveASpecificEffect(oAssociate, EFFECT_TYPE_CUTSCENEGHOST);
            DeleteLocalInt(oAssociate, sGhostModeVarname);
       }
    }
    for(nIndex = 2; nIndex < 6; nIndex++)
    {
        oAssociate = GetAssociate(nIndex, oPC);
        if(oAssociate != OBJECT_INVALID && ai_GetAIMode(oPC, AI_MODE_GHOST))
        {
            ai_RemoveASpecificEffect(oAssociate, EFFECT_TYPE_CUTSCENEGHOST);
            DeleteLocalInt(oAssociate, sGhostModeVarname);
        }
    }
}
void ai_RemoveAllActionMode(object oPC)
{
    object oAssociate;
    int nIndex;
    for(nIndex = 1; nIndex <= AI_MAX_HENCHMAN; nIndex++)
    {
        oAssociate = GetAssociate(ASSOCIATE_TYPE_HENCHMAN, oPC, nIndex);
        if(oAssociate != OBJECT_INVALID)
        {
            if(ai_GetAIMode(oPC, AI_MODE_GHOST))
            {
                ai_RemoveASpecificEffect(oAssociate, EFFECT_TYPE_CUTSCENEGHOST);
                DeleteLocalInt(oAssociate, sGhostModeVarname);
            }
        }
    }
    for(nIndex = 2; nIndex < 6; nIndex++)
    {
        oAssociate = GetAssociate(nIndex, oPC);
        if(oAssociate != OBJECT_INVALID)
        {
            if(ai_GetAIMode(oPC, AI_MODE_GHOST))
            {
                ai_RemoveASpecificEffect(oAssociate, EFFECT_TYPE_CUTSCENEGHOST);
                DeleteLocalInt(oAssociate, sGhostModeVarname);
            }
        }
    }
}
void ai_SelectTrap(object oPC, object oAssociate, object oItem)
{
    if(GetBaseItemType(oItem) != BASE_ITEM_TRAPKIT)
    {
        ai_SendMessages("A trap kit was not selected.", AI_COLOR_YELLOW, oPC);
        return;
    }
    ai_SendMessages("Now select a location to place the trap.", AI_COLOR_YELLOW, oPC);
    SetLocalObject(oAssociate, "AI_TRAP_KIT", oItem);
    SetLocalString(oPC, AI_TARGET_MODE, "ASSOCIATE_PLACE_TRAP");
    OpenInventory(oAssociate, oPC);
    EnterTargetingMode(oPC, OBJECT_TYPE_TILE, MOUSECURSOR_ACTION, MOUSECURSOR_NOWALK);
}
void ai_PlaceTrap(object oPC, location lLocation)
{
    object oItem = GetLocalObject(OBJECT_SELF, "AI_TRAP_KIT");
    itemproperty ipTrap = GetFirstItemProperty(oItem);
    if(GetItemPropertyType(ipTrap) == ITEM_PROPERTY_TRAP)
    {
        ActionUseItemAtLocation(oItem, ipTrap, lLocation);
    }
    else ai_SendMessages("This trap kit does not have a trap property!", AI_COLOR_YELLOW, oPC);
}

