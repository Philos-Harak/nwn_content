/*//////////////////////////////////////////////////////////////////////////////
 Script: 0c_if_no_weapon
 Programmer: Philos
////////////////////////////////////////////////////////////////////////////////
 Conversation script that checks to see if they have a weapon.
*///////////////////////////////////////////////////////////////////////////////
#include "0i_items"
int StartingConditional()
{
    object oWeapon = GetItemInSlot (INVENTORY_SLOT_RIGHTHAND, GetPCSpeaker());
    // If they are not wielding a weapon then we cannot let them change it.
    if (!GetIsObjectValid (oWeapon)) return TRUE;
    // Make sure it is a weapon.
    else if (!GetIsWeapon (oWeapon)) return TRUE;
    else if (GetBaseItemType(oWeapon) == BASE_ITEM_WHIP ||
             GetBaseItemType(oWeapon) == BASE_ITEM_SLING ) return TRUE;
    return FALSE;
}
