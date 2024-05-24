/*////////////////////////////////////////////////////////////////////////////////////////////////////
Script Name: 0i_items
Programmer: Philos
//////////////////////////////////////////////////////////////////////////////////////////////////////
 Include scripts for use with items.
*/////////////////////////////////////////////////////////////////////////////////////////////////////
#include "0i_main"
#include "0i_messages"
// Returns TRUE if oItem is a weapon.
int ai_GetIsWeapon(object oItem);
// Returns TRUE if oItem is a melee weapon.
int ai_GetIsMeleeWeapon(object oItem);
// Returns TRUE if oItem is a slashing weapon.
int ai_GetIsSlashingWeapon(object oItem);
// Returns TRUE if oItem is a piercing weapon.
int ai_GetIsPiercingWeapon(object oItem);
// Returns TRUE if oItem is a bludgeoning weapon.
int ai_GetIsBludgeoningWeapon(object oItem);
// Returns TRUE if oItem is an ammo.
int ai_GetIsAmmo(object oItem);
// Returns TRUE if oItem is a thrown weapon.
int ai_GetIsThrownWeapon(object oItem);
// Returns TRUE if oItem is able to be used single handed by oCreature.
int ai_GetIsSingleHandedWeapon(object oItem, object oCreature);
// Returns TRUE if oItem is able to be used two handed by oCreature.
int ai_GetIsTwoHandedWeapon(object oItem, object oCreature);
// Returns TRUE if oCreature has a ranged weapon equiped and has ammo for it.
int ai_HasRangedWeaponWithAmmo(object oCreature);
// Returns TRUE if oItem is a ranged weapon.
int ai_GetIsRangeWeapon(object oItem);
// Returns TRUE if oItem is a finesse weapon.
int ai_GetIsFinesseWeapon(object oItem);
// Returns TRUE if oItem is a shield.
int ai_GetIsShield(object oItem);
// Returns the size of oItem using 1 = small to 6 = large.
int ai_GetItemSize(object oItem);
// Returns TRUE if the caller has a potion that is identified of nSpell.
int ai_CheckPotionIsIdentified(object oCreature, int nSpell);
// Returns an item from oCreature's inventory with sTag.
// bCheckEquiped will also look through the creatures equiped items.
// Returns OBJECT_INVALID if the items does not exist with sTag.
object ai_GetCreatureHasItem(object oCreature, string sTag, int bCheckEquiped = FALSE);
// Returns TRUE if oCreature can identify oItem based on the file SkillVsItemCost.2da
// Reports the findings to oPC unless oPC = OBJECT_INVALID.
int ai_IdentifyItemVsKnowledge(object oCreature, object oItem, object oPC = OBJECT_INVALID);
// Identifies all items on oObject based on the file SkillVsItemCost.2da
// Reports the findings to oPC unless oPC = OBJECT_INVALID
// bIdentifyAll ignores the chart and does what it says!
void ai_IdentifyAllVsKnowledge(object oCreature, object oPC = OBJECT_INVALID);
// Will (Un)Identify all items on oCreature.
// If bIdentify is TRUE they will all be Identified, FALSE Unidentifies them.
void ai_SetIdentifyAllItems(object oCreature, int bIdentify = TRUE);
// Returns oWeapons attack bonus from either Enhancment or Attack bonus.
int ai_GetWeaponAtkBonus(object oWeapon);
// Returns oArmors armor bonus.
int ai_GetArmorBonus(object oArmor);
// Returns the maximum gold value that an item can have to be equiped.
int ai_GetMaxItemValueThatCanBeEquiped(int nLevel);
// Returns oCreatures total attack bonus with melee weapon (Mostly).
int ai_GetCreatureAttackBonus(object oCreature);
// Returns TRUE if oCreature can use oItem based on Class, Race, and Alignment
// restrictions. Also checks UseMagicDevice of oCreature.
int ai_CheckIfCanUseItem(object oCreature, object oItem);

