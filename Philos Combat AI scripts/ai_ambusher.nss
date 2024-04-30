/*////////////////////////////////////////////////////////////////////////////////////////////////////
// Script Name: ai_ambusher
//////////////////////////////////////////////////////////////////////////////////////////////////////
 ai script for ambushing creatures (Any).
 OBJECT_SELF is the creature running the ai.
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
    // Check the battle field to see if anyone see us?
    int nEnemyIndex = ai_GetNearestIndexThatSeesUs(oCreature);
    int bTried = GetLocalInt(oCreature, "AI_TRIED_TO_HIDE");
    // If seen, tried to hide and out of combat then lets move away!
    if(nEnemyIndex)
    {
        string sEnemyIndex = IntToString(nEnemyIndex);
        object oEnemy = GetLocalObject(oCreature, AI_ENEMY + sEnemyIndex);
        float fEnemyDistance = GetLocalFloat(oCreature, AI_ENEMY + sEnemyIndex);
        //ai_Debug("ai_ambusher", "26", "bTried: " + IntToString(bTried) + " HPS: " +
        //         IntToString(!GetHasFeat(FEAT_HIDE_IN_PLAIN_SIGHT)) + " fDistance: " +
        //         FloatToString(fEnemyDistance, 0, 2));
        // If they see us and we have Hide in Plain sight then HIDE!
        if(GetHasFeat(FEAT_HIDE_IN_PLAIN_SIGHT, oCreature))
        {
            SetActionMode(oCreature, ACTION_MODE_STEALTH, TRUE);
        }
        else if(bTried && fEnemyDistance > AI_RANGE_CLOSE)
        {
            //ai_Debug("ai_ambusher", "36", GetName(oCreature) + " is trying to move away to hide!");
            // Move away so we can hide.
            SetActionMode(oCreature, ACTION_MODE_STEALTH, FALSE);
            ActionMoveAwayFromObject(oEnemy, TRUE, AI_RANGE_BATTLEFIELD);
            SetLocalInt(oCreature, "AI_TRIED_TO_HIDE", FALSE);
            return;
        }
        // We have been seen by our nearest enemy or a hostile attacker so drop stealth.
        else SetActionMode(oCreature, ACTION_MODE_STEALTH, FALSE);
    }
    // if we are not seen and we have not tried to hide then lets try.
    else if(!bTried)
    {
        // Use any hiding talents we have
        if(!TrySpell(SPELL_IMPROVED_INVISIBILITY, oCreature, oCreature) ||
           !TrySpell(SPELL_INVISIBILITY, oCreature, oCreature))
        {
            SetActionMode(oCreature, ACTION_MODE_STEALTH, TRUE);
        }
        SetLocalInt(oCreature, "AI_TRIED_TO_HIDE", TRUE);
        return;
    }
    // We are dropping out to do a normal action.
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
    //****************************  SKILL FEATURES  ****************************
    object oTarget = ai_GetNearestRacialTarget(oCreature, AI_RACIAL_TYPE_ANIMAL_BEAST);
    if(oTarget != OBJECT_INVALID && ai_TryAnimalEmpathy(oCreature, oTarget)) return;
    //****************************  CLASS FEATURES  ****************************
    if(ai_TryBarbarianRageFeat(oCreature)) return;
    if(ai_TryBardSongFeat(oCreature)) return;
    if(ai_TryTurningTalent(oCreature)) return;
    if(ai_TrySummonAnimalCompanionTalent(oCreature)) return;
    if(ai_TrySummonFamiliarTalent(oCreature)) return;
    //***************************  DEFENSIVE TALENTS  **************************
    if(ai_TryDefensiveTalents(oCreature, nInMelee, nMaxLevel)) return;
    //**********************  OFFENSIVE TARGETED TALENTS  **********************
    if(nInMelee > 0 && ai_UseCreatureTalent(oCreature, AI_TALENT_TOUCH, nInMelee, nMaxLevel)) return;
    if(ai_UseCreatureTalent(oCreature, AI_TALENT_RANGED, nInMelee, nMaxLevel)) return;
    // PHYSICAL ATTACKS - Either we don't have talents or we are saving them.
    ai_DoPhysicalAttackOnNearest(oCreature, nInMelee);
}
