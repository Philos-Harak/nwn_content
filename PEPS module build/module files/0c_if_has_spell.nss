/*//////////////////////////////////////////////////////////////////////////////
 Script: 0c_if_has_spell
 Programmer: Philos
////////////////////////////////////////////////////////////////////////////////
 Text Appears When script that checks to see if caster can cast the specified spell.
 Param
 nSpell# - the spell to look for nSpell1, sSpell2, nSpell3 for each spell to check.
*///////////////////////////////////////////////////////////////////////////////
#include "0i_spells"
int StartingConditional()
{
    object oCaster = OBJECT_SELF;
    int nCnt = 1;
    int nSpell;
    string sSpell;
    while(nCnt < 20)
    {
        sSpell = GetScriptParam("nSpell" + IntToString(nCnt));
        if(sSpell == "") return FALSE;
        nSpell = StringToInt(sSpell);
        if(GetHasSpell(nSpell, oCaster)) return TRUE;
        //else if(ai_GetKnownSpell(oCaster, nSpell)) return TRUE;
        nCnt++;
    }
    return FALSE;
}
