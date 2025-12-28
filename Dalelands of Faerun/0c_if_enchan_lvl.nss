/*//////////////////////////////////////////////////////////////////////////////
 Script: 0c_if_enchan_lvl
 Programmer: Philos
////////////////////////////////////////////////////////////////////////////////
 Text Appears When script that checks to see if caster for enchanting can select
 this caster level.
 Param:
 nLevel - the level to check for.
*///////////////////////////////////////////////////////////////////////////////
#include "0i_spells"
int StartingConditional()
{
    int nLevel = StringToInt (GetScriptParam ("nLevel"));
    // Check minimum level.
    if (GetLocalInt (OBJECT_SELF, "0_Min_Spell_Level") > nLevel) return FALSE;
    int nCasterLevel = GetLocalInt (OBJECT_SELF, "0_CasterLevel");
    int nSpellID = GetLocalInt (OBJECT_SELF, "0_Spell");
    // Check the spells max enchantment level.
    int nSpellLevel = StringToInt (Get2DAString ("enchant_table", "max_level", nSpellID));
    // compare spell level with caster level.
    if (nSpellLevel < nCasterLevel) nCasterLevel = nSpellLevel;
    // DM's get all the levels.
    if (GetIsDungeonMaster (OBJECT_SELF)) nCasterLevel = 20;
    // Check to see if we can show this level.
    if (nCasterLevel > nLevel) return TRUE;
    return FALSE;
}
