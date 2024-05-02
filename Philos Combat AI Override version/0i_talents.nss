/*//////////////////////////////////////////////////////////////////////////////
 Script: 0i_talents
 Programmer: Philos
////////////////////////////////////////////////////////////////////////////////
    Fuctions to use a category of skills, feats, spells, or items.
*///////////////////////////////////////////////////////////////////////////////
#include "0i_states_cond"
#include "0i_combat"
// *****************************************************************************
// ************************* Try * Defensive Talents ***************************
// *****************************************************************************
// These functions try to find and use a specific set of talents intelligently.

// Returns TRUE if oCreature uses a healing talent on oTarge.
// nInMelee is the number of enemies the caller is in melee with.
// If oTarget is set then they will heal that target if they need it.
// Otherwise checks all allies to see who we should heal based on the talent.
int ai_TryHealingTalent(object oCreature, int nInMelee, object oTarget = OBJECT_INVALID);
// Returns TRUE if oCreature uses a cure condition talent on an ally or self.
int ai_TryCureConditionTalent(object oCreature, int nInMelee, object oTarget = OBJECT_INVALID);
// Returns TRUE if oCreature uses a defensive talent.
// nInMelee is the number of enemies oCreature is in melee with.
// nLevel is the highest level talent to use (0-9 is the talent levels).
// sCategory is AI_DEF_CAT_* constants.
// if oTarget != OBJECT_INVALID that target will be used.
int ai_TryDefensiveTalent(object oCreature, int nInMelee, int nMaxLevel, string sCategory, object oTarget = OBJECT_INVALID);
// Returns TRUE if oCreature uses a defensive talent.
// Checks for a Defensive talent(Protection, Enhancement, or Summons).
// Randomizes the order to mix up spells in combat.
// if oTarget is set then the defensive talent will be cast on them or OBJECT_SELF.
int ai_TryDefensiveTalents(object oCreature, int nInMelee, int nMaxLevel, object oTarget = OBJECT_INVALID);
// Returns TRUE if oCreature uses a defensive talent.
// Checks the enemy faction for most powerful class and picks a buff based on it.
//int ai_TryAdvancedBuffOnSelf(object oCreature, int nInMelee);
// Set any auras this oCreature has instantly.
// This can be done in the OnSpawn script, heart beat, or Perception.
void ai_SetAura(object oCreature);
// Returns TRUE if the caller uses a healing talent on oCreature.
int ai_TryHealingTalentOutOfCombat(object oCreature, object oTarget = OBJECT_INVALID);

// *****************************************************************************
// ************************ Try Physical Attack Talents ************************
// *****************************************************************************
// These functions try to find and use melee attack talents intelligently.

// Wrapper for ActionAttack, oCreature uses nAction (attack) on oTarget.
// nInMelee is only used in AI_LAST_ACTION_RANGED_ATK actions.
// bPassive TRUE oCreature will not move while attacking.
void ai_ActionAttack(object oCreature, int nAction, object oTarget, int nInMelee = 0, int bPassive = FALSE);
// Returns TRUE if oCreature uses a dragons breath talent
// Check for dragon's attacks under TALENT_CATEGORY_DRAGONS_BREATH(19).
// nRound must be supplied so we can keep track of the breath uses.
int ai_TryDragonBreathAttack(object oCreature, int nRound, object oTarget = OBJECT_INVALID);
// Returns TRUE if oCreature uses a dragons wing attacks.
// Checks to see if a dragon can use its wings on a nearby enemy.
// Checks the right side and then the left side to see if it can attack.
int ai_TryWingAttacks(object oCreature);
// Returns TRUE if oCreature uses a dragons tail slap.
// Looks behind the dragon to see if it can use it's tail slap on an enemy.
int ai_TryTailSlap(object oCreature);
// Returns TRUE if oCreature uses a dragons crush attack.
// Dragon can fly up and crash down on opponents to do bludgeoning damage.
// If 3 times smaller than the dragon they will take extra damage and be
// Knocked Down for 1 round if Reflex save is not made.
int ai_TryCrushAttack(object oCreature, object oTarget);
// Returns TRUE if oCreature uses a dragons tail sweep attack.
// If the enemy is 4 sizes smaller than it the dragon to use its tail to sweep
// behind it doing damage and knocking the opponents down.
int ai_TryTailSweepAttack(object oCreature);
// Returns TRUE if oCreature finds a good target and uses Sneak Attack.
int ai_TrySneakAttack(object oCreature, int nInMelee, int bAlwaysAtk = TRUE);
// Returns TRUE if oCreature finds a good ranged target and uses Sneak Attack.
int ai_TryRangedSneakAttack(object oCreature, int nInMelee);
// Returns TRUE if oCreature uses a harmful melee talent.
int ai_TryMeleeTalents(object oCreature, object oTarget);
// Targets the nearest creature oCreature it can see.
// This checks all physcal attack talents starting with ranged attacks then melee.
// Using TALENT_CATEGORY_HARMFUL_MELEE [22] talents.
// If no talents are used it will do either a ranged attack or a melee attack.
void ai_DoPhysicalAttackOnNearest(object oCreature, int nInMelee, int bAlwaysAtk = TRUE);
// Targets the weakest creature oCreature can see.
// This checks all physcal attack talents starting with ranged attacks then melee.
// Using TALENT_CATEGORY_HARMFUL_MELEE [22] talents.
// If no talents are used it will do either a ranged attack or a melee attack.
void ai_DoPhysicalAttackOnLowestCR(object oCreature, int nInMelee, int bAlwaysAtk = TRUE);
// *****************************************************************************
// ******************************* Try * Skills ********************************
// *****************************************************************************
// These functions try to find and use a specific set of skills intelligently.

// Wrapper to have oCreature use nSkill on oTarget.
void ai_UseSkill(object oCreature, int nSkill, object oTarget);
// Returns TRUE if oCreature uses the parry skill on someone attacking them.
// Checks if doing a parry might be successful.
int ai_TryParry(object oCreature);
// Returns TRUE if oCreature uses the Taunt skill on oTarget.
// Checks if doing a taunt might be successful against oTarget.
int ai_TryTaunt(object oCreature, object oTarget);
// Returns TRUE if oCreature uses the Animial emapthy skill on oTarget.
// For it to work oTarget must be an Animal, Beast, or Magical Beast.
// Checks if doing Animal Empathy might be successful against oTarget.
int ai_TryAnimalEmpathy(object oCreature, object oTarget);
// *****************************************************************************
// ******************************** Try * Feats ********************************
// *****************************************************************************
// These functions try to find and use a specific set of feats intelligently.

// Wrapper to have oCreature use nFeat on oTarget.
void ai_UseFeat(object oCreature, int nFeat, object oTarget);
// Wrapper to have oCreature use nActionMode on oTarget.
// nInMelee is only used in AI_LAST_ACTION_RANGED_ATK actions.
// bPassive TRUE oCreature will not move while attacking.
void ai_UseFeatAttackMode(object oCreature, int nActionMode, int nAction, object oTarget, int nInMelee = 0, int bPassive = FALSE);
// Returns TRUE if oCreature uses Rage.
// This checks if they are already in a rage and if they have the Rage feat.
int ai_TryBarbarianRageFeat(object oCreature);
// Returns TRUE if oCreature uses Bard song.
// This checks if they have any uses left, have the feat and if its viable.
int ai_TryBardSongFeat(object oCreature);
// Returns TRUE if oCreature uses Called shot.
// This checks if they have the feat and if its viable.
int ai_TryCalledShotFeat(object oCreature, object oTarget);
// Returns TRUE if oCreature uses Disarm.
// This checks if they have the feat and if its viable.
int ai_TryDisarmFeat(object oCreature, object oTarget);
// Returns TRUE if oCreature uses Expertise.
// This checks if they have the feat and if its viable.
// Also checks to see if the Improved Expertise feat would be better.
int ai_TryExpertiseFeat(object oCreature);
// Returns TRUE if oCreature uses Flurry of Blows.
// This checks if they have the feat and if its viable.
int ai_TryFlurryOfBlowsFeat(object oCreature, object oTarget);
// Returns TRUE if oCreature uses Improved Expertise.
// This checks if they have the feat and if its viable.
// Also checks to see if the Expertise feat would be better.
int ai_TryImprovedExpertiseFeat(object oCreature);
// Returns TRUE if oCreature uses Improved Power Attack.
// This checks if they have the feat and if its viable.
// Also checks to see if the Power Attack feat would be better.
int ai_TryImprovedPowerAttackFeat(object oCreature, object oTarget);
// Returns TRUE if oCreature uses Ki Damage.
// This checks if they have any uses left, have the feat and if its viable.
int ai_TryKiDamageFeat(object oCreature, object oTarget);
// Returns TRUE if oCreature uses Knockdown.
// This checks if they have the feat and if its viable.
int ai_TryKnockdownFeat(object oCreature, object oTarget);
// Returns TRUE if oCreature uses Power Attack.
// This checks if they have the feat and if its viable.
// Also checks to see if the Improved Power Attack would be better.
int ai_TryPowerAttackFeat(object oCreature, object oEnemy);
// Returns TRUE if oCreature uses Quivering palm.
// This checks if they have any uses left, have the feat and if its viable.
int ai_TryQuiveringPalmFeat(object oCreature, object oTarget);
// Returns TRUE if oCreature uses Power Attack.
// This checks if they have the feat and if its viable.
// Using a bow and having arrows should be checked before calling this.
int ai_TryRapidShotFeat(object oCreature, object oTarget, int nInMelee);
// Returns TRUE if oCreature uses Sap.
// This checks if they have the feat and if its viable.
int ai_TrySapFeat(object oCreature, object oTarget);
// Returns TRUE if oCreature uses Smite evil.
// This checks if they have any uses left, have the feat and if its viable.
int ai_TrySmiteEvilFeat(object oCreature, object oTarget);
// Returns TRUE if oCreature uses Smite good.
// This checks if they have any uses left, have the feat and if its viable.
int ai_TrySmiteGoodFeat(object oCreature, object oTarget);
// Returns TRUE if oCreature uses Stunning fists.
// This checks if they have any uses left, have the feat and if its viable.
int ai_TryStunningFistFeat(object oCreature, object oTarget);
// Returns TRUE if oCreature uses a summon animal companion talent.
int ai_TrySummonAnimalCompanionTalent(object oCreature);
// Returns TRUE if oCreature uses a summon familiar talent.
int ai_TrySummonFamiliarTalent(object oCreature);
// Returns TRUE if oCreature uses a turning talent.
int ai_TryTurningTalent(object oCreature);
// Returns TRUE if oCreature uses Whirlwind.
// This checks if they have the feat and if its viable.
int ai_TryWhirlwindFeat(object oCreature);
// Returns TRUE if oCreature uses Wholeness of Body.
// This checks if they have any uses left, have the feat and if its viable.
int ai_TryWholenessOfBodyFeat(object oCreature);
// *****************************************************************************
// *****************************  TALENT SCRIPTS  ******************************
// *****************************************************************************
// These functions do not fall into another section.

// Returns the MaxLevel used in GetCreatureTalent for oCreature.
// This checks the intelligence and the level of oCreature.
// Returns either -1 (random) or 10 for all talents.
int ai_GetMonsterTalentMaxLevel(object oCreature);
// Returns the nMaxLevel used in GetCreatureTalent for oCreature.
// This checks the difficulty of the combat and the level of oCreature.
// Return a number equal to 1 and half the level of oCreature upto 10.
// The max spell level used is equal to nMaxLevel or less.
int ai_GetAssociateTalentMaxLevel(object oCreature, int nDifficulty);
// Saves a talent in JsonArray.
// Array: 0-Type (1-spell, 2-sp ability, 4-feat, 3-item)
// Type 1)spell 0-type, 1-spell, 2-class, 3-level, 4-slot.
// Type 2)sp Ability 0-type, 1-spell, 2-class, 3-level, 4-slot.
// Type 3)feat 0-type, 1-spell, 2- class, 3- level.
// Type 4)item 0-type, 1-spell, 2-item object, 3-level, 4-slot.
void ai_SaveTalent(object oCreature, int nClass, int nLevel, int nSlot, int nSpell, int nType, int bBuff, object oItem = OBJECT_INVALID);
// Removes a talent nSlotIndex from jLevel in jCategory.
void ai_RemoveTalent(object oCreature, json jCategory, json jLevel, string sCategory, int nLevel, int nSlotIndex);
// Saves a creatures talents to variables upon them for combat use.
// bBuff will have oCreature Prebuff for combat by using quick talents.
void ai_SetCreatureTalents(object oCreature, int bBuff);
// Returns TRUE if oCreature uses jTalent on oTarget.
// also Returns -1 if oCreature uses jTalent on oTarget with a memorized spell.
// This allows the user to remove jTalent from jLevel in jCategory.
int ai_UseCreatureSpellTalent(object oCreature, json jLevel, json jTalent, string sCategory, int nInMelee, object oTarget = OBJECT_INVALID);
// Return TRUE if oCreature uses a jTalent from oItem on oTarget.
int ai_UseCreatureItemTalent(object oCreature, json jLevel, json jTalent, string sCategory, int nInMelee, object oTarget = OBJECT_INVALID);
// Returns TRUE if oCreature uses a talent from sCategory of nLevel or less.
int ai_UseCreatureTalent(object oCreature, string sCategory, int nInMelee, int nLevel = 10, object oTarget = OBJECT_INVALID);
// Returns TRUE if jTalent is used on oTarget by oCaster.
// Checks the talent type and casts the correct spell. For items it checks uses.
int ai_UseTalentOnObject(object oCaster, json jTalent, object oTarget, int nInMelee);
// Returns TRUE if jTalent is used at lTarget location by oCaster.
// Checks the talent type and cast the correct spell. For items it checks uses.
int ai_UseTalentAtLocation(object oCaster, json jTalent, location lTarget, int nInMelee);
// Return TRUE if oCreature uses jTalent on oTarget after checking special cases.
int ai_CheckSpecialTalentsandUse(object oCreature, json jTalent, string sCategory, int nInMelee, object oTarget);

