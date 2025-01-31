/*//////////////////////////////////////////////////////////////////////////////
 Script: default
 Programmer: Philos
////////////////////////////////////////////////////////////////////////////////
    Default script that runs various events.
    For a player this will fire for many events that are not defined.
*///////////////////////////////////////////////////////////////////////////////
#include "0i_menus"
#include "0i_menus_dm"
#include "0i_player_target"
void main()
{
    object oCreature = OBJECT_SELF;
    int nEvent = GetCurrentlyRunningEvent();
    if(ai_GetIsCharacter(oCreature))
    {
        if(nEvent == EVENT_SCRIPT_CREATURE_ON_SPAWN_IN)
        {
            ai_CheckAIRules();
            ai_StartupPlugins(oCreature);
            ai_CheckAssociateData(oCreature, oCreature, "pc");
            ai_CreateWidgetNUI(oCreature, oCreature);
            ai_SetupPlayerTarget(oCreature);
            ai_SetNormalAppearance(oCreature);
        }
    }
    else if(GetIsDM(oCreature) || GetIsPlayerDM(oCreature))
    {
        if(nEvent == EVENT_SCRIPT_CREATURE_ON_SPAWN_IN)
        {
            ai_CheckAIRules();
            ai_StartupPlugins(oCreature);
            ai_CheckDMData(oCreature);
            ai_CreateDMWidgetNUI(oCreature);
            ai_SetupPlayerTarget(oCreature);
        }
    }
}


