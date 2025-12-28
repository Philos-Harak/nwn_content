/*/////////////////////////////////////////////////////////////////////////////////////////////////////
 Script Name: ac_dm_play_tool
 Programmer: Philos
///////////////////////////////////////////////////////////////////////////////////////////////////////
 Activate item script for DM's play tool.
 This opens a conversation so a DM can do DM things.
*//////////////////////////////////////////////////////////////////////////////////////////////////////

#include "0i_master"

void main()
{
    object oPC = GetItemActivator ();
    // Get the target and save them to the player.
    SetLocalLocation (oPC, "0_Location_Target", GetSpellTargetLocation ());
    // Get the target and save them to the player.
    SetLocalObject(oPC, "0_Creature_Target", GetSpellTargetObject());
    // Open up the tool.
    ActionStartConversation (oPC, "co_tool_play", TRUE, FALSE);
}
