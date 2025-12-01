/*//////////////////////////////////////////////////////////////////////////////
 Script: 0c_if_has_class
 Programmer: Philos
////////////////////////////////////////////////////////////////////////////////
 Text Appears When script that checks to see if conversation owner has a
 specified class. Multiple classes maybe selected.
 Param
 nClass# - the class to look for use nClass1, nClass2, nClass3 for each one to check.
*///////////////////////////////////////////////////////////////////////////////
int StartingConditional()
{
    object oHenchman = OBJECT_SELF;
    int nCntr = 1;
    int nClass;
    string sClass;
    while(nCntr < 10)
    {
        sClass = GetScriptParam("nClass" + IntToString(nCntr));
        if(sClass != "")
        {
            nClass = StringToInt(sClass);
            if(GetLevelByClass(nClass, oHenchman)) return TRUE;
            nCntr++;
        }
        else break;
    }
    return FALSE;
}
