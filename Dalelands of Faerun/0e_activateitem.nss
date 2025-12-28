/*////////////////////////////////////////////////////////////////////////////////////////////////////
 Script Name: 0e_activateitem
 Programmer: Philos
//////////////////////////////////////////////////////////////////////////////////////////////////////
 Event script for activating items.
 To run scripts for items that have powers on activation name the script
 with the prefix "ac_" + the tag of the item.
 Makes the user the OBJECT_SELF for those scripts.
*/////////////////////////////////////////////////////////////////////////////////////////////////////

#include "0i_s_message"
#include "0i_crafting"
#include "0i_character"

void main()
{
    object oPC = GetItemActivator();
    // Check to make sure the activator is conscious.
    if (GetCurrentHitPoints(oPC) <= 0)
    {
        SendMessages("You cannot take any actions right now!", COLOR_RED, oPC, FALSE, FALSE);
        return;
    }
    object oItem = GetItemActivated();
    string sItemTag = GetTag(oItem);
    object oTarget = GetItemActivatedTarget();
    // Check to see if they are crafting.
    if(sItemTag == "artisan_tools")
    {
        CraftBaseItem(oPC, oItem, oTarget);
        return;
    }
    //int nBaseItemType = GetBaseItemType(oItem);
    location lLocal = GetItemActivatedTargetLocation();
    // Set variables to pass the script.
    SetLocalObject(oPC, "0_item", oItem);
    SetLocalObject(oPC, "0_target", oTarget);
    SetLocalLocation(oPC, "0_location", lLocal);
    // Check for special item scripts via Prefix "ac_" and the items tag.
    // Pass the user as OBJECT_SELF.
    ExecuteScript("ac_" + sItemTag, oPC);
}

