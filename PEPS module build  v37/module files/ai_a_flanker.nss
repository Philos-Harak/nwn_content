/*////////////////////////////////////////////////////////////////////////////////////////////////////
// Script Name: ai_a_flanker
//////////////////////////////////////////////////////////////////////////////////////////////////////
 ai script for associates to flank the enemy and not charge into combat.
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
    if(nDifficulty >= AI_COMBAT_MODERATE)
    {
        // *************************** SPELL TALENTS ***************************
        if(ai_CheckForAssociateSpellTalent(oCreature, nInMelee, nMaxLevel)) return;
        //**************************  SKILL FEATURES  **************************
        if(ai_TryAnimalEmpathy(oCreature)) return;
        // ************************** CLASS FEATURES ***************************
        if(ai_TryBarbarianRageFeat(oCreature)) return;
        if(ai_TryBardSongFeat(oCreature)) return;
        if(ai_TrySummonAnimalCompanionTalent(oCreature)) return;
        if(ai_TrySummonFamiliarTalent(oCreature)) return;
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
    object oTarget;
    oTarget = GetLocalObject(oCreature, AI_PC_LOCKED_TARGET);
    // ************************** Melee feat attacks *************************
    if(ai_GetAIMode(oCreature, AI_MODE_DEFEND_MASTER)) oTarget = ai_GetLowestCRAttackerOnMaster(oCreature);
    // Lets get the nearest target that is attacking someone besides me. We want to flank!
    if(oTarget == OBJECT_INVALID)
    {
        if(!nInMelee) oTarget = ai_GetFlankTarget(oCreature);
        // If there are few enemies then we can safely move around.
        else if(nInMelee < 3 || ai_CanIMoveInCombat(oCreature))
        {
            oTarget = ai_GetFlankTarget(oCreature, AI_RANGE_MELEE);
        }
        // Ok we are in a serious fight so lets not give attacks of opportunities.
        else oTarget = ai_GetNearestTarget(oCreature, AI_RANGE_MELEE);
    }
    // If there are no enemies being attacked then lets stay back.
    if(oTarget == OBJECT_INVALID)
    {
        if(nInMelee)
        {
            if(ai_InCombatEquipBestMeleeWeapon(oCreature)) return;
            // Lets get the strongest melee opponent in melee with us.
            object oTarget = ai_GetHighestCRTargetForMeleeCombat(oCreature, nInMelee);
            if(oTarget != OBJECT_INVALID)
            {
                ai_ActionAttack(oCreature, AI_LAST_ACTION_MELEE_ATK, oTarget);
                return;
            }
        }
        // ************************** Ranged feat attacks **************************
        else if(!ai_GetAIMode(oCreature, AI_MODE_STOP_RANGED) && ai_CanIUseRangedWeapon(oCreature, nInMelee))
        {
            if(ai_HasRangedWeaponWithAmmo(oCreature))
            {
                if(ai_TryRangedSneakAttack(oCreature, nInMelee)) return;
                oTarget = ai_GetLowestCRTarget(oCreature);
                if(oTarget != OBJECT_INVALID)
                {
                    if(ai_TryRangedTalents(oCreature, oTarget, nInMelee)) return;
                    ai_ActionAttack(oCreature, AI_LAST_ACTION_RANGED_ATK, oTarget, nInMelee, TRUE);
                    return;
                }
            }
            else if(ai_InCombatEquipBestRangedWeapon(oCreature)) return;
            else
            {
                ai_SearchForHiddenCreature(oCreature, FALSE, OBJECT_INVALID, AI_RANGE_CLOSE);
                return;
            }
        }
        // Make sure we are not the only one here. Moving around looks funny when we are by ourselves.
        else if(ai_GetNearestAlly(oCreature, 1, 7, 7) == OBJECT_INVALID)
        {
            oTarget = ai_GetNearestTarget(oCreature, AI_RANGE_MELEE);
            ai_ActionAttack(oCreature, AI_LAST_ACTION_MELEE_ATK, oTarget);
        }
    }
    if(oTarget != OBJECT_INVALID)
    {
        if(ai_InCombatEquipBestMeleeWeapon(oCreature)) return;
        if(ai_TryMeleeTalents(oCreature, oTarget)) return;
        ai_ActionAttack(oCreature, AI_LAST_ACTION_MELEE_ATK, oTarget);
        return;
    }
    // Are we too far from our master?
    object oMaster = GetMaster();
    if(GetDistanceBetween(oMaster, oCreature) > AI_RANGE_LONG)
    {
        ActionMoveToObject(oMaster, TRUE, AI_RANGE_CLOSE);
        return;
    }
    ai_SearchForHiddenCreature(oCreature, FALSE, OBJECT_INVALID, AI_RANGE_CLOSE);
}
