/*///////////////////////////////////////////////////////////////////////////////////////////////////
 Script Name: 0e_pcdeath
 Programmer: Philos
//////////////////////////////////////////////////////////////////////////////////////////////////////
 Event script that runs when the character dies.
*/////////////////////////////////////////////////////////////////////////////////////////////////////
#include "0i_win_layout_pc"
#include "0i_character"
#include "0i_database"
#include "0i_effects"
void main()
{
    object oPC = GetLastPlayerDied();
    object oArea = GetArea (oPC);
    SendMessages (GetName (oPC) + " has died in " + GetName (oArea) + "[" + GetTag (oArea) + "].", COLOR_RED, OBJECT_INVALID, TRUE, TRUE);
    // Set character/player death counters.
    IncreaseServerDatabaseCounter (oPC, PLAYER_TABLE, "deaths");
    IncreaseObjectDatabaseCounter (oPC, CHARACTER_TABLE, "deaths");
    // Remove all good effects.
    //RemoveCreatureEffects (oPC, 2);
    NWNX_Creature_OverrideDamageLevel (oPC, -1);
    // Now kill them!
    DeathEffect(oPC);
    // Place the death GUI Panel
    //DelayCommand(5.0f, PopUpGUIPanel (oPC, GUI_PANEL_PLAYER_DEATH));
    PopUpDeathPanel(oPC);
    // Remove the PC to dying mode so creatures can attack.
    SetLocalInt(oPC, "0_BLEEDING", FALSE);
}

