/*//////////////////////////////////////////////////////////////////////////////
 Script Name: NW_S0_Summon
 Programmer: Preston Watamaniuk
////////////////////////////////////////////////////////////////////////////////
Conjuration (Summoning) [see text]
Level: 1st through 9th.
Components: V, S, F/DF
Casting Time: 1 round
Range: Close (25 ft. + 5 ft./2 levels)
Effect: One summoned creature
Duration: 1 hour / level (D)
Saving Throw: None
Spell Resistance: No

This spell summons an extraplanar creature (typically an outsider, elemental, or
magical beast native to another plane). It appears where you designate and acts
immediately, on your turn. It attacks your opponents to the best of its ability.
The spell conjures one of the creatures selected on the summoning list in the
Player's Handbook in the Spells chapter. You choose which kind of creature to summon,
and you can change that choice at any time.
A summoned monster cannot summon or otherwise conjure another creature, nor can it
use any teleportation or planar travel abilities.

Arcane Focus: A tiny bag and a small (not necessarily lit) candle.
/*//////////////////////////////////////////////////////////////////////////////
#include "0i_spells"
string GetSummonResRef (int nSpellID);
int GetSummonVisualEffect (int iSpellID);

void main()
{
    // ***********************************************************
    // *************** Set Spell Structure ***********************
    // ***********************************************************
    // Setup the spell in the structured variables, then pass through the SetSpell function.
    Spell.iSubType = SUBTYPE_MAGICAL;
    Spell.iSubSchool = SUBSCHOOL_SUMMONING;
    Spell.sArcaneComponent = COMPONENT_POUCH;
    Spell.iDivineFocus = TRUE;
    Spell.iDurationType = DURATION_TYPE_HOURS;
    Spell.iDuration = 1;
    Spell.iDurPerLvl = 1;
    Spell = SetSpell (Spell);
    if (Spell.iSpellID == STOP_SPELL) return;
    Spell = GetDuration (Spell);
    // *******************************************************************
    // ********************** Spell effects ******************************
    // *******************************************************************
    int iSpellID;
    object oSummons;
    string sSummonResRef = GetSummonResRef (Spell.iSpellID);
    int nVisualEffect = GetSummonVisualEffect (Spell.iSpellID);
    effect eSummons = EffectSummonCreature (sSummonResRef, nVisualEffect);
    effect eVisual = EffectVisualEffect (nVisualEffect);
    // Check to see if we have multiple summons.
    // Sorcerer: Abyssal blood line IV: Summon Fiendish creatures with each summoning spell.
    if (GetHasFeat (1318, Spell.oCaster) && GetStringLeft (sSummonResRef, 3) == "s_f") iSpellID = Spell.iSpellID;
    // Sorcerer: Celestial blood line IV: Summon Celestial creatures with each summoning spell.
    else if (GetHasFeat (1328, Spell.oCaster) && GetStringLeft (sSummonResRef, 3) == "s_c") iSpellID = Spell.iSpellID;
    // Limits casters to only have one summon creature from the summoning spells.
    else iSpellID = SPELL_SUMMON_CREATURE_I;
    AdjustCurrentSummonedCreatures (Spell.oCaster, iSpellID);
    ApplyEffectAtLocation (DURATION_TYPE_TEMPORARY, eSummons, Spell.lTarget, Spell.fDuration);
    MarkSummonedCreatures (Spell.oCaster, iSpellID);
    CleanUpSpell (Spell);
}

int GetSummonVisualEffect (int iSpellID)
{
    if (iSpellID == SPELL_SUMMON_CREATURE_I) return VFX_FNF_SUMMON_MONSTER_1;
    else if (iSpellID == SPELL_SUMMON_CREATURE_II) return VFX_FNF_SUMMON_MONSTER_1;
    else if (iSpellID == SPELL_SUMMON_CREATURE_III) return VFX_FNF_SUMMON_MONSTER_1;
    else if (iSpellID == SPELL_SUMMON_CREATURE_IV) return VFX_FNF_SUMMON_MONSTER_2;
    else if (iSpellID == SPELL_SUMMON_CREATURE_V) return VFX_FNF_SUMMON_MONSTER_2;
    else if (iSpellID == SPELL_SUMMON_CREATURE_VI) return VFX_FNF_SUMMON_MONSTER_2;
    return VFX_FNF_SUMMON_MONSTER_3;
}

