/*/////////////////////////////////////////////////////////////////////////////////////////////////////
 Script Name: 0c_demonappear
 Programmer: Philos
//////////////////////////////////////////////////////////////////////////////////////////////////////
 Conversation script that sets the script to run on conversation select.
 Used to run various functions from one conversation.
 Sets up demon appearances for a PC.
*/////////////////////////////////////////////////////////////////////////////////////////////////////

#include "0i_database"
#include "0i_items"

void main()
{
    object oPC = GetLocalObject (OBJECT_SELF, "0_PC_Speaker");
    // Get the selections.
    string sSelection = GetLocalString (OBJECT_SELF, "0_Conv_Select");
    // Get the players appearance data.
    // Appearance Array is :Eyes:Legs:Claws:"
    string sAppearanceArray = GetObjectDatabaseString (oPC, CHARACTER_TABLE, "appearance");
    // Destroy any previous demonic body they may have.
    object oItem = GetCreatureHasItem (oPC, "0_demonic_body", TRUE);
    if (GetIsObjectValid (oItem)) DestroyObject (oItem);
    // Turn demon legs off.
    if (sSelection == "1")
    {
        sAppearanceArray = SetStringArray (sAppearanceArray, 1, "0");
    }
    // Set demon legs with claw and give body for legs.
    else if (sSelection == "2")
    {
        CreateItemOnObject ("0_demonic_body", oPC);
        sAppearanceArray = SetStringArray (sAppearanceArray, 1, "116");
    }
    // Set demon legs with hoof and give body for legs.
    else if (sSelection == "3")
    {
        CreateItemOnObject ("0_demonic_body", oPC);
        sAppearanceArray = SetStringArray (sAppearanceArray, 1, "117");
    }
    // Set demon legs with split hoof and give body for legs.
    else if (sSelection == "4")
    {
        CreateItemOnObject ("0_demonic_body", oPC);
        sAppearanceArray = SetStringArray (sAppearanceArray, 1, "118");
    }
    // Set demon to have claws.
    else if (sSelection == "5")
    {
        SetCreatureBodyPart(CREATURE_PART_LEFT_HAND, 203, oPC);
        SetCreatureBodyPart(CREATURE_PART_RIGHT_HAND, 203, oPC);
        sAppearanceArray = SetStringArray (sAppearanceArray, 2, "1");
    }
    // Set demon to white claws.
    else if (sSelection == "6")
    {
        SetCreatureBodyPart(CREATURE_PART_LEFT_HAND, 222, oPC);
        SetCreatureBodyPart(CREATURE_PART_RIGHT_HAND, 222, oPC);
        sAppearanceArray = SetStringArray (sAppearanceArray, 2, "1");
    }
    // Set demon to brown claws.
    else if (sSelection == "7")
    {
        SetCreatureBodyPart(CREATURE_PART_LEFT_HAND, 221, oPC);
        SetCreatureBodyPart(CREATURE_PART_RIGHT_HAND, 221, oPC);
        sAppearanceArray = SetStringArray (sAppearanceArray, 2, "1");
    }
    // Set demon to have normal hands
    else if (sSelection == "8")
    {
        SetCreatureBodyPart(CREATURE_PART_LEFT_HAND, 1, oPC);
        SetCreatureBodyPart(CREATURE_PART_RIGHT_HAND, 1, oPC);
        sAppearanceArray = SetStringArray (sAppearanceArray, 2, "0");
    }
    // Save the changes.
    SetObjectDatabaseString (oPC, CHARACTER_TABLE, "appearance", sAppearanceArray);
}

