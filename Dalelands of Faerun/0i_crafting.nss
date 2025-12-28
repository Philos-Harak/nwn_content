/*////////////////////////////////////////////////////////////////////////////////////////////////////
 Script Name: 0i_crafting
 Programmer: Philos
//////////////////////////////////////////////////////////////////////////////////////////////////////
 Include file that holds the servers crafting and enchanting system.
*/////////////////////////////////////////////////////////////////////////////////////////////////////
#include "0i_master"
#include "0i_effects"
#include "0i_checks"
#include "0i_magicitems"

// Check to see if we need to craft an item.
// stSpell is the spells information.
void CraftDisposableItem (struct stSpell Spell);

// Craft a permanent magic item from inside a box.
// stSpell is the spells information.
// oTarget is containers that cannot be placed into the enchanting box.
void CraftPermanentItem (struct stSpell Spell, object oTarget = OBJECT_INVALID);

// Used to craft base items such as Longswords.
// oPC is the crafter.
// oBook is the instruction booklet used.
// oContainer is the container used to craft the item.
void CraftBaseItem (object oPC, object oBook, object oContainer);

// Used to enchant items in an enchanting box.
// oCaster is the Caster.
// iLevel is the level of the caster.
void EnchantBox (object oCaster, int iLevel);

// Checks oContainer for any enhancment items.
// oContainer it the enchantment box.
// iSpell is the spell cast.
int CheckEnhancments (object oCaster, int iSpell);

// Used in the crafting GUI to copy an item to be pasted to another item later.
void CopyCraftingItem (object oPC, object oItem);

// Used in the crafting GUI to paste a copy of an item to another item.
object PasteCraftingItem (object oPC, object oTarget, object oItem);

int GetItemSelectedEquipSlot (int nItemSelected);

int GetArmorModelSelected (object oPC);

object ChangeItemsAppearance (object oPC, object oTarget, int nToken, object oItem, int nDirection);

// Checks to see if the item can be crafted.
// bPasteCheck is a special check when an item is being pasted.
int CanCraftItem (object oPC, object oItem, int nToken, int bPasteCheck = FALSE);

object RandomizeItemsCraftAppearance (object oPlayer, object oTarget, int nToken, object oItem);

// Returns the correct item based on the crafting menu selected item.
object GetSelectedItem (object oTarget, int nItemSelected);

// Cancels the crafted item for the player and restoring the original.
void CancelCraftedItem (object oPlayer, object oTarget);

// Craft a permanent magic item from inside a box.
// stSpell is the spells information.
// oTarget is containers that cannot be placed into the enchanting box.
void CraftPermanentItem (struct stSpell Spell, object oTarget = OBJECT_INVALID)
{
    int iEnchant = FALSE, iEnchantFail, iQuality, iPowerFullImbue = FALSE;

    string sResRefLeft, sMinLevel, sPowerNum;
    object oItemToEnchant;
    // Get the item to enchant, use the first non gem / crafting item.
    if (oTarget != OBJECT_INVALID) oItemToEnchant = oTarget;
    else
    {
        oItemToEnchant = GetFirstItemInInventory (Spell.oTarget);
        while (oItemToEnchant != OBJECT_INVALID)
        {
            sResRefLeft = GetStringLeft(GetResRef (oItemToEnchant), 2);
            if (sResRefLeft != "g_" && sResRefLeft != "e_") break;
            oItemToEnchant = GetNextItemInInventory (Spell.oTarget);
        }
    }
    // Select the correct enchantment type based on item type.
    int iBaseItemType = GetBaseItemType (oItemToEnchant);
    string sEnchant_Column = Get2DAString ("smi_list", "enchant", iBaseItemType);
    // Break out armors and clothing.
    if(sEnchant_Column == "armor")
    {
        string sTag = GetTag (oItemToEnchant);
        if (sTag == "garb" || sTag == "outfit" || sTag == "robe" ||
            sTag == "tunic" || sTag == "dress") sEnchant_Column = "clothing";
    }
    // Check to make sure we can enchant this item.
    if(sEnchant_Column == "") SendMessages ("This item cannot be enchanted with this spell!", COLOR_RED, Spell.oCaster, FALSE, FALSE);
    // Continue setting up the item to enchant.
    else
    {
        // Get the number of properties.
        int iPropCounter = GetNumberOfProperties (oItemToEnchant);
        // Check for Powerful Imbue feat then increase the caster level by 4.
        iPowerFullImbue = GetHasFeat (FEAT_POWERFUL_IMBUE, Spell.oCaster);
        // DM's default to Powerful Imbue.
        if (GetIsDungeonMaster (Spell.oCaster))
        {
            iPowerFullImbue = TRUE;
            Spell.iCasterLevel = Spell.iCasterLevel + 40;
        }
        else if (iPowerFullImbue) Spell.iCasterLevel = Spell.iCasterLevel + 4;
        // to build the name of the item add one for the new property.
        SetLocalInt (oItemToEnchant, "0_NumOfProperties", iPropCounter + 1);
        // Check to see if they have the feat.
        if (GetIsCharacter (Spell.oCaster))
        {
            iEnchantFail = FALSE;
            // Make sure the casters level is high enough.
            // We are checking properties already on the items adding a new one will add one more.
            if (iPropCounter == 4 && !iPowerFullImbue)
            {
                iEnchantFail = TRUE;
                sMinLevel = "an Artificer";
                sPowerNum = "5";
            }
            else if (iPropCounter == 3 && Spell.iCasterLevel <= 19)
            {
                iEnchantFail = TRUE;
                sMinLevel = "19th level";
                sPowerNum = "4";
            }
            else if (iPropCounter == 2 && Spell.iCasterLevel <= 13)
            {
                iEnchantFail = TRUE;
                sMinLevel = "13th level";
                sPowerNum = "3";
            }
            else if (iPropCounter == 1 && Spell.iCasterLevel <= 7)
            {
                iEnchantFail = TRUE;
                sMinLevel = "7th level";
                sPowerNum = "2";
            }
            if (iEnchantFail)
            {
                SendMessages ("You do not have enough power to enchant this item further [Must be "
                             + sMinLevel + " to enchant up to" + sPowerNum + " powers!", COLOR_RED, Spell.oCaster, FALSE, FALSE);
                return;
            }
            // Check the items quality.
            itemproperty ipProperty = HasProperty (oItemToEnchant, 86);
            iQuality = GetItemPropertyCostTableValue (ipProperty);
            if (iPropCounter >= iQuality)
            {
                if (iQuality == 0) SendMessages ("Items must be at least Masterwork to hold any enchantment!", COLOR_RED, Spell.oCaster, FALSE, FALSE);
                else SendMessages ("This items quality is to low it cannot hold enough power to be enchanted any further!", COLOR_RED, Spell.oCaster, FALSE, FALSE);
                return;
            }
            // Check to see if they can enchant the item.
            // Do they have the Craft Arms and Armor feat?
            if (sEnchant_Column == "melee" || sEnchant_Column == "ammo" ||
                sEnchant_Column == "ranged" || sEnchant_Column == "armor" ||
                sEnchant_Column == "shield")
            {
                if (!GetHasFeat (FEAT_CRAFT_ARMS_AND_ARMOR, Spell.oCaster) && !GetIsDungeonMaster (Spell.oCaster))
                {
                    SendMessages ("You do not have the Craft Arms and Armor feat!", COLOR_RED, Spell.oCaster, FALSE, FALSE);
                    return;
                }
            }
            // Do they have the Craft Rods and Staves feat?
            if (sEnchant_Column == "rod" || sEnchant_Column == "stave")
            {
                if (!GetHasFeat (FEAT_CRAFT_RODS_STAVES, Spell.oCaster) && !GetIsDungeonMaster (Spell.oCaster))
                {
                    SendMessages ("You do not have the Craft Rods and Staves feat!", COLOR_RED, Spell.oCaster, FALSE, FALSE);
                    return;
                }
             }
             // Do they have the Craft Wondrous feat?
             if (sEnchant_Column == "belt" || sEnchant_Column == "boots" ||
                 sEnchant_Column == "gloves" || sEnchant_Column == "bracers" ||
                 sEnchant_Column == "cloaks" || sEnchant_Column == "helmets" ||
                 sEnchant_Column == "clothing" || sEnchant_Column == "wondrous")
             {
                 if (!GetHasFeat (FEAT_CRAFT_WONDROUS, Spell.oCaster) && !GetIsDungeonMaster (Spell.oCaster))
                 {
                     SendMessages ("You do not have the Craft Wondrous feat!", COLOR_RED, Spell.oCaster, FALSE, FALSE);
                     return;
                 }
              }
              // Do they have the Forge Amulets and Rings feat?
              if (sEnchant_Column == "amulet" || sEnchant_Column == "ring")
              {
                  if (!GetHasFeat (FEAT_CRAFT_AMULETS_RINGS, Spell.oCaster) && !GetIsDungeonMaster (Spell.oCaster))
                  {
                      SendMessages ("You do not have the Forge Amulets and Rings feat!", COLOR_RED, Spell.oCaster, FALSE, FALSE);
                      return;
                  }
               }
        }
    }
    // Get the spells name.
    string sSpellName = GetStringByStrRef (StringToInt (Get2DAString ("Spells", "Name", Spell.iSpellID)));
    // Check to make sure this spell can enchant this item.
    int iEnchantProperty = StringToInt (Get2DAString ("enchant_table", sEnchant_Column, Spell.iSpellID));
    if (iEnchantProperty == 0)
    {
        SendMessages (sSpellName + " cannot enchant this item!", COLOR_RED, Spell.oCaster, FALSE, FALSE);
        return;
    }
    // Save the enchanting box to the caster for later use.
    SetLocalObject (Spell.oCaster, "0_enchanting_box", Spell.oTarget);
    // Save the spell on the caster to use later in the convo.
    SetLocalInt (Spell.oCaster, "0_Spell", Spell.iSpellID);
    // Save the class used on the caster to use later in the convo.
    SetLocalInt (Spell.oCaster, "0_CasterClass", Spell.iClass);
    // Save the caster level on the caster to use later in the convo.
    SetLocalInt (Spell.oCaster, "0_CasterLevel", Spell.iCasterLevel);
    // Save the object to enchant to the caster to use later in the convo.
    SetLocalObject (Spell.oCaster, "0_Item_to_enchant", oItemToEnchant);
    // Save the enchant_column on the caster to use later in the convo.
    SetLocalString (Spell.oCaster, "0_enchant_column", sEnchant_Column);
    // Set the item name into a custom token.
    SetCustomToken (300, GetName (oItemToEnchant));
    // Get the spell name and set it to a token.
    SetCustomToken (301, sSpellName);
    ActionStartConversation (Spell.oCaster, "co_ench_perm", TRUE, FALSE);
}

