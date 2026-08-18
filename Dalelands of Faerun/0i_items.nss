/*////////////////////////////////////////////////////////////////////////////////////////////////////
Script Name: 0i_items
Programmer: Philos
//////////////////////////////////////////////////////////////////////////////////////////////////////
 Include scripts for use with items.

 Icon Numbers:
 Rings (1 - 232)
 Cloaks (normal 1 - 21 / group 22 - 31 / god 32 - 102 / unknown 103 - 115)
 Belts (1 - 110)
 Book (1 - 20)
 Bracers (1 - 78)
 Gems (1 - 71)
 Gloves (1 - 112)
 Sml Misc (1 - 107)
 Thin Misc (1 - 65)
 Mid Misc (1 - 169)
 Amulet (1 - 163)
 Small Box (1 - 14)
 Small Stackable (1 - 1)
 Shortswords T(12/4) M(6/4) B(6/4)
 Longswords  T(22/5) M(23/5) B(22/5)
*/////////////////////////////////////////////////////////////////////////////////////////////////////
#include "0i_master"
#include "0i_states"
#include "0i_checks"
#include "0i_database"
#include "nwnx_feedback"
#include "nwnx_creature"
#include "nwnx_object"
#include "nwnx_item"
#include "nwnx_itemprop"

// oItem to reduce the cost of.
// sTag to set the tag so it maybe removed later.
void AddCostReductionItemProperty(object oItem, string sTag);
// Return either the targets weapon or the weapon that is targeted.
// oTarget is the target selected.
object GetTargetedOrEquippedWeapon(object oTarget);
// Return either the targets armor/shield or the armor that is targeted.
// oTarget is the target selected.
object GetTargetedOrEquippedArmor(object oTarget);
// See if a creature has an item based on a specific tag.
// sTag is the tag of the item being looked for.
// bCheckEquiped will also look through the creatures equiped items.
// Returns the item if found or OBJECT_INVALID.
object GetCreatureHasItem(object oCreature, string sTag, int bCheckEquiped = FALSE);
// See if a creature has an item based on a specific resref.
// sResRef is the sResRef of the item being looked for.
// bCheckEquiped will also look through the creatures equiped items.
// Returns the item if found or OBJECT_INVALID.
object GetCreatureHasItemResRef(object oCreature, string sResRef, int bCheckEquiped = FALSE);
// Return TRUE if oItem is stackable.
int GetIsItemStackable(object oItem);
// Removes amount of items in any amount of stacks from a container.
// If it cannot remove them it returns false.
// oPC is the PC to report the removal from if oPC isn't a player then nothing is reported.
// oContainer is the container to remove the items from this maybe oPC.
// sItemTag is the tag of the item stacks to remove.
// iAmountToRemove is the amount of items to remove.
int RemoveItemStackFromContainer(object oPC, object oContainer, string sItemTag, int nAmountToRemove);
// Gets a pallet items resref randomly based on a 2da_table.
string RollBaseItemResRef(string s2da_table, object oPC = OBJECT_INVALID);
// Gets a basic set of armor based on 2da random charts.
string GetBaseArmor();
// Gets a basic shield based on 2da random charts.
string GetBasehield();
// Gets a weapon based on 2da random charts.
string GetBaseWeapon();
// Returns true if the item is a weapon.
int GetIsWeapon(object oItem);
// Returns true if the weapon is a melee weapon.
int GetIsMeleeWeapon(object oItem);
// Returns true if the weapon is a slashing weapon.
int GetIsSlashingWeapon(object oItem);
// Returns true if the weapon is a piercing weapon.
int GetIsPiercingWeapon(object oItem);
// Returns true if the weapon is a bludgeoning weapon.
int GetIsBludgeoningWeapon(object oItem);
// Returns true if the weapon is ammo.
int GetIsAmmo(object oItem);
// Returns true if the weapon is a thrown.
int GetIsThrownWeapon(object oItem);
// Returns true if the weapon is able to be used single handed by oCreature.
int GetIsSingleHandedWeapon(object oItem, object oCreature);
// Returns true if the weapon is a twohanded for oCreature.
int GetIsTwoHandedWeapon(object oItem, object oCreature);
// Returns true if they have ammo of currently equipped range weapon.
int HasRangedWeaponWithAmmo(object oCreature = OBJECT_SELF);
// Returns true if the weapon is a ranged weapon.
int GetIsRangeWeapon(object oItem);
// Returns true if the weapon is a finesse weapon.
int GetIsFinesseWeapon(object oItem);
// Returns true if the item is a shield.
int GetIsShield(object oItem);
// Returns true if they have an item with regeneration.
// bIsEquiped requires that the regeneration is working.
int GetHasRegeneration (object oPC, int bIsEquiped = FALSE);
// Gives appropriate ammo for the weapon given.
// If it doesn't use ammo then it will exit.
void GiveAmmoForWeapon(object oWeapon, object oContainer);
// Equips items for oCreature.
// If bDestroyDuplicate is TRUE then it destroys any items that it unequips.
// bAlwaysArmor is TRUE it gives oCreatures armor.
void EquipItems(object oCreature, int bDestroyDuplicate, int bAlwaysArmor = FALSE);
// ID's all drops on oTarget.
void IdDrops(object oTarget, int iIdentified = FALSE);
// Make all items on oTarget Id'ed or not Id'ed
// iID can be TRUE (Identified) or FALSE (Unidentified).
// iEquiped will check the creatures equiped items as well.
void IdAllInventory(object oTarget, int iID = TRUE, int iEquiped = FALSE);
// Returns oArmors armor bonus.
int GetArmorBonus(object oArmor);
// Returns the maximum gold value that an item can have to be equiped.
int GetMaxItemValueThatCanBeEquiped(int nLevel);
// Returns the minimum level that is required to equip this item.
int GetMinimumEquipLevel(object oItem);
// Make all items on oTarget Droppable or not Droppable
// bDroppable can be TRUE (Droppable) or FALSE (Not Droppable).
// nEquiped will check the creatures equiped items as well.
void SetDroppableFlagAllInventory(object oTarget, int bDroppable = TRUE, int nEquiped = FALSE);
// Gives oCreature a simple melee weapon.
object GiveSimpleMeleeWeapons(object oCreature);
// Gives oCreature a martial melee weapon.
object GiveMartialMeleeWeapons(object oCreature);
// Gives oCreature a exotic melee weapon.
object GiveExoticMeleeWeapons(object oCreature);
// Gives oCreature a simple melee weapon.
object GiveSimpleRangedWeapons(object oCreature);
// Gives oCreature a martial melee weapon.
object GiveMartialRangedWeapons(object oCreature);
// Gives oCreature a Onehanded and light weapon.
object GiveTwoWeaponStyleWeapons(object oCreature, int bDroppable);
// Gives oCreature a melee weapon that does d4.
object Gived4MeleeWeapons(object oCreature);
// Gives oCreature a melee weapon that does d6.
object Gived6MeleeWeapons(object oCreature);
// Gives oCreature a melee weapon that does d8.
object Gived8MeleeWeapons(object oCreature);
// Gives oCreature a melee weapon that does d10.
object Gived10MeleeWeapons(object oCreature);
// Gives oCreature a melee weapon that does d12.
object Gived12MeleeWeapons(object oCreature);
// Gives creature clothing.
object GiveClothing(object oCreature, int bDroppable = TRUE);
// Gives oCreature a set of light armor.
// iType: 0 - light, 1 - medium, 2 - heavy, 3 - light/medium
// 4 - medium/heavy, 5 - light/medium/heavy.
object GiveArmor(object oCreature, int iType = 0);
// Returns an items size based on 1-small to 6-large.
int GetItemSize(object oItem);
// Gives equipment to a creature based on their feats.
// oCreature is the creature to equip.
// iDroppable: TRUE will make the items drop, FALSE they will not.
// iItem allows you to select one item and get it returned.
// Arguments:
// BASE_ITEM_ARMOR = 16;
// BASE_ITEM_MELEE_WEAPON = 153;
// BASE_ITEM_RANGED_WEAPON = 154;
// BASE_ITEM_SHIELD = 161;
// iPackage is the package of the NPC class.
object GiveEquipment(object oCreature, int iDroppable = TRUE, int iItem = -1, int iPackage = PACKAGE_INVALID);
// Checks each item in a container and makes a roll to see if its breaks.
// Replaced with an appropriate broken item.
void CheckForBrokenItems(object oContainer);
// Get the items max models and max colors.
// oItem is the item to check.
// sPart is the part to get for:
// TopModel, MiddleModel, BottomModel - Used for weapon models.
// Color - Used for weapon colors.
int GetItemsMaxModels(object oItem, string sPart);
// Changes an items appearance this will remove the item sent
// and the new item put in its place.
// oContainer is where the original item is.
// oItem is the item to change.
// iQuality defines the different levels of item appearances.
// 1 = Master work, 2 = Exquisite, 3 = Legendary, 4 = Relic, 5 = Artifact.
object ChangeItemAppearance(object oItem, int iQuality = 0);
// Removes Temporary item properties.
// Used in set items.
// A variable named SetItemsTag + "_NumOfProps" holds
// the number of Temp properties
void RemoveTempProperties(object oItem, string sSetTag);
// Removes items from a creature or placeable.
// Will not remove a Players's Handbook, Dungeon Masters Guide, or Creature Skin!
// iEquiped will remove a creatures equiped items if TRUE.
// This will not remove a Players's Handbook or Dungeon Masters Guide!
// oCreature is the creature or container to remove the items.
// iEquiped will remove iEquiped items as well.
// iIgnoreSlot will ignore one slot on the equiped character INVENTORY_SLOT_*.
void RemoveItems(object oCreature, int iEquiped = FALSE, int iIgnoreSlot = -1);
// Identifies all items on oObject based on the 2da "SkillVsItemCost
// vs OBJECT_SELF  Knowledge skill.
// Reports the findings to oPC unless oPC = OBJECT_INVALID
void IdentifyAllVsKnowledge(object oObject, object oPC = OBJECT_INVALID);
// Attempts to lock the oTarget door by oPC with oItem.
void AttemptToLockTheDoor(object oPC, object oItem, object oTarget);
// Checks oCreature to see if they have any of Myrkul's set to power up oUndead.
void MyrkulSetCheck(object oCreature, object oUndead);
// Checks oItem and based on oCreature and any item properties will
// adjust the items equip level to be correct.
// oCreature is the creature to base the check on. If OBJECT_INVALID then no creature check.
void AdjustItemsEquipLevel(object oItem, object oCreature = OBJECT_INVALID);
// oItem to reduce the cost of.
// sTag to set the tag so it maybe removed later.
void AddCostReductionItemProperty(object oItem, string sTag)
{
    itemproperty ipCostReduction = ItemPropertyAbilityBonus (ABILITY_STRENGTH, 1);
    struct NWNX_IPUnpacked stCostReduction;
    stCostReduction = NWNX_ItemProperty_UnpackIP (ipCostReduction);
    stCostReduction.nProperty = 42;
    stCostReduction.nCostTable = 31;
    stCostReduction.nCostTableValue = 20;
    stCostReduction.sTag = sTag;
    ipCostReduction = NWNX_ItemProperty_PackIP (stCostReduction);
    AddItemProperty (DURATION_TYPE_PERMANENT, ipCostReduction, oItem);
}

// Return either the targets weapon or the weapon that is targeted.
// oTarget is the target selected.
object GetTargetedOrEquippedWeapon (object oTarget)
{
    object oWeapon;
    // if the object is a weapon then return it.
    if(GetIsWeapon(oTarget)) return oTarget;
    // The target was not a weapon get the right hand weapon of the target.
    if(GetObjectType(oTarget) == OBJECT_TYPE_CREATURE)
    {
        oWeapon = GetItemInSlot(INVENTORY_SLOT_RIGHTHAND, oTarget);
        if(GetIsWeapon(oWeapon)) return oWeapon;
        // If the right hand didn't have a weapon, check the left hand weapon of the target.
        oWeapon = GetItemInSlot(INVENTORY_SLOT_LEFTHAND, oTarget);
        if(GetIsWeapon(oWeapon)) return oWeapon;
        // Does not have a weapon in their hand. Do they have claws?
        oWeapon = GetItemInSlot(INVENTORY_SLOT_CWEAPON_R, oTarget);
        if(oWeapon != OBJECT_INVALID) return oWeapon;
        oWeapon = GetItemInSlot(INVENTORY_SLOT_ARMS, oTarget);
        return oWeapon;
    }
  // Does not have a weapon!
  return OBJECT_INVALID;
}

// Return either the targets armor/shield or the armor that is targeted.
// oTarget is the target selected.
object GetTargetedOrEquippedArmor (object oTarget)
{
  object oArmor;
  int nItemType = GetBaseItemType (oTarget);
  // if the object is armor or a shield then return it.
  if (nItemType == BASE_ITEM_ARMOR) return oTarget;
  else if (nItemType == BASE_ITEM_LARGESHIELD ||
           nItemType == BASE_ITEM_SMALLSHIELD ||
           nItemType == BASE_ITEM_TOWERSHIELD) return oTarget;
  // The target was not a armor piece so get the chest item of the target.
  oArmor = GetItemInSlot (INVENTORY_SLOT_CHEST, oTarget);
  if (GetBaseItemType (oArmor) == BASE_ITEM_ARMOR) return oArmor;
  // Now check for a shield.
  oArmor = GetItemInSlot (INVENTORY_SLOT_LEFTHAND, oTarget);
  nItemType = GetBaseItemType (oArmor);
  if (nItemType == BASE_ITEM_LARGESHIELD ||
      nItemType == BASE_ITEM_SMALLSHIELD ||
      nItemType == BASE_ITEM_TOWERSHIELD) return oArmor;
  // Does not have an armor piece!
  return OBJECT_INVALID;

}

// See if a creature has an item based on a specific tag.
// sTag is the tag of the item being looked for.
// bCheckEquiped will also look through the creatures equiped items.
// Returns the item if found or OBJECT_INVALID.
object GetCreatureHasItem (object oCreature, string sTag, int bCheckEquiped = FALSE)
{
    int nSlot = 0, nCount, nCasterLevel;
    string sItemTag;
    object oItem;
    // Should we check the creatures equiped items.
    if(bCheckEquiped)
    {
       // Check all of the creatures slots (0 - 17).
       while(nSlot <= 17)
       {
            oItem = GetItemInSlot(nSlot, oCreature);
            if(GetTag(oItem) == sTag) return oItem;
            nSlot++;
       }
    }
    // Cycle through the creatures unequiped items.
    oItem = GetFirstItemInInventory(oCreature);
    while(oItem != OBJECT_INVALID)
    {
        sItemTag = GetTag(oItem);
        // Magic scrolls, wands, and potions put the caster level at the end of the tag.
        // Check for those.
        nCasterLevel = GetLocalInt(oItem, "0_Caster_Level");
        if(nCasterLevel > 0)
        {
            if(nCasterLevel < 10) nCount = GetStringLength(sItemTag) - 1;
            else nCount = GetStringLength(sItemTag) - 2;
            sItemTag = GetStringLeft(sItemTag, nCount);
        }
        if(sItemTag == sTag ) return oItem;
        oItem = GetNextItemInInventory(oCreature);
    }
    return OBJECT_INVALID;
}

