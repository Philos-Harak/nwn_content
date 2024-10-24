/*////////////////////////////////////////////////////////////////////////////////////////////////////
// Script Name: ai_paladin
//////////////////////////////////////////////////////////////////////////////////////////////////////
 ai script for creatures using the class Paladin.
 Paladins face the strongest opponents on the battlefield first!
 OBJECT_SELF is the creature running the ai.
*/////////////////////////////////////////////////////////////////////////////////////////////////////
// Programmer: Philos
//////////////////////////////////////////////////////////////////////////////////////////////////////
//#include "0i_actions"
#include "0i_actions_debug"
void main()
{
    object oCreature = OBJECT_SELF;
    // Get the number of enemies that we are in melee combat with.
    int nInMelee = ai_GetNumOfEnemiesInRange(oCreature);
    //***************************  HEALING & CURES  ****************************
    if(ai_TryHealingTalent(oCreature, nInMelee)) return;
    if(ai_TryCureConditionTalent(oCreature, nInMelee)) return;
    if(ai_MoralCheck(oCreature)) return;
    int nMaxLevel = ai_GetMonsterTalentMaxLevel(oCreature);
    //*******************  OFFENSIVE AREA OF EFFECT TALENTS  *******************
    // Check the battlefield for a group of enemies to shoot a big talent at!
    // We are checking here since these opportunities are rare and we need
    // to take advantage of them as often as possible.
    if(ai_UseCreatureTalent(oCreature, AI_TALENT_INDISCRIMINANT_AOE, nInMelee, nMaxLevel)) return;
    if(ai_UseCreatureTalent(oCreature, AI_TALENT_DISCRIMINANT_AOE, nInMelee, nMaxLevel)) return;
    //****************************  CLASS FEATURES  ****************************
    if(ai_TryTurningTalent(oCreature)) return;
    //**************************  DEFENSIVE TALENTS  ***************************
    int nRound = ai_GetCurrentRound(oCreature);
    if(ai_TryDefensiveTalents(oCreature, nInMelee, nMaxLevel, nRound)) return;
    if(ai_TryDivineShieldFeat(oCreature, nInMelee)) return;
    if(ai_TryDivineMightFeat(oCreature, nInMelee)) return;
    //**********************  OFFENSIVE TARGETED TALENTS  **********************
    // Look for a touch attack since we are in melee.
    if(nInMelee > 0 && ai_UseCreatureTalent(oCreature, AI_TALENT_TOUCH, nInMelee, nMaxLevel)) return;
    if(ai_UseCreatureTalent(oCreature, AI_TALENT_RANGED, nInMelee, nMaxLevel)) return;
    // PHYSICAL ATTACKS - Either we don't have talents or we are saving them.
    // ************************  RANGED ATTACKS  *******************************
    object oTarget;
    if(ai_CanIUseRangedWeapon(oCreature, nInMelee))
    {
        if(ai_HasRangedWeaponWithAmmo(oCreature))
        {
            // Paladins face the biggest challenges first!
            if(!nInMelee) oTarget = ai_GetHighestCRTarget(oCreature);
            else oTarget = ai_GetHighestCRTarget(oCreature, AI_RANGE_MELEE);
            if(oTarget != OBJECT_INVALID)
            {
                ai_ActionAttack(oCreature, AI_LAST_ACTION_RANGED_ATK, oTarget, nInMelee, TRUE);
                return;
            }
            else
            {
                ai_SearchForInvisibleCreature(oCreature);
                return;
            }
        }
        else if(ai_InCombatEquipBestRangedWeapon(oCreature)) return;
    }
    // *************************  MELEE ATTACKS  *******************************
    if(ai_InCombatEquipBestMeleeWeapon(oCreature)) return;
    // Paladins face the biggest challenges first!
    oTarget = ai_GetHighestCRTargetForMeleeCombat(oCreature, nInMelee);
    if(oTarget != OBJECT_INVALID)
    {
        if(ai_TryMeleeTalents(oCreature, oTarget)) return;
        ai_ActionAttack(oCreature, AI_LAST_ACTION_MELEE_ATK, oTarget);
    }
    else ai_SearchForInvisibleCreature(oCreature);
}
