/*////////////////////////////////////////////////////////////////////////////////////////////////////
// Script Name: ai_a_invisible
//////////////////////////////////////////////////////////////////////////////////////////////////////
 ai script for associates to use when they are invisible.
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
    // Has our master told us to not use magic?
    int bUseMagic = !ai_GetMagicMode(oCreature, AI_MAGIC_NO_MAGIC);
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
    if(nDifficulty >= AI_COMBAT_EASY)
    {
        // *************************** SPELL TALENTS ***************************
        if(ai_GetMagicMode(oCreature, AI_MAGIC_OFFENSIVE_CASTING)) return;
        // ********** PROTECTION/ENHANCEMENT/SUMMON TALENTS ************
        // Does our master want to be buffed first?
        object oTarget = OBJECT_INVALID;
        if(ai_GetMagicMode(oCreature, AI_MAGIC_BUFF_MASTER)) oTarget = GetMaster(oCreature);
        int nRound = ai_GetCurrentRound(oCreature);
        if(ai_TryDefensiveTalents(oCreature, nInMelee, nMaxLevel, nRound, oTarget)) return;
        // ************************** CLASS FEATURES ***************************
        if(ai_TrySummonAnimalCompanionTalent(oCreature)) return;
        if(ai_TrySummonFamiliarTalent(oCreature)) return;
    }
    // Class and Offensive single target talents.
    if(nDifficulty >= AI_COMBAT_EFFORTLESS)
    {
        // *************************** SPELL TALENTS ***************************
        if(!ai_GetMagicMode(oCreature, AI_MAGIC_DEFENSIVE_CASTING))
        {
            // ******************* OFFENSIVE AOE TALENTS ***********************
            // Check the battlefield for a group of enemies to shoot a big spell at!
            // We are checking here since these opportunities are rare and we need
            // to take advantage of them as often as possible.
            if(!ai_GetMagicMode(oCreature, AI_MAGIC_DEFENSIVE_CASTING))
            {
                if(ai_UseCreatureTalent(oCreature, AI_TALENT_INDISCRIMINANT_AOE, nInMelee, nMaxLevel)) return;
                if(ai_UseCreatureTalent(oCreature, AI_TALENT_DISCRIMINANT_AOE, nInMelee, nMaxLevel)) return;
            }
            if(nInMelee > 0 && ai_UseCreatureTalent(oCreature, AI_TALENT_TOUCH, nInMelee, nMaxLevel)) return;
            if(ai_UseCreatureTalent(oCreature, AI_TALENT_RANGED, nInMelee, nMaxLevel)) return;
        }
    }
    // PHYSICAL ATTACKS - Either we don't have talents or we are saving them.
    object oTarget;
    // ************************** Melee feat attacks *************************
    // If we won't loose invisibility then ranged attacks are ok!
    // ************************  RANGED ATTACKS  *******************************
    if(GetHasSpellEffect(SPELL_IMPROVED_INVISIBILITY) || GetHasSpellEffect(SPELLABILITY_AS_IMPROVED_INVISIBLITY))
    {
        if(!ai_GetAIMode(oCreature, AI_MODE_STOP_RANGED) && ai_CanIUseRangedWeapon(oCreature, nInMelee))
        {
            if(ai_HasRangedWeaponWithAmmo(oCreature))
            {
                // Are we suppose to protect our master first?
                if(ai_GetAIMode(oCreature, AI_MODE_DEFEND_MASTER)) oTarget = ai_GetLowestCRAttackerOnMaster(oCreature);
                if(oTarget == OBJECT_INVALID)
                {
                    // Lets pick off the weakest targets.
                    if(!nInMelee) oTarget = ai_GetLowestCRTarget(oCreature);
                    else oTarget = ai_GetLowestCRTarget(oCreature, AI_RANGE_MELEE);
                }
                if(oTarget != OBJECT_INVALID)
                {
                    if(ai_TryRapidShotFeat(oCreature, oTarget, nInMelee)) return;
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
    }
    if(ai_InCombatEquipBestMeleeWeapon(oCreature)) return;
    if(ai_TrySneakAttack(oCreature, nInMelee)) return;
    if(ai_GetAIMode(oCreature, AI_MODE_DEFEND_MASTER)) oTarget = ai_GetLowestCRAttackerOnMaster(oCreature);
    if(oTarget == OBJECT_INVALID) oTarget = ai_GetNearestFavoredEnemyTarget(oCreature);
    if(oTarget == OBJECT_INVALID) oTarget = ai_GetLowestCRTargetForMeleeCombat(oCreature, nInMelee);
    if(oTarget != OBJECT_INVALID)
    {
        talent tUse = GetCreatureTalentBest(TALENT_CATEGORY_HARMFUL_MELEE, 20, oCreature);
        if(GetIsTalentValid(tUse))
        {
            int nId = GetIdFromTalent(tUse);
            if(nId == FEAT_POWER_ATTACK) { if(ai_TryPowerAttackFeat(oCreature, oTarget)) return; }
            else if(nId == FEAT_KNOCKDOWN) { if(ai_TryKnockdownFeat(oCreature, oTarget)) return; }
            else if(nId == FEAT_SMITE_EVIL) { if(ai_TrySmiteEvilFeat(oCreature, oTarget)) return; }
            else if(nId == FEAT_SMITE_GOOD) { if(ai_TrySmiteGoodFeat(oCreature, oTarget)) return; }
            else if(nId == FEAT_IMPROVED_POWER_ATTACK) { if(ai_TryImprovedPowerAttackFeat(oCreature, oTarget)) return; }
            else if(nId == FEAT_FLURRY_OF_BLOWS) { if(ai_TryFlurryOfBlowsFeat(oCreature, oTarget)) return; }
            else if(nId == FEAT_STUNNING_FIST) { if(ai_TryStunningFistFeat(oCreature, oTarget)) return; }
            else if(nId == FEAT_SAP) { if(ai_TrySapFeat(oCreature, oTarget)) return; }
            else if(nId == FEAT_DISARM) { if(ai_TryDisarmFeat(oCreature, oTarget)) return; }
            else if(nId == FEAT_KI_DAMAGE) { if(ai_TryKiDamageFeat(oCreature, oTarget)) return; }
            else if(nId == FEAT_CALLED_SHOT) { if(ai_TryCalledShotFeat(oCreature, oTarget)) return; }
        }
        ai_ActionAttack(oCreature, AI_LAST_ACTION_MELEE_ATK, oTarget);
    }
    else ai_SearchForHiddenCreature(oCreature, FALSE);
}

