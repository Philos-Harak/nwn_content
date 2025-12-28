/*//////////////////////////////////////////////////////////////////////////////
 Script: 0c_if_roll
 Programmer: Philos
////////////////////////////////////////////////////////////////////////////////
 Text Appears When script that check if a roll needs to be made and/or if a
 specific roll was made for conversation nodes.
 Param:
 sDice - rolls a die i.e. 1d6, 2d8, 10d4, if set will roll these dice.
 sQualifier - set to either "==", ">", "<".
 nResult - the number to check the roll against, i.e. ">","3" is (Roll > 3)
*///////////////////////////////////////////////////////////////////////////////
#include "0i_master"
int StartingConditional()
{
    int nRoll;
    object oPC = GetPCSpeaker ();
    string sDice = GetScriptParam ("sDice");
    if (sDice != "")
    {
        nRoll = RollDiceString (sDice);
        SetLocalInt (oPC, "0_Roll", nRoll);
    }
    else nRoll = GetLocalInt (oPC, "0_Roll");
    string sQualifier = GetScriptParam ("sQualifier");
    int nResult = StringToInt (GetScriptParam ("nResult"));
    if (sQualifier == "==") {if (nRoll == nResult) return TRUE;}
    else if (sQualifier == ">")
    {
        if (nRoll > nResult)
        {
            SetLocalInt (oPC, "0_Roll", 9999);
            return TRUE;
        }
    }
    else if (sQualifier == "<")
    {
        if (nRoll < nResult)
        {
            SetLocalInt (oPC, "0_Roll", -9999);
            return TRUE;
        }
    }
    return FALSE;
}