int ai_TryHealingTalent(object oCreature, int nInMelee, object oTarget = OBJECT_INVALID)
{
    // First lets evaluate oTarget and see how strong of a spell we will need.
    // We don't have a target so lets go check for one.
    if(oTarget == OBJECT_INVALID)
    {
        // Lets not run past an enemy to heal, bad tactics!
        float fRange;
        if(ai_CanIMoveInCombat(oCreature)) fRange = AI_RANGE_PERCEPTION;
        else
        {
            fRange = GetDistanceBetween(oCreature, GetLocalObject(oCreature, AI_ENEMY_NEAREST));
            // Looks bad when your right next to an ally, but technically the enemy is closer.
            if(fRange < AI_RANGE_MELEE) fRange = AI_RANGE_MELEE;
        }
        oTarget = ai_GetMostWoundedTarget(oCreature, fRange, AI_ALLY);
        if(oTarget == OBJECT_INVALID) return FALSE;
    }
    int nHp = ai_GetPercHPLoss(oTarget);
    int nHpLimit = ai_GetHealersHpLimit(oCreature);
    if(nHp > nHpLimit) return FALSE;
    int nHpLost = GetMaxHitPoints(oTarget) - GetCurrentHitPoints(oTarget);
    //ai_Debug("0i_talents", "247", GetName(oTarget) + " has lost " + IntToString(nHpLost) + " hitpoints!");
    int nMaxLevel = 1;
    if(nHpLost > 50) nMaxLevel = 7; // Druid gets heal at 7th.
    else if(nHpLost > 32) nMaxLevel = 4;
    else if(nHpLost > 24) nMaxLevel = 3;
    else if(nHpLost > 16) nMaxLevel = 2;
    //ai_Debug("0i_talents", "253", "AI_NO_TALENTS_" + AI_TALENT_HEALING + ": " +
    //         IntToString(GetLocalInt(oCreature, AI_NO_TALENTS + AI_TALENT_HEALING)));
    // If we have saved this level or higher to AI_NO_TALENTS then skip.
    if(GetLocalInt(oCreature, AI_NO_TALENTS + AI_TALENT_HEALING) >= nMaxLevel) return FALSE;
    // If they are about to die then throw caution to the wind and HEAL!
    if(nHp <= AI_HEALTH_BLOODY) nInMelee = 0;
    if(ai_UseCreatureTalent(oCreature, AI_TALENT_HEALING, nInMelee, nMaxLevel, oTarget)) return TRUE;
    if(GetLevelByClass(CLASS_TYPE_CLERIC, oCreature) > 0)
    {
        // We need to do our melee check here and use an average cure spell.
        if(!ai_CastInMelee(oCreature, SPELL_CURE_MODERATE_WOUNDS, nInMelee)) return FALSE;
        // Since clerics can cast cure spells spontaneously lets make sure we don't have any left.
        if(ai_CastSpontaneousCure(oCreature, oTarget, nMaxLevel)) return TRUE;
    }
    // Set AI_NO_TALENTS to nMaxLevel since we couldn't heal.
    SetLocalInt(oCreature, AI_NO_TALENTS + AI_TALENT_HEALING, nMaxLevel);
    return FALSE;
}
int ai_CheckTargetVsConditions(object oTarget, json jTalent, int nConditions)
{
    // Check nCondition for any negative effects based on the talent we have.
    switch(JsonGetInt(JsonArrayGet(jTalent, 1)))
    {
        case SPELL_NEUTRALIZE_POISON :
            if(ai_GetHasNegativeCondition(AI_CONDITION_POISON, nConditions)) return TRUE;
            break;
        case SPELL_REMOVE_DISEASE :
            if(ai_GetHasNegativeCondition(AI_CONDITION_DISEASE, nConditions)) return TRUE;
            break;
        case SPELL_REMOVE_BLINDNESS_AND_DEAFNESS :
            if(ai_GetHasNegativeCondition(AI_CONDITION_BLINDDEAF, nConditions)) return TRUE;
            break;
        case SPELL_REMOVE_FEAR :
            if(ai_GetHasNegativeCondition(AI_CONDITION_FRIGHTENED, nConditions)) return TRUE;
            break;
        case SPELL_REMOVE_CURSE :
            if(ai_GetHasNegativeCondition(AI_CONDITION_CURSE, nConditions)) return TRUE;
            break;
        case SPELL_REMOVE_PARALYSIS :
            if(ai_GetHasNegativeCondition(AI_CONDITION_PARALYZE, nConditions)) return TRUE;
            break;
        case SPELL_GREATER_RESTORATION :
            if(ai_GetHasNegativeCondition(AI_CONDITION_DAZED, nConditions)) return TRUE;
            if(ai_GetHasNegativeCondition(AI_CONDITION_CONFUSED, nConditions)) return TRUE;
            if(ai_GetHasNegativeCondition(AI_CONDITION_DOMINATED, nConditions)) return TRUE;
            if(ai_GetHasNegativeCondition(AI_CONDITION_SLOW, nConditions)) return TRUE;
            if(ai_GetHasNegativeCondition(AI_CONDITION_FRIGHTENED, nConditions)) return TRUE;
            if(ai_GetHasNegativeCondition(AI_CONDITION_STUNNED, nConditions)) return TRUE;
            if(ai_GetHasNegativeCondition(AI_CONDITION_CHARMED, nConditions)) return TRUE;
        case SPELL_RESTORATION :
            if(ai_GetHasNegativeCondition(AI_CONDITION_LEVEL_DRAIN, nConditions)) return TRUE;
            if(ai_GetHasNegativeCondition(AI_CONDITION_BLINDDEAF, nConditions)) return TRUE;
            if(ai_GetHasNegativeCondition(AI_CONDITION_PARALYZE, nConditions)) return TRUE;
        case SPELL_LESSER_RESTORATION :
            if(ai_GetHasNegativeCondition(AI_CONDITION_ABILITY_DRAIN, nConditions)) return TRUE;
            if(ai_GetHasNegativeCondition(AI_CONDITION_SAVE_DECREASE, nConditions)) return TRUE;
            if(ai_GetHasNegativeCondition(AI_CONDITION_SR_DECREASE, nConditions)) return TRUE;
            if(ai_GetHasNegativeCondition(AI_CONDITION_SKILL_DECREASE, nConditions)) return TRUE;
            if(ai_GetHasNegativeCondition(AI_CONDITION_AC_DECREASE , nConditions)) return TRUE;
            if(ai_GetHasNegativeCondition(AI_CONDITION_ATK_DECREASE, nConditions)) return TRUE;
            if(ai_GetHasNegativeCondition(AI_CONDITION_DMG_DECREASE, nConditions)) return TRUE;
            if(ai_GetHasNegativeCondition(AI_CONDITION_DMG_I_DECREASE, nConditions)) return TRUE;
    }
    return FALSE;
}
int ai_CheckTalentsVsConditions(object oCreature, int nConditions, int nInMelee, int nMaxLevel, object oTarget)
{
    // Get the saved category from oCreature.
    json jCategory = GetLocalJson(oCreature, AI_TALENT_CURE);
    //ai_Debug("0i_talents", "322", "jCategory: " + AI_TALENT_CURE + " " + JsonDump(jCategory, 2));
    if(JsonGetType(jCategory) == JSON_TYPE_NULL)
    {
        SetLocalInt(oCreature, AI_NO_TALENTS + AI_TALENT_CURE, 10);
        return FALSE;
    }
    json jLevel, jTalent;
    int nClass, nSlot, nType, nSlotIndex, nMaxSlotIndex, nTalentUsed;
    // Loop through nLevels down to 0 looking for the first talent (i.e. the highest).
    int nLevel = nMaxLevel;
    while(nLevel >= 0)
    {
        // Get the array of nLevel cycling down to 0.
        jLevel = JsonArrayGet(jCategory, nLevel);
        nMaxSlotIndex = JsonGetLength(jLevel);
        //ai_Debug("0i_talents", "337", "nLevel: " + IntToString(nLevel) +
        //         " nMaxSlotIndex: " + IntToString(nMaxSlotIndex));
        if(nMaxSlotIndex > 0)
        {
            // Get the talent within nLevel cycling from the first to the last.
            nSlotIndex = 0;
            while (nSlotIndex <= nMaxSlotIndex)
            {
                jTalent= JsonArrayGet(jLevel, nSlotIndex);
                //ai_Debug("0i_talents", "346", "nSlotIndex: " + IntToString(nSlotIndex) +
                //         " jTalent Type: " + IntToString(JsonGetType(jTalent)));
                // Check to see if the talent matches oTargets nConditionss.
                if(ai_CheckTargetVsConditions(oTarget, jTalent, nConditions))
                {
                    nType = JsonGetInt(JsonArrayGet(jTalent, 0));
                    if(nType == AI_TALENT_TYPE_SPELL)
                    {
                        if(ai_CastInMelee(oCreature, JsonGetInt(JsonArrayGet(jTalent, 1)), nInMelee))
                        {
                            nTalentUsed = ai_UseCreatureSpellTalent(oCreature, jLevel, jTalent, AI_TALENT_CURE, nInMelee, oTarget);
                            // -1 means it was a memorized spell and we need to remove it.
                            if(nTalentUsed == -1)
                            {
                                ai_RemoveTalent(oCreature, jCategory, jLevel, AI_TALENT_CURE, nLevel, nSlotIndex);
                                return TRUE;
                            }
                            else if(nTalentUsed) return TRUE;
                        }
                    }
                    else if(nType == AI_TALENT_TYPE_SP_ABILITY)
                    {
                        // Special ability spells do not need to concentrate?!
                        if(ai_CheckSpecialTalentsandUse(oCreature, jTalent, AI_TALENT_CURE, nInMelee, oTarget))
                        {
                            // When the ability is used that slot is now not readied.
                            // Multiple uses of the same spell are stored in different slots.
                            ai_RemoveTalent(oCreature, jCategory, jLevel, AI_TALENT_CURE, nLevel, nSlotIndex);
                            return TRUE;
                        }
                    }
                    else if (nType == AI_TALENT_TYPE_ITEM)
                    {
                        // Items do not need to concentrate.
                        if(ai_UseCreatureItemTalent(oCreature, jLevel, jTalent, AI_TALENT_CURE, nInMelee, oTarget))
                        {
                            //ai_Debug("0i_talents", "382", "Checking if Item is used up: " +
                            //         IntToString(JsonGetInt(JsonArrayGet(jTalent, 4))));
                            if(JsonGetInt(JsonArrayGet(jTalent, 4)) == -1)
                            {
                                ai_RemoveTalent(oCreature, jCategory, jLevel, AI_TALENT_CURE, nLevel, nSlotIndex);
                            }
                            return TRUE;
                        }
                    }
                }
                nSlotIndex++;
            }
        }
        else SetLocalInt(oCreature, AI_NO_TALENTS + AI_TALENT_CURE, nLevel - 1);
        nLevel--;
    }
    return FALSE;
}
int ai_TryCureConditionTalent(object oCreature, int nInMelee, object oTarget = OBJECT_INVALID)
{
    int nMaxLevel = GetLocalInt(oCreature, AI_NO_TALENTS + AI_TALENT_CURE);
    //ai_Debug("0i_talents", "403", AI_NO_TALENTS + AI_TALENT_CURE + ": " + IntToString(nMaxLevel));
    // If we have saved this level or lower to AI_NO_TALENTS then skip.
    if(nMaxLevel == 0) return FALSE;
    // We check targets to see if they need to be cured.
    int nNegativeConditions, nTargetNegConds, nIndex, nCnt = 1;
    object oTarget;
    if(oTarget == OBJECT_INVALID)
    {
        oTarget = GetLocalObject(oCreature, AI_ALLY + "1");
        while(oTarget != OBJECT_INVALID)
        {
            nTargetNegConds = ai_GetNegativeConditions(oTarget);
            if(nNegativeConditions < nTargetNegConds)
            {
                nNegativeConditions = nTargetNegConds;
                nIndex = nCnt;
            }
            oTarget = GetLocalObject(oCreature, AI_ALLY + IntToString(++nCnt));
        }
        // No one has a negative condition then get out.
        if(!nNegativeConditions) return FALSE;
        oTarget = GetLocalObject(oCreature, AI_ALLY + IntToString(nIndex));
    }
    else
    {
        nNegativeConditions = ai_GetNegativeConditions(oTarget);
        if(!nNegativeConditions) return FALSE;
    }
    //ai_Debug("0i_talents", "431", "nNegativeConditions: " + IntToString(nNegativeConditions) +
    //         " on " + GetName(oTarget));
    if(ai_CheckTalentsVsConditions(oCreature, nNegativeConditions, nInMelee, nMaxLevel, oTarget)) return TRUE;
    return FALSE;
}
int ai_TryDefensiveTalent(object oCreature, int nInMelee, int nMaxLevel, string sCategory, object oTarget = OBJECT_INVALID)
{
    //ai_Debug("0i_talents", "438", "AI_NO_TALENTS_" + sCategory + ": " + IntToString(GetLocalInt(oCreature, AI_NO_TALENTS + sCategory)) +
    //         " nMaxLevel: " + IntToString(nMaxLevel));
    // If we have saved this level or higher to AI_NO_TALENTS then skip.
    if(GetLocalInt(oCreature, AI_NO_TALENTS + sCategory) >= nMaxLevel) return FALSE;
    if(ai_UseCreatureTalent(oCreature, sCategory, nInMelee, nMaxLevel, oTarget)) return TRUE;
    return FALSE;
}
// *****************************************************************************
// ************************* Try * Defensive Talents ***************************
// *****************************************************************************
// These functions try to find and use a specific set of talents intelligently.

int ai_TryDefensiveTalents(object oCreature, int nInMelee, int nMaxLevel, object oTarget = OBJECT_INVALID)
{
    // Summons are powerfull and should be used as much as possible.
    if(ai_UseCreatureTalent(oCreature, AI_TALENT_SUMMON, nInMelee, nMaxLevel, oTarget)) return TRUE;
    // Try to mix them up so we don't always cast spells in the same order.
    int nRoll = d2();
    //ai_Debug("0i_talents", "456", "Lets help someone(Check Talents: " +IntToString(nRoll) +
    //         " nMaxLevel: " + IntToString(nMaxLevel) + ")!");
    if(nRoll == 1)
    {
        if(ai_UseCreatureTalent(oCreature, AI_TALENT_ENHANCEMENT, nInMelee, nMaxLevel, oTarget)) return TRUE;
        if(ai_UseCreatureTalent(oCreature, AI_TALENT_PROTECTION, nInMelee, nMaxLevel, oTarget)) return TRUE;
    }
    else if(nRoll == 2)
    {
        if(ai_UseCreatureTalent(oCreature, AI_TALENT_PROTECTION, nInMelee, nMaxLevel, oTarget)) return TRUE;
        if(ai_UseCreatureTalent(oCreature, AI_TALENT_ENHANCEMENT, nInMelee, nMaxLevel, oTarget)) return TRUE;
    }
    return FALSE;
}
void ai_SetAura(object oCreature)
{
    // Cycle through a creatures special abilities and use any auras.
    int bCanUse, nIndex = 0, nMaxSpAbility = GetSpellAbilityCount(oCreature);
    int nSpell = GetSpellAbilitySpell(oCreature, nIndex);
    while(nIndex < nMaxSpAbility)
    {
        bCanUse = FALSE;
        if(GetSpellAbilityReady(oCreature, nIndex))
        {
            if(nSpell == SPELLABILITY_AURA_BLINDING) bCanUse = TRUE;
            else if(nSpell == SPELLABILITY_AURA_COLD) bCanUse = TRUE;
            else if(nSpell == SPELLABILITY_AURA_ELECTRICITY) bCanUse = TRUE;
            else if(nSpell == SPELLABILITY_AURA_FEAR) bCanUse = TRUE;
            else if(nSpell == SPELLABILITY_AURA_FIRE) bCanUse = TRUE;
            else if(nSpell == SPELLABILITY_AURA_HORRIFICAPPEARANCE) bCanUse = TRUE;
            else if(nSpell == SPELLABILITY_AURA_MENACE) bCanUse = TRUE;
            else if(nSpell == SPELLABILITY_AURA_HORRIFICAPPEARANCE) bCanUse = TRUE;
            else if(nSpell == SPELLABILITY_AURA_PROTECTION) bCanUse = TRUE;
            else if(nSpell == SPELLABILITY_AURA_STUN) bCanUse = TRUE;
            else if(nSpell == SPELLABILITY_AURA_UNEARTHLY_VISAGE) bCanUse = TRUE;
            else if(nSpell == SPELLABILITY_AURA_UNNATURAL) bCanUse = TRUE;
            else if(nSpell == SPELLABILITY_AURA_HORRIFICAPPEARANCE) bCanUse = TRUE;
            else if(nSpell == 306 /*SPELLABILITY_AURA_TYRANT_FOG_MIST*/) bCanUse = TRUE;
            else if(nSpell == 412 /*SPELLABILITY_AURA_DRAGON_FEAR*/) bCanUse = TRUE;
            else if(nSpell == 761 /*SPELLABILITY_AURA_HELLFIRE*/) bCanUse = TRUE;
            else if(nSpell == 805/*SPELLABILITY_AURA_TROGLODYTE_STENCH*/) bCanUse = TRUE;
        }
        if(bCanUse) ActionCastSpellAtObject(nSpell, oCreature, 255, FALSE, 0, 0, TRUE);
        nSpell = GetSpellAbilitySpell(oCreature, ++nIndex);
    }
}
int ai_TryHealingTalentOutOfCombat(object oCreature, object oTarget)
{
    // Undead don't heal so lets skip this for them, maybe later we can fix this.
    if(GetRacialType(oTarget) == RACIAL_TYPE_UNDEAD) return FALSE;
    //ai_Debug("0i_talents", "506", "TryHealingTalentsOutOfCombat.");
    // If we don't have any Healing talents then just exit.
    if(GetLocalInt(oCreature, AI_NO_TALENTS + AI_TALENT_HEALING) > 9) return FALSE;
    // First lets evaluate oTarget and see how strong of a spell we will need.
    int nHp = ai_GetPercHPLoss(oTarget);
    int nHpLimit = AI_HEALTH_WOUNDED;
    // Check for Associate rules.
    if(ai_GetAssociateMode(oCreature, AI_MODE_HEAL_AT_25)) nHpLimit = 25;
    else if(ai_GetAssociateMode(oCreature, AI_MODE_HEAL_AT_75)) nHpLimit = 75;
    if(nHp > nHpLimit) return FALSE;
    int nHpLost = GetMaxHitPoints(oTarget) - GetCurrentHitPoints(oTarget);
    int nMaxLevel = 1;
    if(nHpLost > 50) nMaxLevel = 7; // Druid gets heal at 7th.
    else if(nHpLost > 32) nMaxLevel = 4;
    else if(nHpLost > 24) nMaxLevel = 3;
    else if(nHpLost > 16) nMaxLevel = 2;
    //ai_Debug("0i_talents", "522", "AI_NO_TALENTS_" + AI_TALENT_HEALING + ": " +
    //         IntToString(GetLocalInt(oCreature, AI_NO_TALENTS + AI_TALENT_HEALING)));
    // If we have saved this level or higher to AI_NO_TALENTS then skip.
    if(GetLocalInt(oCreature, AI_NO_TALENTS + AI_TALENT_HEALING) <= nMaxLevel) return FALSE;
    if(ai_UseCreatureTalent(oCreature, AI_TALENT_HEALING, 0, nMaxLevel, oTarget)) return TRUE;
    if(GetLevelByClass(CLASS_TYPE_CLERIC, oCreature) > 0)
    {
        // Since clerics can cast cure spells spontaneously lets make sure we don't have any left.
        if(ai_CastSpontaneousCure(oCreature, oTarget, nMaxLevel)) return TRUE;
    }
    // Set AI_NO_TALENTS to TRUE since we didn't find a healing talent.
    SetLocalInt(oCreature, AI_NO_TALENTS + AI_TALENT_HEALING, nMaxLevel);
    return FALSE;
}
// *****************************************************************************
// ************************* Try * Skills **************************************
// *****************************************************************************
// These functions try to find and use a specific set of skills intelligently.

void ai_UseSkill(object oCreature, int nSkill, object oTarget)
{
    ai_SetLastAction(oCreature, AI_LAST_ACTION_USED_SKILL);
    //ai_Debug("0i_talents", "544", GetName(oCreature) + " is using skill: " +
    //         GetStringByStrRef(StringToInt(Get2DAString("skills", "Name", nSkill))) +
    //         " on " + GetName(oTarget));
    ActionUseSkill(SKILL_TAUNT, oTarget);
}
int ai_TryParry(object oCreature)
{
    // Only use parry on an active melee attacker
    object oTarget = GetLastHostileActor(oCreature);
    // If we are already in parry mode then lets keep it up.
    if(GetActionMode(oCreature, ACTION_MODE_PARRY) &&
       GetCurrentAction(oCreature) == ACTION_ATTACKOBJECT) return TRUE;
    if(oTarget == OBJECT_INVALID ||
       ai_GetAttackedTarget(oTarget) != oCreature ||
       !ai_GetIsMeleeWeapon(GetItemInSlot(INVENTORY_SLOT_RIGHTHAND, oTarget))) return FALSE;
    // Only if our parry skill > their attack bonus + 5 + d10
    // Parry has a -4 atk adjustment. Our chance to hit should be 75% + d10.
    // EnemyAtk(20) - OurParrySkill(10) = 0 + d10(75% to 25% chance to hit).
    int nParrySkill = GetSkillRank(SKILL_PARRY, oCreature);
    int nAtk = ai_GetCreatureAttackBonus(oTarget);
    if(nAtk - nParrySkill >= 0 + d10()) return FALSE;
    ai_EquipBestMeleeWeapon(oCreature, oTarget);
    SetActionMode(oCreature, ACTION_MODE_PARRY, TRUE);
    ai_SetLastAction(oCreature, AI_LAST_ACTION_USED_SKILL);
    ActionAttack(oTarget);
    //ai_Debug("0i_talents", "569", "Using parry against " + GetName(oTarget) + "!");
    return TRUE;
}
int ai_TryTaunt(object oCreature, object oTarget)
{
    // Is this target already taunted?
    //ai_Debug("0i_talents", "575", "Has Taunt Effect? " + IntToString(ai_GetHasEffectType(oTarget, EFFECT_TYPE_TAUNT)));
    if(!ai_GetHasEffectType(oTarget, EFFECT_TYPE_TAUNT)) return FALSE;
    // Check to see if we have a good chance for it to work.
    int nTauntRnk = GetSkillRank(SKILL_TAUNT, oCreature);
    //ai_Debug("0i_talents", "579", "Check Taunt: TauntRnk: " + IntToString(nTauntRnk) +
    //          " HitDice + 1: " + IntToString(GetHitDice(oCreature) + 1) +
    //          " Concentration: " + IntToString(GetSkillRank(SKILL_CONCENTRATION, oTarget)) + ".");
    int nConcentration = GetSkillRank(SKILL_CONCENTRATION, oTarget);
    // Our chance is greater than 50%.
    if(nTauntRnk <= nConcentration) return FALSE;
    //ai_Debug("0i_talents", "585", "USING TAUNT SKILL.");
    ai_UseSkill(oCreature, SKILL_TAUNT, oTarget);
    return TRUE;
}
int ai_TryAnimalEmpathy(object oCreature, object oTarget)
{
    // Is this target already taunted?
    //ai_Debug("0i_talents", "592", "Has Taunt Effect? " + IntToString(ai_GetHasEffectType(oTarget, EFFECT_TYPE_TAUNT)));
    if(ai_GetHasEffectType(oTarget, EFFECT_TYPE_DOMINATED)) return FALSE;
    // Get the race of the target, it only works on Animals, Beasts, and Magical Beasts.
    int nRace = GetRacialType(oTarget);
    int nDC;
    if(nRace == RACIAL_TYPE_ANIMAL) nDC = 5;
    if(nRace == RACIAL_TYPE_BEAST || nRace == RACIAL_TYPE_MAGICAL_BEAST) nDC = 9;
    if(nDC <= 0) return FALSE;
     // Check to see if we have a good chance for it to work.
    int nEmpathyRnk = GetSkillRank(SKILL_ANIMAL_EMPATHY, oCreature);
    //ai_Debug("0i_talents", "602", "Check Animal Empathy: Rnk: " + IntToString(nEmpathyRnk) +
    //          " HitDice + 1: " + IntToString(GetHitDice(oCreature) + 1) +
    //          " Concentration: " + IntToString(GetSkillRank(SKILL_CONCENTRATION, oTarget)) + ".");
     nDC += GetHitDice(oTarget);
    // Our chance is greater than 50%.
    if(nEmpathyRnk >= nDC) return FALSE;
    //ai_Debug("0i_talents", "608", "USING ANIMAL EMPATHY SKILL.");
    ai_UseSkill(oCreature, SKILL_ANIMAL_EMPATHY, oTarget);
    return TRUE;
}
// *****************************************************************************
// ************************* Try * Feats ***************************************
// *****************************************************************************
// These functions try to find and use a specific set of feats intelligently.

