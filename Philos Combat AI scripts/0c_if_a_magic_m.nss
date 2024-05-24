/*//////////////////////////////////////////////////////////////////////////////
 Script: 0c_if_a_magic_m
 Programmer: Philos
////////////////////////////////////////////////////////////////////////////////
 Text Appears When script that checks to see if the henchmen has a specific
 associate magic mode.
 Param:
 nMode - The mode to check.
*///////////////////////////////////////////////////////////////////////////////
#include "0i_associates"
int StartingConditional()
{
    object oHenchman = OBJECT_SELF;
    int nMode = StringToInt(GetScriptParam("nMode"));
    return ai_GetAssociateMagicMode (oHenchman, nMode);
}
