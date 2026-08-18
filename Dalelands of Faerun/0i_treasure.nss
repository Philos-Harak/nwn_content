/*////////////////////////////////////////////////////////////////////////////////////////////////////
 Script Name: 0i_treasure
 Programmer: Philos
//////////////////////////////////////////////////////////////////////////////////////////////////////
 Include scripts for use with magic items.
*/////////////////////////////////////////////////////////////////////////////////////////////////////
#include "0i_magicitems"
#include "x2_inc_switches"
void CheckForTreasure(object oPC, object oCreature);

// Randomizes Treasure and places it in oContainer.
// oPC is the PC we are rolling treasure for.
// iLevel bypassed default levels.
void RollTreasure(object oContainer, object oPC = OBJECT_INVALID, int iLevel = 0);

// Randomizes gems and place in oContainer.
// Selects the treasure based on the iLevel passed.
// oContainer is the container/creature to put the gems on.
// iLevel is the level of the treasure we are creating.
// iNumber is the number to be rolled.
// oPC is the PC's luck we should use.
object RollGems(object oContainer, int iLevel, int iNumber, object oPC = OBJECT_INVALID);

// Randomizes art items and place in oContainer.
// Selects the treasure based on the iLevel passed.
// oContainer is the container/creature to put the gems on.
// iLevel is the level of the treasure we are creating.
// iNumber is the number to be rolled.
// oPC is the PC's luck we should use.
object RollArt(object oContainer, int iLevel, int iNumber, object oPC = OBJECT_INVALID);

// Randomizes mundane items and place in oContainer.
// Selects the treasure based on the iLevel passed.
// iNumber is the number to be rolled.
// oPC is the PC's luck we should use.
void RollMundaneItems(object oContainer, int iLevel, int iNumber, object oPC = OBJECT_INVALID);

void CheckForTreasure(object oPC, object oCreature)
{
    // if they are not incorporeal, iMultiplier = -1 (i.e. no treasure)
    // or are a specific type of creature.
    object oArea = GetArea (oCreature);
    int nRacialType = (GetRacialType (oCreature));
    int bEquipment = FALSE;
    if (nRacialType != RACIAL_TYPE_ANIMAL &&
        nRacialType != RACIAL_TYPE_VERMIN &&
        nRacialType != RACIAL_TYPE_CONSTRUCT &&
        nRacialType != RACIAL_TYPE_ELEMENTAL &&
        !GetCreatureFlag (oCreature, CREATURE_VAR_IS_INCORPOREAL)) bEquipment = TRUE;
    if ((GetTag (oArea) != "cynosure2" &&
         GetLocalInt (oCreature, "0_Multiplier") != -1 && bEquipment) ||
         GetLocalInt (oCreature, "0_BonusMagicItems") > 0)
    {
       RollTreasure (oCreature, oPC);
       // Give base equipment and armor.
       if (bEquipment && nRacialType != RACIAL_TYPE_OOZE &&
           nRacialType != RACIAL_TYPE_MAGICAL_BEAST &&
           nRacialType != RACIAL_TYPE_DRAGON)
       {
           GiveEquipment (oCreature, FALSE);
           DelayCommand (0.5f, EquipItems (oCreature, FALSE));
       }
   }
}

