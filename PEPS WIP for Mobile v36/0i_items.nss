/*////////////////////////////////////////////////////////////////////////////////////////////////////
Script Name: 0i_items
Programmer: Philos
//////////////////////////////////////////////////////////////////////////////////////////////////////
 Include scripts for use with items.
*/////////////////////////////////////////////////////////////////////////////////////////////////////
//#include "0i_main"
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
// Returns TRUE if oItem is a light weapon for oCreature.
int ai_GetIsLightWeapon(object oItem, object oCreature);
// Returns TRUE if oItem is able to be used two handed by oCreature.
int ai_GetIsTwoHandedWeapon(object oItem, object oCreature);
// Returns TRUE if oItem is a double weapon.
int ai_GetIsDoubleWeapon(object oItem);
// Returns TRUE if oCreature has a ranged weapon equiped and has ammo for it.
int ai_HasRangedWeaponWithAmmo(object oCreature);
// Returns TRUE if oItem is a ranged weapon.
int ai_GetIsRangeWeapon(object oItem);
// Returns the amount of damage the weapon oCreature is holding.
// nDamageAmount tells the function the amount of damage to return;
//      1 - Minimum, 2- Average, 3 Maximum.
// bMelee If it is not a melee weapon then return 0;
int ai_GetWeaponDamage(object oCreature, int nDamageAmount = 3, int bMelee = FALSE);
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
// If the item can be identified by oCreature then it will be identified.
int ai_IdentifyItemVsKnowledge(object oCreature, object oItem, object oPC = OBJECT_INVALID);
// Identifies all items on oObject based on the file SkillVsItemCost.2da
// Reports the findings to oPC unless oPC = OBJECT_INVALID
// bIdentifyAll ignores the chart and does what it says!
void ai_IdentifyAllVsKnowledge(object oCreature, object oContainer, object oPC = OBJECT_INVALID);
// Will (Un)Identify all items on oCreature.
// If bIdentify is TRUE they will all be Identified, FALSE Unidentifies them.
void ai_SetIdentifyAllItems(object oCreature, int bIdentify = TRUE);
// Returns oWeapons attack bonus from either Enhancment or Attack bonus.
int ai_GetWeaponAtkBonus(object oWeapon);
// Returns oArmors armor bonus.
int ai_GetArmorBonus(object oArmor);
// Returns the maximum gold value that an item can have to be equiped.
int ai_GetMaxItemValueThatCanBeEquiped(int nLevel);
// Returns the minimum level that is required to equip this item.
int ai_GetMinimumEquipLevel(object oItem);
// Returns oCreatures total attack bonus with melee weapon (Mostly).
int ai_GetCreatureAttackBonus(object oCreature);
// Returns TRUE if oCreature can use oItem based on Class, Race, and Alignment
// restrictions. Also checks UseMagicDevice of oCreature.
int ai_CheckIfCanUseItem(object oCreature, object oItem);
// Returns TRUE if oCreature can use oItem due to feats.
int ai_GetIsProficientWith(object oCreature, object oItem);
// Gets the Average Damage on the weapon for Main and Off Hand to allow
// us to check which weapon is better for oCreature to equip.
// b2Handed set to TRUE returns only checks main avg damage.
// bOffHand set to TRUE returns the OffHand avg damage.
// if b2Handed & bOffHand are set to TRUE it returns main & offhand added together.
// if oOffWeapon is Set then it will return the Avg Damage assuming oItem is
// the Main weapon and oOffWeapon is in the Offhand.
float ai_GetMeleeWeaponAvgDmg(object oCreature, object oItem, int b2Handed = FALSE, int bOffHand = FALSE, object oOffWeapon = OBJECT_INVALID);
// Sets shield AC on the shield to allow us to check which shield is better
// for oCreature to equip.
int ai_SetShieldAC(object oCreature, object oItem);
// Returns TRUE if oItem has nItemPropertyType.
// nItemPropertySubType will not be used if its below 0.
int ai_GetHasItemProperty(object oItem, int nItemPropertyType, int nItemPropertySubType = -1);
// Returns the highest bonus Lock Picks needed to unlock nLockDC in oCreatures inventory.
object ai_GetBestPicks(object oCreature, int nLockDC);
// Removes all items from oCreature.
void ai_RemoveInventory(object oCreature);
// Copies all equiped and inventory items from oOldHenchman to oNewHenchman.
void ai_MoveInventory(object oOldHenchman, object oNewHenchman);
// Returns if oCreature is proficient with nBaseItem.
// PRC lets the creature use any weapon, but gives -4 penalty if not proficient.
int prc_IsProficient(object oCreature, int nBaseItem);

