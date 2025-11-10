/*//////////////////////////////////////////////////////////////////////////////
// Script Name: 0i_player_target
////////////////////////////////////////////////////////////////////////////////
 Include script for handling player targeting functions.

*///////////////////////////////////////////////////////////////////////////////
#include "0i_associates"
#include "0i_menus"
// Setup an AI OnPlayerTarget Event script while allowing any module onplayer
// target event script to still work.
void ai_SetupPlayerTarget();
// Selects a target for oAssocite to follow.
void ai_AllSelectTarget(object oPC, object oAssociate, object oTarget);
// Removes the Cutscene ghosts and Command mode from all associates.
void ai_RemoveAllActionMode(object oPC);
// Once a trap has been selected from the associates inventory move to placing the trap.
void ai_SelectTrap(object oPC, object oAssociate, object oItem);
// Place the selected trap at the location selected by the player for OBJECT_SELF.
void ai_PlaceTrap(object oPC, location lLocation);
// Adds a creature to nGroup for oDM
void ai_AddToGroup(object oDM, object oTarget, string sTargetMode);
// Has nGroup perform an action based on the selected target or location.
void ai_DMAction(object oDM, object oTarget, location lLocation, string sTargetMode);
// Get oPC to select a spell target for oAssociate.
void ai_SelectWidgetSpellTarget(object oPC, object oAssociate, string sElem);
// Updates oAssociates widget by destroying the current one and rebuilding.
void ai_UpdateAssociateWidget(object oPC, object oAssociate);
// Sets oAssociates action mode for nFeat from the quick widget menu
int ai_SetActionMode(object oAssociate, int nFeat);

