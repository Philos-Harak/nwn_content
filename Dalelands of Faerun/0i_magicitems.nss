/*////////////////////////////////////////////////////////////////////////////////////////////////////
// Script Name: 0i_magicitems
//////////////////////////////////////////////////////////////////////////////////////////////////////
 If the container has the variable "0_MaxNumOfPowers" set on it then the first
  permanent magic item will get the maximum number of powers based on the containers level.

 Include scripts help create item properties.
 This is a 2da driven magic item creation system.

 Number of powers are gained at the following levels.
 2 powers 6th
 3 powers 12th
 4 powers 18th

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
// Programmer: Philos
//////////////////////////////////////////////////////////////////////////////////////////////////////
#include "0i_itemproperty"
#include "0i_database"
// Randomizes magic items and places them in oContainer.
// oContainer is the object to place the items in.
// iLevel is the level of the roll; From 1 to 40. Count as a CR or area Level.
// iNumber is the number of items to be rolled.
// iItemType = BASE_ITEM_* of the type needed. See new top of script for new BASE_ITEM_*.
// oPC is the PC's luck we will be using.
// If only one item is rolled it will return that item.
object RollMagicItems(object oContainer, int iLevel, int iNumber = 1, int iItemBaseType = BASE_ITEM_INVALID, object oPC = OBJECT_INVALID, int bQuestItem = FALSE, int bMaxNumOfPowers = FALSE);

// Adds properties to an item based on the prop_table.2da file.
// oItem is the item to add the property to.
// iLevel is the CR or area level passed to the treasure scripts.
// iRow is the row to use on the master property table.
// iCrafting defines weather we randomly roll or use ilevel.
// oPC is the PC's luck we will be using in the rolls.
// Returns true if the item was enchanted.
int EnchantItem(object oItem, int iLevel, int iRow, int iCrafting = FALSE, object oPC = OBJECT_INVALID);

// Checks to see if the name has already been changed. If not then changes it.
// oItem is the item to change.
// sNewName is the FULL name to change to.
// iCrafting tells the system to change the name every time.
void SetMagicItemName(object oItem, string sNewName, int iCrafting = FALSE);

// Rolls scrolls of a specific level.
// oPC is the object to give them to.
// iNumber is the number of scrolls to roll.
// iType is the type of scrolls to roll (0 - Arcane, 1 - Divine, 2 - Both)
// iLevel is the spell level of the scrolls.
void RollMagicScrolls(object oPC, int iNumber, int iType, int iLevel, object oPC = OBJECT_INVALID);

// Gives creature magical gear based on level.
// oCreature is the creature getting gear.
// iLevel is the level of the magical items rolled.
// iPackage is the package used by the creature, if INVALID then uses default.
void GiveMagicalEquipment(object oCreature, int iLevel, int bDroppable = TRUE, int iPackage = PACKAGE_INVALID);

void GenerateLightOnItem(object oItem, int nQuality);

// Randomizes magic items and places them in oContainer.
// oContainer is the object to place the items in.
// iLevel is the level of the roll; From 1 to 40. Count as a CR or area Level.
// iNumber is the number of items to be rolled.
// iItemType = BASE_ITEM_* of the type needed. See new top of script for new BASE_ITEM_*.
// oPC is the PC's luck we will be using.
// If only one item is rolled it will return that item.
object RollMagicItems (object oContainer, int iLevel, int iNumber = 1, int iItemBaseType = BASE_ITEM_INVALID, object oPC = OBJECT_INVALID, int bQuestItem = FALSE, int bMaxNumOfPowers = FALSE)
{
    int iCount, iFailSafe, iMaxRow, iRow, iNumOfProperties, iResRefIndex, iMaxQuality, iItemType;
    int iCasterLevel, iSpellLevel, iSet, iPowerLevel, iValue, iMinLevel, iTotalItems, iTreasureSlider;
    int iRoll;
    string sResRef, sProperty2DAFile, s2DAItemTable, sIsTable, sNameColor;
    object oItem, oItem2, oArea;
    object oModule = GetModule();
    itemproperty ipProperty;
    // Get the Building container.
    object oBuildContainer = GetObjectByTag (TEMP_CHEST);
    // Lock the number of items generated.
    iTotalItems = iNumber;
    //Debug ("0i_magicitems", "100", "oContainer: " + GetName (oContainer));
    //Debug ("0i_magicitems", "101", "Number of Magic Items: " + IntToString (iNumber));
    //Debug ("0i_magicitems", "102", " iItemBaseType: " + IntToString (iItemBaseType));
    // Roll for the number of magic items passed (iNumber).
    while (iNumber > 0)
    {
        iResRefIndex = 0;
        // Roll chance of a unique item, stores cannot roll unique items!
        if(!bQuestItem && GetObjectType(oContainer) != OBJECT_TYPE_STORE &&
           d100() <= GetLocalInt(GetModule(), "0_UNIQUE_CHANCE"))
        {
            s2DAItemTable = "special_pallet";
            // Roll on the special pallet chart.
            iRow = RollOn2daTableWithMinItems (s2DAItemTable, iLevel);
            // Get its ResRef of the item.
            sResRef = Get2DAString (s2DAItemTable, "ResRef", iRow);
        }
        // Check to see if they have passed a BASE_ITEM_*.
        // If not then get a random item from the magic item tables.
        else if (iItemBaseType == BASE_ITEM_INVALID)
        {
            // Roll on the Base Magic Item Chart for the base item type.
            iRow = RollOn2daTableWithMinItems (BASE_MAGIC_ITEM_2DA_FILE, iLevel);
            // Get the next 2da File to randomly roll for the ResRef of the item.
            s2DAItemTable = Get2DAString (BASE_MAGIC_ITEM_2DA_FILE, "ItemTable", iRow);
            // Get the full Resref of the base item to create.
            // Roll on the item chart.
            iRow = RollOn2daTableWithMinItems (s2DAItemTable, iLevel);
            // Get its ResRef of the item.
            sResRef = Get2DAString (s2DAItemTable, "ResRef", iRow);
            // Get the ResRefindex of the item.
            iResRefIndex = StringToInt (Get2DAString (s2DAItemTable, "ResRefIndex", iRow));
        }
        // Get the specific magic item based on iItemType.
        else
        {
            iItemType = iItemBaseType;
            // Set the Row and table so we can roll for a property
            s2DAItemTable = "smi_list";
            iRow = iItemType;
            // Look at the 2da file associated with specific magic items. smi_list
            // Check to see if its a table or a specific item.
            if (StringToInt (Get2DAString ("smi_list", "IsTable", iItemType)))
            {
                s2DAItemTable = Get2DAString ("smi_list", "TableName", iItemType);
                // Get the full Resref of the base item to create.
                // Roll on the item chart.
                iRow = RollOn2daTableWithMinItems (s2DAItemTable, iLevel);
                // Get the ResRefindex of the item.
                iResRefIndex = StringToInt (Get2DAString (s2DAItemTable, "ResRefIndex", iRow));
                // Check to see if we need to reroll on another table.
                if (iResRefIndex == -1)
                {
                   // Roll on New table defined in the ResRef field.
                   s2DAItemTable = Get2DAString (s2DAItemTable, "ResRef", iRow);
                   iRow = RollOn2daTableWithMinItems (s2DAItemTable, iLevel);
                   // Get the new ResRefindex of the item.
                   iResRefIndex = StringToInt (Get2DAString (s2DAItemTable, "ResRefIndex", iRow));
                }
                // Get its ResRef of the item.
                sResRef = Get2DAString (s2DAItemTable, "ResRef", iRow);

            }
            else
            {
                sResRef = Get2DAString ("smi_list", "ResRef", iItemType);
                iResRefIndex = StringToInt (Get2DAString ("smi_list", "ResRefIndex", iItemType));
            }
        }
        // Build the base item.
        if (iResRefIndex > 0) sResRef = sResRef + "_" + IntToString (Random (iResRefIndex) + 1);
        //Debug ("0i_magicitems", "162", "ResRef: " + sResRef);
        // Create the object.
        oItem = CreateItemOnObject (sResRef, oBuildContainer);
        // Get the items base type.
        iItemType = GetBaseItemType (oItem);
        // Check for an error.
        if (!GetIsObjectValid (oItem)) SetModuleError ("RESREF", "0i_magicitems", "176", s2DAItemTable + " 2da file has invalid resref: " + sResRef + " on row " + IntToString (iRow));
        // Check to see if its ammo. If so then give a random amount.
        if (GetIsAmmo (oItem)) SetItemStackSize (oItem, RandomLuckRoll  (oPC, 50) + 50);
        else if (GetIsThrownWeapon (oItem)) SetItemStackSize (oItem, d20LuckRoll (oPC) + 30);
        // Now flag the item with who created it.
        if (!GetIsItemStackable (oItem)) SetLocalString (oItem, "0_Creator", StripColorCodes (GetName (oContainer)));
        // Get the 2da that lists the Property table for this item.
        sProperty2DAFile = Get2DAString (s2DAItemTable, "PropertyTable", iRow);
        //Debug ("0i_magicitems", "179", "ItemTable2DAFile: " + s2DAItemTable);
        if (sProperty2DAFile != "")
        {
            // Does this item get maximum number of powers?
            if (GetLocalInt (oContainer, "0_MaxNumOfPowers") || bMaxNumOfPowers)
            {
                //Debug ("0i_magicitems", "180", " Maximum Number of Powers given!");
                SetLocalInt (oContainer, "0_MaxNumOfPowers", FALSE);
                iRoll = 100;
            }
            else
            {
                iTreasureSlider = GetLocalInt (GetModule (), "0_TREASURE_SLIDER");
                // Roll for the number of properties the item can have.
                iRoll = d100LuckRoll(oPC) + iTreasureSlider;
            }
            // 4 powered item is straight 5%.
            iMaxQuality = iLevel / 6 + 1;
            if (iLevel > 19 && iRoll == 100)
            {
                iNumOfProperties = 5;
                iMaxQuality = 5;
            }
            if (iLevel >= 18 && iRoll > 94) iNumOfProperties = 4;
            // 3 powered item is level of item / 2 [6% to 10%];
            else if (iLevel >= 12 && iRoll >= 100 - iLevel / 2) iNumOfProperties = 3;
            // 2 powered item is level of the item  [7% to 20%];
            else if (iLevel >= 6 && iRoll >= 100 - iLevel) iNumOfProperties = 2;
            else iNumOfProperties = 1;
            // Add the quality to the item.
            // See if the items quality is better than the number of properties on the item.
            iMaxQuality = Random (iMaxQuality - iNumOfProperties + 1) + iNumOfProperties;
            // Change items appearance.
            oItem2 = ChangeItemAppearance (oItem, iMaxQuality);
            // Copy final item to container.
            oItem = CopyItem (oItem2, oContainer, TRUE);
            // Destroy Buildcontainer copy.
            DestroyObject (oItem2);
            ipProperty = ItemPropertyQuality (iMaxQuality);
            AddItemProperty (DURATION_TYPE_PERMANENT, ipProperty, oItem);
            // Set the number of properties on the item so we know when
            // to build the name of the item.
            SetLocalInt (oItem, "0_NumOfProperties", iNumOfProperties);
            // Set the items powerlevel so we can reduce based on multiple properties.
            iPowerLevel = iLevel;
            // Reduce each power added by this value that is reduce at higher levels.
            int nReduction;
            if(iLevel > 29 && iLevel < 35) nReduction = 1;
            else if(iLevel > 24) nReduction = 2;
            else if(iLevel > 21) nReduction = 3;
            else nReduction = 4;
            // Set the failsafe.
            iFailSafe = 0;
            // Now roll properties until we have the max properties for this item.
            while (iNumOfProperties > 0 && iFailSafe < 10)
            {
                iRow = RollOn2daTableWithMinItems (sProperty2DAFile, iPowerLevel);
                // Get the row on the master property_table we are adding.
                iRow = StringToInt (Get2DAString (sProperty2DAFile, "Property", iRow));
                iSet = EnchantItem (oItem, iPowerLevel, iRow, FALSE, oPC);
                if (iSet)
                {
                    iPowerLevel = iPowerLevel - nReduction;
                    if (iPowerLevel < 1) iPowerLevel = 1;
                    iNumOfProperties --;
                }
                else iFailSafe ++;
            }
            // Now check to see if the item has light 20% chance.
            if (d100() > 79)
            {
                if (iItemType == BASE_ITEM_RING
                 || iItemType == BASE_ITEM_ARMOR
                 || iItemType == BASE_ITEM_SMALLSHIELD
                 || iItemType == BASE_ITEM_LARGESHIELD
                 || iItemType == BASE_ITEM_TOWERSHIELD
                 || GetIsWeapon (oItem)) GenerateLightOnItem (oItem, iMaxQuality);
            }
        }
        // This is a pallet item so lets color the name
        // Also give caster level to potions, wands, and scrolls.
        // based upon the 2da file.
        else
        {
            // Get the color of the pallet item.
            sNameColor = Get2DAString (s2DAItemTable, "Name_Color", iRow);
            // Identify the item.
            SetIdentified (oItem, TRUE);
            // Check for potions and wands.
            if (iItemType == BASE_ITEM_POTIONS ||
                iItemType == BASE_ITEM_MAGICWAND ||
                iItemType == BASE_ITEM_SPELLSCROLL)
            {
                // Generate the items caster level to used instead of the creatures level.
                // Get the spell level of the item.
                iSpellLevel = StringToInt (Get2DAString (s2DAItemTable, "spell_level", iRow));
                // Get minimum caster level.
                iMinLevel = iSpellLevel + iSpellLevel - 1;
                // All stores get minimum caster level items.
                if (GetObjectType (oContainer) == OBJECT_TYPE_STORE) iCasterLevel = iMinLevel;
                // Roll between the minimum caster level and the optimal level (Highest level thats good for the spell).
                else
                {
                    // Get the optimal level for a spell, the highest level of effect.
                    iPowerLevel = StringToInt (Get2DAString (s2DAItemTable, "optimal_level", iRow));
                    // Randomize the caster level for the Item.
                    iCasterLevel = RandomLuckRoll (oPC, iLevel);
                    // Make sure the iCasterLevel is no less than the minimum level.
                    if (iCasterLevel < iMinLevel) iCasterLevel = iMinLevel;
                    // Make sure iCasterLevel is no higher than the optimal level.
                    if (iCasterLevel > iPowerLevel) iCasterLevel = iPowerLevel;
                }
                // Save the caster level to the item.
                SetLocalInt (oItem, "0_Caster_Level", iCasterLevel);
                // Set a new tag so only same level items stack.
                //SetTag (oItem, GetTag (oItem));
                // Set the name of the potion, wand, or scroll.
                SetName (oItem, AddColorToText (GetName (oItem, TRUE) + " (" + IntToString (iCasterLevel) + ")", sNameColor));
            }
            // Set other item names items name.
            else SetName (oItem, AddColorToText (GetName (oItem, TRUE), sNameColor));
            // Copy the item to the container.
            CopyItem (oItem, oContainer, TRUE);
            // Destroy Buildcontainer copy.
            DestroyObject (oItem);
        }
        iNumber --;
    }
    // Returns the item only if one was generated.
    if (iTotalItems == 1) return oItem;
    else return OBJECT_INVALID;
}


// Adds properties to an item based on the prop_table.2da file.
// oItem is the item to add the property to.
// iLevel is the CR or area level passed to the treasure scripts.
// iRow is the row to use on the master property table.
// iCrafting defines weather we randomly roll or use ilevel.
// oPC is the PC we will be using the luck of for rolls.
// Returns true if the item was enchanted.
int EnchantItem(object oItem, int iLevel, int iRow, int iCrafting = FALSE, object oPC = OBJECT_INVALID)
{
    int iType, iSubType, iModifier = 0, iSubModifier, iProperty, iSet, iRow2;
    string sTypeName, sModName, s2DAModFile, sETypeName, sEModName;
    itemproperty ipProperty;
    // Get the property we are using.
    string sProperty = Get2DAString (PROPERTY_LIST_2DA_FILE, "Property", iRow);
    iProperty = StringToInt (sProperty);
    // Check to see if this property has a maximum level.
    int iMaxLevel = StringToInt (Get2DAString (PROPERTY_LIST_2DA_FILE, "MaxLevel", iRow));
    if (iMaxLevel > 0 && iMaxLevel < iLevel) iLevel = iMaxLevel;
    //Debug ("0i_magicitems", "233", GetName (oItem) + " Property:" +
    //       sProperty + " Level:" + IntToString (iLevel) +
    //       " Row:" + IntToString (iRow));
    switch (iProperty)
    {
        case 1 : // Ability Score increase.
        {
            // Get any Type and TypeName from the main property list.
            iType = StringToInt (Get2DAString (PROPERTY_LIST_2DA_FILE, "Type", iRow));
            sTypeName = Get2DAString (PROPERTY_LIST_2DA_FILE, "TypeName", iRow);
            // Get the 2da file that holds the modifiers.
            s2DAModFile = Get2DAString (PROPERTY_LIST_2DA_FILE, "ModifierTable", iRow);
            // Roll for the modifier.
            if (iCrafting)
            {
                sETypeName = Get2DAString (PROPERTY_LIST_2DA_FILE, "Enchant_Name", iRow);
                iRow = iLevel;
            }
            else iRow = RandomLuckRoll (oPC, iLevel);
            iModifier = StringToInt (Get2DAString (s2DAModFile, "Modifier", iRow));
            // Generate the Ability Score property on the item.
            iSet = IP_ABBonus (oItem, iType, iModifier);
            // Set Name: ItemName + " of " + sName + " +" + Modifier (Headband of Intellect +2).
            if (iSet)
            {
                SetMagicItemName (oItem, GetName (oItem, TRUE) + " of " + sTypeName + " + " + IntToString (iModifier), iCrafting);
                // Set the token to tell what ability the item is getting.
                if (iCrafting) SetCustomToken (304, "+" + IntToString (iModifier) + " " + sETypeName);
            }
            break;
        }
        case 2 : // Armor Class Bonus
        {
            // Get the TypeName from the main property list.
            sTypeName = Get2DAString (PROPERTY_LIST_2DA_FILE, "TypeName", iRow);
            // Get the 2da file that holds the modifiers.
            s2DAModFile = Get2DAString (PROPERTY_LIST_2DA_FILE, "ModifierTable", iRow);
            // Roll for the modifier.
            if (iCrafting)
            {
                sETypeName = Get2DAString (PROPERTY_LIST_2DA_FILE, "Enchant_Name", iRow);
                iRow = iLevel;
            }
            else
            {
                iRow = RandomLuckRoll (oPC, iLevel);
                // Check to see if this item has either an alignment or racial bonus.
                ipProperty = HasProperty (oItem, 2);
                if (GetIsItemPropertyValid (ipProperty)) iModifier = GetItemPropertyCostTableValue (ipProperty) - 2;
                ipProperty = HasProperty (oItem, 4);
                if (GetIsItemPropertyValid (ipProperty)) iModifier = GetItemPropertyCostTableValue (ipProperty) - 2;
            }
            // We have not set a modifier yet so randomize it.
            if (iModifier == 0) iModifier = StringToInt (Get2DAString (s2DAModFile, "Modifier", iRow));
            // Generate the AC property on the item.
            iSet = IP_ACBonus (oItem, iModifier);
            // Set Name (sTypeName = ""): "+" + Modifier + " " + ItemName (+2 Chain shirt).
            // Set Name (sTypeName = "Armor"): ItemName + " of " + sTypeName + " +" + Modifier (Bracers of Armor +2).
            if (iSet)
            {
                if (sTypeName == "") SetMagicItemName (oItem, "+" + IntToString (iModifier) + " " + GetName (oItem, TRUE));
                else SetMagicItemName (oItem, GetName (oItem, TRUE) + " of " + sTypeName + " + " + IntToString (iModifier), iCrafting);
                if (iCrafting) SetCustomToken (304, "+" + IntToString (iModifier) + " " + sETypeName);
            }
            break;
        }
        case 3 : // Armor Class Bonus vs Alignment Groups
        {
            // Get the Type and TypeName from the main property list.
            iType = StringToInt (Get2DAString (PROPERTY_LIST_2DA_FILE, "Type", iRow));
            sTypeName = Get2DAString (PROPERTY_LIST_2DA_FILE, "TypeName", iRow);
            // Get the 2da file that holds the modifiers.
            s2DAModFile = Get2DAString (PROPERTY_LIST_2DA_FILE, "ModifierTable", iRow);
            // Roll for the modifier.
            if (iCrafting)
            {
                sETypeName = Get2DAString (PROPERTY_LIST_2DA_FILE, "Enchant_Name", iRow);
                iRow = iLevel;
            }
            else
            {
                iRow = RandomLuckRoll (oPC, iLevel);
                // Check to see if this item has either an alignment or racial bonus.
                ipProperty = HasProperty (oItem, 1);
                if (GetIsItemPropertyValid (ipProperty)) iModifier = GetItemPropertyCostTableValue (ipProperty) + 2;
                ipProperty = HasProperty (oItem, 2);
                if (GetIsItemPropertyValid (ipProperty)) iModifier = GetItemPropertyCostTableValue (ipProperty);
                ipProperty = HasProperty (oItem, 4);
                if (GetIsItemPropertyValid (ipProperty)) iModifier = GetItemPropertyCostTableValue (ipProperty);
            }
            // We have not set a modifier yet so randomize it.
            if (iModifier == 0) iModifier = StringToInt (Get2DAString (s2DAModFile, "Modifier", iRow));
            // Generate the AC property on the item.
            iSet = IP_ACBonusVsAlign (oItem, iType, iModifier);
            // Set Name: " +" + Modifier + " " + TypeName + " " + ItemName (+ 3 Unholy Chain Shirt).
            if (iSet)
            {
                SetMagicItemName (oItem, " +" + IntToString (iModifier) + " " + sTypeName + " " + GetName (oItem, TRUE), iCrafting);
                if (iCrafting) SetCustomToken (304, "+" + IntToString (iModifier) + " " + sETypeName);
            }
            break;
        }
        case 4 : // Armor Class Bonus vs Race
        {
            // Get the Type and TypeName from the main property list.
            iType = StringToInt (Get2DAString (PROPERTY_LIST_2DA_FILE, "Type", iRow));
            sTypeName = Get2DAString (PROPERTY_LIST_2DA_FILE, "TypeName", iRow);
            // Get the 2da file that holds the modifiers.
            s2DAModFile = Get2DAString (PROPERTY_LIST_2DA_FILE, "ModifierTable", iRow);
            // Roll for the modifier.
            if (iCrafting)
            {
                sETypeName = Get2DAString (PROPERTY_LIST_2DA_FILE, "Enchant_Name", iRow);
                iRow = iLevel;
            }
            else
            {
                iRow = RandomLuckRoll (oPC, iLevel);
                // Check to see if this item has either an alignment or racial bonus.
                ipProperty = HasProperty (oItem, 1);
                if (GetIsItemPropertyValid (ipProperty)) iModifier = GetItemPropertyCostTableValue (ipProperty) + 2;
                ipProperty = HasProperty (oItem, 2);
                if (GetIsItemPropertyValid (ipProperty)) iModifier = GetItemPropertyCostTableValue (ipProperty);
                ipProperty = HasProperty (oItem, 4);
                if (GetIsItemPropertyValid (ipProperty)) iModifier = GetItemPropertyCostTableValue (ipProperty);
            }
            // We have not set a modifier yet so randomize it.
            if (iModifier == 0) iModifier = StringToInt (Get2DAString (s2DAModFile, "Modifier", iRow));
            // Generate the AC property on the item.
            iSet = IP_ACBonusVsRace (oItem, iType, iModifier);
            // Set Name: " +" + Modifier + " " + ItemName + " vs " + TypeName (+3 Chain Shirt vs Dragons).
            if (iSet)
            {
                SetMagicItemName (oItem, " +" + IntToString (iModifier) + " " + GetName (oItem, TRUE) + " vs " + sTypeName, iCrafting);
                if (iCrafting) SetCustomToken (304, "+" + IntToString (iModifier) + " " + sETypeName);
            }
            break;
        }
        //case 5 : IP_ACBonusVsSAlign (oItem, iType, iModifier) break;
        case 6 : // Arcane Spell Failure reduction.
        {
            // Get the TypeName from the main property list.
            sTypeName = Get2DAString (PROPERTY_LIST_2DA_FILE, "TypeName", iRow);
            // Get the 2da file that holds the modifiers.
            s2DAModFile = Get2DAString (PROPERTY_LIST_2DA_FILE, "ModifierTable", iRow);
            // Roll for the modifier.
            if (iCrafting)
            {
                sETypeName = Get2DAString (PROPERTY_LIST_2DA_FILE, "Enchant_Name", iRow);
                iRow = iLevel;
            }
            else iRow = RandomLuckRoll (oPC, iLevel);
            iModifier = StringToInt (Get2DAString (s2DAModFile, "Modifier", iRow));
            sModName = Get2DAString (s2DAModFile, "Name", iRow);
            // Generate the Arcane Spell Failure property on the item.
            iSet = IP_ArcaneSpellFailure (oItem, iModifier);
            // Set Name : sModName + " " + sTypeName + " " + ItemName (Greater Casters Chain Shirt).
            if (iSet)
            {
                SetMagicItemName (oItem, sModName + " " + sTypeName + " " + GetName (oItem, TRUE), iCrafting);
                if (iCrafting)
                {
                    sEModName = Get2DAString (s2DAModFile, "Enchant_Name", iRow);
                    SetCustomToken (304, sEModName + " " + sETypeName);
                }
            }
            break;
        }
        case 7 : // Attack Bonus
        {
            // Get the TypeName from the main property list.
            sTypeName = Get2DAString (PROPERTY_LIST_2DA_FILE, "TypeName", iRow);
            // Get the 2da file that holds the modifiers.
            s2DAModFile = Get2DAString (PROPERTY_LIST_2DA_FILE, "ModifierTable", iRow);
            // Roll for the modifier.
            if (iCrafting) iRow = iLevel;
            else iRow = RandomLuckRoll (oPC, iLevel);
            iModifier = StringToInt (Get2DAString (s2DAModFile, "Modifier", iRow));
            // Generate the AC property on the item.
            iSet = IP_AttackBonus (oItem, iModifier);
            // Set Name = "Masterwork" : "Masterwork " + ItemName (Masterwork Longsword).
            // Set Name : " +" + Modifier + " " + sTypeName + " " + ItemName ( +1 Attacking Longsword).
            if (iSet)
            {
                if (sTypeName == "Masterwork") SetName (oItem, "Masterwork " + GetName (oItem, TRUE));
                else SetMagicItemName (oItem,  "+" + IntToString (iModifier) + " " + GetName (oItem, TRUE) + " " + sTypeName, iCrafting);
            }
            break;
        }
        //case 8 : IP_AttackBonusVsAlign (oItem, iType, iModifier); break;
        //case 9 : IP_AttackBonusVsRace (oItem, iType, iModifier); break;
        //case 10 : IP_AttackBonusVsSAlign (oItem, iType, iModifier); break;
        //case 11 : IP_AttackPenalty (oItem, iModifier); break;
        case 12 : // Bonus Feats
        {
            // Get the Type and TypeName from the main property list.
            iType = StringToInt (Get2DAString (PROPERTY_LIST_2DA_FILE, "Type", iRow));
            sTypeName = Get2DAString (PROPERTY_LIST_2DA_FILE, "TypeName", iRow);
            // Generate the Feat property on the item.
            iSet = IP_BonusFeat (oItem, iType);
            // Set Name : ItemName + " of " + sTypeName (Longsword of Cleaving).
            if (iSet)
            {
                SetMagicItemName (oItem, GetName (oItem, TRUE) + " of " + sTypeName, iCrafting);
                if (iCrafting)
                {
                    sETypeName = Get2DAString (PROPERTY_LIST_2DA_FILE, "Enchant_Name", iRow);
                    SetCustomToken (304, sETypeName);
                }
            }
            break;
        }
        /*case 13 : // Bonus Hitpoints
        {
            // Get the TypeName from the main property list.
            sTypeName = Get2DAString (PROPERTY_LIST_2DA_FILE, "TypeName", iRow);
            // Get the 2da file that holds the modifiers.
            s2DAModFile = Get2DAString (PROPERTY_LIST_2DA_FILE, "ModifierTable", iRow);
            // Roll for the modifier.
            if (iCrafting) iRow = iLevel;
            else iRow = RandomLuckRoll (oPC, iLevel);
            iModifier = StringToInt (Get2DAString (s2DAModFile, "Modifier", iRow));
            // Generate the HP property on the item.
            iSet = IP_BonusHP (oItem, iModifier);
            // Set Name : ItemName + " of " + sTypeName + " +" + Modifier (Belt of Vitality +2).
            if (iSet)
            {
                int iHP;
                if (iModifier < 21) iHP = iModifier;
                else iHP = (iModifier - 20) * 5;
                SetMagicItemName (oItem, GetName (oItem, TRUE) + " " + sTypeName + " +" + IntToString (iHP));
            }
            else SetModuleError  ("Property", "0i_magicitems", "540", GetName (oItem) +
                 ": Property: " + IntToString (iProperty) +
                 " Modifier: " + IntToString (iModifier));
            break;
        } */
        case 14 : // Bonus Spell Levels
        {
            // Get the Type and TypeName from the main property list.
            iType = StringToInt (Get2DAString (PROPERTY_LIST_2DA_FILE, "Type", iRow));
            sTypeName = Get2DAString (PROPERTY_LIST_2DA_FILE, "TypeName", iRow);
            // Get the 2da file that holds the modifiers.
            s2DAModFile = Get2DAString (PROPERTY_LIST_2DA_FILE, "ModifierTable", iRow);
            // Roll for the modifier.
            if (iCrafting)
            {
                sETypeName = Get2DAString (PROPERTY_LIST_2DA_FILE, "Enchant_Name", iRow);
                iRow = iLevel;
            }
            else iRow = RandomLuckRoll (oPC, iLevel);
            iModifier = StringToInt (Get2DAString (s2DAModFile, "Modifier", iRow));
            sModName = Get2DAString (s2DAModFile, "Name", iRow);
            // Generate the Bonus Spell levels property on the item.
            iSet = IP_BonusSpellLevel (oItem, iType, iModifier);
            // Set Name ItemName + " of " + sTypeName + " " + sModName (Ring of Wizardry (IV)).
            if (iSet)
            {
                SetMagicItemName (oItem, GetName (oItem, TRUE) + " of " + sTypeName + " " + sModName, iCrafting);
                if (iCrafting)
                {
                    sEModName = Get2DAString (s2DAModFile, "Enchant_Name", iRow);
                    SetCustomToken (304, sEModName + " " + sETypeName);
                }
            }
            break;
        }
        case 15 : // Saving Throw bonuses
        {
            // Get the Type and TypeName from the main property list.
            iType = StringToInt (Get2DAString (PROPERTY_LIST_2DA_FILE, "Type", iRow));
            sTypeName = Get2DAString (PROPERTY_LIST_2DA_FILE, "TypeName", iRow);
            // Get the 2da file that holds the modifiers.
            s2DAModFile = Get2DAString (PROPERTY_LIST_2DA_FILE, "ModifierTable", iRow);
            // Roll for the modifier.
            if (iCrafting)
            {
                sETypeName = Get2DAString (PROPERTY_LIST_2DA_FILE, "Enchant_Name", iRow);
                iRow = iLevel;
            }
            else iRow = RandomLuckRoll (oPC, iLevel);
            iModifier = StringToInt (Get2DAString (s2DAModFile, "Modifier", iRow));
            // Generate the Savingthrow bonus property on the item.
            iSet = IP_BonusSavingThrow (oItem, iType, iModifier);
            // Set Name ItemName + " of " + sTypeName + " +" + Modifier (Boots of Reflexes +2).
            if (iSet)
            {
                SetMagicItemName (oItem, GetName (oItem, TRUE) + " of " + sTypeName + " +" + IntToString (iModifier), iCrafting);
                if (iCrafting) SetCustomToken (304, "+" + IntToString (iModifier) + " " + sETypeName);
            }
            break;
        }
        case 16 : // Saving Throw specific bonuses
        {
            // Get the Type and TypeName from the main property list.
            iType = StringToInt (Get2DAString (PROPERTY_LIST_2DA_FILE, "Type", iRow));
            sTypeName = Get2DAString (PROPERTY_LIST_2DA_FILE, "TypeName", iRow);
            // Get the 2da file that holds the modifiers.
            s2DAModFile = Get2DAString (PROPERTY_LIST_2DA_FILE, "ModifierTable", iRow);
            // Roll for the modifier.
            if (iCrafting)
            {
                sETypeName = Get2DAString (PROPERTY_LIST_2DA_FILE, "Enchant_Name", iRow);
                iRow = iLevel;
            }
            else iRow = RandomLuckRoll (oPC, iLevel);
            iModifier = StringToInt (Get2DAString (s2DAModFile, "Modifier", iRow));
            sModName = Get2DAString (s2DAModFile, "Name", iRow);
            // Generate the Savingthrow specific bonus property on the item.
            iSet = IP_BonusSavingThrowVsX (oItem, iType, iModifier);
            // Set Name ItemName + " of " + sTypeName + " +" + Modifier (Cloak of Resistance +2).
            if (iSet)
            {
                SetMagicItemName (oItem, GetName (oItem, TRUE) + " of " + sTypeName + " +" + IntToString (iModifier), iCrafting);
                if (iCrafting) SetCustomToken (304, "+" + IntToString (iModifier) + " " + sETypeName);
            }
            break;
        }
        case 17 : // Spell resistance
        {
            // Get the 2da file that holds the modifiers.
            s2DAModFile = Get2DAString (PROPERTY_LIST_2DA_FILE, "ModifierTable", iRow);
            // Roll for the modifier.
            if (iCrafting)
            {
                sETypeName = Get2DAString (PROPERTY_LIST_2DA_FILE, "Enchant_Name", iRow);
                iRow = iLevel;
            }
            else iRow = RandomLuckRoll (oPC, iLevel);
            iModifier = StringToInt (Get2DAString (s2DAModFile, "Modifier", iRow));
            sModName = Get2DAString (s2DAModFile, "Enchant_Name", iRow);
            // Generate the Spell resistance bonus property on the item.
            iSet = IP_BonusSpellResistance (oItem, iModifier);
            // Set Name ItemName + " of Spell resistance (" + ModName + ")" (Chain shirt of Spell resistance (12)).
            if (iSet)
            {
                SetMagicItemName (oItem, GetName (oItem, TRUE) + " " + "of Spell resistance (" + sModName + ")", iCrafting);
                if (iCrafting)
                {
                    sEModName = Get2DAString (s2DAModFile, "Enchant_Name", iRow);
                    SetCustomToken (304, sEModName + " " + sETypeName);
                }
            }
            break;
        }
        case 18 : // Cast spell from object.
        {
            // Generate spell cast property on the item.
            // Get the 2da file that holds the modifiers.
            s2DAModFile = Get2DAString (PROPERTY_LIST_2DA_FILE, "ModifierTable", iRow);
            // The spell to add is passed via iCrafting.
            if(iCrafting)
            {
                // iType is the spell to be added we get it from iCrafting.
                iType = iCrafting;
                sTypeName = GetStringByStrRef(StringToInt(Get2DAString("spells", "Name", iType)));
                // iModifier is the number of uses, i.e. charges, or per day uses.
                int sLevel = StringToInt(Get2DAString("spells", "Innate", iType));
                if(sLevel == 1) iModifier = 11; // Level 1 spells get 4 uses per day.
                else if(sLevel == 2) iModifier = 10; // Level 2 spells get 3 uses per day.
                else if(sLevel == 3) iModifier = 9; // Level 3 spells get 2 uses per day.
                else if(sLevel == 4) iModifier = 8; // Level 4 spells get 1 use per day.
                else if(sLevel == 5) iModifier = 5; // Level 5 spells use 2 charges per use.
                else iModifier = 3; // Level 6+ spells use 4 charges per use.
                // Now we must get the iprp_spells.2da row for this spell.
                iType = StringToInt(Get2DAString("enchant_table", "iprp_spells", iCrafting));
            }
            else
            {
                iRow = RollOn2daTableWithMinItems (s2DAModFile, iLevel);
                iType = StringToInt (Get2DAString (s2DAModFile, "Modifier", iRow));
                sTypeName = Get2DAString (s2DAModFile, "Name", iRow);
                iModifier = StringToInt (Get2DAString (s2DAModFile, "Num_Of_Uses", iRow));
            }
            // Generate the spell property on the item.
            iSet = IP_CastSpell (oItem, iType, iModifier);
            //Debug ("0i_magicitems", "701", GetName (oItem) + " sTypeName: " + sTypeName);
            // Set Name : ItemName + " of " + sTypeName (Brooch of Shielding).
            if (iSet)
            {
                // Set the number of charges if it needs them to 21.
                // Using an odd number so the last charge is not used.
                // We set the charges at either 2 or 4 only!
                if (iModifier < 7) SetItemCharges (oItem, 21);
                SetMagicItemName (oItem, GetName (oItem, TRUE) + " of " + sTypeName, iType);
                if(iCrafting)
                {
                    sEModName = GetStringByStrRef(StringToInt(Get2DAString("iprp_spells", "Name", iType)));
                    SetCustomToken (304, sEModName + " spell");
                }
            }
            break;
        }

        case 19 : // Reduce container weight (i.e. Bags of holding).
        {
            // Get the 2da file that holds the modifiers.
            s2DAModFile = Get2DAString (PROPERTY_LIST_2DA_FILE, "ModifierTable", iRow);
            // Roll for the modifier.
            if (iCrafting)
            {
                sETypeName = Get2DAString (PROPERTY_LIST_2DA_FILE, "Enchant_Name", iRow);
                iRow = iLevel;
            }
            else iRow = RandomLuckRoll (oPC, iLevel);
            iModifier = StringToInt (Get2DAString (s2DAModFile, "Modifier", iRow));
            sModName = Get2DAString (s2DAModFile, "Enchant_Name", iRow);
            // Generate the Reduced weight bonus property on the item.
            iSet = IP_ContainerReduceWeight (oItem, iModifier);
            // Set Name ItemName + " of Spell resistance (" + ModName + ")" (Chain shirt of Spell resistance (12)).
            if (iSet)
            {
                SetMagicItemName (oItem, GetName (oItem, TRUE) + " of Holding " + sModName, iCrafting);
                if (iCrafting)
                {
                    sEModName = Get2DAString (s2DAModFile, "Enchant_Name", iRow);
                    SetCustomToken (304, sEModName + " " + sETypeName);
                }
            }
            break;
        }
        case 20 : // Damage Bonus
        {
            // Get the Type and TypeName from the main property list.
            iType = StringToInt (Get2DAString (PROPERTY_LIST_2DA_FILE, "Type", iRow));
            sTypeName = Get2DAString (PROPERTY_LIST_2DA_FILE, "TypeName", iRow);
            // Get the 2da file that holds the modifiers.
            s2DAModFile = Get2DAString (PROPERTY_LIST_2DA_FILE, "ModifierTable", iRow);
            // Roll for the modifier.
            if (iCrafting)
            {
                sETypeName = Get2DAString (PROPERTY_LIST_2DA_FILE, "Enchant_Name", iRow);
                iRow = iLevel;
            }
            else iRow = RandomLuckRoll (oPC, iLevel);
            iModifier = StringToInt (Get2DAString (s2DAModFile, "Modifier", iRow));
            sModName = Get2DAString (s2DAModFile, "Name", iRow);
            // Generate the damage bonus property on the item.
            iSet = IP_DamageBonus (oItem, iType, iModifier);
            // Set Name : sModName + " " + sTypeName + " " + ItemName (Grand Flaming Longsword).
            if (iSet)
            {
                SetMagicItemName (oItem, sModName + " " + sTypeName + " " + GetName (oItem, TRUE), iCrafting);
                if (iCrafting)
                {
                    sEModName = Get2DAString (s2DAModFile, "Enchant_Name", iRow);
                    SetCustomToken (304, sEModName + " " + sETypeName);
                }
            }
            break;
        }
        //case 21 : break;
        //case 22 : IP_DamageBonusVsAlign (oItem, iType, iSubType, iModifier); break;
        //case 23 : IP_DamageBonusVsRace (oItem, iType, iSubType, iModifier); break;
        //case 24 : IP_DamageBonusVsSAlign (oItem, iType, iSubType, iModifier); break;
        //case 25 : IP_DamageImmunity (oItem, iType, iModifier); break;
        //case 26 : /*IP_DamagePenalty (oItem, iModifier);  break;
        case 27 : // Damage reduction energy.
        {
            // Get the Type and TypeName from the main property list.
            iType = StringToInt (Get2DAString (PROPERTY_LIST_2DA_FILE, "Type", iRow));
            sTypeName = Get2DAString (PROPERTY_LIST_2DA_FILE, "TypeName", iRow);
            // Get the 2da file that holds the modifiers.
            s2DAModFile = Get2DAString (PROPERTY_LIST_2DA_FILE, "ModifierTable", iRow);
            // Roll for the modifier.
            if (iCrafting)
            {
                sETypeName = Get2DAString (PROPERTY_LIST_2DA_FILE, "Enchant_Name", iRow);
                iRow = iLevel;
            }
            else iRow = RandomLuckRoll (oPC, iLevel);
            iModifier = StringToInt (Get2DAString (s2DAModFile, "Modifier", iRow));
            sModName = Get2DAString (s2DAModFile, "Name", iRow);
            // Generate the damage reduction property on the item.
            iSet = IP_DamageResistance (oItem, iType, iModifier);
            // Set Name : ItemName + sTypeName + " resistance, " + sModName (Chain shirt Fire resistance, Improved).
            if (iSet)
            {
                if (sModName == "") SetMagicItemName (oItem, GetName (oItem, TRUE) + " " + sTypeName + " resistance", iCrafting);
                else SetMagicItemName (oItem, GetName (oItem, TRUE) + " " + sTypeName + " resistance, " + sModName, iCrafting);
                if (iCrafting)
                {
                    sEModName = Get2DAString (s2DAModFile, "Enchant_Name", iRow);
                    SetCustomToken (304, sEModName + " " + sETypeName);
                }
            }
            break;
        }
        //case 28 : /*IP_Darkvision (oItem); break;
        //case 29 : /*IP_DecreaseAB (oItem, iType, iModifier); break;
        //case 30 : /*IP_DecreaseAC (oItem, iType, iModifier); break;
        //case 31 : /*IP_DecreaseSkill (oItem, iType, iModifier); break;
        case 32 : // Enhancement Bonus
        {
            // Get the 2da file that holds the modifiers.
            s2DAModFile = Get2DAString (PROPERTY_LIST_2DA_FILE, "ModifierTable", iRow);
            // Roll for the modifier.
            if (iCrafting)
            {
                sETypeName = Get2DAString (PROPERTY_LIST_2DA_FILE, "Enchant_Name", iRow);
                iRow = iLevel;
            }
            else
            {
                iRow = RandomLuckRoll (oPC, iLevel);
                // Check to see if this item has either an alignment or racial bonus.
                ipProperty = HasProperty (oItem, 8);
                if (GetIsItemPropertyValid (ipProperty)) iModifier = GetItemPropertyCostTableValue (ipProperty) - 2;
            }
            // We have not set a modifier yet so randomize it.
            if (iModifier == 0) iModifier = StringToInt (Get2DAString (s2DAModFile, "Modifier", iRow));
            // Generate enhancement property on the item.
            iSet = IP_Enhancement (oItem, iModifier);
            // Set Name : " +" + Modifier + " " + ItemName (+2 Longsword).
            if (iSet)
            {
                SetMagicItemName (oItem,  "+" + IntToString (iModifier) + " " + GetName (oItem, TRUE), iCrafting);
                if (iCrafting) SetCustomToken (304, "+" + IntToString (iModifier) + " " + sETypeName);
            }
            break;
        }
        // case 33 : IP_EnhancementVsAlign (oItem, iType, iModifier, " of " + sTypeName + " Slaying");
        // case 33 : IP_EnhancementVsRace (oItem, iType, iModifier, " of " + sTypeName + " Slaying");
        //case 35 : IP_EnhancementVsSAlign (oItem, iType, iModifier); break;
        //case 36 : IP_EnhancementPenalty (oItem, iModifier); break;
        case 37 :
        {
            // Generate spell immunity property on the item.
            // Get the 2da file that holds the modifiers.
            s2DAModFile = Get2DAString (PROPERTY_LIST_2DA_FILE, "ModifierTable", iRow);
            // Roll for the modifier. Need to fix Crafting for this property!
            if (iCrafting)
            {
                sETypeName = Get2DAString (PROPERTY_LIST_2DA_FILE, "Enchant_Name", iRow);
                iRow = iLevel;
            }
            else iRow = RollOn2daTableWithMinItems (s2DAModFile, iLevel);
            iType = StringToInt (Get2DAString (s2DAModFile, "Modifier", iRow));
            sTypeName = Get2DAString (s2DAModFile, "Name", iRow);
            // Generate the spell immunity property on the item.
            iSet = IP_ImmunitySpecific (oItem, iType);
            // Set Name : ItemName + " of " + sTypeName (Brooch of Shielding).
            if (iSet)
            {
                SetMagicItemName (oItem, GetName (oItem, TRUE) + " of " + sTypeName, iCrafting);
                if (iCrafting)
                {
                    sEModName = Get2DAString (s2DAModFile, "Enchant_Name", iRow);
                    SetCustomToken (304, sETypeName + " " + sEModName);
                }
            }
                 break;
        }
        case 38 :
        {
            // Generate the keen bonus property on the item.
            iSet = IP_Keen (oItem);
            // Set Name as either Impacting or Keen + ItemName (Keen Longsword).
            if (iSet)
            {
                if (GetIsBludgeoningWeapon (oItem) ) SetMagicItemName (oItem, "Impacting " + GetName (oItem, TRUE));
                else SetMagicItemName (oItem, "Keen " + GetName (oItem, TRUE), iCrafting);
                if (iCrafting)
                {
                    sETypeName = Get2DAString (PROPERTY_LIST_2DA_FILE, "Enchant_Name", iRow);
                    SetCustomToken (304, sETypeName);
                }
            }
            break;
        }
        case 39 : // Sheds Light.
        {
            // Get the Type and TypeName from the main property list.
            iType = StringToInt (Get2DAString (PROPERTY_LIST_2DA_FILE, "Type", iRow));
            sTypeName = Get2DAString (PROPERTY_LIST_2DA_FILE, "TypeName", iRow);
            // Get the 2da file that holds the modifiers.
            s2DAModFile = Get2DAString (PROPERTY_LIST_2DA_FILE, "ModifierTable", iRow);
            // Roll for the modifier.
            if (iCrafting)
            {
                sETypeName = Get2DAString (PROPERTY_LIST_2DA_FILE, "Enchant_Name", iRow);
                iRow = iLevel;
            }
            else iRow = RandomLuckRoll (oPC, iLevel);
            iModifier = StringToInt (Get2DAString (s2DAModFile, "Modifier", iRow));
            sModName = Get2DAString (s2DAModFile, "Name", iRow);
            // Generate the Light bonus property on the item.
            iSet = IP_Light (oItem, iType, iModifier);
            // Set Name : ModName + " " + TypeName + " " + ItemName (Dim Topaz Ring).
            if (iSet)
            {
                SetMagicItemName (oItem, sModName + " " + sTypeName + " " + GetName (oItem, TRUE), iCrafting);
                if (iCrafting)
                {
                    sEModName = Get2DAString (s2DAModFile, "Enchant_Name", iRow);
                    SetCustomToken (304, sEModName + " " + sETypeName);
                }
            }
            break;
        }
        //case 40 : IP_LimitUseByAlign (oItem, iModifier); break;
        //case 41 : IP_LimitUseByClass (oItem, iModifier); break;
        //case 42 : IP_LimitUseByRace (oItem, iModifier); break;
        //case 43 : IP_LimitUseBySAlign (oItem, iModifier); break;
        //case 44 : IP_Mighty (oItem, iModifier); break;
        //case 45 : IP_OnHitCastSpell (oItem, iType, iModifier); break;
        //case 46 : IP_OnHitProps (oItem, iType, iSubType, iModifier); break;
        //case 47 : IP_ReduceSavingThrow (oItem, iType, iModifier); break;
        //case 48 : IP_ReduceSavingThrowVsX (oItem, iType, iModifier); break;
        case 49 : // Regeneration.
        {
            // Get the 2da file that holds the modifiers.
            s2DAModFile = Get2DAString (PROPERTY_LIST_2DA_FILE, "ModifierTable", iRow);
            // Roll for the modifier.
            if (iCrafting)
            {
                sETypeName = Get2DAString (PROPERTY_LIST_2DA_FILE, "Enchant_Name", iRow);
                iRow = iLevel;
            }
            else iRow = RandomLuckRoll (oPC, iLevel);
            iModifier = StringToInt (Get2DAString (s2DAModFile, "Modifier", iRow));
            // Generate the regeneration property on the item.
            iSet = IP_Regeneration(oItem, iModifier);
            // Set Name : ItemName + " of Regeneration +" + Modifier (Ring of Regeneration +2).
            if (iSet)
            {
                SetMagicItemName (oItem, GetName (oItem, TRUE) + " of Regeneration +" + IntToString (iModifier), iCrafting);
                if (iCrafting) SetCustomToken (304, "+" + IntToString (iModifier) + " " + sETypeName);
            }
            break;
        }
        case 50 : // Skill bonus.
        {
            // Get the type and TypeName of the type.
            iType = StringToInt (Get2DAString (PROPERTY_LIST_2DA_FILE, "Type", iRow));
            sTypeName = Get2DAString (PROPERTY_LIST_2DA_FILE, "TypeName", iRow);
            // Get the 2da file that holds the modifiers.
            s2DAModFile = Get2DAString (PROPERTY_LIST_2DA_FILE, "ModifierTable", iRow);
            // Roll for the modifier.
            if (iCrafting)
            {
                sETypeName = Get2DAString (PROPERTY_LIST_2DA_FILE, "Enchant_Name", iRow);
                iRow = iLevel;
            }
            else iRow = RandomLuckRoll (oPC, iLevel);
            iModifier = StringToInt (Get2DAString (s2DAModFile, "Modifier", iRow));
            // Generate the skill bonus property on the item.
            iSet = IP_SkillBonus (oItem, iType, iModifier);
            // Set Name : ItemName + " of " + sTypeName + " +" + Modifier (Chain shirt of Shadows +2).
            if (iSet)
            {
                SetMagicItemName (oItem, GetName (oItem, TRUE) + " of " + sTypeName + " +" + IntToString (iModifier), iCrafting);
                if (iCrafting) SetCustomToken (304, "+" + IntToString (iModifier) + " " + sETypeName);
            }
            break;
        }
        case 51 : // Unlimited ammo.
        {
            // Get the TypeName of the type.
            sTypeName = Get2DAString (PROPERTY_LIST_2DA_FILE, "TypeName", iRow);
            // Get the 2da file that holds the modifiers.
            s2DAModFile = Get2DAString (PROPERTY_LIST_2DA_FILE, "ModifierTable", iRow);
            // Roll for the modifier.
            if (iCrafting)
            {
                sETypeName = Get2DAString (PROPERTY_LIST_2DA_FILE, "Enchant_Name", iRow);
                iRow = iLevel;
            }
            else iRow = RandomLuckRoll (oPC, iLevel);
            iModifier = StringToInt (Get2DAString (s2DAModFile, "Modifier", iRow));
            sModName = Get2DAString (s2DAModFile, "Name", iRow);
            // Generate the Unlimited ammo property on the item.
            iSet = IP_UnlimitedAmmo (oItem, iModifier);
            // Set Name : ItemName + " of " + TypeName + " " + ModName (Longbow of Firing +2).
            if (iSet)
            {
                SetMagicItemName (oItem, GetName (oItem, TRUE) + " of " + sTypeName + " " + sModName, iCrafting);
                if (iCrafting)
                {
                    sEModName = Get2DAString (s2DAModFile, "Enchant_Name", iRow);
                    SetCustomToken (304, sEModName + " " + sETypeName);
                }
            }
            break;
        }
        case 52 : // Vampiric Regeneration
        {
            // Get the TypeName of the type.
            sTypeName = Get2DAString (PROPERTY_LIST_2DA_FILE, "TypeName", iRow);
            // Get the 2da file that holds the modifiers.
            s2DAModFile = Get2DAString (PROPERTY_LIST_2DA_FILE, "ModifierTable", iRow);
            // Roll for the modifier.
            if (iCrafting)
            {
                sETypeName = Get2DAString (PROPERTY_LIST_2DA_FILE, "Enchant_Name", iRow);
                iRow = iLevel;
            }
            else iRow = RandomLuckRoll (oPC, iLevel);
            iModifier = StringToInt (Get2DAString (s2DAModFile, "Modifier", iRow));
            sModName = Get2DAString (s2DAModFile, "Name", iRow);
            // Generate the Vampiric Regeneration property on the item.
            iSet = IP_VampiricRegeneration (oItem, iModifier);
            // Set Name : " +" + Modifier + " " + TypeName + " " + ItemName (+2 Vampiric Longsword).
            if (iSet)
            {
                SetMagicItemName (oItem, "+" + IntToString (iModifier) + " " + sTypeName + " " + GetName (oItem, TRUE), iCrafting);
                if (iCrafting) SetCustomToken (304, "+" + IntToString (iModifier) + " " + sETypeName);
            }
            break;
        }
        //case 53 : IP_VisualEffect (oItem, iType); break;
        //case 54 : IP_WeightIncrease (oItem, iType); break;
        case 55 : // Reduce the weight of armors and shields.
        {
            // Get the TypeName of the type.
            sTypeName = Get2DAString (PROPERTY_LIST_2DA_FILE, "TypeName", iRow);
            // Get the 2da file that holds the modifiers.
            s2DAModFile = Get2DAString (PROPERTY_LIST_2DA_FILE, "ModifierTable", iRow);
            // Roll for the modifier.
            if (iCrafting)
            {
                sETypeName = Get2DAString (PROPERTY_LIST_2DA_FILE, "Enchant_Name", iRow);
                iRow = iLevel;
            }
            else iRow = RandomLuckRoll (oPC, iLevel);
            iModifier = StringToInt (Get2DAString (s2DAModFile, "Modifier", iRow));
            sModName = Get2DAString (s2DAModFile, "Name", iRow);
            // Generate the Weight reduction property on the item.
            iSet = IP_WeightReduction (oItem, iModifier);
            // Set Name : sModName + " " + ItemName (Ethereal Full Plate).
            if (iSet)
            {
                SetMagicItemName (oItem, sModName + " " + GetName (oItem, TRUE), iCrafting);
                if (iCrafting)
                {
                    sEModName = Get2DAString (s2DAModFile, "Enchant_Name", iRow);
                    SetCustomToken (304, sEModName + " " + sETypeName);
                }
            }
            break;
        }
        case 56 : // Aligned weapon based on DMG magic item.
        {
            iType = StringToInt (Get2DAString (PROPERTY_LIST_2DA_FILE, "Type", iRow));
            sTypeName = Get2DAString (PROPERTY_LIST_2DA_FILE, "TypeName", iRow);
            // Get damage type
            iSubType = StringToInt (Get2DAString (PROPERTY_LIST_2DA_FILE, "SubType", iRow));
            // Get the apposing alignment so we can restrict the wielder.
            iSubModifier = StringToInt (Get2DAString (PROPERTY_LIST_2DA_FILE, "SubModifier", iRow));
            // Get the 2da file that holds the modifiers.
            s2DAModFile = Get2DAString (PROPERTY_LIST_2DA_FILE, "ModifierTable", iRow);
            if (iCrafting)
            {
                sETypeName = Get2DAString (PROPERTY_LIST_2DA_FILE, "Enchant_Name", iRow);
                iRow = iLevel;
            }
            else iRow = RandomLuckRoll (oPC, iLevel);
            iModifier = StringToInt (Get2DAString (s2DAModFile, "Modifier", iRow));
            sModName = Get2DAString (s2DAModFile, "Name", iRow);
            // Generate the Bane Alignment properties on the item.
            iSet = IP_BaneAlignment (oItem, iType, iSubType, iModifier, iSubModifier);
            if (iSet)
            {
                SetMagicItemName (oItem, sModName + " " + sTypeName + " " + GetName (oItem, TRUE), iCrafting);
                if (iCrafting)
                {
                    sEModName = Get2DAString (s2DAModFile, "Enchant_Name", iRow);
                    SetCustomToken (304, sEModName + " " + sETypeName);
                }
            }
            break;
        }
        case 57 : // Bane based on DMG magic item.
        {
            iType = StringToInt (Get2DAString (PROPERTY_LIST_2DA_FILE, "Type", iRow));
            sTypeName = Get2DAString (PROPERTY_LIST_2DA_FILE, "TypeName", iRow);
            // Get the Damage Type
            if (GetIsBludgeoningWeapon (oItem)) iSubType = IP_CONST_DAMAGETYPE_BLUDGEONING;
            else if (GetIsSlashingWeapon (oItem)) iSubType = IP_CONST_DAMAGETYPE_SLASHING;
            else iSubType = IP_CONST_DAMAGETYPE_PIERCING;
            // Get the 2da file that holds the modifiers (Enhancement).
            s2DAModFile = Get2DAString (PROPERTY_LIST_2DA_FILE, "ModifierTable", iRow);
            if (iCrafting)
            {
                sETypeName = Get2DAString (PROPERTY_LIST_2DA_FILE, "Enchant_Name", iRow);
                iRow2 = iLevel;
            }
            else
            {
                iRow2 = RandomLuckRoll (oPC, iLevel);
                // Check to see if this item has an enhancement bonus.
                ipProperty = HasProperty (oItem, 6);
                if (GetIsItemPropertyValid (ipProperty)) iRow2 = GetItemPropertyCostTableValue (ipProperty) * 4;
                ipProperty = HasProperty (oItem, 8);
                if (GetIsItemPropertyValid (ipProperty)) iRow2 = GetItemPropertyCostTableValue (ipProperty);
            }
            // We have not set a modifier yet so randomize it.
            iModifier = StringToInt (Get2DAString (s2DAModFile, "Modifier", iRow2));
            // Get the 2da file that holds the submodifiers (Bonus Damage).
            s2DAModFile = Get2DAString (PROPERTY_LIST_2DA_FILE, "SubModifier", iRow);
            iSubModifier = StringToInt (Get2DAString (s2DAModFile, "Modifier", iRow2));
            // Generate the Bane Racial properties on the item.
            iSet = IP_BaneRacial (oItem, iType, iSubType, iModifier, iSubModifier);
            // Set Name : ItemName + " of " + TypeName + " Slaying +" + Modifier (Longsword of Dragon Slaying +3).
            if (iSet)
            {
                SetMagicItemName (oItem, GetName (oItem, TRUE) + " of " + sTypeName + " Slaying +" + IntToString (iModifier), iCrafting);
                if (iCrafting)
                {
                    sEModName = Get2DAString (s2DAModFile, "Enchant_Name", iRow2);
                    SetCustomToken (304,  "+" + IntToString (iModifier) + " " + sEModName + " " + sETypeName);
                }
            }
            break;
        }
        case 58 : // Returning property "Haste".
        {
            // Generate the haste property.
            iSet = IP_Haste (oItem);
            // Set Name : ItemName + " of returning).
            if (iSet)
            {
                SetMagicItemName (oItem, GetName (oItem, TRUE) + " of Speed", iCrafting);
                if (iCrafting)
                {
                    sETypeName = Get2DAString (PROPERTY_LIST_2DA_FILE, "Enchant_Name", iRow);
                    SetCustomToken (304, sETypeName);
                }
            }
            break;
        }
        case 59 : // Damage reduction physical
        {
            // Get the Type and TypeName from the main property list.
            iType = StringToInt (Get2DAString (PROPERTY_LIST_2DA_FILE, "Type", iRow));
            sTypeName = Get2DAString (PROPERTY_LIST_2DA_FILE, "TypeName", iRow);
            // Generate the damage reduction property on the item.
            iSet = IP_DamageResistance (oItem, iType, IP_CONST_DAMAGERESIST_5);
            // Set Name : sTypeName + ItemName (Archer's Belt).
            if (iSet)
            {
                SetMagicItemName (oItem, sTypeName + " " + GetName (oItem, TRUE), iCrafting);
                if (iCrafting)
                {
                    sETypeName = Get2DAString (PROPERTY_LIST_2DA_FILE, "Enchant_Name", iRow);
                    SetCustomToken (304, "5 " + sETypeName);
                }
            }
            break;
        }
        default :
        {
            SetModuleError ("ERROR", "0i_magicitems", "1153", "Magic Item Property Not Found (" +
                            IntToString (iProperty) + ") Item: " + GetName (oItem) + " Property Row: " + IntToString (iRow) + ".");
            break;
        }
    }
    return iSet;
}