// See if a creature has an item based on a specific resref.
// sResRef is the ResRef of the item being looked for.
// bCheckEquiped will also look through the creatures equiped items.
// Returns the item if found or OBJECT_INVALID.
object GetCreatureHasItemResRef (object oCreature, string sResRef, int bCheckEquiped = FALSE)
{
    int nSlot = 0, nCount;
    string sItemResRef;
    object oItem, oFoundItem = OBJECT_INVALID;
    // Cycle through the creatures unequiped items.
    oItem = GetFirstItemInInventory (oCreature);
    while (oItem != OBJECT_INVALID)
    {
        if (GetResRef (oItem) == sResRef ) oFoundItem = oItem;
        oItem = GetNextItemInInventory (oCreature);
    }
    // Should we check the creatures equiped items.
    // If we have already found it then stop looking.
    if (bCheckEquiped || oFoundItem == OBJECT_INVALID)
    {
       // Check all of the creatures slots (0 - 17).
       while (nSlot <= 17)
       {
            oItem = GetItemInSlot (nSlot, oCreature);
            if (GetResRef (oItem) == sResRef)
            {
                // Stop checking.
                nSlot == 17;
                oFoundItem = oItem;
            }
            nSlot ++;
       }
    }
    return oFoundItem;
}

// Get if item is stackable.
int GetIsItemStackable (object oItem)
{
    // First see if the item has more than one stack size.
    if (GetItemStackSize (oItem) > 1) return TRUE;
    // Check the baseitems.2da
    int nItemType = GetBaseItemType (oItem);
    int nStackSize = StringToInt (Get2DAString ("baseitems", "Stacking", nItemType));
    if (nStackSize > 1) return TRUE;
    return FALSE;
}

// Removes amount of items in any amount of stacks from a container.
// If it cannot remove them it returns false.
// oPC is the PC to report the removal from if oPC isn't a player then nothing is reported.
// oContainer is the container to remove the items from this maybe oPC.
// sItemTag is the tag of the item stacks to remove.
// iAmountToRemove is the amount of items to remove.
int RemoveItemStackFromContainer(object oPC, object oContainer, string sItemTag, int nAmountToRemove)
{
    // First lets check for focuses that we don't want to remove.
    if(nAmountToRemove < 1)
    {
        if(GetCreatureHasItem(oContainer, sItemTag) != OBJECT_INVALID) return TRUE;
        else return FALSE;
    }
    // Now check for the components and remove them.
    int nStack, nOriginalAmount = nAmountToRemove;
    object oOriginalItem, oItem = GetFirstItemInInventory(oContainer);
    while(nAmountToRemove > 0 && oItem != OBJECT_INVALID)
    {
        if(GetTag(oItem) == sItemTag)
        {
            oOriginalItem = oItem;
            nStack = GetItemStackSize(oItem);
            if(nStack > nAmountToRemove)
            {
                SetLocalInt(oItem, "0_Remove", nAmountToRemove);
                DelayCommand(1.0f, DeleteLocalInt (oItem, "0_Remove"));
                nAmountToRemove = 0;
            }
            else if(nStack == nAmountToRemove)
            {
                SetLocalInt(oItem, "0_Remove", -1);
                DelayCommand(0.0, DeleteLocalInt(oItem, "0_Remove"));
                nAmountToRemove = 0;
            }
            else
            {
                SetLocalInt(oItem, "0_Remove", -1);
                DelayCommand(0.0, DeleteLocalInt(oItem, "0_Remove"));
                nAmountToRemove -= nStack;
            }
        }
        oItem = GetNextItemInInventory(oContainer);
    }
    // Since we found enough components to use let us remove them.
    // If we didn't then skip removing them.
    if(nAmountToRemove == 0)
    {
        if(GetIsCharacter(oPC)) NWNX_Feedback_SetFeedbackMessageHidden(NWNX_FEEDBACK_ITEM_LOST, TRUE, oPC);
        oItem = GetFirstItemInInventory(oContainer);
        while(oItem != OBJECT_INVALID)
        {
            nAmountToRemove = GetLocalInt(oItem, "0_Remove");
            if(nAmountToRemove == -1) DestroyObject(oItem);
            else if(nAmountToRemove)
            {
                DeleteLocalInt(oItem, "0_Remove");
                SetItemStackSize(oItem, nStack - nAmountToRemove);
            }
            oItem = GetNextItemInInventory(oContainer);
        }
        if(GetIsCharacter(oPC))
        {
            NWNX_Feedback_SetFeedbackMessageHidden(NWNX_FEEDBACK_ITEM_LOST, FALSE, oPC);
            SendMessages("Lost Item: " + IntToString(nOriginalAmount) + " " + GetName(oOriginalItem), COLOR_YELLOW, oPC);
        }
        return TRUE;
    }
    return FALSE;
}

// Gets a pallet items resref randomly based on a 2da_table.
string RollBaseItemResRef (string s2DAItemTable, object oPC = OBJECT_INVALID)
{
   string sResRef;
   int iResRefIndex, iRow;
   // Roll on the item chart.
   iRow = RollOn2daTable (s2DAItemTable, 0, oPC);
   // Get its ResRef of the item.
   sResRef = Get2DAString (s2DAItemTable, "ResRef", iRow);
   // Get the ResRefindex of the item.
   iResRefIndex = StringToInt (Get2DAString (s2DAItemTable, "ResRefIndex", iRow));
   // Set the pallet items new resref.
   if (iResRefIndex > 0) sResRef = sResRef + "_" + IntToString (Random (iResRefIndex) + 1);
   return sResRef;
}

// Returns true if the item is a  weapon.
int GetIsWeapon (object oItem)
{
    int nWeaponType = StringToInt(Get2DAString ("baseitems", "WeaponType", GetBaseItemType (oItem)));
    if (nWeaponType > 0) return TRUE;
    return FALSE;
}
// Returns true if the weapon is a melee weapon.
int GetIsMeleeWeapon (object oItem)
{
    int iType = GetBaseItemType (oItem);
    switch (iType)
    {
      case BASE_ITEM_LONGSWORD: return TRUE;
      case BASE_ITEM_RAPIER: return TRUE;
      case BASE_ITEM_DAGGER: return TRUE;
      case BASE_ITEM_GREATAXE: return TRUE;
      case BASE_ITEM_GREATSWORD: return TRUE;
      case BASE_ITEM_SHORTSWORD: return TRUE;
      case BASE_ITEM_MORNINGSTAR: return TRUE;
      case BASE_ITEM_LIGHTMACE: return TRUE;
      case BASE_ITEM_BATTLEAXE: return TRUE;
      case BASE_ITEM_BASTARDSWORD: return TRUE;
      case BASE_ITEM_SCIMITAR: return TRUE;
      case BASE_ITEM_SHORTSPEAR: return TRUE;
      case BASE_ITEM_QUARTERSTAFF: return TRUE;
      case BASE_ITEM_WARHAMMER: return TRUE;
      case BASE_ITEM_HALBERD: return TRUE;
      case BASE_ITEM_SICKLE: return TRUE;
      case BASE_ITEM_HANDAXE: return TRUE;
      case BASE_ITEM_DWARVENWARAXE: return TRUE;
      case BASE_ITEM_HEAVYFLAIL: return TRUE;
      case BASE_ITEM_LIGHTFLAIL: return TRUE;
      case BASE_ITEM_LIGHTHAMMER: return TRUE;
      case BASE_ITEM_KATANA: return TRUE;
      case BASE_ITEM_CLUB: return TRUE;
      case BASE_ITEM_DOUBLEAXE: return TRUE;
      case BASE_ITEM_TWOBLADEDSWORD: return TRUE;
      case BASE_ITEM_DIREMACE: return TRUE;
      case BASE_ITEM_KAMA: return TRUE;
      case BASE_ITEM_KUKRI: return TRUE;
      case BASE_ITEM_SCYTHE: return TRUE;
      case BASE_ITEM_TRIDENT: return TRUE;
      case BASE_ITEM_WHIP: return TRUE;
      case 163: return TRUE; // Falchion
      case 164: return TRUE; // Heavy Mace
      case 165: return TRUE; // Maul
      case 166: return TRUE; // Mercury Longsword
      case 167: return TRUE; // Mercury greatsword
      case 168: return TRUE; // Double Scimitar
      case 169: return TRUE; // Heavy Pick
      case 170: return TRUE; // Light Pick
      case 171: return TRUE; // Sai
      case 172: return TRUE; // Nunchaku
      case 173: return TRUE; // Wakazashi
      case 174: return TRUE; // Short spear
      case 175: return TRUE; // Short staff
   }
   return FALSE;
}

// Returns true if the weapon is able to be used single handed by oCreature.
int GetIsSingleHandedWeapon (object oItem, object oCreature)
{
  if (!GetIsMeleeWeapon (oItem)) return FALSE;
  int nBaseItemType = GetBaseItemType (oItem);
  // Weapon Size in the baseitems.2da is 1 = Tiny, 2 = Small, 3 = Medium, 4 = Large.
  int nWeaponSize = StringToInt (Get2DAString ("baseitems", "WeaponSize", nBaseItemType));
  // Ranged weapons have a value greater than 0 in this field. So melee weapons have 0.
  int nWeaponMelee = StringToInt (Get2DAString ("baseitems", "RangedWeapon", nBaseItemType));
  // Creature size is 1 = Tiny, 2 = Small, 3 = Medium, 4 = Large.
  int nCreatureSize = GetCreatureSize (oCreature);
  if (nWeaponMelee == 0 && nWeaponSize <= nCreatureSize) return TRUE;
  return FALSE;
}

// Returns true if the weapon is a twohanded for oCreature.
int GetIsTwoHandedWeapon (object oItem, object oCreature)
{
  if (!GetIsMeleeWeapon (oItem)) return FALSE;
  int nBaseItemType = GetBaseItemType (oItem);
  // Weapon Size in the baseitems.2da is 1 = Tiny, 2 = Small, 3 = Medium, 4 = Large.
  int nWeaponSize = StringToInt (Get2DAString ("baseitems", "WeaponSize", nBaseItemType));
  // Ranged weapons have a value greater than 0 in this field. So melee weapons have 0.
  int nWeaponMelee = StringToInt (Get2DAString ("baseitems", "RangedWeapon", nBaseItemType));
  // Creature size is 1 = Tiny, 2 = Small, 3 = Medium, 4 = Large.
  int nCreatureSize = GetCreatureSize (oCreature);
  if (nWeaponSize > nCreatureSize) return TRUE;
  if (nWeaponMelee == 0 && nWeaponSize > nCreatureSize) return TRUE;
  return FALSE;
}

// Returns true if the weapon is a slashing weapon.
int GetIsSlashingWeapon (object oItem)
{
  int iBaseItemType = GetBaseItemType (oItem);
  int iWeaponType = StringToInt (Get2DAString ("baseitems", "WeaponType", iBaseItemType));
  // Weapon Type in the baseitems.2da is 1 = Piercing, 2 = Bludgeoning, 3 = Slashing.
  if (iWeaponType == 3) return TRUE;
  return FALSE;
}

// Returns true if the item is a  weapon.
int GetIsPiercingWeapon (object oItem)
{
  int iBaseItemType = GetBaseItemType (oItem);
  int iWeaponType = StringToInt (Get2DAString ("baseitems", "WeaponType", iBaseItemType));
  // Weapon Type in the baseitems.2da is 1 = Piercing, 2 = Bludgeoning, 3 = Slashing.
  if(iWeaponType == 1) return TRUE;
  return FALSE;
}

// Returns true if the item is a  weapon.
int GetIsBludgeoningWeapon (object oItem)
{
  int iBaseItemType = GetBaseItemType (oItem);
  int iWeaponType = StringToInt (Get2DAString ("baseitems", "WeaponType", iBaseItemType));
  // Weapon Type in the baseitems.2da is 1 = Piercing, 2 = Bludgeoning, 3 = Slashing.
  if (iWeaponType == 2) return TRUE;
  return FALSE;
}

// Returns true if the item is ammo.
int GetIsAmmo (object oItem)
{
   switch (GetBaseItemType (oItem))
   {
      case BASE_ITEM_ARROW: return TRUE;
      case BASE_ITEM_BOLT: return TRUE;
      case BASE_ITEM_BULLET: return TRUE;
   }
   return FALSE;
}

// Returns true if the weapon is a thrown.
int GetIsThrownWeapon (object oItem)
{
   switch (GetBaseItemType (oItem))
   {
      case 31/*BASE_ITEM_JAVELIN*/: return TRUE;
      case BASE_ITEM_SHURIKEN: return TRUE;
      case BASE_ITEM_THROWINGAXE: return TRUE;
   }
   return FALSE;
}

// Returns true if they have ammo of the currently equipped range weapon.
int HasRangedWeaponWithAmmo (object oCreature = OBJECT_SELF)
{
    object oWeapon = GetItemInSlot (INVENTORY_SLOT_RIGHTHAND, oCreature);
    int nAmmoType, nWeaponType = GetBaseItemType (oWeapon);
    object oAmmo = OBJECT_INVALID;
    if (nWeaponType == BASE_ITEM_LONGBOW || nWeaponType == BASE_ITEM_SHORTBOW)
    {
        oAmmo = GetItemInSlot (INVENTORY_SLOT_ARROWS, oCreature);
        nAmmoType = BASE_ITEM_ARROW;
    }
    else if (nWeaponType == BASE_ITEM_LIGHTCROSSBOW || nWeaponType == BASE_ITEM_HEAVYCROSSBOW)
    {
        oAmmo = GetItemInSlot (INVENTORY_SLOT_BOLTS, oCreature);
        nAmmoType = BASE_ITEM_BOLT;
    }
    else if (nWeaponType == BASE_ITEM_SLING)
    {
        oAmmo = GetItemInSlot (INVENTORY_SLOT_BULLETS, oCreature);
        nAmmoType = BASE_ITEM_BULLET;
    }
    else if (nWeaponType == BASE_ITEM_THROWINGAXE) return TRUE;
    else if (nWeaponType == BASE_ITEM_SHURIKEN) return TRUE;
    else if (nWeaponType == 31/*BASE_ITEM_JAVELIN*/) return TRUE;
    if (oAmmo != OBJECT_INVALID) return TRUE;
    if (nAmmoType == 0)
    {
        //Debug ("0i_items", "687", "They do not have a ranged weapon equiped.");
        return FALSE;
    }
    // They don't have any ammo in the slot, but do they have ammo in the inventory?
    oAmmo = GetFirstItemInInventory (oCreature);
    while (oAmmo != OBJECT_INVALID)
    {
        if (GetBaseItemType (oAmmo) == nAmmoType)
        {
            if (nAmmoType == BASE_ITEM_ARROW) AssignCommand (oCreature, ActionEquipItem(oAmmo, INVENTORY_SLOT_ARROWS));
            else if (nAmmoType == BASE_ITEM_BOLT) AssignCommand (oCreature, ActionEquipItem (oAmmo, INVENTORY_SLOT_BOLTS));
            else if (nAmmoType == BASE_ITEM_BULLET) AssignCommand (oCreature, ActionEquipItem (oAmmo, INVENTORY_SLOT_BULLETS));
            return TRUE;
        }
        oAmmo =GetNextItemInInventory (oCreature);
    }
    //Debug ("0i_items", "703", "They are out of ammo!");
    return FALSE;
}