int ai_GetIsWeapon(object oItem)
{
   int iType = GetBaseItemType(oItem);
   switch(iType)
   {
      case BASE_ITEM_LONGSWORD: return TRUE;
      case BASE_ITEM_LONGBOW: return TRUE;
      case BASE_ITEM_RAPIER: return TRUE;
      case BASE_ITEM_DAGGER: return TRUE;
      case BASE_ITEM_GREATAXE: return TRUE;
      case BASE_ITEM_SHORTBOW: return TRUE;
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
      case BASE_ITEM_THROWINGAXE: return TRUE;
      case BASE_ITEM_DWARVENWARAXE: return TRUE;
      case BASE_ITEM_HEAVYFLAIL: return TRUE;
      case BASE_ITEM_LIGHTFLAIL: return TRUE;
      case BASE_ITEM_LIGHTHAMMER: return TRUE;
      case BASE_ITEM_LIGHTCROSSBOW: return TRUE;
      case BASE_ITEM_HEAVYCROSSBOW: return TRUE;
      case BASE_ITEM_SLING: return TRUE;
      case BASE_ITEM_KATANA: return TRUE;
      case BASE_ITEM_BOLT: return TRUE;
      case BASE_ITEM_ARROW: return TRUE;
      case BASE_ITEM_BULLET: return TRUE;
      case BASE_ITEM_CLUB: return TRUE;
      case BASE_ITEM_DART: return TRUE;
      case BASE_ITEM_DOUBLEAXE: return TRUE;
      case BASE_ITEM_TWOBLADEDSWORD: return TRUE;
      case BASE_ITEM_DIREMACE: return TRUE;
      case BASE_ITEM_KAMA: return TRUE;
      case BASE_ITEM_KUKRI: return TRUE;
      case BASE_ITEM_SCYTHE: return TRUE;
      case BASE_ITEM_SHURIKEN: return TRUE;
      case BASE_ITEM_TRIDENT: return TRUE;
      case BASE_ITEM_WHIP: return TRUE;
   }
   return FALSE;
}
int ai_GetIsMeleeWeapon(object oItem)
{
    int iType = GetBaseItemType(oItem);
    switch(iType)
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
   }
   return FALSE;
}
int ai_GetIsSingleHandedWeapon(object oItem, object oCreature)
{
  if(!ai_GetIsMeleeWeapon(oItem)) return FALSE;
  int nBaseItemType = GetBaseItemType(oItem);
  // Weapon Size in the baseitems.2da is 1 = Tiny, 2 = Small, 3 = Medium, 4 = Large.
  int nWeaponSize = StringToInt(Get2DAString("baseitems", "WeaponSize", nBaseItemType));
  // Ranged weapons have a value greater than 0 in this field. So melee weapons have 0.
  int nWeaponMelee = StringToInt(Get2DAString("baseitems", "RangedWeapon", nBaseItemType));
  // Creature size is 1 = Tiny, 2 = Small, 3 = Medium, 4 = Large.
  int nCreatureSize = GetCreatureSize(oCreature);
  return (nWeaponMelee == 0 && nWeaponSize <= nCreatureSize);
}
int ai_GetIsTwoHandedWeapon(object oItem, object oCreature)
{
  if(!ai_GetIsMeleeWeapon(oItem)) return FALSE;
  int nBaseItemType = GetBaseItemType(oItem);
  // Weapon Size in the baseitems.2da is 1 = Tiny, 2 = Small, 3 = Medium, 4 = Large.
  int nWeaponSize = StringToInt(Get2DAString("baseitems", "WeaponSize", nBaseItemType));
  // Ranged weapons have a value greater than 0 in this field. So melee weapons have 0.
  int nWeaponMelee = StringToInt(Get2DAString("baseitems", "RangedWeapon", nBaseItemType));
  // Creature size is 1 = Tiny, 2 = Small, 3 = Medium, 4 = Large.
  int nCreatureSize = GetCreatureSize(oCreature);
  if(nWeaponSize > nCreatureSize) return TRUE;
  return (nWeaponMelee == 0 && nWeaponSize > nCreatureSize);
}
int ai_GetIsSlashingWeapon(object oItem)
{
  int iBaseItemType = GetBaseItemType(oItem);
  int iWeaponType = StringToInt(Get2DAString("baseitems", "WeaponType", iBaseItemType));
  // Weapon Type in the baseitems.2da is 1 = Piercing, 2 = Bludgeoning, 3 = Slashing.
  return (iWeaponType == 3);
}
int ai_GetIsPiercingWeapon(object oItem)
{
  int iBaseItemType = GetBaseItemType(oItem);
  int iWeaponType = StringToInt(Get2DAString("baseitems", "WeaponType", iBaseItemType));
  // Weapon Type in the baseitems.2da is 1 = Piercing, 2 = Bludgeoning, 3 = Slashing.
  return (iWeaponType == 1);
}
int ai_GetIsBludgeoningWeapon(object oItem)
{
  int iBaseItemType = GetBaseItemType(oItem);
  int iWeaponType = StringToInt(Get2DAString("baseitems", "WeaponType", iBaseItemType));
  // Weapon Type in the baseitems.2da is 1 = Piercing, 2 = Bludgeoning, 3 = Slashing.
  return (iWeaponType == 2);
}
int ai_GetIsAmmo(object oItem)
{
   switch(GetBaseItemType(oItem))
   {
      case BASE_ITEM_ARROW: return TRUE;
      case BASE_ITEM_BOLT: return TRUE;
      case BASE_ITEM_BULLET: return TRUE;
   }
   return FALSE;
}
int ai_GetIsThrownWeapon(object oItem)
{
   switch(GetBaseItemType(oItem))
   {
      case BASE_ITEM_DART: return TRUE;
      case BASE_ITEM_SHURIKEN: return TRUE;
      case BASE_ITEM_THROWINGAXE: return TRUE;
   }
   return FALSE;
}
int ai_HasRangedWeaponWithAmmo(object oCreature)
{
    object oWeapon = GetItemInSlot(INVENTORY_SLOT_RIGHTHAND, oCreature);
    if(!GetWeaponRanged(oWeapon)) return FALSE;
    int nAmmoType, nWeaponType = GetBaseItemType(oWeapon);
    object oAmmo = OBJECT_INVALID;
    if(nWeaponType == BASE_ITEM_LONGBOW || nWeaponType == BASE_ITEM_SHORTBOW)
    {
        if(GetItemInSlot(INVENTORY_SLOT_ARROWS, oCreature) != OBJECT_INVALID) return TRUE;
        nAmmoType = BASE_ITEM_ARROW;
    }
    else if(nWeaponType == BASE_ITEM_LIGHTCROSSBOW || nWeaponType == BASE_ITEM_HEAVYCROSSBOW)
    {
        if(GetItemInSlot(INVENTORY_SLOT_BOLTS, oCreature) != OBJECT_INVALID) return TRUE;
        nAmmoType = BASE_ITEM_BOLT;
    }
    else if(nWeaponType == BASE_ITEM_SLING)
    {
        if(GetItemInSlot(INVENTORY_SLOT_BULLETS, oCreature) != OBJECT_INVALID) return TRUE;
        nAmmoType = BASE_ITEM_BULLET;
    }
    else if(nWeaponType == BASE_ITEM_THROWINGAXE) return TRUE;
    else if(nWeaponType == BASE_ITEM_SHURIKEN) return TRUE;
    else if(nWeaponType == BASE_ITEM_DART) return TRUE;
    // They don't have any ammo in the slot, but do they have ammo in the inventory?
    oAmmo = GetFirstItemInInventory(oCreature);
    while(oAmmo != OBJECT_INVALID)
    {
        if(GetBaseItemType(oAmmo) == nAmmoType)
        {
            if(nAmmoType == BASE_ITEM_ARROW) ActionEquipItem(oAmmo, INVENTORY_SLOT_ARROWS);
            else if(nAmmoType == BASE_ITEM_BOLT) ActionEquipItem(oAmmo, INVENTORY_SLOT_BOLTS);
            else if(nAmmoType == BASE_ITEM_BULLET) ActionEquipItem(oAmmo, INVENTORY_SLOT_BULLETS);
            return TRUE;
        }
        oAmmo = GetNextItemInInventory(oCreature);
    }
    //ai_Debug("0i_items", "254", "They are out of ammo!");
    return FALSE;
}
int ai_GetIsRangeWeapon(object oItem)
{
   switch(GetBaseItemType(oItem))
   {
      case BASE_ITEM_DART: return TRUE;
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
int ai_GetIsFinesseWeapon(object oItem)
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
   }
   return FALSE;
}
int ai_GetIsShield(object oItem)
{
   switch(GetBaseItemType(oItem))
   {
      case BASE_ITEM_SMALLSHIELD: return TRUE;
      case BASE_ITEM_LARGESHIELD: return TRUE;
      case BASE_ITEM_TOWERSHIELD: return TRUE;
   }
   return FALSE;
 }
