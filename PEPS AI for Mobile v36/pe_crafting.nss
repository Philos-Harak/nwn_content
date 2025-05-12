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
const int CRAFT_MAX_MODEL_NUMBER = 999;

struct stWeaponAppearance
{
    object oItem;
    int nModel;
    int nColor;
    string sPart;
};
// Maximum model number for weapons. Note this will be the 100s and 10s places.
// The color number uses the ones place. Thus 25 is actually 250.
const int CRAFT_MAX_WEAPON_MODEL_NUMBER = 99;
const string CRAFT_JSON = "CRAFT_JSON";
const string CRAFT_ORIGINAL_ITEM = "CRAFT_ORIGINAL_ITEM";
const string CRAFT_COOL_DOWN = "CRAFT_COOL_DOWN";
const string CRAFT_ITEM_SELECTION = "CRAFT_ITEM_SELECTION";
const string CRAFT_MATERIAL_SELECTION = "CRAFT_MATERIAL_SELECTION";
const string CRAFT_MODEL_SELECTION = "CRAFT_MODEL_SELECTION";
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
const string CRAFT_TARGET = "CRAFT_TARGET";
// Tag used in lighting effects.
const string CRAFT_HIGHLIGHT = "CRAFT_HIGHLIGHT";
const string CRAFT_ULTRALIGHT = "CRAFT_ULTRALIGHT";
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
int GetColorPalletId(object oPC, int nToken);
// Sets the pointer based on current Item, Part, and Material selected.
void SetColorPalletPointer(object oPC, int nToken, object oItem);
// Locks/Unlocks specific buttons when an item has been changed.
void LockItemInCraftingWindow(object oPC, object oItem, object oTarget, int nToken);
// Locks/Unlocks specific buttons when an item has been cleared.
void ClearItemInCraftingWindow(object oPC, object oItem, object oTarget, int nToken);
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
// Sets the material buttons for use.
// nMaterial 0,1 Cloth 2,3 Leather 4,5 Metal -1 None.
void SetMaterialButtons(object oPC, int nToken, int nMaterial);
// Creates the item editing menu.
void CreateItemGUIPanel(object oPC, object oTarget);
// Events for ItemGUIPanel
void CraftItemInfoEvents(object oPC, int nToken);
// Creates the save/load menu for items.
//void CreateDresserGUIPanel(object oPC, object oTarget);

