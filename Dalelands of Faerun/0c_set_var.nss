/*//////////////////////////////////////////////////////////////////////////////
 Script: 0c_set_var
 Programmer: Philos
////////////////////////////////////////////////////////////////////////////////
 Sets a variable base on the params.
 sVar is the name of the variable.
 sValue is the value of the variable.
 sType is the type of variable it is (Int, Float, String)
 sObject is the target of the variable (OBJECT_SELF, oPCSpeaker)
*///////////////////////////////////////////////////////////////////////////////
void main()
{
    object oPC = GetPCSpeaker ();
    string sVar = GetScriptParam ("sVar");
    string sValue = GetScriptParam ("sValue");
    string sType = GetScriptParam ("sType");
    string sObject = GetScriptParam ("sObject");
    if (sObject == "oPCSpeaker")
    {
        if (sType == "Int") SetLocalInt (oPC, sVar, StringToInt (sValue));
        else if (sType == "Float") SetLocalFloat (oPC, sVar, StringToFloat (sValue));
        else if (sType == "String") SetLocalString (oPC, sVar, sValue);
    }
    else
    {
        if (sType == "Int") SetLocalInt (OBJECT_SELF, sVar, StringToInt (sValue));
        else if (sType == "Float") SetLocalFloat (OBJECT_SELF, sVar, StringToFloat (sValue));
        else if (sType == "String") SetLocalString (OBJECT_SELF, sVar, sValue);
    }
}
