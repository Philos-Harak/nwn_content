/*//////////////////////////////////////////////////////////////////////////////
// Script Name: pi_crafting
////////////////////////////////////////////////////////////////////////////////
 Executable plug in script for Philos Module Extentions

 Crafting UI for players items.
*///////////////////////////////////////////////////////////////////////////////
#include "0i_nui"
#include "0i_items"
#include "nw_inc_gff"
const string CRAFT_JSON = "CRAFT_JSON";
const string CRAFT_COOL_DOWN = "CRAFT_COOL_DOWN";
const string CRAFT_ITEM_SELECTION = "CRAFT_ITEM_SELECTION";
const string CRAFT_MATERIAL_SELECTION = "CRAFT_MATERIAL_SELECTION";
const string CRAFT_MODEL_SELECTION = "CRAFT_MODEL_SELECTION";
const string CRAFT_COLOR_PALLET = "CRAFT_COLOR_PALLET";
const string CRAFT_LEFT_PART_COLOR = "CRAFT_LEFT_PART_COLOR";
const string CRAFT_ALL_COLOR = "CRAFT_ALL_COLOR";
const string CRAFT_RIGHT_PART_COLOR = "CRAFT_RIGHT_PART_COLOR";
const string CRAFT_TARGET = "CRAFT_TARGET";
// Tag used in lighting effects.
const string CRAFT_HIGHLIGHT = "CRAFT_HIGHLIGHT";
const string CRAFT_ULTRALIGHT = "CRAFT_ULTRALIGHT";

json CreateItemCombo(object oPC, json jRow, string sComboBind);
json CreateModelCombo(object oPC, object oTarget, json jRow, string sComboBind);
json CreateMaterialCombo(object oPC, json jRow, string sComboBind);
// Sets the material buttons for use.
// nMaterial 0,1 Cloth 2,3 Leather 4,5 Metal -1 None.
void SetMaterialButtons(object oPC, int nToken, int nMaterial);
// Returns the correct item based on the crafting menu selected item.
object GetSelectedItem(object oTarget, int nItemSelected);
int GetArmorModelSelected(object oPC);
// Returns True if oItem, nPart has a per part color for sSide.
int GetHasPartColor(object oItem, int nPart, string sSide);
// Does startup check if the game has just been loaded.
int StartingUp(object oPC);
void main()
{
    object oPC = OBJECT_SELF;
    object oTarget = GetLocalObject(oPC, CRAFT_TARGET);
    if(oTarget == OBJECT_INVALID) oTarget = oPC;
    if(StartingUp(oPC)) return;
    json jCraft = GetLocalJson(oPC, CRAFT_JSON);
    // Row 1 (Object Name)****************************************************** 508 / 83
    json jRow = CreateTextEditBox(JsonArray(), "plc_hold_bind", "txt_item_name", 50, FALSE, 486.0f, 30.0f);  // 419
    json jCol = JsonArrayInsert(JsonArray(), NuiRow(jRow));
    // Row 2 (Object Name)****************************************************** 508 / 121
    jRow = JsonArray();
    if(!AI_SERVER) jRow = CreateButton(jRow, "Information", "btn_info", 160.0f, 30.0f, -1.0, "btn_info_tooltip");
    else
    {
        if(GetIsDM(oTarget))
        {
            jRow = CreateButton(jRow, "Information", "btn_info", 160.0f, 30.0f, -1.0, "btn_info_tooltip");
        }
        else jRow = JsonArrayInsert(jRow, NuiSpacer());
    }
    jRow = CreateButton(jRow, "Wardrobe", "btn_wardrobe", 158.0f, 30.0f, -1.0, "btn_wardrobe_tooltip");
    jRow = CreateButtonSelect(jRow, "Add Light", "btn_highlight", 160.0f, 30.0f, "btn_highlight_tooltip");
    jCol = JsonArrayInsert(jCol, NuiRow(jRow));
    // Row 3 (Object Name)****************************************************** 508 / 159
    jRow = CreateButton(JsonArray(), "Save", "btn_save", 160.0f, 30.0f, -1.0, "btn_save_tooltip");
    jRow = CreateButton(jRow, "Select Target", "btn_select_target", 158.0f, 30.0f);
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
    json jIndicator = JsonArrayInsert(JsonArray(), NuiDrawListRect(JsonBool(TRUE), NuiColor(255,255,255), JsonBool(FALSE), JsonFloat(2.0), NuiBind("color_pallet_pointer")));
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
    jGroupRow = CreateButtonSelect(JsonArray(), "Cloth 1", "btn_material_0", 98.0, 30.0);
    jGroupRow = JsonArrayInsert(jGroupRow, NuiSpacer());
    jGroupRow = CreateButtonSelect(jGroupRow, "Leather 1", "btn_material_2", 98.0, 30.0);
    jGroupRow = JsonArrayInsert(jGroupRow, NuiSpacer());
    jGroupRow = CreateButtonSelect(jGroupRow, "Metal 1", "btn_material_4", 98.0, 30.0);
    jGroupCol = JsonArrayInsert(jGroupCol, NuiRow(jGroupRow));
    // Row 557 (groups)********************************************************* 508 / 567 / 390
    jGroupRow = CreateButtonSelect(JsonArray(), "Cloth 2", "btn_material_1", 98.0, 30.0);
    jGroupRow = JsonArrayInsert(jGroupRow, NuiSpacer());
    jGroupRow = CreateButtonSelect(jGroupRow, "Leather 2", "btn_material_3", 98.0, 30.0);
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
    NuiSetBind(oPC, nToken, "txt_item_name_event", JsonBool(TRUE));
    NuiSetBindWatch(oPC, nToken, "txt_item_name", TRUE);
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
    return nPartColor;
}
int StartingUp(object oPC)
{
    if(GetLocalInt(oPC, AI_ADD_PLUGIN))
    {
        json jPlugin = JsonArray();
        jPlugin = JsonArrayInsert(jPlugin, JsonString("pi_crafting"));
        jPlugin = JsonArrayInsert(jPlugin, JsonInt(FALSE));
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

