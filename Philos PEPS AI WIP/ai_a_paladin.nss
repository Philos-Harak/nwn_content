/*////////////////////////////////////////////////////////////////////////////////////////////////////
// Script Name: ai_a_paladin
//////////////////////////////////////////////////////////////////////////////////////////////////////
 ai script for associates using the Paladin class.
 Paladins always protect their masters and face the strongest opponents first!
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
        if(nInMelee && ai_MoralCheck(oCreature)) return;
        nMaxLevel = ai_GetAssociateTalentMaxLevel(oCreature, nDifficulty);
    }
    // Skill, Class, Offensive AOE's, and Defensive talents.
    if(nDifficulty >= AI_COMBAT_MODERATE)
    {
        // *************************** SPELL TALENTS ***************************
        if(bUseMagic)
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
            if(!ai_GetMagicMode(oCreature, AI_MAGIC_OFFENSIVE_CASTING))
            {
                // ********** PROTECTION/ENHANCEMENT/SUMMON TALENTS ************
                // Does our master want to be buffed first?
                object oTarget = OBJECT_INVALID;
                if(ai_GetMagicMode(oCreature, AI_MAGIC_BUFF_MASTER)) oTarget = GetMaster(oCreature);
                if(ai_TryDefensiveTalents(oCreature, nInMelee, nMaxLevel, 0, oTarget)) return;
                if(ai_TryDivineShieldFeat(oCreature, nInMelee)) return;
                if(ai_TryDivineMightFeat(oCreature, nInMelee)) return;
            }
        }
    }
    // Class and Offensive single target talents.
    if(nDifficulty >= AI_COMBAT_EFFORTLESS)
    {
        // ************************** CLASS FEATURES ***************************
        if(ai_TryTurningTalent(oCreature)) return;
        if(ai_TryLayOnHands(oCreature)) return;
        // *************************** SPELL TALENTS ***************************
        if(bUseMagic && !ai_GetMagicMode(oCreature, AI_MAGIC_DEFENSIVE_CASTING))
        {
            if(nInMelee > 0 && ai_UseCreatureTalent(oCreature, AI_TALENT_TOUCH, nInMelee, nMaxLevel)) return;
            if(ai_UseCreatureTalent(oCreature, AI_TALENT_RANGED, nInMelee, nMaxLevel)) return;
        }
    }
    // PHYSICAL ATTACKS - Either we don't have talents or we are saving them.
    object oTarget = OBJECT_INVALID;
    // ************************** Ranged feat attacks **************************
    if(!ai_GetAIMode(oCreature, AI_MODE_STOP_RANGED) && ai_CanIUseRangedWeapon(oCreature, nInMelee))
    {
        if(ai_HasRangedWeaponWithAmmo(oCreature))
        {
            // Paladins ALWAYS protect their masters first!
            oTarget = ai_GetLowestCRAttackerOnMaster(oCreature);
            if(oTarget == OBJECT_INVALID)
            {
                // Paladins face off against the strongest opponents first.
                if(!nInMelee) oTarget = ai_GetHighestCRTarget(oCreature);
                else oTarget = ai_GetHighestCRTarget(oCreature, AI_RANGE_MELEE);
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
    // ************************** Melee feat attacks *************************
    if(ai_InCombatEquipBestMeleeWeapon(oCreature)) return;
    // Paladins ALWAYS protect their masters first!
    oTarget = ai_GetLowestCRAttackerOnMaster(oCreature);
    if(oTarget == OBJECT_INVALID)
    {
        int bCheckCombat = ai_GetAIMode(oCreature, AI_MODE_CHECK_ATTACK);
        if(bCheckCombat) oTarget = ai_GetNearestTargetForMeleeCombat(oCreature, nInMelee, FALSE);
        // If always attacking Paladins ALWAYS attack the strongest opponent.
        else oTarget = ai_GetHighestCRTargetForMeleeCombat(oCreature, nInMelee);
    }
    if(oTarget != OBJECT_INVALID)
    {
        if(ai_TryMeleeTalents(oCreature, oTarget)) return;
        ai_ActionAttack(oCreature, AI_LAST_ACTION_MELEE_ATK, oTarget);
    }
    else ai_SearchForHiddenCreature(oCreature, FALSE);
}
