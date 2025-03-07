/*////////////////////////////////////////////////////////////////////////////////////////////////////
// Script Name: ai_flanker
//////////////////////////////////////////////////////////////////////////////////////////////////////
 ai script for monsters to flank the enemy and not charge into combat.
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
    if(ai_TryHealingTalent(oCreature, nInMelee)) return;
    if(ai_TryCureConditionTalent(oCreature, nInMelee)) return;
    if(nInMelee && ai_MoralCheck(oCreature)) return;
    int nMaxLevel = ai_GetMonsterTalentMaxLevel(oCreature);
    //*****************  OFFENSIVE AREA OF EFFECT TALENTS  *********************
    // Check the battlefield for a group of enemies to shoot a big talent at!
    // We are checking here since these opportunities are rare and we need
    // to take advantage of them as often as possible.
    if(ai_UseCreatureTalent(oCreature, AI_TALENT_INDISCRIMINANT_AOE, nInMelee, nMaxLevel)) return;
    if(ai_UseCreatureTalent(oCreature, AI_TALENT_DISCRIMINANT_AOE, nInMelee, nMaxLevel)) return;
    // ***********************  DEFENSIVE TALENTS  *****************************
    int nRound = ai_GetCurrentRound(oCreature);
    if(ai_TryDefensiveTalents(oCreature, nInMelee, nMaxLevel, nRound)) return;
    //*******************  OFFENSIVE TARGETED TALENTS  *************************
    // Look for a touch attack since we are in melee.
    if(nInMelee > 0 && ai_UseCreatureTalent(oCreature, AI_TALENT_TOUCH, nInMelee, nMaxLevel)) return;
    if(ai_UseCreatureTalent(oCreature, AI_TALENT_RANGED, nInMelee, nMaxLevel)) return;
    // PHYSICAL ATTACKS - Either we don't have talents or we are saving them.
    object oTarget;
    // ************************** Melee feat attacks *************************
    // Lets get the nearest target that is attacking someone besides me. We want to flank!
    if(oTarget == OBJECT_INVALID)
    {
        if(!nInMelee) oTarget = ai_GetBestEnemyToFlankTarget(oCreature);
        // If there are few enemies then we can safely move around.
        else if(nInMelee < 3 || ai_CanIMoveInCombat(oCreature))
        {
            oTarget = ai_GetBestEnemyToFlankTarget(oCreature, AI_RANGE_MELEE);
        }
        // Ok we are in a serious fight so lets not give attack of opportunities.
        else oTarget = ai_GetNearestTarget(oCreature, AI_RANGE_MELEE);
    }
    // If there are no enemies being attacked then lets stay back.
    if(oTarget == OBJECT_INVALID)
    {
        if(nInMelee)
        {
            if(ai_InCombatEquipBestMeleeWeapon(oCreature)) return;
            // Lets get the strongest melee opponent in melee with us.
            object oTarget = ai_GetNearestTargetForMeleeCombat(oCreature, nInMelee);
            if(oTarget != OBJECT_INVALID)
            {
                ai_ActionAttack(oCreature, AI_LAST_ACTION_MELEE_ATK, oTarget);
                return;
            }
        }
        // ************************** Ranged feat attacks **************************
        if(!ai_GetAIMode(oCreature, AI_MODE_STOP_RANGED) && ai_CanIUseRangedWeapon(oCreature, nInMelee))
        {
            if(ai_HasRangedWeaponWithAmmo(oCreature))
            {
                if(ai_TryRangedSneakAttack(oCreature, nInMelee)) return;
                oTarget = ai_GetNearestTarget(oCreature);
                if(oTarget != OBJECT_INVALID)
                {
                    if(ai_TryRapidShotFeat(oCreature, oTarget, nInMelee)) return;
                    ai_ActionAttack(oCreature, AI_LAST_ACTION_RANGED_ATK, oTarget, nInMelee, TRUE);
                    return;
                }
            }
            else if(ai_InCombatEquipBestRangedWeapon(oCreature)) return;
            else
            {
                ai_SearchForHiddenCreature(oCreature, FALSE, OBJECT_INVALID, AI_RANGE_CLOSE);
                return;
            }
        }
    }
    if(oTarget != OBJECT_INVALID)
    {
        if(ai_InCombatEquipBestMeleeWeapon(oCreature)) return;
        if(ai_TryMeleeTalents(oCreature, oTarget)) return;
        ai_ActionAttack(oCreature, AI_LAST_ACTION_MELEE_ATK, oTarget);
        return;
    }
    ai_SearchForHiddenCreature(oCreature, FALSE, OBJECT_INVALID, AI_RANGE_CLOSE);
}
