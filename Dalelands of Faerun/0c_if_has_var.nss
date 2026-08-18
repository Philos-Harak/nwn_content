/*//////////////////////////////////////////////////////////////////////////////
 Script: 0c_if_has_var
////////////////////////////////////////////////////////////////////////////////
 Text Appears When script that checks to see if caster can has a variable with
      a specific value.
 Param
 sVarObject is which object to get variable from. 0)oPC 1)OBJECT_SELF
 nVarType is the type of variable 1)Int 2)Float 3)String
 sVarName is the variable name.
 sValue is the value required to have.
*///////////////////////////////////////////////////////////////////////////////
#include "0i_spells"
int StartingConditional()
{
    object oPC = GetPCSpeaker();
    string sVarObject = GetScriptParam("sVarObject");
    object oObject;
    if(sVarObject == "PCSpeaker") oObject = oPC;
    else if(sVarObject == "OBJECT_SELF") oObject = OBJECT_SELF;
    else if(sVarObject != "") oObject = GetCreatureHasItem(oPC, sVarObject);
    else
    {
        SetModuleError("TAG", "0c_if_has_var", "20", "This does not give a variable object for the conversation!");
        return FALSE;
    }
    string sVarType = GetScriptParam("sVarType");
    string sVarName = GetScriptParam("sVarName");
    string sValue = GetScriptParam ("sValue");
    if(sVarType == "Int")
    {
        if(GetLocalInt(oObject, sVarName) == StringToInt(sValue)) return TRUE;
    }
    if(sVarType == "Float")
    {
        if(GetLocalFloat(oObject, sVarName) == StringToFloat(sValue)) return TRUE;
    }
    if(sVarType == "String")
    {
        if (GetLocalString(oObject, sVarName) == sValue) return TRUE;
    }
    return FALSE;
}
