/*//////////////////////////////////////////////////////////////////////////////
// Script Name: ai_wizard
////////////////////////////////////////////////////////////////////////////////
 ai script for creatures using the class Wizard.
 OBJECT_SELF is the creature running the ai.
////////////////////////////////////////////////////////////////////////////////
 Programmer: Philos
*///////////////////////////////////////////////////////////////////////////////
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
    // **************************  CLASS FEATURES  ****************************
    if(GetLocalInt(GetModule(), AI_RULE_SUMMON_COMPANIONS) && ai_TrySummonFamiliarTalent(oCreature)) return;
    //**************************  DEFENSIVE TALENTS  ***************************
    int nRound = ai_GetCurrentRound(oCreature);
    if(ai_TryDefensiveTalents(oCreature, nInMelee, nMaxLevel, nRound)) return;
    //*********************  OFFENSIVE TARGETED TALENTS  ***********************
    // Look for a touch attack since we are in melee.
    if(nInMelee > 0 && ai_UseCreatureTalent(oCreature, AI_TALENT_TOUCH, nInMelee, nMaxLevel)) return;
    if(ai_UseCreatureTalent(oCreature, AI_TALENT_RANGED, nInMelee, nMaxLevel)) return;
    // PHYSICAL ATTACKS - Either we don't have talents or we are saving them.
    // **************************  RANGED ATTACKS  *****************************
    object oTarget;
    if(ai_CanIUseRangedWeapon(oCreature, nInMelee))
    {
        if(ai_HasRangedWeaponWithAmmo(oCreature))
        {
            if(!nInMelee) oTarget = ai_GetNearestPhysicalTarget(oCreature);
            else oTarget = ai_GetNearestPhysicalTarget(oCreature, AI_RANGE_MELEE);
            if(oTarget != OBJECT_INVALID)
            {
                ai_ActionAttack(oCreature, AI_LAST_ACTION_RANGED_ATK, oTarget, nInMelee, TRUE);
                return;
            }
            else
            {
                ai_SearchForHiddenCreature(oCreature, TRUE, OBJECT_INVALID, AI_RANGE_CLOSE);
                return;
            }
        }
        else if(ai_InCombatEquipBestRangedWeapon(oCreature)) return;
    }
    // *************************  MELEE ATTACKS  *******************************
    if(ai_InCombatEquipBestMeleeWeapon(oCreature)) return;
    oTarget = ai_GetNearestTargetForMeleeCombat(oCreature, nInMelee, TRUE);
    // I have a target now lets see if we want to move in!
    if(oTarget != OBJECT_INVALID) ai_ActionAttack(oCreature, AI_LAST_ACTION_MELEE_ATK, oTarget);
    else ai_SearchForHiddenCreature(oCreature, TRUE, OBJECT_INVALID, AI_RANGE_CLOSE);
}
