/*////////////////////////////////////////////////////////////////////////////////////////////////////
 Script Name: 0e_rolltreasure
 Programmer: Philos
/////////////////////////////////////////////////////////////////////////////////////////////////////
 Used to create magic items in containers and creatures.
 The following variables can adjust what is rolled in the system.
 0_TreasureLevel   - Level of the chest from 1 - 20. If it is 0 then it will check the area level.
 0_TreasureBonus   - Bonus on top of the area level. Thus a level of 1 + a bonus of 1 = 2. Still limited from 1 - 20.
 0_Multiplier      - Will multiply the rolled treasure by this variables amount.
                     -1 will give no treasure to the container.
 0_BonusGold       - Gives a bonus amount of gold equal to 0_BonusGold.
 0_BonusMagicItems - Gives a bonus number of magic items equal to 0_BonusMagicItems.
 0_BaseItemType    - Will drop a specific base item type.

Tables that can be used with BaseItemType:
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

*//////////////////////////////////////////////////////////////////////////////////////////////////
#include "0i_treasure"
#include "0i_magicitems"
#include "0i_items"
#include "0i_quest"
void main ()
{
   object oPC;
   // Check to see if this placeable has been checked already.
   if (!GetLocalInt (OBJECT_SELF, "0_Used"))
   {
      // Set this placeable as checked.
      SetLocalInt (OBJECT_SELF, "0_Used", TRUE);
      // Get the player opening this placeable using Philos PEPS AI.
      object oPC = GetLocalObject(OBJECT_SELF, "AI_GET_LAST_OPENED_BY");
      if (oPC == OBJECT_INVALID) oPC = GetLastOpenedBy();
      int nLevel = GetLocalInt (OBJECT_SELF, "0_TreasureLevel");
      RollTreasure (OBJECT_SELF, oPC, nLevel);
      // See if we want any treasure maps.
      if(d100() < 6)
      {
           object oMap = CreateItemOnObject("0_treasure_map");
           Build_Treasure_Map(oPC, oMap, nLevel);
      }
      // Check the objects inventory and identify all object below a specific cost.
      IdDrops (OBJECT_SELF, GetLocalInt (OBJECT_SELF, "0_Identified"));
   }
}

