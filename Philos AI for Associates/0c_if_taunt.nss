/*//////////////////////////////////////////////////////////////////////////////
 Script: 0c_if_taunt
 Programmer: Philos
////////////////////////////////////////////////////////////////////////////////
 Text Appears When script that returns TRUE the server allows a henchman to
 taunt and if they have the don't have the taunt ai script set.
*///////////////////////////////////////////////////////////////////////////////
#include "0i_associates"
int StartingConditional()
{
    object oHenchman = OBJECT_SELF;
    return (AI_TAUNTING_ON &&
            GetSkillRank(SKILL_TAUNT, oHenchman) > ai_GetCharacterLevels(oHenchman) &&
            GetLocalString(oHenchman, AI_COMBAT_SCRIPT) != "ai_a_taunt");
}
