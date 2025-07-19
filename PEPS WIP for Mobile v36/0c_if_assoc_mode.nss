/*//////////////////////////////////////////////////////////////////////////////
 Script: 0c_if_assoc_mode
 Programmer: Philos
////////////////////////////////////////////////////////////////////////////////
 Text Appears When script that checks to see if the henchmen has a specific
 associate mode.
 Param:
 nMode - The mode to check.
*///////////////////////////////////////////////////////////////////////////////
#include "0i_associates"
int StartingConditional()
{
    object oHenchman = OBJECT_SELF;
    int nMode = StringToInt(GetScriptParam("nMode"));
    // This conversation line turns off picking up any items.
    if (nMode == -1)
    {
        if(ai_SetAIMode (oHenchman, AI_MODE_PICKUP_ITEMS)) return TRUE;
        return FALSE;
    }
    return ai_GetAIMode (oHenchman, nMode);
}
