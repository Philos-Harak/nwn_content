/*////////////////////////////////////////////////////////////////////////////////////////////////////
 Script Name: 0e_unequip
 Programmer: Philos
//////////////////////////////////////////////////////////////////////////////////////////////////////
 Event script that runs when a creature unequips an item (Due to NWNX TWEAK).
 Notes: This runs before oItem is actually unequiped.

 All code has been moved to 0e_oi_unequip_a since that event works with NPC's.
*/////////////////////////////////////////////////////////////////////////////////////////////////////
#include "0i_character"
void main()
{
    object oItem = GetPCItemLastUnequipped();
    object oCreature = GetPCItemLastUnequippedBy();
    Debug("0e_unequip", "15", GetName(oCreature) + " oItem: " + GetName(oItem));
    int nBaseItemType = GetBaseItemType(oItem);
    // Check for weapon adjustments.
    if(GetIsWeapon(oItem))
    {
        // Check for Feats, Class abilities and Spell effects that work on weapons.
        DelayCommand(0.0, CheckEquipWeaponFeats(oCreature, oItem, FALSE));
        // Check for weapons used with Keldain's set.
        RemoveTempProperties(oItem, "itemset_1");
    }
    // Check for head gear used with U'l Phair's set.
    else if(nBaseItemType == BASE_ITEM_HELMET) RemoveTempProperties(oItem, "itemset_2");
    // Check armor to see if a tiefling has demonic legs.
    else if(nBaseItemType == BASE_ITEM_ARMOR)
    {
        RemoveTempProperties(oItem, "0_ASF_EQUIP");
        DelayCommand(0.0, CheckForArmorBonus(oCreature));
        DelayCommand(0.0, CheckDemonicAppearance(oCreature, oItem, 2));
    }
    // Check for shield adjustements
    else if(nBaseItemType == BASE_ITEM_LARGESHIELD ||
            nBaseItemType == BASE_ITEM_SMALLSHIELD ||
            nBaseItemType == BASE_ITEM_TOWERSHIELD)
    {
        RemoveTempProperties(oItem, "0_ASF_EQUIP");
        // Check for Feats, Class abilities and Spell effects that work on shields.
        DelayCommand(0.0, CheckEquipShieldFeats(oCreature, oItem, FALSE));
    }
    else if(nBaseItemType == BASE_ITEM_OPEN_FACE_HELMET)
    {
        RemoveTagedEffects(oCreature, "EFFECT_HELM");
    }
    string sTag = GetTag(oItem);
    // We have removed one of the Keldain's set, reapply.
    if(sTag == "itemset_1")
    {
        // We set this for eq_itemset_1 since we cannot reliably get the
        // creature that equips this item.
        SetLocalObject(oItem, "0_ITEMSET_OWNER", oCreature);
        DelayCommand(0.0, ExecuteScript("eq_itemset_1", oItem));
    }
    // We have removed ond of the U'l Phair's set, reapply.
    else if(sTag == "itemset_2")
    {
        // We set this for eq_itemset_2 since we cannot reliably get the
        // creature that equips this item.
        SetLocalObject(oItem, "0_ITEMSET_OWNER", oCreature);
        DelayCommand(0.0, ExecuteScript("eq_itemset_2", oItem));
    }
    // Check for special item scripts via Prefix "ue_" and the items tag.
    DelayCommand(0.0, ExecuteScript("ue_" + sTag, oItem));
}

