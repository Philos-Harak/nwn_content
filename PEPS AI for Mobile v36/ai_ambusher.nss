/*////////////////////////////////////////////////////////////////////////////////////////////////////
// Script Name: ai_ambusher
//////////////////////////////////////////////////////////////////////////////////////////////////////
 ai script for ambushing creatures (Any).
 OBJECT_SELF is the creature running the ai.
*/////////////////////////////////////////////////////////////////////////////////////////////////////
// Programmer: Philos
//////////////////////////////////////////////////////////////////////////////////////////////////////
#include "0i_actions"
void main()
{
    object oCreature = OBJECT_SELF;
    // Get the number of enemies that we are in melee combat with.
    int nInMelee = ai_GetNumOfEnemiesInRange(oCreature);
    // Has our master told us to not use magic?
    int bUseMagic = !ai_GetMagicMode(oCreature, AI_MAGIC_NO_MAGIC);
    //***************************  HEALING & CURES  ****************************
    if(bUseMagic)
    {
        if(ai_TryHealingTalent(oCreature, nInMelee)) return;
        if(ai_TryCureConditionTalent(oCreature, nInMelee)) return;
    }
    // Check for moral and get the maximum spell level we should use.
    if(ai_GetDifficulty(oCreature) >= AI_COMBAT_EFFORTLESS)
    {
        if(nInMelee && ai_MoralCheck(oCreature)) return;
    }
    // Rule used to disable ambush if the player wants to.
    if(!GetLocalInt(GetModule(), AI_RULE_AMBUSH))
    {
        ExecuteScript("ai_default", oCreature);
        return;
    }
    // If can turn invisible then we should probably do that!
    if(ai_UseTalent(oCreature, SPELL_IMPROVED_INVISIBILITY, oCreature)) return;
    if(ai_UseTalent(oCreature, SPELL_INVISIBILITY, oCreature)) return;
    if(ai_UseTalent(oCreature, SPELL_INVISIBILITY_SPHERE, oCreature)) return;
    if(ai_UseTalent(oCreature, SPELL_SANCTUARY, oCreature)) return;
    if(ai_UseTalent(oCreature, SPELL_ETHEREALNESS, oCreature)) return; // Greater Sanctuary
    if(ai_UseTalent(oCreature, SPELLABILITY_AS_IMPROVED_INVISIBLITY, oCreature)) return;
    if(ai_UseTalent(oCreature, SPELLABILITY_AS_INVISIBILITY, oCreature)) return;
    // Check the battle field to see if anyone see us?
    int nEnemyIndex = ai_GetNearestIndexThatSeesUs(oCreature);
    // If seen, can we try to hide now?
    if(nEnemyIndex)
    {
        // Check for an attacker and can they see through invisibility?
        object oAttacker = ai_GetEnemyAttackingMe(oCreature);
        int bCanSeeInvisible;
        if(oAttacker != OBJECT_INVALID)
        {
            bCanSeeInvisible = ai_GetHasEffectType(oAttacker, EFFECT_TYPE_SEEINVISIBLE);
            if(!bCanSeeInvisible) bCanSeeInvisible = ai_GetHasEffectType(oAttacker, EFFECT_TYPE_TRUESEEING);
            if(!bCanSeeInvisible) bCanSeeInvisible = GetHasFeat(FEAT_BLINDSIGHT_5_FEET, oCreature);
            if(!bCanSeeInvisible) bCanSeeInvisible = GetHasFeat(FEAT_BLINDSIGHT_10_FEET, oCreature);
            if(!bCanSeeInvisible) bCanSeeInvisible = GetHasFeat(FEAT_BLINDSIGHT_60_FEET, oCreature);
        }
        if(AI_DEBUG) ai_Debug("ai_ambusher", "43", "bCanSeeInvisible: " + IntToString(bCanSeeInvisible));
        if(!bCanSeeInvisible)
        {
            if(GetHasFeat(FEAT_HIDE_IN_PLAIN_SIGHT, oCreature))
            {
                if(!GetActionMode(oCreature, ACTION_MODE_STEALTH))
                {
                    if(AI_DEBUG) ai_Debug("ai_ambusher", "50", GetName(oCreature) + " is using hide in plain sight!");
                    ClearAllActions(TRUE);
                    SetActionMode(oCreature, ACTION_MODE_STEALTH, TRUE);
                    return;
                }
            }
            // Does not have hide in plain sight.
            else
            {
                string sEnemyIndex = IntToString(nEnemyIndex);
                float fEnemyDistance = GetLocalFloat(oCreature, AI_ENEMY_RANGE + sEnemyIndex);
                if(AI_DEBUG) ai_Debug("ai_ambusher", "61", "fDistance: " + FloatToString(fEnemyDistance, 0, 2));
                if(fEnemyDistance >= AI_RANGE_LONG)
                {
                    int bTried = GetLocalInt(oCreature, AI_TRIED_TO_HIDE);
                    if(!bTried)
                    {
                        // Move away so we can hide.
                        if(AI_DEBUG) ai_Debug("ai_ambusher", "68", GetName(oCreature) + " is trying to move away to hide!");
                        SetActionMode(oCreature, ACTION_MODE_STEALTH, FALSE);
                        object oEnemy = GetLocalObject(oCreature, AI_ENEMY + sEnemyIndex);
                        ActionMoveAwayFromObject(oEnemy, TRUE, AI_RANGE_BATTLEFIELD);
                        SetLocalInt(oCreature, AI_TRIED_TO_HIDE, 3);
                        return;
                    }
                    else SetLocalInt(oCreature, AI_TRIED_TO_HIDE, GetLocalInt(oCreature, AI_TRIED_TO_HIDE) - 1);
                }
                // We have been seen by an enemy too close to us so drop stealth.
                else SetActionMode(oCreature, ACTION_MODE_STEALTH, FALSE);
            }
        }
        // The enemy can see through stealth so lets drop it.
        else SetActionMode(oCreature, ACTION_MODE_STEALTH, FALSE);
    }
    // We are not in stealth mode so lets get there.
    else if(!GetActionMode(oCreature, ACTION_MODE_STEALTH))
    {
        // Use any hiding talents we have
        if(AI_DEBUG) ai_Debug("ai_ambusher", "88", GetName(oCreature) + " is trying to hide!");
        SetActionMode(oCreature, ACTION_MODE_STEALTH, TRUE);
        SetLocalInt(oCreature, AI_TRIED_TO_HIDE, 3);
        return;
    }
    // If we have givin up on stealth do our normal actions.
    string sScript = GetLocalString(oCreature, AI_DEFAULT_SCRIPT);
    if(sScript == "ai_ambusher" || sScript == "") sScript = "ai_default";
    if(AI_DEBUG) ai_Debug("ai_ambusher", "96", "sScript: " + sScript + " AI_DEFAULT_SCRIPT: " + GetLocalString(oCreature, AI_DEFAULT_SCRIPT));
    ExecuteScript(sScript, oCreature);
}
