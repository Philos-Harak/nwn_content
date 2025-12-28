/*//////////////////////////////////////////////////////////////////////////////
 Script: 0e_lever_level
 Programmer: Philos
////////////////////////////////////////////////////////////////////////////////
 OnUse event to switch levers on and off.
 This gives an DM character another level or takes a level, or gives gold.
 Based on the tag of the Lever.
*///////////////////////////////////////////////////////////////////////////////
#include "0i_character"

void main()
{
    object oPC = GetLastUsedBy ();
    if (!GetLocalInt(OBJECT_SELF,"Lever_is_On"))
    {
        PlayAnimation (ANIMATION_PLACEABLE_ACTIVATE);
        SetLocalInt (OBJECT_SELF,"Lever_is_On", TRUE);
    }
    else
    {
        PlayAnimation (ANIMATION_PLACEABLE_DEACTIVATE);
        SetLocalInt (OBJECT_SELF,"Lever_is_On", FALSE);
    }
    // Allow full DM's and Admins to use this lever.
    if (GetServerDatabaseInt (oPC, PLAYER_TABLE, "status") > 3)
    {
        int nNextLevel;
        // Get which level they are using (Level up or Level down).
        string sTag = GetTag (OBJECT_SELF);
        if (sTag == "0_level_down")
        {
            nNextLevel = GetCharacterLevels (oPC, FALSE) - 1;
            SendMessages (GetPCPlayerName (oPC) + "'s character named " + GetName (oPC) + " has lost a level.", COLOR_RED, oPC, FALSE, TRUE);
            SetXpGold (oPC, nNextLevel, TRUE, FALSE);
        }
        else if (sTag == "0_level_up")
        {
            nNextLevel = GetCharacterLevels (oPC, FALSE) + 1;
            SendMessages (GetPCPlayerName (oPC) + "'s character named " + GetName (oPC) + " has gained a level.", COLOR_GREEN, oPC, FALSE, TRUE);
            SetXpGold (oPC, nNextLevel, TRUE, FALSE);
        }
        else if (sTag == "0_lever_gold")
        {
            nNextLevel = GetCharacterLevels (oPC, FALSE);
            SetXpGold (oPC, nNextLevel, FALSE, TRUE);
        }
    }
    else SendMessages ("The lever easily moves but has no visible effect.", COLOR_GRAY);
}