// Randomizes Treasure and places it in oContainer.
// oPC is the PC we are rolling treasure for.
// iLevel bypassed default levels.
void RollTreasure(object oContainer, object oPC = OBJECT_INVALID, int iLevel = 0)
{
   int iMundane, iGold, iArt, iGem, iMagicItems, iRoll;
   // See if loot is disabled in this area.
   object oArea = GetArea (oContainer);
   if (GetLocalInt (oArea, "0_LootOFF")) return;
   // Get the games treasure slider that can add or subract % chance to rolls.
   int iTreasureSlider = GetLocalInt (GetModule (), "0_TREASURE_SLIDER");
   // If a level was not passed then create one based on type of container.
   if (iLevel < 1)
   {
       // Check to see if the container is a creature or placeable.
       // Then get the level based on creature CR or area level.
       if (GetObjectType (oContainer) == OBJECT_TYPE_CREATURE) iLevel = FloatToInt (GetChallengeRating (oContainer));
       // Placeable treasure level.
       else
       {
            iLevel = GetLocalInt (oContainer, "0_TreasureLevel");
            // If there is no treasure level then generate it by getting the area level.
            if (iLevel == 0) iLevel = GetLocalInt (oArea, "0_Area_Level");
       }
       // Check for a bonus level to the Treasure.
       iLevel = iLevel + GetLocalInt (oContainer, "0_TreasureBonus");
       if (iLevel < 1) iLevel = 1;
   }
   // Cap treasure levels to 40.
   if (iLevel > 40) iLevel = 40;
   int nChance = iLevel;
   if(nChance > 20) nChance = 20;
   // Get the treasure multiplier.
   int iMultiplier = GetLocalInt (oContainer, "0_Multiplier");
   // If 0 (default) then set to 1.
   if (iMultiplier == 0) iMultiplier = 1;
   // If greater than 0 then roll treasure otherwise skip (-1 = no treasure).
   if (iMultiplier > 0)
   {
       // Gold Chance: 25%
       if ((d100LuckRoll (oPC) + iTreasureSlider) > 74)
       {
            // Gold Amount: Gives a range of gold: 1st) 1-10, 5th) 5-50, 10th) 10-109 15th) 15 - 164, 20th) 20-219.
            iGold = (RandomLuckRoll (oPC, iLevel * 10) + iLevel) * iMultiplier;
       }
       // Art Object Chance: 1st)0% 5th)2% 10th)5% 15th)7% 20th)10%.
       if ((d100LuckRoll (oPC) + iTreasureSlider) > 100 - (nChance - (nChance / 2)))
       {
            // Art Object Amount: (iLevel / 5) gives max of 4 at 20th.
            iArt = (RandomLuckRoll (oPC, nChance / 6)) * iMultiplier;
            RollArt (oContainer, iLevel, iArt, oPC);
       }
       // Gems Chance: 1st)0% 5th)3% 10th)6% 15th)10% 20th)13%.
       if ((d100LuckRoll (oPC) + iTreasureSlider) > 100 - (nChance - (nChance / 3)))
       {
            // Gems Amount: (iLevel / 6) +1 gives max of 4 at 20th.
            iGem = (RandomLuckRoll (oPC, nChance / 6)) * iMultiplier;
            RollGems (oContainer, iLevel, iGem, oPC);
       }
       // Mundane Item Chance: 1st)20% 5th)15% 10th)10% 15th)5% 20th)1%.
       // Mundane Item Amount: Gives 1 item.
       if ((d100LuckRoll (oPC) + iTreasureSlider) > 99 - (20 - nChance)) RollMundaneItems (oContainer, iLevel, 1);
       // Magic Item Chance: 1st)1%, 5th)5%, 10th)10%, 15th)15%, 20th)20%.
       // Magic Item Amount: (iLevel / 5) gives max of 4 at 20th.
       int nRoll = d100LuckRoll (oPC) + iTreasureSlider;
       if (nRoll > 100 - nChance + (nChance / 2))
       {
            // Get Number of Magic items to generate.
            if (iLevel < 10) iMagicItems = 1;
            else iMagicItems = (RandomLuckRoll(oPC, nChance / 5)) * iMultiplier;
       }
   }
   // Add any bonus gold.
   iGold = iGold + GetLocalInt (oContainer, "0_BonusGold");
   // Add any bonus magic items.
   iMagicItems = iMagicItems + GetLocalInt (oContainer, "0_BonusMagicItems");
   // Generate any gold rolled.
   if (iGold > 0)
   {
       // Get container.
       int iType = GetObjectType (oContainer);
       // Give gold.
       if (iType == OBJECT_TYPE_CREATURE) GiveGoldToCreature (oContainer, iGold);
       else if (iType == OBJECT_TYPE_PLACEABLE) CreateItemOnObject ("nw_it_gold001", oContainer, iGold, "");
   }
   // Generate any magic items rolled.
   if (iMagicItems > 0)
   {
        // Check to see if they drop a specific base item type or use a special table.
        int iBaseItemType = GetLocalInt (oContainer, "0_BaseItemType");
        if (iBaseItemType == 0) iBaseItemType = BASE_ITEM_INVALID;
        // Generate magic items.
        RollMagicItems (oContainer, iLevel, iMagicItems, iBaseItemType, oPC);
   }
}

