/*////////////////////////////////////////////////////////////////////////////////////////////////////
// Script Name: ai_invisible
//////////////////////////////////////////////////////////////////////////////////////////////////////
 ai script for creatures(Any) that are invisible.
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
    if(nInMelee && ai_MoralCheck(oCreature)) return;
    int nMaxLevel = ai_GetMonsterTalentMaxLevel(oCreature);
    // Skill, Class, Offensive AOE's, and Defensive talents.
    // *************************** SPELL TALENTS ***************************
    // ********** PROTECTION/ENHANCEMENT/SUMMON TALENTS ************
    int nRound = ai_GetCurrentRound(oCreature);
    if(ai_TryDefensiveTalents(oCreature, nInMelee, nMaxLevel, nRound)) return;
    // ************************** CLASS FEATURES ***************************
    if(GetLocalInt(GetModule(), AI_RULE_SUMMON_COMPANIONS))
    {
        if(ai_TrySummonFamiliarTalent(oCreature)) return;
        if(ai_TrySummonAnimalCompanionTalent(oCreature)) return;
    }
    // ******************* OFFENSIVE AOE TALENTS ***********************
    // Check the battlefield for a group of enemies to shoot a big spell at!
    // We are checking here since these opportunities are rare and we need
    // to take advantage of them as often as possible.
    if(ai_UseCreatureTalent(oCreature, AI_TALENT_INDISCRIMINANT_AOE, nInMelee, nMaxLevel)) return;
    if(ai_UseCreatureTalent(oCreature, AI_TALENT_DISCRIMINANT_AOE, nInMelee, nMaxLevel)) return;
    if(nInMelee > 0 && ai_UseCreatureTalent(oCreature, AI_TALENT_TOUCH, nInMelee, nMaxLevel)) return;
    if(ai_UseCreatureTalent(oCreature, AI_TALENT_RANGED, nInMelee, nMaxLevel)) return;
    // PHYSICAL ATTACKS - Either we don't have talents or we are saving them.
    object oTarget;
    // PHYSICAL ATTACKS - Either we don't have talents or we are saving them.
    // If we won't loose invisibility then ranged attacks are ok!
    // ************************  RANGED ATTACKS  *******************************
    if(GetHasSpellEffect(SPELL_IMPROVED_INVISIBILITY) || GetHasSpellEffect(SPELLABILITY_AS_IMPROVED_INVISIBLITY))
    {
        if(ai_CanIUseRangedWeapon(oCreature, nInMelee))
        {
            if(ai_HasRangedWeaponWithAmmo(oCreature))
            {
                if(!nInMelee) oTarget = ai_GetNearestPhysicalTarget(oCreature);
                else oTarget = ai_GetNearestPhysicalTarget(oCreature, AI_RANGE_MELEE);
                if(oTarget != OBJECT_INVALID)
                {
                    if(ai_TryRangedTalents(oCreature, oTarget, nInMelee)) return;
                    ai_ActionAttack(oCreature, AI_LAST_ACTION_RANGED_ATK, oTarget, nInMelee, TRUE);
                    return;
                }
                else
                {
                    ai_SearchForHiddenCreature(oCreature, TRUE);
                    return;
                }
            }
        }
        else if(ai_InCombatEquipBestRangedWeapon(oCreature)) return;
    }
    // ************************** Melee feat attacks *************************
    if(ai_InCombatEquipBestMeleeWeapon(oCreature)) return;
    if(ai_TrySneakAttack(oCreature, nInMelee)) return;
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
    else ai_SearchForHiddenCreature(oCreature, TRUE);
}