int GetColorIDChange(object oItem, int nType, int nIndex, int nChange)
{
    int nColorId = GetItemAppearance(oItem, nType, nIndex) + nChange;
    if(nColorId > 175) return 0;
    if(nColorId < 0) return 175;
    return nColorId;
}
void main()
{
    // Get the last player to use targeting mode
    object oPC = GetLastPlayerToSelectTarget();
    string sTargetMode = GetLocalString(oPC, AI_TARGET_MODE);
    if(oPC == OBJECT_SELF && sTargetMode != "")
    {
        // Get the targeting mode data
        object oTarget = GetTargetingModeSelectedObject();
        //vector vTarget = GetTargetingModeSelectedPosition();
        //location lLocation = Location(GetArea(oPC), vTarget, GetFacing(oPC));
        //object oObject = GetLocalObject(oPC, "AI_TARGET_OBJECT");
        // If the user manually exited targeting mode without selecting a target, return
        if(!GetIsObjectValid(oTarget))// && vTarget == Vector())
        {
            return;
        }
        // Targeting code here.
        if(sTargetMode == "SELECT_TARGET")
        {
            if(GetAssociateType(oTarget) == ASSOCIATE_TYPE_HENCHMAN ||
               ai_GetIsCharacter(oTarget))
            {
                SetLocalObject(oPC, CRAFT_TARGET, oTarget);
                AttachCamera(oPC, oTarget);
                ExecuteScript("pi_crafting", oPC);
            }
            else ai_SendMessages(GetName(oTarget) + " is not the player or a henchmen! Other associates cannot use item crafting.", AI_COLOR_RED, oPC);
        }
        DeleteLocalString(oPC, AI_TARGET_MODE);
    }
    else
    {
        object oPC = NuiGetEventPlayer();
        int nToken = NuiGetEventWindow();
        string sWndId = NuiGetWindowId (oPC, nToken);
        if(sWndId == "craft_item_nui")
        {
            CraftItemInfoEvents(oPC, nToken);
            return;
        }
        string sEvent = NuiGetEventType();
        // We don't use and it causes error windows to go off! Return early!
        if(sEvent == "mouseup") return;
        string sElem = NuiGetEventElement();
        int nIndex = NuiGetEventArrayIndex();
        json jCraft = GetLocalJson(oPC, CRAFT_JSON);
        //SendMessageToPC(oPC, "0e_crafting, 144, sElem: " + sElem + " sEvent: " + sEvent);
        //**************************************************************************
        // Watch to see if the window moves and save.
        if(sElem == "window_geometry" && sEvent == "watch")
        {
            if(!GetLocalInt (oPC, AI_NO_NUI_SAVE))
            {
                json jCraft = GetLocalJson(oPC, CRAFT_JSON);
                if(JsonGetType(jCraft) == JSON_TYPE_NULL)
                {
                    SetLocalJson(oPC, CRAFT_JSON, JsonObject());
                    jCraft = GetLocalJson(oPC, CRAFT_JSON);
                }
                // Get the height, width, x, and y of the window.
                json jGeometry = NuiGetBind(oPC, nToken, "window_geometry");
                JsonObjectSetInplace(jCraft, "CRAFT_MENU", jGeometry);
            }
            return;
        }
        //**************************************************************************
        object oTarget = GetLocalObject(oPC, CRAFT_TARGET);
        if(oTarget == OBJECT_INVALID) oTarget = oPC;
        // Get the item we are crafting.
        int nItemSelected = JsonGetInt(JsonObjectGet(jCraft, CRAFT_ITEM_SELECTION));
        object oItem = GetSelectedItem(oTarget, nItemSelected);
        object oOriginalItem = GetLocalObject(oPC, CRAFT_ORIGINAL_ITEM);
        if(oItem == OBJECT_INVALID)
        {
            if(sElem != "btn_cancel")
            {
                ai_SendMessages("The item we are adjusting is not equiped!", AI_COLOR_RED, oPC);
                return;
            }
        }
        else if(oOriginalItem != OBJECT_INVALID && GetTag(oItem) != GetTag(oOriginalItem))
        {
            ai_SendMessages(GetName(oItem) + " is not the item you have been adjusting!", AI_COLOR_RED, oPC);
            return;
        }
        // Changing the name needs to be before the cooldown.
        if(sElem == "txt_item_name" && sEvent == "watch")
        {
            string sName = JsonGetString(NuiGetBind(oPC, nToken, "txt_item_name"));
            SetName(oItem, sName);
            int nToken2 = NuiFindWindow(oPC, "craft_item_nui");
            if(nToken2) NuiSetBind(oPC, nToken2, "txt_item_name", JsonString(sName));
            return;
        }
        // Delay crafting so it has time to equip and unequip as well as remove.
        //if(GetLocalInt(oPC, CRAFT_COOL_DOWN)) return;
        //SetLocalInt(oPC, CRAFT_COOL_DOWN, TRUE);
        //DelayCommand(0.25f, DeleteLocalInt(oPC, CRAFT_COOL_DOWN));
        // They have selected a color.
        if(sElem == "color_pallet")
        {
            int nColorId, nChange;
            object oNewItem;
            if(sEvent == "mousedown")
            {
                // Get the color they selected from the color pallet cell.
                nColorId = GetColorPalletId(oPC, nToken);
            }
            //else if(sEvent == "mousescroll")
            //{
            //    float nMouseScroll = JsonGetFloat(JsonObjectGet(JsonObjectGet(NuiGetEventPayload(), "mouse_scroll"), "y"));
            //    nChange = FloatToInt(nMouseScroll);
            //}
            else return;
            if(!CanCraftItem(oPC, oItem, nToken)) return;
            int nMaterialSelected = JsonGetInt(JsonObjectGet(jCraft, CRAFT_MATERIAL_SELECTION));
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
                        oNewItem = CopyItemAndModify(oItem, ITEM_APPR_TYPE_ARMOR_COLOR, nIndex, nColorId, TRUE);
                        DestroyObject(oItem);
                        // Fix buttons.
                        NuiSetBind(oPC, nToken, "btn_right_part_reset_event", JsonBool(TRUE));
                        NuiSetBind(oPC, nToken, "btn_all_reset_event", JsonBool(TRUE));
                        if(nLeftColor)
                        {
                            // If we are doing the left side then add one to get the left side.
                            // Note: Right Thigh and Left Thigh are backwards so this fixes that!
                            if (nModelSelected == ITEM_APPR_ARMOR_MODEL_RTHIGH) nModelSelected = nModelSelected - 1;
                            else nModelSelected = nModelSelected + 1;
                            nIndex = ITEM_APPR_ARMOR_NUM_COLORS + (nModelSelected * ITEM_APPR_ARMOR_NUM_COLORS) + nMaterialSelected;
                            if(nChange) nColorId = GetColorIDChange(oNewItem, ITEM_APPR_TYPE_ARMOR_COLOR, nIndex, nChange);
                            oItem = CopyItemAndModify(oNewItem, ITEM_APPR_TYPE_ARMOR_COLOR, nIndex, nColorId, TRUE);
                            DestroyObject(oNewItem);
                            oNewItem = oItem;
                            // Fix buttons.
                            NuiSetBind(oPC, nToken, "btn_all_reset_event", JsonBool(TRUE));
                            NuiSetBind(oPC, nToken, "btn_left_part_reset_event", JsonBool(TRUE));
                        }
                    }
                    else if(nLeftColor)
                    {
                        // If we are doing the left side then add one to get the left side.
                        // Note: Right Thigh and Left Thigh are backwards so this fixes that!
                        if (nModelSelected == ITEM_APPR_ARMOR_MODEL_RTHIGH) nModelSelected = nModelSelected - 1;
                        else nModelSelected = nModelSelected + 1;
                        nIndex = ITEM_APPR_ARMOR_NUM_COLORS + (nModelSelected * ITEM_APPR_ARMOR_NUM_COLORS) + nMaterialSelected;
                        if(nChange) nColorId = GetColorIDChange(oItem, ITEM_APPR_TYPE_ARMOR_COLOR, nIndex, nChange);
                        oNewItem = CopyItemAndModify(oItem, ITEM_APPR_TYPE_ARMOR_COLOR, nIndex, nColorId, TRUE);
                        DestroyObject(oItem);
                        // Fix buttons.
                        NuiSetBind(oPC, nToken, "btn_all_reset_event", JsonBool(TRUE));
                        NuiSetBind(oPC, nToken, "btn_left_part_reset_event", JsonBool(TRUE));
                    }
                }
            }
            else
            {
                if(nChange) nColorId = GetColorIDChange(oItem, ITEM_APPR_TYPE_ARMOR_COLOR, nMaterialSelected, nChange);
                oNewItem = CopyItemAndModify(oItem, ITEM_APPR_TYPE_ARMOR_COLOR, nMaterialSelected, nColorId, TRUE);
                DestroyObject(oItem);
            }
            // Lock the new item so they can't change it on the character.
            LockItemInCraftingWindow(oPC, oNewItem, oTarget, nToken);
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
                oItem = GetSelectedItem(oTarget, nSelected);
                if(oItem == OBJECT_INVALID)
                {
                    ai_SendMessages("There is not an item to modify!", AI_COLOR_RED, oPC);
                    int nItem = JsonGetInt(JsonObjectGet(jCraft, CRAFT_ITEM_SELECTION));
                    NuiSetBind(oPC, nToken, "item_combo_selected", JsonInt(nItem));
                    return;
                }
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
                json jCraft = GetLocalJson(oPC, CRAFT_JSON);
                int nItem = JsonGetInt(JsonObjectGet(jCraft, CRAFT_ITEM_SELECTION));
                if(nItem == 1) // Cloak
                {
                    object oItem = GetItemInSlot(INVENTORY_SLOT_CLOAK, oTarget);
                    if(nSelected == 1) SetHiddenWhenEquipped(oItem, TRUE);
                    else SetHiddenWhenEquipped(oItem, FALSE);
                }
                else if(nItem == 2) // Headgear
                {
                    object oItem = GetItemInSlot(INVENTORY_SLOT_HEAD, oTarget);
                    if(nSelected == 1) SetHiddenWhenEquipped(oItem, TRUE);
                    else SetHiddenWhenEquipped(oItem, FALSE);
                }
                else if(nItem == 4 && ai_GetIsShield(oItem))
                {
                    object oItem = GetItemInSlot(INVENTORY_SLOT_LEFTHAND, oTarget);
                    if(nSelected == 1) SetHiddenWhenEquipped(oItem, TRUE);
                    else SetHiddenWhenEquipped(oItem, FALSE);
                }
            }
        }
        else if(sEvent == "click")
        {
            if(sElem == "btn_info")
            {
                SetLocalObject(oPC, "CRAFT_INFO_ITEM", oItem);
                CreateItemGUIPanel(oPC, oItem);
            }
            //else if(sElem == "btn_wardrobe") CreateDresserGUIPanel(oPC, oTarget);
            // Random button to change items looks randomly.
            else if(sElem == "btn_randomize")
            {
                if(CanCraftItem(oPC, oItem, nToken))
                {
                    oItem = RandomizeItemsCraftAppearance(oPC, oTarget, nToken, oItem);
                    LockItemInCraftingWindow(oPC, oItem, oTarget, nToken);
                }
            }
            // Save any changes made to the selected item.
            else if(sElem == "btn_save")
            {
                SaveCraftedItem(oPC, oTarget, nToken);
            }
            // Selecte target to change clothing on.
            else if(sElem == "btn_select_target")
            {
                // Set this variable on the player so PEPS can run the targeting script for this plugin.
                SetLocalString(oPC, AI_PLUGIN_TARGET_SCRIPT, "pe_crafting");
                // Set Targeting variables.
                SetLocalString(oPC, AI_TARGET_MODE, "SELECT_TARGET");
                NuiDestroy(oPC, nToken);
                ai_SendMessages("Select either your charcter or a henchman to craft their equipment.", AI_COLOR_YELLOW, oPC);
                EnterTargetingMode(oPC, OBJECT_TYPE_CREATURE , MOUSECURSOR_EXAMINE, MOUSECURSOR_NOEXAMINE);
            }
            // Cancel any changes made to the selected item.
            else if(sElem == "btn_cancel")
            {
                // If the button is on cancel then clear the item.
                if(JsonGetString(NuiGetBind(oPC, nToken, "btn_cancel_label")) == "Cancel")
                {
                    CancelCraftedItem(oPC, oTarget);
                    ClearItemInCraftingWindow(oPC, oItem, oTarget, nToken);
                }
                // If the button is on Exit not Cancel then exit.
                else
                {
                    AssignCommand(oPC, RestoreCameraFacing());
                    AttachCamera(oPC, oPC);
                    DeleteLocalObject(oPC, CRAFT_TARGET);
                    DeleteLocalObject(oPC, "CRAFT_INFO_ITEM");
                    NuiDestroy(oPC, nToken);
                    nToken = NuiFindWindow(oPC, "craft_item_nui");
                    if(nToken) NuiDestroy(oPC, nToken);
                    if(GetLocalInt(oPC, CRAFT_ULTRALIGHT))
                    {
                        RemoveTagedEffects(oTarget, CRAFT_ULTRALIGHT);
                        DeleteLocalInt(oPC, CRAFT_ULTRALIGHT);
                    }
                    if(GetLocalInt(oPC, CRAFT_HIGHLIGHT))
                    {
                        RemoveTagedEffects(oTarget, CRAFT_HIGHLIGHT);
                        DeleteLocalInt(oPC, CRAFT_HIGHLIGHT);
                    }
                }
            }
            // Get the previous model of the selected item.
            else if(GetStringLeft(sElem, 9) == "btn_prev_")
            {
                if(CanCraftItem(oPC, oItem, nToken))
                {
                    oItem = ChangeItemsAppearance(oPC, oTarget, nToken, oItem, -1, GetStringRight(sElem, 1));
                    LockItemInCraftingWindow(oPC, oItem, oTarget, nToken);
                }
            }
            // Get the next model of the selected item.
            else if(GetStringLeft(sElem, 9) == "btn_next_")
            {
                if(CanCraftItem(oPC, oItem, nToken))
                {
                    oItem = ChangeItemsAppearance(oPC, oTarget, nToken, oItem, 1, GetStringRight(sElem, 1));
                    LockItemInCraftingWindow(oPC, oItem, oTarget, nToken);
                }
            }
            else if(sElem == "btn_highlight")
            {
                if(GetLocalInt(oPC, CRAFT_HIGHLIGHT))
                {
                    RemoveTagedEffects(oTarget, CRAFT_HIGHLIGHT);
                    DeleteLocalInt(oPC, CRAFT_HIGHLIGHT);
                    NuiSetBind(oPC, nToken, "btn_highlight", JsonBool(FALSE));
                }
                else
                {
                    if(GetLocalInt(oPC, CRAFT_ULTRALIGHT))
                    {
                        RemoveTagedEffects(oTarget, CRAFT_ULTRALIGHT);
                        DeleteLocalInt(oPC, CRAFT_ULTRALIGHT);
                    }
                    SetLocalInt(oPC, CRAFT_HIGHLIGHT, TRUE);
                    effect eLight = EffectVisualEffect(VFX_DUR_LIGHT_WHITE_20);
                    eLight = TagEffect(eLight, CRAFT_HIGHLIGHT);
                    ApplyEffectToObject(DURATION_TYPE_PERMANENT, eLight, oTarget);
                    NuiSetBind(oPC, nToken, "btn_highlight", JsonBool(TRUE));
                }
            }
            else if(sElem == "btn_left_part_color")
            {
                int nBool = !JsonGetInt(JsonObjectGet(jCraft, CRAFT_LEFT_PART_COLOR));
                JsonObjectSetInplace(jCraft, CRAFT_LEFT_PART_COLOR, JsonInt(nBool));
                NuiSetBind(oPC, nToken, "btn_left_part_color", JsonBool(nBool));
                if(!nBool)
                {
                    if(JsonGetInt(NuiGetBind(oPC, nToken, "btn_right_part_color"))) nBool = FALSE;
                    else nBool = TRUE;
                }
                else nBool = FALSE;
                JsonObjectSetInplace(jCraft, CRAFT_ALL_COLOR, JsonInt(nBool));
                NuiSetBind(oPC, nToken, "btn_all_color", JsonBool(nBool));
                SetColorPalletPointer(oPC, nToken, oItem);
            }
            else if(sElem == "btn_all_color")
            {
                JsonObjectSetInplace(jCraft, CRAFT_ALL_COLOR, JsonInt(TRUE));
                NuiSetBind(oPC, nToken, "btn_all_color", JsonBool(TRUE));
                JsonObjectSetInplace(jCraft, CRAFT_LEFT_PART_COLOR, JsonInt(FALSE));
                NuiSetBind(oPC, nToken, "btn_left_part_color", JsonBool(FALSE));
                JsonObjectSetInplace(jCraft, CRAFT_RIGHT_PART_COLOR, JsonInt(FALSE));
                NuiSetBind(oPC, nToken, "btn_right_part_color", JsonBool(FALSE));
                SetColorPalletPointer(oPC, nToken, oItem);
            }
            else if(sElem == "btn_right_part_color")
            {
                int nBool = !JsonGetInt(JsonObjectGet(jCraft, CRAFT_RIGHT_PART_COLOR));
                JsonObjectSetInplace(jCraft, CRAFT_RIGHT_PART_COLOR, JsonInt(nBool));
                NuiSetBind(oPC, nToken, "btn_right_part_color", JsonBool (nBool));
                if(!nBool)
                {
                    if(JsonGetInt(NuiGetBind(oPC, nToken, "btn_left_part_color"))) nBool = FALSE;
                    else nBool = TRUE;
                }
                else nBool = FALSE;
                JsonObjectSetInplace(jCraft, CRAFT_ALL_COLOR, JsonInt(nBool));
                NuiSetBind(oPC, nToken, "btn_all_color", JsonBool (nBool));
                SetColorPalletPointer(oPC, nToken, oItem);
            }
            else if(sElem == "btn_right_part_reset")
            {
                int nIndex;
                int nModelSelected = GetArmorModelSelected(oPC);
                int nMaterialSelected = JsonGetInt(JsonObjectGet(jCraft, CRAFT_MATERIAL_SELECTION));
                object oNewItem;
                if(nModelSelected == ITEM_APPR_ARMOR_MODEL_NECK ||
                   nModelSelected == ITEM_APPR_ARMOR_MODEL_TORSO ||
                   nModelSelected == ITEM_APPR_ARMOR_MODEL_BELT ||
                   nModelSelected == ITEM_APPR_ARMOR_MODEL_PELVIS ||
                   nModelSelected == ITEM_APPR_ARMOR_MODEL_ROBE)
                {
                    nIndex = ITEM_APPR_ARMOR_NUM_COLORS + (nModelSelected * ITEM_APPR_ARMOR_NUM_COLORS) + nMaterialSelected;
                    oNewItem = CopyItemAndModify(oItem, ITEM_APPR_TYPE_ARMOR_COLOR, nIndex, 255, TRUE);
                    DestroyObject(oItem);
                }
                else
                {
                    nIndex = ITEM_APPR_ARMOR_NUM_COLORS + (nModelSelected * ITEM_APPR_ARMOR_NUM_COLORS) + nMaterialSelected;
                    oNewItem = CopyItemAndModify(oItem, ITEM_APPR_TYPE_ARMOR_COLOR, nIndex, 255, TRUE);
                    DestroyObject(oItem);
                }
                // Lock the new item so they can't change it on the character.
                LockItemInCraftingWindow(oPC, oNewItem, oTarget, nToken);
                // Equip new item.
                AssignCommand(oTarget, ActionEquipItem(oNewItem, INVENTORY_SLOT_CHEST));
                // Fix buttons.
                NuiSetBind(oPC, nToken, "btn_right_part_color", JsonBool(FALSE));
                JsonObjectSetInplace(jCraft, CRAFT_RIGHT_PART_COLOR, JsonInt(FALSE));
                int nLeft = JsonGetInt(NuiGetBind(oPC, nToken, "btn_left_part_color"));
                NuiSetBind(oPC, nToken, "btn_all_color", JsonBool(!nLeft));
                JsonObjectSetInplace(jCraft, CRAFT_ALL_COLOR, JsonInt(!nLeft));
                NuiSetBind(oPC, nToken, "btn_right_part_reset_event", JsonBool(FALSE));
                nLeft = JsonGetInt(NuiGetBind(oPC, nToken, "btn_left_part_reset_event"));
                NuiSetBind(oPC, nToken, "btn_all_reset_event", JsonBool(nLeft));
                SetColorPalletPointer(oPC, nToken, oNewItem);
            }
            else if(sElem == "btn_all_reset")
            {
                int nIndex, nColor;
                json jItem = ObjectToJson(oItem, TRUE);
                string sColor, sPartName;
                for(nIndex = 0;nIndex < 19;nIndex++)
                {
                    sPartName = "APart_" + IntToString(nIndex) + "_Col_";
                    for(nColor = 0;nColor < 6;nColor++)
                    {
                        sColor = IntToString(nColor);
                        if(JsonGetType(GffGetByte(jItem, sPartName + sColor)) != JSON_TYPE_NULL)
                        {
                            jItem = GffRemoveByte(jItem, sPartName + sColor);
                        }
                    }
                }
                object oNewItem = JsonToObject(jItem, GetLocation(oTarget), oTarget, TRUE);
                AssignCommand(oTarget, ActionEquipItem(oNewItem, INVENTORY_SLOT_CHEST));
                DestroyObject(oItem);
                // Fix buttons.
                NuiSetBind(oPC, nToken, "btn_right_part_color", JsonBool(FALSE));
                JsonObjectSetInplace(jCraft, CRAFT_RIGHT_PART_COLOR, JsonInt(FALSE));
                NuiSetBind(oPC, nToken, "btn_all_color", JsonBool(TRUE));
                JsonObjectSetInplace(jCraft, CRAFT_ALL_COLOR, JsonInt(TRUE));
                NuiSetBind(oPC, nToken, "btn_left_part_color", JsonBool(FALSE));
                JsonObjectSetInplace(jCraft, CRAFT_RIGHT_PART_COLOR, JsonInt(FALSE));
                NuiSetBind(oPC, nToken, "btn_right_part_reset_event", JsonBool(FALSE));
                NuiSetBind(oPC, nToken, "btn_all_reset_event", JsonBool(FALSE));
                NuiSetBind(oPC, nToken, "btn_left_part_reset_event", JsonBool(FALSE));
                SetColorPalletPointer(oPC, nToken, oNewItem);
            }
            else if(sElem == "btn_left_part_reset")
            {
                int nModelSelected = GetArmorModelSelected(oPC);
                if (nModelSelected == ITEM_APPR_ARMOR_MODEL_RTHIGH) nModelSelected = nModelSelected - 1;
                else nModelSelected = nModelSelected + 1;
                int nMaterialSelected = JsonGetInt(JsonObjectGet(jCraft, CRAFT_MATERIAL_SELECTION));
                int nIndex = ITEM_APPR_ARMOR_NUM_COLORS + (nModelSelected * ITEM_APPR_ARMOR_NUM_COLORS) + nMaterialSelected;
                object oNewItem = CopyItemAndModify(oItem, ITEM_APPR_TYPE_ARMOR_COLOR, nIndex, 255, TRUE);
                DestroyObject(oItem);
                // Lock the new item so they can't change it on the character.
                LockItemInCraftingWindow(oPC, oNewItem, oTarget, nToken);
                // Equip new item.
                AssignCommand(oTarget, ActionEquipItem(oNewItem, INVENTORY_SLOT_CHEST));
                // Fix buttons.
                NuiSetBind(oPC, nToken, "btn_left_part_color", JsonBool(FALSE));
                JsonObjectSetInplace(jCraft, CRAFT_LEFT_PART_COLOR, JsonInt(FALSE));
                int nRight = JsonGetInt(NuiGetBind(oPC, nToken, "btn_right_part_color"));
                NuiSetBind(oPC, nToken, "btn_all_color", JsonBool(!nRight));
                JsonObjectSetInplace(jCraft, CRAFT_ALL_COLOR, JsonInt(!nRight));
                NuiSetBind(oPC, nToken, "btn_left_part_reset_event", JsonBool(FALSE));
                nRight = JsonGetInt(NuiGetBind(oPC, nToken, "btn_right_part_reset_event"));
                NuiSetBind(oPC, nToken, "btn_all_reset_event", JsonBool(nRight));
                SetColorPalletPointer(oPC, nToken, oNewItem);
            }
            // They have changed the material (color item) for the item.
            else if(GetStringLeft(sElem, 13) == "btn_material_")
            {
                int nSelected = StringToInt(GetStringRight(sElem, 1));
                SetMaterialButtons(oPC, nToken, nSelected);
                JsonObjectSetInplace(jCraft, CRAFT_MATERIAL_SELECTION, JsonInt(nSelected));
                // Change the pallet for the correct material.
                string sColorPallet;
                if(nSelected < 4)
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
                SetColorPalletPointer(oPC, nToken, oItem);
            }
        }
        if(sEvent == "mousedown")
        {
            int nMouseButton = JsonGetInt(JsonObjectGet(NuiGetEventPayload(), "mouse_btn"));
            if(nMouseButton == NUI_MOUSE_BUTTON_RIGHT)
            {
                AssignCommand(oPC, PlaySound("gui_button"));
                if(sElem == "btn_highlight")
                {
                    if(GetLocalInt(oPC, CRAFT_ULTRALIGHT))
                    {
                        RemoveTagedEffects(oTarget, CRAFT_ULTRALIGHT);
                        DeleteLocalInt(oPC, CRAFT_ULTRALIGHT);
                        NuiSetBind(oPC, nToken, "btn_highlight", JsonBool(FALSE));
                    }
                    else
                    {
                        if(GetLocalInt(oPC, CRAFT_HIGHLIGHT))
                        {
                            RemoveTagedEffects(oTarget, CRAFT_HIGHLIGHT);
                            DeleteLocalInt(oPC, CRAFT_HIGHLIGHT);
                        }
                        SetLocalInt(oPC, CRAFT_ULTRALIGHT, TRUE);
                        effect eLight = EffectVisualEffect(VFX_DUR_ULTRAVISION);
                        eLight = TagEffect(eLight, CRAFT_ULTRALIGHT);
                        ApplyEffectToObject(DURATION_TYPE_PERMANENT, eLight, oTarget);
                        NuiSetBind(oPC, nToken, "btn_highlight", JsonBool(TRUE));
                    }
                }
            }
        }
    }
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
int GetMaxSimpleItemNumber(object oItem, int nBaseItemType)
{
    int nResType, nMaxNumber, nModelNumber;
    string sModelNumber, sModelName = Get2DAString("baseitems", "ItemClass", nBaseItemType) + "_";
    //ai_Debug("pe_crafting", "804", "sModelName: " + sModelName + sModelNumber +
    //         " nModelNumber: " + IntToString(nModelNumber));
    while(nModelNumber < 999)
    {
        if(nModelNumber < 10) sModelNumber = "00" + IntToString(nModelNumber);
        else if(nModelNumber < 100) sModelNumber = "0" + IntToString(nModelNumber);
        else sModelNumber = IntToString(nModelNumber);
        if(nBaseItemType == BASE_ITEM_CLOAK) nResType = RESTYPE_PLT;
        else nResType = RESTYPE_MDL;
        if(ResManGetAliasFor(sModelName + sModelNumber, nResType) != "") nMaxNumber++;
        nModelNumber++;
        //ai_Debug("pe_crafting", "841", "sModelName: " + sModelName + sModelNumber +
        //         " nModelNumber: " + IntToString(nModelNumber));
    }
    return nMaxNumber;
}
int GetSimpleItemNumber(object oItem, int nModelNumber, int nBaseItemType)
{
    int nResType, nIndex, nCounter;
    string sModelNumber, sModelName = Get2DAString("baseitems", "ItemClass", nBaseItemType) + "_";
    //ai_Debug("pe_crafting", "804", "sModelName: " + sModelName + sModelNumber +
    //         " nModelNumber: " + IntToString(nModelNumber));
    while(nIndex <= 999)
    {
        if(nIndex < 10) sModelNumber = "00" + IntToString(nIndex);
        else if(nIndex < 100) sModelNumber = "0" + IntToString(nIndex);
        else sModelNumber = IntToString(nIndex);
        if(nBaseItemType == BASE_ITEM_CLOAK) nResType = RESTYPE_PLT;
        else nResType = RESTYPE_MDL;
        if(ResManGetAliasFor(sModelName + sModelNumber, nResType) != "") nCounter++;
        if(nCounter == nModelNumber) return nIndex;
        nIndex++;
        //ai_Debug("pe_crafting", "841", "sModelName: " + sModelName + sModelNumber +
        //         " nModelNumber: " + IntToString(nModelNumber));
    }
    return nIndex;
}
int GetMaxWeaponModuleNumber(struct stWeaponAppearance stWA)
{
    int nBaseItemType = GetBaseItemType(stWA.oItem);
    stWA.nColor = 1;
    stWA.nModel = 99;
    stWA.sPart = "t";
    string sModelNumber;
    string sModelName = Get2DAString("baseitems", "ItemClass", nBaseItemType) + "_" + stWA.sPart + "_";
    int nModelNumber = (stWA.nModel * 10) + stWA.nColor;
    if(nModelNumber < 10) sModelNumber = "00" + IntToString(nModelNumber);
    else if(nModelNumber < 100) sModelNumber = "0" + IntToString(nModelNumber);
    else sModelNumber = IntToString(nModelNumber);
    //SendMessageToPC(GetFirstPC(), "pe_crafting, 780, sModel: " + sModelName + sModelNumber +
    //         " nModel: " + IntToString(stWA.nModel) + " nColor: " + IntToString(stWA.nColor));
    while(ResManGetAliasFor(sModelName + sModelNumber, RESTYPE_MDL) == "")
    {
        stWA.nModel += -1;
        // Create the model name.
        nModelNumber = (stWA.nModel * 10) + stWA.nColor;
        if(nModelNumber < 100) sModelNumber = "0" + IntToString(nModelNumber);
        else sModelNumber = IntToString(nModelNumber);
        //SendMessageToPC(GetFirstPC(), "pe_crafting, 789, sModel: " + sModelName + sModelNumber +
        //         " nModel: " + IntToString(stWA.nModel) + " nColor: " + IntToString(stWA.nColor));
    }
    return stWA.nModel;
}
struct stWeaponAppearance GetNextWeaponAppearance(struct stWeaponAppearance stWA, int nDirection)
{
    int nBaseItemType = GetBaseItemType(stWA.oItem);
    string sModelNumber;
    string sModelName = Get2DAString("baseitems", "ItemClass", nBaseItemType) + "_" + stWA.sPart + "_";
    // Get next/previous color/model.
    stWA.nColor += nDirection;
    if(stWA.nColor > 9)
    {
        stWA.nColor = 1;
        stWA.nModel += nDirection;
        if(stWA.nModel > CRAFT_MAX_WEAPON_MODEL_NUMBER) stWA.nModel = 1;
    }
    else if(stWA.nColor < 1)
    {
        stWA.nColor = 9;
        stWA.nModel += nDirection;
        if(stWA.nModel < 1) stWA.nModel = CRAFT_MAX_WEAPON_MODEL_NUMBER;
    }
    int nModelNumber = (stWA.nModel * 10) + stWA.nColor;
    if(nModelNumber < 10) sModelNumber = "00" + IntToString(nModelNumber);
    else if(nModelNumber < 100) sModelNumber = "0" + IntToString(nModelNumber);
    else sModelNumber = IntToString(nModelNumber);
    //SendMessageToPC(GetFirstPC(), "pe_crafting, 778, sModel: " + sModelName + sModelNumber +
    //         " nModel: " + IntToString(stWA.nModel) + " nColor: " + IntToString(stWA.nColor));
    while(ResManGetAliasFor(sModelName + sModelNumber, RESTYPE_MDL) == "")
    {
        // Get next/previous color/model.
        stWA.nColor += nDirection;
        if(stWA.nColor > 9)
        {
            stWA.nColor = 1;
            stWA.nModel += nDirection;
            if(stWA.nModel > CRAFT_MAX_WEAPON_MODEL_NUMBER) stWA.nModel = 1;
        }
        else if(stWA.nColor < 1)
        {
            stWA.nColor = 9;
            stWA.nModel += nDirection;
            if(stWA.nModel < 1) stWA.nModel = CRAFT_MAX_WEAPON_MODEL_NUMBER;
        }
        // Create the model name.
        nModelNumber = (stWA.nModel * 10) + stWA.nColor;
        if(nModelNumber < 100) sModelNumber = "0" + IntToString(nModelNumber);
        else sModelNumber = IntToString(nModelNumber);
        //SendMessageToPC(GetFirstPC(), "pe_crafting, 800, sModel: " + sModelName + sModelNumber +
        //         " nModel: " + IntToString(stWA.nModel) + " nColor: " + IntToString(stWA.nColor));
    }
    return stWA;
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
    if(ai_GetIsWeapon(oItem))
    {
        // Freeze animations - vfx 352?
        if(sPart == "t") nModelSelected = 2;
        else if(sPart == "m") nModelSelected = 1;
        else if(sPart == "b") nModelSelected = 0;
        sModelName = Get2DAString("baseitems", "ItemClass", GetBaseItemType(oItem)) + "_" + sPart + "_";
        struct stWeaponAppearance stWA;
        stWA.oItem = oItem;
        stWA.sPart = sPart;
        stWA.nModel = GetItemAppearance(oItem, ITEM_APPR_TYPE_WEAPON_MODEL, nModelSelected);
        stWA.nColor = GetItemAppearance(oItem, ITEM_APPR_TYPE_WEAPON_COLOR, nModelSelected);
        stWA = GetNextWeaponAppearance(stWA, nDirection);
        json jItem = ObjectToJson(oItem, TRUE);
        int nModelNumber = stWA.nModel * 10 + stWA.nColor;
        jItem = GffReplaceByte(jItem, "ModelPart" + IntToString(nModelSelected + 1), nModelNumber);
        jItem = GffReplaceWord(jItem, "xModelPart" + IntToString(nModelSelected + 1), nModelNumber);
        oNewItem = JsonToObject(jItem, GetLocation(oTarget), oTarget, TRUE);
        AssignCommand(oTarget, ClearAllActions(TRUE));
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
        //SendMessageToPC(oPC, "pe_crafting, 826, nModelNumber: " + IntToString(nModelNumber) +
        //                     " sPart: " + sPart + " nModelSelected: " + IntToString(nModelSelected));
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
            //SendMessageToPC(oPC, "pe_crafting, 842, sModelName: " + sModelName + sModelNumber +
            //         " nModelNumber: " + IntToString(nModelNumber) + " sCurrentACBonus: " + sCurrentACBonus +
            //         " sACBonus: " + sACBonus + " nModelSelected: " + IntToString(nModelSelected));
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
                //SendMessageToPC(oPC, "pe_crafting, 854, sModelName: " + sModelName + sModelNumber +
                //         " nModelNumber: " + IntToString(nModelNumber) + " sACBonus: " + sACBonus +
                //         " nModelSelected: " + IntToString(nModelSelected));
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
            //SendMessageToPC(oPC, "pe_crafting, 866, sModelName: " + sModelName + sModelNumber +
            //         " nModelNumber: " + IntToString(nModelNumber) + " nModelSelected: " + IntToString(nModelSelected));
            while(ResManGetAliasFor(sModelName + sModelNumber, RESTYPE_MDL) == "")
            {
                nModelNumber += nDirection;
                if (nModelNumber > CRAFT_MAX_MODEL_NUMBER) nModelNumber = 0;
                else if (nModelNumber < 0) nModelNumber = CRAFT_MAX_MODEL_NUMBER;
                if(nModelNumber < 10) sModelNumber = "00" + IntToString(nModelNumber);
                else if(nModelNumber < 100) sModelNumber = "0" + IntToString(nModelNumber);
                else sModelNumber = IntToString(nModelNumber);
                //SendMessageToPC(oPC, "pe_crafting, 705, sModelName: " + sModelName + sModelNumber +
                //         " nModelNumber: " + IntToString(nModelNumber) + " nModelSelected: " + IntToString(nModelSelected));
            }
            oNewItem = CopyItemAndModify (oItem, ITEM_APPR_TYPE_ARMOR_MODEL, nModelSelected, nModelNumber, TRUE);
            DestroyObject (oItem);
            // If using the linked menu option then change the left side too.
            if(sPart == "m" && (nModelSelected != ITEM_APPR_ARMOR_MODEL_NECK &&
                nModelSelected != ITEM_APPR_ARMOR_MODEL_BELT &&
                nModelSelected != ITEM_APPR_ARMOR_MODEL_PELVIS &&
                nModelSelected != ITEM_APPR_ARMOR_MODEL_ROBE))
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
                // Using labels for Mobile.
                //NuiSetBind(oPC, nToken, "txt_model_number_t", JsonString(IntToString(nModelNumber)));
                //NuiSetBind(oPC, nToken, "txt_model_number_m", JsonString(IntToString(nModelNumber)));
                //NuiSetBind(oPC, nToken, "txt_model_number_b", JsonString(IntToString(nModelNumber)));
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
        if(nModelNumber > CRAFT_MAX_MODEL_NUMBER) nModelNumber = 0;
        else if (nModelNumber < 0) nModelNumber = CRAFT_MAX_MODEL_NUMBER;
        if(nModelNumber < 10) sModelNumber = "00" + IntToString(nModelNumber);
        else if(nModelNumber < 100) sModelNumber = "0" + IntToString(nModelNumber);
        else sModelNumber = IntToString(nModelNumber);
        //ai_Debug("pe_crafting", "804", "sModelName: " + sModelName + sModelNumber +
        //         " nModelNumber: " + IntToString(nModelNumber));
        while(ResManGetAliasFor(sModelName + sModelNumber, nResType) == "")
        {
            nModelNumber += nDirection;
            if(nModelNumber > CRAFT_MAX_MODEL_NUMBER) nModelNumber = 0;
            else if(nModelNumber < 0) nModelNumber = CRAFT_MAX_MODEL_NUMBER;
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
    return oNewItem;
}
object RandomizeItemsCraftAppearance(object oPC, object oTarget, int nToken, object oItem)
{
    // Get the item we are changing.
    json jCraft = GetLocalJson(oPC, CRAFT_JSON);
    int nItemSelected = JsonGetInt(JsonObjectGet(jCraft, CRAFT_ITEM_SELECTION));
    int nBaseItemType = GetBaseItemType(oItem);
    object oNewItem;
    if(ai_GetIsWeapon(oItem))
    {
        int nRollTop, nRollMid, nRollBottom;
        int nColorTop, nColorMid, nColorBottom;
        struct stWeaponAppearance stWA;
        stWA.oItem = oItem;
        int nMaxModuleNumber = GetMaxWeaponModuleNumber(stWA);
        nRollTop = Random(nMaxModuleNumber) + 1;
        // Check bows as they must randomize to the same top, middle, and bottom otherwise they look bad.
        if(nBaseItemType == BASE_ITEM_LONGBOW || nBaseItemType == BASE_ITEM_SHORTBOW)
        {
            nRollMid = nRollTop;
            nRollBottom = nRollTop;
        }
        // Randomize each item individualy for other weapons.
        else
        {
            nRollMid = Random(nMaxModuleNumber) + 1;
            nRollBottom = Random(nMaxModuleNumber) + 1;
        }
        nColorTop = Random(9) + 1;
        nColorMid = Random(9) + 1;
        nColorBottom = Random(9) + 1;
        // Change weapons model.
        stWA.sPart = "t";
        stWA.nModel = nRollTop;
        stWA.nColor = nColorTop;
        stWA = GetNextWeaponAppearance(stWA, -1);
        json jItem = ObjectToJson(oItem, TRUE);
        //ai_Debug("pe_crafting", "614", "ModelPart" + IntToString(nModelSelected + 1) +
        //         " nModelNumber: " + IntToString(nModelNumber));
        jItem = GffReplaceByte(jItem, "ModelPart" + IntToString(3), stWA.nModel * 10 + stWA.nColor);
        jItem = GffReplaceWord(jItem, "xModelPart" + IntToString(3), stWA.nModel * 10 + stWA.nColor);
        NuiSetBind(oPC, nToken, "txt_model_number_" + stWA.sPart, JsonString(IntToString(stWA.nModel * 10 + stWA.nColor)));
        stWA.sPart = "m";
        stWA.nModel = nRollMid;
        stWA.nColor = nColorMid;
        stWA = GetNextWeaponAppearance(stWA, -1);
        jItem = GffReplaceByte(jItem, "ModelPart" + IntToString(2), stWA.nModel * 10 + stWA.nColor);
        jItem = GffReplaceWord(jItem, "xModelPart" + IntToString(2), stWA.nModel * 10 + stWA.nColor);
        NuiSetBind(oPC, nToken, "txt_model_number_" + stWA.sPart, JsonString(IntToString(stWA.nModel * 10 + stWA.nColor)));
        stWA.sPart = "b";
        stWA.nModel = nRollBottom;
        stWA.nColor = nColorBottom;
        stWA = GetNextWeaponAppearance(stWA, -1);
        jItem = GffReplaceByte(jItem, "ModelPart" + IntToString(1), stWA.nModel * 10 + stWA.nColor);
        jItem = GffReplaceWord(jItem, "xModelPart" + IntToString(1), stWA.nModel * 10 + stWA.nColor);
        NuiSetBind(oPC, nToken, "txt_model_number_" + stWA.sPart, JsonString(IntToString(stWA.nModel * 10 + stWA.nColor)));
        oNewItem = JsonToObject(jItem, GetLocation(oTarget), oTarget, TRUE);
        AssignCommand(oTarget, ClearAllActions(TRUE));
        DestroyObject(oItem);
        // Item selected 3 is the right hand, 4 is the left hand.
        if (nItemSelected == 3) AssignCommand(oTarget, ActionEquipItem(oNewItem, INVENTORY_SLOT_RIGHTHAND));
        else AssignCommand(oTarget, ActionEquipItem(oNewItem, INVENTORY_SLOT_LEFTHAND));
    }
    // Armor.
    else if(nItemSelected == 0)
    {
        int nRoll, nRoll2;
        json jItem = ObjectToJson(oItem, TRUE);
        // Randomize the models.
        // Randomize Torso
        //jItem = GffReplaceByte(jItem, "ArmorPart_Torso", );
        //jItem = GffReplaceWord(jItem, "xArmorPart_Torso", );
        // Randomize the colors.
        nRoll = Random(175) + 1;
        if(d100() < 50) nRoll2 = nRoll + Random(5) - 3;
        else nRoll2 = Random(175) + 1;
        jItem = GffReplaceByte(jItem, "Cloth1Color", nRoll);
        jItem = GffReplaceByte(jItem, "Cloth2Color", nRoll2);
        nRoll = Random(175) + 1;
        if(d100() < 50) nRoll2 = nRoll + Random(5) - 3;
        else nRoll2 = Random(175) + 1;
        jItem = GffReplaceByte(jItem, "Leather1Color", nRoll);
        jItem = GffReplaceByte(jItem, "Leather2Color", nRoll2);
        nRoll = Random(175) + 1;
        if(d100() < 50) nRoll2 = nRoll + Random(5) - 3;
        else nRoll2 = Random(175) + 1;
        jItem = GffReplaceByte(jItem, "Metal1Color", nRoll);
        jItem = GffReplaceByte(jItem, "Metal2Color", nRoll2);
        DestroyObject(oItem);
        oNewItem = JsonToObject(jItem, GetLocation(oTarget), oTarget, TRUE);
        AssignCommand(oTarget, ActionEquipItem(oNewItem, INVENTORY_SLOT_CHEST));
    }
    // All other items.
    else
    {
        int nSlot;
        // Get max models and inventory slot.
        int nMaxModel = GetMaxSimpleItemNumber(oItem, nBaseItemType);
        if(nBaseItemType == BASE_ITEM_CLOAK) nSlot = INVENTORY_SLOT_CLOAK;
        else if(nBaseItemType == BASE_ITEM_HELMET) nSlot = INVENTORY_SLOT_HEAD;
        else if(nBaseItemType == BASE_ITEM_LARGESHIELD || nBaseItemType == BASE_ITEM_SMALLSHIELD ||
                nBaseItemType == BASE_ITEM_TOWERSHIELD) nSlot = INVENTORY_SLOT_LEFTHAND;
        int nRoll = Random(nMaxModel) + 1;
        int nModel = GetSimpleItemNumber(oItem, nRoll, nBaseItemType);
        json jItem = ObjectToJson(oItem, TRUE);
        jItem = GffReplaceByte(jItem, "ModelPart1", nModel);
        jItem = GffReplaceWord(jItem, "xModelPart1", nModel);
        if (nBaseItemType == BASE_ITEM_CLOAK || nBaseItemType == BASE_ITEM_HELMET)
        {
            jItem = GffReplaceByte(jItem, "Cloth1Color", Random(175) + 1);
            jItem = GffReplaceByte(jItem, "Cloth2Color", Random(175) + 1);
            jItem = GffReplaceByte(jItem, "Leather1Color", Random(175) + 1);
            jItem = GffReplaceByte(jItem, "Leather2Color", Random(175) + 1);
            jItem = GffReplaceByte(jItem, "Metal1Color", Random(175) + 1);
            jItem = GffReplaceByte(jItem, "Metal2Color", Random(175) + 1);
        }
        DestroyObject(oItem);
        oNewItem = JsonToObject(jItem, GetLocation(oTarget), oTarget, TRUE);
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
int GetColorPalletId(object oPC, int nToken)
{
    float fScale = IntToFloat(GetPlayerDeviceProperty(oPC, PLAYER_DEVICE_PROPERTY_GUI_SCALE)) / 100.0f;
    json jPayload = NuiGetEventPayload();
    json jMousePosition = JsonObjectGet(jPayload, "mouse_pos");
    json jX = JsonObjectGet(jMousePosition, "x");
    json jY = JsonObjectGet(jMousePosition, "y");
    float fX = StringToFloat(JsonDump (jX));
    float fY = StringToFloat(JsonDump (jY));
    float fCellSize = 20.0f * fScale;
    int nCellX = FloatToInt(fX / fCellSize);
    int nCellY = FloatToInt(fY / fCellSize);
    if(nCellX < 0) nCellX = 0;
    else if (nCellX > 16) nCellX = 16;
    if(nCellY < 0) nCellY = 0;
    else if(nCellY > 11) nCellY = 11;
    NuiSetBind(oPC, nToken, "color_pallet_pointer", NuiRect(IntToFloat(nCellX * 20), IntToFloat(nCellY * 20), 20.0, 20.0));
    return nCellX + nCellY * 16;
}
void SetColorPalletPointer(object oPC, int nToken, object oItem)
{
    json jCraft = GetLocalJson(oPC, CRAFT_JSON);
    int nMaterialSelected = JsonGetInt(JsonObjectGet(jCraft, CRAFT_MATERIAL_SELECTION));
    int nModelSelected = GetArmorModelSelected(oPC);
    int nColor;
    if(!JsonGetInt(NuiGetBind(oPC, nToken, "btn_all_color")))
    {
        int nIndex = ITEM_APPR_ARMOR_NUM_COLORS + (nModelSelected * ITEM_APPR_ARMOR_NUM_COLORS) + nMaterialSelected;
        nColor = GetItemAppearance(oItem, ITEM_APPR_TYPE_ARMOR_COLOR, nIndex);
    }
    else nColor = 255;
    if(nColor == 255) nColor = GetItemAppearance(oItem, ITEM_APPR_TYPE_ARMOR_COLOR, nMaterialSelected);
    float fPointX = IntToFloat((nColor - ((nColor / 16) * 16)) * 20);
    float fPointY = IntToFloat((nColor / 16) * 20);
    NuiSetBind(oPC, nToken, "color_pallet_pointer", NuiRect(fPointX, fPointY, 20.0, 20.0));
}
void LockItemInCraftingWindow(object oPC, object oItem, object oTarget, int nToken)
{
    NuiSetBind(oPC, nToken, "item_combo_event", JsonBool(FALSE));
    NuiSetBind(oPC, nToken, "btn_cancel_label", JsonString("Cancel"));
    NuiSetBind(oPC, nToken, "btn_cancel_tooltip", JsonString("  Revert back to the original items appearance"));
    NuiSetBind(oPC, nToken, "btn_save_event", JsonBool(TRUE));
    NuiSetBind(oPC, nToken, "btn_select_target_event", JsonBool(FALSE));
    NuiSetBind(oPC, nToken, "btn_info_event", JsonBool(FALSE));
    NuiSetBind(oPC, nToken, "btn_wardrobe_event", JsonBool(FALSE));
    // Make sure the item information window is closed.
    nToken = NuiFindWindow(oPC, "craft_item_nui");
    if(nToken) NuiDestroy(oPC, nToken);
}
void ClearItemInCraftingWindow(object oPC, object oItem, object oTarget, int nToken)
{
    NuiSetBind(oPC, nToken, "btn_save_event", JsonBool(FALSE));
    NuiSetBind(oPC, nToken, "item_combo_event", JsonBool(TRUE));
    NuiSetBind(oPC, nToken, "btn_select_target_event", JsonBool(TRUE));
    NuiSetBind(oPC, nToken, "btn_info_event", JsonBool(TRUE));
    NuiSetBind(oPC, nToken, "btn_wardrobe_event", JsonBool(TRUE));
    NuiSetBind(oPC, nToken, "btn_cancel_label", JsonString("Exit"));
    NuiSetBind(oPC, nToken, "btn_cancel_tooltip", JsonString("  Exit the crafting menu"));
}
void SaveCraftedItem(object oPC, object oTarget, int nToken)
{
    json jCraft = GetLocalJson(oPC, CRAFT_JSON);
    int nItemSelected = JsonGetInt(JsonObjectGet(jCraft, CRAFT_ITEM_SELECTION));
    object oItem = GetSelectedItem(oTarget, nItemSelected);
    ClearItemInCraftingWindow(oPC, oItem, oTarget, nToken);
    DestroyObject(GetLocalObject(oPC, CRAFT_ORIGINAL_ITEM));
    DeleteLocalObject(oPC, CRAFT_ORIGINAL_ITEM);
}
int CanCraftItem(object oPC, object oItem, int nToken, int bPasteCheck = FALSE)
{
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
    if(GetLocalObject(oPC, CRAFT_ORIGINAL_ITEM) == OBJECT_INVALID)
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
int GetHasPartColor(object oItem, int nPart, string sSide)
{
    json jItem = ObjectToJson(oItem);
    string sPartName = "APart_";
    if(sSide == "Left")
    {
        // Note: Right Thigh and Left Thigh are backwards so this fixes that!
        if (nPart == ITEM_APPR_ARMOR_MODEL_RTHIGH) nPart--;
        else nPart++;
    }
    sPartName += IntToString(nPart) + "_Col_";
    int nPartColor = JsonGetInt(GffGetByte(jItem, sPartName + "0"));
    nPartColor += JsonGetInt(GffGetByte(jItem, sPartName + "1"));
    nPartColor += JsonGetInt(GffGetByte(jItem, sPartName + "2"));
    nPartColor += JsonGetInt(GffGetByte(jItem, sPartName + "3"));
    nPartColor += JsonGetInt(GffGetByte(jItem, sPartName + "4"));
    nPartColor += JsonGetInt(GffGetByte(jItem, sPartName + "5"));
    //SendMessageToPC(GetFirstPC(), "sPartName: " + sPartName + " nPartColor: " + IntToString(nPartColor));
    return nPartColor;
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
        //NuiSetBind(oPC, nToken, "txt_model_number_t_enable", JsonBool(TRUE));
        //NuiSetBindWatch(oPC, nToken, "txt_model_number_t", TRUE);
        NuiSetBind(oPC, nToken, "txt_model_name_t", JsonString(sModelTop));
        NuiSetBind(oPC, nToken, "btn_prev_t_event", JsonBool(TRUE));
        NuiSetBind(oPC, nToken, "btn_next_t_event", JsonBool(TRUE));
        NuiSetBind(oPC, nToken, "middle_title_label", JsonString("Middle"));
        //NuiSetBind(oPC, nToken, "txt_model_number_m_enable", JsonBool(TRUE));
        //NuiSetBindWatch(oPC, nToken, "txt_model_number_m", TRUE);
        NuiSetBind(oPC, nToken, "txt_model_number_m", JsonString(sModelMiddle));
        NuiSetBind(oPC, nToken, "btn_prev_m_event", JsonBool(TRUE));
        NuiSetBind(oPC, nToken, "btn_next_m_event", JsonBool(TRUE));
        NuiSetBind(oPC, nToken, "bottom_title_label", JsonString("Bottom"));
        //NuiSetBind(oPC, nToken, "txt_model_number_b_enable", JsonBool(TRUE));
        //NuiSetBindWatch(oPC, nToken, "txt_model_number_b", TRUE);
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
            //NuiSetBind(oPC, nToken, "txt_model_number_t_event", JsonBool(FALSE));
            NuiSetBind(oPC, nToken, "txt_model_name_t", JsonString(""));
            NuiSetBind(oPC, nToken, "btn_prev_t_event", JsonBool(FALSE));
            NuiSetBind(oPC, nToken, "btn_next_t_event", JsonBool(FALSE));
            NuiSetBind(oPC, nToken, "middle_title_label", JsonString("Model"));
            //NuiSetBind(oPC, nToken, "txt_model_number_m_event", JsonBool(TRUE));
            NuiSetBind(oPC, nToken, "txt_model_number_m", JsonString(sModelMiddle));
            NuiSetBind(oPC, nToken, "btn_prev_m_event", JsonBool(TRUE));
            NuiSetBind(oPC, nToken, "btn_next_m_event", JsonBool(TRUE));
            NuiSetBind(oPC, nToken, "bottom_title_label", JsonString(""));
            //NuiSetBind(oPC, nToken, "txt_model_number_b_event", JsonBool(FALSE));
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
            NuiSetBind(oPC, nToken, "top_title_label", JsonString("Right"));
            //NuiSetBind(oPC, nToken, "txt_model_number_t_event", JsonBool(TRUE));
            NuiSetBind(oPC, nToken, "txt_model_number_t", JsonString(sModelTop));
            NuiSetBind(oPC, nToken, "btn_prev_t_event", JsonBool(TRUE));
            NuiSetBind(oPC, nToken, "btn_next_t_event", JsonBool(TRUE));
            NuiSetBind(oPC, nToken, "middle_title_label", JsonString("Right & Left"));
            //NuiSetBind(oPC, nToken, "txt_model_number_m_event", JsonBool(TRUE));
            NuiSetBind(oPC, nToken, "txt_model_number_m", JsonString(sModelTop));
            NuiSetBind(oPC, nToken, "btn_prev_m_event", JsonBool(TRUE));
            NuiSetBind(oPC, nToken, "btn_next_m_event", JsonBool(TRUE));
            NuiSetBind(oPC, nToken, "bottom_title_label", JsonString("Left"));
            //NuiSetBind(oPC, nToken, "txt_model_number_b_event", JsonBool(TRUE));
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
        //NuiSetBind(oPC, nToken, "txt_model_number_t_event", JsonBool(FALSE));
        NuiSetBind(oPC, nToken, "txt_model_number_t", JsonString(""));
        NuiSetBind(oPC, nToken, "btn_prev_t_event", JsonBool(FALSE));
        NuiSetBind(oPC, nToken, "btn_next_t_event", JsonBool(FALSE));
        //NuiSetBind(oPC, nToken, "txt_model_number_m_event", JsonBool(TRUE));
        NuiSetBind(oPC, nToken, "txt_model_number_m", JsonString(sModelMiddle));
        NuiSetBind(oPC, nToken, "middle_title_label", JsonString("Model"));
        NuiSetBind(oPC, nToken, "btn_prev_m_event", JsonBool(TRUE));
        NuiSetBind(oPC, nToken, "btn_next_m_event", JsonBool(TRUE));
        //NuiSetBind(oPC, nToken, "txt_model_number_b_event", JsonBool(FALSE));
        NuiSetBind(oPC, nToken, "txt_model_number_b", JsonString(""));
        NuiSetBind(oPC, nToken, "bottom_title_label", JsonString(""));
        NuiSetBind(oPC, nToken, "btn_prev_b_event", JsonBool(FALSE));
        NuiSetBind(oPC, nToken, "btn_next_b_event", JsonBool(FALSE));
    }
    // Color Group
    if(ai_GetIsWeapon(oItem) || ai_GetIsShield(oItem))
    {
        // Need to disable the color widgets.
        // Row 511
        NuiSetBind(oPC, nToken, "color_pallet_image", JsonString("gui_pal_tattoo"));
        NuiSetBind(oPC, nToken, "color_pallet_image_event", JsonBool(FALSE));
        // Row 512 - Label Part to Color
        // Row 5l3
        NuiSetBind(oPC, nToken, "btn_right_part_color_event", JsonBool(FALSE));
        NuiSetBind(oPC, nToken, "btn_all_color_event", JsonBool(FALSE));
        NuiSetBind(oPC, nToken, "btn_left_part_color_event", JsonBool(FALSE));
        // Row 514 - Label Part Color to Reset
        // Row 515
        NuiSetBind(oPC, nToken, "btn_right_part_reset_event", JsonBool(FALSE));
        NuiSetBind(oPC, nToken, "btn_all_reset_event", JsonBool(FALSE));
        NuiSetBind(oPC, nToken, "btn_left_part_reset_event", JsonBool(FALSE));
        // Row 516 - Label Material to Color
        // Row 517
        NuiSetBind(oPC, nToken, "btn_material_0", JsonBool(FALSE));
        NuiSetBind(oPC, nToken, "btn_material_2", JsonBool(FALSE));
        NuiSetBind(oPC, nToken, "btn_material_4", JsonBool(FALSE));
        // Row 518
        NuiSetBind(oPC, nToken, "btn_material_1", JsonBool(FALSE));
        NuiSetBind(oPC, nToken, "btn_material_3", JsonBool(FALSE));
        NuiSetBind(oPC, nToken, "btn_material_5", JsonBool(FALSE));
        SetMaterialButtons(oPC, nToken, -1);
    }
    // Armor and clothing
    else if(nItem == 0)
    {
        // Row 511
        string sColorPallet = GetLocalString(oPC, CRAFT_COLOR_PALLET);
        if(sColorPallet == "") sColorPallet = "gui_pal_tattoo";
        NuiSetBind(oPC, nToken, "color_pallet_image", JsonString(sColorPallet));
        NuiSetBind(oPC, nToken, "color_pallet_event", JsonBool(TRUE));
        NuiSetBind(oPC, nToken, "color_pallet_tooltip", JsonString("  Select a color or use the mouse wheel"));
        int nSelectedRight, nSelectedAll, nSelectedLeft;
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
            // Row 512 - Label Part to Color
            // Row 5l3
            nSelectedRight = JsonGetInt(JsonObjectGet(jCraft, CRAFT_RIGHT_PART_COLOR));
            nSelectedAll = JsonGetInt(JsonObjectGet(jCraft, CRAFT_ALL_COLOR));
            if(!nSelectedRight && !nSelectedAll)
            {
                nSelectedAll = TRUE;
                JsonObjectSetInplace(jCraft, CRAFT_ALL_COLOR, JsonBool(TRUE));
                JsonObjectSetInplace(jCraft, CRAFT_LEFT_PART_COLOR, JsonBool(FALSE));
            }
            NuiSetBind(oPC, nToken, "btn_right_part_color", JsonBool(nSelectedRight));
            NuiSetBind(oPC, nToken, "btn_right_part_color_event", JsonBool(TRUE));
            NuiSetBind(oPC, nToken, "btn_all_color", JsonBool(nSelectedAll));
            NuiSetBind(oPC, nToken, "btn_all_color_event", JsonBool(TRUE));
            NuiSetBind(oPC, nToken, "btn_left_part_color", JsonBool(FALSE));
            NuiSetBind(oPC, nToken, "btn_left_part_color_event", JsonBool(FALSE));
            // Row 514 - Label Part Color to Reset
            // Row 5l5
            nSelectedRight = GetHasPartColor(oItem, nModelSelected, "Right");
            nSelectedAll = nSelectedRight;
            NuiSetBind(oPC, nToken, "btn_right_part_reset_event", JsonBool(nSelectedRight));
            NuiSetBind(oPC, nToken, "btn_all_reset_event", JsonBool(nSelectedAll));
            NuiSetBind(oPC, nToken, "btn_left_part_reset_event", JsonBool(FALSE));
        }
        else
        {
            // Row 511
            string sColorPallet = GetLocalString(oPC, CRAFT_COLOR_PALLET);
            if(sColorPallet == "") sColorPallet = "gui_pal_tattoo";
            NuiSetBind(oPC, nToken, "color_pallet_image", JsonString(sColorPallet));
            NuiSetBind(oPC, nToken, "color_pallet_event", JsonBool(TRUE));
            NuiSetBind(oPC, nToken, "color_pallet_tooltip", JsonString("  Select a color or use the mouse wheel"));
            // Row 512 - Label Part to Color
            // Row 5l3
            nSelectedRight = JsonGetInt(JsonObjectGet(jCraft, CRAFT_RIGHT_PART_COLOR));
            nSelectedAll = JsonGetInt(JsonObjectGet(jCraft, CRAFT_ALL_COLOR));
            nSelectedLeft = JsonGetInt(JsonObjectGet(jCraft, CRAFT_LEFT_PART_COLOR));
            if(!nSelectedRight && !nSelectedAll && !nSelectedLeft)
            {
                nSelectedAll = TRUE;
                JsonObjectSetInplace(jCraft, CRAFT_ALL_COLOR, JsonBool(TRUE));
            }
            NuiSetBind(oPC, nToken, "btn_right_part_color", JsonBool(nSelectedRight));
            NuiSetBind(oPC, nToken, "btn_right_part_color_event", JsonBool(TRUE));
            NuiSetBind(oPC, nToken, "btn_all_color", JsonBool(nSelectedAll));
            NuiSetBind(oPC, nToken, "btn_all_color_event", JsonBool(TRUE));
            NuiSetBind(oPC, nToken, "btn_left_part_color", JsonBool(nSelectedLeft));
            NuiSetBind(oPC, nToken, "btn_left_part_color_event", JsonBool(TRUE));
            // Row 514 - Label Part Color to Reset
            // Row 5l5
            nSelectedRight = GetHasPartColor(oItem, nModelSelected, "Right");
            nSelectedLeft = GetHasPartColor(oItem, nModelSelected, "Left");
            nSelectedAll = nSelectedRight || nSelectedLeft;
            //SendMessageToPC(oPC, "nSelectedRight: " + IntToString(nSelectedRight) +
            //                     " nSelectedLeft: " + IntToString(nSelectedLeft));
            NuiSetBind(oPC, nToken, "btn_right_part_reset_event", JsonBool(nSelectedRight));
            NuiSetBind(oPC, nToken, "btn_all_reset_event", JsonBool(nSelectedAll));
            NuiSetBind(oPC, nToken, "btn_left_part_reset_event", JsonBool(nSelectedLeft));
            // Row 516 - Label Material to Color
            // Row 517 & 518
            nSelected = JsonGetInt(JsonObjectGet(jCraft, CRAFT_MATERIAL_SELECTION));
            SetMaterialButtons(oPC, nToken, nSelected);
        }
    }
    // Cloaks and Helmets.
    else
    {
        // Row 512 - Label Part to Color
        // Row 5l3
        NuiSetBind(oPC, nToken, "btn_right_part_color", JsonBool(FALSE));
        NuiSetBind(oPC, nToken, "btn_right_part_color_event", JsonBool(FALSE));
        NuiSetBind(oPC, nToken, "btn_all_color_event", JsonBool(TRUE));
        NuiSetBind(oPC, nToken, "btn_all_color", JsonBool(TRUE));
        NuiSetBind(oPC, nToken, "btn_left_part_color", JsonBool(FALSE));
        NuiSetBind(oPC, nToken, "btn_left_part_color_event", JsonBool(FALSE));
        // Row 514 - Label Part Color to Reset
        // Row 5l5
        NuiSetBind(oPC, nToken, "btn_right_part_reset_event", JsonBool(FALSE));
        //NuiSetBind(oPC, nToken, "btn_left_part_reset_event", JsonBool(FALSE));
        NuiSetBind(oPC, nToken, "btn_all_reset_event", JsonBool(FALSE));
        // Row 516 - Label Material to Color
        // Row 517 & 518
        nSelected = JsonGetInt(JsonObjectGet(jCraft, CRAFT_MATERIAL_SELECTION));
        SetMaterialButtons(oPC, nToken, nSelected);
    }
}
void SetMaterialButtons(object oPC, int nToken, int nMaterial)
{
    int nIndex, bBool, bUseable;
    string sIndex;
    if(nMaterial > -1) bUseable = TRUE;
    for(nIndex = 0;nIndex < 6;nIndex++)
    {
        if(nIndex == nMaterial) bBool = TRUE;
        else bBool = FALSE;
        sIndex = IntToString(nIndex);
        NuiSetBind(oPC, nToken, "btn_material_" + sIndex + "_event", JsonBool(bUseable));
        NuiSetBind(oPC, nToken, "btn_material_" + sIndex, JsonBool(bBool));
    }
}
void CreateItemGUIPanel(object oPC, object oItem)
{
    // Row 1 (Name)************************************************************* 73
    json jRow = JsonArray();
    CreateLabel(jRow, "Name:", "lbl_name_title", 50.0f, 20.0f, NUI_HALIGN_LEFT);
    CreateTextEditBox (jRow, "name_placeholder", "txt_item_name", 60, FALSE, 325.0f, 20.0f);
    // Add row to the column.
    json jCol = JsonArrayInsert(JsonArray(), NuiRow(jRow));
    // Row 2 (Tag)************************************************************** 101
    jRow = JsonArray();
    CreateLabel(jRow, "Tag:", "lbl_tag_title", 50.0f, 20.0f, NUI_HALIGN_LEFT);
    CreateTextEditBox(jRow, "name_placeholder", "txt_item_tag", 60, FALSE, 325.0f, 20.0f);
    jCol = JsonArrayInsert(jCol, NuiRow(jRow));
    // Row 2 (ResRef)*********************************************************** 129
    jRow = JsonArray();
    CreateLabel(jRow, "ResRef:", "lbl_resref_title", 50.0f, 20.0f, NUI_HALIGN_LEFT);
    CreateTextEditBox(jRow, "name_placeholder", "txt_item_resref", 60, FALSE, 325.0f, 20.0f);
    // Add row to the column.
    jCol = JsonArrayInsert(jCol, NuiRow(jRow));
    // Row 3 (Base Item/Weight)************************************************* 157
    jRow = JsonArray();
    CreateLabel(jRow, "Base Item: ", "lbl_baseitem_title", 75.0f, 20.0f, NUI_HALIGN_LEFT);
    CreateLabel(jRow, "", "lbl_baseitem", 145.0f, 20.0f, NUI_HALIGN_LEFT);
    CreateLabel(jRow, "Weight: ", "lbl_weight_title", 55.0f, 20.0f, NUI_HALIGN_LEFT);
    CreateLabel(jRow, "", "lbl_weight", 65.0f, 20.0f, NUI_HALIGN_LEFT);
    // Add row to the column.
    jCol = JsonArrayInsert(jCol, NuiRow(jRow));
    // Row 4 (Gold Value)******************************************************* 185
    jRow = JsonArray();
    CreateLabel(jRow, "Gold Value: ", "lbl_gold_title", 85.0f, 20.0f, NUI_HALIGN_LEFT);
    CreateLabel(jRow, "", "lbl_gold_value", 135.0f, 20.0f, NUI_HALIGN_LEFT);
    CreateLabel(jRow, "Minimum Level: ", "lbl_min_lvl_title", 110.0f, 20.0f, NUI_HALIGN_LEFT);
    CreateLabel(jRow, "", "lbl_min_lvl", 20.0f, 20.0f, NUI_HALIGN_LEFT);
    // Add row to the column.
    jCol = JsonArrayInsert(jCol, NuiRow(jRow));
    // Row 5 (Plot/Stolen)****************************************************** 213
    jRow = JsonArray();
    CreateCheckBox(jRow, " Plot", "chbx_plot", 110.0, 20.0f, "chbx_plot_tooltip");
    CreateCheckBox(jRow, " Stolen", "chbx_stolen", 110.0, 20.0f, "chbx_stolen_tooltip");
    CreateCheckBox(jRow, " Cursed", "chbx_cursed", 110.0, 20.0f, "chbx_cursed_tooltip");
    // Add row to the column.
    jCol = JsonArrayInsert(jCol, NuiRow(jRow));
    // Row 6 (Identified/Droppable)********************************************* 269
    jRow = JsonArray();
    CreateCheckBox(jRow, " Identified", "chbx_identified", 110.0, 25.0f, "chbx_identified_tooltip");
    CreateCheckBox(jRow, " Droppable", "chbx_droppable", 110.0, 25.0f, "chbx_droppable_tooltip");
    CreateButton(jRow, "Save as UTI", "btn_save_uti", 110.0, 25.0, -1.0, "btn_save_uti_tooltip");
    // Add row to the column.
    jCol = JsonArrayInsert(jCol, NuiRow(jRow));
    // Row 9 (Stack/Variables/Destroy/Charges)********************************** 307
    jRow = JsonArray();
    CreateTextEditBox(jRow, "name_placeholder", "txt_stack", 4, FALSE, 35.0f, 25.0f);
    CreateLabel(jRow, " Stack", "lbl_stack_title", 72.0f, 20.0f, NUI_HALIGN_LEFT);
    CreateTextEditBox(jRow, "name_placeholder", "txt_charges", 4, FALSE, 40.0f, 25.0f);
    CreateLabel(jRow, " Charges", "lbl_charges_title", 68.0f, 25.0f, NUI_HALIGN_LEFT);
    CreateButtonSelect(jRow, "Destroy", "btn_destroy", 110.0, 25.0, "btn_destroy_tooltip");
    // Add row to the column.
    jCol = JsonArrayInsert(jCol, NuiRow(jRow));
    // Row 11 (Description)***************************************************** 558
    jRow = JsonArray();
    CreateTextEditBox(jRow, "desc_placeholder", "txt_desc", 1000, TRUE, 375.0, 243.0, "txt_desc_tooltip");
    // Add row to the column.
    jCol = JsonArrayInsert(jCol, NuiRow(jRow));
    float fHeight = 566.0;
    // Row 12 (Item Base Description)* ***************************************** 158
    int nBaseItemType = GetBaseItemType(oItem);
    float fWeight;
    string sBaseItemDesc;
    if(nBaseItemType == BASE_ITEM_ARMOR)
    {
        int nArmorAC = ai_GetArmorBonus(oItem);
        sBaseItemDesc = GetStringByStrRef(StringToInt(Get2DAString("armor", "BASEITEMSTATREF", nArmorAC)));
        fWeight = StringToFloat(Get2DAString("armor", "WEIGHT", nArmorAC));
    }
    else
    {
        sBaseItemDesc = GetStringByStrRef(StringToInt(Get2DAString("baseitems", "BaseItemStatRef", nBaseItemType)));
        fWeight = StringToFloat(Get2DAString("baseitems", "TenthLBS", nBaseItemType));
    }
    if(sBaseItemDesc == "Bad Strref") sBaseItemDesc = "";
    if(sBaseItemDesc != "")
    {
        jRow = JsonArray();
        CreateTextBox(jRow, "txt_base_desc", 375.0, 150.0, FALSE, NUI_SCROLLBARS_NONE, "txt_base_desc_tooltip");
        // Add row to the column.
        jCol = JsonArrayInsert(jCol, NuiRow(jRow));
        fHeight += 158.0;
    }
    // Set the layout of the window.
    json jLayout = NuiCol (jCol);
    object oOwner = GetItemPossessor(oItem);
    string sName = ai_StripColorCodes (GetName(oOwner));
    int nToken = SetWindow (oPC, jLayout, "craft_item_nui", sName + "'s item menu",
                            -1.0, -1.0, 400.0, fHeight, FALSE, FALSE, TRUE, FALSE, TRUE, "pe_crafting");
    // Set the buttons to show events to 0e_window.
    NuiSetBind(oPC, nToken, "txt_item_name_event", JsonBool(TRUE));
    NuiSetBind(oPC, nToken, "txt_item_name", JsonString(GetName(oItem)));
    NuiSetBindWatch(oPC, nToken, "txt_item_name", TRUE);
    NuiSetBind(oPC, nToken, "txt_item_tag_event", JsonBool(TRUE));
    NuiSetBind(oPC, nToken, "txt_item_tag", JsonString(GetTag(oItem)));
    NuiSetBindWatch(oPC, nToken, "txt_item_tag", TRUE);
    NuiSetBind(oPC, nToken, "txt_item_resref_event", JsonBool(TRUE));
    NuiSetBind(oPC, nToken, "txt_item_resref", JsonString(GetResRef(oItem)));
    NuiSetBindWatch(oPC, nToken, "txt_item_resref", TRUE);
    string sValue = GetStringByStrRef(StringToInt(Get2DAString("baseitems", "Name", nBaseItemType)));
    NuiSetBind(oPC, nToken, "lbl_baseitem_label", JsonString(sValue));
    sValue = FloatToString(fWeight * 0.1f, 0, 1);
    NuiSetBind(oPC, nToken, "lbl_weight_label", JsonString(sValue));
    int nValue = GetGoldPieceValue(oItem);
    NuiSetBind (oPC, nToken, "lbl_gold_value_label", JsonString(IntToString(nValue)));
    sValue = IntToString (ai_GetMinimumEquipLevel(oItem));
    NuiSetBind(oPC, nToken, "lbl_min_lvl_label", JsonString (sValue));
    nValue = GetPlotFlag (oItem);
    NuiSetBind(oPC, nToken, "chbx_plot_event", JsonBool(TRUE));
    NuiSetBind(oPC, nToken, "chbx_plot_check", JsonBool(nValue));
    NuiSetBindWatch(oPC, nToken, "chbx_plot_check", TRUE);
    NuiSetBind(oPC, nToken, "chbx_plot_tooltip", JsonString ("  Plot items cannot be sold or destroyed."));
    nValue = GetStolenFlag(oItem);
    NuiSetBind(oPC, nToken, "chbx_stolen_event", JsonBool(TRUE));
    NuiSetBind(oPC, nToken, "chbx_stolen_check", JsonBool(nValue));
    NuiSetBindWatch (oPC, nToken, "chbx_stolen_check", TRUE);
    NuiSetBind(oPC, nToken, "chbx_stolen_tooltip", JsonString ("  Stolen items cannot be sold to some stores."));
    nValue = GetItemCursedFlag(oItem);
    NuiSetBind(oPC, nToken, "chbx_cursed_event", JsonBool(TRUE));
    NuiSetBind(oPC, nToken, "chbx_cursed_check", JsonBool(nValue));
    NuiSetBindWatch (oPC, nToken, "chbx_cursed_check", TRUE);
    NuiSetBind(oPC, nToken, "chbx_cursed_tooltip", JsonString ("  Cursed items cannot be dropped or sold."));
    nValue = GetIdentified (oItem);
    NuiSetBind(oPC, nToken, "chbx_identified_event", JsonBool(TRUE));
    NuiSetBind(oPC, nToken, "chbx_identified_check", JsonBool(nValue));
    NuiSetBindWatch(oPC, nToken, "chbx_identified_check", TRUE);
    NuiSetBind(oPC, nToken, "chbx_identified_tooltip", JsonString ("  Close inventory and open again to refresh identified state."));
    nValue = GetDroppableFlag(oItem);
    NuiSetBind(oPC, nToken, "chbx_droppable_event", JsonBool(TRUE));
    NuiSetBind(oPC, nToken, "chbx_droppable_check", JsonBool(nValue));
    NuiSetBindWatch(oPC, nToken, "chbx_droppable_check", TRUE);
    NuiSetBind(oPC, nToken, "chbx_droppable_tooltip", JsonString ("  Droppable items only work on death of an NPC."));
    NuiSetBind(oPC, nToken, "btn_save_uti_event", JsonBool(TRUE));
    NuiSetBind(oPC, nToken, "btn_save_uti_tooltip", JsonString ("  Saves item to a UTI file. Update will be used in the game."));
    nValue = GetItemStackSize (oItem);
    NuiSetBind(oPC, nToken, "txt_stack_event", JsonBool(TRUE));
    NuiSetBind (oPC, nToken, "txt_stack", JsonString(IntToString (nValue)));
    NuiSetBindWatch (oPC, nToken, "txt_stack", TRUE);
    nValue = GetItemCharges (oItem);
    NuiSetBind(oPC, nToken, "txt_charges_event", JsonBool(TRUE));
    NuiSetBind (oPC, nToken, "txt_charges", JsonString(IntToString (nValue)));
    NuiSetBindWatch (oPC, nToken, "txt_charges", TRUE);
    NuiSetBind(oPC, nToken, "btn_destroy_event", JsonBool(TRUE));
    NuiSetBind(oPC, nToken, "btn_destroy_tooltip", JsonString("  Destroys the item permanently! Must click twice to destroy the item."));
    // Description
    NuiSetBind(oPC, nToken, "txt_desc_event", JsonBool(TRUE));
    NuiSetBindWatch(oPC, nToken, "txt_desc", TRUE);
    NuiSetBind(oPC, nToken, "txt_desc_tooltip", JsonString ("  Color codes can be used!"));
    NuiSetBind(oPC, nToken, "txt_desc", JsonString(GetDescription(oItem)));
    // Base Item Description
    NuiSetBind(oPC, nToken, "txt_base_desc_event", JsonBool(TRUE));
    //NuiSetBind(oPC, nToken, "txt_desc_tooltip", JsonString ("Color codes can be used!"));
    if(sBaseItemDesc != "") NuiSetBind(oPC, nToken, "txt_base_desc", JsonString(sBaseItemDesc));
}
void CraftItemInfoEvents(object oPC, int nToken)
{
    string sEvent = NuiGetEventType();
    // We don't use and it causes error windows to go off! Return early!
    if(sEvent == "mouseup") return;
    string sElem = NuiGetEventElement();
    int nIndex = NuiGetEventArrayIndex();
    json jCraft = GetLocalJson(oPC, CRAFT_JSON);
    //SendMessageToPC(oPC, "0e_crafting, 1961, sElem: " + sElem + " sEvent: " + sEvent);
    object oTarget = GetLocalObject(oPC, CRAFT_TARGET);
    if(oTarget == OBJECT_INVALID) oTarget = oPC;
    // Get the item we are crafting.
    int nItemSelected = JsonGetInt(JsonObjectGet(jCraft, CRAFT_ITEM_SELECTION));
    object oItem = GetLocalObject(oPC, "CRAFT_INFO_ITEM");
    if(sEvent == "click")
    {
        if(sElem == "btn_destroy")
        {
            if(!JsonGetInt(NuiGetBind(oPC, nToken, "btn_destroy")))
            {
                if(!GetPlotFlag(oItem))
                {
                    DestroyObject(oItem);
                    ai_SendMessages(GetName(oItem) + " has been permanently destroyed!", AI_COLOR_RED, oPC);
                    NuiDestroy(oPC, nToken);
                }
                else
                {
                    ai_SendMessages("The plot flag must be removed before you can destroy " + GetName(oItem) + "!", AI_COLOR_YELLOW, oPC);
                }
            }
            else
            {
                ai_SendMessages("Click Destroy button again to destroy " + GetName(oItem) + "!", AI_COLOR_RED, oPC);
            }
        }
        // Allows saving the item as a UTI!
        else if(sElem == "btn_save_uti")
        {
            json jItem = ObjectToJson(oItem);
            string sResRef = JsonGetString(NuiGetBind(oPC, nToken, "txt_item_resref"));
            sResRef = ai_RemoveIllegalCharacters(sResRef);
            if(sResRef == "") ai_SendMessages(GetName(oItem) + " has not been saved! ResRef does not have a value.", AI_COLOR_RED, oPC);
            else
            {
                JsonToTemplate(jItem, sResRef, RESTYPE_UTI);
                ai_SendMessages(GetName(oItem) + " has been saved as " + sResRef + ".uti in your Neverwinter Nights Temp directory.", AI_COLOR_GREEN, oPC);
                ai_SendMessages("This temp directory will be removed when the game is left.", AI_COLOR_GREEN, oPC);
            }
        }
    }
    if(sEvent == "watch")
    {
        // Changing the name needs to be before the cooldown.
        if(sElem == "txt_item_name")
        {
            string sName = JsonGetString(NuiGetBind(oPC, nToken, "txt_item_name"));
            SetName(oItem, sName);
            int nToken2 = NuiFindWindow(oPC, "crafting_nui");
            if(nToken2) NuiSetBind(oPC, nToken2, "txt_item_name", JsonString(sName));
        }
        else if(sElem == "txt_item_tag")
        {
            string sTag = JsonGetString(NuiGetBind(oPC, nToken, "txt_item_tag"));
            SetTag(oItem, sTag);
        }
        else if(sElem == "txt_stack")
        {
            int nSize = StringToInt(JsonGetString(NuiGetBind(oPC, nToken, "txt_stack")));
            int nBaseItemType = GetBaseItemType(oItem);
            string sMaxSize = Get2DAString("baseitems", "Stacking", nBaseItemType);
            if(nSize > StringToInt(sMaxSize))
            {
                ai_SendMessages("The maximum stack for this item type is " + sMaxSize + ".", AI_COLOR_RED, oPC);
                NuiSetBind(oPC, nToken, "txt_stack", JsonString(sMaxSize));
            }
            if(nSize != 0) SetItemStackSize(oItem, nSize);
        }
        else if(sElem == "txt_charges")
        {
            int nCharges = StringToInt(JsonGetString(NuiGetBind(oPC, nToken, "txt_charges")));
            if(nCharges > 250)
            {
                ai_SendMessages("The maximum charges for this item type is 250.", AI_COLOR_RED, oPC);
                NuiSetBind(oPC, nToken, "txt_charges", JsonString("250"));
            }
            if(nCharges != 0) SetItemCharges(oItem, nCharges);
        }
        else if(sElem == "chbx_plot_check")
        {
            int nValue = JsonGetInt(NuiGetBind(oPC, nToken, sElem));
            SetPlotFlag(oItem, nValue);
        }
        else if(sElem == "chbx_stolen_check")
        {
            int nValue = JsonGetInt(NuiGetBind(oPC, nToken, sElem));
            SetStolenFlag(oItem, nValue);
        }
        else if(sElem == "chbx_cursed_check")
        {
            int nValue = JsonGetInt(NuiGetBind(oPC, nToken, sElem));
            SetItemCursedFlag(oItem, nValue);
        }
        else if(sElem == "chbx_identified_check")
        {
            int nValue = JsonGetInt(NuiGetBind(oPC, nToken, sElem));
            SetIdentified(oItem, nValue);
        }
        else if(sElem == "chbx_droppable_check")
        {
            int nValue = JsonGetInt(NuiGetBind(oPC, nToken, sElem));
            SetDroppableFlag(oItem, nValue);
        }
    }
}
/*void CreateDresserGUIPanel(object oPC, object oTarget)
{
    // Set window to not save until it has been created.
    SetLocalInt (oPC, "0_No_Win_Save", TRUE);
    DelayCommand (0.5f, DeleteLocalInt (oPC, "0_No_Win_Save"));
    // Group 1 (Portrait)******************************************************* 151 / 73
    // Group 1 Row 1 *********************************************************** 350 / 91
    json jRow = JsonArray();
    json jGroupRow = JsonArray();
    json jGroupCol = JsonArray();
    JsonArrayInsertInplace(jGroupRow, NuiSpacer());
    CreateTextEditBox (jGroupRow, "name_placeholder", "char_name", 15, FALSE, 140.0, 20.0);
    JsonArrayInsertInplace(jGroupRow, NuiSpacer());
    // Add the group row to the group column.
    JsonArrayInsertInplace(jGroupCol, NuiRow(jGroupRow));
    // Group 1 Row 1 *********************************************************** 350 / 91
    jGroupRow = JsonArray();
    JsonArrayInsertInplace(jGroupRow, NuiSpacer());
    CreateTextEditBox (jGroupRow, "port_placeholder", "port_name", 15, FALSE, 140.0, 20.0, "port_tooltip");
    JsonArrayInsertInplace(jGroupRow, NuiSpacer());
    // Add the group row to the group column.
    JsonArrayInsertInplace(jGroupCol, NuiRow(jGroupRow));
    // Group 1 Row 2 *********************************************************** 350 / 91
    jGroupRow = JsonArray();
    JsonArrayInsertInplace(jGroupRow, NuiSpacer());
    CreateLabel(jGroupRow, "", "port_id", 140.0, 10.0f);
    JsonArrayInsertInplace(jGroupRow, NuiSpacer());
    // Add the group row to the group column.
    JsonArrayInsertInplace(jGroupCol, NuiRow(jGroupRow));
    // Group 1 Row 3 *********************************************************** 350 / 259
    jGroupRow = JsonArray();
    JsonArrayInsertInplace(jGroupRow, NuiSpacer());
    CreateImage(jGroupRow, "", "port_resref", NUI_ASPECT_EXACTSCALED, NUI_HALIGN_CENTER, NUI_VALIGN_TOP, 140.0f, 160.0f);
    JsonArrayInsertInplace(jGroupRow, NuiSpacer());
    // Add the group row to the group column.
    JsonArrayInsertInplace(jGroupCol, NuiRow(jGroupRow));
    // Group 1 Row 4 *********************************************************** 350 / 292
    jGroupRow = JsonArray();
    JsonArrayInsertInplace(jGroupRow, NuiSpacer());
    CreateButton (jGroupRow, "<", "btn_portrait_prev", 42.0f, 25.0f);
    CreateButton (jGroupRow, "Set", "btn_portrait_ok", 44.0f, 25.0f);
    CreateButton (jGroupRow, ">", "btn_portrait_next", 42.0f, 25.0f);
    JsonArrayInsertInplace(jGroupRow, NuiSpacer());
    // Add group row to the group column.
    JsonArrayInsertInplace(jGroupCol, NuiRow(jGroupRow));
    JsonArrayInsertInplace(jRow, NuiGroup(NuiCol(jGroupCol)));
    // Group 2 (Stats)********************************************************** 151 / 73
    // Group 2 Row 1 *********************************************************** 350 / 91
    jGroupRow = JsonArray();
    jGroupCol = JsonArray();
    JsonArrayInsertInplace(jGroupRow, NuiSpacer());
    CreateLabel(jGroupRow, "", "lbl_stats", 150.0, 15.0, 0, 0, 0.0);
    JsonArrayInsertInplace(jGroupRow, NuiSpacer());
    // Add group row to the group column.
    JsonArrayInsertInplace(jGroupCol, NuiRow(jGroupRow));
    // Group 2 Row 2 *********************************************************** 350 / 91
    jGroupRow = JsonArray();
    json jClasses = CreateOptionsClasses(oHenchman);
    CreateOptions(jGroupRow, "opt_classes", NUI_DIRECTION_VERTICAL, jClasses, 150.0, 144.0);
    JsonArrayInsertInplace(jGroupRow, NuiSpacer());
    // Add group row to the group column.
    JsonArrayInsertInplace(jGroupCol, NuiRow(jGroupRow));
    // Group 2 Row 3 *********************************************************** 350 / 91
    jGroupRow = JsonArray();
    JsonArrayInsertInplace(jGroupRow, NuiSpacer());
    CreateButton (jGroupRow, "Level Up", "btn_level_up", 150.0f, 25.0f);
    JsonArrayInsertInplace(jGroupRow, NuiSpacer());
    // Add group row to the group column.
    JsonArrayInsertInplace(jGroupCol, NuiRow(jGroupRow));
    // Group 2 Row 4 *********************************************************** 350 / 91
    jGroupRow = JsonArray();
    JsonArrayInsertInplace(jGroupRow, NuiSpacer());
    CreateCombo(jGroupRow, jArrayInsertClasses(), "cmb_class", 150.0, 25.0);
    JsonArrayInsertInplace(jGroupRow, NuiSpacer());
    // Add group row to the group column.
    JsonArrayInsertInplace(jGroupCol, NuiRow(jGroupRow));
    // Group 2 Row 5 *********************************************************** 350 / 91
    jGroupRow = JsonArray();
    JsonArrayInsertInplace(jGroupRow, NuiSpacer());
    int nClassOption = GetLocalInt(oHenchman, "CLASS_OPTION_POSITION");
    int nClass = GetClassByPosition(nClassOption + 1, oHenchman);
    int bNoClass = FALSE;
    if(nClass == CLASS_TYPE_INVALID)
    {
        nClass = GetLocalInt(oHenchman, "CLASS_SELECTED_" + IntToString(nClassOption + 1));
        bNoClass = TRUE;
    }
    string sClass = IntToString(nClass);
    CreateCombo(jGroupRow, jArrayInsertPackages(sClass), "cmb_package", 150.0, 25.0);
    JsonArrayInsertInplace(jGroupRow, NuiSpacer());
    // Add group row to the group column.
    JsonArrayInsertInplace(jGroupCol, NuiRow(jGroupRow));
    JsonArrayInsertInplace(jRow, NuiGroup(NuiCol(jGroupCol)));
    // Add the row to the column.
    json jCol = JsonArray();
    JsonArrayInsertInplace(jCol, NuiRow(jRow));
    // Row 5 (text edit box)**************************************************** 350 / 518
    jRow = JsonArray();
    CreateTextEditBox (jRow, "desc_placeholder", "desc_value", 1000, TRUE, 350.0, 150.0, "desc_tooltip");
    // Add the row to the column.
    JsonArrayInsertInplace(jCol, NuiRow (jRow));
    // Row 6 (button)*********************************************************** 350/ 546
    jRow = JsonArray();
    JsonArrayInsertInplace(jRow, NuiSpacer());
    CreateButton (jRow, "Save Description", "btn_desc_save", 150.0f, 20.0f);
    JsonArrayInsertInplace(jRow, NuiSpacer());
    // Add row to the column.
    JsonArrayInsertInplace(jCol, NuiRow (jRow));
    // Set the Layout of the window.
    json jLayout = NuiCol (jCol);
    // Get the window location to restore it from the database.
    CheckHenchmanDataAndInitialize(oPC, "0");
    json jData = GetHenchmanDbJson(oPC, "henchman", "0");
    json jGeometry = JsonObjectGet(jData, "henchman_edit_nui");
    float fX = JsonGetFloat(JsonObjectGet(jGeometry, "x"));
    float fY = JsonGetFloat(JsonObjectGet(jGeometry, "y"));
    if(fX == 0.0 && fY == 0.0)
    {
        fX = -1.0;
        fY = -1.0;
    }
    string sName = GetName(oHenchman);
    if(GetStringRight(sName, 1) == "s") sName = sName + "'";
    else sName = sName + "'s";
    int nToken = SetWindow (oPC, jLayout, "henchman_edit_nui", sName + " Character editor",
                            fX, fY, 380.0, 555.0, FALSE, FALSE, TRUE, FALSE, TRUE, "pe_henchmen");
    // Set all binds, events, and watches.
    int nID = GetPortraitId (oPC);
    NuiSetUserData(oPC, nToken, JsonInt(nID));
    string sResRef = GetPortraitResRef(oHenchman);
    string sID;
    if (nID == 65535) sID = "Custom Portrait";
    else sID = IntToString (nID);
    NuiSetBind(oPC, nToken, "char_name_event", JsonBool(TRUE));
    NuiSetBind(oPC, nToken, "char_name", JsonString(GetName(oHenchman)));
    NuiSetBindWatch(oPC, nToken, "char_name", TRUE);
    NuiSetBind(oPC, nToken, "port_name_event", JsonBool(TRUE));
    NuiSetBindWatch(oPC, nToken, "port_name", TRUE);
    NuiSetBind(oPC, nToken, "port_name", JsonString(sResRef));
    NuiSetBind(oPC, nToken, "port_id", JsonString(sID));
    NuiSetBind(oPC, nToken, "port_resref_event", JsonBool(TRUE));
    NuiSetBind(oPC, nToken, "port_resref_image", JsonString(sResRef + "l"));
    NuiSetBind(oPC, nToken, "port_tooltip", JsonString ("  You may also type the portrait file name."));
    // Set buttons active.
    NuiSetBind(oPC, nToken, "btn_portrait_prev_event", JsonBool(TRUE));
    NuiSetBind(oPC, nToken, "btn_portrait_next_event", JsonBool(TRUE));
    NuiSetBind(oPC, nToken, "btn_desc_save_event", JsonBool(TRUE));
    NuiSetBind(oPC, nToken, "btn_portrait_ok_event", JsonBool(TRUE));
    NuiSetBind(oPC, nToken, "desc_tooltip", JsonString("  You can use color codes!"));
    string sDescription = GetDescription(oHenchman);
    NuiSetBind(oPC, nToken, "desc_value_event", JsonBool(TRUE));
    NuiSetBind(oPC, nToken, "desc_value", JsonString (sDescription));
    NuiSetBindWatch(oPC, nToken, "window_geometry", TRUE);
    // Setup the henchman window.
    string sStats = GetAlignText(oHenchman) + " ";
    if(GetGender(oHenchman) == GENDER_MALE) sStats += "Male ";
    else sStats += "Female ";
    sStats += GetStringByStrRef (StringToInt (Get2DAString ("racialtypes", "Name", GetRacialType (oHenchman))));
    NuiSetBind(oPC, nToken, "lbl_stats_label", JsonString(sStats));
    json jHenchman = ObjectToJson(oHenchman);
    json jLvlStatList = JsonObjectGet(jHenchman, "LvlStatList");
    int bLevelUp = JsonGetType(jLvlStatList) != JSON_TYPE_NULL;
    NuiSetBind(oPC, nToken, "opt_classes_event", JsonBool(bLevelUp));
    NuiSetBind(oPC, nToken, "opt_classes_value", JsonInt(nClassOption));
    NuiSetBind(oPC, nToken, "btn_level_up_event", JsonBool(bLevelUp));
    NuiSetBind(oPC, nToken, "cmb_class_event", JsonBool(bNoClass));
    NuiSetBindWatch(oPC, nToken, "cmb_class_selected", bNoClass);
    int nSelection = GetSelectionByClass2DA(nClass);
    NuiSetBind(oPC, nToken, "cmb_class_selected", JsonInt(nSelection));
    NuiSetBind(oPC, nToken, "cmb_package_event", JsonBool(bNoClass));
    NuiSetBindWatch(oPC, nToken, "cmb_package_selected", bNoClass);
    int nPackage = GetLocalInt(oHenchman, "PACKAGE_SELECTED_" + IntToString(nClassOption + 1));
    if(nPackage == 0)
    {
        if(GetClassByPosition(1, oHenchman) == nClass) nPackage = GetCreatureStartingPackage(oHenchman);
        else nPackage = GetPackageBySelection2DA(sClass, 0);
        SetLocalInt(oHenchman, "PACKAGE_SELECTED_" + IntToString(nClassOption + 1), nPackage);
    }
    NuiSetBind(oPC, nToken, "cmb_package_selected", JsonInt(GetSelectionByPackage2DA(sClass, nPackage)));
}

