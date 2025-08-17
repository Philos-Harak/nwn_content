/*//////////////////////////////////////////////////////////////////////////////
 Script: default
 Programmer: Philos
////////////////////////////////////////////////////////////////////////////////
    Default script that runs various events.
    For a player this will fire for many events that are not defined.
*///////////////////////////////////////////////////////////////////////////////
#include "0i_menus_dm"
#include "0i_player_target"
#include "0i_module"
void main()
{
    object oCreature = OBJECT_SELF;
    int nEvent = GetCurrentlyRunningEvent();
    if(ai_GetIsCharacter(oCreature))
    {
        if(nEvent == EVENT_SCRIPT_CREATURE_ON_SPAWN_IN) ai_CheckPCStart(oCreature);
    }
    else if(ai_GetIsDungeonMaster(oCreature))
    {
        if(nEvent == EVENT_SCRIPT_CREATURE_ON_SPAWN_IN) ai_CheckDMStart(oCreature);
    }
}