// Returns true if the weapon is a ranged weapon.
int GetIsRangeWeapon (object oItem)
{
   switch (GetBaseItemType (oItem))
   {
      case 31: return TRUE; // Javelin
      case BASE_ITEM_HEAVYCROSSBOW: return TRUE;
      case BASE_ITEM_LIGHTCROSSBOW: return TRUE;
      case BASE_ITEM_LONGBOW: return TRUE;
      case BASE_ITEM_SHORTBOW: return TRUE;
      case BASE_ITEM_SHURIKEN: return TRUE;
      case BASE_ITEM_SLING: return TRUE;
      case BASE_ITEM_THROWINGAXE: return TRUE;
   }
   return FALSE;
}

// Returns true if the weapon is a finesse weapon.
int GetIsFinesseWeapon(object oItem)
{
   switch(GetBaseItemType(oItem))
   {
      case BASE_ITEM_DAGGER: return TRUE;
      case BASE_ITEM_HANDAXE: return TRUE;
      case BASE_ITEM_KAMA: return TRUE;
      case BASE_ITEM_KUKRI: return TRUE;
      case BASE_ITEM_LIGHTHAMMER: return TRUE;
      case BASE_ITEM_LIGHTMACE: return TRUE;
      case BASE_ITEM_RAPIER: return TRUE;
      case BASE_ITEM_SHORTSWORD: return TRUE;
      case BASE_ITEM_SICKLE: return TRUE;
      case BASE_ITEM_WHIP: return TRUE;
      case 170: return TRUE; // Light Pick
      case 171: return TRUE; // Sai
      case 172: return TRUE; // Nunchaku
      case 173: return TRUE; // Wakazashi
      case 174: return TRUE; // Short spear
      case 175: return TRUE; // Short staff
   }
   return FALSE;
}

// Returns true if the item is a shield.
int GetIsShield (object oItem)
{
   switch (GetBaseItemType (oItem))
   {
      case BASE_ITEM_SMALLSHIELD: return TRUE;
      case BASE_ITEM_LARGESHIELD: return TRUE;
      case BASE_ITEM_TOWERSHIELD: return TRUE;
   }
   return FALSE;
 }
// Returns true if they have an item with regeneration.
// bIsEquiped requires that the regeneration is working.
int GetHasRegeneration (object oPC, int bIsEquiped = FALSE)
{
    if (bIsEquiped)
    {
        object oItem = GetItemInSlot  (INVENTORY_SLOT_RIGHTRING, oPC);
        if (GetTag (oItem) == "0_ring_regenerat") return TRUE;
        oItem = GetItemInSlot  (INVENTORY_SLOT_LEFTRING, oPC);
        if (GetTag (oItem) == "0_ring_regenerat") return TRUE;
        // Check for regeneration Ioun stone.
        effect eEffect = GetFirstEffect (oPC);
        while (GetIsEffectValid (eEffect))
        {
            if ("0_is_emerald_2" == GetEffectTag (eEffect)) return TRUE;
            eEffect = GetNextEffect (oPC);
        }
    }
    else
    {
        if (GetCreatureHasItem (oPC, "0_ring_regenerat", TRUE) != OBJECT_INVALID) return TRUE;
        if (GetCreatureHasItemResRef (oPC, "0_is_emerald_2") != OBJECT_INVALID) return TRUE;
    }

    return FALSE;
}

// Gives appropriate ammo for the weapon given.
// If it doesn't use ammo then it will exit.
void GiveAmmoForWeapon (object oWeapon, object oContainer)
{
    object oAmmo;
    switch (GetBaseItemType (oWeapon))
    {
       case BASE_ITEM_HEAVYCROSSBOW:
       case BASE_ITEM_LIGHTCROSSBOW:
       {
            CreateItemOnObject ("bolt", oContainer, 99);
            break;
       }
       case BASE_ITEM_LONGBOW:
       case BASE_ITEM_SHORTBOW:
       {
            CreateItemOnObject ("arrow", oContainer, 99);
            break;
       }
       case BASE_ITEM_SLING:
       {
            CreateItemOnObject ("bullet", oContainer, 99);
            break;
       }
   }
}
int EquipItemBaseOnGoldValue (object oCreature, object oItem, int iSlot, int bDestroyDuplicate = FALSE)
{
   object oEquiped = GetItemInSlot (iSlot, oCreature);
   if (GetGoldPieceValue (oItem) > GetGoldPieceValue (oEquiped))
   {
      if (oEquiped != OBJECT_INVALID && bDestroyDuplicate)
      {
        DestroyObject (oEquiped);
      }
      AssignCommand (oCreature, ActionEquipItem (oItem, iSlot));
      ActionWait (6.0f);
      return TRUE;
   }
   else if (bDestroyDuplicate)
      {
            DestroyObject (oItem);
      }
   return FALSE;
}

void CheckArmor (object oCreature, object oArmor, int bChecked = FALSE)
{
    object oEquipedArmor = GetItemInSlot (INVENTORY_SLOT_CHEST, oCreature);
    if (oEquipedArmor == OBJECT_INVALID)
    {
        if (bChecked)
        {
           oArmor = GiveEquipment (oCreature, FALSE, 16);
           AssignCommand (oCreature, ActionEquipItem (oArmor, INVENTORY_SLOT_CHEST));
        }
        else
        {
            AssignCommand (oCreature, ActionEquipItem (oArmor, INVENTORY_SLOT_CHEST));
            DelayCommand (0.1, CheckArmor (oCreature, oArmor, TRUE));
        }
    }
}
void EquipItems(object oCreature, int bDestroyDuplicate, int bAlwaysArmor = FALSE)
{
   object oItem, oItem2, oMeleeWeapon1, oMeleeWeapon2, oShield, oArmor, oArrow;
   object oBelt, oBoots, oCloak, oHelmet, oAmulet, oHands, oBolt, oBullet, oRangedWeapon;
   object oRing1 = OBJECT_INVALID, oRing2 = OBJECT_INVALID;
   int nType, nValue, nGood, nAC;
   // Now equip any other items.
   oItem = GetFirstItemInInventory (oCreature);
   while (oItem != OBJECT_INVALID)
   {
      SetIdentified (oItem, TRUE);
      nType = GetBaseItemType (oItem);
      nValue = GetGoldPieceValue (oItem);
      if (nType == BASE_ITEM_ARMOR)
      {
          nAC = GetItemACValue (oItem);
          nGood = FALSE;
          if (GetHasFeat (FEAT_ARMOR_PROFICIENCY_HEAVY)) nGood = TRUE;
          else if (GetHasFeat (FEAT_ARMOR_PROFICIENCY_MEDIUM , oCreature) && nAC < 6) nGood = TRUE;
          else if (GetHasFeat (FEAT_ARMOR_PROFICIENCY_LIGHT , oCreature) && nAC < 4) nGood = TRUE;
          else if (nAC < 1) nGood = TRUE;
          if (nValue >= GetGoldPieceValue (oArmor) && nGood) oArmor = oItem;
      }
      else if (nType == BASE_ITEM_LARGESHIELD ||
               nType == BASE_ITEM_SMALLSHIELD ||
               nType == BASE_ITEM_TOWERSHIELD)
      {
          if (nValue >= GetGoldPieceValue (oShield) &&
          (oMeleeWeapon1 == OBJECT_INVALID) || GetIsSingleHandedWeapon (oMeleeWeapon1, oCreature)) oShield = oItem;
      }
      else if (nType == BASE_ITEM_ARROW && nValue >= GetGoldPieceValue (oArrow)) oArrow = oItem;
      else if (nType == BASE_ITEM_BOLT && nValue >= GetGoldPieceValue (oBolt)) oBolt = oItem;
      else if (nType == BASE_ITEM_BULLET && nValue >= GetGoldPieceValue (oBullet)) oBullet = oItem;
      else if (nType == BASE_ITEM_BELT && nValue >= GetGoldPieceValue (oBelt)) oBelt = oItem;
      else if (nType == BASE_ITEM_BOOTS && nValue >= GetGoldPieceValue (oBoots)) oBoots = oItem;
      else if (nType == BASE_ITEM_CLOAK && nValue >= GetGoldPieceValue (oCloak)) oCloak = oItem;
      else if (nType == BASE_ITEM_HELMET && nValue >= GetGoldPieceValue (oHelmet)) oHelmet = oItem;
      else if (nType == BASE_ITEM_AMULET && nValue >= GetGoldPieceValue (oAmulet)) oAmulet = oItem;
      else if (nType == BASE_ITEM_BRACER || nType == BASE_ITEM_GLOVES)
      {
          if (nValue >= GetGoldPieceValue (oHands)) oHands = oItem;
      }
      else if (nType == BASE_ITEM_RING)
      {
          if (nValue >= GetGoldPieceValue (oRing1))
          {
              if (oRing2 == OBJECT_INVALID) oRing2 = oRing1;
              oRing1 = oItem;
          }
          else if (nValue >= GetGoldPieceValue (oRing2)) oRing2 = oItem;
      }
      else if (GetIsWeapon (oItem))
      {
          if (GetWeaponRanged (oItem))
          {
            if (nValue > GetGoldPieceValue (oRangedWeapon)) oRangedWeapon = oItem;
          }
          else if (GetHasFeat (374/*FEAT_DUAL_WIELD*/, oCreature) ||
                   GetHasFeat (FEAT_TWO_WEAPON_FIGHTING, oCreature))
          {
              if (GetIsSingleHandedWeapon (oItem, oCreature))
              {
                  if (nValue >= GetGoldPieceValue (oMeleeWeapon1))
                  {
                    if (oMeleeWeapon2 == OBJECT_INVALID) oMeleeWeapon2 = oMeleeWeapon1;
                    oMeleeWeapon1 = oItem;
                  }
                  else if (nValue >= GetGoldPieceValue (oMeleeWeapon2)) oMeleeWeapon2 = oItem;
              }
              else if (nValue >= GetGoldPieceValue (oMeleeWeapon1)) oMeleeWeapon1 = oItem;
          }
          else
          {
            if (nValue >= GetGoldPieceValue (oMeleeWeapon1)) oMeleeWeapon1 = oItem;
          }
      }
      oItem = GetNextItemInInventory (oCreature);
   }
   // Equip all items.
   if (oArrow != OBJECT_INVALID) AssignCommand (oCreature, ActionEquipItem (oArrow, INVENTORY_SLOT_ARROWS));
   if (oBolt != OBJECT_INVALID) AssignCommand (oCreature, ActionEquipItem (oBolt, INVENTORY_SLOT_BOLTS));
   if (oBullet != OBJECT_INVALID) AssignCommand (oCreature, ActionEquipItem (oBullet, INVENTORY_SLOT_BULLETS));
   if (oBelt != OBJECT_INVALID) AssignCommand (oCreature, ActionEquipItem (oBelt, INVENTORY_SLOT_BELT));
   if (oBoots != OBJECT_INVALID) AssignCommand (oCreature, ActionEquipItem (oBoots, INVENTORY_SLOT_BOOTS));
   if (oCloak != OBJECT_INVALID) AssignCommand (oCreature, ActionEquipItem (oCloak, INVENTORY_SLOT_CLOAK));
   if (oHelmet != OBJECT_INVALID) AssignCommand (oCreature, ActionEquipItem (oHelmet, INVENTORY_SLOT_HEAD));
   if (oAmulet != OBJECT_INVALID) AssignCommand (oCreature, ActionEquipItem (oAmulet, INVENTORY_SLOT_NECK));
   if (oHands != OBJECT_INVALID) AssignCommand (oCreature, ActionEquipItem (oHands, INVENTORY_SLOT_ARMS));
   if (oRing1 != OBJECT_INVALID) AssignCommand (oCreature, ActionEquipItem (oRing1, INVENTORY_SLOT_LEFTRING));
   if (oRing2 != OBJECT_INVALID) AssignCommand (oCreature, ActionEquipItem (oRing2, INVENTORY_SLOT_RIGHTRING));
   // Check for ranged weapon 1st then, dual wield then, weapon/shield.
   if (oRangedWeapon != OBJECT_INVALID)
   {
        AssignCommand (oCreature, ActionEquipItem (oRangedWeapon, INVENTORY_SLOT_RIGHTHAND));
        // Range Striker : Requires a ranged weapon and bonus to dexerity.
        //if (d100() < 75 && GetAbilityModifier (ABILITY_DEXTERITY) > 0)
        //{
        //    SetCombatMode (COMBAT_MODE_RANGED, TRUE);
        //}
   }
   else if (GetHasFeat(374/*FEAT_DUAL_WIELD*/, OBJECT_SELF) ||
       GetHasFeat(FEAT_TWO_WEAPON_FIGHTING, OBJECT_SELF))
   {
       AssignCommand (oCreature, ActionEquipItem (oMeleeWeapon1, INVENTORY_SLOT_RIGHTHAND));
       AssignCommand (oCreature, ActionEquipItem (oMeleeWeapon2, INVENTORY_SLOT_LEFTHAND));
   }
   // Equip main weapon and shield if they have one.
   else
   {
       AssignCommand (oCreature, ActionEquipItem (oMeleeWeapon1, INVENTORY_SLOT_RIGHTHAND));
       if (oShield != OBJECT_INVALID) AssignCommand (oCreature, ActionEquipItem (oShield, INVENTORY_SLOT_LEFTHAND));
   }
   if (oArmor != OBJECT_INVALID) AssignCommand (oCreature, ActionEquipItem (oArmor, INVENTORY_SLOT_CHEST));
   // Check to make sure they are wearing clothes or armor.
   DelayCommand (0.1, CheckArmor (oCreature, oArmor));
}

