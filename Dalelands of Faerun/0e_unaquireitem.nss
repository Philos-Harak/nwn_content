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
    int nBaseItemType = GetBaseItemType(oItem);
    if(nBaseItemType == 179 || nBaseItemType == 180 ||
       nBaseItemType == 181 || nBaseItemType == 182 ||
       nBaseItemType == 183) DoAccessoryVisuals(oCreature, oItem, FALSE, TRUE);
    if(GetIsCharacter(oCreature)) RemoveQuestPaperFromDatabase(oCreature, oItem);
    // Make sure to set any component containers or other focus items for quick retrieval later.
    string sItemTag = GetTag (oItem);
    if(sItemTag == CLERIC_HOLY_SYMBOL) 
    {
        object oHasItem = GetCreatureHasItem(oCreature, CLERIC_HOLY_SYMBOL, TRUE);
        if(oHasItem == OBJECT_INVALID) DeleteLocalObject(oCreature, CLERIC_HOLY_SYMBOL);
        else SetLocalObject(oCreature, CLERIC_HOLY_SYMBOL, oHasItem);
    }
    else if(sItemTag == DRUID_HOLY_SYMBOL) 
    {
        object oHasItem = GetCreatureHasItem(oCreature, DRUID_HOLY_SYMBOL, TRUE);
        if(oHasItem == OBJECT_INVALID) DeleteLocalObject(oCreature, DRUID_HOLY_SYMBOL);
        else SetLocalObject(oCreature, DRUID_HOLY_SYMBOL, oHasItem);
    }
    else if(sItemTag == COMPONENT_POUCH && GetLocalObject(oCreature, COMPONENT_POUCH) == oItem) 
    {
        object oHasItem = GetCreatureHasItem(oCreature, COMPONENT_POUCH, TRUE);
        if(oHasItem == OBJECT_INVALID) DeleteLocalObject(oCreature, COMPONENT_POUCH);
        else SetLocalObject(oCreature, COMPONENT_POUCH, oHasItem);
    }
    // Check for special item scripts via Prefix "ua_" and the items tag.
    ExecuteScript("ua_" + GetTag(oItem), oItem);
}

