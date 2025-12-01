/*////////////////////////////////////////////////////////////////////////////////////////////////////
// Script Name: ai_a_druid
//////////////////////////////////////////////////////////////////////////////////////////////////////
 ai script for associates using the Druid class.
 OBJECT_SELF is the creature running the ai.
*/////////////////////////////////////////////////////////////////////////////////////////////////////
// Programmer: Philos
//////////////////////////////////////////////////////////////////////////////////////////////////////
#include "0i_actions"
void main()
{
    object oCreature = OBJECT_SELF;
    // Get the number of enemies that we are in melee combat with.
    int nInMelee = ai_GetNumOfEnemiesInRange(oCreature);
    //***************************  HEALING & CURES  ****************************
    if(ai_TryHealingTalent(oCreature, nInMelee)) return;
    if(ai_TryCureConditionTalent(oCreature, nInMelee)) return;
    int nDifficulty = ai_GetDifficulty(oCreature);
    int nMaxLevel;
    // Check for moral and get the maximum spell level we should use.
    if(nDifficulty >= AI_COMBAT_EFFORTLESS)
    {
        if(nInMelee && ai_MoralCheck(oCreature)) return;
        nMaxLevel = ai_GetAssociateTalentMaxLevel(oCreature, nDifficulty);
    }
    // Skill, Class, Offensive AOE's, and Defensive talents.
    object oTarget = OBJECT_INVALID;
    // Get the Spell Level we should still cast before turning into our polymorph form.
    int nSpellLevel = ai_GetHasPolymorphSelfFeat(oCreature);
    int nMaxTalentLevel;
    if(AI_DEBUG) ai_Debug("ai_a_druid", "31", "nSpellLevel: " + IntToString(nSpellLevel));
    if(nDifficulty >= AI_COMBAT_MODERATE)
    {
        // *************************** SPELL TALENTS ***************************
        if(!ai_GetMagicMode(oCreature, AI_MAGIC_DEFENSIVE_CASTING))
        {
            if(ai_UseCreatureTalent(oCreature, AI_TALENT_INDISCRIMINANT_AOE, nInMelee, nMaxLevel)) return;
            if(ai_UseCreatureTalent(oCreature, AI_TALENT_DISCRIMINANT_AOE, nInMelee, nMaxLevel)) return;
        }
        // ************************** CLASS FEATURES ***************************
        if(ai_TrySummonAnimalCompanionTalent(oCreature)) return;
        //**************************  DEFENSIVE TALENTS  ***************************
        if(!ai_GetMagicMode(oCreature, AI_MAGIC_OFFENSIVE_CASTING))
        {
            if(ai_GetMagicMode(oCreature, AI_MAGIC_BUFF_MASTER)) oTarget = GetMaster(oCreature);
            nMaxTalentLevel = GetLocalInt(oCreature, AI_MAX_TALENT + AI_TALENT_SUMMON);
            if(AI_DEBUG) ai_Debug("ai_a_druid", "47", "nMaxTalentLevel 'S' " + IntToString(nMaxTalentLevel));
            if(nSpellLevel < nMaxTalentLevel &&
               ai_UseCreatureTalent(oCreature, AI_TALENT_SUMMON, nInMelee, nMaxLevel, oTarget)) return;
            nMaxTalentLevel = GetLocalInt(oCreature, AI_MAX_TALENT + AI_TALENT_PROTECTION);
            if(AI_DEBUG) ai_Debug("ai_a_druid", "51", "nMaxTalentLevel 'P' " + IntToString(nMaxTalentLevel));
            if(nSpellLevel < nMaxTalentLevel &&
               ai_UseCreatureTalent(oCreature, AI_TALENT_PROTECTION, nInMelee, nMaxLevel, oTarget)) return;
            nMaxTalentLevel = GetLocalInt(oCreature, AI_MAX_TALENT + AI_TALENT_ENHANCEMENT);
            if(AI_DEBUG) ai_Debug("ai_a_druid", "55", "nMaxTalentLevel 'E' " + IntToString(nMaxTalentLevel));
            if(nSpellLevel < nMaxTalentLevel &&
               ai_UseCreatureTalent(oCreature, AI_TALENT_ENHANCEMENT, nInMelee, nMaxLevel, oTarget)) return;
        }
    }
    // Offensive single target talents.
    if(nDifficulty >= AI_COMBAT_EFFORTLESS)
    {
        // *************************** SPELL TALENTS ***************************
        if(!ai_GetMagicMode(oCreature, AI_MAGIC_DEFENSIVE_CASTING))
        {
            if(nInMelee > 0)
            {
                nMaxTalentLevel = GetLocalInt(oCreature, AI_MAX_TALENT + AI_TALENT_TOUCH);
                if(AI_DEBUG) ai_Debug("ai_druid", "69", "nMaxTalentLevel 'T' " + IntToString(nMaxTalentLevel));
                if(nSpellLevel < nMaxTalentLevel &&
                   ai_UseCreatureTalent(oCreature, AI_TALENT_TOUCH, nInMelee, nMaxLevel)) return;
            }
            nMaxTalentLevel = GetLocalInt(oCreature, AI_MAX_TALENT + AI_TALENT_RANGED);
            if(AI_DEBUG) ai_Debug("ai_druid", "74", "nMaxTalentLevel 'R' " + IntToString(nMaxTalentLevel));
            if(nSpellLevel < nMaxTalentLevel &&
               ai_UseCreatureTalent(oCreature, AI_TALENT_RANGED, nInMelee, nMaxLevel)) return;
        }
        if(nDifficulty >= AI_COMBAT_MODERATE && ai_TryPolymorphSelfFeat(oCreature)) return;
    }
    //**************************  SKILL FEATURES  **************************
    if(ai_TryAnimalEmpathy(oCreature)) return;
    // PHYSICAL ATTACKS - Either we don't have talents or we are saving them.
    // ************************** Ranged feat attacks **************************
    if(!ai_GetAIMode(oCreature, AI_MODE_STOP_RANGED) && ai_CanIUseRangedWeapon(oCreature, nInMelee))
    {
        if(ai_HasRangedWeaponWithAmmo(oCreature))
        {
            // Are we suppose to protect our master first?
            if(ai_GetAIMode(oCreature, AI_MODE_DEFEND_MASTER)) oTarget = ai_GetLowestCRAttackerOnMaster(oCreature);
            if(oTarget == OBJECT_INVALID)
            {
                // Lets pick off the weakest targets.
                if(!nInMelee) oTarget = ai_GetLowestCRPhysicalTarget(oCreature);
                else oTarget = ai_GetLowestCRPhysicalTarget(oCreature, AI_RANGE_MELEE);
            }
            if(oTarget != OBJECT_INVALID)
            {
                if(ai_TryRangedTalents(oCreature, oTarget, nInMelee)) return;
                ai_ActionAttack(oCreature, AI_LAST_ACTION_RANGED_ATK, oTarget, nInMelee, TRUE);
                return;
            }
            else
            {
                ai_SearchForHiddenCreature(oCreature, FALSE);
                return;
            }
        }
        else if(ai_InCombatEquipBestRangedWeapon(oCreature)) return;
    }
    // ************************** Melee feat attacks *************************
    if(ai_InCombatEquipBestMeleeWeapon(oCreature)) return;
    if(ai_GetAIMode(oCreature, AI_MODE_DEFEND_MASTER)) oTarget = ai_GetLowestCRAttackerOnMaster(oCreature);
    if(oTarget == OBJECT_INVALID) oTarget = ai_GetBestTargetForMeleeCombat(oCreature, nInMelee, !ai_GetAIMode(oCreature, AI_MODE_CHECK_ATTACK));
    if(oTarget != OBJECT_INVALID)
    {
        if(ai_TryMeleeTalents(oCreature, oTarget)) return;
        ai_ActionAttack(oCreature, AI_LAST_ACTION_MELEE_ATK, oTarget);
    }
    else ai_SearchForHiddenCreature(oCreature, FALSE);
}