// Check to see if we need to craft an item.
// stSpell is the spells information.
void CraftDisposableItem (struct stSpell Spell)
{
    int iBaseItemType;
    string sItemType;
    // Find out what type of item this is.
    iBaseItemType = GetBaseItemType (Spell.oTarget);
    // Check to see if we are creating a scroll.
    if (iBaseItemType == BASE_ITEM_BLANK_SCROLL)
    {
        // Check for Scribe Scroll feat.
        if (GetIsCharacter (Spell.oCaster))
        {
            if (!GetHasFeat (FEAT_SCRIBE_SCROLL, Spell.oCaster))
            {
                SendMessages ("You do not have the the Scribe scroll feat!", COLOR_RED, Spell.oCaster);
                return;
            }
        }
        sItemType = "Scroll of ";
    }
    // Check to see if we are creating a potion.
    else if (iBaseItemType == BASE_ITEM_BLANK_POTION)
    {
        // Check for Brew Potion feat.
        if (GetIsCharacter (Spell.oCaster))
        {
            if (!GetHasFeat (FEAT_BREW_POTION, Spell.oCaster))
            {
                SendMessages ("You do not have the the Brew Potion feat!", COLOR_RED, Spell.oCaster);
                return;
            }
        }
        sItemType = "Potion of ";
    }
    // Check to see if we are creating a wand.
    else if (iBaseItemType == BASE_ITEM_BLANK_WAND)
    {
        // Check for the Craft wand feat.
        if (GetIsCharacter (Spell.oCaster))
        {
            if (!GetHasFeat (FEAT_CRAFT_WAND, Spell.oCaster))
            {
                SendMessages ("You do not have the the Craft Wand feat!", COLOR_RED, Spell.oCaster);
                return;
            }
        }
        sItemType = "Wand of ";
    }
    if (sItemType != "")
    {
        // Stop the spell since we are attempting to enchant.
        SetLocalInt (Spell.oCaster, "0_ReturnInt", FALSE);
        // Save that this is a temp item.
        int iMinSpellLvl = StringToInt (Get2DAString ("spells", "Innate", Spell.iSpellID));
        // Check to see if this spell is level 4 or less.
        if (iMinSpellLvl > 4 && sItemType == "Wand of")
        {
            SendMessages ("Spells above 4th level cannot be enchanted into a wand!", COLOR_RED, Spell.oCaster);
            return;
        }
        else if (iMinSpellLvl > 3 && sItemType == "Potion of")
        {
            SendMessages ("Spells above 3rd level cannot be enchanted into a potion!", COLOR_RED, Spell.oCaster);
            return;
        }
        iMinSpellLvl = (iMinSpellLvl + iMinSpellLvl) - 1;
        SetLocalInt (Spell.oCaster, "0_Min_Spell_Level", iMinSpellLvl);
        // Save the enchanting box to the caster for later use.
        SetLocalObject (Spell.oCaster, "0_enchanting_box", Spell.oCaster);
        // Save the spell on the caster to use later in the convo.
        SetLocalInt (Spell.oCaster, "0_Spell", Spell.iSpellID);
        // Save the class used on the caster to use later in the convo.
        SetLocalInt (Spell.oCaster, "0_CasterLevel", Spell.iCasterLevel);
        // Save the object to enchant to the caster to use later in the convo.
        SetLocalObject (Spell.oCaster, "0_Item_to_enchant", Spell.oTarget);
        // Set the item name into a custom token.
        SetCustomToken (300, GetName (Spell.oTarget));
        // Get the spell name and set it to a token.
        string sSpellName = GetStringByStrRef (StringToInt (Get2DAString ("Spells", "Name", Spell.iSpellID)));
        SetCustomToken (301, sSpellName);
        SetCustomToken (304, sItemType + sSpellName);
        ActionStartConversation (Spell.oCaster, "co_ench_temp", TRUE, FALSE);
    }
}

void CreateCraftMaterial (string sItemTemplate, object oTarget, int nStackSize)
{
    CreateItemOnObject (sItemTemplate, oTarget, nStackSize);
}

// Used to craft base items such as Longswords.
// oPC is the crafter and where we put the new item.
// oTool is the instruction booklet used.
// oBook is the book used to craft the item.
/*
Banded 100   40 metal 10 leather
Full Plate 350 150 metal 25 leather
Half Plate 200 80 metal 20 leather
Splint Mail 100 30 metal 20 leather
Chain Shirt 50 25 metal
Leather Armor 10 5 leather
Padded Armor 5 3 cloth
Studded Leather 15 3 metal 5 leather
Breast Plate 100 40 metal 10 leather
Chainmail 100 50 metal
Hide Armor 15 5 leather 3 cloth
Scale Mail 50 20 metal 5 leather

Metal: Billets 1gp, Ingots 10gp, Bars 50gp.
Leather: Strips 1gp, Hide 10gp.
Cloth: Bolts 1gp
Wood: Planks 1gp
*/
void CraftBaseItem (object oPC, object oTool, object oBook)
{
    int nCounter, nMetalRequired, nLeatherRequired, nClothRequired, nWoodRequired, nBaseItemType;
    int nDC, nCheck, nMetalHas, nLeatherHas, nClothHas, nWoodHas, nStack, nAmount;
    int nTagLength, nCount, nIndex, nQuality, nBonus, nMetalCount, nLeatherCount, nClothCount, nWoodCount;
    string sMaterialTag, sItem, sTag, sText;
    object oItem, oMaterial, oCraftChest, oNewItem;
    // Get the length of the books tag so we can pull the base item name
    // from the tag.
    sTag = GetTag (oBook);
    nTagLength = GetStringLength (sTag);
    // Get the base item name from the book tag.
    sItem = GetSubString (sTag, 6, nTagLength - 6);
    // Get the Crafting Chest.
    oCraftChest = GetObjectByTag ("ClothingBuilder");
    // Create the item in the crafting chest.
    // So we can get the BaseItemType and pull our crafting info from the 2da.
    oItem = CreateItemOnObject (sItem, oCraftChest);
    // Check if the item did not make then check for an index.
    if (!GetIsObjectValid (oItem))
    {
        // If there is an index then add it to the resref.
        sItem = sItem + "_" + IntToString (Random (4) + 1);
        // Now try to make the item again.
        oItem = CreateItemOnObject (sItem, oCraftChest);
        // If not an item now then we have an error.
        if (!GetIsObjectValid (oItem))
        {
            SetModuleError ("RESREF", "0i_crafting", "331", "Craft item: " + sItem);
            return;
        }
    }
    sText = GetName (oItem);
    // Randomize how it looks.
    oItem = ChangeItemAppearance (oItem, 0);
    // Get the tag of the item so we can stuff.
    sTag = GetTag (oItem);
    // If it is a stackable item then set the stack.
    if (GetIsItemStackable (oItem)) SetItemStackSize (oItem, 50);
    // Get what materials are needed based upon the base item.
    nBaseItemType = GetBaseItemType (oItem);
    // if the base item type is armor then change to the specific type of armor.
    if (nBaseItemType == BASE_ITEM_ARMOR)
    {
        if (sTag == "garb") nBaseItemType = 115;
        else if (sTag == "outfit") nBaseItemType = 116;
        else if (sTag == "robe") nBaseItemType = 117;
        else if (sTag == "tunic") nBaseItemType = 118;
        else if (sTag == "padded") nBaseItemType = 119;
        else if (sTag == "leather") nBaseItemType = 120;
        else if (sTag == "stleather") nBaseItemType = 121;
        else if (sTag == "hide") nBaseItemType = 122;
        else if (sTag == "chainshirt") nBaseItemType = 123;
        else if (sTag == "scalemail") nBaseItemType = 124;
        else if (sTag == "chainmail") nBaseItemType = 125;
        else if (sTag == "breastplate") nBaseItemType = 126;
        else if (sTag == "splintmail") nBaseItemType = 127;
        else if (sTag == "bandedmail") nBaseItemType = 128;
        else if (sTag == "halfplate") nBaseItemType = 129;
        else if (sTag == "fullplate") nBaseItemType = 130;
    }
    nMetalRequired = StringToInt (Get2DAString ("smi_list", "Craft_Metal", nBaseItemType));
    nLeatherRequired = StringToInt (Get2DAString ("smi_list", "Craft_Leather", nBaseItemType));
    nClothRequired = StringToInt (Get2DAString ("smi_list", "Craft_Cloth", nBaseItemType));
    nWoodRequired = StringToInt (Get2DAString ("smi_list", "Craft_Wood", nBaseItemType));
    // Check to see if we have all of the materials.
    oMaterial = GetFirstItemInInventory (oPC);
    while (oMaterial != OBJECT_INVALID && nCounter < 100)
    {
        // Get the items tag.
        sMaterialTag = GetTag (oMaterial);
        // Check to see if this is a material needed.
        if (GetStringLeft (sMaterialTag, 7) == "m_metal" && nMetalHas < nMetalRequired)
        {
            nAmount = StringToInt (GetStringRight (sMaterialTag, GetStringLength (sMaterialTag) - 8));
            nAmount = nAmount * GetItemStackSize (oMaterial);
            nMetalHas += nAmount;
            nMetalCount ++;
            // Save this object to be removed.
            SetLocalObject (oPC, "0_Metal_" + IntToString (nMetalCount), oMaterial);
        }
        else if (GetStringLeft (sMaterialTag, 9) == "m_leather" && nLeatherHas < nLeatherRequired)
        {
            nAmount = StringToInt (GetStringRight (sMaterialTag, GetStringLength (sMaterialTag) - 10));
            nAmount = nAmount * GetItemStackSize (oMaterial);
            nLeatherHas += nAmount;
            nLeatherCount ++;
            // Save this object to be removed.
            SetLocalObject (oPC, "0_Leather_" + IntToString (nLeatherCount), oMaterial);
        }
        else if (GetStringLeft (sMaterialTag, 7) == "m_cloth" && nClothHas < nClothRequired)
        {
            nAmount = StringToInt (GetStringRight (sMaterialTag, GetStringLength (sMaterialTag) - 8));
            nAmount = nAmount * GetItemStackSize (oMaterial);
            nClothHas += nAmount;
            nClothCount ++;
            // Save this object to be removed.
            SetLocalObject (oPC, "0_Cloth_" + IntToString (nClothCount), oMaterial);
        }
        else if (GetStringLeft (sMaterialTag, 6) == "m_wood" && nWoodHas < nWoodRequired)
        {
            nAmount = StringToInt (GetStringRight (sMaterialTag, GetStringLength (sMaterialTag) - 7));
            nAmount = nAmount * GetItemStackSize (oMaterial);
            nWoodHas += nAmount;
            nWoodCount ++;
            // Save this object to be removed.
            SetLocalObject (oPC, "0_Wood_" + IntToString (nWoodCount), oMaterial);
        }
        nCounter ++;
        oMaterial = GetNextItemInInventory (oPC);
    }
    // Now check to see if we have all the materials.
    if (nWoodHas >= nWoodRequired && nClothHas >= nClothRequired &&
        nLeatherHas >= nLeatherRequired && nMetalHas >= nMetalRequired)
    {
        // Make Crafting skill check.
        nDC = StringToInt (Get2DAString ("smi_list", "CraftDC", nBaseItemType));
        // Get the artisan tool bonus if it has one.
        sTag = GetResRef (oTool);
        if (sTag == "artisan_tools") nBonus = 0;
        else if (sTag == "artisan_tools_1") nBonus = 1;
        else if (sTag == "artisan_tools_2") nBonus = 2;
        else if (sTag == "artisan_tools_3") nBonus = 3;
        else if (sTag == "artisan_tools_4") nBonus = 4;
        else if (sTag == "artisan_tools_5") nBonus = 5;
        else if (sTag == "artisan_tools_6") nBonus = 6;
        else if (sTag == "artisan_tools_7") nBonus = 7;
        else if (sTag == "artisan_tools_8") nBonus = 8;
        else if (sTag == "artisan_tools_9") nBonus = 9;
        else if (sTag == "artisan_tools_10") nBonus = 10;
        nCheck = GetSkillCheck (oPC, SKILL_CRAFTING, FALSE, nBonus, nDC, TRUE, FALSE);
        if (nCheck >= 0)
        {
            // Create item and remove materials.
            oNewItem = CopyItem (oItem, oPC, TRUE);
            nQuality = 0;
            // Check for Artifact quality.
            if (nCheck + nDC >= ITEM_QUALITY_ARTIFACT)
            {
                nQuality = 5;
                sText = "Artifact " + sText;
                sText = AddColorToText (sText, COLOR_ARTIFACT);
            }
            // Check for Relic quality.
            else if (nCheck + nDC >= ITEM_QUALITY_RELIC)
            {
                nQuality = 4;
                sText = "Relic " + sText;
                sText = AddColorToText (sText, COLOR_RELIC);
            }
            // Check for Legendary quality.
            else if (nCheck + nDC >= ITEM_QUALITY_LEGENDARY)
            {
                nQuality = 3;
                sText = "Legendary " + sText;
                sText = AddColorToText (sText, COLOR_LEGENDARY);
            }
            // Check for Exquisite quality.
            else if (nCheck + nDC >= ITEM_QUALITY_EXQUISITE)
            {
                nQuality = 2;
                sText = "Exquisite " + sText;
                sText = AddColorToText (sText, COLOR_EXQUISITE);
            }
            // Check for Master Work quality.
            else if (nCheck + nDC >= ITEM_QUALITY_MASTER_WORK)
            {
                nQuality = 1;
                sText = "Masterwork " + sText;
                sText = AddColorToText (sText, COLOR_MAGIC);
            }
            if (nQuality > 0)
            {
                itemproperty ipProperty = ItemPropertyQuality (nQuality);
                AddItemProperty (DURATION_TYPE_PERMANENT, ipProperty, oNewItem);
            }
        }
        // Remove all of the Materials used from the container.
        if (nMetalRequired > 0)
        {
            for (nCount = nMetalCount; nCount > 0; nCount --)
            {
                oMaterial = GetLocalObject (oPC, "0_Metal_" + IntToString (nCount));
                sMaterialTag = GetTag (oMaterial);
                nAmount = StringToInt (GetStringRight (sMaterialTag, GetStringLength (sMaterialTag) - 8));
                nAmount = nAmount * GetItemStackSize (oMaterial);
                nMetalRequired -= nAmount;
                if (nMetalRequired < 0)
                {
                    if (nMetalRequired < -49)
                    {
                        nStack = abs (nMetalRequired) / 50;
                        DelayCommand (0.2f, CreateCraftMaterial ("m_iron_bar", oPC, nStack));
                        nMetalRequired += nStack * 50;
                    }
                    if (nMetalRequired < -9)
                    {
                        nStack = abs (nMetalRequired) / 10;
                        DelayCommand (0.4f, CreateCraftMaterial ("m_iron_ingot", oPC, nStack));
                        nMetalRequired += nStack * 10;
                    }
                    if (nMetalRequired < 0) DelayCommand (0.6f, CreateCraftMaterial ("m_iron_billet", oPC, abs(nMetalRequired)));
                }
                DestroyObject (oMaterial);
            }
            // Clear all variables used.
            for (nCount = 0; nCount <= nMetalCount; nCount ++)
            {
                DeleteLocalObject (oPC, "0_Metal_" + IntToString (nCount));
            }
        }
        if (nLeatherHas > 0)
        {
            for (nCount = nLeatherCount; nCount > 0; nCount --)
            {
                oMaterial = GetLocalObject (oPC, "0_Leather_" + IntToString (nCount));
                sMaterialTag = GetTag (oMaterial);
                nAmount = StringToInt (GetStringRight (sMaterialTag, GetStringLength (sMaterialTag) - 10));
                nAmount = nAmount * GetItemStackSize (oMaterial);
                nLeatherRequired -= nAmount;
                if (nLeatherRequired < 0)
                {
                    if (nLeatherRequired < -9)
                    {
                        nStack = abs (nLeatherRequired) / 10;
                        DelayCommand (0.4f, CreateCraftMaterial ("m_leather_hide", oPC, nStack));
                        nLeatherRequired += nStack * 10;
                    }
                    if (nLeatherRequired < 0) DelayCommand (0.6f, CreateCraftMaterial ("m_leather_strip", oPC, abs(nLeatherRequired)));
                }
                DestroyObject (oMaterial);
            }
            // Clear all variables used.
            for (nCount = 0; nCount <= nLeatherCount; nCount ++)
            {
                DeleteLocalObject (oPC, "0_Leather_" + IntToString (nCount));
            }
        }
        if (nClothHas > 0)
        {
            for (nCount = nClothCount; nCount > 0; nCount --)
            {
                oMaterial = GetLocalObject (oPC, "0_Cloth_" + IntToString (nCount));
                sMaterialTag = GetTag (oMaterial);
                nAmount = StringToInt (GetStringRight (sMaterialTag, GetStringLength (sMaterialTag) - 8));
                nAmount = nAmount * GetItemStackSize (oMaterial);
                nClothRequired -= nAmount;
                if (nClothRequired < 0)
                {
                    if (nClothRequired < -9)
                    {
                        nStack = abs (nClothRequired) / 10;
                        DelayCommand (0.4f, CreateCraftMaterial ("m_cloth_bolt", oPC, nStack));
                        nClothRequired += nStack * 10;
                    }
                    if (nClothRequired < 0) DelayCommand (0.6f, CreateCraftMaterial ("m_cloth_sheet", oPC, abs(nClothRequired)));
                }
                DestroyObject (oMaterial);
            }
            // Clear all variables used.
            for (nCount = 0; nCount <= nClothCount; nCount ++)
            {
                DeleteLocalObject (oPC, "0_Cloth_" + IntToString (nCount));
            }
        }
        if (nWoodHas > 0)
        {
            for (nCount = nWoodCount; nCount > 0; nCount --)
            {
                oMaterial = GetLocalObject (oPC, "0_Wood_" + IntToString (nCount));
                sMaterialTag = GetTag (oMaterial);
                nAmount = StringToInt (GetStringRight (sMaterialTag, GetStringLength (sMaterialTag) - 7));
                nAmount = nAmount * GetItemStackSize (oMaterial);
                nWoodRequired -= nAmount;
                if (nWoodRequired < 0)
                {
                    if (nWoodRequired < -9)
                    {
                        nStack = abs (nWoodRequired) / 10;
                        DelayCommand (0.4f, CreateCraftMaterial ("m_wood_plank", oPC, nStack));
                        nWoodRequired += nStack * 10;
                    }
                    if (nWoodRequired < 0) DelayCommand (0.6f, CreateCraftMaterial ("m_wood_stick", oPC, abs(nWoodRequired)));
                }
                DestroyObject (oMaterial);
            }
            // Clear all variables used.
            for (nCount = 0; nCount <= nWoodCount; nCount ++)
            {
                DeleteLocalObject (oPC, "0_Wood_" + IntToString (nCount));
            }
        }
        SendMessages ("You have crafted a " + sText + ".", COLOR_GREEN, oPC, FALSE, FALSE);
        // Set the name of the item.
        SetName (oNewItem, sText);
    }
    else SendMessages ("You do not have all of the materials to craft this!", COLOR_RED, oPC, FALSE, FALSE);
    DestroyObject (oItem);
}

