/*//////////////////////////////////////////////////////////////////////////////
 Script: 0c_if_cntrspell
 Programmer: Philos
////////////////////////////////////////////////////////////////////////////////
 Text Appears When script that returns TRUE the server allows a henchman to
 use counterspell and if they don't have the counterspell ai script set.
 Param:
 sAIScript - The special combat script to check.
*///////////////////////////////////////////////////////////////////////////////
#include "0i_associates"
int StartingConditional()
{
    object oHenchman = OBJECT_SELF;
    return (AI_COUNTERSPELLING_ON &&
            ai_CheckClassType(oHenchman, AI_CLASS_TYPE_CASTER) &&
            GetLocalString(oHenchman, AI_COMBAT_SCRIPT) != "ai_a_cntrspell");
}
