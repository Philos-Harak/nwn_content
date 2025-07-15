/*////////////////////////////////////////////////////////////////////////////////////////////////////
// Script Name: 0i_gui_events
// Programmer: Philos
//////////////////////////////////////////////////////////////////////////////////////////////////////
 Include scripts for all gui events. See also 0e_gui_events

 GUI Events:
 GUIEVENT_EFFECTICON_CLICK: For displaying icon information.

 This was built by DAZ all credit to him.
 I just changed it from PostString to a NUI menu.
*/////////////////////////////////////////////////////////////////////////////////////////////////////
#include "0i_constants"
#include "0i_nui"
void ai_SetupModuleGUIEvents(object oCreature)
{
    object oModule = GetModule();
    string sModuleGUIEvents = GetEventScript(oModule, EVENT_SCRIPT_MODULE_ON_PLAYER_GUIEVENT);
    if(sModuleGUIEvents != "" || sModuleGUIEvents != "0e_gui_events")
    {
        SetLocalString(oModule, AI_MODULE_GUI_EVENT, sModuleGUIEvents);
    }
    SetEventScript(oModule, EVENT_SCRIPT_MODULE_ON_PLAYER_GUIEVENT, "0e_gui_events");
}
int EffectIconToEffectType(int nEffectIcon)
{
    switch (nEffectIcon)
    {
        case EFFECT_ICON_INVALID:                           return EFFECT_TYPE_INVALIDEFFECT;

        // *** No Extra Stats
        case EFFECT_ICON_BLIND:                             return EFFECT_TYPE_BLINDNESS;
        case EFFECT_ICON_CHARMED:                           return EFFECT_TYPE_CHARMED;
        case EFFECT_ICON_CONFUSED:                          return EFFECT_TYPE_CONFUSED;
        case EFFECT_ICON_FRIGHTENED:                        return EFFECT_TYPE_FRIGHTENED;
        case EFFECT_ICON_DOMINATED:                         return EFFECT_TYPE_DOMINATED;
        case EFFECT_ICON_PARALYZE:                          return EFFECT_TYPE_PARALYZE;
        case EFFECT_ICON_DAZED:                             return EFFECT_TYPE_DAZED;
        case EFFECT_ICON_STUNNED:                           return EFFECT_TYPE_STUNNED;
        case EFFECT_ICON_SLEEP:                             return EFFECT_TYPE_SLEEP;
        case EFFECT_ICON_SILENCE:                           return EFFECT_TYPE_SILENCE;
        case EFFECT_ICON_TURNED:                            return EFFECT_TYPE_TURNED;
        case EFFECT_ICON_HASTE:                             return EFFECT_TYPE_HASTE;
        case EFFECT_ICON_SLOW:                              return EFFECT_TYPE_SLOW;
        case EFFECT_ICON_ENTANGLE:                          return EFFECT_TYPE_ENTANGLE;
        case EFFECT_ICON_DEAF:                              return EFFECT_TYPE_DEAF;
        case EFFECT_ICON_DARKNESS:                          return EFFECT_TYPE_DARKNESS;
        case EFFECT_ICON_POLYMORPH:                         return EFFECT_TYPE_POLYMORPH;
        case EFFECT_ICON_SANCTUARY:                         return EFFECT_TYPE_SANCTUARY;
        case EFFECT_ICON_TRUESEEING:                        return EFFECT_TYPE_TRUESEEING;
        case EFFECT_ICON_SEEINVISIBILITY:                   return EFFECT_TYPE_SEEINVISIBLE;
        case EFFECT_ICON_ETHEREALNESS:                      return EFFECT_TYPE_ETHEREAL;
        case EFFECT_ICON_PETRIFIED:                         return EFFECT_TYPE_PETRIFY;
        // ***

        case EFFECT_ICON_DAMAGE_RESISTANCE:                 return EFFECT_TYPE_DAMAGE_RESISTANCE;
        case EFFECT_ICON_REGENERATE:                        return EFFECT_TYPE_REGENERATE;
        case EFFECT_ICON_DAMAGE_REDUCTION:                  return EFFECT_TYPE_DAMAGE_REDUCTION;
        case EFFECT_ICON_TEMPORARY_HITPOINTS:               return EFFECT_TYPE_TEMPORARY_HITPOINTS;
        case EFFECT_ICON_IMMUNITY:                          return EFFECT_TYPE_IMMUNITY;
        case EFFECT_ICON_POISON:                            return EFFECT_TYPE_POISON;
        case EFFECT_ICON_DISEASE:                           return EFFECT_TYPE_DISEASE;
        case EFFECT_ICON_CURSE:                             return EFFECT_TYPE_CURSE;
        case EFFECT_ICON_ATTACK_INCREASE:                   return EFFECT_TYPE_ATTACK_INCREASE;
        case EFFECT_ICON_ATTACK_DECREASE:                   return EFFECT_TYPE_ATTACK_DECREASE;
        case EFFECT_ICON_DAMAGE_INCREASE:                   return EFFECT_TYPE_DAMAGE_INCREASE;
        case EFFECT_ICON_DAMAGE_DECREASE:                   return EFFECT_TYPE_DAMAGE_DECREASE;
        case EFFECT_ICON_AC_INCREASE:                       return EFFECT_TYPE_AC_INCREASE;
        case EFFECT_ICON_AC_DECREASE:                       return EFFECT_TYPE_AC_DECREASE;
        case EFFECT_ICON_MOVEMENT_SPEED_INCREASE:           return EFFECT_TYPE_MOVEMENT_SPEED_INCREASE;
        case EFFECT_ICON_MOVEMENT_SPEED_DECREASE:           return EFFECT_TYPE_MOVEMENT_SPEED_DECREASE;
        case EFFECT_ICON_SAVING_THROW_DECREASE:             return EFFECT_TYPE_SAVING_THROW_DECREASE;
        case EFFECT_ICON_SPELL_RESISTANCE_INCREASE:         return EFFECT_TYPE_SPELL_RESISTANCE_INCREASE;
        case EFFECT_ICON_SPELL_RESISTANCE_DECREASE:         return EFFECT_TYPE_SPELL_RESISTANCE_DECREASE;
        case EFFECT_ICON_SKILL_INCREASE:                    return EFFECT_TYPE_SKILL_INCREASE;
        case EFFECT_ICON_SKILL_DECREASE:                    return EFFECT_TYPE_SKILL_DECREASE;
        case EFFECT_ICON_ELEMENTALSHIELD:                   return EFFECT_TYPE_ELEMENTALSHIELD;
        case EFFECT_ICON_LEVELDRAIN:                        return EFFECT_TYPE_NEGATIVELEVEL;
        case EFFECT_ICON_SPELLLEVELABSORPTION:              return EFFECT_TYPE_SPELLLEVELABSORPTION;
        case EFFECT_ICON_SPELLIMMUNITY:                     return EFFECT_TYPE_SPELL_IMMUNITY;
        case EFFECT_ICON_CONCEALMENT:                       return EFFECT_TYPE_CONCEALMENT;
        case EFFECT_ICON_EFFECT_SPELL_FAILURE:              return EFFECT_TYPE_SPELL_FAILURE;

        case EFFECT_ICON_INVISIBILITY:
        case EFFECT_ICON_IMPROVEDINVISIBILITY:              return EFFECT_TYPE_INVISIBILITY;

        case EFFECT_ICON_ABILITY_INCREASE_STR:
        case EFFECT_ICON_ABILITY_INCREASE_DEX:
        case EFFECT_ICON_ABILITY_INCREASE_CON:
        case EFFECT_ICON_ABILITY_INCREASE_INT:
        case EFFECT_ICON_ABILITY_INCREASE_WIS:
        case EFFECT_ICON_ABILITY_INCREASE_CHA:              return EFFECT_TYPE_ABILITY_INCREASE;

        case EFFECT_ICON_ABILITY_DECREASE_STR:
        case EFFECT_ICON_ABILITY_DECREASE_CHA:
        case EFFECT_ICON_ABILITY_DECREASE_DEX:
        case EFFECT_ICON_ABILITY_DECREASE_CON:
        case EFFECT_ICON_ABILITY_DECREASE_INT:
        case EFFECT_ICON_ABILITY_DECREASE_WIS:              return EFFECT_TYPE_ABILITY_DECREASE;

        case EFFECT_ICON_IMMUNITY_ALL:
        case EFFECT_ICON_IMMUNITY_MIND:
        case EFFECT_ICON_IMMUNITY_POISON:
        case EFFECT_ICON_IMMUNITY_DISEASE:
        case EFFECT_ICON_IMMUNITY_FEAR:
        case EFFECT_ICON_IMMUNITY_TRAP:
        case EFFECT_ICON_IMMUNITY_PARALYSIS:
        case EFFECT_ICON_IMMUNITY_BLINDNESS:
        case EFFECT_ICON_IMMUNITY_DEAFNESS:
        case EFFECT_ICON_IMMUNITY_SLOW:
        case EFFECT_ICON_IMMUNITY_ENTANGLE:
        case EFFECT_ICON_IMMUNITY_SILENCE:
        case EFFECT_ICON_IMMUNITY_STUN:
        case EFFECT_ICON_IMMUNITY_SLEEP:
        case EFFECT_ICON_IMMUNITY_CHARM:
        case EFFECT_ICON_IMMUNITY_DOMINATE:
        case EFFECT_ICON_IMMUNITY_CONFUSE:
        case EFFECT_ICON_IMMUNITY_CURSE:
        case EFFECT_ICON_IMMUNITY_DAZED:
        case EFFECT_ICON_IMMUNITY_ABILITY_DECREASE:
        case EFFECT_ICON_IMMUNITY_ATTACK_DECREASE:
        case EFFECT_ICON_IMMUNITY_DAMAGE_DECREASE:
        case EFFECT_ICON_IMMUNITY_DAMAGE_IMMUNITY_DECREASE:
        case EFFECT_ICON_IMMUNITY_AC_DECREASE:
        case EFFECT_ICON_IMMUNITY_MOVEMENT_SPEED_DECREASE:
        case EFFECT_ICON_IMMUNITY_SAVING_THROW_DECREASE:
        case EFFECT_ICON_IMMUNITY_SPELL_RESISTANCE_DECREASE:
        case EFFECT_ICON_IMMUNITY_SKILL_DECREASE:
        case EFFECT_ICON_IMMUNITY_KNOCKDOWN:
        case EFFECT_ICON_IMMUNITY_NEGATIVE_LEVEL:
        case EFFECT_ICON_IMMUNITY_SNEAK_ATTACK:
        case EFFECT_ICON_IMMUNITY_CRITICAL_HIT:
        case EFFECT_ICON_IMMUNITY_DEATH_MAGIC:              return EFFECT_TYPE_IMMUNITY;

        case EFFECT_ICON_SAVING_THROW_INCREASE:
        case EFFECT_ICON_REFLEX_SAVE_INCREASED:
        case EFFECT_ICON_FORT_SAVE_INCREASED:
        case EFFECT_ICON_WILL_SAVE_INCREASED:               return EFFECT_TYPE_SAVING_THROW_INCREASE;

        case EFFECT_ICON_DAMAGE_IMMUNITY_INCREASE:
        case EFFECT_ICON_DAMAGE_IMMUNITY_MAGIC:
        case EFFECT_ICON_DAMAGE_IMMUNITY_ACID:
        case EFFECT_ICON_DAMAGE_IMMUNITY_COLD:
        case EFFECT_ICON_DAMAGE_IMMUNITY_DIVINE:
        case EFFECT_ICON_DAMAGE_IMMUNITY_ELECTRICAL:
        case EFFECT_ICON_DAMAGE_IMMUNITY_FIRE:
        case EFFECT_ICON_DAMAGE_IMMUNITY_NEGATIVE:
        case EFFECT_ICON_DAMAGE_IMMUNITY_POSITIVE:
        case EFFECT_ICON_DAMAGE_IMMUNITY_SONIC:             return EFFECT_TYPE_DAMAGE_IMMUNITY_INCREASE;

       case EFFECT_ICON_DAMAGE_IMMUNITY_DECREASE:
        case EFFECT_ICON_DAMAGE_IMMUNITY_MAGIC_DECREASE:
        case EFFECT_ICON_DAMAGE_IMMUNITY_ACID_DECREASE:
        case EFFECT_ICON_DAMAGE_IMMUNITY_COLD_DECREASE:
        case EFFECT_ICON_DAMAGE_IMMUNITY_DIVINE_DECREASE:
        case EFFECT_ICON_DAMAGE_IMMUNITY_ELECTRICAL_DECREASE:
        case EFFECT_ICON_DAMAGE_IMMUNITY_FIRE_DECREASE:
        case EFFECT_ICON_DAMAGE_IMMUNITY_NEGATIVE_DECREASE:
        case EFFECT_ICON_DAMAGE_IMMUNITY_POSITIVE_DECREASE:
        case EFFECT_ICON_DAMAGE_IMMUNITY_SONIC_DECREASE:    return EFFECT_TYPE_DAMAGE_IMMUNITY_DECREASE;

        //case EFFECT_ICON_INVULNERABLE: return EFFECT_TYPE_INVULNERABLE;
        //case EFFECT_ICON_WOUNDING: return EFFECT_TYPE_INVALIDEFFECT;
        //case EFFECT_ICON_TAUNTED: return EFFECT_TYPE_INVALIDEFFECT;
        //case EFFECT_ICON_TIMESTOP: return EFFECT_TYPE_TIMESTOP;
        //case EFFECT_ICON_BLINDNESS: return EFFECT_TYPE_BLINDNESS;
        //case EFFECT_ICON_DISPELMAGICBEST: return EFFECT_TYPE_INVALIDEFFECT;
        //case EFFECT_ICON_DISPELMAGICALL: return EFFECT_TYPE_INVALIDEFFECT;
        //case EFFECT_ICON_ENEMY_ATTACK_BONUS: return EFFECT_TYPE_INVALIDEFFECT;
        //case EFFECT_ICON_FATIGUE: return EFFECT_TYPE_INVALIDEFFECT;
    }
    return EFFECT_TYPE_INVALIDEFFECT;
}
int AbilityTypeFromEffectIconAbility(int nEffectIcon)
{
    switch (nEffectIcon)
    {
        case EFFECT_ICON_ABILITY_INCREASE_STR:
        case EFFECT_ICON_ABILITY_DECREASE_STR:
            return ABILITY_STRENGTH;
        case EFFECT_ICON_ABILITY_INCREASE_DEX:
        case EFFECT_ICON_ABILITY_DECREASE_DEX:
            return ABILITY_DEXTERITY;
        case EFFECT_ICON_ABILITY_INCREASE_CON:
        case EFFECT_ICON_ABILITY_DECREASE_CON:
            return ABILITY_CONSTITUTION;
        case EFFECT_ICON_ABILITY_INCREASE_INT:
        case EFFECT_ICON_ABILITY_DECREASE_INT:
            return ABILITY_INTELLIGENCE;
        case EFFECT_ICON_ABILITY_INCREASE_WIS:
        case EFFECT_ICON_ABILITY_DECREASE_WIS:
            return ABILITY_WISDOM;
        case EFFECT_ICON_ABILITY_INCREASE_CHA:
        case EFFECT_ICON_ABILITY_DECREASE_CHA:
            return ABILITY_CHARISMA;
    }
    return -1;
}
int DamageTypeFromEffectIconDamageImmunity(int nEffectIcon)
{
    switch (nEffectIcon)
    {
        case EFFECT_ICON_DAMAGE_IMMUNITY_MAGIC:
        case EFFECT_ICON_DAMAGE_IMMUNITY_MAGIC_DECREASE:
            return DAMAGE_TYPE_MAGICAL;
        case EFFECT_ICON_DAMAGE_IMMUNITY_ACID:
        case EFFECT_ICON_DAMAGE_IMMUNITY_ACID_DECREASE:
            return DAMAGE_TYPE_ACID;
        case EFFECT_ICON_DAMAGE_IMMUNITY_COLD:
        case EFFECT_ICON_DAMAGE_IMMUNITY_COLD_DECREASE:
            return DAMAGE_TYPE_COLD;
        case EFFECT_ICON_DAMAGE_IMMUNITY_DIVINE:
        case EFFECT_ICON_DAMAGE_IMMUNITY_DIVINE_DECREASE:
            return DAMAGE_TYPE_DIVINE;
        case EFFECT_ICON_DAMAGE_IMMUNITY_ELECTRICAL:
        case EFFECT_ICON_DAMAGE_IMMUNITY_ELECTRICAL_DECREASE:
            return DAMAGE_TYPE_ELECTRICAL;
        case EFFECT_ICON_DAMAGE_IMMUNITY_FIRE:
        case EFFECT_ICON_DAMAGE_IMMUNITY_FIRE_DECREASE:
            return DAMAGE_TYPE_FIRE;
        case EFFECT_ICON_DAMAGE_IMMUNITY_NEGATIVE:
        case EFFECT_ICON_DAMAGE_IMMUNITY_NEGATIVE_DECREASE:
            return DAMAGE_TYPE_NEGATIVE;
        case EFFECT_ICON_DAMAGE_IMMUNITY_POSITIVE:
        case EFFECT_ICON_DAMAGE_IMMUNITY_POSITIVE_DECREASE:
            return DAMAGE_TYPE_POSITIVE;
        case EFFECT_ICON_DAMAGE_IMMUNITY_SONIC:
        case EFFECT_ICON_DAMAGE_IMMUNITY_SONIC_DECREASE:
            return DAMAGE_TYPE_SONIC;
    }
    return -1;
}