// Used to enchant items in an enchanting box
// or potion, scroll, and wands.
// oCaster is the Caster.
// iLevel is the level of the caster.
void EnchantBox (object oCaster, int iLevel)
{
    int iPreviousCost = 0, iSpell, iEnchantProperty, iGoldCost, iBaseItemType;
    int iValue, iSpellLevel, iCount, iPowerLevel, iNewCost;
    string sResRef, sColumn = "";
    object oItem, oNewItem, oContainer;
    oContainer = GetObjectByTag ("ClothingBuilder");
    // Get the spell being cast.
    iSpell = GetLocalInt (oCaster, "0_Spell");
    // Get the item to enchant from the caster.
    oItem = GetLocalObject (oCaster, "0_Item_to_enchant");
    // Check to see if it is a blank scroll.
    // Find out what type of item this is.
    iBaseItemType = GetBaseItemType (oItem);
    // Check to see if we are creating a potion.
    if (iBaseItemType == BASE_ITEM_BLANK_SCROLL) sColumn = "scroll";
    // Check to see if we are creating a potion.
    else if (iBaseItemType == BASE_ITEM_BLANK_POTION) sColumn = "potion";
    // Check to see if we are creating a wand.
    else if (iBaseItemType == BASE_ITEM_BLANK_WAND) sColumn = "wand";
    // We are creating a scroll, potion, wand.
    if (sColumn != "")
    {
        // Get the resref of the new item.
        sResRef = Get2DAString ("enchant_table", sColumn, iSpell);
        // Create new item.
        oNewItem = CreateItemOnObject (sResRef, oContainer);
        // Check for errors.
        if (!GetIsObjectValid (oNewItem)) SetModuleError ("RESREF", "0i_crafting", "531", "enchanting_table: Column:" + sColumn + " 2da file has invalid resref: " + sResRef + " on row " + IntToString (iSpell));
        else
        {
            SetIdentified (oNewItem, TRUE);
            // Get the cost of the new item and reduce it by the previous cost.
            iGoldCost = GetGoldPieceValue(oNewItem);
            // Get the Minimum level you can have for this spell.
            //itemproperty ipProperty = GetFirstItemProperty (oNewItem);
            //int iSpellProperty = GetItemPropertySubType (ipProperty);
            //int iSpellMinLevel = StringToInt (Get2DAString ("iprp_spells", "Innate", iSpellProperty));
            // Place Level of the spell cast on the item.
            SetLocalInt (oNewItem, "0_Caster_Level", iLevel);
            //if (iLevel < iSpellMinLevel) iLevel = iSpellMinLevel;
            // Place the level in the items name.
            SetName (oNewItem, AddColorToText(GetName(oNewItem) + " (" + IntToString (iLevel) + ")", COLOR_MAGIC));
        }
    }
    // Enchant all other types of items.
    else
    {
        // now copy it to the temporary container for enchantment.
        oNewItem = CopyItem (oItem, oContainer, TRUE);
        // Get the cost of the item before enchantment.
        iPreviousCost = GetGoldPieceValue(oNewItem);
        // We need to check for enhancment objects within the box based on the property used.
        iEnchantProperty = CheckEnhancments (oCaster, iSpell);
        // Enchant the item.
        EnchantItem (oNewItem, iLevel, iEnchantProperty, TRUE);
        // Get the cost of the new item and reduce it by the previous cost.
        iGoldCost = GetGoldPieceValue(oNewItem) - iPreviousCost;
    }
    // Reduce gold cost by 1/3rd.
    iGoldCost = (iGoldCost / 3) * 2;
    // if they have the feat Grand Craftsmanship (Reduce cost by 5% and 10% at level 7th.
    if (GetHasFeat (FEAT_GRAND_CRAFTMANSHIP, oCaster))
    {
        if (GetLevelByClass (CLASS_TYPE_ARTIFICER, oCaster) > 6) iGoldCost = (iGoldCost * 90) / 100;
        else iGoldCost = (iGoldCost * 95) / 100;
    }
    // Get the gold cost and save to caster.
    SetLocalInt (oCaster, "0_GoldCost", iGoldCost);
    // Save the location of the new item so we can get it.
    SetLocalObject (oCaster, "0_enchanted_item", oNewItem);
    // Now setup the cost tokens.
    SetCustomToken (302, IntToString (iGoldCost));
    //SetCustomToken (303, IntToString (iXPCost));
    // Setup the Power Level of the Item.
    iNewCost = GetGoldPieceValue (oNewItem);
    iCount = 0;
    while (iCount < 41 && iPowerLevel == 0)
    {
       if (iNewCost <= StringToInt (Get2DAString ("itemvalue", "MAXSINGLEITEMVALUE", iCount))) iPowerLevel = iCount + 1;
       iCount++;
    }
    SetCustomToken (305, IntToString (iPowerLevel));
}

