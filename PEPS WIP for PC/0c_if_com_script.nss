/*//////////////////////////////////////////////////////////////////////////////
 Script: 0c_if_com_script
 Programmer: Philos
////////////////////////////////////////////////////////////////////////////////
 Text Appears When script that returns TRUE the caller does have an ai combat
 script set to sAIScript.
 Param:
 sAIScript - The special combat script to check.
*///////////////////////////////////////////////////////////////////////////////
#include "0i_associates"
int StartingConditional()
{
    string sAIScript = GetScriptParam("sAIScript");
    string sAICombatScript = GetLocalString (OBJECT_SELF, AI_COMBAT_SCRIPT);
    return (sAIScript == sAICombatScript);
}