int ai_GetItemSize(object oItem)
{
    int nBaseItemType = GetBaseItemType(oItem);
    int nWidth = StringToInt(Get2DAString("baseitems", "InvSlotWidth", nBaseItemType));
    int nHeight = StringToInt(Get2DAString("baseitems", "InvSlotHeight", nBaseItemType));
    return nWidth + nHeight - 1;
}
int ai_CheckPotionIsIdentified(object oCreature, int nSpell)
{
    int nPotionSpell;
    itemproperty ipPotion;
    object oPotion = GetFirstItemInInventory(oCreature);
    while(oPotion != OBJECT_INVALID)
    {
        if(GetIdentified(oPotion))
        {
            ipPotion = GetFirstItemProperty(oPotion);
            nPotionSpell = GetItemPropertySubType(ipPotion);
            nPotionSpell = StringToInt(Get2DAString("iprp_spells", "SpellIndex", nPotionSpell));
            //ai_Debug("0i_talents", "318", "Potion ID'ed? nSpell: " + IntToString(nSpell) + " nPotionSpell: " + IntToString(nPotionSpell));
            if(nSpell == nPotionSpell) return TRUE;
        }
        oPotion = GetNextItemInInventory(oCreature);
    }
    return FALSE;
}
object ai_GetCreatureHasItem(object oCreature, string sTag, int bCheckEquiped = FALSE)
{
    // Cycle through the creatures unequiped items.
    object oItem = GetFirstItemInInventory(oCreature);
    while(oItem != OBJECT_INVALID)
    {
        if(GetTag(oItem) == sTag) return oItem;
        oItem = GetNextItemInInventory(oCreature);
    }
    // Should we check the creatures equiped items.
    // If we have already found it then stop looking.
    int nSlot = 0;
    if(bCheckEquiped)
    {
       // Check all of the creatures slots(0 - 17).
       while(nSlot <= 17)
       {
            oItem = GetItemInSlot(nSlot, oCreature);
            if(GetTag(oItem) == sTag) return oItem;
            nSlot ++;
       }
    }
    return OBJECT_INVALID;
}
int ai_IdentifyItemVsKnowledge(object oCreature, object oItem, object oPC = OBJECT_INVALID)
{
    // SkillVsItemCost 2da starts 1 at 0 ... go figure!
    int nKnowledge = GetSkillRank(SKILL_LORE, oCreature) - 1;
    int nItemValue; // gold value of item
    string sBaseName;
    string sMaxValue = Get2DAString("SkillVsItemCost", "DeviceCostMax", nKnowledge);
    int nMaxValue = StringToInt(sMaxValue);
    // * Handle overflow(November 2003 - BK)
    if(sMaxValue == "") nMaxValue = 0;
    if(GetIdentified(oItem)) return FALSE;
    // Setting TRUE to get the true value of the item.
    SetIdentified(oItem, TRUE);
    nItemValue = GetGoldPieceValue(oItem);
    if(nMaxValue <= nItemValue)
    {
        SetIdentified(oItem, FALSE);
        sBaseName = GetStringByStrRef(StringToInt(Get2DAString("baseitems", "name", GetBaseItemType(oItem))));
        if(oPC != OBJECT_INVALID) ai_SendMessages(GetName(oCreature) + " cannot identify " + sBaseName, COLOR_RED, oPC);
    }
    else
    {
        if(oPC != OBJECT_INVALID) ai_SendMessages(GetName(oCreature) + " has identified " + GetName(oItem), COLOR_GREEN, oPC);
        return TRUE;
    }
    return FALSE;
}
void ai_IdentifyAllVsKnowledge(object oCreature, object oPC = OBJECT_INVALID)
{
    // SkillVsItemCost 2da starts 1 at 0 ... go figure!
    int nKnowledge = GetSkillRank(SKILL_LORE, oCreature) - 1;
    int nItemValue; // gold value of item
    string sBaseName;
    string sMaxValue = Get2DAString("SkillVsItemCost", "DeviceCostMax", nKnowledge);
    int nMaxValue = StringToInt(sMaxValue);
    // * Handle overflow(November 2003 - BK)
    if(sMaxValue == "") nMaxValue = 0;
    object oItem = GetFirstItemInInventory(oCreature);
    while(oItem != OBJECT_INVALID)
    {
        if(!GetIdentified(oItem))
        {
            // setting TRUE to get the true value of the item.
            SetIdentified(oItem, TRUE);
            nItemValue = GetGoldPieceValue(oItem);
            if(nMaxValue < nItemValue)
            {
                SetIdentified(oItem, FALSE);
                sBaseName = GetStringByStrRef(StringToInt(Get2DAString("baseitems", "name", GetBaseItemType(oItem))));
                if(oPC != OBJECT_INVALID) ai_SendMessages(GetName(oCreature) + " cannot identify " + sBaseName, COLOR_RED, oPC);
            }
            else if(oPC != OBJECT_INVALID) ai_SendMessages(GetName(oCreature) + " has identified " + GetName(oItem), COLOR_GREEN, oPC);
        }
        oItem = GetNextItemInInventory(oCreature);
    }
}
void ai_SetIdentifyAllItems(object oCreature, int bIdentify = TRUE)
{
    object oItem = GetFirstItemInInventory(oCreature);
    while(oItem != OBJECT_INVALID)
    {
        if(!GetIdentified(oItem)) SetIdentified(oItem, bIdentify);
        oItem = GetNextItemInInventory(oCreature);
    }
    int nSlot;
    oItem = GetItemInSlot(nSlot, oCreature);
    while(nSlot < 11)
    {
        if(!GetIdentified(oItem)) SetIdentified(oItem, bIdentify);
        oItem = GetItemInSlot(++nSlot, oCreature);
    }
}
int ai_GetWeaponAtkBonus(object oWeapon)
{
   int nCounter = 1, nPropertyType, nBonus;
    // Get first property
    itemproperty ipProperty = GetFirstItemProperty(oWeapon);
    while(GetIsItemPropertyValid(ipProperty))
    {
        // Check to see if the property type matches.
        nPropertyType = GetItemPropertyType(ipProperty);
        if(nPropertyType == 6/*ITEMPROPERTY_ENHANCEMENT*/ ||
           nPropertyType == 56/*ITEMPROPERTY_ATTACKBONUS*/)
        {
            nBonus += GetItemPropertyCostTableValue(ipProperty);
        }
        // Get the next property.
        ipProperty = GetNextItemProperty(oWeapon);
    }
    //ai_Debug("0i_items", "438", GetName(oWeapon) + " attack bonus is " + IntToString(nBonus));
    return nBonus;
}
int ai_GetArmorBonus(object oArmor)
{
    int nTorsoValue = GetItemAppearance(oArmor, ITEM_APPR_TYPE_ARMOR_MODEL, ITEM_APPR_ARMOR_MODEL_TORSO);
    //ai_Debug("0i_items", "444", "Armor Bonus: " + Get2DAString("parts_chest.2da", "ACBONUS", nTorsoValue));
    return StringToInt(Get2DAString("parts_chest.2da", "ACBONUS", nTorsoValue));
}
int ai_GetMaxItemValueThatCanBeEquiped(int nLevel)
{
    return StringToInt(Get2DAString("itemvalue", "MAXSINGLEITEMVALUE", nLevel - 1));
}
int ai_GetCreatureAttackBonus(object oCreature)
{
    object oWeapon = GetItemInSlot(INVENTORY_SLOT_RIGHTHAND, oCreature);
    int nAtkBonus = GetBaseAttackBonus(oCreature);
    if((GetHasFeat(FEAT_WEAPON_FINESSE, oCreature) && ai_GetIsFinesseWeapon(oWeapon)) ||
       ai_GetIsRangeWeapon(oWeapon))
    {
        nAtkBonus += GetAbilityModifier(ABILITY_DEXTERITY, oCreature);
    }
    else nAtkBonus += GetAbilityModifier(ABILITY_STRENGTH, oCreature);
    if(ai_GetIsMeleeWeapon(oWeapon)) nAtkBonus += ai_GetWeaponAtkBonus(oWeapon);
    return nAtkBonus;
 }
