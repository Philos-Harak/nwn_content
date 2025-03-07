/*////////////////////////////////////////////////////////////////////////////////////////////////////
// Script Name: ai_ranged
//////////////////////////////////////////////////////////////////////////////////////////////////////
 ai script for monsters to use the ranged ai.
 OBJECT_SELF is the creature running the ai.
 Will attempt to use ranged weapons/spells until surrounded.
*/////////////////////////////////////////////////////////////////////////////////////////////////////
// Programmer: Philos
//////////////////////////////////////////////////////////////////////////////////////////////////////
#include "0i_actions"
void main()
{
    object oCreature = OBJECT_SELF;
    // Get the number of enemies that we are in melee combat with.
    int nInMelee = ai_GetNumOfEnemiesInRange(oCreature);
    //***************************  HEALING & CURES  ****************************
    if(ai_TryHealingTalent(oCreature, nInMelee)) return;
    if(ai_TryCureConditionTalent(oCreature, nInMelee)) return;
    // Check for moral and get the maximum spell level we should use.
    if(nInMelee && ai_MoralCheck(oCreature)) return;
    int nMaxLevel = ai_GetMonsterTalentMaxLevel(oCreature);
    //*******************  OFFENSIVE AREA OF EFFECT TALENTS  *******************
    // Check the battlefield for a group of enemies to shoot a big talent at!
    // We are checking here since these opportunities are rare and we need
    // to take advantage of them as often as possible.
    if(ai_UseCreatureTalent(oCreature, AI_TALENT_INDISCRIMINANT_AOE, nInMelee, nMaxLevel)) return;
    if(ai_UseCreatureTalent(oCreature, AI_TALENT_DISCRIMINANT_AOE, nInMelee, nMaxLevel)) return;
    //**************************  SKILL FEATURES  ******************************
    if(ai_TryAnimalEmpathy(oCreature)) return;
    // ************************** CLASS FEATURES *******************************
    if(ai_TryBardSongFeat(oCreature)) return;
    //**************************  DEFENSIVE TALENTS  ***************************
    int nRound = ai_GetCurrentRound(oCreature);
    if(ai_TryDefensiveTalents(oCreature, nInMelee, nMaxLevel, nRound)) return;
    // ************************** CLASS FEATURES *******************************
    if(ai_TryTurningTalent(oCreature)) return;
    //**********************  OFFENSIVE TARGETED TALENTS  **********************
    // Look for a touch attack since we are in melee.
    if(nInMelee > 0 && ai_UseCreatureTalent(oCreature, AI_TALENT_TOUCH, nInMelee, nMaxLevel)) return;
    if(ai_UseCreatureTalent(oCreature, AI_TALENT_RANGED, nInMelee, nMaxLevel)) return;
    // PHYSICAL ATTACKS - Either we don't have talents or we are saving them.
    object oTarget;
    // ************************** Ranged feat attacks **************************
    if(!GetHasFeatEffect(FEAT_BARBARIAN_RAGE, oCreature) &&
       (nInMelee < 3 || ai_GetEnemyAttackingMe(oCreature) == OBJECT_INVALID))
    {
        if(ai_HasRangedWeaponWithAmmo(oCreature))
        {
            if(ai_TryRangedSneakAttack(oCreature, nInMelee)) return;
            // Lets pick off the weaker targets.
            if(!nInMelee)
            {
                if(oTarget == OBJECT_INVALID) oTarget = ai_GetNearestFavoredEnemyTarget(oCreature);
                if(oTarget == OBJECT_INVALID) oTarget = ai_GetNearestTarget(oCreature);
            }
            else
            {
                if(oTarget == OBJECT_INVALID) oTarget = ai_GetNearestFavoredEnemyTarget(oCreature, AI_RANGE_MELEE);
                if(oTarget == OBJECT_INVALID) oTarget = ai_GetNearestTarget(oCreature, AI_RANGE_MELEE);
            }
            if(oTarget != OBJECT_INVALID)
            {
                if(ai_TryRapidShotFeat(oCreature, oTarget, nInMelee)) return;
                ai_ActionAttack(oCreature, AI_LAST_ACTION_RANGED_ATK, oTarget, nInMelee, TRUE);
                return;
            }
            else
            {
                ai_SearchForHiddenCreature(oCreature, FALSE, OBJECT_INVALID, AI_RANGE_CLOSE);
                return;
            }
        }
        else if(ai_InCombatEquipBestRangedWeapon(oCreature)) return;
    }
    // ************************** Melee feat attacks *************************
    object oNearestEnemy = GetLocalObject(oCreature, AI_ENEMY_NEAREST);
    if(nInMelee)
    {
        oTarget = ai_GetEnemyAttackingMe(oCreature);
        if(oTarget != OBJECT_INVALID)
        {
            if(ai_InCombatEquipBestMeleeWeapon(oCreature)) return;
            if(ai_TrySneakAttack(oCreature, nInMelee)) return;
            if(ai_TryWhirlwindFeat(oCreature)) return;
            if(oTarget == OBJECT_INVALID) oTarget = ai_GetNearestFavoredEnemyTarget(oCreature);
            if(oTarget == OBJECT_INVALID) oTarget = ai_GetNearestTargetForMeleeCombat(oCreature, nInMelee);
            if(oTarget != OBJECT_INVALID)
            {
                if(ai_TryMeleeTalents(oCreature, oTarget)) return;
                ai_ActionAttack(oCreature, AI_LAST_ACTION_MELEE_ATK, oTarget);
                return;
            }
        }
    }
    if(oNearestEnemy != OBJECT_INVALID)
    {
        float fDistance = GetDistanceBetween(oCreature, oNearestEnemy);
        float fRange = AI_RANGE_LONG;
        if(GetHasFeat(FEAT_SNEAK_ATTACK, oCreature)) fRange = AI_RANGE_CLOSE;
        if(fDistance < fRange)
         {
            int bRun = ai_CanIMoveInCombat(oCreature);
            ActionMoveAwayFromObject(oNearestEnemy, bRun, fRange - fDistance + 2.0);
        }
    }
    else ai_SearchForHiddenCreature(oCreature, FALSE, OBJECT_INVALID, AI_RANGE_CLOSE);
}

