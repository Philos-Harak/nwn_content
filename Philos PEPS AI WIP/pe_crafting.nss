/*//////////////////////////////////////////////////////////////////////////////
// Script Name: pe_crafting
////////////////////////////////////////////////////////////////////////////////
 Used with ai_crafting to run the crafting plugin for
 Philos Single Player Enhancements.
*///////////////////////////////////////////////////////////////////////////////
#include "nw_inc_gff"
#include "0i_items"
const string CRAFT_ORIGINAL_ITEM = "CRAFT_ORIGINAL_ITEM";
const string CRAFT_COOL_DOWN = "CRAFT_COOL_DOWN";
const string CRAFT_ITEM_SELECTION = "CRAFT_ITEM_SELECTION";
const string CRAFT_MATERIAL_SELECTION = "CRAFT_MATERIAL_SELECTION";
const string CRAFT_MODEL_SELECTION = "CRAFT_MODEL_SELECTION";
const string CRAFT_MODEL = "CRAFT_MODEL";
const string CRAFT_MODEL_SPECIAL = "CRAFT_MODEL_SPECIAL";
const string CRAFT_ITEM_TYPE = "CRAFT_ITEM_TYPE";
const string CRAFT_WEAPON_MOD_TOP = "CRAFT_WEAPON_MOD_TOP";
const string CRAFT_WEAPON_MOD_MID = "CRAFT_WEAPON_MOD_MID";
const string CRAFT_WEAPON_MOD_BOT = "CRAFT_WEAPON_MOD_BOT";
const string CRAFT_WEAPON_COL_TOP = "CRAFT_WEAPON_COL_TOP";
const string CRAFT_WEAPON_COL_MID = "CRAFT_WEAPON_COL_MID";
const string CRAFT_WEAPON_COL_BOT = "CRAFT_WEAPON_COL_BOT";
const string CRAFT_COPY_ITEM = "CRAFT_COPY_ITEM";
const string CRAFT_COPY_ITEM_TYPE = "CRAFT_COPY_ITEM_TYPE";
const string CRAFT_COPY_MODEL = "CRAFT_COPY_MODEL";
const string CRAFT_COPY_COLOR = "CRAFT_COPY_COLOR";
const string CRAFT_COPY_PART_COLOR = "CRAFT_COPY_PART_COLOR";
const string CRAFT_ARMOR_AC = "CRAFT_ARMOR_AC";
const string CRAFT_COLOR_PALLET = "CRAFT_COLOR_PALLET";
const string CRAFT_PART_COLOR = "CRAFT_PART_COLOR";
// Tag used in effects to freeze player.
const string CRAFT_FREEZE = "CRAFT_FREEZE";
// The tags for containers used to do some crafting.
const string CRAFT_TEMPLATE = "x3_plc_basket";
const string CRAFT_CONTAINER = "CRAFT_CONTAINER";
// Used in the crafting GUI to copy an item to be pasted to another item later.
void CopyCraftingItem(object oPC, object oItem);
// Used in the crafting GUI to paste a copy of an item to another item.
object PasteCraftingItem(object oPC, object oTarget, object oItem);
int GetItemSelectedEquipSlot(int nItemSelected);
int GetArmorModelSelected(object oPC);
object ChangeItemsAppearance(object oPC, object oTarget, int nToken, object oItem, int nDirection);
// Checks to see if the item can be crafted.
// bPasteCheck is a special check when an item is being pasted.
int CanCraftItem(object oPC, object oItem, int nToken, int bPasteCheck = FALSE);
object RandomizeItemsCraftAppearance(object oPlayer, object oTarget, int nToken, object oItem);
// Returns the correct item based on the crafting menu selected item.
object GetSelectedItem(object oTarget, int nItemSelected);
// Cancels the crafted item for the player and restoring the original.
void CancelCraftedItem(object oPlayer, object oTarget);
// Gets the colorId from a image of the color pallet.
// Thanks Zunath for the base code.
int GetColorPalletId(object oPC);
// Locks/Unlocks specific buttons when an item has been changed.
void LockItemInCraftingWindow(object oPC, object oItem, int nToken);
// Locks/Unlocks specific buttons when an item has been cleared.
void ClearItemInCraftingWindow(object oPC, object oItem, int nToken);
// Change the button or item based on this buttons special function.
// Armor - 0 Left/Right, 1 Right, 2 Left, Cloak/Helm 3 Hidden, 4 Visible
void DoSpecialButton(object oPC, object oItem, int nToken);
// Saves the crafted item for the player removing the original.
void SaveCraftedItem(object oPC, object oTarget, int nToken);
// Remove Effect of type specified from oCreature;
// sEffectTag is the tag of the effect to remove.
// Feat, Class, Racial.
void RemoveTagedEffects(object oCreature, string sEffectTag);
// Returns TRUE/FALSE if item has temporary item property.
int CheckForTemporaryItemProperty(object oItem);
void main()
{
    // Let the inspector handle what it wants.
    //HandleWindowInspectorEvent ();
    object oPC = NuiGetEventPlayer();
    int nToken = NuiGetEventWindow();
    string sEvent = NuiGetEventType();
    string sElem = NuiGetEventElement();
    int nIndex = NuiGetEventArrayIndex();
    string sWndId = NuiGetWindowId (oPC, nToken);
    int bNumberRolls;
    //**************************************************************************
    // Crafting window events.
    if(sWndId == "plcraftwin")
    {
        // Delay crafting so it has time to equip and unequip as well as remove.
        if(GetLocalInt(oPC, CRAFT_COOL_DOWN)) return;
        SetLocalInt(oPC, CRAFT_COOL_DOWN, TRUE);
        DelayCommand(0.25f, DeleteLocalInt(oPC, CRAFT_COOL_DOWN));
        object oTarget = oPC;
        // Get the item we are crafting.
        int nItemSelected = GetLocalInt(oPC, CRAFT_ITEM_SELECTION);
        object oItem = GetSelectedItem(oTarget, nItemSelected);
        // They have selected a color.
        if(sEvent == "mousedown" && sElem == "color_pallet")
        {
            // Get the color they selected from the color pallet cell.
            int nColorId = GetColorPalletId(oPC);
            if(ai_GetIsWeapon(oItem) || ai_GetIsShield(oItem))
            {
                ai_SendMessages("Weapons and shields don't use the color Pallet!", AI_COLOR_RED, oPC);
                return;
            }
            if(!CanCraftItem(oPC, oItem, nToken)) return;
            int nMaterialSelected = GetLocalInt(oPC, CRAFT_MATERIAL_SELECTION);
            object oNewItem;
            int nBaseItemType = GetBaseItemType(oItem);
            if(GetLocalInt(oPC, CRAFT_PART_COLOR) && nBaseItemType == BASE_ITEM_ARMOR)
            {
                int nIndex;
                int nModelSelected = GetArmorModelSelected(oPC);
                int nModelSide = GetLocalInt(oPC, CRAFT_MODEL_SPECIAL);
                if(nModelSide == 1 ||
                   nModelSelected == ITEM_APPR_ARMOR_MODEL_NECK ||
                   nModelSelected == ITEM_APPR_ARMOR_MODEL_TORSO ||
                   nModelSelected == ITEM_APPR_ARMOR_MODEL_BELT ||
                   nModelSelected == ITEM_APPR_ARMOR_MODEL_PELVIS ||
                   nModelSelected == ITEM_APPR_ARMOR_MODEL_ROBE)
                {
                    nIndex = ITEM_APPR_ARMOR_NUM_COLORS + (nModelSelected * ITEM_APPR_ARMOR_NUM_COLORS) + nMaterialSelected;
                    oNewItem = CopyItemAndModify(oItem, ITEM_APPR_TYPE_ARMOR_COLOR, nIndex, nColorId, TRUE);
                    DestroyObject(oItem);
                }
                else if(nModelSide == 0)
                {
                    // Color Right side.
                    nIndex = ITEM_APPR_ARMOR_NUM_COLORS + (nModelSelected * ITEM_APPR_ARMOR_NUM_COLORS) + nMaterialSelected;
                    oNewItem = CopyItemAndModify(oItem, ITEM_APPR_TYPE_ARMOR_COLOR, nIndex, nColorId, TRUE);
                    DestroyObject(oItem);
                    // If we are doing the left side then add one to get the left side.
                    // Note: Right Thigh and Left Thigh are backwards so this fixes that!
                    if (nModelSelected == ITEM_APPR_ARMOR_MODEL_RTHIGH) nModelSelected = nModelSelected - 1;
                    else nModelSelected = nModelSelected + 1;
                    nIndex = ITEM_APPR_ARMOR_NUM_COLORS + (nModelSelected * ITEM_APPR_ARMOR_NUM_COLORS) + nMaterialSelected;
                    oItem = CopyItemAndModify(oNewItem, ITEM_APPR_TYPE_ARMOR_COLOR, nIndex, nColorId, TRUE);
                    DestroyObject(oNewItem);
                    oNewItem = oItem;
                }
                else
                {
                    // If we are doing the left side then add one to get the left side.
                    // Note: Right Thigh and Left Thigh are backwards so this fixes that!
                    if (nModelSelected == ITEM_APPR_ARMOR_MODEL_RTHIGH) nModelSelected = nModelSelected - 1;
                    else nModelSelected = nModelSelected + 1;
                    nIndex = ITEM_APPR_ARMOR_NUM_COLORS + (nModelSelected * ITEM_APPR_ARMOR_NUM_COLORS) + nMaterialSelected;
                    oNewItem = CopyItemAndModify(oItem, ITEM_APPR_TYPE_ARMOR_COLOR, nIndex, nColorId, TRUE);
                    DestroyObject(oItem);
                }
            }
            else oNewItem = CopyItemAndModify(oItem, ITEM_APPR_TYPE_ARMOR_COLOR, nMaterialSelected, nColorId, TRUE);
            // Lock the new item so they can't change it on the character.
            LockItemInCraftingWindow(oPC, oNewItem, nToken);
            // Equip new item.
            if(nBaseItemType == BASE_ITEM_CLOAK) AssignCommand (oTarget, ActionEquipItem(oNewItem, INVENTORY_SLOT_CLOAK));
            else if(nBaseItemType == BASE_ITEM_HELMET) AssignCommand(oTarget, ActionEquipItem(oNewItem, INVENTORY_SLOT_HEAD));
            else if(nBaseItemType == BASE_ITEM_ARMOR) AssignCommand(oTarget, ActionEquipItem(oNewItem, INVENTORY_SLOT_CHEST));

        }
        else if(sEvent == "watch")
        {
            // The player is changing the item they are crafting.
            if(sElem == "item_combo_selected")
            {
                int nSelected = JsonGetInt (NuiGetBind (oPC, nToken, sElem));
                SetLocalInt (oPC, CRAFT_ITEM_SELECTION, nSelected);
                // Set special option.
                if(nSelected == 0)
                {
                    int nSpecial = GetLocalInt(oPC, CRAFT_MODEL_SPECIAL);
                    if(nSpecial > 2) nSpecial = 0;
                    SetLocalInt (oPC, CRAFT_MODEL_SPECIAL, nSpecial);
                }
                // Set button for cloak and helms.
                else if(nSelected == 1 || nSelected == 2)
                {
                    int nHidden = GetHiddenWhenEquipped(oItem);
                    if(nHidden) SetLocalInt(oPC, CRAFT_MODEL_SPECIAL, 4);
                    else SetLocalInt(oPC, CRAFT_MODEL_SPECIAL, 3);
                }
                // Remove any copy.
                SetLocalInt(oPC, CRAFT_COPY_ITEM, FALSE);
                NuiDestroy(oPC, nToken);
                ExecuteScript("pi_crafting", oPC);
            }
            // They have selected a part to change.
            else if(sElem == "model_combo_selected")
            {
                int nSelected = JsonGetInt(NuiGetBind (oPC, nToken, sElem));
                SetLocalInt(oPC, CRAFT_MODEL_SELECTION, nSelected);
            }
            // They have changed the material (color item) for the item.
            else if(sElem == "material_combo_selected")
            {
                int nSelected = JsonGetInt(NuiGetBind(oPC, nToken, sElem));
                SetLocalInt(oPC, CRAFT_MATERIAL_SELECTION, nSelected);
                // Change the pallet for the correct material.
                string sColorPallet;
                if(nSelected == 0 || nSelected == 1) sColorPallet = "cloth_pallet";
                else if(nSelected == 2 || nSelected == 3) sColorPallet = "leather_pallet";
                else sColorPallet = "armor_pallet";
                NuiSetBind(oPC, nToken, "color_pallet_image", JsonString (sColorPallet));
                SetLocalString(oPC, CRAFT_COLOR_PALLET, sColorPallet);
            }
        }
        else if(sEvent == "click")
        {
            // Copy the item they have selected.
            if(sElem == "btn_copy")
            {
                if(!GetLocalInt (oPC, CRAFT_COPY_ITEM))
                {
                    CopyCraftingItem (oPC, oItem);
                    NuiSetBind (oPC, nToken, "btn_paste_event", JsonBool (TRUE));
                }
                NuiSetBind (oPC, nToken, "btn_copy", JsonBool (TRUE));
            }
            // Paste the copy item with the current item.
            else if(sElem == "btn_paste")
            {
                if(CanCraftItem(oPC, oItem, nToken, TRUE))
                {
                    oItem = PasteCraftingItem(oPC, oTarget, oItem);
                    LockItemInCraftingWindow(oPC, oItem, nToken);
                    NuiSetBind(oPC, nToken, "btn_paste_event", JsonBool (FALSE));
                }
            }
            // Random button to change items looks randomly.
            else if(sElem == "btn_rand")
            {
                if(CanCraftItem(oPC, oItem, nToken))
                {
                    oItem = RandomizeItemsCraftAppearance(oPC, oTarget, nToken, oItem);
                    LockItemInCraftingWindow(oPC, oItem, nToken);
                }
            }
            // Get the previous model of the selected item.
            else if(sElem == "btn_prev")
            {
                if(CanCraftItem(oPC, oItem, nToken))
                {
                    oItem = ChangeItemsAppearance(oPC, oTarget, nToken, oItem, -1);
                    LockItemInCraftingWindow(oPC, oItem, nToken);
                }
            }
            // Get the next model of the selected item.
            else if(sElem == "btn_next")
            {
                if(CanCraftItem(oPC, oItem, nToken))
                {
                    oItem = ChangeItemsAppearance(oPC, oTarget, nToken, oItem, 1);
                    LockItemInCraftingWindow(oPC, oItem, nToken);
                }
            }
            // Save any changes made to the selected item.
            else if(sElem == "btn_save")
            {
                SaveCraftedItem(oPC, oTarget, nToken);
            }
            // Do a specific tast based on selected item.
            // i.e. Left/Right/Link and disappear/visible.
            else if(sElem == "btn_special")
            {
                if(CanCraftItem(oPC, oItem, nToken)) DoSpecialButton(oPC, oItem, nToken);
            }
            // Cancel any changes made to the selected item.
            else if(sElem == "btn_cancel")
            {
                // If the button is on cancel then clear the item.
                if(JsonGetString(NuiGetBind(oPC, nToken, "btn_cancel_label")) == "Cancel")
                {
                    CancelCraftedItem(oPC, oTarget);
                    ClearItemInCraftingWindow(oPC, oItem, nToken);
                }
                // If the button is on Exit not Cancel then exit.
                else
                {
                    AssignCommand(oPC, RestoreCameraFacing());
                    RemoveTagedEffects(oPC, CRAFT_FREEZE);
                    NuiDestroy(oPC, nToken);
                }
            }
            else if(sElem == "btn_part_color")
            {
                if(!GetLocalInt(oPC, CRAFT_PART_COLOR))
                {
                    SetLocalInt(oPC, CRAFT_PART_COLOR, TRUE);
                    NuiSetBind(oPC, nToken, "btn_part_color", JsonBool (TRUE));
                }
                else
                {
                    SetLocalInt(oPC, CRAFT_PART_COLOR, FALSE);
                    NuiSetBind(oPC, nToken, "btn_part_color", JsonBool (FALSE));
                }
            }
        }
    }
}
void CopyCraftingItem(object oPC, object oItem)
{
    ai_Debug("pe_crafting", "295", JsonDump(ObjectToJson(oItem), 2));
    json jItem = ObjectToJson(oItem);
    SetLocalInt(oPC, CRAFT_COPY_ITEM, TRUE);
    int nSelected = GetLocalInt(oPC, CRAFT_ITEM_SELECTION);
    if (ai_GetIsWeapon(oItem))
    {
        // Copy the base item type;
        SetLocalInt(oPC, CRAFT_COPY_ITEM_TYPE, GetBaseItemType(oItem));
        // Copy each model/color & save to variables.
        int nIndex = 1;
        string sIndex;
        while(nIndex <= 3)
        {
            sIndex = IntToString(nIndex);
            SetLocalInt(oPC, CRAFT_COPY_MODEL + sIndex, JsonGetInt(GffGetByte(jItem, "ModelPart" + sIndex)));
            nIndex++;
        }
    }
    else if (nSelected == 0)
    {
        // Copy the armors AC so we can check it.
        SetLocalInt(oPC, CRAFT_ARMOR_AC, ai_GetArmorBonus(oItem));
        // Copy an per part colors if they exist.
        int nPart, nColor, nPartColor;
        string sPart, sColor;
        while(nPart <= 18)
        {
            sPart = IntToString(nPart);
            nColor = 0;
            while(nColor <= 5)
            {
                sColor = IntToString(nColor);
                if(GffGetFieldExists(jItem, "APart_" + sPart + "_Col_" + sColor, GFF_FIELD_TYPE_BYTE))
                {
                    // Shift the number up by 1 so we can save as a variable and not use 0!
                    nPartColor = JsonGetInt(GffGetByte(jItem, "APart_" + sPart + "_Col_" + sColor)) + 1;
                    SetLocalInt(oPC, CRAFT_COPY_PART_COLOR + sPart + sColor, nPartColor);
                }
                nColor++;
            }
            nPart++;
        }
        // Copy each model & save to variables.
        SetLocalInt(oPC, "CRAFT_COPY_MODEL0", JsonGetInt(GffGetByte(jItem, "ArmorPart_Belt")));
        SetLocalInt(oPC, "CRAFT_COPY_MODEL1", JsonGetInt(GffGetByte(jItem, "ArmorPart_LBicep")));
        SetLocalInt(oPC, "CRAFT_COPY_MODEL2", JsonGetInt(GffGetByte(jItem, "ArmorPart_LFArm")));
        SetLocalInt(oPC, "CRAFT_COPY_MODEL3", JsonGetInt(GffGetByte(jItem, "ArmorPart_LFoot")));
        SetLocalInt(oPC, "CRAFT_COPY_MODEL4", JsonGetInt(GffGetByte(jItem, "ArmorPart_LHand")));
        SetLocalInt(oPC, "CRAFT_COPY_MODEL5", JsonGetInt(GffGetByte(jItem, "ArmorPart_LShin")));
        SetLocalInt(oPC, "CRAFT_COPY_MODEL6", JsonGetInt(GffGetByte(jItem, "ArmorPart_LShoul")));
        SetLocalInt(oPC, "CRAFT_COPY_MODEL7", JsonGetInt(GffGetByte(jItem, "ArmorPart_LThigh")));
        SetLocalInt(oPC, "CRAFT_COPY_MODEL8", JsonGetInt(GffGetByte(jItem, "ArmorPart_Neck")));
        SetLocalInt(oPC, "CRAFT_COPY_MODEL9", JsonGetInt(GffGetByte(jItem, "ArmorPart_Pelvis")));
        SetLocalInt(oPC, "CRAFT_COPY_MODEL10", JsonGetInt(GffGetByte(jItem, "ArmorPart_RBicep")));
        SetLocalInt(oPC, "CRAFT_COPY_MODEL11", JsonGetInt(GffGetByte(jItem, "ArmorPart_RFArm")));
        SetLocalInt(oPC, "CRAFT_COPY_MODEL12", JsonGetInt(GffGetByte(jItem, "ArmorPart_RFoot")));
        SetLocalInt(oPC, "CRAFT_COPY_MODEL13", JsonGetInt(GffGetByte(jItem, "ArmorPart_RHand")));
        SetLocalInt(oPC, "CRAFT_COPY_MODEL14", JsonGetInt(GffGetByte(jItem, "ArmorPart_RShin")));
        SetLocalInt(oPC, "CRAFT_COPY_MODEL15", JsonGetInt(GffGetByte(jItem, "ArmorPart_RShoul")));
        SetLocalInt(oPC, "CRAFT_COPY_MODEL16", JsonGetInt(GffGetByte(jItem, "ArmorPart_RThigh")));
        SetLocalInt(oPC, "CRAFT_COPY_MODEL17", JsonGetInt(GffGetByte(jItem, "ArmorPart_Robe")));
        SetLocalInt(oPC, "CRAFT_COPY_MODEL18", JsonGetInt(GffGetByte(jItem, "ArmorPart_Torso")));
        // Copy each color and save to variables.
        SetLocalInt(oPC, "CRAFT_COPY_COLOR0", JsonGetInt(GffGetByte(jItem, "Cloth1Color")));
        SetLocalInt(oPC, "CRAFT_COPY_COLOR1", JsonGetInt(GffGetByte(jItem, "Cloth2Color")));
        SetLocalInt(oPC, "CRAFT_COPY_COLOR2", JsonGetInt(GffGetByte(jItem, "Leather1Color")));
        SetLocalInt(oPC, "CRAFT_COPY_COLOR3", JsonGetInt(GffGetByte(jItem, "Leather2Color")));
        SetLocalInt(oPC, "CRAFT_COPY_COLOR4", JsonGetInt(GffGetByte(jItem, "Metal1Color")));
        SetLocalInt(oPC, "CRAFT_COPY_COLOR5", JsonGetInt(GffGetByte(jItem, "Metal2Color")));
    }
else
    {
        // Copy the base item type;
        SetLocalInt(oPC, CRAFT_COPY_ITEM_TYPE, GetBaseItemType(oItem));
        // Copy the base item type;
        SetLocalInt(oPC, "CRAFT_COPY_MODEL0", JsonGetInt(GffGetByte(jItem, "ModelPart1")));
        // Copy each color and save to variables.
        SetLocalInt(oPC, "CRAFT_COPY_COLOR0", JsonGetInt(GffGetByte(jItem, "Cloth1Color")));
        SetLocalInt(oPC, "CRAFT_COPY_COLOR1", JsonGetInt(GffGetByte(jItem, "Cloth2Color")));
        SetLocalInt(oPC, "CRAFT_COPY_COLOR2", JsonGetInt(GffGetByte(jItem, "Leather1Color")));
        SetLocalInt(oPC, "CRAFT_COPY_COLOR3", JsonGetInt(GffGetByte(jItem, "Leather2Color")));
        SetLocalInt(oPC, "CRAFT_COPY_COLOR4", JsonGetInt(GffGetByte(jItem, "Metal1Color")));
        SetLocalInt(oPC, "CRAFT_COPY_COLOR5", JsonGetInt(GffGetByte(jItem, "Metal2Color")));
    }
    // Send message that it has been copied.
    ai_SendMessages(GetName (oItem) + " appearance has been copied!", AI_COLOR_GREEN, oPC);
}

