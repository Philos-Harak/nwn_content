/*////////////////////////////////////////////////////////////////////////////////////////////////////
// Script Name: ai_a_ranged
//////////////////////////////////////////////////////////////////////////////////////////////////////
 ai script for associates to use the ranged ai.
 OBJECT_SELF is the creature running the ai.
 Will attempt to use ranged weapons until surrounded.
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
    int nDifficulty = ai_GetDifficulty(oCreature);
    int nMaxLevel;
    // Check for moral and get the maximum spell level we should use.
    if(nDifficulty >= AI_COMBAT_EFFORTLESS)
    {
        if(nInMelee && ai_MoralCheck(oCreature)) return;
        nMaxLevel = ai_GetAssociateTalentMaxLevel(oCreature, nDifficulty);
    }
    // Skill, Class, Offensive AOE's, and Defensive talents.
    if(nDifficulty >= AI_COMBAT_MODERATE)
    {
        //**************************  SKILL FEATURES  **************************
        if(ai_TryAnimalEmpathy(oCreature)) return;
        // ************************** CLASS FEATURES ***************************
        // Turning is basically a powerful AOE so treat it like one.
        if(ai_TryTurningTalent(oCreature)) return;
        if(ai_TryBarbarianRageFeat(oCreature)) return;
        if(ai_TryBardSongFeat(oCreature)) return;
        if(ai_TrySummonAnimalCompanionTalent(oCreature)) return;
        if(ai_TrySummonFamiliarTalent(oCreature)) return;
        // *************************** SPELL TALENTS ***************************
        if(ai_CheckForAssociateSpellTalent(oCreature, nInMelee, nMaxLevel)) return;
    }
    // Class and Offensive single target talents.
    if(nDifficulty >= AI_COMBAT_EFFORTLESS)
    {
        // ************************** CLASS FEATURES ***************************
        if(ai_TryTurningTalent(oCreature)) return;
        // *************************** SPELL TALENTS ***************************
        if(!ai_GetMagicMode(oCreature, AI_MAGIC_DEFENSIVE_CASTING))
        {
            if(nInMelee > 0 && ai_UseCreatureTalent(oCreature, AI_TALENT_TOUCH, nInMelee, nMaxLevel)) return;
            if(ai_UseCreatureTalent(oCreature, AI_TALENT_RANGED, nInMelee, nMaxLevel)) return;
        }
    }
    // PHYSICAL ATTACKS - Either we don't have talents or we are saving them.
    object oTarget;
    // ************************** Ranged feat attacks **************************
    if(!ai_GetAIMode(oCreature, AI_MODE_STOP_RANGED))
    {
        if(!GetHasFeatEffect(FEAT_BARBARIAN_RAGE, oCreature) &&
           nInMelee < 3)
        {
            if(ai_HasRangedWeaponWithAmmo(oCreature))
            {
                // Lets defend master, nearest favored enemy, ranged, sneak, weakest targets.
                if(!nInMelee)
                {
                    if(ai_GetAIMode(oCreature, AI_MODE_DEFEND_MASTER)) oTarget = ai_GetLowestCRAttackerOnMaster(oCreature);
                    if(oTarget == OBJECT_INVALID) oTarget = ai_GetNearestFavoredEnemyTarget(oCreature);
                    if(oTarget == OBJECT_INVALID) oTarget == ai_GetRangedTarget(oCreature);
                    if(oTarget == OBJECT_INVALID && ai_TryRangedSneakAttack(oCreature, nInMelee)) return;
                    if(oTarget == OBJECT_INVALID) oTarget = ai_GetLowestCRTarget(oCreature);
                }
                else
                {
                    if(ai_GetAIMode(oCreature, AI_MODE_DEFEND_MASTER)) oTarget = ai_GetLowestCRAttackerOnMaster(oCreature);
                    if(oTarget == OBJECT_INVALID) oTarget = ai_GetNearestFavoredEnemyTarget(oCreature, AI_RANGE_MELEE);
                    if(oTarget == OBJECT_INVALID) oTarget = ai_GetLowestCRTarget(oCreature, AI_RANGE_MELEE);
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
            if(ai_GetAIMode(oCreature, AI_MODE_DEFEND_MASTER)) oTarget = ai_GetLowestCRAttackerOnMaster(oCreature);
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
        if(GetIsAreaInterior(GetArea(oCreature))) fRange = AI_RANGE_CLOSE;
        if(GetHasFeat(FEAT_SNEAK_ATTACK, oCreature)) fRange = AI_RANGE_CLOSE;
        if(fDistance < fRange)
         {
            int bRun = ai_CanIMoveInCombat(oCreature);
            ActionMoveAwayFromObject(oNearestEnemy, bRun, fRange - fDistance + 2.0);
        }
    }
    else ai_SearchForHiddenCreature(oCreature, FALSE, OBJECT_INVALID, AI_RANGE_CLOSE);
}

