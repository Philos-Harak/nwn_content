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
void main()
{
    object oCreature = OBJECT_SELF;
    int nInMelee = ai_GetNumOfEnemiesInRange(oCreature);
    object oNearestEnemy = GetLocalObject(oCreature, AI_ENEMY_NEAREST);
    if(ai_TryHealingTalent(oCreature, nInMelee)) return;
    if(ai_TryCureConditionTalent(oCreature, nInMelee)) return;
    if(GetPercentageHPLoss(oCreature) <= AI_HEALTH_BLOODY)
    {
        if(AI_DEBUG) ai_Debug("ai_polymorphed", "20", "We are wounded and are transforming back!");
        ai_RemoveASpecificEffect(oCreature, EFFECT_TYPE_POLYMORPH);
        DeleteLocalInt(oCreature, AI_POLYMORPHED);
        // We need to create the creatures normal forms talent list.
        DelayCommand(0.0, ai_ClearTalents(oCreature));
        DelayCommand(0.1, ai_SetCreatureTalents(oCreature, TRUE, TRUE));
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
    // ***************************  RANGED ATTACKS  ****************************
    object oTarget;
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
            else
            {
                ai_SearchForHiddenCreature(oCreature, TRUE);
                return;
            }
        }
        else if(ai_InCombatEquipBestRangedWeapon(oCreature)) return;
    }
    // ****************************  MELEE ATTACKS  ****************************
    oTarget = ai_GetNearestTargetForMeleeCombat(oCreature, nInMelee);
    if(oTarget != OBJECT_INVALID)     ActionAttack(oTarget);
//ai_ActionAttack(oCreature, AI_LAST_ACTION_MELEE_ATK, oTarget);
    else ai_SearchForHiddenCreature(oCreature, TRUE);
}
