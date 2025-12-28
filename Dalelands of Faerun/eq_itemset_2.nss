//////////////////////////////////////////////////////////////////////////////////////////////////////
// Name: eq_itemset_2
/*////////////////////////////////////////////////////////////////////////////////////////////////////

 Equip item script for U'l Phair's set.
 Used to add spell slots to an equiped head gear.

 Note: We must pass the creature that is equiping or unequiping the set piece
       via "0_ITEMSET_OWNER".
*/////////////////////////////////////////////////////////////////////////////////////////////////////
// Made By: Philos
// Made On: 2/11/16
//////////////////////////////////////////////////////////////////////////////////////////////////////

#include "0i_items"
#include "nwnx_itemprop"
void main()
{
    int nNumOfPieces;
    object oCreature = GetLocalObject(OBJECT_SELF, "0_ITEMSET_OWNER");
    object oHeadGear = GetItemInSlot(INVENTORY_SLOT_HEAD, oCreature);
    // Check to make sure they have a head gear equiped.
    if(oHeadGear == OBJECT_INVALID) return;
    // Remove the powers from the head gear. So we can set it to the correct value.
    RemoveTempProperties(oHeadGear, "itemset_2");
    // Check to see what pieces are being used from the set.
    // Check for Hand of silver or Gold in ring Slot 1.
    object oItem = GetItemInSlot(INVENTORY_SLOT_LEFTRING, oCreature);
    string sResRef = GetResRef(oItem);
    if(sResRef == "itemset_2_1" || sResRef == "itemset_2_2") nNumOfPieces ++;
    // Check for Hand of silver or Gold in ring Slot 2.
    oItem = GetItemInSlot(INVENTORY_SLOT_RIGHTRING, oCreature);
    sResRef = GetResRef(oItem);
    if(sResRef == "itemset_2_1" || sResRef == "itemset_2_2") nNumOfPieces ++;
    // Check for the Ruby eyes.
    oItem = GetItemInSlot(INVENTORY_SLOT_ARMS, oCreature);
    if(GetResRef(oItem) == "itemset_2_3") nNumOfPieces ++;
    // Check for Bone skull.
    oItem = GetItemInSlot(INVENTORY_SLOT_BELT, oCreature);
    if(GetResRef (oItem) == "itemset_2_4") nNumOfPieces ++;
    // Now set the number and power of spell slots.
    if(nNumOfPieces > 0)
    {
        itemproperty ipProperty;
        AddCostReductionItemProperty (oHeadGear, "itemset_2");
        ipProperty = ItemPropertyBonusLevelSpell (CLASS_TYPE_WIZARD, nNumOfPieces);
        ipProperty = TagItemProperty (ipProperty, "itemset_2");
        AddItemProperty (DURATION_TYPE_PERMANENT, ipProperty, oHeadGear);
    }
}
