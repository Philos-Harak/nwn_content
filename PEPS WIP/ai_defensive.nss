/*////////////////////////////////////////////////////////////////////////////////////////////////////
// Script Name: ai_defensive
//////////////////////////////////////////////////////////////////////////////////////////////////////
 ai script for creatures put in to a defensive mode to protect themselves(Any).
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
    object oNearestEnemy = GetLocalObject(oCreature, AI_ENEMY_NEAREST);
    //***************************  HEALING & CURES  ****************************
    if(ai_TryHealingTalent(oCreature, nInMelee)) return;
    if(ai_TryCureConditionTalent(oCreature, nInMelee)) return;
    if(nInMelee && ai_MoralCheck(oCreature)) return;
    int nMaxLevel = ai_GetMonsterTalentMaxLevel(oCreature);
    //****************************  SKILL FEATURES  ****************************
    if(ai_TryAnimalEmpathy(oCreature)) return;
    //****************************  CLASS FEATURES  ****************************
    if(ai_TryBardSongFeat(oCreature)) return;
    if(ai_TryTurningTalent(oCreature)) return;
    if(GetLocalInt(GetModule(), AI_RULE_SUMMON_COMPANIONS))
    {
        if(ai_TrySummonFamiliarTalent(oCreature)) return;
        if(ai_TrySummonAnimalCompanionTalent(oCreature)) return;
    }
    //**************************  DEFENSIVE TALENTS  ***************************
    if(ai_TryDefensiveTalents(oCreature, nInMelee, nMaxLevel)) return;
    //********************  DEFENSIVE MELEE FEATS  *****************************
    if(nInMelee > 0)
    {
        if(ai_TryImprovedExpertiseFeat(oCreature)) return;
        if(ai_TryExpertiseFeat(oCreature)) return;
        // Lets get the strongest melee opponent in melee with us.
        object oTarget = ai_GetHighestCRTargetForMeleeCombat(oCreature, nInMelee);
        if(oTarget == OBJECT_INVALID) oTarget = oNearestEnemy;
        // Use knockdown when appropriate and the target is not immune
        if(ai_TryKnockdownFeat(oCreature, oTarget)) return;
        if(ai_TryParry(oCreature)) return;
    }
    //**********************  PHYSICAL ATTACKS  ********************************
    // Even in defensive mode we want to be in battle so go find someone!
    ai_DoPhysicalAttackOnNearest(oCreature, nInMelee);
}
