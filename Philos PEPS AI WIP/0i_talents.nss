/*//////////////////////////////////////////////////////////////////////////////
 Script: 0i_talents
 Programmer: Philos
////////////////////////////////////////////////////////////////////////////////
    Fuctions to use a category of skills, feats, spells, or items.
*///////////////////////////////////////////////////////////////////////////////
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
int ai_TryDefensiveTalents(object oCreature, int nInMelee, int nMaxLevel, int nRound = 0, object oTarget = OBJECT_INVALID);
// Returns TRUE if oCreature uses a defensive talent.
// Checks the enemy faction for most powerful class and picks a buff based on it.
//int ai_TryAdvancedBuffOnSelf(object oCreature, int nInMelee);
// Set any auras this oCreature has instantly.
// This can be done in the OnSpawn script, heart beat, or Perception.
void ai_SetAura(object oCreature);

// *****************************************************************************
// ************************ Try Physical Attack Talents ************************
// *****************************************************************************
// These functions try to find and use melee attack talents intelligently.

// Wrapper for ActionAttack, oCreature uses nAction (attack) on oTarget.
// nInMelee is only used in AI_LAST_ACTION_RANGED_ATK actions.
// bPassive TRUE oCreature will not move while attacking.
// nActionMode, pass the action mode if one is being used.
void ai_ActionAttack(object oCreature, int nAction, object oTarget, int nInMelee = 0, int bPassive = FALSE, int nActionMode = 0);
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
int ai_TryAnimalEmpathy(object oCreature, object oTarget = OBJECT_INVALID);
// *****************************************************************************
// ******************************** Try * Feats ********************************
// *****************************************************************************
// These functions try to find and use a specific set of feats intelligently.

// Wrapper to have oCreature use nFeat on oTarget.
void ai_UseFeat(object oCreature, int nFeat, object oTarget, int nSubFeat = 0);
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
// Returns TRUE if oCreature uses Divine Might.
// This only checks if they can use the feat and have turn undead uses left.
int ai_TryDivineMightFeat(object oCreature, int nInMelee);
// Returns TRUE if oCreature uses Divine Shield.
// This only checks if they can use the feat and have turn undead uses left.
int ai_TryDivineShieldFeat(object oCreature, int nInMelee);
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
// Returns TRUE if oCreature uses a polymorph self feat.
// This checks if they have the feat and will use the best one.
int ai_TryPolymorphSelfFeat(object oCreature);
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
// Returns TRUE if oCreature uses the Lay on Hands feat talent.
int ai_TryLayOnHands(object oCreature);
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
// Returns TRUE if oCreature has nTalent.
// nTalent will be a spell in the spells.2da.
int ai_GetHasTalent(object oCreature, int nTalent);
// Saves a talent in JsonArray.
// Array: 0-Type (1-spell, 2-sp ability, 4-feat, 3-item)
// Type 1)spell 0-type, 1-spell, 2-class, 3-level, 4-slot.
// Type 2)sp Ability 0-type, 1-spell, 2-class, 3-level, 4-slot.
// Type 3)feat 0-type, 1-spell, 2- class, 3- level.
// Type 4)item 0-type, 1-spell, 2-item object, 3-level, 4-slot.
// jJsonLevel is the level to place the talent in the json array
//     maybe different then the talents actual level which is passed in nLevel.
void ai_SaveTalent(object oCreature, int nClass, int nJsonLevel, int nLevel, int nSlot, int nSpell, int nType, int bBuff, object oItem = OBJECT_INVALID);
// Removes a talent nSlotIndex from jLevel in jCategory.
void ai_RemoveTalent(object oCreature, json jCategory, json jLevel, string sCategory, int nLevel, int nSlotIndex);
// Saves a creatures talents to variables upon them for combat use.
// bMonster will check to see if they should be buffed when we set the talents.
void ai_SetCreatureTalents(object oCreature, int bMonster);
// Return TRUE if oCreature spontaneously casts a cure spell from a talent in sCategory.
int ai_UseSpontaneousCureTalentFromCategory(object oCreature, string sCategory, int nInMelee, int nDamage, object oTarget = OBJECT_INVALID);
// Returns TRUE if oCreature uses jTalent on oTarget.
// also Returns -1 if oCreature uses jTalent on oTarget with a memorized spell.
// This allows the user to remove jTalent from jLevel in jCategory.
int ai_UseCreatureSpellTalent(object oCreature, json jLevel, json jTalent, string sCategory, int nInMelee, object oTarget = OBJECT_INVALID);
// Return TRUE if oCreature uses a jTalent from oItem on oTarget.
int ai_UseCreatureItemTalent(object oCreature, json jLevel, json jTalent, string sCategory, int nInMelee, object oTarget = OBJECT_INVALID);
// Returns TRUE if oCreature uses a talent from sCategory of nLevel or less.
int ai_UseCreatureTalent(object oCreature, string sCategory, int nInMelee, int nLevel = 10, object oTarget = OBJECT_INVALID);
// Return TRUE if oCreature uses nTalent on oTarget.
int ai_UseTalent(object oCreature, int nTalent, object oTarget);
// Returns TRUE if jTalent is used on oTarget by oCaster.
// Checks the talent type and casts the correct spell. For items it checks uses.
int ai_UseTalentOnObject(object oCaster, json jTalent, object oTarget, int nInMelee);
// Returns TRUE if jTalent is used at lTarget location by oCaster.
// Checks the talent type and cast the correct spell. For items it checks uses.
int ai_UseTalentAtLocation(object oCaster, json jTalent, object oTarget, int nInMelee);
// Return TRUE if oCreature uses jTalent on oTarget after checking special cases.
int ai_CheckSpecialTalentsandUse(object oCreature, json jTalent, string sCategory, int nInMelee, object oTarget);