// ID's all drops on oTarget.
void IdDrops (object oTarget, int iIdentified = FALSE)
{
   // Do all items in the inventory.
   int nGoldValue;
   string sName, sResRef;
   itemproperty ipProperty;
   object oItem = GetFirstItemInInventory (oTarget);
   while (oItem != OBJECT_INVALID)
   {
        // Check to see if it has a property or a gem / art object or gold.
        ipProperty = GetFirstItemProperty (oItem);
        if (GetItemPropertyType (ipProperty) == ITEM_PROPERTY_QUALITY) ipProperty = GetNextItemProperty (oItem);
        sResRef = GetStringLeft (GetResRef (oItem), 2);
        nGoldValue = GetGoldPieceValue (oItem);
        // Identify all non-power, non-gem, non-art objects make sure quality is not counted.
        // Also identify all items if the iIdentified flag is set.
        if((!GetIsItemPropertyValid (ipProperty)
          && sResRef != "g_"
          && sResRef != "a_"
          && nGoldValue < 400)
          || GetTag(oItem) == "0_quest_paper") SetIdentified (oItem, TRUE);
        else SetIdentified (oItem, iIdentified);
        oItem = GetNextItemInInventory (oTarget);
   }
   // Now do all items equiped.
   int iCounter;
   for (iCounter = 0; iCounter < 19; iCounter ++)
   {
       oItem = GetItemInSlot (iCounter, oTarget);
       if (oItem != OBJECT_INVALID)
       {
           ipProperty = GetFirstItemProperty (oItem);
           if (GetItemPropertyType (ipProperty) == ITEM_PROPERTY_QUALITY) ipProperty = GetNextItemProperty (oItem);
           nGoldValue = GetGoldPieceValue (oItem);
           if (!GetIsItemPropertyValid (ipProperty)
             && nGoldValue < 400) SetIdentified (oItem, TRUE);
           else SetIdentified (oItem, iIdentified);
       }
   }
}

// Make all items on oTarget Id'ed or not Id'ed
// iID can be TRUE (Identified) or FALSE (Unidentified).
// iEquiped will check the creatures equiped items as well.
void IdAllInventory (object oTarget, int iID = TRUE, int iEquiped = FALSE)
{
   // Do all items in the inventory.
   string sName, sTag;
   object oItem = GetFirstItemInInventory (oTarget);
   while (oItem != OBJECT_INVALID)
   {
        SetIdentified (oItem, iID);
        oItem = GetNextItemInInventory (oTarget);
   }
   // Now do all items equiped.
   if (iEquiped)
   {
       int iCounter;
       for (iCounter = 0; iCounter < 19; iCounter++)
       {
           oItem = GetItemInSlot (iCounter, oTarget);
           if (oItem != OBJECT_INVALID)
           {
               SetIdentified (oItem, iID);
           }
       }
   }
}
int GetArmorBonus(object oArmor)
{
    int nTorsoValue = GetItemAppearance(oArmor, ITEM_APPR_TYPE_ARMOR_MODEL, ITEM_APPR_ARMOR_MODEL_TORSO);
    //ai_Debug("0i_items", "444", "Armor Bonus: " + Get2DAString("parts_chest.2da", "ACBONUS", nTorsoValue));
    return StringToInt(Get2DAString("parts_chest", "ACBONUS", nTorsoValue));
}
int GetMaxItemValueThatCanBeEquiped(int nLevel)
{
    return StringToInt(Get2DAString("itemvalue", "MAXSINGLEITEMVALUE", nLevel - 1));
}
int GetMinimumEquipLevel(object oItem)
{
    int nIndex, nUnIdentified;
    if(!GetIdentified(oItem))
    {
        nUnIdentified = TRUE;
        SetIdentified(oItem, TRUE);
    }
    int nGoldValue = GetGoldPieceValue(oItem);
    if(nUnIdentified) SetIdentified(oItem, FALSE);
    int n2daMaxRow = Get2DARowCount("itemvalue");
    while(nIndex < n2daMaxRow)
    {
        if(nGoldValue <= StringToInt(Get2DAString("itemvalue", "MAXSINGLEITEMVALUE", nIndex)))
        {
            return nIndex + 1;
        }
        nIndex++;
    }
    return nIndex;
}
// Make all items on oTarget Droppable or not Droppable
// bDroppable can be TRUE (Droppable) or FALSE (Not Droppable).
// nEquiped will check the creatures equiped items as well.
void SetDroppableFlagAllInventory(object oTarget, int bDroppable = TRUE, int nEquiped = FALSE)
{
   // Do all items in the inventory.
   string sName, sTag;
   object oItem = GetFirstItemInInventory(oTarget);
   while (oItem != OBJECT_INVALID)
   {
        if(GetTag(oItem) != "0_skin") SetDroppableFlag(oItem, bDroppable);
        oItem = GetNextItemInInventory(oTarget);
   }
   // Now do all items equiped.
   if(nEquiped)
   {
       int nCounter;
       for(nCounter = 0; nCounter < 14; nCounter++)
       {
           oItem = GetItemInSlot(nCounter, oTarget);
           if(oItem != OBJECT_INVALID)
           {
               SetDroppableFlag(oItem, bDroppable);
           }
       }
   }
}

// Gives oCreature a simple melee weapon.
object GiveSimpleMeleeWeapons (object oCreature)
{
   int iRoll;
   string sResRef;
   // Check creatures size.
   if (GetCreatureSize (oCreature) == CREATURE_SIZE_SMALL) iRoll = Random (80) + 1;
   else iRoll = d100();
   if (iRoll < 21) sResRef = "dagger"; // Tiny
   else if (iRoll < 31) sResRef = "mace"; // Small
   else if (iRoll < 37) sResRef = "sickle"; // Small
   else if (iRoll < 47) sResRef = "heavymace"; // Medium
   else if (iRoll < 71) sResRef = "club"; // Medium
   else if (iRoll < 81) sResRef = "morningstar"; //Medium
   else if (iRoll < 91) sResRef = "quarterstaff"; // Large
   else sResRef = "spear"; // Large
   object oItem = CreateItemOnObject (sResRef, oCreature);
   if (oItem == OBJECT_INVALID) SetModuleError ("RESREF", "0i_items", "997", "Created invalid resref: " + sResRef);
   return oItem;
}

// Gives oCreature a martial melee weapon.
object GiveMartialMeleeWeapons (object oCreature)
{
   int iRoll;
   string sResRef;
   // Check creatures size.
   if (GetCreatureSize (oCreature) == CREATURE_SIZE_SMALL) iRoll = Random (63) + 1;
   else iRoll = d100();
   if (iRoll < 6) sResRef = "kukri"; // Tiny
   else if (iRoll < 11) sResRef = "shortsword"; // Small
   else if (iRoll < 13) sResRef = "lighthammer"; // Small
   else if (iRoll < 15) sResRef = "lightpick"; // Small
   else if (iRoll < 30) sResRef = "longsword"; // Medium
   else if (iRoll < 35) sResRef = "rapier"; // Medium
   else if (iRoll < 40) sResRef = "scimitar"; // Medium
   else if (iRoll < 45) sResRef = "battleaxe"; // Medium
   else if (iRoll < 50) sResRef = "lightflail"; // Medium
   else if (iRoll < 52) sResRef = "warhammer"; // Medium
   else if (iRoll < 54) sResRef = "heavypick"; // Medium
   else if (iRoll < 64) sResRef = "greataxe"; // Large
   else if (iRoll < 74) sResRef = "greatsword"; // Large
   else if (iRoll < 78) sResRef = "heavyflail"; // large
   else if (iRoll < 80) sResRef = "halberd"; // Large
   else if (iRoll < 85) sResRef = "falchion"; // Large
   else if (iRoll < 90) sResRef = "maul"; // Large
   else sResRef = "trident"; // Large
   object oItem = CreateItemOnObject (sResRef, oCreature);
   if (oItem  == OBJECT_INVALID) SetModuleError ("RESREF", "0i_items", "1028", "Created invalid resref: " + sResRef);
   return oItem;
}

// Gives oCreature a exotic melee weapon.
object GiveExoticMeleeWeapons (object oCreature)
{
   int iRoll;
   string sResRef;
   if (GetCreatureSize (oCreature) == CREATURE_SIZE_SMALL) iRoll = Random (60) + 1;
   else iRoll = d100();
   if (iRoll < 11) sResRef = "kama"; // Small
   else if (iRoll < 16) sResRef = "sai"; // Small
   else if (iRoll < 21) sResRef = "nunchaku"; // Small
   else if (iRoll < 41) sResRef = "bastardsword"; // Medium
   else if (iRoll < 51) sResRef = "dwarvenwaraxe"; // Medium
   else if (iRoll < 56) sResRef = "katana"; // Medium
   else if (iRoll < 57) sResRef = "mlongsword"; // Medium
   else if (iRoll < 61) sResRef = "wakazashi"; // Medium
   else if (iRoll < 66) sResRef = "scythe"; // Large
   else if (iRoll < 76) sResRef = "twobladedsword"; // Large
   else if (iRoll < 86) sResRef = "doubleaxe"; // Large
   else if (iRoll < 91) sResRef = "doublescimitar"; // Large
   else if (iRoll < 92) sResRef = "mgreatsword"; // Large
   else sResRef = "diremace"; // Large
   object oItem = CreateItemOnObject (sResRef, oCreature);
   if (oItem == OBJECT_INVALID) SetModuleError ("RESREF", "0i_items", "1054", "Created invalid resref: " + sResRef);
   return oItem;
}

// Gives oCreature a restricted set of weapons.
// iType is the type of restricted weapon.
// 1: Elf, 2: Druid, 3: Monk, 4: Rogue, 5: Wizard.
object GiveSpecialWeapon (object oCreature, int iType)
{
   string sResRef;
   int iRoll = d100();
   switch (iType)
   {
        case 1 : // Elf
           if (iRoll < 50) sResRef = "longsword";
           else sResRef = "rapier";
        break;
        case 2 : // Druid
           if (GetCreatureSize (oCreature) == CREATURE_SIZE_SMALL) iRoll = Random (47) + 1;
           if (iRoll < 16) sResRef = "club"; // Medium
           else if (iRoll < 32) sResRef = "dagger"; // Tiny
           else if (iRoll < 48) sResRef = "scimitar"; // Medium
           else if (iRoll < 64) sResRef = "sickle"; // Large
           else if (iRoll < 80) sResRef = "spear"; // Large
           else sResRef = "quarterstaff"; // Large
        break;
        case 3 : // Monk
           if (GetCreatureSize (oCreature) == CREATURE_SIZE_SMALL) iRoll = Random (90) + 1;
           if (iRoll < 11) sResRef = "club";// Medium
           else if (iRoll < 41) sResRef = "dagger"; // Tiny
           else if (iRoll < 51) sResRef = "handaxe"; // Small
           else if (iRoll < 91) sResRef = "kama"; // Small
           else sResRef = "quarterstaff"; // Large
        break;
        case 4 : // Rogue
           if (GetCreatureSize (oCreature) == CREATURE_SIZE_SMALL) iRoll = Random (94) + 1;
           if (iRoll < 5) sResRef = "club"; // Medium
           else if (iRoll < 30) sResRef = "dagger"; // Tiny
           else if (iRoll < 35) sResRef = "handaxe"; // Small
           else if (iRoll < 40) sResRef = "mace"; // Small
           else if (iRoll < 45) sResRef = "morningstar"; // Medium
           else if (iRoll < 70) sResRef = "rapier"; // Medium
           else if (iRoll < 95) sResRef = "shortsword"; // Medium
           else sResRef = "quarterstaff"; // Large
        break;
        case 5 : // Wizard
           if (GetCreatureSize (oCreature) == CREATURE_SIZE_SMALL) iRoll = Random (50) + 1;
           if (iRoll < 5) sResRef = "club"; // Medium
           else if (iRoll < 50) sResRef = "dagger"; // Tiny
           else sResRef = "quarterstaff"; // Large
        break;
   }
   object oItem = CreateItemOnObject (sResRef, oCreature);
   if (oItem == OBJECT_INVALID) SetModuleError ("RESREF", "0i_items", "1107", "Created invalid resref: " + sResRef);
   return oItem;
}

// Gives oCreature a simple ranged weapon.
object GiveSimpleRangedWeapons (object oCreature)
{
   string sResRef, sResRefAmmo;
   int iRoll = d100(), iStackSize;
   object oAmmo;
   if (iRoll < 16) { sResRef = "heavycrossbow"; sResRefAmmo = "bolt"; }
   else if (iRoll < 61) { sResRef = "lightcrossbow"; sResRefAmmo = "bolt"; }
   else if (iRoll < 91) { sResRef = "sling"; sResRefAmmo = "bullet"; }
   else { sResRef = "javelin"; iStackSize = 10;}
   object oItem = CreateItemOnObject (sResRef, oCreature);
   if (iStackSize > 0) SetItemStackSize (oItem, Random (iStackSize) + iStackSize);
   if (sResRefAmmo != "")
   {
       oAmmo = CreateItemOnObject (sResRefAmmo, oCreature, Random (50) + 51);
       SetDroppableFlag (oAmmo, FALSE);
   }
   if (oItem == OBJECT_INVALID) SetModuleError ("RESREF", "0i_items", "1128", "Created invalid resref: " + sResRef);
   return oItem;
}

// Gives oCreature a martial ranged weapon.
object GiveMartialRangedWeapons (object oCreature)
{
   string sResRef, sResRefAmmo;
   int iRoll = d100(), iStackSize;
   object oAmmo;
   if (GetCreatureSize (oCreature) == CREATURE_SIZE_SMALL) iRoll = Random (50) + 1;
   if (iRoll < 41) { sResRef = "shortbow"; sResRefAmmo = "arrow"; }
   else if (iRoll < 51) { sResRef = "throwingaxe"; iStackSize = 25; }
   else { sResRef = "longbow"; sResRefAmmo = "arrow"; }
   // Create the ranged weapon.
   object oItem = CreateItemOnObject (sResRef, oCreature);
   if (iStackSize > 0) SetItemStackSize (oItem, Random (iStackSize) + iStackSize);
   // Create ammo if needed.
   if (sResRefAmmo != "")
   {
       oAmmo = CreateItemOnObject (sResRefAmmo, oCreature, Random (50) + 51);
       SetDroppableFlag (oAmmo, FALSE);
   }
   if (oItem == OBJECT_INVALID) SetModuleError ("RESREF", "0i_items", "1151", "Created invalid resref: " + sResRef);
   return oItem;
}

