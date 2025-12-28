/*////////////////////////////////////////////////////////////////////////////////////////////////////
 Script Name: 0e_unaquireitem
 Programmer: Philos
//////////////////////////////////////////////////////////////////////////////////////////////////////
 Event script that runs when a creature unaquires an item.
 To make scripts for items that have powers on aquiring name the script
 with the prefix "ua_" + the tag of the item.
 Note: This script should undo what the aquire script does.
*/////////////////////////////////////////////////////////////////////////////////////////////////////
#include "0i_quest"
#include "0i_items"

void main()
{
    object oItem = GetModuleItemLost();
    object oCreature = GetModuleItemLostBy ();
    Debug("0e_unquireitem", "17", GetName(oCreature) + " oItem: " + GetName(oItem));
    // See if the item is being given by a dm to a player.
    // Set it to the dm who gave it.
    if(GetIsDungeonMaster(oCreature) && GetLocalString(oItem, "0_Creator") == "")
    {
        // Don't tag stackable items... stacking issues.
        if(!GetIsItemStackable(oItem)) SetLocalString(oItem, "0_Creator", StripColorCodes (GetName (oCreature)));
    }
    if(GetIsCharacter(oCreature)) RemoveQuestPaperFromDatabase(oCreature, oItem);
    // Check for special item scripts via Prefix "ua_" and the items tag.
    ExecuteScript("ua_" + GetTag(oItem), oItem);
}