void ai_UseFeat(object oCreature, int nFeat, object oTarget)
{
    ai_SetLastAction(oCreature, AI_LAST_ACTION_USED_FEAT);
    //ai_Debug("0i_talents", "620", GetName(oCreature) + " is using feat: " +
    //         GetStringByStrRef(StringToInt(Get2DAString("feat", "FEAT", nFeat))) +
    //         " on " + GetName(oTarget));
    ActionUseFeat(nFeat, oTarget);
}
void ai_UseFeatAttackMode(object oCreature, int nActionMode, int nAction, object oTarget, int nInMelee = 0, int bPassive = FALSE)
{
    //ai_Debug("0i_talents", "627", "Action mode (" + IntToString(nActionMode) + ") Is it set?: " +
    //         IntToString(GetActionMode(oCreature, nActionMode)));
    if(!GetActionMode(oCreature, nActionMode))
    {
        //ai_Debug("0i_talents", "631", "Setting action mode: " + IntToString(nActionMode));
        SetActionMode(oCreature, nActionMode, TRUE);
        SetLocalInt(oCreature, AI_CURRENT_ACTION_MODE, nActionMode);
    }
    ai_ActionAttack(oCreature, nAction, oTarget, nInMelee, bPassive);
}
int ai_TryBarbarianRageFeat(object oCreature)
{
    // Must not have rage already, must have the feat, and enemy must be strong enough.
    if(GetHasFeatEffect(FEAT_BARBARIAN_RAGE, oCreature) ||
       !GetHasFeat(FEAT_BARBARIAN_RAGE, oCreature)) return FALSE;
    //ai_Debug("0i_talents", "642", "USING BARBARIAN RAGE.");
    ai_UseFeat(oCreature, FEAT_BARBARIAN_RAGE, oCreature);
    return TRUE;
}
int ai_TryBardSongFeat(object oCreature)
{
    //ai_Debug("0i_talents", "648", "BardSong Effect: " + IntToString(GetHasSpellEffect(411/*SPELL_BARD_SONG*/)) +
    //         " Level: " + IntToString(GetLevelByClass(CLASS_TYPE_BARD)) +
    //         " HasFeat: " + IntToString(GetHasFeat(FEAT_BARD_SONGS)));
    if(GetHasSpellEffect(411/*SPELL_BARD_SONG*/, oCreature) ||
       !GetHasFeat(FEAT_BARD_SONGS, oCreature)) return FALSE;
    ai_UseFeat(oCreature, FEAT_BARD_SONGS, oCreature);
    return TRUE;
}
int ai_TryCalledShotFeat(object oCreature, object oTarget)
{
    // Called shot has a -4 to hit adjustment.
    if(!ai_CanHitOpponent(oCreature, oTarget, 4)) return FALSE;
    //ai_Debug("0i_talents", "660", "USING CALLED SHOT on  " + GetName(oTarget) + ".");
    ai_UseFeat(oCreature, FEAT_CALLED_SHOT, oTarget);
    return TRUE;
}
int ai_TryDisarmFeat(object oCreature, object oTarget)
{
    // If we can't disarm them then get out!
    if(!GetIsCreatureDisarmable(oTarget)) return FALSE;
    int nEAC = GetAC(oTarget);
    int nOAtk = ai_GetCreatureAttackBonus(oCreature);
    // The combatant with the larger weapon gains +4 per size category.
    // Weapon Size in the baseitems.2da is 1 = Tiny, 2 = Small, 3 = Medium, 4 = Large.
    int nOWeaponType = GetBaseItemType(GetItemInSlot(INVENTORY_SLOT_RIGHTHAND));
    int nOWeaponSize = StringToInt(Get2DAString("baseitems", "WeaponSize", nOWeaponType));
    int nEWeaponType = GetBaseItemType(GetItemInSlot(INVENTORY_SLOT_RIGHTHAND, oTarget));
    int nEWeaponSize = StringToInt(Get2DAString("baseitems", "WeaponSize", nEWeaponType));
    nOAtk +=(nOWeaponSize - nEWeaponSize) * 4;
    // Do they have Improved Disarm?
    if(GetHasFeat(FEAT_IMPROVED_DISARM, oCreature)) nOAtk += 2;
    // Disarm has a -6 atk adjustment.
    if(!ai_CanHitOpponent(oCreature, oTarget, 6)) return FALSE;
    //ai_Debug("0i_talents", "681", "USING DISARM on  " + GetName(oTarget) + ".");
    ai_UseFeat(oCreature, FEAT_DISARM, oTarget);
    return TRUE;
}
int ai_TryExpertiseFeat(object oCreature)
{
    if(!GetHasFeat(FEAT_EXPERTISE, oCreature)) return FALSE;
    object oTarget = ai_GetEnemyAttackingMe(oCreature);
    if(oTarget == OBJECT_INVALID) return FALSE;
    // Expertise has a -5 atk and a +5 AC adjustment.
    if(!ai_EnemyCanHitMe(oCreature, oTarget)) return FALSE;
    //ai_Debug("0i_talents", "693", "USING EXPERTISE on " + GetName(oTarget) + ".");
    ai_UseFeatAttackMode(oCreature, ACTION_MODE_EXPERTISE, AI_LAST_ACTION_MELEE_ATK, oTarget);
    return TRUE;
}
int ai_TryFlurryOfBlowsFeat(object oCreature, object oTarget)
{
    if(!GetHasFeat(FEAT_FLURRY_OF_BLOWS, oCreature)) return FALSE;
    // Flurry of Blows has a -2 atk adjustment.
    if(!ai_CanHitOpponent(oCreature, oTarget, 2)) return FALSE;
    //ai_Debug("0i_talents", "704", "USING FLURRY OF BLOWS on " + GetName(oTarget) + ".");
    ai_UseFeatAttackMode(oCreature, ACTION_MODE_FLURRY_OF_BLOWS, AI_LAST_ACTION_MELEE_ATK, oTarget, TRUE);
    return TRUE;
}
int ai_TryImprovedExpertiseFeat(object oCreature)
{
    if(!GetHasFeat(FEAT_IMPROVED_EXPERTISE, oCreature)) return FALSE;
    object oTarget = ai_GetEnemyAttackingMe(oCreature);
    if(oTarget == OBJECT_INVALID) return FALSE;
    // Improved expertise has a -10 atk +10 AC adjustment.
    if(ai_EnemyCanHitMe(oCreature, oTarget)) return FALSE;
    //ai_Debug("0i_talents", "716", "USING IMPROVED EXPERTISE on " + GetName(oTarget) + ".");
    ai_UseFeatAttackMode(oCreature, ACTION_MODE_IMPROVED_EXPERTISE, AI_LAST_ACTION_MELEE_ATK, oTarget);
    return TRUE;
}
int ai_TryImprovedPowerAttackFeat(object oCreature, object oTarget)
{
    if(!GetHasFeat(FEAT_IMPROVED_POWER_ATTACK, oCreature)) return FALSE;
    // Improved Power Attack has a -10 atk adjustment.
    if(!ai_CanHitOpponent(oCreature, oTarget, 10)) return ai_TryPowerAttackFeat(oCreature, oTarget);
    ai_UseFeatAttackMode(oCreature, ACTION_MODE_IMPROVED_POWER_ATTACK, AI_LAST_ACTION_MELEE_ATK, oTarget);
    return TRUE;
}
int ai_TryKiDamageFeat(object oCreature, object oTarget)
{
    // Must have > 40 hitpoints AND
    // Damage reduction OR damage resistance
    // or just have over 200 hitpoints
    int bHasDamageReduction = FALSE;
    int bHasDamageResistance = FALSE;
    int bHasHitpoints = FALSE;
    int bHasMassiveHitpoints = FALSE;
    int bOutNumbered;
    int nCurrentHP = GetCurrentHitPoints(oTarget);
    if(nCurrentHP > 40) bHasHitpoints = TRUE;
    if(nCurrentHP > 200) bHasMassiveHitpoints = TRUE;
    if(ai_GetHasEffectType(oTarget, EFFECT_TYPE_DAMAGE_REDUCTION)) bHasDamageReduction = TRUE;
    if(ai_GetHasEffectType(oTarget, EFFECT_TYPE_DAMAGE_RESISTANCE)) bHasDamageResistance = TRUE;
    if(ai_GetNearestEnemy(oCreature, 3, 7, 7) != OBJECT_INVALID) bOutNumbered = TRUE;
    if((!bHasHitpoints || (!bHasDamageReduction && !bHasDamageResistance)) &&
      (!bHasMassiveHitpoints) && (!bHasHitpoints || !bOutNumbered)) return FALSE;
    ai_UseFeat(oCreature, FEAT_KI_DAMAGE, oTarget);
    return TRUE;
}
int ai_TryKnockdownFeat(object oCreature, object oTarget)
{
    int nMySize = GetCreatureSize(oCreature);
    if(GetHasFeat(FEAT_IMPROVED_KNOCKDOWN, oCreature)) nMySize++;
    // Prevent silly use of knockdown on immune or too-large targets.
    // Knockdown has a -4 atk adjustment.
    if(GetIsImmune(oTarget, IMMUNITY_TYPE_KNOCKDOWN) ||
       GetCreatureSize(oTarget) > nMySize + 1 ||
       !ai_CanHitOpponent(oCreature, oTarget, 4)) return FALSE;
    ai_UseFeat(oCreature, FEAT_KNOCKDOWN, oTarget);
    return TRUE;
}
int ai_TryPowerAttackFeat(object oCreature, object oTarget)
{
    if(!GetHasFeat(FEAT_POWER_ATTACK, oCreature)) return FALSE;
    // Power Attack has a -5 atk adjustment.
    // If we have Improved Power attack and can hit with power attack maybe check it.
    if(!ai_CanHitOpponent(oCreature, oTarget, 5)) return ai_TryImprovedPowerAttackFeat(oCreature, oTarget);
    ai_UseFeatAttackMode(oCreature, ACTION_MODE_POWER_ATTACK, AI_LAST_ACTION_MELEE_ATK, oTarget);
    return TRUE;
}
int ai_TryQuiveringPalmFeat(object oCreature, object oTarget)
{
    // Must have the feat, and enemy must be lower level, and not immune to crits.
    if(!GetHasFeat(FEAT_QUIVERING_PALM, oCreature) ||
        GetHitDice(oTarget) >= GetHitDice(oCreature) ||
        GetIsImmune(oTarget, IMMUNITY_TYPE_CRITICAL_HIT)) return FALSE;
    ai_UseFeat(oCreature, FEAT_QUIVERING_PALM, oTarget);
    return TRUE;
}
int ai_TryRapidShotFeat(object oCreature, object oTarget, int nInMelee)
{
    if(!GetHasFeat(FEAT_RAPID_SHOT, oCreature)) return FALSE;
    // Rapidshot has a -4 atk adjustment.
    if(!ai_CanHitOpponent(oCreature, oTarget, 4)) return FALSE;
    ai_UseFeatAttackMode(oCreature, ACTION_MODE_RAPID_SHOT, AI_LAST_ACTION_RANGED_ATK, oTarget, TRUE);
    return TRUE;
}
int ai_TrySapFeat(object oCreature, object oTarget)
{
    // Does not work on creatures that cannot be hit by criticals or stunned.
    // Sap has a -4 atk adjustment.
    if(GetIsImmune(oTarget, IMMUNITY_TYPE_CRITICAL_HIT) ||
       GetIsImmune(oTarget, IMMUNITY_TYPE_STUN) ||
       !ai_CanHitOpponent(oCreature, oTarget, 4)) return FALSE;
    ai_UseFeat(oCreature, FEAT_SAP, oTarget);
    return TRUE;
}
int ai_TrySmiteEvilFeat(object oCreature, object oTarget)
{
    if(!GetHasFeat(FEAT_SMITE_EVIL, oCreature) ||
       GetAlignmentGoodEvil(oTarget) != ALIGNMENT_EVIL ||
       !ai_StrongOpponent(oCreature, oTarget)) return FALSE;
    ai_UseFeat(oCreature, FEAT_SMITE_EVIL, oTarget);
    return TRUE;
}
int ai_TrySmiteGoodFeat(object oCreature, object oTarget)
{
    if(!GetHasFeat(FEAT_SMITE_GOOD, oCreature) ||
       GetAlignmentGoodEvil(oTarget) != ALIGNMENT_GOOD ||
       !ai_StrongOpponent(oCreature, oTarget)) return FALSE;
    ai_UseFeat(oCreature, FEAT_SMITE_GOOD, oTarget);
    return TRUE;
}
int ai_TryStunningFistFeat(object oCreature, object oTarget)
{
    // Cannot use if we have a weapon equiped.
    if(GetItemInSlot(INVENTORY_SLOT_RIGHTHAND, oCreature) != OBJECT_INVALID) return FALSE;
    // Does not work on creatures that cannot be hit by criticals or stunned.
    // Stunning Fists has a -4 atk adjustment.
    if(!GetHasFeat(FEAT_STUNNING_FIST, oCreature) ||
       GetIsImmune(oTarget, IMMUNITY_TYPE_CRITICAL_HIT) ||
       GetIsImmune(oTarget, IMMUNITY_TYPE_STUN) ||
       !ai_StrongOpponent(oCreature, oTarget) && ai_CanHitOpponent(oCreature, oTarget, 4)) return FALSE;
    ai_UseFeat(oCreature, FEAT_STUNNING_FIST, oTarget);
    return TRUE;
}
void ai_NameAssociate(object oCreature, int nAssociateType, string sName)
{
    object oAssociate = GetAssociate(nAssociateType, oCreature);
    SetName(oAssociate, sName);
    ChangeFaction(oAssociate, oCreature);
}
int ai_TrySummonAnimalCompanionTalent(object oCreature)
{
    if(!AI_SUMMON_COMPANIONS || !GetHasFeat(FEAT_ANIMAL_COMPANION, oCreature)) return FALSE;
    if(GetAssociate(ASSOCIATE_TYPE_ANIMALCOMPANION, oCreature) != OBJECT_INVALID) return FALSE;
    ai_UseFeat(oCreature, FEAT_ANIMAL_COMPANION, oCreature);
    //SummonAnimalCompanion(oCreature);
    //DecrementRemainingFeatUses(oCreature, FEAT_ANIMAL_COMPANION);
    //DelayCommand(0.0, ai_NameAssociate(oCreature, ASSOCIATE_TYPE_FAMILIAR, "Animal Companion"));
    //ai_SetLastAction(oCreature, AI_LAST_ACTION_USED_FEAT);
    return TRUE;
}
int ai_TrySummonFamiliarTalent(object oCreature)
{
    if(!AI_SUMMON_FAMILIARS || !GetHasFeat(FEAT_SUMMON_FAMILIAR, oCreature)) return FALSE;
    if(GetAssociate(ASSOCIATE_TYPE_FAMILIAR, oCreature) != OBJECT_INVALID) return FALSE;
    ai_UseFeat(oCreature, FEAT_SUMMON_FAMILIAR, oCreature);
    //DelayCommand(0.0, ai_NameAssociate(oCreature, ASSOCIATE_TYPE_FAMILIAR, "Familiar"));
    //ai_SetLastAction(oCreature, AI_LAST_ACTION_USED_FEAT);
    return TRUE;
}
int ai_TryTurningTalent(object oCreature)
{
    if(!GetHasFeat(FEAT_TURN_UNDEAD, oCreature)) return FALSE;
    int nCount;
    int nConstructs = GetHasFeat(FEAT_DESTRUCTION_DOMAIN_POWER, oCreature);
    int nOutsider = GetHasFeat(FEAT_GOOD_DOMAIN_POWER, oCreature)
        + GetHasFeat(FEAT_EVIL_DOMAIN_POWER, oCreature)
        + GetHasFeat(1000/*FEAT_PLANAR_TURNING*/, oCreature);
    // Now check for the number of creatures of that racial type based
    // on what feats we have.
    if(GetHasFeat(FEAT_AIR_DOMAIN_POWER, oCreature) ||
       GetHasFeat(FEAT_EARTH_DOMAIN_POWER, oCreature) ||
       GetHasFeat(FEAT_FIRE_DOMAIN_POWER, oCreature) ||
       GetHasFeat(FEAT_WATER_DOMAIN_POWER, oCreature))
    {
        nCount += ai_GetRacialTypeCount(oCreature, RACIAL_TYPE_ELEMENTAL);
    }
    if(GetHasFeat(FEAT_PLANT_DOMAIN_POWER, oCreature)) nCount += ai_GetRacialTypeCount(oCreature, RACIAL_TYPE_VERMIN);
    if(GetHasFeat(FEAT_GOOD_DOMAIN_POWER, oCreature) ||
       GetHasFeat(FEAT_EVIL_DOMAIN_POWER, oCreature) ||
       GetHasFeat(1000/*PLANAR_TURNING*/, oCreature)) nCount += ai_GetRacialTypeCount(oCreature, RACIAL_TYPE_OUTSIDER);
    if(GetHasFeat(FEAT_DESTRUCTION_DOMAIN_POWER, oCreature)) nCount += ai_GetRacialTypeCount(oCreature, RACIAL_TYPE_CONSTRUCT);
    nCount += ai_GetRacialTypeCount(oCreature, RACIAL_TYPE_UNDEAD);
    if(nCount <= d3()) return FALSE;
    ai_UseFeat(oCreature, FEAT_TURN_UNDEAD, oCreature);
    return TRUE;
}
int ai_TryWhirlwindFeat(object oCreature)
{
    if(!GetHasFeat(FEAT_WHIRLWIND_ATTACK, oCreature)) return FALSE;
    // Only worth using if there are 3+ targets.
    //ai_Debug("0i_talents", "889", "WHIRLWIND : NumOfEnemies: " + IntToString(ai_GetNumOfEnemiesInGroup(oCreature, 3.0)) + ".");
    // Shortened distance so its more effective(went from 5.0 to 2.0 and up to 3.0)
    if(ai_GetNumOfEnemiesInGroup(oCreature, 3.0) < d3() + 1) return FALSE;
    // * DO NOT WHIRLWIND if any of the targets are "large" or bigger
    // * it seldom works against such large opponents.
    // * Though its okay to use Improved Whirlwind against these targets
    if((!GetHasFeat(FEAT_IMPROVED_WHIRLWIND, oCreature)) ||
      (GetCreatureSize(ai_GetNearestEnemy(oCreature, 1, 7, 7)) >= CREATURE_SIZE_LARGE &&
         GetCreatureSize(ai_GetNearestEnemy(oCreature, 2, 7, 7)) >= CREATURE_SIZE_LARGE))
    //ai_Debug("0i_talents", "898", "USING WHIRLWIND.");
    ai_UseFeat(oCreature, FEAT_WHIRLWIND_ATTACK, oCreature);
    return TRUE;
}
int ai_TryWholenessOfBodyFeat(object oCreature)
{
    if(!GetHasFeat(FEAT_WHOLENESS_OF_BODY, oCreature)) return FALSE;
    // Get when we are suppose to heal base off conversation with PC or
    // on spawn generation.
    int nHp = ai_GetPercHPLoss(oCreature);
    if(nHp >= AI_HEALTH_WOUNDED) return FALSE;
    //ai_Debug("0i_talents", "909", "USING WHOLENESS OF BODY.");
    ai_UseFeat(oCreature, FEAT_WHOLENESS_OF_BODY, oCreature);
    return TRUE;
}
// *****************************************************************************
// ******************** Try Physical Attack Talents ****************************
// *****************************************************************************
// These functions try to find and use physical attack talents intelligently.

