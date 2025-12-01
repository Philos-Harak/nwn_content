/*//////////////////////////////////////////////////////////////////////////////
 Script: 0c_if_SkillRank
 Programmer: Philos
////////////////////////////////////////////////////////////////////////////////
 Text Appears When script that checks to see if the caller's skill ranks
 are above or equal to the param value.
 Param:
 nSkill - the skill number for the skill. See skills.2da.
 nRank - the rank required.
*///////////////////////////////////////////////////////////////////////////////
#include "0i_main"
int StartingConditional()
{
    string sSkill = GetScriptParam("nSkill");
    if(sSkill == "") return FALSE;
    int nRank = StringToInt(GetScriptParam("nRank"));
    return (GetSkillRank(StringToInt(sSkill)) >= nRank);
}
