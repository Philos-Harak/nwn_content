/*//////////////////////////////////////////////////////////////////////////////
 Script:0c_if_light_prop
 Programmer:Philos
////////////////////////////////////////////////////////////////////////////////
 Text Appears When script that checks if the PCSpeaker's specific item has
 the light property on it and 500 gold for the removal.
 Param: nItemType
    can be 1 - right weapon 2 - left weapon 3 - Armor
           4 - right Ring 5 - left Ring 6 - shield
*///////////////////////////////////////////////////////////////////////////////
#include "0i_itemproperty"

int StartingConditional()
{
    object oItem, oPC = GetPCSpeaker();
    int nItemType = StringToInt (GetScriptParam ("nItemType"));
    if (nItemType == 1) oItem = GetItemInSlot (INVENTORY_SLOT_RIGHTHAND, oPC);
    if (nItemType == 2)
    {
        oItem = GetItemInSlot (INVENTORY_SLOT_LEFTHAND, oPC);
        if (!GetIsWeapon (oItem)) return FALSE;
    }
    else if (nItemType == 3) oItem = GetItemInSlot (INVENTORY_SLOT_CHEST, oPC);
    else if (nItemType == 4) oItem = GetItemInSlot (INVENTORY_SLOT_RIGHTRING, oPC);
    else if (nItemType == 5) oItem = GetItemInSlot (INVENTORY_SLOT_LEFTRING, oPC);
    else if (nItemType == 6)
    {
        oItem = GetItemInSlot (INVENTORY_SLOT_LEFTHAND, oPC);
        if (!GetIsShield (oItem)) return FALSE;
    }
    if (oItem == OBJECT_INVALID) return FALSE;
    itemproperty ipLight = HasProperty (oItem, ITEM_PROPERTY_LIGHT);
    if (GetIsItemPropertyValid (ipLight) && GetGold (oPC) >= 100) return TRUE;
    return FALSE;
}
