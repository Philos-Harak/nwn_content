/*//////////////////////////////////////////////////////////////////////////////
 Script: 0c_set_racexp
 Programmer: Philos
////////////////////////////////////////////////////////////////////////////////
 Text Appears When script that sets CUSTOM500 to show racial xp in the
 players handbook.
*///////////////////////////////////////////////////////////////////////////////
#include "0i_master"
int StartingConditional()
{
    int nRace, nRacialXPNeeded;
    object oPC = GetPCSpeaker ();
    // Get any racial xp left.
    int nRacialXP = FloatToInt (GetLocalFloat (oPC, "0_RacialXP"));
    if(nRacialXP > 0)
    {
        int nECL = FloatToInt(GetEffectiveCharacterLevel(oPC));
        if(nECL == 1) nRacialXPNeeded = 1000; 
        else if(nECL == 2) nRacialXPNeeded = 3000;
        else if(nECL == 3) nRacialXPNeeded = 6000;
        // We only save what racial xp is left to get.
        // Get the actual Racial xp by looking at what we have left and subtracting what is needed.
        nRacialXP = nRacialXPNeeded - nRacialXP;
        // To get what we need subtract xp needed by actual racial xp.
        nRacialXPNeeded = nRacialXPNeeded - nRacialXP;
        SetCustomToken (500, "Racial XP: " + IntToString (nRacialXP) + " Racial XP needed: " + IntToString (nRacialXPNeeded));
    }
    else SetCustomToken (500, "0");
    return TRUE;
}