void ai_ActionAttack(object oCreature, int nAction, object oTarget, int nInMelee = 0, int bPassive = FALSE)
{
    ai_SetLastAction(oCreature, nAction);
    // If we are doing a ranged attack then check our position on the battlefield.
    if(nAction == AI_LAST_ACTION_RANGED_ATK) ai_CheckCombatPosition(oCreature, oTarget, nInMelee, nAction);
    //ai_Debug("0i_talents", "913", GetName(oCreature) + " is attacking(" + IntToString(nAction) +
    //         ") " + GetName(oTarget) + " Current Action: " + IntToString(GetCurrentAction(oCreature)) +
    //         " Attacked Target: " + GetName(ai_GetAttackedTarget(oCreature)));
    ActionAttack(oTarget, bPassive);
}
void ai_FlyToAttacks(object oCreature, object oTarget)
{
    ai_TryWingAttacks(oCreature);
    // If we don't do a Tail sweep attack then see if we can do a Tail slap!
    if(!ai_TryTailSweepAttack(oCreature)) ai_TryTailSlap(oCreature);
    ai_ActionAttack(oCreature, AI_LAST_ACTION_MELEE_ATK, oTarget);
}
void ai_FlyToTarget(object oCreature, object oTarget)
{
    //ai_Debug("0i_talents", "938", GetName(OBJECT_SELF) + " is flying to " + GetName(oTarget) + "!");
    effect eFly = EffectDisappearAppear(GetLocation(oTarget));
    ApplyEffectToObject(DURATION_TYPE_TEMPORARY, eFly, oCreature, 3.0f);
    DelayCommand(4.0f, ai_FlyToAttacks(oCreature, oTarget));
    // Used to make creature wait before starting its next round.
    SetLocalInt(oCreature, AI_COMBAT_WAIT_IN_SECONDS, 5);
}
int ai_TryDragonBreathAttack(object oCreature, int nRound, object oTarget = OBJECT_INVALID)
{
    int nCnt = GetLocalInt(oCreature, "AI_DRAGONS_BREATH");
    //ai_Debug("0i_talents", "948", "Try Dragon Breath Attack: nRound(" + IntToString(nRound) + ")" +
    //         " > nCnt(" + IntToString(nCnt) + ")!");
    if(nRound <= nCnt) return FALSE;
    talent tUse = GetCreatureTalentBest(TALENT_CATEGORY_DRAGONS_BREATH, 20, oCreature);
    if(GetIsTalentValid(tUse)) return FALSE;
    int nRoll, nInMelee;
    if(oTarget == OBJECT_INVALID)
    {
        string sIndex = IntToString(ai_GetHighestMeleeIndexNotInAOE(oCreature));
        nInMelee = GetLocalInt(oCreature, AI_ENEMY + "_MELEE" + sIndex) + 1;
        oTarget = GetLocalObject(oCreature, AI_ENEMY + sIndex);
        // If they found one target and we have a 25% chance when in melee to use it.
        nRoll = d4();
        //ai_Debug("0i_talents", "961", "oTarget: " + GetName(oTarget) + " nInMelee:" + IntToString(nInMelee) +
        //       " d4:" + IntToString(nRoll) + " nTalent: " + IntToString(GetIdFromTalent(tUse)));
        if(oTarget != OBJECT_INVALID && nInMelee < nRoll) return FALSE;
    }
    SetLocalInt(oCreature, "AI_DRAGONS_BREATH", d4() + nRound);
    ai_UseFeat(oCreature, GetIdFromTalent(tUse), oTarget);
    return TRUE;
}
void ai_DragonMeleeAttack(object oCreature, object oTarget, string sDmgDice, string sText)
{
    //ai_Debug("0i_talents", "971", "oAttacker: " + GetName(oCreature) +
    //          " oTarget: " + GetName(oTarget));
    int nDmg, nCheck, nAB = ai_GetCreatureAttackBonus(oCreature) - 5;
    int nAC = GetAC(oTarget);
    int nRoll = d20();
    string sHit;
    // nCheck is a hit if nCheck > -1 and a miss if < 0;
    if(nRoll == 20) nCheck = 20;
    // We add one to the check so a equal result is still a hit.
    else if(nRoll > 1) nCheck = nRoll + nAB - nAC + 1;
    else nCheck == 0;
    if(nCheck > 0)
    {
        nDmg = ai_RollDiceString(sDmgDice);
        if(nCheck == 20) nDmg = nDmg * 2;
    }
    if(nCheck > 0) sHit = "*hit*";
    else sHit = "*miss*";
    string sMessage = ai_AddColorToText(GetName(oCreature) + "'s", COLOR_LIGHT_MAGENTA) +
                      ai_AddColorToText(sText + "attacks " + GetName(oTarget) + " : " + sHit + " :(" +
                      IntToString(nRoll) + " + " + IntToString(nAB) +
                      " = " + IntToString(nRoll + nAB) + ")", COLOR_DARK_ORANGE);
    SendMessageToPC(oCreature, sMessage);
    SendMessageToPC(oTarget, sMessage);
    //ai_Debug("0i_talents", "995", "nAB: " + IntToString(nAB) +
    //          " nAC: " + IntToString(nAC) + " nRoll: " + IntToString(nRoll) +
    //          " nCheck: " + IntToString(nCheck) + " nDmg: " + IntToString(nDmg));
    if(nCheck <= 0) return;
    // Apply any damage to the target!
    effect eDmg = EffectDamage(nDmg, DAMAGE_TYPE_BLUDGEONING);
    ApplyEffectToObject(DURATION_TYPE_INSTANT, eDmg, oTarget);
}
// Checks to see if a dragon can use its wings on a nearby enemy.
// Checks the right side and then the left side to see if it can attack.
int ai_TryWingAttacks(object oCreature)
{
    //ai_Debug("0i_talents", "1007", GetName(oCreature) + " is checking for wing Attacks!");
    // Only Medium size dragons can use thier wings in combat.
    // We use HitDice to base size S:1-5, M:6-11, L:12-17, H:18-29, G:30-39, C:40+.
    int nHitDice = GetHitDice(oCreature);
    if(nHitDice <= 5) return FALSE;
    int nDragonSize;
    string sDmgDice, sMessage;
    float fSize;
    // Get the stats based on the size of the dragon.
    if(nHitDice < 12) { fSize = 5.0f; nDragonSize = 3; sDmgDice = "1d4"; } // Medium
    else if(nHitDice < 18) { fSize = 10.0f; nDragonSize = 4; sDmgDice = "1d6"; } // Large
    else if(nHitDice < 30) { fSize = 10.0f; nDragonSize = 5; sDmgDice = "1d8"; } // Huge
    else if(nHitDice < 40) { fSize = 15.0f; nDragonSize = 6; sDmgDice = "2d6"; } // Gargantuan
    else { fSize = 15.0f; nDragonSize = 7; sDmgDice = "2d8"; } // Colossal
    // Add half the dragons strength modifier.
    int nDmg = GetAbilityModifier(ABILITY_STRENGTH, oCreature);
    if(nDmg > 0) sDmgDice = sDmgDice + "+" + IntToString(nDmg / 2);
    //ai_Debug("0i_talents", "1024", "nHitDice: " + IntToString(nHitDice) +
    //          " nDragonSize: " + IntToString(nDragonSize) +
    //          " sDmgDice: " + sDmgDice + " nDmg: " + IntToString(nDmg));
    // Get the closest enemy to our right wing.
    location lWing = GetFlankingRightLocation(oCreature);
    object oTarget = GetFirstObjectInShape(SHAPE_SPHERE, fSize, lWing);
    while(oTarget != OBJECT_INVALID)
    {
        //ai_Debug("0i_talents", "1032", "oTarget: " + GetName(oTarget));
        if(GetIsEnemy(oTarget) && !GetIsDead(oTarget)) break;
        oTarget = GetNextObjectInShape(SHAPE_SPHERE, fSize, lWing);
    }
    if(oTarget != OBJECT_INVALID) ai_DragonMeleeAttack(oCreature, oTarget, sDmgDice, " right wing ");
    // Get the closest enemy to our left wing.
    lWing = GetFlankingLeftLocation(oCreature);
    oTarget = GetFirstObjectInShape(SHAPE_SPHERE, fSize, lWing);
    while(oTarget != OBJECT_INVALID)
    {
        //ai_Debug("0i_talents", "1042", "oTarget: " + GetName(oTarget));
        if(GetIsEnemy(oTarget) && !GetIsDead(oTarget)) break;
        oTarget = GetNextObjectInShape(SHAPE_SPHERE, fSize, lWing);
    }
    if(oTarget != OBJECT_INVALID) ai_DragonMeleeAttack(oCreature, oTarget, sDmgDice, " left wing ");
    return TRUE;
}
// Looks behind the dragon to see if it can use it's tail slap on an enemy.
int ai_TryTailSlap(object oCreature)
{
    //ai_Debug("0i_talents", "1052", GetName(OBJECT_SELF) + " is checking for tail slap Attack!");
    // Only Large size dragons can use thier tail in combat.
    // We use HitDice to base size S:1-5, M:6-11, L:12-17, H:18-29, G:30-39, C:40+.
    int nHitDice = GetHitDice(oCreature);
    if(nHitDice <= 11) return FALSE;
    int nDragonSize;
    string sDmgDice, sMessage;
    float fSize;
    // Get the stats based on the size of the dragon.
    if(nHitDice < 12) { fSize = 5.0f; nDragonSize = 3; sDmgDice = "1d4"; } // Medium
    else if(nHitDice < 18) { fSize = 10.0f; nDragonSize = 4; sDmgDice = "1d6"; } // Large
    else if(nHitDice < 30) { fSize = 10.0f; nDragonSize = 5; sDmgDice = "1d8"; } // Huge
    else if(nHitDice < 40) { fSize = 15.0f; nDragonSize = 6; sDmgDice = "2d6"; } // Gargantuan
    else { fSize = 15.0f; nDragonSize = 7; sDmgDice = "2d8"; } // Colossal
    // Add one and a half the dragons strength modifier.
    int nDmg = GetAbilityModifier(ABILITY_STRENGTH, oCreature);
    if(nDmg > 0) sDmgDice = sDmgDice + "+" + IntToString(nDmg + nDmg / 2);
    //ai_Debug("0i_talents", "1069", "nHitDice: " + IntToString(nHitDice) +
    //          " nDragonSize: " + IntToString(nDragonSize) +
    //          " sDmgDice: " + sDmgDice + " nDmg: " + IntToString(nDmg));
    // Get the closest enemy to our tail.
    location lTail = GetBehindLocation(oCreature);
    object oTarget = GetFirstObjectInShape(SHAPE_SPHERE, fSize, lTail);
    while(oTarget != OBJECT_INVALID)
    {
        if(GetIsEnemy(oTarget) && !GetIsDead(oTarget)) break;
        oTarget = GetNextObjectInShape(SHAPE_SPHERE, fSize, lTail);
    }
    if(oTarget != OBJECT_INVALID) ai_DragonMeleeAttack(oCreature, oTarget, sDmgDice, " tail ");\
    return TRUE;
}
void ai_CrushEffect(object oCreature, object oBaseTarget, int nHitDice)
{
    int nDragonSize, nAtkValue, nDC = ai_GetDragonDC(oCreature);
    string sDmgDice, sMessage;
    location lImpact = GetLocation(oBaseTarget);
    float fSize;
    // Get the stats based on the size of the dragon.
    if(nHitDice < 30) { fSize = 15.0f; nDragonSize = 5; sDmgDice = "2d8"; } // Huge
    else if(nHitDice < 40) { fSize = 25.0f; nDragonSize = 6; sDmgDice = "4d6"; } // Gargantuan
    else { fSize = 45.0f; nDragonSize = 7; sDmgDice = "4d8"; } // Colossal
    // Add the dragons strength modifier 1.5 times.
    int nDmgBonus = GetAbilityModifier(ABILITY_STRENGTH, oCreature);
    if(nDmgBonus > 0) sDmgDice = sDmgDice + "+" + IntToString(nDmgBonus + nDmgBonus / 2);
    // Dragon flies up and then crushes the area below it.
    effect eDmg, eKnockDown = EffectKnockdown();
    effect eImpact = EffectVisualEffect(VFX_FNF_SCREEN_SHAKE);
    object oTarget = GetFirstObjectInShape(SHAPE_SPHERE, fSize, lImpact);
    while(oTarget != OBJECT_INVALID)
    {
        if(ai_GetIsCharacter(oTarget)) DelayCommand(1.0, ApplyEffectToObject(DURATION_TYPE_INSTANT, eImpact, oTarget));
        // If they have evasion they automatically dodge the crush attack.
        if(!GetHasFeat(FEAT_EVASION, oTarget) && oTarget != oCreature)
        {
            if(!ReflexSave(oTarget, nDC, SAVING_THROW_TYPE_NONE, oCreature))
            {
                eDmg =EffectDamage(ai_RollDiceString(sDmgDice), DAMAGE_TYPE_BLUDGEONING);
                ApplyEffectToObject(DURATION_TYPE_INSTANT, eDmg, oTarget);
                sMessage =  ai_AddColorToText(GetName(oCreature), COLOR_LIGHT_MAGENTA) +
                            ai_AddColorToText(" crushes " + GetName(oTarget) + ".", COLOR_DARK_ORANGE);
                if(ai_GetIsCharacter(oTarget)) SendMessageToPC(oTarget, sMessage);
                // Must be 3 sizes smaller to be affected by extra damage and knockdown.
                if(nDragonSize - 2 < GetCreatureSize(oTarget))
                {
                    if(!GetIsImmune(oTarget, IMMUNITY_TYPE_KNOCKDOWN))
                    {
                        ApplyEffectToObject(DURATION_TYPE_INSTANT, eDmg, oTarget);
                        ApplyEffectToObject(DURATION_TYPE_TEMPORARY, eKnockDown, oTarget, 6.0f);
                    }
                }
            }
        }
        else
        {
            if(ai_GetIsCharacter(oTarget))
            {
                sMessage =  ai_AddColorToText(GetName(oTarget), COLOR_LIGHT_MAGENTA) +
                      ai_AddColorToText(" dodges the crush attack from " + GetName(oTarget) + ".", COLOR_DARK_ORANGE);
                SendMessageToPC(oTarget, sMessage);
            }
        }
        oTarget = GetNextObjectInShape(SHAPE_SPHERE, fSize, lImpact);
    }
    // Now do normal attacks!
    ai_FlyToAttacks(oCreature, oBaseTarget);
}
int ai_TryCrushAttack(object oCreature, object oTarget)
{
    //ai_Debug("0i_talents", "1140", GetName(OBJECT_SELF) + " is checking for crush Attack!");
    // Only Huge size dragons can use crush attack.
    // We use HitDice to base size S:1-5, M:6-11, L:12-17, H:18-29, G:30-39, C:40+.
    int nHitDice = GetHitDice(oCreature);
    if(nHitDice <= 17) return FALSE;
    int nCrush = GetLocalInt(oCreature, "0_DRAGON_CRUSH") - 1;
    if(nCrush > 0)
    {
        SetLocalInt(oCreature, "0_DRAGON_CRUSH", nCrush);
        return FALSE;
    }
    effect eFly = EffectDisappearAppear(GetLocation(oTarget));
    ApplyEffectToObject(DURATION_TYPE_TEMPORARY, eFly, oCreature, 3.0f);
    DelayCommand(4.0f, ai_CrushEffect(oCreature, oTarget, nHitDice));
    // Used to make creature wait before starting its next round.
    SetLocalInt(oCreature, AI_COMBAT_WAIT_IN_SECONDS, 5);
    // We only crush every 3 rounds if we can.
    SetLocalInt(oCreature, "0_DRAGON_CRUSH", 3);
    return TRUE;
}
int ai_TryTailSweepAttack(object oCreature)
{
    //ai_Debug("0i_talents", "1162", GetName(oCreature) + " is checking for tail sweep Attack!");
    // Only Gargantuan size dragons can use tail sweep attack.
    // We use HitDice to base size S:1-5, M:6-11, L:12-17, H:18-29, G:30-40, C:40+.
    int nHitDice = GetHitDice(oCreature);
    if(nHitDice <= 29) return FALSE;
    int nSweep = GetLocalInt(oCreature, "0_DRAGON_SWEEP") - 1;
    if(nSweep > 0)
    {
        SetLocalInt(oCreature, "0_DRAGON_SWEEP", nSweep);
        return FALSE;
    }
    int nDragonSize, nAtkValue, nDC = ai_GetDragonDC(oCreature);
    string sDmgDice, sMessage;
    float fSize;
    // Get the stats based on the size of the dragon.
    if(nHitDice < 33) { fSize = 15.0f; nDragonSize = 6; sDmgDice = "2d6"; } // Gargantuan
    else { fSize = 40.0f; nDragonSize = 7; sDmgDice = "2d8"; } // Colossal
    location lImpact = GetBehindLocation(oCreature);
    // We always sweep if we have the opportunity.
    // Add the dragons strength modifier 1.5 times.
    int nDmgBonus = GetAbilityModifier(ABILITY_STRENGTH, oCreature);
    if(nDmgBonus > 0) sDmgDice = sDmgDice + "+" + IntToString(nDmgBonus + nDmgBonus / 2);
    // Sweeps any creatures behind them.
    effect eDmg;
    effect eKnockDown = EffectKnockdown();
    object oTarget = GetFirstObjectInShape(SHAPE_SPHERE, fSize, lImpact);
    while(oTarget != OBJECT_INVALID)
    {
        sMessage =  ai_AddColorToText(GetName(oCreature), COLOR_LIGHT_MAGENTA) +
                    ai_AddColorToText(" sweeps " + GetName(oTarget) + ".", COLOR_ORANGE);
        if(ai_GetIsCharacter(oTarget)) SendMessageToPC(oTarget, sMessage);
        // If they have evasion they automatically dodge the sweep attack.
        if(!GetHasFeat(FEAT_EVASION, oTarget) && oTarget != oCreature)
        {
            if(!ReflexSave(oTarget, nDC, SAVING_THROW_TYPE_NONE, oCreature))
            {
                eDmg = EffectDamage(ai_RollDiceString(sDmgDice), DAMAGE_TYPE_BLUDGEONING);
                ApplyEffectToObject(DURATION_TYPE_INSTANT, eDmg, oTarget);
                // Must be 4 sizes smaller to be affected by extra damage and knockdown.
                if(nDragonSize - 3 < GetCreatureSize(oTarget))
                {
                    if(!GetIsImmune(oTarget, IMMUNITY_TYPE_KNOCKDOWN))
                    {
                        ApplyEffectToObject(DURATION_TYPE_TEMPORARY, eKnockDown, oTarget, 12.0f);
                    }
                }
            }
        }
    }
    oTarget = GetNextObjectInShape(SHAPE_SPHERE, fSize, lImpact);
    // We only sweep every 3 rounds if we can.
    SetLocalInt(oCreature, "0_DRAGON_SWEEP", 3);
    return TRUE;
}
int ai_TrySneakAttack(object oCreature, int nInMelee, int bAlwaysAtk = TRUE)
{
    //ai_Debug("0i_talents", "1218", GetName(OBJECT_SELF) + " is checking for melee Sneak Attack!");
    if(!GetHasFeat(FEAT_SNEAK_ATTACK, oCreature)) return FALSE;
    // Lets get the nearest target that is attacking someone besides me.
    object oTarget = OBJECT_INVALID;
    if(ai_GetAssociateMode(oCreature, AI_MODE_DEFEND_MASTER)) oTarget = ai_GetLowestCRAttackerOnMaster(oCreature);
    if(oTarget == OBJECT_INVALID)
    {
        // Check if we have Mobility, Spring Attack or a good tumble.
        // if we do then look for other targets besides who we are in melee with.
        float fRange;
        if(!nInMelee || ai_CanIMoveInCombat(oCreature)) fRange = AI_RANGE_PERCEPTION;
        else fRange = AI_RANGE_MELEE;
        string sIndex = IntToString(ai_GetBestSneakAttackIndex(oCreature, fRange, bAlwaysAtk));
        oTarget = GetLocalObject(oCreature, AI_ENEMY + sIndex);
    }
    if(oTarget == OBJECT_INVALID) return FALSE;
    ai_ActionAttack(oCreature, AI_LAST_ACTION_MELEE_ATK, oTarget);
    return TRUE;
}
int ai_TryRangedSneakAttack(object oCreature, int nInMelee)
{
    //ai_Debug("0i_talents", "1239", GetName(oCreature) + " is checking for a Ranged Sneak Attack!");
    // If we have Sneak Attack then we should be attacking targets that
    // are busy fighting so we can get extra damage.
    if(!GetHasFeat(FEAT_SNEAK_ATTACK, oCreature)) return FALSE;
    object oTarget = OBJECT_INVALID;
    if(ai_GetAssociateMode(oCreature, AI_MODE_DEFEND_MASTER)) oTarget = ai_GetLowestCRAttackerOnMaster(oCreature);
    if(oTarget == OBJECT_INVALID) oTarget = GetLocalObject(oCreature, AI_ENEMY + IntToString(ai_GetBestSneakAttackIndex(oCreature)));
    if(oTarget == OBJECT_INVALID) return FALSE;
    // If we have a target and are not within 30' then move within 30'.
    if(GetDistanceToObject(oTarget) > AI_RANGE_CLOSE) ActionMoveToObject(oTarget, TRUE, AI_RANGE_CLOSE);
    ai_ActionAttack(oCreature, AI_LAST_ACTION_RANGED_ATK, oTarget, nInMelee, FALSE);
    return TRUE;
}
int ai_TryMeleeTalents(object oCreature, object oTarget)
{
    //ai_Debug("0i_talents", "1254", "Check category melee talents!");
    talent tUse = GetCreatureTalentBest(TALENT_CATEGORY_HARMFUL_MELEE, 20, oCreature);
    if(!GetIsTalentValid(tUse)) return FALSE;
    int nId = GetIdFromTalent(tUse);
    //ai_Debug("0i_talents", "1258", "TALENT_CATEGORY_MELEE_TALENTS nId: " + IntToString(nId));
    if(nId == FEAT_POWER_ATTACK) { if(ai_TryPowerAttackFeat(oCreature, oTarget)) return TRUE; }
    else if(nId == FEAT_EXPERTISE) { if(ai_TryExpertiseFeat(oCreature)) return TRUE; }
    else if(nId == FEAT_KNOCKDOWN) { if(ai_TryKnockdownFeat(oCreature, oTarget)) return TRUE; }
    else if(nId == FEAT_SMITE_EVIL) { if(ai_TrySmiteEvilFeat(oCreature, oTarget)) return TRUE; }
    else if(nId == FEAT_SMITE_GOOD) { if(ai_TrySmiteGoodFeat(oCreature, oTarget)) return TRUE; }
    else if(nId == FEAT_IMPROVED_POWER_ATTACK) { if(ai_TryImprovedPowerAttackFeat(oCreature, oTarget)) return TRUE; }
    else if(nId == FEAT_IMPROVED_EXPERTISE) { if(ai_TryImprovedExpertiseFeat(oCreature)) return TRUE; }
    else if(nId == FEAT_FLURRY_OF_BLOWS) { if(ai_TryFlurryOfBlowsFeat(oCreature, oTarget)) return TRUE; }
    else if(nId == FEAT_STUNNING_FIST) { if(ai_TryStunningFistFeat(oCreature, oTarget)) return TRUE; }
    else if(nId == FEAT_SAP) { if(ai_TrySapFeat(oCreature, oTarget)) return TRUE; }
    else if(nId == FEAT_DISARM) { if(ai_TryDisarmFeat(oCreature, oTarget)) return TRUE; }
    else if(nId == FEAT_KI_DAMAGE) { if(ai_TryKiDamageFeat(oCreature, oTarget)) return TRUE; }
    return FALSE;
}
void ai_DoPhysicalAttackOnNearest(object oCreature, int nInMelee, int bAlwaysAtk = TRUE)
{
    talent tUse;
    object oTarget;
    //ai_Debug("0i_talents", "1275", "Check for ranged attack on nearest enemy!");
    // ************************** Ranged feat attacks **************************
    if(!GetHasFeatEffect(FEAT_BARBARIAN_RAGE, oCreature) && ai_CanIUseRangedWeapon(oCreature, nInMelee))
    {
        if(ai_TryRangedSneakAttack(oCreature, nInMelee)) return;
        // Lets pick off the nearest targets first.
        if(!nInMelee)
        {
            if(ai_GetAssociateMode(oCreature, AI_MODE_DEFEND_MASTER)) oTarget = ai_GetLowestCRAttackerOnMaster(oCreature);
            if(oTarget == OBJECT_INVALID) oTarget = ai_GetNearestFavoredEnemyTarget(oCreature);
            if(oTarget == OBJECT_INVALID) oTarget = ai_GetNearestTarget(oCreature);
        }
        else
        {
            if(ai_GetAssociateMode(oCreature, AI_MODE_DEFEND_MASTER)) oTarget = ai_GetLowestCRAttackerOnMaster(oCreature);
            if(oTarget == OBJECT_INVALID) oTarget = ai_GetNearestFavoredEnemyTarget(oCreature, AI_RANGE_MELEE);
            if(oTarget == OBJECT_INVALID) oTarget = ai_GetNearestTarget(oCreature, AI_RANGE_MELEE);
        }
        if(ai_TryRapidShotFeat(oCreature, oTarget, nInMelee)) return;
        //ai_Debug("0i_talents", "1294", "Do ranged attack against nearest: " + GetName(oTarget) + "!");
        ai_ActionAttack(oCreature, AI_LAST_ACTION_RANGED_ATK, oTarget, nInMelee, FALSE);
        return;
    }
    //ai_Debug("0i_talents", "1298", "Check for melee attack on nearest enemy!");
    // ************************** Melee feat attacks *************************
    if(!ai_GetIsMeleeWeapon(GetItemInSlot(INVENTORY_SLOT_RIGHTHAND))) ai_EquipBestMeleeWeapon(oCreature);
    if(ai_TryWhirlwindFeat(oCreature)) return;
    if(ai_TrySneakAttack(oCreature, nInMelee, bAlwaysAtk)) return;
    if(ai_GetAssociateMode(oCreature, AI_MODE_DEFEND_MASTER)) oTarget = ai_GetLowestCRAttackerOnMaster(oCreature);
    if(oTarget == OBJECT_INVALID) oTarget = ai_GetNearestFavoredEnemyTarget(oCreature, AI_RANGE_PERCEPTION, bAlwaysAtk);
    if(oTarget == OBJECT_INVALID) oTarget = ai_GetNearestTargetForMeleeCombat(oCreature, nInMelee, bAlwaysAtk);
    // If we don't find a target then we don't want to fight anyone!
    if(oTarget == OBJECT_INVALID) return;
    if(ai_TryMeleeTalents(oCreature, oTarget)) return;
    //ai_Debug("0i_talents", "1311", "Do melee attack against nearest: " + GetName(oTarget) + "!");
    ai_ActionAttack(oCreature, AI_LAST_ACTION_MELEE_ATK, oTarget);
}
void ai_DoPhysicalAttackOnLowestCR(object oCreature, int nInMelee, int bAlwaysAtk = TRUE)
{
   //ai_Debug("0i_talents", "1316", "Check for ranged attack on weakest enemy!");
    object oTarget;
    // ************************** Ranged feat attacks **************************
    if(!GetHasFeatEffect(FEAT_BARBARIAN_RAGE, oCreature) &&
       !ai_GetAssociateMode(oCreature, AI_MODE_STOP_RANGED) &&
       ai_CanIUseRangedWeapon(oCreature, nInMelee))
    {
        if(ai_TryRangedSneakAttack(oCreature, nInMelee)) return;
        // Lets pick off the weaker targets.
        if(!nInMelee)
        {
            if(ai_GetAssociateMode(oCreature, AI_MODE_DEFEND_MASTER)) oTarget = ai_GetLowestCRAttackerOnMaster(oCreature);
            if(oTarget == OBJECT_INVALID) oTarget = ai_GetNearestFavoredEnemyTarget(oCreature);
            if(oTarget == OBJECT_INVALID) oTarget = ai_GetLowestCRTarget(oCreature);
        }
        else
        {
            if(ai_GetAssociateMode(oCreature, AI_MODE_DEFEND_MASTER)) oTarget = ai_GetLowestCRAttackerOnMaster(oCreature);
            if(oTarget == OBJECT_INVALID) oTarget = ai_GetNearestFavoredEnemyTarget(oCreature, AI_RANGE_MELEE);
            if(oTarget == OBJECT_INVALID) oTarget = ai_GetLowestCRTarget(oCreature, AI_RANGE_MELEE);
        }
        if(ai_TryRapidShotFeat(oCreature, oTarget, nInMelee)) return;
        //ai_Debug("0i_talents", "1338", GetName(OBJECT_SELF) + " does ranged attack on weakest: " + GetName(oTarget) + "!");
        ai_ActionAttack(oCreature, AI_LAST_ACTION_RANGED_ATK, oTarget, nInMelee, FALSE);
        return;
    }
    //ai_Debug("0i_talents", "1342", "Check for melee attack on weakest enemy!");
    // ************************** Melee feat attacks *************************
    if(!ai_GetIsMeleeWeapon(GetItemInSlot(INVENTORY_SLOT_RIGHTHAND))) ai_EquipBestMeleeWeapon(oCreature);
    if(ai_TrySneakAttack(oCreature, nInMelee, bAlwaysAtk)) return;
    if(ai_TryWhirlwindFeat(oCreature)) return;
    if(ai_GetAssociateMode(oCreature, AI_MODE_DEFEND_MASTER)) oTarget = ai_GetLowestCRAttackerOnMaster(oCreature);
    if(oTarget == OBJECT_INVALID) oTarget = ai_GetNearestFavoredEnemyTarget(oCreature, AI_RANGE_PERCEPTION, bAlwaysAtk);
    if(oTarget == OBJECT_INVALID) oTarget = ai_GetLowestCRTargetForMeleeCombat(oCreature, nInMelee, bAlwaysAtk);
    if(ai_TryMeleeTalents(oCreature, oTarget)) return;
    //ai_Debug("0i_talents", "1351", GetName(OBJECT_SELF) + " does melee attack against weakest: " + GetName(oTarget) + "!");
    ai_ActionAttack(oCreature, AI_LAST_ACTION_MELEE_ATK, oTarget);
}
// *****************************************************************************
// *****************************  TALENT SCRIPTS  ******************************
// *****************************************************************************
// These functions do not fall into another section.

