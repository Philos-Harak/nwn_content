/*////////////////////////////////////////////////////////////////////////////////////////////////////
// Script Name: ai_default
//////////////////////////////////////////////////////////////////////////////////////////////////////
 ai script for default creatures(Any).
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
    //***************************  HEALING & CURES  ****************************
    if(ai_TryHealingTalent(oCreature, nInMelee)) return;
    if(ai_TryCureConditionTalent(oCreature, nInMelee)) return;
    if(nInMelee && ai_MoralCheck(oCreature)) return;
    int nMaxLevel = ai_GetMonsterTalentMaxLevel(oCreature);
    //*******************  OFFENSIVE AREA OF EFFECT TALENTS  *******************
    // Check the battlefield for a group of enemies to shoot a big talent at!
    // We are checking here since these opportunities are rare and we need
    // to take advantage of them as often as possible.
    if(ai_UseCreatureTalent(oCreature, AI_TALENT_INDISCRIMINANT_AOE, nInMelee, nMaxLevel)) return;
    if(ai_UseCreatureTalent(oCreature, AI_TALENT_DISCRIMINANT_AOE, nInMelee, nMaxLevel)) return;
    //****************************  SKILL FEATURES  ****************************
    if(ai_TryAnimalEmpathy(oCreature)) return;
    //****************************  CLASS FEATURES  ****************************
    if(GetLocalInt(GetModule(), AI_RULE_SUMMON_COMPANIONS))
    {
        if(ai_TrySummonFamiliarTalent(oCreature)) return;
        if(ai_TrySummonAnimalCompanionTalent(oCreature)) return;
    }
    //**************************  DEFENSIVE TALENTS  ***************************
    int nRound = ai_GetCurrentRound(oCreature);
    if(ai_TryDefensiveTalents(oCreature, nInMelee, nMaxLevel, nRound)) return;
    if(ai_TryDivineShieldFeat(oCreature, nInMelee)) return;
    if(ai_TryDivineMightFeat(oCreature, nInMelee)) return;
    //**********************  OFFENSIVE TARGETED TALENTS  **********************
    // Look for a touch attack since we are in melee.
    if(nInMelee > 0 && ai_UseCreatureTalent(oCreature, AI_TALENT_TOUCH, nInMelee, nMaxLevel)) return;
    if(ai_UseCreatureTalent(oCreature, AI_TALENT_RANGED, nInMelee, nMaxLevel)) return;
    //****************************  CLASS FEATURES  ****************************
    if(ai_TryPolymorphSelfFeat(oCreature)) return;
    if(ai_TryBarbarianRageFeat(oCreature)) return;
    if(ai_TryBardSongFeat(oCreature)) return;
    if(ai_TryTurningTalent(oCreature)) return;
    // PHYSICAL ATTACKS - Either we don't have talents or we are saving them.
    ai_DoPhysicalAttackOnNearest(oCreature, nInMelee);
}
