/*////////////////////////////////////////////////////////////////////////////////////////////////////
// Script Name: 0i_states_cond
//////////////////////////////////////////////////////////////////////////////////////////////////////
 Include scripts that handle states and conditions for combat.
*/////////////////////////////////////////////////////////////////////////////////////////////////////
#include "0i_main"
#include "0i_messages"
#include "0i_time"
//#include "X0_I0_COMBAT"
// Wrapper for ClearAllActions - we have added extra vars to be cleared as well.
// Note this references OBJECT_SELF!
void ai_ClearCreatureActions(int bClearCombatState = FALSE);
// Used in combat to keep track of the creatures last rounds action.
// One use is to make sure we don't use the same spell on the next round.
// 0+ is the spell that was cast, other actions use AI_LAST_ACTION_* constants.
void ai_SetLastAction(object oCreature, int nAction = AI_LAST_ACTION_NONE);
// Returns TRUE if oCreatures last rounds action is equal to nAction.
// 0+ is the spell that was cast, other actions use AI_LAST_ACTION_* constants.
int ai_CompareLastAction(object oCreature, int nAction);
// Sets the correct listen checks on oCreature.
void ai_SetListeningPatterns(object oCreature);
// Returns TRUE if oCreature is an elemental, undead, or golem i.e. non-living.
int ai_IsNonliving(int nRacialType);
// Returns TRUE if oCreature is in combat.
int ai_GetIsInCombat(object oCreature);
// Sets the time that this oCreature's current combat round started.
// Using action based combat rounds has an unfortunate side effect:
// Once you attack in melee you will continue to attack in melee do to hardcoded
// logic. This will "PUSH" your end of round back until it decides to stop attacking!
// We avoid this by setting the time and if we check for combat and 6 seconds has
// passed then we assume the current round is over, ClearAllActions, and start the next round.
void ai_SetCombatRound(object oCreature);
// Clears the current combat round timer by deleting the value.
void ai_EndCombatRound(object oCreature);
// Returns TRUE if AI_COMBAT_ROUND_IN_SECONDS has not passed since ai_SetCombatRound.
// If it returns FALSE then it will clear the current combat round timer.
int ai_IsInCombatRound(object oCreature, int nCombatRound = AI_COMBAT_ROUND_IN_SECONDS);
// Returns TRUE if oCreature is busy.
// This checks various actions to see if oCreature is busy;
// in combat, busy mode, Actions: attacking, casting spell, counterspelling,
// disabling trap, item casting spell, opening lock, resting, setting trap.
int ai_GetIsBusy(object oCreature);
// Returns a value based on the disabling effect.
// Dead = 1, Bleeding = 2, Dying = 2, Stunned = 29, Confused = 24, Paralyzed = 27
// Frightened 25, Turned = 35, Petrified = 79, Charmed = 23, Disappearappear = 75,
// Time Stop = 66, Dazed = 28, Sleep = 30.
// Returns FALSE if not Disabled.
int ai_Disabled(object oCreature);
// Set one of the AI_MODE_* bitwise constants on oAssociate to bOn.
void ai_SetAIMode(object oAssociate, int nBit, int bOn = TRUE);
// Return if nMode is set on oAssociate. Uses the AI_MODE_* bitwise constants.
int ai_GetAIMode(object oAssociate, int nBit);
// Set one of the AI_MAGIC_* bitwise constants on oAssociate to bOn.
void ai_SetMagicMode(object oAssociate, int nBit, int bOn = TRUE);
// Return if nMode is set on oAssociate. Uses the AI_MAGIC_* bitwise constants.
int ai_GetMagicMode(object oAssociate, int nBit);
// This is based off of the PC's settings for an associate and other creatures use a default.
// Set one of the AI_LOOT_* bitwise constants on oAssociate to bOn.
void ai_SetLootFilter(object oAssociate, int nBit, int bOn = TRUE);
// Return if nMode is set on oAssociate. Uses the AI_LOOT_* bitwise constants.
int ai_GetLootFilter(object oAssociate, int nBit);
// Set one of the AI_IP_* bitwise constants on oCreature to bOn.
void ai_SetItemProperty(object oCreature, string sVarname, int nBit, int bOn = TRUE);
// Return if nMode is set on oCreature. Uses the AI_IP_* bitwise constants.
int ai_GetItemProperty(object oCreature, string sVarname, int nBit);
// Returns the number of hitpoints a creature must have to not be healed.
// This is based off of the PC's settings for an associate and other creatures use a default.
int ai_GetHealersHpLimit(object oCreature, int bInCombat = TRUE);
// Returns TRUE if nCondition is within nCurrentConditions.
// nCurrentConditions is setup in ai_GetNegativeConditions.
int ai_GetHasNegativeCondition(int nCondition, int nCurrentConditions);
// Returns an integer with bitwise flags set that represent the current negative
// conditions on oCreature. ai_GetHasNegativeCondition uses this function.
int ai_GetNegativeConditions(object oCreature);
// Returns TRUE if oObject is in the line of sight of oCreature.
// If the creature is close LineOfSight doesn't work well.
int ai_GetIsInLineOfSight(object oCreature, object oObject);
// Add the specified condition flag to the behavior state of the caller
void ai_SetBehaviorState(int nCondition, int bValid = TRUE);
// Returns TRUE if the specified behavior flag is set on the caller
int ai_GetBehaviorState(int nCondition);
// Highlights the current mode for the widget passed.
void ai_HighlightWidgetMode(object oPC, object oAssociate, int nToken);
// Checks to see if the party scale is correctly adjusted.
void ai_CheckXPPartyScale(object oCreature);

