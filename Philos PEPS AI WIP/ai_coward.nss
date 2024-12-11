/*//////////////////////////////////////////////////////////////////////////////
 Script Name: ai_coward
////////////////////////////////////////////////////////////////////////////////
 ai script for cowardly creatures (Any) used when they fail a moral check or
 when associates are to remain out of combat.
 OBJECT_SELF is the creature running the ai.
////////////////////////////////////////////////////////////////////////////////
 Programmer: Philos
*///////////////////////////////////////////////////////////////////////////////
#include "0i_actions"
void main()
{
    object oCreature = OBJECT_SELF;
    // Get the number of enemies that we are in melee combat with us.
    int nInMelee = ai_GetNumOfEnemiesInRange(oCreature);
    object oNearestEnemy = GetLocalObject(oCreature, AI_ENEMY_NEAREST);
    // If we have been healed up then get back in there!
    if(ai_GetPercHPLoss(oCreature) > AI_HEALTH_WOUNDED)
    {
        string sDefaultCombatScript = GetLocalString(oCreature, AI_DEFAULT_SCRIPT);
        SetLocalString(oCreature, AI_COMBAT_SCRIPT, sDefaultCombatScript);
        ExecuteScript(sDefaultCombatScript, oCreature);
        return;
    }
    // In Melee combat!
    if(nInMelee)
    {
        if(ai_InCombatEquipBestMeleeWeapon(oCreature)) return;
        if(ai_TryImprovedExpertiseFeat(oCreature)) return;
        if(ai_TryExpertiseFeat(oCreature)) return;
        // Lets get the strongest melee opponent in melee with us.
        object oTarget = ai_GetHighestCRTargetForMeleeCombat(oCreature, nInMelee);
        if(oTarget == OBJECT_INVALID) oTarget = oNearestEnemy;
        // Use knockdown when appropriate and the target is not immune.
        if(ai_TryKnockdownFeat(oCreature, oTarget)) return;
        if (ai_TryParry(oCreature)) return;
        // We have tried everything to protect ourselves so the only thing left
        // to do is man up and attack!
        // Physical attacks are under TALENT_CATEGORY_HARMFUL_MELEE(22).
        ai_DoPhysicalAttackOnNearest(oCreature, nInMelee);
        return;
    }
    else
    {
        // If can turn invisible then we should probably do that!
        if(ai_UseTalent(oCreature, SPELL_IMPROVED_INVISIBILITY, oCreature)) return;
        if(ai_UseTalent(oCreature, SPELL_INVISIBILITY, oCreature)) return;
        if(ai_UseTalent(oCreature, SPELL_INVISIBILITY_SPHERE, oCreature)) return;
        if(ai_UseTalent(oCreature, SPELL_SANCTUARY, oCreature)) return;
        if(ai_UseTalent(oCreature, SPELL_ETHEREALNESS, oCreature)) return; // Greater Sanctuary
        if(ai_UseTalent(oCreature, SPELLABILITY_AS_IMPROVED_INVISIBLITY, oCreature)) return;
        if(ai_UseTalent(oCreature, SPELLABILITY_AS_INVISIBILITY, oCreature)) return;
        // If we are seen by the enemy we need to move back so we can hide.
        int nEnemyIndex = ai_GetNearestIndexThatSeesUs(oCreature);
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
            if(!bCanSeeInvisible)
            {
                if(GetHasFeat(FEAT_HIDE_IN_PLAIN_SIGHT, oCreature))
                {
                    if(!GetActionMode(oCreature, ACTION_MODE_STEALTH))
                    {
                        if(AI_DEBUG) ai_Debug("ai_coward", "74", GetName(oCreature) + " is using hide in plain sight!");
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
                    if(AI_DEBUG) ai_Debug("ai_coward", "85", "fDistance: " + FloatToString(fEnemyDistance, 0, 2));
                    if(fEnemyDistance >= AI_RANGE_CLOSE)
                    {
                        int bTried = GetLocalInt(oCreature, AI_TRIED_TO_HIDE);
                        if(!bTried)
                        {
                            // Move away so we can hide.
                            ai_Debug("ai_coward", "93", GetName(oCreature) + " is trying to move away to hide!");
                            SetActionMode(oCreature, ACTION_MODE_STEALTH, FALSE);
                            object oEnemy = GetLocalObject(oCreature, AI_ENEMY + sEnemyIndex);
                            ActionMoveAwayFromObject(oEnemy, TRUE, AI_RANGE_BATTLEFIELD);
                            SetLocalInt(oCreature, AI_TRIED_TO_HIDE, 3);
                            return;
                        }
                        else SetLocalInt(oCreature, AI_TRIED_TO_HIDE, GetLocalInt(oCreature, AI_TRIED_TO_HIDE) - 1);
                    }
                    // We have been seen by an enemy near us so drop stealth.
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
            ai_Debug("ai_coward", "113", GetName(oCreature) + " is trying to hide!");
            SetActionMode(oCreature, ACTION_MODE_STEALTH, TRUE);
            SetLocalInt(oCreature, AI_TRIED_TO_HIDE, 3);
            return;
        }
    }
    // Either we cannot go into stealth or we are in stealth so do something else.
    //*************************  OUT OF MELEE COMBAT  **************************
    //***************************  HEALING & CURES  ****************************
    if(ai_TryHealingTalent(oCreature, 0, oCreature)) return;
    if(ai_TryCureConditionTalent(oCreature, 0)) return;
    int nMaxLevel = ai_GetMonsterTalentMaxLevel(oCreature);
    //**************************  DEFENSIVE TALENTS  ***************************
    if(GetLocalInt(GetModule(), AI_RULE_SUMMON_COMPANIONS))
    {
        if(ai_TrySummonFamiliarTalent(oCreature)) return;
        if(ai_TrySummonAnimalCompanionTalent(oCreature)) return;
    }
    if(ai_TryDefensiveTalents(oCreature, nInMelee, nMaxLevel)) return;
    // Stand and watch the battle we don't want to provoke anyone!
    if(AI_DEBUG) ai_Debug("ai_coward", "132", GetName(oCreature) + " is holding here.");
}
