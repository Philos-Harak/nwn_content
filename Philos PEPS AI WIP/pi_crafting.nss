/*//////////////////////////////////////////////////////////////////////////////
// Script Name: pi_crafting
////////////////////////////////////////////////////////////////////////////////
 Executable plug in script for Philos Module Extentions

 Crafting UI for players items.
*///////////////////////////////////////////////////////////////////////////////
#include "0i_nui"
#include "0i_items"
const string CRAFT_COOL_DOWN = "CRAFT_COOL_DOWN";
const string CRAFT_ITEM_SELECTION = "CRAFT_ITEM_SELECTION";
const string CRAFT_MATERIAL_SELECTION = "CRAFT_MATERIAL_SELECTION";
const string CRAFT_MODEL_SELECTION = "CRAFT_MODEL_SELECTION";
const string CRAFT_MODEL_SPECIAL = "CRAFT_MODEL_SPECIAL";
const string CRAFT_MODEL = "CRAFT_MODEL";
const string CRAFT_COLOR_PALLET = "CRAFT_COLOR_PALLET";
const string CRAFT_COPY_ITEM = "CRAFT_COPY_ITEM";
const string CRAFT_PART_COLOR = "CRAFT_PART_COLOR";

void CreateItemCombo(object oPC, json jRow, string sComboBind);
void CreateModelCombo(object oPC, json jRow, string sComboBind);
void CreateMaterialCombo(object oPC, json jRow, string sComboBind);
// Returns the correct item based on the crafting menu selected item.
object GetSelectedItem(object oTarget, int nItemSelected);
int GetArmorModelSelected(object oPC);
void main()
{
    object oPC = OBJECT_SELF;
    // Row 1 (Object Name)****************************************************** 422 / 73
    json jRow = JsonArray();
    CreateTextEditBox(jRow, "plc_hold_bind", "txt_item_name", 25, FALSE, 234.0f, 20.0f);
    CreateTextEditBox(jRow, "plc_hold_bind", "txt_item_resref", 16, FALSE, 160.0f, 20.0f);
    // Add the row to the column.
    json jCol = JsonArray();
    JsonArrayInsertInplace(jCol, NuiRow(jRow));
    // Row 2 (Object Name)****************************************************** 422 / 101
    jRow = JsonArray();
    CreateButton(jRow, "Description", "btn_description", 131.0f, 20.0f);
    CreateButton(jRow, "Save Template", "btn_save_template", 131.0f, 20.0f);
    CreateButton(jRow, "Load Template", "btn_load_template", 130.0f, 20.0f);
    // Add the row to the column.
    JsonArrayInsertInplace(jCol, NuiRow(jRow));
    // Row 3 (Object Name)****************************************************** 422 / 129
    jRow = JsonArray();
    CreateButton(jRow, "Previous Target", "btn_prev_target", 131.0f, 20.0f);
    CreateTextEditBox(jRow, "plc_hold_bind", "txt_model_name_l", 3, FALSE, 41.0f, 20.0f);
    CreateTextEditBox(jRow, "plc_hold_bind", "txt_model_name_c", 3, FALSE, 41.0f, 20.0f);
    CreateTextEditBox(jRow, "plc_hold_bind", "txt_model_name_r", 3, FALSE, 41.0f, 20.0f);
    CreateButton(jRow, "Next Target", "btn_next_target", 131.0f, 20.0f);
    // Add the row to the column.
    JsonArrayInsertInplace(jCol, NuiRow(jRow));
    // Row 4 (buttons)********************************************************** 422 / 157
    jRow = JsonArray();
    CreateButtonSelect(jRow, "Copy", "btn_copy", 97.0f, 20.0f);
    CreateButton(jRow, "Paste", "btn_paste", 97.0f, 20.0f);
    CreateButton(jRow, "Randomize", "btn_rand", 97.0f, 20.0f);
    CreateButtonSelect(jRow, "Color Part", "btn_part_color", 97.0f, 20.0f);
    // Add the row to the column.
    JsonArrayInsertInplace(jCol, NuiRow(jRow));
    // Row 5 (images)*********************************************************** 422 / 341
    jRow = JsonArray();
    CreateButtonImage(jRow, "left_arrow", "btn_prev", 67.0f, 176.0f); //82.0
    CreateImage(jRow, "", "color_pallet", NUI_ASPECT_EXACTSCALED, NUI_HALIGN_CENTER, NUI_VALIGN_TOP, 256.0f, 176.0f);
    CreateButtonImage(jRow, "right_arrow", "btn_next", 67.0f, 176.0f); //82.0
    // Add the row to the column.
    JsonArrayInsertInplace(jCol, NuiRow(jRow));
    // Row 6 (button)*********************************************************** 422 / 369
    jRow = JsonArray();
    CreateButton(jRow, "Save", "btn_save", 130.0f, 20.0f);
    CreateButton(jRow, "", "btn_special", 130.0f, 20.0f);
    CreateButton(jRow, "", "btn_cancel", 130.0f, 20.0f);
    // Add the row to the column.
    JsonArrayInsertInplace(jCol, NuiRow(jRow));
    // Row 7 (text)************************************************************* 422 / 387
    jRow = JsonArray();
    CreateLabel(jRow, "Item to Craft", "item_title", 130.0f, 10.0f);
    CreateLabel(jRow, "Model to craft", "model_title", 130.0f, 10.0f);
    CreateLabel(jRow, "Material to color", "material_title", 130.0f, 10.0f);
    // Add the row to the column.
    JsonArrayInsertInplace(jCol, NuiRow(jRow));
    // Row 8 (combo box)******************************************************** 422 / 415
    jRow = JsonArray();
    CreateItemCombo(oPC, jRow, "item_combo");
    CreateModelCombo(oPC, jRow, "model_combo");
    CreateMaterialCombo(oPC, jRow, "material_combo");
    // Add the row to the column.
    JsonArrayInsertInplace(jCol, NuiRow(jRow));
    // Set the Layout for column.
    json jLayout = NuiCol(jCol);
    // Get the window location to restore it from the database.
    string sPCWindow;
    int nToken = SetWindow(oPC, jLayout, "plcraftwin", "Crafting",
                 0.0, -1.0, 422.0, 415.0, FALSE, FALSE, FALSE, FALSE, TRUE, "pe_crafting");
    // Set all binds, events, and watches.
    int nItem = GetLocalInt(oPC, CRAFT_ITEM_SELECTION);
    object oItem = GetSelectedItem(oPC, nItem);
    // Row 1
    NuiSetBind(oPC, nToken, "txt_item_name", JsonString(GetName(oItem)));
    NuiSetBindWatch(oPC, nToken, "txt_item_name", TRUE);
    NuiSetBind(oPC, nToken, "txt_item_resref", JsonString(GetResRef(oItem)));
    // Row 2
    NuiSetBind(oPC, nToken, "btn_description_event", JsonBool(TRUE));
    NuiSetBind(oPC, nToken, "btn_save_template_event", JsonBool(TRUE));
    NuiSetBind(oPC, nToken, "btn_load_template_event", JsonBool(TRUE));
    // Row 3
    int nSelected = GetLocalInt(oPC, CRAFT_MODEL_SELECTION);
    string sModelLeft, sModelCenter, sModelRight;
    if (ai_GetIsWeapon (oItem))
    {
        int nModel = GetItemAppearance(oItem, ITEM_APPR_TYPE_WEAPON_MODEL, 0);
        int nColor = GetItemAppearance(oItem, ITEM_APPR_TYPE_WEAPON_COLOR, 0);
        int nModelNumber = (nModel * 10) + nColor;
        sModelLeft = IntToString(nModelNumber);
        nModel = GetItemAppearance(oItem, ITEM_APPR_TYPE_WEAPON_MODEL, 1);
        nColor = GetItemAppearance(oItem, ITEM_APPR_TYPE_WEAPON_COLOR, 1);
        nModelNumber = (nModel * 10) + nColor;
        sModelCenter = IntToString(nModelNumber);
        nModel = GetItemAppearance(oItem, ITEM_APPR_TYPE_WEAPON_MODEL, 2);
        nColor = GetItemAppearance(oItem, ITEM_APPR_TYPE_WEAPON_COLOR, 2);
        nModelNumber = (nModel * 10) + nColor;
        sModelRight = IntToString(nModelNumber);
        NuiSetBindWatch(oPC, nToken, "txt_model_name_l", TRUE);
        NuiSetBind(oPC, nToken, "txt_model_name_l", JsonString(sModelLeft));
        NuiSetBindWatch(oPC, nToken, "txt_model_name_c", TRUE);
        NuiSetBind(oPC, nToken, "txt_model_name_c", JsonString(sModelCenter));
        NuiSetBindWatch(oPC, nToken, "txt_model_name_r", TRUE);
        NuiSetBind(oPC, nToken, "txt_model_name_r", JsonString(sModelRight));
    }
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
            sModelCenter = IntToString(GetItemAppearance(oItem, ITEM_APPR_TYPE_ARMOR_MODEL, nSelected));
            NuiSetBindWatch(oPC, nToken, "txt_model_name_l", FALSE);
            NuiSetBind(oPC, nToken, "txt_model_name_l", JsonString(""));
            NuiSetBindWatch(oPC, nToken, "txt_model_name_c", TRUE);
            NuiSetBind(oPC, nToken, "txt_model_name_c", JsonString(sModelCenter));
            NuiSetBindWatch(oPC, nToken, "txt_model_name_r", FALSE);
            NuiSetBind(oPC, nToken, "txt_model_name_r", JsonString(""));
        }
        else
        {
            sModelLeft = IntToString(GetItemAppearance(oItem, ITEM_APPR_TYPE_ARMOR_MODEL, nSelected));
            if(nSelected == ITEM_APPR_ARMOR_MODEL_RTHIGH) nSelected--;
            else nSelected++;
            sModelRight = IntToString(GetItemAppearance(oItem, ITEM_APPR_TYPE_ARMOR_MODEL, nSelected));
            NuiSetBindWatch(oPC, nToken, "txt_model_name_l", TRUE);
            NuiSetBind(oPC, nToken, "txt_model_name_l", JsonString(sModelLeft));
            NuiSetBindWatch(oPC, nToken, "txt_model_name_c", FALSE);
            NuiSetBind(oPC, nToken, "txt_model_name_c", JsonString(""));
            NuiSetBindWatch(oPC, nToken, "txt_model_name_r", TRUE);
            NuiSetBind(oPC, nToken, "txt_model_name_r", JsonString(sModelRight));
        }
    }
    else
    {
        sModelCenter = IntToString(GetItemAppearance(oItem, ITEM_APPR_TYPE_SIMPLE_MODEL, 0));
        NuiSetBindWatch(oPC, nToken, "txt_model_name_l", TRUE);
        NuiSetBind(oPC, nToken, "txt_model_name_l", JsonString(""));
        NuiSetBindWatch(oPC, nToken, "txt_model_name_c", TRUE);
        NuiSetBind(oPC, nToken, "txt_model_name_c", JsonString(sModelCenter));
        NuiSetBindWatch(oPC, nToken, "txt_model_name_r", TRUE);
        NuiSetBind(oPC, nToken, "txt_model_name_r", JsonString(""));
    }
    NuiSetBind(oPC, nToken, "btn_prev_target_event", JsonBool(TRUE));
    NuiSetBind(oPC, nToken, "btn_next_target_event", JsonBool(TRUE));
    // Row 4
    nSelected = GetLocalInt (oPC, CRAFT_COPY_ITEM);
    NuiSetBind(oPC, nToken, "btn_copy", JsonBool(nSelected));
    NuiSetBind(oPC, nToken, "btn_copy_event", JsonBool(TRUE));
    NuiSetBind(oPC, nToken, "btn_paste", JsonBool(TRUE));
    NuiSetBind(oPC, nToken, "btn_paste_event", JsonBool(nSelected));
    NuiSetBind(oPC, nToken, "btn_rand", JsonBool(TRUE));
    NuiSetBind(oPC, nToken, "btn_rand_event", JsonBool(TRUE));
    nSelected = GetLocalInt (oPC, CRAFT_PART_COLOR);
    NuiSetBind(oPC, nToken, "btn_part_color", JsonBool(nSelected));
    NuiSetBind(oPC, nToken, "btn_part_color_event", JsonBool(TRUE));
    // Row 5
    NuiSetBind(oPC, nToken, "btn_prev", JsonBool(TRUE));
    NuiSetBind(oPC, nToken, "btn_prev_event", JsonBool(TRUE));
    string sColorPallet = GetLocalString(oPC, CRAFT_COLOR_PALLET);
    if(sColorPallet == "") sColorPallet = "cloth_pallet";
    NuiSetBind(oPC, nToken, "color_pallet_image", JsonString(sColorPallet));
    NuiSetBind(oPC, nToken, "color_pallet_event", JsonBool(TRUE));
    NuiSetBind(oPC, nToken, "btn_next", JsonBool(TRUE));
    NuiSetBind(oPC, nToken, "btn_next_event", JsonBool(TRUE));
    // Row 6 is premade labels.
    // Row 7
    // Setup the Item selection combo.
    NuiSetBind(oPC, nToken, "item_combo_selected", JsonInt(nItem));
    NuiSetBind(oPC, nToken, "item_combo_event", JsonBool(TRUE));
    NuiSetBindWatch(oPC, nToken, "item_combo_selected", TRUE);
    // Setup the model selection combo.
    nSelected = GetLocalInt(oPC, CRAFT_MODEL_SELECTION);
    NuiSetBind(oPC, nToken, "model_combo_selected", JsonInt (nSelected));
    NuiSetBind(oPC, nToken, "model_combo_event", JsonBool (TRUE));
    NuiSetBindWatch(oPC, nToken, "model_combo_selected", TRUE);
    // Setup the material selection combo.
    nSelected = GetLocalInt (oPC, CRAFT_MATERIAL_SELECTION);
    NuiSetBind(oPC, nToken, "material_combo_selected", JsonInt(nSelected));
    NuiSetBind(oPC, nToken, "material_combo_event", JsonBool(TRUE));
    NuiSetBindWatch(oPC, nToken, "material_combo_selected", TRUE);
    // Row 8
    // Setup the save button.
    NuiSetBind(oPC, nToken, "btn_save", JsonBool(TRUE));
    NuiSetBind(oPC, nToken, "btn_save_event", JsonBool(FALSE));
    // Setup the special button.
    nSelected = GetLocalInt(oPC, CRAFT_MODEL_SPECIAL);
    NuiSetBind(oPC, nToken, "btn_special", JsonBool(TRUE));
    NuiSetBind(oPC, nToken, "btn_special_event", JsonBool(TRUE));
    if(nItem == 3 || nItem == 4)
    {
        NuiSetBind(oPC, nToken, "btn_special_label", JsonString("****"));
        NuiSetBind(oPC, nToken, "btn_special", JsonBool(FALSE));
        NuiSetBind(oPC, nToken, "btn_special_event", JsonBool(FALSE));
    }
    else if(nSelected == 0) NuiSetBind(oPC, nToken, "btn_special_label", JsonString("Left/Right Linked"));
    else if(nSelected == 1) NuiSetBind(oPC, nToken, "btn_special_label", JsonString("Left Model"));
    else if(nSelected == 2) NuiSetBind(oPC, nToken, "btn_special_label", JsonString("Right Model"));
    else
    {
        nSelected = GetHiddenWhenEquipped(oItem);
        if(nSelected)
        {
            NuiSetBind(oPC, nToken, "btn_special_label", JsonString("Model Hidden"));
            SetLocalInt(oPC, CRAFT_MODEL_SPECIAL, 4);
        }
        else
        {
            NuiSetBind(oPC, nToken, "btn_special_label", JsonString("Model Visible"));
            SetLocalInt(oPC, CRAFT_MODEL_SPECIAL, 3);
        }
    }
    // Setup the Cancel/Exit button.
    NuiSetBind(oPC, nToken, "btn_cancel_label", JsonString("Exit"));
    NuiSetBind(oPC, nToken, "btn_cancel", JsonBool(TRUE));
    NuiSetBind(oPC, nToken, "btn_cancel_event", JsonBool(TRUE));
    NuiSetBindWatch (oPC, nToken, "window_geometry", TRUE);
    // Lets make sure we clean up any cool down variables.
    DeleteLocalInt(oPC, CRAFT_COOL_DOWN);
}
void CreateItemCombo(object oPC, json jRow, string sComboBind)
{
    int nCnt;
    json jCombo = JsonArray();
    // Create the list.
    JsonArrayInsertInplace(jCombo, NuiComboEntry("Armor", 0));
    JsonArrayInsertInplace(jCombo, NuiComboEntry("Cloak", 1));
    JsonArrayInsertInplace(jCombo, NuiComboEntry("Headgear", 2));
    JsonArrayInsertInplace(jCombo, NuiComboEntry("Right hand", 3));
    JsonArrayInsertInplace(jCombo, NuiComboEntry("Left hand", 4));
    CreateCombo(jRow, jCombo, sComboBind, 130.0, 25.0);
}
void CreateModelCombo(object oPC, json jRow, string sComboBind)
{
    float fFacing = GetFacing(oPC);
    json jCombo = JsonArray();
    int nSelected = GetLocalInt(oPC, CRAFT_ITEM_SELECTION);
    // Create the list.
    // Armor.
    if(nSelected == 0)
    {
        fFacing += 180.0f;
        if (fFacing > 359.0) fFacing -=359.0;
        AssignCommand(oPC, SetCameraFacing(fFacing, 4.5f, 75.0, CAMERA_TRANSITION_TYPE_VERY_FAST));
        JsonArrayInsertInplace(jCombo, NuiComboEntry("Neck", 0));
        JsonArrayInsertInplace(jCombo, NuiComboEntry("Shoulder", 1));
        JsonArrayInsertInplace(jCombo, NuiComboEntry("Bicep", 2));
        JsonArrayInsertInplace(jCombo, NuiComboEntry("Forearm", 3));
        JsonArrayInsertInplace(jCombo, NuiComboEntry("Hand", 4));
        JsonArrayInsertInplace(jCombo, NuiComboEntry("Torso", 5));
        JsonArrayInsertInplace(jCombo, NuiComboEntry("Belt", 6));
        JsonArrayInsertInplace(jCombo, NuiComboEntry("Pelvis", 7));
        JsonArrayInsertInplace(jCombo, NuiComboEntry("Thigh", 8));
        JsonArrayInsertInplace(jCombo, NuiComboEntry("Shin", 9));
        JsonArrayInsertInplace(jCombo, NuiComboEntry("Foot", 10));
        JsonArrayInsertInplace(jCombo, NuiComboEntry("Robe", 11));
    }
    // Cloak.
    else if(nSelected == 1)
    {
        if(fFacing > 359.0) fFacing -=359.0;
        AssignCommand (oPC, SetCameraFacing(fFacing, 4.5f, 75.0, CAMERA_TRANSITION_TYPE_VERY_FAST));
        JsonArrayInsertInplace(jCombo, NuiComboEntry("Cloak", 0));
    }
    // Headgear.
    else if (nSelected == 2)
    {
        fFacing += 180.0f;
        if(fFacing > 359.0) fFacing -=359.0;
        AssignCommand(oPC, SetCameraFacing(fFacing, 2.5f, 75.0, CAMERA_TRANSITION_TYPE_VERY_FAST));
        JsonArrayInsertInplace(jCombo, NuiComboEntry("Headgear", 0));
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
        JsonArrayInsertInplace(jCombo, NuiComboEntry("Bottom", 0));
        JsonArrayInsertInplace(jCombo, NuiComboEntry("Middle", 1));
        JsonArrayInsertInplace(jCombo, NuiComboEntry("Top", 2));
    }
    // Weapon/Shield.
    else if(nSelected == 4)
    {
        fFacing += 270.0f;
        if(fFacing > 359.0) fFacing -=359.0;
        AssignCommand(oPC, SetCameraFacing(fFacing, 3.5f, 75.0, CAMERA_TRANSITION_TYPE_VERY_FAST));
        object oItem = GetItemInSlot(INVENTORY_SLOT_LEFTHAND, oPC);
        if(ai_GetIsWeapon (oItem))
        {
            JsonArrayInsertInplace(jCombo, NuiComboEntry("Top", 0));
            JsonArrayInsertInplace(jCombo, NuiComboEntry("Middle", 1));
            JsonArrayInsertInplace(jCombo, NuiComboEntry("Bottom", 2));
        }
        else JsonArrayInsertInplace(jCombo, NuiComboEntry("Shield", 0));
    }
    CreateCombo(jRow, jCombo, sComboBind, 130.0, 25.0);
}
void CreateMaterialCombo(object oPC, json jRow, string sComboBind)
{
    int nCnt;
    json jCombo = JsonArray();
    int nSelected = GetLocalInt(oPC, CRAFT_ITEM_SELECTION);
    // Create the list.
    // Armor, Cloak, Headgear.
    if(nSelected == 0 || nSelected == 1 || nSelected == 2)
    {
        JsonArrayInsertInplace(jCombo, NuiComboEntry("Cloth 1", 0));
        JsonArrayInsertInplace(jCombo, NuiComboEntry("Cloth 2", 1));
        JsonArrayInsertInplace(jCombo, NuiComboEntry("Leather 1", 2));
        JsonArrayInsertInplace(jCombo, NuiComboEntry("Leather 2", 3));
        JsonArrayInsertInplace(jCombo, NuiComboEntry("Metal 1", 4));
        JsonArrayInsertInplace(jCombo, NuiComboEntry("Metal 2", 5));
    }
    else JsonArrayInsertInplace(jCombo, NuiComboEntry("None", 0));
    CreateCombo(jRow, jCombo, sComboBind, 130.0, 25.0);
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
int GetArmorModelSelected(object oPC)
{
    int nModelSelected = GetLocalInt(oPC, CRAFT_MODEL_SELECTION);
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

