/*//////////////////////////////////////////////////////////////////////////////
 Script: 0c_if_racialtype
 Programmer: Philos
////////////////////////////////////////////////////////////////////////////////
 Text Appears When script that checks racial type of the PC speaker.
 Param:
 nRacialType - the racial type to check used in racialtypes.2da.
*///////////////////////////////////////////////////////////////////////////////
#include "0i_master"
#include "nwnx_race_2da"
int StartingConditional()
{
    object oPC = GetPCSpeaker ();
    int nRacialType = StringToInt (GetScriptParam ("nRacialType"));
    if (nRacialType == GetRacialType (oPC) || GetIsDungeonMaster (oPC)) return TRUE;
    return FALSE;
}
