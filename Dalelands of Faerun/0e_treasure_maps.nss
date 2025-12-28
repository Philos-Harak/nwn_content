/*////////////////////////////////////////////////////////////////////////////////////////////////////
 Script Name: 0e_treasure_maps
 Programmer: Philos
/////////////////////////////////////////////////////////////////////////////////////////////////////
 Used to create Treasure maps.
*//////////////////////////////////////////////////////////////////////////////////////////////////
#include "0i_quest"
void main()
{
     object oChest = OBJECT_SELF;
     object oPC = GetLastOpenedBy();
     int nLevel = GetLocalInt (oChest, "0_TreasureLevel");
     if(GetMaster(oPC) != OBJECT_INVALID) oPC = GetMaster(oPC);
     object oMap = CreateItemOnObject("0_treasure_map", oChest);
     Build_Treasure_Map(oPC, oMap, nLevel);
     oMap = CreateItemOnObject("0_treasure_map", oChest);
     Build_Treasure_Map(oPC, oMap, nLevel);
     oMap = CreateItemOnObject("0_treasure_map", oChest);
     Build_Treasure_Map(oPC, oMap, nLevel);
}
