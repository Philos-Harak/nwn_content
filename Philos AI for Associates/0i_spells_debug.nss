/*////////////////////////////////////////////////////////////////////////////////////////////////////
 Script Name: 0i_spells
 Programmer: Philos
//////////////////////////////////////////////////////////////////////////////////////////////////////
 Include scripts for base spells.

 Buffing Groups are as follows:
 1 - Elemental Damage Resistance
 2 - AC Natural
 3 - AC Deflection
 4 - AC bonus
 5 - Invisibility/Sanctuary
 6 - Regeneration
 7 - Globes of Invulnerablility
 8 - Damage Reduction
 9 - Mantles
*/////////////////////////////////////////////////////////////////////////////////////////////////////
#include "0i_messages"
#include "0i_states_cond_d"
#include "0i_items"
#include "X0_I0_POSITION"
struct stSpell
{
    object oPC;
    object oCaster;
    object oTarget;
    int nBuffType;
    int nTarget;
    int nPosition;
    int nClass;
    int nLevel;
    int nMaxSlots;
    int nSlot;
};
// Returns TRUE if oCreature knows nSpell.
int ai_GetKnownSpell(object oCreature, int nSpell);
// Returns TRUE if oCreature is immune to petrification.
int ai_IsImmuneToPetrification(object oCaster, object oCreature);
// Returns TRUE if oCreature has an effect from a mind affecting spell.
int ai_DoIHaveAMindAffectingSpellOnMe(object oCreature);
// Returns TRUE if nSpell is a cure spell.
int ai_IsCureSpell(int nSpell);
// Returns TRUE if nSpell is an inflict spell.
int ai_IsInflictSpell(int nSpell);
// Returns TRUE if nSpell is an area of effect spell.
int ai_IsAreaOfEffectSpell(int nSpell);
// Returns TRUE if nSpell is ready to cast.
// nSpell is the spell to find.
// nClass is the class that the spell was readied by.
// nLevel the level of the spell.
// nMetamagic is if it has metamagic on it.
// nDomain is if it is a domain spell.
int ai_GetSpellReady(object oCaster, int nSpell, int nClass, int nLevel, int nMetamagic, int nDomain);
// Returns TRUE if oCreature is immune to nSpells effects.
int ai_CreatureImmuneToEffect(object oCaster, object oCreature, int nSpell);
// Returns the ranged of nSpell from the spells.2da(Column "Range").
// S = 8.0f, M = 20.0f, L = 40.0f, T = 5.0f, else = 0.1f;
float ai_GetSpellRange(int nSpell);
// Returns TRUE if oTarget has a spell that we would want to dispel.
// Checks for harmful effects as well as buffing effects.
int ai_CreatureHasDispelableEffect(object oCaster, object oCreature);
// Remove nEffectType of Type specified on oCreature;
// nEffectType uses the constants EFFECT_TYPE_*
void ai_RemoveASpecificEffect(object oCreature, int nEffectType);
// Returns TRUE if oCreature has nEffectType.
// nEffectType uses the constants EFFECT_TYPE_*
int ai_GetHasEffectType(object oCreature, int nEffectType);
// Checks oCreature for special abilities have a long duration.
void ai_CheckCreatureSpecialAbilities(object oCreature);
// Checks oCreature for the silence effect and if the spell only has a somatic component.
int ai_IsNotSilenced(object oCreature, int nSpell);
// Returns TRUE if oCaster casts nSpell on oTarget.
// This will only cast the spell if oTarget DOES NOT already have the spell
// effect, and the caster has the spell ready.
int ai_TryToCastSpell(object oCaster, int nSpell, object oTarget);
// In "Buff_Target" column the value of 0 in the "ai_spells.2da" references the Caster.
// In "Buff_Target" column this is value 1-6(STR, DEX, CON, INT, WIS, CHA) in the "ai_spells.2da".
object ai_BuffHighestAbilityScoreTarget(object oCaster, int nSpell, int nAbilityScore, string sBuffGroup, float fRange, string sTargetType = "AI_ALLY_TARGET_");
// In "Buff_Target" column this is value 7 in the "ai_spells.2da".
object ai_BuffLowestACTarget(object oCaster, int nSpell, string sBuffGroup, float fRange, string sTargetType = "AI_ALLY_TARGET_");
// In "Buff_Target" column this is value 8 in the "ai_spells.2da".
object ai_BuffLowestACWithOutACBonus(object oCaster, int nSpell, string sBuffGroup, float fRange, string sTargetType = "AI_ALLY_TARGET_");
// In "Buff_Target" column this is value 9 in the "ai_spells.2da".
object ai_BuffHighestAttackTarget(object oCaster, int nSpell, string sBuffGroup, float fRange, string sTargetType = "AI_ALLY_TARGET_");
// In "Buff_Target" column this is value 10 in the "ai_spells.2da".
object ai_BuffMostWoundedTarget(object oCaster, int nSpell, string sBuffGroup, float fRange, string sTargetType = "AI_ALLY_TARGET_");
// In "Buff_Target" column this is value 11 in the "ai_spells.2da".
object ai_BuffLowestFortitudeSaveTarget(object oCaster, int nSpell, string sBuffGroup, float fRange, string sTargetType = "AI_ALLY_TARGET_");
// In "Buff_Target" column this is value 12 in the "ai_spells.2da".
object ai_BuffLowestReflexSaveTarget(object oCaster, int nSpell, string sBuffGroup, float fRange, string sTargetType = "AI_ALLY_TARGET_");
// In "Buff_Target" column this is value 13 in the "ai_spells.2da".
object ai_BuffLowestWillSaveTarget(object oCaster, int nSpell, string sBuffGroup, float fRange, string sTargetType = "AI_ALLY_TARGET_");
// In "Buff_Target" column this is value 14 in the "ai_spells.2da".
object ai_BuffLowestSaveTarget(object oCaster, int nSpell, string sBuffGroup, float fRange, string sTargetType = "AI_ALLY_TARGET_");
// In "Buff_Target" column this is value 15 in the "ai_spells.2da".
object ai_BuffItemTarget(object oCaster, int nSpell, string sBuffGroup, float fRange, string sTargetType = "AI_ALLY_TARGET_");
// Returns a target for nSpell cast by oCaster based on ai_spells.2da file.
object ai_GetBuffTarget(object oCaster, int nSpell);
// Returns TRUE if the spell is cast.
void ai_CastMemorizedSpell(object oCaster, int nClass, int nSpellLevel, int nSpellSlot, object oTarget, object oPC = OBJECT_INVALID);
// Returns TRUE if the spell is cast.
void ai_CastKnownSpell(object oCaster, int nClass, int nSpell, object oTarget, object oPC = OBJECT_INVALID);
// Returns true if the spell is cast.
// Checks if they have the spell and will cast it if possible.
int ai_CheckAndCastSpell(object oCaster, int nSpell, int nSpellGroup, float fDelay, object oTarget, object oPC = OBJECT_INVALID);
// Setup monsters for oCaster to buff in ai_CastSpells.
void ai_SetupMonsterBuffTargets(object oCaster);
// Setup the targets for an NPC to buff one of the PC's members or the whole group.
void ai_SetupAllyTargets(object oCaster, object oPC);
// Clears the casters buff targets.
void ai_ClearBuffTargets(object oCaster);
// Cycles through a casters spells casting all buffs via actions.
void ai_ActionCastMemorizedBuff(struct stSpell stSpell);
// Cycles through a casters spells casting all buffs via actions.
void ai_ActionCastKnownBuff(struct stSpell stSpell);
// Checks oCaster for buffing spells and casts them based on nTarget;
// These are cast as actions and will happen fast, but are still actions.
// nTarget is 0-9 where 0 is all targets, 1 is oPC, 2 is the caster
// 3-6 is oPC's henchman, 7 Familiar, 8 is Animal Companion, and 9 is Summons.
// nBuffType is the duration 1 - all, 2 - short, 3 - long.
void ai_CastBuffs(object oCaster, int nBuffType, int nTarget, object oPC);
// Attempts to cast spontaneous cure spells on oTarget.
void ai_CastSpontaneousCure(struct stSpell stSpell, int bInCombat);
// Cycles through a casters spells casting any healing spells on nTargets.
void ai_ActionCastMemorizedHealing(struct stSpell stSpell, int nIndex, int bInCombat);
// Cycles through a casters spells casting any healing spells on nTargets.
void ai_ActionCastKnownHealing(struct stSpell stSpell, int nIndex, int bInCombat);
// Checks oCaster for healing spells to cast based on nTarget.
// These are cast as actions and will happen fast, but are still actions.
// nTarget is 0-9 where 0 is all targets, 1 is oPC, 2-5 is oPC's henchman,
// 6 is the caster, 7 Familiar, 8 is Animal Companion, and 9 is Summons.
// bInCombat is used to define if the healing is happening in or out of combat.
void ai_CastHealing(object oCaster, int nTarget, object oPC, int bInCombat);
// Returns TRUE if oCreature has an effect that will break their concentration.
int ai_ConcentrationCondition(object oCreature);
// Check to see if a spell's concentration has been broken, works for summons as well.
void ai_SpellConcentrationCheck(object oCaster);
// Returns TRUE if oCreature can safely cast nSpell defensively or has a good
// chance of casting while in melee.
int ai_CastInMelee(object oCreature, int nSpell, int nInMelee);
// Returns a float range for the caster to search for a target of an offensive spell.
float ai_GetOffensiveSpellSearchRange(object oCreature, int nSpell);
// Returns TRUE if nSpell is a cure spell and will not over heal for nHpLost.
int ai_ShouldWeCastThisCureSpell(int nSpell, int nHpLost);

