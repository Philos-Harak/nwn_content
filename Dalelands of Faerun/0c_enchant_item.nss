/*///////////////////////////////////////////////////////////////////////////////
 Script: 0c_enchant_item
 Programmer: Philos
////////////////////////////////////////////////////////////////////////////////
 Actions Taken script that takes the enchanted item from temp container ane
 moves it to the enchanting box, while removing the old item.
*///////////////////////////////////////////////////////////////////////////////
#include "0i_crafting"
#include "nwnx_object"
#include "nwnx_feedback"

void CleanVariables(object oCaster)
{
    NWNX_Feedback_SetFeedbackMessageHidden(NWNX_FEEDBACK_ITEM_RECEIVED, FALSE, oCaster);
    DelayCommand(1.0, NWNX_Feedback_SetFeedbackMessageHidden(NWNX_FEEDBACK_ITEM_LOST, FALSE, oCaster));
    DeleteLocalObject(oCaster, "0_enchanting_box");
    DeleteLocalObject(oCaster, "0_enchanted_item");
    DeleteLocalObject(oCaster, "0_Item_to_enchant");
    DeleteLocalInt(oCaster, "0_Spell");
    DeleteLocalInt(oCaster, "0_CasterClass");
    DeleteLocalInt(oCaster, "0_GoldCost");
    DeleteLocalInt(oCaster, "0_XPCost");
    DeleteLocalInt(oCaster, "0_Temp_Item");
    DeleteLocalString(oCaster, "0_enchant_column");
}

void main()
{
    object oCaster = OBJECT_SELF;
    object oNewItem;
    int nStack, nGoldCost = GetLocalInt (oCaster, "0_GoldCost");
    // Remove any enhancing components used.
    object oComponent = GetLocalObject(oCaster, "0_Component_to_enchant");
    NWNX_Feedback_SetFeedbackMessageHidden(NWNX_FEEDBACK_ITEM_RECEIVED, TRUE, oCaster);
    NWNX_Feedback_SetFeedbackMessageHidden(NWNX_FEEDBACK_ITEM_LOST, TRUE, oCaster);
    if(oComponent != OBJECT_INVALID)
    {
        nStack = GetItemStackSize(oComponent);
        int nStackToRemove = GetLocalInt(oCaster, "0_Enhancement_Stack_Size");
        DeleteLocalObject(oCaster, "0_Component_to_enchant");
        DeleteLocalInt(oCaster, "0_Enhancement_Stack_Size");
        if(nStack < nStackToRemove)
        {
            CleanVariables(oCaster);
            SendMessages("This spell requires " + IntToString(nStackToRemove) + " " + GetName(oComponent) + " gems to enchant it to this item.", COLOR_RED, oCaster);
            return;
        }
        string sPlural = nStackToRemove > 1 ? "s" : "";
        SendMessages("The enchantment consumes " + IntToString(nStackToRemove) + " " + GetName(oComponent) + " gem" + sPlural + ".", COLOR_YELLOW, oCaster);
        if(nStack - nStackToRemove > 0) SetItemStackSize(oComponent, nStack - nStackToRemove);
        else DestroyObject(oComponent);
    }
    if(!GetIsDungeonMaster(oCaster)) TakeGoldFromCreature (nGoldCost, oCaster, TRUE);
    // XP Cost has been removed... for now.
    //int iXPCost = GetLocalInt (oCaster, "0_XPCost");
    //int iNewXP = GetXP (oCaster) - iXPCost;
    //SetXP (oCaster, iNewXP);
    // Remove the base item.
    object oItem = GetLocalObject (oCaster, "0_Item_to_enchant");
    // Check for ammo and thrown items.
    nStack = GetItemStackSize (oItem);
    int nItemType = GetBaseItemType (oItem);
    if (GetIsAmmo (oItem) || GetIsThrownWeapon (oItem)) DestroyObject (oItem);
    else if (nStack - 1 > 0) SetItemStackSize (oItem, nStack - 1);
    else DestroyObject (oItem);
    // Move the new enchanted item into the box.
    object oContainer = GetLocalObject(oCaster, "0_enchanting_box");
    object oEnchantedItem = GetLocalObject (oCaster, "0_enchanted_item");
    // Containers cannot be placed into containers so we have to place on enchanter.
    if (GetHasInventory (oContainer)) oNewItem = CopyItem (oEnchantedItem, oCaster, TRUE);
    else oNewItem = CopyItem (oEnchantedItem, oContainer, TRUE);
    SetLocalString (oNewItem, "0_EnchantedBy", GetName (oCaster, TRUE));
    // Remove the enchanted copy item.
    DestroyObject (oEnchantedItem);
    CleanVariables(oCaster);
}
