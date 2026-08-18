/*////////////////////////////////////////////////////////////////////////////////////////////////////
 Script Name: 0e_equip
 Programmer: Philos
//////////////////////////////////////////////////////////////////////////////////////////////////////
 Event script that runs when a creature equips an item (Due to NWNX TWEAK).

 NOTE: This also fires when a character enters the server as follows:
 1) 0e_equip: Runs the OnEquip script for each item equiped. Before 0e_aquireitem!
 2) 0e_aquireitem: Runs the OnAquireItem script for each item aquired at login.

 To make scripts for items that have powers on equiping name the script
 with the prefix "eq_" + the tag of the item. Don't forget to make a script
 for unequiping the item as well. Use "ue_" + the tag to define the unequip script.
*/////////////////////////////////////////////////////////////////////////////////////////////////////
#include "0i_items"
#include "0i_effects"
void main()
{
    object oCreature = GetPCItemLastEquippedBy();
    object oItem = GetPCItemLastEquipped();
    Debug("0e_equip", "17", GetName(oCreature) + " oItem: " + GetName(oItem) +
          " Character Loaded: " + IntToString(GetLocalInt(oCreature, "0_Character_Loaded")));
    // We only use this event for when players are loading into the server.
    if(GetIsCharacter(oCreature) && !GetLocalInt(oCreature, "0_Character_Loaded"))
    {
        int nBaseItemType = GetBaseItemType(oItem);
        // Check for open faced helms.
        if(nBaseItemType == BASE_ITEM_OPEN_FACE_HELMET) DoOpenFaceHelmetVisuals(oCreature, oItem);
        // Check for weapons.
        else if(GetIsWeapon(oItem) && !GetIsAmmo(oItem))
        {
            // Check for Feats, Class abilities and Spell effects that work on weapons.
            // we must wait until the player is loaded the first time.
            DelayCommand(5.0f, CheckEquipWeaponFeats(oCreature, oItem));
            DelayCommand(5.0f, ExecuteScript("eq_itemset_1", oItem));
        }
        // Check for head gear used with U'l Phair's set.
        else if(nBaseItemType == BASE_ITEM_HELMET) ExecuteScript("eq_itemset_2", oItem);
        else if(nBaseItemType == BASE_ITEM_ARMOR)
        {
            // Check to see if we need to add ArcaneSpellFailure mods.
            DelayCommand(5.0, CheckForArmorArcaneSpellFailure(oCreature, oItem));
            // Check to see if we need to adjust armor
            DelayCommand(5.0, CheckForArmorBonus(oCreature));
            // Check armor to see if a tiefling has demonic legs.
            DelayCommand(5.0, CheckDemonicAppearance(oCreature, oItem, 1));
        }
        // Check for shield adjustments
        else if(nBaseItemType == BASE_ITEM_LARGESHIELD || nBaseItemType == BASE_ITEM_SMALLSHIELD || nBaseItemType == BASE_ITEM_TOWERSHIELD)
        {
            // Check to see if we need to add ArcaneSpellFailure mods.
            DelayCommand(5.0, CheckForArmorArcaneSpellFailure(oCreature, oItem));
            // Check for Feats, Class abilities and Spell effects that work with shields.
            DelayCommand(5.0f, CheckEquipShieldFeats(oCreature, oItem));
        }
        string sTag = GetTag(oItem);
        // We have removed one of the Keldain's set, reapply.
        if(sTag == "itemset_1")
        {
            // We set this for eq_itemset_1 since we cannot reliably get the
            // creature that equips this item.
            SetLocalObject(oItem, "0_ITEMSET_OWNER", oCreature);
            DelayCommand(5.0, ExecuteScript("eq_itemset_1", oItem));
        }
        // We have removed one of the U'l Phair's set, reapply.
        else if(sTag == "itemset_2")
        {
            // We set this for eq_itemset_2 since we cannot reliably get the
            // creature that equips this item.
            SetLocalObject(oItem, "0_ITEMSET_OWNER", oCreature);
            DelayCommand(5.0, ExecuteScript("eq_itemset_2", oItem));
        }
        // Check for special item scripts via Prefix "eq_" and the items tag.
        DelayCommand(5.0, ExecuteScript("eq_" + sTag, oItem));
    }
    else
    {
        // Check for open faced helms.
        int nBaseItemType = GetBaseItemType(oItem);
        if(nBaseItemType == BASE_ITEM_OPEN_FACE_HELMET) DoOpenFaceHelmetVisuals(oCreature, oItem);
        // Check for head gear used with U'l Phair's set.
        else if(nBaseItemType == BASE_ITEM_HELMET) ExecuteScript("eq_itemset_2", oItem);
        else if(nBaseItemType == BASE_ITEM_ARMOR)
        {
            // Check to see if we need to add ArcaneSpellFailure mods.
            CheckForArmorArcaneSpellFailure(oCreature, oItem);
            // Check to see if we need to adjust armor
            CheckForArmorBonus(oCreature);
            // Check armor to see if a tiefling has demonic legs.
            CheckDemonicAppearance(oCreature, oItem, 1);
        }
        else if(nBaseItemType == 181/*BASE_ITEM_ACCESSORY_MOUTH*/)
        {
            // Remove any effect that is already using the mouth effects slot.
            string sEffectTag;
            effect eVFX = GetFirstEffect(oCreature);
            while(GetIsEffectValid(eVFX))
            {
                sEffectTag = GetEffectTag(eVFX);
                if(GetStringLeft(sEffectTag, 9) == "VFXMOUTH_" && nBaseItemType == 181) 
                {
                    RemoveEffect(oCreature, eVFX);
                    DeleteLocalInt(oItem, "VFX_APPLIED");
                    break;
                }
                eVFX = GetNextEffect(oCreature);
            }            
        }
        // Check for weapons.
        else if(GetIsWeapon(oItem) && !GetIsAmmo(oItem))
        {
            CheckEquipWeaponFeats(oCreature, oItem);
            // We set this for eq_itemset_1 since we cannot reliably get the
            // creature that equips this item.
            SetLocalObject(oItem, "0_ITEMSET_OWNER", oCreature);
            DelayCommand(0.5, ExecuteScript("eq_itemset_1", oItem));
        }
        // Check for shield adjustments
        else if(nBaseItemType == BASE_ITEM_LARGESHIELD ||
                nBaseItemType == BASE_ITEM_SMALLSHIELD ||
                nBaseItemType == BASE_ITEM_TOWERSHIELD)
        {
            // Check to see if we need to add ArcaneSpellFailure mods.
            CheckForArmorArcaneSpellFailure(oCreature, oItem);
            // Check for Feats, Class abilities and Spell effects that work with shields.
            CheckEquipShieldFeats(oCreature, oItem);
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
        // Check for special item scripts via Prefix "eq_" and the items tag.
        ExecuteScript("eq_" + GetTag(oItem), oItem);
    }
}

