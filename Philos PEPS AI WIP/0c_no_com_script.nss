/*//////////////////////////////////////////////////////////////////////////////
 Script: 0c_no_com_script
 Programmer: Philos
////////////////////////////////////////////////////////////////////////////////
 Text Appears When script that returns TRUE the caller does not have an ai combat
 script set to sAIScript.
 if sAIScript is blank then if its equal to all of them.
 Param: sAIScripts:"ai_a_ambusher", "ai_a_defensive", "ai_a_taunter", "ai_coward".
 sAIScript - The special combat script to check.
*///////////////////////////////////////////////////////////////////////////////
#include "0i_associates"
int StartingConditional()
{
    string sAIScript = GetScriptParam("sAIScript");
    string sAICombatScript = GetLocalString (OBJECT_SELF, AI_COMBAT_SCRIPT);
    // This is the value for do your own thing in combat!
    if (sAIScript == "")
    {
        return (sAICombatScript == "ai_a_ambusher" ||
                sAICombatScript == "ai_a_defensive" ||
                sAICombatScript == "ai_a_ranged" ||
                sAICombatScript == "ai_a_taunter" ||
                sAICombatScript == "ai_a_cntrspell" ||
                 sAICombatScript == "ai_a_peaceful");
    }
    return (sAIScript != sAICombatScript);
}
