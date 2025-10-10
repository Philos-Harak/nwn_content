/*//////////////////////////////////////////////////////////////////////////////
// Script Name: pe_crafting
////////////////////////////////////////////////////////////////////////////////
 Used with pi_crafting to run the crafting plugin events for
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
const int    ALLOW_CRAFT_NAMES = TRUE;
const int    CRAFT_MAX_WEAPON_MODEL_NUMBER = 99;
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
const string CRAFT_ITEM = "CRAFT_ITEM";
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
void SetModelNumberText(object oPC, object oTarget, int nToken);
// Sets the material buttons for use.
// nMaterial 0,1 Cloth 2,3 Leather 4,5 Metal -1 None.
void SetMaterialButtons(object oPC, int nToken, int nMaterial);
// Creates the item editing menu.
void CreateItemGUIPanel(object oPC, object oTarget);
// Events for ItemGUIPanel
void CraftItemInfoEvents(object oPC, int nToken);
// Creates the save/load menu for items.
//void CreateDresserGUIPanel(object oPC, object oTarget);
json CreateItemCombo(object oPC, json jRow, string sComboBind);
json CreateModelCombo(object oPC, object oTarget, json jRow, string sComboBind);
void CreateCreatureCraftingGUIPanel(object oPC, object oTarget);

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
            int nObjectType = GetObjectType(oTarget);
            if(nObjectType == OBJECT_TYPE_CREATURE)
            {
                if(oPC == oTarget || GetMaster(oTarget) == oPC ||
                   ai_GetIsDungeonMaster(oPC))
                {
                    SetLocalObject(oPC, CRAFT_TARGET, oTarget);
                    AttachCamera(oPC, oTarget);
                    SetLocalObject(oPC, CRAFT_TARGET, oTarget);
                    CreateCreatureCraftingGUIPanel(oPC, oTarget);
                }
                else
                {
                    ai_SendMessages(GetName(oTarget) + " is not the player or a henchmen! Other associates cannot use item crafting.", AI_COLOR_RED, oPC);
                    // Set this variable on the player so PEPS can run the targeting script for this plugin.
                    SetLocalString(oPC, AI_PLUGIN_TARGET_SCRIPT, "pe_crafting");
                    // Set Targeting variables.
                    SetLocalString(oPC, AI_TARGET_MODE, "SELECT_TARGET");
                    ai_SendMessages("Select your character, a henchman or an item possessed by one.", AI_COLOR_YELLOW, oPC);
                    EnterTargetingMode(oPC, OBJECT_TYPE_CREATURE | OBJECT_TYPE_ITEM ,
                                        MOUSECURSOR_EXAMINE, MOUSECURSOR_NOEXAMINE);
                    return;
                }
            }
            else if(nObjectType == OBJECT_TYPE_ITEM)
            {
                if(!GetIdentified(oTarget) && !ai_GetIsDungeonMaster(oPC))
                {
                    ai_SendMessages("The item must be Identified!", AI_COLOR_RED, oPC);
                    // Set this variable on the player so PEPS can run the targeting script for this plugin.
                    SetLocalString(oPC, AI_PLUGIN_TARGET_SCRIPT, "pe_crafting");
                    // Set Targeting variables.
                    SetLocalString(oPC, AI_TARGET_MODE, "SELECT_TARGET");
                    ai_SendMessages("Select your character, a henchman or an item possessed by one of them.", AI_COLOR_YELLOW, oPC);
                    EnterTargetingMode(oPC, OBJECT_TYPE_CREATURE | OBJECT_TYPE_ITEM ,
                                        MOUSECURSOR_EXAMINE, MOUSECURSOR_NOEXAMINE);
                    return;
                }
                object oCreature = GetItemPossessor(oTarget, TRUE);
                if(oCreature == oPC || GetMaster(oCreature) == oPC || ai_GetIsDungeonMaster(oPC))
                {
                    SetLocalObject(oPC, "CRAFT_INFO_ITEM", oTarget);
                    CreateItemGUIPanel(oPC, oTarget);
                }
                else
                {
                    ai_SendMessages("Items must be possessed by the player or a henchmen!", AI_COLOR_RED, oPC);
                    // Set this variable on the player so PEPS can run the targeting script for this plugin.
                    SetLocalString(oPC, AI_PLUGIN_TARGET_SCRIPT, "pe_crafting");
                    // Set Targeting variables.
                    SetLocalString(oPC, AI_TARGET_MODE, "SELECT_TARGET");
                    ai_SendMessages("Select your character, a henchman or an item possessed by one of them.", AI_COLOR_YELLOW, oPC);
                    EnterTargetingMode(oPC, OBJECT_TYPE_CREATURE | OBJECT_TYPE_ITEM ,
                                        MOUSECURSOR_EXAMINE, MOUSECURSOR_NOEXAMINE);
                    return;
                }
            }
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
                if(JsonGetType(jCraft) == JSON_TYPE_NULL) jCraft = JsonObject();
                // Get the height, width, x, and y of the window.
                json jGeometry = NuiGetBind(oPC, nToken, "window_geometry");
                jCraft = JsonObjectSet(jCraft, "CRAFT_MENU", jGeometry);
                SetLocalJson(oPC, CRAFT_JSON, jCraft);
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
        if(GetLocalInt(oPC, CRAFT_COOL_DOWN)) return;
        SetLocalInt(oPC, CRAFT_COOL_DOWN, TRUE);
        DelayCommand(0.25f, DeleteLocalInt(oPC, CRAFT_COOL_DOWN));
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
            else if(sEvent == "mousescroll")
            {
                float nMouseScroll = JsonGetFloat(JsonObjectGet(JsonObjectGet(NuiGetEventPayload(), "mouse_scroll"), "y"));
                nChange = FloatToInt(nMouseScroll);
            }
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
                SetColorPalletPointer(oPC, nToken, oNewItem);
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
                jCraft = JsonObjectSet(jCraft, CRAFT_ITEM_SELECTION, JsonInt(nSelected));
                // Set button for cloak and helms.
                if(nSelected == 1 || nSelected == 2)
                {
                    int nHidden = GetHiddenWhenEquipped(oItem);
                    if(nHidden) jCraft = JsonObjectSet(jCraft, CRAFT_MODEL_SELECTION, JsonInt(1));
                    else jCraft = JsonObjectSet(jCraft, CRAFT_MODEL_SELECTION, JsonInt(0));
                }
                else jCraft = JsonObjectSet(jCraft, CRAFT_MODEL_SELECTION, JsonInt(0));
                SetLocalJson(oPC, CRAFT_JSON, jCraft);
                NuiDestroy(oPC, nToken);
                CreateCreatureCraftingGUIPanel(oPC, GetLocalObject(oPC, CRAFT_TARGET));
            }
            // They have selected a part to change.
            else if(sElem == "model_combo_selected")
            {
                int nSelected = JsonGetInt(NuiGetBind(oPC, nToken, sElem));
                jCraft = JsonObjectSet(jCraft, CRAFT_MODEL_SELECTION, JsonInt(nSelected));
                SetLocalJson(oPC, CRAFT_JSON, jCraft);
                SetModelNumberText(oPC, oTarget, nToken);
                int nItem = JsonGetInt(JsonObjectGet(jCraft, CRAFT_ITEM_SELECTION));
                if(nItem == 1) // Cloak
                {
                    if(!CanCraftItem(oPC, oItem, nToken)) return;
                    object oItem = GetItemInSlot(INVENTORY_SLOT_CLOAK, oTarget);
                    if(nSelected == 1) SetHiddenWhenEquipped(oItem, TRUE);
                    else SetHiddenWhenEquipped(oItem, FALSE);
                    LockItemInCraftingWindow(oPC, oItem, oTarget, nToken);
                }
                else if(nItem == 2) // Headgear
                {
                    if(!CanCraftItem(oPC, oItem, nToken)) return;
                    object oItem = GetItemInSlot(INVENTORY_SLOT_HEAD, oTarget);
                    if(nSelected == 1) SetHiddenWhenEquipped(oItem, TRUE);
                    else SetHiddenWhenEquipped(oItem, FALSE);
                    LockItemInCraftingWindow(oPC, oItem, oTarget, nToken);
                }
                else if(nItem == 4 && ai_GetIsShield(oItem))
                {
                    if(!CanCraftItem(oPC, oItem, nToken)) return;
                    object oItem = GetItemInSlot(INVENTORY_SLOT_LEFTHAND, oTarget);
                    if(nSelected == 1) SetHiddenWhenEquipped(oItem, TRUE);
                    else SetHiddenWhenEquipped(oItem, FALSE);
                    LockItemInCraftingWindow(oPC, oItem, oTarget, nToken);
                }
                if(ai_GetIsWeapon(oItem))
                {
                    // Clearing sets the module to 0 triggering an extra call.
                    if(GetLocalInt(oPC, AI_NO_NUI_SAVE)) return;
                    if(!CanCraftItem(oPC, oItem, nToken)) return;
                    int nVisual;
                    itemproperty ipProperty = GetFirstItemProperty(oItem);
                    while(GetIsItemPropertyValid(ipProperty))
                    {
                        if(GetItemPropertyType(ipProperty) == ITEM_PROPERTY_VISUALEFFECT)
                        {
                            RemoveItemProperty(oItem, ipProperty);
                        }
                        ipProperty = GetNextItemProperty(oItem);
                    }
                    if(nSelected == 1) nVisual = ITEM_VISUAL_ACID;
                    else if(nSelected == 2) nVisual = ITEM_VISUAL_COLD;
                    else if(nSelected == 3) nVisual = ITEM_VISUAL_ELECTRICAL;
                    else if(nSelected == 4) nVisual = ITEM_VISUAL_EVIL;
                    else if(nSelected == 5) nVisual = ITEM_VISUAL_FIRE;
                    else if(nSelected == 6) nVisual = ITEM_VISUAL_HOLY;
                    else if(nSelected == 7) nVisual = ITEM_VISUAL_SONIC;
                    if(nVisual)
                    {
                        ipProperty = ItemPropertyVisualEffect(nVisual);
                        AddItemProperty(DURATION_TYPE_PERMANENT, ipProperty, oItem);
                    }
                    LockItemInCraftingWindow(oPC, oItem, oTarget, nToken);
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
                ai_SendMessages("Select your charcter, a henchman or an item possessed by one.", AI_COLOR_YELLOW, oPC);
                DeleteLocalObject(oPC, CRAFT_ORIGINAL_ITEM);
                DeleteLocalObject(oPC, CRAFT_TARGET);
                DeleteLocalObject(oPC, "CRAFT_INFO_ITEM");
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
                EnterTargetingMode(oPC, OBJECT_TYPE_CREATURE | OBJECT_TYPE_ITEM ,
                                    MOUSECURSOR_EXAMINE, MOUSECURSOR_NOEXAMINE);
            }
            // Cancel any changes made to the selected item.
            else if(sElem == "btn_cancel")
            {
                // If the button is on cancel then clear the item.
                if(JsonGetString(NuiGetBind(oPC, nToken, "btn_cancel_label")) == "Cancel")
                {
                    CancelCraftedItem(oPC, oTarget);
                    ClearItemInCraftingWindow(oPC, oItem, nToken);
                    DelayCommand(0.5, NuiDestroy(oPC, nToken));
                    DelayCommand(0.5, CreateCreatureCraftingGUIPanel(oPC, GetLocalObject(oPC, CRAFT_TARGET)));
                }
                // If the button is on Exit not Cancel then exit.
                else
                {
                    AssignCommand(oPC, RestoreCameraFacing());
                    AttachCamera(oPC, oPC);
                    DeleteLocalObject(oPC, CRAFT_ORIGINAL_ITEM);
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
                jCraft = JsonObjectSet(jCraft, CRAFT_ALL_COLOR, JsonInt(FALSE));
                NuiSetBind(oPC, nToken, "btn_all_color", JsonBool(FALSE));
                jCraft = JsonObjectSet(jCraft, CRAFT_LEFT_PART_COLOR, JsonInt(TRUE));
                NuiSetBind(oPC, nToken, "btn_left_part_color", JsonBool(TRUE));
                jCraft = JsonObjectSet(jCraft, CRAFT_RIGHT_PART_COLOR, JsonInt(FALSE));
                NuiSetBind(oPC, nToken, "btn_right_part_color", JsonBool(FALSE));
                SetColorPalletPointer(oPC, nToken, oItem);
            }
            else if(sElem == "btn_all_color")
            {
                jCraft = JsonObjectSet(jCraft, CRAFT_ALL_COLOR, JsonInt(TRUE));
                NuiSetBind(oPC, nToken, "btn_all_color", JsonBool(TRUE));
                jCraft = JsonObjectSet(jCraft, CRAFT_LEFT_PART_COLOR, JsonInt(FALSE));
                NuiSetBind(oPC, nToken, "btn_left_part_color", JsonBool(FALSE));
                jCraft = JsonObjectSet(jCraft, CRAFT_RIGHT_PART_COLOR, JsonInt(FALSE));
                NuiSetBind(oPC, nToken, "btn_right_part_color", JsonBool(FALSE));
                SetColorPalletPointer(oPC, nToken, oItem);
            }
            else if(sElem == "btn_right_part_color")
            {
                jCraft = JsonObjectSet(jCraft, CRAFT_ALL_COLOR, JsonInt(FALSE));
                NuiSetBind(oPC, nToken, "btn_all_color", JsonBool(FALSE));
                jCraft = JsonObjectSet(jCraft, CRAFT_LEFT_PART_COLOR, JsonInt(FALSE));
                NuiSetBind(oPC, nToken, "btn_left_part_color", JsonBool(FALSE));
                jCraft = JsonObjectSet(jCraft, CRAFT_RIGHT_PART_COLOR, JsonInt(TRUE));
                NuiSetBind(oPC, nToken, "btn_right_part_color", JsonBool(TRUE));
                SetColorPalletPointer(oPC, nToken, oItem);
            }
            else if(sElem == "btn_right_part_reset")
            {
                if(CanCraftItem(oPC, oItem, nToken))
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
                    jCraft = JsonObjectSet(jCraft, CRAFT_RIGHT_PART_COLOR, JsonInt(FALSE));
                    int nLeft = JsonGetInt(NuiGetBind(oPC, nToken, "btn_left_part_color"));
                    NuiSetBind(oPC, nToken, "btn_all_color", JsonBool(!nLeft));
                    jCraft = JsonObjectSet(jCraft, CRAFT_ALL_COLOR, JsonInt(!nLeft));
                    NuiSetBind(oPC, nToken, "btn_right_part_reset_event", JsonBool(FALSE));
                    nLeft = JsonGetInt(NuiGetBind(oPC, nToken, "btn_left_part_reset_event"));
                    NuiSetBind(oPC, nToken, "btn_all_reset_event", JsonBool(nLeft));
                    SetColorPalletPointer(oPC, nToken, oNewItem);
                }
            }
            else if(sElem == "btn_all_reset")
            {
                if(CanCraftItem(oPC, oItem, nToken))
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
                    // Lock the new item so they can't change it on the character.
                    LockItemInCraftingWindow(oPC, oNewItem, oTarget, nToken);
                    // Fix buttons.
                    NuiSetBind(oPC, nToken, "btn_right_part_color", JsonBool(FALSE));
                    jCraft = JsonObjectSet(jCraft, CRAFT_RIGHT_PART_COLOR, JsonInt(FALSE));
                    NuiSetBind(oPC, nToken, "btn_all_color", JsonBool(TRUE));
                    jCraft = JsonObjectSet(jCraft, CRAFT_ALL_COLOR, JsonInt(TRUE));
                    NuiSetBind(oPC, nToken, "btn_left_part_color", JsonBool(FALSE));
                    jCraft = JsonObjectSet(jCraft, CRAFT_RIGHT_PART_COLOR, JsonInt(FALSE));
                    NuiSetBind(oPC, nToken, "btn_right_part_reset_event", JsonBool(FALSE));
                    NuiSetBind(oPC, nToken, "btn_all_reset_event", JsonBool(FALSE));
                    NuiSetBind(oPC, nToken, "btn_left_part_reset_event", JsonBool(FALSE));
                    SetColorPalletPointer(oPC, nToken, oNewItem);
                }
            }
            else if(sElem == "btn_left_part_reset")
            {
                if(CanCraftItem(oPC, oItem, nToken))
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
                    jCraft = JsonObjectSet(jCraft, CRAFT_LEFT_PART_COLOR, JsonInt(FALSE));
                    int nRight = JsonGetInt(NuiGetBind(oPC, nToken, "btn_right_part_color"));
                    NuiSetBind(oPC, nToken, "btn_all_color", JsonBool(!nRight));
                    jCraft = JsonObjectSet(jCraft, CRAFT_ALL_COLOR, JsonInt(!nRight));
                    NuiSetBind(oPC, nToken, "btn_left_part_reset_event", JsonBool(FALSE));
                    nRight = JsonGetInt(NuiGetBind(oPC, nToken, "btn_right_part_reset_event"));
                    NuiSetBind(oPC, nToken, "btn_all_reset_event", JsonBool(nRight));
                    SetColorPalletPointer(oPC, nToken, oNewItem);
                }
            }
            // They have changed the material (color item) for the item.
            else if(GetStringLeft(sElem, 13) == "btn_material_")
            {
                int nSelected = StringToInt(GetStringRight(sElem, 1));
                SetMaterialButtons(oPC, nToken, nSelected);
                jCraft = JsonObjectSet(jCraft, CRAFT_MATERIAL_SELECTION, JsonInt(nSelected));
                SetLocalJson(oPC, CRAFT_JSON, jCraft);
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
            SetLocalJson(oPC, CRAFT_JSON, jCraft);
        }
        else if(sEvent == "mousedown")
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
        //SendMessageToPC(oPC, "nItemSelected: " + IntToString(nItemSelected));
        if(nItemSelected == 3)
        {
            AssignCommand(oTarget, ActionEquipItem(oNewItem, INVENTORY_SLOT_RIGHTHAND));
        }
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
            WriteTimestampedLogEntry("pe_crafting, 1241, " + GetName(oItem) + " nModelSelected: " +
                          IntToString(nModelSelected) + " nModelNumber: " + IntToString(nModelNumber));
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
                WriteTimestampedLogEntry("pe_crafting, 1275, " + GetName(oItem) + " nModelSelected: " +
                              IntToString(nModelSelected) + " nModelNumber: " + IntToString(nModelNumber));
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
        if(d100() < 50) nRoll = nRoll + Random(5) - 3;
        else nRoll = Random(175) + 1;
        if(d100() < 50) nRoll2 = nRoll + Random(5) - 3;
        else nRoll2 = Random(175) + 1;
        jItem = GffReplaceByte(jItem, "Leather1Color", nRoll);
        jItem = GffReplaceByte(jItem, "Leather2Color", nRoll2);
        if(d100() < 50) nRoll = nRoll + Random(5) - 3;
        else nRoll = Random(175) + 1;
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
    object oItem = GetLocalObject(oPC, CRAFT_ITEM);
    object oOriginalItem = GetLocalObject(oPC, CRAFT_ORIGINAL_ITEM);
    if(oOriginalItem != OBJECT_INVALID)
    {
        int nSlot = GetItemSelectedEquipSlot(nItemSelected);
        // Give item Backup to Player
        oOriginalItem = CopyItem(oOriginalItem, oTarget, TRUE);
        DelayCommand(0.2f, AssignCommand (oTarget, ActionEquipItem(oOriginalItem, nSlot)));
        DeleteLocalObject(oPC, CRAFT_ORIGINAL_ITEM);
    }
    DestroyObject(oItem);
    DeleteLocalObject(oPC, CRAFT_ITEM);
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
    int nColor;
    if(!JsonGetInt(NuiGetBind(oPC, nToken, "btn_all_color")))
    {
        int nModelSelected = GetArmorModelSelected(oPC);
        if(!JsonGetInt(JsonObjectGet(jCraft, CRAFT_RIGHT_PART_COLOR)))
        {
            // Note: Right Thigh and Left Thigh are backwards so this fixes that!
            if (nModelSelected == ITEM_APPR_ARMOR_MODEL_RTHIGH) nModelSelected--;
            else nModelSelected++;
        }
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
    SetLocalObject(oPC, CRAFT_ITEM, oItem);
}
void ClearItemInCraftingWindow(object oPC, object oItem, int nToken)
{
    NuiSetBind(oPC, nToken, "btn_save_event", JsonBool(FALSE));
    NuiSetBind(oPC, nToken, "item_combo_event", JsonBool(TRUE));
    NuiSetBind(oPC, nToken, "btn_select_target_event", JsonBool(TRUE));
    NuiSetBind(oPC, nToken, "btn_info_event", JsonBool(TRUE));
    NuiSetBind(oPC, nToken, "btn_wardrobe_event", JsonBool(TRUE));
    NuiSetBind(oPC, nToken, "btn_cancel_label", JsonString("Exit"));
    NuiSetBind(oPC, nToken, "btn_cancel_tooltip", JsonString("  Exit the crafting menu"));
    if(ai_GetIsWeapon(oItem))
    {
        SetLocalInt(oPC, AI_NO_NUI_SAVE, TRUE);
        NuiSetBind(oPC, nToken, "model_combo_selected", JsonInt(0));
        DelayCommand(1.0, DeleteLocalInt(oPC, AI_NO_NUI_SAVE));
    }
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
void SetModelNumberText(object oPC, object oTarget, int nToken)
{
    json jCraft = GetLocalJson(oPC, CRAFT_JSON);
    int nItem = JsonGetInt(JsonObjectGet(jCraft, CRAFT_ITEM_SELECTION));
    object oItem = GetSelectedItem(oTarget, nItem);
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
        NuiSetBindWatch(oPC, nToken, "txt_color_l", TRUE);
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
                jCraft = JsonObjectSet(jCraft, CRAFT_ALL_COLOR, JsonBool(TRUE));
                jCraft = JsonObjectSet(jCraft, CRAFT_LEFT_PART_COLOR, JsonBool(FALSE));
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
                jCraft = JsonObjectSet(jCraft, CRAFT_ALL_COLOR, JsonBool(TRUE));
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
        SetLocalJson(oPC, CRAFT_JSON, jCraft);
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
    json jRow = CreateLabel(JsonArray(), "Name:", "lbl_name_title", 50.0f, 20.0f, NUI_HALIGN_LEFT);
    jRow = CreateTextEditBox (jRow, "name_placeholder", "txt_item_name", 60, FALSE, 325.0f, 20.0f);
    // Add row to the column.
    json jCol = JsonArrayInsert(JsonArray(), NuiRow(jRow));
    float fHeight = 113.0;
    if(!ai_GetIsServer() || ai_GetIsDungeonMaster(oPC))
    {
        // Row 2 (Tag)************************************************************** 101
        jRow = CreateLabel(JsonArray(), "Tag:", "lbl_tag_title", 50.0f, 20.0f, NUI_HALIGN_LEFT);
        jRow = CreateTextEditBox(jRow, "name_placeholder", "txt_item_tag", 60, FALSE, 325.0f, 20.0f);
        jCol = JsonArrayInsert(jCol, NuiRow(jRow));
        // Row 2 (ResRef)*********************************************************** 129
        jRow = CreateLabel(JsonArray(), "ResRef:", "lbl_resref_title", 50.0f, 20.0f, NUI_HALIGN_LEFT);
        jRow = CreateTextEditBox(jRow, "name_placeholder", "txt_item_resref", 60, FALSE, 325.0f, 20.0f);
        // Add row to the column.
        jCol = JsonArrayInsert(jCol, NuiRow(jRow));
        fHeight += 56.0;
    }
    // Row 3 (Base Item/Weight)************************************************* 157
    jRow = CreateLabel(JsonArray(), "Base Item: ", "lbl_baseitem_title", 67.0f, 20.0f, NUI_HALIGN_LEFT);
    jRow = CreateLabel(jRow, "", "lbl_baseitem", 120.0f, 20.0f, NUI_HALIGN_LEFT);
    jRow = CreateLabel(jRow, "Weight: ", "lbl_weight_title", 48.0f, 20.0f, NUI_HALIGN_LEFT);
    jRow = CreateLabel(jRow, "", "lbl_weight", 30.0f, 20.0f, NUI_HALIGN_LEFT);
    jRow = CreateButton(jRow, "Select Target", "btn_select_target", 100.0f, 20.0f);
    // Add row to the column.
    jCol = JsonArrayInsert(jCol, NuiRow(jRow));
    fHeight += 28.0;
    if(!ai_GetIsServer() || ai_GetIsDungeonMaster(oPC))
    {
        // Row 4 (Gold Value)******************************************************* 185
        jRow = CreateLabel(JsonArray(), "Gold Value: ", "lbl_gold_title", 85.0f, 25.0f, NUI_HALIGN_LEFT);
        jRow = CreateLabel(jRow, "", "lbl_gold_value", 135.0f, 25.0f, NUI_HALIGN_LEFT);
        jRow = CreateLabel(jRow, "Minimum Level: ", "lbl_min_lvl_title", 110.0f, 25.0f, NUI_HALIGN_LEFT);
        jRow = CreateLabel(jRow, "", "lbl_min_lvl", 20.0f, 25.0f, NUI_HALIGN_LEFT);
        // Add row to the column.
        jCol = JsonArrayInsert(jCol, NuiRow(jRow));
        // Row 5 (Plot/Stolen)****************************************************** 213
        jRow = CreateCheckBox(JsonArray(), " Plot", "chbx_plot", 110.0, 25.0f, "chbx_plot_tooltip");
        jRow = CreateCheckBox(jRow, " Stolen", "chbx_stolen", 110.0, 25.0f, "chbx_stolen_tooltip");
        jRow = CreateCheckBox(jRow, " Cursed", "chbx_cursed", 110.0, 25.0f, "chbx_cursed_tooltip");
        // Add row to the column.
        jCol = JsonArrayInsert(jCol, NuiRow(jRow));
        // Row 6 (Identified/Droppable)********************************************* 269
        jRow = CreateCheckBox(JsonArray(), " Identified", "chbx_identified", 110.0, 25.0f, "chbx_identified_tooltip");
        jRow = CreateCheckBox(jRow, " Droppable", "chbx_droppable", 110.0, 25.0f, "chbx_droppable_tooltip");
        jRow = CreateButton(jRow, "Save as UTI", "btn_save_uti", 110.0, 25.0, -1.0, "btn_save_uti_tooltip");
        // Add row to the column.
        jCol = JsonArrayInsert(jCol, NuiRow(jRow));
        // Row 9 (Stack/Variables/Destroy/Charges)********************************** 307
        jRow = CreateTextEditBox(JsonArray(), "name_placeholder", "txt_stack", 4, FALSE, 35.0f, 25.0f);
        jRow = CreateLabel(jRow, " Stack", "lbl_stack_title", 72.0f, 20.0f, NUI_HALIGN_LEFT);
        jRow = CreateTextEditBox(jRow, "name_placeholder", "txt_charges", 4, FALSE, 40.0f, 25.0f);
        jRow = CreateLabel(jRow, " Charges", "lbl_charges_title", 68.0f, 25.0f, NUI_HALIGN_LEFT);
        jRow = CreateButtonSelect(jRow, "Destroy", "btn_destroy", 110.0, 25.0, "btn_destroy_tooltip");
        // Add row to the column.
        jCol = JsonArrayInsert(jCol, NuiRow(jRow));
        fHeight += 132.0;
    }
    // Row 11 (Description)***************************************************** 558
    jRow = CreateTextEditBox(JsonArray(), "desc_placeholder", "txt_desc", 1000, TRUE, 375.0, 243.0, "txt_desc_tooltip");
    // Add row to the column.
    jCol = JsonArrayInsert(jCol, NuiRow(jRow));
    fHeight += 251.0;
    if(!ai_GetIsServer() || ai_GetIsDungeonMaster(oPC) || ALLOW_CRAFT_NAMES)
    {
        // Row 12 (Description Save Button)***************************************** 558
        jRow = JsonArrayInsert(JsonArray(), NuiSpacer());
        jRow = CreateButton(jRow, "Save Description", "btn_save_desc", 150.0f, 20.0f);
        jRow = JsonArrayInsert(jRow, NuiSpacer());
        // Add row to the column.
        jCol = JsonArrayInsert(jCol, NuiRow(jRow));
    }    fHeight += 28.0;
    // Row 13 (Item Base Description)* ***************************************** 158
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
        jRow = CreateTextBox(JsonArray(), "txt_base_desc", 375.0, 150.0, FALSE, NUI_SCROLLBARS_NONE, "txt_base_desc_tooltip");
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
    NuiSetBind(oPC, nToken, "txt_item_name", JsonString(GetName(oItem)));
    if(!ai_GetIsServer() || ai_GetIsDungeonMaster(oPC) || ALLOW_CRAFT_NAMES)
    {
        NuiSetBind(oPC, nToken, "txt_item_name_event", JsonBool(TRUE));
        NuiSetBindWatch(oPC, nToken, "txt_item_name", TRUE);
    }
    if(!ai_GetIsServer() || ai_GetIsDungeonMaster(oPC))
    {
        NuiSetBind(oPC, nToken, "txt_item_tag_event", JsonBool(TRUE));
        NuiSetBind(oPC, nToken, "txt_item_tag", JsonString(GetTag(oItem)));
        NuiSetBindWatch(oPC, nToken, "txt_item_tag", TRUE);
        NuiSetBind(oPC, nToken, "txt_item_resref_event", JsonBool(TRUE));
        NuiSetBind(oPC, nToken, "txt_item_resref", JsonString(GetResRef(oItem)));
        NuiSetBindWatch(oPC, nToken, "txt_item_resref", TRUE);
    }
    string sValue = GetStringByStrRef(StringToInt(Get2DAString("baseitems", "Name", nBaseItemType)));
    NuiSetBind(oPC, nToken, "lbl_baseitem_label", JsonString(sValue));
    sValue = FloatToString(fWeight * 0.1f, 0, 1);
    NuiSetBind(oPC, nToken, "lbl_weight_label", JsonString(sValue));
    NuiSetBind(oPC, nToken, "btn_select_target_event", JsonBool(TRUE));
    NuiSetBind(oPC, nToken, "btn_select_target_tooltip", JsonString("  Select another Item"));
    if(!ai_GetIsServer() || ai_GetIsDungeonMaster(oPC))
    {
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
    }
    // Description
    NuiSetBind(oPC, nToken, "txt_desc", JsonString(GetDescription(oItem)));
    if(!ai_GetIsServer() || ai_GetIsDungeonMaster(oPC) || ALLOW_CRAFT_NAMES)
    {
        NuiSetBind(oPC, nToken, "txt_desc_event", JsonBool(TRUE));
        NuiSetBindWatch(oPC, nToken, "txt_desc", TRUE);
        NuiSetBind(oPC, nToken, "txt_desc_tooltip", JsonString ("  Color codes can be used!"));
        NuiSetBind(oPC, nToken, "btn_save_desc_event", JsonBool(TRUE));
    }
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
        if(sElem == "btn_select_target")
        {
            // Set this variable on the player so PEPS can run the targeting script for this plugin.
            SetLocalString(oPC, AI_PLUGIN_TARGET_SCRIPT, "pe_crafting");
            // Set Targeting variables.
            SetLocalString(oPC, AI_TARGET_MODE, "SELECT_TARGET");
            NuiDestroy(oPC, nToken);
            ai_SendMessages("Select your charcter, a henchman or an item possessed by one.", AI_COLOR_YELLOW, oPC);
            EnterTargetingMode(oPC, OBJECT_TYPE_CREATURE | OBJECT_TYPE_ITEM ,
                                MOUSECURSOR_EXAMINE, MOUSECURSOR_NOEXAMINE);
        }
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
        if(sElem == "btn_save_desc")
        {
            string sDescription = JsonGetString(NuiGetBind(oPC, nToken, "txt_desc"));
            SetDescription(oItem, sDescription);
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
}  */
json CreateItemCombo(object oPC, json jRow, string sComboBind)
{
    int nCnt;
    // Create the list.
    json jCombo = JsonArrayInsert(JsonArray(), NuiComboEntry("Armor", 0));
    jCombo = JsonArrayInsert(jCombo, NuiComboEntry("Cloak", 1));
    jCombo = JsonArrayInsert(jCombo, NuiComboEntry("Headgear", 2));
    jCombo = JsonArrayInsert(jCombo, NuiComboEntry("Right hand", 3));
    jCombo = JsonArrayInsert(jCombo, NuiComboEntry("Left hand", 4));
    return CreateCombo(jRow, jCombo, sComboBind, 128.0, 40.0);
}
json CreateModelCombo(object oPC, object oTarget, json jRow, string sComboBind)
{
    float fFacing = GetFacing(oTarget);
    json jCombo, jCraft = GetLocalJson(oPC, CRAFT_JSON);
    int nSelected = JsonGetInt(JsonObjectGet(jCraft, CRAFT_ITEM_SELECTION));
    // Create the list.
    // Armor.
    if(nSelected == 0)
    {
        fFacing += 180.0f;
        if (fFacing > 359.0) fFacing -=359.0;
        AssignCommand(oPC, SetCameraFacing(fFacing, 4.5f, 75.0, CAMERA_TRANSITION_TYPE_VERY_FAST));
        jCombo = JsonArrayInsert(JsonArray(), NuiComboEntry("Neck", 0));
        jCombo = JsonArrayInsert(jCombo, NuiComboEntry("Shoulder", 1));
        jCombo = JsonArrayInsert(jCombo, NuiComboEntry("Bicep", 2));
        jCombo = JsonArrayInsert(jCombo, NuiComboEntry("Forearm", 3));
        jCombo = JsonArrayInsert(jCombo, NuiComboEntry("Hand", 4));
        jCombo = JsonArrayInsert(jCombo, NuiComboEntry("Torso", 5));
        jCombo = JsonArrayInsert(jCombo, NuiComboEntry("Belt", 6));
        jCombo = JsonArrayInsert(jCombo, NuiComboEntry("Pelvis", 7));
        jCombo = JsonArrayInsert(jCombo, NuiComboEntry("Thigh", 8));
        jCombo = JsonArrayInsert(jCombo, NuiComboEntry("Shin", 9));
        jCombo = JsonArrayInsert(jCombo, NuiComboEntry("Foot", 10));
        jCombo = JsonArrayInsert(jCombo, NuiComboEntry("Robe", 11));
    }
    // Cloak.
    else if(nSelected == 1)
    {
        if(fFacing > 359.0) fFacing -=359.0;
        AssignCommand (oPC, SetCameraFacing(fFacing, 4.5f, 75.0, CAMERA_TRANSITION_TYPE_VERY_FAST));
        jCombo = JsonArrayInsert(JsonArray(), NuiComboEntry("Cloak", 0));
        jCombo = JsonArrayInsert(jCombo, NuiComboEntry("Invisible", 1));
    }
    // Headgear.
    else if (nSelected == 2)
    {
        fFacing += 180.0f;
        if(fFacing > 359.0) fFacing -=359.0;
        AssignCommand(oPC, SetCameraFacing(fFacing, 2.5f, 75.0, CAMERA_TRANSITION_TYPE_VERY_FAST));
        jCombo = JsonArrayInsert(JsonArray(), NuiComboEntry("Headgear", 0));
        jCombo = JsonArrayInsert(jCombo, NuiComboEntry("Invisible", 1));
    }
    // Weapon.
    else if (nSelected == 3)
    {
        // If they are changing a bow then face the opposite side.
        object oItem = GetItemInSlot(INVENTORY_SLOT_RIGHTHAND, oPC);
        int nBaseItemType = GetBaseItemType(oItem);
        if(nBaseItemType == BASE_ITEM_LONGBOW || nBaseItemType == BASE_ITEM_SHORTBOW) fFacing -= 90.00;
        // This will make the camera face a melee weapon.
        else fFacing += 90.0;
        if(fFacing > 359.0) fFacing -=359.0;
        AssignCommand(oPC, SetCameraFacing(fFacing, 3.5f, 75.0, CAMERA_TRANSITION_TYPE_VERY_FAST));
        jCombo = JsonArrayInsert(JsonArray(), NuiComboEntry("Weapon", 0));
        jCombo = JsonArrayInsert(jCombo, NuiComboEntry("Acidic", 1));
        jCombo = JsonArrayInsert(jCombo, NuiComboEntry("Frost", 2));
        jCombo = JsonArrayInsert(jCombo, NuiComboEntry("Electric", 3));
        jCombo = JsonArrayInsert(jCombo, NuiComboEntry("Unholy", 4));
        jCombo = JsonArrayInsert(jCombo, NuiComboEntry("Flaming", 5));
        jCombo = JsonArrayInsert(jCombo, NuiComboEntry("Holy", 6));
        jCombo = JsonArrayInsert(jCombo, NuiComboEntry("Sonic", 7));
}
    // Weapon/Shield.
    else if(nSelected == 4)
    {
        fFacing += 270.0f;
        if(fFacing > 359.0) fFacing -=359.0;
        AssignCommand(oPC, SetCameraFacing(fFacing, 3.5f, 75.0, CAMERA_TRANSITION_TYPE_VERY_FAST));
        object oItem = GetItemInSlot(INVENTORY_SLOT_LEFTHAND, oPC);
        if(ai_GetIsShield(oItem))
        {
            jCombo = JsonArrayInsert(JsonArray(), NuiComboEntry("Shield", 0));
            jCombo = JsonArrayInsert(jCombo, NuiComboEntry("Invisible", 1));
        }
        else
        {
            jCombo = JsonArrayInsert(JsonArray(), NuiComboEntry("Weapon", 0));
            jCombo = JsonArrayInsert(jCombo, NuiComboEntry("Acidic", 1));
            jCombo = JsonArrayInsert(jCombo, NuiComboEntry("Frost", 2));
            jCombo = JsonArrayInsert(jCombo, NuiComboEntry("Electric", 3));
            jCombo = JsonArrayInsert(jCombo, NuiComboEntry("Unholy", 4));
            jCombo = JsonArrayInsert(jCombo, NuiComboEntry("Flaming", 5));
            jCombo = JsonArrayInsert(jCombo, NuiComboEntry("Holy", 6));
            jCombo = JsonArrayInsert(jCombo, NuiComboEntry("Sonic", 7));
        }
    }
    return CreateCombo(jRow, jCombo, sComboBind, 128.0, 40.0);
}
void CreateCreatureCraftingGUIPanel(object oPC, object oTarget)
{
    json jCraft = GetLocalJson(oPC, CRAFT_JSON);
    if(JsonGetType(jCraft) == JSON_TYPE_NULL) jCraft = JsonObject();
    // Row 1 (Object Name)****************************************************** 508 / 83
    json jRow = CreateTextEditBox(JsonArray(), "plc_hold_bind", "txt_item_name", 50, FALSE, 486.0f, 30.0f);  // 419
    json jCol = JsonArrayInsert(JsonArray(), NuiRow(jRow));
    // Row 2 (Object Name)****************************************************** 508 / 121
    jRow = JsonArray();
    jRow = CreateButton(jRow, "Information", "btn_info", 160.0f, 30.0f, -1.0, "btn_info_tooltip");
    jRow = CreateButton(jRow, "Wardrobe", "btn_wardrobe", 158.0f, 30.0f, -1.0, "btn_wardrobe_tooltip");
    jRow = CreateButtonSelect(jRow, "Add Light", "btn_highlight", 160.0f, 30.0f, "btn_highlight_tooltip");
    jCol = JsonArrayInsert(jCol, NuiRow(jRow));
    // Row 3 (Object Name)****************************************************** 508 / 159
    jRow = CreateButton(JsonArray(), "Save", "btn_save", 160.0f, 30.0f, -1.0, "btn_save_tooltip");
    jRow = CreateButton(jRow, "Select Target", "btn_select_target", 158.0f, 30.0f, -1.0, "btn_select_target_tooltip");
    jRow = CreateButton(jRow, "", "btn_cancel", 160.0f, 30.0f, -1.0, "btn_cancel_tooltip");
    jCol = JsonArrayInsert(jCol, NuiRow(jRow));
    // Row 4 (labels)*********************************************************** 508 / 177
    jRow = CreateLabel(JsonArray(), "Model", "module_title", 143.0f, 10.0f);
    jRow = CreateLabel(jRow, "Color", "color_title", 339.0f, 10.0f);
    jRow = JsonArrayInsert(jCol, NuiRow(jRow));
    // Row 5 (groups)
    // Row 51 (title)*********************************************************** 508 / 195 / 18
    json jGroupRow = CreateLabel(JsonArray(), "Item", "item__cmb_title", 128.0f, 10.0f);
    json jGroupCol = JsonArrayInsert(JsonArray(), NuiRow(jGroupRow));
    // Row 52 (combo)*********************************************************** 508 / 233 / 56
    jGroupRow = CreateItemCombo(oPC, JsonArray(), "item_combo");
    jGroupCol = JsonArrayInsert(jGroupCol, NuiRow(jGroupRow));
    // Row 53 (title)*********************************************************** 508 / 251 / 74
    jGroupRow = CreateLabel(JsonArray(), "Model", "model_cmb_title",128.0f, 10.0f);
    jGroupCol = JsonArrayInsert(jGroupCol, NuiRow(jGroupRow));
    // Row 54 (combo)*********************************************************** 508 / 289 / 112
    jGroupRow = CreateModelCombo(oPC, oTarget, JsonArray(), "model_combo");
    jGroupCol = JsonArrayInsert(jGroupCol, NuiRow(jGroupRow));
    // Row 55 (title)*********************************************************** 508 / 307 / 120
    jGroupRow = CreateLabel(JsonArray(), "", "top_title",128.0f, 10.0f);
    jGroupCol = JsonArrayInsert(jGroupCol, NuiRow(jGroupRow));
    // Row 56 (top)************************************************************* 508 / 355 / 168
    jGroupRow = CreateButtonImage(JsonArray(), "nui_shld_left", "btn_prev_t", 40.0f, 40.0f);
    // Removed TextEditBox for mobile
    jGroupRow = CreateTextEditBox(jGroupRow, "place_holder", "txt_model_number_t", 3, FALSE, 40.0, 40.0);
    //CreateLabel(jGroupRow, "", "txt_model_number_t", 40.0, 40.0);
    jGroupRow = CreateButtonImage(jGroupRow, "nui_shld_right", "btn_next_t", 40.0f, 40.0f);
    jGroupCol = JsonArrayInsert(jGroupCol, NuiRow(jGroupRow));
    // Row 57 (title)*********************************************************** 508 / 373 / 186
    jGroupRow = CreateLabel(JsonArray(), "", "middle_title",128.0f, 10.0f);
    jGroupCol = JsonArrayInsert(jGroupCol, NuiRow(jGroupRow));
    // Row 58 (middle)********************************************************** 508 / 421 /234
    jGroupRow = CreateButtonImage(JsonArray(), "nui_shld_left", "btn_prev_m", 40.0f, 40.0f);
    // Removed TextEditBox for mobile
    jGroupRow = CreateTextEditBox(jGroupRow, "place_holder", "txt_model_number_m", 3, FALSE, 40.0, 40.0);
    //CreateLabel(jGroupRow, "", "txt_model_number_m", 40.0, 40.0);
    jGroupRow = CreateButtonImage(jGroupRow, "nui_shld_right", "btn_next_m", 40.0f, 40.0f);
    jGroupCol = JsonArrayInsert(jGroupCol, NuiRow(jGroupRow));
    // Row 59 (title)*********************************************************** 508 / 439 / 252
    jGroupRow = CreateLabel(JsonArray(), "", "bottom_title",128.0f, 10.0f);
    jGroupCol = JsonArrayInsert(jGroupCol, NuiRow(jGroupRow));
    // Row 510 (bottom)********************************************************* 508 / 487 /300
    jGroupRow = CreateButtonImage(JsonArray(), "nui_shld_left", "btn_prev_b", 40.0f, 40.0f);
    // Removed TextEditBox for mobile
    jGroupRow = CreateTextEditBox(jGroupRow, "place_holder", "txt_model_number_b", 3, FALSE, 40.0, 40.0);
    //CreateLabel(jGroupRow, "", "txt_model_number_b", 40.0, 40.0);
    jGroupRow = CreateButtonImage(jGroupRow, "nui_shld_right", "btn_next_b", 40.0f, 40.0f);
    jGroupCol = JsonArrayInsert(jGroupCol, NuiRow(jGroupRow));
    // Row 511 (blank spacer)
    jGroupRow = CreateLabel(JsonArray(), "", "blank_space",128.0f, 20.0f);
    jGroupCol = JsonArrayInsert(jGroupCol, NuiRow(jGroupRow));
    // Row 512 (light)********************************************************** 508 / 487 /300
    jGroupRow = CreateButtonSelect(JsonArray(), "Randomize", "btn_randomize", 128.0f, 30.0f);
    jGroupCol = JsonArrayInsert(jGroupCol, NuiRow(jGroupRow));
    jGroupCol = JsonArrayInsert(jGroupCol, NuiSpacer());
    jRow = JsonArrayInsert(JsonArray(), NuiHeight(NuiWidth(NuiGroup(NuiCol(jGroupCol)), 143.0), 442.0));
    // Make the Color Group.
    // Row 550 (groups)********************************************************* 508 / 361 / 184
    json jImage = NuiEnabled(NuiId(NuiImage(NuiBind("color_pallet_image"), JsonInt(0), JsonInt(0), JsonInt(1)), "color_pallet"), NuiBind("color_pallet_event"));
    jImage = NuiWidth(jImage, 320.0);  // 256 + 64
    jImage = NuiHeight(jImage, 220.0); // 176 + 44
    jImage = NuiTooltip(jImage, NuiBind("color_pallet_tooltip"));
    json jIndicator = JsonArrayInsert(JsonArray(), NuiDrawListRect(JsonBool(TRUE), NuiColor(255,0,0), JsonBool(FALSE), JsonFloat(2.0), NuiBind("color_pallet_pointer")));
    jImage = NuiDrawList(jImage, JsonBool(FALSE), jIndicator);
    jGroupRow = JsonArrayInsert(JsonArray(), jImage);
    jGroupCol = JsonArrayInsert(JsonArray(), NuiRow(jGroupRow));
    // Row 551 (groups)********************************************************* 508 / 379 /202
    jGroupRow = CreateLabel(JsonArray(), "Part To Color", "lbl_color_parts", 320.0f, 10.0f);
    jGroupCol = JsonArrayInsert(jGroupCol, NuiRow(jGroupRow));
    // Row 552 (groups)********************************************************* 508 / 417 /240
    jGroupRow = CreateButtonSelect(JsonArray(), "Right", "btn_right_part_color", 98.0, 30.0, "btn_right_part_color_tooltip");
    jGroupRow = JsonArrayInsert(jGroupRow, NuiSpacer());
    jGroupRow = CreateButtonSelect(jGroupRow, "All", "btn_all_color", 98.0, 30.0, "btn_all_color_tooltip");
    jGroupRow = JsonArrayInsert(jGroupRow, NuiSpacer());
    jGroupRow = CreateButtonSelect(jGroupRow, "Left", "btn_left_part_color", 98.0, 30.0, "btn_left_part_color_tooltip");
    jGroupCol = JsonArrayInsert(jGroupCol, NuiRow(jGroupRow));
    // Row 553 (groups)********************************************************* 508 / 435 / 258
    jGroupRow = CreateLabel(JsonArray(), "Part Color To Reset", "lbl_reset_parts", 320.0f, 10.0f);
    jGroupCol = JsonArrayInsert(jGroupCol, NuiRow(jGroupRow));
    // Row 554 (groups)********************************************************* 508 / 473 /296
    jGroupRow = CreateButton(JsonArray(), "Right", "btn_right_part_reset", 98.0, 30.0, -1.0, "btn_right_part_reset_tooltip");
    jGroupRow = JsonArrayInsert(jGroupRow, NuiSpacer());
    jGroupRow = CreateButton(jGroupRow, "All", "btn_all_reset", 50.0, 30.0, -1.0, "btn_all_reset_tooltip");
    jGroupRow = JsonArrayInsert(jGroupRow, NuiSpacer());
    jGroupRow = CreateButton(jGroupRow, "Left", "btn_left_part_reset", 98.0, 30.0, -1.0, "btn_left_part_reset_tooltip");
    jGroupCol = JsonArrayInsert(jGroupCol, NuiRow(jGroupRow));
    // Row 555 (groups)********************************************************* 508 / 491 / 314
    jGroupRow = CreateLabel(JsonArray(), "Material to Color", "lbl_material_color", 320.0f, 10.0f);
    jGroupCol = JsonArrayInsert(jGroupCol, NuiRow(jGroupRow));
    // Row 556 (groups)********************************************************* 508 / 529 /352
    jGroupRow = CreateButtonSelect(JsonArray(), "Leather 1", "btn_material_0", 98.0, 30.0);
    jGroupRow = JsonArrayInsert(jGroupRow, NuiSpacer());
    jGroupRow = CreateButtonSelect(jGroupRow, "Cloth 1", "btn_material_2", 98.0, 30.0);
    jGroupRow = JsonArrayInsert(jGroupRow, NuiSpacer());
    jGroupRow = CreateButtonSelect(jGroupRow, "Metal 1", "btn_material_4", 98.0, 30.0);
    jGroupCol = JsonArrayInsert(jGroupCol, NuiRow(jGroupRow));
    // Row 557 (groups)********************************************************* 508 / 567 / 390
    jGroupRow = CreateButtonSelect(JsonArray(), "Leather 2", "btn_material_1", 98.0, 30.0);
    jGroupRow = JsonArrayInsert(jGroupRow, NuiSpacer());
    jGroupRow = CreateButtonSelect(jGroupRow, "Cloth 2", "btn_material_3", 98.0, 30.0);
    jGroupRow = JsonArrayInsert(jGroupRow, NuiSpacer());
    jGroupRow = CreateButtonSelect(jGroupRow, "Metal 2", "btn_material_5", 98.0, 30.0);
    jGroupCol = JsonArrayInsert(jGroupCol, NuiRow(jGroupRow));
    jGroupCol = JsonArrayInsert(jGroupCol, NuiSpacer());
    jRow = JsonArrayInsert(jRow, NuiHeight(NuiWidth(NuiGroup(NuiCol(jGroupCol)), 339.0), 442.0));  // 275 398
    jCol = JsonArrayInsert(jCol, NuiRow(jRow));
    json jLayout = NuiCol(jCol);
    // Get the window location to restore it from the database.
    json jGeometry = JsonObjectGet(jCraft, "CRAFT_MENU");
    float fX = JsonGetFloat(JsonObjectGet(jGeometry, "x"));
    float fY = JsonGetFloat(JsonObjectGet(jGeometry, "y"));
    string sPCWindow;
    int nToken = SetWindow(oPC, jLayout, "crafting_nui", "Crafting",
                 fX, fY, 508.0, 700.0, FALSE, FALSE, FALSE, FALSE, TRUE, "pe_crafting");  // 444 645
    // Set all binds, events, and watches.
    NuiSetBindWatch (oPC, nToken, "window_geometry", TRUE);
    int nItem = JsonGetInt(JsonObjectGet(jCraft, CRAFT_ITEM_SELECTION));
    object oItem = GetSelectedItem(oTarget, nItem);
    // Row 1
    NuiSetBind(oPC, nToken, "txt_item_name", JsonString(GetName(oItem)));
    if(!ai_GetIsServer() || ai_GetIsDungeonMaster(oPC) || ALLOW_CRAFT_NAMES)
    {
        NuiSetBind(oPC, nToken, "txt_item_name_event", JsonBool(TRUE));
        NuiSetBindWatch(oPC, nToken, "txt_item_name", TRUE);
    }
    // Row 2
    NuiSetBind(oPC, nToken, "btn_info_event", JsonBool(TRUE));
    NuiSetBind(oPC, nToken, "btn_info_tooltip", JsonString("  Look at and change item information"));
    NuiSetBind(oPC, nToken, "btn_wardrobe_event", JsonBool(TRUE));
    NuiSetBind(oPC, nToken, "btn_wardrobe_tooltip", JsonString("  Use your wardrobe to save/load item appearances"));
    int nLight = GetLocalInt(oPC, CRAFT_HIGHLIGHT) + GetLocalInt(oPC, CRAFT_ULTRALIGHT);
    NuiSetBind(oPC, nToken, "btn_highlight", JsonBool(nLight));
    NuiSetBind(oPC, nToken, "btn_highlight_event", JsonBool(TRUE));
    NuiSetBind(oPC, nToken, "btn_highlight_tooltip", JsonString("  Left click for White light, Right click for Ultravision"));
    // Row 3
    NuiSetBind(oPC, nToken, "btn_save_event", JsonBool(FALSE));
    NuiSetBind(oPC, nToken, "btn_save_tooltip", JsonString("  Save current changes"));
    NuiSetBind(oPC, nToken, "btn_select_target_event", JsonBool(TRUE));
    NuiSetBind(oPC, nToken, "btn_select_target_tooltip", JsonString("  Select another party member or Item"));
    NuiSetBind(oPC, nToken, "btn_cancel_label", JsonString("Exit"));
    NuiSetBind(oPC, nToken, "btn_cancel_event", JsonBool(TRUE));
    NuiSetBind(oPC, nToken, "btn_cancel_tooltip", JsonString("  Exit the crafting menu"));
    // Row 4 Labels.
    // Row 5 Groups.
    // Row 51 title.
    // Row 52
    NuiSetBind(oPC, nToken, "item_combo_selected", JsonInt(nItem));
    NuiSetBind(oPC, nToken, "item_combo_event", JsonBool(TRUE));
    NuiSetBindWatch(oPC, nToken, "item_combo_selected", TRUE);
    // Row 53 title.
    // Row 54
    int nSelected = JsonGetInt(JsonObjectGet(jCraft, CRAFT_MODEL_SELECTION));
    if(nItem == 1 || nItem == 2 || nItem == 4)
    {
        if(GetHiddenWhenEquipped(oItem)) nSelected = 1;
        else nSelected = 0;
    }
    NuiSetBind(oPC, nToken, "model_combo_selected", JsonInt (nSelected));
    NuiSetBind(oPC, nToken, "model_combo_event", JsonBool (TRUE));
    NuiSetBindWatch(oPC, nToken, "model_combo_selected", TRUE);
    // Row 55, 56, 57 titles
    // Row 58 top, 59 middle, 510 bottom
    string sModelTop, sModelMiddle, sModelBottom;
    // Model Group
    if(ai_GetIsWeapon(oItem))
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
        // Row 55
        NuiSetBind(oPC, nToken, "top_title_label", JsonString("Top"));
        // Row 56
        //NuiSetBind(oPC, nToken, "txt_model_number_t_event", JsonBool(TRUE));
        NuiSetBind(oPC, nToken, "txt_model_number_t", JsonString(sModelTop));
        NuiSetBind(oPC, nToken, "btn_prev_t_event", JsonBool(TRUE));
        NuiSetBind(oPC, nToken, "btn_next_t_event", JsonBool(TRUE));
        // Row 57
        NuiSetBind(oPC, nToken, "middle_title_label", JsonString("Middle"));
        // Row 58
        //NuiSetBind(oPC, nToken, "txt_model_number_m_event", JsonBool(TRUE));
        NuiSetBind(oPC, nToken, "txt_model_number_m", JsonString(sModelMiddle));
        NuiSetBind(oPC, nToken, "btn_prev_m_event", JsonBool(TRUE));
        NuiSetBind(oPC, nToken, "btn_next_m_event", JsonBool(TRUE));
        // Row 59
        NuiSetBind(oPC, nToken, "bottom_title_label", JsonString("Bottom"));
        // Row 510
        //NuiSetBind(oPC, nToken, "txt_model_number_b_event", JsonBool(TRUE));
        NuiSetBind(oPC, nToken, "txt_model_number_b", JsonString(sModelBottom));
        NuiSetBind(oPC, nToken, "btn_prev_b_event", JsonBool(TRUE));
        NuiSetBind(oPC, nToken, "btn_next_b_event", JsonBool(TRUE));
        // Row 511
        NuiSetBind(oPC, nToken, "btn_randomize_event", JsonBool(TRUE));
        NuiSetBind(oPC, nToken, "btn_randomize_tooltip", JsonString("  Randomize the selected weapon"));
    }
    // Armor and clothing
    else if(nItem == 0)
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
            // Row 55
            NuiSetBind(oPC, nToken, "top_title_label", JsonString(""));
            // Row 56
            //NuiSetBind(oPC, nToken, "txt_model_number_t_event", JsonBool(FALSE));
            NuiSetBind(oPC, nToken, "txt_model_name_t", JsonString(""));
            NuiSetBind(oPC, nToken, "btn_prev_t_event", JsonBool(FALSE));
            NuiSetBind(oPC, nToken, "btn_next_t_event", JsonBool(FALSE));
            // Row 57
            NuiSetBind(oPC, nToken, "middle_title_label", JsonString("Model"));
            // Row 58
            //NuiSetBind(oPC, nToken, "txt_model_number_m_event", JsonBool(TRUE));
            NuiSetBind(oPC, nToken, "txt_model_number_m", JsonString(sModelMiddle));
            NuiSetBind(oPC, nToken, "btn_prev_m_event", JsonBool(TRUE));
            NuiSetBind(oPC, nToken, "btn_next_m_event", JsonBool(TRUE));
            // Row 59
            NuiSetBind(oPC, nToken, "bottom_title_label", JsonString(""));
            // Row 510
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
            // Row 55
            NuiSetBind(oPC, nToken, "top_title_label", JsonString("Right"));
            // Row 56
            //NuiSetBind(oPC, nToken, "txt_model_number_t_event", JsonBool(TRUE));
            NuiSetBind(oPC, nToken, "txt_model_number_t", JsonString(sModelTop));
            NuiSetBind(oPC, nToken, "btn_prev_t_event", JsonBool(TRUE));
            NuiSetBind(oPC, nToken, "btn_next_t_event", JsonBool(TRUE));
            // Row 57
            NuiSetBind(oPC, nToken, "middle_title_label", JsonString("Right & Left"));
            // Row 58
            //NuiSetBind(oPC, nToken, "txt_model_number_m_event", JsonBool(TRUE));
            NuiSetBind(oPC, nToken, "txt_model_number_m", JsonString(sModelTop));
            NuiSetBind(oPC, nToken, "btn_prev_m_event", JsonBool(TRUE));
            NuiSetBind(oPC, nToken, "btn_next_m_event", JsonBool(TRUE));
            // Row 59
            NuiSetBind(oPC, nToken, "bottom_title_label", JsonString("Left"));
            // Row 510
            //NuiSetBind(oPC, nToken, "txt_model_number_b_event", JsonBool(TRUE));
            NuiSetBind(oPC, nToken, "txt_model_number_b", JsonString(sModelBottom));
            NuiSetBind(oPC, nToken, "btn_prev_b_event", JsonBool(TRUE));
            NuiSetBind(oPC, nToken, "btn_next_b_event", JsonBool(TRUE));
        }
        // Row 511
        NuiSetBind(oPC, nToken, "btn_randomize_event", JsonBool(TRUE));
        NuiSetBind(oPC, nToken, "btn_randomize_tooltip", JsonString("  Randomize the selected armor"));
    }
    // Shields, Cloaks, and Helmets.
    else
    {
        sModelMiddle = IntToString(GetItemAppearance(oItem, ITEM_APPR_TYPE_SIMPLE_MODEL, 0));
            // Row 55
        NuiSetBind(oPC, nToken, "top_title_label", JsonString(""));
            // Row 56
        //NuiSetBind(oPC, nToken, "txt_model_number_t_event", JsonBool(FALSE));
        NuiSetBind(oPC, nToken, "txt_model_number_t", JsonString(""));
        NuiSetBind(oPC, nToken, "btn_prev_t_event", JsonBool(FALSE));
        NuiSetBind(oPC, nToken, "btn_next_t_event", JsonBool(FALSE));
            // Row 57
        NuiSetBind(oPC, nToken, "middle_title_label", JsonString("Model"));
            // Row 58
        //NuiSetBind(oPC, nToken, "txt_model_number_m_event", JsonBool(TRUE));
        NuiSetBind(oPC, nToken, "txt_model_number_m", JsonString(sModelMiddle));
        NuiSetBind(oPC, nToken, "btn_prev_m_event", JsonBool(TRUE));
        NuiSetBind(oPC, nToken, "btn_next_m_event", JsonBool(TRUE));
            // Row 59
        NuiSetBind(oPC, nToken, "bottom_title_label", JsonString(""));
            // Row 510
        //NuiSetBind(oPC, nToken, "txt_model_number_b_event", JsonBool(FALSE));
        NuiSetBind(oPC, nToken, "txt_model_number_b", JsonString(""));
        NuiSetBind(oPC, nToken, "btn_prev_b_event", JsonBool(FALSE));
        NuiSetBind(oPC, nToken, "btn_next_b_event", JsonBool(FALSE));
        // Row 511
        NuiSetBind(oPC, nToken, "btn_randomize_event", JsonBool(TRUE));
        NuiSetBind(oPC, nToken, "btn_randomize_tooltip", JsonString("  Randomize the selected item"));
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
        int nMaterialSelected = JsonGetInt(JsonObjectGet(jCraft, CRAFT_MATERIAL_SELECTION));
        int nModelSelected = GetArmorModelSelected(oPC);
        // Row 511
        NuiSetBind(oPC, nToken, "color_pallet_image", JsonString(sColorPallet));
        NuiSetBind(oPC, nToken, "color_pallet_event", JsonBool(TRUE));
        NuiSetBind(oPC, nToken, "color_pallet_tooltip", JsonString("  Select a color or use the mouse wheel"));
        int nSelectedRight, nSelectedAll, nSelectedLeft;
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
            int nPartColor = GetHasPartColor(oItem, nModelSelected, "Right");
            nSelectedRight = JsonGetInt(JsonObjectGet(jCraft, CRAFT_RIGHT_PART_COLOR));
            if(!nSelectedRight && nPartColor)
            {
                nSelectedRight = TRUE;
                nSelectedLeft = FALSE;
            }
            nSelectedAll = !nSelectedRight;
            jCraft = JsonObjectSet(jCraft, CRAFT_ALL_COLOR, JsonBool(nSelectedAll));
            jCraft = JsonObjectSet(jCraft, CRAFT_RIGHT_PART_COLOR, JsonBool(nSelectedRight));
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
            // Row 512 - Label Part to Color
            // Row 5l3
            int nPartColor = GetHasPartColor(oItem, nModelSelected, "Right");
            nSelectedRight = JsonGetInt(JsonObjectGet(jCraft, CRAFT_RIGHT_PART_COLOR));
            if(!nSelectedRight && nPartColor)
            {
                nSelectedRight = TRUE;
                nSelectedLeft = FALSE;
            }
            else
            {
                nPartColor = GetHasPartColor(oItem, nModelSelected, "Left");
                nSelectedLeft = JsonGetInt(JsonObjectGet(jCraft, CRAFT_LEFT_PART_COLOR));
                if(!nSelectedLeft && nPartColor)
                {
                    nSelectedLeft = TRUE;
                    nSelectedRight = FALSE;
                }
            }
            nSelectedAll = !nSelectedRight && !nSelectedLeft;
            jCraft = JsonObjectSet(jCraft, CRAFT_LEFT_PART_COLOR, JsonBool(nSelectedLeft));
            jCraft = JsonObjectSet(jCraft, CRAFT_ALL_COLOR, JsonBool(nSelectedAll));
            jCraft = JsonObjectSet(jCraft, CRAFT_RIGHT_PART_COLOR, JsonBool(nSelectedRight));
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
            NuiSetBind(oPC, nToken, "btn_right_part_reset_event", JsonBool(nSelectedRight));
            NuiSetBind(oPC, nToken, "btn_all_reset_event", JsonBool(nSelectedAll));
            NuiSetBind(oPC, nToken, "btn_left_part_reset_event", JsonBool(nSelectedLeft));
        }
        int nColor;
        if(!JsonGetInt(NuiGetBind(oPC, nToken, "btn_all_color")))
        {
            int nModelSelected = GetArmorModelSelected(oPC);
            if(!JsonGetInt(JsonObjectGet(jCraft, CRAFT_RIGHT_PART_COLOR)))
            {
                // Note: Right Thigh and Left Thigh are backwards so this fixes that!
                if (nModelSelected == ITEM_APPR_ARMOR_MODEL_RTHIGH) nModelSelected--;
                else nModelSelected++;
            }
            int nIndex = ITEM_APPR_ARMOR_NUM_COLORS + (nModelSelected * ITEM_APPR_ARMOR_NUM_COLORS) + nMaterialSelected;
            nColor = GetItemAppearance(oItem, ITEM_APPR_TYPE_ARMOR_COLOR, nIndex);
        }
        else nColor = 255;
        if(nColor == 255) nColor = GetItemAppearance(oItem, ITEM_APPR_TYPE_ARMOR_COLOR, nMaterialSelected);
        float fPointX = IntToFloat((nColor - ((nColor / 16) * 16)) * 20);
        float fPointY = IntToFloat((nColor / 16) * 20);
        NuiSetBind(oPC, nToken, "color_pallet_pointer", NuiRect(fPointX, fPointY, 20.0, 20.0));
        // Row 516 - Label Material to Color
        // Row 517 & 518
        NuiSetBind(oPC, nToken, "btn_right_part_color_tooltip", JsonString("  Select the right part to be uniquely colored"));
        NuiSetBind(oPC, nToken, "btn_all_color_tooltip", JsonString("  Select all parts to be colored"));
        NuiSetBind(oPC, nToken, "btn_left_part_color_tooltip", JsonString("  Select the left part to be uniquely colored"));
        NuiSetBind(oPC, nToken, "btn_right_part_reset_tooltip", JsonString("  Clears the right part's unique color"));
        NuiSetBind(oPC, nToken, "btn_all_reset_tooltip", JsonString("  Clears all parts unique colors"));
        NuiSetBind(oPC, nToken, "btn_left_part_reset_tooltip", JsonString("  Clears the left part's unique color"));
        nSelected = JsonGetInt(JsonObjectGet(jCraft, CRAFT_MATERIAL_SELECTION));
        SetMaterialButtons(oPC, nToken, nSelected);
        SetLocalJson(oPC, CRAFT_JSON, jCraft);
    }
    // Cloaks and Helmets.
    else
    {
        // Row 511
        string sColorPallet = GetLocalString(oPC, CRAFT_COLOR_PALLET);
        if(sColorPallet == "") sColorPallet = "gui_pal_tattoo";
        int nMaterialSelected = JsonGetInt(JsonObjectGet(jCraft, CRAFT_MATERIAL_SELECTION));
        int nModelSelected = JsonGetInt(JsonObjectGet(jCraft, CRAFT_MODEL_SELECTION));
        int nColor = GetItemAppearance(oItem, ITEM_APPR_TYPE_ARMOR_COLOR, nMaterialSelected);
        float fPointX = IntToFloat((nColor - ((nColor / 16) * 16)) * 20);
        float fPointY = IntToFloat((nColor / 16) * 20);
        NuiSetBind(oPC, nToken, "color_pallet_pointer", NuiRect(fPointX, fPointY, 20.0, 20.0));
        NuiSetBind(oPC, nToken, "color_pallet_image", JsonString(sColorPallet));
        NuiSetBind(oPC, nToken, "color_pallet_event", JsonBool(TRUE));
        NuiSetBind(oPC, nToken, "color_pallet_tooltip", JsonString("  Select a color or use the mouse wheel"));
        // Row 512 - Label Part to Color
        // Row 5l3
        NuiSetBind(oPC, nToken, "btn_right_part_color_event", JsonBool(FALSE));
        NuiSetBind(oPC, nToken, "btn_right_part_color_event", JsonBool(FALSE));
        NuiSetBind(oPC, nToken, "btn_all_color_event", JsonBool(TRUE));
        NuiSetBind(oPC, nToken, "btn_all_color", JsonBool(TRUE));
        NuiSetBind(oPC, nToken, "btn_left_part_color_event", JsonBool(FALSE));
        NuiSetBind(oPC, nToken, "btn_left_part_color", JsonBool(FALSE));
        // Row 514 - Label Part Color to Reset
        // Row 5l5
        NuiSetBind(oPC, nToken, "btn_right_part_reset_event", JsonBool(FALSE));
        //NuiSetBind(oPC, nToken, "btn_all_reset_event", JsonBool(FALSE));
        NuiSetBind(oPC, nToken, "btn_left_part_reset_event", JsonBool(FALSE));
        // Row 516 - Label Material to Color
        // Row 517 & 518
        nSelected = JsonGetInt(JsonObjectGet(jCraft, CRAFT_MATERIAL_SELECTION));
        SetMaterialButtons(oPC, nToken, nSelected);
    }
    // Lets make sure we clean up any cool down variables.
    //DeleteLocalInt(oPC, CRAFT_COOL_DOWN);
}