int ai_GetMonsterTalentMaxLevel(object oCreature)
{
    // Monsters should use either the best spell they have or a random spell so
    // they all don't look robotic. Mix it up based on an Intelligence check.
    int nMaxLevel = (ai_GetCharacterLevels(oCreature) + 1) / 2;
    if(nMaxLevel > 9) nMaxLevel = 9;
    if(d20() + GetAbilityModifier(ABILITY_INTELLIGENCE) <= AI_INTELLIGENCE_DC)
    {
        nMaxLevel = Random(nMaxLevel) + 1;
    }
    //ai_Debug("0i_talents", "1371", "nMaxLevel: " + IntToString(nMaxLevel));
    return nMaxLevel;
}
int ai_GetAssociateTalentMaxLevel(object oCreature, int nDifficulty)
{
    int nLevel = ai_GetCharacterLevels(oCreature) / 2;
    if(nLevel > 20) nLevel = 20;
    int nMaxLevel = (nLevel * nDifficulty)/25;
    if(nMaxLevel < 1) return 1;
    //ai_Debug("0i_talents", "1380", "nMaxLevel: " + IntToString(nMaxLevel));
    return nMaxLevel;
}
object ai_CheckTalentForBuffing(object oCreature, string sCategory, int nSpell)
{
    if(sCategory != "P" && sCategory != "E" &&
      (sCategory != "S" && AI_PREBUFF_SUMMONS)) return OBJECT_INVALID;
    return ai_GetBuffTarget(oCreature, 3, nSpell);
}
int ai_UseBuffTalent(object oCreature, int nClass, int nLevel, int nSlot, int nSpell, int nType, object oTarget, object oItem)
{
    if(nType == AI_TALENT_TYPE_SPELL)
    {
        if(Get2DAString("classes", "MemorizesSpells", nClass) == "1")
        {
            if(GetMemorizedSpellReady(oCreature, nClass, nLevel, nSlot))
            {
                ai_CastMemorizedSpell(oCreature, nClass, nLevel, nSlot, oTarget, 0.0);
                return TRUE;
            }
        }
        else if(GetSpellUsesLeft(oCreature, nClass, nSpell))
        {
            ai_CastKnownSpell(oCreature, nClass, nSpell, oTarget, 0.0);
            return TRUE;
        }
    }
    else if(nType == AI_TALENT_TYPE_SP_ABILITY)
    {
        ActionCastSpellAtObject(nSpell, oTarget, 255, FALSE, 0, 0, TRUE, 255);
    }
    /* This will not work as there is not cheat option for using an item.
    else if(nType == AI_TALENT_TYPE_ITEM)
    {
        int nBaseItem = GetBaseItemType(oItem);
        if(!AI_BUFF_MONSTER_POTIONS &&
          (nBaseItem == BASE_ITEM_POTIONS || nBaseItem == BASE_ITEM_ENCHANTED_POTION)) return FALSE;
        itemproperty ipProp = GetFirstItemProperty(oItem);
        while(GetIsItemPropertyValid(ipProp))
        {
            if(nIndex++ == nSlot) break;
            ipProp = GetNextItemProperty(oItem);
        }
        // Cast items have the following:
        // 1)Single_Use.
        // 2-6) Charges/Use [Note: 7 is 0 charges per use].
        // 8-12) Uses/Day [Note: 13 is unlimited uses per day].
        // We set the slot to -1 to let the other function know we need this talent removed.
        int nUses = GetItemPropertyCostTableValue(ipProp);
        if(nUses == 1) JsonArrayInsertInplace(jTalent, JsonInt(-1), 4);
        else if(nUses > 1 && nUses < 7)
        {
            //ai_Debug("0i_talents", "1432", "Item charges: " + IntToString(GetItemCharges(oItem)));
            int nCharges = GetItemCharges(oItem);
            if(nUses == 6 && nCharges == 1 || nUses == 5 && nCharges < 4 ||
               nUses == 4 && nCharges < 6 || nUses == 3 && nCharges < 8 ||
               nUses == 2 && nCharges < 10) return FALSE;
        }
        else if(nUses > 7 && nUses < 13)
        {
            //ai_Debug("0i_talents", "1440", "Item uses: " + IntToString(GetItemPropertyUsesPerDayRemaining(oItem, ipProp)));
            int nPerDay = GetItemPropertyUsesPerDayRemaining(oItem, ipProp);
            if(nUses == 8 && nPerDay == 1 || nUses == 9 && nPerDay < 4 ||
               nUses == 10 && nPerDay < 6 || nUses == 11 && nPerDay < 8 ||
               nUses == 12 && nPerDay < 10) return FASLE;
        }
        ActionUseItemOnObject(oItem, ipProp, oTarget, nSubIndex);
        return TRUE;
    } */
    return FALSE;
}
void ai_SaveTalent(object oCreature, int nClass, int nLevel, int nSlot, int nSpell, int nType, int bBuff, object oItem = OBJECT_INVALID)
{
    // Get the talent category, we organize all talents by categories.
    string sCategory = Get2DAString("ai_spells", "Category", nSpell);
    if(sCategory == "") return;
    // Check to see if we should be prebuffing.
    if(bBuff)
    {
        object oTarget = ai_CheckTalentForBuffing(oCreature, sCategory, nSpell);
        if(oTarget != OBJECT_INVALID &&
           ai_UseBuffTalent(oCreature, nClass, nLevel, nSlot, nSpell, nType, oTarget, oItem)) return;
    }
    json jCategory = GetLocalJson(oCreature, sCategory);
    // With no jCategory then we make one with all 0-9 levels.
    if(JsonGetType(jCategory) == JSON_TYPE_NULL)
    {
        jCategory = JsonArray();
        JsonArrayInsertInplace(jCategory, JsonArray(), 0);
        int nNewLevel = 9;
        while(nNewLevel > 0)
        {
            JsonArrayInsertInplace(jCategory, JsonArray());
            nNewLevel--;
        }
    }
    // Get the current Level so we can save to it.
    json jLevel = JsonArrayGet(jCategory, nLevel);
    json jTalent = JsonArray();
    if(nType == AI_TALENT_TYPE_SPELL || nType == AI_TALENT_TYPE_SP_ABILITY)
    {
        JsonArrayInsertInplace(jTalent, JsonInt(nType), 0);
        JsonArrayInsertInplace(jTalent, JsonInt(nSpell));
        JsonArrayInsertInplace(jTalent, JsonInt(nClass));
        JsonArrayInsertInplace(jTalent, JsonInt(nLevel));
        JsonArrayInsertInplace(jTalent, JsonInt(nSlot));
    }
    else if(nType == AI_TALENT_TYPE_ITEM)
    {
        JsonArrayInsertInplace(jTalent, JsonInt(nType), 0);
        JsonArrayInsertInplace(jTalent, JsonInt(nSpell));
        JsonArrayInsertInplace(jTalent, JsonString(ObjectToString(oItem)));
        JsonArrayInsertInplace(jTalent, JsonInt(nLevel));
        JsonArrayInsertInplace(jTalent, JsonInt(nSlot));
    }
    JsonArrayInsertInplace(jLevel, jTalent);
    JsonArraySetInplace(jCategory, nLevel, jLevel);
    SetLocalJson(oCreature, sCategory, jCategory);
    //ai_Debug("0i_talents", "1497", sCategory + ": " + JsonDump(jCategory, 1));
    // Set AI_NO_TALENTS so they can skip checks for nLevel.
    if(nLevel > 0) SetLocalInt(oCreature, AI_NO_TALENTS + sCategory, nLevel - 1);
    else SetLocalInt(oCreature, AI_NO_TALENTS + sCategory, 0);
}
void ai_RemoveTalent(object oCreature, json jCategory, json jLevel, string sCategory, int nLevel, int nSlotIndex)
{
    //ai_Debug("0i_talents", "1504", "removing Talent from slot: " + IntToString(nSlotIndex));
    JsonArrayDelInplace(jLevel, nSlotIndex);
    //ai_Debug("0i_talents", "1506", "jLevel: " + JsonDump(jLevel, 2));
    JsonArraySetInplace(jCategory, nLevel, jLevel);
    //ai_Debug("0i_talents", "1508", "jCategory: " + JsonDump(jCategory, 2));
    SetLocalJson(oCreature, sCategory, jCategory);
}
void ai_SetCreatureSpellTalents(object oCreature, int bBuff)
{
    //ai_Debug("0i_talents", "1513", GetName(oCreature) + ": Setting Spell Talents for combat.");
    // Cycle through all classes and spells.
    int nClassPosition = 1, nMaxSlot, nLevel, nSlot, nSpell, nIndex;
    int nClass = GetClassByPosition(nClassPosition);
    while(nClassPosition <= AI_MAX_CLASSES_PER_CHARACTER && nClass != CLASS_TYPE_INVALID)
    {
        if(Get2DAString("classes", "SpellCaster", nClass) == "1")
        {
            // Search all memorized spells for the spell.
            if(Get2DAString("classes", "MemorizesSpells", nClass) == "1")
            {
                // Check each level organizing from highest to lowest.
                nLevel = (GetLevelByPosition(nClassPosition, oCreature) + 1) / 2;
                while(nLevel > -1)
                {
                    // Check each slot within each level.
                    nMaxSlot = GetMemorizedSpellCountByLevel(oCreature, nClass, nLevel);
                    nSlot = 0;
                    while(nSlot < nMaxSlot)
                    {
                        //ai_Debug("0i_talents", "1533", "nClass: " + IntToString(nClass) +
                        //         " nLevel: " + IntToString(nLevel) +
                        //         " nSlot: " + IntToString(nSlot) + " nSpell: " +
                        //         IntToString(GetMemorizedSpellId(oCreature, nClass, nLevel, nSlot)) + " spell memorized: " +
                        //         IntToString(GetMemorizedSpellReady(oCreature, nClass, nLevel, nSlot)));
                        if(GetMemorizedSpellReady(oCreature, nClass, nLevel, nSlot) == 1)
                        {
                            nSpell = GetMemorizedSpellId(oCreature, nClass, nLevel, nSlot);
                            ai_SaveTalent(oCreature, nClass, nLevel, nSlot, nSpell, AI_TALENT_TYPE_SPELL, bBuff);
                        }
                        nSlot++;
                    }
                    nLevel--;
                }
            }
            // Check non-memorized known lists for the spell.
            else
            {
                // Check each level starting with the highest to lowest.
                nLevel = (GetLevelByPosition(nClassPosition, oCreature) + 1) / 2;
                while(nLevel > -1)
                {
                    // Check each slot within each level.
                    nMaxSlot = GetKnownSpellCount(oCreature, nClass, nLevel);
                    nSlot = 0;
                    while(nSlot < nMaxSlot)
                    {
                        nSpell = GetKnownSpellId(oCreature, nClass, nLevel, nSlot);
                        if(GetSpellUsesLeft(oCreature, nClass, nSpell) > 0)
                        {
                            ai_SaveTalent(oCreature, nClass, nLevel, nSlot, nSpell, AI_TALENT_TYPE_SPELL, bBuff);
                        }
                        nSlot++;
                    }
                    nLevel--;
                }
            }
        }
        nClassPosition++;
        nClass = GetClassByPosition(nClassPosition);
    }
}
void ai_SetCreatureSpecialAbilityTalents(object oCreature, int bBuff)
{
    //ai_Debug("0i_talents", "1577", GetName(oCreature) + ": Setting Special Ability Talents for combat.");
    // Cycle through all the creatures special abilities.
    int nMaxSpecialAbilities = GetSpellAbilityCount(oCreature);
    //ai_Debug("0i_talents", "1580", IntToString(GetSpellAbilityCount(oCreature)) + " Spell abilities.");
    if(nMaxSpecialAbilities)
    {
        int nIndex, nSpell, nLevel;
        while(nIndex < nMaxSpecialAbilities)
        {
            nSpell = GetSpellAbilitySpell(oCreature, nIndex);
            if(GetSpellAbilityReady(oCreature, nSpell))
            {
                nLevel = StringToInt(Get2DAString("spells", "Innate", nSpell));
                ai_SaveTalent(oCreature, 255, nLevel, nIndex, nSpell, AI_TALENT_TYPE_SP_ABILITY, bBuff);
            }
            nIndex++;
        }
    }
}
int ai_CheckUseMagicDevice(object oCreature, string sColumn, object oItem)
{
    if(!AI_ALLOW_USE_MAGIC_DEVICE) return FALSE;
    int nUMD = GetSkillRank(SKILL_USE_MAGIC_DEVICE, oCreature);
    //ai_Debug("0i_talents", "1600", GetName(oCreature) + " is check UMD: " + IntToString(nUMD));
    if(nUMD < 1) return FALSE;
    int nDC, nIndex, nItemValue = GetGoldPieceValue(oItem);
    while(nIndex < 55)
    {
        //ai_Debug("0i_talents", "1605", GetName(oItem) + " has a value of " +
        //         Get2DAString("skillvsitemcost", "DeviceCostMax", nIndex) +
        //         " nIndex: " + IntToString(nIndex));
        if(nItemValue < StringToInt(Get2DAString("skillvsitemcost", "DeviceCostMax", nIndex)))
        {
            //ai_Debug("0i_talents", "1610", "nUMD >= " + Get2DAString("skillvsitemcost", sColumn, nIndex));
            if(nUMD >= StringToInt(Get2DAString("skillvsitemcost", sColumn, nIndex))) return TRUE;
            return FALSE;
        }
        nIndex++;
    }
    return FALSE;
}
void ai_CheckItemProperties(object oCreature, object oItem, int bBuff, int bEquiped = FALSE)
{
    //ai_Debug("0i_talents", "1620", "Checking Item properties on " + GetName(oItem));
    int nIprpSubType, nSpell, nLevel;
    itemproperty ipProp;
    // We have established that we can use the item if it is equiped.
    if(!bEquiped)
    {
        ipProp = GetFirstItemProperty(oItem);
        // Lets skip this if there are no properties.
        if(!GetIsItemPropertyValid(ipProp)) return;
        int bAlign, bClass, bRace, bAlignLimit, bClassLimit, bRaceLimit, nItemPropertyType;
        // Check to see if this item is limited to a specific alignment, class, or race.
        int nAlign1 = GetAlignmentLawChaos(oCreature);
        int nAlign2 = GetAlignmentGoodEvil(oCreature);
        int nRace = GetRacialType(oCreature);
        //ai_Debug("0i_talents", "1634", "nAlign1: " + IntToString(nAlign1) +
        //         " nAlign2: " + IntToString(nAlign2) + " nRace: " + IntToString(nRace));
        while(GetIsItemPropertyValid(ipProp))
        {
            nItemPropertyType = GetItemPropertyType(ipProp);
            //ai_Debug("0i_talents", "1639", "ItempropertyType(62/63/64/65): " + IntToString(nItemPropertyType));
            if(nItemPropertyType == ITEM_PROPERTY_USE_LIMITATION_ALIGNMENT_GROUP)
            {
                bAlignLimit = TRUE;
                // SubType is the group index for iprp_aligngrp.2da
                nIprpSubType = GetItemPropertySubType(ipProp);
                //ai_Debug("0i_talents", "1645", "nIprpSubType: " + IntToString(nIprpSubType));
                if(nIprpSubType == nAlign1 || nIprpSubType == nAlign2) bAlign = TRUE;
            }
            else if(nItemPropertyType == ITEM_PROPERTY_USE_LIMITATION_SPECIFIC_ALIGNMENT)
            {
                bAlignLimit = TRUE;
                // SubType is the alignment index for iprp_alignment.2da
                nIprpSubType = GetItemPropertySubType(ipProp);
                //ai_Debug("0i_talents", "1653", "nIprpSubType: " + IntToString(nIprpSubType));
                if(nIprpSubType == 0 && nAlign1 == 2 && nAlign2 == 4) bAlign = TRUE;
                else if(nIprpSubType == 1 && nAlign1 == 2 && nAlign2 == 1) bAlign = TRUE;
                else if(nIprpSubType == 2 && nAlign1 == 2 && nAlign2 == 5) bAlign = TRUE;
                else if(nIprpSubType == 3 && nAlign1 == 1 && nAlign2 == 4) bAlign = TRUE;
                else if(nIprpSubType == 4 && nAlign1 == 1 && nAlign2 == 1) bAlign = TRUE;
                else if(nIprpSubType == 5 && nAlign1 == 1 && nAlign2 == 5) bAlign = TRUE;
                else if(nIprpSubType == 6 && nAlign1 == 3 && nAlign2 == 4) bAlign = TRUE;
                else if(nIprpSubType == 7 && nAlign1 == 3 && nAlign2 == 1) bAlign = TRUE;
                else if(nIprpSubType == 8 && nAlign1 == 3 && nAlign2 == 5) bAlign = TRUE;
            }
            else if(nItemPropertyType == ITEM_PROPERTY_USE_LIMITATION_CLASS)
            {
                bClassLimit = TRUE;
                // SubType is the class index for classes.2da
                nIprpSubType = GetItemPropertySubType(ipProp);
                //ai_Debug("0i_talents", "1669", "nIprpSubType: " + IntToString(nIprpSubType));
                int nClassPosition = 1;
                int nClass = GetClassByPosition(nClassPosition, oCreature);
                while(nClassPosition <= AI_MAX_CLASSES_PER_CHARACTER)
                {
                    if(nIprpSubType == nClass) bClass = TRUE;
                    nClass = GetClassByPosition(++nClassPosition, oCreature);
                }
            }
            else if(nItemPropertyType == ITEM_PROPERTY_USE_LIMITATION_RACIAL_TYPE)
            {
                bRaceLimit = TRUE;
                // SubType is the race index for racialtypes.2da
                nIprpSubType = GetItemPropertySubType(ipProp);
                //ai_Debug("0i_talents", "1683", "nIprpSubType: " + IntToString(nIprpSubType));
                if(nIprpSubType == nRace) bRace = TRUE;
            }
            ipProp = GetNextItemProperty(oItem);
        }
        //ai_Debug("0i_talents", "1688", "bAlignLimit: " + IntToString(bAlignLimit) + " bAlign: " + IntToString(bAlign) +
        //         " bClassLimit: " + IntToString(bClassLimit) + " bClass: " + IntToString(bClass) +
        //         " bRaceLimit: " + IntToString(bRaceLimit) + " bRace: " + IntToString(bRace));
        if(bClassLimit && !bClass && !ai_CheckUseMagicDevice(oCreature, "SkillReq_Class", oItem)) return;
        if(bRaceLimit && !bRace && !ai_CheckUseMagicDevice(oCreature, "SkillReq_Race", oItem)) return;
        if(bAlignLimit && !bAlign && !ai_CheckUseMagicDevice(oCreature, "SkillReq_Align", oItem)) return;
    }
    // Check for cast spell property and add them to the talent list.
    int nIndex;
    ipProp = GetFirstItemProperty(oItem);
    while(GetIsItemPropertyValid(ipProp))
    {
        //ai_Debug("0i_talents", "1700", "ItempropertyType(15): " + IntToString(GetItemPropertyType(ipProp)));
        if(GetItemPropertyType(ipProp) == ITEM_PROPERTY_CAST_SPELL)
        {
            // SubType is the ip spell index for iprp_spells.2da
            nIprpSubType = GetItemPropertySubType(ipProp);
            nSpell = StringToInt(Get2DAString("iprp_spells", "SpellIndex", nIprpSubType));
            nLevel = StringToInt(Get2DAString("iprp_spells", "InnateLvl", nIprpSubType));
            ai_SaveTalent(oCreature, 255, nLevel, nIndex, nSpell, AI_TALENT_TYPE_ITEM, bBuff, oItem);
        }
        nIndex++;
        ipProp = GetNextItemProperty(oItem);
    }
}
void ai_SetCreatureItemTalents(object oCreature, int bBuff)
{
    //ai_Debug("0i_talents", "1715", GetName(oCreature) + ": Setting Item Talents for combat.");
    int bEquiped;
    string sSlots;
    // Cycle through all the creatures inventory items.
    object oItem = GetFirstItemInInventory(oCreature);
    while(oItem != OBJECT_INVALID)
    {
        if(GetIdentified(oItem))
        {
            // Does the item need to be equiped to use its powers?
            sSlots = Get2DAString("baseitems", "EquipableSlots", GetBaseItemType(oItem));
            //ai_Debug("0i_talents", "1726", GetName(oItem) + " requires " + Get2DAString("baseitems", "EquipableSlots", GetBaseItemType(oItem)) + " slots.");
            if(sSlots == "0x00000") ai_CheckItemProperties(oCreature, oItem, bBuff);
        }
        oItem = GetNextItemInInventory(oCreature);
    }
    int nSlot;
    // Cycle through all the creatures equiped items.
    oItem = GetItemInSlot(nSlot, oCreature);
    while(nSlot < 11)
    {
        if(oItem != OBJECT_INVALID) ai_CheckItemProperties(oCreature, oItem, bBuff, TRUE);
        oItem = GetItemInSlot(++nSlot, oCreature);
    }
}
void ai_SetCreatureTalents(object oCreature, int bBuff)
{
    //ai_Counter_Start();
    ai_SetCreatureSpellTalents(oCreature, bBuff);
    //ai_Counter_End(GetName(oCreature) + ": Spell Talents");
    ai_SetCreatureSpecialAbilityTalents(oCreature, bBuff);
    //ai_Counter_End(GetName(oCreature) + ": Special Ability Talents");
    if(!ai_GetAssociateMode(oCreature, AI_MODE_NO_MAGIC_ITEMS)) ai_SetCreatureItemTalents(oCreature, bBuff);
    //ai_Counter_End(GetName(oCreature) + ": Item Talents");
    if(AI_SUMMON_COMPANIONS && !GetLocalInt(oCreature, "AI_NO_COMPANION"))
    {
        SummonAnimalCompanion(oCreature);
        DelayCommand(0.0, ai_NameAssociate(oCreature, ASSOCIATE_TYPE_ANIMALCOMPANION, "Animal Companion"));
    }
    if(AI_SUMMON_FAMILIARS && !GetLocalInt(oCreature, "AI_NO_FAMILIAR"))
    {
        SummonFamiliar(oCreature);
        DelayCommand(0.0, ai_NameAssociate(oCreature, ASSOCIATE_TYPE_FAMILIAR, "Familiar"));
    }
    // AI_CAT_CURE is setup differently we save the level as the highest.
    if(JsonGetType(GetLocalJson(oCreature, AI_TALENT_CURE)) != JSON_TYPE_NULL) SetLocalInt(oCreature, AI_NO_TALENTS + AI_TALENT_CURE, 9);
    // With spontaneous cure spells we need to clear this as the number of spells don't count.
    if(GetLevelByClass(CLASS_TYPE_CLERIC, oCreature)) SetLocalInt(oCreature, AI_NO_TALENTS + AI_TALENT_HEALING, 0);
}
int ai_UseCreatureSpellTalent(object oCreature, json jLevel, json jTalent, string sCategory, int nInMelee, object oTarget = OBJECT_INVALID)
{
    // Get the spells information so we can check if they still have it.
    int nClass = JsonGetInt(JsonArrayGet(jTalent, 2));
    // Check to see if we should try to cast an arcane spell.
    //ai_Debug("0i_talents", "1769", "Arcane Spells: " + Get2DAString("classes", "ASF", nClass) +
    //         " Arcane Spell Failure: " + IntToString(GetArcaneSpellFailure(oCreature)));
    if(Get2DAString("classes", "ASF", nClass) == "1" && GetArcaneSpellFailure(oCreature) > AI_ASF_WILL_USE) return FALSE;
    int nLevel = JsonGetInt(JsonArrayGet(jTalent, 3));
    int nSlot = JsonGetInt(JsonArrayGet(jTalent, 4));
    if(Get2DAString("classes", "MemorizesSpells", nClass) == "1")
    {
        // Shouldn't need this anymore, we need to do a debug looking at this.
        if(GetMemorizedSpellReady(oCreature, nClass, nLevel, nSlot) < 1) return FALSE;
        if(ai_CheckSpecialTalentsandUse(oCreature, jTalent, sCategory, nInMelee, oTarget)) return -1;
        return FALSE;
    }
    // We should get a random known spell of this level in this category
    // for casters who pick spells when casting.
    //ai_Debug("0i_talents", "1783", "Known caster Level: " + IntToString(nLevel) +
    //         " Uses : " + IntToString(GetSpellUsesLeft(oCreature, nClass, JsonGetInt(JsonArrayGet(jTalent, 1)))));
    if(!GetSpellUsesLeft(oCreature, nClass, JsonGetInt(JsonArrayGet(jTalent, 1)))) return FALSE;
    return ai_CheckSpecialTalentsandUse(oCreature, jTalent, sCategory, nInMelee, oTarget);
}
int ai_UseCreatureItemTalent(object oCreature, json jLevel, json jTalent, string sCategory, int nInMelee, object oTarget = OBJECT_INVALID)
{
    object oItem = StringToObject(JsonGetString(JsonArrayGet(jTalent, 2)));
    int nSlots, nItemType = GetBaseItemType(oItem);
    // Check if the item is a potion since there are some special cases.
    if(nItemType == BASE_ITEM_POTIONS || nItemType == BASE_ITEM_ENCHANTED_POTION)
    {
        // Potions cause attack of opportunities and this would be deadly!
        if(nInMelee > 2) return FALSE;
        // Potions cannot be used on other creatures!
        if(oCreature != oTarget)
        {
            if(sCategory == AI_TALENT_HEALING)
            {
                if(ai_GetPercHPLoss(oCreature) > ai_GetHealersHpLimit(oCreature)) return FALSE;
                oTarget = oCreature;
            }
            else if(sCategory == AI_TALENT_PROTECTION ||
                    sCategory == AI_TALENT_ENHANCEMENT ||
                    sCategory == AI_TALENT_CURE) oTarget = oCreature;
        }
    }
    if(ai_CheckSpecialTalentsandUse(oCreature, jTalent, sCategory, nInMelee, oTarget)) return TRUE;
    return FALSE;
}
int ai_UseCreatureTalent(object oCreature, string sCategory, int nInMelee, int nLevel = 10, object oTarget = OBJECT_INVALID)
{
    //ai_Debug("0i_talents", "1815", "AI_NO_TALENTS_" + sCategory + ": " +
    //         IntToString(GetLocalInt(oCreature, AI_NO_TALENTS + sCategory)) +
    //         " nLevel: " + IntToString(nLevel));
    // If we have saved this level or higher to AI_NO_TALENTS then skip.
    int nMinNoTalentLevel = GetLocalInt(oCreature, AI_NO_TALENTS + sCategory);
    if(nMinNoTalentLevel >= nLevel) return FALSE;
    // Get the saved category from oCreature.
    json jCategory = GetLocalJson(oCreature, sCategory);
    //ai_Debug("0i_talents", "1823", "jCategory: " + sCategory + " " + JsonDump(jCategory, 2));
    if(JsonGetType(jCategory) == JSON_TYPE_NULL)
    {
        SetLocalInt(oCreature, AI_NO_TALENTS + sCategory, 9);
        return FALSE;
    }
    if(nLevel < 0 || nLevel > 10) nLevel = 9;
    json jLevel, jTalent;
    int nClass, nSlot, nType, nSlotIndex, nMaxSlotIndex, nTalentUsed, nSpell, nMaxNoTalentLevel;
    // Loop through nLevels down to nMinNoTalentLevel looking for the first talent
    // (i.e. the highest or best?).
    while(nLevel >= nMinNoTalentLevel)
    {
        // Get the array of nLevel cycling down to 0.
        jLevel = JsonArrayGet(jCategory, nLevel);
        nMaxSlotIndex = JsonGetLength(jLevel);
        //ai_Debug("0i_talents", "1839", "nLevel: " + IntToString(nLevel) +
        //         " nMaxSlotIndex: " + IntToString(nMaxSlotIndex));
        if(nMaxSlotIndex > 0)
        {
            // Set MaxNoTalentLevel to 0 if the level has a talent.
            nMaxNoTalentLevel = 0;
            // Get the talent within nLevel cycling from the first to the last.
            nSlotIndex = 0;
            while (nSlotIndex < nMaxSlotIndex)
            {
                jTalent= JsonArrayGet(jLevel, nSlotIndex);
                //ai_Debug("0i_talents", "1850", "nSlotIndex: " + IntToString(nSlotIndex) +
                //         " jTalent Type: " + IntToString(JsonGetInt(JsonArrayGet(jTalent, 0))));
                nType = JsonGetInt(JsonArrayGet(jTalent, 0));
                if(nType == AI_TALENT_TYPE_SPELL)
                {
                    nTalentUsed = ai_UseCreatureSpellTalent(oCreature, jLevel, jTalent, sCategory, nInMelee, oTarget);
                    // -1 means it was a memorized spell and we need to remove it.
                    if(nTalentUsed == -1)
                    {
                        ai_RemoveTalent(oCreature, jCategory, jLevel, sCategory, nLevel, nSlotIndex);
                        return TRUE;
                    }
                    else if(nTalentUsed) return TRUE;
                }
                else if(nType == AI_TALENT_TYPE_SP_ABILITY)
                {
                    // Special ability spells do not need to concentrate?!
                    if(ai_CheckSpecialTalentsandUse(oCreature, jTalent, sCategory, nInMelee, oTarget))
                    {
                        // When the ability is used that slot is now not readied.
                        // Multiple uses of the same spell are stored in different slots.
                        ai_RemoveTalent(oCreature, jCategory, jLevel, sCategory, nLevel, nSlotIndex);
                        return TRUE;
                    }
                }
                else if (nType == AI_TALENT_TYPE_ITEM)
                {
                    // Items do not need to concentrate.
                    if(ai_UseCreatureItemTalent(oCreature, jLevel, jTalent, sCategory, nInMelee, oTarget))
                    {
                        //ai_Debug("0i_talents", "1880", "Checking if Item is used up: " +
                        //         IntToString(JsonGetInt(JsonArrayGet(jTalent, 4))));
                        if(JsonGetInt(JsonArrayGet(jTalent, 4)) == -1)
                        {
                            ai_RemoveTalent(oCreature, jCategory, jLevel, sCategory, nLevel, nSlotIndex);
                        }
                        return TRUE;
                    }
                }
                //else if(nType == AI_TALENT_TYPE_FEAT) {}
                nSlotIndex++;
            }
        }
        // Set nMaxNoTalentLevel to the level if it is not set. This will hold
        // the highest level we don't have a talent for in our checks.
        else if(!nMaxNoTalentLevel) nMaxNoTalentLevel = nLevel;
        nLevel--;
    }
    // If we have nMaxNoTalentLevel then we didn't find a talent on these levels.
    if(nMaxNoTalentLevel) SetLocalInt(oCreature, AI_NO_TALENTS + sCategory, nMaxNoTalentLevel);
    return FALSE;
}
int ai_UseTalentOnObject(object oCreature, json jTalent, object oTarget, int nInMelee)
{
    int nSpell, nClass, nLevel, nSlot, nMetaMagic, nDomain;
    int nType = JsonGetInt(JsonArrayGet(jTalent, 0));
    if(nType == AI_TALENT_TYPE_SPELL)
    {
        if(!ai_CastInMelee(oCreature, nSpell, nInMelee)) return FALSE;
        nClass = JsonGetInt(JsonArrayGet(jTalent, 2));
        if(Get2DAString("classes", "MemorizesSpells", nClass) == "1")
        {
            nSpell = JsonGetInt(JsonArrayGet(jTalent, 1));
            nLevel = JsonGetInt(JsonArrayGet(jTalent, 3));
            nSlot = JsonGetInt(JsonArrayGet(jTalent, 4));
            if(GetMemorizedSpellIsDomainSpell(oCreature, nClass, nLevel, nSlot) == 1) nDomain = nLevel;
            else nDomain = 0;
            int nMetaMagic = GetMemorizedSpellMetaMagic(oCreature, nClass, nLevel, nSlot);
        }
        else
        {
            nSpell = JsonGetInt(JsonArrayGet(jTalent, 1));
            nMetaMagic = METAMAGIC_NONE;
            nDomain = 0;
        }
    }
    else if(nType == AI_TALENT_TYPE_SP_ABILITY)
    {
        //ai_Debug("0i_talents", "1928", GetName(oCreature) + " is using a special ability!");
        nSpell = JsonGetInt(JsonArrayGet(jTalent, 1));
        nClass = 255;
    }
    else if(nType == AI_TALENT_TYPE_ITEM)
    {
        object oItem = StringToObject(JsonGetString(JsonArrayGet(jTalent, 2)));
        int nIndex, nSubIndex = 0;
        nSlot = JsonGetInt(JsonArrayGet(jTalent, 4));
        itemproperty ipProp = GetFirstItemProperty(oItem);
        while(GetIsItemPropertyValid(ipProp))
        {
            if(nIndex++ == nSlot) break;
            ipProp = GetNextItemProperty(oItem);
        }
        // Cast items have the following:
        // 1)Single_Use.
        // 2-6) Charges/Use [Note: 7 is 0 charges per use].
        // 8-12) Uses/Day [Note: 13 is unlimited uses per day].
        // We set the slot to -1 to let the other function know we need this talent removed.
        int nUses = GetItemPropertyCostTableValue(ipProp);
        if(nUses == 1) JsonArrayInsertInplace(jTalent, JsonInt(-1), 4);
        else if(nUses > 1 && nUses < 7)
        {
            //ai_Debug("0i_talents", "1952", "Item charges: " + IntToString(GetItemCharges(oItem)));
            int nCharges = GetItemCharges(oItem);
            if(nUses == 6 && nCharges == 1 || nUses == 5 && nCharges < 4 ||
               nUses == 4 && nCharges < 6 || nUses == 3 && nCharges < 8 ||
               nUses == 2 && nCharges < 10) JsonArrayInsertInplace(jTalent, JsonInt(-1), 4);
        }
        else if(nUses > 7 && nUses < 13)
        {
            //ai_Debug("0i_talents", "1960", "Item uses: " + IntToString(GetItemPropertyUsesPerDayRemaining(oItem, ipProp)));
            int nPerDay = GetItemPropertyUsesPerDayRemaining(oItem, ipProp);
            if(nUses == 8 && nPerDay == 1 || nUses == 9 && nPerDay < 4 ||
               nUses == 10 && nPerDay < 6 || nUses == 11 && nPerDay < 8 ||
               nUses == 12 && nPerDay < 10) JsonArrayInsertInplace(jTalent, JsonInt(-1), 4);
        }
        ai_SetLastAction(oCreature, nSpell);
        ActionUseItemOnObject(oItem, ipProp, oTarget, nSubIndex);
        //ai_Debug("0i_talents", "1968", GetName(oCreature) + " is using " + GetName(oItem) + " on " + GetName(oTarget));
        return TRUE;
    }
    //ai_Debug("0i_talents", "1971", "nMetaMagic: " + IntToString(nMetaMagic) +
    //         " nDomain: " + IntToString(nDomain) + " nClass: " + IntToString(nClass));
    ai_SetLastAction(oCreature, nSpell);
    ActionCastSpellAtObject(nSpell, oTarget, nMetaMagic, FALSE, nDomain, 0, FALSE, nClass, FALSE);
    //string sSpellName = GetStringByStrRef(StringToInt(Get2DAString("spells", "Name", nSpell)));
    //ai_Debug("0i_talents", "1976", GetName(oCreature) + " is casting " + sSpellName + " on " + GetName(oTarget));
    return TRUE;
}
int ai_UseTalentAtLocation(object oCreature, json jTalent, location lTarget, int nInMelee)
{
    int nSpell, nClass, nLevel, nSlot, nMetaMagic, nDomain;
    int nType = JsonGetInt(JsonArrayGet(jTalent, 0));
    if(nType == AI_TALENT_TYPE_SPELL)
    {
        if(!ai_CastInMelee(oCreature, nSpell, nInMelee)) return FALSE;
        nClass = JsonGetInt(JsonArrayGet(jTalent, 2));
        if(Get2DAString("classes", "MemorizesSpells", nClass) == "1")
        {
            nSpell = JsonGetInt(JsonArrayGet(jTalent, 1));
            nLevel = JsonGetInt(JsonArrayGet(jTalent, 3));
            nSlot = JsonGetInt(JsonArrayGet(jTalent, 4));
            if(GetMemorizedSpellIsDomainSpell(oCreature, nClass, nLevel, nSlot) == 1) nDomain = nLevel;
            else nDomain = 0;
            int nMetaMagic = GetMemorizedSpellMetaMagic(oCreature, nClass, nLevel, nSlot);
        }
        else
        {
            nSpell = JsonGetInt(JsonArrayGet(jTalent, 1));
            nMetaMagic = METAMAGIC_NONE;
            nDomain = 0;
        }
    }
    else if(nType == AI_TALENT_TYPE_SP_ABILITY)
    {
        //ai_Debug("0i_talents", "2005", GetName(oCreature) + " is using a special ability!");
        nSpell = JsonGetInt(JsonArrayGet(jTalent, 1));
        nClass = 255;
    }
    else if(nType == AI_TALENT_TYPE_ITEM)
    {
        object oItem = StringToObject(JsonGetString(JsonArrayGet(jTalent, 2)));
        int nIndex, nSubIndex = 0;
        nSlot = JsonGetInt(JsonArrayGet(jTalent, 4));
        itemproperty ipProp = GetFirstItemProperty(oItem);
        while(GetIsItemPropertyValid(ipProp))
        {
            if(nIndex++ == nSlot) break;
            ipProp = GetNextItemProperty(oItem);
        }
        // Cast items have the following:
        // 1)Single_Use.
        // 2-6) Charges/Use [Note: 7 is 0 charges per use].
        // 8-12) Uses/Day [Note: 13 is unlimited uses per day].
        // We set the slot to -1 to let the other function know we need this talent removed.
        int nUses = GetItemPropertyCostTableValue(ipProp);
        if(nUses == 1) JsonArrayInsertInplace(jTalent, JsonInt(-1), 4);
        else if(nUses > 1 && nUses < 7)
        {
            //ai_Debug("0i_talents", "2029", "Item charges: " + IntToString(GetItemCharges(oItem)));
            int nCharges = GetItemCharges(oItem);
            if(nUses == 6 && nCharges == 1 || nUses == 5 && nCharges < 4 ||
               nUses == 4 && nCharges < 6 || nUses == 3 && nCharges < 8 ||
               nUses == 2 && nCharges < 10) JsonArrayInsertInplace(jTalent, JsonInt(-1), 4);
        }
        else if(nUses > 7 && nUses < 13)
        {
            //ai_Debug("0i_talents", "2037", "Item uses: " + IntToString(GetItemPropertyUsesPerDayRemaining(oItem, ipProp)));
            int nPerDay = GetItemPropertyUsesPerDayRemaining(oItem, ipProp);
            if(nUses == 8 && nPerDay == 1 || nUses == 9 && nPerDay < 4 ||
               nUses == 10 && nPerDay < 6 || nUses == 11 && nPerDay < 8 ||
               nUses == 12 && nPerDay < 10) JsonArrayInsertInplace(jTalent, JsonInt(-1), 4);
        }
        ai_SetLastAction(oCreature, nSpell);
        ActionUseItemAtLocation(oItem, ipProp, lTarget, nSubIndex);
        //ai_Debug("0i_talents", "2045", GetName(oCreature) + " is using " + GetName(oItem) + " at a location.");
        return TRUE;
    }
    ai_SetLastAction(oCreature, nSpell);
    ActionCastSpellAtLocation(nSpell, lTarget, nMetaMagic, FALSE, 0, FALSE, nClass, FALSE, nDomain);
    //string sSpellName = GetStringByStrRef(StringToInt(Get2DAString("spells", "Name", nSpell)));
    //ai_Debug("0i_talents", "2051", GetName(oCreature) + " is casting " + sSpellName + " at a location!");
    return TRUE;
}
int ai_CheckSpecialTalentsandUse(object oCreature, json jTalent, string sCategory, int nInMelee, object oTarget)
{
    int nSpell = JsonGetInt(JsonArrayGet(jTalent, 1));
    //ai_Debug("0i_talents", "2057", "nSpell: " + GetStringByStrRef(StringToInt(Get2DAString("spells", "Name", nSpell))) +
    //         " sCategory: " + sCategory);
    if(sCategory == AI_TALENT_DISCRIMINANT_AOE)
    {
        //ai_Debug("0i_talents", "2061", "CompareLastAction: " +
        //          IntToString(ai_CompareLastAction(oCreature, nSpell)));
        // If we used this spell talent last round then don't use it this round.
        if(ai_CompareLastAction(oCreature, nSpell)) return FALSE;
        // Check to see if Disjunction should *not* be cast.
        if(nSpell == SPELL_MORDENKAINENS_DISJUNCTION)
        {
            // Our master does not want us using any type of dispel!
            if(ai_GetAssociateMode(oCreature, AI_MODE_STOP_DISPEL)) return FALSE;
            if(!ai_CreatureHasDispelableEffect(oCreature, oTarget)) return FALSE;
        }
        // These spells have a Range of Personal i.e. cast on themselves, and
        // an Area of Effect of Colossal (10.0).
        else if(nSpell == SPELL_FIRE_STORM || nSpell == SPELL_STORM_OF_VENGEANCE)
        {
            // Make sure we have enough enemies to use this on.
            int nEnemies = ai_GetNumOfEnemiesInRange(oCreature, 10.0);
            if(nEnemies < 2) return FALSE;
            // Get the nearest target to check defenses on.
            oTarget = ai_GetNearestTarget(oCreature, 10.0);
            if(!ai_CastOffensiveSpellVsTarget(oCreature, oTarget, nSpell) ||
               ai_CreatureImmuneToEffect(oCreature, oTarget, nSpell)) return FALSE;
            if(ai_UseTalentAtLocation(oCreature, jTalent, GetLocation(oCreature), nInMelee)) return TRUE;
        }
        // Get a target for discriminant spells if one is not already set.
        if(oTarget == OBJECT_INVALID)
        {
            float fRange;
            if(nInMelee) fRange = AI_RANGE_MELEE;
            else fRange = ai_GetOffensiveSpellSearchRange(oCreature, nSpell);
            oTarget = ai_CheckForGroupedTargetNotInAOE(oCreature, fRange);
        }
        if(oTarget == OBJECT_INVALID || GetHasSpellEffect(nSpell, oTarget) ||
           !ai_CastOffensiveSpellVsTarget(oCreature, oTarget, nSpell) ||
           ai_CreatureImmuneToEffect(oCreature, oTarget, nSpell)) return FALSE;
    }
    else if(sCategory == AI_TALENT_INDISCRIMINANT_AOE)
    {
        //ai_Debug("0i_talents", "2099", "CompareLastAction: " +
        //          IntToString(ai_CompareLastAction(oCreature, nSpell)));
        // If we used this spell talent last round then don't use it this round.
        if(ai_CompareLastAction(oCreature, nSpell)) return FALSE;
        // These spells have a Range of Personal i.e. cast on themselves, and
        // an Area of Effect of Colossal (10.0).
        if(nSpell == SPELL_METEOR_SWARM)
        {
            // Make sure we have enough enemies and few allies to hit.
            int nAllies = ai_GetNumOfAlliesInGroup(oCreature, 10.0);
            int nEnemies = ai_GetNumOfEnemiesInRange(oCreature, 10.0);
            if(nAllies > 1 || nEnemies < 2) return FALSE;
            // Get the nearest target to check defenses on.
            oTarget = ai_GetNearestTarget(oCreature, 10.0);
            if(!ai_CastOffensiveSpellVsTarget(oCreature, oTarget, nSpell) ||
               ai_CreatureImmuneToEffect(oCreature, oTarget, nSpell)) return FALSE;
            if(ai_UseTalentAtLocation(oCreature, jTalent, GetLocation(oCreature), nInMelee)) return TRUE;
        }
        // Get a target for indiscriminant spells if one is not already set.
        if(oTarget == OBJECT_INVALID)
        {
            float fRange = ai_GetOffensiveSpellSearchRange(oCreature, nSpell);
            oTarget = ai_CheckForGroupedTargetNotInAOE(oCreature, fRange);
            // Check for the number of allies, if there are too many then skip.
            if(oTarget == OBJECT_INVALID) return FALSE;
            int nAllies = ai_GetNumOfAlliesInGroup(oTarget, AI_RANGE_CLOSE);
            int nRoll = d3();
            //ai_Debug("0i_talents", "2126", "Num of Allies in range: " + IntToString(nAllies)+
            //         " < d3: " + IntToString(nRoll));
            if(nAllies >= nRoll) return FALSE;
        }
        if(oTarget == OBJECT_INVALID || GetHasSpellEffect(nSpell, oTarget) ||
           !ai_CastOffensiveSpellVsTarget(oCreature, oTarget, nSpell) ||
           ai_CreatureImmuneToEffect(oCreature, oTarget, nSpell)) return FALSE;
        //**********************************************************************
        //********** These spells are checked after picking a target ***********
        //**********************************************************************
        // Check if the Sleep spells are being used appropriately.
        if(nSpell == SPELL_SLEEP)
        {
            if(GetHitDice(oTarget) > 4) return FALSE;
        }
        // Lets only use silence on casters.
        else if(nSpell == SPELL_SILENCE)
        {
            if(!ai_CheckClassType(oTarget, AI_CLASS_TYPE_CASTER))
            {
                oTarget = ai_GetNearestClassTarget(oCreature, AI_CLASS_TYPE_CASTER);
                if(oTarget == OBJECT_INVALID) return FALSE;
            }
        }
    }
    else if(sCategory == AI_TALENT_RANGED)
    {
        //ai_Debug("0i_talents", "2153", "CompareLastAction: " +
        //          IntToString(ai_CompareLastAction(oCreature, nSpell)));
        // If we used this spell talent last round then don't use it this round.
        if(ai_CompareLastAction(oCreature, nSpell)) return FALSE;
        // Check to see if Dispel Magic and similar spells should *not* be cast
        if(nSpell == SPELL_DISPEL_MAGIC || nSpell == SPELL_LESSER_DISPEL ||
                nSpell == SPELL_GREATER_DISPELLING)
        {
            // Our master does not want us using any type of dispel!
            if(ai_GetAssociateMode(oCreature, AI_MODE_STOP_DISPEL)) return FALSE;
            float fRange;
            if(nInMelee) fRange = AI_RANGE_MELEE;
            else fRange = ai_GetOffensiveSpellSearchRange(oCreature, nSpell);
            // Getting lowest fortitude save since most caster would have the lowest.
            oTarget == ai_GetLowestFortitudeSaveTarget(oCreature, fRange);
            if(!ai_CreatureHasDispelableEffect(oCreature, oTarget)) return FALSE;
            // Maybe we should do an area of effect instead?
            int nEnemies = ai_GetNumOfEnemiesInRange(oTarget, 5.0);
            if(nEnemies > 2)
            {
                if(ai_UseTalentAtLocation(oCreature, jTalent, GetLocation(oTarget), nInMelee)) return TRUE;
            }
        }
        // Make sure the spell will work on the target.
        else if(nSpell == SPELL_HOLD_PERSON || nSpell == SPELL_DOMINATE_PERSON ||
                nSpell == SPELL_CHARM_PERSON)
        {
            if(oTarget != OBJECT_INVALID)
            {
                int nRaceType = GetRacialType(oTarget);
                //ai_Debug("0i_talents", "2183", " Person Spell race: " + IntToString(nRaceType));
                if((nRaceType > 6 && nRaceType < 12) || nRaceType > 15) oTarget = OBJECT_INVALID;
            }
            if(oTarget == OBJECT_INVALID)
            {
                float fRange;
                if(nInMelee) fRange = AI_RANGE_MELEE;
                else fRange = ai_GetOffensiveSpellSearchRange(oCreature, nSpell);
                oTarget = ai_GetNearestRacialTarget(oCreature, AI_RACIAL_TYPE_HUMANOID, fRange);
                if(oTarget == OBJECT_INVALID) return FALSE;
            }
        }
        else if(nSpell == SPELL_HOLD_ANIMAL || nSpell == SPELL_DOMINATE_ANIMAL)
        {
            if(oTarget != OBJECT_INVALID)
            {
                if(GetRacialType(oTarget) != RACIAL_TYPE_ANIMAL) oTarget = OBJECT_INVALID;
            }
            if(oTarget == OBJECT_INVALID)
            {
                float fRange;
                if(nInMelee) fRange = AI_RANGE_MELEE;
                else fRange = ai_GetOffensiveSpellSearchRange(oCreature, nSpell);
                oTarget = ai_GetNearestRacialTarget(oCreature, AI_RACIAL_TYPE_ANIMAL_BEAST, fRange);
                if(oTarget == OBJECT_INVALID) return FALSE;
            }
        }
        // Get a target for ranged spells if one is not already set.
        if(oTarget == OBJECT_INVALID)
        {
            float fRange;
            if(nInMelee) fRange = AI_RANGE_MELEE;
            else fRange = ai_GetOffensiveSpellSearchRange(oCreature, nSpell);
            oTarget = ai_GetSpellTargetBasedOnSaves(oCreature, nSpell, fRange);
        }
        if(oTarget == OBJECT_INVALID || GetHasSpellEffect(nSpell, oTarget) ||
           !ai_CastOffensiveSpellVsTarget(oCreature, oTarget, nSpell) ||
           ai_CreatureImmuneToEffect(oCreature, oTarget, nSpell)) return FALSE;
        //**********************************************************************
        //********** These spells are checked after picking a target ***********
        //**********************************************************************
        // Don't use Domination spells on players! They don't work.
        if((nSpell == SPELL_DOMINATE_MONSTER || nSpell == SPELL_DOMINATE_PERSON))
        {
           if(ai_GetIsCharacter(oTarget)) return FALSE;
        }
        // Check to see if they have the shield spell up.
        else if(nSpell == SPELL_MAGIC_MISSILE)
        {
            if(GetHasSpellEffect(SPELL_SHIELD, oTarget)) return FALSE;
        }
        // Don't use drown against nonliving opponents.
        else if(nSpell == SPELL_DROWN)
        {
            if(ai_IsNonliving(GetRacialType(oTarget))) return FALSE;
        }
        // Don't use Power Word Kill on Targets with more than 100hp
        else if(nSpell == SPELL_POWER_WORD_KILL)
        {
            if(GetCurrentHitPoints(oTarget) <= 100) return FALSE;
        }
    }
    else if(sCategory == AI_TALENT_TOUCH)
    {
        //ai_Debug("0i_talents", "2247", "CompareLastAction: " +
        //          IntToString(ai_CompareLastAction(oCreature, nSpell)));
        // If we used this spell talent last round then don't use it this round.
        if(ai_CompareLastAction(oCreature, nSpell)) return FALSE;
        // Get a target for touch spells if one is not already set.
        if(oTarget == OBJECT_INVALID)
        {
            oTarget = ai_GetSpellTargetBasedOnSaves(oCreature, nSpell, AI_RANGE_MELEE);
        }
        if(oTarget == OBJECT_INVALID || GetHasSpellEffect(nSpell, oTarget) ||
           !ai_CastOffensiveSpellVsTarget(oCreature, oTarget, nSpell) ||
           ai_CreatureImmuneToEffect(oCreature, oTarget, nSpell)) return FALSE;
    }
    else if(sCategory == AI_TALENT_HEALING)
    {
        // Make sure we should use a mass heal on us or an ally!
        // Two allies need healing or one is almost dead to use mass heal!
        if(nSpell == SPELL_MASS_HEAL)
        {
            int bWoundedAlly;
            object oAlly = ai_GetNearestAlly(oTarget);
            if(oAlly != OBJECT_INVALID)
            {
                // If we don't have a nearby ally that needs healed then skip.
                if(ai_GetPercHPLoss(oAlly) > AI_HEALTH_WOUNDED ||
                    GetDistanceBetween(oCreature, oAlly) > 9.0f) bWoundedAlly = TRUE;
            }
            // If oTarget is not about to die then skip.
            int nHealth = ai_GetPercHPLoss(oTarget);
            if(nHealth > AI_HEALTH_BLOODY && !bWoundedAlly) return FALSE;
        }
    }
    else if(sCategory == AI_TALENT_ENHANCEMENT)
    {
        // If anyone goes into a polymorphed form we use a polymorph ai script.
        if(nSpell == FEAT_WILD_SHAPE || nSpell == 304/*FEAT_ELEMENTAL_SHAPE*/ ||
            nSpell == FEAT_EPIC_WILD_SHAPE_DRAGON || nSpell == FEAT_EPIC_WILD_SHAPE_UNDEAD ||
            nSpell == FEAT_GREATER_WILDSHAPE_1 || nSpell == FEAT_GREATER_WILDSHAPE_2 ||
            nSpell == FEAT_GREATER_WILDSHAPE_3 || nSpell == FEAT_GREATER_WILDSHAPE_4 ||
            nSpell == 1060/*FEAT_EPIC_OUTSIDER_SHAPE*/ || nSpell == 1061/*FEAT_EPIC_CONSTRUCT_SHAPE*/ ||
            nSpell == 902/*FEAT_HUMANOID_SHAPE*/)
        {
            // Save the original form so we can check when we turn back(Add 1 so we don't save a 0!).
            SetLocalInt(oCreature, AI_NORMAL_FORM, GetAppearanceType(oCreature) + 1);
            SetLocalString(oCreature, AI_COMBAT_SCRIPT, "ai_polymorphed");
        }
        // Get a target for enhancement spells if one is not already set.
        if(oTarget == OBJECT_INVALID)
        {
            // Get talents range and target.
            float fRange = ai_GetSpellRange(nSpell);
            // Personal spell
            if(fRange == 0.1f) oTarget = oCreature;
            // Range/Touch spell
            else
            {
                // Make sure we don't over extend our movement running across the
                // battlefield to cast a spell on someone does not look good.
                float fNearestEnemy = GetDistanceBetween(oCreature, GetLocalObject(oCreature, AI_ENEMY_NEAREST));
                // If we are in melee then extend to melee incase an ally is just past the enemy.
                if(fNearestEnemy <= AI_RANGE_MELEE) fNearestEnemy = AI_RANGE_MELEE;
                if(fRange > fNearestEnemy) fRange = fNearestEnemy;
                // Select the higest ally combat target for enhancements.
                oTarget = ai_GetHighestCRTarget(oCreature, fRange, AI_ALLY);
            }
        }
        if(oTarget == OBJECT_INVALID || GetHasSpellEffect(nSpell, oTarget)) return FALSE;
        //**********************************************************************
        //********** These spells are checked after picking a target ***********
        //**********************************************************************
        // Weapon enhancing spells only work on melee weapons!
        if(nSpell == SPELL_MAGIC_WEAPON || nSpell == SPELL_GREATER_MAGIC_WEAPON ||
            nSpell == SPELL_BLESS_WEAPON || nSpell == SPELL_FLAME_WEAPON ||
            nSpell == SPELL_DARKFIRE)
        {
            object oWeapon = GetItemInSlot(INVENTORY_SLOT_RIGHTHAND, oTarget);
            if(!ai_GetIsMeleeWeapon(oWeapon)) return FALSE;
        }
    }
    else if(sCategory == AI_TALENT_PROTECTION)
    {
        // Stone bones only effects the undead.
        if(nSpell == SPELL_STONE_BONES)
        {
            if(oTarget != OBJECT_INVALID)
            {
                if(GetRacialType(oTarget) != RACIAL_TYPE_UNDEAD) oTarget = OBJECT_INVALID;
            }
            if(oTarget == OBJECT_INVALID)
            {
                float fRange;
                if(nInMelee) fRange = AI_RANGE_MELEE;
                else fRange = ai_GetOffensiveSpellSearchRange(oCreature, nSpell);
                oTarget = ai_GetNearestRacialTarget(oCreature, RACIAL_TYPE_UNDEAD, fRange);
                if(oTarget == OBJECT_INVALID) return FALSE;
            }
        }
        // Get a target for protection spells if one is not already set.
        if(oTarget == OBJECT_INVALID)
        {
            // Get talents range and target.
            float fRange = ai_GetSpellRange(nSpell);
            // Personal spell
            if(fRange == 0.1f) oTarget = oCreature;
            // Range/Touch spell
            else
            {
                // Make sure we don't over extend our movement running across the
                // battlefield to cast a spell on someone does not look good.
                float fNearestEnemy = GetDistanceBetween(oCreature, GetLocalObject(oCreature, AI_ENEMY_NEAREST));
                // If we are in melee then extend to melee incase an ally is just past the enemy.
                if(fNearestEnemy <= AI_RANGE_MELEE) fNearestEnemy = AI_RANGE_MELEE;
                if(fRange > fNearestEnemy) fRange = fNearestEnemy;
                // Select the lowest ally combat target for protections.
                oTarget = ai_GetLowestCRTarget(oCreature, fRange, AI_ALLY);
            }
        }
        if(oTarget == OBJECT_INVALID || GetHasSpellEffect(nSpell, oTarget)) return FALSE;
        //**********************************************************************
        //********** These spells are checked after picking a target ***********
        //**********************************************************************
        // Don't double up Stoneskin, Ghostly visage, or Ethereal visage.
        if(nSpell == SPELL_GHOSTLY_VISAGE || nSpell == SPELL_ETHEREAL_VISAGE ||
           nSpell == SPELL_STONESKIN)
        {
            if(GetHasSpellEffect(SPELL_ETHEREAL_VISAGE, oTarget) ||
                GetHasSpellEffect(SPELL_STONESKIN, oTarget) ||
                GetHasSpellEffect(SPELL_GHOSTLY_VISAGE, oTarget)) return FALSE;
        }
        // Don't use displacement if we are invisible!
        else if(nSpell == SPELL_DISPLACEMENT)
        {
            if(GetHasSpellEffect(SPELL_INVISIBILITY, oTarget) ||
                GetHasSpellEffect(SPELL_IMPROVED_INVISIBILITY, oTarget) ||
                GetHasSpellEffect(SPELL_INVISIBILITY_SPHERE, oTarget) ||
                GetHasSpellEffect(SPELL_DISPLACEMENT, oTarget)) return FALSE;
        }
    }
    else if(sCategory == AI_TALENT_SUMMON)
    {
        if(GetAssociate(ASSOCIATE_TYPE_SUMMONED, oCreature) != OBJECT_INVALID) return FALSE;
        if(oTarget == OBJECT_INVALID)
        {
            float fRange;
            if(nInMelee) fRange = AI_RANGE_MELEE;
            else fRange = ai_GetOffensiveSpellSearchRange(oCreature, nSpell);
            // Select lowest enemy combat target for summons.
            oTarget = ai_GetLowestCRTarget(oCreature, fRange);
            if(oTarget == OBJECT_INVALID) oTarget = oCreature;
            if(ai_UseTalentAtLocation(oCreature, jTalent, GetLocation(oTarget), nInMelee))
            {
                DelayCommand(4.0, ai_NameAssociate(oCreature, ASSOCIATE_TYPE_SUMMONED, ""));
                return TRUE;
            }
        }
    }
    else if(sCategory == AI_TALENT_CURE)
    {
    }
    if(ai_UseTalentOnObject(oCreature, jTalent, oTarget, nInMelee)) return TRUE;
    return FALSE;
}
