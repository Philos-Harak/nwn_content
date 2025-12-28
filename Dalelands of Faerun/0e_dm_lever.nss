/*////////////////////////////////////////////////////////////////////////////////////////////////////
 Script Name: 0e_dm_lever
 Programmer: Philos
//////////////////////////////////////////////////////////////////////////////////////////////////////
 OnUse event to switch levers on and off.
 This changes the dm chests treasure level from 1 - 20.
*/////////////////////////////////////////////////////////////////////////////////////////////////////
#include "0i_s_message"

void main()
{
    int iCounter = 1;
    string sNewName;
    object oPC = GetLastUsedBy (), oChest;
    // Get the level of the chest.
    int iLevel = GetLocalInt (OBJECT_SELF, "0_TreasureLevel");
    // Cycle through the levels.
    if (iLevel == 20) iLevel = 1;
    else iLevel = iLevel + 1;
    SetLocalInt (OBJECT_SELF, "0_TreasureLevel", iLevel);
    SendMessages ("Chest level is now " + IntToString (iLevel) + ".", COLOR_GRAY, oPC, FALSE, FALSE);
    // Set all of the chests to the new level.
    oChest = GetNearestObjectByTag ("ChestofDrawers", OBJECT_SELF, iCounter);
    while (GetIsObjectValid (oChest))
    {
        SetLocalInt (oChest, "0_TreasureLevel", iLevel);
        // Change the name of the chest.
        sNewName = GetName (oChest, TRUE) + " (" + IntToString (iLevel) + ")";
        SetName (oChest, sNewName);
        iCounter ++;
        oChest = GetNearestObjectByTag ("ChestofDrawers", OBJECT_SELF, iCounter);
    }
    // Set the name of the lever.
    sNewName = "Treasure Level " + IntToString (iLevel);
    SetName (OBJECT_SELF, sNewName);
    // Is the object on?
    if (GetLocalInt(OBJECT_SELF,"NW_L_AMION") == 0)
    {
        // Turn on.
        PlayAnimation(ANIMATION_PLACEABLE_ACTIVATE);
        SetLocalInt(OBJECT_SELF,"NW_L_AMION",1);
    }
    // Animiation is on...
    else
    {
        // Turn animation off.
        PlayAnimation(ANIMATION_PLACEABLE_DEACTIVATE);
        SetLocalInt(OBJECT_SELF,"NW_L_AMION",0);
    }
}
