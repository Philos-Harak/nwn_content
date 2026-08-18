/*//////////////////////////////////////////////////////////////////////////////
 Script: 0c_set_var
 Programmer: Philos
////////////////////////////////////////////////////////////////////////////////
 Sets a variable base on the params.
 sVar is the name of the variable.
 sValue is the value of the variable.
 sType is the type of variable it is (Int, Float, String)
 sObject is the target of the variable (OBJECT_SELF, oPCSpeaker, ItemTag)
 if sObject is set to anything other than OBJECT_SELF or oPCSpeaker then it will
     save the variable to the item in the players inventory with this tag.
*///////////////////////////////////////////////////////////////////////////////
#include "0i_items"
void main()
{
    object oPC = GetPCSpeaker ();
    string sVar = GetScriptParam ("sVar");
    string sValue = GetScriptParam ("sValue");
    string sType = GetScriptParam ("sType");
    string sObject = GetScriptParam ("sObject");
    if(sObject == "oPCSpeaker")
    {
        if (sType == "Int") SetLocalInt (oPC, sVar, StringToInt (sValue));
        else if (sType == "Float") SetLocalFloat (oPC, sVar, StringToFloat (sValue));
        else if (sType == "String") SetLocalString (oPC, sVar, sValue);
    }
    else if(sObject == "OBJECT_SELF")
    {
        if (sType == "Int") SetLocalInt (OBJECT_SELF, sVar, StringToInt (sValue));
        else if (sType == "Float") SetLocalFloat (OBJECT_SELF, sVar, StringToFloat (sValue));
        else if (sType == "String") SetLocalString (OBJECT_SELF, sVar, sValue);
    }
    else if(sObject != "")
    {
        object oItem = GetCreatureHasItem(oPC, sObject);
        if (sType == "Int") SetLocalInt (oItem, sVar, StringToInt (sValue));
        else if (sType == "Float") SetLocalFloat (oItem, sVar, StringToFloat (sValue));
        else if (sType == "String") SetLocalString (oItem, sVar, sValue);
    }
    else SetModuleError("TAG", "0c_set_var", "40", "This does not give a variable object for the conversation!");
}
