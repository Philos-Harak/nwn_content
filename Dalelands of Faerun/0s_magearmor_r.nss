/*/////////////////////////////////////////////////////
 Script: 0s_magearmor_r
 Programmer: Philos
///////////////////////////////////////////////////////
 This removes the bonuses from the spell Mage armor and Greater Mage armor.
 OBJECT_SELF is the target of the effect.
/*/////////////////////////////////////////////////////
#include "0i_spells"
#include "nwnx_creature"
#include "nwnx_effect"
void main()
{
    // Spell passes the armor bonus data.
    effect eEffect = GetLastRunScriptEffect ();
    int nMageArmorBonus = StringToInt (GetEffectString (eEffect, 0));
    int nArmorBonus = GetLocalInt (OBJECT_SELF, "0_Armor_Bonus");
    if (nArmorBonus >= nMageArmorBonus)
    {
        // Remove the armor bonus.
        nArmorBonus = nArmorBonus - nMageArmorBonus;
        SetLocalInt (OBJECT_SELF, "0_Armor_Bonus", nArmorBonus);
        // Get equiped Armor AC.
        object oItem = GetItemInSlot (INVENTORY_SLOT_CHEST, OBJECT_SELF);
        int nArmorAC = NWNX_Item_GetBaseArmorClass (oItem);
        if (nArmorAC < nArmorBonus) nArmorAC = nArmorBonus;
        NWNX_Creature_SetBaseAC (OBJECT_SELF, nArmorAC);
    }
}