// Checks to see if the name has already been changed. If not then changes it.
// oItem is the item to change.
// sNewName is the FULL name to change to.
// iCrafting tells the system to change the name every time.
void SetMagicItemName (object oItem, string sNewName, int iCrafting = FALSE)
{
    int iRoll, iRow, iSetName, iNumOfProperties, iQuality;
    string sPrefix, sSuffix, sItemName, sColor;
    itemproperty ipProperty;
    // Lets get how many times this item has been named, and how many abilities it has.
    iSetName = GetLocalInt (oItem, "0_SetName") + 1;
    // Now set that this item is named.
    SetLocalInt (oItem, "0_SetName", iSetName);
    // Get the number of properties for this item so we can
    // build the name if it is time.
    iNumOfProperties = GetLocalInt (oItem, "0_NumOfProperties");
    // Give it a unique name if its got multiple powers.
    if (iSetName == iNumOfProperties || iCrafting)
    {
        if (iNumOfProperties > 1)
        {
            iRoll = d100();
            // Get a Prefix & Suffix 50% of the time.
            // Get a Prefix name 75% chance.
            if (iRoll <= 75)
            {
                iRow = RollOn2daTable ("names_magic");
                sPrefix = Get2DAString ("names_magic", "prefix", iRow) + " ";
            }
            else sPrefix = "";
            // Get a Suffix name 75% chance.
            if (iRoll >= 25)
            {
                iRow = RollOn2daTable ("names_magic");
                sSuffix = Get2DAString ("names_magic", "suffix", iRow);
            }
            else sSuffix = "";
            // Now get the items correct color based on the number of powers.
            if (iNumOfProperties == 2) sColor = COLOR_EXQUISITE;
            else if (iNumOfProperties == 3) sColor = COLOR_LEGENDARY;
            else if (iNumOfProperties == 4) sColor = COLOR_RELIC;
            else sColor = COLOR_ARTIFACT;
            // Should we use the items base name?
            if (sPrefix == "" || sSuffix == "" || d100() <= 51)
            {
                sItemName = GetName (oItem, TRUE) + " ";
                // add the "of" or "of the" to the Suffix
                // since we are using the baseitem name.
                if (sSuffix != "") sSuffix = Get2DAString ("names_magic", "of_the", iRow) + " " + sSuffix;
            }
            else sItemName = "";
            // Set the name.
            sNewName = AddColorToText (sPrefix + sItemName + sSuffix, sColor);
            // Now clear the variables on the item.
            DeleteLocalInt (oItem, "0_SetName");
            DeleteLocalInt (oItem, "0_NumOfProperties");
        }
        else sNewName = AddColorToText (sNewName, COLOR_MAGIC);
        // Check for ammo and change the tag as well so they will not merge with same appearance ammo.
        if (GetIsAmmo (oItem)) SetTag (oItem, sNewName);
        SetName (oItem, sNewName);
    }
}

