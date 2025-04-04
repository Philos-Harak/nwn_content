/*//////////////////////////////////////////////////////////////////////////////
 Script: peps
 Programmer: Philos
////////////////////////////////////////////////////////////////////////////////
    This is a script to run in debug mode to add the Enhanced player system!
    Sometimes the Default script or x3_s3_horse script is used by other content
    or is not wanted by the user.
*///////////////////////////////////////////////////////////////////////////////
#include "0i_module"
#include "0i_menus_dm"
void main()
{
    object oPC = GetFirstPC();
    if(!AI_SERVER) ai_CheckPCStart(oPC, TRUE);
    else if(GetIsDM(oPC) || GetIsPlayerDM(oPC))
    {
        ai_SetAIRules();
        ai_StartupPlugins(oPC);
        ai_CheckDMData(oPC);
        ai_CreateDMWidgetNUI(oPC);
        ai_SetupPlayerTarget(oPC);
    }
}

