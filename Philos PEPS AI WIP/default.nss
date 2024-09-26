/*//////////////////////////////////////////////////////////////////////////////
 Script: default
 Programmer: Philos
////////////////////////////////////////////////////////////////////////////////
    Default script that runs various events.
    For a player this will fire for many events that are not defined.
*///////////////////////////////////////////////////////////////////////////////
#include "0i_menus"
#include "0i_player_target"
void main()
{
    object oCreature = OBJECT_SELF;
    int nEvent = GetCurrentlyRunningEvent();
    if(nEvent == EVENT_SCRIPT_CREATURE_ON_SPAWN_IN)
    {
        if(GetIsPC(oCreature))
        {
            ai_CheckPlayerForData(oCreature);
            ai_CreateWidgetNUI(oCreature, oCreature);
            ai_SetupPlayerTarget(oCreature);
        }
    }
}