// Checks for any enhancment items in the enchant box.
// oCaster it the player casting the enchantment.
// iSpell is the spell cast.
int CheckEnhancments (object oCaster, int iSpell)
{
    object oEnchantBox = GetLocalObject (oCaster, "0_enchanting_box");
    // Get the spell used.
    int iItemType;
    // Get the sEnchant_Column.
    string sResRef, sResRefLeft, sEnchant_Column = GetLocalString (oCaster, "0_enchant_column");
    // Get the property to add to the item.
    int iProperty = StringToInt (Get2DAString ("enchant_table", sEnchant_Column, iSpell));
    // Now check the property for any enhancements.
    object oItem = GetFirstItemInInventory (oEnchantBox);
    while (GetIsObjectValid (oItem))
    {
        // make sure the item is an enhancing item.
        sResRef = GetResRef (oItem);
        sResRefLeft = GetStringLeft(sResRef, 2);
        if (sResRefLeft == "g_" || sResRefLeft == "e_")
        {
            // Check for light property (yellow).
            if (iProperty == 156)
            {
                // Blue color.
                if (sResRef == "g_500_1" || sResRef == "g_10_5" || sResRef == "g_10_6" ||
                    sResRef == "g_50_5" || sResRef == "g_1000_2" || sResRef == "g_1000_5") iProperty = 150;
                // Green color.
                else if (sResRef == "g_500_1" || sResRef == "g_5000_4" ||
                         sResRef == "g_5000_2" || sResRef == "g_10_3" ||
                         sResRef == "g_100_6" || sResRef == "g_10_4") iProperty = 151;
                // Orange color.
                else if (sResRef == "g_50_4" || sResRef == "g_5000_5") iProperty = 152;
                // Purple color.
                else if (sResRef == "g_100_1" || sResRef == "g_10_2)" ||
                         sResRef == "g_500_4") iProperty = 153;
                // Red color.
                else if (sResRef == "g_1000_1" || sResRef == "g_100_2" ||
                         sResRef == "g_5000_3" || sResRef == "g_1000_4") iProperty = 154;
                // White color.
                else if (sResRef == "g_5000_1" || sResRef == "g_5000_6" ||
                         sResRef == "g_100_4") iProperty = 155;
            }
            // Check for bane weapons (Uses Enhancment 148).
            else if (iProperty == 148)
            {
                if (sResRef == "e_aberration_eye") iProperty = 192;
                else if (sResRef == "e_animal_skin") iProperty = 193;
                else if (sResRef == "e_construct_part") iProperty = 195;
                else if (sResRef == "e_dragon_blood") iProperty = 196;
                else if (sResRef == "e_dwarf_beard") iProperty = 197;
                else if (sResRef == "e_elemental_esse") iProperty = 198;
                else if (sResRef == "e_elf_ear") iProperty = 199;
                else if (sResRef == "e_fey_dust") iProperty = 200;
                else if (sResRef == "e_giant_tooth") iProperty = 201;
                else if (sResRef == "e_gnome_nose") iProperty = 202;
                else if (sResRef == "e_halfling_hand") iProperty = 204;
                else if (sResRef == "e_human_skull") iProperty = 206;
                else if (sResRef == "e_goblin_head") iProperty = 207;
                else if (sResRef == "e_monster_heart") iProperty = 208;
                else if (sResRef == "e_orc_head") iProperty = 209;
                else if (sResRef == "e_reptilian_tong") iProperty = 210;
                else if (sResRef == "e_beast_claw") iProperty = 211;
                else if (sResRef == "e_outsider_soul") iProperty = 212;
                else if (sResRef == "e_shchange_brain") iProperty = 213;
                else if (sResRef == "e_undead_bone") iProperty = 214;
                else if (sResRef == "e_vermin_guts") iProperty = 215;
            }
            // Check for ac vs creature type (Uses armor bonus 13, 14, 15, 16).
            else if (iProperty >= 13 && iProperty <= 16)
            {
                if (sResRef == "e_aberration_eye") iProperty = 22;
                else if (sResRef == "e_animal_skin") iProperty = 23;
                else if (sResRef == "e_construct_part") iProperty = 25;
                else if (sResRef == "e_dragon_blood") iProperty = 26;
                else if (sResRef == "e_dwarf_beard") iProperty = 27;
                else if (sResRef == "e_elemental_esse") iProperty = 28;
                else if (sResRef == "e_elf_ear") iProperty = 29;
                else if (sResRef == "e_fey_dust") iProperty = 30;
                else if (sResRef == "e_giant_tooth") iProperty = 31;
                else if (sResRef == "e_gnome_nose") iProperty = 32;
                else if (sResRef == "e_halfling_hand") iProperty = 34;
                else if (sResRef == "e_human_skull") iProperty = 36;
                else if (sResRef == "e_goblin_head") iProperty = 37;
                else if (sResRef == "e_monster_heart") iProperty = 38;
                else if (sResRef == "e_orc_head") iProperty = 39;
                else if (sResRef == "e_reptilian_tong") iProperty = 40;
                else if (sResRef == "e_beast_claw") iProperty = 41;
                else if (sResRef == "e_outsider_soul") iProperty = 42;
                else if (sResRef == "e_shchange_brain") iProperty = 43;
                else if (sResRef == "e_undead_bone") iProperty = 44;
                else if (sResRef == "e_vermin_guts") iProperty = 45;
            }
        }
        oItem = GetNextItemInInventory (oEnchantBox);
    }
    return iProperty;
}


// Used in the crafting GUI to copy an item to be pasted to another item later.
void CopyCraftingItem (object oPC, object oItem)
{
    int nSelected = GetLocalInt (oPC, "0_CRAFT_ITEM_SELECTION");
    if (GetIsWeapon (oItem))
    {
        // Copy the base item type;
        SetLocalInt (oPC, "0_Craft_Item_Type", GetBaseItemType (oItem));
        // Copy each model & save to variables.
        SetLocalInt (oPC, "0_Weapon_M_Top", GetItemAppearance (oItem, ITEM_APPR_TYPE_WEAPON_MODEL, ITEM_APPR_WEAPON_MODEL_TOP));
        SetLocalInt (oPC, "0_Weapon_M_Middle", GetItemAppearance (oItem, ITEM_APPR_TYPE_WEAPON_MODEL, ITEM_APPR_WEAPON_MODEL_MIDDLE));
        SetLocalInt (oPC, "0_Weapon_M_Bottom", GetItemAppearance (oItem, ITEM_APPR_TYPE_WEAPON_MODEL, ITEM_APPR_WEAPON_MODEL_BOTTOM));
        // Copy each color and save to variables.
        SetLocalInt (oPC, "0_Weapon_C_Top", GetItemAppearance (oItem, ITEM_APPR_TYPE_WEAPON_COLOR, ITEM_APPR_WEAPON_COLOR_TOP));
        SetLocalInt (oPC, "0_Weapon_C_Middle", GetItemAppearance (oItem, ITEM_APPR_TYPE_WEAPON_COLOR, ITEM_APPR_WEAPON_COLOR_MIDDLE));
        SetLocalInt (oPC, "0_Weapon_C_Bottom", GetItemAppearance (oItem, ITEM_APPR_TYPE_WEAPON_COLOR, ITEM_APPR_WEAPON_COLOR_BOTTOM));
    }
    else if (nSelected == 0)
    {
        // Copy the armors AC so we can check it.
        SetLocalInt (oPC, "0_Armor_AC", NWNX_Item_GetBaseArmorClass (oItem));
        // Copy each model & save to variables.
        SetLocalInt (oPC, "0_Armor_Belt", GetItemAppearance (oItem, ITEM_APPR_TYPE_ARMOR_MODEL, ITEM_APPR_ARMOR_MODEL_BELT));
        SetLocalInt (oPC, "0_Armor_LBicep", GetItemAppearance (oItem, ITEM_APPR_TYPE_ARMOR_MODEL, ITEM_APPR_ARMOR_MODEL_LBICEP));
        SetLocalInt (oPC, "0_Armor_LFoot", GetItemAppearance (oItem, ITEM_APPR_TYPE_ARMOR_MODEL, ITEM_APPR_ARMOR_MODEL_LFOOT));
        SetLocalInt (oPC, "0_Armor_LForearm", GetItemAppearance (oItem, ITEM_APPR_TYPE_ARMOR_MODEL, ITEM_APPR_ARMOR_MODEL_LFOREARM));
        SetLocalInt (oPC, "0_Armor_LHand", GetItemAppearance (oItem, ITEM_APPR_TYPE_ARMOR_MODEL, ITEM_APPR_ARMOR_MODEL_LHAND));
        SetLocalInt (oPC, "0_Armor_LShin", GetItemAppearance (oItem, ITEM_APPR_TYPE_ARMOR_MODEL, ITEM_APPR_ARMOR_MODEL_LSHIN));
        SetLocalInt (oPC, "0_Armor_LShoulder", GetItemAppearance (oItem, ITEM_APPR_TYPE_ARMOR_MODEL, ITEM_APPR_ARMOR_MODEL_LSHOULDER));
        SetLocalInt (oPC, "0_Armor_LThigh", GetItemAppearance (oItem, ITEM_APPR_TYPE_ARMOR_MODEL, ITEM_APPR_ARMOR_MODEL_LTHIGH));
        SetLocalInt (oPC, "0_Armor_Neck", GetItemAppearance (oItem, ITEM_APPR_TYPE_ARMOR_MODEL, ITEM_APPR_ARMOR_MODEL_NECK));
        SetLocalInt (oPC, "0_Armor_Pelvis", GetItemAppearance (oItem, ITEM_APPR_TYPE_ARMOR_MODEL, ITEM_APPR_ARMOR_MODEL_PELVIS));
        SetLocalInt (oPC, "0_Armor_RBicep", GetItemAppearance (oItem, ITEM_APPR_TYPE_ARMOR_MODEL, ITEM_APPR_ARMOR_MODEL_RBICEP));
        SetLocalInt (oPC, "0_Armor_RFoot", GetItemAppearance (oItem, ITEM_APPR_TYPE_ARMOR_MODEL, ITEM_APPR_ARMOR_MODEL_RFOOT));
        SetLocalInt (oPC, "0_Armor_RForearm", GetItemAppearance (oItem, ITEM_APPR_TYPE_ARMOR_MODEL, ITEM_APPR_ARMOR_MODEL_RFOREARM));
        SetLocalInt (oPC, "0_Armor_RHand", GetItemAppearance (oItem, ITEM_APPR_TYPE_ARMOR_MODEL, ITEM_APPR_ARMOR_MODEL_RHAND));
        SetLocalInt (oPC, "0_Armor_Robe", GetItemAppearance (oItem, ITEM_APPR_TYPE_ARMOR_MODEL, ITEM_APPR_ARMOR_MODEL_ROBE));
        SetLocalInt (oPC, "0_Armor_RShin", GetItemAppearance (oItem, ITEM_APPR_TYPE_ARMOR_MODEL, ITEM_APPR_ARMOR_MODEL_RSHIN));
        SetLocalInt (oPC, "0_Armor_RShoulder", GetItemAppearance (oItem, ITEM_APPR_TYPE_ARMOR_MODEL, ITEM_APPR_ARMOR_MODEL_RSHOULDER));
        SetLocalInt (oPC, "0_Armor_RThigh", GetItemAppearance (oItem, ITEM_APPR_TYPE_ARMOR_MODEL, ITEM_APPR_ARMOR_MODEL_RTHIGH));
        SetLocalInt (oPC, "0_Armor_Torso", GetItemAppearance (oItem, ITEM_APPR_TYPE_ARMOR_MODEL, ITEM_APPR_ARMOR_MODEL_TORSO));
        // Copy each color and save to variables.
        SetLocalInt (oPC, "0_Armor_Cloth1", GetItemAppearance (oItem, ITEM_APPR_TYPE_ARMOR_COLOR, ITEM_APPR_ARMOR_COLOR_CLOTH1));
        SetLocalInt (oPC, "0_Armor_Cloth2", GetItemAppearance (oItem, ITEM_APPR_TYPE_ARMOR_COLOR, ITEM_APPR_ARMOR_COLOR_CLOTH2));
        SetLocalInt (oPC, "0_Armor_Leather1", GetItemAppearance (oItem, ITEM_APPR_TYPE_ARMOR_COLOR, ITEM_APPR_ARMOR_COLOR_LEATHER1));
        SetLocalInt (oPC, "0_Armor_Leather2", GetItemAppearance (oItem, ITEM_APPR_TYPE_ARMOR_COLOR, ITEM_APPR_ARMOR_COLOR_LEATHER2));
        SetLocalInt (oPC, "0_Armor_Metal1", GetItemAppearance (oItem, ITEM_APPR_TYPE_ARMOR_COLOR, ITEM_APPR_ARMOR_COLOR_METAL1));
        SetLocalInt (oPC, "0_Armor_Metal2", GetItemAppearance (oItem, ITEM_APPR_TYPE_ARMOR_COLOR, ITEM_APPR_ARMOR_COLOR_METAL2));
    }
    else
    {
        // Copy the base item type;
        SetLocalInt (oPC, "0_Craft_Item_Type", GetBaseItemType (oItem));
        // Copy each model & save to variables.
        SetLocalInt (oPC, "0_Item_Model", GetItemAppearance (oItem, ITEM_APPR_TYPE_SIMPLE_MODEL, 0));
        // Copy each color and save to variables.
        SetLocalInt (oPC, "0_Item_C_Cloth_1", GetItemAppearance (oItem, ITEM_APPR_TYPE_ARMOR_COLOR, ITEM_APPR_ARMOR_COLOR_CLOTH1));
        SetLocalInt (oPC, "0_Item_C_Cloth_2", GetItemAppearance (oItem, ITEM_APPR_TYPE_ARMOR_COLOR, ITEM_APPR_ARMOR_COLOR_CLOTH2));
        SetLocalInt (oPC, "0_Item_C_Leather_1", GetItemAppearance (oItem, ITEM_APPR_TYPE_ARMOR_COLOR, ITEM_APPR_ARMOR_COLOR_LEATHER1));
        SetLocalInt (oPC, "0_Item_C_Leather_2", GetItemAppearance (oItem, ITEM_APPR_TYPE_ARMOR_COLOR, ITEM_APPR_ARMOR_COLOR_LEATHER2));
        SetLocalInt (oPC, "0_Item_C_Metal_1", GetItemAppearance (oItem, ITEM_APPR_TYPE_ARMOR_COLOR, ITEM_APPR_ARMOR_COLOR_METAL1));
        SetLocalInt (oPC, "0_Item_C_Metal_2", GetItemAppearance (oItem, ITEM_APPR_TYPE_ARMOR_COLOR, ITEM_APPR_ARMOR_COLOR_METAL2));
    }
    // Send message that it has been copied.
    SendMessages (GetName (oItem) + " appearance has been copied!", COLOR_GREEN, oPC);
}

