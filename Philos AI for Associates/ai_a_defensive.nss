/*////////////////////////////////////////////////////////////////////////////////////////////////////
// Script Name: ai_a_defensive
//////////////////////////////////////////////////////////////////////////////////////////////////////
 ai script for associates put in to a defensive mode to protect themselves.
 OBJECT_SELF is the creature running the ai.
 Our actions.
 1 - Get nearest enemy and the difficulty of the battle.
 2 - Check for healing potions if this is a simple+ battle.
 3 - Check moral if wounded and is a simple+ battle.
 4 - Check for a magical ranged attack if not in melee and a difficult+ battle.
 5 - Check for a buff if this is a difficult+ battle.
 6 - Check for defensive ability such as knockdown, expertise or parry.
 7 - If we can't fight defensive then flee.
 8 - If we are out of range with no ability then stand and watch.
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
    object oNearestEnemy = GetLocalObject(oCreature, AI_ENEMY_NEAREST);
    //ai_Debug("ai_a_defensive", "27", "oNearest Enemy: " + GetName(oNearestEnemy) +
    //       " Distance to Nearest Enemy: " + FloatToString(GetDistanceToObject(oNearestEnemy), 0, 2));
    // Has our master told us to not use magic?
    int bUseMagic = !ai_GetAssociateMagicMode(oCreature, AI_MAGIC_NO_MAGIC);
    // ALWAYS - Check for healing and cure talents.
    if(bUseMagic)
    {
        if(ai_TryHealingTalent(oCreature, nInMelee)) return;
        if(ai_TryCureConditionTalent(oCreature, nInMelee)) return;
    }
    int nDifficulty = ai_GetDifficulty(oCreature);
    int nMaxLevel;
    // SIMPLE+ - Check for moral and get what spell power we should be using.
    if(nDifficulty >= AI_COMBAT_EFFORTLESS)
    {
        if(ai_MoralCheck(oCreature)) return;
        nMaxLevel = ai_GetAssociateTalentMaxLevel(oCreature, nDifficulty);
    }
    // DIFFICULT+ - Class talents, Offensive AOE's, Defensive talents, and Potion talents.
    if(nDifficulty >= AI_COMBAT_MODERATE)
    {
        // ************************** CLASS FEATURES ***************************
        if(ai_TryBardSongFeat(oCreature)) return;
        if(bUseMagic && !ai_GetAssociateMagicMode(oCreature, AI_MAGIC_OFFENSIVE_CASTING))
        {
            // ********** PROTECTION/ENHANCEMENT/SUMMON TALENTS ****************
            // Does our master want to be buffed first?
            object oTarget = OBJECT_INVALID;
            if (ai_GetAssociateMagicMode(oCreature, AI_MAGIC_BUFF_MASTER)) oTarget = GetMaster(oCreature);
            ai_TryDefensiveTalents(oCreature, nInMelee, nMaxLevel, oTarget);
        }
    }
    object oTarget;
    // PHYSICAL ATTACKS - Either we don't have talents or we are saving them.
    if(nInMelee > 0)
    {
        if(ai_TryImprovedExpertiseFeat(oCreature)) return;
        if(ai_TryExpertiseFeat(oCreature)) return;
        // Lets get the strongest melee opponent in melee with us.
        oTarget = ai_GetHighestCRTarget(oCreature, AI_RANGE_MELEE);
        if(oTarget == OBJECT_INVALID) oTarget = oNearestEnemy;
        // Use knockdown when appropriate and the target is not immune.
        if(ai_TryKnockdownFeat(oCreature, oTarget)) return;
        if (ai_TryParry (oCreature)) return;
        // We have tried everything to protect ourselves so the only thing left
        // to do is man up and attack!
        ai_DoPhysicalAttackOnLowestCR(oCreature, nInMelee, !ai_GetAssociateMode(oCreature, AI_MODE_CHECK_ATTACK));
        return;
    }
    //**********************  PHYSICAL ATTACKS  ********************************
    // Even in defensive mode we want to be in battle so go find someone!
    ai_DoPhysicalAttackOnLowestCR(oCreature, nInMelee, !ai_GetAssociateMode(oCreature, AI_MODE_CHECK_ATTACK), TRUE);
}
