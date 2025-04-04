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
const string CRAFT_JSON = "CRAFT_JSON";
const string CRAFT_COOL_DOWN = "CRAFT_COOL_DOWN";
const string CRAFT_ITEM_SELECTION = "CRAFT_ITEM_SELECTION";
const string CRAFT_MATERIAL_SELECTION = "CRAFT_MATERIAL_SELECTION";
const string CRAFT_MODEL_SELECTION = "CRAFT_MODEL_SELECTION";
const string CRAFT_MODEL = "CRAFT_MODEL";
const string CRAFT_COLOR_PALLET = "CRAFT_COLOR_PALLET";
const string CRAFT_LEFT_PART_COLOR = "CRAFT_LEFT_PART_COLOR";
const string CRAFT_ALL_COLOR = "CRAFT_ALL_COLOR";
const string CRAFT_RIGHT_PART_COLOR = "CRAFT_RIGHT_PART_COLOR";
const string CRAFT_TARGET = "CRAFT_TARGET";

void CreateItemCombo(object oPC, json jRow, string sComboBind);
void CreateModelCombo(object oPC, object oTarget, json jRow, string sComboBind);
void CreateMaterialCombo(object oPC, json jRow, string sComboBind);
// Sets the material buttons for use.
// nMaterial 0,1 Cloth 2,3 Leather 4,5 Metal -1 None.
void SetMaterialButtons(object oPC, int nToken, int nMaterial);
// Returns the correct item based on the crafting menu selected item.
object GetSelectedItem(object oTarget, int nItemSelected);
int GetArmorModelSelected(object oPC);
// Does startup check if the game has just been loaded.
int StartingUp(object oPC);
void main()
{
    object oPC = OBJECT_SELF;
    object oTarget = GetLocalObject(oPC, CRAFT_TARGET);
    if(oTarget == OBJECT_INVALID) oTarget = oPC;
    if(StartingUp(oPC)) return;
    json jCraft = GetLocalJson(oPC, CRAFT_JSON);
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
    // Row 51 (title)********************************************************** 400 / 165 / 18
    jRow = JsonArray();
    json jGroupRow = JsonArray();
    json jGroupCol = JsonArray();
    CreateLabel(jGroupRow, "Item", "item__cmb_title", 110.0f, 10.0f);
    JsonArrayInsertInplace(jGroupCol, NuiRow(jGroupRow));
    // Row 52 (combo)********************************************************** 400 / 198 / 51
    jGroupRow = JsonArray();
    CreateItemCombo(oPC, jGroupRow, "item_combo");
    JsonArrayInsertInplace(jGroupCol, NuiRow(jGroupRow));
    // Row 53 (title)********************************************************** 400 / 216 / 69
    jGroupRow = JsonArray();
    CreateLabel(jGroupRow, "Model", "model_cmb_title",110.0f, 10.0f);
    JsonArrayInsertInplace(jGroupCol, NuiRow(jGroupRow));
    // Row 54 (combo)********************************************************** 400 / 249 / 102
    jGroupRow = JsonArray();
    CreateModelCombo(oPC, oTarget, jGroupRow, "model_combo");
    JsonArrayInsertInplace(jGroupCol, NuiRow(jGroupRow));
    // Row 55 (title)********************************************************** 400 / 267 / 120
    jGroupRow = JsonArray();
    CreateLabel(jGroupRow, "", "top_title",110.0f, 10.0f);
    JsonArrayInsertInplace(jGroupCol, NuiRow(jGroupRow));
    // Row 56 (top)********************************************************** 400 / 307 / 160
    jGroupRow = JsonArray();
    CreateButtonImage(jGroupRow, "nui_shld_left", "btn_prev_t", 32.0f, 32.0f);
    CreateTextEditBox(jGroupRow, "place_holder", "txt_model_number_t", 3, FALSE, 40.0, 32.0);
    CreateButtonImage(jGroupRow, "nui_shld_right", "btn_next_t", 32.0f, 32.0f);
    JsonArrayInsertInplace(jGroupCol, NuiRow(jGroupRow));
    // Row 57 (title)********************************************************** 400 / 325 / 178
    jGroupRow = JsonArray();
    CreateLabel(jGroupRow, "", "middle_title",110.0f, 10.0f);
    JsonArrayInsertInplace(jGroupCol, NuiRow(jGroupRow));
    // Row 58 (middle)********************************************************** 400 / 365 / 218
    jGroupRow = JsonArray();
    CreateButtonImage(jGroupRow, "nui_shld_left", "btn_prev_m", 32.0f, 32.0f);
    CreateTextEditBox(jGroupRow, "place_holder", "txt_model_number_m", 3, FALSE, 40.0, 32.0);
    CreateButtonImage(jGroupRow, "nui_shld_right", "btn_next_m", 32.0f, 32.0f);
    JsonArrayInsertInplace(jGroupCol, NuiRow(jGroupRow));
    // Row 59 (title)********************************************************** 400 / 383 / 236
    jGroupRow = JsonArray();
    CreateLabel(jGroupRow, "", "bottom_title",110.0f, 10.0f);
    JsonArrayInsertInplace(jGroupCol, NuiRow(jGroupRow));
    // Row 510 (bottom)********************************************************** 400 / 423 / 276
    jGroupRow = JsonArray();
    CreateButtonImage(jGroupRow, "nui_shld_left", "btn_prev_b", 32.0f, 32.0f);
    CreateTextEditBox(jGroupRow, "place_holder", "txt_model_number_b", 3, FALSE, 40.0, 32.0);
    CreateButtonImage(jGroupRow, "nui_shld_right", "btn_next_b", 32.0f, 32.0f);
    JsonArrayInsertInplace(jGroupCol, NuiRow(jGroupRow));
    JsonArrayInsertInplace(jGroupCol, NuiSpacer());
    JsonArrayInsertInplace(jRow, NuiHeight(NuiWidth(NuiGroup(NuiCol(jGroupCol)), 127.0), 350.0));
    // Make the Color Group.
    jGroupRow = JsonArray();
    jGroupCol = JsonArray();
    // Row 511 (groups)********************************************************** 400 / 331 / 184
    CreateImage(jGroupRow, "", "color_pallet", NUI_ASPECT_EXACTSCALED, NUI_HALIGN_CENTER, NUI_VALIGN_TOP, 256.0f, 176.0f, -1.0, "color_pallet_tooltip");
    JsonArrayInsertInplace(jGroupCol, NuiRow(jGroupRow));
    // Row 512 (groups)********************************************************** 400 / 349 / 202
    jGroupRow = JsonArray();
    CreateLabel(jGroupRow, "Part to Color", "lbl_color_parts", 255.0f, 10.0f);
    JsonArrayInsertInplace(jGroupCol, NuiRow(jGroupRow));
    // Row 513 (groups)********************************************************** 400 / 377 / 230
    jGroupRow = JsonArray();
    JsonArrayInsertInplace(jGroupRow, NuiSpacer());
    CreateButtonSelect(jGroupRow, "Right", "btn_right_part_color", 82.0, 20.0);
    JsonArrayInsertInplace(jGroupRow, NuiSpacer());
    CreateButtonSelect(jGroupRow, "All", "btn_all_color", 82.0, 20.0);
    JsonArrayInsertInplace(jGroupRow, NuiSpacer());
    CreateButtonSelect(jGroupRow, "Left", "btn_left_part_color", 82.0, 20.0);
    JsonArrayInsertInplace(jGroupRow, NuiSpacer());
    JsonArrayInsertInplace(jGroupCol, NuiRow(jGroupRow));
    // Row 514 (groups)********************************************************** 400 / 395 / 248
    jGroupRow = JsonArray();
    CreateLabel(jGroupRow, "Part Color to Reset", "lbl_reset_parts", 255.0f, 10.0f);
    JsonArrayInsertInplace(jGroupCol, NuiRow(jGroupRow));
    // Row 515 (groups)********************************************************** 400 / 423 / 276
    jGroupRow = JsonArray();
    JsonArrayInsertInplace(jGroupRow, NuiSpacer());
    CreateButton(jGroupRow, "Right", "btn_right_part_reset", 100.0, 20.0);
    //JsonArrayInsertInplace(jGroupRow, NuiSpacer());
    //CreateButton(jGroupRow, "All", "btn_all_reset", 82.0, 20.0);
    JsonArrayInsertInplace(jGroupRow, NuiSpacer());
    CreateButton(jGroupRow, "Left", "btn_left_part_reset", 100.0, 20.0);
    JsonArrayInsertInplace(jGroupRow, NuiSpacer());
    JsonArrayInsertInplace(jGroupCol, NuiRow(jGroupRow));
    // Row 516 (groups)********************************************************** 400 / 395 / 248
    jGroupRow = JsonArray();
    CreateLabel(jGroupRow, "Material to Color", "lbl_material_color", 255.0f, 10.0f);
    JsonArrayInsertInplace(jGroupCol, NuiRow(jGroupRow));
    // Row 517 (groups)********************************************************** 400 / 451 / 304
    jGroupRow = JsonArray();
    JsonArrayInsertInplace(jGroupRow, NuiSpacer());
    CreateButtonSelect(jGroupRow, "Cloth 1", "btn_material_0", 82.0, 20.0);
    JsonArrayInsertInplace(jGroupRow, NuiSpacer());
    CreateButtonSelect(jGroupRow, "Leather 1", "btn_material_2", 82.0, 20.0);
    JsonArrayInsertInplace(jGroupRow, NuiSpacer());
    CreateButtonSelect(jGroupRow, "Metal 1", "btn_material_4", 82.0, 20.0);
    JsonArrayInsertInplace(jGroupRow, NuiSpacer());
    JsonArrayInsertInplace(jGroupCol, NuiRow(jGroupRow));
    // Row 518 (groups)********************************************************** 400 / 479 / 332
    jGroupRow = JsonArray();
    JsonArrayInsertInplace(jGroupRow, NuiSpacer());
    CreateButtonSelect(jGroupRow, "Cloth 2", "btn_material_1", 82.0, 20.0);
    JsonArrayInsertInplace(jGroupRow, NuiSpacer());
    CreateButtonSelect(jGroupRow, "Leather 2", "btn_material_3", 82.0, 20.0);
    JsonArrayInsertInplace(jGroupRow, NuiSpacer());
    CreateButtonSelect(jGroupRow, "Metal 2", "btn_material_5", 82.0, 20.0);
    JsonArrayInsertInplace(jGroupRow, NuiSpacer());
    JsonArrayInsertInplace(jGroupCol, NuiRow(jGroupRow));
    JsonArrayInsertInplace(jGroupCol, NuiSpacer());
    JsonArrayInsertInplace(jRow, NuiHeight(NuiWidth(NuiGroup(NuiCol(jGroupCol)), 275.0), 350.0));
    JsonArrayInsertInplace(jCol, NuiRow(jRow));
    json jLayout = NuiCol(jCol);
    // Get the window location to restore it from the database.
    json jGeometry = JsonObjectGet(jCraft, "Geometry");
    float fX = JsonGetFloat(JsonObjectGet(jGeometry, "x"));
    float fY = JsonGetFloat(JsonObjectGet(jGeometry, "y"));
    string sPCWindow;
    int nToken = SetWindow(oPC, jLayout, "crafting_nui", "Crafting",
                 fX, fY, 440.0, 540.0, FALSE, FALSE, FALSE, FALSE, TRUE, "pe_crafting");
    // Set all binds, events, and watches.
    NuiSetBindWatch (oPC, nToken, "window_geometry", TRUE);
    int nItem = JsonGetInt(JsonObjectGet(jCraft, CRAFT_ITEM_SELECTION));
    object oItem = GetSelectedItem(oTarget, nItem);
    // Row 1
    NuiSetBind(oPC, nToken, "txt_item_name", JsonString(GetName(oItem)));
    NuiSetBind(oPC, nToken, "txt_item_name_event", JsonBool(TRUE));
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
        NuiSetBind(oPC, nToken, "txt_model_number_t_event", JsonBool(TRUE));
        NuiSetBind(oPC, nToken, "txt_model_number_t", JsonString(sModelTop));
        NuiSetBind(oPC, nToken, "btn_prev_t_event", JsonBool(TRUE));
        NuiSetBind(oPC, nToken, "btn_next_t_event", JsonBool(TRUE));
        // Row 57
        NuiSetBind(oPC, nToken, "middle_title_label", JsonString("Middle"));
        // Row 58
        NuiSetBind(oPC, nToken, "txt_model_number_m_event", JsonBool(TRUE));
        NuiSetBind(oPC, nToken, "txt_model_number_m", JsonString(sModelMiddle));
        NuiSetBind(oPC, nToken, "btn_prev_m_event", JsonBool(TRUE));
        NuiSetBind(oPC, nToken, "btn_next_m_event", JsonBool(TRUE));
        // Row 59
        NuiSetBind(oPC, nToken, "bottom_title_label", JsonString("Bottom"));
        // Row 510
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
            // Row 55
            NuiSetBind(oPC, nToken, "top_title_label", JsonString(""));
            // Row 56
            NuiSetBind(oPC, nToken, "txt_model_number_t_event", JsonBool(FALSE));
            NuiSetBind(oPC, nToken, "txt_model_name_t", JsonString(""));
            NuiSetBind(oPC, nToken, "btn_prev_t_event", JsonBool(FALSE));
            NuiSetBind(oPC, nToken, "btn_next_t_event", JsonBool(FALSE));
            // Row 57
            NuiSetBind(oPC, nToken, "middle_title_label", JsonString("Model"));
            // Row 58
            NuiSetBind(oPC, nToken, "txt_model_number_m_event", JsonBool(TRUE));
            NuiSetBind(oPC, nToken, "txt_model_number_m", JsonString(sModelMiddle));
            NuiSetBind(oPC, nToken, "btn_prev_m_event", JsonBool(TRUE));
            NuiSetBind(oPC, nToken, "btn_next_m_event", JsonBool(TRUE));
            // Row 59
            NuiSetBind(oPC, nToken, "bottom_title_label", JsonString(""));
            // Row 510
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
            // Row 55
            NuiSetBind(oPC, nToken, "top_title_label", JsonString("Right"));
            // Row 56
            NuiSetBind(oPC, nToken, "txt_model_number_t_event", JsonBool(TRUE));
            NuiSetBind(oPC, nToken, "txt_model_number_t", JsonString(sModelTop));
            NuiSetBind(oPC, nToken, "btn_prev_t_event", JsonBool(TRUE));
            NuiSetBind(oPC, nToken, "btn_next_t_event", JsonBool(TRUE));
            // Row 57
            NuiSetBind(oPC, nToken, "middle_title_label", JsonString("Right & Left"));
            // Row 58
            NuiSetBind(oPC, nToken, "txt_model_number_m_event", JsonBool(TRUE));
            NuiSetBind(oPC, nToken, "txt_model_number_m", JsonString(sModelTop));
            NuiSetBind(oPC, nToken, "btn_prev_m_event", JsonBool(TRUE));
            NuiSetBind(oPC, nToken, "btn_next_m_event", JsonBool(TRUE));
            // Row 59
            NuiSetBind(oPC, nToken, "bottom_title_label", JsonString("Left"));
            // Row 510
            NuiSetBind(oPC, nToken, "txt_model_number_b_event", JsonBool(TRUE));
            NuiSetBind(oPC, nToken, "txt_model_number_b", JsonString(sModelBottom));
            NuiSetBind(oPC, nToken, "btn_prev_b_event", JsonBool(TRUE));
            NuiSetBind(oPC, nToken, "btn_next_b_event", JsonBool(TRUE));
        }
    }
    // Shields, Cloaks, and Helmets.
    else
    {
        sModelMiddle = IntToString(GetItemAppearance(oItem, ITEM_APPR_TYPE_SIMPLE_MODEL, 0));
            // Row 55
        NuiSetBind(oPC, nToken, "top_title_label", JsonString(""));
            // Row 56
        NuiSetBind(oPC, nToken, "txt_model_number_t_event", JsonBool(FALSE));
        NuiSetBind(oPC, nToken, "txt_model_number_t", JsonString(""));
        NuiSetBind(oPC, nToken, "btn_prev_t_event", JsonBool(FALSE));
        NuiSetBind(oPC, nToken, "btn_next_t_event", JsonBool(FALSE));
            // Row 57
        NuiSetBind(oPC, nToken, "middle_title_label", JsonString("Model"));
            // Row 58
        NuiSetBind(oPC, nToken, "txt_model_number_m_event", JsonBool(TRUE));
        NuiSetBind(oPC, nToken, "txt_model_number_m", JsonString(sModelMiddle));
        NuiSetBind(oPC, nToken, "btn_prev_m_event", JsonBool(TRUE));
        NuiSetBind(oPC, nToken, "btn_next_m_event", JsonBool(TRUE));
            // Row 59
        NuiSetBind(oPC, nToken, "bottom_title_label", JsonString(""));
            // Row 510
        NuiSetBind(oPC, nToken, "txt_model_number_b_event", JsonBool(FALSE));
        NuiSetBind(oPC, nToken, "txt_model_number_b", JsonString(""));
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
        //NuiSetBind(oPC, nToken, "btn_all_reset_event", JsonBool(FALSE));
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
        string sColorPallet = GetLocalString(oPC, CRAFT_COLOR_PALLET);
        if(sColorPallet == "") sColorPallet = "gui_pal_tattoo";
        // Row 511
        NuiSetBind(oPC, nToken, "color_pallet_image", JsonString(sColorPallet));
        NuiSetBind(oPC, nToken, "color_pallet_event", JsonBool(TRUE));
        NuiSetBind(oPC, nToken, "color_pallet_tooltip", JsonString("  Select a color or use the mouse wheel"));
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
            // Row 512 - Label Part to Color
            // Row 5l3
            nSelected = JsonGetInt(JsonObjectGet(jCraft, CRAFT_RIGHT_PART_COLOR));
            NuiSetBind(oPC, nToken, "btn_right_part_color", JsonBool(nSelected));
            NuiSetBind(oPC, nToken, "btn_right_part_color_event", JsonBool(TRUE));
            nSelected = JsonGetInt(JsonObjectGet(jCraft, CRAFT_ALL_COLOR));
            NuiSetBind(oPC, nToken, "btn_all_color", JsonBool(nSelected));
            NuiSetBind(oPC, nToken, "btn_all_color_event", JsonBool(TRUE));
            NuiSetBind(oPC, nToken, "btn_left_part_color", JsonBool(FALSE));
            NuiSetBind(oPC, nToken, "btn_left_part_color_event", JsonBool(FALSE));
            // Row 514 - Label Part Color to Reset
            // Row 5l5
            NuiSetBind(oPC, nToken, "btn_right_part_reset_event", JsonBool(TRUE));
            //NuiSetBind(oPC, nToken, "btn_all_reset_event", JsonBool(TRUE));
            NuiSetBind(oPC, nToken, "btn_left_part_reset_event", JsonBool(FALSE));
        }
        else
        {
            // Row 512 - Label Part to Color
            // Row 5l3
            nSelected = JsonGetInt(JsonObjectGet(jCraft, CRAFT_RIGHT_PART_COLOR));
            NuiSetBind(oPC, nToken, "btn_right_part_color", JsonBool(nSelected));
            NuiSetBind(oPC, nToken, "btn_right_part_color_event", JsonBool(TRUE));
            nSelected = JsonGetInt(JsonObjectGet(jCraft, CRAFT_ALL_COLOR));
            NuiSetBind(oPC, nToken, "btn_all_color", JsonBool(nSelected));
            NuiSetBind(oPC, nToken, "btn_all_color_event", JsonBool(TRUE));
            nSelected = JsonGetInt(JsonObjectGet(jCraft, CRAFT_LEFT_PART_COLOR));
            NuiSetBind(oPC, nToken, "btn_left_part_color", JsonBool(nSelected));
            NuiSetBind(oPC, nToken, "btn_left_part_color_event", JsonBool(TRUE));
            // Row 514 - Label Part Color to Reset
            // Row 5l5
            NuiSetBind(oPC, nToken, "btn_left_part_reset_event", JsonBool(TRUE));
            //NuiSetBind(oPC, nToken, "btn_all_reset_event", JsonBool(TRUE));
            NuiSetBind(oPC, nToken, "btn_right_part_reset_event", JsonBool(TRUE));
        }
        // Row 516 - Label Material to Color
        // Row 517 & 518
        nSelected = JsonGetInt(JsonObjectGet(jCraft, CRAFT_MATERIAL_SELECTION));
        SetMaterialButtons(oPC, nToken, nSelected);
    }
    // Cloaks and Helmets.
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
        NuiSetBind(oPC, nToken, "btn_right_part_color_event", JsonBool(FALSE));
        NuiSetBind(oPC, nToken, "btn_right_part_color_event", JsonBool(FALSE));
        NuiSetBind(oPC, nToken, "btn_all_color_event", JsonBool(TRUE));
        NuiSetBind(oPC, nToken, "btn_all_color_event", JsonBool(TRUE));
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
void CreateModelCombo(object oPC, object oTarget, json jRow, string sComboBind)
{
    float fFacing = GetFacing(oTarget);
    json jCombo = JsonArray();
    json jCraft = GetLocalJson(oPC, CRAFT_JSON);
    int nSelected = JsonGetInt(JsonObjectGet(jCraft, CRAFT_ITEM_SELECTION));
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
        if(ai_GetIsShield(oItem))
        {
            JsonArrayInsertInplace(jCombo, NuiComboEntry("Shield", 0));
            JsonArrayInsertInplace(jCombo, NuiComboEntry("Invisible", 1));
        }
        else JsonArrayInsertInplace(jCombo, NuiComboEntry("Weapon", 0));
    }
    CreateCombo(jRow, jCombo, sComboBind, 110.0, 25.0);
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
int StartingUp(object oPC)
{
    if(GetLocalInt(oPC, AI_ADD_PLUGIN))
    {
        json jPlugin = JsonArray();
        jPlugin = JsonArrayInsert(jPlugin, JsonString("pi_crafting"));
        jPlugin = JsonArrayInsert(jPlugin, JsonBool(FALSE));
        jPlugin = JsonArrayInsert(jPlugin, JsonString("Item Crafting"));
        jPlugin = JsonArrayInsert(jPlugin, JsonString("isk_x2cweap"));
        json jPlugins = GetLocalJson(oPC, AI_JSON_PLUGINS);
        jPlugins = JsonArrayInsert(jPlugins, jPlugin);
        SetLocalJson(oPC, AI_JSON_PLUGINS, jPlugin);
        SetLocalInt(oPC, AI_PLUGIN_SET, TRUE);
        return TRUE;
    }
    if(!GetLocalInt(oPC, AI_STARTING_UP)) return FALSE;
    return TRUE;
}

