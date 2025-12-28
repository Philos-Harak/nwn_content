/*////////////////////////////////////////////////////////////////////////////////////////////////////
 Script Name: 0e_aquireitem
 Programmer: Philos
//////////////////////////////////////////////////////////////////////////////////////////////////////
 Event script that runs when a creature aquires an item.

 NOTE: This also fires when a character enters the server as follows:
 1) 0e_equip: Runs the OnEquip script for each item equiped. Before 0e_aquireitem!
 2) 0e_aquireitem: Runs the OnAquireItem script for each item aquired at login.

 The game gives the player each item and runs this script!
 We check this with GetLocalInt (oPC, "0_Character_Loaded");

 To make scripts for items that have powers on aquiring name the script
 with the prefix "aq_" + the tag of the item. Don't forget to make a script
 for unaquiring the item as well. Use "ua_" + the tag to define the unaquire script.

*/////////////////////////////////////////////////////////////////////////////////////////////////////
#include "0i_quest"
#include "0i_items"
#include "0i_character"

void main()
{
    object oReceiver = GetModuleItemAcquiredBy ();
    object oItem = GetModuleItemAcquired ();
    Debug("0e_aquireitem", "25", GetName(oReceiver) + " oItem: " + GetName(oItem));
    string sItemTag = GetTag (oItem);
    // Run this only if it is a player.
    if(GetIsCharacter(oReceiver))
    {
        // Don't bother if we are loading in!
        if(GetLocalInt(oReceiver, "0_Character_Loaded"))
        {
            // Check to see if we can auto identify this item.
            if (!GetIdentified (oItem) &&
                GetTag (oItem) != "" &&
                GetSkillRank (SKILL_KNOWLEDGE, oReceiver, TRUE) > 0)
            {
                if(IdentifyItemVsKnowledge(oReceiver, oItem))
                {
                    SendMessageToPC(oReceiver, AddColorToText("You have identified ", COLOR_GREEN) + GetName(oItem));
                }
            }
            object oGiver = GetModuleItemAcquiredFrom();
            // Lets see if this has been bound to a player yet.
            if(GetLocalString(oItem, "0_Binded") == "")
            {
                // Don't bind stackable items!
                if(!GetIsItemStackable(oItem)) SetLocalString(oItem, "0_Binded", StripColorCodes(GetName(oReceiver, TRUE)));
            }
            // Check to see if a PC can see them pickup the item.
            if(!GetIsDungeonMaster(oGiver) && !GetIsDungeonMaster (oReceiver)) DoSpotVsSleightOfHandCheck(oReceiver, oItem, oGiver);
            CheckSmartContainers(oItem, oReceiver);
        }
        // Leave here temporarily... then put back into character loaded code!
        // Also remove the db check once we move this back.
        if(sItemTag == "0_quest_paper") AddQuestPaperToDatabase(oReceiver, oItem);
    }
    // Check an item to see if we need to adjust the equip level of this item.
    AdjustItemsEquipLevel(oItem, oReceiver);
    // Check for weight and adjust if need be.
    int nWeight = GetLocalInt(oItem, "0_Weight");
    if(nWeight > 0) NWNX_Item_SetWeight(oItem, nWeight);
    // Check for special item scripts via Prefix "aq_" and the items tag.
    ExecuteScript("aq_" + sItemTag, oItem);
}

