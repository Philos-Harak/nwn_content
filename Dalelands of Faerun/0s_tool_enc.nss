/*/////////////////////////////////////////////////////////////////////////////////////////////////////
 Script Name: 0s_tool_enc
 Programmer: Philos
//////////////////////////////////////////////////////////////////////////////////////////////////////
 Spell script that spawns creatures from the encounter area using the encounter tool for the DM.
*/////////////////////////////////////////////////////////////////////////////////////////////////////
#include "0i_s_message"
void main()
{
    object oUser = OBJECT_SELF;
    object oModule = GetModule ();
    // Lock out the menu, remove on exiting the menu.
    // Used to lock so only one DM can use at a time.
    if (GetLocalInt (oModule, "0_Enc_Tool_InUse"))
    {
        SendMessages ("The encounter tool is being used at the moment.", COLOR_RED, oUser, FALSE, FALSE);
        return;
    }
    SetLocalInt (oModule, "0_C_Enc_Tool_InUse", TRUE);
    // Get the target and save them to the player.
    SetLocalLocation (oUser, "0_Location_Target", GetSpellTargetLocation ());
    // Setup the type of encounters.
    int nSpellID = GetSpellId ();
    if (nSpellID == 820) SetLocalInt (oUser, "0_Encounter_Faction", 3); // Defender.
    if (nSpellID == 821) SetLocalInt (oUser, "0_Encounter_Faction", 0); // Hostile.
    if (nSpellID == 822) SetLocalInt (oUser, "0_Encounter_Faction", 4); // Neutral.
    AssignCommand (oUser, ClearAllActions());
    AssignCommand (oUser, ActionStartConversation(OBJECT_SELF, "co_tool_enc", TRUE, FALSE));
}


