/*////////////////////////////////////////////////////////////////////////////////////////////////////
// Script Name: ai_dragon
//////////////////////////////////////////////////////////////////////////////////////////////////////
 ai script for dragons.
 OBJECT_SELF is the dragons running the ai.
*/////////////////////////////////////////////////////////////////////////////////////////////////////
// Programmer: Philos
//////////////////////////////////////////////////////////////////////////////////////////////////////
#include "0i_actions"
//#include "0i_actions_debug"
void main()
{
    object oCreature = OBJECT_SELF;
    // Get the number of enemies that we are in melee combat with.
    int nInMelee = ai_GetNumOfEnemiesInRange(oCreature);
    //***************************  HEALING & CURES  ****************************
    if(ai_TryHealingTalent(oCreature, nInMelee)) return;
    if(ai_TryCureConditionTalent(oCreature, nInMelee)) return;
    // Dragons do not flee! if(ai_MoralCheck(oCreature)) return;
    int nMaxLevel = ai_GetMonsterTalentMaxLevel(oCreature);
    //*******************  OFFENSIVE AREA OF EFFECT TALENTS  *******************
    // Check the battlefield for a group of enemies to shoot a big talent at!
    // We are checking here since these opportunities are rare and we need
    // to take advantage of them as often as possible.
    if(ai_UseCreatureTalent(oCreature, AI_TALENT_INDISCRIMINANT_AOE, nInMelee, nMaxLevel)) return;
    if(ai_UseCreatureTalent(oCreature, AI_TALENT_DISCRIMINANT_AOE, nInMelee, nMaxLevel)) return;
    //**************************  DEFENSIVE TALENTS  ***************************
    int nRound = ai_GetCurrentRound(oCreature);
    if(ai_TryDefensiveTalents(oCreature, nInMelee, nMaxLevel, nRound)) return;
    //**********************  OFFENSIVE TARGETED TALENTS  **********************
    // Look for a touch attack since we are in melee.
    if(nInMelee > 0 && ai_UseCreatureTalent(oCreature, AI_TALENT_TOUCH, nInMelee, nMaxLevel)) return;
    if(ai_UseCreatureTalent(oCreature, AI_TALENT_RANGED, nInMelee, nMaxLevel)) return;
    // ************************  MELEE ATTACKS  ********************************
    object oTarget = ai_GetLowestCRTargetForMeleeCombat(oCreature, nInMelee);
    if(oTarget != OBJECT_INVALID)
    {
        if(GetDistanceBetween(oCreature, oTarget) > AI_RANGE_CLOSE)
        {
            // Can we do a crush attack(HD 18+)?
            if(ai_TryCrushAttack(oCreature, oTarget)) return;
            ai_FlyToTarget(oCreature, oTarget);
            return;
        }
        if(ai_TryDragonBreathAttack(oCreature, nRound)) return;
        ai_TryWingAttacks(oCreature);
        // If we don't do a Tail sweep attack(HD 30+) then see if we can do a Tail slap(HD 12+)!
        if(!ai_TryTailSweepAttack(oCreature)) ai_TryTailSlap(oCreature);
        ai_ActionAttack(oCreature, AI_LAST_ACTION_MELEE_ATK, oTarget);
    }
    else ai_SearchForInvisibleCreature(oCreature);
}