int ai_TryHealingTalent(object oCreature, int nInMelee, object oTarget = OBJECT_INVALID)
{
    // First lets evaluate oTarget and see how strong of a spell we will need.
    if(oTarget != OBJECT_INVALID)
    {
        if(oTarget == oCreature)
        {
            if(ai_GetAIMode(oCreature, AI_MODE_SELF_HEALING_OFF)) return FALSE;
        }
        else if(ai_GetAIMode(oCreature, AI_MODE_PARTY_HEALING_OFF)) return FALSE;
    }
    // We don't have a target so lets go check for one.
    else
    {
        if(!ai_GetAIMode(oCreature, AI_MODE_PARTY_HEALING_OFF))
        {
            // Lets not run past an enemy to heal unless we have the feats, bad tactics!
            float fRange;
            if(ai_CanIMoveInCombat(oCreature)) fRange = AI_RANGE_PERCEPTION;
            else
            {
                fRange = GetDistanceBetween(oCreature, GetLocalObject(oCreature, AI_ENEMY_NEAREST)) - 3.0f;
                // Looks bad when your right next to an ally, but technically the enemy is closer.
                if(fRange < AI_RANGE_MELEE) fRange = AI_RANGE_MELEE;
            }
            oTarget = ai_GetAllyToHealTarget(oCreature, fRange);
        }
        else oTarget = oCreature;
        if(oTarget == OBJECT_INVALID) return FALSE;
    }
    int nHp = ai_GetPercHPLoss(oTarget);
    int nHpLimit = ai_GetHealersHpLimit(oCreature);
    if(AI_DEBUG) ai_Debug("0i_talents", "256", "nHp: " + IntToString(nHp) +
             "< nHpLimit: " + IntToString(nHpLimit));
    if(nHp >= nHpLimit) return FALSE;
    int nDamage = GetMaxHitPoints(oTarget) - GetCurrentHitPoints(oTarget);
    if(AI_DEBUG) ai_Debug("0i_talents", "260", GetName(oTarget) + " has lost " + IntToString(nDamage) + " hitpoints!");
    // Do they have Lay on Hands?
    if(GetHasFeat(FEAT_LAY_ON_HANDS, oCreature))
    {
        int nCanHeal = GetAbilityModifier(ABILITY_CHARISMA, oCreature) * ai_GetCharacterLevels(oCreature);
        if(nCanHeal <= nDamage)
        {
            ai_UseFeat(oCreature, FEAT_LAY_ON_HANDS, oTarget);
            return TRUE;
        }
    }
    int nMaxLevel = 7;
    // If they are about to die then throw caution to the wind and HEAL!
    if(nHp <= AI_HEALTH_BLOODY) nInMelee = 0;
    if(ai_UseCreatureTalent(oCreature, AI_TALENT_HEALING, nInMelee, nMaxLevel, oTarget)) return TRUE;
    if(AI_DEBUG) ai_Debug("0i_talents", "275", GetName(oCreature) + " has no healing spells!" +
             " Cleric lvls: " + IntToString(GetLevelByClass(CLASS_TYPE_CLERIC, oCreature)) +
             " Sontaneous casting: " + IntToString(ai_GetMagicMode(oCreature, AI_MAGIC_NO_SPONTANEOUS_CURE)));
    if(GetLevelByClass(CLASS_TYPE_CLERIC, oCreature) && !ai_GetMagicMode(oCreature, AI_MAGIC_NO_SPONTANEOUS_CURE))
    {
        // We need to check our talents and see what spells we can convert.
        if(ai_UseSpontaneousCureTalentFromCategory(oCreature, AI_TALENT_ENHANCEMENT, nInMelee, nDamage, oTarget)) return TRUE;
        if(ai_UseSpontaneousCureTalentFromCategory(oCreature, AI_TALENT_PROTECTION, nInMelee, nDamage, oTarget)) return TRUE;
        if(ai_UseSpontaneousCureTalentFromCategory(oCreature, AI_TALENT_DISCRIMINANT_AOE, nInMelee, nDamage, oTarget)) return TRUE;
        if(ai_UseSpontaneousCureTalentFromCategory(oCreature, AI_TALENT_INDISCRIMINANT_AOE, nInMelee, nDamage, oTarget)) return TRUE;
        if(ai_UseSpontaneousCureTalentFromCategory(oCreature, AI_TALENT_TOUCH, nInMelee, nDamage, oTarget)) return TRUE;
        if(ai_UseSpontaneousCureTalentFromCategory(oCreature, AI_TALENT_RANGED, nInMelee, nDamage, oTarget)) return TRUE;
        if(ai_UseSpontaneousCureTalentFromCategory(oCreature, AI_TALENT_SUMMON, nInMelee, nDamage, oTarget)) return TRUE;
        if(ai_UseSpontaneousCureTalentFromCategory(oCreature, AI_TALENT_CURE, nInMelee, nDamage, oTarget)) return TRUE;
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
        case SPELL_CLARITY :
            if(ai_GetHasNegativeCondition(AI_CONDITION_DAZED, nConditions)) return TRUE;
            if(ai_GetHasNegativeCondition(AI_CONDITION_CHARMED, nConditions)) return TRUE;
            if(ai_GetHasNegativeCondition(AI_CONDITION_CONFUSED, nConditions)) return TRUE;
            if(ai_GetHasNegativeCondition(AI_CONDITION_STUNNED, nConditions)) return TRUE;
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
    if(AI_DEBUG) ai_Debug("0i_talents", "310", "jCategory: " + AI_TALENT_CURE + " " + JsonDump(jCategory, 2));
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
        if(AI_DEBUG) ai_Debug("0i_talents", "325", "nLevel: " + IntToString(nLevel) +
                 " nMaxSlotIndex: " + IntToString(nMaxSlotIndex));
        if(nMaxSlotIndex > 0)
        {
            // Get the talent within nLevel cycling from the first to the last.
            nSlotIndex = 0;
            while (nSlotIndex <= nMaxSlotIndex)
            {
                jTalent= JsonArrayGet(jLevel, nSlotIndex);
                if(AI_DEBUG) ai_Debug("0i_talents", "334", "nSlotIndex: " + IntToString(nSlotIndex) +
                         " jTalent Type: " + IntToString(JsonGetType(jTalent)));
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
                            if(AI_DEBUG) ai_Debug("0i_talents", "370", "Checking if Item is used up: " +
                                     IntToString(JsonGetInt(JsonArrayGet(jTalent, 4))));
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
    if(AI_DEBUG) ai_Debug("0i_talents", "391", AI_NO_TALENTS + AI_TALENT_CURE + ": " + IntToString(nMaxLevel));
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
    if(oTarget == oCreature)
    {
        if(ai_GetAIMode(oCreature, AI_MODE_SELF_HEALING_OFF)) return FALSE;
    }
    else if(ai_GetAIMode(oCreature, AI_MODE_PARTY_HEALING_OFF)) return FALSE;
    if(AI_DEBUG) ai_Debug("0i_talents", "419", "nNegativeConditions: " + IntToString(nNegativeConditions) +
             " on " + GetName(oTarget));
    if(ai_CheckTalentsVsConditions(oCreature, nNegativeConditions, nInMelee, nMaxLevel, oTarget)) return TRUE;
    return FALSE;
}
int ai_TryDefensiveTalent(object oCreature, int nInMelee, int nMaxLevel, string sCategory, object oTarget = OBJECT_INVALID)
{
    if(AI_DEBUG) ai_Debug("0i_talents", "426", "AI_NO_TALENTS_" + sCategory + ": " + IntToString(GetLocalInt(oCreature, AI_NO_TALENTS + sCategory)) +
             " >= nMaxLevel: " + IntToString(nMaxLevel));
    // If we have saved this level or higher to AI_NO_TALENTS then skip.
    if(GetLocalInt(oCreature, AI_NO_TALENTS + sCategory) >= nMaxLevel) return FALSE;
    if(ai_UseCreatureTalent(oCreature, sCategory, nInMelee, nMaxLevel, oTarget)) return TRUE;
    return FALSE;
}
// *****************************************************************************
// ************************* Try * Defensive Talents ***************************
// *****************************************************************************
// These functions try to find and use a specific set of talents intelligently.

int ai_TryDefensiveTalents(object oCreature, int nInMelee, int nMaxLevel, int nRound = 0, object oTarget = OBJECT_INVALID)
{
    // Summons are powerfull and should be used as much as possible.
    if(ai_UseCreatureTalent(oCreature, AI_TALENT_SUMMON, nInMelee, nMaxLevel, oTarget)) return TRUE;
    // Try to mix them up so we don't always cast spells in the same order.
    if(nRound >= d8()) return FALSE;
    int nRoll = d2();
    if(AI_DEBUG) ai_Debug("0i_talents", "444", "Lets help someone(Check Talents: " +IntToString(nRoll) +
             " nMaxLevel: " + IntToString(nMaxLevel) + ")!");
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
// *****************************************************************************
// ************************* Try * Skills **************************************
// *****************************************************************************
// These functions try to find and use a specific set of skills intelligently.

void ai_UseSkill(object oCreature, int nSkill, object oTarget)
{
    ai_SetLastAction(oCreature, AI_LAST_ACTION_USED_SKILL);
    if(GetReputation(oCreature, oTarget) < 11) SetLocalObject(oCreature, AI_ATTACKED_PHYSICAL, oTarget);
    if(AI_DEBUG) ai_Debug("0i_talents", "498", GetName(oCreature) + " is using skill: " +
             GetStringByStrRef(StringToInt(Get2DAString("skills", "Name", nSkill))) +
             " on " + GetName(oTarget));
    ActionUseSkill(nSkill, oTarget);
    ActionDoCommand(ExecuteScript("0e_do_combat_rnd", oCreature));
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
    if(AI_DEBUG) ai_Debug("0i_talents", "524", "Using parry against " + GetName(oTarget) + "!");
    return TRUE;
}
int ai_TryTaunt(object oCreature, object oTarget)
{
    int nCoolDown = GetLocalInt(oCreature, "AI_TAUNT_COOLDOWN");
    if(AI_DEBUG) ai_Debug("0i_talents", "530", "Has Taunt Effect? " +
               IntToString(ai_GetHasEffectType(oTarget, EFFECT_TYPE_TAUNT)) +
               " Cooldown: " + IntToString(nCoolDown));
    if(nCoolDown > 0)
    {
        SetLocalInt(oCreature, "AI_TAUNT_COOLDOWN", --nCoolDown);
        return FALSE;
    }
    if(!ai_GetHasEffectType(oTarget, EFFECT_TYPE_TAUNT)) return FALSE;
    // Check to see if we have a good chance for it to work.
    int nTauntRnk = GetSkillRank(SKILL_TAUNT, oCreature);
    if(AI_DEBUG) ai_Debug("0i_talents", "542", "Check Taunt: TauntRnk: " + IntToString(nTauntRnk) +
              " HitDice + 1: " + IntToString(GetHitDice(oCreature) + 1) +
              " Concentration: " + IntToString(GetSkillRank(SKILL_CONCENTRATION, oTarget)) + ".");
    int nConcentration = GetSkillRank(SKILL_CONCENTRATION, oTarget);
    // Our chance is greater than 50%.
    if(nTauntRnk <= nConcentration) return FALSE;
    ai_UseSkill(oCreature, SKILL_TAUNT, oTarget);
    SetLocalInt(oCreature, "AI_TAUNT_COOLDOWN", AI_TAUNT_COOLDOWN);
    return TRUE;
}
int ai_TryAnimalEmpathy(object oCreature, object oTarget = OBJECT_INVALID)
{
    if(!GetSkillRank(SKILL_ANIMAL_EMPATHY, oCreature)) return FALSE;
    int nCoolDown = GetLocalInt(oCreature, "AI_EMPATHY_COOLDOWN");
    if(AI_DEBUG) ai_Debug("0i_talents", "556", "Has Dominate Effect? " +
               IntToString(ai_GetHasEffectType(oTarget, EFFECT_TYPE_DOMINATED)) +
               " Cooldown: " + IntToString(nCoolDown));
    if(nCoolDown > 0)
    {
        SetLocalInt(oCreature, "AI_EMPATHY_COOLDOWN", --nCoolDown);
        return FALSE;
    }
    if(oTarget == OBJECT_INVALID)
    {
        oTarget = ai_GetNearestRacialTarget(oCreature, AI_RACIAL_TYPE_ANIMAL_BEAST);
        if(oTarget == OBJECT_INVALID) return FALSE;
    }
    if(!GetObjectSeen(oCreature, oTarget)) return FALSE;
    if(ai_GetHasEffectType(oTarget, EFFECT_TYPE_DOMINATED) ||
       GetIsImmune(oTarget, IMMUNITY_TYPE_MIND_SPELLS) ||
       GetIsImmune(oTarget, IMMUNITY_TYPE_DOMINATE) ||
       GetAssociateType(oTarget) != ASSOCIATE_TYPE_NONE) return FALSE;
    // Get the race of the target, it only works on Animals, Beasts, and Magical Beasts.
    int nRace = GetRacialType(oTarget);
    int nDC;
    if(nRace == RACIAL_TYPE_ANIMAL) nDC = 5;
    else if(nRace == RACIAL_TYPE_BEAST || nRace == RACIAL_TYPE_MAGICAL_BEAST) nDC = 9;
    else return FALSE;
     // Check to see if we have a good chance for it to work.
    int nEmpathyRnk = GetSkillRank(SKILL_ANIMAL_EMPATHY, oCreature);
    nDC += GetHitDice(oTarget);
    if(AI_DEBUG) ai_Debug("0i_talents", "632", "Check Animal Empathy: Rnk: " + IntToString(nEmpathyRnk) +
              " nDC: " + IntToString(nDC) + ".");
    // Our chance is greater than 50%.
    if(nEmpathyRnk <= nDC) return FALSE;
    ai_UseSkill(oCreature, SKILL_ANIMAL_EMPATHY, oTarget);
    SetLocalInt(oCreature, "AI_EMPATHY_COOLDOWN", AI_EMPATHY_COOLDOWN);
    return TRUE;
}
// *****************************************************************************
// ************************* Try * Feats ***************************************
// *****************************************************************************
// These functions try to find and use a specific set of feats intelligently.

void ai_UseFeat(object oCreature, int nFeat, object oTarget, int nSubFeat = 0)
{
    ai_SetLastAction(oCreature, AI_LAST_ACTION_USED_FEAT);
    if(GetReputation(oCreature, oTarget) < 11) SetLocalObject(oCreature, AI_ATTACKED_PHYSICAL, oTarget);
    if(AI_DEBUG) ai_Debug("0i_talents", "600", GetName(oCreature) + " is using feat: " +
             GetStringByStrRef(StringToInt(Get2DAString("feat", "FEAT", nFeat))) +
             " on " + GetName(oTarget));
    ActionUseFeat(nFeat, oTarget, nSubFeat);
    ActionDoCommand(ExecuteScript("0e_do_combat_rnd", oCreature));
}
void ai_UseFeatAttackMode(object oCreature, int nActionMode, int nAction, object oTarget, int nInMelee = 0, int bPassive = FALSE)
{
    if(AI_DEBUG) ai_Debug("0i_talents", "608", "Action mode (" + IntToString(nActionMode) + ") Is it set?: " +
             IntToString(GetActionMode(oCreature, nActionMode)));
    if(!GetActionMode(oCreature, nActionMode))
    {
        if(AI_DEBUG) ai_Debug("0i_talents", "612", "Setting action mode: " + IntToString(nActionMode));
        SetActionMode(oCreature, nActionMode, TRUE);
        SetLocalInt(oCreature, AI_CURRENT_ACTION_MODE, nActionMode);
    }
    ai_ActionAttack(oCreature, nAction, oTarget, nInMelee, bPassive, nActionMode);
}
int ai_TryBarbarianRageFeat(object oCreature)
{
    // Must not have rage already, must have the feat, and enemy must be strong enough.
    if(GetHasFeatEffect(FEAT_BARBARIAN_RAGE, oCreature) ||
       !GetHasFeat(FEAT_BARBARIAN_RAGE, oCreature)) return FALSE;
    ai_UseFeat(oCreature, FEAT_BARBARIAN_RAGE, oCreature);
    return TRUE;
}
int ai_TryBardSongFeat(object oCreature)
{
    if(AI_DEBUG) ai_Debug("0i_talents", "629", "BardSong Effect: " + IntToString(GetHasSpellEffect(411/*SPELL_BARD_SONG*/)) +
             " Level: " + IntToString(GetLevelByClass(CLASS_TYPE_BARD)) +
             " HasFeat: " + IntToString(GetHasFeat(FEAT_BARD_SONGS)));
    if(GetHasSpellEffect(411/*SPELL_BARD_SONG*/, oCreature) ||
       !GetHasFeat(FEAT_BARD_SONGS, oCreature)) return FALSE;
    ai_UseFeat(oCreature, FEAT_BARD_SONGS, oCreature);
    return TRUE;
}
int ai_TryCalledShotFeat(object oCreature, object oTarget)
{
    // Called shot has a -4 to hit adjustment.
    if(!ai_AttackPenaltyOk(oCreature, oTarget, -4.0)) return FALSE;
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
    if(!ai_AttackPenaltyOk(oCreature, oTarget, -6.0)) return FALSE;
    ai_UseFeat(oCreature, FEAT_DISARM, oTarget);
    return TRUE;
}
int ai_TryDivineMightFeat(object oCreature, int nInMelee)
{
    if(!GetHasFeat(FEAT_TURN_UNDEAD)) return FALSE;
    if(!GetHasFeat(FEAT_DIVINE_MIGHT)) return FALSE;
    if(GetHasFeatEffect(FEAT_DIVINE_MIGHT, oCreature)) return FALSE;
    if(!nInMelee) return FALSE;
    object oTarget = ai_GetEnemyAttackingMe(oCreature);
    if(oTarget == OBJECT_INVALID) return FALSE;
    float fAtkAdj = IntToFloat(GetAbilityModifier(ABILITY_CHARISMA, oCreature));
    if(!ai_AttackBonusGood(oCreature, oTarget, fAtkAdj)) return FALSE;
    if(AI_DEBUG) ai_Debug("0i_talents", "722", "USING DIVINE MIGHT on " + GetName(oCreature) + ".");
    ai_UseFeat(oCreature, FEAT_DIVINE_MIGHT, oCreature);
    return TRUE;
}
int ai_TryDivineShieldFeat(object oCreature, int nInMelee)
{
    if(!GetHasFeat(FEAT_TURN_UNDEAD)) return FALSE;
    if(!GetHasFeat(FEAT_DIVINE_SHIELD)) return FALSE;
    if(GetHasFeatEffect(FEAT_DIVINE_SHIELD, oCreature)) return FALSE;
    if(!nInMelee) return FALSE;
    object oTarget = ai_GetEnemyAttackingMe(oCreature);
    if(oTarget == OBJECT_INVALID) return FALSE;
    float fACAdj = IntToFloat(GetAbilityModifier(ABILITY_CHARISMA, oCreature));
    if(!ai_ACAdjustmentGood(oCreature, oTarget, fACAdj)) return FALSE;
    if(AI_DEBUG) ai_Debug("0i_talents", "736", "USING DIVINE SHIELD on " + GetName(oCreature) + ".");
    ai_UseFeat(oCreature, FEAT_DIVINE_SHIELD, oCreature);
    return TRUE;
}
int ai_TryExpertiseFeat(object oCreature)
{
    if(!GetHasFeat(FEAT_EXPERTISE, oCreature)) return FALSE;
    object oTarget = ai_GetEnemyAttackingMe(oCreature);
    // Expertise has a -5 atk and a +5 AC adjustment.
    if(oTarget == OBJECT_INVALID ||
       !ai_AttackPenaltyOk(oCreature, oTarget, -5.0) ||
       !ai_ACAdjustmentGood(oCreature, oTarget, 5.0))
    {
        SetActionMode(oCreature, ACTION_MODE_EXPERTISE, FALSE);
        DeleteLocalInt(oCreature, AI_CURRENT_ACTION_MODE);
        return FALSE;
    }
    if(AI_DEBUG) ai_Debug("0i_talents", "704", "USING EXPERTISE on " + GetName(oTarget) + ".");
    ai_UseFeatAttackMode(oCreature, ACTION_MODE_EXPERTISE, AI_LAST_ACTION_MELEE_ATK, oTarget);
    return TRUE;
}
int ai_TryFlurryOfBlowsFeat(object oCreature, object oTarget)
{
    if(!GetHasFeat(FEAT_FLURRY_OF_BLOWS, oCreature)) return FALSE;
    // Flurry of Blows has a -2 atk adjustment.
    if(!ai_AttackPenaltyOk(oCreature, oTarget, -2.0))
    {
        SetActionMode(oCreature, ACTION_MODE_FLURRY_OF_BLOWS, FALSE);
        DeleteLocalInt(oCreature, AI_CURRENT_ACTION_MODE);
        return FALSE;
    }
    if(AI_DEBUG) ai_Debug("0i_talents", "718", "USING FLURRY OF BLOWS on " + GetName(oTarget) + ".");
    ai_UseFeatAttackMode(oCreature, ACTION_MODE_FLURRY_OF_BLOWS, AI_LAST_ACTION_MELEE_ATK, oTarget, TRUE);
    return TRUE;
}
int ai_TryImprovedExpertiseFeat(object oCreature)
{
    if(!GetHasFeat(FEAT_IMPROVED_EXPERTISE, oCreature)) return FALSE;
    object oTarget = ai_GetEnemyAttackingMe(oCreature);
    // Improved expertise has a -10 atk +10 AC adjustment.
    if(oTarget == OBJECT_INVALID ||
       !ai_AttackPenaltyOk(oCreature, oTarget, -10.0) ||
       !ai_ACAdjustmentGood(oCreature, oTarget, 10.0))
    {
        SetActionMode(oCreature, ACTION_MODE_IMPROVED_EXPERTISE, FALSE);
        DeleteLocalInt(oCreature, AI_CURRENT_ACTION_MODE);
        return FALSE;
    }
    if(AI_DEBUG) ai_Debug("0i_talents", "735", "USING IMPROVED EXPERTISE on " + GetName(oTarget) + ".");
    ai_UseFeatAttackMode(oCreature, ACTION_MODE_IMPROVED_EXPERTISE, AI_LAST_ACTION_MELEE_ATK, oTarget);
    return TRUE;
}
int ai_TryImprovedPowerAttackFeat(object oCreature, object oTarget)
{
    if(!GetHasFeat(FEAT_IMPROVED_POWER_ATTACK, oCreature)) return FALSE;
    // Improved Power Attack has a -10 atk adjustment.
    // If we cannot hit or will kill in one hit then maybe we should use Power Attack instead.
    if(ai_PowerAttackGood(oCreature, oTarget, 10.0))
    {
        SetActionMode(oCreature, ACTION_MODE_IMPROVED_POWER_ATTACK, FALSE);
        DeleteLocalInt(oCreature, AI_CURRENT_ACTION_MODE);
        return ai_TryPowerAttackFeat(oCreature, oTarget);
    }
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
       !ai_AttackPenaltyOk(oCreature, oTarget, -4.0)) return FALSE;
    ai_UseFeat(oCreature, FEAT_KNOCKDOWN, oTarget);
    return TRUE;
}
int ai_TryPolymorphSelfFeat(object oCreature)
{
    if(GetHasFeat(FEAT_EPIC_OUTSIDER_SHAPE))
    {
        int nSubFeat = Random(3) + 733; // 733 azer, 734 rakshasa,  735 Slaad.
        if(ai_UseFeat(oCreature, FEAT_EPIC_OUTSIDER_SHAPE, oCreature, nSubFeat)) return TRUE;
    }
    else if(GetHasFeat(FEAT_EPIC_CONSTRUCT_SHAPE))
    {
        int nSubFeat = Random(3) + 738; // 738 Stone, 739 Flesh,  740 Iron.
        if(ai_UseFeat(oCreature, FEAT_EPIC_CONSTRUCT_SHAPE, oCreature, nSubFeat)) return TRUE;
    }
    else if(GetHasFeat(FEAT_EPIC_WILD_SHAPE_DRAGON))
    {
        int nSubFeat = Random(3) + 707; // 707 Red, 708 Blue,  709 Green.
        if(ai_UseFeat(oCreature, FEAT_EPIC_WILD_SHAPE_DRAGON, oCreature, nSubFeat)) return TRUE;
    }
    else if(GetHasFeat(FEAT_EPIC_WILD_SHAPE_UNDEAD))
    {
        int nSubFeat = Random(3) + 704; // 704 Risen Lord, 705 Vampire, 706 Spectre.
        if(ai_UseFeat(oCreature, FEAT_EPIC_WILD_SHAPE_UNDEAD, oCreature, nSubFeat)) return TRUE;
    }
    else if(GetHasFeat(FEAT_GREATER_WILDSHAPE_4))
    {
        int nSubFeat;
        int nRoll = d3();
        if(nRoll == 1) nSubFeat = 679; // Medusa
        else if(nRoll == 2) nSubFeat = 691; // Mindflayer
        else nSubFeat = 694; // DireTiger
        if(ai_UseFeat(oCreature, FEAT_GREATER_WILDSHAPE_4, oCreature, nSubFeat)) return TRUE;
    }
    else if(GetHasFeat(FEAT_GREATER_WILDSHAPE_3))
    {
        int nSubFeat;
        int nRoll = d3();
        if(nRoll == 1) nSubFeat = 670; // Basilisk
        else if(nRoll == 2) nSubFeat = 673; // Drider
        else nSubFeat = 674; // Manticore
        if(ai_UseFeat(oCreature, FEAT_GREATER_WILDSHAPE_3, oCreature, nSubFeat)) return TRUE;
    }
    else if(GetHasFeat(FEAT_GREATER_WILDSHAPE_2))
    {
        int nSubFeat;
        int nRoll = d3();
        if(nRoll == 1) nSubFeat = 672; // Harpy
        else if(nRoll == 2) nSubFeat = 678; // Gargoyle
        else nSubFeat = 680; // Minotaur
        if(ai_UseFeat(oCreature, FEAT_GREATER_WILDSHAPE_2, oCreature, nSubFeat)) return TRUE;
    }
    else if(GetHasFeat(FEAT_GREATER_WILDSHAPE_1))
    {
        int nSubFeat = Random(5) + 658; // Wyrmling
        if(ai_UseFeat(oCreature, FEAT_GREATER_WILDSHAPE_1, oCreature, nSubFeat)) return TRUE;
    }
    if(GetHasFeat(FEAT_HUMANOID_SHAPE))
    {
        int nSubFeat = Random(3) + 682; // 682 Drow, 683 Lizard, 684 Kobold.
        if(ai_UseFeat(oCreature, FEAT_HUMANOID_SHAPE, oCreature, nSubFeat)) return TRUE;
    }
    else if(GetHasFeat(FEAT_ELEMENTAL_SHAPE))
    {
        int nSubFeat = Random(4) + SUBFEAT_ELEMENTAL_SHAPE_EARTH;
        if(ai_UseFeat(oCreature, FEAT_ELEMENTAL_SHAPE, oCreature, nSubFeat)) return TRUE;
    }
    else if(GetHasFeat(FEAT_WILD_SHAPE))
    {
        int nSubFeat;
        int nCompanionType = GetAnimalCompanionCreatureType(oCreature);
        if(nCompanionType == ANIMAL_COMPANION_CREATURE_TYPE_NONE)
            nSubFeat = Random(5) + SUBFEAT_WILD_SHAPE_BROWN_BEAR;
        else
        {
            if(nCompanionType == ANIMAL_COMPANION_CREATURE_TYPE_BADGER)
                nSubFeat = SUBFEAT_WILD_SHAPE_BADGER;
            else if(nCompanionType == ANIMAL_COMPANION_CREATURE_TYPE_BOAR)
                nSubFeat = SUBFEAT_WILD_SHAPE_BOAR;
            else if(nCompanionType == ANIMAL_COMPANION_CREATURE_TYPE_BEAR)
                nSubFeat = SUBFEAT_WILD_SHAPE_BROWN_BEAR;
            else if(nCompanionType == ANIMAL_COMPANION_CREATURE_TYPE_PANTHER)
                nSubFeat = SUBFEAT_WILD_SHAPE_PANTHER;
            else if(nCompanionType == ANIMAL_COMPANION_CREATURE_TYPE_WOLF)
                nSubFeat = SUBFEAT_WILD_SHAPE_WOLF;
            else nSubFeat = Random(5) + SUBFEAT_WILD_SHAPE_BROWN_BEAR;
        }
        if(AI_DEBUG) ai_Debug("0i_talents", "885", " Using wild shape feat: " + IntToString(nSubFeat));
        ai_UseFeat(oCreature, FEAT_WILD_SHAPE, oCreature, nSubFeat);
        return TRUE;
    }
    return FALSE;
}
int ai_TryPowerAttackFeat(object oCreature, object oTarget)
{
    if(!GetHasFeat(FEAT_POWER_ATTACK, oCreature)) return FALSE;
    // Power Attack has a -5 atk adjustment.
    if(ai_PowerAttackGood(oCreature, oTarget, 5.0))
    {
        SetActionMode(oCreature, ACTION_MODE_POWER_ATTACK, FALSE);
        DeleteLocalInt(oCreature, AI_CURRENT_ACTION_MODE);
        return FALSE;
    }
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
    if(!ai_AttackPenaltyOk(oCreature, oTarget, -4.0))
    {
        SetActionMode(oCreature, ACTION_MODE_RAPID_SHOT, FALSE);
        DeleteLocalInt(oCreature, AI_CURRENT_ACTION_MODE);
        return FALSE;
    }
    ai_UseFeatAttackMode(oCreature, ACTION_MODE_RAPID_SHOT, AI_LAST_ACTION_RANGED_ATK, oTarget, nInMelee, TRUE);
    return TRUE;
}
int ai_TrySapFeat(object oCreature, object oTarget)
{
    // Does not work on creatures that cannot be hit by criticals or stunned.
    // Sap has a -4 atk adjustment.
    if(GetIsImmune(oTarget, IMMUNITY_TYPE_CRITICAL_HIT) ||
       GetIsImmune(oTarget, IMMUNITY_TYPE_STUN) ||
       !ai_AttackPenaltyOk(oCreature, oTarget, -4.0)) return FALSE;
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
       !ai_StrongOpponent(oCreature, oTarget) ||
       !ai_AttackPenaltyOk(oCreature, oTarget, -4.0)) return FALSE;
    ai_UseFeat(oCreature, FEAT_STUNNING_FIST, oTarget);
    return TRUE;
}
void ai_NameAssociate(object oCreature, int nAssociateType, string sName)
{
    object oAssociate = GetAssociate(nAssociateType, oCreature);
    if(GetName(oCreature) != "") return;
    SetName(oAssociate, sName);
    ChangeFaction(oAssociate, oCreature);
}
int ai_TrySummonAnimalCompanionTalent(object oCreature)
{
    if(!GetHasFeat(FEAT_ANIMAL_COMPANION, oCreature)) return FALSE;
    if(GetAssociate(ASSOCIATE_TYPE_ANIMALCOMPANION, oCreature) != OBJECT_INVALID) return FALSE;
    ai_UseFeat(oCreature, FEAT_ANIMAL_COMPANION, oCreature);
    DelayCommand(0.0, ai_NameAssociate(oCreature, ASSOCIATE_TYPE_FAMILIAR, "Animal Companion"));
    return TRUE;
}
int ai_TrySummonFamiliarTalent(object oCreature)
{
    if(!GetHasFeat(FEAT_SUMMON_FAMILIAR, oCreature)) return FALSE;
    if(GetAssociate(ASSOCIATE_TYPE_FAMILIAR, oCreature) != OBJECT_INVALID) return FALSE;
    ai_UseFeat(oCreature, FEAT_SUMMON_FAMILIAR, oCreature);
    DelayCommand(0.0, ai_NameAssociate(oCreature, ASSOCIATE_TYPE_FAMILIAR, "Familiar"));
    return TRUE;
}
int ai_TryLayOnHands(object oCreature)
{
    if(!GetHasFeat(FEAT_LAY_ON_HANDS, oCreature)) return FALSE;
    // Lets not run past an enemy to use touch atk unless we have the feats, bad tactics!
    float fRange;
    if(ai_CanIMoveInCombat(oCreature)) fRange = AI_RANGE_PERCEPTION;
    else
    {
        fRange = GetDistanceBetween(oCreature, GetLocalObject(oCreature, AI_ENEMY_NEAREST)) - 3.0f;
        // Looks bad when your right next to an ally, but technically the enemy is closer.
        if(fRange < AI_RANGE_MELEE) fRange = AI_RANGE_MELEE;
    }
    object oTarget = ai_GetLowestCRRacialTarget(oCreature, RACIAL_TYPE_UNDEAD, fRange);
    if(oTarget == OBJECT_INVALID) return FALSE;
    ai_UseFeat(oCreature, FEAT_LAY_ON_HANDS, oTarget);
    return TRUE;
}
int ai_TryTurningTalent(object oCreature)
{
    if(!GetHasFeat(FEAT_TURN_UNDEAD, oCreature)) return FALSE;
    if(AI_DEBUG) ai_Debug("0i_talents", "1043", "Checking for Turning Targets. ");
    int nHDCount, nHDCount2, nRacial, nHD;
    // Get characters levels.
    int nClericLevel = GetLevelByClass(CLASS_TYPE_CLERIC, oCreature);
    int nPaladinLevel = GetLevelByClass(CLASS_TYPE_PALADIN, oCreature);
    int nBlackguardlevel = GetLevelByClass(CLASS_TYPE_BLACKGUARD, oCreature);
    int nTotalLevel = GetHitDice(oCreature);
    int nTurnLevel = nClericLevel;
    int nClassLevel = nClericLevel;
    // GZ: Since paladin levels stack when turning, blackguard levels should stack as well
    // GZ: but not with the paladin levels (thus else if).
    if(nBlackguardlevel - 2 > 0 && nBlackguardlevel > nPaladinLevel)
    {
        nClassLevel += (nBlackguardlevel - 2);
        nTurnLevel  += (nBlackguardlevel - 2);
    }
    else if(nPaladinLevel - 2 > 0)
    {
        nClassLevel += (nPaladinLevel - 2);
        nTurnLevel  += (nPaladinLevel - 2);
    }
    //Flags for bonus turning types
    int nElemental = GetHasFeat(FEAT_AIR_DOMAIN_POWER, oCreature) +
                     GetHasFeat(FEAT_EARTH_DOMAIN_POWER, oCreature) +
                     GetHasFeat(FEAT_FIRE_DOMAIN_POWER, oCreature) +
                     GetHasFeat(FEAT_WATER_DOMAIN_POWER, oCreature);
    int nVermin = GetHasFeat(FEAT_PLANT_DOMAIN_POWER, oCreature);
    int nConstructs = GetHasFeat(FEAT_DESTRUCTION_DOMAIN_POWER, oCreature);
    int nGoodOrEvilDomain = GetHasFeat(FEAT_GOOD_DOMAIN_POWER, oCreature) +
                            GetHasFeat(FEAT_EVIL_DOMAIN_POWER, oCreature);
    int nPlanar = GetHasFeat(854, oCreature);
    // Get turning check average, modify if have the Sun Domain
    int nChrMod = GetAbilityModifier(ABILITY_CHARISMA, oCreature);
    int nTurnCheck = 15 + nChrMod; //The roll to apply to the max HD of undead that can be turned --> nTurnLevel
    int nTurnHD = 12 + nChrMod + nClassLevel; //The number of HD of undead that can be turned.
    if(GetHasFeat(FEAT_SUN_DOMAIN_POWER, oCreature))
    {
        nTurnCheck += 2;
        nTurnHD += 3;
    }
    //Determine the maximum HD of the undead that can be turned using a roll of 15 + ChrMod.
    if(nTurnCheck == 15) nTurnLevel += 1;
    else if(nTurnCheck >= 16 && nTurnCheck <= 18) nTurnLevel += 2;
    else if(nTurnCheck >= 19 && nTurnCheck <= 21) nTurnLevel += 3;
    else if(nTurnCheck >= 22) nTurnLevel += 4;
    // Collect the number of HitDice we will affect.
    int nCnt = 1;
    object oEnemy = GetNearestCreature(7, 7, oCreature, nCnt);
    while(oEnemy != OBJECT_INVALID && nHDCount < nTurnHD && GetDistanceBetween(oEnemy, oCreature) <= 20.0)
    {
        if(GetReputation(oCreature, oEnemy) < 11 && !ai_Disabled(oEnemy))
        {
            nRacial = GetRacialType(oEnemy);
            nHD = 0;
            if(nRacial == RACIAL_TYPE_UNDEAD) nHD = GetHitDice(oEnemy) + GetTurnResistanceHD(oEnemy);
            else if(nRacial == RACIAL_TYPE_OUTSIDER && nGoodOrEvilDomain + nPlanar > 0)
            {
                //Planar turning decreases spell resistance against turning by 1/2
                if(nPlanar) nHD = GetHitDice(oEnemy) + (GetSpellResistance(oEnemy) / 2);
                else nHD = GetHitDice(oEnemy) + GetSpellResistance(oEnemy);
            }
            else if(nRacial == RACIAL_TYPE_VERMIN && nVermin > 0) nHD = GetHitDice(oEnemy);
            else if(nRacial == RACIAL_TYPE_ELEMENTAL && nElemental > 0) nHD = GetHitDice(oEnemy);
            else if (nRacial == RACIAL_TYPE_CONSTRUCT && nConstructs > 0) nHD = GetHitDice(oEnemy);
            // Only count undead we can defeat!
            if(AI_DEBUG) ai_Debug("0i_talents", "1110", " nHD: " + IntToString(nHD) +
                                  " nTurnLevel: " + IntToString(nTurnLevel) +
                                  " nTurnHD: " + IntToString(nTurnHD) +
                                  " nHDCount: " + IntToString(nHDCount));
            if(nHD > 0 && nHD <= nTurnLevel && nHD <= (nTurnHD - nHDCount)) nHDCount += nHD;
        }
        oEnemy = GetNearestCreature(7, 7, oCreature, ++nCnt);
    }
    if(AI_DEBUG) ai_Debug("0i_talents", "1089", "Found " + IntToString(nHDCount) + " hitdice to turn from my location.");
    // Lets do one more check to see if we can get a better position to use TurnUndead.
    nCnt = 1;
    object oNearestEnemy = GetLocalObject(oCreature, AI_ENEMY_NEAREST);
    if(GetDistanceBetween(oCreature, oNearestEnemy) > AI_RANGE_MELEE)
    {
        oEnemy = oNearestEnemy;
        if(AI_DEBUG) ai_Debug("0i_talents", "1126", GetName(oEnemy));
        while(oEnemy != OBJECT_INVALID && nHDCount2 < nTurnHD && GetDistanceBetween(oEnemy, oNearestEnemy) <= 20.0)
        {
            if(AI_DEBUG) ai_Debug("0i_talents", "1129", GetName(oEnemy));
            if(GetReputation(oCreature, oEnemy) < 11 && !ai_Disabled(oEnemy))
            {
                nRacial = GetRacialType(oEnemy);
                nHD = 0;
                if(nRacial == RACIAL_TYPE_UNDEAD) nHD = GetHitDice(oEnemy) + GetTurnResistanceHD(oEnemy);
                else if(nRacial == RACIAL_TYPE_OUTSIDER && nGoodOrEvilDomain + nPlanar > 0)
                {
                    //Planar turning decreases spell resistance against turning by 1/2
                    if(nPlanar) nHD = GetHitDice(oEnemy) + (GetSpellResistance(oEnemy) / 2);
                    else nHD = GetHitDice(oEnemy) + GetSpellResistance(oEnemy);
                }
                else if(nRacial == RACIAL_TYPE_VERMIN && nVermin > 0) nHD = GetHitDice(oEnemy);
                else if(nRacial == RACIAL_TYPE_ELEMENTAL && nElemental > 0) nHD = GetHitDice(oEnemy);
                else if (nRacial == RACIAL_TYPE_CONSTRUCT && nConstructs > 0) nHD = GetHitDice(oEnemy);
                // Only count undead we can defeat!
                if(AI_DEBUG) ai_Debug("0i_talents", "1140", " nHD: " + IntToString(nHD) +
                                      " nTurnLevel: " + IntToString(nTurnLevel) +
                                      " nTurnHD: " + IntToString(nTurnHD) +
                                      " nHDCount2: " + IntToString(nHDCount2));
                if(nHD > 0 && nHD <= nTurnLevel && nHD <= (nTurnHD - nHDCount2)) nHDCount2 += nHD;
            }
            oEnemy = GetNearestCreature(7, 7, oNearestEnemy, ++nCnt);
        }
    }
    if(AI_DEBUG) ai_Debug("0i_talents", "1148", "Found " + IntToString(nHDCount2) + " hitdice to turn from enemy location.");
    if(nHDCount > nHDCount2)
    {
        if(nHDCount < nTurnHD / 2) return FALSE;
        ai_UseFeat(oCreature, FEAT_TURN_UNDEAD, oCreature);
        return TRUE;
    }
    else
    {
        if(nHDCount2 < nTurnHD / 2) return FALSE;
        ActionMoveToObject(oNearestEnemy, TRUE, 1.0f);
        ai_UseFeat(oCreature, FEAT_TURN_UNDEAD, oCreature);
        return TRUE;
    }
    return FALSE;
}
int ai_TryWhirlwindFeat(object oCreature)
{
    if(!GetHasFeat(FEAT_WHIRLWIND_ATTACK, oCreature)) return FALSE;
    // Only worth using if there are 3+ targets.
    if(AI_DEBUG) ai_Debug("0i_talents", "860", "WHIRLWIND : NumOfEnemies: " + IntToString(ai_GetNumOfEnemiesInGroup(oCreature, 3.0)) + ".");
    // Shortened distance so its more effective(went from 5.0 to 2.0 and up to 3.0)
    if(ai_GetNumOfEnemiesInGroup(oCreature, 3.0) < d3() + 1) return FALSE;
    // * DO NOT WHIRLWIND if any of the targets are "large" or bigger
    // * it seldom works against such large opponents.
    // * Though its okay to use Improved Whirlwind against these targets
    if((!GetHasFeat(FEAT_IMPROVED_WHIRLWIND, oCreature)) ||
      (GetCreatureSize(ai_GetNearestEnemy(oCreature, 1, 7, 7)) >= CREATURE_SIZE_LARGE &&
         GetCreatureSize(ai_GetNearestEnemy(oCreature, 2, 7, 7)) >= CREATURE_SIZE_LARGE))
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
    ai_UseFeat(oCreature, FEAT_WHOLENESS_OF_BODY, oCreature);
    return TRUE;
}
// *****************************************************************************
// ******************** Try Physical Attack Talents ****************************
// *****************************************************************************
// These functions try to find and use physical attack talents intelligently.

void ai_ActionAttack(object oCreature, int nAction, object oTarget, int nInMelee = 0, int bPassive = FALSE, int nActionMode = 0)
{
    // If we are doing a ranged attack then check our position on the battlefield.
    if(nAction == AI_LAST_ACTION_RANGED_ATK && ai_CheckCombatPosition(oCreature, oTarget, nInMelee, nAction)) return;
    ai_SetLastAction(oCreature, nAction);
    SetLocalObject(oCreature, AI_ATTACKED_PHYSICAL, oTarget);
    if(AI_DEBUG) ai_Debug("0i_talents", "894", GetName(oCreature) + " is attacking(" + IntToString(nAction) +
             ") " + GetName(oTarget) + " Current Action: " + IntToString(GetCurrentAction(oCreature)) +
             " Lastround Attacked Target: " + GetName(ai_GetAttackedTarget(oCreature)) +
             " bPassive: " + IntToString(bPassive) + " nActionMode: " + IntToString(nActionMode));
    ActionAttack(oTarget, bPassive);
    if(nActionMode == 0) ActionDoCommand(ExecuteScript("0e_do_combat_rnd", oCreature));
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
    if(AI_DEBUG) ai_Debug("0i_talents", "908", GetName(OBJECT_SELF) + " is flying to " + GetName(oTarget) + "!");
    effect eFly = EffectDisappearAppear(GetLocation(oTarget));
    ApplyEffectToObject(DURATION_TYPE_TEMPORARY, eFly, oCreature, 3.0f);
    DelayCommand(4.0f, ai_FlyToAttacks(oCreature, oTarget));
    // Used to make creature wait before starting its next round.
    SetLocalInt(oCreature, AI_COMBAT_WAIT_IN_SECONDS, 5);
}
int ai_TryDragonBreathAttack(object oCreature, int nRound, object oTarget = OBJECT_INVALID)
{
    int nCnt = GetLocalInt(oCreature, "AI_DRAGONS_BREATH");
    if(AI_DEBUG) ai_Debug("0i_talents", "918", "Try Dragon Breath Attack: nRound(" + IntToString(nRound) + ")" +
             " <= nCnt(" + IntToString(nCnt) + ")!");
    if(nRound <= nCnt) return FALSE;
    talent tUse = GetCreatureTalentBest(TALENT_CATEGORY_DRAGONS_BREATH, 20, oCreature);
    if(!GetIsTalentValid(tUse)) return FALSE;
    if(oTarget == OBJECT_INVALID)
    {
        string sIndex = IntToString(ai_GetHighestMeleeIndexNotInAOE(oCreature));
        oTarget = GetLocalObject(oCreature, AI_ENEMY + sIndex);
        if(oTarget == OBJECT_INVALID) return FALSE;
    }
    SetLocalInt(oCreature, "AI_DRAGONS_BREATH", d4() + nRound);
    ActionCastSpellAtObject(GetIdFromTalent(tUse), oTarget);
    if(AI_DEBUG) ai_Debug("0i_talents", "1019", GetName(oCreature) + " breaths on " + GetName(oTarget) + "!");
    return TRUE;
}
void ai_DragonMeleeAttack(object oCreature, object oTarget, string sDmgDice, string sText)
{
    if(AI_DEBUG) ai_Debug("0i_talents", "941", "oAttacker: " + GetName(oCreature) +
              " oTarget: " + GetName(oTarget));
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
    string sMessage = ai_AddColorToText(GetName(oCreature) + "'s", AI_COLOR_LIGHT_MAGENTA) +
                      ai_AddColorToText(sText + "attacks " + GetName(oTarget) + " : " + sHit + " :(" +
                      IntToString(nRoll) + " + " + IntToString(nAB) +
                      " = " + IntToString(nRoll + nAB) + ")", AI_COLOR_DARK_ORANGE);
    SendMessageToPC(oCreature, sMessage);
    SendMessageToPC(oTarget, sMessage);
    if(AI_DEBUG) ai_Debug("0i_talents", "965", "nAB: " + IntToString(nAB) +
              " nAC: " + IntToString(nAC) + " nRoll: " + IntToString(nRoll) +
              " nCheck: " + IntToString(nCheck) + " nDmg: " + IntToString(nDmg));
    if(nCheck <= 0) return;
    // Apply any damage to the target!
    effect eDmg = EffectDamage(nDmg, DAMAGE_TYPE_BLUDGEONING);
    ApplyEffectToObject(DURATION_TYPE_INSTANT, eDmg, oTarget);
}
// Checks to see if a dragon can use its wings on a nearby enemy.
// Checks the right side and then the left side to see if it can attack.
int ai_TryWingAttacks(object oCreature)
{
    if(AI_DEBUG) ai_Debug("0i_talents", "977", GetName(oCreature) + " is checking for wing Attacks!");
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
    if(AI_DEBUG) ai_Debug("0i_talents", "994", "nHitDice: " + IntToString(nHitDice) +
              " nDragonSize: " + IntToString(nDragonSize) +
              " sDmgDice: " + sDmgDice + " nDmg: " + IntToString(nDmg));
    // Get the closest enemy to our right wing.
    location lWing = GetFlankingRightLocation(oCreature);
    object oTarget = GetFirstObjectInShape(SHAPE_SPHERE, fSize, lWing);
    while(oTarget != OBJECT_INVALID)
    {
        if(AI_DEBUG) ai_Debug("0i_talents", "1002", "oTarget: " + GetName(oTarget));
        if(GetReputation(oCreature, oTarget) < 11 && !GetIsDead(oTarget)) break;
        oTarget = GetNextObjectInShape(SHAPE_SPHERE, fSize, lWing);
    }
    if(oTarget != OBJECT_INVALID) ai_DragonMeleeAttack(oCreature, oTarget, sDmgDice, " right wing ");
    // Get the closest enemy to our left wing.
    lWing = GetFlankingLeftLocation(oCreature);
    oTarget = GetFirstObjectInShape(SHAPE_SPHERE, fSize, lWing);
    while(oTarget != OBJECT_INVALID)
    {
        if(AI_DEBUG) ai_Debug("0i_talents", "1012", "oTarget: " + GetName(oTarget));
        if(GetReputation(oCreature, oTarget) < 11 && !GetIsDead(oTarget)) break;
        oTarget = GetNextObjectInShape(SHAPE_SPHERE, fSize, lWing);
    }
    if(oTarget != OBJECT_INVALID) ai_DragonMeleeAttack(oCreature, oTarget, sDmgDice, " left wing ");
    return TRUE;
}
// Looks behind the dragon to see if it can use it's tail slap on an enemy.
int ai_TryTailSlap(object oCreature)
{
    if(AI_DEBUG) ai_Debug("0i_talents", "1022", GetName(OBJECT_SELF) + " is checking for tail slap Attack!");
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
    if(AI_DEBUG) ai_Debug("0i_talents", "1039", "nHitDice: " + IntToString(nHitDice) +
              " nDragonSize: " + IntToString(nDragonSize) +
              " sDmgDice: " + sDmgDice + " nDmg: " + IntToString(nDmg));
    // Get the closest enemy to our tail.
    location lTail = GetBehindLocation(oCreature);
    object oTarget = GetFirstObjectInShape(SHAPE_SPHERE, fSize, lTail);
    while(oTarget != OBJECT_INVALID)
    {
        if(GetReputation(oCreature, oTarget) < 11 && !GetIsDead(oTarget)) break;
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
                sMessage =  ai_AddColorToText(GetName(oCreature), AI_COLOR_LIGHT_MAGENTA) +
                            ai_AddColorToText(" crushes " + GetName(oTarget) + ".", AI_COLOR_DARK_ORANGE);
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
                sMessage =  ai_AddColorToText(GetName(oTarget), AI_COLOR_LIGHT_MAGENTA) +
                      ai_AddColorToText(" dodges the crush attack from " + GetName(oTarget) + ".", AI_COLOR_DARK_ORANGE);
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
    if(AI_DEBUG) ai_Debug("0i_talents", "1110", GetName(OBJECT_SELF) + " is checking for crush Attack!");
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
    if(AI_DEBUG) ai_Debug("0i_talents", "1132", GetName(oCreature) + " is checking for tail sweep Attack!");
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
        sMessage =  ai_AddColorToText(GetName(oCreature), AI_COLOR_LIGHT_MAGENTA) +
                    ai_AddColorToText(" sweeps " + GetName(oTarget) + ".", AI_COLOR_ORANGE);
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
        oTarget = GetNextObjectInShape(SHAPE_SPHERE, fSize, lImpact);
    }
    // We only sweep every 3 rounds if we can.
    SetLocalInt(oCreature, "0_DRAGON_SWEEP", 3);
    return TRUE;
}
int ai_TrySneakAttack(object oCreature, int nInMelee, int bAlwaysAtk = TRUE)
{
    if(AI_DEBUG) ai_Debug("0i_talents", "1188", GetName(OBJECT_SELF) + " is checking for melee Sneak Attack!");
    if(!GetHasFeat(FEAT_SNEAK_ATTACK, oCreature)) return FALSE;
    // Lets get the nearest target that is attacking someone besides me.
    object oTarget = OBJECT_INVALID;
    oTarget = GetLocalObject(oCreature, AI_PC_LOCKED_TARGET);
    if(ai_GetAIMode(oCreature, AI_MODE_DEFEND_MASTER)) oTarget = ai_GetLowestCRAttackerOnMaster(oCreature);
    if(oTarget == OBJECT_INVALID)
    {
        string sIndex;
        // Check if we have Mobility, Spring Attack or a good tumble.
        // if we do then look for other targets besides who we are in melee with.
        if(!nInMelee) sIndex = IntToString(ai_GetBestSneakAttackIndex(oCreature, AI_RANGE_PERCEPTION, bAlwaysAtk));
        // If there are few enemies then we can safely move around.
        else if(nInMelee < 3 || ai_CanIMoveInCombat(oCreature))
        {
            sIndex = IntToString(ai_GetBestSneakAttackIndex(oCreature, AI_RANGE_MELEE));
        }
        // Ok we are in a serious fight so lets not give attack of opportunities.
        else sIndex = IntToString(ai_GetNearestCreatureIndex(oCreature, AI_RANGE_MELEE));
        oTarget = GetLocalObject(oCreature, AI_ENEMY + sIndex);
    }
    if(oTarget == OBJECT_INVALID) return FALSE;
    int nRacialType = GetRacialType(oTarget);
    if(nRacialType == RACIAL_TYPE_CONSTRUCT || nRacialType == RACIAL_TYPE_UNDEAD) return FALSE;
    if(ai_GetHasEffectType(oTarget, IMMUNITY_TYPE_CRITICAL_HIT)) return FALSE;
    ai_ActionAttack(oCreature, AI_LAST_ACTION_MELEE_ATK, oTarget);
    return TRUE;
}
int ai_TryRangedSneakAttack(object oCreature, int nInMelee)
{
    if(AI_DEBUG) ai_Debug("0i_talents", "1209", GetName(oCreature) + " is checking for a Ranged Sneak Attack!");
    // If we have Sneak Attack then we should be attacking targets that
    // are busy fighting so we can get extra damage.
    if(!GetHasFeat(FEAT_SNEAK_ATTACK, oCreature)) return FALSE;
    object oTarget = OBJECT_INVALID;
    oTarget = GetLocalObject(oCreature, AI_PC_LOCKED_TARGET);
    if(ai_GetAIMode(oCreature, AI_MODE_DEFEND_MASTER)) oTarget = ai_GetLowestCRAttackerOnMaster(oCreature);
    if(oTarget == OBJECT_INVALID) oTarget = GetLocalObject(oCreature, AI_ENEMY + IntToString(ai_GetBestSneakAttackIndex(oCreature)));
    if(oTarget == OBJECT_INVALID) return FALSE;
    int nRacialType = GetRacialType(oTarget);
    if(nRacialType == RACIAL_TYPE_CONSTRUCT || nRacialType == RACIAL_TYPE_UNDEAD) return FALSE;
    if(ai_GetHasEffectType(oTarget, IMMUNITY_TYPE_CRITICAL_HIT)) return FALSE;
    // If we have a target and are not within 30' then move within 30'.
    if(GetDistanceToObject(oTarget) > AI_RANGE_CLOSE) ActionMoveToObject(oTarget, TRUE, AI_RANGE_CLOSE);
    ai_ActionAttack(oCreature, AI_LAST_ACTION_RANGED_ATK, oTarget, nInMelee, TRUE);
    return TRUE;
}
int ai_TryMeleeTalents(object oCreature, object oTarget)
{
    if(AI_DEBUG) ai_Debug("0i_talents", "1224", "Check category melee talents!");
    talent tUse = GetCreatureTalentBest(TALENT_CATEGORY_HARMFUL_MELEE, 20, oCreature);
    if(!GetIsTalentValid(tUse)) return FALSE;
    int nId = GetIdFromTalent(tUse);
    if(AI_DEBUG) ai_Debug("0i_talents", "1228", "TALENT_CATEGORY_MELEE_TALENTS nId: " + IntToString(nId));
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
    else if(nId == FEAT_CALLED_SHOT) { if(ai_TryCalledShotFeat(oCreature, oTarget)) return TRUE; }
    return FALSE;
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
    if(AI_DEBUG) ai_Debug("0i_talents", "1258", "nMaxLevel: " + IntToString(nMaxLevel));
    return nMaxLevel;
}
int ai_GetAssociateTalentMaxLevel(object oCreature, int nDifficulty)
{
    int nLevel = (ai_GetCharacterLevels(oCreature) + 1) / 2;
    if(nLevel > 20) nLevel = 20;
    int nMaxLevel = (nLevel * nDifficulty) / 20;
    if(nMaxLevel < 1) nMaxLevel = 1;
    if(AI_DEBUG) ai_Debug("0i_talents", "1267", "nLevel: " + IntToString(nLevel) +
             " nMaxLevel: " + IntToString(nMaxLevel));
    return nMaxLevel;
}
int ai_GetHasTalent(object oCreature, int nTalent)
{
    string sCategory = Get2DAString("ai_spells", "Category", nTalent);
    json jCategory = GetLocalJson(oCreature, sCategory);
    if(JsonGetType(jCategory) == JSON_TYPE_NULL) return FALSE;
    int nLevel, nSlot, nSlotIndex, nMaxSlotIndex, nSpell;
    json jLevel, jTalent;
    // Loop through nLevels looking for nTalent
    while(nLevel <= 9)
    {
        // Get the array of nLevel.
        jLevel = JsonArrayGet(jCategory, nLevel);
        nMaxSlotIndex = JsonGetLength(jLevel);
        if(nMaxSlotIndex > 0)
        {
            // Get the talent within nLevel cycling from the first to the last.
            nSlotIndex = 0;
            while (nSlotIndex < nMaxSlotIndex)
            {
                jTalent= JsonArrayGet(jLevel, nSlotIndex);
                nSpell = JsonGetInt(JsonArrayGet(jTalent, 1));
                if(nSpell == nTalent) return TRUE;
                nSlotIndex++;
            }
        }
        nLevel++;
    }
    return FALSE;
}
object ai_CheckTalentForBuffing(object oCreature, string sCategory, int nSpell)
{
    // Should we buff this monster caster? Added legacy code just in case.
    if((sCategory == "P" || sCategory == "E") &&
       (GetLocalInt(GetModule(), AI_RULE_BUFF_MONSTERS) ||
        GetLocalInt(oCreature, "NW_GENERIC_MASTER") & 0x04000000)) return ai_GetBuffTarget(oCreature, nSpell);
    if(sCategory == "S" && GetLocalInt(GetModule(), AI_RULE_PRESUMMON)) return oCreature;
    return OBJECT_INVALID;
}
int ai_UseBuffTalent(object oCreature, int nClass, int nLevel, int nSlot, int nSpell, int nType, object oTarget, object oItem)
{
    if(nType == AI_TALENT_TYPE_SPELL)
    {
        if(Get2DAString("classes", "MemorizesSpells", nClass) == "1")
        {
            if(GetMemorizedSpellReady(oCreature, nClass, nLevel, nSlot))
            {
                ai_CastMemorizedSpell(oCreature, nClass, nLevel, nSlot, oTarget, TRUE);
                return TRUE;
            }
        }
        else if(GetSpellUsesLeft(oCreature, nClass, nSpell))
        {
            ai_CastKnownSpell(oCreature, nClass, nSpell, oTarget, TRUE);
            return TRUE;
        }
    }
    else if(nType == AI_TALENT_TYPE_SP_ABILITY)
    {
        ActionCastSpellAtObject(nSpell, oTarget, 255, FALSE, 0, 0, TRUE, 255);
    }
    /* This will not work as there is no cheat option for using an item.
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
            if(AI_DEBUG) ai_Debug("0i_talents", "1319", "Item charges: " + IntToString(GetItemCharges(oItem)));
            int nCharges = GetItemCharges(oItem);
            if(nUses == 6 && nCharges == 1 || nUses == 5 && nCharges < 4 ||
               nUses == 4 && nCharges < 6 || nUses == 3 && nCharges < 8 ||
               nUses == 2 && nCharges < 10) return FALSE;
        }
        else if(nUses > 7 && nUses < 13)
        {
            if(AI_DEBUG) ai_Debug("0i_talents", "1327", "Item uses: " + IntToString(GetItemPropertyUsesPerDayRemaining(oItem, ipProp)));
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
int ai_SpellRestricted(int nSpell)
{
    json jRSpells = GetLocalJson(GetModule(), AI_RULE_RESTRICTED_SPELLS);
    int nIndex, nMaxIndex = JsonGetLength(jRSpells);
    while(nIndex < nMaxIndex)
    {
        if(JsonGetInt(JsonArrayGet(jRSpells, nIndex)) == nSpell)
        {
            if(AI_DEBUG) ai_Debug("0i_talents", "1703", IntToString(nSpell) + " is has been restricted and will be ignored!");
            return TRUE;
        }
        nIndex++;
    }
    return FALSE;
}
void ai_SaveTalent(object oCreature, int nClass, int nJsonLevel, int nLevel, int nSlot, int nSpell, int nType, int bMonster, object oItem = OBJECT_INVALID)
{
    // Players/Admins can restrict some spells.
    if(ai_SpellRestricted(nSpell)) return;
    // Get the talent category, we organize all talents by categories.
    string sCategory = Get2DAString("ai_spells", "Category", nSpell);
    // If it is a blank talent or it is an Area of Effect talent we skip.
    if(sCategory == "" || sCategory == "A") return;
    // Check to see if we should be prebuffing.
    if(bMonster)
    {
        int nSpellBuffDuration = StringToInt(Get2DAString("ai_spells", "Buff_Duration", nSpell));
        if(nSpellBuffDuration == 3)
        {
            if(AI_DEBUG) ai_Debug("0i_talents", "1600", GetName(oCreature) + " is buffing with spell " + IntToString(nSpell));
            object oTarget = ai_CheckTalentForBuffing(oCreature, sCategory, nSpell);
            if(oTarget != OBJECT_INVALID &&
               ai_UseBuffTalent(oCreature, nClass, nLevel, nSlot, nSpell, nType, oTarget, oItem)) return;
        }
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
        // Default the no talent check to 0 and each spell will raise it based on level.
        SetLocalInt(oCreature, AI_NO_TALENTS + sCategory, 0);
    }
    // Get the current Level so we can save to it.
    json jLevel = JsonArrayGet(jCategory, nJsonLevel);
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
    JsonArraySetInplace(jCategory, nJsonLevel, jLevel);
    SetLocalJson(oCreature, sCategory, jCategory);
    if(AI_DEBUG) ai_Debug("0i_talents", "1387", sCategory + ": " + JsonDump(jCategory, 1));
    if(AI_DEBUG) ai_Debug("0i_talents", "1388", "AI_NO_TALENTS: " +
             IntToString(GetLocalInt(oCreature, AI_NO_TALENTS + sCategory)) +
             " nJsonLevel: " + IntToString(nJsonLevel));
    // Set AI_NO_TALENTS so they can skip checks for nLevel.
    if(nJsonLevel <= GetLocalInt(oCreature, AI_NO_TALENTS + sCategory))
    {
        SetLocalInt(oCreature, AI_NO_TALENTS + sCategory, nJsonLevel);
    }
}
// For removing used up spell slots.
void ai_RemoveTalent(object oCreature, json jCategory, json jLevel, string sCategory, int nLevel, int nSlotIndex)
{
    if(AI_DEBUG) ai_Debug("0i_talents", "1400", "removing Talent from slot: " + IntToString(nSlotIndex));
    JsonArrayDelInplace(jLevel, nSlotIndex);
    if(AI_DEBUG) ai_Debug("0i_talents", "1402", "jLevel: " + JsonDump(jLevel, 2));
    JsonArraySetInplace(jCategory, nLevel, jLevel);
    if(AI_DEBUG) ai_Debug("0i_talents", "1404", "jCategory: " + JsonDump(jCategory, 2));
    SetLocalJson(oCreature, sCategory, jCategory);
}
// For removing Sorcerer/Bard spell levels once used up.
void ai_RemoveTalentLevel(object oCreature, json jCategory, json jLevel, string sCategory, int nLevel)
{
    if(AI_DEBUG) ai_Debug("0i_talents", "1410", "removing Talent level: " + IntToString(nLevel));
    JsonArrayDelInplace(jCategory, nLevel);
    if(AI_DEBUG) ai_Debug("0i_talents", "1412", "jCategory: " + JsonDump(jCategory, 2));
    SetLocalJson(oCreature, sCategory, jCategory);
}
void ai_SetCreatureSpellTalents(object oCreature, int bMonster)
{
    if(AI_DEBUG) ai_Debug("0i_talents", "1417", GetName(oCreature) + ": Setting Spell Talents for combat [Buff: " +
             IntToString(bMonster) + "].");
    // Cycle through all classes and spells.
    int nClassPosition = 1, nMaxSlot, nLevel, nSlot, nSpell, nIndex, nMetaMagic;
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
                    if(AI_DEBUG) ai_Debug("0i_talents", "1434", "nClass: " + IntToString(nClass) +
                                 " nLevel: " + IntToString(nLevel) + " nMaxSlot: " +
                                 IntToString(nMaxSlot));
                    nSlot = 0;
                    while(nSlot < nMaxSlot)
                    {
                        if(AI_DEBUG) ai_Debug("0i_talents", "1440", "nSlot: " + IntToString(nSlot) + " nSpell: " +
                                 IntToString(GetMemorizedSpellId(oCreature, nClass, nLevel, nSlot)) + " spell memorized: " +
                                 IntToString(GetMemorizedSpellReady(oCreature, nClass, nLevel, nSlot)));
                        if(GetMemorizedSpellReady(oCreature, nClass, nLevel, nSlot) == 1)
                        {
                            nSpell = GetMemorizedSpellId(oCreature, nClass, nLevel, nSlot);
                            // Move a spell up to a different JsonLevel as higher Jsonlevel
                            // spells usually get cast first.
                            nMetaMagic = GetMemorizedSpellMetaMagic(oCreature, nClass, nLevel, nSlot);
                            if(nMetaMagic > 0)
                            {
                                if(nMetaMagic == METAMAGIC_STILL) nMetaMagic = 1;
                                else if(nMetaMagic == METAMAGIC_EXTEND) nMetaMagic = 1;
                                else if(nMetaMagic == METAMAGIC_SILENT) nMetaMagic = 1;
                                else if(nMetaMagic == METAMAGIC_EMPOWER) nMetaMagic = 2;
                                else if(nMetaMagic == METAMAGIC_MAXIMIZE) nMetaMagic = 3;
                                else if(nMetaMagic == METAMAGIC_QUICKEN) nMetaMagic = 4;
                            }
                            ai_SaveTalent(oCreature, nClass, nLevel + nMetaMagic, nLevel, nSlot, nSpell, AI_TALENT_TYPE_SPELL, bMonster);
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
                    if(AI_DEBUG) ai_Debug("0i_talents", "1462", "nClass: " + IntToString(nClass) +
                                 " nLevel: " + IntToString(nLevel) + " nMaxSlot: " +
                                 IntToString(nMaxSlot));
                    nSlot = 0;
                    while(nSlot < nMaxSlot)
                    {
                        nSpell = GetKnownSpellId(oCreature, nClass, nLevel, nSlot);
                        if(AI_DEBUG) ai_Debug("0i_talents", "1469", "nSlot: " + IntToString(nSlot) +
                                 " nSpell: " + IntToString(nSpell) + " nUsesLeft: " +
                                 IntToString(GetSpellUsesLeft(oCreature, nClass, nSpell)));
                        if(GetSpellUsesLeft(oCreature, nClass, nSpell) > 0)
                        {
                            ai_SaveTalent(oCreature, nClass, nLevel, nLevel, nSlot, nSpell, AI_TALENT_TYPE_SPELL, bMonster);
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
void ai_SetCreatureSpecialAbilityTalents(object oCreature, int bMonster)
{
    if(AI_DEBUG) ai_Debug("0i_talents", "1488", GetName(oCreature) + ": Setting Special Ability Talents for combat.");
    // Cycle through all the creatures special abilities.
    int nMaxSpecialAbilities = GetSpellAbilityCount(oCreature);
    if(AI_DEBUG) ai_Debug("0i_talents", "1491", IntToString(GetSpellAbilityCount(oCreature)) + " Spell abilities.");
    if(nMaxSpecialAbilities)
    {
        int nIndex, nSpell, nLevel;
        while(nIndex < nMaxSpecialAbilities)
        {
            nSpell = GetSpellAbilitySpell(oCreature, nIndex);
            if(GetSpellAbilityReady(oCreature, nSpell))
            {
                nLevel = StringToInt(Get2DAString("spells", "Innate", nSpell));
                ai_SaveTalent(oCreature, 255, nLevel, nLevel, nIndex, nSpell, AI_TALENT_TYPE_SP_ABILITY, bMonster);
            }
            nIndex++;
        }
    }
}
void ai_CheckItemProperties(object oCreature, object oItem, int bMonster, int bEquiped = FALSE)
{
    if(AI_DEBUG) ai_Debug("0i_talents", "1509", "Checking Item properties on " + GetName(oItem));
    // We have established that we can use the item if it is equiped.
    if(!bEquiped && !ai_CheckIfCanUseItem(oCreature, oItem)) return;
    // Get or create an Immunity in json so we can check item immunities quickly.
    int nSpellImmunity, bHasItemImmunity, nPerDay, nCharges, nUses, bSaveTalent;
    int bMagicItemUse = !ai_GetMagicMode(oCreature, AI_MAGIC_NO_MAGIC_ITEMS);
    json jImmunity = GetLocalJson(oCreature, AI_TALENT_IMMUNITY);
    if(JsonGetType(jImmunity) == JSON_TYPE_NULL) jImmunity = JsonArray();
    int nIprpSubType, nSpell, nLevel, nIPType, nIndex;
    itemproperty ipProp = GetFirstItemProperty(oItem);
    // Lets skip this if there are no properties.
    if(!GetIsItemPropertyValid(ipProp)) return;
    // Check for cast spell property and add them to the talent list.
    while(GetIsItemPropertyValid(ipProp))
    {
        nIPType = GetItemPropertyType(ipProp);
        if(AI_DEBUG) ai_Debug("0i_talents", "1895", "ItempropertyType(15/80/53): " + IntToString(nIPType));
        if(bMagicItemUse)
        {
            if(nIPType == ITEM_PROPERTY_CAST_SPELL)
            {
                bSaveTalent = TRUE;
                // Get how they use the item (charges or uses per day).
                nUses = GetItemPropertyCostTableValue(ipProp);
                if(nUses > 1 && nUses < 7)
                {
                    nCharges = GetItemCharges(oItem);
                    if(AI_DEBUG) ai_Debug("0i_talents", "1530", "Charges per use: " + IntToString(nUses) +
                             " Item charges: " + IntToString(nCharges));
                    if((nUses == IP_CONST_CASTSPELL_NUMUSES_1_CHARGE_PER_USE && nCharges < 1) ||
                       (nUses == IP_CONST_CASTSPELL_NUMUSES_2_CHARGES_PER_USE && nCharges < 2) ||
                       (nUses == IP_CONST_CASTSPELL_NUMUSES_3_CHARGES_PER_USE && nCharges < 3) ||
                       (nUses == IP_CONST_CASTSPELL_NUMUSES_4_CHARGES_PER_USE && nCharges < 4) ||
                       (nUses == IP_CONST_CASTSPELL_NUMUSES_5_CHARGES_PER_USE && nCharges < 5)) bSaveTalent = FALSE;
                }
                else if(nUses > 7 && nUses < 13)
                {
                    nPerDay = GetItemPropertyUsesPerDayRemaining(oItem, ipProp);
                    if(AI_DEBUG) ai_Debug("0i_talents", "1676", "Item uses: " + IntToString(nPerDay));
                    if(nPerDay == 0) bSaveTalent = FALSE;
                }
                if(bSaveTalent)
                {
                    // SubType is the ip spell index for iprp_spells.2da
                    nIprpSubType = GetItemPropertySubType(ipProp);
                    nSpell = StringToInt(Get2DAString("iprp_spells", "SpellIndex", nIprpSubType));
                    nLevel = StringToInt(Get2DAString("iprp_spells", "InnateLvl", nIprpSubType));
                    ai_SaveTalent(oCreature, 255, nLevel, nLevel, nIndex, nSpell, AI_TALENT_TYPE_ITEM, bMonster, oItem);
                    nIndex++;
                }
            }
            else if(nIPType == ITEM_PROPERTY_HEALERS_KIT)
            {
                // Lets set Healing kits as Cure Light Wounds since they heal 1d20 in combat.
                nSpell = SPELL_CURE_MINOR_WOUNDS;
                // Save the healer kit as level 9 so we can use them first.
                // Must also have ranks in healing kits.
                if(GetSkillRank(SKILL_HEAL, oCreature) > 0)
                {
                    ai_SaveTalent(oCreature, 255, 5, nLevel, nIndex, nSpell, AI_TALENT_TYPE_ITEM, bMonster, oItem);
                    nIndex++;
                }
            }
        }
        if(bEquiped)
        {
            if(nIPType == ITEM_PROPERTY_IMMUNITY_SPECIFIC_SPELL)
            {
                bHasItemImmunity = TRUE;
                nSpellImmunity = GetItemPropertyCostTableValue(ipProp);
                nSpellImmunity = StringToInt(Get2DAString("iprp_spellcost", "SpellIndex", nSpellImmunity));
                //if(AI_DEBUG) ai_Debug("0i_talents", "1950", "SpellImmunity to " + Get2DAString("spells", "Label", nSpellImmunity));
                JsonArrayInsertInplace(jImmunity, JsonInt(nSpellImmunity));
            }
            else if(nIPType == ITEM_PROPERTY_HASTE) SetLocalInt(oCreature, sIPHasHasteVarname, TRUE);
            else if(nIPType == ITEM_PROPERTY_IMMUNITY_DAMAGE_TYPE)
            {
                int nBit, nIpSubType = GetItemPropertySubType(ipProp);
                if(AI_DEBUG) ai_Debug("0i_talents", "1957", "nIPSubType: " + IntToString(nIpSubType));
                if(nIpSubType == 0) nBit = DAMAGE_TYPE_BLUDGEONING;
                else if(nIpSubType == 1) nBit = DAMAGE_TYPE_PIERCING;
                else if(nIpSubType == 2) nBit = DAMAGE_TYPE_SLASHING;
                else if(nIpSubType == 5) nBit = DAMAGE_TYPE_MAGICAL;
                else if(nIpSubType == 6) nBit = DAMAGE_TYPE_ACID;
                else if(nIpSubType == 7) nBit = DAMAGE_TYPE_COLD;
                else if(nIpSubType == 8) nBit = DAMAGE_TYPE_DIVINE;
                else if(nIpSubType == 9) nBit = DAMAGE_TYPE_ELECTRICAL;
                else if(nIpSubType == 10) nBit = DAMAGE_TYPE_FIRE;
                else if(nIpSubType == 11) nBit = DAMAGE_TYPE_NEGATIVE;
                else if(nIpSubType == 12) nBit = DAMAGE_TYPE_POSITIVE;
                else if(nIpSubType == 13) nBit = DAMAGE_TYPE_SONIC;
                if(nBit > 0) ai_SetItemProperty(oCreature, sIPImmuneVarname, nBit, TRUE);
            }
            else if(nIPType == ITEM_PROPERTY_DAMAGE_RESISTANCE)
            {
                int nBit, nIpSubType = GetItemPropertySubType(ipProp);
                if(nIpSubType == 0) nBit = DAMAGE_TYPE_BLUDGEONING;
                else if(nIpSubType == 1) nBit = DAMAGE_TYPE_PIERCING;
                else if(nIpSubType == 2) nBit = DAMAGE_TYPE_SLASHING;
                else if(nIpSubType == 5) nBit = DAMAGE_TYPE_MAGICAL;
                else if(nIpSubType == 6) nBit = DAMAGE_TYPE_ACID;
                else if(nIpSubType == 7) nBit = DAMAGE_TYPE_COLD;
                else if(nIpSubType == 8) nBit = DAMAGE_TYPE_DIVINE;
                else if(nIpSubType == 9) nBit = DAMAGE_TYPE_ELECTRICAL;
                else if(nIpSubType == 10) nBit = DAMAGE_TYPE_FIRE;
                else if(nIpSubType == 11) nBit = DAMAGE_TYPE_NEGATIVE;
                else if(nIpSubType == 12) nBit = DAMAGE_TYPE_POSITIVE;
                else if(nIpSubType == 13) nBit = DAMAGE_TYPE_SONIC;
                if(nBit > 0) ai_SetItemProperty(oCreature, sIPResistVarname, nBit, TRUE);
            }
            else if(nIPType == ITEM_PROPERTY_DAMAGE_REDUCTION)
            {
                int nIpSubType = GetItemPropertySubType(ipProp);
                SetLocalInt(oCreature, sIPReducedVarname, nIpSubType);
            }
        }
        ipProp = GetNextItemProperty(oItem);
    }
    // If nSpellImmunity has been set then we need to save our Immunity json.
    if(bHasItemImmunity) SetLocalJson(oCreature, AI_TALENT_IMMUNITY, jImmunity);
}
void ai_SetCreatureItemTalents(object oCreature, int bMonster)
{
    if(AI_DEBUG) ai_Debug("0i_talents", "1561", GetName(oCreature) + ": Setting Item Talents for combat.");
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
            if(AI_DEBUG) ai_Debug("0i_talents", "1572", GetName(oItem) + " requires " + Get2DAString("baseitems", "EquipableSlots", GetBaseItemType(oItem)) + " slots.");
            if(sSlots == "0x00000") ai_CheckItemProperties(oCreature, oItem, bMonster);
        }
        oItem = GetNextItemInInventory(oCreature);
    }
    int nSlot;
    // Cycle through all the creatures equiped items.
    oItem = GetItemInSlot(nSlot, oCreature);
    while(nSlot < 11)
    {
        if(oItem != OBJECT_INVALID) ai_CheckItemProperties(oCreature, oItem, bMonster, TRUE);
        oItem = GetItemInSlot(++nSlot, oCreature);
    }
    oItem = GetItemInSlot(INVENTORY_SLOT_CARMOUR, oCreature);
    if(oItem != OBJECT_SELF) ai_CheckItemProperties(oCreature, oItem, bMonster, TRUE);
}
void ai_SetCreatureTalents(object oCreature, int bMonster)
{
    if(GetLocalInt(oCreature, AI_TALENTS_SET)) return;
    SetLocalInt(oCreature, AI_TALENTS_SET, TRUE);
    object oModule = GetModule();
    ai_Counter_Start();
    ai_SetCreatureSpellTalents(oCreature, bMonster);
    ai_Counter_End(GetName(oCreature) + ": Spell Talents");
    ai_SetCreatureSpecialAbilityTalents(oCreature, bMonster);
    ai_Counter_End(GetName(oCreature) + ": Special Ability Talents");
    DeleteLocalJson(oCreature, AI_TALENT_IMMUNITY);
    ai_SetCreatureItemTalents(oCreature, bMonster);
    ai_Counter_End(GetName(oCreature) + ": Item Talents");
    if(GetLocalInt(oModule, AI_RULE_SUMMON_COMPANIONS) && GetLocalInt(oModule, AI_RULE_PRESUMMON) && bMonster)
    {
        ai_TrySummonFamiliarTalent(oCreature);
        ai_TrySummonAnimalCompanionTalent(oCreature);
    }
    // AI_CAT_CURE is setup differently we save the level as the highest.
    if(JsonGetType(GetLocalJson(oCreature, AI_TALENT_CURE)) != JSON_TYPE_NULL) SetLocalInt(oCreature, AI_NO_TALENTS + AI_TALENT_CURE, 9);
    // With spontaneous cure spells we need to clear this as the number of spells don't count.
    if(GetLevelByClass(CLASS_TYPE_CLERIC, oCreature)) SetLocalInt(oCreature, AI_NO_TALENTS + AI_TALENT_HEALING, 0);
}
int ai_UseSpontaneousCureTalentFromCategory(object oCreature, string sCategory, int nInMelee, int nDamage, object oTarget = OBJECT_INVALID)
{
    int nLevel = 4;
    if(AI_DEBUG) ai_Debug("0i_talents", "1782", "AI_NO_TALENTS_" + sCategory + ": " +
             IntToString(GetLocalInt(oCreature, AI_NO_TALENTS + sCategory)) +
             "  >= nLevel: " + IntToString(nLevel));
    // If we have saved this level or higher to AI_NO_TALENTS then skip.
    int nMinNoTalentLevel = GetLocalInt(oCreature, AI_NO_TALENTS + sCategory);
    if(nMinNoTalentLevel >= nLevel) return FALSE;
    // Get the saved category from oCreature.
    json jCategory = GetLocalJson(oCreature, sCategory);
    if(AI_DEBUG) ai_Debug("0i_talents", "1790", "jCategory: " + sCategory + " " + JsonDump(jCategory, 2));
    if(JsonGetType(jCategory) == JSON_TYPE_NULL)
    {
        SetLocalInt(oCreature, AI_NO_TALENTS + sCategory, 9);
        return FALSE;
    }
    if(nLevel < 0 || nLevel > 5) nLevel = 4;
    json jLevel, jTalent, jLevelSave;
    int nTalentType, nTalentClass, nTalentSlot, nSpell;
    int nSlotIndex, nMaxSlotIndex, nMaxNoTalentLevel, nSpellSave, nLevelSave, nSlotSave;
    string sSpellName;
    // Loop through nLevels down to nMinNoTalentLevel looking for the first talent
    // (i.e. the highest or best?).
    while(nLevel >= nMinNoTalentLevel)
    {
        // Get the array of nLevel cycling down to 0.
        jLevel = JsonArrayGet(jCategory, nLevel);
        nMaxSlotIndex = JsonGetLength(jLevel);
        if(AI_DEBUG) ai_Debug("0i_talents", "1806", "nLevel: " + IntToString(nLevel) +
                 " nMaxSlotIndex: " + IntToString(nMaxSlotIndex));
        if(nMaxSlotIndex > 0)
        {
            // Set MaxNoTalentLevel to 0 if the level has a talent.
            nMaxNoTalentLevel = 0;
            // Get the talent within nLevel cycling from the first to the last.
            nSlotIndex = 0;
            while (nSlotIndex < nMaxSlotIndex)
            {
                jTalent= JsonArrayGet(jLevel, nSlotIndex);
                if(AI_DEBUG) ai_Debug("0i_talents", "1817", "nSlotIndex: " + IntToString(nSlotIndex) +
                         " jTalent Type: " + IntToString(JsonGetInt(JsonArrayGet(jTalent, 0))));
                nTalentType = JsonGetInt(JsonArrayGet(jTalent, 0));
                nTalentClass = JsonGetInt(JsonArrayGet(jTalent, 2));
                // We can only convert spells from the cleric class.
                if(nTalentType == AI_TALENT_TYPE_SPELL && nTalentClass == CLASS_TYPE_CLERIC)
                {
                    if(nLevel == 4) nSpell = SPELL_CURE_CRITICAL_WOUNDS;
                    else if(nLevel == 3) nSpell = SPELL_CURE_SERIOUS_WOUNDS;
                    else if(nLevel == 2) nSpell = SPELL_CURE_MODERATE_WOUNDS;
                    else if(nLevel == 1) nSpell = SPELL_CURE_LIGHT_WOUNDS;
                    else nSpell = 0;
                    if(AI_DEBUG) ai_Debug("0i_talents", "1828", "nSpell: " + IntToString(nSpell));
                    if(nSpell)
                    {
                        if(ai_ShouldWeCastThisCureSpell(nSpell, nDamage))
                        {

                            nTalentSlot = JsonGetInt(JsonArrayGet(jTalent, 4));
                            SetMemorizedSpellReady(oCreature, nTalentClass, nLevel, nTalentSlot, FALSE);
                            ai_RemoveTalent(oCreature, jCategory, jLevel, sCategory, nLevel, nSlotIndex);
                            sSpellName = GetStringByStrRef(StringToInt(Get2DAString("spells", "Name", nSpell)));
                            if(ai_GetIsCharacter(oCreature)) ai_SendMessages(GetName(oCreature) + " has spontaneously cast " + sSpellName + " on " + GetName(oTarget) + ".", AI_COLOR_MAGENTA, oCreature);
                            if(AI_DEBUG) ai_Debug("0i_talents", "1841", GetName(oCreature) + " has spontaneously cast " + sSpellName + " on " + GetName(oTarget) + ".");
                            ActionCastSpellAtObject(nSpell, oTarget, 255, TRUE);
                            return TRUE;
                        }
                        // Save the lowest level cure spell as we might need to cast it.
                        else if(nLevel < nLevelSave)
                        {
                            jLevelSave = jLevel;
                            nLevelSave = nLevel;
                            nSlotSave = nTalentSlot;
                            nSpellSave = nSpell;
                        }
                    }
                }
                nSlotIndex++;
            }
        }
        // Set nMaxNoTalentLevel to the level if it is not set. This will hold
        // the highest level we don't have a talent for in our checks.
        else if(!nMaxNoTalentLevel)
        {
            if(AI_DEBUG) ai_Debug("0i_talents", "1820", "nMaxNoTalentLevel: " + IntToString(nMaxNoTalentLevel) +
                     " nLevel: " + IntToString(nLevel));
            nMaxNoTalentLevel = nLevel;
        }
        nLevel--;
    }
    // Did we find a spell? If we did then use it.
    if(nSpellSave)
    {
        if(AI_DEBUG) ai_Debug("0i_talents", "1872", GetName(oCreature) + " has cast the lowest level cure spell on " + GetName(oTarget) + ".");
        SetMemorizedSpellReady(oCreature, CLASS_TYPE_CLERIC, nLevelSave, nSlotSave, FALSE);
        ai_RemoveTalent(oCreature, jCategory, jLevelSave, sCategory, nLevelSave, nSlotSave);
        sSpellName = GetStringByStrRef(StringToInt(Get2DAString("spells", "Name", nSpellSave)));
        if(ai_GetIsCharacter(oCreature)) ai_SendMessages(GetName(oCreature) + " has spontaneously cast " + sSpellName + " on " + GetName(oTarget) + ".", AI_COLOR_MAGENTA, oCreature);
        ActionCastSpellAtObject(nSpellSave, oTarget, 255, TRUE);
        return TRUE;
    }
    // If we have nMaxNoTalentLevel then we didn't find a talent on these levels.
    if(nMaxNoTalentLevel) SetLocalInt(oCreature, AI_NO_TALENTS + sCategory, nMaxNoTalentLevel);
    return FALSE;
}
int ai_UseCreatureSpellTalent(object oCreature, json jLevel, json jTalent, string sCategory, int nInMelee, object oTarget = OBJECT_INVALID)
{
    // Check for polymorph, spells cannot be used while polymorphed.
    if(GetAppearanceType(oCreature) != ai_GetNormalAppearance(oCreature)) return FALSE;
    // Get the spells information so we can check if they still have it.
    int nClass = JsonGetInt(JsonArrayGet(jTalent, 2));
    int nLevel = JsonGetInt(JsonArrayGet(jTalent, 3));
    int nSlot = JsonGetInt(JsonArrayGet(jTalent, 4));
    if(ai_ArcaneSpellFailureTooHigh(oCreature, nClass, nLevel, nSlot)) return FALSE;
    if(Get2DAString("classes", "MemorizesSpells", nClass) == "1")
    {
        // Shouldn't need this anymore, we need to do a debug looking at this.
        if(GetMemorizedSpellReady(oCreature, nClass, nLevel, nSlot) < 1) return FALSE;
        if(ai_CheckSpecialTalentsandUse(oCreature, jTalent, sCategory, nInMelee, oTarget))
        {
            if(ai_CompareLastAction(oCreature, AI_LAST_ACTION_CAST_SPELL)) return -1;
            return TRUE;
        }
        return FALSE;
    }
    if(AI_DEBUG) ai_Debug("0i_talents", "1629", "Known caster Level: " + IntToString(nLevel) +
             " Uses : " + IntToString(GetSpellUsesLeft(oCreature, nClass, JsonGetInt(JsonArrayGet(jTalent, 1)))));
    if(!GetSpellUsesLeft(oCreature, nClass, JsonGetInt(JsonArrayGet(jTalent, 1)))) return -2;
    return ai_CheckSpecialTalentsandUse(oCreature, jTalent, sCategory, nInMelee, oTarget);
}
int ai_UseCreatureItemTalent(object oCreature, json jLevel, json jTalent, string sCategory, int nInMelee, object oTarget = OBJECT_INVALID)
{
    object oItem = StringToObject(JsonGetString(JsonArrayGet(jTalent, 2)));
    int nItemType = GetBaseItemType(oItem);
    // Check if the item is a potion since there are some special cases.
    if(nItemType == BASE_ITEM_POTIONS || nItemType == BASE_ITEM_ENCHANTED_POTION)
    {
        // Potions cause attack of opportunities and this could be deadly!
        // Removed for healing potions as that is one time you would use potions in melee.
        if(sCategory != AI_TALENT_HEALING)
        {
            if(AI_DEBUG) ai_Debug("0i_talents", "1925", "Using a non-healing potion nInMelee: " + IntToString(nInMelee));
            if(nInMelee > 1) return FALSE;
            // Don't use potions on allies that are not within 5'.
            if(GetDistanceBetween(oCreature, oTarget) > AI_RANGE_MELEE) return FALSE;
        }
        // For now we are allowing creatures to use "give" potions to others
        // unless the player is using a healing potion and has party healing turned off.
        else if(oCreature != oTarget && ai_GetAIMode(oCreature, AI_MODE_PARTY_HEALING_OFF)) return FALSE;
    }
    // Check for polymorph, only potions can be used while polymorphed.
    else if(GetAppearanceType(oCreature) != ai_GetNormalAppearance(oCreature)) return FALSE;
    else if(nItemType == BASE_ITEM_HEALERSKIT)
    {
        if(!GetLocalInt(GetModule(), AI_RULE_HEALERSKITS) ||
           ai_GetAIMode(oCreature, AI_MODE_PARTY_HEALING_OFF)) return FALSE;
        if(AI_DEBUG) ai_Debug("0i_talents", "1724", "Using " + GetName(oItem) + " nInMelee: " + IntToString(nInMelee) +
                 " targeting: " + GetName(oTarget));
        ActionUseItemOnObject(oItem, GetFirstItemProperty(oItem), oTarget);
        // We also must check for stack size.
        if(GetItemStackSize(oItem) == 1) JsonArrayInsertInplace(jTalent, JsonInt(-1), 4);
        return TRUE;
    }
    if(ai_CheckSpecialTalentsandUse(oCreature, jTalent, sCategory, nInMelee, oTarget)) return TRUE;
    return FALSE;
}
int ai_UseCreatureTalent(object oCreature, string sCategory, int nInMelee, int nLevel = 10, object oTarget = OBJECT_INVALID)
{
    if(AI_DEBUG) ai_Debug("0i_talents", "1673", "AI_NO_TALENTS_" + sCategory + ": " +
             IntToString(GetLocalInt(oCreature, AI_NO_TALENTS + sCategory)) +
             "  >= nLevel: " + IntToString(nLevel));
    // If we have saved this level or higher to AI_NO_TALENTS then skip.
    int nMinNoTalentLevel = GetLocalInt(oCreature, AI_NO_TALENTS + sCategory);
    if(nMinNoTalentLevel >= nLevel) return FALSE;
    // Get the saved category from oCreature.
    json jCategory = GetLocalJson(oCreature, sCategory);
    if(AI_DEBUG) ai_Debug("0i_talents", "1729", "jCategory: " + sCategory + " " + JsonDump(jCategory, 2));
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
        if(AI_DEBUG) ai_Debug("0i_talents", "1697", "nLevel: " + IntToString(nLevel) +
                 " nMaxSlotIndex: " + IntToString(nMaxSlotIndex));
        if(nMaxSlotIndex > 0)
        {
            // Set MaxNoTalentLevel to 0 if the level has a talent.
            nMaxNoTalentLevel = 0;
            // Get the talent within nLevel cycling from the first to the last.
            nSlotIndex = 0;
            while (nSlotIndex < nMaxSlotIndex)
            {
                jTalent= JsonArrayGet(jLevel, nSlotIndex);
                if(AI_DEBUG) ai_Debug("0i_talents", "1708", "nSlotIndex: " + IntToString(nSlotIndex) +
                         " jTalent Type: " + IntToString(JsonGetInt(JsonArrayGet(jTalent, 0))));
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
                    else if(nTalentUsed == -2)
                    {
                        ai_RemoveTalentLevel(oCreature, jCategory, jLevel, sCategory, nLevel);
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
                        if(AI_DEBUG) ai_Debug("0i_talents", "1742", "Checking if Item is used up: " +
                                 IntToString(JsonGetInt(JsonArrayGet(jTalent, 4))));
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
        else if(!nMaxNoTalentLevel)
        {
            if(AI_DEBUG) ai_Debug("0i_talents", "1820", "nMaxNoTalentLevel: " + IntToString(nMaxNoTalentLevel) +
                     " nLevel: " + IntToString(nLevel));
            nMaxNoTalentLevel = nLevel;
        }
        nLevel--;
    }
    // If we have nMaxNoTalentLevel then we didn't find a talent on these levels.
    if(nMaxNoTalentLevel) SetLocalInt(oCreature, AI_NO_TALENTS + sCategory, nMaxNoTalentLevel);
    return FALSE;
}
int ai_UseTalent(object oCreature, int nTalent, object oTarget)
{
    if(AI_DEBUG) ai_Debug("0i_talents", "1912", GetName(oCreature) + " is trying to use " + GetStringByStrRef(StringToInt(Get2DAString("spells", "Name", nTalent))) +
             " on " + GetName(oTarget));
    // Get the saved category from oCreature.
    string sCategory = Get2DAString("ai_spells", "Category", nTalent);
    json jCategory = GetLocalJson(oCreature, sCategory);
    if(AI_DEBUG) ai_Debug("0i_talents", "1917", "jCategory: " + sCategory + " " + JsonDump(jCategory, 2));
    if(JsonGetType(jCategory) == JSON_TYPE_NULL) return FALSE;
    json jLevel, jTalent;
    int nLevel, nClass, nSlot, nType, nSlotIndex, nMaxSlotIndex, nTalentUsed, nSpell;
    // Loop through nLevels down to nMinNoTalentLevel looking for the first talent
    // (i.e. the highest or best?).
    while(nLevel <= 9)
    {
        // Get the array of nLevel.
        jLevel = JsonArrayGet(jCategory, nLevel);
        nMaxSlotIndex = JsonGetLength(jLevel);
        if(AI_DEBUG) ai_Debug("0i_talents", "1925", "nLevel: " + IntToString(nLevel) +
                 " nMaxSlotIndex: " + IntToString(nMaxSlotIndex));
        if(nMaxSlotIndex > 0)
        {
            // Get the talent within nLevel cycling from the first to the last.
            nSlotIndex = 0;
            while (nSlotIndex < nMaxSlotIndex)
            {
                jTalent= JsonArrayGet(jLevel, nSlotIndex);
                if(AI_DEBUG) ai_Debug("0i_talents", "1936", "nSlotIndex: " + IntToString(nSlotIndex) +
                         " jTalent Type: " + IntToString(JsonGetInt(JsonArrayGet(jTalent, 0))));
                nSpell = JsonGetInt(JsonArrayGet(jTalent, 1));
                if(nSpell == nTalent)
                {
                    nType = JsonGetInt(JsonArrayGet(jTalent, 0));
                    if(nType == AI_TALENT_TYPE_SPELL || nType == AI_TALENT_TYPE_SP_ABILITY)
                    {
                        if(ai_UseTalentOnObject(oCreature, jTalent, oTarget, 0))
                        {
                            ai_RemoveTalent(oCreature, jCategory, jLevel, sCategory, nLevel, nSlotIndex);
                            return TRUE;
                        }
                    }
                    else if(nType == AI_TALENT_TYPE_ITEM)
                    {
                        // Items do not need to concentrate.
                        if(ai_UseCreatureItemTalent(oCreature, jLevel, jTalent, sCategory, 0, oTarget))
                        {
                            if(AI_DEBUG) ai_Debug("0i_talents", "1955", "Checking if Item is used up: " +
                                     IntToString(JsonGetInt(JsonArrayGet(jTalent, 4))));
                            if(JsonGetInt(JsonArrayGet(jTalent, 4)) == -1)
                            {
                                ai_RemoveTalent(oCreature, jCategory, jLevel, sCategory, nLevel, nSlotIndex);
                            }
                            return TRUE;
                        }
                    }
                }
                nSlotIndex++;
            }
        }
        nLevel++;
    }
    return FALSE;
}
int ai_UseTalentOnObject(object oCreature, json jTalent, object oTarget, int nInMelee)
{
    int nClass, nLevel, nSlot, nMetaMagic, nDomain;
    int nSpell = JsonGetInt(JsonArrayGet(jTalent, 1));
    int nType = JsonGetInt(JsonArrayGet(jTalent, 0));
    if(nType == AI_TALENT_TYPE_SPELL)
    {
        if(!ai_CastInMelee(oCreature, nSpell, nInMelee)) return FALSE;
        nClass = JsonGetInt(JsonArrayGet(jTalent, 2));
        if(Get2DAString("classes", "MemorizesSpells", nClass) == "1")
        {
            nLevel = JsonGetInt(JsonArrayGet(jTalent, 3));
            nSlot = JsonGetInt(JsonArrayGet(jTalent, 4));
            if(GetMemorizedSpellIsDomainSpell(oCreature, nClass, nLevel, nSlot) == 1) nDomain = nLevel;
            else nDomain = 0;
            nMetaMagic = GetMemorizedSpellMetaMagic(oCreature, nClass, nLevel, nSlot);
        }
        else
        {
            nMetaMagic = METAMAGIC_NONE;
            nDomain = 0;
        }
        if(ai_CheckCombatPosition(oCreature, oTarget, nInMelee, nSpell)) return TRUE;
    }
    else if(nType == AI_TALENT_TYPE_SP_ABILITY)
    {
        if(AI_DEBUG) ai_Debug("0i_talents", "1790", GetName(oCreature) + " is using a special ability!");
        nSpell = JsonGetInt(JsonArrayGet(jTalent, 1));
        nClass = 255;
        if(ai_CheckCombatPosition(oCreature, oTarget, nInMelee, nSpell)) return TRUE;
    }
    else if(nType == AI_TALENT_TYPE_ITEM)
    {
        object oItem = StringToObject(JsonGetString(JsonArrayGet(jTalent, 2)));
        int nBaseItemType = GetBaseItemType(oItem);
        if(ai_CheckCombatPosition(oCreature, oTarget, nInMelee, nSpell, nBaseItemType)) return TRUE;
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
        if(nUses == 1)
        {
            if(AI_DEBUG) ai_Debug("0i_talents", "1816", "Single Use item.");
            if(AI_DEBUG) ai_Debug("0i_talents", "1817", "Stack size: " + IntToString(GetItemStackSize(oItem)));
            // We also must check for stack size.
            if(GetItemStackSize(oItem) == 1) JsonArrayInsertInplace(jTalent, JsonInt(-1), 4);
        }
        else if(nUses > 1 && nUses < 7)
        {
            int nCharges = GetItemCharges(oItem);
            if(AI_DEBUG) ai_Debug("0i_talents", "1824", "Item charges: " + IntToString(nCharges));
            if((nUses == IP_CONST_CASTSPELL_NUMUSES_1_CHARGE_PER_USE && nCharges == 1) ||
               (nUses == IP_CONST_CASTSPELL_NUMUSES_2_CHARGES_PER_USE && nCharges < 4) ||
               (nUses == IP_CONST_CASTSPELL_NUMUSES_3_CHARGES_PER_USE && nCharges < 6) ||
               (nUses == IP_CONST_CASTSPELL_NUMUSES_4_CHARGES_PER_USE && nCharges < 8) ||
               (nUses == IP_CONST_CASTSPELL_NUMUSES_5_CHARGES_PER_USE && nCharges < 10))
            {
                if(AI_DEBUG) ai_Debug("0i_talents", "1829", "Stack size: " + IntToString(GetItemStackSize(oItem)));
                // We also must check for stack size.
                if(GetItemStackSize(oItem) == 1) JsonArrayInsertInplace(jTalent, JsonInt(-1), 4);
            }
        }
        else if(nUses > 7 && nUses < 13)
        {
            int nPerDay = GetItemPropertyUsesPerDayRemaining(oItem, ipProp);
            if(AI_DEBUG) ai_Debug("0i_talents", "1837", "Item uses: " + IntToString(nPerDay));
            if(nPerDay == 1)
            {
                if(AI_DEBUG) ai_Debug("0i_talents", "1842", "Stack size: " + IntToString(GetItemStackSize(oItem)));
                // We also must check for stack size.
                if(GetItemStackSize(oItem) == 1) JsonArrayInsertInplace(jTalent, JsonInt(-1), 4);
            }
        }
        ai_SetLastAction(oCreature, nSpell);
        ActionUseItemOnObject(oItem, ipProp, oTarget, nSubIndex);
        ActionDoCommand(ExecuteScript("0e_do_combat_rnd", oCreature));
        if(AI_DEBUG) ai_Debug("0i_talents", "1850", GetName(oCreature) + " is using " + GetName(oItem) + " on " + GetName(oTarget));
        return TRUE;
    }
    if(AI_DEBUG) ai_Debug("0i_talents", "1853", "nMetaMagic: " + IntToString(nMetaMagic) +
             " nDomain: " + IntToString(nDomain) + " nClass: " + IntToString(nClass));
    ai_SetLastAction(oCreature, nSpell);
    ActionCastSpellAtObject(nSpell, oTarget, nMetaMagic, FALSE, nDomain, 0, FALSE, nClass, FALSE);
    ActionDoCommand(ExecuteScript("0e_do_combat_rnd", oCreature));
    string sSpellName = GetStringByStrRef(StringToInt(Get2DAString("spells", "Name", nSpell)));
    if(AI_DEBUG) ai_Debug("0i_talents", "1859", GetName(oCreature) + " is casting " + sSpellName + " on " + GetName(oTarget));
    return TRUE;
}
int ai_UseTalentAtLocation(object oCreature, json jTalent, object oTarget, int nInMelee)
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
            nMetaMagic = GetMemorizedSpellMetaMagic(oCreature, nClass, nLevel, nSlot);
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
        if(AI_DEBUG) ai_Debug("0i_talents", "1888", GetName(oCreature) + " is using a special ability!");
        nSpell = JsonGetInt(JsonArrayGet(jTalent, 1));
        nClass = 255;
    }
    else if(nType == AI_TALENT_TYPE_ITEM)
    {
        object oItem = StringToObject(JsonGetString(JsonArrayGet(jTalent, 2)));
        int nBaseItemType = GetBaseItemType(oItem);
        if(ai_CheckCombatPosition(oCreature, oTarget, nInMelee, nSpell, nBaseItemType)) return TRUE;
        int nIndex;
        int nSubIndex = JsonGetInt(JsonArrayGet(jTalent, 3));;
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
            if(AI_DEBUG) ai_Debug("0i_talents", "1915", "Item charges: " + IntToString(GetItemCharges(oItem)));
            int nCharges = GetItemCharges(oItem);
            if(nUses == 6 && nCharges == 1 || nUses == 5 && nCharges < 4 ||
               nUses == 4 && nCharges < 6 || nUses == 3 && nCharges < 8 ||
               nUses == 2 && nCharges < 10) JsonArrayInsertInplace(jTalent, JsonInt(-1), 4);
        }
        else if(nUses > 7 && nUses < 13)
        {
            if(AI_DEBUG) ai_Debug("0i_talents", "1923", "Item uses: " + IntToString(GetItemPropertyUsesPerDayRemaining(oItem, ipProp)));
            int nPerDay = GetItemPropertyUsesPerDayRemaining(oItem, ipProp);
            if(nUses == 8 && nPerDay == 1 || nUses == 9 && nPerDay < 4 ||
               nUses == 10 && nPerDay < 6 || nUses == 11 && nPerDay < 8 ||
               nUses == 12 && nPerDay < 10) JsonArrayInsertInplace(jTalent, JsonInt(-1), 4);
        }
        if(ai_CheckCombatPosition(oCreature, oTarget, nInMelee, nSpell)) return TRUE;
        ai_SetLastAction(oCreature, nSpell);
        ActionUseItemAtLocation(oItem, ipProp, GetLocation(oTarget), nSubIndex);
        ActionDoCommand(ExecuteScript("0e_do_combat_rnd", oCreature));
        if(AI_DEBUG) ai_Debug("0i_talents", "1934", GetName(oCreature) + " is using " + GetName(oItem) + " at a location.");
        return TRUE;
    }
    if(ai_CheckCombatPosition(oCreature, oTarget, nInMelee, nSpell)) return TRUE;
    ai_SetLastAction(oCreature, nSpell);
    ActionCastSpellAtLocation(nSpell, GetLocation(oTarget), nMetaMagic, FALSE, 0, FALSE, nClass, FALSE, nDomain);
    ActionDoCommand(ExecuteScript("0e_do_combat_rnd", oCreature));
    string sSpellName = GetStringByStrRef(StringToInt(Get2DAString("spells", "Name", nSpell)));
    if(AI_DEBUG) ai_Debug("0i_talents", "1943", GetName(oCreature) + " is casting " + sSpellName + " at a location!");
    return TRUE;
}
int ai_CheckSpecialTalentsandUse(object oCreature, json jTalent, string sCategory, int nInMelee, object oTarget)
{
    int nSpell = JsonGetInt(JsonArrayGet(jTalent, 1));
    if(AI_DEBUG) ai_Debug("0i_talents", "1949", "nSpell: " + GetStringByStrRef(StringToInt(Get2DAString("spells", "Name", nSpell))) +
             " sCategory: " + sCategory);
    if(sCategory == AI_TALENT_DISCRIMINANT_AOE)
    {
        //ai_Debug("0i_talents", "1953", "CompareLastAction: " +
        //          IntToString(ai_CompareLastAction(oCreature, nSpell)));
        // If we used this spell talent last round then don't use it this round.
        //if(ai_CompareLastAction(oCreature, nSpell)) return FALSE;
        // Check to see if Disjunction should *not* be cast.
        if(nSpell == SPELL_MORDENKAINENS_DISJUNCTION)
        {
            // Our master does not want us using any type of dispel!
            if(ai_GetMagicMode(oCreature, AI_MAGIC_STOP_DISPEL)) return FALSE;
            float fRange;
            if(nInMelee) fRange = AI_RANGE_MELEE;
            else fRange = ai_GetOffensiveSpellSearchRange(oCreature, nSpell);
            // Get the biggest group we can.
            string sIndex = IntToString(ai_GetHighestMeleeIndexNotInAOE(oCreature));
            oTarget = GetLocalObject(oCreature, AI_ENEMY + sIndex);
            if(!ai_CreatureHasDispelableEffect(oCreature, oTarget)) return FALSE;
            // Maybe we should do an area of effect instead?
            int nEnemies = ai_GetNumOfEnemiesInRange(oTarget, 5.0);
            if(nEnemies > 2)
            {
                if(ai_UseTalentAtLocation(oCreature, jTalent, oTarget, nInMelee)) return TRUE;
            }
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
            if(ai_UseTalentAtLocation(oCreature, jTalent, oTarget, nInMelee)) return TRUE;
        }
        else if(nSpell == SPELL_UNDEATH_TO_DEATH)
        {
            float fRange = ai_GetOffensiveSpellSearchRange(oCreature, nSpell);
            int nUndead = ai_GetRacialTypeCount(oCreature, RACIAL_TYPE_UNDEAD, fRange);
            if(nUndead < 3) return FALSE;
            oTarget = ai_GetLowestCRRacialTarget(oCreature, RACIAL_TYPE_UNDEAD, fRange);
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
        //ai_Debug("0i_talents", "1991", "CompareLastAction: " +
        //          IntToString(ai_CompareLastAction(oCreature, nSpell)));
        // If we used this spell talent last round then don't use it this round.
        //if(ai_CompareLastAction(oCreature, nSpell)) return FALSE;
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
            if(ai_UseTalentAtLocation(oCreature, jTalent, oCreature, nInMelee)) return TRUE;
        }
        // Get a target for indiscriminant spells if one is not already set.
        if(oTarget == OBJECT_INVALID)
        {
            float fRange = ai_GetOffensiveSpellSearchRange(oCreature, nSpell);
            oTarget = ai_CheckForGroupedTargetNotInAOE(oCreature, fRange);
            // Check for the number of allies, if there are too many then skip.
            if(oTarget == OBJECT_INVALID) return FALSE;
            int nRoll = d6() + 1;
            if(GetAssociateType(oCreature)) nRoll = d3();
            int nAllies = ai_GetNumOfAlliesInGroup(oTarget, AI_RANGE_CLOSE);
            if(AI_DEBUG) ai_Debug("0i_talents", "2084", "Num of Allies in range: " + IntToString(nAllies)+
                     " < nRoll: " + IntToString(nRoll));
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
        //ai_Debug("0i_talents", "2045", "CompareLastAction: " +
        //          IntToString(ai_CompareLastAction(oCreature, nSpell)));
        // If we used this spell talent last round then don't use it this round.
        //if(ai_CompareLastAction(oCreature, nSpell)) return FALSE;
        // Check to see if Dispel Magic and similar spells should *not* be cast
        if(nSpell == SPELL_DISPEL_MAGIC || nSpell == SPELL_LESSER_DISPEL ||
                nSpell == SPELL_GREATER_DISPELLING)
        {
            // Our master does not want us using any type of dispel!
            if(ai_GetMagicMode(oCreature, AI_MAGIC_STOP_DISPEL)) return FALSE;
            float fRange;
            if(nInMelee) fRange = AI_RANGE_MELEE;
            else fRange = ai_GetOffensiveSpellSearchRange(oCreature, nSpell);
            // Lets get a cast as they should have more buffs.
            oTarget = ai_GetNearestClassTarget(oCreature, AI_CLASS_TYPE_CASTER, fRange);
            if(oTarget != OBJECT_INVALID)
            {
                if(!ai_CreatureHasDispelableEffect(oCreature, oTarget)) return FALSE;
                // Maybe we should do an area of effect instead?
                int nEnemies = ai_GetNumOfEnemiesInRange(oTarget, 5.0);
                if(nEnemies > 2)
                {
                    if(ai_UseTalentAtLocation(oCreature, jTalent, oTarget, nInMelee)) return TRUE;
                }
            }
        }
        // Make sure the spell will work on the target.
        else if(nSpell == SPELL_HOLD_PERSON || nSpell == SPELL_DOMINATE_PERSON ||
                nSpell == SPELL_CHARM_PERSON)
        {
            if(oTarget != OBJECT_INVALID)
            {
                int nRaceType = GetRacialType(oTarget);
                if(AI_DEBUG) ai_Debug("0i_talents", "2075", " Person Spell race: " + IntToString(nRaceType));
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
        // Scare only works on 5 hitdice or less.
        else if(nSpell == SPELL_SCARE)
        {
            if(GetHitDice(oTarget) > 5) return FALSE;
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
        //ai_Debug("0i_talents", "2139", "CompareLastAction: " +
        //          IntToString(ai_CompareLastAction(oCreature, nSpell)));
        // If we used this spell talent last round then don't use it this round.
        //if(ai_CompareLastAction(oCreature, nSpell)) return FALSE;
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
        int nHpLost = ai_GetPercHPLoss(oTarget);
        // If the target is bloody then just use the best we have!
        if(nHpLost > AI_HEALTH_BLOODY)
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
                        GetDistanceBetween(oCreature, oAlly) > 9.0f) return FALSE;
                }
            }
            // Make sure they have taken enough damage.
            int nHpDmg = GetMaxHitPoints(oTarget) - GetCurrentHitPoints(oTarget);
            if(!ai_ShouldWeCastThisCureSpell(nSpell, nHpDmg)) return FALSE;
        }
    }
    else if(sCategory == AI_TALENT_ENHANCEMENT)
    {
        if(AI_DEBUG) ai_Debug("0i_talents", "2713", "CompareLastAction: " +
                  IntToString(ai_CompareLastAction(oCreature, nSpell)));
        // If we used this spell talent last round then don't use it this round.
        if(ai_CompareLastAction(oCreature, nSpell)) return FALSE;
        if(nSpell == SPELL_INVISIBILITY || nSpell == SPELL_SANCTUARY)
        {
            // Lets not run past an enemy to cast an enhancement unless we have
            // the ability to move in combat, bad tactics!
            float fRange;
            if(ai_CanIMoveInCombat(oCreature)) fRange = AI_RANGE_PERCEPTION;
            else
            {
                fRange = GetDistanceBetween(oCreature, GetLocalObject(oCreature, AI_ENEMY_NEAREST)) - 3.0f;
                // Looks bad when your right next to an ally, but technically the enemy is closer.
                if(fRange < AI_RANGE_MELEE) fRange = AI_RANGE_MELEE;
            }
            oTarget = ai_GetAllyToHealTarget(oCreature, fRange);
            if(oTarget != OBJECT_INVALID)
            {
                int nHp = ai_GetPercHPLoss(oTarget);
                int nHpLimit = ai_GetHealersHpLimit(oCreature);
                if(nHp > nHpLimit) return FALSE;
            }
            if(nSpell == SPELL_PRAYER)
            {
                int nEnemies = ai_GetNumOfEnemiesInRange(oCreature, 10.0);
                int nAllies = ai_GetNumOfAlliesInGroup(oCreature, 10.0);
                if(nEnemies + nAllies < 5) return FALSE;
                oTarget = oCreature;
            }
        }
        // Since haste does not have an effect when it comes from items when we
        // check for item properties we set this variable so we know they have it.
        else if(nSpell == SPELL_HASTE && GetLocalInt(oCreature, sIPHasHasteVarname)) return FALSE;
        // Only reason to cast Ultravision(Darkvision) in combat is if a Darkness
        // spell is nearby.
        else if(nSpell == SPELL_DARKVISION)
        {
            int nCnt = 1, bCastSpell;
            string sAOEType;
            object oAOE = GetNearestObject(OBJECT_TYPE_AREA_OF_EFFECT, oCreature, nCnt);
            while(oAOE != OBJECT_INVALID && GetDistanceBetween(oCreature, oAOE) <= AI_RANGE_PERCEPTION)
            {
                // AOE's have the tag set to the "LABEL" in vfx_persistent.2da
                sAOEType = GetTag(oAOE);
                if(AI_DEBUG) ai_Debug("0i_talents", "2759", "Ultravision check; AOE tag: " + sAOEType);
                if(sAOEType == "VFX_PER_DARKNESS")
                {
                   if(!GetHasFeat(FEAT_DARKVISION)) bCastSpell = TRUE;
                   break;
                }
                oAOE = GetNearestObject(OBJECT_TYPE_AREA_OF_EFFECT, oCreature, ++nCnt);
            }
            if(!bCastSpell) return FALSE;
        }
        // Get a target for enhancement spells if one is not already set.
        if(oTarget == OBJECT_INVALID)
        {
            // Get talents range and target.
            float fRange = ai_GetSpellRange(nSpell);
            // Personal spell
            if(fRange == 0.1f) oTarget = oCreature;
            // Range/Touch spell
            else oTarget = ai_GetAllyBuffTarget(oCreature, nSpell, fRange);
        }
        if(AI_DEBUG) ai_Debug("0i_talents", "2260", " oTarget: " + GetName(oTarget) +
                 " HasSpellEffect: " + IntToString(GetHasSpellEffect(nSpell, oTarget)));
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
        if(AI_DEBUG) ai_Debug("0i_talents", "2281", "CompareLastAction: " +
                  IntToString(ai_CompareLastAction(oCreature, nSpell)));
        // If we used this spell talent last round then don't use it this round.
        if(ai_CompareLastAction(oCreature, nSpell)) return FALSE;
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
        else if(nSpell == SPELL_MAGIC_FANG)
        {
            oTarget = GetAssociate(ASSOCIATE_TYPE_ANIMALCOMPANION, oCreature);
            if(oTarget == OBJECT_INVALID) return FALSE;
        }
        // Lets see if we should cast resistances in our current situation,
        // lets check for enemy casters that may have energy damaging spells, or energy weapons.
        else if(nSpell == SPELL_ENDURE_ELEMENTS || nSpell == SPELL_PROTECTION_FROM_ELEMENTS ||
                nSpell == SPELL_RESIST_ELEMENTS || nSpell == SPELL_ENERGY_BUFFER)
        {
            int bCastSpell;
            object oEnemy = ai_GetEnemyAttackingMe(oCreature);
            if(oEnemy != OBJECT_INVALID)
            {
                object oWeapon = GetItemInSlot(INVENTORY_SLOT_RIGHTHAND, oEnemy);
                if(oWeapon == OBJECT_INVALID) oWeapon = GetItemInSlot(INVENTORY_SLOT_CWEAPON_R, oEnemy);
                if(oWeapon == OBJECT_INVALID) oWeapon = GetItemInSlot(INVENTORY_SLOT_CWEAPON_B, oEnemy);
                if(AI_DEBUG) ai_Debug("0i_talents", "2812", GetName(oEnemy) + " is using weapon: " + GetName(oWeapon));
                if(oWeapon != OBJECT_INVALID)
                {
                    itemproperty nProperty = GetFirstItemProperty(oWeapon);
                    while(GetIsItemPropertyValid(nProperty))
                    {
                        if(GetItemPropertyType(nProperty) == ITEM_PROPERTY_DAMAGE_BONUS)
                        {
                            int nSubType = GetItemPropertySubType(nProperty);
                            if(AI_DEBUG) ai_Debug("0i_talents", "2821", GetName(oWeapon) + " has PropertySubType: " +
                                     IntToString(nSubType) + " If equals [6,7,9,10,13] don't cast!");
                            if(nSubType == 6 || nSubType == 7 || nSubType == 9 ||
                               nSubType == 10 || nSubType == 13)
                            {
                                bCastSpell = TRUE;
                                break;
                            }
                        }
                        nProperty = GetNextItemProperty(oWeapon);
                    }
                }
            }
            if(ai_GetNearestClassTarget(oCreature, AI_CLASS_TYPE_CASTER) != OBJECT_INVALID) bCastSpell = TRUE;
            if(!bCastSpell) return FALSE;
        }
        // Get a target for protection spells if one is not already set.
        if(oTarget == OBJECT_INVALID)
        {
            // Get talents range and target.
            float fRange = ai_GetSpellRange(nSpell);
            // Personal spell
            if(fRange == 0.1f) oTarget = oCreature;
            // Range/Touch spell
            else oTarget = ai_GetAllyBuffTarget(oCreature, nSpell, fRange);
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
            /* Removed for now, summons creature in location that enemy was... looks bad.
            float fRange;
            if(nInMelee) fRange = AI_RANGE_MELEE;
            else fRange = ai_GetOffensiveSpellSearchRange(oCreature, nSpell);
            // Select lowest enemy combat target for summons.
            oTarget = ai_GetLowestCRTarget(oCreature, fRange);
            if(oTarget == OBJECT_INVALID) oTarget = oCreature;
            */
            oTarget = oCreature;
            if(ai_UseTalentAtLocation(oCreature, jTalent, oTarget, nInMelee))
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
