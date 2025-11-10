/*////////////////////////////////////////////////////////////////////////////////////////////////////
// Script Name: ai_a_atk_casters
//////////////////////////////////////////////////////////////////////////////////////////////////////
 ai script for associates to the nearest casting creatures.
 OBJECT_SELF is the creature running the ai.
 Our actions.
 1 - Get nearest enemy.
 2 - Check for healing and curing first.
 3 - Check moral if wounded and this is a simple+ battle.
 4 - Check for a magical ranged attack if not in melee and a difficult+ battle.
 5 - Check for a buff or summons if this is a difficult+ battle.
 6 - Check for a Class ability and an offensive spell if this is a simple+ battle.
 7 - Check for a physical attack.
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
        // ************************** CLASS FEATURES ***************************
        if(ai_TryTurningTalent(oCreature)) return;
        // *************************** SPELL TALENTS ***************************
        if(!ai_GetMagicMode(oCreature, AI_MAGIC_DEFENSIVE_CASTING))
        {
            if(nInMelee > 0 && ai_UseCreatureTalent(oCreature, AI_TALENT_TOUCH, nInMelee, nMaxLevel)) return;
            if(ai_UseCreatureTalent(oCreature, AI_TALENT_RANGED, nInMelee, nMaxLevel)) return;
        }
    }
    // PHYSICAL ATTACKS - Either we don't have talents or we are saving them.
    object oTarget;
    int bAlwaysAtk = !ai_GetAIMode(oCreature, AI_MODE_CHECK_ATTACK);
    if(AI_DEBUG) ai_Debug("ai_a_atk_casters", "80", "Check for ranged attack on nearest casting enemy!");
    // ************************** Ranged feat attacks **************************
    if(!GetHasFeatEffect(FEAT_BARBARIAN_RAGE, oCreature) &&
       !ai_GetAIMode(oCreature, AI_MODE_STOP_RANGED) &&
       ai_CanIUseRangedWeapon(oCreature, nInMelee))
    {
        if(ai_HasRangedWeaponWithAmmo(oCreature))
        {
            if(ai_TryRangedSneakAttack(oCreature, nInMelee)) return;
            // Lets pick off the nearest targets first.
            if(!nInMelee)
            {
                if(ai_GetAIMode(oCreature, AI_MODE_DEFEND_MASTER)) oTarget = ai_GetLowestCRAttackerOnMaster(oCreature);
                if(oTarget == OBJECT_INVALID) oTarget = ai_GetNearestFavoredEnemyTarget(oCreature);
                if(oTarget == OBJECT_INVALID) ai_GetNearestClassTarget(oCreature, AI_CLASS_TYPE_CASTER);
                if(oTarget == OBJECT_INVALID) oTarget = ai_GetLowestCRTarget(oCreature);
            }
            else
            {
                if(ai_GetAIMode(oCreature, AI_MODE_DEFEND_MASTER)) oTarget = ai_GetLowestCRAttackerOnMaster(oCreature);
                if(oTarget == OBJECT_INVALID) oTarget = ai_GetNearestFavoredEnemyTarget(oCreature, AI_RANGE_MELEE);
                if(oTarget == OBJECT_INVALID) ai_GetNearestClassTarget(oCreature, AI_CLASS_TYPE_CASTER, AI_RANGE_MELEE);
                if(oTarget == OBJECT_INVALID) oTarget = ai_GetLowestCRTarget(oCreature, AI_RANGE_MELEE);
            }
            if(oTarget != OBJECT_INVALID)
            {
                if(ai_TryRapidShotFeat(oCreature, oTarget, nInMelee)) return;
                if(AI_DEBUG) ai_Debug("0i_actions", "519", "Do ranged attack against nearest: " + GetName(oTarget) + "!");
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
    if(AI_DEBUG) ai_Debug("ai_a_atk_casters", "119", "Check for melee attack on nearest enemy!");
    // ************************** Melee feat attacks *************************
    if(ai_InCombatEquipBestMeleeWeapon(oCreature)) return;
    if(ai_TryWhirlwindFeat(oCreature)) return;
    if(ai_TrySneakAttack(oCreature, nInMelee, bAlwaysAtk)) return;
    if(ai_GetAIMode(oCreature, AI_MODE_DEFEND_MASTER)) oTarget = ai_GetLowestCRAttackerOnMaster(oCreature);
    if(oTarget == OBJECT_INVALID) oTarget = ai_GetNearestFavoredEnemyTarget(oCreature, AI_RANGE_PERCEPTION, bAlwaysAtk);
    if(oTarget == OBJECT_INVALID)
    {
        object oPCTarget = GetLocalObject(oCreature, AI_PC_LOCKED_TARGET);
        if(oPCTarget == OBJECT_INVALID)
        {
            // Are we in melee? If so try to get the nearest enemy in melee.
            if(nInMelee > 0)
            {
                oTarget = ai_GetNearestClassTarget(oCreature, AI_CLASS_TYPE_CASTER, AI_RANGE_MELEE, AI_ENEMY, bAlwaysAtk);
                // If we didn't get a target then get any target within range.
                if(oTarget == OBJECT_INVALID) oTarget = ai_GetNearestTarget(oCreature, AI_RANGE_MELEE, AI_ENEMY);
            }
            // If not then lets go find someone to attack!
            else
            {
                // Get the nearest enemy.
                oTarget = ai_GetNearestClassTarget(oCreature, AI_CLASS_TYPE_CASTER, AI_RANGE_PERCEPTION, AI_ENEMY, bAlwaysAtk);
                // If we didn't get a target then get any target within range.
                if(oTarget == OBJECT_INVALID) oTarget = ai_GetNearestTarget(oCreature, AI_RANGE_PERCEPTION, AI_ENEMY);
            }
        }
    }
    // We might not have a target this is fine as sometimes we don't want to attack!
    if(AI_DEBUG) ai_Debug("ai_a_atk_casters", "149", GetName(oTarget) + " is the nearest target for melee combat!");
    // If we don't find a target then we don't want to fight anyone!
    if(oTarget != OBJECT_INVALID)
    {
        if(ai_TryMeleeTalents(oCreature, oTarget)) return;
        if(AI_DEBUG) ai_Debug("ai_a_atk_casters", "154", "Do melee attack against (caster/nearest): " + GetName(oTarget) + "!");
        ai_ActionAttack(oCreature, AI_LAST_ACTION_MELEE_ATK, oTarget);
    }
    else ai_SearchForHiddenCreature(oCreature, TRUE);
}

