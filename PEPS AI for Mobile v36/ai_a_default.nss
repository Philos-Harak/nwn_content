/*////////////////////////////////////////////////////////////////////////////////////////////////////
// Script Name: ai_a_default
//////////////////////////////////////////////////////////////////////////////////////////////////////
 ai script for associates to use the default ai.
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
        if(bUseMagic && !ai_GetMagicMode(oCreature, AI_MAGIC_DEFENSIVE_CASTING))
        {
            if(nInMelee > 0 && ai_UseCreatureTalent(oCreature, AI_TALENT_TOUCH, nInMelee, nMaxLevel)) return;
            if(ai_UseCreatureTalent(oCreature, AI_TALENT_RANGED, nInMelee, nMaxLevel)) return;
        }
    }
    // PHYSICAL ATTACKS - Either we don't have talents or we are saving them.
    ai_DoPhysicalAttackOnLowestCR(oCreature, nInMelee, !ai_GetAIMode(oCreature, AI_MODE_CHECK_ATTACK));
}

