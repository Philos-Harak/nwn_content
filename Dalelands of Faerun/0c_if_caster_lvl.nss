/*//////////////////////////////////////////////////////////////////////////////
 Script: 0c_if_caster_lvl
 Programmer: Philos
////////////////////////////////////////////////////////////////////////////////
 Text Appears When script that checks to see if caster can has the specified
 level or higher for each class option.
 Param
 nLevel - the level to check for.
 nClass1 - any number of classes that should be that level based on Class.2da.
*///////////////////////////////////////////////////////////////////////////////
#include "0i_spells"
int StartingConditional()
{
    int nCasterLevel;
    object oCreature = GetPCSpeaker ();
    int nLevel = StringToInt (GetScriptParam ("nLevel"));
    int i = 1;
    string sClass = GetScriptParam ("nClass" + IntToString (i));
    while (sClass != "")
    {
        nCasterLevel = GetCasterLevelByClass (oCreature, StringToInt (sClass));
        if (nCasterLevel >= nLevel) return TRUE;
        i ++;
        sClass = GetScriptParam ("nClass" + IntToString (i));
    }
    return FALSE;
}
