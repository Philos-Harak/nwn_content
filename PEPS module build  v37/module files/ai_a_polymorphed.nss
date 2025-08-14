/*////////////////////////////////////////////////////////////////////////////////////////////////////
// Script Name: ai_a_polymorphed
//////////////////////////////////////////////////////////////////////////////////////////////////////
 ai script for polymorphed associates.
 We check for abilities based on the form we are using and if we should polymorph back.
 OBJECT_SELF is the creature running the ai.
*/////////////////////////////////////////////////////////////////////////////////////////////////////
// Programmer: Philos
//////////////////////////////////////////////////////////////////////////////////////////////////////
#include "0i_actions"
void main()
{
    object oCreature = OBJECT_SELF;
    int nInMelee = ai_GetNumOfEnemiesInRange(oCreature);
    object oNearestEnemy = GetLocalObject(oCreature, AI_ENEMY_NEAREST);
    if(ai_TryHealingTalent(oCreature, nInMelee)) return;
    if(ai_TryCureConditionTalent(oCreature, nInMelee)) return;
    if(GetPercentageHPLoss(oCreature) <= AI_HEALTH_BLOODY)
    {
        if(AI_DEBUG) ai_Debug("ai_a_polymorphed", "20", "We are wounded and are transforming back!");
        ai_RemoveASpecificEffect(oCreature, EFFECT_TYPE_POLYMORPH);
        DeleteLocalInt(oCreature, AI_POLYMORPHED);
        // We need to create the creatures normal forms talent list.
        DelayCommand(0.0, ai_ClearTalents(oCreature));
        DelayCommand(0.1, ai_SetCreatureTalents(oCreature, FALSE, TRUE));
        return;
    }
    int nDifficulty = ai_GetDifficulty(oCreature);
    int nMaxLevel;
    // Check for moral and get the maximum spell level we should use.
    if(nDifficulty >= AI_COMBAT_EFFORTLESS)
    {
        // When polymorphed we turn back then check moral.
        //if(nInMelee && ai_MoralCheck(oCreature)) return;
        nMaxLevel = ai_GetAssociateTalentMaxLevel(oCreature, nDifficulty);
    }
    // Skill, Class, Offensive AOE's, and Defensive talents.
    if(nDifficulty >= AI_COMBAT_MODERATE)
    {
        // *************************** SPELL TALENTS ***************************
        if(ai_CheckForAssociateSpellTalent(oCreature, nInMelee, nMaxLevel)) return;
    }
    // Class and Offensive single target talents.
    if(nDifficulty >= AI_COMBAT_EFFORTLESS)
    {
        // *************************** SPELL TALENTS ***************************
        if(!ai_GetMagicMode(oCreature, AI_MAGIC_DEFENSIVE_CASTING))
        {
            if(nInMelee > 0 && ai_UseCreatureTalent(oCreature, AI_TALENT_TOUCH, nInMelee, nMaxLevel)) return;
            if(ai_UseCreatureTalent(oCreature, AI_TALENT_RANGED, nInMelee, nMaxLevel)) return;
        }
    }
    // PHYSICAL ATTACKS - Either we don't have talents or we are saving them.
    object oTarget = ai_GetLowestCRTargetForMeleeCombat(oCreature, nInMelee);
    // If we don't find a target then we don't want to fight anyone!
    if(oTarget != OBJECT_INVALID) ai_ActionAttack(oCreature, AI_LAST_ACTION_MELEE_ATK, oTarget);
    else ai_SearchForHiddenCreature(oCreature, FALSE);
}