// Used in the crafting GUI to paste a copy of an item to another item.
object PasteCraftingItem (object oPC, object oTarget, object oItem)
{
    int iMaxModel, iModelTop, iModelMiddle, iModelBottom, iColorTop;
    int iColorMiddle, iColorBottom, iModel, iColor;
    object oItemDone, oItem1, oItem2, oItem3, oItem4, oItem5, oItem6, oItem7;
    object oItem8, oItem9, oItem10, oItem11, oItem12, oItem13, oItem14, oItem15;
    object oItem16, oItem17, oItem18, oItem19, oItem20, oItem21, oItem22;
    object oItem23, oItem24, oItem25, oItem26, oBuildContainer;
    int nSelected = GetLocalInt (oPC, "0_CRAFT_ITEM_SELECTION");
    SetLocalInt (oItem, "0_EQUIP_LOCKED", FALSE);
    if (GetIsWeapon (oItem))
    {
        // Get each model & save to variables.
        iModelTop = GetLocalInt (oPC, "0_Weapon_M_Top");
        iModelMiddle = GetLocalInt (oPC, "0_Weapon_M_Middle");
        iModelBottom = GetLocalInt (oPC, "0_Weapon_M_Bottom");
        // Get each color and save to variables.
        iColorTop = GetLocalInt (oPC, "0_Weapon_C_Top");
        iColorMiddle = GetLocalInt (oPC, "0_Weapon_C_Middle");
        iColorBottom = GetLocalInt (oPC, "0_Weapon_C_Bottom");
        // Move the weapon to a chest.
        // Get the Building container.
        oBuildContainer = GetObjectByTag (TEMP_CHEST);
        // Move the item to the building container.
        oItem1 = CopyItem (oItem, oBuildContainer, TRUE);
        // Remove the original item.
        DestroyObject (oItem);
        // Change the weapon.
        oItem2 = CopyItemAndModify (oItem1, ITEM_APPR_TYPE_WEAPON_MODEL, ITEM_APPR_WEAPON_MODEL_TOP, iModelTop, TRUE);
        DestroyObject (oItem1);
        oItem3 = CopyItemAndModify (oItem2, ITEM_APPR_TYPE_WEAPON_MODEL, ITEM_APPR_WEAPON_MODEL_MIDDLE, iModelMiddle, TRUE);
        DestroyObject (oItem2, 0.2f);
        oItem4 = CopyItemAndModify (oItem3, ITEM_APPR_TYPE_WEAPON_MODEL, ITEM_APPR_WEAPON_MODEL_BOTTOM, iModelBottom, TRUE);
        DestroyObject (oItem3, 0.4f);
        oItem5 = CopyItemAndModify (oItem4, ITEM_APPR_TYPE_WEAPON_COLOR, ITEM_APPR_WEAPON_COLOR_TOP, iColorTop, TRUE);
        DestroyObject (oItem4, 0.6f);
        oItem6 = CopyItemAndModify (oItem5, ITEM_APPR_TYPE_WEAPON_COLOR, ITEM_APPR_WEAPON_COLOR_MIDDLE, iColorMiddle, TRUE);
        DestroyObject (oItem5, 0.8f);
        oItem7 = CopyItemAndModify (oItem6, ITEM_APPR_TYPE_WEAPON_COLOR, ITEM_APPR_WEAPON_COLOR_BOTTOM, iColorBottom, TRUE);
        DestroyObject (oItem6, 1.f);
        // Move the item back to the PC.
        // Put the item back.
        oItemDone = CopyItem (oItem7, oTarget, TRUE);
        DestroyObject (oItem7);
        // Equip new item.
        AssignCommand (oTarget, ActionEquipItem (oItemDone, INVENTORY_SLOT_RIGHTHAND));
    }
    // Armor.
    else if (nSelected == 0)
    {
        // Move the armor to a chest.
        // Get the Building container.
        oBuildContainer = GetObjectByTag (TEMP_CHEST);
        // Move the item to the building container.
        oItem1 = CopyItem (oItem, oBuildContainer, TRUE);
        // Remove the original item.
        DestroyObject (oItem);
        // Get each model & save to variables.
        iModel = GetLocalInt (oPC, "0_Armor_Belt");
        oItem2 = CopyItemAndModify (oItem1, ITEM_APPR_TYPE_ARMOR_MODEL, ITEM_APPR_ARMOR_MODEL_BELT, iModel, TRUE);
        DestroyObject (oItem1);
        iModel = GetLocalInt (oPC, "0_Armor_LBicep");
        oItem3 = CopyItemAndModify (oItem2, ITEM_APPR_TYPE_ARMOR_MODEL, ITEM_APPR_ARMOR_MODEL_LBICEP, iModel, TRUE);
        DestroyObject (oItem2, 0.2f);
        iModel = GetLocalInt (oPC, "0_Armor_LFoot");
        oItem4 = CopyItemAndModify (oItem3, ITEM_APPR_TYPE_ARMOR_MODEL, ITEM_APPR_ARMOR_MODEL_LFOOT, iModel, TRUE);
        DestroyObject (oItem3, 0.4f);
        iModel = GetLocalInt (oPC, "0_Armor_LForearm");
        oItem5 = CopyItemAndModify (oItem4, ITEM_APPR_TYPE_ARMOR_MODEL, ITEM_APPR_ARMOR_MODEL_LFOREARM, iModel, TRUE);
        DestroyObject (oItem4, 0.6f);
        iModel = GetLocalInt (oPC, "0_Armor_LHand");
        oItem6 = CopyItemAndModify (oItem5, ITEM_APPR_TYPE_ARMOR_MODEL, ITEM_APPR_ARMOR_MODEL_LHAND, iModel, TRUE);
        DestroyObject (oItem5, 0.8f);
        iModel = GetLocalInt (oPC, "0_Armor_LShin");
        oItem7 = CopyItemAndModify (oItem6, ITEM_APPR_TYPE_ARMOR_MODEL, ITEM_APPR_ARMOR_MODEL_LSHIN, iModel, TRUE);
        DestroyObject (oItem6, 1.0f);
        iModel = GetLocalInt (oPC, "0_Armor_LShoulder");
        oItem8 = CopyItemAndModify (oItem7, ITEM_APPR_TYPE_ARMOR_MODEL, ITEM_APPR_ARMOR_MODEL_LSHOULDER, iModel, TRUE);
        DestroyObject (oItem7, 1.2f);
        iModel = GetLocalInt (oPC, "0_Armor_LThigh");
        oItem9 = CopyItemAndModify (oItem8, ITEM_APPR_TYPE_ARMOR_MODEL, ITEM_APPR_ARMOR_MODEL_LTHIGH, iModel, TRUE);
        DestroyObject (oItem8, 1.4f);
        iModel = GetLocalInt (oPC, "0_Armor_Neck");
        oItem10 = CopyItemAndModify (oItem9, ITEM_APPR_TYPE_ARMOR_MODEL, ITEM_APPR_ARMOR_MODEL_NECK, iModel, TRUE);
        DestroyObject (oItem9, 1.6f);
        iModel = GetLocalInt (oPC, "0_Armor_Pelvis");
        oItem11 = CopyItemAndModify (oItem10, ITEM_APPR_TYPE_ARMOR_MODEL, ITEM_APPR_ARMOR_MODEL_PELVIS, iModel, TRUE);
        DestroyObject (oItem10, 1.8f);
        iModel = GetLocalInt (oPC, "0_Armor_RBicep");
        oItem12 = CopyItemAndModify (oItem11, ITEM_APPR_TYPE_ARMOR_MODEL, ITEM_APPR_ARMOR_MODEL_RBICEP, iModel, TRUE);
        DestroyObject (oItem11, 2.0f);
        iModel = GetLocalInt (oPC, "0_Armor_RFoot");
        oItem13 = CopyItemAndModify (oItem12, ITEM_APPR_TYPE_ARMOR_MODEL, ITEM_APPR_ARMOR_MODEL_RFOOT, iModel, TRUE);
        DestroyObject (oItem12, 2.2f);
        iModel = GetLocalInt (oPC, "0_Armor_RForearm");
        oItem14 = CopyItemAndModify (oItem13, ITEM_APPR_TYPE_ARMOR_MODEL, ITEM_APPR_ARMOR_MODEL_RFOREARM, iModel, TRUE);
        DestroyObject (oItem13, 2.4f);
        iModel = GetLocalInt (oPC, "0_Armor_RHand");
        oItem15 = CopyItemAndModify (oItem14, ITEM_APPR_TYPE_ARMOR_MODEL, ITEM_APPR_ARMOR_MODEL_RHAND, iModel, TRUE);
        DestroyObject (oItem14, 2.6f);
        iModel = GetLocalInt (oPC, "0_Armor_Robe");
        oItem16 = CopyItemAndModify (oItem15, ITEM_APPR_TYPE_ARMOR_MODEL, ITEM_APPR_ARMOR_MODEL_ROBE, iModel, TRUE);
        DestroyObject (oItem15, 2.8f);
        iModel = GetLocalInt (oPC, "0_Armor_RShin");
        oItem17 = CopyItemAndModify (oItem16, ITEM_APPR_TYPE_ARMOR_MODEL, ITEM_APPR_ARMOR_MODEL_RSHIN, iModel, TRUE);
        DestroyObject (oItem16, 3.0f);
        iModel = GetLocalInt (oPC, "0_Armor_RShoulder");
        oItem18 = CopyItemAndModify (oItem17, ITEM_APPR_TYPE_ARMOR_MODEL, ITEM_APPR_ARMOR_MODEL_RSHOULDER, iModel, TRUE);
        DestroyObject (oItem17, 3.2f);
        iModel = GetLocalInt (oPC, "0_Armor_RThigh");
        oItem19 = CopyItemAndModify (oItem18, ITEM_APPR_TYPE_ARMOR_MODEL, ITEM_APPR_ARMOR_MODEL_RTHIGH, iModel, TRUE);
        DestroyObject (oItem18, 3.4f);
        iModel = GetLocalInt (oPC, "0_Armor_Torso");
        oItem20 = CopyItemAndModify (oItem19, ITEM_APPR_TYPE_ARMOR_MODEL, ITEM_APPR_ARMOR_MODEL_TORSO, iModel, TRUE);
        DestroyObject (oItem19, 3.6f);
        // Change armors color.
        iColor = GetLocalInt (oPC, "0_Armor_Cloth1");
        oItem21 = CopyItemAndModify (oItem20, ITEM_APPR_TYPE_ARMOR_COLOR, ITEM_APPR_ARMOR_COLOR_CLOTH1, iColor, TRUE);
        DestroyObject (oItem20, 3.6f);
        iColor = GetLocalInt (oPC, "0_Armor_Cloth2");
        oItem22 = CopyItemAndModify (oItem21, ITEM_APPR_TYPE_ARMOR_COLOR, ITEM_APPR_ARMOR_COLOR_CLOTH2, iColor, TRUE);
        DestroyObject (oItem21, 3.6f);
        iColor = GetLocalInt (oPC, "0_Armor_Leather1");
        oItem23 = CopyItemAndModify (oItem22, ITEM_APPR_TYPE_ARMOR_COLOR, ITEM_APPR_ARMOR_COLOR_LEATHER1, iColor, TRUE);
        DestroyObject (oItem22, 3.6f);
        iColor = GetLocalInt (oPC, "0_Armor_Leather2");
        oItem24 = CopyItemAndModify (oItem23, ITEM_APPR_TYPE_ARMOR_COLOR, ITEM_APPR_ARMOR_COLOR_LEATHER2, iColor, TRUE);
        DestroyObject (oItem23, 3.6f);
        iColor = GetLocalInt (oPC, "0_Armor_Metal1");
        oItem25 = CopyItemAndModify (oItem24, ITEM_APPR_TYPE_ARMOR_COLOR, ITEM_APPR_ARMOR_COLOR_METAL1, iColor, TRUE);
        DestroyObject (oItem24, 3.6f);
        iColor = GetLocalInt (oPC, "0_Armor_Metal2");
        oItem26 = CopyItemAndModify (oItem25, ITEM_APPR_TYPE_ARMOR_COLOR, ITEM_APPR_ARMOR_COLOR_METAL2, iColor, TRUE);
        DestroyObject (oItem25, 3.6f);
        // Move the item back to the PC.
        // Put the item back.
        oItemDone = CopyItem (oItem26, oTarget, TRUE);
        DestroyObject (oItem26);
        // Equip new item.
        AssignCommand (oTarget, ActionEquipItem (oItemDone, INVENTORY_SLOT_CHEST));
    }
    else
    {
        // Move the item to a chest.
        // Get the Building container.
        oBuildContainer = GetObjectByTag (TEMP_CHEST);
        // Move the item to the building container.
        oItem1 = CopyItem (oItem, oBuildContainer, TRUE);
        // Remove the original item.
        DestroyObject (oItem);
        // Get each model & save to variables.
        iModel = GetLocalInt (oPC, "0_Item_Model");
        oItem2 = CopyItemAndModify (oItem1, ITEM_APPR_TYPE_SIMPLE_MODEL, 0, iModel, TRUE);
        DestroyObject (oItem1);
        // Change item's color.
        iColor = GetLocalInt (oPC, "0_Item_C_Cloth_1");
        oItem3 = CopyItemAndModify (oItem2, ITEM_APPR_TYPE_ARMOR_COLOR, ITEM_APPR_ARMOR_COLOR_CLOTH1, iColor, TRUE);
        DestroyObject (oItem2, 3.6f);
        iColor = GetLocalInt (oPC, "0_Item_C_Cloth_2");
        oItem4 = CopyItemAndModify (oItem3, ITEM_APPR_TYPE_ARMOR_COLOR, ITEM_APPR_ARMOR_COLOR_CLOTH2, iColor, TRUE);
        DestroyObject (oItem3, 3.6f);
        iColor = GetLocalInt (oPC, "0_Item_C_Leather_1");
        oItem5 = CopyItemAndModify (oItem4, ITEM_APPR_TYPE_ARMOR_COLOR, ITEM_APPR_ARMOR_COLOR_LEATHER1, iColor, TRUE);
        DestroyObject (oItem4, 3.6f);
        iColor = GetLocalInt (oPC, "0_Item_C_Leather_2");
        oItem6 = CopyItemAndModify (oItem5, ITEM_APPR_TYPE_ARMOR_COLOR, ITEM_APPR_ARMOR_COLOR_LEATHER2, iColor, TRUE);
        DestroyObject (oItem5, 3.6f);
        iColor = GetLocalInt (oPC, "0_Item_C_Metal_1");
        oItem7 = CopyItemAndModify (oItem6, ITEM_APPR_TYPE_ARMOR_COLOR, ITEM_APPR_ARMOR_COLOR_METAL1, iColor, TRUE);
        DestroyObject (oItem6, 3.6f);
        iColor = GetLocalInt (oPC, "0_Item_C_Metal_2");
        oItem8 = CopyItemAndModify (oItem7, ITEM_APPR_TYPE_ARMOR_COLOR, ITEM_APPR_ARMOR_COLOR_METAL2, iColor, TRUE);
        DestroyObject (oItem7, 3.6f);
        // Move the item back to the PC.
        // Put the item back.
        oItemDone = CopyItem (oItem8, oTarget, TRUE);
        DestroyObject (oItem8);
        // Equip new item.
        int iItemType = GetBaseItemType (oItemDone);
        if (iItemType == BASE_ITEM_CLOAK) AssignCommand (oTarget, ActionEquipItem (oItemDone, INVENTORY_SLOT_CLOAK));
        else if (iItemType == BASE_ITEM_HELMET) AssignCommand (oTarget, ActionEquipItem (oItemDone, INVENTORY_SLOT_HEAD));
    }
    // Send message that it has been copied.
    AssignCommand (oPC, SendMessages (GetName (oItemDone) + " appearance has been changed!", COLOR_GREEN, oPC));
    return oItemDone;
}