int ai_GetKnownSpell(object oCreature, int nSpell)
{
    int ic, nLevel, nIndex, nSpellCount, nClass;
    for(ic = 1; ic < 4; ic++)
    {
        nClass = GetClassByPosition(ic, oCreature);
        if(nClass == CLASS_TYPE_INVALID) return FALSE;
        for(nLevel = 1; nLevel < 10; nLevel++)
        {
            nSpellCount = GetKnownSpellCount(oCreature, nClass, nLevel);
            for(nIndex = 0; nIndex < nSpellCount; nIndex ++)
            {
                if(nSpell == GetKnownSpellId(oCreature, nClass, nLevel, nIndex)) return TRUE;
            }
        }
    }
    return FALSE;
}
int ai_IsImmuneToPetrification(object oCaster, object oCreature)
{
    int nAppearance = GetAppearanceType(oCreature);
    switch(nAppearance)
    {
        case APPEARANCE_TYPE_BASILISK:
        case APPEARANCE_TYPE_COCKATRICE:
        case APPEARANCE_TYPE_MEDUSA:
        case APPEARANCE_TYPE_ALLIP:
        case APPEARANCE_TYPE_ELEMENTAL_AIR:
        case APPEARANCE_TYPE_ELEMENTAL_AIR_ELDER:
        case APPEARANCE_TYPE_ELEMENTAL_EARTH:
        case APPEARANCE_TYPE_ELEMENTAL_EARTH_ELDER:
        case APPEARANCE_TYPE_ELEMENTAL_FIRE:
        case APPEARANCE_TYPE_ELEMENTAL_FIRE_ELDER:
        case APPEARANCE_TYPE_ELEMENTAL_WATER:
        case APPEARANCE_TYPE_ELEMENTAL_WATER_ELDER:
        case APPEARANCE_TYPE_GOLEM_STONE:
        case APPEARANCE_TYPE_GOLEM_IRON:
        case APPEARANCE_TYPE_GOLEM_CLAY:
        case APPEARANCE_TYPE_GOLEM_BONE:
        case APPEARANCE_TYPE_GORGON:
        case APPEARANCE_TYPE_HEURODIS_LICH:
        case APPEARANCE_TYPE_LANTERN_ARCHON:
        case APPEARANCE_TYPE_SHADOW:
        case APPEARANCE_TYPE_SHADOW_FIEND:
        case APPEARANCE_TYPE_SHIELD_GUARDIAN:
        case APPEARANCE_TYPE_SKELETAL_DEVOURER:
        case APPEARANCE_TYPE_SKELETON_CHIEFTAIN:
        case APPEARANCE_TYPE_SKELETON_COMMON:
        case APPEARANCE_TYPE_SKELETON_MAGE:
        case APPEARANCE_TYPE_SKELETON_PRIEST:
        case APPEARANCE_TYPE_SKELETON_WARRIOR:
        case APPEARANCE_TYPE_SKELETON_WARRIOR_1:
        case APPEARANCE_TYPE_SPECTRE:
        case APPEARANCE_TYPE_WILL_O_WISP:
        case APPEARANCE_TYPE_WRAITH:
        case APPEARANCE_TYPE_BAT_HORROR:
        case 405: // Dracolich:
        case 415: // Alhoon
        case 418: // shadow dragon
        case 420: // mithral golem
        case 421: // admantium golem
        case 430: // Demi Lich
        case 469: // animated chest
        case 474: // golems
        case 475: // golems
            return TRUE;
    }
    // Petrification immunity can also be granted as an item property.
    if(ResistSpell(oCaster, oCreature) == 2 ) return TRUE;
    // Prevent people from petrifying DM, resulting in GUI even when effect is not successful.
    if(!GetPlotFlag(oCreature) && GetIsDM(oCreature)) return TRUE;
    return FALSE;
}
int ai_DoIHaveAMindAffectingSpellOnMe(object oCreature)
{
    if(GetHasSpellEffect(SPELL_SLEEP, oCreature) ||
         GetHasSpellEffect(SPELL_DAZE, oCreature) ||
         GetHasSpellEffect(SPELL_HOLD_ANIMAL, oCreature) ||
         GetHasSpellEffect(SPELL_HOLD_MONSTER, oCreature) ||
         GetHasSpellEffect(SPELL_HOLD_PERSON, oCreature) ||
         GetHasSpellEffect(SPELL_CHARM_MONSTER, oCreature) ||
         GetHasSpellEffect(SPELL_CHARM_PERSON, oCreature) ||
         GetHasSpellEffect(SPELL_CHARM_PERSON_OR_ANIMAL, oCreature) ||
         GetHasSpellEffect(SPELL_MASS_CHARM, oCreature) ||
         GetHasSpellEffect(SPELL_DOMINATE_ANIMAL, oCreature) ||
         GetHasSpellEffect(SPELL_DOMINATE_MONSTER, oCreature) ||
         GetHasSpellEffect(SPELL_DOMINATE_PERSON, oCreature) ||
         GetHasSpellEffect(SPELL_CONFUSION, oCreature)  ||
         GetHasSpellEffect(SPELL_MIND_FOG, oCreature)   ||
         GetHasSpellEffect(SPELL_CLOUD_OF_BEWILDERMENT, oCreature)   ||
         GetHasSpellEffect(SPELLABILITY_BOLT_DOMINATE,oCreature) ||
         GetHasSpellEffect(SPELLABILITY_BOLT_CHARM,oCreature) ||
         GetHasSpellEffect(SPELLABILITY_BOLT_CONFUSE,oCreature) ||
         GetHasSpellEffect(SPELLABILITY_BOLT_DAZE,oCreature)) return TRUE;
    return FALSE;
}
int ai_IsCureSpell(int nSpell)
{
    switch(nSpell)
    {
        case SPELL_CURE_CRITICAL_WOUNDS:
        case SPELL_CURE_LIGHT_WOUNDS:
        case SPELL_CURE_MINOR_WOUNDS:
        case SPELL_CURE_MODERATE_WOUNDS:
        case SPELL_CURE_SERIOUS_WOUNDS:
        case SPELL_HEAL: return TRUE; break;
   }
   return FALSE;
}
int ai_IsInflictSpell(int nSpell)
{
    switch(nSpell)
    {
        case SPELL_INFLICT_CRITICAL_WOUNDS:
        case SPELL_INFLICT_LIGHT_WOUNDS:
        case SPELL_INFLICT_MINOR_WOUNDS:
        case SPELL_INFLICT_MODERATE_WOUNDS:
        case SPELL_INFLICT_SERIOUS_WOUNDS:
        case SPELL_HARM: return TRUE; break;
   }
   return FALSE;
}
int ai_IsAreaOfEffectSpell(int nSpell)
{
    switch(nSpell)
    {
        case SPELL_ACID_FOG          :
        case SPELL_MIND_FOG          :
        case SPELL_STORM_OF_VENGEANCE:
        case SPELL_WEB               :
        case SPELL_GREASE            :
        case SPELL_CREEPING_DOOM     :
//      case SPELL_DARKNESS          :
        case SPELL_SILENCE           :
        case SPELL_BLADE_BARRIER     :
        case SPELL_CLOUDKILL         :
        case SPELL_STINKING_CLOUD    :
        case SPELL_WALL_OF_FIRE      :
        case SPELL_INCENDIARY_CLOUD  :
        case SPELL_ENTANGLE          :
        case SPELL_EVARDS_BLACK_TENTACLES:
        case SPELL_CLOUD_OF_BEWILDERMENT :
        case SPELL_STONEHOLD             :
        case SPELL_VINE_MINE             :
        case SPELL_SPIKE_GROWTH          :
        case SPELL_DIRGE                 :
        case 530                         : // vine mine
        case 531                         : // vine mine
        case 532                         : // vine mine
        case 961                         : // Prismatic Sphere
            return TRUE;
    }
    return FALSE;
}
int ai_GetSpellReady(object oCaster, int nSpell, int nClass, int nLevel, int nMetamagic, int nDomain)
{
    int nIndex, nMaxIndex, nMSpell, nMmSpell, nDSpell;
    if(StringToInt(Get2DAString("classes", "MemorizesSpells", nClass)))
    {
        nMaxIndex = GetMemorizedSpellCountByLevel(oCaster, nClass, nLevel);
        while(nIndex < nMaxIndex)
        {
            nMSpell = GetMemorizedSpellId(oCaster, nClass, nLevel, nIndex);
            if(nSpell == nMSpell)
            {
                nMmSpell = GetMemorizedSpellMetaMagic(oCaster, nClass, nLevel, nIndex);
                nDSpell = GetMemorizedSpellIsDomainSpell(oCaster, nClass, nLevel, nIndex);
                if(nMmSpell == nMetamagic &&
                 ((nDomain > 0 && nDSpell == TRUE) || nDomain == 0 && nDSpell == FALSE))
                {
                    return GetMemorizedSpellReady(oCaster, nClass, nLevel, nIndex);
                }
            }
            nIndex ++;
        }
        return -1;
    }
    else
    {
        if(GetKnownSpellCount(oCaster, nClass, nLevel) > 0) return TRUE;
    }
    return FALSE;
}
int ai_CreatureImmuneToEffect(object oCaster, object oCreature, int nSpell)
{
    string sIType = Get2DAString("ai_spells", "ImmunityType", nSpell);
    if(sIType != "")
    {
        ai_Debug("0i_spells", "290", "Checking spell immunity type(" + sIType + ").");
        if(sIType == "Death" && GetIsImmune(oCreature, IMMUNITY_TYPE_DEATH)) return TRUE;
        if(sIType == "Level_Drain" && GetIsImmune(oCreature, IMMUNITY_TYPE_NEGATIVE_LEVEL)) return TRUE;
        if(sIType == "Ability_Drain" && GetIsImmune(oCreature, IMMUNITY_TYPE_ABILITY_DECREASE)) return TRUE;
        if(sIType == "Poison" && GetIsImmune(oCreature, IMMUNITY_TYPE_POISON)) return TRUE;
        if(sIType == "Disease" && GetIsImmune(oCreature, IMMUNITY_TYPE_DISEASE)) return TRUE;
        if(sIType == "Fear" && GetIsImmune(oCreature, IMMUNITY_TYPE_FEAR)) return TRUE;
        if(sIType == "Curse" && GetIsImmune(oCreature, IMMUNITY_TYPE_CURSED)) return TRUE;
        if(sIType == "Mind_Affecting" && GetIsImmune(oCreature, IMMUNITY_TYPE_MIND_SPELLS)) return TRUE;
        if(sIType == "Petrification" && ai_IsImmuneToPetrification(oCaster, oCreature)) return TRUE;
        if(sIType == "Sleep" &&
          (GetIsImmune(oCreature, IMMUNITY_TYPE_SLEEP) ||
           GetIsImmune(oCreature, IMMUNITY_TYPE_MIND_SPELLS))) return TRUE;
        if(sIType == "Paralysis" &&
          (GetIsImmune(oCreature, IMMUNITY_TYPE_PARALYSIS) ||
           GetIsImmune(oCreature, IMMUNITY_TYPE_MIND_SPELLS))) return TRUE;
        if(sIType == "Domination" &&
          (GetIsImmune(oCreature, IMMUNITY_TYPE_DOMINATE) ||
           GetIsImmune(oCreature, IMMUNITY_TYPE_MIND_SPELLS))) return TRUE;
        if(sIType == "Confusion" &&
          (GetIsImmune(oCreature, IMMUNITY_TYPE_CONFUSED) ||
           GetIsImmune(oCreature, IMMUNITY_TYPE_MIND_SPELLS))) return TRUE;
        if(sIType == "Blindness" &&
          (GetIsImmune(oCreature, IMMUNITY_TYPE_BLINDNESS) ||
           GetIsImmune(oCreature, IMMUNITY_TYPE_MIND_SPELLS))) return TRUE;
        if(sIType == "Dazed" &&
          (GetIsImmune(oCreature, IMMUNITY_TYPE_DAZED) ||
           GetIsImmune(oCreature, IMMUNITY_TYPE_MIND_SPELLS))) return TRUE;
        if(sIType == "Charm" &&
          (GetIsImmune(oCreature, IMMUNITY_TYPE_CHARM) ||
           GetIsImmune(oCreature, IMMUNITY_TYPE_MIND_SPELLS))) return TRUE;
        // Check for damage immunities.
        // Negative damage does not work on undead!
        if(sIType == "Negative" && GetRacialType(oCreature) == RACIAL_TYPE_UNDEAD)
        {
            ai_Debug("0i_spell", "325", "Undead are immune to Negative energy!");
            return TRUE;
        }
        // Elemental damage resistances should be checked.
        if(sIType == "Acid" || sIType == "Cold"  || sIType == "Fire" ||
            sIType == "Electricty" || sIType == "Sonic")
        {
            if(ai_GetHasEffectType(oCreature, EFFECT_TYPE_DAMAGE_RESISTANCE))
            {
                ai_Debug("0i_spell", "334", "Target is resistant to my energy spell!");
                return TRUE;
            }
            // Maybe add checks for item damage resistance?
        }
    }
    int nLevel = StringToInt(Get2DAString("ai_spells", "Innate", nSpell));
    // Globe spells should be checked...
    if((GetHasSpellEffect(SPELL_MINOR_GLOBE_OF_INVULNERABILITY, oCreature) ||
        GetHasSpellEffect(SPELL_GREATER_SHADOW_CONJURATION_MINOR_GLOBE, oCreature)) &&
        nLevel < 4 && d100() < 75) return TRUE;
    if(GetHasSpellEffect(SPELL_GLOBE_OF_INVULNERABILITY, oCreature) &&
        nLevel < 5 && d100() < 75) return TRUE;
    ai_Debug("0i_spell", "347", GetName(oCreature) + " is not immune to the spell.");
    return FALSE;
}
float ai_GetSpellRange(int nSpell)
{
    string sRange = Get2DAString("ai_spells", "Range", nSpell);
    if(sRange == "S") return AI_SHORT_DISTANCE;
    else if(sRange == "M") return AI_MEDIUM_DISTANCE;
    else if(sRange == "L") return AI_LONG_DISTANCE;
    else if(sRange == "T") return AI_RANGE_MELEE;
    return 0.1;
}
int ai_CreatureHasDispelableEffect(object oCaster, object oCreature)
{
    int bSpell, nDispelChance;
    // Cycle through the targets effects.
    effect eEffect = GetFirstEffect(oCreature);
    while(GetIsEffectValid(eEffect))
    {
        int nEffectID = GetEffectSpellId(eEffect);
        // If the effects originated from me(i.e., I cast
        // a disabling effect on you. Then I will not chance using dispel.
        if(GetEffectCreator(eEffect) == oCaster) return FALSE;
        // -1 is not a spell.
        else if(nEffectID > -1)
        {
            // We check if the spell is Hostile(-1) or Helpful(+1).
            if(Get2DAString("ai_spells", "HostileSetting", nEffectID) == "1") nDispelChance--;
            else nDispelChance++;
        }
        eEffect = GetNextEffect(oCreature);
    }
    // if the target has more Helpful spells than harmful spells effecting them
    // then use dispel!
    ai_Debug("0i_spells", "381", "nDispelChance: " + IntToString(nDispelChance));
    return (nDispelChance > 0);
}
void ai_RemoveASpecificEffect(object oCreature, int nEffectType)
{
   effect eEffect = GetFirstEffect(oCreature);
   //Search for the effect.
   while(GetIsEffectValid(eEffect))
   {
      if(GetEffectType(eEffect) == nEffectType)
      {
         //Remove effect.
         RemoveEffect(oCreature, eEffect);
         eEffect = GetFirstEffect(oCreature);
      }
      else  eEffect = GetNextEffect(oCreature);
   }
}
int ai_GetHasEffectType(object oCreature, int nEffectType)
{
    effect eEffect = GetFirstEffect(oCreature);
    while(GetIsEffectValid(eEffect))
    {
        if(GetEffectType(eEffect, TRUE) == nEffectType) return TRUE;
        eEffect = GetNextEffect(oCreature);
    }
    return FALSE;
}
void ai_CheckCreatureSpecialAbilities(object oCreature)
{
    int nMaxSpecialAbilities = GetSpellAbilityCount(oCreature);
    if(nMaxSpecialAbilities)
    {
        int nIndex, bCanCast;
        // Struct is id, ready, level.
        int nSpell;
        while(nIndex < nMaxSpecialAbilities)
        {
            nSpell = GetSpellAbilitySpell(oCreature, nIndex);
            if(GetSpellAbilityReady(oCreature, nSpell))
            {
                bCanCast = FALSE;
                if(GetSpellAbilityCasterLevel(oCreature, nIndex) > 4)
                {
                    // 1 Min/Lvl spell that is too low of level so it must be cast at 5th lvl or greater.
                    if(nSpell == SPELL_FLAME_WEAPON) bCanCast = TRUE;
                    else if(nSpell == SPELL_BLESS) bCanCast = TRUE;
                    else if(nSpell == SPELL_AID) bCanCast = TRUE;
                    else if(nSpell == SPELL_DEATH_WARD) bCanCast = TRUE;
                }
                if(nSpell == SPELL_ENERGY_BUFFER) bCanCast = TRUE;
                else if(nSpell == SPELL_PROTECTION_FROM_ELEMENTS) bCanCast = TRUE;
                else if(nSpell == SPELL_RESIST_ELEMENTS) bCanCast = TRUE;
                else if(nSpell == SPELL_ENDURE_ELEMENTS) bCanCast = TRUE;
                else if(nSpell == SPELL_MAGE_ARMOR) bCanCast = TRUE;
                else if(nSpell == SPELL_MAGIC_VESTMENT) bCanCast = TRUE;
                else if(nSpell == SPELL_GREATER_MAGIC_WEAPON) bCanCast = TRUE;
                else if(nSpell == SPELL_MAGIC_WEAPON) bCanCast = TRUE;
                else if(nSpell == SPELL_SUMMON_CREATURE_IX) bCanCast = TRUE;
                else if(nSpell == SPELL_SUMMON_CREATURE_VIII) bCanCast = TRUE;
                else if(nSpell == SPELL_SUMMON_CREATURE_VII) bCanCast = TRUE;
                else if(nSpell == SPELL_SUMMON_CREATURE_VI) bCanCast = TRUE;
                else if(nSpell == SPELL_SUMMON_CREATURE_V) bCanCast = TRUE;
                else if(nSpell == SPELL_SUMMON_CREATURE_IV) bCanCast = TRUE;
                else if(nSpell == SPELL_SUMMON_CREATURE_III) bCanCast = TRUE;
                else if(nSpell == SPELL_SUMMON_CREATURE_II) bCanCast = TRUE;
                else if(nSpell == SPELL_SUMMON_CREATURE_I) bCanCast = TRUE;
                else if(nSpell == SPELL_BARKSKIN) bCanCast = TRUE;
                else if(nSpell == SPELL_SHIELD) bCanCast = TRUE;
                else if(nSpell == SPELL_ENTROPIC_SHIELD) bCanCast = TRUE;
                else if(nSpell == SPELL_SHIELD_OF_FAITH) bCanCast = TRUE;
                else if(nSpell == SPELL_REMOVE_FEAR) bCanCast = TRUE;
                else if(nSpell == SPELL_IRONGUTS) bCanCast = TRUE;
                else if(nSpell == SPELL_PREMONITION) bCanCast = TRUE;
                else if(nSpell == SPELL_GREATER_STONESKIN) bCanCast = TRUE;
                else if(nSpell == SPELL_GHOSTLY_VISAGE) bCanCast = TRUE;
                else if(nSpell == SPELL_IMPROVED_INVISIBILITY) bCanCast = TRUE;
                else if(nSpell == SPELL_INVISIBILITY_SPHERE) bCanCast = TRUE;
                else if(nSpell == SPELL_INVISIBILITY) bCanCast = TRUE;
                else if(nSpell == SPELL_GREATER_BULLS_STRENGTH) bCanCast = TRUE;
                else if(nSpell == SPELL_BULLS_STRENGTH) bCanCast = TRUE;
                else if(nSpell == SPELL_GREATER_CATS_GRACE) bCanCast = TRUE;
                else if(nSpell == SPELL_CATS_GRACE) bCanCast = TRUE;
                else if(nSpell == SPELL_GREATER_EAGLE_SPLENDOR) bCanCast = TRUE;
                else if(nSpell == SPELL_EAGLE_SPLEDOR) bCanCast = TRUE;
                else if(nSpell == SPELL_GREATER_ENDURANCE) bCanCast = TRUE;
                else if(nSpell == SPELL_ENDURANCE) bCanCast = TRUE;
                else if(nSpell == SPELL_GREATER_FOXS_CUNNING) bCanCast = TRUE;
                else if(nSpell == SPELL_FOXS_CUNNING) bCanCast = TRUE;
                else if(nSpell == SPELL_GREATER_OWLS_WISDOM) bCanCast = TRUE;
                else if(nSpell == SPELL_OWLS_WISDOM) bCanCast = TRUE;
                else if(nSpell == SPELL_KEEN_EDGE) bCanCast = TRUE;
                else if(nSpell == SPELL_ANIMATE_DEAD) bCanCast = TRUE;
                else if(nSpell == SPELL_INVISIBILITY_PURGE) bCanCast = TRUE;
                else if(nSpell == SPELL_CLAIRAUDIENCE_AND_CLAIRVOYANCE) bCanCast = TRUE;
                else if(nSpell == SPELL_DARKFIRE) bCanCast = TRUE;
                else if(nSpell == SPELL_NEGATIVE_ENERGY_PROTECTION) bCanCast = TRUE;
                else if(nSpell == SPELL_MAGIC_CIRCLE_AGAINST_GOOD) bCanCast = TRUE;
                else if(nSpell == SPELL_FREEDOM_OF_MOVEMENT) bCanCast = TRUE;
                else if(nSpell == SPELL_NEUTRALIZE_POISON) bCanCast = TRUE;
                else if(nSpell == SPELL_MIND_BLANK) bCanCast = TRUE;
                else if(nSpell == SPELL_LESSER_MIND_BLANK) bCanCast = TRUE;
                else if(nSpell == SPELL_SPELL_RESISTANCE) bCanCast = TRUE;
                else if(nSpell == SPELL_PROTECTION_FROM_GOOD) bCanCast = TRUE;
                else if(nSpell == SPELL_CREATE_UNDEAD) bCanCast = TRUE;
                else if(nSpell == SPELL_PLANAR_ALLY) bCanCast = TRUE;
                else if(nSpell == SPELL_LESSER_PLANAR_BINDING) bCanCast = TRUE;
                else if(nSpell == SPELL_ETHEREALNESS) bCanCast = TRUE;
                else if(nSpell == SPELL_PROTECTION_FROM_SPELLS) bCanCast = TRUE;
                else if(nSpell == SPELL_SHADOW_SHIELD) bCanCast = TRUE;
                else if(nSpell == SPELL_CREATE_GREATER_UNDEAD) bCanCast = TRUE;
                else if(nSpell == SPELL_GREATER_PLANAR_BINDING) bCanCast = TRUE;
                if(bCanCast && GetSpellAbilityReady(oCreature, nIndex))
                {
                    ActionCastSpellAtObject(nSpell, oCreature, 255, 0, 0, 0, TRUE);
                }
            }
            nIndex++;
        }
    }
}
int ai_IsNotSilenced(object oCreature, int nSpell)
{
    string sComponents = Get2DAString("ai_spells", "VS", nSpell);
    return (sComponents == "s" || !ai_GetHasEffectType(oCreature, EFFECT_TYPE_SILENCE));
}
int ai_TryToCastSpell(object oCaster, int nSpell, object oTarget)
{
    if(GetHasSpell(nSpell, oCaster) && !GetHasSpellEffect(nSpell, oTarget))
    {
        ActionCastSpellAtObject(nSpell, oTarget);
        return TRUE;
    }
    return FALSE;
}
int ai_SpellGroupNotCast(object oCreature, string sBuffGroup)
{
    return !GetLocalInt(oCreature, sBuffGroup);
}
void ai_ClearSpellsCastGroups(object oCreature)
{
    int nCounter = 1;
    for(nCounter = 1; nCounter <= AI_BUFF_GROUPS; nCounter++)
    {
        DeleteLocalInt(oCreature, "AI_USED_SPELL_GROUP_" + IntToString(nCounter));
    }
}
int ai_CanUseSpell(object oCaster, object oTarget, int nSpell, int nTargetType)
{
    if(nTargetType > 0 && nTargetType < 7) // Ability score buffs.
    {
        return TRUE;
    }
    if(nTargetType == 7) // Lowest AC.
    {
        // Stone bones only effects the undead.
        if(nSpell == SPELL_STONE_BONES)
        {
            if(GetRacialType(oTarget) != RACIAL_TYPE_UNDEAD) return FALSE;
        }
        return TRUE;
    }
    if(nTargetType == 8) // Lowest AC without AC Bonus.
    {
        if(nSpell == SPELL_MAGIC_VESTMENT)
        {
             object oArmor = GetItemInSlot(INVENTORY_SLOT_CHEST, oTarget);
             if(oArmor == OBJECT_INVALID) return FALSE;
        }
        return TRUE;
    }
    if(nTargetType == 9) // Highest Attack.
    {
        return TRUE;
    }
    if(nTargetType == 10) // Most wounded, Lowest Hp.
    {
        return TRUE;
    }
    if(nTargetType == 11) // Lowest Fortitude save.
    {
        return TRUE;
    }
    if(nTargetType == 12) // Lowest Reflex save.
    {
        return TRUE;
    }
    if(nTargetType == 13) // Lowest Will save.
    {
        return TRUE;
    }
    if(nTargetType == 14) // Lowest Save.
    {
        return TRUE;
    }
    if(nSpell == SPELL_MAGIC_FANG)
    {
        object oCompanion = GetAssociate(ASSOCIATE_TYPE_ANIMALCOMPANION, oCaster);
        if(oTarget != oCompanion) return FALSE;
    }
    return TRUE;
}
// Used to check if the targets weapon can be buffed by the spells effects.
int ai_CanItemBeBuffed(int nSpell, object oTarget)
{
    object oWeapon, oArmor;
    if(nSpell == SPELL_MAGIC_WEAPON || nSpell == SPELL_GREATER_MAGIC_WEAPON ||
       nSpell == SPELL_BLADE_THIRST)
    {
        oWeapon = GetItemInSlot(INVENTORY_SLOT_RIGHTHAND, oTarget);
        if(!ai_GetIsMeleeWeapon(oWeapon)) return FALSE;
        if(ai_GetHasItemProperty(oWeapon, ITEM_PROPERTY_ENHANCEMENT_BONUS)) return FALSE;
    }
    else if(nSpell == SPELL_MAGIC_VESTMENT)
    {
        oArmor = GetItemInSlot(INVENTORY_SLOT_CHEST, oTarget);
        if(oArmor == OBJECT_INVALID) return FALSE;
        if(ai_GetHasItemProperty(oArmor, ITEM_PROPERTY_AC_BONUS)) return FALSE;
    }
    else if(nSpell == SPELL_DARKFIRE)
    {
        oWeapon = GetItemInSlot(INVENTORY_SLOT_RIGHTHAND, oTarget);
        if(!ai_GetIsMeleeWeapon(oWeapon)) return FALSE;
        if(ai_GetHasItemProperty(oWeapon, ITEM_PROPERTY_ON_HIT_PROPERTIES, 127)) return FALSE;
    }
    else if(nSpell == SPELL_FLAME_WEAPON)
    {
        oWeapon = GetItemInSlot(INVENTORY_SLOT_RIGHTHAND, oTarget);
        if(!ai_GetIsMeleeWeapon(oWeapon)) return FALSE;
        if(ai_GetHasItemProperty(oWeapon, ITEM_PROPERTY_ON_HIT_PROPERTIES, 124)) return FALSE;
    }
    else if(nSpell == SPELL_KEEN_EDGE)
    {
        oWeapon = GetItemInSlot(INVENTORY_SLOT_RIGHTHAND, oTarget);
        if(!ai_GetIsSlashingWeapon(oWeapon)) return FALSE;
        if(ai_GetHasItemProperty(oWeapon, ITEM_PROPERTY_KEEN)) return FALSE;
    }
    else if(nSpell == SPELL_DEAFENING_CLANG)
    {
        oWeapon = GetItemInSlot(INVENTORY_SLOT_RIGHTHAND, oTarget);
        if(!ai_GetIsMeleeWeapon(oWeapon)) return FALSE;
        if(ai_GetHasItemProperty(oWeapon, ITEM_PROPERTY_ON_HIT_PROPERTIES, 137)) return FALSE;
    }
    else if(nSpell == SPELL_BLESS_WEAPON)
    {
        oWeapon = GetItemInSlot(INVENTORY_SLOT_RIGHTHAND, oTarget);
        if(!ai_GetIsMeleeWeapon(oWeapon)) return FALSE;
        if(ai_GetHasItemProperty(oWeapon, ITEM_PROPERTY_DAMAGE_BONUS_VS_RACIAL_GROUP, IP_CONST_RACIALTYPE_UNDEAD)) return FALSE;
    }
    else if(nSpell == SPELL_HOLY_SWORD)
    {
        oWeapon = GetItemInSlot(INVENTORY_SLOT_RIGHTHAND, oTarget);
        if(!ai_GetIsMeleeWeapon(oWeapon)) return FALSE;
        if(ai_GetHasItemProperty(oWeapon, ITEM_PROPERTY_HOLY_AVENGER)) return FALSE;
    }
    else if(nSpell == SPELL_BLACKSTAFF)
    {
        oWeapon = GetItemInSlot(INVENTORY_SLOT_RIGHTHAND, oTarget);
        if(GetBaseItemType(oWeapon) != BASE_ITEM_QUARTERSTAFF) return FALSE;
        if(ai_GetHasItemProperty(oWeapon, ITEM_PROPERTY_ON_HIT_PROPERTIES, IP_CONST_ONHIT_DISPELMAGIC)) return FALSE;
    }
    return TRUE;
}
// In "Buff_Target" column the value of 0 in the "ai_spells.2da" references the Caster.
// In "Buff_Target" column this is value 1-6(STR, DEX, CON, INT, WIS, CHA) in the "ai_spells.2da".
object ai_BuffHighestAbilityScoreTarget(object oCaster, int nSpell, int nAbilityScore, string sBuffGroup, float fRange, string sTargetType = "AI_ALLY_TARGET_")
{
    int nCntr = 1, nAB, nHighAB, nTarget;
    object oTarget = GetLocalObject(oCaster, sTargetType + IntToString(nCntr));
    while (nCntr < 10)
    {
        if(oTarget != OBJECT_INVALID && !GetHasSpellEffect(nSpell, oTarget) &&
           GetDistanceBetween(oCaster, oTarget) <= fRange)
        {
            nAB = GetAbilityScore(oTarget, nAbilityScore);
            if(nAB > nHighAB && ai_CanUseSpell(oCaster, oTarget, nSpell, nAbilityScore + 1) &&
              // We don't want to buff the strength for someone using weapon finesse!
              (nAbilityScore != ABILITY_STRENGTH || !GetHasFeat(FEAT_WEAPON_FINESSE, oTarget)))
            {nHighAB = nAB; nTarget = nCntr; }
        }
        oTarget = GetLocalObject(oCaster, sTargetType + IntToString(++nCntr));
    }
    if(nTarget == 0) return OBJECT_INVALID;
    else return GetLocalObject(oCaster, sTargetType + IntToString(nTarget));
}
// In "Buff_Target" column this is value 7 in the "ai_spells.2da".
object ai_BuffLowestACTarget(object oCaster, int nSpell, string sBuffGroup, float fRange, string sTargetType = "AI_ALLY_TARGET_")
{
    int nCntr = 1, nAC, nLowAC = 100, nTarget;
    object oTarget = GetLocalObject(oCaster, sTargetType + IntToString(nCntr));
    while (nCntr < 10)
    {
        if(oTarget != OBJECT_INVALID && !GetHasSpellEffect(nSpell, oTarget) &&
           GetDistanceBetween(oCaster, oTarget) <= fRange && ai_SpellGroupNotCast(oTarget, sBuffGroup))
        {
            nAC = GetAC(oTarget);
            if(nAC < nLowAC && ai_CanUseSpell(oCaster, oTarget, nSpell, 7))
            {nLowAC = nAC; nTarget = nCntr; }
        }
        oTarget = GetLocalObject(oCaster, sTargetType + IntToString(++nCntr));
    }
    if(nTarget == 0) return OBJECT_INVALID;
    oTarget = GetLocalObject(oCaster, sTargetType + IntToString(nTarget));
    return oTarget;
}
// In "Buff_Target" column this is value 8 in the "ai_spells.2da".
object ai_BuffLowestACWithOutACBonus(object oCaster, int nSpell, string sBuffGroup, float fRange, string sTargetType = "AI_ALLY_TARGET_")
{
    int nCntr = 1, nAC, nLowAC = 50, nTarget;
    object oItem, oTarget = GetLocalObject(oCaster, sTargetType + IntToString(nCntr));
    while (nCntr < 10)
    {
        if(oTarget != OBJECT_INVALID && !GetHasSpellEffect(nSpell, oTarget) &&
           GetDistanceBetween(oCaster, oTarget) <= fRange && ai_SpellGroupNotCast(oTarget, sBuffGroup))
        {
            nAC = GetAC(oTarget);
            oItem = GetItemInSlot(INVENTORY_SLOT_CHEST, oTarget);
            if(nAC < nLowAC  && ai_CanUseSpell(oCaster, oTarget, nSpell, 8) &&
               !GetItemHasItemProperty(oItem, ITEM_PROPERTY_AC_BONUS))
            {
                nLowAC = nAC;
                nTarget = nCntr;
            }
        }
        oTarget = GetLocalObject(oCaster, sTargetType + IntToString(++nCntr));
    }
    if(nTarget == 0) return OBJECT_INVALID;
    else return GetLocalObject(oCaster, sTargetType + IntToString(nTarget));
}
// In "Buff_Target" column this is value 9 in the "ai_spells.2da".
object ai_BuffHighestAttackTarget(object oCaster, int nSpell, string sBuffGroup, float fRange, string sTargetType = "AI_ALLY_TARGET_")
{
    int nCntr = 1, nAtk, nHighAtk, nTarget;
    object oTarget = GetLocalObject(oCaster, sTargetType + IntToString(nCntr));
    while (nCntr < 10)
    {
        if(oTarget != OBJECT_INVALID && !GetHasSpellEffect(nSpell, oTarget) &&
           GetDistanceBetween(oCaster, oTarget) <= fRange && ai_SpellGroupNotCast(oTarget, sBuffGroup))
        {
            nAtk = GetBaseAttackBonus(oTarget);
            if(nAtk > nHighAtk && ai_CanUseSpell(oCaster, oTarget, nSpell, 9))
            {nHighAtk = nAtk; nTarget = nCntr; }
        }
        oTarget = GetLocalObject(oCaster, sTargetType + IntToString(++nCntr));
    }
    if(nTarget == 0) return OBJECT_INVALID;
    oTarget = GetLocalObject(oCaster, sTargetType + IntToString(nTarget));
    return oTarget;
}
// In "Buff_Target" column this is value 10 in the "ai_spells.2da".
object ai_BuffMostWoundedTarget(object oCaster, int nSpell, string sBuffGroup, float fRange, string sTargetType = "AI_ALLY_TARGET_")
{
    int nCntr = 1, nDmg, nMostDmg, nHp, nLowHp = 10000, nTarget, nHpTarget;
    object oTarget = GetLocalObject(oCaster, sTargetType + IntToString(nCntr));
    while (nCntr < 10)
    {
        if(oTarget != OBJECT_INVALID && !GetHasSpellEffect(nSpell, oTarget) &&
           GetDistanceBetween(oCaster, oTarget) <= fRange && ai_SpellGroupNotCast(oTarget, sBuffGroup))
        {
            nHp = GetCurrentHitPoints(oTarget);
            nDmg = GetMaxHitPoints(oTarget) - nHp;
            if(nDmg > nMostDmg) { nMostDmg = nDmg; nTarget = nCntr; }
            if(nHp < nLowHp) { nLowHp = nHp; nHpTarget = nCntr; }
        }
        // If no one is damage then put regeneration on the lowest hp target.
        if(nMostDmg == 0) nTarget = nHpTarget;
        oTarget = GetLocalObject(oCaster, sTargetType + IntToString(++nCntr));
    }
    if(nTarget == 0) return OBJECT_INVALID;
    else return GetLocalObject(oCaster, sTargetType + IntToString(nTarget));
}
// In "Buff_Target" column this is value 11 in the "ai_spells.2da".
object ai_BuffLowestFortitudeSaveTarget(object oCaster, int nSpell, string sBuffGroup, float fRange, string sTargetType = "AI_ALLY_TARGET_")
{
    int nCntr = 1, nSave, nLowSave = 100, nTarget;
    object oTarget = GetLocalObject(oCaster, sTargetType + IntToString(nCntr));
    while (nCntr < 10)
    {
        if(oTarget != OBJECT_INVALID && !GetHasSpellEffect(nSpell, oTarget) &&
           GetDistanceBetween(oCaster, oTarget) <= fRange && ai_SpellGroupNotCast(oTarget, sBuffGroup))
        {
            nSave = GetFortitudeSavingThrow(oTarget);
            if(nSave < nLowSave && ai_CanUseSpell(oCaster, oTarget, nSpell, 11))
            {nLowSave = nSave; nTarget = nCntr; }
        }
        oTarget = GetLocalObject(oCaster, sTargetType + IntToString(++nCntr));
    }
    if(nTarget == 0) return OBJECT_INVALID;
    else return GetLocalObject(oCaster, sTargetType + IntToString(nTarget));
}
// In "Buff_Target" column this is value 12 in the "ai_spells.2da".
object ai_BuffLowestReflexSaveTarget(object oCaster, int nSpell, string sBuffGroup, float fRange, string sTargetType = "AI_ALLY_TARGET_")
{
    int nCntr = 1, nSave, nLowSave = 100, nTarget;
    object oTarget = GetLocalObject(oCaster, sTargetType + IntToString(nCntr));
    while (nCntr < 10)
    {
        if(oTarget != OBJECT_INVALID && !GetHasSpellEffect(nSpell, oTarget) &&
           GetDistanceBetween(oCaster, oTarget) <= fRange && ai_SpellGroupNotCast(oTarget, sBuffGroup))
        {
            nSave = GetReflexSavingThrow(oTarget);
            if(nSave < nLowSave && ai_CanUseSpell(oCaster, oTarget, nSpell, 12))
            {nLowSave = nSave; nTarget = nCntr; }
        }
        oTarget = GetLocalObject(oCaster, sTargetType + IntToString(++nCntr));
    }
    if(nTarget == 0) return OBJECT_INVALID;
    else return GetLocalObject(oCaster, sTargetType + IntToString(nTarget));
}
// In "Buff_Target" column this is value 13 in the "ai_spells.2da".
object ai_BuffLowestWillSaveTarget(object oCaster, int nSpell, string sBuffGroup, float fRange, string sTargetType = "AI_ALLY_TARGET_")
{
    int nCntr = 1, nSave, nLowSave = 100, nTarget;
    object oTarget = GetLocalObject(oCaster, sTargetType + IntToString(nCntr));
    while (nCntr < 10)
    {
        if(oTarget != OBJECT_INVALID && !GetHasSpellEffect(nSpell, oTarget) &&
           GetDistanceBetween(oCaster, oTarget) <= fRange && ai_SpellGroupNotCast(oTarget, sBuffGroup))
        {
            nSave = GetWillSavingThrow(oTarget);
            if(nSave < nLowSave && ai_CanUseSpell(oCaster, oTarget, nSpell, 13))
            {nLowSave = nSave; nTarget = nCntr; }
        }
        oTarget = GetLocalObject(oCaster, sTargetType + IntToString(++nCntr));
    }
    if(nTarget == 0) return OBJECT_INVALID;
    else return GetLocalObject(oCaster, sTargetType + IntToString(nTarget));
}
// In "Buff_Target" column this is value 14 in the "ai_spells.2da".
object ai_BuffLowestSaveTarget(object oCaster, int nSpell, string sBuffGroup, float fRange, string sTargetType = "AI_ALLY_TARGET_")
{
    int nCntr = 1, nSave, nLowSave = 200, nTarget;
    object oTarget = GetLocalObject(oCaster, sTargetType + IntToString(nCntr));
    while (nCntr < 10)
    {
        if(oTarget != OBJECT_INVALID && !GetHasSpellEffect(nSpell, oTarget) &&
           GetDistanceBetween(oCaster, oTarget) <= fRange && ai_SpellGroupNotCast(oTarget, sBuffGroup))
        {
            nSave = GetFortitudeSavingThrow(oTarget) + GetReflexSavingThrow(oTarget) + GetWillSavingThrow(oTarget);
            if(nSave < nLowSave && ai_CanUseSpell(oCaster, oTarget, nSpell, 14))
            {nLowSave = nSave; nTarget = nCntr; }
        }
        oTarget = GetLocalObject(oCaster, sTargetType + IntToString(++nCntr));
    }
    if(nTarget == 0) return OBJECT_INVALID;
    else return GetLocalObject(oCaster, sTargetType + IntToString(nTarget));
}
// In "Buff_Target" column this is value 9 in the "ai_spells.2da".
object ai_BuffItemTarget(object oCaster, int nSpell, string sBuffGroup, float fRange, string sTargetType = "AI_ALLY_TARGET_")
{
    int nCntr = 1, nAtk, nHighAtk = -9999, nTarget;
    object oTarget = GetLocalObject(oCaster, sTargetType + IntToString(nCntr));
    while (nCntr < 10)
    {
        if(oTarget != OBJECT_INVALID && ai_CanItemBeBuffed(nSpell, oTarget) &&
           GetDistanceBetween(oCaster, oTarget) <= fRange && ai_SpellGroupNotCast(oTarget, sBuffGroup))
        {
            nAtk = GetBaseAttackBonus(oTarget);
            if(nAtk > nHighAtk)
            { nHighAtk = nAtk; nTarget = nCntr; }
        }
        oTarget = GetLocalObject(oCaster, sTargetType + IntToString(++nCntr));
    }
    if(nTarget == 0) return OBJECT_INVALID;
    oTarget = GetLocalObject(oCaster, sTargetType + IntToString(nTarget));
    return oTarget;
}
object ai_GetBuffTarget(object oCaster, int nSpell)
{
    object oTarget = OBJECT_INVALID;
    if(ai_GetAssociateMagicMode(oCaster, AI_MAGIC_BUFF_MASTER)) return GetMaster(oCaster);
    string sBuffGroup = "AI_USED_SPELL_GROUP_" + Get2DAString("ai_spells", "Buff_Group", nSpell);
    string sBuffTarget = Get2DAString("ai_spells", "Buff_Target", nSpell);
    ai_Debug("0i_spells", "769", "BuffTarget: " + sBuffTarget);
    if(sBuffTarget == "0")
    {
        if(ai_SpellGroupNotCast(oCaster, sBuffGroup) &&
           !GetHasSpellEffect(nSpell, oCaster) &&
           ai_CanUseSpell(oCaster, oTarget, nSpell, 0))
        {
            oTarget = oCaster;
        }
    }
    else if(sBuffTarget == "1")
        oTarget = ai_BuffHighestAbilityScoreTarget(oCaster, nSpell, ABILITY_STRENGTH, "", AI_RANGE_BATTLEFIELD);
    else if(sBuffTarget == "2")
        oTarget = ai_BuffHighestAbilityScoreTarget(oCaster, nSpell, ABILITY_DEXTERITY, "", AI_RANGE_BATTLEFIELD);
    else if(sBuffTarget == "3")
        oTarget = ai_BuffHighestAbilityScoreTarget(oCaster, nSpell, ABILITY_CONSTITUTION, "", AI_RANGE_BATTLEFIELD);
    else if(sBuffTarget == "4")
        oTarget = ai_BuffHighestAbilityScoreTarget(oCaster, nSpell, ABILITY_INTELLIGENCE, "", AI_RANGE_BATTLEFIELD);
    else if(sBuffTarget == "5")
        oTarget = ai_BuffHighestAbilityScoreTarget(oCaster, nSpell, ABILITY_WISDOM, "", AI_RANGE_BATTLEFIELD);
    else if(sBuffTarget == "6")
        oTarget = ai_BuffHighestAbilityScoreTarget(oCaster, nSpell, ABILITY_CHARISMA, "", AI_RANGE_BATTLEFIELD);
    else if(sBuffTarget == "7")
        oTarget = ai_BuffLowestACTarget(oCaster, nSpell, sBuffGroup, AI_RANGE_BATTLEFIELD);
    else if(sBuffTarget == "8")
        oTarget = ai_BuffLowestACWithOutACBonus(oCaster, nSpell, sBuffGroup, AI_RANGE_BATTLEFIELD);
    else if(sBuffTarget == "9")
        oTarget = ai_BuffHighestAttackTarget(oCaster, nSpell, sBuffGroup, AI_RANGE_BATTLEFIELD);
    else if(sBuffTarget == "10")
        oTarget = ai_BuffMostWoundedTarget(oCaster, nSpell, sBuffGroup, AI_RANGE_BATTLEFIELD);
    else if(sBuffTarget == "11")
        oTarget = ai_BuffLowestFortitudeSaveTarget(oCaster, nSpell, sBuffGroup, AI_RANGE_BATTLEFIELD);
    else if(sBuffTarget == "12")
        oTarget = ai_BuffLowestReflexSaveTarget(oCaster, nSpell, sBuffGroup, AI_RANGE_BATTLEFIELD);
    else if(sBuffTarget == "13")
        oTarget = ai_BuffLowestWillSaveTarget(oCaster, nSpell, sBuffGroup, AI_RANGE_BATTLEFIELD);
    else if(sBuffTarget == "14")
        oTarget = ai_BuffLowestSaveTarget(oCaster, nSpell, sBuffGroup, AI_RANGE_BATTLEFIELD);
    else if(sBuffTarget == "15")
        oTarget = ai_BuffItemTarget(oCaster, nSpell, sBuffGroup, AI_RANGE_BATTLEFIELD);
    if(oTarget != OBJECT_INVALID && sBuffGroup != "AI_USED_SPELL_GROUP_") SetLocalInt(oTarget, sBuffGroup, TRUE);
    ai_Debug("0i_spells", "939", GetName(oCaster) + " is targeting " + GetName(oTarget) +
             " with " + GetStringByStrRef(StringToInt(Get2DAString("spells", "Name", nSpell))) + " spell" +
             " sBuffGroup: " + sBuffGroup + ".");
    return oTarget;
}
void ai_CastMemorizedSpell(object oCaster, int nClass, int nSpellLevel, int nSpellSlot, object oTarget, object oPC = OBJECT_INVALID)
{
    int nDomain;
    int nSpell = GetMemorizedSpellId(oCaster, nClass, nSpellLevel, nSpellSlot);
    if(GetMemorizedSpellIsDomainSpell(oCaster, nClass, nSpellLevel, nSpellSlot) == 1) nDomain = nSpellLevel;
    else nDomain = 0;
    int nMetaMagic = GetMemorizedSpellMetaMagic(oCaster, nClass, nSpellLevel, nSpellSlot);
    ai_Debug("0i_spells", "951", "nSpell: " + IntToString(nSpell) + " oTarget: " + GetName(oTarget) +
             " nMetaMagic: " + IntToString(nMetaMagic) + " nDomain: " + IntToString(nDomain) +
             " nClass: " + IntToString(nClass));
    ActionCastSpellAtObject(nSpell, oTarget, nMetaMagic, FALSE, nDomain, 0, TRUE);
    // Right now I cannot get nClass to work here...
    //DelayCommand(fDelay, ActionCastSpellAtObject(nSpell, oTarget, nMetaMagic, FALSE, nDomain, 0, TRUE, nClass));
    if(oPC != OBJECT_INVALID)
    {
        string sSpellName = GetStringByStrRef(StringToInt(Get2DAString("spells", "Name", nSpell)));
        ai_SendMessages(GetName(oCaster) + " has cast " + sSpellName + " on " + GetName(oTarget) + ".", COLOR_GREEN, oPC);
    }
}
void ai_CastKnownSpell(object oCaster, int nClass, int nSpell, object oTarget, object oPC = OBJECT_INVALID)
{
    ai_Debug("0i_Spells", "965", GetName(oCaster) + " is casting " + IntToString(nSpell));
    ActionCastSpellAtObject(nSpell, oTarget, 255, FALSE, 0, 0, TRUE);
    // Right now I cannot get nClass to work here...
    //ActionCastSpellAtObject(nSpell, oTarget, 255, FALSE, 0, 0, TRUE, nClass);
    if(oPC != OBJECT_INVALID)
    {
        string sSpellName = GetStringByStrRef(StringToInt(Get2DAString("spells", "Name", nSpell)));
        ai_SendMessages(GetName(oCaster) + " has cast " + sSpellName + " on " + GetName(oTarget) + ".", COLOR_GREEN, oPC);
    }
}
int ai_CheckAndCastSpell(object oCaster, int nSpell, int nSpellGroup, float fDelay, object oTarget, object oPC = OBJECT_INVALID)
{
    int nClassCnt = 1, nClass, nMaxSlot, nSpellLevel, nSpellSlot, nMemorizedSpell, nDomain, nMetaMagic;
    string sSpellName = GetStringByStrRef(StringToInt(Get2DAString("spells", "Name", nSpell)));
    while(nClassCnt <= AI_MAX_CLASSES_PER_CHARACTER && nClass != CLASS_TYPE_INVALID)
    {
        nClass = GetClassByPosition(nClassCnt);
        // Search all memorized spells for the spell.
        if(Get2DAString("classes", "MemorizesSpells", nClass) == "1")
        {
            // Check each level starting with the highest to lowest.
            nSpellLevel = 0;
            while(nSpellLevel < 10)
            {
                // Check each slot within each level.
                nMaxSlot = GetMemorizedSpellCountByLevel(oCaster, nClass, nSpellLevel);
                nSpellSlot = 0;
                while(nSpellSlot < nMaxSlot)
                {
                    if(GetMemorizedSpellReady(oCaster, nClass, nSpellLevel, nSpellSlot))
                    {
                        nMemorizedSpell = GetMemorizedSpellId(oCaster, nClass, nSpellLevel, nSpellSlot);
                        if(nMemorizedSpell == nSpell)
                        {
                            ai_CastMemorizedSpell(oCaster, nClass, nSpellLevel, nSpellSlot, oTarget, oPC);
                            return TRUE;
                        }
                    }
                    nSpellSlot++;
                }
                nSpellLevel++;
            }
        }
        // Check non-memorized known lists for the spell.
        else if(GetSpellUsesLeft(oCaster, nClass, nSpell))
        {
            ai_CastKnownSpell(oCaster, nClass, nSpell, oTarget, oPC);
            return TRUE;
        }
        nClassCnt++;
    }
    return FALSE;
}
void ai_SetupMonsterBuffTargets(object oCaster)
{
    ai_Debug("0i_spells", "1020", GetName(oCaster) + " is setting buff targets.");
    SetLocalObject (oCaster, "AI_ALLY_TARGET_1" , oCaster);
    SetLocalObject (oCaster, "AI_ALLY_TARGET_2", oCaster);
    int nCntr = 1;
    object oCreature = GetNearestCreature(CREATURE_TYPE_REPUTATION, REPUTATION_TYPE_FRIEND, oCaster, nCntr);
    ai_Debug("0i_spells", "864", GetName(oCreature) + " nCntr: " + IntToString(nCntr) +
             " Distance: " + FloatToString(GetDistanceBetween(oCaster, oCreature), 0, 2));
    while(oCreature != OBJECT_INVALID && nCntr < 8 && GetDistanceBetween(oCaster, oCreature) < AI_RANGE_CLOSE)
    {
        ai_Debug("0i_spells", "1029", "Setting " + GetName(oCreature) + " as AI_ALLY_TARGET_" + IntToString(nCntr + 2));
        SetLocalObject (oCaster, "AI_ALLY_TARGET_" + IntToString(nCntr + 2), oCreature);
        oCreature = GetNearestCreature(CREATURE_TYPE_REPUTATION, REPUTATION_TYPE_FRIEND, oCaster, ++nCntr);
        ai_Debug("0i_spells", "871", GetName(oCreature) + " nCntr: " + IntToString(nCntr) +
                 " Distance: " + FloatToString(GetDistanceBetween(oCaster, oCreature), 0, 2));
    }
}
void ai_SetupAllyTargets(object oCaster, object oPC)
{
    // Setup our targets.
    if(oCaster != oPC) SetLocalObject (oCaster, "AI_ALLY_TARGET_1", oPC);
    SetLocalObject (oCaster, "AI_ALLY_TARGET_2", oCaster);
    int nCntr = 1;
    object oHenchman = GetHenchman(oPC, nCntr);
    while(oHenchman != OBJECT_INVALID && nCntr < 5)
    {
        if(oHenchman != oCaster) SetLocalObject(oCaster, "AI_ALLY_TARGET_" + IntToString(nCntr + 2), oHenchman);
        oHenchman = GetHenchman(oPC, ++nCntr);
    }
    SetLocalObject (oCaster, "AI_ALLY_TARGET_7", GetAssociate(ASSOCIATE_TYPE_FAMILIAR, oPC));
    SetLocalObject (oCaster, "AI_ALLY_TARGET_8", GetAssociate(ASSOCIATE_TYPE_ANIMALCOMPANION, oPC));
    SetLocalObject (oCaster, "AI_ALLY_TARGET_9", GetAssociate(ASSOCIATE_TYPE_SUMMONED, oPC));
    nCntr = 1;
    while(nCntr < 10)
    {
        ai_Debug("0i_spells", "910", "Target " + IntToString(nCntr) + ": " +
                 GetName(GetLocalObject(oCaster, "AI_ALLY_TARGET_" + IntToString(nCntr))));
        nCntr++;
    }
}
void ai_ClearBuffTargets(object oCaster)
{
    // Lets clean this up.
    ai_Debug("0i_spells", "927", GetName(oCaster) + " is clearing Buff targets.");
    DeleteLocalObject (oCaster, "AI_ALLY_TARGET_1");
    DeleteLocalObject (oCaster, "AI_ALLY_TARGET_2");
    DeleteLocalObject (oCaster, "AI_ALLY_TARGET_3");
    DeleteLocalObject (oCaster, "AI_ALLY_TARGET_4");
    DeleteLocalObject (oCaster, "AI_ALLY_TARGET_5");
    DeleteLocalObject (oCaster, "AI_ALLY_TARGET_6");
    DeleteLocalObject (oCaster, "AI_ALLY_TARGET_7");
    DeleteLocalObject (oCaster, "AI_ALLY_TARGET_8");
    DeleteLocalObject (oCaster, "AI_ALLY_TARGET_9");
}
void ai_ActionCastMemorizedBuff(struct stSpell stSpell)
{
    ai_Debug("0i_spells", "962", "Start of ActionCastMemorizedBuff!");
    int nSpell,nBuffType;
    string sBuffGroup, sBuffTarget;
    object oTarget;
    while(stSpell.nPosition <= AI_MAX_CLASSES_PER_CHARACTER)
    {
        ai_Debug("0i_spells", "966", "SpellCaster: " + Get2DAString("classes", "SpellCaster", stSpell.nClass));
        if(Get2DAString("classes", "SpellCaster", stSpell.nClass) == "1")
        {
            ai_Debug("0i_spells", "969", "nLevel: " + IntToString(stSpell.nLevel));
            while(stSpell.nLevel > -1)
            {
                ai_Debug("0i_spells", "972", "nMaxSlots: " + IntToString(stSpell.nMaxSlots) +
                         " nSlots: " + IntToString(stSpell.nSlot));
                while(stSpell.nSlot < stSpell.nMaxSlots)
                {
                    ai_Debug("0i_spells", "976", "Ready: " + IntToString(GetMemorizedSpellReady(stSpell.oCaster, stSpell.nClass, stSpell.nLevel, stSpell.nSlot)));
                    if(GetMemorizedSpellReady(stSpell.oCaster, stSpell.nClass, stSpell.nLevel, stSpell.nSlot))
                    {
                        nSpell = GetMemorizedSpellId(stSpell.oCaster, stSpell.nClass, stSpell.nLevel, stSpell.nSlot);
                        int nSpellBuffDuration = StringToInt(Get2DAString("ai_spells", "Buff_Duration", nSpell));
                        ai_Debug("0i_spells", "1095", "nBuffType: " + IntToString(stSpell.nBuffType) +
                                 " nSpellBuffDuration: " + IntToString(nSpellBuffDuration) +
                                 " sBuffGroup: " + Get2DAString("ai_spells", "Buff_Group", nSpell));
                        if(stSpell.nBuffType == nSpellBuffDuration || stSpell.nBuffType == 1)
                        {
                            if(stSpell.nTarget > 0)
                            {
                                sBuffTarget = Get2DAString("ai_spells", "Buff_Target", nSpell);
                                oTarget = GetLocalObject(stSpell.oCaster, "AI_ALLY_TARGET_" + IntToString(stSpell.nTarget));
                                if(sBuffTarget != "0" || (sBuffTarget == "0" && stSpell.oCaster == oTarget))
                                {
                                    sBuffGroup = "AI_USED_SPELL_GROUP_" + Get2DAString("ai_spells", "Buff_Group", nSpell);
                                    if(!ai_SpellGroupNotCast(oTarget, sBuffGroup)) oTarget == OBJECT_INVALID;
                                }
                                else oTarget == OBJECT_INVALID;
                            }
                            else oTarget = ai_GetBuffTarget(stSpell.oCaster, nSpell);
                            ai_Debug("0i_spells", "982", "nSpell: " + IntToString(nSpell) +
                                     " oTarget: " + GetName(oTarget));
                            if(oTarget != OBJECT_INVALID)
                            {
                                ai_CastMemorizedSpell(stSpell.oCaster, stSpell.nClass, stSpell.nLevel, stSpell.nSlot, oTarget, stSpell.oPC);
                                stSpell.nSlot++;
                                DelayCommand(AI_HENCHMAN_BUFF_DELAY, AssignCommand(stSpell.oCaster, ai_ActionCastMemorizedBuff(stSpell)));
                                return;
                            }
                        }
                    }
                    stSpell.nSlot++;
                }
                stSpell.nLevel--;
                ai_Debug("0i_spells", "995", "nLevel: " + IntToString(stSpell.nLevel));
                if(stSpell.nLevel > -1)
                {
                    stSpell.nMaxSlots = GetMemorizedSpellCountByLevel(stSpell.oCaster, stSpell.nClass, stSpell.nLevel);
                    stSpell.nSlot = 0;
                }
            }
        }
        stSpell.nPosition++;
        stSpell.nClass = GetClassByPosition(stSpell.nPosition, stSpell.oCaster);
        if(stSpell.nClass == CLASS_TYPE_INVALID) break;
        ai_Debug("0i_spells", "1007", "nClass: " + IntToString(stSpell.nClass));
        if(Get2DAString("classes", "SpellCaster", stSpell.nClass) == "1")
        {
            stSpell.nLevel = (GetLevelByPosition(stSpell.nPosition, stSpell.oCaster) + 1) / 2;
            stSpell.nSlot = 0;
            if(Get2DAString("classes", "MemorizesSpells", stSpell.nClass) == "1")
            {
                stSpell.nMaxSlots = GetMemorizedSpellCountByLevel(stSpell.oCaster, stSpell.nClass, stSpell.nLevel);
            }
            else
            {
                stSpell.nMaxSlots = GetKnownSpellCount(stSpell.oCaster, stSpell.nClass, stSpell.nLevel);
                AssignCommand(stSpell.oCaster, ai_ActionCastKnownBuff(stSpell));
                return;
            }
        }
    }
    // Clean up our variables.
    int nCntr;
    while(nCntr < 10)
    {
        oTarget = GetLocalObject(stSpell.oCaster, "AI_ALLY_TARGET_" + IntToString(nCntr));
        if(oTarget != OBJECT_INVALID)
        {
            ai_ClearSpellsCastGroups(oTarget);
            DeleteLocalObject(stSpell.oCaster, "AI_ALLY_TARGET_" + IntToString(nCntr));
        }
        nCntr++;
    }
}
void ai_ActionCastKnownBuff(struct stSpell stSpell)
{
    ai_Debug("0i_spells", "1170", "Start of ActionCastKnownBuff!");
    int nSpell;
    string sBuffGroup, sBuffTarget;
    object oTarget;
    while(stSpell.nPosition <= AI_MAX_CLASSES_PER_CHARACTER)
    {
        ai_Debug("0i_spells", "1176", "SpellCaster: " + Get2DAString("classes", "SpellCaster", stSpell.nClass));
        if(Get2DAString("classes", "SpellCaster", stSpell.nClass) == "1")
        {
            ai_Debug("0i_spells", "1179", "nLevel: " + IntToString(stSpell.nLevel));
            while(stSpell.nLevel > -1)
            {
                if(stSpell.nMaxSlots)
                {
                ai_Debug("0i_spells", "1184", "nMaxSlots: " + IntToString(stSpell.nMaxSlots) +
                         " nSlots: " + IntToString(stSpell.nSlot));
                    while(stSpell.nSlot < stSpell.nMaxSlots)
                    {
                        nSpell = GetKnownSpellId(stSpell.oCaster, stSpell.nClass, stSpell.nLevel, stSpell.nSlot);
                        int nSpellBuffDuration = StringToInt(Get2DAString("ai_spells", "Buff_Duration", nSpell));
                        ai_Debug("0i_spells", "1190", "nBuffType: " + IntToString(stSpell.nBuffType) +
                                 " nSpellBuffDuration: " + IntToString(nSpellBuffDuration) +
                                 " sBuffGroup: " + Get2DAString("ai_spells", "Buff_Group", nSpell));
                        if(stSpell.nBuffType == nSpellBuffDuration || stSpell.nBuffType == 1)
                        {
                            ai_Debug("0i_spells", "1195", "Ready: " + IntToString(GetSpellUsesLeft(stSpell.oCaster, stSpell.nClass, nSpell)));
                            if(GetSpellUsesLeft(stSpell.oCaster, stSpell.nClass, nSpell))
                            {
                                if(stSpell.nTarget > 0)
                                {
                                    sBuffTarget = Get2DAString("ai_spells", "Buff_Target", nSpell);
                                    oTarget = GetLocalObject(stSpell.oCaster, "AI_ALLY_TARGET_" + IntToString(stSpell.nTarget));
                                    if(sBuffTarget != "0" || (sBuffTarget == "0" && stSpell.oCaster == oTarget))
                                    {
                                        sBuffGroup = "AI_USED_SPELL_GROUP_" + Get2DAString("ai_spells", "Buff_Group", nSpell);
                                        if(!ai_SpellGroupNotCast(oTarget, sBuffGroup)) oTarget == OBJECT_INVALID;
                                    }
                                    else oTarget == OBJECT_INVALID;
                                }
                                else oTarget = ai_GetBuffTarget(stSpell.oCaster, nSpell);
                                ai_Debug("0i_spells", "1210", "nSpell: " + IntToString(nSpell) +
                                         " oTarget: " + GetName(oTarget));
                                if(oTarget != OBJECT_INVALID)
                                {
                                    ai_CastKnownSpell(stSpell.oCaster, stSpell.nClass, nSpell, oTarget, stSpell.oPC);
                                    stSpell.nSlot++;
                                    DelayCommand(AI_HENCHMAN_BUFF_DELAY, AssignCommand(stSpell.oCaster, ai_ActionCastKnownBuff(stSpell)));
                                    return;
                                }
                            }
                        }
                        stSpell.nSlot++;
                    }
                }
                stSpell.nLevel--;
                ai_Debug("0i_spells", "1225", "nLevel: " + IntToString(stSpell.nLevel));
                if(stSpell.nLevel > -1)
                {
                    stSpell.nMaxSlots = GetKnownSpellCount(stSpell.oCaster, stSpell.nClass, stSpell.nLevel);
                    stSpell.nSlot = 0;
                }
            }
        }
        stSpell.nPosition++;
        stSpell.nClass = GetClassByPosition(stSpell.nPosition, stSpell.oCaster);
        if(stSpell.nClass == CLASS_TYPE_INVALID) break;
        //ai_Debug("0i_spells", "921", "nClass: " + IntToString(stSpell.nClass));
        if(Get2DAString("classes", "SpellCaster", stSpell.nClass) == "1")
        {
            stSpell.nLevel = (GetLevelByPosition(stSpell.nPosition, stSpell.oCaster) + 1) / 2;
            stSpell.nSlot = 0;
            if(Get2DAString("classes", "MemorizesSpells", stSpell.nClass) == "1")
            {
                stSpell.nMaxSlots = GetMemorizedSpellCountByLevel(stSpell.oCaster, stSpell.nClass, stSpell.nLevel);
                AssignCommand(stSpell.oCaster, ai_ActionCastMemorizedBuff(stSpell));
                return;
            }
            else stSpell.nMaxSlots = GetKnownSpellCount(stSpell.oCaster, stSpell.nClass, stSpell.nLevel);
        }
    }
    // Clean up our variables.
    int nCntr;
    while(nCntr < 10)
    {
        oTarget = GetLocalObject(stSpell.oCaster, "AI_ALLY_TARGET_" + IntToString(nCntr));
        if(oTarget != OBJECT_INVALID)
        {
            ai_ClearSpellsCastGroups(oTarget);
            DeleteLocalObject(stSpell.oCaster, "AI_ALLY_TARGET_" + IntToString(nCntr));
        }
        nCntr++;
    }
}
void ai_CastBuffs(object oCaster, int nBuffType, int nTarget, object oPC)
{
    // buff types: 1 - All, 2 - Short duration, 3 - Long duration
    // Buff groups are used to prevent a henchmen to cast spells that have the same effect,
    // for example: resist elements and protection from elements are similiar so the henchmen
    // would cast only the most powerful among these if he has them both.
    ai_Debug("0i_spells", "1118", GetName(oCaster) + " is casting buffs: " + IntToString(nBuffType) +
             " nTarget: " + IntToString(nTarget) + "!");
    struct stSpell stSpell;
    stSpell.oPC = oPC;
    stSpell.oCaster = oCaster;
    stSpell.nBuffType = nBuffType;
    stSpell.nTarget = nTarget;
    stSpell.nPosition = 1;
    while(stSpell.nPosition <= AI_MAX_CLASSES_PER_CHARACTER)
    {
        stSpell.nClass = GetClassByPosition(stSpell.nPosition, stSpell.oCaster);
        ai_Debug("0i_spells", "1129", "nClass: " + IntToString(stSpell.nClass));
        if(stSpell.nClass == CLASS_TYPE_INVALID) break;
        ai_Debug("0i_spells", "1131", "SpellCaster: " + Get2DAString("classes", "SpellCaster", stSpell.nClass));
        if(Get2DAString("classes", "SpellCaster", stSpell.nClass) == "1")
        {
            stSpell.nLevel = (GetLevelByPosition(stSpell.nPosition, stSpell.oCaster) + 1) / 2;
            ai_Debug("0i_spells", "1135", "MemorizesSpells: " + Get2DAString("classes", "MemorizesSpells", stSpell.nClass));
            ai_SetupAllyTargets(oCaster, oPC);
            if(Get2DAString("classes", "MemorizesSpells", stSpell.nClass) == "1")
            {
                stSpell.nMaxSlots = GetMemorizedSpellCountByLevel(stSpell.oCaster, stSpell.nClass, stSpell.nLevel);
                AssignCommand(stSpell.oCaster, ai_ActionCastMemorizedBuff(stSpell));
            }
            else AssignCommand(stSpell.oCaster, ai_ActionCastKnownBuff(stSpell));
            return;
        }
        stSpell.nPosition++;
    }
}
int ai_CheckItemForHealing(object oCreature, object oTarget, object oItem, int nHpLost, int bEquiped = FALSE)
{
    ai_Debug("0i_spells", "1165", "Checking Item properties on " + GetName(oItem));
    int nIprpSubType, nSpell, nLevel, nIPType;
    itemproperty ipProp = GetFirstItemProperty(oItem);
    // Lets skip this if there are no properties.
    if(!GetIsItemPropertyValid(ipProp)) return FALSE;
    // Check for cast spell property and add them to the talent list.
    int nIndex;
    ipProp = GetFirstItemProperty(oItem);
    while(GetIsItemPropertyValid(ipProp))
    {
        ai_Debug("0i_spells", "1175", "ItempropertyType(15): " + IntToString(GetItemPropertyType(ipProp)));
        nIPType = GetItemPropertyType(ipProp);
        if(nIPType == ITEM_PROPERTY_CAST_SPELL)
        {
            nIprpSubType = GetItemPropertySubType(ipProp);
            nSpell = StringToInt(Get2DAString("iprp_spells", "SpellIndex", nIprpSubType));
            if(ai_ShouldWeCastThisCureSpell(nSpell, nHpLost))
            {
                // We have established that we can use the item if it is equiped.
                if(!bEquiped) ai_CheckIfCanUseItem(oCreature, oItem);
                // Get how they use the item (charges or uses per day).
                int nUses = GetItemPropertyCostTableValue(ipProp);
                if(nUses > 1 && nUses < 7)
                {
                    int nCharges = GetItemCharges(oItem);
                    ai_Debug("0i_spells", "1190", "Item charges: " + IntToString(nCharges));
                    if(nUses == 6 && nCharges < 1 || nUses == 5 && nCharges < 3 ||
                       nUses == 4 && nCharges < 5 || nUses == 3 && nCharges < 7 ||
                       nUses == 2 && nCharges < 9) return FALSE;
                }
                else if(nUses > 7 && nUses < 13)
                {
                    int nPerDay = GetItemPropertyUsesPerDayRemaining(oItem, ipProp);
                    ai_Debug("0i_spells", "1198", "Item uses: " + IntToString(nPerDay));
                    if(nUses == 8 && nPerDay < 1 || nUses == 9 && nPerDay < 3 ||
                       nUses == 10 && nPerDay < 5 || nUses == 11 && nPerDay < 7 ||
                       nUses == 12 && nPerDay < 9) return FALSE;
                }
                // SubType is the ip spell index for iprp_spells.2da
                nIprpSubType = GetItemPropertySubType(ipProp);
                ActionUseItemOnObject(oItem, ipProp, oTarget, GetItemPropertySubType(ipProp));
                return TRUE;
            }
        }
        nIndex++;
        ipProp = GetNextItemProperty(oItem);
    }
    return FALSE;
}
void ai_UseItemHealing(struct stSpell stSpell, int bEquiped, int bInCombat)
{
    string sSlots;
    if(ai_GetAssociateMagicMode(stSpell.oCaster, AI_MAGIC_NO_MAGIC_ITEMS)) return;
    int nHpLost = ai_GetPercHPLoss(stSpell.oTarget);
    if(nHpLost < ai_GetHealersHpLimit(stSpell.oCaster, bInCombat))
    {
        itemproperty ipProp;
        object oItem = GetFirstItemInInventory(stSpell.oCaster);
        while(!bEquiped && oItem != OBJECT_INVALID)
        {
            if(GetIdentified(oItem))
            {
                // Does the item need to be equiped to use its powers?
                sSlots = Get2DAString("baseitems", "EquipableSlots", GetBaseItemType(oItem));
                ai_Debug("0i_spells", "1229", GetName(oItem) + " requires " + Get2DAString("baseitems", "EquipableSlots", GetBaseItemType(oItem)) + " slots.");
                if(sSlots == "0x00000")
                {
                    int nBaseItemType = GetBaseItemType(oItem);
                    // Lets not use up our healing kits on minor damage.
                    if(nBaseItemType == BASE_ITEM_HEALERSKIT && nHpLost > AI_MIN_HP_TO_USE_HEALINGKIT)
                    {
                        ipProp = GetFirstItemProperty(oItem);
                        while(GetIsItemPropertyValid(ipProp))
                        {
                            if(GetItemPropertyType(ipProp) == ITEM_PROPERTY_HEALERS_KIT)
                            {
                                if(ai_GetIsCharacter(stSpell.oCaster)) SendMessageToPC(stSpell.oCaster, GetName(stSpell.oCaster) + " uses " + GetName(oItem) + ".");
                                ActionUseItemOnObject(oItem, ipProp, stSpell.oTarget);
                                DelayCommand(6.0, ai_UseItemHealing(stSpell, FALSE, bInCombat));
                                return;
                            }
                        }
                    }
                    else if(nBaseItemType == BASE_ITEM_ENCHANTED_POTION ||
                            nBaseItemType == BASE_ITEM_POTIONS)
                    {
                        if(stSpell.oCaster == stSpell.oTarget)
                        {
                            if(ai_CheckItemForHealing(stSpell.oCaster, stSpell.oTarget, oItem, nHpLost))
                            {
                                DelayCommand(6.0, ai_UseItemHealing(stSpell, FALSE, bInCombat));
                                return;
                            }
                        }
                    }
                    else if(ai_CheckItemForHealing(stSpell.oCaster, stSpell.oTarget, oItem, nHpLost))
                    {
                        DelayCommand(6.0, ai_UseItemHealing(stSpell, FALSE, bInCombat));
                        return;
                    }
                }
            }
            oItem = GetNextItemInInventory(stSpell.oCaster);
        }
        // Cycle through all the creatures equiped items.
        int nSlot;
        oItem = GetItemInSlot(nSlot, stSpell.oCaster);
        while(nSlot < 11)
        {
            if(oItem != OBJECT_INVALID && ai_CheckItemForHealing(stSpell.oCaster, stSpell.oTarget, oItem, nHpLost, TRUE))
            {
                DelayCommand(6.0, ai_UseItemHealing(stSpell, nSlot, bInCombat));
                return;
            }
            oItem = GetItemInSlot(++nSlot, stSpell.oCaster);
        }
    }
}
void ai_CastSpontaneousCure(struct stSpell stSpell, int bInCombat)
{
    if(!AI_USE_SPONTANEOUS_CASTING) return;
    int nHpLost = ai_GetPercHPLoss(stSpell.oTarget);
    if(nHpLost < ai_GetHealersHpLimit(stSpell.oCaster, bInCombat))
    {
        while(stSpell.nLevel > -1)
        {
            while(stSpell.nSlot < stSpell.nMaxSlots)
            {
                if(GetMemorizedSpellReady(stSpell.oCaster, stSpell.nClass, stSpell.nLevel, stSpell.nSlot))
                {
                    int nSpell = GetMemorizedSpellId(stSpell.oCaster, stSpell.nClass, stSpell.nLevel, stSpell.nSlot);
                    ai_Debug("0i_spells", "1296", "nLevel: " + IntToString(stSpell.nLevel));
                    if(stSpell.nLevel == 4) nSpell = SPELL_CURE_CRITICAL_WOUNDS;
                    else if(stSpell.nLevel == 3) nSpell = SPELL_CURE_SERIOUS_WOUNDS;
                    else if(stSpell.nLevel == 2) nSpell = SPELL_CURE_MODERATE_WOUNDS;
                    else if(stSpell.nLevel == 1) nSpell = SPELL_CURE_LIGHT_WOUNDS;
                    else return;
                    if(ai_ShouldWeCastThisCureSpell(nSpell, nHpLost))
                    {
                        SetMemorizedSpellReady(stSpell.oCaster, 2, stSpell.nLevel, stSpell.nSlot, FALSE);
                        ActionCastSpellAtObject(nSpell, stSpell.oTarget, 255, TRUE);
                        stSpell.nSlot++;
                        DelayCommand(AI_HENCHMAN_BUFF_DELAY, AssignCommand(stSpell.oCaster, ai_CastSpontaneousCure(stSpell, bInCombat)));
                        return;
                    }
                }
                stSpell.nSlot++;
            }
            stSpell.nLevel--;
            if(stSpell.nLevel > -1)
            {
                stSpell.nMaxSlots = GetMemorizedSpellCountByLevel(stSpell.oCaster, stSpell.nClass, stSpell.nLevel);
                stSpell.nSlot = 0;
            }
        }
    }
}
void ai_ActionCastMemorizedHealing(struct stSpell stSpell, int nIndex, int bInCombat)
{
    int nSpell;
    int nHpLost = ai_GetPercHPLoss(stSpell.oTarget);
    if(nHpLost < ai_GetHealersHpLimit(stSpell.oCaster, bInCombat))
    {
        while(stSpell.nPosition <= AI_MAX_CLASSES_PER_CHARACTER)
        {
            if(Get2DAString("classes", "SpellCaster", stSpell.nClass) == "1")
            {
                while(stSpell.nLevel > -1)
                {
                    while(stSpell.nSlot < stSpell.nMaxSlots)
                    {
                        if(GetMemorizedSpellReady(stSpell.oCaster, stSpell.nClass, stSpell.nLevel, stSpell.nSlot))
                        {
                            nSpell = GetMemorizedSpellId(stSpell.oCaster, stSpell.nClass, stSpell.nLevel, stSpell.nSlot);
                            if(ai_ShouldWeCastThisCureSpell(nSpell, nHpLost))
                            {
                                ai_CastMemorizedSpell(stSpell.oCaster, stSpell.nClass, stSpell.nLevel, stSpell.nSlot, stSpell.oTarget, stSpell.oPC);
                                stSpell.nSlot++;
                                DelayCommand(AI_HENCHMAN_BUFF_DELAY, AssignCommand(stSpell.oCaster, ai_ActionCastMemorizedHealing(stSpell, nIndex, bInCombat)));
                                return;
                            }
                        }
                        stSpell.nSlot++;
                    }
                    stSpell.nLevel--;
                    if(stSpell.nLevel > -1)
                    {
                        stSpell.nMaxSlots = GetMemorizedSpellCountByLevel(stSpell.oCaster, stSpell.nClass, stSpell.nLevel);
                        stSpell.nSlot = 0;
                    }
                }
            }
            stSpell.nPosition++;
            stSpell.nClass = GetClassByPosition(stSpell.nPosition, stSpell.oCaster);
            if(stSpell.nClass == CLASS_TYPE_INVALID) break;
            ai_Debug("0i_spells", "1360", "nClass: " + IntToString(stSpell.nClass));
            if(Get2DAString("classes", "SpellCaster", stSpell.nClass) == "1")
            {
                stSpell.nLevel = (GetLevelByPosition(stSpell.nPosition, stSpell.oCaster) + 1) / 2;
                if(Get2DAString("classes", "MemorizesSpells", stSpell.nClass) == "1")
                {
                    stSpell.nMaxSlots = GetMemorizedSpellCountByLevel(stSpell.oCaster, stSpell.nClass, stSpell.nLevel);
                    stSpell.nSlot = 0;
                    AssignCommand(stSpell.oCaster, ai_ActionCastMemorizedHealing(stSpell, nIndex, bInCombat));
                }
                else AssignCommand(stSpell.oCaster, ai_ActionCastKnownHealing(stSpell, nIndex, bInCombat));
                return;
            }
        }
    }
    // We have exhausted all attempts to use healing spells for this target.
    ai_UseItemHealing(stSpell, FALSE, bInCombat);
    stSpell.nLevel = 4;
    stSpell.nSlot = 0;
    ai_CastSpontaneousCure(stSpell, bInCombat);
    if(stSpell.nTarget == 0)
    {
        // Check for other allies.
        while(nIndex < 10)
        {
            if(stSpell.nTarget == 0) nIndex++;
            stSpell.oTarget = GetLocalObject(stSpell.oCaster, "AI_ALLY_TARGET_" + IntToString(nIndex));
            ai_Debug("0c_henchmanspell", "1387", "oTarget: " + GetName(stSpell.oTarget) +
                     " nIndex: " + IntToString(nIndex));
            nHpLost = ai_GetPercHPLoss(stSpell.oTarget);
            if(stSpell.oTarget != OBJECT_INVALID)
            {
                if(nHpLost < ai_GetHealersHpLimit(stSpell.oCaster, bInCombat))
                {
                    while(stSpell.nPosition <= AI_MAX_CLASSES_PER_CHARACTER)
                    {
                        stSpell.nClass = GetClassByPosition(stSpell.nPosition, stSpell.oCaster);
                        ai_Debug("0i_spells", "1397", "nClass: " + IntToString(stSpell.nClass));
                        if(stSpell.nClass == CLASS_TYPE_INVALID) break;
                        if(Get2DAString("classes", "SpellCaster", stSpell.nClass) == "1")
                        {
                            stSpell.nLevel = (GetLevelByPosition(stSpell.nPosition, stSpell.oCaster) + 1) / 2;
                            if(Get2DAString("classes", "MemorizesSpells", stSpell.nClass) == "1")
                            {
                                stSpell.nMaxSlots = GetMemorizedSpellCountByLevel(stSpell.oCaster, stSpell.nClass, stSpell.nLevel);
                                stSpell.nSlot = 0;
                                AssignCommand(stSpell.oCaster, ai_ActionCastMemorizedHealing(stSpell, nIndex, bInCombat));
                            }
                            else AssignCommand(stSpell.oCaster, ai_ActionCastKnownHealing(stSpell, nIndex, bInCombat));
                            return;
                        }
                        stSpell.nPosition++;
                    }
                }
                else ai_SendMessages(GetName(stSpell.oTarget) + " does not need any healing.", COLOR_RED, stSpell.oPC);
            }
            if(stSpell.nTarget == 0) nIndex++;
            else break;
        }
    }
    // Clean up our variables.
    int nCntr;
    while(nCntr < 10)
    {
        stSpell.oTarget = GetLocalObject(stSpell.oCaster, "AI_ALLY_TARGET_" + IntToString(nCntr));
        if(stSpell.oTarget != OBJECT_INVALID)
        {
            DeleteLocalObject(stSpell.oCaster, "AI_ALLY_TARGET_" + IntToString(nCntr));
        }
        nCntr++;
    }
}
void ai_ActionCastKnownHealing(struct stSpell stSpell, int nIndex, int bInCombat)
{
    int nSpell;
    int nHpLost = ai_GetPercHPLoss(stSpell.oTarget);
    if(nHpLost < ai_GetHealersHpLimit(stSpell.oCaster, bInCombat))
    {
        while(stSpell.nPosition <= AI_MAX_CLASSES_PER_CHARACTER)
        {
            if(Get2DAString("classes", "SpellCaster", stSpell.nClass) == "1")
            {
                while(stSpell.nLevel > -1)
                {
                    while(stSpell.nSlot < stSpell.nMaxSlots)
                    {
                        nSpell = GetKnownSpellId(stSpell.oCaster, stSpell.nClass, stSpell.nLevel, stSpell.nSlot);
                        if(GetSpellUsesLeft(stSpell.oCaster, stSpell.nClass, nSpell))
                        {
                            if(ai_ShouldWeCastThisCureSpell(nSpell, nHpLost))
                            {
                                ai_CastKnownSpell(stSpell.oCaster, stSpell.nClass, nSpell, stSpell.oTarget, stSpell.oPC);
                                stSpell.nSlot++;
                                DelayCommand(AI_HENCHMAN_BUFF_DELAY, AssignCommand(stSpell.oCaster, ai_ActionCastKnownHealing(stSpell, nIndex, bInCombat)));
                                return;
                            }
                        }
                        stSpell.nSlot++;
                    }
                    stSpell.nLevel--;
                    if(stSpell.nLevel > -1)
                    {
                        stSpell.nMaxSlots = GetMemorizedSpellCountByLevel(stSpell.oCaster, stSpell.nClass, stSpell.nLevel);
                        stSpell.nSlot = 0;
                    }
                }
            }
            stSpell.nPosition++;
            stSpell.nClass = GetClassByPosition(stSpell.nPosition, stSpell.oCaster);
            if(stSpell.nClass == CLASS_TYPE_INVALID) break;
            ai_Debug("0i_spells", "1470", "nClass: " + IntToString(stSpell.nClass));
            if(Get2DAString("classes", "SpellCaster", stSpell.nClass) == "1")
            {
                stSpell.nLevel = (GetLevelByPosition(stSpell.nPosition, stSpell.oCaster) + 1) / 2;
                if(Get2DAString("classes", "MemorizesSpells", stSpell.nClass) == "1")
                {
                    AssignCommand(stSpell.oCaster, ai_ActionCastMemorizedHealing(stSpell, nIndex, bInCombat));
                }
                else AssignCommand(stSpell.oCaster, ai_ActionCastKnownHealing(stSpell, nIndex, bInCombat));
                return;
            }
        }
    }
    // We have exhausted all attempts to use healing spells for this target.
    if(ai_UseItemHealing(stSpell, FALSE, bInCombat)) return;
    if(stSpell.nTarget == 0)
    {
        // Check for other allies.
        while(nIndex < 10)
        {
            if(stSpell.nTarget == 0) nIndex++;
            stSpell.oTarget = GetLocalObject(stSpell.oCaster, "AI_ALLY_TARGET_" + IntToString(nIndex));
            ai_Debug("0c_henchmanspell", "1492", "oTarget: " + GetName(stSpell.oTarget) +
                     " nIndex: " + IntToString(nIndex));
            nHpLost = ai_GetPercHPLoss(stSpell.oTarget);
            if(stSpell.oTarget != OBJECT_INVALID)
            {
                if(nHpLost < ai_GetHealersHpLimit(stSpell.oCaster, bInCombat))
                {
                    while(stSpell.nPosition <= AI_MAX_CLASSES_PER_CHARACTER)
                    {
                        stSpell.nClass = GetClassByPosition(stSpell.nPosition, stSpell.oCaster);
                        ai_Debug("0i_spells", "1502", "nClass: " + IntToString(stSpell.nClass));
                        if(stSpell.nClass == CLASS_TYPE_INVALID) break;
                        if(Get2DAString("classes", "SpellCaster", stSpell.nClass) == "1")
                        {
                            stSpell.nLevel = (GetLevelByPosition(stSpell.nPosition, stSpell.oCaster) + 1) / 2;
                            if(Get2DAString("classes", "MemorizesSpells", stSpell.nClass) == "1")
                            {
                                stSpell.nMaxSlots = GetMemorizedSpellCountByLevel(stSpell.oCaster, stSpell.nClass, stSpell.nLevel);
                                stSpell.nSlot = 0;
                                AssignCommand(stSpell.oCaster, ai_ActionCastMemorizedHealing(stSpell, nIndex, bInCombat));
                            }
                            else AssignCommand(stSpell.oCaster, ai_ActionCastKnownHealing(stSpell, nIndex, bInCombat));
                            return;
                        }
                        stSpell.nPosition++;
                    }
                }
                else ai_SendMessages(GetName(stSpell.oTarget) + " does not need any healing.", COLOR_RED, stSpell.oPC);
            }
            if(stSpell.nTarget == 0) nIndex++;
            else break;
        }
    }
    // Clean up our variables.
    int nCntr;
    while(nCntr < 10)
    {
        stSpell.oTarget = GetLocalObject(stSpell.oCaster, "AI_ALLY_TARGET_" + IntToString(nCntr));
        if(stSpell.oTarget != OBJECT_INVALID)
        {
            DeleteLocalObject(stSpell.oCaster, "AI_ALLY_TARGET_" + IntToString(nCntr));
        }
        nCntr++;
    }
}
void ai_CastHealing(object oCaster, int nTarget, object oPC, int bInCombat)
{
    struct stSpell stSpell;
    stSpell.oPC = oPC;
    stSpell.oCaster = oCaster;
    stSpell.nTarget = nTarget;
    stSpell.nPosition = 1;
    int nHpLost, nIndex = nTarget;
    ai_SetupAllyTargets(oCaster, oPC);
    while(nIndex < 10)
    {
        if(stSpell.nTarget == 0) nIndex++;
        stSpell.oTarget = GetLocalObject(stSpell.oCaster, "AI_ALLY_TARGET_" + IntToString(nIndex));
        ai_Debug("0i_spells", "1550", "oTarget: " + GetName(stSpell.oTarget) +
                 " nIndex: " + IntToString(nIndex));
        if(stSpell.oTarget != OBJECT_INVALID)
        {
            nHpLost = ai_GetPercHPLoss(stSpell.oTarget);
            if(nHpLost < ai_GetHealersHpLimit(oCaster, bInCombat))
            {
                // Undead don't heal so lets skip this for them, maybe later we can fix this.
                if(GetRacialType(stSpell.oTarget) != RACIAL_TYPE_UNDEAD)
                {
                    while(stSpell.nPosition <= AI_MAX_CLASSES_PER_CHARACTER)
                    {
                        stSpell.nClass = GetClassByPosition(stSpell.nPosition, stSpell.oCaster);
                        ai_Debug("0i_spells", "1561", "nClass: " + IntToString(stSpell.nClass));
                        if(stSpell.nClass == CLASS_TYPE_INVALID) break;
                        if(Get2DAString("classes", "SpellCaster", stSpell.nClass) == "1")
                        {
                            stSpell.nLevel = (GetLevelByPosition(stSpell.nPosition, stSpell.oCaster) + 1) / 2;
                            if(Get2DAString("classes", "MemorizesSpells", stSpell.nClass) == "1")
                            {
                                AssignCommand(stSpell.oCaster, ai_ActionCastMemorizedHealing(stSpell, nIndex, bInCombat));
                            }
                            else AssignCommand(stSpell.oCaster, ai_ActionCastKnownHealing(stSpell, nIndex, bInCombat));
                            return;
                        }
                        stSpell.nPosition++;
                    }
                }
            }
            //else ai_SendMessages(GetName(stSpell.oTarget) + " does not need any healing.", COLOR_RED, stSpell.oPC);
        }
        if(stSpell.nTarget == 0) nIndex++;
        else break;
    }
}
int ai_ConcentrationCondition(object oCreature)
{
     int nType;
     effect eEffect = GetFirstEffect(oCreature);
     while(GetIsEffectValid(eEffect))
     {
         nType = GetEffectType(eEffect);
         if(nType == EFFECT_TYPE_STUNNED || nType == EFFECT_TYPE_PARALYZE ||
             nType == EFFECT_TYPE_SLEEP || nType == EFFECT_TYPE_FRIGHTENED ||
             nType == EFFECT_TYPE_PETRIFY || nType == EFFECT_TYPE_CONFUSED ||
             nType == EFFECT_TYPE_DOMINATED || nType == EFFECT_TYPE_POLYMORPH)
         {
             return TRUE;
         }
         eEffect = GetNextEffect(oCreature);
     }
    return FALSE;
}
void ai_SpellConcentrationCheck(object oCaster = OBJECT_SELF)
{
    object oMaster = GetMaster();
    if(GetLocalInt(oCaster,"X2_L_CREATURE_NEEDS_CONCENTRATION"))
    {
        if(GetIsObjectValid(oMaster))
        {
            int nAction = GetCurrentAction(oMaster);
            // master doing anything that requires attention and breaks concentration
            if(nAction == ACTION_DISABLETRAP || nAction == ACTION_TAUNT ||
                nAction == ACTION_PICKPOCKET || nAction ==ACTION_ATTACKOBJECT ||
                nAction == ACTION_COUNTERSPELL || nAction == ACTION_FLAGTRAP ||
                nAction == ACTION_CASTSPELL || nAction == ACTION_ITEMCASTSPELL)
            {
                SignalEvent(oCaster,EventUserDefined(X2_EVENT_CONCENTRATION_BROKEN));
            }
            else if(ai_ConcentrationCondition(oMaster))
            {
                SignalEvent(oCaster,EventUserDefined(X2_EVENT_CONCENTRATION_BROKEN));
            }
        }
    }
}
int ai_CastInMelee(object oCreature, int nSpell, int nInMelee)
{
    // If this is a spell and we are in melee.
    if(nInMelee > 0 && !GetHasFeat(FEAT_EPIC_IMPROVED_COMBAT_CASTING, oCreature))
    {
        // Using DC 19 so we will use with up to a 50% failure.
        int nSpellLevel = StringToInt(Get2DAString("ai_spells", "Innate", nSpell));
        int nDC = AI_DEFENSIVE_CASTING_DC + nSpellLevel;
        int nRoll = Random(AI_DEFENSIVE_CASTING_DIE) + 1;
        int nConcentration = GetSkillRank(SKILL_CONCENTRATION, oCreature);
        if(GetHasFeat(FEAT_COMBAT_CASTING, oCreature)) nConcentration += 4;
        ai_Debug("0i_spells", "1081", "Use Defensive Casting? nDC: " + IntToString(nDC) + " FEAT_COMBAT_CASTING: " +
               IntToString(GetHasFeat(FEAT_COMBAT_CASTING, oCreature)) +
               " nConcentration: " + IntToString(nConcentration) + " + nRoll: " + IntToString(nRoll));
        if(nConcentration + nRoll > nDC)
        {
            ai_Debug("0i_spells", "1086", GetName(oCreature) + " is casting defensively!");
            SetActionMode(oCreature, ACTION_MODE_DEFENSIVE_CAST, TRUE);
        }
        // Defensive casting is a bad idea so maybe casting anyspell is a bad idea.
        else
        {
            object oMelee = GetLocalObject(oCreature, AI_ENEMY_NEAREST);
            if(GetIsObjectValid(oMelee))
            {
                nRoll = Random(AI_CASTING_IN_MELEE_ROLL) + 1;
                nDC = AI_CASTING_IN_MELEE_DC + nSpellLevel + nInMelee * ai_GetCreatureAttackBonus(oMelee);
                ai_Debug("0i_spells", "1097", "Cast anyway: nConcentration: " + IntToString(nConcentration) +
                       " nRoll: " + IntToString(nRoll) + " nDC: " + IntToString(nDC) +
                       " oMelee: " + GetName(oMelee));
                if(nConcentration + nRoll > nDC) return TRUE;
                ai_Debug("0i_spells", "1101", GetName(oCreature) + " is not casting in melee against " + GetName(oMelee));
                return FALSE;
            }
        }
    }
    // We don't need to cast defensively so lets make sure it's off.
    else if(GetActionMode(oCreature, ACTION_MODE_DEFENSIVE_CAST))
    {
        SetActionMode(oCreature, ACTION_MODE_DEFENSIVE_CAST, FALSE);
    }
    return TRUE;
}
float ai_GetOffensiveSpellSearchRange(object oCreature, int nSpell)
{
    // Search the spell range + the distance to the closest enemy - 7.5 meters).
    // This will keep the caster from running up on an enemy to cast.
    // But allow them to move up some if needed.
    float fRange = ai_GetSpellRange(nSpell);
    object oNearestEnemy = GetLocalObject(oCreature, AI_ENEMY_NEAREST);
    float fEnemyDistance = GetDistanceBetween(oCreature, oNearestEnemy);
    // Spell range is greater than the nearest enemy. Restrict based on nearest enemy.
    if(fRange > fEnemyDistance) fRange = fRange + fEnemyDistance - 7.5;
    // Spell range is less than the nearestenemy. Check enemy action then adjust.
    else
    {
        // We check this because if the enemy is moving or has not started acting
        // then we don't want to move up on them as they might move towards us!
        int nAction = GetCurrentAction(oNearestEnemy);
        ai_Debug("0i_spells", "1130", GetName(oNearestEnemy) + " current action: " + IntToString(nAction));
        if(nAction != ACTION_MOVETOPOINT &&
           nAction != ACTION_INVALID &&
           nAction != ACTION_RANDOMWALK) fRange = fEnemyDistance + (fRange - 7.5);
    }
    if(fRange > AI_RANGE_BATTLEFIELD) return AI_RANGE_BATTLEFIELD;
    else if(fRange < 0.1f) return 0.1f;
    return fRange;
}
int ai_ShouldWeCastThisCureSpell(int nSpell, int nHpLost)
{
    ai_Debug("0i_spells", "1127", "nSpell: " + IntToString(nSpell) + " nHpLost: " +
             IntToString(nHpLost));
    if(nSpell == SPELL_HEAL && nHpLost > 50) return TRUE;
    else if(nSpell == SPELL_CURE_CRITICAL_WOUNDS && nHpLost > 32) return TRUE;
    else if(nSpell == SPELL_CURE_SERIOUS_WOUNDS && nHpLost > 24) return TRUE;
    else if(nSpell == SPELL_CURE_MODERATE_WOUNDS && nHpLost > 16) return TRUE;
    else if(nSpell == SPELL_CURE_LIGHT_WOUNDS && nHpLost > 8) return TRUE;
    else if(nSpell == SPELL_CURE_MINOR_WOUNDS) return TRUE;
    return FALSE;
}
