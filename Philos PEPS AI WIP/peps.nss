/*//////////////////////////////////////////////////////////////////////////////
 Script: peps
 Programmer: Philos
////////////////////////////////////////////////////////////////////////////////
    This is a script to run in debug mode to add the Enhanced player system!
    Sometimes the Default script or x3_s3_horse script is used by other content
    or is not wanted by the user.
*///////////////////////////////////////////////////////////////////////////////
#include "0i_menus"
#include "0i_player_target"
void main()
{
    object oPC = GetFirstPC();
    ai_CheckPlayerForData(oPC);
    ai_CreateWidgetNUI(oPC, oPC);
    ai_SetupPlayerTarget(oPC);
}

