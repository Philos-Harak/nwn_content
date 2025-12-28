/*//////////////////////////////////////////////////////////////////////////////
 Script: 0c_if_equal_int
 Programmer: Philos
////////////////////////////////////////////////////////////////////////////////
 Text Appears When script that checks to see if a specific variable is equal.
 Param:
 sVar - the name of the variable on the NPC.
 nValue - the value
 nFalse - if set to 1 then we look for if var does not equal nValue!
*///////////////////////////////////////////////////////////////////////////////
int StartingConditional()
{
    string sVar = GetScriptParam ("sVar");
    int nValue = StringToInt (GetScriptParam ("nValue"));
    int nFalse = StringToInt (GetScriptParam ("nFalse"));
    if (nFalse) return GetLocalInt (OBJECT_SELF, sVar) != nValue;
    return GetLocalInt (OBJECT_SELF, sVar) == nValue;
}