// Gives oCreature a Onehanded and light weapon.
object GiveTwoWeaponStyleWeapons(object oCreature, int bDroppable)
{
    int iRoll;
    string sResRef;
    // Check creatures size.
    int nSize = GetCreatureSize (oCreature);
    // Give them a light weapon.
    if (nSize == CREATURE_SIZE_SMALL) iRoll = Random (30) + 1;
    else if (nSize == CREATURE_SIZE_MEDIUM) iRoll = Random (71) + 1;
    else iRoll = d100();
    if (iRoll < 21) sResRef = "dagger"; // Tiny
    else if (iRoll < 31) sResRef = "kukri"; // Tiny
    else if (iRoll < 36) sResRef = "mace"; // Small
    else if (iRoll < 38) sResRef = "sickle"; // Small
    else if (iRoll < 68) sResRef = "shortsword"; // Small
    else if (iRoll < 70) sResRef = "lighthammer"; // Small
    else if (iRoll < 72) sResRef = "lightpick"; // Small
    else if (iRoll < 74) sResRef = "heavymace"; // Medium
    else if (iRoll < 76) sResRef = "club"; // Medium
    else if (iRoll < 78) sResRef = "morningstar"; //Medium
    else if (iRoll < 88) sResRef = "longsword"; // Medium
    else if (iRoll < 90) sResRef = "rapier"; // Medium
    else if (iRoll < 92) sResRef = "scimitar"; // Medium
    else if (iRoll < 94) sResRef = "battleaxe"; // Medium
    else if (iRoll < 96) sResRef = "lightflail"; // Medium
    else if (iRoll < 98) sResRef = "warhammer"; // Medium
    else sResRef = "heavypick"; // Medium
    object oItem = CreateItemOnObject (sResRef, oCreature);
    if (oItem  == OBJECT_INVALID) SetModuleError ("RESREF", "0i_items", "1185", "Created invalid resref: " + sResRef);
    else SetDroppableFlag (oItem, bDroppable);
    // Give them a medium weapon.
    if (nSize == CREATURE_SIZE_SMALL) iRoll = Random (30) + 1;
    else if (nSize == CREATURE_SIZE_MEDIUM) iRoll = Random (84) + 1;
    else iRoll = d100();
    if (iRoll < 11) sResRef = "dagger"; // Tiny
    else if (iRoll < 13) sResRef = "kukri"; // Tiny
    else if (iRoll < 15) sResRef = "mace"; // Small
    else if (iRoll < 17) sResRef = "sickle"; // Small
    else if (iRoll < 27) sResRef = "shortsword"; // Small
    else if (iRoll < 29) sResRef = "lighthammer"; // Small
    else if (iRoll < 31) sResRef = "lightpick"; // Small
    else if (iRoll < 33) sResRef = "heavymace"; // Medium
    else if (iRoll < 35) sResRef = "club"; // Medium
    else if (iRoll < 37) sResRef = "morningstar"; //Medium
    else if (iRoll < 47) sResRef = "longsword"; // Medium
    else if (iRoll < 67) sResRef = "rapier"; // Medium
    else if (iRoll < 77) sResRef = "scimitar"; // Medium
    else if (iRoll < 79) sResRef = "battleaxe"; // Medium
    else if (iRoll < 81) sResRef = "lightflail"; // Medium
    else if (iRoll < 83) sResRef = "warhammer"; // Medium
    else if (iRoll < 85) sResRef = "heavypick"; // Medium
    else if (iRoll < 87) sResRef = "greataxe"; // Large
    else if (iRoll < 90) sResRef = "greatsword"; // Large
    else if (iRoll < 92) sResRef = "heavyflail"; // large
    else if (iRoll < 94) sResRef = "halberd"; // Large
    else if (iRoll < 97) sResRef = "falchion"; // Large
    else if (iRoll < 99) sResRef = "maul"; // Large
    else sResRef = "trident"; // Large
    oItem = CreateItemOnObject (sResRef, oCreature);
    if (oItem  == OBJECT_INVALID) SetModuleError ("RESREF", "0i_items", "1216", "Created invalid resref: " + sResRef);
    else SetDroppableFlag (oItem, bDroppable);
    return oItem;
}

// Gives oCreature a melee weapon that does d4.
object Gived4MeleeWeapons (object oCreature)
{
   string sResRef;
   int iRoll = d3();
   if (iRoll == 1) sResRef = "dagger";
   else if (iRoll == 2) sResRef = "lighthammer";
   else sResRef = "kukri";
   object oItem = CreateItemOnObject (sResRef, oCreature);
   if (oItem == OBJECT_INVALID) SetModuleError ("RESREF", "0i_items", "1228", "Created invalid resref: " + sResRef);
   return oItem;
}

// Gives oCreature a melee weapon that does d6.
object Gived6MeleeWeapons (object oCreature)
{
   string sResRef;
   int iRoll = d6();
   if (iRoll == 1) sResRef = "mace";
   else if (iRoll == 2) sResRef = "sickle";
   else if (iRoll == 3) sResRef = "club";
   else if (iRoll == 4) sResRef = "quarterstaff";
   // Uncommon simple weapons.
   else if (iRoll == 5) sResRef = "shortsword";
   else sResRef = "rapier";
   object oItem = CreateItemOnObject (sResRef, oCreature);
   if (oItem == OBJECT_INVALID) SetModuleError ("RESREF", "0i_items", "1245", "Created invalid resref: " + sResRef);
   return oItem;
}

// Gives oCreature a melee weapon that does d8.
object Gived8MeleeWeapons (object oCreature)
{
   string sResRef;
   int iRoll = d10();
   // Common martial weapons.
   if (iRoll == 1) sResRef = "morningstar";
   else if (iRoll == 2) sResRef = "shortspear";
   else if (iRoll == 3) sResRef = "battleaxe";
   else if (iRoll == 4) sResRef = "warhammer";
   else if (iRoll == 5) sResRef = "falchion";
   else if (iRoll == 6) sResRef = "scythe";
   // Uncommon martial weapons.
   else if (iRoll == 7) sResRef = "flail";
   else sResRef = "longsword";
   object oItem = CreateItemOnObject (sResRef, oCreature);
   if (oItem == OBJECT_INVALID) SetModuleError ("RESREF", "0i_items", "1265", "Created invalid resref: " + sResRef);
   return oItem;
}

// Gives oCreature a melee weapon that does d10.
object Gived10MeleeWeapons (object oCreature)
{
   string sResRef;
   int iRoll = d3();
   // Common martial weapons.
   if (iRoll == 1) sResRef = "halberd";
   else if (iRoll == 2) sResRef = "bastardsword";
   else sResRef = "dwarvenwaraxe";
   object oItem = CreateItemOnObject (sResRef, oCreature);
   if (oItem == OBJECT_INVALID) SetModuleError ("RESREF", "0i_items", "1279", "Created invalid resref: " + sResRef);
   return oItem;
}

// Gives oCreature a melee weapon that does d12.
object Gived12MeleeWeapons (object oCreature)
{
   string sResRef;
   int iRoll = d2();
   // Common martial weapons.
   if (iRoll == 1) sResRef = "greataxe";
   else if (iRoll == 2) sResRef = "greatsword";
   object oItem = CreateItemOnObject (sResRef, oCreature);
   if (oItem == OBJECT_INVALID) SetModuleError ("RESREF", "0i_items", "1292", "Created invalid resref: " + sResRef);
   return oItem;
}

// Gives creature clothing.
object GiveClothing (object oCreature, int bDroppable = TRUE)
{
    string sResRef;
    int iRoll = d100();
    object oItem, oItem2, oItem3, oTempChest;
    if (iRoll < 26) sResRef = "outfit";
    else if (iRoll < 51) sResRef = "robe";
    else if (iRoll < 78) sResRef = "garb";
    else sResRef = "tunic";
   sResRef = sResRef + "_" + IntToString (d4());
   // Get the Building container.
   oTempChest = GetObjectByTag (TEMP_CHEST);
   // Create Item.
   oItem = CreateItemOnObject (sResRef, oTempChest);
   if (oItem == OBJECT_INVALID) SetModuleError ("RESREF", "0i_items", "1311", "Created invalid resref: " + sResRef);
   else
   {
       // Change items appearance.
       oItem2 = ChangeItemAppearance (oItem, 0);
       // Copy final item to container.
       oItem3 = CopyItem (oItem2, oCreature, TRUE);
       // Destroy Buildcontainer copy.
       DestroyObject (oItem);
       DestroyObject (oItem2);
   }
   SetDroppableFlag (oItem3, bDroppable);
   return oItem3;
}

// Gives oCreature a set of light armor.
// iType: 0 - light, 1 - medium, 2 - heavy, 3 - light/medium
// 4 - medium/heavy, 5 - light/medium/heavy.
object GiveArmor(object oCreature, int nType = 0)
{
   string sResRef = "";
   object oItem, oItem2, oItem3, oTempChest;
   int iRoll = d100();
   switch (nType)
   {
      case 0 :
      {
         if (iRoll < 33) sResRef = sResRef + "padded";
         else if (iRoll < 66) sResRef = sResRef + "leather";
         else sResRef = sResRef + "stleather";
         break;
      }
      case 1 :
      {
         if (iRoll < 06) sResRef = sResRef + "hide";
         else if (iRoll < 31)sResRef = sResRef + "chainshirt";
         else if (iRoll < 56) sResRef = sResRef + "scalemail";
         else if (iRoll < 76) sResRef = sResRef + "chainmail";
         else sResRef = sResRef + "breastplate";
         break;
      }
      case 2 :
      {
         if (iRoll < 26) sResRef = sResRef + "splintmail";
         else if (iRoll < 46) sResRef = sResRef + "bandedmail";
         else if (iRoll < 76) sResRef = sResRef + "halfplate";
         else sResRef = sResRef + "fullplate";
         break;
      }
      case 3 :
      {
         if (iRoll < 06) sResRef = sResRef + "padded";
         else if (iRoll < 16) sResRef = sResRef + "leather";
         else if (iRoll < 31) sResRef = sResRef + "stleather";
         else if (iRoll < 51) sResRef = sResRef + "chainshirt";
         else if (iRoll < 54) sResRef = sResRef + "hide";
         else if (iRoll < 79) sResRef = sResRef + "scalemail";
         else if (iRoll < 91) sResRef = sResRef + "chainmail";
         else sResRef = sResRef + "breastplate";
         break;
      }
      case 4 :
      {
         if (iRoll < 3) sResRef = sResRef + "hide";
         else if (iRoll < 27) sResRef = sResRef + "scalemail";
         else if (iRoll < 39) sResRef = sResRef + "chainmail";
         else if (iRoll < 51) sResRef = sResRef + "breastplate";
         else if (iRoll < 64) sResRef = sResRef + "splintmail";
         else if (iRoll < 74) sResRef = sResRef + "bandedmail";
         else if (iRoll < 89) sResRef = sResRef + "halfplate";
         else sResRef = sResRef + "fullplate";
         break;
      }
      case 5 :
      {
         if (iRoll < 02) sResRef = sResRef + "padded";
         else if (iRoll < 03) sResRef = sResRef + "leather";
         else if (iRoll < 18) sResRef = sResRef + "stleather";
         else if (iRoll < 33) sResRef = sResRef + "chainshirt";
         else if (iRoll < 43) sResRef = sResRef + "hide";
         else if (iRoll < 44) sResRef = sResRef + "scalemail";
         else if (iRoll < 45) sResRef = sResRef + "chainmail";
         else if (iRoll < 58) sResRef = sResRef + "breastplate";
         else if (iRoll < 59) sResRef = sResRef + "splintmail";
         else if (iRoll < 60) sResRef = sResRef + "bandedmail";
         else if (iRoll < 61) sResRef = sResRef + "halfplate";
         else sResRef = sResRef + "fullplate";
         break;
      }
   }
   sResRef = sResRef + "_" + IntToString (d4());;
   // Get the Building container.
   oTempChest = GetObjectByTag (TEMP_CHEST);
   // Create Item.
   oItem = CreateItemOnObject (sResRef, oTempChest);
   if (oItem == OBJECT_INVALID) SetModuleError ("RESREF", "0i_items", "1406", "Created invalid resref: " + sResRef);
   else
   {
       // Change items appearance.
       oItem2 = ChangeItemAppearance (oItem, 0);
       // Copy final item to container.
       oItem3 = CopyItem (oItem2, oCreature, TRUE);
       // Destroy Buildcontainer copy.
       DestroyObject (oItem);
       DestroyObject (oItem2);
   }
   return oItem3;
}

// Gives creature a shield.
object GiveShield (object oCreature)
{
   string sResRef;
   object oItem, oItem2, oItem3, oTempChest;
   int iRoll = d100();
   // Shields.
   if (iRoll < 30) sResRef = "smshield";
   else if (iRoll < 90) sResRef = "lgshield";
   else sResRef = "twshield";
   // Get the Building container.
   oTempChest = GetObjectByTag (TEMP_CHEST);
   // Create Item.
   oItem = CreateItemOnObject (sResRef, oTempChest);
   if (oItem == OBJECT_INVALID) SetModuleError ("RESREF", "0i_items", "1434", "Created invalid resref: " + sResRef);
   else
   {
       // Change items appearance.
       oItem2 = ChangeItemAppearance (oItem, 0);
       // Copy final item to container.
       oItem3 = CopyItem (oItem2, oCreature, TRUE);
       // Destroy Buildcontainer copy.
       DestroyObject (oItem);
       DestroyObject (oItem2);
   }
   return oItem3;
}

