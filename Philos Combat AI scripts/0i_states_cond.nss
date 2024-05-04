/*////////////////////////////////////////////////////////////////////////////////////////////////////
// Script Name: 0i_states_cond
//////////////////////////////////////////////////////////////////////////////////////////////////////
 Include scripts that handle states and conditions for combat.
*/////////////////////////////////////////////////////////////////////////////////////////////////////
#include "0i_messages"
#include "inc_sqlite_time"
//#include "X0_I0_COMBAT"
// Wrapper for ClearAllActions - we have added extra vars to be cleared as well.
void ai_ClearCreatureActions(object oCreature, int bClearCombatState = FALSE);
// Used in combat to keep track of the creatures last rounds action.
// One use is to make sure we don't use the same spell on the next round.
// 0+ is the spell that was cast, other actions use AI_LAST_ACTION_* constants.
void ai_SetLastAction(object oCreature, int nAction = AI_LAST_ACTION_NONE);
// Returns TRUE if oCreatures last rounds action is equal to nAction.
// 0+ is the spell that was cast, other actions use AI_LAST_ACTION_* constants.
int ai_CompareLastAction(object oCreature, int nAction);
// Sets the correct listen checks on oCreature.
void ai_SetMonsterListeningPatterns(object oCreature);
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
// Set one of the MODE_* bitwise constants on oAssociate to bValid.
void ai_SetAssociateMode(object oAssociate, int nMode, int bValid = TRUE);
// Return if nMode is set on oAssociate. Uses the MODE_* bitwise constants.
int ai_GetAssociateMode(object oAssociate, int nMode);
// Returns TRUE if nCondition is within nCurrentConditions.
// nCurrentConditions is setup in ai_GetNegativeConditions.
int ai_GetHasNegativeCondition(int nCondition, int nCurrentConditions);
// Returns an integer with bitwise flags set that represent the current negative
// conditions on oCreature. ai_GetHasNegativeCondition uses this function.
int ai_GetNegativeConditions(object oCreature);
// Returns TRUE if oObject is in the line of sight of oCreature.
// If the creature is close LineOfSight doesn't work well.
int ai_GetIsInLineOfSight(object oCreature, object oObject);