void ai_EnterAssociateTargetMode(object oPC, object oAssociate)
{
    SetLocalObject(oPC, AI_TARGET_ASSOCIATE, oAssociate);
    SetLocalString(oPC, AI_TARGET_MODE, "ASSOCIATE_ACTION");
    SetLocalInt(oPC, AI_TARGET_MODE_ON, TRUE);
    EnterTargetingMode(oPC, OBJECT_TYPE_ALL, MOUSECURSOR_ACTION, MOUSECURSOR_NOWALK);
}
void ai_SetupPlayerTarget()
{
    object oModule = GetModule();
    string sModuleTargetEvent = GetEventScript(oModule, EVENT_SCRIPT_MODULE_ON_PLAYER_TARGET);
    if(sModuleTargetEvent != "")
    {
        if(sModuleTargetEvent != "0e_player_target") SetLocalString(oModule, AI_MODULE_TARGET_EVENT, sModuleTargetEvent);
    }
    SetEventScript(oModule, EVENT_SCRIPT_MODULE_ON_PLAYER_TARGET, "0e_player_target");
}
void ai_ActionAssociate(object oPC, object oTarget, location lLocation, int bActionAll = FALSE)
{
    object oAssociate = OBJECT_SELF;
    if(ai_GetAIMode(oPC, AI_MODE_ACTION_GHOST) &&
       !ai_GetAIMode(oAssociate, AI_MODE_GHOST) &&
       !GetLocalInt(oAssociate, sGhostModeVarname))
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
        if(GetIsDead(oTarget))
        {
            AssignCommand(oAssociate, ActionDoCommand(ai_SearchObject(oAssociate, oTarget, oPC, TRUE)));
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
            /*if(ai_GetIsInCombat(oAssociate)) ai_DoAssociateCombatRound(oAssociate, oTarget);
            else
            {
                ai_HaveCreatureSpeak(oAssociate, 5, ":0:1:2:3:6:");
                ai_StartAssociateCombat(oAssociate, oTarget);
            } */
            if(ai_GetIsRangeWeapon(GetItemInSlot(INVENTORY_SLOT_LEFTHAND, oAssociate))) ActionAttack(oTarget, TRUE);
            else ActionAttack(oTarget);
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
        if(GetIsTrapped(oTarget))
        {
            if(GetTrapDetectedBy(oTarget, oPC)) SetTrapDetectedBy(oTarget, oAssociate);
            if(GetTrapDetectedBy(oTarget, oAssociate))
            {
                int bStopAction = !GetLocalInt(oTarget, "AI_CANNOT_TRAP_" + GetTag(oAssociate));
                if(ai_ReactToTrap(oAssociate, oTarget, TRUE)) bStopAction = TRUE;
                if(bStopAction)
                {
                    EnterTargetingMode(oPC, OBJECT_TYPE_ALL, MOUSECURSOR_ACTION, MOUSECURSOR_NOWALK);
                    return;
                }
            }
        }
        if(GetLocked(oTarget)) ai_AttemptToByPassLock(oAssociate, oTarget, TRUE);
        else if(GetIsOpen(oTarget)) ActionCloseDoor(oTarget);
        else ActionOpenDoor(oTarget);
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
                if(GetTrapDetectedBy(oTarget, oPC)) SetTrapDetectedBy(oTarget, oAssociate);
                if(GetTrapDetectedBy(oTarget, oAssociate))
                {
                    if(ai_ReactToTrap(oAssociate, oTarget, TRUE))
                    {
                        ai_EnterAssociateTargetMode(oPC, oAssociate);
                        return;
                    }

                }
            }
            if(GetLocked(oTarget)) ai_AttemptToByPassLock(oAssociate, oTarget, TRUE);
            else ActionDoCommand(ai_SearchObject(oAssociate, oTarget, oPC, TRUE));
        }
        else
        {
            if(ai_GetAIMode(oAssociate, AI_MODE_BASH_LOCKS))
            {
                AssignCommand(oAssociate, ai_ClearCreatureActions());
                // Check to make sure we are using a melee weapon.
                if(ai_GetIsMeleeWeapon(GetItemInSlot(INVENTORY_SLOT_RIGHTHAND, oAssociate)) ||
                   ai_EquipBestMeleeWeapon(oAssociate))
                {
                    AssignCommand(oAssociate, ActionWait(1.0));
                    AssignCommand(oAssociate, ActionAttack(oTarget));
                }
            }
            else AssignCommand(oAssociate, DoPlaceableObjectAction(oTarget, PLACEABLE_ACTION_USE));
        }
    }
    else if(nObjectType == OBJECT_TYPE_TRIGGER)
    {
        if(GetIsTrapped(oTarget))
        {
            if(GetTrapDetectedBy(oTarget, oPC)) SetTrapDetectedBy(oTarget, oAssociate);
            if(GetTrapDetectedBy(oTarget, oAssociate)) ai_ReactToTrap(oAssociate, oTarget, TRUE);
        }
    }
    if(!bActionAll) ai_EnterAssociateTargetMode(oPC, oAssociate);
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
void ai_RemoveAllActionMode(object oPC)
{
    object oAssociate;
    int nIndex;
    for(nIndex = 1; nIndex <= AI_MAX_HENCHMAN; nIndex++)
    {
        oAssociate = GetAssociate(ASSOCIATE_TYPE_HENCHMAN, oPC, nIndex);
        if(oAssociate != OBJECT_INVALID)
        {
            ai_SetAIMode(oAssociate, AI_MODE_COMMANDED, FALSE);
            if(ai_GetAIMode(oPC, AI_MODE_ACTION_GHOST) &&
               !ai_GetAIMode(oAssociate, AI_MODE_GHOST) &&
               GetLocalInt(oAssociate, sGhostModeVarname))
            {
                ai_RemoveASpecificEffect(oAssociate, EFFECT_TYPE_CUTSCENEGHOST);
                DeleteLocalInt(oAssociate, sGhostModeVarname);
            }
            ExecuteScript("nw_ch_ac1", oAssociate);
        }
    }
    for(nIndex = 2; nIndex < 6; nIndex++)
    {
        oAssociate = GetAssociate(nIndex, oPC);
        if(oAssociate != OBJECT_INVALID)
        {
            ai_SetAIMode(oAssociate, AI_MODE_COMMANDED, FALSE);
            if(ai_GetAIMode(oPC, AI_MODE_ACTION_GHOST) &&
               !ai_GetAIMode(oAssociate, AI_MODE_GHOST) &&
               GetLocalInt(oAssociate, sGhostModeVarname))
            {
                ai_RemoveASpecificEffect(oAssociate, EFFECT_TYPE_CUTSCENEGHOST);
                DeleteLocalInt(oAssociate, sGhostModeVarname);
            }
            ExecuteScript("nw_ch_ac1", oAssociate);
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
void ai_AddToGroup(object oDM, object oTarget, string sTargetMode)
{
    string sGroup = GetStringRight(sTargetMode, 1);
    if(oDM == oTarget)
    {
        ai_SendMessages("Group " + sGroup + " has been cleared.", AI_COLOR_YELLOW, oDM);
        string sText = "Group " + sGroup;
        NuiSetBind(oDM, NuiFindWindow(oDM, "dm" + AI_WIDGET_NUI), "btn_cmd_group" + sGroup + "_tooltip", JsonString(sText + " (Left Action/Right Add)"));
        NuiSetBind(oDM, NuiFindWindow(oDM, "dm" + AI_COMMAND_NUI), "btn_cmd_group" + sGroup + "_tooltip", JsonString(sText + " (Left Action/Right Add)"));
        NuiSetBind(oDM, NuiFindWindow(oDM, "dm" + AI_COMMAND_NUI), "btn_cmd_group" + sGroup + "_label", JsonString(sText));
        DeleteLocalJson(oDM, "DM_GROUP" + sGroup);
        return;
    }
    string sName = GetName(oTarget);
    json jGroup = GetLocalJson(oDM, "DM_GROUP" + sGroup);
    if(JsonGetType(jGroup) == JSON_TYPE_NULL)
    {
        string sText = sName + "'s group";
        NuiSetBind(oDM, NuiFindWindow(oDM, "dm" + AI_WIDGET_NUI), "btn_cmd_group" + sGroup + "_tooltip", JsonString(sText + " [Run]"));
        NuiSetBind(oDM, NuiFindWindow(oDM, "dm" + AI_COMMAND_NUI), "btn_cmd_group" + sGroup + "_tooltip", JsonString(sText + " [Run]"));
        NuiSetBind(oDM, NuiFindWindow(oDM, "dm" + AI_COMMAND_NUI), "btn_cmd_group" + sGroup + "_label", JsonString(sText));
        jGroup = JsonArrayInsert(JsonArray(), JsonInt(1));
    }
    string sUUID = GetObjectUUID(oTarget);
    int nIndex = 1;
    string sListUUID = JsonGetString(JsonArrayGet(jGroup, nIndex));
    while(sListUUID != "")
    {
        if(sListUUID == sUUID)
        {
            ai_SendMessages("This creature is already in the group!", AI_COLOR_RED, oDM);
            return;
        }
        sListUUID = JsonGetString(JsonArrayGet(jGroup, ++nIndex));
    }
    jGroup = JsonArrayInsert(jGroup, JsonString(sUUID));
    ai_SendMessages(sName + " has been saved to group" + sGroup, AI_COLOR_YELLOW, oDM);
    SetLocalJson(oDM, "DM_GROUP" + sGroup, jGroup);
    EnterTargetingMode(oDM, OBJECT_TYPE_CREATURE, MOUSECURSOR_PICKUP, MOUSECURSOR_PICKUP_DOWN);
}
void ai_MonsterAction(object oDM, object oTarget, location lLocation, int bRun, int nIndex)
{
    object oCreature = OBJECT_SELF;
    int nObjectType = GetObjectType(oTarget);
    ai_ClearCreatureActions(TRUE);
    if(oTarget == GetArea(oDM))
    {
        ActionMoveToLocation(lLocation, bRun);
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
                ai_StartMonsterCombat(oCreature);
            }
            if(nIndex == 1)
            {
                ai_SendMessages(GetName(oCreature) + "'s group is attacking " + GetName(oTarget), AI_COLOR_RED, oDM);
            }
        }
        else if(oTarget == oDM)
        {
            if(GetLocalInt(oCreature, "AI_FOLLOWING_DM"))
            {
                AssignCommand(oCreature, ClearAllActions(FALSE));
                DeleteLocalInt(oCreature, "AI_FOLLOWING_DM");
                if(nIndex == 1)
                {
                    ai_SendMessages(GetName(oCreature) + "'s group has stopped following you.", AI_COLOR_RED, oDM);
                }
            }
            else
            {
                ActionForceFollowObject(oDM, 4.0);
                SetLocalInt(oCreature, "AI_FOLLOWING_DM", TRUE);
                if(nIndex == 1)
                {
                    ai_SendMessages(GetName(oCreature) + "'s group is following you.", AI_COLOR_RED, oDM);
                }
            }
        }
        else
        {
            ActionMoveToObject(oTarget, TRUE);
            // Player will be stuck with this variable if they are not using the AI.
            DeleteLocalInt(oTarget, "AI_I_AM_BEING_HEALED");
            ActionDoCommand(ai_ActionTryHealing(oCreature, oTarget));
            if(nIndex == 1)
            {
                ai_SendMessages(GetName(oCreature) + "'s group is moving to and attempting to heal " + GetName(oTarget), AI_COLOR_RED, oDM);
            }
        }
    }
    else if(nObjectType == OBJECT_TYPE_DOOR)
    {
        if(GetIsTrapped(oTarget))
        {
            if(GetTrapDetectedBy(oTarget, oDM)) SetTrapDetectedBy(oTarget, oCreature);
            if(GetTrapDetectedBy(oTarget, oCreature))
            {
                ai_ReactToTrap(oCreature, oTarget, TRUE);
                EnterTargetingMode(oDM, OBJECT_TYPE_ALL, MOUSECURSOR_ACTION, MOUSECURSOR_NOWALK);
                return;
            }
            else if(GetLocked(oTarget)) ai_AttemptToByPassLock(oCreature, oTarget);
        }
        else if(GetLocked(oTarget)) ai_AttemptToByPassLock(oCreature, oTarget);
        else if(GetIsOpen(oTarget))
        {
            ActionCloseDoor(oTarget);
        }
        else ActionOpenDoor(oTarget);
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
                if(GetTrapDetectedBy(oTarget, oDM)) SetTrapDetectedBy(oTarget, oCreature);
                if(GetTrapDetectedBy(oTarget, oCreature))
                {
                    ai_ReactToTrap(oCreature, oTarget, TRUE);
                    EnterTargetingMode(oDM, OBJECT_TYPE_ALL, MOUSECURSOR_ACTION, MOUSECURSOR_NOWALK);
                    return;
                }
                if(GetLocked(oTarget))
                {
                    if(!ai_AttemptToByPassLock(oCreature, oTarget))
                    {
                        AssignCommand(oCreature, ai_HaveCreatureSpeak(oCreature, 0, "This " + GetName(oTarget) + " is locked!"));
                    }
                    EnterTargetingMode(oDM, OBJECT_TYPE_ALL, MOUSECURSOR_ACTION, MOUSECURSOR_NOWALK);
                    return;
                }
                DoPlaceableObjectAction(oTarget, PLACEABLE_ACTION_USE);
            }
            else if(GetLocked(oTarget))
            {
                if(ai_AttemptToByPassLock(oCreature, oTarget))
                {
                    AssignCommand(oCreature, ai_HaveCreatureSpeak(oCreature, 0, "This " + GetName(oTarget) + " is locked!"));
                }
                EnterTargetingMode(oDM, OBJECT_TYPE_ALL, MOUSECURSOR_ACTION, MOUSECURSOR_NOWALK);
                return;
            }
            ActionDoCommand(ai_SearchObject(oCreature, oTarget, oDM, TRUE));
        }
        DoPlaceableObjectAction(oTarget, PLACEABLE_ACTION_USE);
    }
    else if(nObjectType == OBJECT_TYPE_TRIGGER)
    {
        if(GetIsTrapped(oTarget))
        {
            if(GetTrapDetectedBy(oTarget, oDM)) SetTrapDetectedBy(oTarget, oCreature);
            if(GetTrapDetectedBy(oTarget, oCreature)) ai_ReactToTrap(oCreature, oTarget, TRUE);
        }
    }
    EnterTargetingMode(oDM, OBJECT_TYPE_ALL, MOUSECURSOR_ACTION, MOUSECURSOR_NOWALK);
}
void ai_DMAction(object oDM, object oTarget, location lLocation, string sTargetMode)
{
    string sGroup = GetStringRight(sTargetMode, 1);
    json jGroup = GetLocalJson(oDM, "DM_GROUP" + sGroup);
    int bRun = JsonGetInt(JsonArrayGet(jGroup, 0));
    int nIndex = 1;
    string sUUID = JsonGetString(JsonArrayGet(jGroup, nIndex));
    object oCreature;
    while(sUUID != "")
    {
        oCreature = GetObjectByUUID(sUUID);
        AssignCommand(oCreature, ai_MonsterAction(oDM, oTarget, lLocation, bRun, nIndex));
        sUUID = JsonGetString(JsonArrayGet(jGroup, ++nIndex));
    }
    if(nIndex == 0) ai_SendMessages("Group" + sGroup + " is empty!", AI_COLOR_RED, oDM);
}
void ai_SelectWidgetSpellTarget(object oPC, object oAssociate, string sElem)
{
    int nIndex;
    if(GetStringLength(sElem) == 13) nIndex = StringToInt(GetStringRight(sElem, 2));
    else nIndex = StringToInt(GetStringRight(sElem, 1));
    SetLocalInt(oAssociate, "AI_WIDGET_SPELL_INDEX", nIndex);
    string sAssociateType = ai_GetAssociateType(oPC, oAssociate);
    json jAIData = ai_GetAssociateDbJson(oPC, sAssociateType, "aidata");
    json jSpells = JsonArrayGet(jAIData, 10);
    json jWidget = JsonArrayGet(jSpells, 2);
    json jSpell = JsonArrayGet(jWidget, nIndex);
    int nSpell = JsonGetInt(JsonArrayGet(jSpell, 0));
    int nClass = JsonGetInt(JsonArrayGet(jSpell, 1));
    SetLocalObject(oPC, AI_TARGET_ASSOCIATE, oAssociate);
    if(nClass == -1) // This is an Item.
    {
        object oItem = GetObjectByUUID(JsonGetString(JsonArrayGet(jSpell, 5)));
        int nBaseItemType = GetBaseItemType(oItem);
        int nIprpSubType = JsonGetInt(JsonArrayGet(jSpell, 4));
        itemproperty ipProperty = GetFirstItemProperty(oItem);
        while(GetIsItemPropertyValid(ipProperty))
        {
            if(nIprpSubType == GetItemPropertySubType(ipProperty)) break;
            ipProperty = GetNextItemProperty(oItem);
        }
        if(Get2DAString("spells", "Range", nSpell) == "P" || // Self
           nBaseItemType == BASE_ITEM_ENCHANTED_POTION ||
           nBaseItemType == BASE_ITEM_POTIONS ||
           nIprpSubType == IP_CONST_CASTSPELL_UNIQUE_POWER_SELF_ONLY)
        {
            if(ai_GetIsInCombat(oAssociate)) AssignCommand(oAssociate, ai_ClearCreatureActions(TRUE));
            AssignCommand(oAssociate, ActionUseItemOnObject(oItem, ipProperty, oAssociate));
            DelayCommand(6.0, ai_UpdateAssociateWidget(oPC, oAssociate));
            return;
        }
        SetLocalString(oPC, AI_TARGET_MODE, "ASSOCIATE_USE_ITEM");
        if(nSpell == SPELL_HEALINGKIT)
        {
            EnterTargetingMode(oPC, OBJECT_TYPE_CREATURE, MOUSECURSOR_MAGIC, MOUSECURSOR_NOMAGIC);
            return;
        }
    }
    else // Feats, Spells, Special Abilities.
    {
        int nFeat = JsonGetInt(JsonArrayGet(jSpell, 5));
        if(nFeat)
        {
            if(!nSpell || Get2DAString("spells", "Range", nSpell) == "P" || // Self
               nFeat == FEAT_SUMMON_FAMILIAR || nFeat == FEAT_ANIMAL_COMPANION ||
               nFeat == FEAT_TURN_UNDEAD)
            {
                if(ai_GetIsInCombat(oAssociate)) AssignCommand(oAssociate, ai_ClearCreatureActions(TRUE));
                // Adjust the spell used for wild shape and other shape feats.
                if(nFeat == FEAT_WILD_SHAPE) nSpell += 607;
                if(nFeat == FEAT_ELEMENTAL_SHAPE)
                {
                    if(nSpell == 397) nSpell == SUBFEAT_ELEMENTAL_SHAPE_FIRE;
                    else if(nSpell == 398) nSpell == SUBFEAT_ELEMENTAL_SHAPE_WATER;
                    else if(nSpell == 399) nSpell == SUBFEAT_ELEMENTAL_SHAPE_EARTH;
                    else if(nSpell == 400) nSpell == SUBFEAT_ELEMENTAL_SHAPE_AIR;
                }
                // Do special targeting for attack feats.
                if(nFeat == FEAT_STUNNING_FIST || nFeat == FEAT_DIRTY_FIGHTING ||
                   nFeat == FEAT_WHIRLWIND_ATTACK || nFeat == FEAT_QUIVERING_PALM ||
                   nFeat == FEAT_KNOCKDOWN || nFeat == FEAT_IMPROVED_KNOCKDOWN ||
                   nFeat == FEAT_SAP || nFeat == FEAT_KI_DAMAGE ||
                   nFeat == FEAT_DISARM || nFeat == FEAT_IMPROVED_DISARM ||
                   nFeat == FEAT_SMITE_EVIL || nFeat == FEAT_SMITE_GOOD)
                {
                    SetLocalString(oPC, AI_TARGET_MODE, "ASSOCIATE_USE_FEAT");
                    SetLocalObject(oPC, AI_TARGET_ASSOCIATE, oAssociate);
                    EnterTargetingMode(oPC, OBJECT_TYPE_CREATURE, MOUSECURSOR_ATTACK, MOUSECURSOR_NOATTACK);
                }
                // Check feat and adjust if it is an action mode feat.
                if(!ai_SetActionMode(oAssociate, nFeat)) AssignCommand(oAssociate, ActionUseFeat(nFeat, oAssociate, nSpell));
                DelayCommand(6.0, ai_UpdateAssociateWidget(oPC, oAssociate));
                return;
            }
            SetLocalString(oPC, AI_TARGET_MODE, "ASSOCIATE_USE_FEAT");
        }
        else SetLocalString(oPC, AI_TARGET_MODE, "ASSOCIATE_CAST_SPELL");
    }
    int nObjectType;
    string sTarget = Get2DAString("spells", "TargetType", nSpell);
    int nTarget = ai_HexStringToInt(sTarget);
    //SendMessageToPC(GetFirstPC(), "nTarget: " + IntToString(nTarget));
    if((nTarget & 1) && !(nTarget & 2) &&!(nTarget & 4))
    {
        if(ai_GetIsInCombat(oAssociate)) AssignCommand(oAssociate, ai_ClearCreatureActions(TRUE));
        ai_CastWidgetSpell(oPC, oAssociate, oAssociate, GetLocation(oAssociate));
        DelayCommand(6.0, ai_UpdateAssociateWidget(oPC, oAssociate));
        return;
    }
    if((nTarget & 1) || (nTarget & 2)) nObjectType += OBJECT_TYPE_CREATURE;
    if(nTarget & 4) nObjectType += OBJECT_TYPE_TILE;
    if(nTarget & 8) nObjectType += OBJECT_TYPE_ITEM;
    if(nTarget & 16) nObjectType += OBJECT_TYPE_DOOR;
    if(nTarget & 32) nObjectType += OBJECT_TYPE_PLACEABLE;
    if(nTarget & 64) nObjectType += OBJECT_TYPE_TRIGGER;
    string sShape = Get2DAString("spells", "TargetShape", nSpell);
    int nShape, nSetData;
    float fRange;
    if(oPC == oAssociate)
    {
        nSetData = TRUE;
        fRange = ai_GetSpellRange(nSpell);
        if(fRange == 0.1) fRange = 0.0;
    }
    if(sShape == "sphere")
    {
        nShape = SPELL_TARGETING_SHAPE_SPHERE;
        nSetData = TRUE;
    }
    else if(sShape == "rectangle")
    {
        nShape = SPELL_TARGETING_SHAPE_RECT;
        nSetData = TRUE;
    }
    else if(sShape == "hsphere")
    {
        nShape = SPELL_TARGETING_SHAPE_HSPHERE;
        nSetData = TRUE;
    }
    else if(sShape == "cone") nShape = SPELL_TARGETING_SHAPE_CONE;
    else nShape = SPELL_TARGETING_SHAPE_NONE;
    if(nSetData)
    {
        float fSizeX = StringToFloat(Get2DAString("spells", "TargetSizeX", nSpell));
        float fSizeY = StringToFloat(Get2DAString("spells", "TargetSizeY", nSpell));
        int nFlags = StringToInt(Get2DAString("spells", "TargetFlags", nSpell));
        SetEnterTargetingModeData(oPC, nShape, fSizeX, fSizeY, nFlags, fRange);
    }
    EnterTargetingMode(oPC, nObjectType, MOUSECURSOR_MAGIC, MOUSECURSOR_NOMAGIC);
}
void ai_UpdateAssociateWidget(object oPC, object oAssociate)
{
    int nUIToken = NuiFindWindow(oPC, ai_GetAssociateType(oPC, oAssociate) + AI_WIDGET_NUI);
    if(nUIToken)
    {
        NuiDestroy(oPC, nUIToken);
        ai_CreateWidgetNUI(oPC, oAssociate);
        /* Not sure why I did this?
        if(oPC != oAssociate)
        {
            nUIToken = NuiFindWindow(oPC, "pc" + AI_WIDGET_NUI);
            if(nUIToken)
            {
                NuiDestroy(oPC, nUIToken);
                ai_CreateWidgetNUI(oPC, oPC);
            }
        } */
    }
}
int ai_SetActionMode(object oAssociate, int nFeat)
{
    int nMode;
    if(nFeat == FEAT_POWER_ATTACK) nMode = ACTION_MODE_POWER_ATTACK;
    else if(nFeat == FEAT_RAPID_SHOT) nMode = ACTION_MODE_RAPID_SHOT;
    else if(nFeat == FEAT_FLURRY_OF_BLOWS) nMode = ACTION_MODE_FLURRY_OF_BLOWS;
    else if(nFeat == FEAT_IMPROVED_POWER_ATTACK) nMode = ACTION_MODE_IMPROVED_POWER_ATTACK;
    else if(nFeat == FEAT_EXPERTISE) nMode = ACTION_MODE_EXPERTISE;
    else if(nFeat == FEAT_IMPROVED_EXPERTISE) nMode = ACTION_MODE_IMPROVED_EXPERTISE;
    else if(nFeat == FEAT_DIRTY_FIGHTING) nMode = ACTION_MODE_DIRTY_FIGHTING;
    else if(nFeat == FEAT_DWARVEN_DEFENDER_DEFENSIVE_STANCE) nMode = 12; // ACTION_MODE_DEFENSIVE_STANCE
    if(nMode)
    {
        SetActionMode(oAssociate, nMode, !GetActionMode(oAssociate, nMode));
        return TRUE;
    }
    return FALSE;
}
