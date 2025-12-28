/*//////////////////////////////////////////////////////////////////////////////
 Script: 0c_if_has_gold
 Programmer: Philos
////////////////////////////////////////////////////////////////////////////////
 Text Appears When script that checks to see if the PC has x amount of gold.
 Param:
 nGold - amount of gold to see if the PC has.
*///////////////////////////////////////////////////////////////////////////////
#include "0i_master"
int StartingConditional()
{
    object oPC = GetPCSpeaker ();
    int nGold = StringToInt (GetScriptParam ("nGold"));
    if (GetGold (oPC) < nGold) return FALSE;
    return TRUE;
}