int ai_GetIsWeapon(object oItem)
{
    int nType = GetBaseItemType(oItem);
    int nWeaponType = StringToInt(Get2DAString("baseitems", "WeaponType", nType));
    if(nWeaponType) return TRUE;
    return FALSE;
}
int ai_GetIsMeleeWeapon(object oItem)
{
    int nType = GetBaseItemType(oItem);
    if(StringToInt(Get2DAString("baseitems", "WeaponType", nType)) > 0)
    {
        if(StringToInt(Get2DAString("baseitems", "RangedWeapon", nType)) == 0) return TRUE;
    }
    return FALSE;
}
int ai_GetIsSingleHandedWeapon(object oItem, object oCreature)
{
  if(!ai_GetIsMeleeWeapon(oItem)) return FALSE;
  int nBaseItemType = GetBaseItemType(oItem);
  // Weapon Size in the baseitems.2da is 1 = Tiny, 2 = Small, 3 = Medium, 4 = Large.
  int nWeaponSize = StringToInt(Get2DAString("baseitems", "WeaponSize", nBaseItemType));
  // Creature size is 1 = Tiny, 2 = Small, 3 = Medium, 4 = Large.
  int nCreatureSize = GetCreatureSize(oCreature);
  return nWeaponSize <= nCreatureSize;
}
int ai_GetIsLightWeapon(object oItem, object oCreature)
{
  if(!ai_GetIsMeleeWeapon(oItem)) return FALSE;
  int nBaseItemType = GetBaseItemType(oItem);
  // Weapon Size in the baseitems.2da is 1 = Tiny, 2 = Small, 3 = Medium, 4 = Large.
  int nWeaponSize = StringToInt(Get2DAString("baseitems", "WeaponSize", nBaseItemType));
  // Creature size is 1 = Tiny, 2 = Small, 3 = Medium, 4 = Large.
  int nCreatureSize = GetCreatureSize(oCreature);
  return nWeaponSize < nCreatureSize;
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
  return (nWeaponMelee == 0 && nWeaponSize > nCreatureSize);
}
int ai_GetIsDoubleWeapon(object oItem)
{
    int iType = GetBaseItemType(oItem);
    switch(iType)
    {
        case BASE_ITEM_DIREMACE:
        case BASE_ITEM_DOUBLEAXE:
        case BASE_ITEM_TWOBLADEDSWORD: return TRUE;
    }
    return FALSE;
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
        if(ai_GetHasItemProperty(oWeapon, ITEM_PROPERTY_UNLIMITED_AMMUNITION)) return TRUE;
        if(GetItemInSlot(INVENTORY_SLOT_ARROWS, oCreature) != OBJECT_INVALID) return TRUE;
        nAmmoType = BASE_ITEM_ARROW;
    }
    else if(nWeaponType == BASE_ITEM_LIGHTCROSSBOW || nWeaponType == BASE_ITEM_HEAVYCROSSBOW)
    {
        if(ai_GetHasItemProperty(oWeapon, ITEM_PROPERTY_UNLIMITED_AMMUNITION)) return TRUE;
        if(GetItemInSlot(INVENTORY_SLOT_BOLTS, oCreature) != OBJECT_INVALID) return TRUE;
        nAmmoType = BASE_ITEM_BOLT;
    }
    else if(nWeaponType == BASE_ITEM_SLING)
    {
        if(ai_GetHasItemProperty(oWeapon, ITEM_PROPERTY_UNLIMITED_AMMUNITION)) return TRUE;
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
int ai_GetIsFinesseWeapon(object oCreature, object oItem)
{
   switch(GetBaseItemType(oItem))
   {
       case BASE_ITEM_DAGGER: return TRUE;
       case BASE_ITEM_HANDAXE: return TRUE;
       case BASE_ITEM_KAMA: return TRUE;
       case BASE_ITEM_KUKRI: return TRUE;
       case BASE_ITEM_LIGHTHAMMER: return TRUE;
       case BASE_ITEM_LIGHTMACE: return TRUE;
       case BASE_ITEM_RAPIER:
       {
           if(GetCreatureSize(oCreature) > CREATURE_SIZE_SMALL) return TRUE;
           return FALSE;
       }
       case BASE_ITEM_SHORTSWORD: return TRUE;
       case BASE_ITEM_SICKLE: return TRUE;
       case BASE_ITEM_WHIP: return TRUE;
   }
   return FALSE;
}
int ai_GetWeaponDamage(object oCreature, int nDamageAmount = 3, int bMelee = FALSE)
{
    object oItem = GetItemInSlot(INVENTORY_SLOT_RIGHTHAND, oCreature);
    if(bMelee && ai_GetIsRangeWeapon(oItem)) return 0;
    int nWeaponDamage = GetLocalInt(oItem, "AI_WEAPON_DAMAGE");
    if(!nWeaponDamage)
    {
        if(ai_GetIsMeleeWeapon(oItem))
        {
            nWeaponDamage = GetAbilityModifier(ABILITY_STRENGTH, oCreature);
            if(ai_GetIsTwoHandedWeapon(oItem, oCreature)) nWeaponDamage += nWeaponDamage / 2;
        }
        int nWeaponDice = StringToInt(Get2DAString("baseitems", "NumDice", GetBaseItemType(oItem)));
        int nWeaponDie = StringToInt(Get2DAString("baseitems", "DieToRoll", GetBaseItemType(oItem)));
        if(nDamageAmount == 1)
        {
            nWeaponDamage += nWeaponDice;
        }
        else if(nDamageAmount == 2)
        {
            nWeaponDamage += nWeaponDice * nWeaponDie / 2;
        }
        else
        {
            nWeaponDamage += nWeaponDice * nWeaponDie;
        }
        SetLocalInt(oItem, "AI_WEAPON_DAMAGE", nWeaponDamage);
    }
    return nWeaponDamage;
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
    if(GetIdentified(oItem)) return FALSE;
    int nKnowledge = GetSkillRank(SKILL_LORE, oCreature);
    int nItemValue; // gold value of item
    string sBaseName;
    string sMaxValue = Get2DAString("SkillVsItemCost", "DeviceCostMax", nKnowledge);
    int nMaxValue = StringToInt(sMaxValue);
    // * Handle overflow(November 2003 - BK)
    if(sMaxValue == "") nMaxValue = 0;
    // Setting TRUE to get the true value of the item.
    SetIdentified(oItem, TRUE);
    nItemValue = GetGoldPieceValue(oItem);
    if(nMaxValue <= nItemValue)
    {
        SetIdentified(oItem, FALSE);
        if(oPC != OBJECT_INVALID)
        {
            sBaseName = GetStringByStrRef(StringToInt(Get2DAString("baseitems", "name", GetBaseItemType(oItem))));
            ai_SendMessages(GetName(oCreature) + " cannot identify " + sBaseName, AI_COLOR_RED, oPC);
        }
    }
    else
    {
        if(oPC != OBJECT_INVALID) ai_SendMessages(GetName(oCreature) + " has identified " + GetName(oItem), AI_COLOR_GREEN, oPC);
        return TRUE;
    }
    return FALSE;
}
void ai_IdentifyAllVsKnowledge(object oCreature, object oContainer, object oPC = OBJECT_INVALID)
{
    // SkillVsItemCost 2da starts 1 at 0 ... go figure!
    int nKnowledge = GetSkillRank(SKILL_LORE, oCreature) - 1;
    int nItemValue; // gold value of item
    string sBaseName;
    string sMaxValue = Get2DAString("SkillVsItemCost", "DeviceCostMax", nKnowledge);
    int nMaxValue = StringToInt(sMaxValue);
    // * Handle overflow(November 2003 - BK)
    if(sMaxValue == "") nMaxValue = 0;
    object oItem = GetFirstItemInInventory(oContainer);
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
                if(oPC != OBJECT_INVALID) ai_SendMessages(GetName(oCreature) + " cannot identify " + sBaseName, AI_COLOR_RED, oPC);
            }
            else if(oPC != OBJECT_INVALID) ai_SendMessages(GetName(oCreature) + " has identified " + GetName(oItem), AI_COLOR_GREEN, oPC);
        }
        oItem = GetNextItemInInventory(oContainer);
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
    return StringToInt(Get2DAString("parts_chest", "ACBONUS", nTorsoValue));
}
int ai_GetMaxItemValueThatCanBeEquiped(int nLevel)
{
    return StringToInt(Get2DAString("itemvalue", "MAXSINGLEITEMVALUE", nLevel - 1));
}
int ai_GetMinimumEquipLevel(object oItem)
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
int ai_GetCreatureAttackBonus(object oCreature)
{
    object oWeapon = GetItemInSlot(INVENTORY_SLOT_RIGHTHAND, oCreature);
    int nAtkBonus = GetBaseAttackBonus(oCreature);
    if((GetHasFeat(FEAT_WEAPON_FINESSE, oCreature) && ai_GetIsFinesseWeapon(oCreature, oWeapon)) ||
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
    if(!GetLocalInt(GetModule(), AI_RULE_ALLOW_UMD)) return FALSE;
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
    //ai_Debug("0i_items", "615", "nAlign1: " + IntToString(nAlign1) +
    //         " nAlign2: " + IntToString(nAlign2) + " nRace: " + IntToString(nRace));
    itemproperty ipProp = GetFirstItemProperty(oItem);
    while(GetIsItemPropertyValid(ipProp))
    {
        nItemPropertyType = GetItemPropertyType(ipProp);
        //ai_Debug("0i_items", "620", "ItempropertyType(62/63/64/65): " + IntToString(nItemPropertyType));
        if(nItemPropertyType == ITEM_PROPERTY_USE_LIMITATION_ALIGNMENT_GROUP)
        {
            bAlignLimit = TRUE;
            // SubType is the group index for iprp_aligngrp.2da
            nIprpSubType = GetItemPropertySubType(ipProp);
            //ai_Debug("0i_items", "626", "nIprpSubType: " + IntToString(nIprpSubType));
            if(nIprpSubType == nAlign1 || nIprpSubType == nAlign2) bAlign = TRUE;
        }
        else if(nItemPropertyType == ITEM_PROPERTY_USE_LIMITATION_SPECIFIC_ALIGNMENT)
        {
            bAlignLimit = TRUE;
            // SubType is the alignment index for iprp_alignment.2da
            nIprpSubType = GetItemPropertySubType(ipProp);
            //ai_Debug("0i_items", "634", "nIprpSubType: " + IntToString(nIprpSubType));
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
            //ai_Debug("0i_items", "650", "nIprpSubType: " + IntToString(nIprpSubType));
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
            //ai_Debug("0i_items", "664", "nIprpSubType: " + IntToString(nIprpSubType));
            if(nIprpSubType == nRace) bRace = TRUE;
        }
        ipProp = GetNextItemProperty(oItem);
    }
    //ai_Debug("0i_items", "669", "bAlignLimit: " + IntToString(bAlignLimit) + " bAlign: " + IntToString(bAlign) +
    //         " bClassLimit: " + IntToString(bClassLimit) + " bClass: " + IntToString(bClass) +
    //         " bRaceLimit: " + IntToString(bRaceLimit) + " bRace: " + IntToString(bRace));
    if(bClassLimit && !bClass && !ai_CheckUseMagicDevice(oCreature, "SkillReq_Class", oItem)) return FALSE;
    if(bRaceLimit && !bRace && !ai_CheckUseMagicDevice(oCreature, "SkillReq_Race", oItem)) return FALSE;
    if(bAlignLimit && !bAlign && !ai_CheckUseMagicDevice(oCreature, "SkillReq_Align", oItem)) return FALSE;
    return TRUE;
}
int ai_GetIsProficientWith(object oCreature, object oItem)
{
    int nWeaponType = GetBaseItemType(oItem);
    // In the PRC you can equip any weapon.
    if(GetLocalInt(GetModule(), AI_USING_PRC)) return TRUE;
    int nFeat = StringToInt(Get2DAString("baseitems", "ReqFeat0", nWeaponType));
    // If it is 0 then it doesn't require a feat or we are at the end of the
    // feat requirements.
    if(nFeat == 0) return TRUE;
    if(GetHasFeat(nFeat, oCreature)) return TRUE;
    nFeat = StringToInt(Get2DAString("baseitems", "ReqFeat1", nWeaponType));
    if(nFeat == 0) return FALSE;
    if(GetHasFeat(nFeat, oCreature)) return TRUE;
    nFeat = StringToInt(Get2DAString("baseitems", "ReqFeat2", nWeaponType));
    if(nFeat == 0) return FALSE;
    if(GetHasFeat(nFeat, oCreature)) return TRUE;
    nFeat = StringToInt(Get2DAString("baseitems", "ReqFeat3", nWeaponType));
    if(nFeat == 0) return FALSE;
    if(GetHasFeat(nFeat, oCreature)) return TRUE;
    nFeat = StringToInt(Get2DAString("baseitems", "ReqFeat4", nWeaponType));
    if(nFeat == 0) return FALSE;
    if(GetHasFeat(nFeat, oCreature)) return TRUE;
    return FALSE;
}
float ai_GetMeleeWeaponAvgDmg(object oCreature, object oItem, int b2Handed = FALSE, int bOffHand = FALSE, object oOffWeapon = OBJECT_INVALID)
{
    // Has this weapon already been calculated for this creature?
    if(oCreature == GetLocalObject(oItem, "AI_CREATURE_POSSESSION"))
    {
        // Return the Main weapons Avg Damage while using a weapon in the off hand.
        if(oOffWeapon != OBJECT_INVALID)
        {
            // We recalculate all OffWeapon avg damage unless its a double weapon.
            if(oOffWeapon == oItem)
            {
                float fMain2WDmg = GetLocalFloat(oItem, "AI_MAIN_2W_HAND_AVG_DMG");
                // If they passed that this is a 2handed weapon then return the total
                // Avg Dmg for oItem. Used for double weapons.
                if(b2Handed)
                {
                    fMain2WDmg += ai_GetMeleeWeaponAvgDmg(oCreature, oItem, FALSE, TRUE);
                }
                if(AI_DEBUG) ai_Debug("0i_items", "611", GetName(oItem) + " avg dmg with Offhand weapon (" + GetName(oOffWeapon) + ") " + FloatToString(fMain2WDmg, 0, 2));
                return fMain2WDmg;
            }
        }
        // Return the avg dmg for oItem assuming it is in the OffHand.
        else if(bOffHand)
        {
            float fOffHandDmg = GetLocalFloat(oItem, "AI_OFFHAND_AVG_DMG");
            if(AI_DEBUG) ai_Debug("0i_items", "618", GetName(oItem) + " fOffHandAvgDmg: " + FloatToString(fOffHandDmg, 0, 2));
            return fOffHandDmg;
        }
        // If we get here then Return the avg dmg for oItem assuming its in the main hand.
        else
        {
            float fMainDmg = GetLocalFloat(oItem, "AI_AVG_DMG");
            if(AI_DEBUG)ai_Debug("0i_items", "623", GetName(oItem) + " fMainDmg: " + FloatToString(fMainDmg, 0, 2));
            return fMainDmg;
        }
    }
    // Set the creature to this item that we are calculationg the avg damages for.
    SetLocalObject(oItem, "AI_CREATURE_POSSESSION", oCreature);
    int nItemType = GetBaseItemType(oItem);
    // Figure average damage for one attack, or two with two weapons.
    // We are keeping it simple to reduce time and checks.
    // Get the weapons base stats.
    int nMinDmg = StringToInt(Get2DAString("baseitems", "NumDice", nItemType));
    int nMaxDmg = nMinDmg * StringToInt(Get2DAString("baseitems", "DieToRoll", nItemType));
    int nThreat = StringToInt(Get2DAString("baseitems", "CritThreat", nItemType));
    int nMultiplier = StringToInt(Get2DAString("baseitems", "CritHitMult", nItemType));
    int nIndex, nBonusMinDmg, nBonusMaxDmg, nItemPropertyType, nNumDice;
    // We set ToHit to 10 for a 50% chance to hit without modifiers.
    float fCritBonusDmg, fToHit = 10.0;
    if(GetLocalInt(GetModule(), AI_USING_PRC))
    {
        if(!prc_IsProficient(oCreature, nItemType)) fToHit -= 4.0;
    }
    // Check oCreature's feats.
    if(GetHasFeat(FEAT_WEAPON_FINESSE, oCreature) &&
       ai_GetIsLightWeapon(oItem, oCreature))
    {
        // Add Dexterity modifier to the Attack bonus.
        nIndex = GetAbilityModifier(ABILITY_DEXTERITY, oCreature);
    }
    else
    {
        // Add Strength modifier to the attack bonus.
        nIndex = GetAbilityModifier(ABILITY_STRENGTH, oCreature);
        // Add 1/2 strength modifier to damage for 2handed weapons, but not Double weapons.
        if(b2Handed && !bOffHand)
        {
            nMinDmg += nIndex / 2;
            nMaxDmg += nIndex / 2;
        }
    }
    fToHit += nIndex;
    if(GetHasFeat(StringToInt(Get2DAString("baseitems", "WeaponFocusFeat", nItemType)), oCreature, TRUE))
    {
        fToHit += 1.0;
        if(GetHasFeat(StringToInt(Get2DAString("baseitems", "WeaponSpecializationFeat", nItemType)), oCreature, TRUE))
        {
            nMinDmg += 2;
            nMaxDmg += 2;
        }
        if(GetHasFeat(StringToInt(Get2DAString("baseitems", "EpicWeaponFocusFeat", nItemType)), oCreature, TRUE))
        {
            fToHit += 2.0;
            if(GetHasFeat(StringToInt(Get2DAString("baseitems", "EpicWeaponSpecializationFeat", nItemType)), oCreature, TRUE))
            {
                nMinDmg += 4;
                nMaxDmg += 4;
            }
        }
    }
    if(GetHasFeat(StringToInt(Get2DAString("baseitems", "WeaponImprovedCriticalFeat", nItemType)), oCreature, TRUE))
    {
        nMultiplier += nMultiplier;
        if(GetHasFeat(StringToInt(Get2DAString("baseitems", "EpicWeaponOverwhelmingCriticalFeat", nItemType)), oCreature, TRUE))
        {
            if(nMultiplier > 3) fCritBonusDmg = 10.5;
            else if(nMultiplier == 3) fCritBonusDmg = 7.0;
            else fCritBonusDmg = 3.5;
        }
    }
    // Check oItem's properties.
    itemproperty ipProperty = GetFirstItemProperty(oItem);
    while(GetIsItemPropertyValid(ipProperty))
    {
        nItemPropertyType = GetItemPropertyType(ipProperty);
        if(nItemPropertyType == ITEM_PROPERTY_ENHANCEMENT_BONUS)
        {
            nIndex = GetItemPropertyCostTableValue(ipProperty);
            nBonusMinDmg += nIndex;
            nBonusMaxDmg += nIndex;
            fToHit += IntToFloat(nIndex);
        }
        else if(nItemPropertyType == ITEM_PROPERTY_DAMAGE_BONUS)
        {
            nIndex = GetItemPropertyCostTableValue(ipProperty);
            nNumDice = StringToInt(Get2DAString("iprp_damagecost", "NumDice", nIndex));
            nBonusMinDmg += nNumDice;
            nBonusMaxDmg += nNumDice * StringToInt(Get2DAString("iprp_damagecost", "Die", nIndex));
        }
        else if(nItemPropertyType == ITEM_PROPERTY_ATTACK_BONUS)
        {
            nIndex = GetItemPropertyCostTableValue(ipProperty);
            fToHit += IntToFloat(nIndex);
        }
        else if(nItemPropertyType == ITEM_PROPERTY_KEEN)
        {
            nIndex = GetItemPropertyCostTableValue(ipProperty);
            nMultiplier += nMultiplier;
        }
        else if(nItemPropertyType == ITEM_PROPERTY_HASTE)
        {
            nIndex = GetItemPropertyCostTableValue(ipProperty);
            nMinDmg += nMinDmg;
            nMaxDmg += nMaxDmg;
            nBonusMinDmg += nBonusMinDmg;
            nBonusMaxDmg += nBonusMaxDmg;
            nMultiplier += nMultiplier;
        }
        else if(nItemPropertyType == ITEM_PROPERTY_MASSIVE_CRITICALS)
        {
            nIndex = GetItemPropertyCostTableValue(ipProperty);
            nNumDice = StringToInt(Get2DAString("iprp_damagecost", "NumDice", nIndex));
            fCritBonusDmg += IntToFloat(nNumDice) + IntToFloat(nNumDice * StringToInt(Get2DAString("iprp_damagecost", "Die", nIndex))) / 2.0;
        }
        else if(nItemPropertyType == ITEM_PROPERTY_DECREASED_ENHANCEMENT_MODIFIER)
        {
            nIndex = GetItemPropertyCostTableValue(ipProperty);
            nBonusMinDmg -= nIndex;
            nBonusMaxDmg -= nIndex;
            fToHit -= IntToFloat(nIndex);
        }
        else if(nItemPropertyType == ITEM_PROPERTY_DECREASED_ATTACK_MODIFIER)
        {
            nIndex = GetItemPropertyCostTableValue(ipProperty);
            fToHit -= IntToFloat(nIndex);
        }
        else if(nItemPropertyType == ITEM_PROPERTY_DECREASED_DAMAGE)
        {
            nIndex = GetItemPropertyCostTableValue(ipProperty);
            nBonusMinDmg -= nIndex;
            nBonusMaxDmg -= nIndex;
        }
        else if(nItemPropertyType == ITEM_PROPERTY_NO_DAMAGE)
        {
            // A weapon always does a minimum of 1 pnt of damage.
            nMinDmg = 1;
            nMaxDmg = 1;
        }
        ipProperty = GetNextItemProperty(oItem);
    }
    float fAvgDmg = IntToFloat(nMinDmg + nMaxDmg + nBonusMinDmg + nBonusMaxDmg) / 2;
    // Set value for Offhand chance to hit.
    float fOffHandToHit = fToHit - 10.0;
    float fOffHandAvgDmg = fAvgDmg;
    // Set value for Main hand chance to hit with a weapon in Off hand.
    float fMain2HandToHit = fToHit - 6.0;
    float fMain2HandAvgDmg = fAvgDmg;
    // Calculate the avg dmg for oItem used in the main hand with no Off hand weapon.
    fToHit = fToHit / 20.0;
    float fThreatChance = (IntToFloat(nThreat) / 20.0) * fToHit;
    fAvgDmg = (fAvgDmg * fToHit) + ((fAvgDmg * IntToFloat(nMultiplier) + fCritBonusDmg) * fThreatChance);
    SetLocalFloat(oItem, "AI_AVG_DMG", fAvgDmg);
    if(AI_DEBUG) ai_Debug("0i_items", "768", GetName(oItem) + " fSingleAvgDmg: " + FloatToString(fAvgDmg, 0, 2));
    if(!b2Handed || (b2Handed && oOffWeapon != OBJECT_INVALID))
    {
        // Calculate chance to hit based on two weapon feats and main hand vs off hand.
        if(GetHasFeat(374/*Dual_Wield*/, oCreature))
        {
            if(ai_GetArmorBonus(GetItemInSlot(INVENTORY_SLOT_CHEST, oCreature)) < 4)
            {
                fMain2HandToHit += 2.0;
                fOffHandToHit += 6.0;
            }
        }
        else
        {
            if(GetHasFeat(FEAT_AMBIDEXTERITY, oCreature)) fOffHandToHit += 4.0;
            if(GetHasFeat(FEAT_TWO_WEAPON_FIGHTING, oCreature))
            {
                fMain2HandToHit += 2.0;
                fOffHandToHit += 2.0;
            }
        }
        if(ai_GetIsLightWeapon(oItem, oCreature)) fOffHandToHit += 2.0;
        if(oOffWeapon != OBJECT_INVALID &&
          (ai_GetIsLightWeapon(oOffWeapon, oCreature) || ai_GetIsDoubleWeapon(oItem)))
        {
            fMain2HandToHit += 2.0;
        }
        // Calculate the avg dmg for oItem used in the main hand with an off hand weapon.
        fMain2HandToHit = fMain2HandToHit / 20.0;
        fThreatChance = (IntToFloat(nThreat) / 20.0) * fMain2HandToHit;
        fMain2HandAvgDmg = (fMain2HandAvgDmg * fMain2HandToHit) + ((fMain2HandAvgDmg * IntToFloat(nMultiplier) + fCritBonusDmg) * fThreatChance);
        SetLocalFloat(oItem, "AI_MAIN_2W_HAND_AVG_DMG", fMain2HandAvgDmg);
        if(AI_DEBUG) ai_Debug("0i_items", "768", GetName(oItem) + " fMain2HandAvgDmg: " + FloatToString(fMain2HandAvgDmg, 0, 2));
        // Calculate the avg dmg for oItem used in the off hand.
        fOffHandToHit = fOffHandToHit / 20.0;
        fThreatChance = (IntToFloat(nThreat) / 20.0) * fOffHandToHit;
        fOffHandAvgDmg = (fOffHandAvgDmg * fOffHandToHit) + ((fOffHandAvgDmg * IntToFloat(nMultiplier) + fCritBonusDmg) * fThreatChance);
        SetLocalFloat(oItem, "AI_OFFHAND_AVG_DMG", fOffHandAvgDmg);
        if(AI_DEBUG) ai_Debug("0i_items", "790", GetName(oItem) + " fOffHandAvgDmg: " + FloatToString(fOffHandAvgDmg, 0, 2));
        // Return the correct value based on params passed.
        if(oOffWeapon != OBJECT_INVALID)
        {
            // This is used only for double weapons! Must pass b2Handed = TRUE and
            // oOffWeapon = the double weapon that was passes as oItem.
            if(b2Handed) return fMain2HandAvgDmg + fOffHandAvgDmg;
            return fMain2HandAvgDmg;
        }
        if(bOffHand) return fOffHandAvgDmg;
    }
    return fAvgDmg;
}
int ai_SetShieldAC(object oCreature, object oItem)
{
    if(oCreature == GetLocalObject(oItem, "AI_CREATURE_POSSESSION"))
    {
        return GetLocalInt(oItem, "AI_SHIELD_AC");
    }
    // Set the creature who has this item for setting the power of.
    SetLocalObject(oItem, "AI_CREATURE_POSSESSION", oCreature);
    int nItemType = GetBaseItemType(oItem);
    int nAC, nItemPropertyType;
    if(nItemType == BASE_ITEM_SMALLSHIELD) nAC = 1;
    else if(nItemType == BASE_ITEM_LARGESHIELD) nAC = 2;
    else if(nItemType == BASE_ITEM_TOWERSHIELD) nAC = 3;
    itemproperty ipProperty = GetFirstItemProperty(oItem);
    while(GetIsItemPropertyValid(ipProperty))
    {
        nItemPropertyType = GetItemPropertyType(ipProperty);
        if(nItemPropertyType == ITEM_PROPERTY_AC_BONUS)
        {
            nAC += GetItemPropertyCostTableValue(ipProperty);
        }
        else if(nItemPropertyType == ITEM_PROPERTY_DECREASED_AC)
        {
            nAC -= GetItemPropertyCostTableValue(ipProperty);
        }
        else if(nItemPropertyType == ITEM_PROPERTY_HASTE)
        {
            nAC += 4;
        }
        ipProperty = GetNextItemProperty(oItem);
    }
    SetLocalInt(oItem, "AI_SHIELD_AC", nAC);
    if(AI_DEBUG) ai_Debug("0i_items", "718", GetName(oItem) + " nAC: " + IntToString(nAC));
    return nAC;
}
int ai_GetHasItemProperty(object oItem, int nItemPropertyType, int nItemPropertySubType = -1)
{
    itemproperty ipProperty = GetFirstItemProperty(oItem);
    while(GetIsItemPropertyValid(ipProperty))
    {
        if(GetItemPropertyType(ipProperty) == nItemPropertyType)
        {
            if(nItemPropertySubType > -1)
            {
                if(GetItemPropertySubType(ipProperty) == nItemPropertySubType) return TRUE;
            }
            else return TRUE;
        }
        ipProperty = GetNextItemProperty(oItem);
    }
    return FALSE;
}
object ai_GetBestPicks(object oCreature, int nLockDC)
{
    int nSkill = GetSkillRank(SKILL_OPEN_LOCK, oCreature);
    int nBonus, nBestBonus = 99, nNeededBonus = nLockDC - nSkill - 20;
    //ai_Debug("0i_items", "651", "nNeededBonus: " + IntToString(nNeededBonus));
    // We don't need to use any picks!
    if(nNeededBonus < 1) return OBJECT_INVALID;
    object oBestItem = OBJECT_INVALID;
    object oItem = GetFirstItemInInventory(oCreature);
    while(oItem != OBJECT_INVALID)
    {
        if(GetBaseItemType(oItem) == BASE_ITEM_THIEVESTOOLS)
        {
            // Get the tools bonus.
            itemproperty ipProperty = GetFirstItemProperty(oItem);
            while(GetIsItemPropertyValid(ipProperty))
            {
                if(GetItemPropertyType(ipProperty) == ITEM_PROPERTY_THIEVES_TOOLS)
                {
                    nBonus = GetItemPropertyCostTableValue(ipProperty);
                    if(nBonus >= nNeededBonus && nBonus < nBestBonus)
                    {
                        nBestBonus = nBonus;
                        oBestItem = oItem;
                        SetLocalInt(oBestItem, "AI_BONUS", nBestBonus);
                        break;
                    }
                }
                ipProperty = GetNextItemProperty(oItem);
            }
        }
        oItem = GetNextItemInInventory(oCreature);
    }
    return oBestItem;
}
void ai_RemoveInventory(object oCreature)
{
    object oItem = GetFirstItemInInventory(oCreature);
    while(oItem != OBJECT_INVALID)
    {
        DestroyObject(oItem);
        oItem = GetNextItemInInventory(oCreature);
    }
    int nIndex;
    for(nIndex = 0; nIndex <= 13; nIndex++)
    {
        oItem = GetItemInSlot(nIndex, oCreature);
        DestroyObject(oItem);
    }
}
void ai_MoveInventory(object oOldHenchman, object oNewHenchman)
{
    // Move all inventory items.
    object oItem = GetFirstItemInInventory(oOldHenchman);
    while(oItem != OBJECT_INVALID)
    {
        CopyItem(oItem, oNewHenchman, TRUE);
        oItem = GetNextItemInInventory(oOldHenchman);
    }
    // Move all equiped items and equip on oNewHenchman.
    int nIndex;
    object oNewItem;
    for(nIndex = 0; nIndex <= 13; nIndex++)
    {
        oItem = GetItemInSlot(nIndex, oOldHenchman);
        if(oItem != OBJECT_INVALID)
        {
            oNewItem = CopyItem(oItem, oNewHenchman, TRUE);
            if(!GetIdentified(oNewItem)) SetIdentified(oNewItem, TRUE);
            ActionEquipItem(oNewItem, nIndex);
        }
    }
}
int prc_IsProficient(object oCreature, int nBaseItem)
{
    switch(nBaseItem)
    {
        //special case: counts as simple for chitine
        case BASE_ITEM_SHORTSWORD:
            return GetHasFeat(FEAT_WEAPON_PROFICIENCY_MARTIAL, oCreature)
                 || GetHasFeat(FEAT_WEAPON_PROFICIENCY_ROGUE, oCreature)
                 || GetHasFeat(3600/*FEAT_MINDBLADE*/, oCreature)
                 || (GetHasFeat(FEAT_WEAPON_PROFICIENCY_SIMPLE, oCreature)
                 && GetRacialType(oCreature) == 76/*RACIAL_TYPE_CHITINE*/)
                 || GetHasFeat(7901/*FEAT_WEAPON_PROFICIENCY_SHORTSWORD*/, oCreature);

        case BASE_ITEM_LONGSWORD:
            return GetHasFeat(FEAT_WEAPON_PROFICIENCY_MARTIAL, oCreature)
                 || GetHasFeat(3600/*FEAT_MINDBLADE*/, oCreature)
                 || GetHasFeat(FEAT_WEAPON_PROFICIENCY_ELF, oCreature)
                 || GetHasFeat(7902/*FEAT_WEAPON_PROFICIENCY_LONGSWORD*/, oCreature);

        case BASE_ITEM_BATTLEAXE:
            return GetHasFeat(FEAT_WEAPON_PROFICIENCY_MARTIAL, oCreature)
                 || (GetHasFeat(FEAT_WEAPON_PROFICIENCY_SIMPLE, oCreature)
                 && GetRacialType(oCreature) == 216/*RACIAL_TYPE_GNOLL*/)
                 || GetHasFeat(7903/*FEAT_WEAPON_PROFICIENCY_BATTLEAXE*/, oCreature);

        case BASE_ITEM_BASTARDSWORD:
            return GetHasFeat(FEAT_WEAPON_PROFICIENCY_EXOTIC, oCreature)
                 || GetHasFeat(3600/*FEAT_MINDBLADE*/, oCreature)
                 || GetHasFeat(7904/*FEAT_WEAPON_PROFICIENCY_BASTARD_SWORD*/, oCreature);

        case BASE_ITEM_LIGHTFLAIL:
            return GetHasFeat(FEAT_WEAPON_PROFICIENCY_MARTIAL, oCreature)
                 || GetHasFeat(7905/*FEAT_WEAPON_PROFICIENCY_LIGHT_FLAIL*/, oCreature);

        case BASE_ITEM_WARHAMMER:
            return GetHasFeat(FEAT_WEAPON_PROFICIENCY_MARTIAL, oCreature)
                 || GetHasFeat(7906/*FEAT_WEAPON_PROFICIENCY_WARHAMMER*/, oCreature);

        case BASE_ITEM_LONGBOW:
            return GetHasFeat(FEAT_WEAPON_PROFICIENCY_MARTIAL, oCreature)
                 || GetHasFeat(FEAT_WEAPON_PROFICIENCY_ELF, oCreature)
                 || GetHasFeat(7907/*FEAT_WEAPON_PROFICIENCY_LONGBOW*/, oCreature);

        case BASE_ITEM_LIGHTMACE:
            return GetHasFeat(FEAT_WEAPON_PROFICIENCY_SIMPLE, oCreature)
                 || GetHasFeat(FEAT_WEAPON_PROFICIENCY_ROGUE, oCreature)
                 || GetHasFeat(7908/*FEAT_WEAPON_PROFICIENCY_LIGHT_MACE*/, oCreature);

        case BASE_ITEM_HALBERD:
            return GetHasFeat(FEAT_WEAPON_PROFICIENCY_MARTIAL, oCreature)
                 || GetHasFeat(7909/*FEAT_WEAPON_PROFICIENCY_HALBERD*/, oCreature);

        case BASE_ITEM_SHORTBOW:
            return GetHasFeat(FEAT_WEAPON_PROFICIENCY_MARTIAL, oCreature)
                 || GetHasFeat(FEAT_WEAPON_PROFICIENCY_ROGUE, oCreature)
                 || GetHasFeat(FEAT_WEAPON_PROFICIENCY_ELF, oCreature)
                 || (GetHasFeat(FEAT_WEAPON_PROFICIENCY_SIMPLE, oCreature)
                 && GetRacialType(oCreature) == 216/*RACIAL_TYPE_GNOLL*/)
                 || GetHasFeat(7910/*FEAT_WEAPON_PROFICIENCY_SHORTBOW*/, oCreature);

        case BASE_ITEM_TWOBLADEDSWORD:
            return GetHasFeat(FEAT_WEAPON_PROFICIENCY_EXOTIC, oCreature)
                 || GetHasFeat(7911/*FEAT_WEAPON_PROFICIENCY_TWO_BLADED_SWORD*/, oCreature);

        case BASE_ITEM_GREATSWORD:
            return GetHasFeat(FEAT_WEAPON_PROFICIENCY_MARTIAL, oCreature)
                 || GetHasFeat(7912/*FEAT_WEAPON_PROFICIENCY_GREATSWORD*/, oCreature);

        case BASE_ITEM_GREATAXE:
            return GetHasFeat(FEAT_WEAPON_PROFICIENCY_MARTIAL, oCreature)
                 || GetHasFeat(7913/*FEAT_WEAPON_PROFICIENCY_GREATAXE*/, oCreature);

        case BASE_ITEM_DART:
            return GetHasFeat(FEAT_WEAPON_PROFICIENCY_SIMPLE, oCreature)
                 || GetHasFeat(FEAT_WEAPON_PROFICIENCY_ROGUE, oCreature)
                 || GetHasFeat(FEAT_WEAPON_PROFICIENCY_DRUID, oCreature)
                 || GetHasFeat(7914/*FEAT_WEAPON_PROFICIENCY_DART*/, oCreature);

        case BASE_ITEM_DIREMACE:
            return GetHasFeat(7915/*FEAT_WEAPON_PROFICIENCY_DIRE_MACE*/, oCreature)
                 || GetHasFeat(FEAT_WEAPON_PROFICIENCY_EXOTIC, oCreature);

        case BASE_ITEM_DOUBLEAXE:
            return GetHasFeat(7916/*FEAT_WEAPON_PROFICIENCY_DOUBLE_AXE*/, oCreature)
                 || GetHasFeat(FEAT_WEAPON_PROFICIENCY_EXOTIC, oCreature);

        case BASE_ITEM_HEAVYFLAIL:
            return GetHasFeat(7917/*FEAT_WEAPON_PROFICIENCY_HEAVY_FLAIL*/, oCreature)
                 || GetHasFeat(FEAT_WEAPON_PROFICIENCY_MARTIAL, oCreature);

        case BASE_ITEM_LIGHTHAMMER:
            return GetHasFeat(7918/*FEAT_WEAPON_PROFICIENCY_LIGHT_HAMMER*/, oCreature)
                 || GetHasFeat(FEAT_WEAPON_PROFICIENCY_MARTIAL, oCreature);

        case BASE_ITEM_HANDAXE:
            return GetHasFeat(7919/*FEAT_WEAPON_PROFICIENCY_HANDAXE*/, oCreature)
                 || GetHasFeat(FEAT_WEAPON_PROFICIENCY_MARTIAL, oCreature)
                 || GetHasFeat(FEAT_WEAPON_PROFICIENCY_ROGUE, oCreature)
                 || GetHasFeat(FEAT_WEAPON_PROFICIENCY_MONK, oCreature);

        case BASE_ITEM_KAMA:
            return GetHasFeat(7920/*FEAT_WEAPON_PROFICIENCY_KAMA*/, oCreature)
                 || GetHasFeat(FEAT_WEAPON_PROFICIENCY_MONK, oCreature)
                 || GetHasFeat(FEAT_WEAPON_PROFICIENCY_EXOTIC, oCreature);

        case BASE_ITEM_KATANA:
            return GetHasFeat(7921/*FEAT_WEAPON_PROFICIENCY_KATANA*/, oCreature)
                 || GetHasFeat(FEAT_WEAPON_PROFICIENCY_EXOTIC, oCreature);

        case BASE_ITEM_KUKRI:
            return GetHasFeat(7922/*FEAT_WEAPON_PROFICIENCY_KUKRI*/, oCreature)
                 || GetHasFeat(FEAT_WEAPON_PROFICIENCY_EXOTIC, oCreature);

        case BASE_ITEM_MORNINGSTAR:
            return GetHasFeat(7923/*FEAT_WEAPON_PROFICIENCY_MORNINGSTAR*/, oCreature)
                 || GetHasFeat(FEAT_WEAPON_PROFICIENCY_SIMPLE, oCreature)
                 || GetHasFeat(FEAT_WEAPON_PROFICIENCY_ROGUE, oCreature);

        case BASE_ITEM_QUARTERSTAFF:
            return GetHasFeat(FEAT_WEAPON_PROFICIENCY_SIMPLE, oCreature)
                 || GetHasFeat(FEAT_WEAPON_PROFICIENCY_DRUID, oCreature)
                 || GetHasFeat(FEAT_WEAPON_PROFICIENCY_WIZARD, oCreature);

        case BASE_ITEM_RAPIER:
            return GetHasFeat(7924/*FEAT_WEAPON_PROFICIENCY_RAPIER*/, oCreature)
                 || GetHasFeat(FEAT_WEAPON_PROFICIENCY_MARTIAL, oCreature)
                 || GetHasFeat(FEAT_WEAPON_PROFICIENCY_ROGUE, oCreature)
                 || GetHasFeat(FEAT_WEAPON_PROFICIENCY_ELF, oCreature);

        case BASE_ITEM_SCIMITAR:
            return GetHasFeat(7925/*FEAT_WEAPON_PROFICIENCY_SCIMITAR*/, oCreature)
                 || GetHasFeat(FEAT_WEAPON_PROFICIENCY_MARTIAL, oCreature)
                 || GetHasFeat(FEAT_WEAPON_PROFICIENCY_DRUID, oCreature);

        case BASE_ITEM_SCYTHE:
            return GetHasFeat(7926/*FEAT_WEAPON_PROFICIENCY_SCYTHE*/, oCreature)
                 || GetHasFeat(FEAT_WEAPON_PROFICIENCY_MARTIAL, oCreature);

        case BASE_ITEM_SHORTSPEAR:
            return GetHasFeat(7927/*FEAT_WEAPON_PROFICIENCY_SHORTSPEAR*/, oCreature)
                 || GetHasFeat(FEAT_WEAPON_PROFICIENCY_SIMPLE, oCreature)
                 || GetHasFeat(FEAT_WEAPON_PROFICIENCY_DRUID, oCreature);

        case BASE_ITEM_SHURIKEN:
             return GetHasFeat(7928/*FEAT_WEAPON_PROFICIENCY_SHURIKEN*/, oCreature)
                  || GetHasFeat(FEAT_WEAPON_PROFICIENCY_EXOTIC, oCreature)
                  || GetHasFeat(FEAT_WEAPON_PROFICIENCY_MONK, oCreature);

        case BASE_ITEM_SICKLE:
            return GetHasFeat(7929/*FEAT_WEAPON_PROFICIENCY_SICKLE*/, oCreature)
                 || GetHasFeat(FEAT_WEAPON_PROFICIENCY_SIMPLE, oCreature)
                 || GetHasFeat(FEAT_WEAPON_PROFICIENCY_DRUID, oCreature);

        case BASE_ITEM_SLING:
            return GetHasFeat(7930/*FEAT_WEAPON_PROFICIENCY_SLING*/, oCreature)
                 || GetHasFeat(FEAT_WEAPON_PROFICIENCY_SIMPLE, oCreature)
                 || GetHasFeat(FEAT_WEAPON_PROFICIENCY_ROGUE, oCreature)
                 || GetHasFeat(FEAT_WEAPON_PROFICIENCY_MONK, oCreature)
                 || GetHasFeat(FEAT_WEAPON_PROFICIENCY_DRUID, oCreature);

        case BASE_ITEM_THROWINGAXE:
            return GetHasFeat(7931/*FEAT_WEAPON_PROFICIENCY_THROWING_AXE*/, oCreature)
                 || GetHasFeat(FEAT_WEAPON_PROFICIENCY_MARTIAL, oCreature)
                 || GetHasFeat(3600/*FEAT_MINDBLADE*/, oCreature);

        case BASE_ITEM_CSLASHWEAPON:
        case BASE_ITEM_CPIERCWEAPON:
        case BASE_ITEM_CBLUDGWEAPON:
        case BASE_ITEM_CSLSHPRCWEAP:
            return GetHasFeat(FEAT_WEAPON_PROFICIENCY_CREATURE, oCreature);

        case BASE_ITEM_TRIDENT:
            return GetHasFeat(7932/*FEAT_WEAPON_PROFICIENCY_TRIDENT*/, oCreature)
                 || GetHasFeat(FEAT_WEAPON_PROFICIENCY_SIMPLE, oCreature)
                 || GetHasFeat(FEAT_WEAPON_PROFICIENCY_DRUID, oCreature);

        case 124://BASE_ITEM_DOUBLE_SCIMITAR:
            return GetHasFeat(7948/*FEAT_WEAPON_PROFICIENCY_DOUBLE_SCIMITAR*/, oCreature)
                || GetHasFeat(FEAT_WEAPON_PROFICIENCY_EXOTIC, oCreature);

        case 119://BASE_ITEM_FALCHION:
            return GetHasFeat(7943/*FEAT_WEAPON_PROFICIENCY_FALCHION*/, oCreature)
                || GetHasFeat(FEAT_WEAPON_PROFICIENCY_MARTIAL, oCreature);

        case 125://BASE_ITEM_GOAD:
            return GetHasFeat(7949/*FEAT_WEAPON_PROFICIENCY_GOAD*/, oCreature)
                || GetHasFeat(FEAT_WEAPON_PROFICIENCY_SIMPLE, oCreature);

        case 122://BASE_ITEM_HEAVY_MACE:
            return GetHasFeat(7946/*FEAT_WEAPON_PROFICIENCY_HEAVY_MACE*/, oCreature)
                || GetHasFeat(FEAT_WEAPON_PROFICIENCY_SIMPLE, oCreature);

        case 115://BASE_ITEM_HEAVY_PICK:
            return GetHasFeat(7939/*FEAT_WEAPON_PROFICIENCY_HEAVY_PICK*/, oCreature)
                || GetHasFeat(FEAT_WEAPON_PROFICIENCY_MARTIAL, oCreature);

        case 116://BASE_ITEM_LIGHT_PICK:
            return GetHasFeat(7940/*FEAT_WEAPON_PROFICIENCY_LIGHT_PICK*/, oCreature)
                || GetHasFeat(FEAT_WEAPON_PROFICIENCY_MARTIAL, oCreature);

        case 121://BASE_ITEM_KATAR:
            return GetHasFeat(7945/*FEAT_WEAPON_PROFICIENCY_KATAR*/, oCreature)
                || GetHasFeat(FEAT_WEAPON_PROFICIENCY_EXOTIC, oCreature);

        case 123://BASE_ITEM_MAUL:
            return GetHasFeat(7947/*FEAT_WEAPON_PROFICIENCY_MAUL*/, oCreature)
                || GetHasFeat(FEAT_WEAPON_PROFICIENCY_MARTIAL, oCreature);

        case 118://BASE_ITEM_NUNCHAKU:
            return GetHasFeat(7942/*FEAT_WEAPON_PROFICIENCY_NUNCHAKU*/, oCreature)
                                || GetHasFeat(FEAT_WEAPON_PROFICIENCY_MONK, oCreature)
                || GetHasFeat(FEAT_WEAPON_PROFICIENCY_EXOTIC, oCreature);

        case 117://BASE_ITEM_SAI:
            return GetHasFeat(7941/*FEAT_WEAPON_PROFICIENCY_SAI*/, oCreature)
                                || GetHasFeat(FEAT_WEAPON_PROFICIENCY_MONK, oCreature)
                || GetHasFeat(FEAT_WEAPON_PROFICIENCY_EXOTIC, oCreature);

        case 120://BASE_ITEM_SAP:
            return GetHasFeat(7944/*FEAT_WEAPON_PROFICIENCY_SAP*/, oCreature)
                                || GetHasFeat(FEAT_WEAPON_PROFICIENCY_ROGUE, oCreature)
                || GetHasFeat(FEAT_WEAPON_PROFICIENCY_MARTIAL, oCreature);

        //special case: counts as martial for dwarves
        case BASE_ITEM_DWARVENWARAXE:
            return GetHasFeat(7933/*FEAT_WEAPON_PROFICIENCY_DWARVEN_WARAXE*/, oCreature)
                 || (GetHasFeat(FEAT_WEAPON_PROFICIENCY_MARTIAL, oCreature)
                 && GetHasFeat(4710/*FEAT_DWARVEN*/, oCreature))
                 || GetHasFeat(FEAT_WEAPON_PROFICIENCY_EXOTIC, oCreature);

        case BASE_ITEM_WHIP:
            return GetHasFeat(7934/*FEAT_WEAPON_PROFICIENCY_WHIP*/, oCreature)
                 || GetHasFeat(FEAT_WEAPON_PROFICIENCY_EXOTIC, oCreature);
    }
    return TRUE;
}
int ai_GetItemUses(object oItem, int nItemPropertySubType)
{
    int nUses;
    itemproperty ipProperty = GetFirstItemProperty(oItem);
    while(GetIsItemPropertyValid(ipProperty))
    {
        if(GetItemPropertyType(ipProperty) == ITEM_PROPERTY_HEALERS_KIT) return GetItemStackSize(oItem);
        if(nItemPropertySubType > -1)
        {
            if(GetItemPropertySubType(ipProperty) == nItemPropertySubType)
            {
                // Get how they use the item (charges or uses per day).
                nUses = GetItemPropertyCostTableValue(ipProperty);
                if(nUses == 1) return GetItemStackSize(oItem);
                else if(nUses > 1 && nUses < 7) return GetItemCharges(oItem);
                else if(nUses == 7 || nUses == 13) return 999;
                else if(nUses > 7 && nUses < 13) return GetItemPropertyUsesPerDayRemaining(oItem, ipProperty);
            }
        }
        else return TRUE;
        ipProperty = GetNextItemProperty(oItem);
    }
    return FALSE;
}


