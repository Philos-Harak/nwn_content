/*//////////////////////////////////////////////////////////////////////////////
 Script: 0c_if_search
 Programmer: Philos
////////////////////////////////////////////////////////////////////////////////
 Text Appears When script that checks to see if the henchmen is either in
 search mode or out of search mode.
 Param:
 nMode - the state of search mode 1- TRUE if searching 0 - TRUE if not searching.
*///////////////////////////////////////////////////////////////////////////////
#include "0i_main"
int StartingConditional()
{
    object oHenchman = OBJECT_SELF;
    int nMode = StringToInt(GetScriptParam("nMode"));
    if(nMode)
    {
        if(GetHasFeat(FEAT_KEEN_SENSE)) return FALSE;
        if(GetDetectMode(oHenchman) == DETECT_MODE_ACTIVE) return TRUE;
    }
    return (!nMode && GetDetectMode(oHenchman) == DETECT_MODE_PASSIVE);
}
