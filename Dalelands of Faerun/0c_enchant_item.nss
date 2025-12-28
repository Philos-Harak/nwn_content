/*///////////////////////////////////////////////////////////////////////////////
 Script: 0c_enchant_item
 Programmer: Philos
////////////////////////////////////////////////////////////////////////////////
 Actions Taken script that takes the enchanted item from temp container ane
 moves it to the enchanting box, while removing the old item.
*///////////////////////////////////////////////////////////////////////////////
#include "0i_crafting"
#include "nwnx_object"
void main()
{
    object oNewItem;
    int nGoldCost = GetLocalInt (OBJECT_SELF, "0_GoldCost");
    TakeGoldFromCreature (nGoldCost, OBJECT_SELF, TRUE);
    // XP Cost has been removed... for now.
    //int iXPCost = GetLocalInt (OBJECT_SELF, "0_XPCost");
    //int iNewXP = GetXP (OBJECT_SELF) - iXPCost;
    //SetXP (OBJECT_SELF, iNewXP);
    // Remove the base item.
    object oItem = GetLocalObject (OBJECT_SELF, "0_Item_to_enchant");
    // Check for ammo and thrown items.
    int nStack = GetItemStackSize (oItem);
    int nItemType = GetBaseItemType (oItem);
    if (GetIsAmmo (oItem) || GetIsThrownWeapon (oItem)) DestroyObject (oItem);
    else if (nStack - 1 > 0) SetItemStackSize (oItem, nStack - 1);
    else DestroyObject (oItem);
    // Move the new enchanted item into the box.
    object oContainer = GetLocalObject (OBJECT_SELF, "0_enchanting_box");
    object oEnchantedItem = GetLocalObject (OBJECT_SELF, "0_enchanted_item");
    // Containers cannot be placed into containers so we have to place on enchanter.
    if (GetHasInventory (oContainer)) oNewItem = CopyItem (oEnchantedItem, OBJECT_SELF, TRUE);
    else oNewItem = CopyItem (oEnchantedItem, oContainer, TRUE);
    SetLocalString (oNewItem, "0_EnchantedBy", GetName (OBJECT_SELF, TRUE));
    // Remove the enchanted copy item.
    DestroyObject (oEnchantedItem);
    // Clean up all variables.
    DeleteLocalObject (OBJECT_SELF, "0_enchanting_box");
    DeleteLocalObject (OBJECT_SELF, "0_enchanted_item");
    DeleteLocalObject (OBJECT_SELF, "0_Item_to_enchant");
    DeleteLocalInt (OBJECT_SELF, "0_Spell");
    DeleteLocalInt (OBJECT_SELF, "0_CasterClass");
    DeleteLocalInt (OBJECT_SELF, "0_GoldCost");
    DeleteLocalInt (OBJECT_SELF, "0_XPCost");
    DeleteLocalInt (OBJECT_SELF, "0_Temp_Item");
    DeleteLocalString (OBJECT_SELF, "0_enchant_column");
}