void ai_ClearCreatureActions(int bClearCombatState = FALSE)
{
    if(AI_DEBUG) ai_Debug("0i_states_cond", "89", GetName(OBJECT_SELF) + " is clearing actions (" +
             IntToString(bClearCombatState) + ")!");
    DeleteLocalInt(OBJECT_SELF, AI_CURRENT_ACTION_MODE);
    ClearAllActions(bClearCombatState);
}
void ai_SetLastAction(object oCreature, int nAction = AI_LAST_ACTION_NONE)
{
    SetLocalInt(oCreature, sLastActionVarname, nAction);
    SetLocalInt(oCreature, sLastActionTimeVarname, ai_GetCurrentTimeStamp());
}
int ai_CompareLastAction(object oCreature, int nAction)
{
    // Are we checking to see if we cast a spell?
    if(nAction == AI_LAST_ACTION_CAST_SPELL &&
        GetLocalInt(oCreature, sLastActionVarname) > -1) return TRUE;
    // Check other last actions.
    return (nAction == GetLocalInt(oCreature, sLastActionVarname));
}
void ai_SetListeningPatterns(object oCreature)
{
    SetListening(oCreature, TRUE);
    SetListenPattern(oCreature, AI_I_SEE_AN_ENEMY, AI_ALLY_SEES_AN_ENEMY);
    SetListenPattern(oCreature, AI_I_HEARD_AN_ENEMY, AI_ALLY_HEARD_AN_ENEMY);
    SetListenPattern(oCreature, AI_ATKED_BY_WEAPON, AI_ALLY_ATKED_BY_WEAPON);
    SetListenPattern(oCreature, AI_ATKED_BY_SPELL, AI_ALLY_ATKED_BY_SPELL);
    SetListenPattern(oCreature, AI_I_AM_WOUNDED, AI_ALLY_IS_WOUNDED);
    SetListenPattern(oCreature, AI_I_AM_DEAD, AI_ALLY_IS_DEAD);
    SetListenPattern(oCreature, AI_I_AM_DISEASED, AI_ALLY_IS_DISEASED);
    SetListenPattern(oCreature, AI_I_AM_POISONED, AI_ALLY_IS_POISONED);
    SetListenPattern(oCreature, AI_I_AM_WEAK, AI_ALLY_IS_WEAK);
}
int ai_IsNonliving(int nRacialType)
{
    switch(nRacialType)
    {
        case RACIAL_TYPE_CONSTRUCT:
        case RACIAL_TYPE_ELEMENTAL:
        case RACIAL_TYPE_UNDEAD: return TRUE;
   }
   return FALSE;
}
int ai_GetIsInCombat(object oCreature)
{
    if(AI_DEBUG) ai_Debug("0i_states_cond", "110", GetName(oCreature) + " is in Combat: Enemy Numbers = " + IntToString(GetLocalInt(oCreature, AI_ENEMY_NUMBERS)));

    return GetLocalInt(oCreature, AI_ENEMY_NUMBERS);
}
void ai_SetCombatRound(object oCreature)
{
    SetLocalInt(oCreature, "AI_COMBAT_ROUND_START", ai_GetCurrentTimeStamp());
    if(AI_DEBUG) ai_Debug("0i_states_cond", "116", " ===============> " + GetName(oCreature) + " ROUND START:" + IntToString(ai_GetCurrentTimeStamp()) + " <===============");
}
void ai_EndCombatRound(object oCreature)
{
    if(AI_DEBUG) ai_Debug("0i_states_cond", "120", " ===============> " + GetName(oCreature) + " ROUND END:" + IntToString(ai_GetCurrentTimeStamp()) + " <===============");
    DeleteLocalInt(oCreature, "AI_COMBAT_ROUND_START");
}
int ai_IsInCombatRound(object oCreature, int nCombatRound = AI_COMBAT_ROUND_IN_SECONDS)
{
    int nCombatRoundStart = GetLocalInt(oCreature, "AI_COMBAT_ROUND_START");
    if(AI_DEBUG) ai_Debug("0i_states_cond", "148", " nCombatRoundStart: " + IntToString(nCombatRoundStart));
    if(!nCombatRoundStart) return FALSE;
    // New combat round calculator. If 6 seconds has passed then we are on a new round!
    int nTime = ai_GetCurrentTimeStamp();
    int nCombatRoundTime = nTime - nCombatRoundStart;
    if(AI_DEBUG) ai_Debug("0i_states_cond", "153", " nTime + (nTime - Round Start): " + IntToString(nTime) +
             "(" + IntToString(nTime - nCombatRoundStart) + ")");
    if(nCombatRoundTime < nCombatRound) return TRUE;
    ai_EndCombatRound(oCreature);
    return FALSE;
}
// Testing to see if we can fix some delaying in combat.
int ai_GetIsBusy(object oCreature)
{
    int nAction = GetCurrentAction(oCreature);
    if(AI_DEBUG) ai_Debug("0i_states_cond", "140", GetName(oCreature) + " Get is Busy, action: " +
             IntToString(nAction));
    switch(nAction)
    {
        case ACTION_CASTSPELL :
        case ACTION_ITEMCASTSPELL :
        case ACTION_OPENLOCK :
        case ACTION_REST :
        case ACTION_DISABLETRAP :
        case ACTION_ATTACKOBJECT :
        case ACTION_COUNTERSPELL :
        case ACTION_SETTRAP : return TRUE;
        case ACTION_WAIT :
        case ACTION_INVALID :
        {
            int nCombatWait = GetLocalInt(oCreature, AI_COMBAT_WAIT_IN_SECONDS);
            if(AI_DEBUG) ai_Debug("0i_states_cond", "153", "nCombatWait: " + IntToString(nCombatWait) +
                     " AI_AM_I_SEARCHING: " + IntToString(GetLocalInt(oCreature, AI_AM_I_SEARCHING)));
            if(nCombatWait)
            {
                if(ai_IsInCombatRound(oCreature, nCombatWait)) return TRUE;
                DeleteLocalInt(oCreature, AI_COMBAT_WAIT_IN_SECONDS);
            }
            else if(GetLocalInt(oCreature, AI_AM_I_SEARCHING)) DeleteLocalInt(oCreature, AI_AM_I_SEARCHING);
            return FALSE;
        }
        case ACTION_MOVETOPOINT :
        {
            return ai_GetIsInCombat(oCreature);
        }
    }
    return FALSE;
}
int ai_Disabled(object oCreature)
{
    if(GetIsDead(oCreature)) return 1;
    // Check for effects.
    effect eEffect = GetFirstEffect(oCreature);
    while(GetIsEffectValid(eEffect))
    {
        switch(GetEffectType(eEffect, TRUE))
        {
            WriteTimestampedLogEntry("Effect Type: " + IntToString(GetEffectType(eEffect, TRUE)));
            case EFFECT_TYPE_DOMINATED :
            case EFFECT_TYPE_CUTSCENE_DOMINATED :
            {
                if(!GetCommandable(oCreature)) SetCommandable(TRUE, oCreature);
                return FALSE;
            }
            case EFFECT_TYPE_STUNNED :
            case EFFECT_TYPE_DAZED :
            case EFFECT_TYPE_SLEEP :
            case EFFECT_TYPE_CONFUSED :
            case EFFECT_TYPE_FRIGHTENED :
            case EFFECT_TYPE_PARALYZE :
            case EFFECT_TYPE_CUTSCENE_PARALYZE :
            case EFFECT_TYPE_TURNED :
            case EFFECT_TYPE_CHARMED :
            case EFFECT_TYPE_PETRIFY :
            case EFFECT_TYPE_TIMESTOP :
            {
                if(AI_DEBUG) ai_Debug("0i_stats_cond", "195", GetName(oCreature) + " is disabled(" +
                         IntToString(GetEffectType(eEffect)) + ")");
                return GetEffectType(eEffect);
            }
        }
        eEffect = GetNextEffect(oCreature);
    }
    // Not Commandable is basically disabled as far as the AI is concerned.
    if(!GetCommandable(oCreature))
    {
        if(AI_DEBUG) ai_Debug("0i_stats_cond", "213", GetName(oCreature) + " is disabled(Not Commandable)!");
        return EFFECT_TYPE_PARALYZE;
    }
    if(AI_DEBUG) ai_Debug("0i_states_cond", "202", GetName(oCreature) + " is not disabled.");
    return FALSE;
}
void ai_SetAIMode(object oAssociate, int nBit, int bOn = TRUE)
{
    int nAIModes = GetLocalInt(oAssociate, sAIModeVarname);
    if(bOn) nAIModes = nAIModes | nBit;
    else nAIModes = nAIModes & ~nBit;
    SetLocalInt(oAssociate, sAIModeVarname, nAIModes);
    // Set widget to show the mode they are in.

}
int ai_GetAIMode(object oAssociate, int nBit)
{
    if(GetLocalInt(oAssociate, sAIModeVarname) & nBit) return TRUE;
    return FALSE;
}
void ai_SetMagicMode(object oAssociate, int nBit, int bOn = TRUE)
{
    int nMagicModes = GetLocalInt(oAssociate, sMagicModeVarname);
    if(bOn) nMagicModes = nMagicModes | nBit;
    else nMagicModes = nMagicModes & ~nBit;
    SetLocalInt(oAssociate, sMagicModeVarname, nMagicModes);
}
int ai_GetMagicMode(object oAssociate, int nBit)
{
    if(GetLocalInt(oAssociate, sMagicModeVarname) & nBit) return TRUE;
    return FALSE;
}
void ai_SetLootFilter(object oAssociate, int nLootBit, int bOn = TRUE)
{
    int nLootFilter = GetLocalInt(oAssociate, sLootFilterVarname);
    if(bOn) nLootFilter = nLootFilter | nLootBit;
    else nLootFilter = nLootFilter & ~nLootBit;
    SetLocalInt(oAssociate, sLootFilterVarname, nLootFilter);
}
int ai_GetLootFilter(object oAssociate, int nBit)
{
    if(GetLocalInt(oAssociate, sLootFilterVarname) & nBit) return TRUE;
    return FALSE;
}
void ai_SetItemProperty(object oCreature, string sVarname, int nBit, int bOn = TRUE)
{
    int nItemProperties = GetLocalInt(oCreature, sVarname);
    if(bOn) nItemProperties = nItemProperties | nBit;
    else nItemProperties = nItemProperties & ~nBit;
    SetLocalInt(oCreature, sVarname, nItemProperties);
}
int ai_GetItemProperty(object oCreature, string sVarname, int nBit)
{
    if(GetLocalInt(oCreature, sVarname) & nBit) return TRUE;
    return FALSE;
}
int ai_GetHealersHpLimit(object oCreature, int bInCombat = TRUE)
{
    if(bInCombat) return GetLocalInt(oCreature, AI_HEAL_IN_COMBAT_LIMIT);
    else return GetLocalInt(oCreature, AI_HEAL_OUT_OF_COMBAT_LIMIT);
}
int ai_GetHasNegativeCondition(int nCondition, int nCurrentConditions)
{
    return (nCurrentConditions & nCondition);
}
int ai_GetNegativeConditions(object oCreature)
{
    int nCondition, nEffectType;
    effect eEffect = GetFirstEffect(oCreature);
    while(GetIsEffectValid (eEffect))
    {
        // Rage and maybe other abilities might come from the oCreature!
        if(GetEffectCreator(eEffect) != oCreature)
        {
            nEffectType = GetEffectType(eEffect);
            switch(nEffectType)
            {
                case EFFECT_TYPE_DISEASE:          nCondition = nCondition | AI_CONDITION_DISEASE; break;
                case EFFECT_TYPE_POISON:           nCondition = nCondition | AI_CONDITION_POISON; break;
                case EFFECT_TYPE_CURSE:            nCondition = nCondition | AI_CONDITION_CURSE; break;
                case EFFECT_TYPE_BLINDNESS:
                case EFFECT_TYPE_DEAF:             nCondition = nCondition | AI_CONDITION_BLINDDEAF; break;
                case EFFECT_TYPE_ABILITY_DECREASE: nCondition = nCondition | AI_CONDITION_ABILITY_DRAIN; break;
                case EFFECT_TYPE_NEGATIVELEVEL:    nCondition = nCondition | AI_CONDITION_LEVEL_DRAIN; break;
                case EFFECT_TYPE_AC_DECREASE:      nCondition = nCondition | AI_CONDITION_AC_DECREASE; break;
                case EFFECT_TYPE_ATTACK_DECREASE:  nCondition = nCondition | AI_CONDITION_ATK_DECREASE; break;
                case EFFECT_TYPE_CHARMED:          nCondition = nCondition | AI_CONDITION_CHARMED; break;
                case EFFECT_TYPE_CONFUSED:         nCondition = nCondition | AI_CONDITION_CONFUSED; break;
                case EFFECT_TYPE_DAZED:            nCondition = nCondition | AI_CONDITION_DAZED; break;
                case EFFECT_TYPE_DAMAGE_DECREASE:  nCondition = nCondition | AI_CONDITION_DMG_DECREASE; break;
                case EFFECT_TYPE_DAMAGE_IMMUNITY_DECREASE: nCondition = nCondition | AI_CONDITION_DMG_I_DECREASE; break;
                case EFFECT_TYPE_DOMINATED:        nCondition = nCondition | AI_CONDITION_DOMINATED; break;
                case EFFECT_TYPE_FRIGHTENED:       nCondition = nCondition | AI_CONDITION_FRIGHTENED; break;
                case EFFECT_TYPE_PARALYZE:         nCondition = nCondition | AI_CONDITION_PARALYZE; break;
                case EFFECT_TYPE_SAVING_THROW_DECREASE: nCondition = nCondition | AI_CONDITION_SAVE_DECREASE; break;
                case EFFECT_TYPE_SKILL_DECREASE:   nCondition = nCondition | AI_CONDITION_SKILL_DECREASE; break;
                case EFFECT_TYPE_SLOW:             nCondition = nCondition | AI_CONDITION_SLOW; break;
                case EFFECT_TYPE_SPELL_RESISTANCE_DECREASE: nCondition = nCondition | AI_CONDITION_SR_DECREASE; break;
                case EFFECT_TYPE_STUNNED:          nCondition = nCondition | AI_CONDITION_STUNNED; break;
            }
        }
        eEffect = GetNextEffect(oCreature);
    }
    return nCondition;
}
int ai_GetIsInLineOfSight(object oCreature, object oObject)
{
    // Creatures can block the line of sight so when close we shouldn't check.
    if(GetDistanceBetween(oObject, oCreature) <= AI_RANGE_MELEE) return TRUE;
    return LineOfSightObject(oCreature, oObject);
}
void ai_SetBehaviorState(int nCondition, int bValid = TRUE)
{
    int nPlot = GetLocalInt(OBJECT_SELF, "NW_BEHAVIOR_MASTER");
    if(bValid)
    {
        nPlot = nPlot | nCondition;
        SetLocalInt(OBJECT_SELF, "NW_BEHAVIOR_MASTER", nPlot);
    }
    else
    {
        nPlot = nPlot & ~nCondition;
        SetLocalInt(OBJECT_SELF, "NW_BEHAVIOR_MASTER", nPlot);
    }
}
int ai_GetBehaviorState(int nCondition)
{
    int nPlot = GetLocalInt(OBJECT_SELF, "NW_BEHAVIOR_MASTER");
    if(nPlot & nCondition) return TRUE;
    return FALSE;
}
void ai_HighlightWidgetMode(object oPC, object oAssociate, int nToken)
{
    if(oPC == oAssociate) return;
    int bBool;
    bBool = ai_GetAIMode(oAssociate,AI_MODE_DEFEND_MASTER);
    NuiSetBind(oPC, nToken, "btn_cmd_guard_encouraged", JsonBool(bBool));
    bBool = ai_GetAIMode(oAssociate,AI_MODE_STAND_GROUND);
    NuiSetBind(oPC, nToken, "btn_cmd_hold_encouraged", JsonBool(bBool));
    bBool = ai_GetAIMode(oAssociate,AI_MODE_FOLLOW);
    NuiSetBind(oPC, nToken, "btn_cmd_follow_encouraged", JsonBool(bBool));
    if(!ai_GetAIMode(oAssociate, AI_MODE_DEFEND_MASTER) &&
       !ai_GetAIMode(oAssociate, AI_MODE_STAND_GROUND) &&
       !ai_GetAIMode(oAssociate, AI_MODE_FOLLOW)) bBool = TRUE;
    else bBool = FALSE;
    NuiSetBind(oPC, nToken, "btn_cmd_attack_encouraged", JsonBool(bBool));
}
void ai_CheckXPPartyScale(object oCreature)
{
    object oModule = GetModule();
    if(!GetLocalInt(oModule, AI_RULE_PARTY_SCALE)) return;
    object oMaster;
    if(!ai_GetIsCharacter(oCreature))
    {
        oMaster = GetMaster(oCreature);
        while(oMaster != OBJECT_INVALID)
        {
            if(ai_GetIsCharacter(oMaster)) break;
            oMaster = GetMaster(oMaster);
        }
        if(oMaster == OBJECT_INVALID) return;
    }
    else oMaster = oCreature;
    float fDefaultXPScale = IntToFloat(GetLocalInt(oModule, AI_BASE_PARTY_SCALE_XP));
    float fPartySize = 4.0;
    int nAssociateType, nHenchman, nHenchAssociate;
    object oHenchman;
    for(nAssociateType = 1; nAssociateType <= 5; nAssociateType++)
    {
        if(nAssociateType == ASSOCIATE_TYPE_HENCHMAN)
        {
            for(nHenchman = 1; nHenchman <= AI_MAX_HENCHMAN; nHenchman++)
            {
                oHenchman = GetAssociate(nAssociateType, oMaster, nHenchman);
                if(oHenchman != OBJECT_INVALID)
                {
                    fPartySize += 1.0;
                    for(nHenchAssociate = 2; nHenchAssociate <= 5; nHenchAssociate++)
                    {
                        if(GetAssociate(nHenchAssociate, oHenchman, 1) != OBJECT_INVALID) fPartySize += 1.0;
                    }
                }
            }
        }
        else if(GetAssociate(nAssociateType, oMaster, 1) != OBJECT_INVALID) fPartySize += 1.0;
    }
    int nXPScale = FloatToInt(fPartySize / 4.0 * fDefaultXPScale);
    //SendMessageToPC(oMaster, GetName(oMaster) + " nXPScale = (3 + fPartySize / 4.0 * fDefaultXPScale)" +
    //                IntToString(nXPScale) + " = (" + FloatToString(fPartySize, 0, 1) + " / 4.0 * " +
    //                FloatToString(fDefaultXPScale, 0, 1) + ")");
    SetModuleXPScale(nXPScale);
}

