/*////////////////////////////////////////////////////////////////////////////////////////////////////
// Script Name: ai_polymorphed
//////////////////////////////////////////////////////////////////////////////////////////////////////
 ai script for polymorphed creatures.
 We check for abilities based on the form we are using and if we should polymorph back.
 OBJECT_SELF is the creature running the ai.
*/////////////////////////////////////////////////////////////////////////////////////////////////////
// Programmer: Philos
//////////////////////////////////////////////////////////////////////////////////////////////////////
#include "0i_actions"
void ai_DoActions(object oCreature, int nForm)
{
    int nInMelee = ai_GetNumOfEnemiesInRange(oCreature);
    object oNearestEnemy = GetLocalObject(oCreature, AI_ENEMY_NEAREST);
    if(ai_TryHealingTalent(oCreature, nInMelee)) return;
    if(ai_TryCureConditionTalent(oCreature, nInMelee)) return;
    if(GetPercentageHPLoss(oCreature) <= AI_HEALTH_BLOODY)
    {
        if(AI_DEBUG) ai_Debug("ai_polymorphed", "19", "We are wounded and are transforming back!");
        ai_RemoveASpecificEffect(oCreature, EFFECT_TYPE_POLYMORPH);
        return;
    }
    int nMaxLevel = ai_GetMonsterTalentMaxLevel(oCreature);
    // When polymorphed we turn back then check moral.
    // if(nInMelee && ai_MoralCheck(oCreature)) return;
    // Skill, Class, Offensive AOE's, and Defensive talents.
    // *************************** SPELL TALENTS ***************************
    if(ai_CheckForAssociateSpellTalent(oCreature, nInMelee, nMaxLevel)) return;
    // Class and Offensive single target talents.
    // *************************** SPELL TALENTS ***************************
    if(nInMelee > 0 && ai_UseCreatureTalent(oCreature, AI_TALENT_TOUCH, nInMelee, nMaxLevel)) return;
    if(ai_UseCreatureTalent(oCreature, AI_TALENT_RANGED, nInMelee, nMaxLevel)) return;
    // PHYSICAL ATTACKS - Either we don't have talents or we are saving them.
    object oTarget = ai_GetNearestTargetForMeleeCombat(oCreature, nInMelee);
    // If we don't find a target then we don't want to fight anyone!
    if(oTarget != OBJECT_INVALID) ai_ActionAttack(oCreature, AI_LAST_ACTION_MELEE_ATK, oTarget);
    else ai_SearchForHiddenCreature(oCreature, TRUE);
}
void main()
{
    object oCreature = OBJECT_SELF;
    // Need to know who we are so we can use thier abilities.
    int nForm = GetAppearanceType(oCreature);
    // Check to see if we are back to our normal form?(-1 to get the actual form #)
    if(nForm == GetLocalInt(oCreature, AI_NORMAL_FORM) - 1)
    {
        // If we are transformed back then go back to our primary ai.
        ai_SetCreatureAIScript(oCreature);
        DeleteLocalInt(oCreature, AI_NORMAL_FORM);
        string sAI = GetLocalString(oCreature, AI_COMBAT_SCRIPT);
        if(sAI == "ai_polymorphed" || sAI == "") sAI = "ai_default";
        ExecuteScript(sAI, oCreature);
    }
    else ai_DoActions(oCreature, nForm);
}