string GetSummonResRef (int iSpellID)
{
    int iNumToSummons = 1;
    int iRoll = d4();
    string sSummon, sSummonArray;
    effect eSummonedMonster;
    // Get the casters summons array.
    if (GetIsCharacter (Spell.oCaster)) sSummonArray = GetObjectDatabaseString (Spell.oCaster, CHARACTER_TABLE, "summons");
    // None players
    else
    {
        iRoll = d10();
        if (iRoll < 6) sSummonArray = "::s_dire_1:s_dire_2:s_dire_3:s_dire_4:s_dire_5:s_dire_6:s_dire_7:s_dire_8:s_dire_9:";
        else if (iRoll == 6) sSummonArray = "::s_air_e_1:s_air_e_2:s_air_e_3:s_air_e_4:s_air_e_5:s_air_e_6:s_air_e_7:s_air_e_8:s_air_e_9:";
        else if (iRoll == 7) sSummonArray = "::s_earth_e_1:s_earth_e_2:s_earth_e_3:s_earth_e_4:s_earth_e_5:s_earth_e_6:s_earth_e_7:s_earth_e_8:s_earth_e_9:";
        else if (iRoll == 8) sSummonArray = "::s_fire_e_1:s_fire_e_2:s_fire_e_3:s_fire_e_4:s_fire_e_5:s_fire_e_6:s_fire_e_7:s_fire_e_8:s_fire_e_9:";
        else if (iRoll == 9) sSummonArray = "::s_water_e_1:s_water_e_2:s_water_e_3:s_water_e_4:s_water_e_5:s_water_e_6:s_water_e_7:s_water_e_8:s_water_e_9:";
        else if (iRoll == 10) sSummonArray = "::s_fiendish_1:s_fiendish_2:s_fiendish_3:s_fiendish_4:s_fiendish_5:s_fiendish_6:s_fiendish_7:s_fiendish_8:s_fiendish_9:";
    }
    //Debug ("nw_s0_summon", "41", sSummonArray);
    if (iSpellID == SPELL_SUMMON_CREATURE_I)
    {
        sSummon = GetStringArray (sSummonArray, 1);
        // If they have no summons then use the default.
        if (sSummon == "") sSummon = "s_dire_1";
    }
    else if (iSpellID == SPELL_SUMMON_CREATURE_II)
    {
        sSummon = GetStringArray (sSummonArray, 2);
        // If they have no summons then use the default.
        if (sSummon == "") sSummon = "s_dire_2";
    }
    else if (iSpellID == SPELL_SUMMON_CREATURE_III)
    {
        sSummon = GetStringArray (sSummonArray, 3);
        // If they have no summons then use the default.
        if (sSummon == "") sSummon = "s_dire_3";
    }
    else if (iSpellID == SPELL_SUMMON_CREATURE_IV)
    {
        sSummon = GetStringArray (sSummonArray, 4);
        // If they have no summons then use the default.
        if (sSummon == "") sSummon = "s_dire_4";
    }
    else if (iSpellID == SPELL_SUMMON_CREATURE_V)
    {
        sSummon = GetStringArray (sSummonArray, 5);
        // If they have no summons then use the default.
        if (sSummon == "") sSummon = "s_dire_5";
    }
    else if (iSpellID == SPELL_SUMMON_CREATURE_VI)
    {
        sSummon = GetStringArray (sSummonArray, 6);
        // If they have no summons then use the default.
        if (sSummon == "") sSummon = "s_dire_6";
    }
    else if (iSpellID == SPELL_SUMMON_CREATURE_VII)
    {
        sSummon = GetStringArray (sSummonArray, 7);
        // If they have no summons then use the default.
        if (sSummon == "")
        {
            switch (iRoll)
            {
                case 1:
                    sSummon = "s_air_e_7";
                break;
                case 2:
                    sSummon = "s_earth_e_7";
                break;
                case 3:
                    sSummon = "s_fire_e_7";
                break;
                case 4:
                    sSummon = "s_water_e_7";
                break;
            }
        }
    }
    else if (iSpellID == SPELL_SUMMON_CREATURE_VIII)
    {
        sSummon = GetStringArray (sSummonArray, 8);
        // If they have no summons then use the default.
        if (sSummon == "")
        {
            switch (iRoll)
            {
                case 1:
                    sSummon = "s_air_e_8";
                break;
                case 2:
                    sSummon = "s_earth_e_8";
                break;
                case 3:
                    sSummon = "s_fire_e_8";
                break;
                case 4:
                    sSummon = "s_water_e_8";
                break;
            }
        }
    }
    else if (iSpellID == SPELL_SUMMON_CREATURE_IX)
    {
        sSummon = GetStringArray (sSummonArray, 9);
        // If they have no summons then use the default.
        if (sSummon == "")
        {
            switch (iRoll)
            {
                case 1:
                    sSummon = "s_air_e_9";
                break;
                case 2:
                    sSummon = "s_earth_e_9";
                break;
                case 3:
                    sSummon = "s_fire_e_9";
                break;
                case 4:
                    sSummon = "s_water_e_9";
                break;
            }
        }
    }
    return sSummon;
}

