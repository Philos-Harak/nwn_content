/*//////////////////////////////////////////////////////////////////////////////
 Script: peps
 Programmer: Philos
////////////////////////////////////////////////////////////////////////////////
    This is a script to run in debug mode to add the Enhanced player system!
    Sometimes the Default script or x3_s3_horse script is used by other content
    or is not wanted by the user.
*///////////////////////////////////////////////////////////////////////////////
#include "0i_menus"
#include "0i_menus_dm"
#include "0i_player_target"
#include "0i_gui_events"
#include "0i_module"
void main()
{
    object oPC = GetFirstPC();
    ai_SetupPlayerTarget(oPC);
    ai_SetupModuleGUIEvents(oPC);
    ai_SetAIRules();
    ai_StartupPlugins(oPC);
    if(ai_GetIsCharacter(oPC))
    {
        ai_CheckAssociateData(oPC, oPC, "pc");
        ai_CreateWidgetNUI(oPC, oPC);
        ai_SetNormalAppearance(oPC);
    }
    if(AI_SERVER && (GetIsDM(oPC) || GetIsPlayerDM(oPC)))
    {
        ai_CheckDMData(oPC);
        ai_CreateDMWidgetNUI(oPC);
    }
}

