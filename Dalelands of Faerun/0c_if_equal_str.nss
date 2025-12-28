/*//////////////////////////////////////////////////////////////////////////////
 Script: 0c_if_equal_str
 Programmer: Philos
////////////////////////////////////////////////////////////////////////////////
 Text Appears When script that checks to see if a specific variable is equal.
 Param:
 sVar - the name of the variable on the NPC.
 sValue - the value
 nFalse - if set to 1 then we look for if var does not equal nValue!
*///////////////////////////////////////////////////////////////////////////////
int StartingConditional()
{
    string sVar = GetScriptParam ("sVar");
    string sValue = GetScriptParam ("sValue");
    int nFalse = StringToInt (GetScriptParam ("sFalse"));
    if (nFalse) return GetLocalString (OBJECT_SELF, sVar) != sValue;
    return GetLocalString (OBJECT_SELF, sVar) == sValue;
}