// Rolls scrolls of a specific level.
// oContainer is the object to give them to.
// iNumber is the number of scrolls to roll.
// iType is the type of scrolls to roll (0 - Arcane, 1 - Divine, 2 - Both)
// iLevel is the spell level of the scrolls.
void RollMagicScrolls (object oContainer, int iNumber, int iType, int iLevel, object oPC = OBJECT_INVALID)
{
    string sScrollType, sResRef;
    int iMinRoll, iMaxRoll, iCount, iRow;
    object oItem;
    // Get the type of scroll.
    if (iType == 0) sScrollType = "scrolls_table_a";
    else if (iType == 1) sScrollType = "scrolls_table_d";
    else sScrollType = "scrolls_table";
    // Get the levels of the scrolls in the 2da files.
    if (iType == 0) // Arcane
    {
        switch (iLevel)
        {
            case 0 : { iMinRoll = 0; iMaxRoll = 6; break;}
            case 1 : { iMinRoll = 7; iMaxRoll = 28; break;}
            case 2 : { iMinRoll = 29; iMaxRoll = 53; break;}
            case 3 : { iMinRoll = 54; iMaxRoll = 82; break;}
            case 4 : { iMinRoll = 84; iMaxRoll = 106; break;}
            case 5 : { iMinRoll = 107; iMaxRoll = 130; break;}
            case 6 : { iMinRoll = 131; iMaxRoll = 164; break;}
            case 7 : { iMinRoll = 165; iMaxRoll = 178; break;}
            case 8 : { iMinRoll = 179; iMaxRoll = 197; break;}
            case 9 : { iMinRoll = 198; iMaxRoll = 211; break;}
        }
    }
    else if (iType == 1) // Divine
    {
        switch (iLevel)
        {
            case 0 : { iMinRoll = 0; iMaxRoll = 5; break;}
            case 1 : { iMinRoll = 6; iMaxRoll = 22; break;}
            case 2 : { iMinRoll = 23; iMaxRoll = 41; break;}
            case 3 : { iMinRoll = 42; iMaxRoll = 65; break;}
            case 4 : { iMinRoll = 66; iMaxRoll = 80; break;}
            case 5 : { iMinRoll = 81; iMaxRoll = 89; break;}
            case 6 : { iMinRoll = 90; iMaxRoll = 110; break;}
            case 7 : { iMinRoll = 111; iMaxRoll = 121; break;}
            case 8 : { iMinRoll = 122; iMaxRoll = 132; break;}
            case 9 : { iMinRoll = 133; iMaxRoll = 140; break;}
        }
    }
    else // Both
    {
        switch (iLevel)
        {
            case 0 : { iMinRoll = 0; iMaxRoll = 9; break;}
            case 1 : { iMinRoll = 10; iMaxRoll = 47; break;}
            case 2 : { iMinRoll = 48; iMaxRoll = 97; break;}
            case 3 : { iMinRoll = 98; iMaxRoll = 153; break;}
            case 4 : { iMinRoll = 154; iMaxRoll = 194; break;}
            case 5 : { iMinRoll = 195; iMaxRoll = 235; break;}
            case 6 : { iMinRoll = 236; iMaxRoll = 281; break;}
            case 7 : { iMinRoll = 282; iMaxRoll = 307; break;}
            case 8 : { iMinRoll = 308; iMaxRoll = 335; break;}
            case 9 : { iMinRoll = 336; iMaxRoll = 359; break;}
        }
    }
    // Roll the number of scrolls required.
    while (iCount < iNumber)
    {
        // Roll for the scroll row number.
        iRow = RandomLuckRoll (oPC, iMaxRoll) + iMinRoll - 1;
        // Get the ResRef from the 2da file.
        sResRef = Get2DAString (sScrollType, "ResRef", iRow);
        // Create the object.
        oItem = CreateItemOnObject (sResRef, oContainer);
        // Check for an error.
        if (!GetIsObjectValid (oItem)) SetModuleError ("RESREF", "0_inc_magicitems", "1313", sScrollType + " 2da file has invalid resref: " + sResRef);
        iCount ++;
    }
}

