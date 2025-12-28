/*/////////////////////////////////////////////////////////////////////////////////////////////////////
 Script Name: 0e_open_magmerch
 Programmer: Philos
/////////////////////////////////////////////////////////////////////////////////////////////////////
 Runs the script to open a merchant that generates random magic items.

 Variables on the Store.
 0_MinItems - The minimum number of items in the store. 0 sets it to the default.
 0_Level will set the shop to this level instead of the areas level.
 0_ItemType will define the type of items generated. Based on the smi_list.2da
    BASE_ITEM_RODS_STAVES = 131               GARB = 115
    BASE_ITEM_WEAPON = 132                    OUTFIT = 116
    BASE_ITEM_MELEE_WEAPON = 133              ROBE = 117
    BASE_ITEM_SIMPLE_WEAPON = 134             TUNIC = 118
    BASE_ITEM_MARTIAL_WEAPON = 135            PADDED = 119
    BASE_ITEM_EXOTIC_WEAPON = 136             LEATHER = 120
    BASE_ITEM_RANGED_WEAPON = 137             ST LEATHER = 121
    BASE_ITEM_THROWN_WEAPON = 138             HIDE = 122
    BASE_ITEM_AMMO = 139                      CHAIN SHIRT = 123
    BASE_ITEM_SHIELD = 140                    SCALE MAIL = 124
    BASE_ITEM_ARMOR_SHIELD = 141              CHAINMAIL = 125
    BASE_ITEM_CLOTHING = 142                  BREAST PLATE = 126
    BASE_ITEM_LIGHT_ARMOR = 143               SPLINT MAIL = 127
    BASE_ITEM_MEDIUM_ARMOR = 144              BANDED MAIL = 128
    BASE_ITEM_HEAVY_ARMOR = 145               HALF PLATE = 129
    BASE_ITEM_WONDROUS = 146                  FULL PLATE = 130
    BASE_ITEM_MAGIC_CLOTH_STORE = 147
    BASE_ITEM_MAGIC_JEWEL_STORE = 148
    BASE_ITEM_NO_ONE_USE_ITEM_STORE = 149
    BASE_ITEM_ALL_ITEM_STORE = 150
*/////////////////////////////////////////////////////////////////////////////////////////////////////
#include "0i_character"
#include "0i_merchant"
#include "0i_quest"
void main ()
{
    object oStore = OBJECT_SELF;
    int nMinItems = GetMinimumNumberOfItemsForMerchant(oStore);
    int nUniqueItems = GetNumberOfUniqueItemsOnMerchant(oStore);
    // Add a patron, we keep track so we don't remove items while someone is in the shop.
    int nPatrons = GetLocalInt(oStore, "0_Patrons") + 1;
    SetLocalInt(oStore, "0_Patrons", nPatrons);
    if(nUniqueItems < nMinItems)
    {
        int nNewItems = Random(nMinItems) + 1 + nMinItems - nUniqueItems;
        int nItemType = GetTypeOfItemsToRoll(oStore);
        int nLevel = GetLevelForMerchant(oStore);
        // Should we add some Treasure maps if the shop sell all types of items?
        if(nItemType == 150)
        {
            object oPC = GetLastOpenedBy();
            if(d100() < 5) Build_Treasure_Map(oPC, CreateItemOnObject("0_treasure_map", oStore), nLevel);
            if(d100() < 5) Build_Treasure_Map(oPC, CreateItemOnObject("0_treasure_map", oStore), nLevel);
            if(d100() < 5) Build_Treasure_Map(oPC, CreateItemOnObject("0_treasure_map", oStore), nLevel);
        }
        if(nNewItems > 0) RollMagicItems(oStore, nLevel, nNewItems, nItemType);
    }
}

