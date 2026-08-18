/*/////////////////////////////////////////////////////
 0s_arcane_song_r
 Created By: Philos
///////////////////////////////////////////////////////
 This removes the bonuses from the bard's arcane song.
 OBJECT_SELF is the target of the effect.
/*/////////////////////////////////////////////////////
#include "0i_spells"
#include "nwnx_effect"

void main()
{
    int iMod, iValue;
    string sArray;
    // Arcane Song String Array;
    // : Caster Level : Spell DC : Spell Dmg : Spell Widen : Spell Duration :
    effect eEffect = GetLastRunScriptEffect ();
    sArray = GetEffectString (eEffect, 0);
    iMod = StringToInt (GetStringArray (sArray, 0));
    if (iMod > 0)
    {
        int iValue = GetLocalInt (OBJECT_SELF, "0_SpellCasterLvlMod");
        SetLocalInt (OBJECT_SELF, "0_SpellCasterLevel", iValue - iMod);
    }
    iMod = StringToInt (GetStringArray (sArray, 1));
    if (iMod > 0)
    {
        int iValue = GetLocalInt (OBJECT_SELF, "0_Spell_DC_Mod");
        SetLocalInt (OBJECT_SELF, "0_Spell_DC_Mod", iValue - iMod);
    }
    iMod = StringToInt (GetStringArray (sArray, 2));
    if (iMod > 0)
    {
        int iValue = GetLocalInt (OBJECT_SELF, "0_SpellDmgMod");
        SetLocalInt (OBJECT_SELF, "iSpellDmg", iValue - iMod);
    }
    iMod = StringToInt (GetStringArray (sArray, 3));
    if (iMod > 0)
    {
        int iValue = GetLocalInt (OBJECT_SELF, "0_SpellWidthMod");
        SetLocalInt (OBJECT_SELF, "0_SpellWidthMod", iValue - iMod);
    }
    iMod = StringToInt (GetStringArray (sArray, 4));
    if (iMod > 0)
    {
        int iValue = GetLocalInt (OBJECT_SELF, "0_SpellDurationMod");
        SetLocalInt (OBJECT_SELF, "0_SpellDurationMod", iValue - iMod);
    }
}

