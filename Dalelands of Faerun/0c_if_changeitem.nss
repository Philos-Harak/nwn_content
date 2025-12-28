/*//////////////////////////////////////////////////////////////////////////////
 Script: 0c_if_changeitem
 Programmer: Philos
////////////////////////////////////////////////////////////////////////////////
 Text Appears When script that checks to see if the PC can change the item for
 the selected slot.
 Param:
 nInventorySlot - INVENTORY_SLOT_* to be checked.
    0 - INVENTORY_SLOT_HEAD
    1 - INVENTORY_SLOT_CHEST
    4 - INVENTORY_SLOT_RIGHTHAND
    5 - INVENTORY_SLOT_LEFTHAND
    6 - INVENTORY_SLOT_CLOAK
 bNot - boolean that flips the check from cannot change to can change.
*///////////////////////////////////////////////////////////////////////////////
#include "0i_itemproperty"
#include "0i_items"
int StartingConditional()
{
    int nInventorySlot = StringToInt (GetScriptParam ("nInventorySlot"));
    int bNot = StringToInt (GetScriptParam ("bNot"));
    object oPC = GetPCSpeaker();
    object oItem = GetItemInSlot (nInventorySlot, oPC);
    int nItemType = GetBaseItemType (oItem);
    if (!GetIsObjectValid (oItem)) return bNot;
    else if (nItemType != BASE_ITEM_LARGESHIELD &&
             nItemType != BASE_ITEM_SMALLSHIELD &&
             nItemType != BASE_ITEM_TOWERSHIELD &&
             INVENTORY_SLOT_LEFTHAND == nInventorySlot) return bNot;
    else if (INVENTORY_SLOT_RIGHTHAND == nInventorySlot)
    {
        if (!GetIsWeapon (oItem)) return bNot;
        else
        {
            // Check to see if the weapon has a unique appearance.
            int iModel = GetItemAppearance (oItem, ITEM_APPR_TYPE_WEAPON_MODEL, ITEM_APPR_WEAPON_MODEL_TOP);
            int iMaxModel = GetItemsMaxModels (oItem, "TopModel");
            if (iModel > iMaxModel) return bNot;
        }
    }
    // Cannot change Head_Gear as they are visual effects and not Models.
    else if (INVENTORY_SLOT_HEAD == nInventorySlot && nItemType == 23/*BASE_ITEM_HEAD_GEAR*/) return bNot;
    // If plot item then we cannot let them change it.
    else if (GetPlotFlag (oItem) && !bNot) return bNot;
    // Cannot change set items.
    else if (GetStringLeft (GetTag (oItem), 7) == "itemset")
    {
        if (!bNot) SendMessages (GetName (oItem) + " is a set item and cannot be altered.", COLOR_RED, oPC);
        return bNot;
    }
    // Cannot change temorary enchanted items.
    else if (CheckForTemporaryItemProperty (oItem))
    {
        if (!bNot) SendMessages (GetName (oItem) + " cannot be altered while it has a temporary enchantment.", COLOR_RED, oPC);
        return bNot;
    }
    return !bNot;
}