int ImmunityTypeFromEffectIconImmunity(int nEffectIcon)
{
    switch (nEffectIcon)
    {
        case EFFECT_ICON_IMMUNITY_MIND:                         return IMMUNITY_TYPE_MIND_SPELLS;
        case EFFECT_ICON_IMMUNITY_POISON:                       return IMMUNITY_TYPE_POISON;
        case EFFECT_ICON_IMMUNITY_DISEASE:                      return IMMUNITY_TYPE_DISEASE;
        case EFFECT_ICON_IMMUNITY_FEAR:                         return IMMUNITY_TYPE_FEAR;
        case EFFECT_ICON_IMMUNITY_TRAP:                         return IMMUNITY_TYPE_TRAP;
        case EFFECT_ICON_IMMUNITY_PARALYSIS:                    return IMMUNITY_TYPE_PARALYSIS;
        case EFFECT_ICON_IMMUNITY_BLINDNESS:                    return IMMUNITY_TYPE_BLINDNESS;
        case EFFECT_ICON_IMMUNITY_DEAFNESS:                     return IMMUNITY_TYPE_DEAFNESS;
        case EFFECT_ICON_IMMUNITY_SLOW:                         return IMMUNITY_TYPE_SLOW;
        case EFFECT_ICON_IMMUNITY_ENTANGLE:                     return IMMUNITY_TYPE_ENTANGLE;
        case EFFECT_ICON_IMMUNITY_SILENCE:                      return IMMUNITY_TYPE_SILENCE;
        case EFFECT_ICON_IMMUNITY_STUN:                         return IMMUNITY_TYPE_STUN;
        case EFFECT_ICON_IMMUNITY_SLEEP:                        return IMMUNITY_TYPE_SLEEP;
        case EFFECT_ICON_IMMUNITY_CHARM:                        return IMMUNITY_TYPE_CHARM;
        case EFFECT_ICON_IMMUNITY_DOMINATE:                     return IMMUNITY_TYPE_DOMINATE;
        case EFFECT_ICON_IMMUNITY_CONFUSE:                      return IMMUNITY_TYPE_CONFUSED;
        case EFFECT_ICON_IMMUNITY_CURSE:                        return IMMUNITY_TYPE_CURSED;
        case EFFECT_ICON_IMMUNITY_DAZED:                        return IMMUNITY_TYPE_DAZED;
        case EFFECT_ICON_IMMUNITY_ABILITY_DECREASE:             return IMMUNITY_TYPE_ABILITY_DECREASE;
        case EFFECT_ICON_IMMUNITY_ATTACK_DECREASE:              return IMMUNITY_TYPE_ATTACK_DECREASE;
        case EFFECT_ICON_IMMUNITY_DAMAGE_DECREASE:              return IMMUNITY_TYPE_DAMAGE_DECREASE;
        case EFFECT_ICON_IMMUNITY_DAMAGE_IMMUNITY_DECREASE:     return IMMUNITY_TYPE_DAMAGE_IMMUNITY_DECREASE;
        case EFFECT_ICON_IMMUNITY_AC_DECREASE:                  return IMMUNITY_TYPE_AC_DECREASE;
        case EFFECT_ICON_IMMUNITY_MOVEMENT_SPEED_DECREASE:      return IMMUNITY_TYPE_MOVEMENT_SPEED_DECREASE;
        case EFFECT_ICON_IMMUNITY_SAVING_THROW_DECREASE:        return IMMUNITY_TYPE_SAVING_THROW_DECREASE;
        case EFFECT_ICON_IMMUNITY_SPELL_RESISTANCE_DECREASE:    return IMMUNITY_TYPE_SPELL_RESISTANCE_DECREASE;
        case EFFECT_ICON_IMMUNITY_SKILL_DECREASE:               return IMMUNITY_TYPE_SKILL_DECREASE;
        case EFFECT_ICON_IMMUNITY_KNOCKDOWN:                    return IMMUNITY_TYPE_KNOCKDOWN;
        case EFFECT_ICON_IMMUNITY_NEGATIVE_LEVEL:               return IMMUNITY_TYPE_NEGATIVE_LEVEL;
        case EFFECT_ICON_IMMUNITY_SNEAK_ATTACK:                 return IMMUNITY_TYPE_SNEAK_ATTACK;
        case EFFECT_ICON_IMMUNITY_CRITICAL_HIT:                 return IMMUNITY_TYPE_CRITICAL_HIT;
        case EFFECT_ICON_IMMUNITY_DEATH_MAGIC:                  return IMMUNITY_TYPE_DEATH;
    }
    return -1;
}
void ClearLines(object oPlayer)
{
    int nLine, nLines = GetLocalInt(oPlayer, "BUFFINFO_LAST_NUM_LINES");
    for (nLine = 1; nLine <= nLines; nLine++)
    {
        PostString(oPlayer, "", 10, nLine + 3, SCREEN_ANCHOR_TOP_RIGHT, 0.1f, 0xFFFFFF00, 0xFFFFFF00, nLine);
    }
}
void DisplayLine(object oPlayer, int nLine, string sText, int nColor)
{
    PostString(oPlayer, sText, 10, nLine + 3, SCREEN_ANCHOR_TOP_RIGHT, 10.0f, nColor, 0xFFFFFF00, nLine);
}
string SecondsToTimestamp(int nSeconds)
{
    sqlquery sql;
    if (nSeconds > 86400) sql = SqlPrepareQueryObject(GetModule(), "SELECT (@seconds / 3600) || ':' || strftime('%M:%S', @seconds / 86400.0);");
    else sql = SqlPrepareQueryObject(GetModule(), "SELECT time(@seconds, 'unixepoch');");
    SqlBindInt(sql, "@seconds", nSeconds);
    SqlStep(sql);
    return SqlGetString(sql, 0);
}
string Get2DAStrRef(string s2DA, string sColumn, int nRow)
{
    return GetStringByStrRef(StringToInt(Get2DAString(s2DA, sColumn, nRow)));
}
string GetVersusRacialTypeAndAlignment(int nRacialType, int nLawfulChaotic, int nGoodEvil)
{
    string sRacialType = nRacialType == RACIAL_TYPE_INVALID ? "" : Get2DAStrRef("racialtypes", "NamePlural", nRacialType);
    string sLawfulChaotic = nLawfulChaotic == ALIGNMENT_LAWFUL ? "Lawful" : nLawfulChaotic == ALIGNMENT_CHAOTIC ? "Chaotic" : "";
    string sGoodEvil = nGoodEvil == ALIGNMENT_GOOD ? "Good" : nGoodEvil == ALIGNMENT_EVIL ? "Evil" : "";
    string sAlignment = sLawfulChaotic + (sLawfulChaotic == "" ? sGoodEvil : (sGoodEvil == "" ? "" : " " + sGoodEvil));
    return (sRacialType != "" || sAlignment != "") ? (" vs. " + sAlignment + (sAlignment == "" ? sRacialType : (sRacialType == "" ? "" : " " + sRacialType))) : "";
}
string GetModifierType(int nEffectType, int nPlus, int nMinus)
{
    return nEffectType == nPlus ? "+" : nEffectType == nMinus ? "-" : "";
}
string ACTypeToString(int nACType)
{
    switch (nACType)
    {
        case AC_DODGE_BONUS:                return "Dodge";
        case AC_NATURAL_BONUS:              return "Natural";
        case AC_ARMOUR_ENCHANTMENT_BONUS:   return "Armor";
        case AC_SHIELD_ENCHANTMENT_BONUS:   return "Shield";
        case AC_DEFLECTION_BONUS:           return "Deflection";
    }
    return "";
}

