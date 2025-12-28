/*//////////////////////////////////////////////////////////////////////////////
 Script: 0c_if_month
 Programmer: Philos
////////////////////////////////////////////////////////////////////////////////
 Text Appears When script that checks to see if we are in specific months.
 Param = sMonth, sMonth2, sMonth3, etc up to 11;
*///////////////////////////////////////////////////////////////////////////////
#include "0i_master"
int StartingConditional()
{
    object oPC = GetPCSpeaker();
    int nCurrentMonth = GetCalendarMonth();
    string sMonth = GetScriptParam("sMonth");
    if(StringToInt(sMonth) == nCurrentMonth) return TRUE;
    else
    {
        int nIndex = 2;
        sMonth = GetScriptParam("sMonth2");
        while(sMonth != "" || nIndex < 12)
        {
            if(StringToInt(sMonth) == nCurrentMonth) return TRUE;
            sMonth = GetScriptParam("sMonth" + IntToString(++nIndex));
        }
    }
    return FALSE;
}
