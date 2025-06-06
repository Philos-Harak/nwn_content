/*////////////////////////////////////////////////////////////////////////////////////////////////////
// Script Name: ai_a_sorcerer
//////////////////////////////////////////////////////////////////////////////////////////////////////
 ai script for associates using the Sorcerer class.
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
    // Has our master told us to not use magic?
    int bUseMagic = !ai_GetAssociateMagicMode(oCreature, AI_MAGIC_NO_MAGIC);
    //***************************  HEALING & CURES  ****************************
    if(bUseMagic)
    {
        if(ai_TryHealingTalent(oCreature, nInMelee)) return;
        if(ai_TryCureConditionTalent(oCreature, nInMelee)) return;
    }
    int nDifficulty = ai_GetDifficulty(oCreature);
    int nMaxLevel;
    // Check for moral and get the maximum spell level we should use.
    if(nDifficulty >= AI_COMBAT_EFFORTLESS)
    {
        if(ai_MoralCheck(oCreature)) return;
        nMaxLevel = ai_GetAssociateTalentMaxLevel(oCreature, nDifficulty);
    }
    // Skill, Class, Offensive AOE's, and Defensive talents.
    if(nDifficulty >= AI_COMBAT_MODERATE)
    {
        // *************************** SPELL TALENTS ***************************
        if(bUseMagic && ai_CheckForAssociateSpellTalent(oCreature, nInMelee, nMaxLevel)) return;
    }
    // Offensive single target talents.
    if(nDifficulty >= AI_COMBAT_EFFORTLESS)
    {
        if(bUseMagic && !ai_GetAssociateMagicMode(oCreature, AI_MAGIC_DEFENSIVE_CASTING))
        {
            if(nInMelee > 0 && ai_UseCreatureTalent(oCreature, AI_TALENT_TOUCH, nInMelee, nMaxLevel)) return;
            if(ai_UseCreatureTalent(oCreature, AI_TALENT_RANGED, nInMelee, nMaxLevel)) return;
        }
    }
    // PHYSICAL ATTACKS - Either we don't have talents or we are saving them.
    object oTarget;
    // ************************** Ranged feat attacks **************************
    if(!ai_GetAssociateMode(oCreature, AI_MODE_STOP_RANGED) && ai_CanIUseRangedWeapon(oCreature, nInMelee))
    {
        if(ai_HasRangedWeaponWithAmmo(oCreature))
        {
            // Are we suppose to protect our master first?
            if(ai_GetAssociateMode(oCreature, AI_MODE_DEFEND_MASTER)) oTarget = ai_GetLowestCRAttackerOnMaster(oCreature);
            if(oTarget == OBJECT_INVALID)
            {
                // Lets pick off the weakest targets.
                if(!nInMelee) oTarget = ai_GetLowestCRTarget(oCreature);
                else oTarget = ai_GetLowestCRTarget(oCreature, AI_RANGE_MELEE);
            }
            if(oTarget != OBJECT_INVALID)
            {
                ai_ActionAttack(oCreature, AI_LAST_ACTION_RANGED_ATK, oTarget, nInMelee, TRUE);
                return;
            }
            else if(ai_SearchForInvisibleCreature(oCreature)) return;
        }
        if(ai_InCombatEquipBestRangedWeapon(oCreature, TRUE)) return;
    }
    // ************************** Melee feat attacks *************************
    if(ai_InCombatEquipBestMeleeWeapon(oCreature, TRUE)) return;
    if(ai_GetAssociateMode(oCreature, AI_MODE_DEFEND_MASTER)) oTarget = ai_GetLowestCRAttackerOnMaster(oCreature);
    if(oTarget == OBJECT_INVALID) oTarget = ai_GetLowestCRTargetForMeleeCombat(oCreature, nInMelee, !ai_GetAssociateMode(oCreature, AI_MODE_CHECK_ATTACK));
    if(oTarget != OBJECT_INVALID) ai_ActionAttack(oCreature, AI_LAST_ACTION_MELEE_ATK, oTarget);
    else ai_SearchForInvisibleCreature(oCreature);
}