// Randomizes gems and place in oContainer.
// Selects the treasure based on the iLevel passed.
// oContainer is the container/creature to put the gems on.
// iLevel is the level of the treasure we are creating.
// iNumber is the number to be rolled.
// oPC is the PC's luck we should use.
object RollGems (object oContainer, int nLevel, int nNumber, object oPC = OBJECT_INVALID)
{
   string sGemResRef;
   int nRoll;
   object oItem;
   while (nNumber > 0)
   {
      nRoll = d100LuckRoll (oPC);
      if(nLevel < 6)
      {
            // Ornamental Stones worth 10gp.
            if (nRoll < 50) { sGemResRef = "g_25_"; nRoll = 26; }
            // Semi-precious Stones worth 50gp.
            else if (nRoll < 86) { sGemResRef = "g_50_"; nRoll = 12; }
            // Fancy Stones worth 100gp.
            else if (nRoll < 99) { sGemResRef = "g_100_"; nRoll = 10; }
            // Precious Stones worth 500gp.
            else { sGemResRef = "g_500_"; nRoll = 12; }
      }
      else if (nLevel < 11)
      {
            // Ornamental Stones worth 10gp.
            if (nRoll < 26) { sGemResRef = "g_25_"; nRoll = 26; }
            // Semi-precious Stones worth 50gp.
            else if (nRoll < 51) { sGemResRef = "g_50_"; nRoll = 12; }
            // Fancy Stones worth 100gp.
            else if (nRoll < 76) { sGemResRef = "g_100_"; nRoll = 10; }
            // Precious Stones worth 500gp.
            else if (nRoll < 99) { sGemResRef = "g_500_"; nRoll = 12; }
            // Gems worth 1000gp.
            else { sGemResRef = "g_1000_"; nRoll = 12; }
      }
      else if (nLevel < 16)
      {
            // Ornamental Stones worth 10gp.
            if (nRoll < 13) { sGemResRef = "g_25_"; nRoll = 26; }
            // Semi-precious Stones worth 50gp.
            else if (nRoll < 26) { sGemResRef = "g_50_"; nRoll = 12; }
            // Fancy Stones worth 100gp.
            else if (nRoll < 76) { sGemResRef = "g_100_"; nRoll = 10; }
            // Precious Stones worth 500gp.
            else if (nRoll < 96) { sGemResRef = "g_500_"; nRoll = 12; }
            // Gems worth 1000gp.
            else if (nRoll < 99) { sGemResRef = "g_1000_"; nRoll = 12; }
            // Jewels worth 5000gp.
            else { sGemResRef = "g_5000_"; nRoll = 10; }
      }
      else
      {
            // Semi-precious Stones worth 50gp.
            if (nRoll < 13) { sGemResRef = "g_50_"; nRoll = 12; }
            // Fancy Stones worth 100gp.
            else if (nRoll < 26) { sGemResRef = "g_100_"; nRoll = 10; }
            // Precious Stones worth 500gp.
            else if (nRoll < 76) { sGemResRef = "g_500_"; nRoll = 12; }
            // Gems worth 1000gp.
            else if (nRoll < 96) { sGemResRef = "g_1000_"; nRoll = 12; }
            // Jewels worth 5000gp.
            else { sGemResRef = "g_5000_"; nRoll = 10; }
      }
      sGemResRef = sGemResRef + IntToString (Random(nRoll) + 1);
      oItem = CreateItemOnObject (sGemResRef, oContainer, 1, "");
      // Check for an error.
      if (!GetIsObjectValid (oItem)) SetModuleError ("RESREF", "0i_treasure", "153", "Invalid resref: " + sGemResRef);
      nNumber--;
   }
   return oItem;
}

// Randomizes art items and place in oContainer.
// Selects the treasure based on the iLevel passed.
// oContainer is the container/creature to put the gems on.
// iLevel is the level of the treasure we are creating.
// iNumber is the number to be rolled.
// oPC is the PC's luck we should use.
object RollArt (object oContainer, int iLevel, int iNumber, object oPC = OBJECT_INVALID)
{
   string sArtResRef;
   int iRoll;
   object oItem;
   while (iNumber > 0)
   {
      iRoll = d100LuckRoll(oPC);
      if (iLevel < 6)
      {
           // Art average worth 50gp.
           if (iRoll < 51) sArtResRef = "a_50_";
           // Art average worth 100gp.
           else if (iRoll < 86) sArtResRef = "a_100_";
           // Art average worth 500gp.
           else if (iRoll < 99) sArtResRef = "a_500_";
           // Art average worth 1000gp.
           else sArtResRef = "a_1000_";
      }
      else if (iLevel < 11)
      {
           // Art average worth 50gp.
           if (iRoll < 26) sArtResRef = "a_50_";
           // Art average worth 100gp.
           else if (iRoll < 51) sArtResRef = "a_100_";
           // Art average worth 500gp.
           else if (iRoll < 86) sArtResRef = "a_500_";
           // Art average worth 1000gp.
           else if (iRoll < 99) sArtResRef = "a_1000_";
           // Art average worth 2500gp.
           else sArtResRef = "a_2500_";
      }
      else if (iLevel < 16)
      {
           // Art average worth 50gp.
           if (iRoll < 13) sArtResRef = "a_50_";
           // Art average worth 100gp.
           else if (iRoll < 26) sArtResRef = "a_100_";
           // Art average worth 500gp.
           else if (iRoll < 51) sArtResRef = "a_500_";
           // Art average worth 1000gp.
           else if (iRoll < 86) sArtResRef = "a_1000_";
           // Art average worth 2500gp.
           else if (iRoll < 99) sArtResRef = "a_2500_";
           // Art average worth 5000gp.
           else sArtResRef = "a_5000_";
      }
      else
      {
           // Art average worth 100gp.
           if (iRoll < 13) sArtResRef = "a_100_";
           // Art average worth 500gp.
           else if (iRoll < 26) sArtResRef = "a_500_";
           // Art average worth 1000gp.
           else if (iRoll < 51) sArtResRef = "a_1000_";
           // Art average worth 2500gp.
           else if (iRoll < 96) sArtResRef = "a_2500_";
           // Art average worth 5000gp.
           else if (iRoll < 99) sArtResRef = "a_5000_";
           // Art average worth 7000gp.
           else sArtResRef = "a_7000_";
      }
      sArtResRef = sArtResRef + IntToString (d4());
      oItem = CreateItemOnObject (sArtResRef, oContainer, 1, "");
      // Check for an error.
      if (!GetIsObjectValid (oItem)) SetModuleError ("RESREF", "0i_treasure", "153", "Invalid resref: " + sArtResRef);
      SetLocalString (oItem, "0_Creator", StripColorCodes (GetName (oContainer)));
      iNumber--;
   }
   return oItem;
}

