/*//////////////////////////////////////////////////////////////////////////////
 Script: ue_itemset_3
 Programmer: Philos
////////////////////////////////////////////////////////////////////////////////
 UnEquip item script for Nature's Ensemble set.
 Used to subtract ability score to the equiped set.
*///////////////////////////////////////////////////////////////////////////////
#include "0i_items"
void main()
{
    itemproperty ipAbilityIncrease;
    int nNumOfPieces = 0;
    itemproperty ipProperty;
    object oPC = GetItemPossessor (OBJECT_SELF);
    object oUnEquipItem = OBJECT_SELF;
    RemoveTempProperties (OBJECT_SELF, "itemset_3");
    // Check to see what pieces are being used from the set.
    // Check for Belt of Silvanus + Strength.
    object oBelt = GetItemInSlot (INVENTORY_SLOT_BELT, oPC);
    if (GetResRef (oBelt) == "itemset_3_1" && oBelt != oUnEquipItem)
    {
        nNumOfPieces ++;
        RemoveTempProperties (oBelt, "itemset_3");
    }
    else oBelt = OBJECT_INVALID;
    // Check for Hood of Chauntea Intelligence+ .
    object oHood = GetItemInSlot (INVENTORY_SLOT_HEAD, oPC);
    if (GetResRef (oHood) == "itemset_3_2" && oHood != oUnEquipItem)
    {
        nNumOfPieces ++;
        RemoveTempProperties (oHood, "itemset_3");
    }
    else oHood = OBJECT_INVALID;
    // Check for Gloves of Eldath + Dexterity.
    object oGloves = GetItemInSlot (INVENTORY_SLOT_ARMS, oPC);
    if (GetResRef (oGloves) == "itemset_3_3" && oGloves != oUnEquipItem)
    {
        nNumOfPieces ++;
        RemoveTempProperties (oGloves, "itemset_3");
    }
    else oGloves = OBJECT_INVALID;
    // Check for Cloak of Mielikki + Charisma.
    object oCloak = GetItemInSlot (INVENTORY_SLOT_CLOAK, oPC);
    if (GetResRef (oCloak) == "itemset_3_4" && oCloak != oUnEquipItem)
    {
        nNumOfPieces ++;
        RemoveTempProperties (oCloak, "itemset_3");
    }
    else oCloak = OBJECT_INVALID;
    // Check for Boots of Gwaeron Windstrom + Constitution.
    object oBoots = GetItemInSlot (INVENTORY_SLOT_BOOTS, oPC);
    if (GetResRef (oBoots) == "itemset_3_5" && oBoots != oUnEquipItem)
    {
        nNumOfPieces ++;
        RemoveTempProperties (oBoots, "itemset_3");
    }
    else oBoots = OBJECT_INVALID;
    // Check for Necklace of Lurue + Wisdom.
    object oNecklace = GetItemInSlot (INVENTORY_SLOT_NECK, oPC);
    if (GetResRef (oNecklace) == "itemset_3_6" && oNecklace != oUnEquipItem)
    {
        nNumOfPieces ++;
        RemoveTempProperties (oNecklace, "itemset_3");
    }
    else oNecklace = OBJECT_INVALID;
    // Give any abilities if found.
    if (oBelt != OBJECT_INVALID)
    {
        ipAbilityIncrease = ItemPropertyAbilityBonus (ABILITY_STRENGTH, nNumOfPieces);
        ipAbilityIncrease = TagItemProperty (ipAbilityIncrease, "itemset_3");
        AddItemProperty (DURATION_TYPE_PERMANENT, ipAbilityIncrease, oBelt);
    }
    if (oHood != OBJECT_INVALID)
    {
        ipAbilityIncrease = ItemPropertyAbilityBonus (ABILITY_INTELLIGENCE, nNumOfPieces);
        ipAbilityIncrease = TagItemProperty (ipAbilityIncrease, "itemset_3");
        AddItemProperty (DURATION_TYPE_PERMANENT, ipAbilityIncrease, oHood);
    }
    if (oGloves != OBJECT_INVALID)
    {
        ipAbilityIncrease = ItemPropertyAbilityBonus (ABILITY_DEXTERITY, nNumOfPieces);
        ipAbilityIncrease = TagItemProperty (ipAbilityIncrease, "itemset_3");
        AddItemProperty (DURATION_TYPE_PERMANENT, ipAbilityIncrease, oGloves);
    }
    if (oCloak != OBJECT_INVALID)
    {
        ipAbilityIncrease = ItemPropertyAbilityBonus (ABILITY_CHARISMA, nNumOfPieces);
        ipAbilityIncrease = TagItemProperty (ipAbilityIncrease, "itemset_3");
        AddItemProperty (DURATION_TYPE_PERMANENT, ipAbilityIncrease, oCloak);
    }
    if (oBoots != OBJECT_INVALID)
    {
        ipAbilityIncrease = ItemPropertyAbilityBonus (ABILITY_CONSTITUTION, nNumOfPieces);
        ipAbilityIncrease = TagItemProperty (ipAbilityIncrease, "itemset_3");
        AddItemProperty (DURATION_TYPE_PERMANENT, ipAbilityIncrease, oBoots);
    }
    if (oNecklace != OBJECT_INVALID)
    {
        ipAbilityIncrease = ItemPropertyAbilityBonus (ABILITY_WISDOM, nNumOfPieces);
        ipAbilityIncrease = TagItemProperty (ipAbilityIncrease, "itemset_3");
        AddItemProperty (DURATION_TYPE_PERMANENT, ipAbilityIncrease, oNecklace);
    }
}