// Gives creature magical gear based on level.
// oCreature is the creature getting gear.
// nLevel is the level of the magical items rolled.
// Each time they roll a magic item nLevel is dropped to reduce the chance and
// the power of any magic items past the first one.
// nPackage is the package used by the creature, if INVALID then uses default.
// [Level * 1 (1-20%)]
// [Level * 2 (2-40%)]
// [Level * 3 (3-60%)]
// [Level * 4 (4-80%)]
// [Level * 5 (5-100%)]
void GiveMagicalEquipment (object oCreature, int nLevel, int bDroppable = TRUE, int nPackage = PACKAGE_INVALID)
{
    object oItem, oArmor, oWeapon, oRanged;
    // Generate magical armor.
    if (d100() < nLevel * 3)
    {
        // Give a set of armor; Light any level , Medium > 2nd, Heavy > 4th.
        if (GetHasFeat (FEAT_ARMOR_PROFICIENCY_HEAVY, oCreature) && nLevel > 4) oArmor = RollMagicItems (oCreature, nLevel, 1, 145);
        else if (GetHasFeat (FEAT_ARMOR_PROFICIENCY_MEDIUM, oCreature) && nLevel > 2) oArmor = RollMagicItems (oCreature, nLevel, 1, 144);
        else if (GetHasFeat (FEAT_ARMOR_PROFICIENCY_LIGHT, oCreature)) oArmor = RollMagicItems (oCreature, nLevel, 1, 143);
        else oArmor = RollMagicItems (oCreature, nLevel, 1, 142);
        SetDroppableFlag (oArmor, bDroppable);
    }
    else GiveEquipment (oCreature, FALSE, 16);
    // Generate a weapon.
    if (GetClassByPosition (1, oCreature) != CLASS_TYPE_MONK)
    {
        if (nPackage == PACKAGE_INVALID) nPackage = GetClassByPosition (0, oCreature);
        int nSpecificWeapon;
        string sSpecificWeapon = Get2DAString ("packages", "Weapon", nPackage);
        if (sSpecificWeapon != "")
        {
            nSpecificWeapon = StringToInt (sSpecificWeapon);
            // Give a specific weapon.
            if (nLevel > 0 && (d100() < nLevel * 5))
            {
                // Lets give them a non-magical version incase the magical one cannot be used.
                GiveEquipment (oCreature, FALSE, nSpecificWeapon);
                oWeapon = RollMagicItems (oCreature, nLevel, 1, nSpecificWeapon);
                SetDroppableFlag (oWeapon, bDroppable);
            }
            else oWeapon = GiveEquipment (oCreature, FALSE, nSpecificWeapon);
            // If they got a ranged weapon also make sure they have a melee weapon.
            if (GetIsRangeWeapon (oWeapon)) GiveEquipment (oCreature, FALSE, 133);
        }
        // No specific weapon so lets find them a good weapon.
        else if (nLevel > 0 && (d100() < nLevel * 5))
        {
            // Give a weapon; Simple any, Martial > 2nd, Exotic > 4th.
            // Lets give a basic weapon incase the magic weapon is not usable.
            // Give a normal weapon incase they cannot use the magical one.
            GiveEquipment (oCreature, FALSE, 133);
            if (GetHasFeat (FEAT_WEAPON_PROFICIENCY_EXOTIC, oCreature) && nLevel > 4) oWeapon = RollMagicItems (oCreature, nLevel, 1, 136);
            else if (GetHasFeat (FEAT_WEAPON_PROFICIENCY_MARTIAL, oCreature) && nLevel > 2) oWeapon = RollMagicItems (oCreature, nLevel, 1, 135);
            else if (GetHasFeat (FEAT_WEAPON_PROFICIENCY_SIMPLE, oCreature)) oWeapon = RollMagicItems (oCreature, nLevel, 1, 134);
            else if (GetHasFeat (FEAT_WEAPON_PROFICIENCY_ELF, oCreature)) oWeapon = RollMagicItems (oCreature, nLevel, 1, 1);
            else if (GetHasFeat (FEAT_WEAPON_PROFICIENCY_DRUID, oCreature)) oWeapon = RollMagicItems (oCreature, nLevel, 1, 53);
            else if (GetHasFeat (FEAT_WEAPON_PROFICIENCY_ROGUE, oCreature)) oWeapon = RollMagicItems (oCreature, nLevel, 1, 51);
            else if (GetHasFeat (FEAT_WEAPON_PROFICIENCY_WIZARD, oCreature)) oWeapon = RollMagicItems (oCreature, nLevel, 1, 50);
            //else SetModuleError ("ERROR", "0i_magicitems", "1360", GetName (oCreature) + " does not have a weapon proficiency!");
            SetDroppableFlag (oWeapon, bDroppable);
            if (GetIsRangeWeapon (oWeapon)) GiveAmmoForWeapon (oWeapon, oCreature);
        }
        else GiveEquipment (oCreature, FALSE, 133);
    }
    // Only give a creature of level 3 or higher one of these items.
    // Check for a shield.
    if (nLevel > 2)
    {
        if (nLevel > 0 && (d100() < nLevel * 3))
        {
            if (GetHasFeat (FEAT_SHIELD_PROFICIENCY)) oItem = RollMagicItems (oCreature, nLevel, 1, 140);
            SetDroppableFlag (oItem, bDroppable);
        }
        // Chance for magical ranged weapon.
        if (nLevel > 0 && (d100() < nLevel * 4))
        {
            if (GetHasFeat (FEAT_WEAPON_PROFICIENCY_MARTIAL, oCreature))
            {
                oRanged = RollMagicItems (oCreature, nLevel, 1, 137);
                SetDroppableFlag (oRanged, bDroppable);
                GiveAmmoForWeapon (oRanged, oCreature);
            }
        }
    }
    // Now see if we get any other magic items.
    // Cloak.
    if (nLevel > 0 && (d100() < nLevel * 3))
    {
        oItem = RollMagicItems (oCreature, nLevel, 1, 80);
        SetDroppableFlag (oItem, bDroppable);
    }
    // Boots.
    if (nLevel > 0 && (d100() < nLevel * 3))
    {
        oItem = RollMagicItems (oCreature, nLevel, 1, 26);
        SetDroppableFlag (oItem, bDroppable);
    }
    // Helmet.
    if (nLevel > 0 && (d100() < nLevel * 3))
    {
        oItem = RollMagicItems (oCreature, nLevel, 1, 17);
        SetDroppableFlag (oItem, bDroppable);
    }
    // Ring #1.
    if (nLevel > 0 && (d100() < nLevel * 1))
    {
        oItem = RollMagicItems (oCreature, nLevel, 1, 52);
        SetDroppableFlag (oItem, bDroppable);
    }
    // Gloves.
    if (nLevel > 0 && (d100() < nLevel * 3))
    {
        oItem = RollMagicItems (oCreature, nLevel, 1, 36);
        SetDroppableFlag (oItem, bDroppable);
    }
    // Belt.
    if (nLevel > 0 && (d100() < nLevel * 3))
    {
        oItem = RollMagicItems (oCreature, nLevel, 1, 21);
        SetDroppableFlag (oItem, bDroppable);
    }
    // Amulet.
    if (nLevel > 0 && (d100() < nLevel * 1))
    {
        oItem = RollMagicItems (oCreature, nLevel, 1, 19);
        SetDroppableFlag (oItem, bDroppable);
    }
    // Ring #2.
    if (nLevel > 0 && (d100() < nLevel * 1))
    {
        oItem = RollMagicItems (oCreature, nLevel, 1, 52);
        SetDroppableFlag (oItem, bDroppable);
    }
}

