/*//////////////////////////////////////////////////////////////////////////////
 Script: 0c_if_not_master
 Programmer: Philos
////////////////////////////////////////////////////////////////////////////////
 Text Appears When script that checks if the speaker is the master of this
 henchman.
*///////////////////////////////////////////////////////////////////////////////
#include "0i_constants"
int StartingConditional()
{
    string sInput = GetScriptParam("sInput");
    if(sInput == "Can_Hire_Henchman" && AI_ALLOW_TAKING_HENCHMAN) return !GetIsObjectValid(GetMaster());
    else if(sInput == "Cannot_Hire_Henchman") return !GetIsObjectValid(GetMaster());
    return FALSE;
}