void ai_ClearCreatureActions(object oCreature, int bClearCombatState = FALSE)
{
    //ai_Debug("0i_states_cond", "63", GetName(oCreature) + " is clearing actions (" +
    //         IntToString(bClearCombatState) + ")!");
    DeleteLocalInt(oCreature, AI_CURRENT_ACTION_MODE);
    ClearAllActions(bClearCombatState);
}
void ai_SetLastAction(object oCreature, int nAction = AI_LAST_ACTION_NONE)
{
    SetLocalInt(oCreature, sLastActionVarname, nAction);
}
int ai_CompareLastAction(object oCreature, int nAction)
{
    // Are we checking to see if we cast a spell?
    if(nAction == AI_LAST_ACTION_CAST_SPELL &&
        GetLocalInt(oCreature, sLastActionVarname) > -1) return TRUE;
    // Check other last actions.
    return (nAction == GetLocalInt(oCreature, sLastActionVarname));
}
void ai_SetMonsterListeningPatterns(object oCreature)
{
    SetListenPattern(oCreature, AI_I_SEE_AN_ENEMY, AI_ALLY_SEES_AN_ENEMY);
    SetListenPattern(oCreature, AI_I_HEARD_AN_ENEMY, AI_ALLY_HEARD_AN_ENEMY);
    SetListenPattern(oCreature, AI_ATKED_BY_WEAPON, AI_ALLY_ATKED_BY_WEAPON);
    SetListenPattern(oCreature, AI_ATKED_BY_SPELL, AI_ALLY_ATKED_BY_SPELL);
    SetListenPattern(oCreature, AI_I_AM_WOUNDED, AI_ALLY_IS_WOUNDED);
    SetListenPattern(oCreature, AI_I_AM_DEAD, AI_ALLY_IS_DEAD);
    SetListening(oCreature, TRUE);
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
    return GetLocalInt(oCreature, AI_ENEMY_NUMBERS);
}
void ai_SetCombatRound(object oCreature)
{
    SetLocalInt(oCreature, "AI_COMBAT_ROUND_START", SQLite_GetTimeStamp());
    //ai_Debug("0i_states_cond", "107", " ===============> " + GetName(oCreature) + " ROUND START:" + IntToString(SQLite_GetTimeStamp()) + " <===============");
}
void ai_EndCombatRound(object oCreature)
{
    //ai_Debug("0i_states_cond", "111", " ===============> " + GetName(oCreature) + " ROUND END:" + IntToString(SQLite_GetTimeStamp()) + " <===============");
    DeleteLocalInt(oCreature, "AI_COMBAT_ROUND_START");
}
int ai_IsInCombatRound(object oCreature, int nCombatRound = AI_COMBAT_ROUND_IN_SECONDS)
{
    int nCombatRoundStart = GetLocalInt(oCreature, "AI_COMBAT_ROUND_START");
    if(!nCombatRoundStart) return FALSE;
    //ai_Debug("0i_states_cond", "118", " nCombatRoundStart: " + IntToString(nCombatRoundStart));
    // New combat round calculator. If 6 seconds has passed then we are on a new round!
    int nSQLTime = SQLite_GetTimeStamp();
    int nCombatRoundTime = nSQLTime - nCombatRoundStart;
    //ai_Debug("0i_states_cond", "122", " SQLite_GetTimeStamp: " + IntToString(nSQLTime) +
    //         "(" + IntToString(nSQLTime - nCombatRoundStart) + ")");
    if(nCombatRoundTime >= nCombatRound) ai_EndCombatRound(oCreature);
    else return TRUE;
    return FALSE;
}
int ai_GetIsBusy(object oCreature)
{
    int nAction = GetCurrentAction(oCreature);
    //ai_Debug("0i_states_cond", "131", GetName(oCreature) + " Get is Busy, action: " +
    //         IntToString(nAction) + " IsInCombat: " + IntToString(ai_GetIsInCombat(oCreature)));
    switch(nAction)
    {
        case ACTION_INVALID :
        {
            int nCombatWait = GetLocalInt(oCreature, AI_COMBAT_WAIT_IN_SECONDS);
            //ai_Debug("0i_states_cond", "138", "nCombatWait: " + IntToString(nCombatWait));
            if(nCombatWait)
            {
                if(ai_IsInCombatRound(oCreature, nCombatWait)) return TRUE;
                DeleteLocalInt(oCreature, AI_COMBAT_WAIT_IN_SECONDS);
            }
            else if(GetLocalInt(oCreature, AI_AM_I_SEARCHING)) DeleteLocalInt(oCreature, AI_AM_I_SEARCHING);
            return FALSE;
        }
        case ACTION_ATTACKOBJECT :
        case ACTION_COUNTERSPELL :
        {
            // If we are attacking/counterspelling and there is time left
            // in this round then we are busy.
            if(ai_IsInCombatRound(oCreature)) return TRUE;
            return FALSE;
        }
        case ACTION_CASTSPELL :
        case ACTION_DISABLETRAP :
        case ACTION_ITEMCASTSPELL :
        case ACTION_OPENLOCK :
        case ACTION_REST :
        case ACTION_SETTRAP : return TRUE;
        case ACTION_MOVETOPOINT :
        {
            if(ai_GetIsInCombat(oCreature)) return TRUE;
        }
    }
    return FALSE;
}
int ai_Disabled(object oCreature)
{
    //ai_Debug("0i_states_cond", "170", GetName(oCreature) + " Checking if disabled.");
    if(GetIsDead(oCreature)) return 1;
    // Check for effects.
    effect eEffect = GetFirstEffect(oCreature);
    while(GetIsEffectValid(eEffect))
    {
        switch(GetEffectType(eEffect))
        {
            case EFFECT_TYPE_STUNNED :
            case EFFECT_TYPE_DAZED :
            case EFFECT_TYPE_SLEEP :
            case EFFECT_TYPE_CONFUSED :
            case EFFECT_TYPE_FRIGHTENED :
            case EFFECT_TYPE_PARALYZE :
            case EFFECT_TYPE_TURNED :
            case EFFECT_TYPE_CHARMED :
            case EFFECT_TYPE_PETRIFY :
            case EFFECT_TYPE_TIMESTOP :
            {
                //ai_Debug("0i_stats_cond", "189", GetName(oCreature) + " is disabled(" +
                //         IntToString(GetEffectType(eEffect)) + ")");
                return GetEffectType(eEffect);
            }
        }
        eEffect = GetNextEffect(oCreature);
    }
    //ai_Debug("0i_states_cond", "196", GetName(oCreature) + " is not disabled.");
    return FALSE;
}
void ai_SetAssociateMode(object oAssociate, int nMode, int bOn = TRUE)
{
    int nAssociateModes = GetLocalInt(oAssociate, sAssociateModeVarname);
    if(bOn) nAssociateModes = nAssociateModes | nMode;
    else nAssociateModes = nAssociateModes & ~nMode;
    SetLocalInt(oAssociate, sAssociateModeVarname, nAssociateModes);
}
int ai_GetAssociateMode(object oAssociate, int nMode)
{
    return (GetLocalInt(oAssociate, sAssociateModeVarname) & nMode);
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

