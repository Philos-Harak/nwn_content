/*//////////////////////////////////////////////////////////////////////////////
// Script Name: 0i_player_target
////////////////////////////////////////////////////////////////////////////////
 Include script for handling player targeting functions.

*///////////////////////////////////////////////////////////////////////////////
#include "0i_associates"
#include "0i_menus"
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
// Adds a creature to nGroup for oDM
void ai_AddToGroup(object oDM, object oTarget, int nGroup);
// Has nGroup perform an action based on the selected target or location.
void ai_DMAction(object oDM, object oTarget, location lLocation, int nGroup);
// Get oPC to select a spell target for oAssociate.
void ai_SelectWidgetSpellTarget(object oPC, object oAssociate, string sElem);
// Updates oAssociates widget by destroying the current one and rebuilding.
void ai_UpdateAssociateWidget(object oPC, object oAssociate);

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
    if(!ai_GetAIMode(oAssociate, AI_MODE_COMMANDED))
    {
        ai_SetAIMode(oAssociate, AI_MODE_COMMANDED, TRUE);
        ai_SetAIMode(oAssociate, AI_MODE_SCOUT_AHEAD, FALSE);
        ai_SetAIMode(oAssociate, AI_MODE_DEFEND_MASTER, FALSE);
        ai_SetAIMode(oAssociate, AI_MODE_STAND_GROUND, FALSE);
        ai_SetAIMode(oAssociate, AI_MODE_FOLLOW, FALSE);
        int nToken = NuiFindWindow(oPC, ai_GetAssociateType(oPC, oAssociate) + AI_WIDGET_NUI);
        ai_HighlightWidgetMode(oPC, oAssociate, nToken);
    }
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
        if(GetIsDead(oTarget))
        {
            AssignCommand(oAssociate, ActionDoCommand(ai_SearchObject(oAssociate, oTarget, oPC, GetAssociateType(oAssociate), TRUE)));
        }
        else if(GetIsEnemy(oTarget, oAssociate))
        {
            // Lock them into attacking this target only.
            SetLocalObject(oAssociate, AI_PC_LOCKED_TARGET, oTarget);
            // This resets a henchmens failed Moral save in combat.
            if(GetLocalString(oAssociate, AI_COMBAT_SCRIPT) == "ai_coward")
            {
                SetLocalString(oAssociate, AI_COMBAT_SCRIPT, GetLocalString(oAssociate, AI_DEFAULT_SCRIPT));
            }
            if(ai_GetIsInCombat(oAssociate)) ai_DoAssociateCombatRound(oAssociate, oTarget);
            else
            {
                ai_HaveCreatureSpeak(oAssociate, 5, ":0:1:2:3:6:");
                ai_SetCreatureTalents(oAssociate, FALSE);
                // Lock them into attacking this target only.
                ai_DoAssociateCombatRound(oAssociate, oTarget);
            }
            ai_SendMessages(GetName(oAssociate) + " is attacking " + GetName(oTarget), AI_COLOR_RED, oPC);
        }
        else
        {
            ActionMoveToObject(oTarget, TRUE);
            // Player will be stuck with this variable if they are not using the AI.
            DeleteLocalInt(oTarget, "AI_I_AM_BEING_HEALED");
            ActionDoCommand(ai_ActionTryHealing(oAssociate, oTarget));
        }
    }
    else if(nObjectType == OBJECT_TYPE_DOOR)
    {
        if(GetIsTrapped(oTarget) && ai_GetAIMode(oAssociate, AI_MODE_DISARM_TRAPS))
        {
            if(GetTrapDetectedBy(oTarget, oPC)) SetTrapDetectedBy(oTarget, oAssociate);
            if(GetTrapDetectedBy(oTarget, oAssociate))
            {
                ai_ReactToTrap(oAssociate, oTarget, TRUE);
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
                    ai_ReactToTrap(oAssociate, oTarget, TRUE);
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
            ActionDoCommand(ai_SearchObject(oAssociate, oTarget, oPC, GetAssociateType(oAssociate), TRUE));
        }
        DoPlaceableObjectAction(oTarget, PLACEABLE_ACTION_USE);
    }
    else if(nObjectType == OBJECT_TYPE_TRIGGER)
    {
        if(GetIsTrapped(oTarget) && ai_GetAIMode(oAssociate, AI_MODE_DISARM_TRAPS))
        {
            if(GetTrapDetectedBy(oTarget, oPC)) SetTrapDetectedBy(oTarget, oAssociate);
            if(GetTrapDetectedBy(oTarget, oAssociate)) ai_ReactToTrap(oAssociate, oTarget, TRUE);
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
void ai_SelectFollowTarget(object oPC, object oAssociate, object oTarget)
{
    string sAssociateType = ai_GetAssociateType(oPC, oAssociate);
    int nToken = NuiFindWindow(oPC, sAssociateType + AI_WIDGET_NUI);
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
        ai_UpdateToolTipUI(oPC, sAssociateType + AI_COMMAND_NUI, sAssociateType + AI_WIDGET_NUI, "btn_follow_target_tooltip", "  " + GetName(oAssociate) + " following " + sTarget + " [" + sRange + " meters]");
    }
    else
    {
        ai_SetAIMode(oAssociate, AI_MODE_FOLLOW, TRUE);
        SetLocalObject(oAssociate, AI_FOLLOW_TARGET, oTarget);
        ai_SendMessages(GetName(oAssociate) + " is now following " + GetName(oTarget) + ".", AI_COLOR_YELLOW, oPC);
        AssignCommand(oAssociate, ActionMoveToObject(oTarget, TRUE, ai_GetFollowDistance(oAssociate)));
        ai_UpdateToolTipUI(oPC, sAssociateType + AI_COMMAND_NUI, sAssociateType + AI_WIDGET_NUI, "btn_follow_target_tooltip", "  " + GetName(oAssociate) + " following " + GetName(oTarget) + " [" + sRange + " meters]");
    }
    aiSaveAssociateModesToDb(oPC, oAssociate);
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
void ai_AddToGroup(object oDM, object oTarget, int nGroup)
{
    string sGroup = IntToString(nGroup);
    if(oDM == oTarget)
    {
        ai_SendMessages("Group" + sGroup + " has been cleared.", AI_COLOR_YELLOW, oDM);
        NuiSetBind(oDM, NuiFindWindow(oDM, "dm" + AI_WIDGET_NUI), "btn_cmd_group" + sGroup + "_tooltip", JsonString("Group" + sGroup));
        DeleteLocalJson(oDM, "DM_GROUP" + sGroup);
        return;
    }
    string sName = GetName(oTarget);
    json jGroup = GetLocalJson(oDM, "DM_GROUP" + sGroup);
    if(JsonGetType(jGroup) == JSON_TYPE_NULL)
    {
        string sText = sName + "'s group";
        NuiSetBind(oDM, NuiFindWindow(oDM, "dm" + AI_WIDGET_NUI), "btn_cmd_group" + sGroup + "_tooltip", JsonString(sText));
        jGroup = JsonArray();
    }
    string sUUID = GetObjectUUID(oTarget);
    JsonArrayInsertInplace(jGroup, JsonString(sUUID));
    ai_SendMessages(sName + " has been saved to group" + sGroup, AI_COLOR_YELLOW, oDM);
    SetLocalJson(oDM, "DM_GROUP" + sGroup, jGroup);
    EnterTargetingMode(oDM, OBJECT_TYPE_CREATURE, MOUSECURSOR_PICKUP, MOUSECURSOR_PICKUP_DOWN);
}
void ai_MonsterAction(object oPC, object oTarget, location lLocation)
{
    object oCreature = OBJECT_SELF;
    int nObjectType = GetObjectType(oTarget);
    ai_ClearCreatureActions(TRUE);
    if(oTarget == GetArea(oPC))
    {
        ActionMoveToLocation(lLocation, FALSE);
    }
    else if(nObjectType == OBJECT_TYPE_CREATURE)
    {
        if(GetIsDead(oTarget)) return;
        else if(GetIsEnemy(oTarget, oCreature))
        {
            // Lock them into attacking this target only.
            SetLocalObject(oCreature, AI_PC_LOCKED_TARGET, oTarget);
            // This resets a creatures failed Moral save in combat.
            if(GetLocalString(oCreature, AI_COMBAT_SCRIPT) == "ai_coward")
            {
                SetLocalString(oCreature, AI_COMBAT_SCRIPT, GetLocalString(oCreature, AI_DEFAULT_SCRIPT));
            }
            if(ai_GetIsInCombat(oCreature)) ai_DoMonsterCombatRound(oCreature);
            else
            {
                ai_HaveCreatureSpeak(oCreature, 5, ":0:1:2:3:6:");
                ai_SetCreatureTalents(oCreature, FALSE);
                ai_DoAssociateCombatRound(oCreature, oTarget);
            }
            ai_SendMessages(GetName(oCreature) + " is attacking " + GetName(oTarget), AI_COLOR_RED, oPC);
        }
        else
        {
            ActionMoveToObject(oTarget, TRUE);
            // Player will be stuck with this variable if they are not using the AI.
            DeleteLocalInt(oTarget, "AI_I_AM_BEING_HEALED");
            ActionDoCommand(ai_ActionTryHealing(oCreature, oTarget));
        }
    }
    else if(nObjectType == OBJECT_TYPE_DOOR)
    {
        if(GetIsTrapped(oTarget))
        {
            if(GetTrapDetectedBy(oTarget, oPC)) SetTrapDetectedBy(oTarget, oCreature);
            if(GetTrapDetectedBy(oTarget, oCreature))
            {
                ai_ReactToTrap(oCreature, oTarget, TRUE);
                EnterTargetingMode(oPC, OBJECT_TYPE_ALL, MOUSECURSOR_ACTION, MOUSECURSOR_NOWALK);
                return;
            }
            else if(GetLocked(oTarget)) ai_AttemptToByPassLock(oCreature, oTarget);
        }
        else if(GetLocked(oTarget)) ai_AttemptToByPassLock(oCreature, oTarget);
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
            if(GetIsTrapped(oTarget))
            {
                if(GetTrapDetectedBy(oTarget, oPC)) SetTrapDetectedBy(oTarget, oCreature);
                if(GetTrapDetectedBy(oTarget, oCreature))
                {
                    ai_ReactToTrap(oCreature, oTarget, TRUE);
                    EnterTargetingMode(oPC, OBJECT_TYPE_ALL, MOUSECURSOR_ACTION, MOUSECURSOR_NOWALK);
                    return;
                }
                if(GetLocked(oTarget))
                {
                    if(!ai_AttemptToByPassLock(oCreature, oTarget))
                    {
                        AssignCommand(oCreature, SpeakString("This " + GetName(oTarget) + " is locked!"));
                    }
                    EnterTargetingMode(oPC, OBJECT_TYPE_ALL, MOUSECURSOR_ACTION, MOUSECURSOR_NOWALK);
                    return;
                }
                DoPlaceableObjectAction(oTarget, PLACEABLE_ACTION_USE);
            }
            else if(GetLocked(oTarget))
            {
                if(ai_AttemptToByPassLock(oCreature, oTarget))
                {
                    AssignCommand(oCreature, SpeakString("This " + GetName(oTarget) + " is locked!"));
                }
                EnterTargetingMode(oPC, OBJECT_TYPE_ALL, MOUSECURSOR_ACTION, MOUSECURSOR_NOWALK);
                return;
            }
            ActionDoCommand(ai_SearchObject(oCreature, oTarget, oPC, GetAssociateType(oCreature), TRUE));
        }
        DoPlaceableObjectAction(oTarget, PLACEABLE_ACTION_USE);
    }
    else if(nObjectType == OBJECT_TYPE_TRIGGER)
    {
        if(GetIsTrapped(oTarget))
        {
            if(GetTrapDetectedBy(oTarget, oPC)) SetTrapDetectedBy(oTarget, oCreature);
            if(GetTrapDetectedBy(oTarget, oCreature)) ai_ReactToTrap(oCreature, oTarget, TRUE);
        }
    }
    EnterTargetingMode(oPC, OBJECT_TYPE_ALL, MOUSECURSOR_ACTION, MOUSECURSOR_NOWALK);
}
void ai_DMAction(object oDM, object oTarget, location lLocation, int nGroup)
{
    string sGroup = IntToString(nGroup);
    json jGroup = GetLocalJson(oDM, "DM_GROUP" + sGroup);
    int nIndex;
    string sUUID = JsonGetString(JsonArrayGet(jGroup, nIndex));
    object oCreature;
    while(sUUID != "")
    {
        oCreature = GetObjectByUUID(sUUID);
        AssignCommand(oCreature, ai_MonsterAction(oDM, oTarget, lLocation));
        sUUID = JsonGetString(JsonArrayGet(jGroup, ++nIndex));
    }
    if(nIndex == 0) ai_SendMessages("Group" + sGroup + " is empty!", AI_COLOR_RED, oDM);
}
void ai_SelectWidgetSpellTarget(object oPC, object oAssociate, string sElem)
{
    int nIndex = StringToInt(GetStringRight(sElem, 1));
    SetLocalInt(oAssociate, "AI_WIDGET_SPELL_INDEX", nIndex);
    string sAssociateType = ai_GetAssociateType(oPC, oAssociate);
    json jAIData = ai_GetAssociateDbJson(oPC, sAssociateType, "aidata");
    json jSpells = JsonArrayGet(jAIData, 10);
    json jWidget = JsonArrayGet(jSpells, 2);
    json jSpell = JsonArrayGet(jWidget, nIndex);
    int nSpell = JsonGetInt(JsonArrayGet(jSpell, 0));
    if(Get2DAString("spells", "Range", nSpell) == "P") // Self
    {
        ai_CastWidgetSpell(oPC, oAssociate, oAssociate, GetLocation(oAssociate));
        DelayCommand(2.0, ai_UpdateAssociateWidget(oPC, oAssociate));
        return;
    }
    string sTarget = Get2DAString("spells", "TargetType", nSpell);
    int nTarget = ai_HexStringToInt(sTarget);
    int nObjectType;
    if(nTarget & 2) nObjectType += OBJECT_TYPE_CREATURE;
    if(nTarget & 4) nObjectType += OBJECT_TYPE_TILE;
    if(nTarget & 8) nObjectType += OBJECT_TYPE_ITEM;
    if(nTarget & 16) nObjectType += OBJECT_TYPE_DOOR;
    if(nTarget & 32) nObjectType += OBJECT_TYPE_PLACEABLE;
    if(nTarget & 64) nObjectType += OBJECT_TYPE_TRIGGER;
    SetLocalObject(oPC, AI_TARGET_ASSOCIATE, oAssociate);
    SetLocalString(oPC, AI_TARGET_MODE, "ASSOCIATE_CAST_SPELL");
    EnterTargetingMode(oPC, nObjectType, MOUSECURSOR_MAGIC, MOUSECURSOR_NOMAGIC);
}
void ai_UpdateAssociateWidget(object oPC, object oAssociate)
{
    int nUIToken = NuiFindWindow(oPC, ai_GetAssociateType(oPC, oAssociate) + AI_WIDGET_NUI);
    NuiDestroy(oPC, nUIToken);
    ai_CreateWidgetNUI(oPC, oAssociate);
}
