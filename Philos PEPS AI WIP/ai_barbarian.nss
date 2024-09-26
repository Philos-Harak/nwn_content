/*//////////////////////////////////////////////////////////////////////////////
 Script Name: ai_barbarian
////////////////////////////////////////////////////////////////////////////////
 ai script for creatures using the class Barbarian.
 OBJECT_SELF is the creature running the ai.
////////////////////////////////////////////////////////////////////////////////
 Programmer: Philos
*///////////////////////////////////////////////////////////////////////////////
#include "0i_actions"
//#include "0i_actions_debug"
void main()
{
    object oCreature = OBJECT_SELF;
    // Get the number of enemies that we are in melee combat with.
    int nInMelee = ai_GetNumOfEnemiesInRange(oCreature);
    object oTarget;
    if(!GetHasFeatEffect(FEAT_BARBARIAN_RAGE, oCreature))
    {
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
        if(ai_TryBarbarianRageFeat(oCreature)) return;
        //**************************  DEFENSIVE TALENTS  ***************************
        if(ai_TryDefensiveTalents(oCreature, nInMelee, nMaxLevel)) return;
        //**********************  OFFENSIVE TARGETED TALENTS  **********************
        // Look for a touch attack since we are in melee.
        if(nInMelee > 0 && ai_UseCreatureTalent(oCreature, AI_TALENT_TOUCH, nInMelee, nMaxLevel)) return;
        if(ai_UseCreatureTalent(oCreature, AI_TALENT_RANGED, nInMelee, nMaxLevel)) return;
        // PHYSICAL ATTACKS - Either we don't have talents or we are saving them.
        // ***************************  RANGED ATTACKS  *****************************
        if(ai_CanIUseRangedWeapon(oCreature, nInMelee))
        {
            if(ai_HasRangedWeaponWithAmmo(oCreature))
            {
                if(!nInMelee) oTarget = ai_GetNearestTarget(oCreature);
                else oTarget = ai_GetNearestTarget(oCreature, AI_RANGE_MELEE);
                if(oTarget != OBJECT_INVALID)
                {
                    if(ai_TryRapidShotFeat(oCreature, oTarget, nInMelee)) return;
                    ai_ActionAttack(oCreature, AI_LAST_ACTION_RANGED_ATK, oTarget, nInMelee, TRUE);
                    return;
                }
                else if(ai_SearchForInvisibleCreature(oCreature)) return;
            }
            if(ai_InCombatEquipBestRangedWeapon(oCreature)) return;
        }
    }
    // *****************************  MELEE ATTACKS  ***************************
    if(ai_InCombatEquipBestMeleeWeapon(oCreature)) return;
    if(ai_TryWhirlwindFeat(oCreature)) return;
    oTarget = ai_GetNearestTargetForMeleeCombat(oCreature, nInMelee);
    if(oTarget != OBJECT_INVALID)
    {
        if(ai_TryMeleeTalents(oCreature, oTarget)) return;
        ai_ActionAttack(oCreature, AI_LAST_ACTION_MELEE_ATK, oTarget);
    }
    else ai_SearchForInvisibleCreature(oCreature);
}