int GetItemSelectedEquipSlot (int nItemSelected)
{
    if (nItemSelected == 0) return INVENTORY_SLOT_CHEST;
    if (nItemSelected == 1) return INVENTORY_SLOT_CLOAK;
    if (nItemSelected == 2) return INVENTORY_SLOT_HEAD;
    if (nItemSelected == 3) return INVENTORY_SLOT_RIGHTHAND;
    if (nItemSelected == 4) return INVENTORY_SLOT_LEFTHAND;
    return INVENTORY_SLOT_CHEST;
}

int GetArmorModelSelected (object oPC)
{
    int nModelSelected = GetLocalInt (oPC, "0_CRAFT_MODEL_SELECTION");
    if (nModelSelected == 0) return ITEM_APPR_ARMOR_MODEL_NECK;
    if (nModelSelected == 1) return ITEM_APPR_ARMOR_MODEL_RSHOULDER;
    if (nModelSelected == 2) return ITEM_APPR_ARMOR_MODEL_RBICEP;
    if (nModelSelected == 3) return ITEM_APPR_ARMOR_MODEL_RFOREARM;
    if (nModelSelected == 4) return ITEM_APPR_ARMOR_MODEL_RHAND;
    if (nModelSelected == 5) return ITEM_APPR_ARMOR_MODEL_TORSO;
    if (nModelSelected == 6) return ITEM_APPR_ARMOR_MODEL_BELT;
    if (nModelSelected == 7) return ITEM_APPR_ARMOR_MODEL_PELVIS;
    if (nModelSelected == 8) return ITEM_APPR_ARMOR_MODEL_RTHIGH;
    if (nModelSelected == 9) return ITEM_APPR_ARMOR_MODEL_RSHIN;
    if (nModelSelected == 10) return ITEM_APPR_ARMOR_MODEL_RFOOT;
    return ITEM_APPR_ARMOR_MODEL_ROBE;
}