int ai_CheckUseMagicDevice(object oCreature, string sColumn, object oItem)
{
    if(!AI_ALLOW_USE_MAGIC_DEVICE) return FALSE;
    int nUMD = GetSkillRank(SKILL_USE_MAGIC_DEVICE, oCreature);
    //ai_Debug("0i_talents", "1600", GetName(oCreature) + " is check UMD: " + IntToString(nUMD));
    if(nUMD < 1) return FALSE;
    int nDC, nIndex, nItemValue = GetGoldPieceValue(oItem);
    while(nIndex < 55)
    {
        //ai_Debug("0i_talents", "1605", GetName(oItem) + " has a value of " +
        //         Get2DAString("skillvsitemcost", "DeviceCostMax", nIndex) +
        //         " nIndex: " + IntToString(nIndex));
        if(nItemValue < StringToInt(Get2DAString("skillvsitemcost", "DeviceCostMax", nIndex)))
        {
            //ai_Debug("0i_talents", "1610", "nUMD >= " + Get2DAString("skillvsitemcost", sColumn, nIndex));
            if(nUMD >= StringToInt(Get2DAString("skillvsitemcost", sColumn, nIndex))) return TRUE;
            return FALSE;
        }
        nIndex++;
    }
    return FALSE;
}
int ai_CheckIfCanUseItem(object oCreature, object oItem)
{
    int bAlign, bClass, bRace, bAlignLimit, bClassLimit, bRaceLimit;
    int nIprpSubType, nItemPropertyType;
    // Check to see if this item is limited to a specific alignment, class, or race.
    int nAlign1 = GetAlignmentLawChaos(oCreature);
    int nAlign2 = GetAlignmentGoodEvil(oCreature);
    int nRace = GetRacialType(oCreature);
    itemproperty ipProp;
    ai_Debug("0i_actions", "615", "nAlign1: " + IntToString(nAlign1) +
             " nAlign2: " + IntToString(nAlign2) + " nRace: " + IntToString(nRace));
    while(GetIsItemPropertyValid(ipProp))
    {
        nItemPropertyType = GetItemPropertyType(ipProp);
        ai_Debug("0i_actions", "620", "ItempropertyType(62/63/64/65): " + IntToString(nItemPropertyType));
        if(nItemPropertyType == ITEM_PROPERTY_USE_LIMITATION_ALIGNMENT_GROUP)
        {
            bAlignLimit = TRUE;
            // SubType is the group index for iprp_aligngrp.2da
            nIprpSubType = GetItemPropertySubType(ipProp);
            ai_Debug("0i_actions", "626", "nIprpSubType: " + IntToString(nIprpSubType));
            if(nIprpSubType == nAlign1 || nIprpSubType == nAlign2) bAlign = TRUE;
        }
        else if(nItemPropertyType == ITEM_PROPERTY_USE_LIMITATION_SPECIFIC_ALIGNMENT)
        {
            bAlignLimit = TRUE;
            // SubType is the alignment index for iprp_alignment.2da
            nIprpSubType = GetItemPropertySubType(ipProp);
            ai_Debug("0i_actions", "634", "nIprpSubType: " + IntToString(nIprpSubType));
            if(nIprpSubType == 0 && nAlign1 == 2 && nAlign2 == 4) bAlign = TRUE;
            else if(nIprpSubType == 1 && nAlign1 == 2 && nAlign2 == 1) bAlign = TRUE;
            else if(nIprpSubType == 2 && nAlign1 == 2 && nAlign2 == 5) bAlign = TRUE;
            else if(nIprpSubType == 3 && nAlign1 == 1 && nAlign2 == 4) bAlign = TRUE;
            else if(nIprpSubType == 4 && nAlign1 == 1 && nAlign2 == 1) bAlign = TRUE;
            else if(nIprpSubType == 5 && nAlign1 == 1 && nAlign2 == 5) bAlign = TRUE;
            else if(nIprpSubType == 6 && nAlign1 == 3 && nAlign2 == 4) bAlign = TRUE;
            else if(nIprpSubType == 7 && nAlign1 == 3 && nAlign2 == 1) bAlign = TRUE;
            else if(nIprpSubType == 8 && nAlign1 == 3 && nAlign2 == 5) bAlign = TRUE;
        }
        else if(nItemPropertyType == ITEM_PROPERTY_USE_LIMITATION_CLASS)
        {
            bClassLimit = TRUE;
            // SubType is the class index for classes.2da
            nIprpSubType = GetItemPropertySubType(ipProp);
            ai_Debug("0i_actions", "650", "nIprpSubType: " + IntToString(nIprpSubType));
            int nClassPosition = 1;
            int nClass = GetClassByPosition(nClassPosition, oCreature);
            while(nClassPosition <= AI_MAX_CLASSES_PER_CHARACTER)
            {
                if(nIprpSubType == nClass) bClass = TRUE;
                nClass = GetClassByPosition(++nClassPosition, oCreature);
            }
        }
        else if(nItemPropertyType == ITEM_PROPERTY_USE_LIMITATION_RACIAL_TYPE)
        {
            bRaceLimit = TRUE;
            // SubType is the race index for racialtypes.2da
            nIprpSubType = GetItemPropertySubType(ipProp);
            ai_Debug("0i_actions", "664", "nIprpSubType: " + IntToString(nIprpSubType));
            if(nIprpSubType == nRace) bRace = TRUE;
        }
        ipProp = GetNextItemProperty(oItem);
    }
    ai_Debug("0i_actions", "669", "bAlignLimit: " + IntToString(bAlignLimit) + " bAlign: " + IntToString(bAlign) +
             " bClassLimit: " + IntToString(bClassLimit) + " bClass: " + IntToString(bClass) +
             " bRaceLimit: " + IntToString(bRaceLimit) + " bRace: " + IntToString(bRace));
    if(bClassLimit && !bClass && !ai_CheckUseMagicDevice(oCreature, "SkillReq_Class", oItem)) return FALSE;
    if(bRaceLimit && !bRace && !ai_CheckUseMagicDevice(oCreature, "SkillReq_Race", oItem)) return FALSE;
    if(bAlignLimit && !bAlign && !ai_CheckUseMagicDevice(oCreature, "SkillReq_Align", oItem)) return FALSE;
    return TRUE;
}

