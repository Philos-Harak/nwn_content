/*////////////////////////////////////////////////
 Script: 0s_maj_creation
 Programmer: Philos
////////////////////////////////////////////////
Conjuration (Creation)
Level:  Sor/Wiz 5
Components: V, S, Focus
Casting Time:   1 standard action
Range:  Personal
Effect: One object.
Duration: Permanent.
Saving Throw: None
Spell Resistance: No

You create a nonmagical objects. The type of object created is based on the recipe you cast this spell on. The quality of the item is base on the casters level.
Level 1-13th Normal
Level 14-16th Masterwork
Level 17-19th Exquisite
Level 20-23rd Legendary
Level 24+ Relics

Material focus: The recipe for the object to be created.
/*////////////////////////////////////////////////////////
#include "0i_spells"
void main()
{
    // ***********************************************************
    // *************** Set Spell Structure ***********************
    // ***********************************************************
    // Setup the spell in the structured variables, then pass through the SetSpell function.
    Spell.iSubType = SUBTYPE_MAGICAL;
    Spell.iSubSchool = SUBSCHOOL_CREATION;
    Spell.iAreaShape = SHAPE_PERSONAL;
    // Setup the spell.
    Spell = SetSpell (Spell);
    // Check to see if we should still fire off the spell.
    if (Spell.iSpellID == STOP_SPELL) return;
    // *******************************************************************
    // ********************** Spell effects ******************************
    // *******************************************************************
    int iBaseItemType, iStack, iTagLength, iQuality;
    string sItem, sTag, sText;
    object oItem, oCraftChest, oNewItem;
    // Get the length of the books tag so we can pull the base item name from the tag.
    sTag = GetTag (Spell.oTarget);
    iTagLength = GetStringLength (sTag);
    // Get the base item name from the book tag.
    sItem = GetSubString (sTag, 6, iTagLength - 6);
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
            SetModuleError ("RESREF", "0s_maj_creation", "64", "Craft item: " + sItem);
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
    iBaseItemType = GetBaseItemType (oItem);
    // if the base item type is armor then change to the specific type of armor.
    if (iBaseItemType == BASE_ITEM_ARMOR)
    {
        if (sTag == "garb") iBaseItemType = 84;
        else if (sTag == "outfit") iBaseItemType = 85;
        else if (sTag == "robe") iBaseItemType = 86;
        else if (sTag == "runic") iBaseItemType = 87;
        else if (sTag == "padded") iBaseItemType = 88;
        else if (sTag == "leather") iBaseItemType = 89;
        else if (sTag == "stleather") iBaseItemType = 90;
        else if (sTag == "hide") iBaseItemType = 91;
        else if (sTag == "chainshirt") iBaseItemType = 92;
        else if (sTag == "scalemail") iBaseItemType = 93;
        else if (sTag == "chainmail") iBaseItemType = 94;
        else if (sTag == "breastplate") iBaseItemType = 95;
        else if (sTag == "splintmail") iBaseItemType = 96;
        else if (sTag == "bandedmail") iBaseItemType = 97;
        else if (sTag == "halfplate") iBaseItemType = 98;
        else if (sTag == "fullplate") iBaseItemType = 99;
    }
    // Create item and remove materials.
    oNewItem = CopyItem (oItem, Spell.oCaster, TRUE);
    iQuality = 0;
    /*/ Check for Artifact quality cannot do in spell.
    if (iCheck + iDC >= ITEM_QUALITY_ARTIFACT)
    {
        iQuality = 5;
        sText = "Artifact " + sText;
        sText = AddColorToText (sText, COLOR_ARTIFACT);
    } */
    // Check for Relic quality.
    if (Spell.iCasterLevel >= 24)
    {
        iQuality = 4;
        sText = "Relic " + sText;
        sText = AddColorToText (sText, COLOR_RELIC);
    }
    // Check for Legendary quality.
    else if (Spell.iCasterLevel >= 20)
    {
        iQuality = 3;
        sText = "Legendary " + sText;
        sText = AddColorToText (sText, COLOR_LEGENDARY);
    }
    // Check for Exquisite quality.
    else if (Spell.iCasterLevel >= 17)
    {
        iQuality = 2;
        sText = "Exquisite " + sText;
        sText = AddColorToText (sText, COLOR_EXQUISITE);
    }
    // Check for Master Work quality.
    else if (Spell.iCasterLevel >= 14)
    {
        iQuality = 1;
        sText = "Masterwork " + sText;
        sText = AddColorToText (sText, COLOR_MAGIC);
    }
    if (iQuality > 0)
    {
        itemproperty ipProperty = ItemPropertyQuality (iQuality);
        AddItemProperty (DURATION_TYPE_PERMANENT, ipProperty, oNewItem);
    }
    SendMessages ("You have created a " + sText + ".", COLOR_GREEN, Spell.oCaster, FALSE, FALSE);
    // Set the name of the item.
    SetName (oNewItem, sText);
    DestroyObject (oItem);
    CleanUpSpell (Spell);
}
