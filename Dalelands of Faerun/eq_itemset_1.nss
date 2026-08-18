//////////////////////////////////////////////////////////////////////////////////////////////////////
// Name: eq_itemset_1
/*////////////////////////////////////////////////////////////////////////////////////////////////////
 Equip / UnEquip item script for Keldain's set.
 Used to add elemental damage to an equiped weapon.

 Note: We must pass the creature that is equiping or unequiping the set piece
       via "0_ITEMSET_OWNER".
*/////////////////////////////////////////////////////////////////////////////////////////////////////
// Made By: Philos
// Made On: 2/11/16
//////////////////////////////////////////////////////////////////////////////////////////////////////

#include "0i_items"
#include "0i_itemproperty"
#include "nwnx_itemprop"
void main()
{
    int nFire, nCold, nAcid, nElectricity;
    int nNumOfPieces, nDamageBonus, nCount, nPowerSet;
    itemproperty ipProperty;
    object oWeapon, oItem, oCreature = GetLocalObject(OBJECT_SELF, "0_ITEMSET_OWNER");
    oWeapon = GetItemInSlot (INVENTORY_SLOT_RIGHTHAND, oCreature);
    // Check to make sure they have a weapon equiped.
    if(oWeapon == OBJECT_INVALID) return;
    // Remove the powers from the weapon. So we can set it to the correct value.
    RemoveTempProperties(oWeapon, "itemset_1");
    // Check to see what pieces are being used from the set.
    // Check for Armor of Acid.
    oItem = GetItemInSlot(INVENTORY_SLOT_CHEST, oCreature);
    if(GetResRef (oItem) == "itemset_1_1") { nAcid = TRUE; nNumOfPieces ++; }
    // Check for Gauntlets of Fire.
    oItem = GetItemInSlot(INVENTORY_SLOT_HEAD, oCreature);
    if(GetResRef(oItem) == "itemset_1_2") { nFire = TRUE; nNumOfPieces ++; }
    // Check for Helmet of Electricity.
    oItem = GetItemInSlot(INVENTORY_SLOT_ARMS, oCreature);
    if(GetResRef(oItem) == "itemset_1_3") { nElectricity = TRUE; nNumOfPieces ++; }
    // Check for Greaves of Ice.
    oItem = GetItemInSlot (INVENTORY_SLOT_BOOTS, oCreature);
    if(GetResRef(oItem) == "itemset_1_4") { nCold = TRUE; nNumOfPieces ++; }
    // Now set the power of the elements.
    if(nNumOfPieces == 1) nDamageBonus = IP_CONST_DAMAGEBONUS_1;
    else if(nNumOfPieces == 2) nDamageBonus = IP_CONST_DAMAGEBONUS_2;
    else if(nNumOfPieces == 3) nDamageBonus = IP_CONST_DAMAGEBONUS_1d4;
    else if(nNumOfPieces == 4) nDamageBonus = IP_CONST_DAMAGEBONUS_1d6;
    // Add cost reduction to the weapon.
    Debug("eq_itemset_1", "46", "oCreature: " + GetName(oCreature) + " oItem: " + GetName(OBJECT_SELF) + " nNumOfPieces: " + IntToString(nNumOfPieces));
    if(nNumOfPieces > 0)
    {
        AddCostReductionItemProperty (oWeapon, "itemset_1");
        // Now add damage to weapon.
        if(nAcid)
        {
            if(!GetIsItemPropertyValid(HasProperty(oWeapon, ITEM_PROPERTY_DAMAGE_BONUS, IP_CONST_DAMAGETYPE_ACID)))
            {
                ipProperty = ItemPropertyDamageBonus (IP_CONST_DAMAGETYPE_ACID, nDamageBonus);
                ipProperty = TagItemProperty (ipProperty, "itemset_1");
                AddItemProperty (DURATION_TYPE_PERMANENT, ipProperty, oWeapon);
            }
        }
        if(nElectricity)
        {
            if(!GetIsItemPropertyValid(HasProperty(oWeapon, ITEM_PROPERTY_DAMAGE_BONUS, IP_CONST_DAMAGETYPE_ELECTRICAL)))
            {
                ipProperty = ItemPropertyDamageBonus (IP_CONST_DAMAGETYPE_ELECTRICAL, nDamageBonus);
                ipProperty = TagItemProperty (ipProperty, "itemset_1");
                AddItemProperty (DURATION_TYPE_PERMANENT, ipProperty, oWeapon);
            }
        }
        if(nFire)
        {
            if(!GetIsItemPropertyValid(HasProperty(oWeapon, ITEM_PROPERTY_DAMAGE_BONUS, IP_CONST_DAMAGETYPE_FIRE)))
            {
                ipProperty = ItemPropertyDamageBonus (IP_CONST_DAMAGETYPE_FIRE, nDamageBonus);
                ipProperty = TagItemProperty (ipProperty, "itemset_1");
                AddItemProperty (DURATION_TYPE_PERMANENT, ipProperty, oWeapon);
            }
        }
        if(nCold)
        {
            if(!GetIsItemPropertyValid(HasProperty(oWeapon, ITEM_PROPERTY_DAMAGE_BONUS, IP_CONST_DAMAGETYPE_COLD)))
            {
                ipProperty = ItemPropertyDamageBonus (IP_CONST_DAMAGETYPE_COLD, nDamageBonus);
                ipProperty = TagItemProperty (ipProperty, "itemset_1");
                AddItemProperty (DURATION_TYPE_PERMANENT, ipProperty, oWeapon);
            }
        }
    }
}
