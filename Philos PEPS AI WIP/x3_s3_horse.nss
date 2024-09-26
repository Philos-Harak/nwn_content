/*//////////////////////////////////////////////////////////////////////////////
 Script: x3_s3_horse
 Programmer: Philos
////////////////////////////////////////////////////////////////////////////////
    We have hijacked this script so a player can add the Enhanced player system!
    Sometimes the Default script is used by other content and this is a work
    around to allow it to be used without the default.ncs
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

