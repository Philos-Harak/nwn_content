/*//////////////////////////////////////////////////////////////////////////////
// Script Name: pe_crafting
////////////////////////////////////////////////////////////////////////////////
 Used with ai_crafting to run the crafting plugin for
 Philos Single Player Enhancements.
*///////////////////////////////////////////////////////////////////////////////
#include "0i_nui"
#include "nw_inc_gff"
#include "0i_main"
#include "0i_items"
// Maximum model number for all items except weapons.
const int CRAFT_MAX_MODEL_NUMBER = 99;
// Maximum model number for weapons. Note this will be the 100s and 10s places.
// The color number uses the ones place. Thus 25 is actually 250.
const int CRAFT_MAX_WEAPON_MODEL_NUMBER = 99;
const string CRAFT_JSON = "CRAFT_JSON";
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
const string CRAFT_LEFT_PART_COLOR = "CRAFT_LEFT_PART_COLOR";
const string CRAFT_ALL_COLOR = "CRAFT_ALL_COLOR";
const string CRAFT_RIGHT_PART_COLOR = "CRAFT_RIGHT_PART_COLOR";
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
object ChangeItemsAppearance(object oPC, object oTarget, int nToken, object oItem, int nDirection, string sPart);
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
// Saves the crafted item for the player removing the original.
void SaveCraftedItem(object oPC, object oTarget, int nToken);
// Remove Effect of type specified from oCreature;
// sEffectTag is the tag of the effect to remove.
// Feat, Class, Racial.
void RemoveTagedEffects(object oCreature, string sEffectTag);
// Returns TRUE/FALSE if item has temporary item property.
int CheckForTemporaryItemProperty(object oItem);
// Updates the model number text in the NUI menu.
void SetModelNumberText(object oPC, int nToken);
int GetColorIDChange(object oItem, int nType, int nIndex, int nChange)
{
    int nColorId = GetItemAppearance(oItem, nType, nIndex) + nChange;
    if(nColorId > 175) return 0;
    if(nColorId < 0) return 175;
    return nColorId;
}
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
    json jCraft = GetLocalJson(oPC, CRAFT_JSON);
    //SendMessageToPC(oPC, "0e_crafting, 95, sElem: " + sElem + " sEvent: " + sEvent);
    //**************************************************************************
    // Watch to see if the window moves and save.
    if(sElem == "window_geometry" && sEvent == "watch")
    {
        if(!GetLocalInt (oPC, AI_NO_NUI_SAVE))
        {
            json jCraft = GetLocalJson(oPC, CRAFT_JSON);
            if(JsonGetType(jCraft) == JSON_TYPE_NULL) jCraft = JsonObject();
            // Get the height, width, x, and y of the window.
            json jGeometry = NuiGetBind(oPC, nToken, "window_geometry");
            JsonObjectSetInplace(jCraft, "Geometry", jGeometry);
            SetLocalJson(oPC, CRAFT_JSON, jCraft);
        }
        return;
    }
    //**************************************************************************
    // Crafting window events.
    if(sWndId == "plcraftwin")
    {
        object oTarget = oPC;
        // Get the item we are crafting.
        int nItemSelected = JsonGetInt(JsonObjectGet(jCraft, CRAFT_ITEM_SELECTION));
        object oItem = GetSelectedItem(oTarget, nItemSelected);
        // Changing the name needs to be before the cooldown.
        if(sEvent == "watch" && sElem == "txt_item_name")
        {
            string sName = JsonGetString(NuiGetBind(oPC, nToken, "txt_item_name"));
            SetName(oItem, sName);
            return;
        }
        // Delay crafting so it has time to equip and unequip as well as remove.
        if(GetLocalInt(oPC, CRAFT_COOL_DOWN)) return;
        SetLocalInt(oPC, CRAFT_COOL_DOWN, TRUE);
        DelayCommand(0.25f, DeleteLocalInt(oPC, CRAFT_COOL_DOWN));
        // They have selected a color.
        if(sElem == "color_pallet" || sElem == "txt_color_number")
        {
            int nColorId, nChange;
            if(sEvent == "mousedown")
            {
                // Get the color they selected from the color pallet cell.
                nColorId = GetColorPalletId(oPC);
            }
            else if(sEvent == "mousescroll")
            {
                float nMouseScroll = JsonGetFloat(JsonObjectGet(JsonObjectGet(NuiGetEventPayload(), "mouse_scroll"), "y"));
                nChange = FloatToInt(nMouseScroll);
            }
            else if(sEvent == "watch")
            {
                nColorId = StringToInt(JsonGetString(NuiGetBind(oPC, nToken, "txt_color_number")));
            }
            if(ai_GetIsWeapon(oItem) || ai_GetIsShield(oItem))
            {
                ai_SendMessages("Weapons and shields don't use the color Pallet!", AI_COLOR_RED, oPC);
                return;
            }
            if(!CanCraftItem(oPC, oItem, nToken)) return;
            int nMaterialSelected = JsonGetInt(JsonObjectGet(jCraft, CRAFT_MATERIAL_SELECTION));
            object oNewItem;
            int nBaseItemType = GetBaseItemType(oItem);
            int nAllColor = JsonGetInt(JsonObjectGet(jCraft, CRAFT_ALL_COLOR));
            if(!nAllColor && nBaseItemType == BASE_ITEM_ARMOR)
            {
                int nIndex;
                int nModelSelected = GetArmorModelSelected(oPC);
                int nLeftColor = JsonGetInt(JsonObjectGet(jCraft, CRAFT_LEFT_PART_COLOR));
                int nRightColor = JsonGetInt(JsonObjectGet(jCraft, CRAFT_RIGHT_PART_COLOR));
                if(nModelSelected == ITEM_APPR_ARMOR_MODEL_NECK ||
                   nModelSelected == ITEM_APPR_ARMOR_MODEL_TORSO ||
                   nModelSelected == ITEM_APPR_ARMOR_MODEL_BELT ||
                   nModelSelected == ITEM_APPR_ARMOR_MODEL_PELVIS ||
                   nModelSelected == ITEM_APPR_ARMOR_MODEL_ROBE)
                {
                    nIndex = ITEM_APPR_ARMOR_NUM_COLORS + (nModelSelected * ITEM_APPR_ARMOR_NUM_COLORS) + nMaterialSelected;
                    if(nChange) nColorId = GetColorIDChange(oItem, ITEM_APPR_TYPE_ARMOR_COLOR, nIndex, nChange);
                    NuiSetBind(oPC, nToken, "txt_color_number", JsonString(IntToString(nColorId)));
                    oNewItem = CopyItemAndModify(oItem, ITEM_APPR_TYPE_ARMOR_COLOR, nIndex, nColorId, TRUE);
                    DestroyObject(oItem);
                }
                else
                {
                    if(nRightColor)
                    {
                        // Color Right side.
                        nIndex = ITEM_APPR_ARMOR_NUM_COLORS + (nModelSelected * ITEM_APPR_ARMOR_NUM_COLORS) + nMaterialSelected;
                        if(nChange) nColorId = GetColorIDChange(oItem, ITEM_APPR_TYPE_ARMOR_COLOR, nIndex, nChange);
                        NuiSetBind(oPC, nToken, "txt_color_r", JsonString(IntToString(nColorId)));
                        oNewItem = CopyItemAndModify(oItem, ITEM_APPR_TYPE_ARMOR_COLOR, nIndex, nColorId, TRUE);
                        DestroyObject(oItem);
                        if(nLeftColor)
                        {
                            // If we are doing the left side then add one to get the left side.
                            // Note: Right Thigh and Left Thigh are backwards so this fixes that!
                            if (nModelSelected == ITEM_APPR_ARMOR_MODEL_RTHIGH) nModelSelected = nModelSelected - 1;
                            else nModelSelected = nModelSelected + 1;
                            nIndex = ITEM_APPR_ARMOR_NUM_COLORS + (nModelSelected * ITEM_APPR_ARMOR_NUM_COLORS) + nMaterialSelected;
                            if(nChange) nColorId = GetColorIDChange(oNewItem, ITEM_APPR_TYPE_ARMOR_COLOR, nIndex, nChange);
                            NuiSetBind(oPC, nToken, "txt_color_l", JsonString(IntToString(nColorId)));
                            oItem = CopyItemAndModify(oNewItem, ITEM_APPR_TYPE_ARMOR_COLOR, nIndex, nColorId, TRUE);
                            DestroyObject(oNewItem);
                            oNewItem = oItem;
                        }
                    }
                    if(nLeftColor)
                    {
                        // If we are doing the left side then add one to get the left side.
                        // Note: Right Thigh and Left Thigh are backwards so this fixes that!
                        if (nModelSelected == ITEM_APPR_ARMOR_MODEL_RTHIGH) nModelSelected = nModelSelected - 1;
                        else nModelSelected = nModelSelected + 1;
                        nIndex = ITEM_APPR_ARMOR_NUM_COLORS + (nModelSelected * ITEM_APPR_ARMOR_NUM_COLORS) + nMaterialSelected;
                        if(nChange) nColorId = GetColorIDChange(oItem, ITEM_APPR_TYPE_ARMOR_COLOR, nIndex, nChange);
                        NuiSetBind(oPC, nToken, "txt_color_l", JsonString(IntToString(nColorId)));
                        oNewItem = CopyItemAndModify(oItem, ITEM_APPR_TYPE_ARMOR_COLOR, nIndex, nColorId, TRUE);
                        DestroyObject(oItem);
                    }
                }
            }
            else
            {
                if(nChange) nColorId = GetColorIDChange(oItem, ITEM_APPR_TYPE_ARMOR_COLOR, nMaterialSelected, nChange);
                NuiSetBind(oPC, nToken, "txt_color_a", JsonString(IntToString(nColorId)));
                oNewItem = CopyItemAndModify(oItem, ITEM_APPR_TYPE_ARMOR_COLOR, nMaterialSelected, nColorId, TRUE);
                DestroyObject(oItem);
            }
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
                int nSelected = JsonGetInt(NuiGetBind (oPC, nToken, sElem));
                JsonObjectSetInplace(jCraft, CRAFT_ITEM_SELECTION, JsonInt(nSelected));
                // Set button for cloak and helms.
                if(nSelected == 1 || nSelected == 2)
                {
                    int nHidden = GetHiddenWhenEquipped(oItem);
                    if(nHidden) JsonObjectSetInplace(jCraft, CRAFT_MODEL_SELECTION, JsonInt(1));
                    else JsonObjectSetInplace(jCraft, CRAFT_MODEL_SELECTION, JsonInt(0));
                }
                else JsonObjectSetInplace(jCraft, CRAFT_MODEL_SELECTION, JsonInt(0));
                NuiDestroy(oPC, nToken);
                ExecuteScript("pi_crafting", oPC);
            }
            // They have selected a part to change.
            else if(sElem == "model_combo_selected")
            {
                int nSelected = JsonGetInt(NuiGetBind(oPC, nToken, sElem));
                JsonObjectSetInplace(jCraft, CRAFT_MODEL_SELECTION, JsonInt(nSelected));
                SetModelNumberText(oPC, nToken);
            }
            // They have changed the material (color item) for the item.
            else if(sElem == "material_combo_selected")
            {
                int nSelected = JsonGetInt(NuiGetBind(oPC, nToken, sElem));
                JsonObjectSetInplace(jCraft, CRAFT_MATERIAL_SELECTION, JsonInt(nSelected));
                // Change the pallet for the correct material.
                string sColorPallet;
                if(nSelected >= 0 && nSelected < 4)
                {
                    sColorPallet = "gui_pal_tattoo";
                    NuiSetBind(oPC, nToken, "armor_block_1", JsonBool(FALSE));
                    NuiSetBind(oPC, nToken, "armor_block_2", JsonBool(FALSE));
                }
                else
                {
                    sColorPallet = "armor_pallet";
                    if(ResManGetAliasFor(sColorPallet, RESTYPE_TGA) == "")
                    {
                        sColorPallet = "gui_pal_tattoo";
                        NuiSetBind(oPC, nToken, "armor_block_1", JsonBool(TRUE));
                    }
                }
                NuiSetBind(oPC, nToken, "color_pallet_image", JsonString (sColorPallet));
                SetLocalString(oPC, CRAFT_COLOR_PALLET, sColorPallet);
            }
        }
        else if(sEvent == "click")
        {
            // Random button to change items looks randomly.
            if(sElem == "btn_rand")
            {
                if(CanCraftItem(oPC, oItem, nToken))
                {
                    oItem = RandomizeItemsCraftAppearance(oPC, oTarget, nToken, oItem);
                    LockItemInCraftingWindow(oPC, oItem, nToken);
                }
            }
            // Get the previous model of the selected item.
            else if(GetStringLeft(sElem, 9) == "btn_prev_")
            {
                if(CanCraftItem(oPC, oItem, nToken))
                {
                    oItem = ChangeItemsAppearance(oPC, oTarget, nToken, oItem, -1, GetStringRight(sElem, 1));
                    LockItemInCraftingWindow(oPC, oItem, nToken);
                }
            }
            // Get the next model of the selected item.
            else if(GetStringLeft(sElem, 9) == "btn_next_")
            {
                if(CanCraftItem(oPC, oItem, nToken))
                {
                    oItem = ChangeItemsAppearance(oPC, oTarget, nToken, oItem, 1, GetStringRight(sElem, 1));
                    LockItemInCraftingWindow(oPC, oItem, nToken);
                }
            }
            // Save any changes made to the selected item.
            else if(sElem == "btn_save")
            {
                SaveCraftedItem(oPC, oTarget, nToken);
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
            else if(sElem == "btn_left_part_color")
            {
                int nBool = !JsonGetInt(JsonObjectGet(jCraft, CRAFT_LEFT_PART_COLOR));
                JsonObjectSetInplace(jCraft, CRAFT_LEFT_PART_COLOR, JsonInt(nBool));
                NuiSetBind(oPC, nToken, "btn_left_part_color", JsonBool(nBool));
                JsonObjectSetInplace(jCraft, CRAFT_ALL_COLOR, JsonInt(FALSE));
                NuiSetBind(oPC, nToken, "btn_all_color", JsonBool(FALSE));
                NuiSetBind(oPC, nToken, "txt_color_l_event", JsonBool(TRUE));
                NuiSetBind(oPC, nToken, "txt_color_1", JsonString("44"));
                NuiSetBind(oPC, nToken, "txt_color_a", JsonString(""));
                NuiSetBind(oPC, nToken, "txt_color_a_event", JsonBool(FALSE));
            }
            else if(sElem == "btn_all_color")
            {
                int nBool = !JsonGetInt(JsonObjectGet(jCraft, CRAFT_ALL_COLOR));
                JsonObjectSetInplace(jCraft, CRAFT_ALL_COLOR, JsonInt(nBool));
                NuiSetBind(oPC, nToken, "btn_all_color", JsonBool(nBool));
                JsonObjectSetInplace(jCraft, CRAFT_LEFT_PART_COLOR, JsonInt(FALSE));
                NuiSetBind(oPC, nToken, "btn_left_part_color", JsonBool(FALSE));
                JsonObjectSetInplace(jCraft, CRAFT_RIGHT_PART_COLOR, JsonInt(FALSE));
                NuiSetBind(oPC, nToken, "btn_right_part_color", JsonBool(FALSE));
                NuiSetBind(oPC, nToken, "txt_color_l", JsonString(""));
                NuiSetBind(oPC, nToken, "txt_color_l_event", JsonBool(FALSE));
                NuiSetBind(oPC, nToken, "txt_color_a_event", JsonBool(TRUE));
                NuiSetBind(oPC, nToken, "txt_color_a", JsonString("44"));
                NuiSetBind(oPC, nToken, "txt_color_r_event", JsonBool(FALSE));
                NuiSetBind(oPC, nToken, "txt_color_r", JsonString(""));
            }
            else if(sElem == "btn_right_part_color")
            {
                int nBool = !JsonGetInt(JsonObjectGet(jCraft, CRAFT_RIGHT_PART_COLOR));
                JsonObjectSetInplace(jCraft, CRAFT_RIGHT_PART_COLOR, JsonInt(nBool));
                NuiSetBind(oPC, nToken, "btn_right_part_color", JsonBool (nBool));
                JsonObjectSetInplace(jCraft, CRAFT_ALL_COLOR, JsonInt(FALSE));
                NuiSetBind(oPC, nToken, "btn_all_color", JsonBool (FALSE));
                NuiSetBind(oPC, nToken, "txt_color_r_event", JsonBool(TRUE));
                NuiSetBind(oPC, nToken, "txt_color_r", JsonString("44"));
                NuiSetBind(oPC, nToken, "txt_color_a", JsonString(""));
                NuiSetBind(oPC, nToken, "txt_color_a_event", JsonBool(FALSE));
            }
            // Allows saving the item as a UTC!
            else if(sElem == "btn_save_template")
            {
                json jItem = ObjectToJson(oItem, TRUE);
                string sResRef = JsonGetString(NuiGetBind(oPC, nToken, "txt_item_resref"));
                sResRef = ai_RemoveIllegalCharacters(sResRef);
                if(sResRef == "") ai_SendMessages(GetName(oItem) + " has not been saved! ResRef does not have a value.", AI_COLOR_RED, oPC);
                else
                {
                    JsonToTemplate(jItem, sResRef, RESTYPE_UTC);
                    ai_SendMessages(GetName(oItem) + " has been saved as " + sResRef + ".utc in your Neverwinter Nights Temp directory.", AI_COLOR_GREEN, oPC);
                }
            }
        }
    }
    SetLocalJson(oPC, CRAFT_JSON, jCraft);
}
/*void CopyCraftingItem(object oPC, object oItem)
{
    //ai_Debug("pe_crafting", "295", JsonDump(ObjectToJson(oItem), 2));
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
} */
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
    json jCraft = GetLocalJson(oPC, CRAFT_JSON);
    int nModelSelected = JsonGetInt(JsonObjectGet(jCraft, CRAFT_MODEL_SELECTION));
    if(nModelSelected == 0) return ITEM_APPR_ARMOR_MODEL_NECK;
    if(nModelSelected == 1) return ITEM_APPR_ARMOR_MODEL_RSHOULDER;
    if(nModelSelected == 2) return ITEM_APPR_ARMOR_MODEL_RBICEP;
    if(nModelSelected == 3) return ITEM_APPR_ARMOR_MODEL_RFOREARM;
    if(nModelSelected == 4) return ITEM_APPR_ARMOR_MODEL_RHAND;
    if(nModelSelected == 5) return ITEM_APPR_ARMOR_MODEL_TORSO;
    if(nModelSelected == 6) return ITEM_APPR_ARMOR_MODEL_BELT;
    if(nModelSelected == 7) return ITEM_APPR_ARMOR_MODEL_PELVIS;
    if(nModelSelected == 8) return ITEM_APPR_ARMOR_MODEL_RTHIGH;
    if(nModelSelected == 9) return ITEM_APPR_ARMOR_MODEL_RSHIN;
    if(nModelSelected == 10) return ITEM_APPR_ARMOR_MODEL_RFOOT;
    return ITEM_APPR_ARMOR_MODEL_ROBE;
}
object ChangeItemsAppearance(object oPC, object oTarget, int nToken, object oItem, int nDirection, string sPart)
{
    json jCraft = GetLocalJson(oPC, CRAFT_JSON);
    // Get the item we are changing.
    int nModelSelected;
    int nItemSelected = JsonGetInt(JsonObjectGet(jCraft, CRAFT_ITEM_SELECTION));
    string sModelName, sModelNumber;
    object oNewItem;
    // Weapons.
    if(ai_GetIsWeapon (oItem))
    {
        if(sPart == "t") nModelSelected = 2;
        else if(sPart == "m") nModelSelected = 1;
        else if(sPart == "b") nModelSelected = 0;
        sModelName = Get2DAString("baseitems", "ItemClass", GetBaseItemType(oItem)) + "_" + sPart + "_";
        // Get the model and color of the weapon.
        int nModel = GetItemAppearance(oItem, ITEM_APPR_TYPE_WEAPON_MODEL, nModelSelected);
        int nColor = GetItemAppearance(oItem, ITEM_APPR_TYPE_WEAPON_COLOR, nModelSelected);
        // Get next/previous color/model.
        nColor += nDirection;
        if(nColor > 9)
        {
            nColor = 1;
            nModel += nDirection;
            if(nModel > CRAFT_MAX_WEAPON_MODEL_NUMBER) nModel = 1;
        }
        else if(nColor < 1)
        {
            nColor = 9;
            nModel += nDirection;
            if(nModel < 1) nModel = CRAFT_MAX_WEAPON_MODEL_NUMBER;
        }
        int nModelNumber = (nModel * 10) + nColor;
        if(nModelNumber < 10) sModelNumber = "00" + IntToString(nModelNumber);
        else if(nModelNumber < 100) sModelNumber = "0" + IntToString(nModelNumber);
        else sModelNumber = IntToString(nModelNumber);
        //ai_Debug("pe_crafting", "587", "sModel: " + sModelName + sModelNumber +
        //         " nModel: " + IntToString(nModel) + " nColor: " + IntToString(nColor));
        while(ResManGetAliasFor(sModelName + sModelNumber, RESTYPE_MDL) == "")
        {
            // Get next/previous color/model.
            nColor += nDirection;
            if(nColor > 9)
            {
                nColor = 1;
                nModel += nDirection;
                if(nModel > CRAFT_MAX_WEAPON_MODEL_NUMBER) nModel = 1;
            }
            else if(nColor < 1)
            {
                nColor = 9;
                nModel += nDirection;
                if(nModel < 1) nModel = CRAFT_MAX_WEAPON_MODEL_NUMBER;
            }
            // Create the model name.
            nModelNumber = (nModel * 10) + nColor;
            if(nModelNumber < 100) sModelNumber = "0" + IntToString(nModelNumber);
            else sModelNumber = IntToString(nModelNumber);
            //ai_Debug("pe_crafting", "610", "sModelPart: " + sModelName + sModelNumber +
            //     " nModel: " + IntToString(nModel) + " nColorPart: " + IntToString(nColor));
        }
        json jItem = ObjectToJson(oItem, TRUE);
        //ai_Debug("pe_crafting", "614", "ModelPart" + IntToString(nModelSelected + 1) +
        //         " nModelNumber: " + IntToString(nModelNumber));
        jItem = GffReplaceByte(jItem, "ModelPart" + IntToString(nModelSelected + 1), nModelNumber);
        jItem = GffReplaceWord(jItem, "xModelPart" + IntToString(nModelSelected + 1), nModelNumber);
        oNewItem = JsonToObject(jItem, GetLocation(oTarget), oTarget, TRUE);
        DestroyObject(oItem);
        // Item selected 3 is the right hand, 4 is the left hand.
        if (nItemSelected == 3) AssignCommand(oTarget, ActionEquipItem(oNewItem, INVENTORY_SLOT_RIGHTHAND));
        else AssignCommand(oTarget, ActionEquipItem(oNewItem, INVENTORY_SLOT_LEFTHAND));
        NuiSetBind(oPC, nToken, "txt_model_number_" + sPart, JsonString(IntToString(nModelNumber)));
    }
    // Armor.
    else if(nItemSelected == 0)
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
        //ai_Debug("pe_crafting", "646", "nModelSide: " + IntToString(nModelSide));
        // If we are doing the left side (bottom menu options) then add one to
        // get the left side.
        // Note: Right Thigh and Left Thigh are backwards so this fixes that!
        if(sPart == "b")
        {
            if(nModelSelected == ITEM_APPR_ARMOR_MODEL_RTHIGH) nModelSelected--;
            else nModelSelected++;
        }
        int nModelNumber = StringToInt(JsonGetString(NuiGetBind(oPC, nToken, "txt_model_number_" + sPart)));
        //int nModelNumber = GetItemAppearance(oItem, ITEM_APPR_TYPE_ARMOR_MODEL, nModelSelected);
        SendMessageToPC(oPC, "pe_crafting, 738, nModelNumber: " + IntToString(nModelNumber) +
                             " sPart: " + sPart);
        int nBaseModelNumber = nModelNumber;
        nModelNumber += nDirection;
        if(nModelNumber > CRAFT_MAX_MODEL_NUMBER) nModelNumber = 0;
        else if(nModelNumber < 0) nModelNumber = CRAFT_MAX_MODEL_NUMBER;
        string sModelNumber;
        if(nModelNumber < 10) sModelNumber = "00" + IntToString(nModelNumber);
        else if(nModelNumber < 100) sModelNumber = "0" + IntToString(nModelNumber);
        else sModelNumber = IntToString(nModelNumber);
        // Check for changes to the torso (base part of the armor linked to AC).
        if(nModelSelected == ITEM_APPR_ARMOR_MODEL_TORSO)
        {
            string sCurrentACBonus = Get2DAString("parts_chest", "ACBONUS", nBaseModelNumber);
            string sACBonus = Get2DAString ("parts_chest", "ACBONUS", nModelNumber);
            sModelName += Get2DAString ("capart", "MDLNAME", nModelSelected);
            //ai_Debug("pe_crafting", "654", "sModelName: " + sModelName + sModelNumber +
            //         " nModelNumber: " + IntToString(nModelNumber) + " sCurrentACBonus: " + sCurrentACBonus + " sACBonus: " + sACBonus);
            while(ResManGetAliasFor(sModelName + sModelNumber, RESTYPE_MDL) == "" ||
                  sACBonus != sCurrentACBonus)
            {
                nModelNumber += nDirection;
                if (nModelNumber > CRAFT_MAX_MODEL_NUMBER) nModelNumber = 0;
                else if (nModelNumber < 0) nModelNumber = CRAFT_MAX_MODEL_NUMBER;
                if(nModelNumber < 10) sModelNumber = "00" + IntToString(nModelNumber);
                else if(nModelNumber < 100) sModelNumber = "0" + IntToString(nModelNumber);
                else sModelNumber = IntToString(nModelNumber);
                sACBonus = Get2DAString ("parts_chest", "ACBONUS", nModelNumber);
                //ai_Debug("pe_crafting", "666", "sModelName: " + sModelName + sModelNumber +
                //         " nModelNumber: " + IntToString(nModelNumber) + " sACBonus: " + sACBonus);
            }
            // Change the model.
            oNewItem = CopyItemAndModify (oItem, ITEM_APPR_TYPE_ARMOR_MODEL, nModelSelected, nModelNumber, TRUE);
            DestroyObject (oItem);
            AssignCommand (oTarget, ActionEquipItem (oNewItem, INVENTORY_SLOT_CHEST));
        }
        // Change all other parts of armor.
        else
        {
            sModelName += Get2DAString("capart", "MDLNAME", nModelSelected);
            //ai_Debug("pe_crafting", "695", "sModelName: " + sModelName + sModelNumber +
            //         " nModelNumber: " + IntToString(nModelNumber));
            while(ResManGetAliasFor(sModelName + sModelNumber, RESTYPE_MDL) == "")
            {
                nModelNumber += nDirection;
                if (nModelNumber > CRAFT_MAX_MODEL_NUMBER) nModelNumber = 0;
                else if (nModelNumber < 0) nModelNumber = CRAFT_MAX_MODEL_NUMBER;
                if(nModelNumber < 10) sModelNumber = "00" + IntToString(nModelNumber);
                else if(nModelNumber < 100) sModelNumber = "0" + IntToString(nModelNumber);
                else sModelNumber = IntToString(nModelNumber);
                //ai_Debug("pe_crafting", "705", "sModelName: " + sModelName + sModelNumber +
                //         " nModelNumber: " + IntToString(nModelNumber));
            }
            oNewItem = CopyItemAndModify (oItem, ITEM_APPR_TYPE_ARMOR_MODEL, nModelSelected, nModelNumber, TRUE);
            DestroyObject (oItem);
            // If using the linked menu option then change the left side too.
            if(sPart == "m")
            {
                // Note: Right Thigh and Left Thigh are backwards so this fixes that!
                if (nModelSelected == ITEM_APPR_ARMOR_MODEL_RTHIGH) nModelSelected--;
                else nModelSelected++;
                oItem = CopyItemAndModify(oNewItem, ITEM_APPR_TYPE_ARMOR_MODEL, nModelSelected, nModelNumber, TRUE);
                DestroyObject(oNewItem);
                AssignCommand(oTarget, ActionEquipItem(oItem, INVENTORY_SLOT_CHEST));
            }
            else AssignCommand(oTarget, ActionEquipItem(oNewItem, INVENTORY_SLOT_CHEST));
        }
        string sModelSelected;
        if (nModelSelected == ITEM_APPR_ARMOR_MODEL_NECK ||
            nModelSelected == ITEM_APPR_ARMOR_MODEL_TORSO ||
            nModelSelected == ITEM_APPR_ARMOR_MODEL_BELT ||
            nModelSelected == ITEM_APPR_ARMOR_MODEL_PELVIS ||
            nModelSelected == ITEM_APPR_ARMOR_MODEL_ROBE)
        {
            NuiSetBind(oPC, nToken, "txt_model_number_" + sPart, JsonString(IntToString(nModelNumber)));
        }
        else
        {
            if(sPart == "m")
            {
                NuiSetBind(oPC, nToken, "txt_model_number_t", JsonString(IntToString(nModelNumber)));
                NuiSetBind(oPC, nToken, "txt_model_number_m", JsonString(IntToString(nModelNumber)));
                NuiSetBind(oPC, nToken, "txt_model_number_b", JsonString(IntToString(nModelNumber)));
            }
            else
            {
                NuiSetBind(oPC, nToken, "txt_model_number_" + sPart, JsonString(IntToString(nModelNumber)));
            }
        }
    }
    // All other items.
    else
    {
        int nSlot, nResType, nBaseItemType = GetBaseItemType(oItem);
        string sModelName = Get2DAString("baseitems", "ItemClass", nBaseItemType) + "_";
        if(nBaseItemType == BASE_ITEM_CLOAK)
        {
            nSlot = INVENTORY_SLOT_CLOAK;
            nResType = RESTYPE_PLT;
        }
        else if(nBaseItemType == BASE_ITEM_HELMET)
        {
            nSlot = INVENTORY_SLOT_HEAD;
            nResType = RESTYPE_MDL;
        }
        else if(nBaseItemType == BASE_ITEM_LARGESHIELD ||
                nBaseItemType == BASE_ITEM_SMALLSHIELD ||
                nBaseItemType == BASE_ITEM_TOWERSHIELD)
        {
            nSlot = INVENTORY_SLOT_LEFTHAND;
            nResType = RESTYPE_MDL;
        }
        int nModelNumber = GetItemAppearance(oItem, ITEM_APPR_TYPE_SIMPLE_MODEL, 0);
        nModelNumber += nDirection;
        if (nModelNumber > CRAFT_MAX_MODEL_NUMBER) nModelNumber = 0;
        else if (nModelNumber < 0) nModelNumber = CRAFT_MAX_MODEL_NUMBER;
        if(nModelNumber < 10) sModelNumber = "00" + IntToString(nModelNumber);
        else if(nModelNumber < 100) sModelNumber = "0" + IntToString(nModelNumber);
        else sModelNumber = IntToString(nModelNumber);
        //ai_Debug("pe_crafting", "804", "sModelName: " + sModelName + sModelNumber +
        //         " nModelNumber: " + IntToString(nModelNumber));
        while(ResManGetAliasFor(sModelName + sModelNumber, nResType) == "")
        {
            nModelNumber += nDirection;
            if (nModelNumber > CRAFT_MAX_MODEL_NUMBER) nModelNumber = 0;
            else if (nModelNumber < 0) nModelNumber = CRAFT_MAX_MODEL_NUMBER;
            if(nModelNumber < 10) sModelNumber = "00" + IntToString(nModelNumber);
            else if(nModelNumber < 100) sModelNumber = "0" + IntToString(nModelNumber);
            else sModelNumber = IntToString(nModelNumber);
            //ai_Debug("pe_crafting", "841", "sModelName: " + sModelName + sModelNumber +
            //         " nModelNumber: " + IntToString(nModelNumber));
        }
        oNewItem = CopyItemAndModify(oItem, ITEM_APPR_TYPE_SIMPLE_MODEL, 0, nModelNumber, TRUE);
        DestroyObject(oItem);
        AssignCommand(oTarget, ActionEquipItem (oNewItem, nSlot));
        NuiSetBind(oPC, nToken, "txt_model_number_" + sPart, JsonString(IntToString(nModelNumber)));
    }
    NuiSetBind(oPC, nToken, "txt_model_number", JsonString(sModelName + sModelNumber));
    SetLocalString(oPC, CRAFT_MODEL, sModelName + sModelNumber);
    return oNewItem;
}
object RandomizeItemsCraftAppearance(object oPC, object oTarget, int nToken, object oItem)
{
    // Get the item we are changing.
    int nModelSelected, nModel, nMaxModel, nColor, nMaxColor;
    json jCraft = GetLocalJson(oPC, CRAFT_JSON);
    int nItemSelected = JsonGetInt(JsonObjectGet(jCraft, CRAFT_ITEM_SELECTION));
    int iBaseItemType, iType, iIndex, iDie, iMod, iRoll, iColor, iRtop, iRmid, iRbottom;
    int iColorT, iColorM, iColorB;
    object oItem1, oItem2, oItem3, oItem4, oItem5, oItem6, oItem7, oItemFinal, oItemDone;
    object oNewItem;
    if(ai_GetIsWeapon(oItem))
    {
        int iWModuleBottom, iWModuleMiddle, iWModuleTop;
        iWModuleBottom = 9;
        iWModuleMiddle = 9;
        iWModuleTop = 9;
        iColor = 4;
        iRtop = Random(iWModuleTop) + 1;
        // Check bows as they must randomize to the same top, middle, and bottom otherwise they look bad.
        if(iBaseItemType == BASE_ITEM_LONGBOW || iBaseItemType == BASE_ITEM_SHORTBOW)
        {
            iRmid = iRtop;
            iRbottom = iRtop;
        }
        // Randomize each item individualy for other weapons.
        else
        {
            iRmid = Random(iWModuleMiddle) + 1;
            iRbottom = Random(iWModuleBottom) + 1;
        }
        // Change weapons model.
        oItem2 = CopyItemAndModify(oItem1, ITEM_APPR_TYPE_WEAPON_MODEL, ITEM_APPR_WEAPON_MODEL_TOP, iRtop, TRUE);
        DestroyObject(oItem1, 0.0f);
        oItem3 = CopyItemAndModify(oItem2, ITEM_APPR_TYPE_WEAPON_MODEL, ITEM_APPR_WEAPON_MODEL_MIDDLE, iRmid, TRUE);
        DestroyObject(oItem2, 0.2f);
        oItem4 = CopyItemAndModify(oItem3, ITEM_APPR_TYPE_WEAPON_MODEL, ITEM_APPR_WEAPON_MODEL_BOTTOM, iRbottom, TRUE);
        DestroyObject (oItem3, 0.4f);
        // Change weapons color.
        iColorT = Random(iColor) + 1;
        iColorM = Random(iColor) + 1;
        iColorB = Random(iColor) + 1;
        oItem5 = CopyItemAndModify(oItem4, ITEM_APPR_TYPE_WEAPON_COLOR, ITEM_APPR_WEAPON_COLOR_TOP, iColorT, TRUE);
        DestroyObject(oItem4, 0.6f);
        oItem6 = CopyItemAndModify(oItem5, ITEM_APPR_TYPE_WEAPON_COLOR, ITEM_APPR_WEAPON_COLOR_MIDDLE, iColorM, TRUE);
        DestroyObject(oItem5, 0.8f);
        oItemFinal = CopyItemAndModify(oItem6, ITEM_APPR_TYPE_WEAPON_COLOR, ITEM_APPR_WEAPON_COLOR_BOTTOM, iColorB, TRUE);
        DestroyObject(oItem6, 1.0f);
        if(nItemSelected == 3) AssignCommand(oTarget, ActionEquipItem(oItemFinal, INVENTORY_SLOT_RIGHTHAND));
        else if(nItemSelected == 4) AssignCommand(oTarget, ActionEquipItem(oItemFinal, INVENTORY_SLOT_LEFTHAND));
    }
    // Armor.
    else if (nItemSelected == 0)
    {
        object oItem1 = CopyItemAndModify(oItem, ITEM_APPR_TYPE_ARMOR_COLOR, ITEM_APPR_ARMOR_COLOR_LEATHER1, Random(175) + 1, TRUE);
        DestroyObject(oItem);
        object oItem2 = CopyItemAndModify(oItem1, ITEM_APPR_TYPE_ARMOR_COLOR, ITEM_APPR_ARMOR_COLOR_LEATHER2, Random(175) + 1, TRUE);
        DestroyObject(oItem1);
        object oItem3 = CopyItemAndModify(oItem2, ITEM_APPR_TYPE_ARMOR_COLOR, ITEM_APPR_ARMOR_COLOR_CLOTH1, Random(175) + 1, TRUE);
        DestroyObject(oItem2);
        object oItem4 = CopyItemAndModify(oItem3, ITEM_APPR_TYPE_ARMOR_COLOR, ITEM_APPR_ARMOR_COLOR_CLOTH2, Random(175) + 1, TRUE);
        DestroyObject(oItem3);
        object oItem5 = CopyItemAndModify(oItem4, ITEM_APPR_TYPE_ARMOR_COLOR, ITEM_APPR_ARMOR_COLOR_METAL1, Random(175) + 1, TRUE);
        DestroyObject (oItem4);
        oNewItem = CopyItemAndModify(oItem5, ITEM_APPR_TYPE_ARMOR_COLOR, ITEM_APPR_ARMOR_COLOR_METAL2, Random(175) + 1, TRUE);
        DestroyObject(oItem5);
        AssignCommand(oTarget, ActionEquipItem(oNewItem, INVENTORY_SLOT_CHEST));
    }
    // All other items.
    else
    {
        int nSlot, nBaseItem = GetBaseItemType(oItem);
        // Get max models and inventory slot.
        if(nBaseItem == BASE_ITEM_CLOAK)
        {
            nMaxModel = 107;
            nSlot = INVENTORY_SLOT_CLOAK;
        }
        else if(nBaseItem == BASE_ITEM_HELMET)
        {
            nMaxModel = 62;
            nSlot = INVENTORY_SLOT_HEAD;
        }
        else if(nBaseItem == BASE_ITEM_LARGESHIELD || nBaseItem == BASE_ITEM_SMALLSHIELD ||
                nBaseItem == BASE_ITEM_TOWERSHIELD)
        {
            nSlot = INVENTORY_SLOT_LEFTHAND;
            if(nBaseItem == BASE_ITEM_SMALLSHIELD) nMaxModel = 64;
            else if(nBaseItem == BASE_ITEM_LARGESHIELD) nMaxModel = 163;
            else if(nBaseItem == BASE_ITEM_TOWERSHIELD) nMaxModel = 124;
        }
        nModel = Random(nMaxModel) + 1;
        object oItem1 = CopyItemAndModify(oItem, ITEM_APPR_TYPE_SIMPLE_MODEL, 0, nModel, TRUE);
        DestroyObject(oItem);
        if (nBaseItem == BASE_ITEM_CLOAK || nBaseItem == BASE_ITEM_HELMET)
        {
            object oItem2 = CopyItemAndModify(oItem1, ITEM_APPR_TYPE_ARMOR_COLOR, ITEM_APPR_ARMOR_COLOR_LEATHER1, Random(175) + 1, TRUE);
            DestroyObject(oItem1);
            object oItem3 = CopyItemAndModify(oItem2, ITEM_APPR_TYPE_ARMOR_COLOR, ITEM_APPR_ARMOR_COLOR_LEATHER2, Random(175) + 1, TRUE);
            DestroyObject(oItem2);
            object oItem4 = CopyItemAndModify(oItem3, ITEM_APPR_TYPE_ARMOR_COLOR, ITEM_APPR_ARMOR_COLOR_CLOTH1, Random(175) + 1, TRUE);
            DestroyObject(oItem3);
            object oItem5 = CopyItemAndModify(oItem4, ITEM_APPR_TYPE_ARMOR_COLOR, ITEM_APPR_ARMOR_COLOR_CLOTH2, Random(175) + 1, TRUE);
            DestroyObject(oItem4);
            object oItem6 = CopyItemAndModify(oItem5, ITEM_APPR_TYPE_ARMOR_COLOR, ITEM_APPR_ARMOR_COLOR_METAL1, Random(175) + 1, TRUE);
            DestroyObject(oItem5);
            oNewItem = CopyItemAndModify(oItem6, ITEM_APPR_TYPE_ARMOR_COLOR, ITEM_APPR_ARMOR_COLOR_METAL2, Random(175) + 1, TRUE);
            DestroyObject(oItem6);
        }
        else
        {
            oNewItem = oItem1;
        }
        AssignCommand(oTarget, ActionEquipItem(oNewItem, nSlot));
    }
    return oNewItem;
}
object GetSelectedItem(object oTarget, int nItemSelected)
{
    if(nItemSelected == 0) return GetItemInSlot(INVENTORY_SLOT_CHEST, oTarget);
    else if(nItemSelected == 1) return GetItemInSlot(INVENTORY_SLOT_CLOAK, oTarget);
    else if(nItemSelected == 2) return GetItemInSlot(INVENTORY_SLOT_HEAD, oTarget);
    else if(nItemSelected == 3) return GetItemInSlot(INVENTORY_SLOT_RIGHTHAND, oTarget);
    else if(nItemSelected == 4) return GetItemInSlot(INVENTORY_SLOT_LEFTHAND, oTarget);
    return OBJECT_INVALID;
}
void CancelCraftedItem(object oPC, object oTarget)
{
    json jCraft = GetLocalJson(oPC, CRAFT_JSON);
    int nItemSelected = JsonGetInt(JsonObjectGet(jCraft, CRAFT_ITEM_SELECTION));
    object oItem = GetSelectedItem(oTarget, nItemSelected);
    object oOriginalItem = GetLocalObject(oPC, CRAFT_ORIGINAL_ITEM);
    if(oOriginalItem != OBJECT_INVALID)
    {
        DestroyObject(oItem);
        int nSlot = GetItemSelectedEquipSlot(nItemSelected);
        // Give item Backup to Player
        oOriginalItem = CopyItem(oOriginalItem, oTarget, TRUE);
        DelayCommand(0.2f, AssignCommand (oTarget, ActionEquipItem(oOriginalItem, nSlot)));
        DeleteLocalObject(oPC, CRAFT_ORIGINAL_ITEM);
    }
}
// Gets the colorId from a image of the color pallet.
// Thanks Zunath for the base code.
int GetColorPalletId(object oPC)
{
    float fScale = IntToFloat(GetPlayerDeviceProperty(oPC, PLAYER_DEVICE_PROPERTY_GUI_SCALE)) / 100.0f;
    json jPayload = NuiGetEventPayload();
    json jMousePosition = JsonObjectGet(jPayload, "mouse_pos");
    json jX = JsonObjectGet(jMousePosition, "x");
    json jY = JsonObjectGet(jMousePosition, "y");
    float fX = StringToFloat(JsonDump (jX));
    float fY = StringToFloat(JsonDump (jY));
    float fCellSize = 16.0f * fScale;
    int nCellX = FloatToInt(fX / fCellSize);
    int nCellY = FloatToInt(fY / fCellSize);
    if(nCellX < 0) nCellX = 0;
    else if (nCellX > 16) nCellX = 16;
    if(nCellY < 0) nCellY = 0;
    else if(nCellY > 11) nCellY = 11;
    return nCellX + nCellY * 16;
}
void LockItemInCraftingWindow(object oPC, object oItem, int nToken)
{
    NuiSetBind(oPC, nToken, "item_combo_event", JsonBool(FALSE));
    NuiSetBind(oPC, nToken, "btn_cancel_label", JsonString("Cancel"));
    NuiSetBind(oPC, nToken, "btn_cancel_tooltip", JsonString("  Revert back to the original items appearance"));
    NuiSetBind(oPC, nToken, "btn_save_event", JsonBool(TRUE));
    NuiSetBind(oPC, nToken, "btn_select_target_event", JsonBool(FALSE));
}
void ClearItemInCraftingWindow(object oPC, object oItem, int nToken)
{
    NuiSetBind(oPC, nToken, "btn_save_event", JsonBool(FALSE));
    NuiSetBind(oPC, nToken, "item_combo_event", JsonBool(TRUE));
    NuiSetBind(oPC, nToken, "btn_select_target_event", JsonBool(TRUE));
    NuiSetBind(oPC, nToken, "btn_cancel_label", JsonString("Exit"));
    NuiSetBind(oPC, nToken, "btn_cancel_tooltip", JsonString("  Exit the crafting menu"));
}
void SaveCraftedItem(object oPC, object oTarget, int nToken)
{
    json jCraft = GetLocalJson(oPC, CRAFT_JSON);
    int nItemSelected = JsonGetInt(JsonObjectGet(jCraft, CRAFT_ITEM_SELECTION));
    object oItem = GetSelectedItem(oTarget, nItemSelected);
    ClearItemInCraftingWindow(oPC, oItem, nToken);
    DestroyObject(GetLocalObject(oPC, CRAFT_ORIGINAL_ITEM));
    DeleteLocalObject(oPC, CRAFT_ORIGINAL_ITEM);
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
void RemoveTagedEffects(object oCreature, string sEffectTag)
{
   //Search for the effect.
   //Debug ("0i_effects", "578", "RemoveTagedEffects: " + sEffectTag);
   effect eEffect = GetFirstEffect(oCreature);
   while (GetIsEffectValid(eEffect))
   {
      //Debug ("0i_effects", "582", "Effect Tag: " + GetEffectTag (eEffect));
      if (GetEffectTag(eEffect) == sEffectTag) RemoveEffect(oCreature, eEffect);
      eEffect = GetNextEffect(oCreature);
   }
}
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
void SetModelNumberText(object oPC, int nToken)
{
    json jCraft = GetLocalJson(oPC, CRAFT_JSON);
    int nItem = JsonGetInt(JsonObjectGet(jCraft, CRAFT_ITEM_SELECTION));
    object oItem = GetSelectedItem(oPC, nItem);
    int nSelected = JsonGetInt(JsonObjectGet(jCraft, CRAFT_MODEL_SELECTION));
    string sModelTop, sModelMiddle, sModelBottom;
    // Model Group
    if (ai_GetIsWeapon (oItem))
    {
        int nModel = GetItemAppearance(oItem, ITEM_APPR_TYPE_WEAPON_MODEL, 0);
        int nColor = GetItemAppearance(oItem, ITEM_APPR_TYPE_WEAPON_COLOR, 0);
        int nModelNumber = (nModel * 10) + nColor;
        sModelTop = IntToString(nModelNumber);
        nModel = GetItemAppearance(oItem, ITEM_APPR_TYPE_WEAPON_MODEL, 1);
        nColor = GetItemAppearance(oItem, ITEM_APPR_TYPE_WEAPON_COLOR, 1);
        nModelNumber = (nModel * 10) + nColor;
        sModelMiddle = IntToString(nModelNumber);
        nModel = GetItemAppearance(oItem, ITEM_APPR_TYPE_WEAPON_MODEL, 2);
        nColor = GetItemAppearance(oItem, ITEM_APPR_TYPE_WEAPON_COLOR, 2);
        nModelNumber = (nModel * 10) + nColor;
        sModelBottom = IntToString(nModelNumber);
        NuiSetBind(oPC, nToken, "top_title_label", JsonString("Top"));
        NuiSetBind(oPC, nToken, "txt_model_number_t_enable", JsonBool(TRUE));
        NuiSetBindWatch(oPC, nToken, "txt_model_number_t", TRUE);
        NuiSetBind(oPC, nToken, "txt_model_name_t", JsonString(sModelTop));
        NuiSetBind(oPC, nToken, "btn_prev_t_event", JsonBool(TRUE));
        NuiSetBind(oPC, nToken, "btn_next_t_event", JsonBool(TRUE));
        NuiSetBind(oPC, nToken, "middle_title_label", JsonString("Middle"));
        NuiSetBind(oPC, nToken, "txt_model_number_m_enable", JsonBool(TRUE));
        NuiSetBindWatch(oPC, nToken, "txt_model_number_m", TRUE);
        NuiSetBind(oPC, nToken, "txt_model_number_m", JsonString(sModelMiddle));
        NuiSetBind(oPC, nToken, "btn_prev_m_event", JsonBool(TRUE));
        NuiSetBind(oPC, nToken, "btn_next_m_event", JsonBool(TRUE));
        NuiSetBind(oPC, nToken, "bottom_title_label", JsonString("Bottom"));
        NuiSetBind(oPC, nToken, "txt_model_number_b_enable", JsonBool(TRUE));
        NuiSetBindWatch(oPC, nToken, "txt_model_number_b", TRUE);
        NuiSetBind(oPC, nToken, "txt_model_number_b", JsonString(sModelBottom));
        NuiSetBind(oPC, nToken, "btn_prev_b_event", JsonBool(TRUE));
        NuiSetBind(oPC, nToken, "btn_next_b_event", JsonBool(TRUE));
    }
    // Armor and clothing
    if(nItem == 0)
    {
        nSelected = GetArmorModelSelected(oPC);
        // These models only have one side so make sure we are not linked.
        if (nSelected == ITEM_APPR_ARMOR_MODEL_NECK ||
            nSelected == ITEM_APPR_ARMOR_MODEL_TORSO ||
            nSelected == ITEM_APPR_ARMOR_MODEL_BELT ||
            nSelected == ITEM_APPR_ARMOR_MODEL_PELVIS ||
            nSelected == ITEM_APPR_ARMOR_MODEL_ROBE)
        {
            sModelMiddle = IntToString(GetItemAppearance(oItem, ITEM_APPR_TYPE_ARMOR_MODEL, nSelected));
            NuiSetBind(oPC, nToken, "top_title_label", JsonString(""));
            NuiSetBind(oPC, nToken, "txt_model_number_t_event", JsonBool(FALSE));
            NuiSetBind(oPC, nToken, "txt_model_name_t", JsonString(""));
            NuiSetBind(oPC, nToken, "btn_prev_t_event", JsonBool(FALSE));
            NuiSetBind(oPC, nToken, "btn_next_t_event", JsonBool(FALSE));
            NuiSetBind(oPC, nToken, "middle_title_label", JsonString("Model"));
            NuiSetBind(oPC, nToken, "txt_model_number_m_event", JsonBool(TRUE));
            NuiSetBind(oPC, nToken, "txt_model_number_m", JsonString(sModelMiddle));
            NuiSetBind(oPC, nToken, "btn_prev_m_event", JsonBool(TRUE));
            NuiSetBind(oPC, nToken, "btn_next_m_event", JsonBool(TRUE));
            NuiSetBind(oPC, nToken, "bottom_title_label", JsonString(""));
            NuiSetBind(oPC, nToken, "txt_model_number_b_event", JsonBool(FALSE));
            NuiSetBind(oPC, nToken, "txt_model_number_b", JsonString(""));
            NuiSetBind(oPC, nToken, "btn_prev_b_event", JsonBool(FALSE));
            NuiSetBind(oPC, nToken, "btn_next_b_event", JsonBool(FALSE));
        }
        else
        {
            sModelTop = IntToString(GetItemAppearance(oItem, ITEM_APPR_TYPE_ARMOR_MODEL, nSelected));
            if(nSelected == ITEM_APPR_ARMOR_MODEL_RTHIGH) nSelected--;
            else nSelected++;
            sModelBottom = IntToString(GetItemAppearance(oItem, ITEM_APPR_TYPE_ARMOR_MODEL, nSelected));
            NuiSetBind(oPC, nToken, "top_title_label", JsonString("Left"));
            NuiSetBind(oPC, nToken, "txt_model_number_t_event", JsonBool(TRUE));
            NuiSetBind(oPC, nToken, "txt_model_number_t", JsonString(sModelTop));
            NuiSetBind(oPC, nToken, "btn_prev_t_event", JsonBool(TRUE));
            NuiSetBind(oPC, nToken, "btn_next_t_event", JsonBool(TRUE));
            NuiSetBind(oPC, nToken, "middle_title_label", JsonString("Left & Right"));
            NuiSetBind(oPC, nToken, "txt_model_number_m_event", JsonBool(TRUE));
            NuiSetBind(oPC, nToken, "txt_model_number_m", JsonString(sModelTop));
            NuiSetBind(oPC, nToken, "btn_prev_m_event", JsonBool(TRUE));
            NuiSetBind(oPC, nToken, "btn_next_m_event", JsonBool(TRUE));
            NuiSetBind(oPC, nToken, "bottom_title_label", JsonString("Right"));
            NuiSetBind(oPC, nToken, "txt_model_number_b_event", JsonBool(TRUE));
            NuiSetBind(oPC, nToken, "txt_model_number_b", JsonString(sModelBottom));
            NuiSetBind(oPC, nToken, "btn_prev_b_event", JsonBool(TRUE));
            NuiSetBind(oPC, nToken, "btn_next_b_event", JsonBool(TRUE));
        }
    }
    // Cloaks and Helmets.
    else
    {
        sModelMiddle = IntToString(GetItemAppearance(oItem, ITEM_APPR_TYPE_SIMPLE_MODEL, 0));
        NuiSetBind(oPC, nToken, "top_title_label", JsonString(""));
        NuiSetBind(oPC, nToken, "txt_model_number_t_event", JsonBool(FALSE));
        NuiSetBind(oPC, nToken, "txt_model_number_t", JsonString(""));
        NuiSetBind(oPC, nToken, "btn_prev_t_event", JsonBool(FALSE));
        NuiSetBind(oPC, nToken, "btn_next_t_event", JsonBool(FALSE));
        NuiSetBind(oPC, nToken, "txt_model_number_m_event", JsonBool(TRUE));
        NuiSetBind(oPC, nToken, "txt_model_number_m", JsonString(sModelMiddle));
        NuiSetBind(oPC, nToken, "middle_title_label", JsonString("Model"));
        NuiSetBind(oPC, nToken, "btn_prev_m_event", JsonBool(TRUE));
        NuiSetBind(oPC, nToken, "btn_next_m_event", JsonBool(TRUE));
        NuiSetBind(oPC, nToken, "txt_model_number_b_event", JsonBool(FALSE));
        NuiSetBind(oPC, nToken, "txt_model_number_b", JsonString(""));
        NuiSetBind(oPC, nToken, "bottom_title_label", JsonString(""));
        NuiSetBind(oPC, nToken, "btn_prev_b_event", JsonBool(FALSE));
        NuiSetBind(oPC, nToken, "btn_next_b_event", JsonBool(FALSE));
    }
    // Color Group
    if(ai_GetIsWeapon(oItem) || ai_GetIsShield(oItem))
    {
        // Need to disable the color widgets.
        // Row 5k
        NuiSetBind(oPC, nToken, "color_pallet_image", JsonString("gui_pal_tattoo"));
        NuiSetBind(oPC, nToken, "color_pallet_image_event", JsonBool(FALSE));
        // Row 5l
        NuiSetBind(oPC, nToken, "btn_left_part_color_event", JsonBool(FALSE));
        NuiSetBind(oPC, nToken, "btn_all_color_event", JsonBool(FALSE));
        NuiSetBind(oPC, nToken, "btn_right_part_color_event", JsonBool(FALSE));
        // Row 5m
        NuiSetBind(oPC, nToken, "txt_color_l", JsonString(""));
        NuiSetBind(oPC, nToken, "txt_color_l_event", JsonBool(FALSE));
        NuiSetBind(oPC, nToken, "txt_color_a", JsonString(""));
        NuiSetBind(oPC, nToken, "txt_color_a_event", JsonBool(FALSE));
        NuiSetBind(oPC, nToken, "txt_color_r", JsonString(""));
        NuiSetBind(oPC, nToken, "txt_color_r_event", JsonBool(FALSE));
        // Row 5n
        NuiSetBind(oPC, nToken, "material_combo_event", JsonBool(FALSE));
    }
    // Armor and clothing
    else if(nItem == 0)
    {
        // Row 5k
        string sColorPallet = GetLocalString(oPC, CRAFT_COLOR_PALLET);
        if(sColorPallet == "") sColorPallet = "gui_pal_tattoo";
        NuiSetBind(oPC, nToken, "color_pallet_image", JsonString(sColorPallet));
        NuiSetBind(oPC, nToken, "color_pallet_event", JsonBool(TRUE));
        NuiSetBind(oPC, nToken, "color_pallet_tooltip", JsonString("  Select a color or use the mouse wheel"));
        // Row 5m
        NuiSetBindWatch(oPC, nToken, "txt_color_l", TRUE);
        int nModelSelected = GetArmorModelSelected(oPC);
        int nMaterialSelected = JsonGetInt(JsonObjectGet(jCraft, CRAFT_MATERIAL_SELECTION));
        string sColorAll = IntToString(GetItemAppearance(oItem, ITEM_APPR_TYPE_ARMOR_COLOR, nMaterialSelected));
        // These models only have one side so make sure we are not linked.
        if (nModelSelected == ITEM_APPR_ARMOR_MODEL_NECK ||
            nModelSelected == ITEM_APPR_ARMOR_MODEL_TORSO ||
            nModelSelected == ITEM_APPR_ARMOR_MODEL_BELT ||
            nModelSelected == ITEM_APPR_ARMOR_MODEL_PELVIS ||
            nModelSelected == ITEM_APPR_ARMOR_MODEL_ROBE)
        {
            // Row 5l
            NuiSetBind(oPC, nToken, "btn_left_part_color", JsonBool(FALSE));
            NuiSetBind(oPC, nToken, "btn_left_part_color_event", JsonBool(FALSE));
            NuiSetBind(oPC, nToken, "btn_all_color", JsonBool(FALSE));
            NuiSetBind(oPC, nToken, "btn_all_color_event", JsonBool(FALSE));
            NuiSetBind(oPC, nToken, "btn_right_part_color", JsonBool(FALSE));
            NuiSetBind(oPC, nToken, "btn_right_part_color_event", JsonBool(FALSE));
            // Row 5m
            NuiSetBind(oPC, nToken, "txt_color_l_event", JsonBool(FALSE));
            NuiSetBind(oPC, nToken, "txt_color_l", JsonString(""));
            NuiSetBind(oPC, nToken, "txt_color_a_event", JsonBool(TRUE));
            NuiSetBind(oPC, nToken, "txt_color_a", JsonString(sColorAll));
            NuiSetBindWatch(oPC, nToken, "txt_color_a", TRUE);
            NuiSetBind(oPC, nToken, "txt_color_a_tooltip", JsonString("  Choose color for all models 0 to 175"));
            NuiSetBind(oPC, nToken, "txt_color_r_event", JsonBool(FALSE));
            NuiSetBind(oPC, nToken, "txt_color_r", JsonString(""));
        }
        else
        {
            // Row 5l
            int nSelected = JsonGetInt(JsonObjectGet(jCraft, CRAFT_LEFT_PART_COLOR));
            NuiSetBind(oPC, nToken, "btn_left_part_color", JsonBool(nSelected));
            NuiSetBind(oPC, nToken, "btn_left_part_color_event", JsonBool(TRUE));
            nSelected = JsonGetInt(JsonObjectGet(jCraft, CRAFT_ALL_COLOR));
            NuiSetBind(oPC, nToken, "btn_all_color", JsonBool(nSelected));
            NuiSetBind(oPC, nToken, "btn_all_color_event", JsonBool(TRUE));
            nSelected = JsonGetInt(JsonObjectGet(jCraft, CRAFT_RIGHT_PART_COLOR));
            NuiSetBind(oPC, nToken, "btn_right_part_color", JsonBool(nSelected));
            NuiSetBind(oPC, nToken, "btn_right_part_color_event", JsonBool(TRUE));
            // Row 5m
            int nIndex = ITEM_APPR_ARMOR_NUM_COLORS + (nModelSelected * ITEM_APPR_ARMOR_NUM_COLORS) + nMaterialSelected;
            string sColor = IntToString(GetItemAppearance(oItem, ITEM_APPR_TYPE_ARMOR_COLOR, nIndex));
            if(sColor == "255") sColor = sColorAll;
            NuiSetBind(oPC, nToken, "txt_color_l_event", JsonBool(TRUE));
            NuiSetBind(oPC, nToken, "txt_color_l", JsonString(sColor));
            NuiSetBind(oPC, nToken, "txt_color_l_tooltip", JsonString("  Choose color for left model 0 to 175"));
            NuiSetBind(oPC, nToken, "txt_color_a_event", JsonBool(TRUE));
            NuiSetBind(oPC, nToken, "txt_color_a", JsonString(sColorAll));
            NuiSetBindWatch(oPC, nToken, "txt_color_a", TRUE);
            NuiSetBind(oPC, nToken, "txt_color_a_tooltip", JsonString("  Choose color for all models 0 to 175"));
            if(nModelSelected == ITEM_APPR_ARMOR_MODEL_RTHIGH) nModelSelected--;
            else nModelSelected++;
            nIndex = ITEM_APPR_ARMOR_NUM_COLORS + (nModelSelected * ITEM_APPR_ARMOR_NUM_COLORS) + nMaterialSelected;
            sColor = IntToString(GetItemAppearance(oItem, ITEM_APPR_TYPE_ARMOR_COLOR, nIndex));
            if(sColor == "255") sColor = sColorAll;
            NuiSetBind(oPC, nToken, "txt_color_r_event", JsonBool(TRUE));
            NuiSetBind(oPC, nToken, "txt_color_r", JsonString(sColor));
            NuiSetBindWatch(oPC, nToken, "txt_color_r", TRUE);
            NuiSetBind(oPC, nToken, "txt_color_r_tooltip", JsonString("  Choose color for right model 0 to 175"));
        }
        // Row 5n
        nSelected = JsonGetInt(JsonObjectGet(jCraft, CRAFT_MATERIAL_SELECTION));
        NuiSetBind(oPC, nToken, "material_combo_selected", JsonInt(nSelected));
        NuiSetBind(oPC, nToken, "material_combo_event", JsonBool(TRUE));
        NuiSetBindWatch(oPC, nToken, "material_combo_selected", TRUE);
    }
}

