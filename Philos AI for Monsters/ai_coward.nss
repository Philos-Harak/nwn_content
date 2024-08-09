/*//////////////////////////////////////////////////////////////////////////////
 Script Name: ai_coward
////////////////////////////////////////////////////////////////////////////////
 ai script for cowardly creatures (Any) used when they fail a moral check or
 when associates are to remain out of combat.
 OBJECT_SELF is the creature running the ai.
////////////////////////////////////////////////////////////////////////////////
 Programmer: Philos
*///////////////////////////////////////////////////////////////////////////////
#include "0i_actions"
//#include "0i_actions_debug"
void main()
{
    object oCreature = OBJECT_SELF;
    // Get the number of enemies that we are in melee combat with us.
    int nInMelee = ai_GetNumOfEnemiesInRange(oCreature);
    object oNearestEnemy = GetLocalObject(oCreature, AI_ENEMY_NEAREST);
    // If we have been healed up then get back in there!
    if(ai_GetPercHPLoss(oCreature) > AI_HEALTH_WOUNDED)
    {
        string sDefaultCombatScript = GetLocalString(oCreature, AI_DEFAULT_SCRIPT);
        SetLocalString(oCreature, AI_COMBAT_SCRIPT, sDefaultCombatScript);
        ExecuteScript(sDefaultCombatScript, oCreature);
        return;
    }
    // In Melee combat!
    if(nInMelee > 0)
    {
        if(ai_InCombatEquipBestMeleeWeapon(oCreature)) return;
        if(ai_TryImprovedExpertiseFeat(oCreature)) return;
        if(ai_TryExpertiseFeat(oCreature)) return;
        // Lets get the strongest melee opponent in melee with us.
        object oTarget = ai_GetHighestCRTargetForMeleeCombat(oCreature, nInMelee);
        if(oTarget == OBJECT_INVALID) oTarget = oNearestEnemy;
        // Use knockdown when appropriate and the target is not immune.
        if(ai_TryKnockdownFeat(oCreature, oTarget)) return;
        if (ai_TryParry(oCreature)) return;
        // We have tried everything to protect ourselves so the only thing left
        // to do is man up and attack!
        // Physical attacks are under TALENT_CATEGORY_HARMFUL_MELEE(22).
        ai_DoPhysicalAttackOnNearest(oCreature, nInMelee);
        return;
    }
    //*************************  OUT OF MELEE COMBAT  **************************
    //***************************  HEALING & CURES  ****************************
    if(ai_TryHealingTalent(oCreature, 0, oCreature)) return;
    if(ai_TryCureConditionTalent(oCreature, 0)) return;
    int nMaxLevel = ai_GetMonsterTalentMaxLevel(oCreature);
    //**************************  DEFENSIVE TALENTS  ***************************
    if(ai_TryDefensiveTalents(oCreature, nInMelee, nMaxLevel)) return;
    // Stand and watch the battle we don't want to provoke anyone!
}
