/*//////////////////////////////////////////////////////////////////////////////
 Script:0c_remove_itmprp
 Programmer:Philos
////////////////////////////////////////////////////////////////////////////////
 Actions Taken script that removes the light property from an item.
 Param: nItemType
    can be 1 - right weapon 2 - left weapon 3 - Armor
           4 - right Ring 5 - left Ring 6 - shield
*///////////////////////////////////////////////////////////////////////////////
#include "0i_itemproperty"

void main ()
{
    object oItem, oPC = GetPCSpeaker();
    if (GetGold (oPC) >= 100)
    {
        int nItemType = StringToInt (GetScriptParam ("nItemType"));
        if (nItemType == 1) oItem = GetItemInSlot (INVENTORY_SLOT_RIGHTHAND, oPC);
        else if (nItemType == 2) oItem = GetItemInSlot (INVENTORY_SLOT_LEFTHAND, oPC);
        else if (nItemType == 3) oItem = GetItemInSlot (INVENTORY_SLOT_CHEST, oPC);
        else if (nItemType == 4) oItem = GetItemInSlot (INVENTORY_SLOT_RIGHTRING, oPC);
        else if (nItemType == 5) oItem = GetItemInSlot (INVENTORY_SLOT_LEFTRING, oPC);
        else if (nItemType == 6) oItem = GetItemInSlot (INVENTORY_SLOT_LEFTHAND, oPC);
        itemproperty ipLight = HasProperty (oItem, ITEM_PROPERTY_LIGHT);
        TakeGoldFromCreature (100, oPC, TRUE);
        RemoveItemProperty (oItem, ipLight);
        ActionPlayAnimation (ANIMATION_FIREFORGET_STEAL);
        SendMessages (GetName (OBJECT_SELF) + " has removed the light property from your " + GetName (oItem) + "!", COLOR_GREEN, oPC);
    }
}