// Gives equipment to a creature based on their feats.
// oCreature is the creature to equip.
// bDroppable: TRUE will make the items drop, FALSE they will not.
// iItem allows you to select one item and get it returned.
// Arguments:
// BASE_ITEM_ARMOR = 16;
// BASE_ITEM_MELEE_WEAPON = 133;
// BASE_ITEM_RANGED_WEAPON = 137;
// BASE_ITEM_SHIELD = 140;
// iPackage is the package of the NPC class.
object GiveEquipment (object oCreature, int bDroppable = TRUE, int nItem = -1, int nPackage = PACKAGE_INVALID)
{
    int nLevel = FloatToInt (GetChallengeRating(oCreature));
    int nClass = GetClassByPosition (1, oCreature);
    object oItem;
    if (nItem > -1)
    {
        if (nItem == 16)
        {
            // Give a set of armor; Light any level , Medium > 2nd, Heavy > 4th.
            if (GetHasFeat (FEAT_ARMOR_PROFICIENCY_HEAVY, oCreature) && nLevel > 4) oItem = GiveArmor (oCreature, 2);
            else if (GetHasFeat (FEAT_ARMOR_PROFICIENCY_MEDIUM, oCreature) && nLevel > 2) oItem = GiveArmor (oCreature, 1);
            else if (GetHasFeat (FEAT_ARMOR_PROFICIENCY_LIGHT, oCreature)) oItem = GiveArmor (oCreature, 0);
            else oItem = GiveClothing (oCreature);
        }
        else if (nItem == 140)
        {
            oItem = GiveShield (oCreature);
        }
        else if (nItem == 133)
        {
            // Give a melee weapon; Simple any, Martial > 2nd, Exotic > 4th.
            if (GetHasFeat (FEAT_TWO_WEAPON_FIGHTING)) GiveTwoWeaponStyleWeapons (oCreature, bDroppable);
            else if (GetHasFeat (FEAT_WEAPON_PROFICIENCY_EXOTIC, oCreature) && nLevel > 4) oItem = GiveExoticMeleeWeapons (oCreature);
            else if (GetHasFeat (FEAT_WEAPON_PROFICIENCY_MARTIAL, oCreature) && nLevel > 2) oItem = GiveMartialMeleeWeapons (oCreature);
            else if (GetHasFeat (FEAT_WEAPON_PROFICIENCY_ELF, oCreature)) oItem = GiveSpecialWeapon (oCreature, 1);
            else if (GetHasFeat (FEAT_WEAPON_PROFICIENCY_SIMPLE, oCreature)) oItem = GiveSimpleMeleeWeapons (oCreature);
            else if (GetHasFeat (FEAT_WEAPON_PROFICIENCY_DRUID, oCreature)) oItem = GiveSpecialWeapon (oCreature, 2);
            else if (GetHasFeat (FEAT_WEAPON_PROFICIENCY_MONK, oCreature)) oItem = GiveSpecialWeapon (oCreature, 3);
            else if (GetHasFeat (FEAT_WEAPON_PROFICIENCY_ROGUE, oCreature)) oItem = GiveSpecialWeapon (oCreature, 4);
            else if (GetHasFeat (FEAT_WEAPON_PROFICIENCY_WIZARD, oCreature)) oItem = GiveSpecialWeapon (oCreature, 5);
        }
        else if (nItem == 137)
        {
            if (GetHasFeat (FEAT_WEAPON_PROFICIENCY_MARTIAL, oCreature))
            {
                oItem = GiveMartialRangedWeapons (oCreature);
            }
            else if (GetHasFeat (FEAT_WEAPON_PROFICIENCY_SIMPLE, oCreature))
            {
                oItem = GiveSimpleRangedWeapons (oCreature);
            }
        }
        else
        {
            string sResRef = Get2DAString ("smi_list", "ResRef", nItem);
            oItem = CreateItemOnObject (sResRef, oCreature);
        }
        SetDroppableFlag(oItem, bDroppable);
        return oItem;
    }
    // Give a set of armor; Ranger/Barbarian - Light, Light any level , Medium > 2nd, Heavy > 4th.
    if (nClass == CLASS_TYPE_BARBARIAN || nClass == 46/*CLASS_TYPE_RANGER*/) oItem = GiveArmor (oCreature, 0);
    else if (GetHasFeat (FEAT_ARMOR_PROFICIENCY_HEAVY, oCreature) && nLevel > 4) oItem = GiveArmor (oCreature, 2);
    else if (GetHasFeat (FEAT_ARMOR_PROFICIENCY_MEDIUM, oCreature) && nLevel > 2) oItem = GiveArmor (oCreature, 1);
    else if (GetHasFeat (FEAT_ARMOR_PROFICIENCY_LIGHT, oCreature)) oItem = GiveArmor (oCreature, 0);
    else oItem = GiveClothing (oCreature);
    SetDroppableFlag (oItem, bDroppable);
    if (nPackage == PACKAGE_INVALID) nPackage = GetClassByPosition (0, oCreature);
    int nSpecificWeapon;
    string sSpecificWeapon = Get2DAString ("packages", "Weapon", nPackage);
    if (sSpecificWeapon != "")
    {
        nSpecificWeapon = StringToInt (sSpecificWeapon);
        string sResRef = Get2DAString ("smi_list", "ResRef", nSpecificWeapon);
        oItem = CreateItemOnObject (sResRef, oCreature);
        // Check for an error.
        if (oItem == OBJECT_INVALID) SetModuleError ("RESREF", "0i_items", "1523", "Packages.2da column weapon (" + sSpecificWeapon + ") is invalid for row: " + IntToString (nPackage));
    }
    // Give a weapon; Simple any, Martial > 2nd, Exotic > 4th.
    if (GetHasFeat (FEAT_TWO_WEAPON_FIGHTING) || GetHasFeat (374/*FEAT_DUAL_WIELD*/)) GiveTwoWeaponStyleWeapons (oCreature, bDroppable);
    else if (GetHasFeat (FEAT_WEAPON_PROFICIENCY_EXOTIC, oCreature) && nLevel > 4) oItem = GiveExoticMeleeWeapons (oCreature);
    else if (GetHasFeat (FEAT_WEAPON_PROFICIENCY_MARTIAL, oCreature) && nLevel > 2) oItem = GiveMartialMeleeWeapons (oCreature);
    else if (GetHasFeat (FEAT_WEAPON_PROFICIENCY_ELF, oCreature)) oItem = GiveSpecialWeapon (oCreature, 1);
    else if (GetHasFeat (FEAT_WEAPON_PROFICIENCY_SIMPLE, oCreature)) oItem = GiveSimpleMeleeWeapons (oCreature);
    else if (GetHasFeat (FEAT_WEAPON_PROFICIENCY_DRUID, oCreature)) oItem = GiveSpecialWeapon (oCreature, 2);
    else if (GetHasFeat (FEAT_WEAPON_PROFICIENCY_MONK, oCreature)) oItem = GiveSpecialWeapon (oCreature, 3);
    else if (GetHasFeat (FEAT_WEAPON_PROFICIENCY_ROGUE, oCreature)) oItem = GiveSpecialWeapon (oCreature, 4);
    else if (GetHasFeat (FEAT_WEAPON_PROFICIENCY_WIZARD, oCreature)) oItem = GiveSpecialWeapon (oCreature, 5);
    SetDroppableFlag (oItem, bDroppable);
    // Check for a shield and ranged weapon on creature 3rd level or higher.
    if (nLevel > 2)
    {
        if (GetHasFeat (FEAT_SHIELD_PROFICIENCY, oCreature))
        {
            oItem = GiveShield (oCreature);
            SetDroppableFlag (oItem, bDroppable);
        }
        oItem = OBJECT_INVALID;
        // Chance for ranged weapon 7% per level (1=7%, 5=35%, 10=70%, 15=100%).
        if (!GetLocalInt (oCreature, "0_No_Ranged") && d100() < nLevel * 7)
        {
            if (GetHasFeat (FEAT_WEAPON_PROFICIENCY_MARTIAL, oCreature))
            {
                oItem = GiveMartialRangedWeapons (oCreature);
            }
            else if (GetHasFeat (FEAT_WEAPON_PROFICIENCY_SIMPLE, oCreature))
            {
                oItem = GiveSimpleRangedWeapons (oCreature);
            }
            else if (GetHasFeat (FEAT_WEAPON_PROFICIENCY_ROGUE, oCreature))
            {
               oItem = CreateItemOnObject ("shortbow", oCreature);
            }
            SetDroppableFlag (oItem, bDroppable);
            if (oItem != OBJECT_INVALID)
            {
                object oAmmo;
                int nBaseItemType = GetBaseItemType (oItem);
                switch (nBaseItemType)
                {
                    case BASE_ITEM_LONGBOW:
                    case BASE_ITEM_SHORTBOW:
                    {
                        oAmmo = CreateItemOnObject ("arrow", oCreature, Random (50) + 51);
                        break;
                    }
                    case BASE_ITEM_HEAVYCROSSBOW:
                    case BASE_ITEM_LIGHTCROSSBOW:
                    {
                        oAmmo = CreateItemOnObject ("bolt", oCreature, Random (50) + 51);
                        break;
                    }
                    case BASE_ITEM_SLING:
                    {
                        oAmmo = CreateItemOnObject ("bullet", oCreature, Random (50) + 51);
                        break;
                    }
                }
                SetDroppableFlag (oAmmo, bDroppable);
            }
        }
    }
    return OBJECT_INVALID;
}

void DelayedCreateItemOnObject (string sItemTag, object oContainer)
{
    CreateItemOnObject (sItemTag, oContainer);
}

// Checks each item in a container and makes a roll to see if its breaks.
// Replaced with an appropriate broken item.
void CheckForBrokenItems (object oContainer)
{
   // Lets get each item and check the type.
   int iCounter = 1, iItemType, iRoll;
   string sItemTag;
   object oItem = GetFirstItemInInventory (oContainer);
   while (oItem != OBJECT_INVALID && iCounter < 50)
   {
      //Debug ("0_inc_items", "633", GetName (oItem) + " is being checked for breakage!");
      iRoll = d100();
      iItemType = GetBaseItemType (oItem);
      sItemTag = "";
      switch (iItemType)
      {
         case BASE_ITEM_AMULET : { if (iRoll <= CHANCE_BREAK_AMULET) sItemTag = "0_broken_amulet"; break; }
         case BASE_ITEM_ARMOR : { if (iRoll <= CHANCE_BREAK_ARMOR) sItemTag = "0_broken_armor"; break; }
         case BASE_ITEM_BELT : { if (iRoll <= CHANCE_BREAK_BELT) sItemTag = "0_broken_belt"; break; }
         case BASE_ITEM_BOOTS : { if (iRoll <= CHANCE_BREAK_BOOTS) sItemTag = "0_broken_boots"; break; }
         case BASE_ITEM_BRACER : { if (iRoll <= CHANCE_BREAK_BRACER) sItemTag = "0_broken_bracers"; break; }
         case BASE_ITEM_CLOAK : { if (iRoll <= CHANCE_BREAK_CLOAK) sItemTag = "0_broken_cloak"; break; }
         case BASE_ITEM_GLOVES : { if (iRoll <= CHANCE_BREAK_GLOVES) sItemTag = "0_broken_gloves"; break; }
         case BASE_ITEM_HELMET : { if (iRoll <= CHANCE_BREAK_HELMET) sItemTag = "0_broken_helmet"; break; }
         case BASE_ITEM_MAGICROD : { if (iRoll <= CHANCE_BREAK_ROD) sItemTag = "0_broken_rod"; break; }
         case BASE_ITEM_MAGICSTAFF : { if (iRoll <= CHANCE_BREAK_STAFF) sItemTag = "0_broken_staff"; break; }
         case BASE_ITEM_BLANK_WAND :
         case BASE_ITEM_ENCHANTED_WAND :
         case BASE_ITEM_MAGICWAND : { if (iRoll <= CHANCE_BREAK_WAND) sItemTag = "0_broken_wand"; break; }
         case BASE_ITEM_MISCLARGE :
         case BASE_ITEM_MISCMEDIUM :
         case BASE_ITEM_MISCSMALL :
         case BASE_ITEM_MISCTALL :
         case BASE_ITEM_MISCTHIN :
         case BASE_ITEM_MISCWIDE : { if (iRoll <= CHANCE_BREAK_MISC) sItemTag = "0_broken_misc"; break; }
         case BASE_ITEM_BLANK_POTION :
         case BASE_ITEM_ENCHANTED_POTION :
         case BASE_ITEM_POTIONS : { if (iRoll <= CHANCE_BREAK_POTION) sItemTag = "0_broken_potion"; break; }
         case BASE_ITEM_BLANK_SCROLL :
         case BASE_ITEM_ENCHANTED_SCROLL :
         case BASE_ITEM_SPELLSCROLL :
         case BASE_ITEM_SCROLL : { if (iRoll <= CHANCE_BREAK_SCROLL) sItemTag = "0_broken_scroll"; break; }
         case BASE_ITEM_RING : { if (iRoll <= CHANCE_BREAK_RING) sItemTag = "0_broken_ring"; break; }
         case BASE_ITEM_GRENADE : { if (iRoll <= CHANCE_BREAK_GRENADE) sItemTag = "0_broken_potion"; break; }
      }
      if (GetIsWeapon (oItem)) if (iRoll <= CHANCE_BREAK_WEAPON) sItemTag = "0_Broken_weapon";
      if (sItemTag != "")
      {
         //Debug ("0_inc_items", "662", sItemTag + "(the tag of the item that is broken");
         DestroyObject (oItem);
         // Delay the creation of the broken items so they don't get checked!
         DelayCommand (0.5f, DelayedCreateItemOnObject (sItemTag, oContainer));
      }
      iCounter ++;
      oItem = GetNextItemInInventory (oContainer);
   }
}

// Get the items max models and max colors.
// oItem is the item to check.
// sPart is the part to get for:
// TopModel, MiddleModel, BottomModel - Used for weapon models.
// Color - Used for weapon colors.
int GetItemsMaxModels (object oItem, string sPart)
{
    return StringToInt (Get2DAString ("smi_list", sPart, GetBaseItemType (oItem)));
}

