/*//////////////////////////////////////////////////////////////////////////////
 Script: 0c_if_scout
 Programmer: Philos
////////////////////////////////////////////////////////////////////////////////
 Text Appears When script that check if scouting is activated on this server.

 Script Param: nTRUE -
     if set to 1 then it will pass TRUE if they are in scout mode.
     if set to 0 then it will pass TRUE if they are NOT in scout mode.
*///////////////////////////////////////////////////////////////////////////////
#include "0i_associates"
int StartingConditional()
{
    int nTRUE = StringToInt(GetScriptParam("nTRUE"));
    return AI_SCOUT_AHEAD_ON && ai_GetAIMode(OBJECT_SELF, AI_MODE_SCOUT_AHEAD) == nTRUE;
}
