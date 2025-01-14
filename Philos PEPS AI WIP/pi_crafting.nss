/*//////////////////////////////////////////////////////////////////////////////
// Script Name: pi_crafting
////////////////////////////////////////////////////////////////////////////////
 Executable plug in script for Philos Module Extentions

 Shield Left - nui_shld_left
 Shield Right - nui_shld_right

 Crafting UI for players items.
*///////////////////////////////////////////////////////////////////////////////
#include "0i_nui"
#include "0i_items"
const string CRAFT_COOL_DOWN = "CRAFT_COOL_DOWN";
const string CRAFT_ITEM_SELECTION = "CRAFT_ITEM_SELECTION";
const string CRAFT_MATERIAL_SELECTION = "CRAFT_MATERIAL_SELECTION";
const string CRAFT_MODEL_SELECTION = "CRAFT_MODEL_SELECTION";
const string CRAFT_MODEL = "CRAFT_MODEL";
const string CRAFT_COLOR_PALLET = "CRAFT_COLOR_PALLET";
const string CRAFT_LEFT_PART_COLOR = "CRAFT_LEFT_PART_COLOR";
const string CRAFT_ALL_PART_COLOR = "CRAFT_ALL_PART_COLOR";
const string CRAFT_RIGHT_PART_COLOR = "CRAFT_RIGHT_PART_COLOR";