// Changes an items appearance this will remove the item sent
// and the new item put in its place.
// oContainer is where the original item is.
// oItem is the item to change.
// iQuality defines the different levels of item appearances.
// 1 = Master work, 2 = Exquisite, 3 = Legendary, 4 = Relic, 5 = Artifact.
object ChangeItemAppearance (object oItem, int iQuality = 0)
{
    int iBaseItemType, iType, iIndex, iDie, iMod, iRoll, iColor, iRtop, iRmid, iRbottom;
    int iColorT, iColorM, iColorB;
    string sName, sDie;
    object oItem1, oItem2, oItem3, oItem4, oItem5, oItem6, oItem7, oItemFinal, oItemDone;
    string sResRef = GetResRef (oItem);
    // Get the items base type.
    iBaseItemType = GetBaseItemType (oItem);
    // Headgear (VFX versions) cannot have an appearance change.
    if (iBaseItemType == 23) return oItem;
    // Ammo that is not magical should all look the same.
    if (GetIsAmmo (oItem) && !GetItemHasItemProperty (oItem, ITEM_PROPERTY_QUALITY)) return oItem;
    // Get the object holding the item.
    object oHolder = GetItemPossessor (oItem);
    // Get the Building container.
    object oBuildContainer = GetObjectByTag (TEMP_CHEST);
    // Move the item to the building container.
    oItem1 = CopyItem (oItem, oBuildContainer, TRUE);
    // Remove the original item.
    DestroyObject (oItem);
    if (GetIsWeapon (oItem1))
    {
        int iWModuleBottom, iWModuleMiddle, iWModuleTop;
        iWModuleBottom = GetItemsMaxModels (oItem1, "BottomModel");
        iWModuleMiddle = GetItemsMaxModels (oItem1, "MiddleModel");
        iWModuleTop = GetItemsMaxModels (oItem1, "TopModel");
        iColor = GetItemsMaxModels (oItem1, "Color");
        if (iWModuleTop == 0)
        {
            // iWModuleTop of 0 tells us the weapon is a simple module and we use
            // iWModuleMiddle as the 10's and iWModuleBottom as the 1's for the die roll.
            iDie = ((Random (iWModuleMiddle) + 1) * 10) + (Random (iWModuleBottom) + 1);
            oItemFinal = CopyItemAndModify (oItem1, ITEM_APPR_TYPE_SIMPLE_MODEL, 0, iDie, TRUE);
            DestroyObject (oItem1);
        }
        else
        {
            // Check for the quality of the weapon.
            if (iQuality < 2)
            {
                if (iWModuleTop > 4) iWModuleTop = 4;
                if (iWModuleMiddle > 4) iWModuleMiddle = 4;
                if (iWModuleBottom > 4) iWModuleBottom = 4;
            }
            // Check for the quality of the weapon.
            else if (iQuality < 4)
            {
                if (iWModuleTop > 12) iWModuleTop = 12;
                if (iWModuleMiddle > 12) iWModuleMiddle = 12;
                if (iWModuleBottom > 12) iWModuleBottom = 12;
            }
            iRtop = Random (iWModuleTop) + 1;
            // Check bows as they must randomize to the same top, middle, and bottom otherwise they look bad.
            if (iBaseItemType == BASE_ITEM_LONGBOW || iBaseItemType == BASE_ITEM_SHORTBOW)
            {
                iRmid = iRtop;
                iRbottom = iRtop;
            }
            // Randomize each item individualy for other weapons.
            else
            {
                iRmid = Random (iWModuleMiddle) + 1;
                iRbottom = Random (iWModuleBottom) + 1;
            }
            // Change weapons model.
            oItem2 = CopyItemAndModify (oItem1, ITEM_APPR_TYPE_WEAPON_MODEL, ITEM_APPR_WEAPON_MODEL_TOP, iRtop, TRUE);
            DestroyObject (oItem1, 0.0f);
            oItem3 = CopyItemAndModify (oItem2, ITEM_APPR_TYPE_WEAPON_MODEL, ITEM_APPR_WEAPON_MODEL_MIDDLE, iRmid, TRUE);
            DestroyObject (oItem2, 0.2f);
            oItem4 = CopyItemAndModify (oItem3, ITEM_APPR_TYPE_WEAPON_MODEL, ITEM_APPR_WEAPON_MODEL_BOTTOM, iRbottom, TRUE);
            DestroyObject (oItem3, 0.4f);
            // Change weapons color.
            iColorT = Random (iColor) + 1;
            iColorM = Random (iColor) + 1;
            iColorB = Random (iColor) + 1;
            oItem5 = CopyItemAndModify (oItem4, ITEM_APPR_TYPE_WEAPON_COLOR, ITEM_APPR_WEAPON_COLOR_TOP, iColorT, TRUE);
            DestroyObject (oItem4, 0.6f);
            oItem6 = CopyItemAndModify (oItem5, ITEM_APPR_TYPE_WEAPON_COLOR, ITEM_APPR_WEAPON_COLOR_MIDDLE, iColorM, TRUE);
            DestroyObject (oItem5, 0.8f);
            oItemFinal = CopyItemAndModify (oItem6, ITEM_APPR_TYPE_WEAPON_COLOR, ITEM_APPR_WEAPON_COLOR_BOTTOM, iColorB, TRUE);
            DestroyObject (oItem6, 1.0f);
        }
    }
    else if (iBaseItemType == BASE_ITEM_BOOTS)
    {
        oItem2 = CopyItemAndModify (oItem1, ITEM_APPR_TYPE_WEAPON_MODEL, ITEM_APPR_WEAPON_MODEL_TOP, Random (5) + 1, TRUE);
        DestroyObject (oItem1);
        oItem3 = CopyItemAndModify (oItem2, ITEM_APPR_TYPE_WEAPON_MODEL, ITEM_APPR_WEAPON_MODEL_MIDDLE, Random (4) + 1, TRUE);
        DestroyObject (oItem2);
        oItem4 = CopyItemAndModify (oItem3, ITEM_APPR_TYPE_WEAPON_MODEL, ITEM_APPR_WEAPON_MODEL_BOTTOM, Random (5) + 1, TRUE);
        DestroyObject (oItem3);
        oItem5 = CopyItemAndModify (oItem4, ITEM_APPR_TYPE_WEAPON_COLOR, ITEM_APPR_WEAPON_COLOR_TOP, Random (4) + 1, TRUE);
        DestroyObject (oItem4);
        oItem6 = CopyItemAndModify (oItem5, ITEM_APPR_TYPE_WEAPON_COLOR, ITEM_APPR_WEAPON_COLOR_MIDDLE, Random (4) + 1, TRUE);
        DestroyObject (oItem5);
        oItemFinal = CopyItemAndModify (oItem6, ITEM_APPR_TYPE_WEAPON_COLOR, ITEM_APPR_WEAPON_COLOR_BOTTOM, Random (8) + 1, TRUE);
        DestroyObject (oItem6);
    }
    else if (iBaseItemType == BASE_ITEM_HELMET)
    {
        // Check and see if this is a helmet
        if (sResRef == "helmet")
        {
            oItem2 = CopyItemAndModify (oItem1, ITEM_APPR_TYPE_SIMPLE_MODEL, 0, Random (42) + 1, TRUE);
            DestroyObject (oItem1);
        }
        // Code for masks.
        else if (sResRef == "mask")
        {
            oItem2 = CopyItemAndModify (oItem1, ITEM_APPR_TYPE_SIMPLE_MODEL, 0, Random (15) + 48, TRUE);
            DestroyObject (oItem1);
        }
        // Code for hoods.
        else
        {
            oItem2 = CopyItemAndModify (oItem1, ITEM_APPR_TYPE_SIMPLE_MODEL, 0, Random (5) + 43, TRUE);
            DestroyObject (oItem1);
        }
        oItem3 = CopyItemAndModify (oItem2, ITEM_APPR_TYPE_ARMOR_COLOR, ITEM_APPR_ARMOR_COLOR_LEATHER1, Random (175) + 1, TRUE);
        DestroyObject (oItem2);
        oItem4 = CopyItemAndModify (oItem3, ITEM_APPR_TYPE_ARMOR_COLOR, ITEM_APPR_ARMOR_COLOR_LEATHER2, Random (175) + 1, TRUE);
        DestroyObject (oItem3);
        oItem5 = CopyItemAndModify (oItem4, ITEM_APPR_TYPE_ARMOR_COLOR, ITEM_APPR_ARMOR_COLOR_CLOTH1, Random (175) + 1, TRUE);
        DestroyObject (oItem4);
        oItem6 = CopyItemAndModify (oItem5, ITEM_APPR_TYPE_ARMOR_COLOR, ITEM_APPR_ARMOR_COLOR_CLOTH2, Random (175) + 1, TRUE);
        DestroyObject (oItem5);
        oItem7 = CopyItemAndModify (oItem6, ITEM_APPR_TYPE_ARMOR_COLOR, ITEM_APPR_ARMOR_COLOR_METAL1, Random (175) + 1, TRUE);
        DestroyObject (oItem6);
        oItemFinal = CopyItemAndModify (oItem7, ITEM_APPR_TYPE_ARMOR_COLOR, ITEM_APPR_ARMOR_COLOR_METAL2, Random (175) + 1, TRUE);
        DestroyObject (oItem7);
    }
    else if (iBaseItemType == BASE_ITEM_CLOAK)
    {
        iRoll = d100();
        // Setup what the chance of a being able to roll a God's cloak.
        if (iRoll < 6) iRoll = 102;
        // Setup what the chance of a being able to roll a Group's cloak.
        else if (iRoll < 26) iRoll = 31;
        // Otherwise just roll a normal cloak.
        else iRoll = 21;
        oItem2 = CopyItemAndModify (oItem1, ITEM_APPR_TYPE_SIMPLE_MODEL, 0, Random (iRoll), TRUE);
        DestroyObject (oItem1);
        oItem3 = CopyItemAndModify (oItem2, ITEM_APPR_TYPE_ARMOR_COLOR, ITEM_APPR_ARMOR_COLOR_LEATHER1, Random (175) + 1, TRUE);
        DestroyObject (oItem2);
        oItem4 = CopyItemAndModify (oItem3, ITEM_APPR_TYPE_ARMOR_COLOR, ITEM_APPR_ARMOR_COLOR_LEATHER2, Random (175) + 1, TRUE);
        DestroyObject (oItem3);
        oItem5 = CopyItemAndModify (oItem4, ITEM_APPR_TYPE_ARMOR_COLOR, ITEM_APPR_ARMOR_COLOR_CLOTH1, Random (175) + 1, TRUE);
        DestroyObject (oItem4);
        oItem6 = CopyItemAndModify (oItem5, ITEM_APPR_TYPE_ARMOR_COLOR, ITEM_APPR_ARMOR_COLOR_CLOTH2, Random (175) + 1, TRUE);
        DestroyObject (oItem5);
        oItem7 = CopyItemAndModify (oItem6, ITEM_APPR_TYPE_ARMOR_COLOR, ITEM_APPR_ARMOR_COLOR_METAL1, Random (175) + 1, TRUE);
        DestroyObject (oItem6);
        oItemFinal = CopyItemAndModify (oItem7, ITEM_APPR_TYPE_ARMOR_COLOR, ITEM_APPR_ARMOR_COLOR_METAL2, Random (175) + 1, TRUE);
        DestroyObject (oItem7);
    }
    else if (iBaseItemType == BASE_ITEM_LARGESHIELD)
    {
        iRoll = Random ((iQuality + 1)* 33) + 1;
        if (iRoll > 163) iRoll = 163;
        oItemFinal = CopyItemAndModify (oItem1, ITEM_APPR_TYPE_SIMPLE_MODEL, 0, iRoll, TRUE);
        DestroyObject (oItem1);
    }
    else if (iBaseItemType == BASE_ITEM_SMALLSHIELD)
    {
        iRoll = Random ((iQuality + 1)* 13) + 1;
        if (iRoll > 64) iRoll = 64;
        oItemFinal = CopyItemAndModify (oItem1, ITEM_APPR_TYPE_SIMPLE_MODEL, 0, iRoll, TRUE);
        DestroyObject (oItem1);
    }
    else if (iBaseItemType == BASE_ITEM_TOWERSHIELD)
    {
        iRoll = Random ((iQuality + 1)* 25) + 1;
        if (iRoll > 124) iRoll = 124;
        oItemFinal = CopyItemAndModify (oItem1, ITEM_APPR_TYPE_SIMPLE_MODEL, 0, iRoll, TRUE);
        DestroyObject (oItem1);
    }
    else if (iBaseItemType == BASE_ITEM_AMULET)
    {
        iRoll = d100();
        // Setup what the chance of a being able to roll a God's amulet
        if (iRoll < 6) iRoll = 163;
        // Otherwise just roll a normal cloak.
        else iRoll = 107;
        oItemFinal = CopyItemAndModify (oItem1, ITEM_APPR_TYPE_SIMPLE_MODEL, 0, Random (iRoll) + 1, TRUE);
        DestroyObject (oItem1);
    }
    else if (iBaseItemType == BASE_ITEM_BELT)
    {
        oItemFinal = CopyItemAndModify (oItem1, ITEM_APPR_TYPE_SIMPLE_MODEL, 0, Random (110) + 1, TRUE);
        DestroyObject (oItem1);
    }
    else if (iBaseItemType == BASE_ITEM_BRACER)
    {
        oItemFinal = CopyItemAndModify (oItem1, ITEM_APPR_TYPE_SIMPLE_MODEL, 0, Random (78) + 1, TRUE);
        DestroyObject (oItem1);
    }
    else if (iBaseItemType == BASE_ITEM_GLOVES)
    {
        sName = GetName (oItem);
        if (sName == "Gloves") { iDie = 62; iMod = 1;}
        else if (sName == "Gauntlets") { iDie = 50; iMod = 62;}
        iRoll = Random (iDie) + iMod;
        oItemFinal = CopyItemAndModify (oItem1, ITEM_APPR_TYPE_SIMPLE_MODEL, 0, iRoll, TRUE);
        DestroyObject (oItem1);
    }
    else if (iBaseItemType == BASE_ITEM_RING)
    {
        oItemFinal = CopyItemAndModify (oItem1, ITEM_APPR_TYPE_SIMPLE_MODEL, 0, Random (232) + 1, TRUE);
        DestroyObject (oItem1);
    }
    else if (iBaseItemType == BASE_ITEM_ARMOR)
    {
        if (d100() < 76)
        {
            oItem2 = CopyItemAndModify (oItem1, ITEM_APPR_TYPE_ARMOR_COLOR, ITEM_APPR_ARMOR_COLOR_LEATHER1, Random (175) + 1, TRUE);
            DestroyObject (oItem1);
            oItem3 = CopyItemAndModify (oItem2, ITEM_APPR_TYPE_ARMOR_COLOR, ITEM_APPR_ARMOR_COLOR_LEATHER2, Random (175) + 1, TRUE);
            DestroyObject (oItem2);
            if (d100() < 51)
            {
                oItem4 = CopyItemAndModify (oItem3, ITEM_APPR_TYPE_ARMOR_COLOR, ITEM_APPR_ARMOR_COLOR_CLOTH1, Random (175) + 1, TRUE);
                DestroyObject (oItem3);
                oItem5 = CopyItemAndModify (oItem4, ITEM_APPR_TYPE_ARMOR_COLOR, ITEM_APPR_ARMOR_COLOR_CLOTH2, Random (175) + 1, TRUE);
                DestroyObject (oItem4);
                if (d100() < 26)
                {
                    oItem6 = CopyItemAndModify (oItem5, ITEM_APPR_TYPE_ARMOR_COLOR, ITEM_APPR_ARMOR_COLOR_METAL1, Random (175) + 1, TRUE);
                    DestroyObject (oItem5);
                    oItemFinal = CopyItemAndModify (oItem6, ITEM_APPR_TYPE_ARMOR_COLOR, ITEM_APPR_ARMOR_COLOR_METAL2, Random (175) + 1, TRUE);
                    DestroyObject (oItem6);
                }
                else oItemFinal = oItem5;
            }
            else oItemFinal = oItem3;
        }
        else oItemFinal = oItem1;
    }
    // It is not in the list to be changed so copy it back.
    else oItemFinal = oItem1;
    // Put the item back.
    oItemDone = CopyItem (oItemFinal, oHolder, TRUE);
    DestroyObject (oItemFinal);
    return oItemDone;
}

// Removes Tagged item properties.
// Used to remove tagged item properties such as those in a set.
// oItem is the item to remove the properties from.
// sSetTag is the tag put on those properties.
void RemoveTempProperties (object oItem, string sSetTag)
{
    int iProperties, iCount;
    itemproperty ipProperty;
    // Cycle through the items properties and remove any that use the sSetTag.
    iCount = 1;
    ipProperty = GetFirstItemProperty (oItem);
    while (GetIsItemPropertyValid (ipProperty))
    {
        if (sSetTag == GetItemPropertyTag (ipProperty)) RemoveItemProperty (oItem, ipProperty);
        ipProperty = GetNextItemProperty (oItem);
        iCount ++;
    }
}

// Removes items from a creature or placeable.
// Will not remove a Players's Handbook, Dungeon Masters Guide, or Creature Skin!
// iEquiped will remove a creatures equiped items if TRUE.
// This will not remove a Players's Handbook or Dungeon Masters Guide!
// oCreature is the creature or container to remove the items.
// iEquiped will remove iEquiped items as well.
// iIgnoreSlot will ignore one slot on the equiped character INVENTORY_SLOT_*.
void RemoveItems (object oCreature, int iEquiped = FALSE, int iIgnoreSlot = -1)
{
    // Lets destroy all items in the inventory.
    object oItem = GetFirstItemInInventory (oCreature);
    string sTag = GetTag (oItem);
    while (oItem != OBJECT_INVALID)
    {
        // Filter out Player's and DM's books so we can keep them.
        if (sTag != "players_book" || sTag != "dm_guide") DestroyObject (oItem);
        oItem = GetNextItemInInventory (oCreature);
    }
    if (iEquiped)
    {
       // Go through equiped items and destroy them. Slot values are 0 - 17.
       // Skip slot 17 the skin as we need that to always remain.
       int iCounter = 0;
       oItem = GetItemInSlot (iCounter, oCreature);
       while (iCounter < 17)
       {
           if (oItem != OBJECT_INVALID && iIgnoreSlot != iCounter) DestroyObject (oItem);
           iCounter ++;
           oItem = GetItemInSlot (iCounter, oCreature);
       }
    }
}