object ChangeItemsAppearance (object oPC, object oTarget, int nToken, object oItem, int nDirection)
{
    // Get the item we are changing.
    int nModelSelected, nModel, nMaxModel, nColor, nMaxColor;
    int nItemSelected = GetLocalInt (oPC, "0_CRAFT_ITEM_SELECTION");
    object oNewItem, oNewItem2;
    SetLocalInt (oItem, "0_EQUIP_LOCKED", FALSE);
    // Weapons.
    if (GetIsWeapon (oItem))
    {
        string sColumn;
        nModelSelected = GetLocalInt (oPC, "0_CRAFT_MODEL_SELECTION");
        // Get the column so we can get the max model.
        if (nModelSelected == 0) sColumn = "BottomModel";
        else if (nModelSelected == 1) sColumn = "MiddleModel";
        else if (nModelSelected == 2) sColumn = "TopModel";
        // Get the maximum model and color for the weapon.
        nMaxModel = GetItemsMaxModels (oItem, sColumn);
        nMaxColor = GetItemsMaxModels (oItem, "Color");
        // Get the model and color of the weapon model.
        nModel = GetItemAppearance (oItem, ITEM_APPR_TYPE_WEAPON_MODEL, nModelSelected);
        nColor = GetItemAppearance (oItem, ITEM_APPR_TYPE_WEAPON_COLOR, nModelSelected);
        // Get next/previous color.
        nColor = nColor + nDirection;
        if (nColor > nMaxColor) nColor = 1;
        else if (nColor < 1) nColor = nMaxColor;
        // If the color rolls over to a new model then change the model.
        if ((nDirection == 1 && nColor == 1) || (nDirection == -1 && nColor == nMaxColor))
        {
            // Get next/previous model.
            nModel = nModel + nDirection;
            if (nModel > nMaxModel) nModel = 1;
            else if (nModel < 1) nModel = nMaxModel;
            if (JsonGetString (NuiGetBind (oPC, nToken, "craft_warning_label")) != "CANNOT CRAFT!")
            {
                NuiSetBind (oPC, nToken, "craft_warning_label", JsonString ("Model # " + IntToString (nModel)));
            }
            oNewItem2 = CopyItemAndModify (oItem, ITEM_APPR_TYPE_WEAPON_MODEL, nModelSelected, nModel, TRUE);
            DestroyObject (oItem);
            oNewItem = CopyItemAndModify (oNewItem2, ITEM_APPR_TYPE_WEAPON_COLOR, nModelSelected, nColor, TRUE);
            DestroyObject (oNewItem2);
        }
        else
        {
            oNewItem = CopyItemAndModify (oItem, ITEM_APPR_TYPE_WEAPON_COLOR, nModelSelected, nColor, TRUE);
            DestroyObject (oItem);
        }
        // Item selected 3 is the right hand, 4 is the left hand.
        if (nItemSelected == 3) AssignCommand (oTarget, ActionEquipItem (oNewItem, INVENTORY_SLOT_RIGHTHAND));
        else AssignCommand (oTarget, ActionEquipItem (oNewItem, INVENTORY_SLOT_LEFTHAND));
    }
    // Armor.
    else if (nItemSelected == 0)
    {
        // Get the selected model.
        nModelSelected = GetArmorModelSelected (oPC);
        // Get if we are doing the left/right or linking both together.
        int nModelSide = GetLocalInt (oPC, "0_MODEL_SPECIAL");
        // These models only have one side so make sure we are not linked.
        if (nModelSelected == ITEM_APPR_ARMOR_MODEL_NECK ||
            nModelSelected == ITEM_APPR_ARMOR_MODEL_BELT ||
            nModelSelected == ITEM_APPR_ARMOR_MODEL_PELVIS ||
            nModelSelected == ITEM_APPR_ARMOR_MODEL_ROBE)
        {
            nModelSide = 1;
        }
        // If we are doing the left side then add one to get the left side.
        // Note: Right Thigh and Left Thigh are backwards so this fixes that!
        if (nModelSide == 2)
        {
            if (nModelSelected == ITEM_APPR_ARMOR_MODEL_RTHIGH) nModelSelected = nModelSelected - 1;
            else nModelSelected = nModelSelected + 1;
        }
        nMaxModel = StringToInt (Get2DAString ("armor_parts", "NumParts", nModelSelected));
        string sPart2daName = (Get2DAString ("armor_parts", "Part_Name", nModelSelected));
        nModel = GetItemAppearance (oItem, ITEM_APPR_TYPE_ARMOR_MODEL, nModelSelected);
        // Check for changes to the torso (base part of the armor linked to AC).
        if (nModelSelected == ITEM_APPR_ARMOR_MODEL_TORSO)
        {
            int nCurrentArmorBonus = NWNX_Item_GetBaseArmorClass (oItem);
            // Get the next or previous model that has the same AC and is valid.
            nModel = nModel + nDirection;
            if (nModel > nMaxModel) nModel = 0;
            else if (nModel < 0) nModel = nMaxModel;
            string sACBonus = Get2DAString (sPart2daName, "ACBONUS", nModel);
            int nACBonus = StringToInt (sACBonus);
            while (nACBonus != nCurrentArmorBonus || sACBonus == "")
            {
                nModel = nModel + nDirection;
                if (nModel > nMaxModel) nModel = 0;
                else if (nModel < 0) nModel = nMaxModel;
                sACBonus = Get2DAString (sPart2daName, "ACBONUS", nModel);
                nACBonus = StringToInt (sACBonus);
            }
            if (JsonGetString (NuiGetBind (oPC, nToken, "craft_warning_label")) != "CANNOT CRAFT!")
            {
                NuiSetBind (oPC, nToken, "craft_warning_label", JsonString ("Model # " + IntToString (nModel)));
            }
            // Change the model.
            oNewItem = CopyItemAndModify (oItem, ITEM_APPR_TYPE_ARMOR_MODEL, nModelSelected, nModel, TRUE);
            DestroyObject (oItem);
            AssignCommand (oTarget, ActionEquipItem (oNewItem, INVENTORY_SLOT_CHEST));
        }
        // Change all other parts of armor.
        else
        {
            // Get the next or previous model that is valid.
            nModel = nModel + nDirection;
            if (nModel > nMaxModel) nModel = 0;
            else if (nModel < 0) nModel = nMaxModel;
            string sACBonus = Get2DAString (sPart2daName, "ACBONUS", nModel);
            while (sACBonus == "")
            {
                nModel = nModel + nDirection;
                if (nModel > nMaxModel) nModel = 0;
                else if (nModel < 0) nModel = nMaxModel;
                sACBonus = Get2DAString (sPart2daName, "ACBONUS", nModel);
            }
            if (JsonGetString (NuiGetBind (oPC, nToken, "craft_warning_label")) != "CANNOT CRAFT!")
            {
                NuiSetBind (oPC, nToken, "craft_warning_label", JsonString ("Model # " + IntToString (nModel)));
            }
            // We set which model is selected above.
            oNewItem = CopyItemAndModify (oItem, ITEM_APPR_TYPE_ARMOR_MODEL, nModelSelected, nModel, TRUE);
            DestroyObject (oItem);
            oItem = oNewItem;
            // If linked then change the left side too.
            if (nModelSide == 0)
            {
                // Note: Right Thigh and Left Thigh are backwards so this fixes that!
                if (nModelSelected == ITEM_APPR_ARMOR_MODEL_RTHIGH) nModelSelected = nModelSelected - 1;
                else nModelSelected = nModelSelected + 1;
                oNewItem = CopyItemAndModify (oItem, ITEM_APPR_TYPE_ARMOR_MODEL, nModelSelected, nModel, TRUE);
                DestroyObject (oItem);
                AssignCommand (oTarget, ActionEquipItem (oNewItem, INVENTORY_SLOT_CHEST));
            }
            else AssignCommand (oTarget, ActionEquipItem (oItem, INVENTORY_SLOT_CHEST));
        }
    }
    // All other items.
    else
    {
        int nSlot, nBaseItem = GetBaseItemType (oItem);
        // Get max models and inventory slot.
        if (nBaseItem == BASE_ITEM_CLOAK)
        {
            nMaxModel = 107;
            nSlot = INVENTORY_SLOT_CLOAK;
        }
        else if (nBaseItem == BASE_ITEM_HELMET)
        {
            nMaxModel = 62;
            nSlot = INVENTORY_SLOT_HEAD;
        }
        else if (nBaseItem == BASE_ITEM_LARGESHIELD || nBaseItem == BASE_ITEM_SMALLSHIELD ||
                 nBaseItem == BASE_ITEM_TOWERSHIELD)
        {
            nSlot = INVENTORY_SLOT_LEFTHAND;
            if (nBaseItem == BASE_ITEM_SMALLSHIELD) nMaxModel = 64;
            else if (nBaseItem == BASE_ITEM_LARGESHIELD) nMaxModel = 163;
            else if (nBaseItem == BASE_ITEM_TOWERSHIELD) nMaxModel = 124;
        }
        nModel = GetItemAppearance (oItem, ITEM_APPR_TYPE_SIMPLE_MODEL, 0);
        nModel = nModel + nDirection;
        if (nModel > nMaxModel) nModel = 0;
        else if (nModel < 0) nModel = nMaxModel;
        if (JsonGetString (NuiGetBind (oPC, nToken, "craft_warning_label")) != "CANNOT CRAFT!")
        {
            NuiSetBind (oPC, nToken, "craft_warning_label", JsonString ("Model # " + IntToString (nModel)));
        }
        oNewItem = CopyItemAndModify (oItem, ITEM_APPR_TYPE_SIMPLE_MODEL, 0, nModel, TRUE);
        DestroyObject (oItem);
        AssignCommand (oTarget, ActionEquipItem (oNewItem, nSlot));
    }
    return oNewItem;
}