void CreateItemCombo(object oPC, json jRow, string sComboBind);
void CreateModelCombo(object oPC, json jRow, string sComboBind);
void CreateMaterialCombo(object oPC, json jRow, string sComboBind);
// Returns the correct item based on the crafting menu selected item.
object GetSelectedItem(object oTarget, int nItemSelected);
int GetArmorModelSelected(object oPC);
void main()
{
    object oPC = OBJECT_SELF;
    // Row 1 (Object Name)****************************************************** 400 / 73
    json jRow = JsonArray();
    CreateTextEditBox(jRow, "plc_hold_bind", "txt_item_name", 50, FALSE, 400.0f, 20.0f);
    json jCol = JsonArray();
    JsonArrayInsertInplace(jCol, NuiRow(jRow));
    // Row 2 (Object Name)****************************************************** 400 / 101
    jRow = JsonArray();
    CreateButton(jRow, "Information", "btn_info", 129.0f, 20.0f, -1.0, "btn_info_tooltip");
    CreateButton(jRow, "Open Dresser", "btn_open_dresser", 130.0f, 20.0f, -1.0, "btn_open_dresser_tooltip");
    CreateButton(jRow, "Randomize", "btn_randomize", 129.0f, 20.0f, -1.0, "btn_randomize_tooltip");
    JsonArrayInsertInplace(jCol, NuiRow(jRow));
    // Row 3 (Object Name)****************************************************** 400 / 129
    jRow = JsonArray();
    CreateButton(jRow, "Save", "btn_save", 129.0f, 20.0f, -1.0, "btn_save_tooltip");
    CreateButton(jRow, "Select Target", "btn_select_target", 130.0f, 20.0f);
    CreateButton(jRow, "", "btn_cancel", 129.0f, 20.0f, -1.0, "btn_cancel_tooltip");
    JsonArrayInsertInplace(jCol, NuiRow(jRow));
    // Row 4 (labels)*********************************************************** 400 / 147
    jRow = JsonArray();
    CreateLabel(jRow, "Model", "module_title", 127.0f, 10.0f);
    CreateLabel(jRow, "Color", "color_title", 273.0f, 10.0f);
    JsonArrayInsertInplace(jCol, NuiRow(jRow));
    // Row 5 (groups)
    // Row 5a (title)********************************************************** 400 / 165 / 18
    jRow = JsonArray();
    json jGroupRow = JsonArray();
    json jGroupCol = JsonArray();
    CreateLabel(jGroupRow, "Item", "item__cmb_title", 110.0f, 10.0f);
    JsonArrayInsertInplace(jGroupCol, NuiRow(jGroupRow));
    // Row 5b (combo)********************************************************** 400 / 198 / 51
    jGroupRow = JsonArray();
    CreateItemCombo(oPC, jGroupRow, "item_combo");
    JsonArrayInsertInplace(jGroupCol, NuiRow(jGroupRow));
    // Row 5c (title)********************************************************** 400 / 216 / 69
    jGroupRow = JsonArray();
    CreateLabel(jGroupRow, "Model", "model_cmb_title",110.0f, 10.0f);
    JsonArrayInsertInplace(jGroupCol, NuiRow(jGroupRow));
    // Row 5d (combo)********************************************************** 400 / 249 / 102
    jGroupRow = JsonArray();
    CreateModelCombo(oPC, jGroupRow, "model_combo");
    JsonArrayInsertInplace(jGroupCol, NuiRow(jGroupRow));
    // Row 5e (title)********************************************************** 400 / 267 / 120
    jGroupRow = JsonArray();
    CreateLabel(jGroupRow, "", "top_title",110.0f, 10.0f);
    JsonArrayInsertInplace(jGroupCol, NuiRow(jGroupRow));
    // Row 5f (top)********************************************************** 400 / 307 / 160
    jGroupRow = JsonArray();
    CreateButtonImage(jGroupRow, "nui_shld_left", "btn_prev_t", 32.0f, 32.0f);
    CreateTextEditBox(jGroupRow, "place_holder", "txt_model_number_t", 3, FALSE, 40.0, 32.0);
    CreateButtonImage(jGroupRow, "nui_shld_right", "btn_next_t", 32.0f, 32.0f);
    JsonArrayInsertInplace(jGroupCol, NuiRow(jGroupRow));
    // Row 5g (title)********************************************************** 400 / 325 / 178
    jGroupRow = JsonArray();
    CreateLabel(jGroupRow, "", "middle_title",110.0f, 10.0f);
    JsonArrayInsertInplace(jGroupCol, NuiRow(jGroupRow));
    // Row 5h (middle)********************************************************** 400 / 365 / 218
    jGroupRow = JsonArray();
    CreateButtonImage(jGroupRow, "nui_shld_left", "btn_prev_m", 32.0f, 32.0f);
    CreateTextEditBox(jGroupRow, "place_holder", "txt_model_number_m", 3, FALSE, 40.0, 32.0);
    CreateButtonImage(jGroupRow, "nui_shld_right", "btn_next_m", 32.0f, 32.0f);
    JsonArrayInsertInplace(jGroupCol, NuiRow(jGroupRow));
    // Row 5i (title)********************************************************** 400 / 383 / 236
    jGroupRow = JsonArray();
    CreateLabel(jGroupRow, "", "bottom_title",110.0f, 10.0f);
    JsonArrayInsertInplace(jGroupCol, NuiRow(jGroupRow));
    // Row 5j (bottom)********************************************************** 400 / 423 / 276
    jGroupRow = JsonArray();
    CreateButtonImage(jGroupRow, "nui_shld_left", "btn_prev_b", 32.0f, 32.0f);
    CreateTextEditBox(jGroupRow, "place_holder", "txt_model_number_b", 3, FALSE, 40.0, 32.0);
    CreateButtonImage(jGroupRow, "nui_shld_right", "btn_next_b", 32.0f, 32.0f);
    JsonArrayInsertInplace(jGroupCol, NuiRow(jGroupRow));
    JsonArrayInsertInplace(jGroupCol, NuiSpacer());
    JsonArrayInsertInplace(jRow, NuiHeight(NuiWidth(NuiGroup(NuiCol(jGroupCol)), 127.0), 292.0));
    // Make the Color Group.
    jGroupRow = JsonArray();
    jGroupCol = JsonArray();
    // Row 5k (groups)********************************************************** 400 / 331 / 184
    CreateImage(jGroupRow, "", "color_pallet", NUI_ASPECT_EXACTSCALED, NUI_HALIGN_CENTER, NUI_VALIGN_TOP, 256.0f, 176.0f, -1.0, "color_pallet_tooltip");
    JsonArrayInsertInplace(jGroupCol, NuiRow(jGroupRow));
    // Row 5l (groups)********************************************************** 400 / 377 / 230
    jGroupRow = JsonArray();
    CreateButtonSelect(jGroupRow, "Left Part", "btn_left_part_color", 90.0, 20.0);
    CreateButtonSelect(jGroupRow, "All Parts", "btn_all_part_color", 77.0, 20.0);
    CreateButtonSelect(jGroupRow, "Right Part", "btn_right_part_color", 90.0, 20.0);
    JsonArrayInsertInplace(jGroupCol, NuiRow(jGroupRow));
    // Row 5m (groups)********************************************************** 400 / 405 /258
    jGroupRow = JsonArray();
    JsonArrayInsertInplace(jGroupRow, NuiSpacer());
    CreateTextEditBox(jGroupRow, "plc_hold_bind", "txt_color_l", 3, FALSE, 40.0f, 20.0f, "txt_color_l_tooltip");
    JsonArrayInsertInplace(jGroupRow, NuiSpacer());
    CreateTextEditBox(jGroupRow, "plc_hold_bind", "txt_color_a", 3, FALSE, 40.0f, 20.0f, "txt_color_a_tooltip");
    JsonArrayInsertInplace(jGroupRow, NuiSpacer());
    CreateTextEditBox(jGroupRow, "plc_hold_bind", "txt_color_r", 3, FALSE, 40.0f, 20.0f, "txt_color_r_tooltip");
    JsonArrayInsertInplace(jGroupRow, NuiSpacer());
    JsonArrayInsertInplace(jGroupCol, NuiRow(jGroupRow));
    // Row 5n (groups)********************************************************** 400 / 438 / 291
    jGroupRow = JsonArray();
    JsonArrayInsertInplace(jGroupRow, NuiSpacer());
    CreateMaterialCombo(oPC, jGroupRow, "material_combo");
    JsonArrayInsertInplace(jGroupRow, NuiSpacer());
    JsonArrayInsertInplace(jGroupCol, NuiRow(jGroupRow));
    JsonArrayInsertInplace(jGroupCol, NuiSpacer());
    JsonArrayInsertInplace(jRow, NuiHeight(NuiWidth(NuiGroup(NuiCol(jGroupCol)), 273.0), 307.0));
    JsonArrayInsertInplace(jCol, NuiRow(jRow));
    json jLayout = NuiCol(jCol);
    // Get the window location to restore it from the database.
    json jGeom = GetLocalJson(oPC, "PI_CRAFTING_POS");
    float fX = JsonGetFloat(JsonObjectGet(jGeom, "x"));
    float fY = JsonGetFloat(JsonObjectGet(jGeom, "y"));
    string sPCWindow;
    int nToken = SetWindow(oPC, jLayout, "plcraftwin", "Crafting",
                 fX, fY, 428.0, 454.0, FALSE, FALSE, FALSE, FALSE, TRUE, "pe_crafting");
    // Set all binds, events, and watches.
    NuiSetBindWatch (oPC, nToken, "window_geometry", TRUE);
    int nItem = GetLocalInt(oPC, CRAFT_ITEM_SELECTION);
    object oItem = GetSelectedItem(oPC, nItem);
    // Row 1
    NuiSetBind(oPC, nToken, "txt_item_name", JsonString(GetName(oItem)));
    NuiSetBindWatch(oPC, nToken, "txt_item_name", TRUE);
    // Row 2
    NuiSetBind(oPC, nToken, "btn_info_event", JsonBool(TRUE));
    NuiSetBind(oPC, nToken, "btn_info_tooltip", JsonString("  Look at and change item information"));
    NuiSetBind(oPC, nToken, "btn_open_dresser_event", JsonBool(TRUE));
    NuiSetBind(oPC, nToken, "btn_open_dresser_tooltip", JsonString("  Open your dresser to save/load items appearances"));
    NuiSetBind(oPC, nToken, "btn_randomize_event", JsonBool(TRUE));
    NuiSetBind(oPC, nToken, "btn_randomize_tooltip", JsonString("  Randomize the selected items appearance"));
    // Row 3
    NuiSetBind(oPC, nToken, "btn_save_event", JsonBool(FALSE));
    NuiSetBind(oPC, nToken, "btn_save_tooltip", JsonString("  Save current changes"));
    NuiSetBind(oPC, nToken, "btn_select_target_event", JsonBool(TRUE));
    NuiSetBind(oPC, nToken, "btn_cancel_label", JsonString("Exit"));
    NuiSetBind(oPC, nToken, "btn_cancel_event", JsonBool(TRUE));
    NuiSetBind(oPC, nToken, "btn_cancel_tooltip", JsonString("  Exit the crafting menu"));
    // Row 4 Labels.
    // Row 5 Groups.
    // Row 5a title.
    // Row 5b
    NuiSetBind(oPC, nToken, "item_combo_selected", JsonInt(nItem));
    NuiSetBind(oPC, nToken, "item_combo_event", JsonBool(TRUE));
    NuiSetBindWatch(oPC, nToken, "item_combo_selected", TRUE);
    // Row 5c title.
    // Row 5d
    int nSelected = GetLocalInt(oPC, CRAFT_MODEL_SELECTION);
    NuiSetBind(oPC, nToken, "model_combo_selected", JsonInt (nSelected));
    NuiSetBind(oPC, nToken, "model_combo_event", JsonBool (TRUE));
    NuiSetBindWatch(oPC, nToken, "model_combo_selected", TRUE);
    // Row 5e, 5g, 5i titles
    // Row 5f top, 5h middle, 5j bottom
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
        NuiSetBind(oPC, nToken, "top_title_label", JsonString("Top"));
        NuiSetBind(oPC, nToken, "txt_model_number_t_event", JsonBool(TRUE));
        NuiSetBind(oPC, nToken, "txt_model_number_t", JsonString(sModelTop));
        NuiSetBind(oPC, nToken, "btn_prev_t_event", JsonBool(TRUE));
        NuiSetBind(oPC, nToken, "btn_next_t_event", JsonBool(TRUE));
        NuiSetBind(oPC, nToken, "middle_title_label", JsonString("Middle"));
        NuiSetBind(oPC, nToken, "txt_model_number_m_event", JsonBool(TRUE));
        NuiSetBind(oPC, nToken, "txt_model_number_m", JsonString(sModelMiddle));
        NuiSetBind(oPC, nToken, "btn_prev_m_event", JsonBool(TRUE));
        NuiSetBind(oPC, nToken, "btn_next_m_event", JsonBool(TRUE));
        NuiSetBind(oPC, nToken, "bottom_title_label", JsonString("Bottom"));
        NuiSetBind(oPC, nToken, "txt_model_number_b_event", JsonBool(TRUE));
        NuiSetBind(oPC, nToken, "txt_model_number_b", JsonString(sModelBottom));
        NuiSetBind(oPC, nToken, "btn_prev_b_event", JsonBool(TRUE));
        NuiSetBind(oPC, nToken, "btn_next_b_event", JsonBool(TRUE));
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
    // Color Group
    if(ai_GetIsWeapon(oItem) || ai_GetIsShield(oItem))
    {
        // Need to disable the color widgets.
        // Row 5k
        NuiSetBind(oPC, nToken, "color_pallet_image", JsonString("gui_pal_tattoo"));
        NuiSetBind(oPC, nToken, "color_pallet_image_event", JsonBool(FALSE));
        // Row 5l
        NuiSetBind(oPC, nToken, "btn_left_part_color_event", JsonBool(FALSE));
        NuiSetBind(oPC, nToken, "btn_all_part_color_event", JsonBool(FALSE));
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
        // Row 5l
        nSelected = GetLocalInt (oPC, CRAFT_LEFT_PART_COLOR);
        NuiSetBind(oPC, nToken, "btn_left_part_color", JsonBool(nSelected));
        NuiSetBind(oPC, nToken, "btn_left_part_color_event", JsonBool(TRUE));
        nSelected = GetLocalInt (oPC, CRAFT_ALL_PART_COLOR);
        NuiSetBind(oPC, nToken, "btn_all_part_color", JsonBool(nSelected));
        NuiSetBind(oPC, nToken, "btn_all_part_color_event", JsonBool(TRUE));
        nSelected = GetLocalInt (oPC, CRAFT_RIGHT_PART_COLOR);
        NuiSetBind(oPC, nToken, "btn_right_part_color", JsonBool(nSelected));
        NuiSetBind(oPC, nToken, "btn_right_part_color_event", JsonBool(TRUE));
        // Row 5m
        NuiSetBindWatch(oPC, nToken, "txt_color_l", TRUE);
        int nModelSelected = GetArmorModelSelected(oPC);
        int nMaterialSelected = GetLocalInt(oPC, CRAFT_MATERIAL_SELECTION);
        string sColorAll = IntToString(GetItemAppearance(oItem, ITEM_APPR_TYPE_ARMOR_COLOR, nMaterialSelected));
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
        sColor = IntToString(GetItemAppearance(oItem, ITEM_APPR_TYPE_ARMOR_COLOR, nIndex));
        if(sColor == "255") sColor = sColorAll;
        NuiSetBind(oPC, nToken, "txt_color_r_event", JsonBool(TRUE));
        NuiSetBind(oPC, nToken, "txt_color_r", JsonString(sColor));
        NuiSetBindWatch(oPC, nToken, "txt_color_r", TRUE);
        NuiSetBind(oPC, nToken, "txt_color_r_tooltip", JsonString("  Choose color for right model 0 to 175"));
        // Row 5n
        nSelected = GetLocalInt (oPC, CRAFT_MATERIAL_SELECTION);
        NuiSetBind(oPC, nToken, "material_combo_selected", JsonInt(nSelected));
        NuiSetBind(oPC, nToken, "material_combo_event", JsonBool(TRUE));
        NuiSetBindWatch(oPC, nToken, "material_combo_selected", TRUE);
    }
    // Cloaks and Helmets.
    else
    {
        // Row 5k
        string sColorPallet = GetLocalString(oPC, CRAFT_COLOR_PALLET);
        if(sColorPallet == "") sColorPallet = "gui_pal_tattoo";
        NuiSetBind(oPC, nToken, "color_pallet_image", JsonString(sColorPallet));
        NuiSetBind(oPC, nToken, "color_pallet_event", JsonBool(TRUE));
        NuiSetBind(oPC, nToken, "color_pallet_tooltip", JsonString("  Select a color or use the mouse wheel"));
        // Row 5l
        NuiSetBind(oPC, nToken, "btn_left_part_color_event", JsonBool(FALSE));
        NuiSetBind(oPC, nToken, "btn_all_part_color_event", JsonBool(FALSE));
        NuiSetBind(oPC, nToken, "btn_right_part_color_event", JsonBool(FALSE));
        // Row 5m
        int nModelSelected = GetArmorModelSelected(oPC);
        int nMaterialSelected = GetLocalInt(oPC, CRAFT_MATERIAL_SELECTION);
        string sColorAll = IntToString(GetItemAppearance(oItem, ITEM_APPR_TYPE_ARMOR_COLOR, nMaterialSelected));
        NuiSetBind(oPC, nToken, "txt_color_l_event", JsonBool(FALSE));
        NuiSetBind(oPC, nToken, "txt_color_l", JsonString(""));
        NuiSetBind(oPC, nToken, "txt_color_a_event", JsonBool(TRUE));
        NuiSetBind(oPC, nToken, "txt_color_a", JsonString(sColorAll));
        NuiSetBind(oPC, nToken, "txt_color_r_event", JsonBool(FALSE));
        NuiSetBind(oPC, nToken, "txt_color_r", JsonString(""));
        // Row 5n
        nSelected = GetLocalInt (oPC, CRAFT_MATERIAL_SELECTION);
        NuiSetBind(oPC, nToken, "material_combo_selected", JsonInt(nSelected));
        NuiSetBind(oPC, nToken, "material_combo_event", JsonBool(TRUE));
        NuiSetBindWatch(oPC, nToken, "material_combo_selected", TRUE);
    }
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
    CreateCombo(jRow, jCombo, sComboBind, 110.0, 25.0);
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
        JsonArrayInsertInplace(jCombo, NuiComboEntry("Invisible", 1));
    }
    // Headgear.
    else if (nSelected == 2)
    {
        fFacing += 180.0f;
        if(fFacing > 359.0) fFacing -=359.0;
        AssignCommand(oPC, SetCameraFacing(fFacing, 2.5f, 75.0, CAMERA_TRANSITION_TYPE_VERY_FAST));
        JsonArrayInsertInplace(jCombo, NuiComboEntry("Headgear", 0));
        JsonArrayInsertInplace(jCombo, NuiComboEntry("Invisible", 1));
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
        JsonArrayInsertInplace(jCombo, NuiComboEntry("Weapon", 0));
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
            JsonArrayInsertInplace(jCombo, NuiComboEntry("Weapon", 0));
        }
        else JsonArrayInsertInplace(jCombo, NuiComboEntry("Shield", 0));
    }
    CreateCombo(jRow, jCombo, sComboBind, 110.0, 25.0);
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
    CreateCombo(jRow, jCombo, sComboBind, 177.0, 25.0); //104
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

