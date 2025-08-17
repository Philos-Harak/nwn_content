/*////////////////////////////////////////////////////////////////////////////////////////////////////
 Script Name: 0i_spells
 Programmer: Philos
//////////////////////////////////////////////////////////////////////////////////////////////////////
 Include scripts for base spells.

Category:
   Enhancement E
    Protection P
Indiscriminant I
  Discriminant D
         Range R
         Touch T
        Summon S
       Healing H
          Cure C

Buff Duration:
1 - All
2 - Short
3 - Long

Buff Target:
 0  - Caster only
 1-6  Str, Dex, Con, Int, Wis, Cha: Highest Ability Score
 7  - Lowest AC
 8  - Lowest AC without AC Bonus
 9  - Highest Atk
 10 - Most Wounded
 11 - Lowest Fortitude
 12 - Lowest Reflex
 13 - Lowest Will
 14 - Lowest total saves
 15 - Buffs an Item

Buff Groups:
-1  - Elemental Resistances.
-2  - Summons
-3  - AC (Non armor)
-4  - AC (for Armor/Shield)
-5  - Chance to Miss (Invisibility)
-6  - Regeneration
-7  - Globes of Invulnerablitity
-8  - Damage Reduction
-9  - Mantles
-10 - Alignment vs Chaos
-11 - Alignment vs Evil
-12 - Alignment vs Good
-13 - Alignment vs Law
-14 - Atk Bonus (for Weapon)
-15 - Light effects
-16 - Haste effects
-17 - Polymorph effects
*/////////////////////////////////////////////////////////////////////////////////////////////////////
#include "0i_messages"
#include "0i_states_cond"
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
// Gets the total caster levels for nClass for oCreature.
int ai_GetCasterTotalLevel(object oCreature, int nClass);
// Returns TRUE if oCreature can cast nSpell from nLevel.
int ai_GetCanCastSpell(object oCreature, int nSpell, int nClass, int nLevel, int nMetaMagic = 0, int nDomain = 0);
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
// Returns 1(TRUE) if oAssociate is a spellcaster.
// Rturns 2(TRUE) if oAssociate is a memorizing spellcaster.
int ai_GetIsSpellCaster(object oAssociate);
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
int ai_IsSilenced(object oCreature, int nSpell);
// Returns TRUE if ArcaneSpellFailure is too high to chance casting the spell.
int ai_ArcaneSpellFailureTooHigh(object oCreature, int nClass, int nLevel, int nSlot);
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
// Casts a memorized spell from oCaster of nClass, nSpellLevel, nSpellSlot on oTarget.
void ai_CastMemorizedSpell(object oCaster, int nClass, int nSpellLevel, int nSpellSlot, object oTarget, int bInstant, object oPC = OBJECT_INVALID);
// Casts a known spell from oCaster of nClass, nSpell on oTarget.
void ai_CastKnownSpell(object oCaster, int nClass, int nSpell, object oTarget, int bInstant, object oPC = OBJECT_INVALID);
// Returns true if the spell is cast.
// Checks if they have the spell and will cast it if possible.
int ai_CheckAndCastSpell(object oCaster, int nSpell, int nSpellGroup, float fDelay, object oTarget, object oPC = OBJECT_INVALID);
// Setup monsters for oCaster to buff in ai_CastSpells.
void ai_SetupMonsterBuffTargets(object oCaster);
// Setup the targets for an NPC to buff one of the PC's members or the whole group.
void ai_SetupAllyTargets(object oCaster, object oPC);
// Setup the targets for an NPC to heal one of the PC's members.
void ai_SetupAllyHealingTargets(object oCaster, object oPC);
// Clears the casters buff targets.
void ai_ClearBuffTargets(object oCaster, string sVariable);
// Cycles through a casters spells casting all buffs via actions.
void ai_ActionCastMemorizedBuff(struct stSpell stSpell);
// Cycles through a casters spells casting all buffs via actions.
void ai_ActionCastKnownBuff(struct stSpell stSpell);
// Checks oCaster for buffing spells and casts them based on nTarget;
// These are cast as actions and will happen at the speed based on
// AI_HENCHMAN_BUFF_DELAY, but are still actions.
// nTarget is 0-9 where 0 is all targets, 1 is oPC, 2 is the caster
// 3 Familiar, 4 is Animal Companion, 5 is Summons, 6 is Dominated, and 7+ is henchman.
// Targets must be defined in variable AI_ALLY_TARGET_* where * is 1 to #.
// nBuffType is the duration 1 - all, 2 - short, 3 - long.
void ai_CastBuffs(object oCaster, int nBuffType, int nTarget, object oPC);
// Returns TRUE if oCaster cast spontaneous cure spell on oTarget.
// This uses an action and must use AssignCommand or OBJECT_SELF is the caster!
int ai_CastSpontaneousCure(object oCreature, object oTarget, object oPC);
// Returns TRUE if oCaster casts a memorized cure spell on oTarget.
// This uses an action and must use AssignCommand or OBJECT_SELF is the caster!
int ai_CastMemorizedHealing(object oCreature, object oTarget, object oPC, int nClass);
// Returns TRUE if oCaster casts a known cure spell on oTarget.
// This uses an action and must use AssignCommand or OBJECT_SELF is the caster!
int ai_CastKnownHealing(object oCreature, object oTarget, object oPC, int nClass);
// Returns TRUE if oCreature has an effect that will break their concentration.
int ai_ConcentrationCondition(object oCreature);
// Check to see if a spell's concentration has been broken, works for summons as well.
void ai_SpellConcentrationCheck(object oCaster);
// Returns TRUE if oCreature can safely cast nSpell defensively or has a good
// chance of casting while in melee.
int ai_CastInMelee(object oCreature, int nSpell, int nInMelee);
// Returns a float range for the caster to search for a target of an offensive spell.
float ai_GetOffensiveSpellSearchRange(object oCreature, int nSpell);
// Returns TRUE if nSpell is a cure spell and will not over heal for nDamage.
int ai_ShouldWeCastThisCureSpell(int nSpell, int nDamage);
// Casts the spell on the current target for oAssociate.
void ai_CastWidgetSpell(object oPC, object oAssociate, object oTarget, location lLocation);
// Uses the feat on the current target for oAssociate.
void ai_UseWidgetFeat(object oPC, object oAssociate, object oTarget, location lLocation);
// Uses the item on the current target for oAssociate.
void ai_UseWidgetItem(object oPC, object oAssociate, object oTarget, location lLocation);
int ai_GetCasterTotalLevel(object oCreature, int nClass)
{
    int nIndex, nCheckClass;
    int nLevel = GetLevelByClass(nClass, oCreature);
    if(nClass == CLASS_TYPE_BARD || nClass == CLASS_TYPE_SORCERER || nClass == CLASS_TYPE_WIZARD)
    {
        for(nIndex = 1; nIndex <= AI_MAX_CLASSES_PER_CHARACTER; nIndex ++)
        {
            nCheckClass = GetClassByPosition(nIndex, oCreature);
            if(nCheckClass == CLASS_TYPE_PALE_MASTER)
            {
                nLevel += (GetLevelByClass(CLASS_TYPE_PALE_MASTER, oCreature) + 1) / 2;
            }
        }
    }
    return nLevel;
}
int ai_GetCanCastSpell(object oCreature, int nSpell, int nClass, int nLevel, int nMetaMagic = 0, int nDomain = 0)
{
    int nIndex, nSpellCount, nClassPosition, nSlot, nMaxSlots, nPosition = 1;
    while(nPosition <= AI_MAX_CLASSES_PER_CHARACTER)
    {
        nClassPosition = GetClassByPosition(nPosition, oCreature);
        if(nClassPosition == CLASS_TYPE_INVALID) return FALSE;
        if(nClass = nClassPosition)
        {
            if(Get2DAString("classes", "SpellCaster", nClass) == "1")
            {
                nSlot = 0;
                if(Get2DAString("classes", "MemorizesSpells", nClass) == "1")
                {
                    nMaxSlots = GetMemorizedSpellCountByLevel(oCreature, nClass, nLevel);
                    while(nSlot < nMaxSlots)
                    {
                        if(GetMemorizedSpellId(oCreature, nClass, nLevel, nSlot) == nSpell &&
                           GetMemorizedSpellReady(oCreature, nClass, nLevel, nSlot)) return TRUE;
                        nSlot++;
                    }
                }
                else return GetSpellUsesLeft(oCreature, nClass, nSpell, nMetaMagic, nDomain);
            }
        }
        nPosition++;
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
int ai_GetIsSpellCaster(object oAssociate)
{
    int nIndex, nSpellCaster, nClass;
    for(nIndex = 1; nIndex <= AI_MAX_CLASSES_PER_CHARACTER; nIndex++)
    {
        nClass = GetClassByPosition(nIndex, oAssociate);
        if(nClass == CLASS_TYPE_INVALID) return nSpellCaster;
        if(Get2DAString("classes", "SpellCaster", nClass) == "1")
        {
            if(Get2DAString("classes", "MemorizesSpells", nClass) == "1") return 2;
            else nSpellCaster = 1;
        }
    }
    return nSpellCaster;
}
int ai_GetIsSpellBookRestrictedCaster(object oAssociate)
{
    int nIndex, nSpellCaster, nClass;
    for(nIndex = 1; nIndex <= AI_MAX_CLASSES_PER_CHARACTER; nIndex++)
    {
        nClass = GetClassByPosition(nIndex, oAssociate);
        if(nClass == CLASS_TYPE_INVALID) return FALSE;
        if(Get2DAString("classes", "SpellbookRestricted", nClass) == "1") return TRUE;
    }
    return FALSE;
}
// This is used to set immunities on a creature not using the AI.
// Should only update every minute.
void ai_SetCreatureItemImmunities(object oCreature)
{
    // Create an Immunity in json so we can check item immunities quickly for non-AI creatures.
    SetLocalInt(oCreature, sIPTimeStampVarname, ai_GetCurrentTimeStamp());
    if(AI_DEBUG) ai_Debug("0i_spells", "402", "Checking for Item immunities on " + GetName(oCreature));
    int nSpellImmunity, bHasItemImmunity, nSlot;
    json jImmunity = JsonArray();
    DeleteLocalInt(oCreature, sIPImmuneVarname);
    DeleteLocalInt(oCreature, sIPResistVarname);
    DeleteLocalInt(oCreature, sIPReducedVarname);
    int nIprpSubType, nSpell, nLevel, nIPType, nIndex;
    itemproperty ipProp;
    // Cycle through all the creatures equiped items.
    object oItem = GetItemInSlot(nSlot, oCreature);
    while(nSlot < 12)
    {
        if(oItem != OBJECT_INVALID)
        {
            if(AI_DEBUG) ai_Debug("0i_spells", "416", "Checking Item immunities on " + GetName(oItem));
            ipProp = GetFirstItemProperty(oItem);
            // Check for immunities on items.
            while(GetIsItemPropertyValid(ipProp))
            {
                nIPType = GetItemPropertyType(ipProp);
                if(AI_DEBUG) ai_Debug("0i_spells", "422", "ItempropertyType(53/20/23/22): " + IntToString(nIPType));
                if(nIPType == ITEM_PROPERTY_IMMUNITY_SPECIFIC_SPELL)
                {
                    bHasItemImmunity = TRUE;
                    nSpellImmunity = GetItemPropertyCostTableValue(ipProp);
                    nSpellImmunity = StringToInt(Get2DAString("iprp_spellcost", "SpellIndex", nSpellImmunity));
                    //if(AI_DEBUG) ai_Debug("0i_talents", "1950", "SpellImmunity to " + Get2DAString("spells", "Label", nSpellImmunity));
                    jImmunity = JsonArrayInsert(jImmunity, JsonInt(nSpellImmunity));
                }
                else if(nIPType == ITEM_PROPERTY_IMMUNITY_DAMAGE_TYPE)
                {
                    int nBit, nIpSubType = GetItemPropertySubType(ipProp);
                    if(AI_DEBUG) ai_Debug("0i_talents", "434", "Immune DmgType: nIPSubType: " + IntToString(nIpSubType));
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
                    if(AI_DEBUG) ai_Debug("0i_talents", "452", "Dmg Resist: nIPSubType: " + IntToString(nIpSubType));
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
                    if(AI_DEBUG) ai_Debug("0i_talents", "470", "Dmg Reduction: nIPSubType: " + IntToString(nIpSubType));
                    SetLocalInt(oCreature, sIPReducedVarname, nIpSubType);
                }
                nIndex++;
                ipProp = GetNextItemProperty(oItem);
            }
            // If nSpellImmunity has been set then we need to save our Immunity json.
            if(bHasItemImmunity) SetLocalJson(oCreature, AI_TALENT_IMMUNITY, jImmunity);
        }
        oItem = GetItemInSlot(++nSlot, oCreature);
        // Make the final check the creatures hide.
        if(nSlot == 11) oItem = GetItemInSlot(INVENTORY_SLOT_CARMOUR, oCreature);
    }
}
int ai_CreatureImmuneToEffect(object oCaster, object oCreature, int nSpell)
{
    // This checks for creatures not using the AI system (usually players)
    // Creatures using the AI system will always have a value in sIPReducedVarname!
    // Updates thier immunity values every minute. Should be good as we only update
    // equiped items. Spell effects are checked on the creature and are not saved.
    if(AI_DEBUG)
    {
        if(GetLocalInt(oCreature, sIPReducedVarname) == 0) ai_Debug("0i_spells", "492",
           " Immunities last saved: " + IntToString(GetLocalInt(oCreature, sIPTimeStampVarname)) +
           " + 60 < " + IntToString(ai_GetCurrentTimeStamp()));
    }
    if(GetLocalInt(oCreature, sIPReducedVarname) == 0 &&
       GetLocalInt(oCreature, sIPTimeStampVarname) + 60 < ai_GetCurrentTimeStamp()) ai_SetCreatureItemImmunities(oCreature);
    string sIType = Get2DAString("ai_spells", "ImmunityType", nSpell);
    if(AI_DEBUG) ai_Debug("0i_spells", "499", "Checking spell immunity type(" + sIType + ").");
    if(sIType != "")
    {
        if(sIType == "Death" && GetIsImmune(oCreature, IMMUNITY_TYPE_DEATH)) return TRUE;
        else if(sIType == "Level_Drain" && GetIsImmune(oCreature, IMMUNITY_TYPE_NEGATIVE_LEVEL)) return TRUE;
        else if(sIType == "Ability_Drain" && GetIsImmune(oCreature, IMMUNITY_TYPE_ABILITY_DECREASE)) return TRUE;
        else if(sIType == "Poison" && GetIsImmune(oCreature, IMMUNITY_TYPE_POISON)) return TRUE;
        else if(sIType == "Disease" && GetIsImmune(oCreature, IMMUNITY_TYPE_DISEASE)) return TRUE;
        else if(sIType == "Curse" && GetIsImmune(oCreature, IMMUNITY_TYPE_CURSED)) return TRUE;
        else if(sIType == "Mind_Affecting" && GetIsImmune(oCreature, IMMUNITY_TYPE_MIND_SPELLS)) return TRUE;
        else if(sIType == "Petrification" && ai_IsImmuneToPetrification(oCaster, oCreature)) return TRUE;
        else if(sIType == "Fear" &&
          (GetIsImmune(oCreature, IMMUNITY_TYPE_FEAR) ||
           GetIsImmune(oCreature, IMMUNITY_TYPE_MIND_SPELLS))) return TRUE;
        else if(sIType == "Sleep" &&
          (GetIsImmune(oCreature, IMMUNITY_TYPE_SLEEP) ||
           GetIsImmune(oCreature, IMMUNITY_TYPE_MIND_SPELLS))) return TRUE;
        else if(sIType == "Paralysis" &&
          (GetIsImmune(oCreature, IMMUNITY_TYPE_PARALYSIS) ||
           GetIsImmune(oCreature, IMMUNITY_TYPE_MIND_SPELLS))) return TRUE;
        else if(sIType == "Domination" &&
          (GetIsImmune(oCreature, IMMUNITY_TYPE_DOMINATE) ||
           GetIsImmune(oCreature, IMMUNITY_TYPE_MIND_SPELLS))) return TRUE;
        else if(sIType == "Confusion" &&
          (GetIsImmune(oCreature, IMMUNITY_TYPE_CONFUSED) ||
           GetIsImmune(oCreature, IMMUNITY_TYPE_MIND_SPELLS))) return TRUE;
        else if(sIType == "Blindness" &&
          (GetIsImmune(oCreature, IMMUNITY_TYPE_BLINDNESS) ||
           GetIsImmune(oCreature, IMMUNITY_TYPE_MIND_SPELLS))) return TRUE;
        else if(sIType == "Dazed" &&
          (GetIsImmune(oCreature, IMMUNITY_TYPE_DAZED) ||
           GetIsImmune(oCreature, IMMUNITY_TYPE_MIND_SPELLS))) return TRUE;
        else if(sIType == "Charm" &&
          (GetIsImmune(oCreature, IMMUNITY_TYPE_CHARM) ||
           GetIsImmune(oCreature, IMMUNITY_TYPE_MIND_SPELLS))) return TRUE;
        // Check for damage immunities.
        // Negative damage does not work on undead!
        else if(sIType == "Negative" && GetRacialType(oCreature) == RACIAL_TYPE_UNDEAD)
        {
            if(AI_DEBUG) ai_Debug("0i_spell", "538", "Undead are immune to Negative energy!");
            return TRUE;
        }
        // Elemental damage resistances should be checked.
        if(sIType == "Acid" || sIType == "Cold"  || sIType == "Fire" ||
            sIType == "Electricty" || sIType == "Sonic")
        {
            if(ai_GetHasEffectType(oCreature, EFFECT_TYPE_DAMAGE_RESISTANCE))
            {
                if(AI_DEBUG) ai_Debug("0i_spell", "547", GetName(oCreature) + " has damage resistance to my " + sIType + " spell!");
                return TRUE;
            }
            // Check for resistances and immunities. Treat resistance as immune.
            int nIPResist = GetLocalInt(oCreature, sIPResistVarname);
            if(AI_DEBUG) ai_Debug("0i_spell", "552", "nIPResist:" + IntToString(nIPResist));
            int nIPImmune = GetLocalInt(oCreature, sIPImmuneVarname) | nIPResist;
            if(AI_DEBUG) ai_Debug("0i_spell", "554", "nIPImmune:" + IntToString(nIPImmune));
            int bImmune;
            if(nIPImmune > 0)            {

                if(sIType == "Acid" && (nIPImmune & DAMAGE_TYPE_ACID)) bImmune = TRUE;
                else if(sIType == "Cold" && (nIPImmune & DAMAGE_TYPE_COLD)) bImmune = TRUE;
                else if(sIType == "Fire" && (nIPImmune & DAMAGE_TYPE_FIRE)) bImmune = TRUE;
                else if(sIType == "Electricity" && (nIPImmune & DAMAGE_TYPE_ELECTRICAL)) bImmune = TRUE;
                else if(sIType == "Sonic" && (nIPImmune & DAMAGE_TYPE_SONIC)) bImmune = TRUE;
            }
            if(bImmune)
            {
                if(AI_DEBUG) ai_Debug("0i_spell", "567", GetName(oCreature) + " is immune/resistant to my " + sIType + " spell through an item!");
                return TRUE;
            }
        }
    }
    int nLevel = StringToInt(Get2DAString("spells", "Innate", nSpell));
    // Globe spells should be checked...
    if((GetHasSpellEffect(SPELL_MINOR_GLOBE_OF_INVULNERABILITY, oCreature) ||
        GetHasSpellEffect(SPELL_GREATER_SHADOW_CONJURATION_MINOR_GLOBE, oCreature)) &&
        nLevel < 4 && d100() < 75) return TRUE;
    if(GetHasSpellEffect(SPELL_GLOBE_OF_INVULNERABILITY, oCreature) &&
        nLevel < 5 && d100() < 75) return TRUE;
    // Check creatures items for immunity.
    int nIndex;
    json jSpellImmunity = GetLocalJson(oCreature, AI_TALENT_IMMUNITY);
    json jSpell = JsonArrayGet(jSpellImmunity, nIndex);
    while(JsonGetType(jSpell) != JSON_TYPE_NULL)
    {
        if(nSpell == JsonGetInt(jSpell))
        {
            if(AI_DEBUG) ai_Debug("0i_spells", "581", GetName(oCreature) + " is immune to the spell via an Item!");
            return TRUE;
        }
        jSpell = JsonArrayGet(jSpellImmunity, ++nIndex);
    }
    if(AI_DEBUG) ai_Debug("0i_spell", "586", GetName(oCreature) + " is not immune to the spell.");
    return FALSE;
}
float ai_GetSpellRange(int nSpell)
{
    string sRange = Get2DAString("spells", "Range", nSpell);
    if(sRange == "S") return AI_SHORT_DISTANCE;
    else if(sRange == "M") return AI_MEDIUM_DISTANCE;
    else if(sRange == "L") return AI_LONG_DISTANCE;
    else if(sRange == "T") return AI_RANGE_MELEE;
    return 0.1;
}
int ai_CreatureHasDispelableEffect(object oCaster, object oCreature)
{
    int nSpellID, nLastSpellID, bSpell, nDispelChance;
    // Cycle through the targets effects.
    effect eEffect = GetFirstEffect(oCreature);
    if(AI_DEBUG) ai_Debug("0i_spells", "485", "nSpell: " + GetStringByStrRef(StringToInt(Get2DAString("spells", "Name", GetEffectSpellId(eEffect)))) +
                     " oCreature: " + GetName(oCreature));
    while(GetIsEffectValid(eEffect))
    {
        nSpellID = GetEffectSpellId(eEffect);
        // -1 is not a spell.
        if(AI_DEBUG) ai_Debug("0i_spells", "491", "nSpell: (" + IntToString(nSpellID) + ") " +
                            GetStringByStrRef(StringToInt(Get2DAString("spells", "Name", nSpellID))));
        if(nSpellID > -1 && nLastSpellID != nSpellID)
        {
            // We check if the spell is Hostile(-1) or Helpful(+1).
            if(Get2DAString("ai_spells", "HostileSetting", nSpellID) == "1") nDispelChance--;
            else nDispelChance++;
            if(AI_DEBUG) ai_Debug("0i_spells", "497", "HostileSetting: " + Get2DAString("ai_spells", "HostileSetting", nSpellID) +
                                   " nDispelChance: " + IntToString(nDispelChance));
        }
        nLastSpellID = nSpellID;
        eEffect = GetNextEffect(oCreature);
    }
    // if the target has more Helpful spells than harmful spells effecting them
    // then use dispel!
    if(AI_DEBUG) ai_Debug("0i_spells", "505", "nDispelChance: " + IntToString(nDispelChance));
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
int ai_IsSilenced(object oCreature, int nSpell)
{
    if(Get2DAString("spells", "VS", nSpell) == "s") return FALSE;
    if(ai_GetHasEffectType(oCreature, EFFECT_TYPE_SILENCE)) return TRUE;
    return FALSE;
}
int ai_ArcaneSpellFailureTooHigh(object oCreature, int nClass, int nLevel, int nSlot)
{
    if(AI_DEBUG) ai_Debug("0i_spells", "746", "Arcane Spells: " + Get2DAString("classes", "ASF", nClass) +
             " Arcane Spell Failure: " + IntToString(GetArcaneSpellFailure(oCreature)) +
             " > " + IntToString(AI_ASF_WILL_USE) + " skip.");
    if(Get2DAString("classes", "ASF", nClass) == "1" &&
       GetArcaneSpellFailure(oCreature) > AI_ASF_WILL_USE)
    {
        if(GetMemorizedSpellMetaMagic(oCreature, nClass, nLevel, nSlot) == METAMAGIC_STILL) return FALSE;
        return TRUE;
    }
    return FALSE;
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
    int nCounter;
    for(nCounter = -1; nCounter <= AI_BUFF_GROUPS; nCounter--)
    {
        DeleteLocalInt(oCreature, "AI_USED_SPELL_GROUP_" + IntToString(nCounter));
    }
}
int ai_CanUseSpell(object oCaster, object oTarget, int nSpell, int nTargetType)
{
    // Should we ignore associates?
    if(ai_GetAIMode(oCaster, AI_MODE_IGNORE_ASSOCIATES) &&
       GetAssociateType(oTarget) > 1) return FALSE;
    // For ability scores we return a bonus to the ability to be checked against
    // the target with the highest ability getting the spell first.
    if(nTargetType == 1) // Ability score buff for strength.
    {
        // We don't want to buff the strength for someone using weapon finesse!
        if(GetHasFeat(FEAT_WEAPON_FINESSE, oTarget)) return -5;
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
    if(ai_GetMagicMode(oCaster, AI_MAGIC_BUFF_MASTER))
    {
        object oMaster = GetMaster();
        if(!GetHasSpellEffect(nSpell, oMaster) &&
           ai_SpellGroupNotCast(oMaster, sBuffGroup)) return oMaster;
    }
    int nCntr = 1, nAB, nHighAB, nTarget, nUseSpell;
    object oTarget = GetLocalObject(oCaster, sTargetType + IntToString(nCntr));
    while (nCntr < 10)
    {
        if(oTarget != OBJECT_INVALID && !GetHasSpellEffect(nSpell, oTarget) &&
           GetDistanceBetween(oCaster, oTarget) <= fRange)
        {
            nUseSpell = ai_CanUseSpell(oCaster, oTarget, nSpell, nAbilityScore + 1);
            if(nUseSpell == 0) {}
            else
            {
                nAB = GetAbilityScore(oTarget, nAbilityScore) + nUseSpell;
                if(nAB > nHighAB)
                {nHighAB = nAB; nTarget = nCntr; }
            }
        }
        oTarget = GetLocalObject(oCaster, sTargetType + IntToString(++nCntr));
    }
    if(nTarget == 0) return OBJECT_INVALID;
    else return GetLocalObject(oCaster, sTargetType + IntToString(nTarget));
}
// In "Buff_Target" column this is value 7 in the "ai_spells.2da".
object ai_BuffLowestACTarget(object oCaster, int nSpell, string sBuffGroup, float fRange, string sTargetType = "AI_ALLY_TARGET_")
{
    object oMaster = GetMaster();
    if(ai_GetMagicMode(oCaster, AI_MAGIC_BUFF_MASTER))
    {
        if(!GetHasSpellEffect(nSpell, oMaster) &&
           ai_SpellGroupNotCast(oMaster, sBuffGroup) &&
           ai_CanUseSpell(oCaster, oMaster, nSpell, 7)) return oMaster;
    }
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
    if(ai_GetMagicMode(oCaster, AI_MAGIC_BUFF_MASTER))
    {
        object oMaster = GetMaster();
        if(!GetHasSpellEffect(nSpell, oMaster) &&
           ai_SpellGroupNotCast(oMaster, sBuffGroup) &&
           ai_CanUseSpell(oCaster, oMaster, nSpell, 8)) return oMaster;
    }
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
    if(ai_GetMagicMode(oCaster, AI_MAGIC_BUFF_MASTER))
    {
        object oMaster = GetMaster();
        if(!GetHasSpellEffect(nSpell, oMaster) &&
           ai_SpellGroupNotCast(oMaster, sBuffGroup) &&
           ai_CanUseSpell(oCaster, oMaster, nSpell, 9)) return oMaster;
    }
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
    if(ai_GetMagicMode(oCaster, AI_MAGIC_BUFF_MASTER))
    {
        object oMaster = GetMaster();
        if(!GetHasSpellEffect(nSpell, oMaster) &&
           ai_SpellGroupNotCast(oMaster, sBuffGroup) &&
           ai_CanUseSpell(oCaster, oMaster, nSpell, 9)) return oMaster;
    }
    int nCntr = 1, nDmg, nMostDmg, nHp, nLowHp = 10000, nTarget, nHpTarget;
    object oTarget = GetLocalObject(oCaster, sTargetType + IntToString(nCntr));
    while (nCntr < 10)
    {
        if(oTarget != OBJECT_INVALID && !GetHasSpellEffect(nSpell, oTarget) &&
           GetDistanceBetween(oCaster, oTarget) <= fRange &&
           ai_SpellGroupNotCast(oTarget, sBuffGroup) &&
           ai_CanUseSpell(oCaster, oTarget, nSpell, 10))
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
    if(ai_GetMagicMode(oCaster, AI_MAGIC_BUFF_MASTER))
    {
        object oMaster = GetMaster();
        if(!GetHasSpellEffect(nSpell, oMaster) &&
           ai_SpellGroupNotCast(oMaster, sBuffGroup) &&
           ai_CanUseSpell(oCaster, oMaster, nSpell, 11)) return oMaster;
    }
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
    if(ai_GetMagicMode(oCaster, AI_MAGIC_BUFF_MASTER))
    {
        object oMaster = GetMaster();
        if(!GetHasSpellEffect(nSpell, oMaster) &&
           ai_SpellGroupNotCast(oMaster, sBuffGroup) &&
           ai_CanUseSpell(oCaster, oMaster, nSpell, 12)) return oMaster;
    }
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
    if(ai_GetMagicMode(oCaster, AI_MAGIC_BUFF_MASTER))
    {
        object oMaster = GetMaster();
        if(!GetHasSpellEffect(nSpell, oMaster) &&
           ai_SpellGroupNotCast(oMaster, sBuffGroup) &&
           ai_CanUseSpell(oCaster, oMaster, nSpell, 13)) return oMaster;
    }
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
    if(ai_GetMagicMode(oCaster, AI_MAGIC_BUFF_MASTER))
    {
        object oMaster = GetMaster();
        if(!GetHasSpellEffect(nSpell, oMaster) &&
           ai_SpellGroupNotCast(oMaster, sBuffGroup) &&
           ai_CanUseSpell(oCaster, oMaster, nSpell, 14)) return oMaster;
    }
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
// In "Buff_Target" column this is value 15 in the "ai_spells.2da".
object ai_BuffItemTarget(object oCaster, int nSpell, string sBuffGroup, float fRange, string sTargetType = "AI_ALLY_TARGET_")
{
    if(ai_GetMagicMode(oCaster, AI_MAGIC_BUFF_MASTER))
    {
        object oMaster = GetMaster();
        if(ai_CanItemBeBuffed(nSpell, oMaster) &&
           ai_SpellGroupNotCast(oMaster, sBuffGroup)) return oMaster;
    }
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
    string sGroup = Get2DAString("ai_spells", "Buff_Group", nSpell);
    if(sGroup == "") sGroup = IntToString(nSpell);
    string sBuffGroup = "AI_USED_SPELL_GROUP_" + sGroup;
    string sBuffTarget = Get2DAString("ai_spells", "Buff_Target", nSpell);
    if(AI_DEBUG) ai_Debug("0i_spells", "769", "BuffTarget: " + sBuffTarget);
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
    if(oTarget != OBJECT_INVALID)
    {
        SetLocalInt(oTarget, sBuffGroup, TRUE);
        DelayCommand(6.0, DeleteLocalInt(oTarget, sBuffGroup));
    }
    if(AI_DEBUG) ai_Debug("0i_spells", "939", GetName(oCaster) + " is targeting " + GetName(oTarget) +
             " with " + GetStringByStrRef(StringToInt(Get2DAString("spells", "Name", nSpell))) + " spell" +
             " sBuffGroup: " + sBuffGroup + ".");
    return oTarget;
}
void ai_CastMemorizedSpell(object oCaster, int nClass, int nSpellLevel, int nSpellSlot, object oTarget, int bInstant, object oPC = OBJECT_INVALID)
{
    int nDomain;
    int nSpell = GetMemorizedSpellId(oCaster, nClass, nSpellLevel, nSpellSlot);
    if(GetMemorizedSpellIsDomainSpell(oCaster, nClass, nSpellLevel, nSpellSlot) == 1) nDomain = nSpellLevel;
    else nDomain = 0;
    int nMetaMagic = GetMemorizedSpellMetaMagic(oCaster, nClass, nSpellLevel, nSpellSlot);
    if(AI_DEBUG) ai_Debug("0i_spells", "951", "nSpell: " + IntToString(nSpell) + " oTarget: " + GetName(oTarget) +
             " nMetaMagic: " + IntToString(nMetaMagic) + " nDomain: " + IntToString(nDomain) +
             " bInstant: " + IntToString(bInstant) + " nClass: " + IntToString(nClass));
    ActionCastSpellAtObject(nSpell, oTarget, nMetaMagic, FALSE, nDomain, 0, bInstant);
    // Right now I cannot get nClass to work here...
    //DelayCommand(fDelay, ActionCastSpellAtObject(nSpell, oTarget, nMetaMagic, FALSE, nDomain, 0, TRUE, nClass));
    if(oPC != OBJECT_INVALID)
    {
        string sSpellName = GetStringByStrRef(StringToInt(Get2DAString("spells", "Name", nSpell)));
        ai_SendMessages(GetName(oCaster) + " has cast " + sSpellName + " on " + GetName(oTarget) + ".", AI_COLOR_GREEN, oPC);
    }
}
void ai_CastKnownSpell(object oCaster, int nClass, int nSpell, object oTarget, int bInstant, object oPC = OBJECT_INVALID)
{
    if(AI_DEBUG) ai_Debug("0i_Spells", "965", GetName(oCaster) + " is casting " + IntToString(nSpell));
    ActionCastSpellAtObject(nSpell, oTarget, 255, FALSE, 0, 0, bInstant);
    // Right now I cannot get nClass to work here...
    //ActionCastSpellAtObject(nSpell, oTarget, 255, FALSE, 0, 0, TRUE, nClass);
    if(oPC != OBJECT_INVALID)
    {
        string sSpellName = GetStringByStrRef(StringToInt(Get2DAString("spells", "Name", nSpell)));
        ai_SendMessages(GetName(oCaster) + " has cast " + sSpellName + " on " + GetName(oTarget) + ".", AI_COLOR_GREEN, oPC);
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
                            ai_CastMemorizedSpell(oCaster, nClass, nSpellLevel, nSpellSlot, oTarget, FALSE, oPC);
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
            ai_CastKnownSpell(oCaster, nClass, nSpell, oTarget, FALSE, oPC);
            return TRUE;
        }
        nClassCnt++;
    }
    return FALSE;
}
void ai_SetupMonsterBuffTargets(object oCaster)
{
    if(AI_DEBUG) ai_Debug("0i_spells", "1020", GetName(oCaster) + " is setting buff targets.");
    SetLocalObject (oCaster, "AI_ALLY_TARGET_1" , oCaster);
    SetLocalObject (oCaster, "AI_ALLY_TARGET_2", oCaster);
    int nCntr = 1;
    object oCreature = GetNearestCreature(CREATURE_TYPE_REPUTATION, REPUTATION_TYPE_FRIEND, oCaster, nCntr);
    if(AI_DEBUG) ai_Debug("0i_spells", "864", GetName(oCreature) + " nCntr: " + IntToString(nCntr) +
             " Distance: " + FloatToString(GetDistanceBetween(oCaster, oCreature), 0, 2));
    while(oCreature != OBJECT_INVALID && nCntr < 8 && GetDistanceBetween(oCaster, oCreature) < AI_RANGE_CLOSE)
    {
        if(AI_DEBUG) ai_Debug("0i_spells", "1133", "Setting " + GetName(oCreature) + " as AI_ALLY_TARGET_" + IntToString(nCntr + 2));
        SetLocalObject (oCaster, "AI_ALLY_TARGET_" + IntToString(nCntr + 2), oCreature);
        oCreature = GetNearestCreature(CREATURE_TYPE_REPUTATION, REPUTATION_TYPE_FRIEND, oCaster, ++nCntr);
        if(AI_DEBUG) ai_Debug("0i_spells", "1136", GetName(oCreature) + " nCntr: " + IntToString(nCntr) +
                 " Distance: " + FloatToString(GetDistanceBetween(oCaster, oCreature), 0, 2));
    }
}
void ai_SetupAllyTargets(object oCaster, object oPC)
{
    // Setup our targets.
    int nTarget;
    if(oCaster != oPC) SetLocalObject (oCaster, "AI_ALLY_TARGET_" + IntToString(++nTarget), oPC);
    SetLocalObject(oCaster, "AI_ALLY_TARGET_" + IntToString(++nTarget), oCaster);
    object oCreature = GetAssociate(ASSOCIATE_TYPE_FAMILIAR, oPC);
    if(oCreature != OBJECT_INVALID) SetLocalObject(oCaster, "AI_ALLY_TARGET_" + IntToString(++nTarget), oCreature);
    oCreature = GetAssociate(ASSOCIATE_TYPE_FAMILIAR, oCaster);
    if(oCreature != OBJECT_INVALID) SetLocalObject(oCaster, "AI_ALLY_TARGET_" + IntToString(++nTarget), oCreature);
    oCreature = GetAssociate(ASSOCIATE_TYPE_ANIMALCOMPANION, oPC);
    if(oCreature != OBJECT_INVALID) SetLocalObject(oCaster, "AI_ALLY_TARGET_" + IntToString(++nTarget), oCreature);
    oCreature = GetAssociate(ASSOCIATE_TYPE_ANIMALCOMPANION, oCaster);
    if(oCreature != OBJECT_INVALID) SetLocalObject(oCaster, "AI_ALLY_TARGET_" + IntToString(++nTarget), oCreature);
    oCreature = GetAssociate(ASSOCIATE_TYPE_SUMMONED, oPC);
    if(oCreature != OBJECT_INVALID) SetLocalObject(oCaster, "AI_ALLY_TARGET_" + IntToString(++nTarget), oCreature);
    oCreature = GetAssociate(ASSOCIATE_TYPE_SUMMONED, oCaster);
    if(oCreature != OBJECT_INVALID) SetLocalObject(oCaster, "AI_ALLY_TARGET_" + IntToString(++nTarget), oCreature);
    oCreature = GetAssociate(ASSOCIATE_TYPE_DOMINATED, oPC);
    if(oCreature != OBJECT_INVALID) SetLocalObject(oCaster, "AI_ALLY_TARGET_" + IntToString(++nTarget), oCreature);
    oCreature = GetAssociate(ASSOCIATE_TYPE_DOMINATED, oCaster);
    if(oCreature != OBJECT_INVALID) SetLocalObject(oCaster, "AI_ALLY_TARGET_" + IntToString(++nTarget), oCreature);
    int nCntr = 1;
    int nMaxHenchman = GetMaxHenchmen() + nTarget;
    object oHenchman = GetHenchman(oPC, nCntr);
    while(oHenchman != OBJECT_INVALID && nCntr <= nMaxHenchman)
    {
        if(oHenchman == OBJECT_INVALID) break;
        if(oHenchman != oCaster) SetLocalObject(oCaster, "AI_ALLY_TARGET_" + IntToString(++nTarget), oHenchman);
        oHenchman = GetHenchman(oPC, ++nCntr);
    }
    nCntr = 1;
    while(nCntr <= nMaxHenchman)
    {
        if(AI_DEBUG) ai_Debug("0i_spells", "1166", "AI_ALLY_TARGET_" + IntToString(nCntr) + ": " +
                 GetName(GetLocalObject(oCaster, "AI_ALLY_TARGET_" + IntToString(nCntr))));
        nCntr++;
    }
}
void ai_SetupAllyHealingTargets(object oCaster, object oPC)
{
    int nMaxHenchman = 1;
    if(oPC == OBJECT_INVALID) oPC = oCaster;
    if(ai_GetAIMode(oCaster, AI_MODE_PARTY_HEALING_OFF))
    {
        if(!ai_GetAIMode(oCaster, AI_MODE_SELF_HEALING_OFF)) SetLocalObject(oCaster, "AI_ALLY_HEAL_1", oCaster);
    }
    else
    {
        int nTarget;
        if(oCaster != oPC)
        {
            SetLocalObject (oCaster, "AI_ALLY_HEAL_1", oPC);
            nTarget++;
        }
        if(!ai_GetAIMode(oCaster, AI_MODE_SELF_HEALING_OFF))
        {
            SetLocalObject(oCaster, "AI_ALLY_HEAL_" + IntToString(++nTarget), oCaster);
        }
        object oCreature = GetAssociate(ASSOCIATE_TYPE_FAMILIAR, oPC);
        if(oCreature != OBJECT_INVALID) SetLocalObject(oCaster, "AI_ALLY_HEAL_" + IntToString(++nTarget), oCreature);
        oCreature = GetAssociate(ASSOCIATE_TYPE_FAMILIAR, oCaster);
        if(oCreature != OBJECT_INVALID) SetLocalObject(oCaster, "AI_ALLY_HEAL_" + IntToString(++nTarget), oCreature);
        oCreature = GetAssociate(ASSOCIATE_TYPE_ANIMALCOMPANION, oPC);
        if(oCreature != OBJECT_INVALID) SetLocalObject(oCaster, "AI_ALLY_HEAL_" + IntToString(++nTarget), oCreature);
        oCreature = GetAssociate(ASSOCIATE_TYPE_ANIMALCOMPANION, oCaster);
        if(oCreature != OBJECT_INVALID) SetLocalObject(oCaster, "AI_ALLY_HEAL_" + IntToString(++nTarget), oCreature);
        oCreature = GetAssociate(ASSOCIATE_TYPE_SUMMONED, oPC);
        if(oCreature != OBJECT_INVALID) SetLocalObject(oCaster, "AI_ALLY_HEAL_" + IntToString(++nTarget), oCreature);
        oCreature = GetAssociate(ASSOCIATE_TYPE_SUMMONED, oCaster);
        if(oCreature != OBJECT_INVALID) SetLocalObject(oCaster, "AI_ALLY_HEAL_" + IntToString(++nTarget), oCreature);
        oCreature = GetAssociate(ASSOCIATE_TYPE_DOMINATED, oPC);
        if(oCreature != OBJECT_INVALID) SetLocalObject(oCaster, "AI_ALLY_HEAL_" + IntToString(++nTarget), oCreature);
        oCreature = GetAssociate(ASSOCIATE_TYPE_DOMINATED, oCaster);
        if(oCreature != OBJECT_INVALID) SetLocalObject(oCaster, "AI_ALLY_HEAL_" + IntToString(++nTarget), oCreature);
        int nCntr = 1;
        nMaxHenchman = GetMaxHenchmen() + nTarget;
        object oHenchman = GetHenchman(oPC, nCntr);
        while(oHenchman != OBJECT_INVALID && nTarget <= nMaxHenchman)
        {
            if(oHenchman == OBJECT_INVALID) break;
            if(oHenchman != oCaster) SetLocalObject(oCaster, "AI_ALLY_HEAL_" + IntToString(++nTarget), oHenchman);
            oHenchman = GetHenchman(oPC, ++nCntr);
        }
    }
    int nCntr = 1;
    while(nCntr <= nMaxHenchman)
    {
        if(AI_DEBUG) ai_Debug("0i_spells", "1211", "AI_ALLY_HEAL_" + IntToString(nCntr) + ": " +
                 GetName(GetLocalObject(oCaster, "AI_ALLY_HEAL_" + IntToString(nCntr++))));
    }
}
void ai_ClearBuffTargets(object oCaster, string sVariable)
{
    if(AI_DEBUG) ai_Debug("0i_spells", "1216", GetName(oCaster) + " is clearing " + sVariable + " targets.");
    int nIndex;
    int nMaxTargets = GetMaxHenchmen() + 6;
    for(nIndex = 1; nIndex < nMaxTargets; nIndex++)
    {
        DeleteLocalObject (oCaster, sVariable + IntToString(nIndex));
    }
}
void ai_CheckForPerDayProperties(object oCreature, object oItem, int nBuffType, int bEquiped = FALSE)
{
    if(AI_DEBUG) ai_Debug("0i_spells", "1150", "Checking Item properties on " + GetName(oItem));
    // We have established that we can use the item if it is equiped.
    if(!bEquiped && !ai_CheckIfCanUseItem(oCreature, oItem)) return;
    int nPerDay, nCharges, nUses, nSpellBuffDuration;
    int nIprpSubType, nSpell, nLevel, nIPType, nIndex;
    object oTarget;
    itemproperty ipProp = GetFirstItemProperty(oItem);
    // Lets skip this if there are no properties.
    if(!GetIsItemPropertyValid(ipProp)) return;
    // Check for cast spell property and add them to the talent list.
    while(GetIsItemPropertyValid(ipProp))
    {
        if(AI_DEBUG) ai_Debug("0i_spells", "1163", "ItempropertyType(15): " + IntToString(GetItemPropertyType(ipProp)));
        nIPType = GetItemPropertyType(ipProp);
        if(nIPType == ITEM_PROPERTY_CAST_SPELL)
        {
            // Get how they use the item (charges or uses per day).
            nUses = GetItemPropertyCostTableValue(ipProp);
            // We only check uses per day.
            if(AI_DEBUG) ai_Debug("0i_spells", "1172", "Item uses: " + IntToString(nPerDay));
            if(nUses > 7 && nUses < 13)
            {
                nPerDay = GetItemPropertyUsesPerDayRemaining(oItem, ipProp);
                if(AI_DEBUG) ai_Debug("0i_spells", "1176", "Item uses per day: " + IntToString(nPerDay));
                if(nPerDay > 0)
                {
                    // SubType is the ip spell index for iprp_spells.2da
                    nIprpSubType = GetItemPropertySubType(ipProp);
                    nSpell = StringToInt(Get2DAString("iprp_spells", "SpellIndex", nIprpSubType));
                    nSpellBuffDuration = StringToInt(Get2DAString("ai_spells", "Buff_Duration", nSpell));
                    if(AI_DEBUG) ai_Debug("0i_spells", "1183", "nSpell: " + IntToString(nSpell) +
                             " nBuffType: " + IntToString(nBuffType) +
                             " nSpellBuffDuration: " + IntToString(nSpellBuffDuration));
                    if(nBuffType == nSpellBuffDuration || nBuffType == 1)
                    {
                        oTarget = ai_GetBuffTarget(oCreature, nSpell);
                        if(oTarget != OBJECT_INVALID)
                        {
                            if(AI_DEBUG) ai_Debug("0i_spells", "1190", GetName(oCreature) + " is using" +
                                     GetName(oItem) + " to cast " + IntToString(nSpell) +
                                     " on " + GetName(oTarget));
                            ActionUseItemOnObject(oItem, ipProp, oTarget);
                        }
                    }
                }
            }
        }
        ipProp = GetNextItemProperty(oItem);
    }
}
void ai_CheckForPerDayItems(object oCreature, object oPC, int nBuffType)
{
    if(AI_DEBUG) ai_Debug("0i_spells", "1198", GetName(oCreature) + ": Checking items for per day buffs.");
    if(!ai_GetMagicMode(oCreature, AI_MAGIC_NO_MAGIC_ITEMS))
    {
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
                if(AI_DEBUG) ai_Debug("0i_talents", "1211", GetName(oItem) + " requires " + Get2DAString("baseitems", "EquipableSlots", GetBaseItemType(oItem)) + " slots.");
                if(sSlots == "0x00000") ai_CheckForPerDayProperties(oCreature, oItem, nBuffType);
            }
            oItem = GetNextItemInInventory(oCreature);
        }
        int nSlot;
        // Cycle through all the creatures equiped items.
        oItem = GetItemInSlot(nSlot, oCreature);
        while(nSlot < 11)
        {
            if(oItem != OBJECT_INVALID) ai_CheckForPerDayProperties(oCreature, oItem, nBuffType, TRUE);
            oItem = GetItemInSlot(++nSlot, oCreature);
        }
        oItem = GetItemInSlot(INVENTORY_SLOT_CARMOUR, oCreature);
        if(oItem != OBJECT_SELF) ai_CheckForPerDayProperties(oCreature, oItem, nBuffType, TRUE);
    }
    // Clean up our variables. Must be done here since these are actions!
    int nCntr;
    object oTarget;
    while(nCntr < 11)
    {
        oTarget = GetLocalObject(oCreature, "AI_ALLY_TARGET_" + IntToString(nCntr));
        if(oTarget != OBJECT_INVALID)
        {
            ai_ClearSpellsCastGroups(oTarget);
            DeleteLocalObject(oCreature, "AI_ALLY_TARGET_" + IntToString(nCntr));
        }
        nCntr++;
    }
}
void ai_CheckForBuffSpells(struct stSpell stSpell)
{
    ai_SetupAllyTargets(stSpell.oCaster, stSpell.oPC);
    stSpell.nPosition = 1;
    stSpell.nClass = GetClassByPosition(stSpell.nPosition, stSpell.oCaster);
    stSpell.nLevel = (GetLevelByPosition(stSpell.nPosition, stSpell.oCaster) + 1) / 2;
    stSpell.nMaxSlots = GetMemorizedSpellCountByLevel(stSpell.oCaster, stSpell.nClass, stSpell.nLevel);
    stSpell.nSlot = 0;
    while(stSpell.nPosition <= AI_MAX_CLASSES_PER_CHARACTER)
    {
        stSpell.nClass = GetClassByPosition(stSpell.nPosition, stSpell.oCaster);
        if(AI_DEBUG) ai_Debug("0i_spells", "1208", "nClass: " + IntToString(stSpell.nClass));
        if(stSpell.nClass == CLASS_TYPE_INVALID) break;
        if(AI_DEBUG) ai_Debug("0i_spells", "1210", "SpellCaster: " + Get2DAString("classes", "SpellCaster", stSpell.nClass));
        if(Get2DAString("classes", "SpellCaster", stSpell.nClass) == "1")
        {
            stSpell.nLevel = (GetLevelByPosition(stSpell.nPosition, stSpell.oCaster) + 1) / 2;
            if(AI_DEBUG) ai_Debug("0i_spells", "1214", "Memorizes Spells: " + Get2DAString("classes", "MemorizesSpells", stSpell.nClass));
            if(Get2DAString("classes", "MemorizesSpells", stSpell.nClass) == "1")
            {
                stSpell.nMaxSlots = GetMemorizedSpellCountByLevel(stSpell.oCaster, stSpell.nClass, stSpell.nLevel);
                AssignCommand(stSpell.oCaster, ai_ActionCastMemorizedBuff(stSpell));
                return;
            }
            else
            {
                stSpell.nMaxSlots = GetKnownSpellCount(stSpell.oCaster, stSpell.nClass, stSpell.nLevel);
                AssignCommand(stSpell.oCaster, ai_ActionCastKnownBuff(stSpell));
                return;
            }
        }
        stSpell.nPosition++;
    }
    ai_CheckForPerDayItems(stSpell.oCaster, stSpell.oPC, stSpell.nBuffType);
}
void ai_ActionCastMemorizedSummons(struct stSpell stSpell)
{
    if(AI_DEBUG) ai_Debug("0i_spells", "1122", "Start of ActionCastMemorizedSummons!");
    int nSpell;
    string sBuffGroup, sBuffTarget;
    object oTarget;
    while(stSpell.nPosition <= AI_MAX_CLASSES_PER_CHARACTER)
    {
        //ai_Debug("0i_spells", "1128", "SpellCaster: " + Get2DAString("classes", "SpellCaster", stSpell.nClass));
        if(Get2DAString("classes", "SpellCaster", stSpell.nClass) == "1")
        {
            //ai_Debug("0i_spells", "1131", "nLevel: " + IntToString(stSpell.nLevel));
            while(stSpell.nLevel > -1)
            {
                //ai_Debug("0i_spells", "1134", "nMaxSlots: " + IntToString(stSpell.nMaxSlots) +
                //         " nSlots: " + IntToString(stSpell.nSlot));
                while(stSpell.nSlot < stSpell.nMaxSlots)
                {
                    //ai_Debug("0i_spells", "1238", "Ready: " + IntToString(GetMemorizedSpellReady(stSpell.oCaster, stSpell.nClass, stSpell.nLevel, stSpell.nSlot)));
                    if(GetMemorizedSpellReady(stSpell.oCaster, stSpell.nClass, stSpell.nLevel, stSpell.nSlot))
                    {
                        nSpell = GetMemorizedSpellId(stSpell.oCaster, stSpell.nClass, stSpell.nLevel, stSpell.nSlot);
                        //ai_Debug("0i_spells", "1142", "nSpell: " + IntToString(nSpell));
                        if(Get2DAString("ai_spells", "Category", nSpell) == "S")
                        {
                            SetLocalInt(stSpell.oCaster, "AI_USED_SPELL_GROUP_-2", TRUE);
                            ai_CastMemorizedSpell(stSpell.oCaster, stSpell.nClass, stSpell.nLevel, stSpell.nSlot, stSpell.oCaster, TRUE, stSpell.oPC);
                            stSpell.nPosition = 1;
                            stSpell.nClass = GetClassByPosition(stSpell.nPosition, stSpell.oCaster);
                            stSpell.nLevel = (GetLevelByPosition(stSpell.nPosition, stSpell.oCaster) + 1) / 2;
                            stSpell.nMaxSlots = GetMemorizedSpellCountByLevel(stSpell.oCaster, stSpell.nClass, stSpell.nLevel);
                            stSpell.nSlot = 0;
                            DelayCommand(2.0, ai_SetupAllyTargets(stSpell.oCaster, stSpell.oPC));
                            DelayCommand(2.0 + 0.5, AssignCommand(stSpell.oCaster, ai_ActionCastMemorizedBuff(stSpell)));
                            return;
                        }
                    }
                    stSpell.nSlot++;
                }
                stSpell.nLevel--;
                //ai_Debug("0i_spells", "1153", "nLevel: " + IntToString(stSpell.nLevel));
                if(stSpell.nLevel > -1)
                {
                    stSpell.nMaxSlots = GetMemorizedSpellCountByLevel(stSpell.oCaster, stSpell.nClass, stSpell.nLevel);
                    stSpell.nSlot = 0;
                }
            }
        }
        stSpell.nPosition++;
        stSpell.nClass = GetClassByPosition(stSpell.nPosition, stSpell.oCaster);
        //ai_Debug("0i_spells", "1164", "nClass: " + IntToString(stSpell.nClass));
        if(stSpell.nClass == CLASS_TYPE_INVALID) break;
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
    ai_CheckForBuffSpells(stSpell);
}
void ai_ActionCastKnownSummons(struct stSpell stSpell)
{
    //ai_Debug("0i_spells", "1184", "Start of ActionCastKnownSummons!");
    int nSpell;
    string sBuffGroup, sBuffTarget;
    object oTarget;
    while(stSpell.nPosition <= AI_MAX_CLASSES_PER_CHARACTER)
    {
        //ai_Debug("0i_spells", "1190", "SpellCaster: " + Get2DAString("classes", "SpellCaster", stSpell.nClass));
        if(Get2DAString("classes", "SpellCaster", stSpell.nClass) == "1")
        {
            //ai_Debug("0i_spells", "1193", "nLevel: " + IntToString(stSpell.nLevel));
            while(stSpell.nLevel > -1)
            {
                if(stSpell.nMaxSlots)
                {
                    //ai_Debug("0i_spells", "1198", "nMaxSlots: " + IntToString(stSpell.nMaxSlots) +
                    //         " nSlots: " + IntToString(stSpell.nSlot));
                    while(stSpell.nSlot < stSpell.nMaxSlots)
                    {
                        nSpell = GetKnownSpellId(stSpell.oCaster, stSpell.nClass, stSpell.nLevel, stSpell.nSlot);
                        //ai_Debug("0i_spells", "1203", "Ready: " + IntToString(GetSpellUsesLeft(stSpell.oCaster, stSpell.nClass, nSpell)));
                        if(GetSpellUsesLeft(stSpell.oCaster, stSpell.nClass, nSpell))
                        {
                            if(Get2DAString("ai_spells", "Category", nSpell) == "S")
                            {
                                SetLocalInt(stSpell.oCaster, "AI_USED_SPELL_GROUP_S", TRUE);
                                //ai_Debug("0i_spells", "1209", "nSpell: " + IntToString(nSpell));
                                ai_CastKnownSpell(stSpell.oCaster, stSpell.nClass, nSpell, stSpell.oCaster, TRUE, stSpell.oPC);
                                stSpell.nPosition = 1;
                                stSpell.nClass = GetClassByPosition(stSpell.nPosition, stSpell.oCaster);
                                stSpell.nLevel = (GetLevelByPosition(stSpell.nPosition, stSpell.oCaster) + 1) / 2;
                                stSpell.nMaxSlots = GetMemorizedSpellCountByLevel(stSpell.oCaster, stSpell.nClass, stSpell.nLevel);
                                stSpell.nSlot = 0;
                                ai_SetupAllyTargets(stSpell.oCaster, stSpell.oPC);
                                DelayCommand(AI_HENCHMAN_BUFF_DELAY, AssignCommand(stSpell.oCaster, ai_ActionCastKnownBuff(stSpell)));
                                return;
                            }
                        }
                        stSpell.nSlot++;
                    }
                }
                stSpell.nLevel--;
                //ai_Debug("0i_spells", "1218", "nLevel: " + IntToString(stSpell.nLevel));
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
        //ai_Debug("0i_spells", "1229", "nClass: " + IntToString(stSpell.nClass));
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
    ai_CheckForBuffSpells(stSpell);
}
void ai_ActionCastMemorizedBuff(struct stSpell stSpell)
{
    int nSpell;
    string sBuffGroup, sBuffTarget;
    object oTarget;
    while(stSpell.nPosition <= AI_MAX_CLASSES_PER_CHARACTER)
    {
        ai_Debug("0i_spells", "1252", "SpellCaster: " + Get2DAString("classes", "SpellCaster", stSpell.nClass));
        if(Get2DAString("classes", "SpellCaster", stSpell.nClass) == "1")
        {
            ai_Debug("0i_spells", "1255", "nLevel: " + IntToString(stSpell.nLevel));
            while(stSpell.nLevel > -1)
            {
                ai_Debug("0i_spells", "1258", "nMaxSlots: " + IntToString(stSpell.nMaxSlots) +
                         " nSlots: " + IntToString(stSpell.nSlot));
                while(stSpell.nSlot < stSpell.nMaxSlots)
                {
                    ai_Debug("0i_spells", "1262", "Ready: " + IntToString(GetMemorizedSpellReady(stSpell.oCaster, stSpell.nClass, stSpell.nLevel, stSpell.nSlot)));
                    if(GetMemorizedSpellReady(stSpell.oCaster, stSpell.nClass, stSpell.nLevel, stSpell.nSlot))
                    {
                        nSpell = GetMemorizedSpellId(stSpell.oCaster, stSpell.nClass, stSpell.nLevel, stSpell.nSlot);
                        int nSpellBuffDuration = StringToInt(Get2DAString("ai_spells", "Buff_Duration", nSpell));
                        ai_Debug("0i_spells", "1267", "nBuffType: " + IntToString(stSpell.nBuffType) +
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
                            ai_Debug("0i_spells", "1284", "nSpell: " + IntToString(nSpell) +
                                     " oTarget: " + GetName(oTarget));
                            if(oTarget != OBJECT_INVALID)
                            {
                                ai_CastMemorizedSpell(stSpell.oCaster, stSpell.nClass, stSpell.nLevel, stSpell.nSlot, oTarget, TRUE, stSpell.oPC);
                                stSpell.nSlot++;
                                DelayCommand(AI_HENCHMAN_BUFF_DELAY, AssignCommand(stSpell.oCaster, ai_ActionCastMemorizedBuff(stSpell)));
                                return;
                            }
                        }
                    }
                    stSpell.nSlot++;
                }
                stSpell.nLevel--;
                ai_Debug("0i_spells", "1298", "nLevel: " + IntToString(stSpell.nLevel));
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
        ai_Debug("0i_spells", "1309", "nClass: " + IntToString(stSpell.nClass));
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
    ai_CheckForPerDayItems(stSpell.oCaster, stSpell.oPC, stSpell.nBuffType);
}
void ai_ActionCastKnownBuff(struct stSpell stSpell)
{
    int nSpell;
    string sBuffGroup, sBuffTarget;
    object oTarget;
    while(stSpell.nPosition <= AI_MAX_CLASSES_PER_CHARACTER)
    {
        //ai_Debug("0i_spells", "1347", "SpellCaster: " + Get2DAString("classes", "SpellCaster", stSpell.nClass));
        if(Get2DAString("classes", "SpellCaster", stSpell.nClass) == "1")
        {
            //ai_Debug("0i_spells", "1350", "nLevel: " + IntToString(stSpell.nLevel));
            while(stSpell.nLevel > -1)
            {
                if(stSpell.nMaxSlots)
                {
                    //ai_Debug("0i_spells", "1356", "nMaxSlots: " + IntToString(stSpell.nMaxSlots) +
                    //         " nSlots: " + IntToString(stSpell.nSlot));
                    while(stSpell.nSlot < stSpell.nMaxSlots)
                    {
                        nSpell = GetKnownSpellId(stSpell.oCaster, stSpell.nClass, stSpell.nLevel, stSpell.nSlot);
                        int nSpellBuffDuration = StringToInt(Get2DAString("ai_spells", "Buff_Duration", nSpell));
                        //ai_Debug("0i_spells", "1361", "nBuffType: " + IntToString(stSpell.nBuffType) +
                        //         " nSpellBuffDuration: " + IntToString(nSpellBuffDuration) +
                        //         " sBuffGroup: " + Get2DAString("ai_spells", "Buff_Group", nSpell));
                        if(stSpell.nBuffType == nSpellBuffDuration || stSpell.nBuffType == 1)
                        {
                            //ai_Debug("0i_spells", "1367", "Ready: " + IntToString(GetSpellUsesLeft(stSpell.oCaster, stSpell.nClass, nSpell)));
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
                                //ai_Debug("0i_spells", "1382", "nSpell: " + IntToString(nSpell) +
                                //         " oTarget: " + GetName(oTarget));
                                if(oTarget != OBJECT_INVALID)
                                {
                                    ai_CastKnownSpell(stSpell.oCaster, stSpell.nClass, nSpell, oTarget, TRUE, stSpell.oPC);
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
                //ai_Debug("0i_spells", "1396", "nLevel: " + IntToString(stSpell.nLevel));
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
    ai_CheckForPerDayItems(stSpell.oCaster, stSpell.oPC, stSpell.nBuffType);
}
void ai_CastBuffs(object oCaster, int nBuffType, int nTarget, object oPC)
{
    // buff types: 1 - All, 2 - Short duration, 3 - Long duration
    // Buff groups are used to prevent a henchmen to cast spells that have the same effect,
    // for example: resist elements and protection from elements are similiar so the henchmen
    // would cast only the most powerful among these if he has them both.
    if(AI_DEBUG) ai_Debug("0i_spells", "1670", GetName(oCaster) + " is casting buffs: " + IntToString(nBuffType) +
             " nTarget: " + IntToString(nTarget) + "!");
    struct stSpell stSpell;
    stSpell.oPC = oPC;
    stSpell.oCaster = oCaster;
    stSpell.nBuffType = nBuffType;
    stSpell.nTarget = nTarget;
    stSpell.nPosition = 1;
    // Look for summons spells on All, Long durations and the whole party.
    if((nBuffType == 1 || nBuffType == 3) && nTarget == 0)
    {
        while(stSpell.nPosition <= AI_MAX_CLASSES_PER_CHARACTER)
        {
            stSpell.nClass = GetClassByPosition(stSpell.nPosition, stSpell.oCaster);
            if(AI_DEBUG) ai_Debug("0i_spells", "1684", "nClass: " + IntToString(stSpell.nClass));
            if(stSpell.nClass == CLASS_TYPE_INVALID) break;
            if(AI_DEBUG) ai_Debug("0i_spells", "1686", "SpellCaster: " + Get2DAString("classes", "SpellCaster", stSpell.nClass));
            if(Get2DAString("classes", "SpellCaster", stSpell.nClass) == "1")
            {
                stSpell.nLevel = (GetLevelByPosition(stSpell.nPosition, stSpell.oCaster) + 1) / 2;
                if(AI_DEBUG) ai_Debug("0i_spells", "1692", "MemorizesSpells: " + Get2DAString("classes", "MemorizesSpells", stSpell.nClass));
                if(Get2DAString("classes", "MemorizesSpells", stSpell.nClass) == "1")
                {
                    stSpell.nMaxSlots = GetMemorizedSpellCountByLevel(stSpell.oCaster, stSpell.nClass, stSpell.nLevel);
                    AssignCommand(stSpell.oCaster, ai_ActionCastMemorizedSummons(stSpell));
                    return;
                }
                else
                {
                    stSpell.nMaxSlots = GetKnownSpellCount(stSpell.oCaster, stSpell.nClass, stSpell.nLevel);
                    AssignCommand(stSpell.oCaster, ai_ActionCastKnownSummons(stSpell));
                    return;
                }
            }
            stSpell.nPosition++;
        }
        // Exit here; if we summoned a monster then it linked off of that spell
        // cast to continue the action queue for all buff spell cast actions.
    }
    ai_CheckForBuffSpells(stSpell);
}
int ai_CastSpontaneousCure(object oCreature, object oTarget, object oPC)
{
    if(ai_GetMagicMode(oCreature, AI_MAGIC_NO_MAGIC)) return FALSE;
    if(ai_GetMagicMode(oCreature, AI_MAGIC_NO_SPONTANEOUS_CURE)) return FALSE;
    if(AI_DEBUG) ai_Debug("0i_spells", "1643", GetName(oCreature) + " is looking to cast a spontaneous cure spell.");
    if(!GetLevelByClass(CLASS_TYPE_CLERIC, oCreature)) return FALSE;
    int nDamage = GetMaxHitPoints(oTarget) - GetCurrentHitPoints(oTarget);
    int nSpell, nSlot, nMaxSlots, nLevel = 4;
    int nSpellSave, nSlotSave, nLevelSave = 5;
    string sSpellName;
    while(nLevel > -1)
    {
        // We check CLASS_TYPE_CLERIC as thats the only class with spontaneous cure spells.
        nMaxSlots = GetMemorizedSpellCountByLevel(oCreature, CLASS_TYPE_CLERIC, nLevel);
        nSlot = 0;
        if(AI_DEBUG) ai_Debug("0i_spells", "1653", "nLevel: " + IntToString(nLevel) + " nMaxSlots: " + IntToString(nMaxSlots));
        while(nSlot < nMaxSlots)
        {
            if(AI_DEBUG) ai_Debug("0i_spells", "1656", "nSlot: " + IntToString(nSlot) +
                     " Spell Ready: " + IntToString(GetMemorizedSpellReady(oCreature, CLASS_TYPE_CLERIC, nLevel, nSlot)));
            if(GetMemorizedSpellReady(oCreature, CLASS_TYPE_CLERIC, nLevel, nSlot))
            {
                if(nLevel == 4) nSpell = SPELL_CURE_CRITICAL_WOUNDS;
                else if(nLevel == 3) nSpell = SPELL_CURE_SERIOUS_WOUNDS;
                else if(nLevel == 2) nSpell = SPELL_CURE_MODERATE_WOUNDS;
                else if(nLevel == 1) nSpell = SPELL_CURE_LIGHT_WOUNDS;
                else nSpell = 0;
                if(AI_DEBUG) ai_Debug("0i_spells", "1665", "nSpell: " + IntToString(nSpell));
                if(nSpell)
                {
                    if(ai_ShouldWeCastThisCureSpell(nSpell, nDamage))
                    {
                        SetMemorizedSpellReady(oCreature, CLASS_TYPE_CLERIC, nLevel, nSlot, FALSE);
                        sSpellName = GetStringByStrRef(StringToInt(Get2DAString("spells", "Name", nSpell)));
                        ai_SendMessages(GetName(oCreature) + " has spontaneously cast " + sSpellName + " on " + GetName(oTarget) + ".", AI_COLOR_MAGENTA, oPC);
                        if(AI_DEBUG) ai_Debug("0i_spells", "1673", GetName(oCreature) + " has spontaneously cast " + sSpellName + " on " + GetName(oTarget) + ".");
                        ActionCastSpellAtObject(nSpell, oTarget, 255, TRUE);
                        return TRUE;
                    }
                    // Save the lowest level cure spell as we might need to cast it.
                    else if(nLevel < nLevelSave)
                    {
                        nSpellSave = nSpell;
                        nLevelSave = nLevel;
                        nSlotSave = nSlot;
                    }
                }
            }
            nSlot++;
        }
        nLevel--;
    }
    // Did we find a cure spell? If we did then use it.
    if(nSpellSave)
    {
        if(AI_DEBUG) ai_Debug("0i_spells", "1693", GetName(oCreature) + " has cast the lowest level cure spell on " + GetName(oTarget) + ".");
        SetMemorizedSpellReady(oCreature, CLASS_TYPE_CLERIC, nLevelSave, nSlotSave, FALSE);
        sSpellName = GetStringByStrRef(StringToInt(Get2DAString("spells", "Name", nSpellSave)));
        ai_SendMessages(GetName(oCreature) + " has spontaneously cast " + sSpellName + " on " + GetName(oTarget) + ".", AI_COLOR_MAGENTA, oPC);
        ActionCastSpellAtObject(nSpellSave, oTarget, 255, TRUE);
        return TRUE;
    }
    return FALSE;
}
int ai_CastMemorizedHealing(object oCreature, object oTarget, object oPC, int nClass)
{
    if(AI_DEBUG) ai_Debug("0i_spells", "1702", GetName(oCreature) + " is looking to cast a memorized cure spell.");
    int nDamage = GetMaxHitPoints(oTarget) - GetCurrentHitPoints(oTarget);
    int nSpell, nSlot, nMaxSlots, nLevel = 9;
    int nClassSave, nSlotSave, nLevelSave = 10;
    while(nLevel > -1)
    {
        nMaxSlots = GetMemorizedSpellCountByLevel(oCreature, nClass, nLevel);
        nSlot = 0;
        if(AI_DEBUG) ai_Debug("0i_spells", "1710", "nLevel: " + IntToString(nLevel) + " nMaxSlots: " + IntToString(nMaxSlots));
        while(nSlot < nMaxSlots)
        {
            if(AI_DEBUG) ai_Debug("0i_spells", "1713", "nSlot: " + IntToString(nSlot) +
                     " Spell Ready: " + IntToString(GetMemorizedSpellReady(oCreature, nClass, nLevel, nSlot)));
            if(GetMemorizedSpellReady(oCreature, nClass, nLevel, nSlot))
            {
                nSpell = GetMemorizedSpellId(oCreature, nClass, nLevel, nSlot);
                if(ai_ShouldWeCastThisCureSpell(nSpell, nDamage))
                {
                    string sSpellName = GetStringByStrRef(StringToInt(Get2DAString("spells", "Name", nSpell)));
                    if(AI_DEBUG) ai_Debug("0i_spells", "1721", GetName(oCreature) + " has cast " + sSpellName + " on " + GetName(oTarget) + ".");
                    ai_CastMemorizedSpell(oCreature, nClass, nLevel, nSlot, oTarget, FALSE, oPC);
                    return TRUE;
                }
                // Save the lowest level cure spell as we might need to cast it.
                else if(nLevel < nLevelSave && (nSpell > 26 && nSpell < 32))
                {
                    nClassSave = nClass;
                    nLevelSave = nLevel;
                    nSlotSave = nSlot;
                }
            }
            nSlot++;
        }
        nLevel--;
    }
    // Did we find a cure spell? If we did then use it.
    if(nLevelSave < 10)
    {
        if(AI_DEBUG) ai_Debug("0i_spells", "1740", GetName(oCreature) + " has cast the lowest level cure spell on " + GetName(oTarget) + ".");
        ai_CastMemorizedSpell(oCreature, nClassSave, nLevelSave, nSlotSave, oTarget, FALSE, oPC);
        return TRUE;
    }
    return FALSE;
}
int ai_CastKnownHealing(object oCreature, object oTarget, object oPC, int nClass)
{
    if(AI_DEBUG) ai_Debug("0i_spells", "1748", GetName(oCreature) + " is looking to cast a known cure spell.");
    int nDamage = GetMaxHitPoints(oTarget) - GetCurrentHitPoints(oTarget);
    int nSpell, nSlot, nMaxSlots, nLevel = 9;
    int nClassSave, nSpellSave, nLevelSave = 10;
    while(nLevel > -1)
    {
        nMaxSlots = GetKnownSpellCount(oCreature, nClass, nLevel);
        nSlot = 0;
        if(AI_DEBUG) ai_Debug("0i_spells", "1756", "nLevel: " + IntToString(nLevel) + " nMaxSlots: " + IntToString(nMaxSlots));
        while(nSlot < nMaxSlots)
        {
            nSpell = GetKnownSpellId(oCreature, nClass, nLevel, nSlot);
            if(AI_DEBUG) ai_Debug("0i_spells", "1760", "nSlot: " + IntToString(nSlot) +
                     " Spell Ready: " + IntToString(GetSpellUsesLeft(oCreature, nClass, nSpell)));
            if(GetSpellUsesLeft(oCreature, nClass, nSpell))
            {
                if(ai_ShouldWeCastThisCureSpell(nSpell, nDamage))
                {
                    string sSpellName = GetStringByStrRef(StringToInt(Get2DAString("spells", "Name", nSpell)));
                    if(AI_DEBUG) ai_Debug("0i_spells", "1767", GetName(oCreature) + " has cast " + sSpellName + " on " + GetName(oTarget) + ".");
                    ai_CastKnownSpell(oCreature, nClass, nSpell, oTarget, FALSE, oPC);
                    return TRUE;
                }
                // Save the lowest level cure spell as we might need to cast it.
                else if(nLevel < nLevelSave && (nSpell > 26 && nSpell < 32))
                {
                    nClassSave = nClass;
                    nLevelSave = nLevel;
                    nSpellSave = nSpell;
                }
            }
            nSlot++;
        }
        nLevel--;
    }
    return FALSE;
    // Did we find a cure spell? If we did then use it.
    if(nLevelSave < 10)
    {
        if(AI_DEBUG) ai_Debug("0i_spells", "1781", GetName(oCreature) + " has cast the lowest level cure spell on " + GetName(oTarget) + ".");
        ai_CastKnownSpell(oCreature, nClassSave, nSpellSave, oTarget, FALSE, oPC);
        return TRUE;
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
        int nSpellLevel = StringToInt(Get2DAString("spells", "Innate", nSpell));
        int nDC = AI_DEFENSIVE_CASTING_DC + nSpellLevel;
        int nRoll = Random(AI_DEFENSIVE_CASTING_DIE) + 1;
        int nConcentration = GetSkillRank(SKILL_CONCENTRATION, oCreature);
        if(GetHasFeat(FEAT_COMBAT_CASTING, oCreature)) nConcentration += 4;
        if(AI_DEBUG) ai_Debug("0i_spells", "1081", "Use Defensive Casting? nDC: " + IntToString(nDC) + " FEAT_COMBAT_CASTING: " +
               IntToString(GetHasFeat(FEAT_COMBAT_CASTING, oCreature)) +
               " nConcentration: " + IntToString(nConcentration) + " + nRoll: " + IntToString(nRoll));
        if(nConcentration + nRoll > nDC)
        {
            if(AI_DEBUG) ai_Debug("0i_spells", "1086", GetName(oCreature) + " is casting defensively!");
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
                if(AI_DEBUG) ai_Debug("0i_spells", "1097", "Cast anyway: nConcentration: " + IntToString(nConcentration) +
                       " nRoll: " + IntToString(nRoll) + " nDC: " + IntToString(nDC) +
                       " oMelee: " + GetName(oMelee));
                if(nConcentration + nRoll > nDC) return TRUE;
                if(AI_DEBUG) ai_Debug("0i_spells", "1101", GetName(oCreature) + " is not casting in melee against " + GetName(oMelee));
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
    // Spell range is less than the nearest enemy. Restrict based on nearest enemy.
    // Spell range is less than the nearestenemy. Check enemy action then adjust.
    if(fRange < fEnemyDistance)
    {
        // We check this because if the enemy is moving or has not started acting
        // then we don't want to move up on them as they might move towards us!
        int nAction = GetCurrentAction(oNearestEnemy);
        if(AI_DEBUG) ai_Debug("0i_spells", "1130", GetName(oNearestEnemy) + " current action: " + IntToString(nAction));
        if(nAction != ACTION_MOVETOPOINT || nAction != ACTION_ITEMCASTSPELL ||
           nAction != ACTION_INVALID || nAction != ACTION_USEOBJECT ||
           nAction != ACTION_RANDOMWALK) fRange = fEnemyDistance + (fRange - 7.5);
    }
    if(fRange > AI_RANGE_BATTLEFIELD) return AI_RANGE_BATTLEFIELD;
    else if(fRange < 0.1f) return 0.1f;
    return fRange;
}
int ai_ShouldWeCastThisCureSpell(int nSpell, int nDamage)
{
    if(AI_DEBUG) ai_Debug("0i_spells", "1127", "nSpell: " + IntToString(nSpell) + " nDamage: " +
             IntToString(nDamage));
    if(nSpell == SPELL_HEAL && nDamage > 50) return TRUE;
    else if(nSpell == SPELL_CURE_CRITICAL_WOUNDS && nDamage > 31) return TRUE;
    else if(nSpell == SPELL_CURE_SERIOUS_WOUNDS && nDamage > 23) return TRUE;
    else if(nSpell == SPELL_CURE_MODERATE_WOUNDS && nDamage > 15) return TRUE;
    else if(nSpell == SPELL_CURE_LIGHT_WOUNDS && nDamage > 6) return TRUE;
    else if(nSpell == SPELL_CURE_MINOR_WOUNDS) return TRUE;
    return FALSE;
}
void ai_CastWidgetSpell(object oPC, object oAssociate, object oTarget, location lLocation)
{
    int nIndex = GetLocalInt(oAssociate, "AI_WIDGET_SPELL_INDEX");
    DeleteLocalInt(oAssociate, "AI_WIDGET_SPELL_INDEX");
    string sAssociateType = ai_GetAssociateType(oPC, oAssociate);
    json jAIData = ai_GetAssociateDbJson(oPC, sAssociateType, "aidata");
    json jSpells = JsonArrayGet(jAIData, 10);
    json jWidget = JsonArrayGet(jSpells, 2);
    json jSpell = JsonArrayGet(jWidget, nIndex);
    int nSpell = JsonGetInt(JsonArrayGet(jSpell, 0));
    int nClass = JsonGetInt(JsonArrayGet(jSpell, 1));
    int nMetaMagic = JsonGetInt(JsonArrayGet(jSpell, 3));
    int nDomain = JsonGetInt(JsonArrayGet(jSpell, 4));
    //SendMessageToPC(oPC, "nSpell: " + IntToString(nSpell) +
    //                     " oTarget: " + GetName(oTarget) +
    //                     " nMetaMagic: " + IntToString(nMetaMagic) +
    //                     " nDomain: " + IntToString(nDomain));
    if(GetCurrentAction(oAssociate) != ACTION_CASTSPELL) AssignCommand(oAssociate, ai_ClearCreatureActions(TRUE));
    if(!GetIsObjectValid(oTarget))
    {
        AssignCommand(oAssociate, ActionCastSpellAtLocation(nSpell, lLocation, nMetaMagic, FALSE, 0, FALSE, -1, FALSE, nDomain));
    }
    else AssignCommand(oAssociate, ActionCastSpellAtObject(nSpell, oTarget, nMetaMagic, FALSE, nDomain));

}
void ai_UseWidgetFeat(object oPC, object oAssociate, object oTarget, location lLocation)
{
    int nIndex = GetLocalInt(oAssociate, "AI_WIDGET_SPELL_INDEX");
    DeleteLocalInt(oAssociate, "AI_WIDGET_SPELL_INDEX");
    string sAssociateType = ai_GetAssociateType(oPC, oAssociate);
    json jAIData = ai_GetAssociateDbJson(oPC, sAssociateType, "aidata");
    json jSpells = JsonArrayGet(jAIData, 10);
    json jWidget = JsonArrayGet(jSpells, 2);
    json jFeat = JsonArrayGet(jWidget, nIndex);
    int nFeat = JsonGetInt(JsonArrayGet(jFeat, 5));
    int nLevel = JsonGetInt(JsonArrayGet(jFeat, 2));
    // We use nLevel at -1 to denote this is a feat with a subradial spell.
    int nSubSpell;
    if(nLevel == -1) nSubSpell = JsonGetInt(JsonArrayGet(jFeat, 0));
    if(ai_GetIsInCombat(oAssociate)) AssignCommand(oAssociate, ai_ClearCreatureActions(TRUE));
    //SendMessageToPC(oPC, "0i_spells, 2104, nFeat: " + IntToString(nFeat) + " oTarget: " + GetName(oTarget));
    if(!GetIsObjectValid(oTarget))
    {
        AssignCommand(oAssociate, ActionUseFeat(nFeat, OBJECT_INVALID, nSubSpell, lLocation));
    }
    else AssignCommand(oAssociate, ActionUseFeat(nFeat, oTarget, nSubSpell));
}
void ai_UseWidgetItem(object oPC, object oAssociate, object oTarget, location lLocation)
{
    int nIndex = GetLocalInt(oAssociate, "AI_WIDGET_SPELL_INDEX");
    DeleteLocalInt(oAssociate, "AI_WIDGET_SPELL_INDEX");
    string sAssociateType = ai_GetAssociateType(oPC, oAssociate);
    json jAIData = ai_GetAssociateDbJson(oPC, sAssociateType, "aidata");
    json jSpells = JsonArrayGet(jAIData, 10);
    json jWidget = JsonArrayGet(jSpells, 2);
    json jItem = JsonArrayGet(jWidget, nIndex);
    int nSpell = JsonGetInt(JsonArrayGet(jItem, 0));
    int nIprpSubType = JsonGetInt(JsonArrayGet(jItem, 4));
    object oItem = GetObjectByUUID(JsonGetString(JsonArrayGet(jItem, 5)));
    itemproperty ipProperty;
    if(ai_GetIsInCombat(oAssociate)) AssignCommand(oAssociate, ai_ClearCreatureActions(TRUE));
    if(nSpell == SPELL_HEALINGKIT)
    {
        ipProperty = GetFirstItemProperty(oItem);
        if(GetItemPropertyType(ipProperty) == ITEM_PROPERTY_HEALERS_KIT)
        {
           if(ai_GetIsCharacter(oPC)) ai_SendMessages(GetName(oAssociate) + " uses " + GetName(oItem) + " on " + GetName(oTarget) + ".", AI_COLOR_YELLOW, oPC);
           AssignCommand(oAssociate, ActionUseItemOnObject(oItem, ipProperty, oTarget));
           return;
        }
    }
    ipProperty = GetFirstItemProperty(oItem);
    while(GetIsItemPropertyValid(ipProperty))
    {
        if(nIprpSubType == GetItemPropertySubType(ipProperty)) break;
        ipProperty = GetNextItemProperty(oItem);
    }
    if(!GetIsObjectValid(oTarget))
    {
        AssignCommand(oAssociate, ActionUseItemAtLocation(oItem, ipProperty, lLocation));
    }
    else AssignCommand(oAssociate, ActionUseItemOnObject(oItem, ipProperty, oTarget));
}
