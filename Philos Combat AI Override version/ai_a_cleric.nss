/*////////////////////////////////////////////////////////////////////////////////////////////////////
// Script Name: ai_a_cleric
//////////////////////////////////////////////////////////////////////////////////////////////////////
 ai script for associates using the Cleric class.
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
    // Has our master told us to not use magic?
    int bUseMagic = !ai_GetAssociateMode(oCreature, AI_MODE_NO_MAGIC);
    //***************************  HEALING & CURES  ****************************
    if(bUseMagic)
    {
        if(ai_TryHealingTalent(oCreature, nInMelee)) return;
        if(ai_TryCureConditionTalent(oCreature, nInMelee)) return;
    }
    int nDifficulty = ai_GetDifficulty(oCreature);
    int nMaxLevel;
    // Check for moral and get the maximum spell level we should use.
    if(nDifficulty >= AI_COMBAT_SIMPLE)
    {
        if(ai_MoralCheck(oCreature)) return;
        nMaxLevel = ai_GetAssociateTalentMaxLevel(oCreature, nDifficulty);
    }
    // Skill, Class, Offensive AOE's, and Defensive talents.
    if(nDifficulty >= AI_COMBAT_DIFFICULT)
    {
        // *************************** SPELL TALENTS ***************************
        if(bUseMagic && ai_CheckForAssociateSpellTalent(oCreature, nInMelee, nMaxLevel)) return;
    }
    // SIMPLE+ - Offensive talents.
    if(nDifficulty >= AI_COMBAT_SIMPLE)
    {
        // ************************** CLASS FEATURES ***************************
        if(ai_TryTurningTalent(oCreature)) return;
        // *************************** SPELL TALENTS ***************************
        if(bUseMagic && !ai_GetAssociateMode(oCreature, AI_MODE_DEFENSIVE_CASTING))
        {
            if(nInMelee > 0 && ai_UseCreatureTalent(oCreature, AI_TALENT_TOUCH, nInMelee, nMaxLevel)) return;
            if(ai_UseCreatureTalent(oCreature, AI_TALENT_RANGED, nInMelee, nMaxLevel)) return;
        }
    }
    // PHYSICAL ATTACKS - Either we don't have talents or we are saving them.
    object oTarget = OBJECT_INVALID;
    // ************************** Ranged feat attacks **************************
    if(!ai_GetAssociateMode(oCreature, AI_MODE_STOP_RANGED) && ai_CanIUseRangedWeapon(oCreature, nInMelee))
    {
        // Are we suppose to protect our master first?
        if(ai_GetAssociateMode(oCreature, AI_MODE_DEFEND_MASTER)) oTarget = ai_GetLowestCRAttackerOnMaster(oCreature);
        if(oTarget == OBJECT_INVALID)
        {
            // Lets pick off the weakest targets.
            if(!nInMelee) oTarget = ai_GetLowestCRTarget(oCreature);
            else oTarget = ai_GetLowestCRTarget(oCreature, AI_RANGE_MELEE);
        }
        if(ai_TryRapidShotFeat(oCreature, oTarget, nInMelee)) return;
        ai_ActionAttack(oCreature, AI_LAST_ACTION_RANGED_ATK, oTarget, nInMelee, TRUE);
        return;
    }
    // ************************** Melee feat attacks *************************
    if(!ai_GetIsMeleeWeapon(GetItemInSlot(INVENTORY_SLOT_RIGHTHAND))) ai_EquipBestMeleeWeapon(oCreature, oTarget);
    if(ai_GetAssociateMode(oCreature, AI_MODE_DEFEND_MASTER)) oTarget = ai_GetLowestCRAttackerOnMaster(oCreature);
    if(oTarget == OBJECT_INVALID) oTarget = ai_GetLowestCRTargetForMeleeCombat(oCreature, nInMelee, !ai_GetAssociateMode(oCreature, AI_MODE_CHECK_ATTACK));
    if(oTarget != OBJECT_INVALID)
    {
        if(ai_TryHarmfulMeleeTalents(oCreature, oTarget)) return;
        if(ai_TryImprovedExpertiseFeat(oCreature, oTarget)) return;
        if(ai_TryExpertiseFeat(oCreature, oTarget)) return;
        ai_ActionAttack(oCreature, AI_LAST_ACTION_MELEE_ATK, oTarget);
    }
}
