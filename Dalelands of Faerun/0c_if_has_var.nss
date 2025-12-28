/*//////////////////////////////////////////////////////////////////////////////
 Script: 0c_if_has_var
////////////////////////////////////////////////////////////////////////////////
 Text Appears When script that checks to see if caster can has a variable with
      a specific value.
 Param
 nVarObject is which object to get variable from. 0)oPC 1)OBJECT_SELF
 nVarType is the type of variable 1)Int 2)Float 3)String
 sVarName is the variable name.
 sValue is the value required to have.
*///////////////////////////////////////////////////////////////////////////////
#include "0i_spells"
int StartingConditional()
{
    int nVarObject = StringToInt (GetScriptParam ("nVarObject"));
    object oObject;
    if (nVarObject == 0) oObject = GetPCSpeaker ();
    else oObject = OBJECT_SELF;
    int nType = StringToInt (GetScriptParam ("nVarType"));
    string sVarName = GetScriptParam ("sVarName");
    string sValue = GetScriptParam ("sValue");
    if (nType == 1)
    {
        if (GetLocalInt (oObject, sVarName) == StringToInt (sValue)) return TRUE;
    }
    if (nType == 2)
    {
        if (GetLocalFloat (oObject, sVarName) == StringToFloat (sValue)) return TRUE;
    }
    if (nType == 3)
    {
        if (GetLocalString (oObject, sVarName) == sValue) return TRUE;
    }
    return FALSE;
}