// Randomizes mundane items and place in oContainer.
// Selects the treasure based on the iLevel passed.
// iNumber is the number to be rolled.
// oPC is the PC's luck we should use.
void RollMundaneItems (object oContainer, int iLevel, int iNumber, object oPC = OBJECT_INVALID)
{
   object oItem, oBuildContainer, oItem2;
   string sResRef, s2DAItemTable;
   int iRoll,iRow, iQuality, iChance;
   while (iNumber > 0)
   {
      // Roll on the Base Mundane Item Chart for the base item type.
      iRow = RollOn2daTable (BASE_MUNDANE_ITEM_2DA_FILE, 0, oPC);
      // Get the next 2da File to randomly roll for the ResRef of the item.
      s2DAItemTable = Get2DAString (BASE_MUNDANE_ITEM_2DA_FILE, "ItemTable", iRow);
      sResRef = RollBaseItemResRef (s2DAItemTable, oPC);
      // Check if the item gets a quality.
      iQuality = StringToInt (Get2DAString (BASE_MUNDANE_ITEM_2DA_FILE, "Quality", iRow));
      // Get the Building container.
      oBuildContainer = GetObjectByTag (TEMP_CHEST);
      // Create the object.
      oItem = CreateItemOnObject (sResRef, oBuildContainer);
      // Check for an error.
      if (!GetIsObjectValid (oItem)) SetModuleError ("RESREF", "0i_treasure", "309", s2DAItemTable + " 2da file has invalid resref: " + sResRef + " on row " + IntToString (iRow));
      // Change items appearance.
      oItem2 = ChangeItemAppearance (oItem, 0);
      // Copy final item to container.
      oItem = CopyItem (oItem2, oContainer, TRUE);
      // Add a quality if needed.
      if (iQuality)
      {
          if (iLevel > 15) iRoll = 5;
          else if (iLevel > 10) iRoll = 4;
          else if (iLevel > 5) iRoll = 3;
          else iRoll = 2;
          // Roll the quality. 1-Master work, 2-Exquisite, 3-Legendary, 4 Relic, 5-Artifact
          iRoll = RandomLuckRoll (oPC, iRoll) - 1;
          if (iRoll > 0)
          {
              itemproperty ipProperty = ItemPropertyQuality (iRoll);
              AddItemProperty (DURATION_TYPE_PERMANENT, ipProperty, oItem);
              if (!GetIsItemStackable (oItem)) NWNX_Item_SetAddGoldPieceValue (oItem, RandomLuckRoll (oPC, iRoll * 100));
          }
      }
      // Destroy Buildcontainer copy.
      DestroyObject (oItem2);
      // Now flag the item with who created it.
      if (!GetIsItemStackable (oItem)) SetLocalString (oItem, "0_Creator", StripColorCodes (GetName (oContainer)));
      // Check to see if its ammo. If so then give a random amount.
      if (GetIsAmmo (oItem)) SetItemStackSize (oItem, RandomLuckRoll (oPC, 50) + 50);
      else if (GetIsThrownWeapon (oItem)) SetItemStackSize (oItem, d20LuckRoll (oPC) + 30);
      iNumber--;
   }
}