string SavingThrowToString(int nSavingThrow)
{
    switch (nSavingThrow)
    {
        case SAVING_THROW_ALL:      return "All";
        case SAVING_THROW_FORT:     return "Fortitude";
        case SAVING_THROW_REFLEX:   return "Reflex";
        case SAVING_THROW_WILL:     return "Will";
    }
    return "";
}
string SavingThrowTypeToString(int nSavingThrowType)
{
    switch (nSavingThrowType)
    {
        case SAVING_THROW_TYPE_MIND_SPELLS:     return "Mind Spells";
        case SAVING_THROW_TYPE_POISON:          return "Poison";
        case SAVING_THROW_TYPE_DISEASE:         return "Disease";
        case SAVING_THROW_TYPE_FEAR:            return "Fear";
        case SAVING_THROW_TYPE_SONIC:           return "Sonic";
        case SAVING_THROW_TYPE_ACID:            return "Acid";
        case SAVING_THROW_TYPE_FIRE:            return "Fire";
        case SAVING_THROW_TYPE_ELECTRICITY:     return "Electricity";
        case SAVING_THROW_TYPE_POSITIVE:        return "Positive";
        case SAVING_THROW_TYPE_NEGATIVE:        return "Negative";
        case SAVING_THROW_TYPE_DEATH:           return "Death";
        case SAVING_THROW_TYPE_COLD:            return "Cold";
        case SAVING_THROW_TYPE_DIVINE:          return "Divine";
        case SAVING_THROW_TYPE_TRAP:            return "Traps";
        case SAVING_THROW_TYPE_SPELL:           return "Spells";
        case SAVING_THROW_TYPE_GOOD:            return "Good";
        case SAVING_THROW_TYPE_EVIL:            return "Evil";
        case SAVING_THROW_TYPE_LAW:             return "Lawful";
        case SAVING_THROW_TYPE_CHAOS:           return "Chaotic";
    }
    return "";
}
string AbilityToString(int nAbility)
{
    switch (nAbility)
    {
        case ABILITY_STRENGTH:      return "Strength";
        case ABILITY_DEXTERITY:     return "Dexterity";
        case ABILITY_CONSTITUTION:  return "Constitution";
        case ABILITY_INTELLIGENCE:  return "Intelligence";
        case ABILITY_WISDOM:        return "Wisdom";
        case ABILITY_CHARISMA:      return "Charisma";
    }
    return "";
}
string DamageTypeToString(int nDamageType)
{
    switch (nDamageType)
    {
        case DAMAGE_TYPE_BLUDGEONING:   return "Bludgeoning";
        case DAMAGE_TYPE_PIERCING:      return "Piercing";
        case DAMAGE_TYPE_SLASHING:      return "Slashing";
        case DAMAGE_TYPE_MAGICAL:       return "Magical";
        case DAMAGE_TYPE_ACID:          return "Acid";
        case DAMAGE_TYPE_COLD:          return "Cold";
        case DAMAGE_TYPE_DIVINE:        return "Divine";
        case DAMAGE_TYPE_ELECTRICAL:    return "Electrical";
        case DAMAGE_TYPE_FIRE:          return "Fire";
        case DAMAGE_TYPE_NEGATIVE:      return "Negative";
        case DAMAGE_TYPE_POSITIVE:      return "Positive";
        case DAMAGE_TYPE_SONIC:         return "Sonic";
        case DAMAGE_TYPE_BASE_WEAPON:   return "Base Weapon";
    }
    return "";
}
string SpellSchoolToString(int nSpellSchool)
{
    switch (nSpellSchool)
    {
        case SPELL_SCHOOL_GENERAL:          return "General";
        case SPELL_SCHOOL_ABJURATION:       return "Abjuration";
        case SPELL_SCHOOL_CONJURATION:      return "Conjuration";
        case SPELL_SCHOOL_DIVINATION:       return "Divination";
        case SPELL_SCHOOL_ENCHANTMENT:      return "Enchantment";
        case SPELL_SCHOOL_EVOCATION:        return "Evocation";
        case SPELL_SCHOOL_ILLUSION:         return "Illusion";
        case SPELL_SCHOOL_NECROMANCY:       return "Necromancy";
        case SPELL_SCHOOL_TRANSMUTATION:    return "Transmutation";
    }
    return "";
}
string MissChanceToString(int nMissChance)
{
    switch (nMissChance)
    {
        case MISS_CHANCE_TYPE_VS_RANGED: return "vs. Ranged";
        case MISS_CHANCE_TYPE_VS_MELEE: return "vs. Melee";
    }
    return "";
}
void ai_CreateEffectChatReport(object oPlayer, int nEffectIconID)
{
    int nIconEffectType = EffectIconToEffectType(nEffectIconID);
    if(nIconEffectType == EFFECT_TYPE_INVALIDEFFECT) return;
    int nLine, nIndex, nEffectIndex;
    string sColor = AI_COLOR_YELLOW;
    int bSkipDisplay, bHasEffect;
    int nEffectType, bIsSpellLevelAbsorptionPretendingToBeSpellImmunity;
    string sText;
    json jEffectID = JsonArray();
    // ************************************************************************* Width / Height
    // Row 1 ******************************************************************* 500 / 27
    sText = Get2DAStrRef("effecticons", "StrRef", nEffectIconID);
    ai_SendMessages(sText, AI_COLOR_YELLOW, oPlayer);
    effect eEffect = GetFirstEffect(oPlayer);
    while(GetIsEffectValid(eEffect))
    {
        bSkipDisplay = FALSE;
        nEffectType = GetEffectType(eEffect);
        // Unlimited EffectSpellLevelAbsorption has a SpellImmunity Icon
        if (nIconEffectType == EFFECT_TYPE_SPELL_IMMUNITY && GetEffectInteger(eEffect, 3))
        {
            bIsSpellLevelAbsorptionPretendingToBeSpellImmunity = TRUE;
            nIconEffectType = EFFECT_TYPE_SPELLLEVELABSORPTION;
        }
        if (nEffectType == nIconEffectType)
        {
            bHasEffect = TRUE;
            int nSpellID = GetEffectSpellId(eEffect);
            string sSpellName = nSpellID == -1 ? "<Unknown>" : Get2DAStrRef("spells", "Name", nSpellID);
            int bIsPermanentEffect = GetEffectDurationType(eEffect) == DURATION_TYPE_PERMANENT;
            int nDurationRemaining = GetEffectDurationRemaining(eEffect);
            string sDurationRemaining = bIsPermanentEffect ? "(Permanent)" : "(" + SecondsToTimestamp(nDurationRemaining) + ")";
            if(bIsPermanentEffect) sColor = AI_COLOR_WHITE;
            else
            {
                if(nDurationRemaining < 61) sColor = AI_COLOR_RED;
                else if(nDurationRemaining < 300) sColor = AI_COLOR_YELLOW;
                else sColor = AI_COLOR_GREEN;
            }
            string sStats = "";
            string sRacialTypeAlignment = "";
            switch (nEffectType)
            {
                case EFFECT_TYPE_AC_INCREASE:
                case EFFECT_TYPE_AC_DECREASE:
                {
                    string sModifier = GetModifierType(nEffectType, EFFECT_TYPE_AC_INCREASE, EFFECT_TYPE_AC_DECREASE);
                    sStats = sModifier + IntToString(GetEffectInteger(eEffect, 1)) + " " + ACTypeToString(GetEffectInteger(eEffect, 0)) + " AC";
                    sRacialTypeAlignment = GetVersusRacialTypeAndAlignment(GetEffectInteger(eEffect, 2), GetEffectInteger(eEffect, 3), GetEffectInteger(eEffect, 4));
                    break;
                }
                case EFFECT_TYPE_ATTACK_INCREASE:
                case EFFECT_TYPE_ATTACK_DECREASE:
                {
                    string sModifier = GetModifierType(nEffectType, EFFECT_TYPE_ATTACK_INCREASE, EFFECT_TYPE_ATTACK_DECREASE);
                    sStats = sModifier + IntToString(GetEffectInteger(eEffect, 0)) +" AB";
                    sRacialTypeAlignment = GetVersusRacialTypeAndAlignment(GetEffectInteger(eEffect, 2), GetEffectInteger(eEffect, 3), GetEffectInteger(eEffect, 4));
                    break;
                }
                case EFFECT_TYPE_SAVING_THROW_INCREASE:
                case EFFECT_TYPE_SAVING_THROW_DECREASE:
                {
                    string sModifier = GetModifierType(nEffectType, EFFECT_TYPE_SAVING_THROW_INCREASE, EFFECT_TYPE_SAVING_THROW_DECREASE);
                    string sSavingThrow = SavingThrowToString(GetEffectInteger(eEffect, 1));
                    string sSavingThrowType = SavingThrowTypeToString(GetEffectInteger(eEffect, 2));
                    sStats = sModifier + IntToString(GetEffectInteger(eEffect, 0)) + " " + sSavingThrow + (sSavingThrowType == "" ? "" : " (vs. " + sSavingThrowType + ")");
                    sRacialTypeAlignment = GetVersusRacialTypeAndAlignment(GetEffectInteger(eEffect, 3), GetEffectInteger(eEffect, 4), GetEffectInteger(eEffect, 5));
                    break;
                }
                case EFFECT_TYPE_ABILITY_INCREASE:
                case EFFECT_TYPE_ABILITY_DECREASE:
                {
                    int nAbility = AbilityTypeFromEffectIconAbility(nEffectIconID);

                    if (nAbility != GetEffectInteger(eEffect, 0))
                        bSkipDisplay = TRUE;
                    else
                    {
                        string sModifier = GetModifierType(nEffectType, EFFECT_TYPE_ABILITY_INCREASE, EFFECT_TYPE_ABILITY_DECREASE);
                        sStats = sModifier + IntToString(GetEffectInteger(eEffect, 1)) + " " + AbilityToString(nAbility);
                    }
                    break;
                }
                case EFFECT_TYPE_DAMAGE_INCREASE:
                case EFFECT_TYPE_DAMAGE_DECREASE:
                {
                    string sModifier = GetModifierType(nEffectType, EFFECT_TYPE_DAMAGE_INCREASE, EFFECT_TYPE_DAMAGE_DECREASE);
                    sStats = sModifier + Get2DAStrRef("iprp_damagecost", "Name", GetEffectInteger(eEffect, 0)) + " (" + DamageTypeToString(GetEffectInteger(eEffect, 1)) + ")";
                    sRacialTypeAlignment = GetVersusRacialTypeAndAlignment(GetEffectInteger(eEffect, 2), GetEffectInteger(eEffect, 3), GetEffectInteger(eEffect, 4));
                    break;
                }
                case EFFECT_TYPE_SKILL_INCREASE:
                case EFFECT_TYPE_SKILL_DECREASE:
                {
                    int nSkill = GetEffectInteger(eEffect, 0);
                    string sSkill = nSkill == 255 ? "All Skills" : Get2DAStrRef("skills", "Name", nSkill);
                    string sModifier = GetModifierType(nEffectType, EFFECT_TYPE_SKILL_INCREASE, EFFECT_TYPE_SKILL_DECREASE);
                    sStats = sModifier + IntToString(GetEffectInteger(eEffect, 1)) + " " + sSkill;
                    sRacialTypeAlignment = GetVersusRacialTypeAndAlignment(GetEffectInteger(eEffect, 2), GetEffectInteger(eEffect, 3), GetEffectInteger(eEffect, 4));
                    break;
                }
                case EFFECT_TYPE_TEMPORARY_HITPOINTS:
                {
                    sStats = "+" + IntToString(GetEffectInteger(eEffect, 0)) + " HitPoints";
                    break;
                }
                case EFFECT_TYPE_DAMAGE_REDUCTION:
                {
                    int nAmount = GetEffectInteger(eEffect, 0);
                    int nDamagePower = GetEffectInteger(eEffect, 1);
                    nDamagePower = nDamagePower > 6 ? --nDamagePower : nDamagePower;
                    int nRemaining = GetEffectInteger(eEffect, 2);
                    sStats = IntToString(nAmount) + "/+" + IntToString(nDamagePower) + " (" + (nRemaining == 0 ? "Unlimited" : IntToString(nRemaining) + " Damage Remaining") + ")";
                    break;
                }
                case EFFECT_TYPE_DAMAGE_RESISTANCE:
                {
                    int nAmount = GetEffectInteger(eEffect, 1);
                    int nRemaining = GetEffectInteger(eEffect, 2);
                    sStats = IntToString(nAmount) + "/- " + DamageTypeToString(GetEffectInteger(eEffect, 0)) + " Resistance (" + (nRemaining == 0 ? "Unlimited" : IntToString(nRemaining) + " Damage Remaining") + ")";
                    break;
                }
                case EFFECT_TYPE_IMMUNITY:
                {
                    int nImmunity = ImmunityTypeFromEffectIconImmunity(nEffectIconID);

                    if (nImmunity != GetEffectInteger(eEffect, 0))
                        bSkipDisplay = TRUE;
                    else
                    {
                        sStats = Get2DAStrRef("effecticons", "StrRef", nEffectIconID);
                        sRacialTypeAlignment = GetVersusRacialTypeAndAlignment(GetEffectInteger(eEffect, 1), GetEffectInteger(eEffect, 2), GetEffectInteger(eEffect, 3));
                    }
                    break;
                }
                case EFFECT_TYPE_DAMAGE_IMMUNITY_INCREASE:
                case EFFECT_TYPE_DAMAGE_IMMUNITY_DECREASE:
                {
                    int nDamageType = GetEffectInteger(eEffect, 0);
                    int nDamageTypeFromIcon = DamageTypeFromEffectIconDamageImmunity(nEffectIconID);

                    if (nDamageTypeFromIcon != -1 && nDamageType != nDamageTypeFromIcon)
                        bSkipDisplay = TRUE;

                    string sModifier = GetModifierType(nEffectType, EFFECT_TYPE_DAMAGE_IMMUNITY_INCREASE, EFFECT_TYPE_DAMAGE_IMMUNITY_DECREASE);
                    sStats = sModifier + IntToString(GetEffectInteger(eEffect, 1)) + "% " + DamageTypeToString(nDamageType) + " Damage Immunity";
                    break;
                }
                case EFFECT_TYPE_SPELL_IMMUNITY:
                {
                    sStats = "Spell Immunity: " + Get2DAStrRef("spells", "Name", GetEffectInteger(eEffect, 0));
                    break;
                }
                case EFFECT_TYPE_SPELLLEVELABSORPTION:
                {
                    int nMaxSpellLevelAbsorbed = GetEffectInteger(eEffect, 0);
                    int bUnlimited = GetEffectInteger(eEffect, 3);
                    string sSpellLevel;
                    switch (nMaxSpellLevelAbsorbed)
                    {
                        case 0: sSpellLevel = "Cantrip"; break;
                        case 1: sSpellLevel = "1st"; break;
                        case 2: sSpellLevel = "2nd"; break;
                        case 3: sSpellLevel = "3rd"; break;
                        default: sSpellLevel = IntToString(nMaxSpellLevelAbsorbed) + "th"; break;
                    }
                    sSpellLevel += " Level" + (nMaxSpellLevelAbsorbed == 0 ? "" : " and Below");
                    string sSpellSchool = SpellSchoolToString(GetEffectInteger(eEffect, 2));
                    string sRemainingSpellLevels = bUnlimited ? "" : "(" + IntToString(GetEffectInteger(eEffect, 1)) + " Spell Levels Remaining)";
                    sStats = sSpellLevel + " " + sSpellSchool + " Spell Immunity " + sRemainingSpellLevels;

                    if (bIsSpellLevelAbsorptionPretendingToBeSpellImmunity)
                        nIconEffectType = EFFECT_TYPE_SPELL_IMMUNITY;
                    else if (bUnlimited && !bIsSpellLevelAbsorptionPretendingToBeSpellImmunity)
                        bSkipDisplay = TRUE;

                    break;
                }
                case EFFECT_TYPE_REGENERATE:
                {
                    sStats = "+" + IntToString(GetEffectInteger(eEffect, 0)) + " HP / " + FloatToString((GetEffectInteger(eEffect, 1) / 1000.0f), 0, 2) + "s";
                    break;
                }
                case EFFECT_TYPE_POISON:
                {
                    sStats = "Poison: " + Get2DAStrRef("poison", "Name", GetEffectInteger(eEffect, 0));
                    break;
                }
                case EFFECT_TYPE_DISEASE:
                {
                    sStats = "Disease: " + Get2DAStrRef("disease", "Name", GetEffectInteger(eEffect, 0));
                    break;
                }
                case EFFECT_TYPE_CURSE:
                {
                    int nAbility;
                    string sAbilityDecrease;
                    for (nAbility = 0; nAbility < 6; nAbility++)
                    {
                        int nAbilityMod = GetEffectInteger(eEffect, nAbility);
                        if (nAbilityMod > 0)
                        {
                            string sAbility = GetStringLeft(AbilityToString(nAbility), 3);
                            sAbilityDecrease += "-" + IntToString(nAbilityMod) + " " + sAbility + ", ";
                        }
                    }
                    sAbilityDecrease = GetStringLeft(sAbilityDecrease, GetStringLength(sAbilityDecrease) - 2);
                    sStats = sAbilityDecrease;
                    break;
                }
                case EFFECT_TYPE_MOVEMENT_SPEED_INCREASE:
                case EFFECT_TYPE_MOVEMENT_SPEED_DECREASE:
                {
                    string sModifier = GetModifierType(nEffectType, EFFECT_TYPE_MOVEMENT_SPEED_INCREASE, EFFECT_TYPE_MOVEMENT_SPEED_DECREASE);
                    sStats = sModifier + IntToString(GetEffectInteger(eEffect, 0)) + "% Movement Speed";
                    break;
                }
                case EFFECT_TYPE_ELEMENTALSHIELD:
                {
                    sStats = IntToString(GetEffectInteger(eEffect, 0)) + " + " + Get2DAStrRef("iprp_damagecost", "Name", GetEffectInteger(eEffect, 1)) + " (" + DamageTypeToString(GetEffectInteger(eEffect, 2)) + ")";
                    break;
                }
                case EFFECT_TYPE_NEGATIVELEVEL:
                {
                    sStats = "-" + IntToString(GetEffectInteger(eEffect, 0)) + " Levels";
                    break;
                }
                case EFFECT_TYPE_CONCEALMENT:
                {
                    string sMissChance = MissChanceToString(GetEffectInteger(eEffect, 4) - 1);
                    sStats = IntToString(GetEffectInteger(eEffect, 0)) + "% Concealment" + (sMissChance == "" ? "" : " (" + sMissChance + ")");
                    sRacialTypeAlignment = GetVersusRacialTypeAndAlignment(GetEffectInteger(eEffect, 1), GetEffectInteger(eEffect, 2), GetEffectInteger(eEffect, 3));
                    break;
                }
                case EFFECT_TYPE_SPELL_RESISTANCE_INCREASE:
                case EFFECT_TYPE_SPELL_RESISTANCE_DECREASE:
                {
                    string sModifier = GetModifierType(nEffectType, EFFECT_TYPE_SPELL_RESISTANCE_INCREASE, EFFECT_TYPE_SPELL_RESISTANCE_DECREASE);
                    sStats = sModifier + IntToString(GetEffectInteger(eEffect, 0)) + " Spell Resistance";
                    break;
                }
                case EFFECT_TYPE_SPELL_FAILURE:
                {
                    sStats = IntToString(GetEffectInteger(eEffect, 0)) + "% Spell Failure (Spell School: " + SpellSchoolToString(GetEffectInteger(eEffect, 1)) + ")";
                    break;
                }
                case EFFECT_TYPE_INVISIBILITY:
                {
                    int nInvisibilityType = GetEffectInteger(eEffect, 0);
                    if (nEffectIconID == EFFECT_ICON_INVISIBILITY)
                        bSkipDisplay = nInvisibilityType != INVISIBILITY_TYPE_NORMAL;
                    else if (nEffectIconID == EFFECT_ICON_IMPROVEDINVISIBILITY)
                        bSkipDisplay = nInvisibilityType != INVISIBILITY_TYPE_IMPROVED;
                    if (!bSkipDisplay)
                    {
                        sStats = (nInvisibilityType == INVISIBILITY_TYPE_IMPROVED ? "Improved " : "") + "Invisibility";
                        sRacialTypeAlignment = GetVersusRacialTypeAndAlignment(GetEffectInteger(eEffect, 1), GetEffectInteger(eEffect, 2), GetEffectInteger(eEffect, 3));
                    }
                    break;
                }
                case EFFECT_TYPE_HASTE:
                {
                    sStats = "Hasted";
                }
            }
            if(!bSkipDisplay)
            {
                sText = sSpellName + " " + sDurationRemaining + (sStats == "" ? "" : " -> " + sStats + sRacialTypeAlignment);
                if(sText != "")
                {
                    ai_SendMessages(sText, sColor, oPlayer);
                    object oSource = GetEffectCreator(eEffect);
                    if(GetIsObjectValid(oSource))
                    {
                        sText = GetObjectType(oSource) ? GetName(oSource) : "<Unknown>";
                        sText = "        Creator: " + sText;
                        float fLength = IntToFloat(GetStringLength(sText) * 8);
                        ai_SendMessages(sText, AI_COLOR_YELLOW, oPlayer);
                    }
                }
            }
        }
        nIndex++;
        eEffect = GetNextEffect(oPlayer);
    }
}
void ai_CreateEffectIconMenu(object oPlayer, int nEffectIconID)
{
    int nIconEffectType = EffectIconToEffectType(nEffectIconID);
    if(nIconEffectType == EFFECT_TYPE_INVALIDEFFECT) return;
    int nLine, nColor, nIndex, nEffectIndex;
    int bSkipDisplay, bHasEffect;
    int nEffectType, bIsSpellLevelAbsorptionPretendingToBeSpellImmunity;
    string sText;
    json jEffectID = JsonArray();
    // ************************************************************************* Width / Height
    // Row 1 ******************************************************************* 500 / 27
    sText = Get2DAStrRef("effecticons", "StrRef", nEffectIconID);
    json jRow = CreateLabel(JsonArray(), "Effect: " + sText, "lbl_buff_name", 700.0f, 15.0f, NUI_HALIGN_LEFT, NUI_VALIGN_MIDDLE, 0.0);
    // Add row to the column.
    json jCol = JsonArrayInsert(JsonArray(), NuiRow(jRow));
    float fHeight = 27.0;
    effect eEffect = GetFirstEffect(oPlayer);
    while(GetIsEffectValid(eEffect))
    {
        bSkipDisplay = FALSE;
        nEffectType = GetEffectType(eEffect);
        // Unlimited EffectSpellLevelAbsorption has a SpellImmunity Icon
        if (nIconEffectType == EFFECT_TYPE_SPELL_IMMUNITY && GetEffectInteger(eEffect, 3))
        {
            bIsSpellLevelAbsorptionPretendingToBeSpellImmunity = TRUE;
            nIconEffectType = EFFECT_TYPE_SPELLLEVELABSORPTION;
        }
        if (nEffectType == nIconEffectType)
        {
            bHasEffect = TRUE;
            int nSpellID = GetEffectSpellId(eEffect);
            string sSpellName = nSpellID == -1 ? "<Unknown>" : Get2DAStrRef("spells", "Name", nSpellID);
            int bIsPermanentEffect = GetEffectDurationType(eEffect) == DURATION_TYPE_PERMANENT;
            int nDurationRemaining = GetEffectDurationRemaining(eEffect);
            string sDurationRemaining = bIsPermanentEffect ? "(Permanent)" : "(" + SecondsToTimestamp(nDurationRemaining) + ")";
            if(bIsPermanentEffect) nColor = 0x0000FFFF;
            else
            {
                float fPercentage = IntToFloat(nDurationRemaining) / IntToFloat(GetEffectDuration(eEffect));
                if(fPercentage > 0.5f) nColor = 0x00FF00FF;
                else if(fPercentage < 0.25f) nColor = 0xFF0000FF;
                else nColor = 0xFFFF00FF;
            }
            string sStats = "";
            string sRacialTypeAlignment = "";
            switch (nEffectType)
            {
                case EFFECT_TYPE_AC_INCREASE:
                case EFFECT_TYPE_AC_DECREASE:
                {
                    string sModifier = GetModifierType(nEffectType, EFFECT_TYPE_AC_INCREASE, EFFECT_TYPE_AC_DECREASE);
                    sStats = sModifier + IntToString(GetEffectInteger(eEffect, 1)) + " " + ACTypeToString(GetEffectInteger(eEffect, 0)) + " AC";
                    sRacialTypeAlignment = GetVersusRacialTypeAndAlignment(GetEffectInteger(eEffect, 2), GetEffectInteger(eEffect, 3), GetEffectInteger(eEffect, 4));
                    break;
                }
                case EFFECT_TYPE_ATTACK_INCREASE:
                case EFFECT_TYPE_ATTACK_DECREASE:
                {
                    string sModifier = GetModifierType(nEffectType, EFFECT_TYPE_ATTACK_INCREASE, EFFECT_TYPE_ATTACK_DECREASE);
                    sStats = sModifier + IntToString(GetEffectInteger(eEffect, 0)) +" AB";
                    sRacialTypeAlignment = GetVersusRacialTypeAndAlignment(GetEffectInteger(eEffect, 2), GetEffectInteger(eEffect, 3), GetEffectInteger(eEffect, 4));
                    break;
                }
                case EFFECT_TYPE_SAVING_THROW_INCREASE:
                case EFFECT_TYPE_SAVING_THROW_DECREASE:
                {
                    string sModifier = GetModifierType(nEffectType, EFFECT_TYPE_SAVING_THROW_INCREASE, EFFECT_TYPE_SAVING_THROW_DECREASE);
                    string sSavingThrow = SavingThrowToString(GetEffectInteger(eEffect, 1));
                    string sSavingThrowType = SavingThrowTypeToString(GetEffectInteger(eEffect, 2));
                    sStats = sModifier + IntToString(GetEffectInteger(eEffect, 0)) + " " + sSavingThrow + (sSavingThrowType == "" ? "" : " (vs. " + sSavingThrowType + ")");
                    sRacialTypeAlignment = GetVersusRacialTypeAndAlignment(GetEffectInteger(eEffect, 3), GetEffectInteger(eEffect, 4), GetEffectInteger(eEffect, 5));
                    break;
                }
                case EFFECT_TYPE_ABILITY_INCREASE:
                case EFFECT_TYPE_ABILITY_DECREASE:
                {
                    int nAbility = AbilityTypeFromEffectIconAbility(nEffectIconID);

                    if (nAbility != GetEffectInteger(eEffect, 0))
                        bSkipDisplay = TRUE;
                    else
                    {
                        string sModifier = GetModifierType(nEffectType, EFFECT_TYPE_ABILITY_INCREASE, EFFECT_TYPE_ABILITY_DECREASE);
                        sStats = sModifier + IntToString(GetEffectInteger(eEffect, 1)) + " " + AbilityToString(nAbility);
                    }
                    break;
                }
                case EFFECT_TYPE_DAMAGE_INCREASE:
                case EFFECT_TYPE_DAMAGE_DECREASE:
                {
                    string sModifier = GetModifierType(nEffectType, EFFECT_TYPE_DAMAGE_INCREASE, EFFECT_TYPE_DAMAGE_DECREASE);
                    sStats = sModifier + Get2DAStrRef("iprp_damagecost", "Name", GetEffectInteger(eEffect, 0)) + " (" + DamageTypeToString(GetEffectInteger(eEffect, 1)) + ")";
                    sRacialTypeAlignment = GetVersusRacialTypeAndAlignment(GetEffectInteger(eEffect, 2), GetEffectInteger(eEffect, 3), GetEffectInteger(eEffect, 4));
                    break;
                }
                case EFFECT_TYPE_SKILL_INCREASE:
                case EFFECT_TYPE_SKILL_DECREASE:
                {
                    int nSkill = GetEffectInteger(eEffect, 0);
                    string sSkill = nSkill == 255 ? "All Skills" : Get2DAStrRef("skills", "Name", nSkill);
                    string sModifier = GetModifierType(nEffectType, EFFECT_TYPE_SKILL_INCREASE, EFFECT_TYPE_SKILL_DECREASE);
                    sStats = sModifier + IntToString(GetEffectInteger(eEffect, 1)) + " " + sSkill;
                    sRacialTypeAlignment = GetVersusRacialTypeAndAlignment(GetEffectInteger(eEffect, 2), GetEffectInteger(eEffect, 3), GetEffectInteger(eEffect, 4));
                    break;
                }
                case EFFECT_TYPE_TEMPORARY_HITPOINTS:
                {
                    sStats = "+" + IntToString(GetEffectInteger(eEffect, 0)) + " HitPoints";
                    break;
                }
                case EFFECT_TYPE_DAMAGE_REDUCTION:
                {
                    int nAmount = GetEffectInteger(eEffect, 0);
                    int nDamagePower = GetEffectInteger(eEffect, 1);
                    nDamagePower = nDamagePower > 6 ? --nDamagePower : nDamagePower;
                    int nRemaining = GetEffectInteger(eEffect, 2);
                    sStats = IntToString(nAmount) + "/+" + IntToString(nDamagePower) + " (" + (nRemaining == 0 ? "Unlimited" : IntToString(nRemaining) + " Damage Remaining") + ")";
                    break;
                }
                case EFFECT_TYPE_DAMAGE_RESISTANCE:
                {
                    int nAmount = GetEffectInteger(eEffect, 1);
                    int nRemaining = GetEffectInteger(eEffect, 2);
                    sStats = IntToString(nAmount) + "/- " + DamageTypeToString(GetEffectInteger(eEffect, 0)) + " Resistance (" + (nRemaining == 0 ? "Unlimited" : IntToString(nRemaining) + " Damage Remaining") + ")";
                    break;
                }
                case EFFECT_TYPE_IMMUNITY:
                {
                    int nImmunity = ImmunityTypeFromEffectIconImmunity(nEffectIconID);

                    if (nImmunity != GetEffectInteger(eEffect, 0))
                        bSkipDisplay = TRUE;
                    else
                    {
                        sStats = Get2DAStrRef("effecticons", "StrRef", nEffectIconID);
                        sRacialTypeAlignment = GetVersusRacialTypeAndAlignment(GetEffectInteger(eEffect, 1), GetEffectInteger(eEffect, 2), GetEffectInteger(eEffect, 3));
                    }
                    break;
                }
                case EFFECT_TYPE_DAMAGE_IMMUNITY_INCREASE:
                case EFFECT_TYPE_DAMAGE_IMMUNITY_DECREASE:
                {
                    int nDamageType = GetEffectInteger(eEffect, 0);
                    int nDamageTypeFromIcon = DamageTypeFromEffectIconDamageImmunity(nEffectIconID);

                    if (nDamageTypeFromIcon != -1 && nDamageType != nDamageTypeFromIcon)
                        bSkipDisplay = TRUE;

                    string sModifier = GetModifierType(nEffectType, EFFECT_TYPE_DAMAGE_IMMUNITY_INCREASE, EFFECT_TYPE_DAMAGE_IMMUNITY_DECREASE);
                    sStats = sModifier + IntToString(GetEffectInteger(eEffect, 1)) + "% " + DamageTypeToString(nDamageType) + " Damage Immunity";
                    break;
                }
                case EFFECT_TYPE_SPELL_IMMUNITY:
                {
                    sStats = "Spell Immunity: " + Get2DAStrRef("spells", "Name", GetEffectInteger(eEffect, 0));
                    break;
                }
                case EFFECT_TYPE_SPELLLEVELABSORPTION:
                {
                    int nMaxSpellLevelAbsorbed = GetEffectInteger(eEffect, 0);
                    int bUnlimited = GetEffectInteger(eEffect, 3);
                    string sSpellLevel;
                    switch (nMaxSpellLevelAbsorbed)
                    {
                        case 0: sSpellLevel = "Cantrip"; break;
                        case 1: sSpellLevel = "1st"; break;
                        case 2: sSpellLevel = "2nd"; break;
                        case 3: sSpellLevel = "3rd"; break;
                        default: sSpellLevel = IntToString(nMaxSpellLevelAbsorbed) + "th"; break;
                    }
                    sSpellLevel += " Level" + (nMaxSpellLevelAbsorbed == 0 ? "" : " and Below");
                    string sSpellSchool = SpellSchoolToString(GetEffectInteger(eEffect, 2));
                    string sRemainingSpellLevels = bUnlimited ? "" : "(" + IntToString(GetEffectInteger(eEffect, 1)) + " Spell Levels Remaining)";
                    sStats = sSpellLevel + " " + sSpellSchool + " Spell Immunity " + sRemainingSpellLevels;

                    if (bIsSpellLevelAbsorptionPretendingToBeSpellImmunity)
                        nIconEffectType = EFFECT_TYPE_SPELL_IMMUNITY;
                    else if (bUnlimited && !bIsSpellLevelAbsorptionPretendingToBeSpellImmunity)
                        bSkipDisplay = TRUE;

                    break;
                }
                case EFFECT_TYPE_REGENERATE:
                {
                    sStats = "+" + IntToString(GetEffectInteger(eEffect, 0)) + " HP / " + FloatToString((GetEffectInteger(eEffect, 1) / 1000.0f), 0, 2) + "s";
                    break;
                }
                case EFFECT_TYPE_POISON:
                {
                    sStats = "Poison: " + Get2DAStrRef("poison", "Name", GetEffectInteger(eEffect, 0));
                    break;
                }
                case EFFECT_TYPE_DISEASE:
                {
                    sStats = "Disease: " + Get2DAStrRef("disease", "Name", GetEffectInteger(eEffect, 0));
                    break;
                }
                case EFFECT_TYPE_CURSE:
                {
                    int nAbility;
                    string sAbilityDecrease;
                    for (nAbility = 0; nAbility < 6; nAbility++)
                    {
                        int nAbilityMod = GetEffectInteger(eEffect, nAbility);
                        if (nAbilityMod > 0)
                        {
                            string sAbility = GetStringLeft(AbilityToString(nAbility), 3);
                            sAbilityDecrease += "-" + IntToString(nAbilityMod) + " " + sAbility + ", ";
                        }
                    }
                    sAbilityDecrease = GetStringLeft(sAbilityDecrease, GetStringLength(sAbilityDecrease) - 2);
                    sStats = sAbilityDecrease;
                    break;
                }
                case EFFECT_TYPE_MOVEMENT_SPEED_INCREASE:
                case EFFECT_TYPE_MOVEMENT_SPEED_DECREASE:
                {
                    string sModifier = GetModifierType(nEffectType, EFFECT_TYPE_MOVEMENT_SPEED_INCREASE, EFFECT_TYPE_MOVEMENT_SPEED_DECREASE);
                    sStats = sModifier + IntToString(GetEffectInteger(eEffect, 0)) + "% Movement Speed";
                    break;
                }
                case EFFECT_TYPE_ELEMENTALSHIELD:
                {
                    sStats = IntToString(GetEffectInteger(eEffect, 0)) + " + " + Get2DAStrRef("iprp_damagecost", "Name", GetEffectInteger(eEffect, 1)) + " (" + DamageTypeToString(GetEffectInteger(eEffect, 2)) + ")";
                    break;
                }
                case EFFECT_TYPE_NEGATIVELEVEL:
                {
                    sStats = "-" + IntToString(GetEffectInteger(eEffect, 0)) + " Levels";
                    break;
                }
                case EFFECT_TYPE_CONCEALMENT:
                {
                    string sMissChance = MissChanceToString(GetEffectInteger(eEffect, 4) - 1);
                    sStats = IntToString(GetEffectInteger(eEffect, 0)) + "% Concealment" + (sMissChance == "" ? "" : " (" + sMissChance + ")");
                    sRacialTypeAlignment = GetVersusRacialTypeAndAlignment(GetEffectInteger(eEffect, 1), GetEffectInteger(eEffect, 2), GetEffectInteger(eEffect, 3));
                    break;
                }
                case EFFECT_TYPE_SPELL_RESISTANCE_INCREASE:
                case EFFECT_TYPE_SPELL_RESISTANCE_DECREASE:
                {
                    string sModifier = GetModifierType(nEffectType, EFFECT_TYPE_SPELL_RESISTANCE_INCREASE, EFFECT_TYPE_SPELL_RESISTANCE_DECREASE);
                    sStats = sModifier + IntToString(GetEffectInteger(eEffect, 0)) + " Spell Resistance";
                    break;
                }
                case EFFECT_TYPE_SPELL_FAILURE:
                {
                    sStats = IntToString(GetEffectInteger(eEffect, 0)) + "% Spell Failure (Spell School: " + SpellSchoolToString(GetEffectInteger(eEffect, 1)) + ")";
                    break;
                }
                case EFFECT_TYPE_INVISIBILITY:
                {
                    int nInvisibilityType = GetEffectInteger(eEffect, 0);
                    if (nEffectIconID == EFFECT_ICON_INVISIBILITY)
                        bSkipDisplay = nInvisibilityType != INVISIBILITY_TYPE_NORMAL;
                    else if (nEffectIconID == EFFECT_ICON_IMPROVEDINVISIBILITY)
                        bSkipDisplay = nInvisibilityType != INVISIBILITY_TYPE_IMPROVED;
                    if (!bSkipDisplay)
                    {
                        sStats = (nInvisibilityType == INVISIBILITY_TYPE_IMPROVED ? "Improved " : "") + "Invisibility";
                        sRacialTypeAlignment = GetVersusRacialTypeAndAlignment(GetEffectInteger(eEffect, 1), GetEffectInteger(eEffect, 2), GetEffectInteger(eEffect, 3));
                    }
                    break;
                }
                case EFFECT_TYPE_HASTE:
                {
                    sStats = "Hasted";
                }
            }
            if(!bSkipDisplay)
            {
                sText = sSpellName + " " + sDurationRemaining + (sStats == "" ? "" : " -> " + sStats + sRacialTypeAlignment);
                if(sText != "")
                {
                    jRow = CreateLabel(JsonArray(), "    " + sText, "lbl_buff_info" + IntToString(nIndex), 700.0f, 10.0f, NUI_HALIGN_LEFT, NUI_VALIGN_TOP, 0.0);
                    // Add row to the column.
                    jCol = JsonArrayInsert(jCol, NuiRow(jRow));
                    fHeight += 10.0;
                    object oSource = GetEffectCreator(eEffect);
                    if(GetIsObjectValid(oSource))
                    {
                        sText = GetObjectType(oSource) ? GetName(oSource) : "<Unknown>";
                        sText = "        Creator: " + sText;
                        float fLength = IntToFloat(GetStringLength(sText) * 8);
                        jRow = CreateLabel(JsonArray(), sText, "lbl_buff_source" + IntToString(nIndex), fLength, 15.0f, NUI_HALIGN_LEFT, NUI_VALIGN_BOTTOM, 0.0);
                        if(oSource == oPlayer)
                        {
                            CreateButton(jRow, "Remove", "btn_remove_effect_" + IntToString(nEffectIndex++), 70.0f, 20.0f, 0.0);
                            jEffectID = JsonArrayInsert(jEffectID, JsonString(GetEffectLinkId(eEffect)));
                            fHeight += 20.0;
                        }
                        else fHeight += 15.0;
                        // Add row to the column.
                        jCol = JsonArrayInsert(jCol, NuiRow(jRow));
                    }
                }
            }
        }
        nIndex++;
        eEffect = GetNextEffect(oPlayer);
    }
    float fScale = IntToFloat(GetPlayerDeviceProperty(oPlayer, PLAYER_DEVICE_PROPERTY_GUI_SCALE)) / 100.0;
    float fX = IntToFloat(GetPlayerDeviceProperty(oPlayer, PLAYER_DEVICE_PROPERTY_GUI_WIDTH));
    fX = fX - (700.0 * fScale);
    float fY = 50 * fScale;
    // Set the Layout of the window.
    json jLayout = NuiCol(jCol);
    int nToken = SetWindow(oPlayer, jLayout, AI_EFFECT_ICON_NUI, "Effect Icon Menu",
                             fX, fY, 700.0, fHeight * fScale, FALSE, FALSE, FALSE, TRUE, FALSE, "0e_nui");
    // Save the associate to the nui for use in 0e_nui
    json jData = JsonArrayInsert(JsonArray(), JsonString(ObjectToString(oPlayer)));
    jData = JsonArrayInsert(jData, JsonInt(nEffectIconID));
    jData = JsonArrayInsert(jData, jEffectID);
    NuiSetUserData(oPlayer, nToken, jData);
    NuiSetBind(oPlayer, nToken, "lbl_buff_name_event", JsonBool(TRUE));
    while(nIndex >= 0)
    {
        NuiSetBind(oPlayer, nToken, "lbl_buff_info" + IntToString(nIndex) + "_event", JsonBool(TRUE));
        NuiSetBind(oPlayer, nToken, "lbl_buff_source" + IntToString(nIndex) + "_event", JsonBool(TRUE));
        nIndex--;
    }
    while(nEffectIndex >= 0)
    {
        NuiSetBind(oPlayer, nToken, "btn_remove_effect_" + IntToString(nEffectIndex) + "_event", JsonBool(TRUE));
        NuiSetBind(oPlayer, nToken, "btn_remove_effect_" + IntToString(nEffectIndex), JsonInt(TRUE));
        nEffectIndex--;
    }
}
