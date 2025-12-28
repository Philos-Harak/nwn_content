/*/////////////////////////////////////////////////////
 0s_tenstrans_r
 Created By: Philos
///////////////////////////////////////////////////////
 This removes the bonuses from the spell Tenser's Transformation.
 OBJECT_SELF is the target of the effect.
/*/////////////////////////////////////////////////////
#include "0i_spells"
#include "nwnx_creature"
#include "0i_items"
void CheckWeapon (object oPC, int nSlot)
{
    // Check weapon in the right hand to make sure they can still use it.
    object oWeapon = GetItemInSlot(INVENTORY_SLOT_RIGHTHAND, oPC);
    int nIndex, bHasFeat;
    int nBaseItemType = GetBaseItemType(oWeapon);
    int nReqFeat = StringToInt(Get2DAString("baseitems", "ReqFeat" + IntToString(nIndex), nBaseItemType));
    while(nReqFeat != 0 || nIndex < 4)
    {
        if(GetHasFeat(nReqFeat, oPC)) bHasFeat = TRUE;
        nReqFeat = StringToInt(Get2DAString("baseitems", "ReqFeat" + IntToString(++nIndex), nBaseItemType));
    }
    if(!bHasFeat)
    {
        ClearAllActions (TRUE);
        ActionUnequipItem (oWeapon);
    }
}

void main()
{
    // Reset the creatures BaseAttackBonus.
    NWNX_Creature_SetBaseAttackBonus(OBJECT_SELF, 0);
    RestoreBaseAttackBonus(OBJECT_SELF);
    object oSkin = GetItemInSlot(INVENTORY_SLOT_CARMOUR, OBJECT_SELF);
    RemoveTaggedItemProperties(oSkin, "Tensers_Transformation");
    DeleteLocalInt(OBJECT_SELF, "0_Cannot_Cast");
    DelayCommand(1.0f, CheckWeapon (OBJECT_SELF, INVENTORY_SLOT_RIGHTHAND));
    DelayCommand(2.0f, CheckWeapon (OBJECT_SELF, INVENTORY_SLOT_LEFTHAND));
}

