/*////////////////////////////////////////////////////////////////////////////////////////////////////
// Script Name: ai_druid
//////////////////////////////////////////////////////////////////////////////////////////////////////
 ai script for creatures using the class Druid.
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
    if(ai_TryHealingTalent(oCreature, nInMelee)) return;
    if(ai_TryCureConditionTalent(oCreature, nInMelee)) return;
    if(nInMelee && ai_MoralCheck(oCreature)) return;
    int nMaxLevel = ai_GetMonsterTalentMaxLevel(oCreature);
    //*******************  OFFENSIVE AREA OF EFFECT TALENTS  *******************
    // Check the battlefield for a group of enemies to shoot a big talent at!
    // We are checking here since these opportunities are rare and we need
    // to take advantage of them as often as possible.
    if(ai_UseCreatureTalent(oCreature, AI_TALENT_INDISCRIMINANT_AOE, nInMelee, nMaxLevel)) return;
    if(ai_UseCreatureTalent(oCreature, AI_TALENT_DISCRIMINANT_AOE, nInMelee, nMaxLevel)) return;
    //****************************  CLASS FEATURES  ****************************
    if(GetLocalInt(GetModule(), AI_RULE_SUMMON_COMPANIONS) && ai_TrySummonAnimalCompanionTalent(oCreature)) return;
    //**************************  DEFENSIVE TALENTS  ***************************
    // Get the Spell Level we should still cast before turning into our polymorph form.
    int nSpellLevel = ai_GetHasPolymorphSelfFeat(oCreature);
    if(AI_DEBUG) ai_Debug("ai_druid", "30", "nSpellLevel: " + IntToString(nSpellLevel));
    int nMaxTalentLevel = GetLocalInt(oCreature, AI_MAX_TALENT + AI_TALENT_SUMMON);
    if(AI_DEBUG) ai_Debug("ai_druid", "32", "nMaxTalentLevel 'S' " + IntToString(nMaxTalentLevel));
    if(nSpellLevel < nMaxTalentLevel &&
       ai_UseCreatureTalent(oCreature, AI_TALENT_SUMMON, nInMelee, nMaxLevel)) return;
    nMaxTalentLevel = GetLocalInt(oCreature, AI_MAX_TALENT + AI_TALENT_PROTECTION);
    if(AI_DEBUG) ai_Debug("ai_druid", "36", "nMaxTalentLevel 'P' " + IntToString(nMaxTalentLevel));
    if(nSpellLevel < nMaxTalentLevel &&
       ai_UseCreatureTalent(oCreature, AI_TALENT_PROTECTION, nInMelee, nMaxLevel)) return;
    nMaxTalentLevel = GetLocalInt(oCreature, AI_MAX_TALENT + AI_TALENT_ENHANCEMENT);
    if(AI_DEBUG) ai_Debug("ai_druid", "40", "nMaxTalentLevel 'E' " + IntToString(nMaxTalentLevel));
    if(nSpellLevel < nMaxTalentLevel &&
       ai_UseCreatureTalent(oCreature, AI_TALENT_ENHANCEMENT, nInMelee, nMaxLevel)) return;
    //**********************  OFFENSIVE TARGETED TALENTS  **********************
    // Look for a touch attack since we are in melee.
    if(nInMelee > 0)
    {
        nMaxTalentLevel = GetLocalInt(oCreature, AI_MAX_TALENT + AI_TALENT_TOUCH);
        if(AI_DEBUG) ai_Debug("ai_druid", "48", "nMaxTalentLevel 'T' " + IntToString(nMaxTalentLevel));
        if(nSpellLevel < nMaxTalentLevel &&
           ai_UseCreatureTalent(oCreature, AI_TALENT_TOUCH, nInMelee, nMaxLevel)) return;
    }
    nMaxTalentLevel = GetLocalInt(oCreature, AI_MAX_TALENT + AI_TALENT_RANGED);
    if(AI_DEBUG) ai_Debug("ai_druid", "53", "nMaxTalentLevel 'R' " + IntToString(nMaxTalentLevel));
    if(nSpellLevel < nMaxTalentLevel &&
       ai_UseCreatureTalent(oCreature, AI_TALENT_RANGED, nInMelee, nMaxLevel)) return;
    if(ai_TryPolymorphSelfFeat(oCreature)) return;
    //****************************  SKILL FEATURES  ****************************
    if(ai_TryAnimalEmpathy(oCreature)) return;
    // All else fails lets see if we have any good potions.
    // PHYSICAL ATTACKS - Either we don't have talents or we are saving them.
    // ************************  RANGED ATTACKS  *******************************
    object oTarget;
    if(ai_CanIUseRangedWeapon(oCreature, nInMelee))
    {
        if(ai_HasRangedWeaponWithAmmo(oCreature))
        {
            // Lets pick off the nearest targets.
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
        else if(ai_InCombatEquipBestRangedWeapon(oCreature)) return;
    }
    // *************************  MELEE ATTACKS  *******************************
    if(ai_InCombatEquipBestMeleeWeapon(oCreature)) return;
    oTarget = ai_GetNearestTargetForMeleeCombat(oCreature, nInMelee);
    if(oTarget != OBJECT_INVALID)
    {
        if(ai_TryMeleeTalents(oCreature, oTarget)) return;
        ai_ActionAttack(oCreature, AI_LAST_ACTION_MELEE_ATK, oTarget);
    }
    else ai_SearchForHiddenCreature(oCreature, TRUE);
}