void GenerateLightOnItem (object oItem, int nQuality)
{
    // Brightness is based on quality.
    int nBrightness = nQuality;
    if (nBrightness > 4) nBrightness = 4;
    // Color is based on some factors then random.
    int nColor = 99;
    itemproperty ip = GetFirstItemProperty (oItem);
    while (GetIsItemPropertyValid (ip))
    {
        if (GetItemPropertyType (ip) == ITEM_PROPERTY_DAMAGE_BONUS)
        {
            if (GetItemPropertySubType (ip) == 5/*MAGIC*/) nColor = IP_CONST_LIGHTCOLOR_PURPLE;
            else if (GetItemPropertySubType (ip) == 6/*ACID*/) nColor = IP_CONST_LIGHTCOLOR_GREEN;
            else if (GetItemPropertySubType (ip) == 7/*COLD*/) nColor = IP_CONST_LIGHTCOLOR_BLUE;
            else if (GetItemPropertySubType (ip) == 8/*DIVINE*/) nColor = IP_CONST_LIGHTCOLOR_YELLOW;
            else if (GetItemPropertySubType (ip) == 9/*ELECTRICAL*/) nColor = IP_CONST_LIGHTCOLOR_YELLOW;
            else if (GetItemPropertySubType (ip) == 10/*FIRE*/) nColor = IP_CONST_LIGHTCOLOR_ORANGE;
            else if (GetItemPropertySubType (ip) == 11/*NEGATIVE*/) nColor = IP_CONST_LIGHTCOLOR_RED;
            else if (GetItemPropertySubType (ip) == 12/*POSITIVE*/) nColor = IP_CONST_LIGHTCOLOR_WHITE;
            else if (GetItemPropertySubType (ip) == 13/*SONIC*/) nColor = IP_CONST_LIGHTCOLOR_WHITE;
        }
        ip = GetNextItemProperty (oItem);
    }
    if (nColor == 99) nColor = Random (7);
    ip = ItemPropertyLight (nBrightness, nColor);
    AddItemProperty (DURATION_TYPE_PERMANENT, ip, oItem);
}