// Checks to see if the item can be crafted.
int CanCraftItem (object oPC, object oItem, int nToken, int bPasteCheck = FALSE)
{
    if (oItem == OBJECT_INVALID)
    {
         SendMessages ("You must have an item equiped!", COLOR_RED, oPC);
         return FALSE;
    }
    // Plot items cannot be changed.
    if (GetPlotFlag (oItem))
    {
         SendMessages (GetName (oItem) + "is a plot item and its appearance cannot be changed!", COLOR_RED, oPC);
         return FALSE;
    }
    // Check to see if the weapon can be changed i.e. special appearances.
    if (GetIsWeapon (oItem))
    {
        int nModel = GetItemAppearance (oItem, ITEM_APPR_TYPE_WEAPON_MODEL, ITEM_APPR_WEAPON_MODEL_TOP);
        int nMaxModel = GetItemsMaxModels (oItem, "TopModel");
        if (nModel > nMaxModel)
        {
            SendMessages (GetName (oItem) + "'s special appearance cannot be changed!", COLOR_RED, oPC);
            return FALSE;
        }
    }
    // Cannot change Head_Gear as they are visual effects and not Models.
    int nItemType = GetBaseItemType (oItem);
    if (nItemType == 23/*BASE_ITEM_HEAD_GEAR*/)
    {
        SendMessages (GetName (oItem) + " is a visual effect item and cannot be changed!", COLOR_RED, oPC);
        return FALSE;
    }
    // Cannot change temorary enchanted items.
    if (CheckForTemporaryItemProperty (oItem))
    {
        SendMessages (GetName (oItem) + " cannot be altered while it has a temporary enchantment.", COLOR_RED, oPC);
        return FALSE;
    }
    // Do special paste checks.
    if (bPasteCheck)
    {
        int nOldItemType = GetLocalInt (oPC, "0_Craft_Item_Type");
        int nNewItemType = GetBaseItemType (oItem);
        if (GetIsWeapon (oItem))
        {
            if (nOldItemType != nNewItemType)
            {
                string sOldBaseItem = GetStringByStrRef (StringToInt (Get2DAString ("baseitems", "Name", nOldItemType)));
                string sNewBaseItem = GetStringByStrRef (StringToInt (Get2DAString ("baseitems", "Name", nNewItemType)));
                SendMessages ("You copied a " + sOldBaseItem + " and are trying to paste to a " + sNewBaseItem + "!", COLOR_RED, oPC);
                return FALSE;
            }
        }
        // Armor.
        else if (nNewItemType == BASE_ITEM_ARMOR)
        {
            if (GetLocalInt (oPC, "0_Armor_AC") != NWNX_Item_GetBaseArmorClass (oItem))
            {
                SendMessages ("The armor you are trying to paste to is not the same type as the copy!", COLOR_RED, oPC);
                return FALSE;
            }
        }
        else if (nOldItemType == nNewItemType)
        {
            string sOldBaseItem = GetStringByStrRef (StringToInt (Get2DAString ("baseitems", "Name", nOldItemType)));
            string sNewBaseItem = GetStringByStrRef (StringToInt (Get2DAString ("baseitems", "Name", nNewItemType)));
            SendMessages ("You copied a " + sOldBaseItem + " and are trying to paste to a " + sNewBaseItem + "!", COLOR_RED, oPC);
            return FALSE;
        }
    }
    if (GetLocalObject (oPC, "0_ORIGINAL_CRAFT_ITEM") == OBJECT_INVALID)
    {
        object oBuildContainer = GetObjectByTag (TEMP_CHEST);
        object oBackup = CopyItem (oItem, oBuildContainer, TRUE);
        // Save the original item to the PC.
        SetLocalObject (oPC, "0_ORIGINAL_CRAFT_ITEM", oBackup);
        // Check ranks required with characters ranks.
        int nRanksRequired;
        // Armor.
        if (nItemType == BASE_ITEM_ARMOR) nRanksRequired = NWNX_Item_GetBaseArmorClass (oItem);
        // All other items.
        else nRanksRequired = StringToInt (Get2DAString ("smi_list", "CraftDC", nItemType)) - 10;
        SetLocalInt (oPC, "0_RANKS_REQUIRED", nRanksRequired);
        NuiSetBind (oPC, nToken, "craft_required_label", JsonString ("Ranks required: " + IntToString (nRanksRequired)));
        int nRanks = GetSkillRank (SKILL_CRAFTING, oPC, TRUE);
        // Check to see if the players has enough ranks.
        if (nRanksRequired > nRanks) NuiSetBind (oPC, nToken, "craft_warning_label", JsonString ("CANNOT CRAFT!"));
        else NuiSetBind (oPC, nToken, "craft_warning_label", JsonString (""));
    }
    return TRUE;
}

object RandomizeItemsCraftAppearance (object oPlayer, object oTarget, int nToken, object oItem)
{
    // Get the item we are changing.
    int nModelSelected, nModel, nMaxModel, nColor, nMaxColor;
    int nItemSelected = GetLocalInt (oPlayer, "0_CRAFT_ITEM_SELECTION");
    object oNewItem;
    SetLocalInt (oItem, "0_EQUIP_LOCKED", FALSE);
    if (GetIsWeapon (oItem))
    {
        // Get the items quality.
        // For craft randomizing just randomize from all options!
        itemproperty ipQuality = HasProperty (oItem, 86);
        int iQuality = GetItemPropertyCostTableValue (ipQuality);
        oNewItem = ChangeItemAppearance (oItem, iQuality);
        if (nItemSelected == 3) AssignCommand (oTarget, ActionEquipItem (oNewItem, INVENTORY_SLOT_RIGHTHAND));
        else if (nItemSelected == 4) AssignCommand (oTarget, ActionEquipItem (oNewItem, INVENTORY_SLOT_LEFTHAND));
    }
    // Armor.
    else if (nItemSelected == 0)
    {
        object oItem1 = CopyItemAndModify (oItem, ITEM_APPR_TYPE_ARMOR_COLOR, ITEM_APPR_ARMOR_COLOR_LEATHER1, Random (175) + 1, TRUE);
        DestroyObject (oItem);
        object oItem2 = CopyItemAndModify (oItem1, ITEM_APPR_TYPE_ARMOR_COLOR, ITEM_APPR_ARMOR_COLOR_LEATHER2, Random (175) + 1, TRUE);
        DestroyObject (oItem1);
        object oItem3 = CopyItemAndModify (oItem2, ITEM_APPR_TYPE_ARMOR_COLOR, ITEM_APPR_ARMOR_COLOR_CLOTH1, Random (175) + 1, TRUE);
        DestroyObject (oItem2);
        object oItem4 = CopyItemAndModify (oItem3, ITEM_APPR_TYPE_ARMOR_COLOR, ITEM_APPR_ARMOR_COLOR_CLOTH2, Random (175) + 1, TRUE);
        DestroyObject (oItem3);
        object oItem5 = CopyItemAndModify (oItem4, ITEM_APPR_TYPE_ARMOR_COLOR, ITEM_APPR_ARMOR_COLOR_METAL1, Random (175) + 1, TRUE);
        DestroyObject (oItem4);
        oNewItem = CopyItemAndModify (oItem5, ITEM_APPR_TYPE_ARMOR_COLOR, ITEM_APPR_ARMOR_COLOR_METAL2, Random (175) + 1, TRUE);
        DestroyObject (oItem5);
        AssignCommand (oTarget, ActionEquipItem (oNewItem, INVENTORY_SLOT_CHEST));
    }
    // All other items.
    else
    {
        int nSlot, nBaseItem = GetBaseItemType (oItem);
        // Get max models and inventory slot.
        if (nBaseItem == BASE_ITEM_CLOAK)
        {
            nMaxModel = 107;
            nSlot = INVENTORY_SLOT_CLOAK;
        }
        else if (nBaseItem == BASE_ITEM_HELMET)
        {
            nMaxModel = 62;
            nSlot = INVENTORY_SLOT_HEAD;
        }
        else if (nBaseItem == BASE_ITEM_LARGESHIELD || nBaseItem == BASE_ITEM_SMALLSHIELD ||
                 nBaseItem == BASE_ITEM_TOWERSHIELD)
        {
            nSlot = INVENTORY_SLOT_LEFTHAND;
            if (nBaseItem == BASE_ITEM_SMALLSHIELD) nMaxModel = 64;
            else if (nBaseItem == BASE_ITEM_LARGESHIELD) nMaxModel = 163;
            else if (nBaseItem == BASE_ITEM_TOWERSHIELD) nMaxModel = 124;
        }
        nModel = Random (nMaxModel) + 1;
        object oItem1 = CopyItemAndModify (oItem, ITEM_APPR_TYPE_SIMPLE_MODEL, 0, nModel, TRUE);
        DestroyObject (oItem);
        if (nBaseItem == BASE_ITEM_CLOAK || nBaseItem == BASE_ITEM_HELMET)
        {
            object oItem2 = CopyItemAndModify (oItem1, ITEM_APPR_TYPE_ARMOR_COLOR, ITEM_APPR_ARMOR_COLOR_LEATHER1, Random (175) + 1, TRUE);
            DestroyObject (oItem1);
            object oItem3 = CopyItemAndModify (oItem2, ITEM_APPR_TYPE_ARMOR_COLOR, ITEM_APPR_ARMOR_COLOR_LEATHER2, Random (175) + 1, TRUE);
            DestroyObject (oItem2);
            object oItem4 = CopyItemAndModify (oItem3, ITEM_APPR_TYPE_ARMOR_COLOR, ITEM_APPR_ARMOR_COLOR_CLOTH1, Random (175) + 1, TRUE);
            DestroyObject (oItem3);
            object oItem5 = CopyItemAndModify (oItem4, ITEM_APPR_TYPE_ARMOR_COLOR, ITEM_APPR_ARMOR_COLOR_CLOTH2, Random (175) + 1, TRUE);
            DestroyObject (oItem4);
            object oItem6 = CopyItemAndModify (oItem5, ITEM_APPR_TYPE_ARMOR_COLOR, ITEM_APPR_ARMOR_COLOR_METAL1, Random (175) + 1, TRUE);
            DestroyObject (oItem5);
            oNewItem = CopyItemAndModify (oItem6, ITEM_APPR_TYPE_ARMOR_COLOR, ITEM_APPR_ARMOR_COLOR_METAL2, Random (175) + 1, TRUE);
            DestroyObject (oItem6);
        }
        else
        {
            oNewItem = oItem1;
        }
        AssignCommand (oTarget, ActionEquipItem (oNewItem, nSlot));
        if (JsonGetString (NuiGetBind (oPlayer, nToken, "craft_warning_label")) != "CANNOT CRAFT!")
        {
            NuiSetBind (oPlayer, nToken, "craft_warning_label", JsonString ("Model # " + IntToString (nModel)));
        }
    }
    return oNewItem;
}

// Returns the correct item based on the crafting menu selected item.
object GetSelectedItem (object oTarget, int nItemSelected)
{
    if (nItemSelected == 0) return GetItemInSlot (INVENTORY_SLOT_CHEST, oTarget);
    else if (nItemSelected == 1) return GetItemInSlot (INVENTORY_SLOT_CLOAK, oTarget);
    else if (nItemSelected == 2) return GetItemInSlot (INVENTORY_SLOT_HEAD, oTarget);
    else if (nItemSelected == 3) return GetItemInSlot (INVENTORY_SLOT_RIGHTHAND, oTarget);
    else if (nItemSelected == 4) return GetItemInSlot (INVENTORY_SLOT_LEFTHAND, oTarget);
    return OBJECT_INVALID;
}

// Cancels the crafted item for the player and restoring the original.
void CancelCraftedItem (object oPlayer, object oTarget)
{
    int nItemSelected = GetLocalInt (oPlayer, "0_CRAFT_ITEM_SELECTION");
    object oItem = GetSelectedItem (oTarget, nItemSelected);
    SetLocalInt (oItem, "0_EQUIP_LOCKED", FALSE);
    DeleteLocalInt (oPlayer, "0_RANKS_REQUIRED");
    object oOriginalItem = GetLocalObject (oPlayer, "0_ORIGINAL_CRAFT_ITEM");
    if (oOriginalItem != OBJECT_INVALID)
    {
        DestroyObject (oItem);
        int nSlot = GetItemSelectedEquipSlot (nItemSelected);
        // Give item Backup to Player
        oOriginalItem = CopyItem (oOriginalItem, oTarget, TRUE);
        DelayCommand (0.2f, AssignCommand (oTarget, ActionEquipItem (oOriginalItem, nSlot)));
        DeleteLocalObject (oPlayer, "0_ORIGINAL_CRAFT_ITEM");
    }
}