// Used in the crafting GUI to paste a copy of an item to another item.
object PasteCraftingItem (object oPC, object oTarget, object oItem)
{
    int nModelPartNum;
    object oChestItem;
    int nSelected = GetLocalInt(oPC, CRAFT_ITEM_SELECTION);
    object oBuildContainer = GetObjectByTag(CRAFT_CONTAINER);
    // Move the item to the building container.
    oChestItem = CopyItem(oItem, oBuildContainer, TRUE);
    DestroyObject(oItem);
    json jItem = ObjectToJson(oChestItem, TRUE);
    if (ai_GetIsWeapon(oChestItem))
    {
        // Copy each model & save to variables.
        int nIndex = 1;
        string sIndex;
        while(nIndex <= 3)
        {
            sIndex = IntToString(nIndex);
            jItem = GffReplaceByte(jItem,"ModelPart" + sIndex, GetLocalInt(oPC, CRAFT_COPY_MODEL + sIndex));
            jItem = GffReplaceWord(jItem,"xModelPart" + sIndex, GetLocalInt(oPC, CRAFT_COPY_MODEL + sIndex));
            DeleteLocalInt(oPC, CRAFT_COPY_MODEL + sIndex);
            nIndex++;
        }
        oItem = JsonToObject(jItem, GetLocation(oTarget), oTarget, TRUE);
        // Equip new item.
        AssignCommand(oTarget, ActionEquipItem (oItem, INVENTORY_SLOT_RIGHTHAND));
    }
    // Armor.
    else if (nSelected == 0)
    {
        // Paste per part colors if they exist.
        int nPart, nColor, nPartColor;
        string sPart, sColor;
        while(nPart <= 18)
        {
            sPart = IntToString(nPart);
            nColor = 0;
            while(nColor <= 5)
            {
                sColor = IntToString(nColor);
                nPartColor = GetLocalInt(oPC, CRAFT_COPY_PART_COLOR + sPart + sColor);
                if(nPartColor > 0)
                {
                    // Shift the number down by 1 since we can not use 0 in the variable!
                    nPartColor = nPartColor - 1;
                    if(GffGetFieldExists(jItem, "APart_" + sPart + "_Col_" + sColor, GFF_FIELD_TYPE_BYTE))
                    {
                        jItem = GffReplaceByte(jItem, "APart_" + sPart + "_Col_" + sColor, nPartColor);
                    }
                    else jItem = GffAddByte(jItem, "APart_" + sPart + "_Col_" + sColor, nPartColor);
                    DeleteLocalInt(oPC, "CRAFT_COPY_PART_COLOR" + sPart + sColor);
                }
                nColor++;
            }
            nPart++;
        }
        jItem = GffReplaceByte(jItem,"ArmorPart_Belt", GetLocalInt(oPC, "CRAFT_COPY_MODEL0"));
        jItem = GffReplaceByte(jItem,"ArmorPart_LBicep", GetLocalInt(oPC, "CRAFT_COPY_MODEL1"));
        jItem = GffReplaceByte(jItem,"ArmorPart_LFArm", GetLocalInt(oPC, "CRAFT_COPY_MODEL2"));
        jItem = GffReplaceByte(jItem,"ArmorPart_LFoot", GetLocalInt(oPC, "CRAFT_COPY_MODEL3"));
        jItem = GffReplaceByte(jItem,"ArmorPart_LHand", GetLocalInt(oPC, "CRAFT_COPY_MODEL4"));
        jItem = GffReplaceByte(jItem,"ArmorPart_LShin", GetLocalInt(oPC, "CRAFT_COPY_MODEL5"));
        jItem = GffReplaceByte(jItem,"ArmorPart_LShoul", GetLocalInt(oPC, "CRAFT_COPY_MODEL6"));
        jItem = GffReplaceByte(jItem,"ArmorPart_LThigh", GetLocalInt(oPC, "CRAFT_COPY_MODEL7"));
        jItem = GffReplaceByte(jItem,"ArmorPart_Neck", GetLocalInt(oPC, "CRAFT_COPY_MODEL8"));
        jItem = GffReplaceByte(jItem,"ArmorPart_Pelvis", GetLocalInt(oPC, "CRAFT_COPY_MODEL9"));
        jItem = GffReplaceByte(jItem,"ArmorPart_RBicep", GetLocalInt(oPC, "CRAFT_COPY_MODEL10"));
        jItem = GffReplaceByte(jItem,"ArmorPart_RFArm", GetLocalInt(oPC, "CRAFT_COPY_MODEL11"));
        jItem = GffReplaceByte(jItem,"ArmorPart_RFoot", GetLocalInt(oPC, "CRAFT_COPY_MODEL12"));
        jItem = GffReplaceByte(jItem,"ArmorPart_RHand", GetLocalInt(oPC, "CRAFT_COPY_MODEL13"));
        jItem = GffReplaceByte(jItem,"ArmorPart_RShin", GetLocalInt(oPC, "CRAFT_COPY_MODEL14"));
        jItem = GffReplaceByte(jItem,"ArmorPart_RShoul", GetLocalInt(oPC, "CRAFT_COPY_MODEL15"));
        jItem = GffReplaceByte(jItem,"ArmorPart_RThigh", GetLocalInt(oPC, "CRAFT_COPY_MODEL16"));
        jItem = GffReplaceByte(jItem,"ArmorPart_Robe", GetLocalInt(oPC, "CRAFT_COPY_MODEL17"));
        jItem = GffReplaceByte(jItem,"ArmorPart_Torso", GetLocalInt(oPC, "CRAFT_COPY_MODEL18"));
        jItem = GffReplaceWord(jItem,"xArmorPart_Belt", GetLocalInt(oPC, "CRAFT_COPY_MODEL0"));
        jItem = GffReplaceWord(jItem,"xArmorPart_LBice", GetLocalInt(oPC, "CRAFT_COPY_MODEL1"));
        jItem = GffReplaceWord(jItem,"xArmorPart_LFArm", GetLocalInt(oPC, "CRAFT_COPY_MODEL2"));
        jItem = GffReplaceWord(jItem,"xArmorPart_LFoot", GetLocalInt(oPC, "CRAFT_COPY_MODEL3"));
        jItem = GffReplaceWord(jItem,"xArmorPart_LHand", GetLocalInt(oPC, "CRAFT_COPY_MODEL4"));
        jItem = GffReplaceWord(jItem,"xArmorPart_LShin", GetLocalInt(oPC, "CRAFT_COPY_MODEL5"));
        jItem = GffReplaceWord(jItem,"xArmorPart_LShou", GetLocalInt(oPC, "CRAFT_COPY_MODEL6"));
        jItem = GffReplaceWord(jItem,"xArmorPart_LThig", GetLocalInt(oPC, "CRAFT_COPY_MODEL7"));
        jItem = GffReplaceWord(jItem,"xArmorPart_Neck", GetLocalInt(oPC, "CRAFT_COPY_MODEL8"));
        jItem = GffReplaceWord(jItem,"xArmorPart_Pelvi", GetLocalInt(oPC, "CRAFT_COPY_MODEL9"));
        jItem = GffReplaceWord(jItem,"xArmorPart_RBice", GetLocalInt(oPC, "CRAFT_COPY_MODEL10"));
        jItem = GffReplaceWord(jItem,"xArmorPart_RFArm", GetLocalInt(oPC, "CRAFT_COPY_MODEL11"));
        jItem = GffReplaceWord(jItem,"xArmorPart_RFoot", GetLocalInt(oPC, "CRAFT_COPY_MODEL12"));
        jItem = GffReplaceWord(jItem,"xArmorPart_RHand", GetLocalInt(oPC, "CRAFT_COPY_MODEL13"));
        jItem = GffReplaceWord(jItem,"xArmorPart_RShin", GetLocalInt(oPC, "CRAFT_COPY_MODEL14"));
        jItem = GffReplaceWord(jItem,"xArmorPart_RShou", GetLocalInt(oPC, "CRAFT_COPY_MODEL15"));
        jItem = GffReplaceWord(jItem,"xArmorPart_RThig", GetLocalInt(oPC, "CRAFT_COPY_MODEL16"));
        jItem = GffReplaceWord(jItem,"xArmorPart_Robe", GetLocalInt(oPC, "CRAFT_COPY_MODEL17"));
        jItem = GffReplaceWord(jItem,"xArmorPart_Torso", GetLocalInt(oPC, "CRAFT_COPY_MODEL18"));
        jItem = GffReplaceByte(jItem,"Cloth1Color", GetLocalInt(oPC, "CRAFT_COPY_COLOR0"));
        jItem = GffReplaceByte(jItem,"Cloth2Color", GetLocalInt(oPC, "CRAFT_COPY_COLOR1"));
        jItem = GffReplaceByte(jItem,"Leather1Color", GetLocalInt(oPC, "CRAFT_COPY_COLOR2"));
        jItem = GffReplaceByte(jItem,"Leather2Color", GetLocalInt(oPC, "CRAFT_COPY_COLOR3"));
        jItem = GffReplaceByte(jItem,"Metal1Color", GetLocalInt(oPC, "CRAFT_COPY_COLOR4"));
        jItem = GffReplaceByte(jItem,"Metal2Color", GetLocalInt(oPC, "CRAFT_COPY_COLOR5"));
        oItem = JsonToObject(jItem, GetLocation(oTarget), oTarget, TRUE);
        int nIndex;
        for(nIndex = 0; nIndex <= 18; nIndex++)
        {
            DeleteLocalInt(oPC, CRAFT_COPY_MODEL + IntToString(nIndex));
        }
        for(nIndex = 0; nIndex <= 5; nIndex++)
        {
            DeleteLocalInt(oPC, CRAFT_COPY_COLOR + IntToString(nIndex));
        }
        // Equip new item.
        AssignCommand (oTarget, ActionEquipItem (oItem, INVENTORY_SLOT_CHEST));
    }
    else if(ai_GetIsShield(oChestItem))
    {
        jItem = GffReplaceByte(jItem,"ModelPart1", GetLocalInt(oPC, "CRAFT_COPY_MODEL1"));
        jItem = GffReplaceWord(jItem,"xModelPart1", GetLocalInt(oPC, "CRAFT_COPY_MODEL1"));
        oItem = JsonToObject(jItem, GetLocation(oTarget), oTarget, TRUE);
        // Equip new item.
        AssignCommand(oTarget, ActionEquipItem (oItem, INVENTORY_SLOT_LEFTHAND));
    }
    else
    {
        //ai_Debug("pe_crafting", "389", JsonDump(ObjectToJson(oChestItem), 2));
        jItem = GffReplaceByte(jItem,"ModelPart1", GetLocalInt(oPC, "CRAFT_COPY_MODEL0"));
        jItem = GffReplaceWord(jItem,"xModelPart1", GetLocalInt(oPC, "CRAFT_COPY_MODEL0"));
        jItem = GffReplaceByte(jItem,"Cloth1Color", GetLocalInt(oPC, "CRAFT_COPY_COLOR0"));
        jItem = GffReplaceByte(jItem,"Cloth2Color", GetLocalInt(oPC, "CRAFT_COPY_COLOR1"));
        jItem = GffReplaceByte(jItem,"Leather1Color", GetLocalInt(oPC, "CRAFT_COPY_COLOR2"));
        jItem = GffReplaceByte(jItem,"Leather2Color", GetLocalInt(oPC, "CRAFT_COPY_COLOR3"));
        jItem = GffReplaceByte(jItem,"Metal1Color", GetLocalInt(oPC, "CRAFT_COPY_COLOR4"));
        jItem = GffReplaceByte(jItem,"Metal2Color", GetLocalInt(oPC, "CRAFT_COPY_COLOR5"));
        oItem = JsonToObject(jItem, GetLocation(oTarget), oTarget, TRUE);
        DeleteLocalInt(oPC, "CRAFT_COPY_MODEL0");
        int nIndex;
        for(nIndex = 0; nIndex <= 5; nIndex++)
        {
            DeleteLocalInt(oPC, CRAFT_COPY_COLOR + IntToString(nIndex));
        }
        // Equip new item.
        int nItemType = GetBaseItemType(oChestItem);
        if(nItemType == BASE_ITEM_CLOAK) AssignCommand(oTarget, ActionEquipItem (oItem, INVENTORY_SLOT_CLOAK));
        else if(nItemType == BASE_ITEM_HELMET) AssignCommand(oTarget, ActionEquipItem (oItem, INVENTORY_SLOT_HEAD));
    }
    // Send message that it has been copied.
    AssignCommand(oPC, ai_SendMessages (GetName (oItem) + " appearance has been changed!", AI_COLOR_GREEN, oPC));
    DestroyObject(oChestItem);
    return oItem;
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
    int nModelSelected = GetLocalInt (oPC, CRAFT_MODEL_SELECTION);
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
object ChangeItemsAppearance(object oPC, object oTarget, int nToken, object oItem, int nDirection)
{
    // Get the item we are changing.
    int nModel, nModelSelected;
    int nItemSelected = GetLocalInt(oPC, CRAFT_ITEM_SELECTION);
    string sModelName, sModelNumber;
    object oNewItem;
    // Weapons.
    if (ai_GetIsWeapon (oItem))
    {
        int nColor;
        string sColumn, sComponent;
        nModelSelected = GetLocalInt (oPC, CRAFT_MODEL_SELECTION);
        // Get the column so we can get the max model.
        if(nModelSelected == 0) { sColumn = "BottomModel"; sComponent = "_b_"; }
        else if(nModelSelected == 1) { sColumn = "MiddleModel"; sComponent = "_m_"; }
        else if(nModelSelected == 2) { sColumn = "TopModel"; sComponent = "_t_"; }
        sModelName = Get2DAString("baseitems", "ItemClass", GetBaseItemType(oItem)) + sComponent;
        // Get the model and color of the weapon model.
        if(nModel == 0) nModel = GetItemAppearance(oItem, ITEM_APPR_TYPE_WEAPON_MODEL, nModelSelected);
        if(nColor == 0) nColor = GetItemAppearance(oItem, ITEM_APPR_TYPE_WEAPON_COLOR, nModelSelected);
        // Get next/previous color/model.
        nColor += nDirection;
        int nModelNumber = (nModel * 10) + nColor;
        if(nModelNumber < 10) sModelNumber = "00" + IntToString(nModelNumber);
        else if(nModelNumber < 100) sModelNumber = "0" + IntToString(nModelNumber);
        else sModelNumber = IntToString(nModelNumber);
        ai_Debug("pe_crafting", "587", "sModel: " + sModelName + sModelNumber +
                 " nModel: " + IntToString(nModel) + " nColor: " + IntToString(nColor));
        while(ResManGetAliasFor(sModelName + sModelNumber, RESTYPE_MDL) == "")
        {
            // Get next/previous color/model.
            nColor += nDirection;
            if(nColor > 9)
            {
                nColor = 1;
                nModel += nDirection;
                if(nModel > 25) nModel = 1;
            }
            else if(nColor < 1)
            {
                nColor = 9;
                nModel += nDirection;
                if(nModel < 1) nModel = 25;
            }
            // Create the model name.
            nModelNumber = (nModel * 10) + nColor;
            if(nModelNumber < 100) sModelNumber = "0" + IntToString(nModelNumber);
            else sModelNumber = IntToString(nModelNumber);
            ai_Debug("pe_crafting", "610", "sModel: " + sModelName + sModelNumber +
                 " nModel: " + IntToString(nModel) + " nColor: " + IntToString(nColor));
        }
        json jItem = ObjectToJson(oItem, TRUE);
        ai_Debug("pe_crafting", "614", "ModelPart" + IntToString(nModelSelected + 1) +
                 " nModelNumber: " + IntToString(nModelNumber));
        jItem = GffReplaceByte(jItem, "ModelPart" + IntToString(nModelSelected + 1), nModelNumber);
        jItem = GffReplaceWord(jItem, "xModelPart" + IntToString(nModelSelected + 1), nModelNumber);
        oNewItem = JsonToObject(jItem, GetLocation(oTarget), oTarget, TRUE);
        DestroyObject(oItem);
        // Item selected 3 is the right hand, 4 is the left hand.
        if (nItemSelected == 3) AssignCommand(oTarget, ActionEquipItem(oNewItem, INVENTORY_SLOT_RIGHTHAND));
        else AssignCommand(oTarget, ActionEquipItem(oNewItem, INVENTORY_SLOT_LEFTHAND));
    }
    // Armor.
    else if (nItemSelected == 0)
    {
        // Create the model name.
        // Get the ModelType.
        int nAppearance = GetAppearanceType(oTarget);
        string sModelName = Get2DAString("appearance", "MODELTYPE", nAppearance);
        // Get gender.
        if(GetGender(oTarget) == GENDER_MALE) sModelName += "m";
        else sModelName += "f";
        // Get race.
        sModelName += Get2DAString("appearance", "RACE", nAppearance);
        // Get Phenotype.
        sModelName += IntToString(GetPhenoType(oTarget)) + "_";
        // Get the selected model.
        nModelSelected = GetArmorModelSelected(oPC);
        // Get if we are doing the left/right or linking both together.
        int nModelSide = GetLocalInt(oPC, CRAFT_MODEL_SPECIAL);
        // These models only have one side so make sure we are not linked.
        if (nModelSelected == ITEM_APPR_ARMOR_MODEL_NECK ||
            nModelSelected == ITEM_APPR_ARMOR_MODEL_TORSO ||
            nModelSelected == ITEM_APPR_ARMOR_MODEL_BELT ||
            nModelSelected == ITEM_APPR_ARMOR_MODEL_PELVIS ||
            nModelSelected == ITEM_APPR_ARMOR_MODEL_ROBE) nModelSide = 1;
        // If we are doing the left side then add one to get the left side.
        // Note: Right Thigh and Left Thigh are backwards so this fixes that!
        else if(nModelSide == 2)
        {
            if(nModelSelected == ITEM_APPR_ARMOR_MODEL_RTHIGH) nModelSelected--;
            else nModelSelected++;
        }
        nModel = GetItemAppearance(oItem, ITEM_APPR_TYPE_ARMOR_MODEL, nModelSelected);
        nModel += nDirection;
        if(nModel > 255) nModel = 0;
        else if(nModel < 0) nModel = 255;
        string sModelNumber;
        if(nModel < 10) sModelNumber = "00" + IntToString(nModel);
        else if(nModel < 100) sModelNumber = "0" + IntToString(nModel);
        else sModelNumber = IntToString(nModel);
        // Check for changes to the torso (base part of the armor linked to AC).
        if(nModelSelected == ITEM_APPR_ARMOR_MODEL_TORSO)
        {
            string sCurrentACBonus = Get2DAString("parts_chest", "ACBONUS", nModel);
            string sACBonus = Get2DAString ("parts_chest", "ACBONUS", nModel);
            sModelName += Get2DAString ("capart", "MDLNAME", nModelSelected);
            ai_Debug("pe_crafting", "654", "sModelName: " + sModelName + sModelNumber +
                     " nModel: " + IntToString(nModel) + " sCurrentACBonus: " + sCurrentACBonus + " sACBonus: " + sACBonus);
            while(ResManGetAliasFor(sModelName + sModelNumber, RESTYPE_MDL) == "" ||
                  sACBonus != sCurrentACBonus)
            {
                nModel += nDirection;
                if (nModel > 255) nModel = 0;
                else if (nModel < 0) nModel = 255;
                if(nModel < 10) sModelNumber = "00" + IntToString(nModel);
                else if(nModel < 100) sModelNumber = "0" + IntToString(nModel);
                else sModelNumber = IntToString(nModel);
                sACBonus = Get2DAString ("parts_chest", "ACBONUS", nModel);
                ai_Debug("pe_crafting", "666", "sModelName: " + sModelName + sModelNumber +
                         " nModel: " + IntToString(nModel) + " sACBonus: " + sACBonus);
            }
            // Change the model.
            oNewItem = CopyItemAndModify (oItem, ITEM_APPR_TYPE_ARMOR_MODEL, nModelSelected, nModel, TRUE);
            DestroyObject (oItem);
            AssignCommand (oTarget, ActionEquipItem (oNewItem, INVENTORY_SLOT_CHEST));
        }
        // Change all other parts of armor.
        else
        {
            sModelName += Get2DAString("capart", "MDLNAME", nModelSelected);
            ai_Debug("pe_crafting", "695", "sModelName: " + sModelName + sModelNumber +
                     " nModel: " + IntToString(nModel));
            while(ResManGetAliasFor(sModelName + sModelNumber, RESTYPE_MDL) == "")
            {
                nModel += nDirection;
                if (nModel > 255) nModel = 0;
                else if (nModel < 0) nModel = 255;
                if(nModel < 10) sModelNumber = "00" + IntToString(nModel);
                else if(nModel < 100) sModelNumber = "0" + IntToString(nModel);
                else sModelNumber = IntToString(nModel);
                ai_Debug("pe_crafting", "705", "sModelName: " + sModelName + sModelNumber +
                         " nModel: " + IntToString(nModel));
            }
            // We set which model is selected above.
            oNewItem = CopyItemAndModify (oItem, ITEM_APPR_TYPE_ARMOR_MODEL, nModelSelected, nModel, TRUE);
            DestroyObject (oItem);
            // If linked then change the left side too.
            if(nModelSide == 0)
            {
                // Note: Right Thigh and Left Thigh are backwards so this fixes that!
                if (nModelSelected == ITEM_APPR_ARMOR_MODEL_RTHIGH) nModelSelected--;
                else nModelSelected++;
                oItem = CopyItemAndModify(oNewItem, ITEM_APPR_TYPE_ARMOR_MODEL, nModelSelected, nModel, TRUE);
                DestroyObject(oNewItem);
                AssignCommand(oTarget, ActionEquipItem(oItem, INVENTORY_SLOT_CHEST));
            }
            else AssignCommand(oTarget, ActionEquipItem(oNewItem, INVENTORY_SLOT_CHEST));
        }
    }
    /*/ All other items.
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
    }  */
    NuiSetBind(oPC, nToken, "txt_model_name", JsonString(sModelName + sModelNumber));
    SetLocalString(oPC, CRAFT_MODEL, sModelName + sModelNumber);
    return oNewItem;
}
object RandomizeItemsCraftAppearance (object oPlayer, object oTarget, int nToken, object oItem)
{
    // Get the item we are changing.
    int nModelSelected, nModel, nMaxModel, nColor, nMaxColor;
    int nItemSelected = GetLocalInt (oPlayer, "0_CRAFT_ITEM_SELECTION");
    int iBaseItemType, iType, iIndex, iDie, iMod, iRoll, iColor, iRtop, iRmid, iRbottom;
    int iColorT, iColorM, iColorB;
    object oItem1, oItem2, oItem3, oItem4, oItem5, oItem6, oItem7, oItemFinal, oItemDone;
    object oNewItem;
    SetLocalInt (oItem, "0_EQUIP_LOCKED", FALSE);
    if (ai_GetIsWeapon (oItem))
    {
        int iWModuleBottom, iWModuleMiddle, iWModuleTop;
        iWModuleBottom = 9;
        iWModuleMiddle = 9;
        iWModuleTop = 9;
        iColor = 4;
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
        if (nItemSelected == 3) AssignCommand (oTarget, ActionEquipItem (oItemFinal, INVENTORY_SLOT_RIGHTHAND));
        else if (nItemSelected == 4) AssignCommand (oTarget, ActionEquipItem (oItemFinal, INVENTORY_SLOT_LEFTHAND));
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
// Gets the colorId from a image of the color pallet.
// Thanks Zunath for the base code.
int GetColorPalletId (object oPC)
{
    float fScale = IntToFloat (GetPlayerDeviceProperty (oPC, PLAYER_DEVICE_PROPERTY_GUI_SCALE)) / 100.0f;
    json jPayload = NuiGetEventPayload ();
    json jMousePosition = JsonObjectGet (jPayload, "mouse_pos");
    json jX = JsonObjectGet (jMousePosition, "x");
    json jY = JsonObjectGet (jMousePosition, "y");
    float fX = StringToFloat (JsonDump (jX));
    float fY = StringToFloat (JsonDump (jY));
    float fCellSize = 16.0f * fScale;
    int nCellX = FloatToInt (fX / fCellSize);
    int nCellY = FloatToInt (fY / fCellSize);
    if (nCellX < 0) nCellX = 0;
    else if (nCellX > 16) nCellX = 16;
    if (nCellY < 0) nCellY = 0;
    else if (nCellY > 11) nCellY = 11;
    return nCellX + nCellY * 16;
}


// Locks/Unlocks specific buttons when an item has been changed.
void LockItemInCraftingWindow (object oPC, object oItem, int nToken)
{
    NuiSetBind(oPC, nToken, "btn_copy", JsonBool(FALSE));
    NuiSetBind(oPC, nToken, "btn_copy_event", JsonBool(FALSE));
    SetLocalInt(oPC, CRAFT_COPY_ITEM, FALSE);
    NuiSetBind(oPC, nToken, "btn_prev_target_event", JsonBool(FALSE));
    NuiSetBind(oPC, nToken, "btn_next_target_event", JsonBool(FALSE));
    NuiSetBind(oPC, nToken, "item_combo_event", JsonBool(FALSE));
    NuiSetBind(oPC, nToken, "btn_cancel_label", JsonString("Cancel"));
    NuiSetBind(oPC, nToken, "btn_save_event", JsonBool(TRUE));
}

// Locks/Unlocks specific buttons when an item has been cleared.
void ClearItemInCraftingWindow (object oPC, object oItem, int nToken)
{
    NuiSetBind (oPC, nToken, "btn_copy_event", JsonBool (TRUE));
    NuiSetBind (oPC, nToken, "btn_paste_event", JsonBool (FALSE));
    NuiSetBind (oPC, nToken, "btn_save_event", JsonBool (FALSE));
    NuiSetBind (oPC, nToken, "item_combo_event", JsonBool (TRUE));
    NuiSetBind(oPC, nToken, "btn_prev_target_event", JsonBool(TRUE));
    NuiSetBind(oPC, nToken, "btn_next_target_event", JsonBool(TRUE));
    NuiSetBind (oPC, nToken, "btn_cancel_label", JsonString ("Exit"));
}
void DoSpecialButton (object oPC, object oItem, int nToken)
{
     int nItemSelected = GetLocalInt (oPC, CRAFT_ITEM_SELECTION);
     int nSpecial = GetLocalInt (oPC, CRAFT_MODEL_SPECIAL) + 1;
     // Change button for armor (Left/Right/Linked).
     if (nItemSelected == 0)
     {
         if (nSpecial > 2) nSpecial = 0;
         if (nSpecial == 0) NuiSetBind (oPC, nToken, "btn_special_label", JsonString ("Left/Right Linked"));
         else if (nSpecial == 1) NuiSetBind (oPC, nToken, "btn_special_label", JsonString ("Right Model"));
         else NuiSetBind (oPC, nToken, "btn_special_label", JsonString ("Left Model"));
         SetLocalInt (oPC, CRAFT_MODEL_SPECIAL, nSpecial);
         //NuiSetBind (oPC, nToken, "btn_special_event", JsonBool (TRUE));
    }
    // Change button for cloak/helmets.
    else if (nItemSelected == 1 || nItemSelected == 2)
    {
        // Get the item to be visible/hidden.
        // Get the items state and set.
        int nHidden = GetHiddenWhenEquipped (oItem);
        if (nHidden)
        {
            SetLocalInt (oPC, CRAFT_MODEL_SPECIAL, 3);
            NuiSetBind (oPC, nToken, "btn_special_label", JsonString ("Model Visible"));
            SetHiddenWhenEquipped (oItem, FALSE);
        }
        else
        {
            SetLocalInt (oPC, CRAFT_MODEL_SPECIAL, 4);
            NuiSetBind (oPC, nToken, "btn_special_label", JsonString ("Model Hidden"));
            SetHiddenWhenEquipped (oItem, TRUE);
        }
        LockItemInCraftingWindow (oPC, oItem, nToken);
        //NuiSetBind (oPC, nToken, "btn_special_event", JsonBool (TRUE));
    }
}

// Saves the crafted item for the player removing the original.
void SaveCraftedItem (object oPC, object oTarget, int nToken)
{
    int nItemSelected = GetLocalInt (oPC, CRAFT_ITEM_SELECTION);
    object oItem = GetSelectedItem (oTarget, nItemSelected);
    ClearItemInCraftingWindow (oPC, oItem, nToken);
    DestroyObject (GetLocalObject (oPC, CRAFT_ORIGINAL_ITEM));
    DeleteLocalObject (oPC, CRAFT_ORIGINAL_ITEM);
}
int CanCraftItem(object oPC, object oItem, int nToken, int bPasteCheck = FALSE)
{
    if(oItem == OBJECT_INVALID)
    {
         ai_SendMessages("You must have an item equiped!", AI_COLOR_RED, oPC);
         return FALSE;
    }
    // Plot items cannot be changed.
    if(GetPlotFlag(oItem))
    {
         ai_SendMessages(GetName(oItem) + "is a plot item and its appearance cannot be changed!", AI_COLOR_RED, oPC);
         return FALSE;
    }
    // Cannot change temorary enchanted items.
    if(CheckForTemporaryItemProperty(oItem))
    {
        ai_SendMessages(GetName(oItem) + " cannot be altered while it has a temporary enchantment.", AI_COLOR_RED, oPC);
        return FALSE;
    }
    // Do special paste checks.
    if (bPasteCheck)
    {
        int nOldItemType = GetLocalInt (oPC, CRAFT_COPY_ITEM_TYPE);
        int nNewItemType = GetBaseItemType(oItem);
        if(nNewItemType == BASE_ITEM_ARMOR)
        {
            if(GetLocalInt (oPC, CRAFT_ARMOR_AC) != ai_GetArmorBonus(oItem))
            {
                ai_SendMessages("The armor you are trying to paste to is not the same type as the copy!", AI_COLOR_RED, oPC);
                return FALSE;
            }
        }
        else if(nOldItemType != nNewItemType)
        {
            string sOldBaseItem = GetStringByStrRef(StringToInt(Get2DAString ("baseitems", "Name", nOldItemType)));
            string sNewBaseItem = GetStringByStrRef(StringToInt(Get2DAString ("baseitems", "Name", nNewItemType)));
            ai_SendMessages("You copied a " + sOldBaseItem + " and are trying to paste to a " + sNewBaseItem + "!", AI_COLOR_RED, oPC);
            return FALSE;
        }
    }
    if (GetLocalObject(oPC, CRAFT_ORIGINAL_ITEM) == OBJECT_INVALID)
    {
        object oBuildContainer = GetObjectByTag(CRAFT_CONTAINER);
        if(!GetIsObjectValid(oBuildContainer))
        {
            vector vPosition = GetPositionFromLocation(GetLocation(oPC));
            vPosition.z = vPosition.z -2.0;
            location lLocation = Location(GetArea(oPC), vPosition, 0.0);
            oBuildContainer = CreateObject(OBJECT_TYPE_PLACEABLE, CRAFT_TEMPLATE, lLocation, FALSE, CRAFT_CONTAINER);
            //SetObjectVisualTransform(oBuildContainer, OBJECT_VISUAL_TRANSFORM_TRANSLATE_Z, -5.0);
       }
        object oBackup = CopyItem(oItem, oBuildContainer, TRUE);
        // Save the original item to the PC.
        SetLocalObject(oPC, CRAFT_ORIGINAL_ITEM, oBackup);
    }
    return TRUE;
}
// Remove Effect of type specified from oCreature;
// sEffectTag is the tag of the effect to remove.
// Base tags are Feat, Class, Racial.
void RemoveTagedEffects (object oCreature, string sEffectTag)
{
   //Search for the effect.
   //Debug ("0i_effects", "578", "RemoveTagedEffects: " + sEffectTag);
   effect eEffect = GetFirstEffect (oCreature);
   while (GetIsEffectValid (eEffect))
   {
      //Debug ("0i_effects", "582", "Effect Tag: " + GetEffectTag (eEffect));
      if (GetEffectTag (eEffect) == sEffectTag) RemoveEffect (oCreature, eEffect);
      eEffect = GetNextEffect (oCreature);
   }
}
// Returns TRUE/FALSE if item has temporary item property.
int CheckForTemporaryItemProperty (object oItem)
{
    itemproperty ipProperty;
    ipProperty = GetFirstItemProperty (oItem);
    while (GetIsItemPropertyValid (ipProperty))
    {
        // Check to see if the item is temporary enchanted.
        if (GetItemPropertyDurationType (ipProperty) == DURATION_TYPE_TEMPORARY) return TRUE;
        ipProperty = GetNextItemProperty (oItem);
    }
    return FALSE;
}