// Returns an items size based on 1-small to 6-large.
int GetItemSize (object oItem)
{
    int nBaseItemType = GetBaseItemType (oItem);
    int nWidth = StringToInt (Get2DAString ("baseitems", "InvSlotWidth", nBaseItemType));
    int nHeight = StringToInt (Get2DAString ("baseitems", "InvSlotHeight", nBaseItemType));
    return nWidth + nHeight - 1;
}

// Identifies all items on oObject based on the 2da "SkillVsItemCost
// vs OBJECT_SELF  Knowledge skill.
// Reports the findings to oPC unless oPC = OBJECT_INVALID.
void IdentifyAllVsKnowledge (object oObject, object oPC = OBJECT_INVALID)
{
    // SkillVsItemCost 2da starts 1 at 0 ... go figure!
    int nKnowledge = GetSkillRank (SKILL_LORE, oObject) - 1;
    int nItemValue; // gold value of item
    string sBaseName;
    string sMaxValue = Get2DAString ("SkillVsItemCost", "DeviceCostMax", nKnowledge);
    int nMaxValue = StringToInt (sMaxValue);
    // * Handle overflow (November 2003 - BK)
    if (sMaxValue == "") nMaxValue = 0;
    object oItem = GetFirstItemInInventory (oObject);
    while (oItem != OBJECT_INVALID)
    {
        if (!GetIdentified (oItem))
        {
            // setting TRUE to get the true value of the item.
            SetIdentified (oItem, TRUE);
            nItemValue = GetGoldPieceValue (oItem);
            if(nMaxValue < nItemValue)
            {
                SetIdentified (oItem, FALSE);
                sBaseName = GetStringByStrRef (StringToInt (Get2DAString ("baseitems", "name", GetBaseItemType (oItem))));
                if (oPC != OBJECT_INVALID) SendMessages (GetName (OBJECT_SELF) + " cannot identify " + sBaseName, COLOR_RED, oPC);
            }
            else if (oPC != OBJECT_INVALID) SendMessages (GetName (OBJECT_SELF) + " has identified " + GetName (oItem), COLOR_GREEN, oPC);
        }
        oItem = GetNextItemInInventory (oObject);
    }
}

// Identifies an item based on the 2da "SkillVsItemCost
// vs OBJECT_SELF  Knowledge skill.
// Reports the findings to oPC unless oPC = OBJECT_INVALID.
int IdentifyItemVsKnowledge (object oObject, object oItem, object oPC = OBJECT_INVALID)
{
    // SkillVsItemCost 2da starts 1 at 0 ... go figure!
    int nKnowledge = GetSkillRank (SKILL_LORE, oObject) - 1;
    int nItemValue; // gold value of item
    string sBaseName;
    string sMaxValue = Get2DAString ("SkillVsItemCost", "DeviceCostMax", nKnowledge);
    int nMaxValue = StringToInt (sMaxValue);
    // * Handle overflow (November 2003 - BK)
    if (sMaxValue == "") nMaxValue = 0;
    if (!GetIdentified (oItem))
    {
        // setting TRUE to get the true value of the item.
        SetIdentified (oItem, TRUE);
        nItemValue = GetGoldPieceValue (oItem);
        if(nMaxValue <= nItemValue)
        {
            SetIdentified (oItem, FALSE);
            sBaseName = GetStringByStrRef (StringToInt (Get2DAString ("baseitems", "name", GetBaseItemType (oItem))));
            if (oPC != OBJECT_INVALID) SendMessages (GetName (OBJECT_SELF) + " cannot identify " + sBaseName, COLOR_RED, oPC);
        }
        else
        {
            if (oPC != OBJECT_INVALID) SendMessages (GetName (OBJECT_SELF) + " has identified " + GetName (oItem), COLOR_GREEN, oPC);
            return TRUE;
        }
    }
    return FALSE;
}

//  Smart Bags by Clobber adjusted for our PW by Philos.
void CheckSmartContainers(object oItem, object oPC)
{
    string sContainerTag;
    int nBaseItemType = GetBaseItemType(oItem);
    // Check to see if the item type matches any of the PC's smart containters.
    if(nBaseItemType == BASE_ITEM_GEM) sContainerTag = "0_gem_pouch";
    else if(nBaseItemType == BASE_ITEM_KEY) sContainerTag = "0_key_ring";
    else if(nBaseItemType == BASE_ITEM_POTIONS) sContainerTag = "0_potion_box";
    else if(nBaseItemType == BASE_ITEM_SPELLSCROLL) sContainerTag = "0_scroll_case";
    else if(nBaseItemType == BASE_ITEM_ARROW ||
            nBaseItemType == BASE_ITEM_BOLT ||
            nBaseItemType == BASE_ITEM_BULLET) sContainerTag = "0_quiver";
    else if(nBaseItemType == BASE_ITEM_MAGICWAND ||
            nBaseItemType == BASE_ITEM_MAGICROD) sContainerTag = "0_wand_case";
    else if(nBaseItemType == BASE_ITEM_RING ||
            nBaseItemType == BASE_ITEM_AMULET) sContainerTag = "0_jewelry_box";
    // Lets not put food in the component pouch.
    else if(nBaseItemType == BASE_ITEM_SMALL_STACKING_ITEM &&
             GetTag(oItem) != "0_rations") sContainerTag = "0_comp_pouch";
    // Quest items.
    else if(nBaseItemType == 178) sContainerTag = "0_quest_book";
    if(sContainerTag != "")
    {
        object oContainer;
        object oInventoryObject = GetFirstItemInInventory(oPC);
        while(oInventoryObject != OBJECT_INVALID)
        {
            if(GetTag(oInventoryObject) == sContainerTag)
            {
                if(GetBaseItemFitsInInventory(nBaseItemType, oInventoryObject))
                {
                    oContainer = oInventoryObject;
                    break;
                }
            }
            oInventoryObject = GetNextItemInInventory(oPC);
        }
        if(oContainer != OBJECT_INVALID)
        {
            // Hide lost and gain item message for the swap.
            NWNX_Feedback_SetFeedbackMessageHidden (NWNX_FEEDBACK_ITEM_LOST, TRUE, oPC);
            DelayCommand (0.2, NWNX_Feedback_SetFeedbackMessageHidden (NWNX_FEEDBACK_ITEM_LOST, FALSE, oPC));
            NWNX_Feedback_SetFeedbackMessageHidden (NWNX_FEEDBACK_ITEM_RECEIVED, TRUE, oPC);
            DelayCommand (0.2, NWNX_Feedback_SetFeedbackMessageHidden (NWNX_FEEDBACK_ITEM_RECEIVED, FALSE, oPC));
            // By now, we've either returned an appropriate smart bag to place the item into, or oBag will be OBJECT_INVALID.
            // If we've returned a smart bag, we now place the item into it.
            AssignCommand(oPC, ActionGiveItem(oItem, oContainer));
        }
    }
}
// Equip item script for Myrkul's necromancy set.
// Used to add bonuses to controlled undead.
// 1) Necklace of the heart adds Attack bonus +1, +2, +4, +6.
// 2) Ring of blood adds health +5, +10, +20, +40.
// 3) Robes of Bone adds AC bonus +1, +2, +4, +6.
// 4) Skull Mask adds Effects: Endure Elements(1st), Blur (2nd), Haste (3rd), Elemental shield (4th).
void MyrkulSetCheck(object oCreature, object oUndead)
{
    // Check to see what pieces are being used from the set.
    // Check for Ring of Blood.
    // Check for Necklace of the Heart.
    int nNumOfPieces;
    object oNecklace = GetItemInSlot(INVENTORY_SLOT_NECK, oCreature);
    if(GetResRef(oNecklace) == "itemset_4_1") nNumOfPieces ++;
    else oNecklace = OBJECT_INVALID;
    object oRing = GetItemInSlot(INVENTORY_SLOT_LEFTRING, oCreature);
    if(GetResRef(oRing) == "itemset_4_2") nNumOfPieces ++;
    else
    {
        // Check for Ring of Blood ring Slot 2.
        oRing = GetItemInSlot(INVENTORY_SLOT_RIGHTRING, oCreature);
        if(GetResRef(oRing) == "itemset_4_2") nNumOfPieces ++;
        else oRing = OBJECT_INVALID;
    }
    // Check for Robes of Bone.
    object oRobe = GetItemInSlot(INVENTORY_SLOT_CHEST, oCreature);
    if(GetResRef(oRobe) == "itemset_4_3") nNumOfPieces ++;
    else oRobe = OBJECT_INVALID;
    // Check for Skull Mask.
    object oMask = GetItemInSlot(INVENTORY_SLOT_HEAD, oCreature);
    if(GetResRef(oMask) == "itemset_4_4") nNumOfPieces ++;
    else oRobe = OBJECT_INVALID;
    // Now set the number and power of spell slots.
    if (nNumOfPieces > 0)
    {
        object oMaster = GetPlayerMaster(oCreature);
        if(oMaster != OBJECT_INVALID)
        {
            SendMessages("Myrkul's blood pact has empowered " + GetName(oUndead) + "!", COLOR_MAGENTA, oMaster);
        }
        int nBonus;
        effect eEffect;
        if(oNecklace != OBJECT_INVALID)
        {
            if(nNumOfPieces == 1) nBonus = 1;
            if(nNumOfPieces == 2) nBonus = 2;
            if(nNumOfPieces == 3) nBonus = 4;
            if(nNumOfPieces == 4) nBonus = 6;
            eEffect = EffectAttackIncrease(nBonus);
            eEffect = UnyieldingEffect(eEffect);
            ApplyEffectToObject(DURATION_TYPE_PERMANENT, eEffect, oUndead);
        }
        if(oRing != OBJECT_INVALID)
        {
            if(nNumOfPieces == 1) nBonus = 10;
            if(nNumOfPieces == 2) nBonus = 20;
            if(nNumOfPieces == 3) nBonus = 40;
            if(nNumOfPieces == 4) nBonus = 60;
            eEffect = EffectTemporaryHitpoints(nBonus);
            eEffect = UnyieldingEffect(eEffect);
            ApplyEffectToObject(DURATION_TYPE_PERMANENT, eEffect, oUndead);
        }
        if(oRobe != OBJECT_INVALID)
        {
            if(nNumOfPieces == 1) nBonus = 1;
            if(nNumOfPieces == 2) nBonus = 2;
            if(nNumOfPieces == 3) nBonus = 4;
            if(nNumOfPieces == 4) nBonus = 6;
            eEffect = EffectACIncrease(nBonus);
            eEffect = UnyieldingEffect(eEffect);
            ApplyEffectToObject(DURATION_TYPE_PERMANENT, eEffect, oUndead);
        }
        if(oMask != OBJECT_INVALID)
        {
            effect eCold = EffectDamageResistance(DAMAGE_TYPE_COLD, 5, 20);
            effect eFire = EffectDamageResistance(DAMAGE_TYPE_FIRE, 5, 20);
            effect eAcid = EffectDamageResistance(DAMAGE_TYPE_ACID, 5, 20);
            effect eSonic = EffectDamageResistance(DAMAGE_TYPE_SONIC, 5, 20);
            effect eElec = EffectDamageResistance(DAMAGE_TYPE_ELECTRICAL, 5, 20);
            effect eImpact = EffectVisualEffect(VFX_IMP_ELEMENTAL_PROTECTION);
            effect eDur = EffectVisualEffect(VFX_DUR_CESSATE_POSITIVE);
            eEffect = EffectLinkEffects(eCold, eFire);
            eEffect = EffectLinkEffects(eEffect, eAcid);
            eEffect = EffectLinkEffects(eEffect, eSonic);
            eEffect = EffectLinkEffects(eEffect, eElec);
            eEffect = EffectLinkEffects(eEffect, eDur);
            ApplyEffectToObject(DURATION_TYPE_PERMANENT, eEffect, oUndead);
            if(nNumOfPieces > 1)
            {
                eEffect = EffectConcealment(20);
                eEffect = UnyieldingEffect(eEffect);
                ApplyEffectToObject(DURATION_TYPE_PERMANENT, eEffect, oUndead);
            }
            if(nNumOfPieces > 2)
            {
                eEffect = EffectHaste();
                eEffect = UnyieldingEffect(eEffect);
                ApplyEffectToObject(DURATION_TYPE_PERMANENT, eEffect, oUndead);
            }
            if(nNumOfPieces == 4)
            {
                effect eVisual = EffectVisualEffect(VFX_DUR_ELEMENTAL_SHIELD);
                effect eShield = EffectDamageShield(nNumOfPieces * 3, DAMAGE_BONUS_1d6, DAMAGE_TYPE_FIRE);
                effect eDuration = EffectVisualEffect(VFX_DUR_CESSATE_POSITIVE);
                effect eCold = EffectDamageImmunityIncrease(DAMAGE_TYPE_COLD, 50);
                effect eLight = EffectVisualEffect(VFX_DUR_LIGHT_WHITE_10);
                //Link effects
                eEffect = EffectLinkEffects(eShield, eCold);
                eEffect = EffectLinkEffects(eEffect, eDuration);
                eEffect = EffectLinkEffects(eEffect, eVisual);
                eEffect = EffectLinkEffects(eEffect, eLight);
                eEffect = UnyieldingEffect(eEffect);
                ApplyEffectToObject(DURATION_TYPE_PERMANENT, eEffect, oUndead);
            }
        }
    }
}

void AdjustItemsEquipLevel(object oItem, object oCreature = OBJECT_INVALID)
{
    int nERL;
    float fRacialXP;
    if(oCreature != OBJECT_INVALID)
    {
        nERL = GetEffectiveRacialLevel(oCreature) * -1;
        if(GetIsCharacter(oCreature))
        {
            fRacialXP = GetLocalFloat(oCreature, "0_RacialXP");
            if(nERL == -1 && fRacialXP > 0.0) nERL++;
            else if(nERL == -2 && fRacialXP > 0.0)
            {
                nERL++;
                if(fRacialXP > 2000.0) nERL++;
            }
            else if(nERL == -3 && fRacialXP > 0.0)
            {
                nERL++;
                if(fRacialXP > 3000.0)
                {
                    nERL++;
                    if(fRacialXP > 5000.0) nERL++;
                }
            }
        }
    }
    int nEquipLevel = NWNX_Item_GetMinEquipLevel(oItem) - NWNX_Item_GetMinEquipLevelModifier(oItem);
    if(nEquipLevel + nERL < 1) nERL = 1 - nEquipLevel;
    //Debug("0i_items", "2359", GetName(oCreature) + " nERL: " + IntToString(nERL) +
    //      " " + GetName(oItem) + " nEquipLevel: " + IntToString(nEquipLevel) + " nEQM: " +
    //      IntToString(NWNX_Item_GetMinEquipLevelModifier(oItem)) +
    //      " fRacialXP: " + FloatToString(fRacialXP, 0, 2));
    NWNX_Item_SetMinEquipLevelModifier(oItem, nERL);
}

