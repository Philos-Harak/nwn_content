/*//////////////////////////////////////////////////////////////////////////////
 Script: 0c_if_pc_level
 Programmer: Philos
////////////////////////////////////////////////////////////////////////////////
 Text Appears When script that checks to see if they are a PC of nLevel.
 Param (Int): nLevel
*///////////////////////////////////////////////////////////////////////////////
#include "0i_character"
int StartingConditional()
{
    object oPC = GetPCSpeaker();
    int nLevel = StringToInt(GetScriptParam("nLevel"));
    if(GetCharacterLevels(oPC) >= nLevel) return TRUE;
    return FALSE;
}
