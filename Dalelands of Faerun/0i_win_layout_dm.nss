/*//////////////////////////////////////////////////////////////////////////////
// Script Name: 0i_win_design_dm
////////////////////////////////////////////////////////////////////////////////
 Include script for handling window displays.
*///////////////////////////////////////////////////////////////////////////////
// Programmer: Philos
////////////////////////////////////////////////////////////////////////////////
#include "0i_quest"
#include "0i_window"
#include "0i_win_functions"
#include "0i_npc"
#include "nwnx_creature"
#include "nwnx_object"

void PopUpDMGUIPanel (object oPC)
{
    // Set window to not save until it has been created.
    SetLocalInt (oPC, "0_No_Win_Save", TRUE);
    DelayCommand (0.5f, DeleteLocalInt (oPC, "0_No_Win_Save"));
    // Get the menu options.
    string sOptionsArray = GetServerDatabaseString (oPC, PLAYER_TABLE, "ploptionwin");
    int bStartCombat = StringToInt (GetStringArray (sOptionsArray,4));
    int bStopCombat = StringToInt (GetStringArray (sOptionsArray,5));
    int bExamine = StringToInt (GetStringArray (sOptionsArray,6));
    int bDice = StringToInt (GetStringArray (sOptionsArray,7));
    int bServer = StringToInt (GetStringArray (sOptionsArray,8));
    int bArea = StringToInt (GetStringArray (sOptionsArray,9));
    int bAdventure = StringToInt (GetStringArray (sOptionsArray,10));
    int bNPC = StringToInt (GetStringArray (sOptionsArray,11));
    int bTransition = StringToInt (GetStringArray (sOptionsArray,12));
    int bCrafting = StringToInt (GetStringArray (sOptionsArray,13));
    int bBugReport = StringToInt (GetStringArray (sOptionsArray,14));
    int bCynosure = StringToInt (GetStringArray (sOptionsArray,15));
    int bTarget = StringToInt (GetStringArray (sOptionsArray,16));
    int bChest = StringToInt (GetStringArray (sOptionsArray,17));
    int bPlayer;
    if (GetIsPlayerDM (oPC)) bPlayer = StringToInt (GetStringArray (sOptionsArray,18));
    float fWidth = 12.0;
    // Row 1 (buttons)**********************************************************
    json jRow = JsonArray ();
    jRow = CreateButton (jRow, "Options", "btn_options", 100.0, 32.0, 0.0);
    fWidth += 100.0;
    if (bStartCombat)
    {
        jRow = CreateButton (jRow, "Start Combat", "btn_str_combat", 100.0, 32.0, 0.0);
        fWidth += 108.0;
    }
    if (bStopCombat)
    {
        jRow = CreateButton (jRow, "Stop Combat", "btn_stp_combat", 100.0, 32.0, 0.0);
        fWidth += 108.0;
    }
    if (bExamine)
    {
        jRow = CreateButton (jRow, "Examine", "btn_examine", 100.0, 32.0, 0.0);
        fWidth += 108.0;
    }
    if (bChest)
    {
        jRow = CreateButton (jRow, "DM Chest", "btn_dm_chest", 100.0, 32.0, 0.0);
        fWidth += 108.0;
    }
    if (bDice)
    {
        jRow = CreateButton (jRow, "Dice", "btn_dice", 100.0, 32.0, 0.0);
        fWidth += 108.0;
    }
    if (bServer)
    {
        jRow = CreateButton (jRow, "Server", "btn_server", 100.0, 32.0, 0.0);
        fWidth += 108.0;
    }
    if (bArea)
    {
        jRow = CreateButton (jRow, "Area", "btn_area", 100.0, 32.0, 0.0);
        fWidth += 108.0;
    }
    if (bAdventure)
    {
        jRow = CreateButton (jRow, "Adventure", "btn_adventure", 100.0, 32.0, 0.0);
        fWidth += 108.0;
    }
    if (bNPC)
    {
        jRow = CreateButton (jRow, "NPC Creator", "btn_npc", 100.0, 32.0, 0.0);
        fWidth += 108.0;
    }
    if (bTransition)
    {
        jRow = CreateButton (jRow, "Transition", "btn_transitions", 100.0, 32.0, 0.0);
        fWidth += 108.0;
    }
    if (bCrafting)
    {
        jRow = CreateButton (jRow, "Crafting", "btn_craft", 100.0, 32.0, 0.0);
        fWidth += 108.0;
    }
    if (bBugReport)
    {
        jRow = CreateButton (jRow, "Bug Report", "btn_bug_report", 100.0, 32.0, 0.0);
        fWidth += 108.0;
    }
    if (bCynosure)
    {
        jRow = CreateButton (jRow, "Cynosure", "btn_cynosure", 100.0, 32.0, 0.0);
        fWidth += 108.0;
    }
    if (bPlayer)
    {
        jRow = CreateButton (jRow, "Player Mode", "btn_pc_mode", 100.0, 32.0, 0.0);
        fWidth += 108.0;
    }
    if (bTarget)
    {
        jRow = CreateLabel (jRow, "Target:", "dm_target_title", 65.0, 32.0);
        jRow = CreateLabel (jRow, "", "dm_target_value", 135.0, 32.0, -1.0, NUI_HALIGN_LEFT);
        fWidth += 208.0;
    }
    fWidth += 12.0;
    // Add the row to the column.
    json jCol = JsonArrayInsert (JsonArray (), NuiRow (jRow));
    // Set the layout of the window.
    float fScale = IntToFloat (GetPlayerDeviceProperty (oPC, PLAYER_DEVICE_PROPERTY_GUI_SCALE)) / 100.0f;
    json jLayout = NuiCol (jCol);
    int nToken = SetWindow (oPC, jLayout, "plplayerwin", "",
                            477.0 * fScale, 0.0, fWidth, 56.0 * fScale, FALSE, FALSE, FALSE, TRUE, FALSE);
    // Set the buttons to show events to 0e_window.
    NuiSetBind (oPC, nToken, "btn_options_event", JsonBool (TRUE));
    if (bStartCombat) NuiSetBind (oPC, nToken, "btn_str_combat_event", JsonBool (TRUE));
    if (bStopCombat) NuiSetBind (oPC, nToken, "btn_stp_combat_event", JsonBool (TRUE));
    if (bExamine) NuiSetBind (oPC, nToken, "btn_examine_event", JsonBool (TRUE));
    if (bChest) NuiSetBind (oPC, nToken, "btn_dm_chest_event", JsonBool (TRUE));
    if (bDice) NuiSetBind (oPC, nToken, "btn_dice_event", JsonBool (TRUE));
    if (bServer) NuiSetBind (oPC, nToken, "btn_server_event", JsonBool (TRUE));
    if (bArea) NuiSetBind (oPC, nToken, "btn_area_event", JsonBool (TRUE));
    if (bAdventure) NuiSetBind (oPC, nToken, "btn_adventure_event", JsonBool (TRUE));
    if (bNPC) NuiSetBind (oPC, nToken, "btn_npc_event", JsonBool (TRUE));
    if (bTransition) NuiSetBind (oPC, nToken, "btn_transitions_event", JsonBool (TRUE));
    if (bCrafting) NuiSetBind (oPC, nToken, "btn_craft_event", JsonBool (TRUE));
    if (bBugReport) NuiSetBind (oPC, nToken, "btn_bug_report_event", JsonBool (TRUE));
    if (bCynosure) NuiSetBind (oPC, nToken, "btn_cynosure_event", JsonBool (TRUE));
    if (bPlayer) NuiSetBind (oPC, nToken, "btn_pc_mode_event", JsonBool (TRUE));
    if (bTarget)
    {
        string sValue = GetName (GetLocalObject (oPC, "0_DM_Target"));
        NuiSetBind (oPC, nToken, "dm_target_value_label", JsonString (sValue));
    }
}

void PopUpDMOptionsGUIPanel (object oPC)
{
    // Set window to not save until it has been created.
    SetLocalInt (oPC, "0_No_Win_Save", TRUE);
    DelayCommand (0.5f, DeleteLocalInt (oPC, "0_No_Win_Save"));
    // Row 1 (Buttons)********************************************************** 45
    json jRow = CreateButtonSelect (JsonArray (), "Require Password", "btn_password", 125.0f, 20.0f);
    jRow = JsonArrayInsert(jRow, NuiSpacer());
    jRow = CreateButtonSelect (jRow, "Get Player Alerts", "btn_alerts", 125.0f, 20.0f);
    // Add row to the column.
    json jCol = JsonArrayInsert (JsonArray (), NuiRow (jRow));
    // Row 2 (Action Buttons)*************************************************** 73
    jRow = CreateButtonSelect (JsonArray (), "Alert Discord", "btn_discord", 125.0f, 20.0f);
    jRow = JsonArrayInsert(jRow, NuiSpacer());
    jRow = CreateButton (jRow, "Credits", "btn_credits", 125.0f, 20.0f);
    // Add row to the column.
    jCol = JsonArrayInsert (jCol, NuiRow (jRow));
    // Row 3 (Action Buttons)*************************************************** 101
    jRow = CreateCheckBox (JsonArray (), "", "str_cmbt", 25.0, 20.0f);
    jRow = CreateButton (jRow, "Start Combat", "btn_str_combat", 100.0,20.0);
    jRow = CreateCheckBox (jRow, "", "stp_cmbt", 25.0, 20.0f);
    jRow = CreateButton (jRow, "Stop Combat", "btn_stp_combat", 100.0, 20.0);
    // Add row to the column.
    jCol = JsonArrayInsert (jCol, NuiRow (jRow));
    // Row 4 (Action Buttons)*************************************************** 129
    jRow = CreateCheckBox (JsonArray (), "", "examine", 25.0, 20.0f);
    jRow = CreateButton (jRow, "Examine", "btn_examine", 100.0,20.0);
    jRow = CreateCheckBox (jRow, "", "dice", 25.0, 20.0f);
    jRow = CreateButton (jRow, "Dice", "btn_dice", 100.0, 20.0);
    // Add row to the column.
    jCol = JsonArrayInsert (jCol, NuiRow (jRow));
    // Row 5 (Action Buttons)*************************************************** 157
    jRow = CreateCheckBox (JsonArray (), "", "server", 25.0, 20.0f);
    jRow = CreateButton (jRow, "Server", "btn_server", 100.0,20.0);
    jRow = CreateCheckBox (jRow, "", "area", 25.0, 20.0f);
    jRow = CreateButton (jRow, "Area", "btn_area", 100.0, 20.0);
    // Add row to the column.
    jCol = JsonArrayInsert (jCol, NuiRow (jRow));
    // Row 6 (Action Buttons)*************************************************** 185
    jRow = CreateCheckBox (JsonArray (), "", "adventure", 25.0, 20.0f);
    jRow = CreateButton (jRow, "Adventure", "btn_adventure", 100.0,20.0);
    jRow = CreateCheckBox (jRow, "", "npc", 25.0, 20.0f);
    jRow = CreateButton (jRow, "NPC Creator", "btn_npc", 100.0, 20.0);
    // Add row to the column.
    jCol = JsonArrayInsert (jCol, NuiRow (jRow));
    // Row 7 (Action Buttons)*************************************************** 213
    jRow = CreateCheckBox (JsonArray (), "", "transitions", 25.0, 20.0f);
    jRow = CreateButton (jRow, "Transition", "btn_transitions", 100.0,20.0);
    jRow = CreateCheckBox (jRow, "", "craft", 25.0, 20.0f);
    jRow = CreateButton (jRow, "Crafting", "btn_craft", 100.0, 20.0);
    // Add row to the column.
    jCol = JsonArrayInsert (jCol, NuiRow (jRow));
    // Row 8 (Action Buttons)*************************************************** 241
    jRow = CreateCheckBox (JsonArray (), "", "bug_report", 25.0, 20.0f);
    jRow = CreateButton (jRow, "Bug Report", "btn_bug_report", 100.0,20.0);
    jRow = CreateCheckBox (jRow, "", "cynosure", 25.0, 20.0f);
    jRow = CreateButton (jRow, "Cynosure", "btn_cynosure", 100.0, 20.0);
    // Add row to the column.
    jCol = JsonArrayInsert (jCol, NuiRow (jRow));
    // Row 9 (Action Buttons)*************************************************** 269
    jRow = CreateCheckBox (JsonArray (), "", "dm_chest", 25.0, 20.0f);
    jRow = CreateButton (jRow, "DM Chest", "btn_dm_chest", 100.0,20.0);
    if (GetIsPlayerDM (oPC))
    {
        jRow = CreateCheckBox (jRow, "", "pc_mode", 25.0, 20.0f);
        jRow = CreateButton (jRow, "Player Mode", "btn_pc_mode", 100.0, 20.0, 0.0);
    }
    else jRow = JsonArrayInsert (jRow, NuiSpacer());
    // Add row to the column.
    jCol = JsonArrayInsert (jCol, NuiRow (jRow));
    // Row 10 (Action Buttons)************************************************** 297
    jRow = CreateCheckBox (JsonArray (), "", "target", 25.0, 20.0f);
    jRow = CreateLabel (jRow, "Target:", "dm_target_title", 65.0, 20.0);
    jRow = CreateLabel (jRow, "", "dm_target_value", 135.0, 20.0, -1.0, NUI_HALIGN_LEFT);
    jRow = JsonArrayInsert(jRow, NuiSpacer());
    // Add row to the column.
    jCol = JsonArrayInsert (jCol, NuiRow (jRow));
    // Get the window location to restore it from the database.
    string sPCWindow = GetServerDatabaseString (oPC, PLAYER_TABLE, "ploptionwin");
    float fX = StringToFloat (GetStringArray (sPCWindow, 1));
    float fY = StringToFloat (GetStringArray (sPCWindow, 2));
    // Set the Layout of the window.
    json jLayout = NuiCol (jCol);
    int nToken = SetWindow (oPC, jLayout, "ploptionwin", "Options",
                            fX, fY, 298.0f, 329.0f, FALSE, FALSE, TRUE, FALSE, TRUE);
    // Setup watch so we can save this windows position to the database.
    NuiSetBindWatch (oPC, nToken, "window_geometry", TRUE);
    string sOptionsArray = GetServerDatabaseString (oPC, PLAYER_TABLE, "ploptionwin");
    int bStartCombat = StringToInt (GetStringArray (sOptionsArray,4));
    int bStopCombat = StringToInt (GetStringArray (sOptionsArray,5));
    int bExamine = StringToInt (GetStringArray (sOptionsArray,6));
    int bDice = StringToInt (GetStringArray (sOptionsArray,7));
    int bServer = StringToInt (GetStringArray (sOptionsArray,8));
    int bArea = StringToInt (GetStringArray (sOptionsArray,9));
    int bAdventure = StringToInt (GetStringArray (sOptionsArray,10));
    int bNPC = StringToInt (GetStringArray (sOptionsArray,11));
    int bTransition = StringToInt (GetStringArray (sOptionsArray,12));
    int bCrafting = StringToInt (GetStringArray (sOptionsArray,13));
    int bBugReport = StringToInt (GetStringArray (sOptionsArray,14));
    int bCynosure = StringToInt (GetStringArray (sOptionsArray,15));
    int bTarget = StringToInt (GetStringArray (sOptionsArray,16));
    int bChest = StringToInt (GetStringArray (sOptionsArray,17));
    int bPlayer = StringToInt (GetStringArray (sOptionsArray,18));
    // Set all binds, events, and watches.
    if (GetServerDatabaseInt (GetModule (), SERVER_TABLE, "password")) NuiSetBind (oPC, nToken, "btn_password", JsonBool (TRUE));
    else NuiSetBind (oPC, nToken, "btn_password", JsonBool (FALSE));
    NuiSetBind (oPC, nToken, "btn_password_event", JsonBool (TRUE));
    string sOptions = GetServerDatabaseString (oPC, DM_TABLE, "options");
    if (GetStringArray (sOptions, 0) == "1") NuiSetBind (oPC, nToken, "btn_alerts", JsonBool (TRUE));
    else NuiSetBind (oPC, nToken, "btn_alerts", JsonBool (FALSE));
    NuiSetBind (oPC, nToken, "btn_alerts_event", JsonBool (TRUE));
    if (GetStringArray (sOptions, 1) == "1") NuiSetBind (oPC, nToken, "btn_discord", JsonBool (TRUE));
    else NuiSetBind (oPC, nToken, "btn_discord", JsonBool (FALSE));
    NuiSetBind (oPC, nToken, "btn_discord_event", JsonBool (TRUE));
    NuiSetBind (oPC, nToken, "btn_credits_event", JsonBool (TRUE));
    NuiSetBind (oPC, nToken, "str_cmbt_check", JsonBool (bStartCombat));
    NuiSetBindWatch (oPC, nToken, "str_cmbt_check", TRUE);
    NuiSetBind (oPC, nToken, "btn_str_combat_event", JsonBool (TRUE));
    NuiSetBind (oPC, nToken, "stp_cmbt_check", JsonBool (bStopCombat));
    NuiSetBindWatch (oPC, nToken, "stp_cmbt_check", TRUE);
    NuiSetBind (oPC, nToken, "btn_stp_combat_event", JsonBool (TRUE));
    NuiSetBind (oPC, nToken, "examine_check", JsonBool (bExamine));
    NuiSetBindWatch (oPC, nToken, "examine_check", TRUE);
    NuiSetBind (oPC, nToken, "btn_examine_event", JsonBool (TRUE));
    NuiSetBind (oPC, nToken, "dice_check", JsonBool (bDice));
    NuiSetBindWatch (oPC, nToken, "dice_check", TRUE);
    NuiSetBind (oPC, nToken, "btn_dice_event", JsonBool (TRUE));
    NuiSetBind (oPC, nToken, "server_check", JsonBool (bServer));
    NuiSetBindWatch (oPC, nToken, "server_check", TRUE);
    NuiSetBind (oPC, nToken, "btn_server_event", JsonBool (TRUE));
    NuiSetBind (oPC, nToken, "area_check", JsonBool (bArea));
    NuiSetBindWatch (oPC, nToken, "area_check", TRUE);
    NuiSetBind (oPC, nToken, "btn_area_event", JsonBool (TRUE));
    NuiSetBind (oPC, nToken, "adventure_check", JsonBool (bAdventure));
    NuiSetBindWatch (oPC, nToken, "adventure_check", TRUE);
    NuiSetBind (oPC, nToken, "btn_adventure_event", JsonBool (TRUE));
    NuiSetBind (oPC, nToken, "npc_check", JsonBool (bNPC));
    NuiSetBindWatch (oPC, nToken, "npc_check", TRUE);
    NuiSetBind (oPC, nToken, "btn_npc_event", JsonBool (TRUE));
    NuiSetBind (oPC, nToken, "transitions_check", JsonBool (bTransition));
    NuiSetBindWatch (oPC, nToken, "transitions_check", TRUE);
    NuiSetBind (oPC, nToken, "btn_transitions_event", JsonBool (TRUE));
    NuiSetBind (oPC, nToken, "craft_check", JsonBool (bCrafting));
    NuiSetBindWatch (oPC, nToken, "craft_check", TRUE);
    NuiSetBind (oPC, nToken, "btn_craft_event", JsonBool (TRUE));
    NuiSetBind (oPC, nToken, "bug_report_check", JsonBool (bBugReport));
    NuiSetBindWatch (oPC, nToken, "bug_report_check", TRUE);
    NuiSetBind (oPC, nToken, "btn_bug_report_event", JsonBool (TRUE));
    NuiSetBind (oPC, nToken, "cynosure_check", JsonBool (bCynosure));
    NuiSetBindWatch (oPC, nToken, "cynosure_check", TRUE);
    NuiSetBind (oPC, nToken, "btn_cynosure_event", JsonBool (TRUE));
    NuiSetBind (oPC, nToken, "dm_chest_check", JsonBool (bChest));
    NuiSetBindWatch (oPC, nToken, "dm_chest_check", TRUE);
    NuiSetBind (oPC, nToken, "btn_dm_chest_event", JsonBool (TRUE));
    NuiSetBind (oPC, nToken, "pc_mode_check", JsonBool (bPlayer));
    NuiSetBindWatch (oPC, nToken, "pc_mode_check", TRUE);
    NuiSetBind (oPC, nToken, "btn_pc_mode_event", JsonBool (TRUE));
    NuiSetBind (oPC, nToken, "target_check", JsonBool (bTarget));
    NuiSetBindWatch (oPC, nToken, "target_check", TRUE);
    string sValue = GetName (GetLocalObject (oPC, "0_DM_Target"));
    NuiSetBind (oPC, nToken, "dm_target_value_label", JsonString (sValue));
}


void PopUpDMCreatureGUIPanel (object oPC)
{
    json jButton;
    float fHeight = 555.0f;
    // Set window to not save until it has been created.
    SetLocalInt(oPC, "0_No_Win_Save", TRUE);
    DelayCommand(0.5f, DeleteLocalInt (oPC, "0_No_Win_Save"));
    // Get the DM target.
    object oTarget = GetLocalObject(oPC, "0_DM_Target");
    int bPC = GetIsPC(oTarget);
    // Create the column.
    // Row 1 (Character sheet tabs)********************************************* 45
    json jRow = CreateButtonImage(JsonArray(), "char_sheet", "btn_char_sheet", 85.0, 25.0, -1.0, "char_sht_tooltip");
    jRow = CreateButtonImage(jRow, "skill_sheet", "btn_skill_sheet", 85.0, 25.0, -1.0, "skill_sht_tooltip");
    jRow = CreateButtonImage(jRow, "feat_sheet", "btn_feat_sheet", 85.0, 25.0, -1.0, "feat_sht_tooltip");
    // Add the row to the column.
    json jCol = JsonArrayInsert(JsonArray(), NuiRow(jRow));
    // Row 2 (Character Name)*************************************************** 78
    jRow = CreateTextEditBox (JsonArray (), "name_placeholder", "char_name", 30, FALSE, 150.0, 20.0);
    if(bPC)
    {
        jRow = CreateLabel(jRow, "Player", "player_lbl", 45.0f, 20.0f, -1.0, NUI_HALIGN_LEFT);
        jRow = CreateLabel(jRow, "", "player_value", 139.0f, 20.0f, -1.0, NUI_HALIGN_LEFT, NUI_VALIGN_MIDDLE, "player_tooltip");
    }
    // Show CR for npc's.
    else
    {
        jRow = CreateLabel(jRow, " Challenge Rating:", "cr_lbl", 130.0f, 20.0f, -1.0, NUI_HALIGN_LEFT);
        jRow = CreateLabel(jRow, "", "cr_value", 44.0f, 20.0f, -1.0, NUI_HALIGN_LEFT);
    }
    // Add the row to the column.
    jCol = JsonArrayInsert(jCol, NuiRow (jRow));
    // Row 3 (Portrait Name)**************************************************** 106
    jRow = CreateTextEditBox(JsonArray(), "port_placeholder", "port_name", 20, FALSE, 150.0, 20.0, "port_tooltip");
    jRow = CreateLabel(jRow, "Deity", "deity_lbl", 40.0f, 20.0f, -1.0, NUI_HALIGN_LEFT);
    jRow = CreateTextEditBox(jRow, "place_holder", "deity_box", 25, FALSE, 144.0, 20.0f);
    // Add the row to the column.
    jCol = JsonArrayInsert (jCol, NuiRow (jRow));
    // Row 4 (Race line)******************************************************** 134
    json jPos = NuiRect(0.0, 0.0, 128.0, 200.0);
    json jLabel = NuiLabel(JsonString(""), JsonInt(0), JsonInt(0));
    jLabel = NuiHeight(NuiWidth(jLabel, 128.0), 10.0);
    // Create image to the left of the window.
    json jImage = JsonArrayInsert(JsonArray (), NuiDrawListImage (JsonBool(TRUE), NuiBind("port_resref_image"), jPos, JsonInt(NUI_ASPECT_EXACTSCALED), JsonInt(NUI_HALIGN_LEFT), JsonInt (NUI_VALIGN_TOP)));
    jRow = JsonArrayInsert(JsonArray(), NuiDrawList (jLabel, JsonBool(FALSE), jImage));
    jRow = CreateLabel(jRow, "", "race", 180.0f, 10.0f, -1.0, NUI_HALIGN_LEFT);
    jRow = CreateLabel(jRow, "", "align", 26.0f, 10.0f, -1.0, NUI_HALIGN_LEFT, NUI_VALIGN_MIDDLE, "align_tooltip");
    // Add the row to the column.
    jCol = JsonArrayInsert(jCol, NuiRow (jRow));
    // Row 5 (Class1 line)****************************************************** 152
    jRow = CreateLabel(JsonArray(), "", "blk_lbl", 128.0f, 10.0f);
    jRow = CreateLabel(jRow, "", "class1", 105.0f, 10.0f, -1.0, NUI_HALIGN_LEFT, NUI_VALIGN_MIDDLE, "class1_tooltip");
    jRow = CreateLabel(jRow, "", "class4", 105.0f, 10.0f, -1.0, NUI_HALIGN_LEFT, NUI_VALIGN_MIDDLE, "class4_tooltip");
    // Add the row to the column.
    jCol = JsonArrayInsert (jCol, NuiRow (jRow));
    // Row 6 (Class2 line)****************************************************** 170
    jRow = CreateLabel(JsonArray(), "", "blk_lbl", 128.0f, 10.0f);
    jRow = CreateLabel(jRow, "", "class2", 105.0f, 10.0f, -1.0, NUI_HALIGN_LEFT, NUI_VALIGN_MIDDLE, "class2_tooltip");
    jRow = CreateLabel(jRow, "", "class5", 105.0f, 10.0f, -1.0, NUI_HALIGN_LEFT, NUI_VALIGN_MIDDLE, "class5_tooltip");
    // Add the row to the column.
    jCol = JsonArrayInsert (jCol, NuiRow (jRow));
    // Row 7 (Class3 line)****************************************************** 188
    jRow = CreateLabel(JsonArray(), "", "blk_lbl", 128.0f, 10.0f);
    jRow = CreateLabel(jRow, "", "class3", 105.0f, 10.0f, -1.0, NUI_HALIGN_LEFT, NUI_VALIGN_MIDDLE, "class3_tooltip");
    jRow = CreateLabel(jRow, "", "class6", 105.0f, 10.0f, -1.0, NUI_HALIGN_LEFT, NUI_VALIGN_MIDDLE, "class6_tooltip");
    // Add the row to the column.
    jCol = JsonArrayInsert (jCol, NuiRow (jRow));
    // Row 8 (Str line)********************************************************* 206
    jRow = CreateLabel(JsonArray(), "", "blk_lbl", 128.0f, 10.0f);
    jRow = CreateLabel(jRow, "Strength", "str_lbl", 94.0f, 16.0f, -1.0, NUI_HALIGN_LEFT);
    jRow = CreateImage(jRow, "gui_chrsht_str", "str_img", NUI_ASPECT_EXACTSCALED, NUI_HALIGN_CENTER, NUI_VALIGN_MIDDLE, 16.0f, 16.0f);
    jRow = CreateLabel(jRow, "", "0_value", 20.0f, 16.0f);
    jRow = CreateLabel(jRow, "", "0_mod", 20.0f, 16.0f);
    jRow = CreateButtonImage(jRow, "nui_cnt_up", "btn_up_str", 20.0, 16.0);
    jRow = CreateButtonImage(jRow, "nui_cnt_down", "btn_down_str", 20.0, 16.0);
    // Add the row to the column.
    jCol = JsonArrayInsert (jCol, NuiRow (jRow));
    // Row 9 (Dex line)********************************************************* 230
    jRow = CreateLabel(JsonArray(), "", "blk_lbl", 128.0f, 10.0f);
    jRow = CreateLabel(jRow, "Dexterity", "dex_lbl", 94.0f, 16.0f, -1.0, NUI_HALIGN_LEFT);
    jRow = CreateImage(jRow, "gui_chrsht_dex", "str_img", NUI_ASPECT_EXACTSCALED, NUI_HALIGN_CENTER, NUI_VALIGN_MIDDLE, 16.0f, 16.0f);
    jRow = CreateLabel(jRow, "", "1_value", 20.0f, 16.0f);
    jRow = CreateLabel(jRow, "", "1_mod", 20.0f, 16.0f);
    jRow = CreateButtonImage(jRow, "nui_cnt_up", "btn_up_dex", 20.0, 16.0);
    jRow = CreateButtonImage(jRow, "nui_cnt_down", "btn_down_dex", 20.0, 16.0);
    // Add the row to the column.
    jCol = JsonArrayInsert (jCol, NuiRow (jRow));
    // Row 10 (Con line)******************************************************** 254
    jRow = CreateLabel(JsonArray(), "", "blk_lbl", 128.0f, 10.0f);
    jRow = CreateLabel(jRow, "Constitution", "con_lbl", 94.0f, 16.0f, -1.0, NUI_HALIGN_LEFT);
    jRow = CreateImage(jRow, "gui_chrsht_con", "con_img", NUI_ASPECT_EXACTSCALED, NUI_HALIGN_CENTER, NUI_VALIGN_MIDDLE, 16.0f, 16.0f);
    jRow = CreateLabel(jRow, "", "2_value", 20.0f, 16.0f);
    jRow = CreateLabel(jRow, "", "2_mod", 20.0f, 16.0f);
    jRow = CreateButtonImage(jRow, "nui_cnt_up", "btn_up_con", 20.0, 16.0);
    jRow = CreateButtonImage(jRow, "nui_cnt_down", "btn_down_con", 20.0, 16.0);
    // Add the row to the column.
    jCol = JsonArrayInsert (jCol, NuiRow (jRow));
    // Row 11 (Int line)******************************************************** 278
    jRow = CreateLabel(JsonArray(), "", "blk_lbl", 128.0f, 10.0f);
    jRow = CreateLabel(jRow, "Intelligence", "int_lbl", 94.0f, 16.0f, -1.0, NUI_HALIGN_LEFT);
    jRow = CreateImage(jRow, "gui_chrsht_int", "int_img", NUI_ASPECT_EXACTSCALED, NUI_HALIGN_CENTER, NUI_VALIGN_MIDDLE, 16.0f, 16.0f);
    jRow = CreateLabel(jRow, "", "3_value", 20.0f, 16.0f);
    jRow = CreateLabel(jRow, "", "3_mod", 20.0f, 16.0f);
    jRow = CreateButtonImage(jRow, "nui_cnt_up", "btn_up_int", 20.0, 16.0);
    jRow = CreateButtonImage(jRow, "nui_cnt_down", "btn_down_int", 20.0, 16.0);
    // Add the row to the column.
    jCol = JsonArrayInsert (jCol, NuiRow (jRow));
    // Row 12 (Wis line)******************************************************** 302
    jRow = CreateLabel(JsonArray(), "", "blk_lbl", 128.0f, 10.0f);
    jRow = CreateLabel(jRow, "Wisdom", "wis_lbl", 94.0f, 16.0f, -1.0, NUI_HALIGN_LEFT);
    jRow = CreateImage(jRow, "gui_chrsht_wis", "wis_img", NUI_ASPECT_EXACTSCALED, NUI_HALIGN_CENTER, NUI_VALIGN_MIDDLE, 16.0f, 16.0f);
    jRow = CreateLabel(jRow, "", "4_value", 20.0f, 16.0f);
    jRow = CreateLabel(jRow, "", "4_mod", 20.0f, 16.0f);
    jRow = CreateButtonImage(jRow, "nui_cnt_up", "btn_up_wis", 20.0, 16.0);
    jRow = CreateButtonImage(jRow, "nui_cnt_down", "btn_down_wis", 20.0, 16.0);
    // Add the row to the column.
    jCol = JsonArrayInsert (jCol, NuiRow (jRow));
    // Row 13 (Cha line)******************************************************** 326
    jRow = CreateButton(JsonArray(), "<", "btn_portrait_prev", 32.0f, 16.0f);
    jRow = CreateLabel(jRow, "", "port_id", 58.0, 16.0f);
    jRow = CreateButton(jRow, ">", "btn_portrait_next", 32.0f, 16.0f);
    jRow = CreateLabel(jRow, "Charisma", "cha_lbl", 94.0f, 16.0f, -1.0, NUI_HALIGN_LEFT);
    jRow = CreateImage(jRow, "gui_chrsht_cha", "cha_img", NUI_ASPECT_EXACTSCALED, NUI_HALIGN_CENTER, NUI_VALIGN_MIDDLE, 16.0f, 16.0f);
    jRow = CreateLabel(jRow, "", "5_value", 20.0f, 16.0f);
    jRow = CreateLabel(jRow, "", "5_mod", 20.0f, 16.0f);
    jRow = CreateButtonImage (jRow, "nui_cnt_up", "btn_up_cha", 20.0, 16.0);
    jRow = CreateButtonImage (jRow, "nui_cnt_down", "btn_down_cha", 20.0, 16.0);
    // Add the row to the column.
    jCol = JsonArrayInsert(jCol, NuiRow(jRow));
    // Row 14 (Description)***************************************************** 350
    jRow = CreateTextEditBox(JsonArray(), "desc_placeholder", "desc_value", 1000, TRUE, 342.0, 150.0, "desc_tooltip");
    // Add the row to the column.
    jCol = JsonArrayInsert(jCol, NuiRow(jRow));
    // Row 15 (Fort/AC/Fame)**************************************************** 508
    jRow = CreateLabel(JsonArray(), "Fortitude", "fort_lbl", 60.0f, 10.0f, -1.0, NUI_HALIGN_LEFT);
    jRow = CreateLabel(jRow, "", "fort_value", 35.0, 10.0f, -1.0, NUI_HALIGN_RIGHT);
    jRow = CreateLabel(jRow, "", "blank_lbl", 10.0f, 10.0f);
    jRow = CreateLabel(jRow, "AC", "ac_lbl", 25.0f, 10.0f, -1.0, NUI_HALIGN_LEFT);
    jRow = CreateLabel(jRow, "", "ac_value", 60.0, 10.0f, -1.0, NUI_HALIGN_RIGHT);
    if(bPC)
    {
        jRow = CreateLabel(jRow, "", "blank_lbl", 10.0f, 10.0f);
        jRow = CreateLabel(jRow, "Fame", "fame_lbl", 45.0f, 10.0f, -1.0, NUI_HALIGN_LEFT);
        jRow = CreateLabel(jRow, "", "fame_value", 60.0, 10.0f, -1.0, NUI_HALIGN_RIGHT, NUI_VALIGN_MIDDLE, "fame_tooltip");
    }
    // Add the row to the column.
    jCol = JsonArrayInsert(jCol, NuiRow(jRow));
    // Row 16 (Reflex/HP/Infamy)************************************************ 526
    jRow = CreateLabel(JsonArray(), "Reflex", "refl_lbl", 60.0f, 10.0f, -1.0, NUI_HALIGN_LEFT);
    jRow = CreateLabel(jRow, "", "refl_value", 35.0, 10.0f, -1.0, NUI_HALIGN_RIGHT);
    jRow = CreateLabel(jRow, "", "blank_lbl", 10.0f, 10.0f);
    jRow = CreateLabel(jRow, "HP", "hp_lbl", 25.0f, 10.0f, -1.0, NUI_HALIGN_LEFT);
    jRow = CreateLabel(jRow, "", "hp_value", 60.0, 10.0f, -1.0, NUI_HALIGN_RIGHT, NUI_VALIGN_MIDDLE, "hp_tooltip");
    if (bPC)
    {
        jRow = CreateLabel(jRow, "", "blank_lbl", 10.0f, 10.0f);
        jRow = CreateLabel(jRow, "Infamy", "infamy_lbl", 45.0f, 10.0f, -1.0, NUI_HALIGN_LEFT);
        jRow = CreateLabel(jRow, "", "infamy_value", 60.0, 10.0f, -1.0, NUI_HALIGN_RIGHT, NUI_VALIGN_MIDDLE, "infamy_tooltip");
    }
    // Add the row to the column.
    jCol = JsonArrayInsert(jCol, NuiRow(jRow));
    // Row 17 (Will/Age)******************************************************** 544
    jRow = CreateLabel(JsonArray(), "Will", "will_lbl", 60.0f, 10.0f, -1.0, NUI_HALIGN_LEFT);
    jRow = CreateLabel(jRow, "", "will_value", 35.0, 10.0f, -1.0, NUI_HALIGN_RIGHT);
    if(bPC)
    {
        jRow = CreateLabel(jRow, "", "blank_lbl", 10.0f, 10.0f);
        jRow = CreateLabel(jRow, "Age", "age_lbl", 25.0f, 10.0f, -1.0, NUI_HALIGN_LEFT);
        jRow = CreateLabel(jRow, "", "age_value", 60.0f, 10.0f, -1.0, NUI_HALIGN_RIGHT);
        // Add the row to the column.
        jCol = JsonArrayInsert(jCol, NuiRow(jRow));
        // Row (Experience)***************************************************** 562
        jRow = CreateLabel(JsonArray(), "Racial XP", "racial_xp_lbl", 65.0f, 10.0f, -1.0, NUI_HALIGN_LEFT);
        jRow = CreateLabel(jRow, "", "racial_xp_value", 30.0, 10.0f, -1.0, NUI_HALIGN_RIGHT, NUI_VALIGN_MIDDLE, "racial_xp_tooltip");
        jRow = CreateLabel(jRow, "", "blank_lbl", 10.0f, 10.0f);
        jRow = CreateLabel(jRow, "XP", "xp_lbl", 25.0f, 10.0f, -1.0, NUI_HALIGN_LEFT);
        jRow = CreateLabel(jRow, "", "xp_value", 60.0, 10.0f, -1.0, NUI_HALIGN_RIGHT, NUI_VALIGN_MIDDLE, "xp_tooltip");
        jRow = CreateLabel(jRow, "", "blank_lbl", 10.0f, 10.0f);
        jRow = CreateLabel(jRow, "Next", "nxtlvl_lbl", 45.0f, 10.0f, -1.0, NUI_HALIGN_LEFT);
        jRow = CreateLabel(jRow, "", "nxtlvl_value", 60.0, 10.0f, -1.0,NUI_HALIGN_RIGHT);
        // Add the row to the column.
        jCol = JsonArrayInsert(jCol, NuiRow(jRow));
        fHeight += 18.0f;
    }
    else jCol = JsonArrayInsert(jCol, NuiRow(jRow));
    // Row 18 (Gold pieces/Wealth*********************************************** 562
    jRow = CreateLabel(JsonArray(), "GP", "gold_lbl", 25.0f, 10.0f, -1.0, NUI_HALIGN_LEFT);
    jRow = CreateLabel(jRow, "", "gold_value", 70.0, 10.0f, -1.0, NUI_HALIGN_RIGHT, NUI_VALIGN_MIDDLE, "gold_tooltip");
    jRow = CreateLabel(jRow, "", "blank_lbl", 10.0f, 10.0f);
    jRow = CreateLabel(jRow, "Wealth lvl", "wealth_lvl_lbl", 65.0f, 10.0f, -1.0, NUI_HALIGN_LEFT);
    jRow = CreateLabel(jRow, "", "wealth_lvl_value", 20.0, 10.0f, -1.0, NUI_HALIGN_RIGHT, NUI_VALIGN_MIDDLE, "wealth_lvl_tooltip");
    jRow = CreateLabel(jRow, "", "blank_lbl", 10.0f, 10.0f);
    jRow = CreateLabel(jRow, "Wealth", "wealth_lbl", 45.0f, 10.0f, -1.0, NUI_HALIGN_LEFT);
    jRow = CreateLabel(jRow, "", "wealth_value", 60.0, 10.0f, -1.0, NUI_HALIGN_RIGHT, NUI_VALIGN_MIDDLE, "wealth_tooltip");
    // Add the row to the column.
    jCol = JsonArrayInsert(jCol, NuiRow(jRow));
    if(!bPC)
    {
        // Row (Experience)***************************************************** 580
        jRow = CreateLabel(JsonArray(), "Faction Current:", "c_faction_lbl", 110.0f, 10.0f, -1.0, NUI_HALIGN_RIGHT);
        jRow = CreateLabel(jRow, "", "c_faction_value", 75.0, 10.0f, -1.0, NUI_HALIGN_LEFT, NUI_VALIGN_MIDDLE, "c_faction_tooltip");
        jRow = CreateLabel(jRow, "Permanent:", "p_faction_lbl", 70.0f, 10.0f, -1.0, NUI_HALIGN_RIGHT);
        jRow = CreateLabel(jRow, "", "p_faction_value", 75.0, 10.0f, -1.0, NUI_HALIGN_LEFT, NUI_VALIGN_MIDDLE, "p_faction_tooltip");
        // Add the row to the column.
        jCol = JsonArrayInsert(jCol, NuiRow(jRow));
        fHeight += 18.0f;
    }
    // Row 19 (buttons)********************************************************* 598
    jRow = JsonArrayInsert(JsonArray(), NuiSpacer());
    jRow = CreateButton(jRow, "Variables", "btn_variables", 70.0, 25.0);
    jRow = JsonArrayInsert(jRow, NuiSpacer());
    if(bPC)
    {
        jRow = CreateButton(jRow, "Quests", "btn_quest", 100.0f, 25.0f);
        jRow = JsonArrayInsert(jRow, NuiSpacer());
        jRow = CreateButton(jRow, "Map Area", "btn_map_area", 85.0f, 25.0f);
        jRow = JsonArrayInsert(jRow, NuiSpacer());
    }
    else
    {
        if(GetIsPC(GetMaster(oTarget)))
        {
            jRow = CreateButton(jRow, "Remove Associate", "btn_assoc", 140.0f, 25.0f);
            jRow = JsonArrayInsert(jRow, NuiSpacer());
        }
        else
        {
            jRow = CreateButton(jRow, "Add Henchmen", "btn_hench", 140.0f, 25.0f);
            jRow = JsonArrayInsert(jRow, NuiSpacer());
        }
    }
    jRow = CreateButton(jRow, "Inventory", "btn_inventory", 75.0, 25.0, -1.0);
    jRow = JsonArrayInsert (jRow, NuiSpacer());
    // Add row to the column.
    jCol = JsonArrayInsert(jCol, NuiRow(jRow));
    if(bPC)
    {
        jRow = CreateButton(JsonArray(), "Reset", "btn_reset", 100.0f, 25.0f, -1.0, "btn_reset_tooltip");
        jRow = CreateButton(jRow, "Database", "btn_database", 100.0f, 25.0f, -1.0, "btn_database_tooltip");
        jRow = JsonArrayInsert(jRow, NuiSpacer());
        // Add row to the column.
        jCol = JsonArrayInsert(jCol, NuiRow(jRow));
        fHeight += 28.0;
    }
    // Get the window location to restore it from the database.
    string sPCWindow = GetServerDatabaseString(oPC, PLAYER_TABLE, "dmcreaturewin");
    float fX = StringToFloat(GetStringArray(sPCWindow, 1));
    float fY = StringToFloat(GetStringArray(sPCWindow, 2));
    // Set the Layout of the window.
    json jLayout = NuiCol(jCol);
    string sName = StripColorCodes(GetName (oTarget));
    int nToken = SetWindow(oPC, jLayout, "dmcreaturewin", "Character Record, " + sName,
                            fX, fY, 366.0, fHeight, FALSE, FALSE, TRUE, FALSE, TRUE);
    // Setup watch so we can save this windows position to the database.
    NuiSetBindWatch(oPC, nToken, "window_geometry", TRUE);
    // Set all binds, events, and watches.
    sName = GetName(oTarget);
    // Set character sheet tabs.
    NuiSetBind(oPC, nToken, "btn_char_sheet_event", JsonBool(TRUE));
    NuiSetBind(oPC, nToken, "char_sht_tooltip", JsonString("  Character Sheet"));
    NuiSetBind(oPC, nToken, "btn_skill_sheet_event", JsonBool (TRUE));
    NuiSetBind(oPC, nToken, "skill_sht_tooltip", JsonString("  Skills"));
    NuiSetBind(oPC, nToken, "btn_feat_sheet_event", JsonBool (TRUE));
    NuiSetBind(oPC, nToken, "feat_sht_tooltip", JsonString("  Feats"));
    // Set Race.
    NuiSetBind(oPC, nToken, "race_label", JsonString(GetRaceText(oTarget)));
    // Set Alignment.
    NuiSetBind(oPC, nToken, "align_label", JsonString(GetAlignText (oTarget)));
    NuiSetBind(oPC, nToken, "align_tooltip", JsonString("  Click to change alignment!"));
    // Set Class and levels.
    NuiSetBind(oPC, nToken, "class1_label", JsonString(GetClassText (oTarget, 1)));
    NuiSetBind(oPC, nToken, "class2_label", JsonString(GetClassText (oTarget, 2)));
    NuiSetBind(oPC, nToken, "class3_label", JsonString(GetClassText (oTarget, 3)));
    NuiSetBind(oPC, nToken, "class4_label", JsonString(GetClassText (oTarget, 4)));
    NuiSetBind(oPC, nToken, "class5_label", JsonString(GetClassText (oTarget, 5)));
    //NuiSetBind (oPC, nToken, "class6_label", JsonString (GetClassText (oTarget, 6)));
    if (!bPC)
    {
        NuiSetBind(oPC, nToken, "class1_tooltip", JsonString("  Click to change class levels!"));
        NuiSetBind(oPC, nToken, "class2_tooltip", JsonString("  Click to change class levels!"));
        NuiSetBind(oPC, nToken, "class3_tooltip", JsonString("  Click to change class levels!"));
        NuiSetBind(oPC, nToken, "class4_tooltip", JsonString("  Click to change class levels!"));
        NuiSetBind(oPC, nToken, "class5_tooltip", JsonString("  Click to change class levels!"));
        NuiSetBind(oPC, nToken, "class6_tooltip", JsonString("  Click to change class levels!"));
        // Current Faction
        int nFaction = GetLocalInt(oTarget, "0_CurrentFaction");
        string sFaction = GetFactionName (nFaction);
        NuiSetBind(oPC, nToken, "c_faction_value_label", JsonString(sFaction));
        NuiSetBind(oPC, nToken, "c_faction_tooltip", JsonString("  Click to change factions!"));
        // Permanent Faction
        nFaction = GetLocalInt(oTarget, "0_PermanentFaction");
        sFaction = GetFactionName(nFaction);
        NuiSetBind(oPC, nToken, "p_faction_value_label", JsonString(sFaction));
        NuiSetBind(oPC, nToken, "p_faction_tooltip", JsonString("  Click to change factions!"));
    }
    // Armor Class
    NuiSetBind(oPC, nToken, "ac_value_label", JsonString(IntToString (GetAC (oTarget))));
    // Hitpoints
    string sHp = IntToString(GetCurrentHitPoints(oTarget));
    sHp = sHp + "/" + IntToString (GetMaxHitPoints(oTarget));
    NuiSetBind(oPC, nToken, "hp_value_label", JsonString(sHp));
    NuiSetBind(oPC, nToken, "hp_tooltip", JsonString("  Click to change hitpoints!"));
    // Strength
    NuiSetBind(oPC, nToken, "0_value_label", JsonString(IntToString(GetAbilityScore(oTarget, ABILITY_STRENGTH))));
    NuiSetBind(oPC, nToken, "0_mod_label", JsonString(IntToString(GetAbilityModifier(ABILITY_STRENGTH, oTarget))));
    NuiSetBind(oPC, nToken, "btn_up_str_event", JsonBool(TRUE));
    NuiSetBind(oPC, nToken, "btn_down_str_event", JsonBool(TRUE));
    NuiSetBind(oPC, nToken, "str_img_event", JsonBool(TRUE));
    // Dexterity
    NuiSetBind(oPC, nToken, "1_value_label", JsonString(IntToString(GetAbilityScore(oTarget, ABILITY_DEXTERITY))));
    NuiSetBind(oPC, nToken, "1_mod_label", JsonString(IntToString(GetAbilityModifier(ABILITY_DEXTERITY, oTarget))));
    NuiSetBind(oPC, nToken, "btn_up_dex_event", JsonBool(TRUE));
    NuiSetBind(oPC, nToken, "btn_down_dex_event", JsonBool(TRUE));
    NuiSetBind(oPC, nToken, "dex_img_event", JsonBool(TRUE));
    // Constitution
    NuiSetBind(oPC, nToken, "2_value_label", JsonString(IntToString(GetAbilityScore(oTarget, ABILITY_CONSTITUTION))));
    NuiSetBind(oPC, nToken, "2_mod_label", JsonString(IntToString(GetAbilityModifier(ABILITY_CONSTITUTION, oTarget))));
    NuiSetBind(oPC, nToken, "btn_up_con_event", JsonBool(TRUE));
    NuiSetBind(oPC, nToken, "btn_down_con_event", JsonBool(TRUE));
    NuiSetBind(oPC, nToken, "con_img_event", JsonBool(TRUE));
    // Intelligence
    NuiSetBind(oPC, nToken, "3_value_label", JsonString(IntToString(GetAbilityScore(oTarget, ABILITY_INTELLIGENCE))));
    NuiSetBind(oPC, nToken, "3_mod_label", JsonString(IntToString(GetAbilityModifier(ABILITY_INTELLIGENCE, oTarget))));
    NuiSetBind(oPC, nToken, "btn_up_int_event", JsonBool(TRUE));
    NuiSetBind(oPC, nToken, "btn_down_int_event", JsonBool(TRUE));
    NuiSetBind(oPC, nToken, "int_img_event", JsonBool(TRUE));
    // Wisdom
    NuiSetBind (oPC, nToken, "4_value_label", JsonString(IntToString(GetAbilityScore (oTarget, ABILITY_WISDOM))));
    NuiSetBind (oPC, nToken, "4_mod_label", JsonString(IntToString(GetAbilityModifier (ABILITY_WISDOM, oTarget))));
    NuiSetBind (oPC, nToken, "btn_up_wis_event", JsonBool(TRUE));
    NuiSetBind (oPC, nToken, "btn_down_wis_event", JsonBool(TRUE));
    NuiSetBind (oPC, nToken, "wis_img_event", JsonBool(TRUE));
    // Charisma
    NuiSetBind (oPC, nToken, "5_value_label", JsonString(IntToString(GetAbilityScore (oTarget, ABILITY_CHARISMA))));
    NuiSetBind (oPC, nToken, "5_mod_label", JsonString(IntToString(GetAbilityModifier (ABILITY_CHARISMA, oTarget))));
    NuiSetBind (oPC, nToken, "btn_up_cha_event", JsonBool(TRUE));
    NuiSetBind (oPC, nToken, "btn_down_cha_event", JsonBool(TRUE));
    NuiSetBind (oPC, nToken, "cha_img_event", JsonBool(TRUE));
    // Saves
    NuiSetBind(oPC, nToken, "fort_value_label", JsonString(IntToString(GetFortitudeSavingThrow(oTarget))));
    NuiSetBind(oPC, nToken, "refl_value_label", JsonString(IntToString(GetReflexSavingThrow(oTarget))));
    NuiSetBind(oPC, nToken, "will_value_label", JsonString(IntToString(GetWillSavingThrow(oTarget))));
    // Name
    NuiSetBindWatch(oPC, nToken, "char_name", TRUE);
    NuiSetBind(oPC, nToken, "char_name", JsonString (sName));
    // Portrait
    int nID = GetPortraitId(oTarget);
    NuiSetUserData(oPC, nToken, JsonInt(nID));
    string sValue = GetPortraitResRef(oTarget);
    string sID;
    if (nID == 65535) sID = "Custom Portrait";
    else sID = IntToString(nID);
    NuiSetBindWatch(oPC, nToken, "port_name", TRUE);
    NuiSetBind(oPC, nToken, "port_name", JsonString(sValue));
    NuiSetBind(oPC, nToken, "port_id_label", JsonString(sID));
    NuiSetBind(oPC, nToken, "port_resref_event", JsonBool(TRUE));
    NuiSetBind(oPC, nToken, "port_resref_image", JsonString (sValue + "l"));
    NuiSetBind(oPC, nToken, "port_tooltip", JsonString ("  You may also type the portrait file name."));
    NuiSetBind(oPC, nToken, "btn_portrait_prev_event", JsonBool(TRUE));
    NuiSetBind(oPC, nToken, "btn_portrait_next_event", JsonBool(TRUE));
    // Special buttons - Quests, Associates.
    if(bPC)
    {
        // Player name.
        NuiSetBind(oPC, nToken, "player_value_label", JsonString (GetPCPlayerName (oTarget)));
        NuiSetBind(oPC, nToken, "player_tooltip", JsonString ("  Click to see player options!"));
        // Age
        NuiSetBind (oPC, nToken, "age_value_label", JsonString (IntToString (GetAge (oTarget))));
        // Fame
        sValue = IntToString(GetCharacterReputation(oTarget));
        NuiSetBind(oPC, nToken, "fame_value_label", JsonString(sValue));
        NuiSetBind(oPC, nToken, "fame_tooltip", JsonString("  Click to change fame!"));
        // Infamy
        sValue = IntToString(GetCharacterReputation(oTarget, FALSE));
        NuiSetBind(oPC, nToken, "infamy_value_label", JsonString(sValue));
        NuiSetBind(oPC, nToken, "infamy_tooltip", JsonString("  Click to change infamy!"));
        // Racial experience
        sValue = FloatToString(GetLocalFloat(oTarget, "0_RacialXP"), 0, 0);
        NuiSetBind(oPC, nToken, "racial_xp_value_label", JsonString(sValue));
        NuiSetBind(oPC, nToken, "racial_xp_tooltip", JsonString("  Click to change racial experience!"));
        // Experience
        sValue = IntToString(GetXP(oTarget));
        NuiSetBind(oPC, nToken, "xp_value_label", JsonString(sValue));
        NuiSetBind(oPC, nToken, "xp_tooltip", JsonString("  Click to change experience!"));
        // Next level
        sValue = IntToString (GetXpForNextLevel(GetCharacterLevels(oTarget)));
        NuiSetBind(oPC, nToken, "nxtlvl_value_label", JsonString(sValue));
        // Main quest button
        NuiSetBind(oPC, nToken, "btn_quest_event", JsonBool(TRUE));
        // Map area button
        NuiSetBind(oPC, nToken, "btn_map_area_event", JsonBool(TRUE));
        // Reset a players factions.
        NuiSetBind(oPC, nToken, "btn_reset_event", JsonBool(TRUE));
        NuiSetBind(oPC, nToken, "btn_reset_tooltip", JsonString("  Resets factions and clears last rest time."));
        // Open the players database information.
        NuiSetBind(oPC, nToken, "btn_database_event", JsonBool(TRUE));
        NuiSetBind(oPC, nToken, "btn_database_tooltip", JsonString("  Opens player database for adjusting."));
    }
    else
    {
        if(GetIsPC(GetMaster(oTarget)))
        {
            NuiSetBind(oPC, nToken, "btn_assoc_event", JsonBool(TRUE));
        }
        else NuiSetBind(oPC, nToken, "btn_hench_event", JsonBool(TRUE));
        // Challenge rating.
        NuiSetBind (oPC, nToken, "cr_value_label", JsonString(FloatToString(GetChallengeRating(oTarget), 0,0)));
    }
    NuiSetBind(oPC, nToken, "btn_inventory_event", JsonBool (TRUE));
    // Diety
    NuiSetBindWatch(oPC, nToken, "deity_box", TRUE);
    sValue = GetDeity(oTarget);
    if(sValue == "") sValue = "None";
    NuiSetBind(oPC, nToken, "deity_box", JsonString(sValue));
    // Gold
    sValue = IntToString (GetGold (oTarget));
    NuiSetBind(oPC, nToken, "gold_value_label", JsonString(sValue));
    NuiSetBind(oPC, nToken, "gold_tooltip", JsonString("  Click to change gold!"));
    // Wealth
    int nValue = GetWealth(oTarget);
    NuiSetBind(oPC, nToken, "wealth_value_label", JsonString(IntToString(nValue)));
    NuiSetBind(oPC, nToken, "wealth_tooltip", JsonString("  Click to see item gold values!"));
    // Wealth Level
    nValue = GetWealthByLevel (nValue);
    NuiSetBind(oPC, nToken, "wealth_lvl_value_label", JsonString (IntToString (nValue)));
    // Set how good they wealth value is.
    sValue = GetWealthByLevelEvaluation (nValue, oTarget);
    NuiSetBind(oPC, nToken, "wealth_lvl_tooltip", JsonString("  " + sValue));
    // Description
    NuiSetBindWatch(oPC, nToken, "desc_value", TRUE);
    NuiSetBind(oPC, nToken, "desc_tooltip", JsonString("  Color codes can be used!"));
    sValue = GetDescription (oTarget);
    NuiSetBind(oPC, nToken, "desc_value", JsonString(sValue));
    // Other
    NuiSetBind(oPC, nToken, "btn_variables_event", JsonBool(TRUE));
}

void PopUpQuestsGUIPanel (object oPC)
{
    // Get the DM target.
    object oTarget = GetLocalObject (oPC, "0_DM_Target");
    // Set window to not save until it has been created.
    SetLocalInt (oPC, "0_No_Win_Save", TRUE);
    DelayCommand (0.5f, DeleteLocalInt (oPC, "0_No_Win_Save"));
    // Create the column.
    // Row 1 (combo box)******************************************************** 45
    // Insert elements into the combo box array.
    json jCombo = JsonArrayInsert (JsonArray (), NuiComboEntry ("Story Quests", 0));
    jCombo = JsonArrayInsert (jCombo, NuiComboEntry ("Quests", 1));
    jCombo = JsonArrayInsert (jCombo, NuiComboEntry ("Side Quests", 2));
    json jRow = JsonArrayInsert (JsonArray (), NuiSpacer());
    jRow = CreateCombo (jRow, jCombo, "quest_type", 300.0, 25.0);
    jRow = JsonArrayInsert(jRow, NuiSpacer());
    // Add the row to the column.
    json jCol = JsonArrayInsert (JsonArray (), NuiRow (jRow));
    // Row 2 (Combo box)******************************************************** 78
    jRow = JsonArrayInsert (JsonArray (), NuiSpacer());
    int nCount = 0, nRow = 1;
    int nQuestType = GetLocalInt(oTarget, "0_Menu_Quest_type");
    string sQuestName, s2daQuestColumn, sText;
    float fHeight = 78.0;
    if(nQuestType < 2)
    {
        if(nQuestType == 0) s2daQuestColumn = "Story_Quest";
        else if(nQuestType == 1) s2daQuestColumn = "Quest";
        sQuestName = Get2DAString ("quest_list", s2daQuestColumn + "_Name", nRow);
        string sOldQuestName = sQuestName;
        jCombo = JsonArray ();
        while (sQuestName != "")
        {
            // Sets up the quest names for each quest.
            if (sOldQuestName != sQuestName)
            {
                sOldQuestName = sQuestName;
                nCount = 1;
            }
            else nCount ++;
            if (nQuestType == 0) sText = " Part " + IntToString (nCount);
            else sText = "";
            jCombo = JsonArrayInsert (jCombo, NuiComboEntry (sQuestName + sText, nRow));
            sQuestName = Get2DAString ("quest_list", s2daQuestColumn + "_Name", ++nRow);
        }
        jRow = CreateCombo (jRow, jCombo, "menu_quest", 300.0, 25.0);
        jRow = JsonArrayInsert (jRow, NuiSpacer ());
        // Add row to the column.
        jCol = JsonArrayInsert (jCol, NuiRow (jRow));
        fHeight += 33.0;
    }
    else
    {
        s2daQuestColumn = "Side_Quest";

        fHeight += 100.0;
    }
    // Row 3 (Quest description label)****************************************** 111
    jRow = CreateLabel (JsonArray (), "", "menu_quest_desc", 400.0f, 10.0f);
    // Add the row to the column.
    jCol = JsonArrayInsert (jCol, NuiRow (jRow));
    // Row 4 (Button set)******************************************************* 129
    jRow = JsonArrayInsert (JsonArray (), NuiSpacer ());
    jRow = CreateLabel (jRow, "Main Quests", "mquest_lbl", 100.0f, 25.0f, -1.0, NUI_HALIGN_RIGHT);
    jRow = CreateTextEditBox (jRow, "name_placeholder", "mquests_done", 30, FALSE, 40.0, 25.0);
    jRow = JsonArrayInsert(jRow, NuiSpacer());
    jRow = JsonArrayInsert (jRow, NuiSpacer ());
    jRow = CreateLabel (jRow, "Side Quests", "squest_lbl", 100.0f, 25.0f, -1.0, NUI_HALIGN_RIGHT);
    jRow = CreateTextEditBox (jRow, "name_placeholder", "squests_done", 30, FALSE, 40.0, 25.0);
    jRow = JsonArrayInsert(jRow, NuiSpacer());
    // Add the row to the column.
    jCol = JsonArrayInsert (jCol, NuiRow (jRow));
    // Row 5 (Button set)******************************************************* 162
    jRow = CreateButtonSelect (JsonArray (), "Quest Removed", "btn_quest_clear", 130.0, 25.0);
    jRow = JsonArrayInsert(jRow, NuiSpacer());
    jRow = CreateButtonSelect (jRow, "Set to Part", "btn_quest_set", 130.0, 25.0);
    jRow = JsonArrayInsert(jRow, NuiSpacer());
    jRow = CreateButtonSelect (jRow, "Quest Complete", "btn_quest_complete", 130.0, 25.0);
    jCol = JsonArrayInsert (jCol, NuiRow (jRow));
    fHeight += 84.0;
    // Get the window location to restore it from the database.
    string sPCWindow = GetServerDatabaseString (oPC, PLAYER_TABLE, "dmmainquestswin");
    float fX = StringToFloat (GetStringArray (sPCWindow, 1));
    float fY = StringToFloat (GetStringArray (sPCWindow, 2));
    // Set the Layout of the window.
    json jLayout = NuiCol (jCol);
    string sName = StripColorCodes (GetName (oTarget));
    int nToken = SetWindow (oPC, jLayout, "dmmainquestswin", sName + "'s main quest menu",
                            fX, fY, 425.0f, fHeight, FALSE, FALSE, TRUE, FALSE, TRUE);
    // Setup watch so we can save this windows position to the database.
    NuiSetBindWatch (oPC, nToken, "window_geometry", TRUE);
    // Set all binds, events, and watches.
    string sQuest = GetServerDatabaseString (oTarget, PLAYER_TABLE, "dmmainquestswin");
    int nQuest = StringToInt (GetStringArray (sQuest, 0));
    //NuiSetBind (oPC, nToken, "menu_quest_selected", JsonInt (nQuest));
    NuiSetBind (oPC, nToken, "menu_quest_event", JsonBool (TRUE));
    NuiSetBindWatch (oPC, nToken, "menu_quest_selected", TRUE);
    NuiSetBind (oPC, nToken, "quest_type_selected", JsonInt (nQuestType));
    NuiSetBind (oPC, nToken, "quest_type_event", JsonBool (TRUE));
    NuiSetBindWatch (oPC, nToken, "quest_type_selected", TRUE);
    int bQuestSet = FALSE, bQuestComplete = FALSE, bQuestClear = FALSE;
    if(nQuestType < 2)
    {
        // Check the pointer for this quest from the database.
        sQuestName = Get2DAString ("quest_list", s2daQuestColumn + "_Name", nQuest);
    }
    string sQuestDesc = Get2DAString ("quest_list", s2daQuestColumn + "_Desc", nQuest);
    NuiSetBind (oPC, nToken, "menu_quest_desc_label", JsonString (sQuestDesc));
    int nTargetPointer = GetObjectDatabaseInt (oTarget, QUEST_TABLE, "questpointer", sQuestName);
    if (nTargetPointer == 0) bQuestClear = TRUE;
    NuiSetBind (oPC, nToken, "btn_quest_set", JsonBool (bQuestClear));
    if (nTargetPointer > nQuest) bQuestSet = TRUE;
    NuiSetBind (oPC, nToken, "btn_quest_set", JsonBool (bQuestSet));
    if (nTargetPointer == -1) bQuestComplete = TRUE;
    NuiSetBind (oPC, nToken, "btn_quest_complete", JsonBool (bQuestComplete));
    string sQuests = IntToString (GetObjectDatabaseInt (oPC, CHARACTER_TABLE, "mainquests"));
    NuiSetBind (oPC, nToken, "mquests_done", JsonString (sQuests));
    NuiSetBindWatch (oPC, nToken, "mquests_done", TRUE);
    sQuests = IntToString (GetObjectDatabaseInt (oPC, CHARACTER_TABLE, "sidequests"));
    NuiSetBind (oPC, nToken, "squests_done", JsonString (sQuests));
    NuiSetBindWatch (oPC, nToken, "squests_done", TRUE);
    // Set the buttons to show events to 0e_window.
    NuiSetBind (oPC, nToken, "btn_quest_clear_event", JsonBool (TRUE));
    NuiSetBind (oPC, nToken, "btn_quest_set_event", JsonBool (TRUE));
    NuiSetBind (oPC, nToken, "btn_quest_complete_event", JsonBool (TRUE));
}

void PopUpDMXPGUIPanel (object oPC)
{
    // Row 1 (Xp type label)****************************************************
    json jRow = CreateLabel (JsonArray (), "Type of Experience", "xp_opt_title", 130.0f, 10.0f, -1.0, NUI_HALIGN_CENTER);
    jRow = CreateLabel (jRow, "Experience", "xp_amount_title", 90.0f, 10.0f, -1.0, NUI_HALIGN_CENTER);
    jRow = CreateLabel (jRow, "Racial XP", "racial_xp_title", 80.0f, 10.0f, -1.0, NUI_HALIGN_CENTER);
    // Add row to the column.
    json jCol = JsonArrayInsert (JsonArray (), NuiRow (jRow));
    // Row 2 (Type of XP and amount)********************************************
    // Insert elements into the combo box array.
    json jCombo = JsonArrayInsert (JsonArray (), NuiComboEntry ("Bonus/Penalty", 0));
    jCombo = JsonArrayInsert (jCombo, NuiComboEntry ("Roleplay", 1));
    jCombo = JsonArrayInsert (jCombo, NuiComboEntry ("Quest", 2));
    jCombo = JsonArrayInsert (jCombo, NuiComboEntry ("Puzzle", 3));
    jCombo = JsonArrayInsert (jCombo, NuiComboEntry ("Milestone", 4));
    jCombo = JsonArrayInsert (jCombo, NuiComboEntry ("Adventure", 5));
    jRow = CreateCombo (JsonArray (), jCombo, "xp_opt", 130.0, 25.0);
    jRow = CreateTextEditBox (jRow, "name_placeholder", "xp_amount", 30, FALSE, 90.0, 25.0);
    jRow = CreateTextEditBox (jRow, "name_placeholder", "racial_xp_amount", 30, FALSE, 80.0, 25.0);
    // Add the row to the column.
    jCol = JsonArrayInsert (jCol, NuiRow (jRow));
    // Row 3 (Party & % of xp)**************************************************
    jRow = JsonArrayInsert(JsonArray (), NuiSpacer());
    jRow = CreateButtonSelect (jRow, "Party", "btn_party_xp", 72.0, 25.0);
    jRow = JsonArrayInsert(jRow, NuiSpacer());
    jRow = CreateButton (jRow, "Set 1%", "btn_1_xp", 72.0, 25.0);
    jRow = JsonArrayInsert(jRow, NuiSpacer());
    jRow = CreateButton (jRow, "Set 5%", "btn_5_xp", 72.0, 25.0);
    jRow = JsonArrayInsert(jRow, NuiSpacer());
    jRow = CreateButton (jRow, "Set 10%", "btn_10_xp", 72.0, 25.0);
    jRow = JsonArrayInsert(jRow, NuiSpacer());
    // Add the row to the column.
    jCol = JsonArrayInsert (jCol, NuiRow (jRow));
    // Row 4 (Take or Give XP)**************************************************
    jRow = JsonArrayInsert(JsonArray (), NuiSpacer());
    jRow = CreateButton (jRow, "Give", "btn_give_xp", 97.0, 25.0);
    jRow = JsonArrayInsert(jRow, NuiSpacer());
    jRow = CreateButton (jRow, "Take", "btn_take_xp", 97.0, 25.0);
    jRow = JsonArrayInsert(jRow, NuiSpacer());
    jRow = CreateButton (jRow, "Set", "btn_set_xp", 97.0, 25.0);
    jRow = JsonArrayInsert(jRow, NuiSpacer());
    // Add the row to the column.
    jCol = JsonArrayInsert (jCol, NuiRow (jRow));
    // Get the DM target.
    object oTarget = GetLocalObject (oPC, "0_DM_Target");
    // Set the layout of the window.
    json jLayout = NuiCol (jCol);
    string sName = StripColorCodes (GetName (oTarget));
    int nToken = SetWindow (oPC, jLayout, "dmxpwin", sName + "'s experience menu",
                            -3.0, -3.0, 328.0, 166.0, FALSE, FALSE, TRUE, FALSE, TRUE);
    // Set the buttons to show events to 0e_window.
    NuiSetBind (oPC, nToken, "xp_opt_selected", JsonInt (0));
    NuiSetBind (oPC, nToken, "xp_opt_event", JsonBool (TRUE));
    NuiSetBind (oPC, nToken, "xp_amount", JsonString (""));
    NuiSetBind (oPC, nToken, "racial_xp_amount", JsonString (""));
    NuiSetBind (oPC, nToken, "btn_party_xp_event", JsonBool (TRUE));
    NuiSetBind (oPC, nToken, "btn_1_xp_event", JsonBool (TRUE));
    NuiSetBind (oPC, nToken, "btn_5_xp_event", JsonBool (TRUE));
    NuiSetBind (oPC, nToken, "btn_10_xp_event", JsonBool (TRUE));
    NuiSetBind (oPC, nToken, "btn_give_xp_event", JsonBool (TRUE));
    NuiSetBind (oPC, nToken, "btn_take_xp_event", JsonBool (TRUE));
    NuiSetBind (oPC, nToken, "btn_set_xp_event", JsonBool (TRUE));
}

void PopUpDMHPGUIPanel (object oPC)
{
    // Row 1 (Hp type label)**************************************************** 45
    json jRow = JsonArrayInsert (JsonArray (), NuiSpacer ());
    jRow = CreateLabel (jRow, "Type of Damage", "dmg_opt_title", 150.0f, 10.0f);
    jRow = JsonArrayInsert (jRow, NuiSpacer ());
    jRow = CreateLabel (jRow, "Hitpoint Adjustment", "hp_amount_title", 150.0f, 10.0f);
    jRow = JsonArrayInsert (jRow, NuiSpacer ());
    // Add row to the column.
    json jCol = JsonArrayInsert (JsonArray (), NuiRow (jRow));
    // Row 2 (Type of Damage and amount to change)****************************** 63
    // Create give damage options.
    // Insert elements into the combo box array.
    jRow = JsonArrayInsert(JsonArray (), NuiSpacer());
    json jCombo = JsonArrayInsert (JsonArray (), NuiComboEntry ("Bludgeoning", 0));
    jCombo = JsonArrayInsert (jCombo, NuiComboEntry ("Piercing", 1));
    jCombo = JsonArrayInsert (jCombo, NuiComboEntry ("Slashing", 2));
    jCombo = JsonArrayInsert (jCombo, NuiComboEntry ("Acid", 3));
    jCombo = JsonArrayInsert (jCombo, NuiComboEntry ("Cold", 4));
    jCombo = JsonArrayInsert (jCombo, NuiComboEntry ("Divine", 5));
    jCombo = JsonArrayInsert (jCombo, NuiComboEntry ("Electrical", 6));
    jCombo = JsonArrayInsert (jCombo, NuiComboEntry ("Fire", 7));
    jCombo = JsonArrayInsert (jCombo, NuiComboEntry ("Magical", 8));
    jCombo = JsonArrayInsert (jCombo, NuiComboEntry ("Negative", 9));
    jCombo = JsonArrayInsert (jCombo, NuiComboEntry ("Positive", 10));
    jCombo = JsonArrayInsert (jCombo, NuiComboEntry ("Sonic", 11));
    jRow = CreateCombo (jRow, jCombo, "dmg_opt", 150.0, 25.0);
    jRow = JsonArrayInsert (jRow, NuiSpacer ());
    jRow = CreateTextEditBox (jRow, "name_placeholder", "hp_amount", 30, FALSE, 150.0, 25.0);
    jRow = JsonArrayInsert(jRow, NuiSpacer());
    // Add the row to the column.
    jCol = JsonArrayInsert (jCol, NuiRow (jRow));
    // Row 3 (Party & die roll)************************************************* 96
    jRow = JsonArrayInsert(JsonArray (), NuiSpacer());
    jRow = CreateButtonSelect (jRow, "Party", "btn_party_hp", 72.0, 25.0);
    jRow = JsonArrayInsert(jRow, NuiSpacer());
    jRow = CreateLabel (jRow, "Die Roll:", "label_roll", 62.0, 25.0);
    jRow = JsonArrayInsert(jRow, NuiSpacer());
    jRow = CreateTextEditBox (jRow, "place_holder", "box_roll", 15, FALSE, 86.0, 25.0, "roll_tooltip");
    jRow = JsonArrayInsert(jRow, NuiSpacer());
    jRow = CreateButton (jRow, "Roll", "btn_roll", 72.0, 25.0);
    jRow = JsonArrayInsert(jRow, NuiSpacer());
    // Add the row to the column.
    jCol = JsonArrayInsert (jCol, NuiRow (jRow));
    // Row 4 (Take or Give Hp)************************************************** 129
    jRow = JsonArrayInsert(JsonArray (), NuiSpacer());
    jRow = CreateButton (jRow, "Heal", "btn_heal_hp", 97.0, 25.0);
    jRow = JsonArrayInsert(jRow, NuiSpacer());
    jRow = CreateButton (jRow, "Damage", "btn_damage_hp", 97.0, 25.0);
    jRow = JsonArrayInsert(jRow, NuiSpacer());
    jRow = CreateButton (jRow, "Set", "btn_set_hp", 97.0, 25.0);
    jRow = JsonArrayInsert(jRow, NuiSpacer());
    // Add the row to the column.
    jCol = JsonArrayInsert (jCol, NuiRow (jRow));
    // Row 5 (Fully Heal/Cure Disease/Poison)*********************************** 162
    jRow = JsonArrayInsert(JsonArray (), NuiSpacer());
    jRow = CreateButton (jRow, "Full Heal", "btn_full_heal", 97.0, 25.0);
    jRow = JsonArrayInsert(jRow, NuiSpacer());
    jRow = CreateButton (jRow, "Cure Disease", "btn_cure_disease", 97.0, 25.0);
    jRow = JsonArrayInsert(jRow, NuiSpacer());
    jRow = CreateButton (jRow, "Cure Poison", "btn_cure_poison", 97.0, 25.0);
    jRow = JsonArrayInsert(jRow, NuiSpacer());
    // Add the row to the column.
    jCol = JsonArrayInsert (jCol, NuiRow (jRow));
    // Get the DM target.
    object oTarget = GetLocalObject (oPC, "0_DM_Target");
    // Set the layout of the window.
    json jLayout = NuiCol (jCol);
    string sName = StripColorCodes (GetName (oTarget));
    int nToken = SetWindow (oPC, jLayout, "dmhpwin", sName + "'s hitpoint menu",
                            -3.0, -3.0, 328.0, 199.0, FALSE, FALSE, TRUE, FALSE, TRUE);
    // Set the buttons to show events to 0e_window.
    NuiSetBind (oPC, nToken, "roll_tooltip", JsonString ("Put a die roll here: 3d6+5."));
    NuiSetBind (oPC, nToken, "box_roll", JsonString ("1d6+1"));
    NuiSetBind (oPC, nToken, "dmg_opt_selected", JsonInt (0));
    NuiSetBind (oPC, nToken, "dmg_opt_event", JsonBool (TRUE));
    NuiSetBind (oPC, nToken, "hp_amount", JsonString (""));
    NuiSetBind (oPC, nToken, "btn_party_hp_event", JsonBool (TRUE));
    NuiSetBind (oPC, nToken, "btn_roll_event", JsonBool (TRUE));
    NuiSetBind (oPC, nToken, "btn_heal_hp_event", JsonBool (TRUE));
    NuiSetBind (oPC, nToken, "btn_damage_hp_event", JsonBool (TRUE));
    NuiSetBind (oPC, nToken, "btn_set_hp_event", JsonBool (TRUE));
    NuiSetBind (oPC, nToken, "btn_full_heal_event", JsonBool (TRUE));
    NuiSetBind (oPC, nToken, "btn_cure_disease_event", JsonBool (TRUE));
    NuiSetBind (oPC, nToken, "btn_cure_poison_event", JsonBool (TRUE));
}

void PopUpDMClassGUIPanel (object oPC)
{
    // Get the DM target.
    object oTarget = GetLocalObject (oPC, "0_DM_Target");
    // Row 1 (Class1 and level label)******************************************* 45
    json jRow = JsonArrayInsert (JsonArray (), NuiSpacer());
    jRow = CreateCombo (jRow, JArrayInsertClasses (), "class1_opt", 150.0, 25.0);
    jRow = CreateLabel (jRow, "", "class1_lvl", 20.0f, 25.0f);
    jRow = CreateButtonImage (jRow, "nui_cnt_up", "btn1_up_lvl", 25.0, 25.0);
    jRow = JsonArrayInsert(jRow, NuiSpacer());
    // Add row to the column.
    json jCol = JsonArrayInsert (JsonArray (), NuiRow (jRow));
    // Row 2 (Class2 and level label)******************************************* 78
    jRow = JsonArrayInsert (JsonArray (), NuiSpacer());
    jRow = CreateCombo (jRow, JArrayInsertClasses (), "class2_opt", 150.0, 25.0);
    jRow = CreateLabel (jRow, "", "class2_lvl", 20.0f, 25.0f);
    jRow = CreateButtonImage (jRow, "nui_cnt_up", "btn2_up_lvl", 25.0, 25.0);
    jRow = JsonArrayInsert (jRow, NuiSpacer ());
    // Add row to the column.
    jCol = JsonArrayInsert (jCol, NuiRow (jRow));
    // Row 3 (Class3 and level label)******************************************* 111
    jRow = JsonArrayInsert(JsonArray (), NuiSpacer());
    jRow = CreateCombo (jRow, JArrayInsertClasses (), "class3_opt", 150.0, 25.0);
    jRow = CreateLabel (jRow, "", "class3_lvl", 20.0f, 25.0f);
    jRow = CreateButtonImage (jRow, "nui_cnt_up", "btn3_up_lvl", 25.0, 25.0);
    jRow = JsonArrayInsert (jRow, NuiSpacer ());
    // Add row to the column.
    jCol = JsonArrayInsert (jCol, NuiRow (jRow));
    // Row 4 (Class4 and level label)******************************************* 144
    jRow = JsonArrayInsert(JsonArray (), NuiSpacer());
    jRow = CreateCombo (jRow, JArrayInsertClasses (), "class4_opt", 150.0, 25.0);
    jRow = CreateLabel (jRow, "", "class4_lvl", 20.0f, 25.0f);
    jRow = CreateButtonImage (jRow, "nui_cnt_up", "btn4_up_lvl", 25.0, 25.0);
    jRow = JsonArrayInsert (jRow, NuiSpacer ());
    // Add row to the column.
    jCol = JsonArrayInsert (jCol, NuiRow (jRow));
    // Row 5 (Class5 and level label)******************************************* 177
    jRow = JsonArrayInsert(JsonArray (), NuiSpacer());
    jRow = CreateCombo (jRow, JArrayInsertClasses (), "class5_opt", 150.0, 25.0);
    jRow = CreateLabel (jRow, "", "class5_lvl", 20.0f, 25.0f);
    jRow = CreateButtonImage (jRow, "nui_cnt_up", "btn5_up_lvl", 25.0, 25.0);
    jRow = JsonArrayInsert (jRow, NuiSpacer ());
    // Add row to the column.
    jCol = JsonArrayInsert (jCol, NuiRow (jRow));
    /*/ Row 6 (Class6 and level label)******************************************* 210
    jRow = JsonArrayInsert(JsonArray (), NuiSpacer());
    jRow = CreateCombo (jRow, JArrayInsertClasses (), "class6_opt", 150.0, 25.0);
    jRow = CreateLabel (jRow, "", "class6_lvl", 20.0f, 25.0f);
    jRow = CreateButtonImage (jRow, "nui_cnt_up", "btn6_up_lvl", 25.0, 25.0);
    jRow = JsonArrayInsert (jRow, NuiSpacer ());
    // Add row to the column.
    jCol = JsonArrayInsert (jCol, NuiRow (jRow));
    */
    // Set the layout of the window.
    json jLayout = NuiCol (jCol);
    string sName = StripColorCodes (GetName (oTarget));
    int nToken = SetWindow (oPC, jLayout, "dmclasswin", sName + "'s class menu",
                            -3.0, -3.0, 227.0, 214.0, FALSE, FALSE, TRUE, FALSE, TRUE);
    // Set the buttons to show events to 0e_window.
    int nLevel, nClass, nIndex;
    string sLevel;
    for (nIndex = 1; nIndex <= MAX_NUMBER_OF_CLASSES; nIndex ++)
    {
        nClass = GetClassForCombo (nIndex, oTarget);
        if (nClass != 46)
        {
            nLevel = GetLevelByPosition (nIndex, oTarget);
            sLevel = IntToString (nLevel);
        }
        else
        {
            NuiSetBind (oPC, nToken, "class" + IntToString (nIndex) + "_opt_event", JsonBool (TRUE));
            sLevel = "";
        }
        NuiSetBind (oPC, nToken, "class" + IntToString (nIndex) + "_opt_selected", JsonInt (nClass));
        NuiSetBind (oPC, nToken, "class" + IntToString (nIndex) + "_lvl_label", JsonString (sLevel));
        NuiSetBind (oPC, nToken, "btn" + IntToString (nIndex) + "_up_lvl_event", JsonBool (TRUE));
    }
}

void PopUpDMReputationGUIPanel (object oPC)
{
    // Get the DM target.
    object oTarget = GetLocalObject (oPC, "0_DM_Target");
    // Row 1 (Fame & Infamy labels)*********************************************
    json jRow = JsonArrayInsert (JsonArray (), NuiSpacer ());
    jRow = CreateLabel (jRow, "Fame", "fame_title", 150.0f, 10.0f, -1.0, NUI_HALIGN_CENTER, NUI_VALIGN_MIDDLE);
    jRow = JsonArrayInsert (jRow, NuiSpacer ());
    jRow = CreateLabel (jRow, "Infamy", "Infamy_title", 150.0f, 10.0f, -1.0, NUI_HALIGN_CENTER, NUI_VALIGN_MIDDLE);
    jRow = JsonArrayInsert (jRow, NuiSpacer ());
    // Add row to the column.
    json jCol = JsonArrayInsert (JsonArray (), NuiRow (jRow));
    // Row 2 (fame & infamy combo boxes)****************************************
    // Insert elements into the combo box array.
    jRow = JsonArrayInsert(JsonArray (), NuiSpacer());
    json jCombo = JsonArrayInsert (JsonArray (), NuiComboEntry ("0 Unknown", 0));
    jCombo = JsonArrayInsert (jCombo, NuiComboEntry ("1 Accepted", 1));
    jCombo = JsonArrayInsert (jCombo, NuiComboEntry ("2 Noted", 2));
    jCombo = JsonArrayInsert (jCombo, NuiComboEntry ("3 Known", 3));
    jCombo = JsonArrayInsert (jCombo, NuiComboEntry ("4 Good Standing", 4));
    jCombo = JsonArrayInsert (jCombo, NuiComboEntry ("5 Liked", 5));
    jCombo = JsonArrayInsert (jCombo, NuiComboEntry ("6 Well-known", 6));
    jCombo = JsonArrayInsert (jCombo, NuiComboEntry ("7 Admired", 7));
    jCombo = JsonArrayInsert (jCombo, NuiComboEntry ("8 Prominant", 8));
    jCombo = JsonArrayInsert (jCombo, NuiComboEntry ("9 Distinguished", 9));
    jCombo = JsonArrayInsert (jCombo, NuiComboEntry ("10 Popular", 10));
    jCombo = JsonArrayInsert (jCombo, NuiComboEntry ("11 Reputable", 11));
    jCombo = JsonArrayInsert (jCombo, NuiComboEntry ("12 Honored", 12));
    jCombo = JsonArrayInsert (jCombo, NuiComboEntry ("13 Celebrated", 13));
    jCombo = JsonArrayInsert (jCombo, NuiComboEntry ("14 Illustrious", 14));
    jCombo = JsonArrayInsert (jCombo, NuiComboEntry ("15 Eminent", 15));
    jCombo = JsonArrayInsert (jCombo, NuiComboEntry ("16 Acclaimed", 16));
    jCombo = JsonArrayInsert (jCombo, NuiComboEntry ("17 Prestigious", 17));
    jCombo = JsonArrayInsert (jCombo, NuiComboEntry ("18 Famous", 18));
    jCombo = JsonArrayInsert (jCombo, NuiComboEntry ("19 Renowned", 19));
    jCombo = JsonArrayInsert (jCombo, NuiComboEntry ("20 Revered", 20));
    jRow = CreateCombo (jRow, jCombo, "fame_opt", 150.0, 25.0);
    jRow = JsonArrayInsert (jRow, NuiSpacer ());
    // Insert elements into the combo box array.
    jCombo = JsonArrayInsert (JsonArray (), NuiComboEntry ("0 Unknown", 0));
    jCombo = JsonArrayInsert (jCombo, NuiComboEntry ("1 Suspicious", 1));
    jCombo = JsonArrayInsert (jCombo, NuiComboEntry ("2 Flagrant", 2));
    jCombo = JsonArrayInsert (jCombo, NuiComboEntry ("3 Blatant", 3));
    jCombo = JsonArrayInsert (jCombo, NuiComboEntry ("4 Scandalous", 4));
    jCombo = JsonArrayInsert (jCombo, NuiComboEntry ("5 Shady", 5));
    jCombo = JsonArrayInsert (jCombo, NuiComboEntry ("6 Shameful", 6));
    jCombo = JsonArrayInsert (jCombo, NuiComboEntry ("7 Nafarious", 7));
    jCombo = JsonArrayInsert (jCombo, NuiComboEntry ("8 Notorious", 8));
    jCombo = JsonArrayInsert (jCombo, NuiComboEntry ("9 Disreputable", 9));
    jCombo = JsonArrayInsert (jCombo, NuiComboEntry ("10 Crooked", 10));
    jCombo = JsonArrayInsert (jCombo, NuiComboEntry ("11 Degenerate", 11));
    jCombo = JsonArrayInsert (jCombo, NuiComboEntry ("12 Inglorious", 12));
    jCombo = JsonArrayInsert (jCombo, NuiComboEntry ("13 Contemptible", 13));
    jCombo = JsonArrayInsert (jCombo, NuiComboEntry ("14 Dispicable", 14));
    jCombo = JsonArrayInsert (jCombo, NuiComboEntry ("15 Wanted", 15));
    jCombo = JsonArrayInsert (jCombo, NuiComboEntry ("16 Detestable", 16));
    jCombo = JsonArrayInsert (jCombo, NuiComboEntry ("17 Heinous", 17));
    jCombo = JsonArrayInsert (jCombo, NuiComboEntry ("18 Infamous", 18));
    jCombo = JsonArrayInsert (jCombo, NuiComboEntry ("19 Villanious", 19));
    jCombo = JsonArrayInsert (jCombo, NuiComboEntry ("20 Dreaded", 20));
    jRow = CreateCombo (jRow, jCombo, "infamy_opt", 150.0, 25.0);
    jRow = JsonArrayInsert (jRow, NuiSpacer ());
    jCol = JsonArrayInsert (jCol, NuiRow (jRow));
    // Set the layout of the window.
    json jLayout = NuiCol (jCol);
    string sName = StripColorCodes (GetName (oTarget));
    int nToken = SetWindow (oPC, jLayout, "dmreputationwin", sName + "'s reputation",
                            -3.0, -3.0, 328.0, 100.0, FALSE, FALSE, TRUE, FALSE, TRUE);
    // Set the buttons to show events to 0e_window.
    int nRep = GetCharacterReputation (oTarget);
    NuiSetBind (oPC, nToken, "fame_opt_selected", JsonInt (nRep));
    NuiSetBind (oPC, nToken, "fame_opt_event", JsonBool (TRUE));
    NuiSetBindWatch (oPC, nToken, "fame_opt_selected", TRUE);
    nRep = GetCharacterReputation (oTarget, FALSE);
    NuiSetBind (oPC, nToken, "infamy_opt_selected", JsonInt (nRep));
    NuiSetBind (oPC, nToken, "infamy_opt_event", JsonBool (TRUE));
    NuiSetBindWatch (oPC, nToken, "infamy_opt_selected", TRUE);
}

void PopUpDMGoldGUIPanel (object oPC)
{
    // Row 1 (Gold type label)****************************************************
    json jRow = JsonArrayInsert (JsonArray (), NuiSpacer ());
    jRow = CreateLabel (jRow, "Type of Gold", "gold_opt_title", 150.0f, 10.0f);
    jRow = JsonArrayInsert (jRow, NuiSpacer ());
    jRow = CreateLabel (jRow, "Amount of Gold", "gold_amount_title", 150.0f, 10.0f);
    jRow = JsonArrayInsert (jRow, NuiSpacer ());
    // Add row to the column.
    json jCol = JsonArrayInsert (JsonArray (), NuiRow (jRow));
    // Row 2 (Type of XP and amount)********************************************
    jRow = JsonArrayInsert(JsonArray (), NuiSpacer());
    // Insert elements into the combo box array.
    json jCombo = JsonArrayInsert (JsonArray (), NuiComboEntry ("Bonus/Penalty", 0));
    jCombo = JsonArrayInsert (jCombo, NuiComboEntry ("Chest/Gambling", 1));
    jCombo = JsonArrayInsert (jCombo, NuiComboEntry ("Treasure/barkeep", 2));
    jCombo = JsonArrayInsert (jCombo, NuiComboEntry ("merchant", 3));
    jCombo = JsonArrayInsert (jCombo, NuiComboEntry ("ally/thief", 4));
    jCombo = JsonArrayInsert (jCombo, NuiComboEntry ("windfall/taxes", 5));
    jRow = CreateCombo (jRow, jCombo, "gold_opt", 150.0, 25.0);
    jRow = JsonArrayInsert (jRow, NuiSpacer ());
    jRow = CreateTextEditBox (jRow, "name_placeholder", "gold_amount", 30, FALSE, 150.0, 25.0);
    jRow = JsonArrayInsert(jRow, NuiSpacer());
    // Add the row to the column.
    jCol = JsonArrayInsert (jCol, NuiRow (jRow));
    // Row 3 (Party & % of xp)**************************************************
    jRow = JsonArrayInsert(JsonArray (), NuiSpacer());
    jRow = CreateButtonSelect (jRow, "Party", "btn_party_gold", 72.0, 25.0);
    jRow = JsonArrayInsert(jRow, NuiSpacer());
    jRow = CreateButton (jRow, "Wealth", "btn_wealth_gold", 72.0, 25.0);
    jRow = JsonArrayInsert(jRow, NuiSpacer());
    jRow = CreateButton (jRow, "Set 5%", "btn_5_gold", 72.0, 25.0);
    jRow = JsonArrayInsert(jRow, NuiSpacer());
    jRow = CreateButton (jRow, "Set 10%", "btn_10_gold", 72.0, 25.0);
    jRow = JsonArrayInsert(jRow, NuiSpacer());
    // Add the row to the column.
    jCol = JsonArrayInsert (jCol, NuiRow (jRow));
    // Row 4 (Take or Give XP)**************************************************
    jRow = JsonArrayInsert(JsonArray (), NuiSpacer());
    jRow = CreateButton (jRow, "Give", "btn_give_gold", 97.0, 25.0);
    jRow = JsonArrayInsert(jRow, NuiSpacer());
    jRow = CreateButton (jRow, "Take", "btn_take_gold", 97.0, 25.0);
    jRow = JsonArrayInsert(jRow, NuiSpacer());
    jRow = CreateButton (jRow, "Set", "btn_set_gold", 97.0, 25.0);
    jRow = JsonArrayInsert(jRow, NuiSpacer());
    // Add the row to the column.
    jCol = JsonArrayInsert (jCol, NuiRow (jRow));
    // Set the layout of the window.
    json jLayout = NuiCol (jCol);
    // Get the DM target.
    object oTarget = GetLocalObject (oPC, "0_DM_Target");
    string sName = StripColorCodes (GetName (oTarget));
    int nToken = SetWindow (oPC, jLayout, "dmgoldwin", sName + "'s gold menu",
                            -3.0, -3.0, 328.0, 166.0, FALSE, FALSE, TRUE, FALSE, TRUE);
    // Set the buttons to show events to 0e_window.
    NuiSetBind (oPC, nToken, "gold_opt_selected", JsonInt (0));
    NuiSetBind (oPC, nToken, "gold_opt_event", JsonBool (TRUE));
    NuiSetBind (oPC, nToken, "gold_amount", JsonString (""));
    NuiSetBind (oPC, nToken, "btn_party_gold_event", JsonBool (TRUE));
    NuiSetBind (oPC, nToken, "btn_5_gold_event", JsonBool (TRUE));
    NuiSetBind (oPC, nToken, "btn_10_gold_event", JsonBool (TRUE));
    NuiSetBind (oPC, nToken, "btn_wealth_gold_event", JsonBool (TRUE));
    NuiSetBind (oPC, nToken, "btn_give_gold_event", JsonBool (TRUE));
    NuiSetBind (oPC, nToken, "btn_take_gold_event", JsonBool (TRUE));
    NuiSetBind (oPC, nToken, "btn_set_gold_event", JsonBool (TRUE));
}

void PopupDMItemWealthGUIPanel (object oPC)
{
    // Get the DM target.
    object oTarget = GetLocalObject (oPC, "0_DM_Target");
    // Create the column.
    // Row 1 (text)*************************************************************
    json jRow = CreateTextBox (JsonArray (), "items_text", 440.0f, 570.0f);
    // Add the row to the column.
    json jCol = JsonArrayInsert (JsonArray (), NuiRow (jRow));
    // Set the Layout of the window.
    json jLayout = NuiCol (jCol);
    float fY = GetGUIHeightMiddle (oPC, 627.0);
    string sName = StripColorCodes (GetName (oTarget));
    int nToken = SetWindow (oPC, jLayout, "dmitemwealthwin", sName + "'s item wealth",
                            0.0, fY, 460.0, 627.0, FALSE, FALSE, TRUE, FALSE, TRUE);
    // Set all binds, events, and watches.
    string sText = GetInventoryGoldValues (oTarget);
    NuiSetBind (oPC, nToken, "items_text", JsonString (sText));
}

void PopUpDMAlignGUIPanel (object oPC)
{
    // Set window to not save until it has been created.
    SetLocalInt (oPC, "0_No_Align_Save", TRUE);
    DelayCommand (0.5f, DeleteLocalInt (oPC, "0_No_Align_Save"));
    // Row 1 (Alignment description)******************************************** 45
    json jRow = CreateLabel (JsonArray (), "", "law_chaos_desc", 150.0f, 10.0f);
    jRow = CreateLabel (jRow, "", "good_evil_desc", 150.0f, 10.0f);
    // Add row to the column.
    json jCol = JsonArrayInsert (JsonArray (), NuiRow (jRow));
    // Row 3 (Alignment sliders)************************************************ 63
    jRow = JsonArrayInsert(JsonArray (), NuiSpacer());
    jRow = CreateSlider (jRow, "law_chaos", 150.0, 25.0);
    jRow = JsonArrayInsert(jRow, NuiSpacer());
    jRow = CreateSlider (jRow, "good_evil", 150.0, 25.0);
    jRow = JsonArrayInsert(jRow, NuiSpacer());
    // Add row to the column.
    jCol = JsonArrayInsert (jCol, NuiRow (jRow));
    // Row 4 (Alignment buttons)************************************************ 96
    jRow = JsonArrayInsert(JsonArray (), NuiSpacer());
    jRow = CreateButton (jRow, "Lawful Good", "btn_lg", 130.0, 25.0);
    jRow = CreateButton (jRow, "Neutral Good", "btn_ng", 130.0, 25.0);
    jRow = CreateButton (jRow, "Chaotic Good", "btn_cg", 130.0, 25.0);
    jRow = JsonArrayInsert(jRow, NuiSpacer());
    // Add row to the column.
    jCol = JsonArrayInsert (jCol, NuiRow (jRow));
    // Row 5 (Alignment buttons)************************************************ 129
    jRow = JsonArrayInsert(JsonArray (), NuiSpacer());
    jRow = CreateButton (jRow, "Lawful Neutral", "btn_ln", 130.0, 25.0);
    jRow = CreateButton (jRow, "True Neutral", "btn_tn", 130.0, 25.0);
    jRow = CreateButton (jRow, "Chaotic Neutral", "btn_cn", 130.0, 25.0);
    jRow = JsonArrayInsert(jRow, NuiSpacer());
    // Add row to the column.
    jCol = JsonArrayInsert (jCol, NuiRow (jRow));
    // Row 6 (Alignment buttons)************************************************ 162
    jRow = JsonArrayInsert(JsonArray (), NuiSpacer());
    jRow = CreateButton (jRow, "Lawful Evil", "btn_le", 130.0, 25.0);
    jRow = CreateButton (jRow, "Neutral Evil", "btn_ne", 130.0, 25.0);
    jRow = CreateButton (jRow, "Chaotic Evil", "btn_ce", 130.0, 25.0);
    jRow = JsonArrayInsert(jRow, NuiSpacer());
    // Add row to the column.
    jCol = JsonArrayInsert (jCol, NuiRow (jRow));
    // Set the layout of the window.
    json jLayout = NuiCol (jCol);
    // Get the DM target.
    object oTarget = GetLocalObject (oPC, "0_DM_Target");
    string sName = StripColorCodes (GetName (oTarget));
    int nToken = SetWindow (oPC, jLayout, "dmalignwin", sName + "'s alignment menu",
                            -3.0, -3.0, 422.0, 199.0, FALSE, FALSE, TRUE, FALSE, TRUE);
    // Set the buttons to show events to 0e_window.
    json jTarget = ObjectToJson (oTarget);
    int nValue = JsonGetInt (JsonObjectGet (JsonObjectGet (jTarget, "LawfulChaotic"), "value"));
    NuiSetBind (oPC, nToken, "law_chaos_desc_label", JsonString (GetLawChaosText (nValue)));
    NuiSetBind (oPC, nToken, "law_chaos_min", JsonInt (0));
    NuiSetBind (oPC, nToken, "law_chaos_max", JsonInt (100));
    NuiSetBind (oPC, nToken, "law_chaos_stepsize", JsonInt (1));
    NuiSetBind (oPC, nToken, "law_chaos_value", JsonInt (nValue));
    NuiSetBindWatch (oPC, nToken, "law_chaos_value", TRUE);
    NuiSetBind (oPC, nToken, "law_chaos_event", JsonBool (TRUE));
    nValue = JsonGetInt (JsonObjectGet (JsonObjectGet (jTarget, "GoodEvil"), "value"));
    NuiSetBind (oPC, nToken, "good_evil_desc_label", JsonString (GetGoodEvilText (nValue)));
    NuiSetBind (oPC, nToken, "good_evil_max", JsonInt (100));
    NuiSetBind (oPC, nToken, "good_evil_stepsize", JsonInt (1));
    NuiSetBind (oPC, nToken, "good_evil_value", JsonInt (nValue));
    NuiSetBindWatch (oPC, nToken, "good_evil_value", TRUE);
    NuiSetBind (oPC, nToken, "good_evil_event", JsonBool (TRUE));
    NuiSetBind (oPC, nToken, "btn_lg_event", JsonBool (TRUE));
    NuiSetBind (oPC, nToken, "btn_ln_event", JsonBool (TRUE));
    NuiSetBind (oPC, nToken, "btn_le_event", JsonBool (TRUE));
    NuiSetBind (oPC, nToken, "btn_ng_event", JsonBool (TRUE));
    NuiSetBind (oPC, nToken, "btn_tn_event", JsonBool (TRUE));
    NuiSetBind (oPC, nToken, "btn_ne_event", JsonBool (TRUE));
    NuiSetBind (oPC, nToken, "btn_cg_event", JsonBool (TRUE));
    NuiSetBind (oPC, nToken, "btn_cn_event", JsonBool (TRUE));
    NuiSetBind (oPC, nToken, "btn_ce_event", JsonBool (TRUE));
}

void PopUpDMPlayerGUIPanel (object oPC)
{
    // Get the DM target.
    object oTarget = GetLocalObject (oPC, "0_DM_Target");
    // Row 1 (Boot/Ban/Watch)*************************************************** 45
    json jRow = CreateButton (JsonArray (), "Boot", "btn_boot", 60.0, 20.0);
    jRow = JsonArrayInsert(jRow, NuiSpacer());
    jRow = CreateButtonSelect (jRow, "Ban", "btn_ban", 60.0, 20.0);
    jRow = JsonArrayInsert(jRow, NuiSpacer());
    jRow = CreateButtonSelect (jRow, "Watch", "btn_watch", 60.0, 20.0);
    // Add the row to the column.
    json jCol = JsonArrayInsert (JsonArray (), NuiRow (jRow));
    // Row 2 (labels)*********************************************************** 73
    jRow = CreateLabel (JsonArray (), "Player Status", "status_opt_title", 150.0f, 20.0f);
    jRow = CreateLabel (jRow, "Public CD Key", "cd_key_title", 150.0f, 20.0f);
    // Add row to the column.
    jCol = JsonArrayInsert (jCol, NuiRow (jRow));
    // Row 3 (Status/CD Key)**************************************************** 91
    jRow = JsonArrayInsert(JsonArray (), NuiSpacer());
    // Insert elements into the combo box array.
    json jCombo = JsonArrayInsert (JsonArray (), NuiComboEntry ("Unknown Player", 0));
    jCombo = JsonArrayInsert (jCombo, NuiComboEntry ("Known Player", 1));
    jCombo = JsonArrayInsert (jCombo, NuiComboEntry ("Privileged Player", 2));
    jCombo = JsonArrayInsert (jCombo, NuiComboEntry ("Dungeon Master", 3));
    jCombo = JsonArrayInsert (jCombo, NuiComboEntry ("Privileged DM", 4));
    jCombo = JsonArrayInsert (jCombo, NuiComboEntry ("Administrator", 5));
    jCombo = JsonArrayInsert (jCombo, NuiComboEntry ("Banned", 6));
    jRow = CreateCombo (jRow, jCombo, "status_opt", 150.0, 25.0);
    jRow = JsonArrayInsert (jRow, NuiSpacer ());
    jRow = CreateLabel (jRow, "", "cd_key", 150.0f, 25.0f, -1.0, NUI_HALIGN_CENTER, NUI_VALIGN_MIDDLE);
    jRow = JsonArrayInsert(jRow, NuiSpacer());
    // Add the row to the column.
    jCol = JsonArrayInsert (jCol, NuiRow (jRow));
    // Row 4 (player stats)***************************************************** 124
    jRow = JsonArrayInsert (JsonArray (), NuiSpacer());
    jRow = CreateLabel (jRow, "", "player", 200.0, 10.0f);
    jRow = JsonArrayInsert (jRow, NuiSpacer());
    // Add the row to the column.
    jCol = JsonArrayInsert (jCol, NuiRow (jRow));
    // Row 5 (text box)********************************************************* 142
    jRow = CreateTextBox (JsonArray (), "player_text", 300.0f, 175.0f);
    // Add the row to the column.
    jCol = JsonArrayInsert (jCol, NuiRow (jRow));
    // Row 6 (character stats)************************************************** 325
    jRow = JsonArrayInsert (JsonArray (), NuiSpacer());
    jRow = CreateLabel (jRow, "", "char", 200.0f, 10.0f);
    jRow = JsonArrayInsert (jRow, NuiSpacer());
    // Add the row to the column.
    jCol = JsonArrayInsert (jCol, NuiRow (jRow));
    // Row 7 (text box)********************************************************* 343
    jRow = CreateTextBox (JsonArray (), "char_text", 300.0f, 175.0f);
    // Add the row to the column.
    jCol = JsonArrayInsert (jCol, NuiRow (jRow));
    // Set the layout of the window.
    json jLayout = NuiCol (jCol);
    float fY = GetGUIHeightMiddle (oPC, 530.0);
    int nToken = SetWindow (oPC, jLayout, "dmplayerwin", GetPCPlayerName (oTarget) + "'s player menu",
                            0.0, fY, 328.0, 530.0, FALSE, FALSE, TRUE, FALSE, TRUE);
    // Set the buttons to show events to 0e_window.
    int nValue = GetServerDatabaseInt (oTarget, PLAYER_TABLE, "status");
    if (nValue == -1)
    {
        NuiSetBind (oPC, nToken, "btn_ban", JsonBool (TRUE));
        NuiSetBind (oPC, nToken, "status_opt_selected", JsonInt (6));
    }
    else
    {
        NuiSetBind (oPC, nToken, "btn_ban", JsonBool (FALSE));
        NuiSetBind (oPC, nToken, "status_opt_selected", JsonInt (nValue));
    }
    NuiSetBind (oPC, nToken, "status_opt_event", JsonBool (TRUE));
    NuiSetBindWatch (oPC, nToken, "status_opt_selected", TRUE);
    NuiSetBind (oPC, nToken, "cd_key_label", JsonString (GetPCPublicCDKey (oTarget)));
    NuiSetBind (oPC, nToken, "btn_boot_event", JsonBool (TRUE));
    NuiSetBind (oPC, nToken, "btn_ban_event", JsonBool (TRUE));
    nValue = GetServerDatabaseInt (oTarget, PLAYER_TABLE, "watched");
    NuiSetBind (oPC, nToken, "btn_watch", JsonBool (nValue));
    NuiSetBind (oPC, nToken, "btn_watch_event", JsonBool (TRUE));
    // Setup player stats.
    NuiSetBind (oPC, nToken, "player_label", JsonString (GetPCPlayerName (oTarget)));
    string sText;
    sText = "Number of Characters: " + IntToString (GetServerDatabaseInt (oTarget, PLAYER_TABLE, "characters"));
    sText += "\nHighest Level Character: " + IntToString (GetServerDatabaseInt (oTarget, PLAYER_TABLE, "highestlevel"));
    sText += "\nNumber of logins: " + IntToString (GetServerDatabaseInt (oTarget, PLAYER_TABLE, "logins"));
    nValue = GetServerDatabaseInt (oTarget, PLAYER_TABLE, "dmlogins");
    if (nValue > 0) sText += "\nNumber of DM logins: " + IntToString (nValue);
    sText += "\nNumber of times resting: " + IntToString (GetServerDatabaseInt (oTarget, PLAYER_TABLE, "rests"));
    sText += "\nNumber of times bleeding: " + IntToString (GetServerDatabaseInt (oTarget, PLAYER_TABLE, "bleeds"));
    sText += "\nNumber of respawns: " + IntToString (GetServerDatabaseInt (oTarget, PLAYER_TABLE, "respawns"));
    sText += "\nNumber of deaths: " + IntToString (GetServerDatabaseInt (oTarget, PLAYER_TABLE, "deaths"));
    nValue = GetServerDatabaseInt (oTarget, PLAYER_TABLE, "kills") + GetLocalInt (oTarget, "0_Kills");
    sText += "\nNumber of Kills: " + IntToString (nValue);
    nValue = GetServerDatabaseInt (oTarget, PLAYER_TABLE, "cynosurejumps");
    if (nValue > 0) sText += "\nNumber of Cynosure jumps: " + IntToString (nValue);
    NuiSetBind (oPC, nToken, "player_text", JsonString (sText));
    // Setup player / character stats.
    NuiSetBind (oPC, nToken, "char_label", JsonString (GetName (oTarget)));
    sText = "Number of times resting: " + IntToString (GetObjectDatabaseInt (oTarget, CHARACTER_TABLE, "rests"));
    sText += "\nNumber of times bleeding: " + IntToString (GetObjectDatabaseInt (oTarget, CHARACTER_TABLE, "bleeds"));
    sText += "\nNumber of respawns: " + IntToString (GetObjectDatabaseInt (oTarget, CHARACTER_TABLE, "respawns"));
    sText += "\nNumber of deaths: " + IntToString (GetObjectDatabaseInt (oTarget, CHARACTER_TABLE, "deaths"));
    nValue = GetObjectDatabaseInt (oTarget, CHARACTER_TABLE, "kills") + GetLocalInt (oTarget, "0_Kills");
    sText += "\nNumber of kills: " + IntToString (nValue);
    nValue = GetObjectDatabaseInt (oTarget, CHARACTER_TABLE, "sidequests");
    sText += "\nCompleted side quests: " + IntToString (nValue);
    nValue = GetObjectDatabaseInt (oTarget, CHARACTER_TABLE, "mainquests");
    sText += "\nCompleted main quests: " + IntToString (nValue);
    NuiSetBind (oPC, nToken, "char_text", JsonString (sText));
    NuiSetBind (oPC, nToken, "btn_variables_event", JsonBool (TRUE));
}
void PopUpDMDatabaseGUIPanel(object oPC)
{
    // Get the DM target.
    object oTarget = GetLocalObject(oPC, "0_DM_Target");
    // Row 1 (Object Table label)*********************************************** 45
    json jRow = JsonArrayInsert(JsonArray(), NuiSpacer());
    jRow = CreateLabel(jRow, "Database Objects", "lbl_database_objects", 150.0, 20.0);
    jRow = JsonArrayInsert(jRow, NuiSpacer());
    json jCol = JsonArrayInsert(JsonArray(), NuiRow(jRow));
    // Row 2 (Object Table list)************************************************ 249
    // Create the button template for the Object List.
    json jButton = NuiId(NuiButtonImage(JsonString("ir_abort")), "btn_o_delete");
    jButton = NuiTooltip(jButton, JsonString("  Delete Entry"));
    json jList = JsonArrayInsert(JsonArray(), NuiListTemplateCell(jButton, 25.0, TRUE));
    jButton = NuiId(NuiLabel(NuiBind("lbls_o_tag"), JsonInt(NUI_HALIGN_LEFT), JsonInt(0)), "lbl_o_tag");
    jList = JsonArrayInsert(jList, NuiListTemplateCell(jButton, 175.0, TRUE));
    jButton = NuiId(NuiLabel(NuiBind("lbls_o_obj_tag"), JsonInt(NUI_HALIGN_LEFT), JsonInt(0)), "lbl_o_obj_tag");
    jList = JsonArrayInsert(jList, NuiListTemplateCell(jButton, 225.0, TRUE));
    // Create the list with the template.
    jRow = JsonArrayInsert(JsonArray(), NuiSpacer());
    jRow = CreateList(jRow, jList, "lbls_o_tag", 25.0, 425.0, 200.0);
    jRow = JsonArrayInsert(jRow, NuiSpacer());
    jCol = JsonArrayInsert(jCol, NuiRow(jRow));
    // Row 3 (Object Table label)*********************************************** 273
    jRow = JsonArrayInsert(JsonArray(), NuiSpacer());
    jRow = CreateLabel(jRow, "Database Quests", "lbl_database_quest", 150.0, 20.0);
    jRow = JsonArrayInsert(jRow, NuiSpacer());
    jCol = JsonArrayInsert(jCol, NuiRow(jRow));
    // Row 4 (Object Table list)************************************************ 477
    // Create the button template for the Object List.
    jButton = NuiId(NuiButtonImage(JsonString("ir_abort")), "btn_q_delete");
    jButton = NuiTooltip(jButton, JsonString("  Delete Entry"));
    jList = JsonArrayInsert(JsonArray(), NuiListTemplateCell(jButton, 25.0, TRUE));
    jButton = NuiId(NuiLabel(NuiBind("lbls_q_name"), JsonInt(NUI_HALIGN_LEFT), JsonInt(0)), "lbl_q_name");
    jList = JsonArrayInsert(jList, NuiListTemplateCell(jButton, 175.0, TRUE));
    jButton = NuiId(NuiLabel(NuiBind("lbls_q_tag"), JsonInt(NUI_HALIGN_LEFT), JsonInt(0)), "lbl_q_tag");
    jList = JsonArrayInsert(jList, NuiListTemplateCell(jButton, 225.0, TRUE));
    // Create the list with the template.
    jRow = JsonArrayInsert(JsonArray(), NuiSpacer());
    jRow = CreateList(jRow, jList, "lbls_q_name", 25.0, 425.0, 200.0);
    jRow = JsonArrayInsert(jRow, NuiSpacer());
    jCol = JsonArrayInsert(jCol, NuiRow(jRow));
    // Set the layout of the window.
    json jLayout = NuiCol(jCol);
    float fX = GetGUIWidthMiddle(oPC, 478.0);
    float fY = GetGUIHeightMiddle(oPC, 500.0);
    int nToken = SetWindow (oPC, jLayout, "dmdatabasewin", GetPCPlayerName(oTarget) + "'s database menu",
                            fX, fY, 478.0, 500.0, FALSE, FALSE, TRUE, FALSE, TRUE);
    // Create buttons for players database objects.
    json jTag = JsonArray();
    json jObjTag = JsonArray();
    string sTag, sObjectTag;
    string sQuery = "SELECT tag, objecttag FROM " + OBJECT_TABLE + " WHERE name = @name;";
    sqlquery sql = SqlPrepareQueryCampaign(SERVER_DATABASE, sQuery);
    SqlBindString(sql, "@name", GetName(oTarget, TRUE));
    if(SqlStep(sql)) sTag = SqlGetString(sql, 0);
    while(sTag != "")
    {
        sObjectTag = SqlGetString(sql, 1);
        jTag = JsonArrayInsert(jTag, JsonString(sTag));
        jObjTag = JsonArrayInsert(jObjTag, JsonString(sObjectTag));
        if(SqlStep(sql)) sTag = SqlGetString(sql, 0);
        else sTag = "";
    }
    // Add the buttons to the list.
    NuiSetBind(oPC, nToken, "lbls_o_tag", jTag);
    NuiSetBind(oPC, nToken, "lbls_o_obj_tag", jObjTag);
    // Create buttons for players database quests.
    string sName;
    json jName = JsonArray();
    jTag = JsonArray();
    sQuery = "SELECT tag, quest, area FROM " + QUEST_TABLE + " WHERE name = @name;";
    sql = SqlPrepareQueryCampaign(SERVER_DATABASE, sQuery);
    SqlBindString(sql, "@name", GetName(oTarget, TRUE));
    if(SqlStep(sql)) sTag = SqlGetString(sql, 0);
    while(sTag != "")
    {
        sName = SqlGetString(sql, 1);
        sName = GetStringArray(sName, 0, "-");
        if(sName == "Treasure Map")
        {
            sName = SqlGetString(sql, 2);
            sName = GetStringArray(sName, 0, "-");
        }
        jName = JsonArrayInsert(jName, JsonString(sName));
        jTag = JsonArrayInsert(jTag, JsonString(sTag));
        if(SqlStep(sql)) sTag = SqlGetString(sql, 0);
        else sTag = "";
    }
    // Add the buttons to the list.
    NuiSetBind(oPC, nToken, "lbls_q_name", jName);
    NuiSetBind(oPC, nToken, "lbls_q_tag", jTag);
}
void PopUpDMObjectGUIPanel(object oPC)
{
    float fWinHeigth = 380.0;
    // Set window to not save until it has been created.
    SetLocalInt (oPC, "0_No_Win_Save", TRUE);
    DelayCommand (0.5f, DeleteLocalInt (oPC, "0_No_Win_Save"));
    // Get the DM target.
    object oTarget = GetLocalObject (oPC, "0_DM_Target");
    // Get the type of object we are examining.
    int nObjectType = GetObjectType (oTarget);
    // Is this a container?
    int bContainer = GetHasInventory (oTarget);
    // Row 1 (Name)************************************************************* 45
    json jRow = CreateLabel (JsonArray (), "Name", "name_title", 45.0f, 20.0f, -1.0, NUI_HALIGN_LEFT);
    jRow = CreateTextEditBox (jRow, "name_placeholder", "name_value", 30, FALSE, 353.0f, 20.0f);
    // Add row to the column.
    json jCol = JsonArrayInsert (JsonArray (), NuiRow (jRow));
    // Row 2 (Tag)************************************************************** 73
    jRow = CreateLabel (JsonArray (), "Tag", "tag_title", 45.0f, 20.0f, -1.0, NUI_HALIGN_LEFT);
    jRow = CreateTextEditBox (jRow, "name_placeholder", "tag_value", 30, FALSE, 353.0f, 20.0f);
    // Add row to the column.
    jCol = JsonArrayInsert (jCol, NuiRow (jRow));
    // Row 3 (Plot/Fortitude)*************************************************** 101
    jRow = CreateCheckBox (JsonArray (), " Plot", "plot", 199.0, 20.0f);
    jRow = CreateLabel (jRow, "Fortitude save", "fort_title", 150.0f, 20.0f, -1.0, NUI_HALIGN_LEFT);
    jRow = CreateTextEditBox (jRow, "name_placeholder", "fort_value", 4, FALSE, 45.0f, 20.0f);
    // Add row to the column.
    jCol = JsonArrayInsert (jCol, NuiRow (jRow));
    // Row 4 (Hardness/Reflex)************************************************** 129
    jRow = CreateLabel (JsonArray (), "Hardness", "hard_title", 150.0f, 20.0f, -1.0, NUI_HALIGN_LEFT);
    jRow = CreateTextEditBox (jRow, "name_placeholder", "hard_value", 4, FALSE, 45.0f, 20.0f);
    jRow = CreateLabel (jRow, "Reflex save", "reflex_title", 150.0f, 20.0f, -1.0, NUI_HALIGN_LEFT);
    jRow = CreateTextEditBox (jRow, "name_placeholder", "reflex_value", 4, FALSE, 45.0f, 20.0f);
    // Add row to the column.
    jCol = JsonArrayInsert (jCol, NuiRow (jRow));
    // Row 5 (Hitpoints/Will)*************************************************** 157
    jRow = CreateLabel (JsonArray (), "Hit points", "hp_title", 150.0f, 20.0f, -1.0, NUI_HALIGN_LEFT);
    jRow = CreateTextEditBox (jRow, "name_placeholder", "hp_value", 4, FALSE, 45.0f, 20.0f);
    jRow = CreateLabel (jRow, "Will save", "will_title", 150.0f, 20.0f, -1.0, NUI_HALIGN_LEFT);
    jRow = CreateTextEditBox (jRow, "name_placeholder", "will_value", 4, FALSE, 45.0f, 20.0f);
    // Add row to the column.
    jCol = JsonArrayInsert (jCol, NuiRow (jRow));
    if (nObjectType == OBJECT_TYPE_DOOR || bContainer)
    {
        if (bContainer)
        {
            // Row 6 (Lock/Trap Groups)************************************************* 185
            jRow = CreateLabel (JsonArray (), "Treasure level", "level_title", 150.0f, 20.0f, -1.0, NUI_HALIGN_LEFT);
            jRow = CreateTextEditBox (jRow, "name_placeholder", "level_value", 4, FALSE, 45.0f, 20.0f);
            jRow = CreateCheckBox (jRow, " Generate Treasure", "gen_treasure", 150.0, 20.0f);
            // Add row to the column.
            jCol = JsonArrayInsert (jCol, NuiRow (jRow));
            fWinHeigth += 28.0;
        }
        // Row 6 (Lock/Trap Groups)************************************************* 185
        // Lock group
        json jGroupRow = CreateCheckBox (JsonArray (), "Locked", "locked", 180.0, 10.0f);
        json jGroupCol = JsonArrayInsert (JsonArray (), NuiRow (jGroupRow));
        jGroupRow = CreateCheckBox (JsonArray (), "Can be relocked", "relocked", 180.0, 10.0f);
        jGroupCol = JsonArrayInsert (jGroupCol, NuiRow (jGroupRow));
        jGroupRow = CreateCheckBox (JsonArray (), "Remove key after use", "remove_key", 180.0, 10.0f);
        jGroupCol = JsonArrayInsert (jGroupCol, NuiRow (jGroupRow));
        jGroupRow = CreateCheckBox (JsonArray (), "Key required", "key_required", 180.0, 10.0f);
        jGroupCol = JsonArrayInsert (jGroupCol, NuiRow (jGroupRow));
        jGroupRow = CreateLabel (JsonArray (), "Key Tag", "key_tag_title", 60.0f, 20.0f, -1.0, NUI_HALIGN_LEFT);
        jGroupRow = CreateTextEditBox (jGroupRow, "name_placeholder", "key_tag_value", 20, FALSE, 116.0f, 20.0f);
        jGroupCol = JsonArrayInsert (jGroupCol, NuiRow (jGroupRow));
        jGroupRow = CreateLabel (JsonArray (), "Open Lock DC", "open_dc_title", 131.0f, 20.0f, -1.0, NUI_HALIGN_LEFT);
        jGroupRow = CreateTextEditBox (jGroupRow, "name_placeholder", "open_dc_value", 4, FALSE, 45.0f, 20.0f);
        jGroupCol = JsonArrayInsert (jGroupCol, NuiRow (jGroupRow));
        jGroupRow = CreateLabel (JsonArray (), "Close Lock DC", "open_dc_title", 131.0f, 20.0f, -1.0, NUI_HALIGN_LEFT);
        jGroupRow = CreateTextEditBox (jGroupRow, "name_placeholder", "close_dc_value", 4, FALSE, 45.0f, 20.0f);
        jGroupCol = JsonArrayInsert (jGroupCol, NuiRow (jGroupRow));
        jGroupRow = CreateLabel (JsonArray (), "Bash DC", "bash_dc_title", 131.0f, 20.0f, -1.0, NUI_HALIGN_LEFT);
        jGroupRow = CreateTextEditBox (jGroupRow, "name_placeholder", "bash_dc_value", 4, FALSE, 45.0f, 20.0f);
        // Add group rows to group column and group column to group layout
        jGroupCol = JsonArrayInsert (jGroupCol, NuiRow (jGroupRow));
        json jGroupLayout = NuiCol (jGroupCol);
        // Add group to row.
        jRow = JsonArrayInsert (JsonArray (), NuiHeight (NuiWidth (NuiGroup (jGroupLayout), 198.0), 200.0));
        // Trap Group
        // Create trap options.
        // Insert elements into the combo box array.
        jGroupRow = CreateCombo (JsonArray (), JsonArrayInsertTraps (), "trap_opt", 180.0, 20.0);
        jGroupCol = JsonArrayInsert (JsonArray (), NuiRow (jGroupRow));
        jGroupRow = CreateCheckBox (JsonArray (), "Area of Effect", "aoe", 180.0, 10.0f);
        jGroupCol = JsonArrayInsert (jGroupCol, NuiRow (jGroupRow));
        jGroupRow = CreateCheckBox (JsonArray (), "One shot", "oneshot", 180.0, 10.0f);
        jGroupCol = JsonArrayInsert (jGroupCol, NuiRow (jGroupRow));
        jGroupRow = CreateCheckBox (JsonArray (), "Detectable trap", "detect_trap", 180.0, 10.0f);
        jGroupCol = JsonArrayInsert (jGroupCol, NuiRow (jGroupRow));
        jGroupRow = CreateCheckBox (JsonArray (), "Disarmable trap", "disarm_trap", 180.0, 10.0f);
        jGroupCol = JsonArrayInsert (jGroupCol, NuiRow (jGroupRow));
        jGroupRow = CreateLabel (JsonArray (), "Detection DC", "key_tag_title", 135.0f, 20.0f, -1.0, NUI_HALIGN_LEFT);
        jGroupRow = CreateTextEditBox (jGroupRow, "name_placeholder", "detect_dc_value", 4, FALSE, 45.0f, 20.0f);
        jGroupCol = JsonArrayInsert (jGroupCol, NuiRow (jGroupRow));
        jGroupRow = CreateLabel (JsonArray (), "Disarm DC", "disarm_dc_title", 135.0f, 20.0f, -1.0, NUI_HALIGN_LEFT);
        jGroupRow = CreateTextEditBox (jGroupRow, "name_placeholder", "disarm_dc_value", 4, FALSE, 45.0f, 20.0f);
        jGroupCol = JsonArrayInsert (jGroupCol, NuiRow (jGroupRow));
        jGroupRow = CreateLabel (JsonArray (), "Trap Level", "trap_level_title", 135.0f, 20.0f, -1.0, NUI_HALIGN_LEFT);
        jGroupRow = CreateTextEditBox (jGroupRow, "name_placeholder", "trap_level_value", 4, FALSE, 45.0f, 20.0f);
        // Add group rows to group column and group column to group layout
        jGroupCol = JsonArrayInsert (jGroupCol, NuiRow (jGroupRow));
        jGroupLayout = NuiCol (jGroupCol);
        // Add group to row.
        jRow = JsonArrayInsert (jRow, NuiWidth (NuiGroup (jGroupLayout), 198.0));
        // Add the row to the column.
        jCol = JsonArrayInsert (jCol, NuiRow (jRow));
        // Row 7 (DC levels)******************************************************** 393
        jGroupRow = CreateButton (JsonArray (), "Area Level", "btn_dc_1", 90.0, 25.0);
        jRow = JsonArrayInsert (jRow, NuiSpacer ());
        jGroupRow = CreateButton (jGroupRow, "Easy", "btn_dc_2", 90.0, 25.0);
        jRow = JsonArrayInsert (jRow, NuiSpacer ());
        jGroupRow = CreateButton (jGroupRow, "Average", "btn_dc_3", 90.0, 25.0);
        jRow = JsonArrayInsert (jRow, NuiSpacer ());
        jGroupRow = CreateButton (jGroupRow, "Tough", "btn_dc_4", 90.0, 25.0);
        // Add group row to the group column.
        jGroupCol = JsonArrayInsert (JsonArray (), NuiRow (jGroupRow));
        // Row 8 (DC levels)******************************************************** 438
        jGroupRow = CreateButton (JsonArray (), "Challenge", "btn_dc_5", 90.0, 25.0);
        jRow = JsonArrayInsert (jRow, NuiSpacer ());
        jGroupRow = CreateButton (jGroupRow, "Formidable", "btn_dc_6", 90.0, 25.0);
        jRow = JsonArrayInsert (jRow, NuiSpacer ());
        jGroupRow = CreateButton (jGroupRow, "Heroic", "btn_dc_7", 90.0, 25.0);
        jRow = JsonArrayInsert (jRow, NuiSpacer ());
        jGroupRow = CreateButton (jGroupRow, "Godly", "btn_dc_8", 90.0, 25.0);
        // Add group rows to group column and group column to group layout
        jGroupCol = JsonArrayInsert (jGroupCol, NuiRow (jGroupRow));
        jGroupLayout = NuiCol (jGroupCol);
        // Add group to row.
        jRow = JsonArrayInsert (JsonArray (), NuiHeight (NuiWidth (NuiGroup (jGroupLayout), 400.0), 74.0));
        // Add the row to the column.
        jCol = JsonArrayInsert (jCol, NuiRow (jRow));
        fWinHeigth += 290.0;
    }
    // Row 9 (Description)****************************************************** 475 / 185
    jRow = CreateTextEditBox (JsonArray (), "desc_placeholder", "desc_value", 1000, TRUE, 398.0, 150.0);
    // Add row to the column.
    jCol = JsonArrayInsert (jCol, NuiRow (jRow));
    // Row 8 (Buttons)********************************************************** 633 / 343
    jRow = JsonArray ();
    jRow = JsonArrayInsert (jRow, NuiSpacer());
    jRow = CreateButton (JsonArray (), "Variables", "btn_variables", 95.0, 25.0);
    if (nObjectType == OBJECT_TYPE_DOOR)
    {
        jRow = JsonArrayInsert (jRow, NuiSpacer());
        jRow = CreateButton (jRow, "", "btn_open", 95.0, 25.0);
    }
    if (nObjectType == OBJECT_TYPE_PLACEABLE)
    {
        jRow = JsonArrayInsert (jRow, NuiSpacer());
        jRow = CreateButton (jRow, "Move", "btn_move", 95.0, 25.0);
        jRow = JsonArrayInsert (jRow, NuiSpacer());
        jRow = CreateButtonSelect (jRow, "Container", "btn_container", 95.0, 25.0);
        if (bContainer)
        {
            jRow = JsonArrayInsert (jRow, NuiSpacer());
            jRow = CreateButton (jRow, "Inventory", "btn_inventory", 95.0, 25.0);
        }
    }
    jRow = JsonArrayInsert(jRow, NuiSpacer());
    // Add row to the column.
    jCol = JsonArrayInsert (jCol, NuiRow (jRow));
    // Set the layout of the window.
    json jLayout = NuiCol (jCol);
    // Get the window location to restore it from the database.
    string sPCWindow = GetServerDatabaseString (oPC, PLAYER_TABLE, "dmobjectwin");
    float fX = StringToFloat (GetStringArray (sPCWindow, 1));
    float fY = StringToFloat (GetStringArray (sPCWindow, 2));
    string sObjectType;
    if (GetObjectType (oTarget) == OBJECT_TYPE_DOOR) sObjectType = "Door";
    else sObjectType = "Placeable";
    int nToken = SetWindow (oPC, jLayout, "dmobjectwin", sObjectType + " menu",
                            fX, fY, 426.0, fWinHeigth, FALSE, FALSE, TRUE, FALSE, TRUE);
    // Setup watch so we can save this windows position to the database.
    NuiSetBindWatch (oPC, nToken, "window_geometry", TRUE);
    // Set the buttons to show events to 0e_window.
    NuiSetBind (oPC, nToken, "name_value", JsonString (GetName (oTarget)));
    NuiSetBindWatch (oPC, nToken, "name_value", TRUE);
    NuiSetBind (oPC, nToken, "tag_value", JsonString (GetTag (oTarget)));
    NuiSetBindWatch (oPC, nToken, "tag_value", TRUE);
    int nValue = GetPlotFlag (oTarget);
    NuiSetBind (oPC, nToken, "plot_check", JsonBool (nValue));
    NuiSetBindWatch (oPC, nToken, "plot_check", TRUE);
    nValue = GetFortitudeSavingThrow (oTarget);
    NuiSetBind (oPC, nToken, "fort_value", JsonString (IntToString (nValue)));
    NuiSetBindWatch (oPC, nToken, "fort_value", TRUE);
    nValue = GetHardness (oTarget);
    NuiSetBind (oPC, nToken, "hard_value", JsonString (IntToString (nValue)));
    NuiSetBindWatch (oPC, nToken, "hard_value", TRUE);
    nValue = GetReflexSavingThrow (oTarget);
    NuiSetBind (oPC, nToken, "reflex_value", JsonString (IntToString (nValue)));
    NuiSetBindWatch (oPC, nToken, "reflex_value", TRUE);
    nValue = GetCurrentHitPoints (oTarget);
    NuiSetBind (oPC, nToken, "hp_value", JsonString (IntToString (nValue)));
    NuiSetBindWatch (oPC, nToken, "hp_value", TRUE);
    nValue = GetWillSavingThrow (oTarget);
    NuiSetBind (oPC, nToken, "will_value", JsonString (IntToString (nValue)));
    NuiSetBindWatch (oPC, nToken, "will_value", TRUE);
    // Containers
    if (bContainer)
    {
        nValue = GetLocalInt (oTarget, "0_TreasureLevel");
        if (nValue == 0) nValue = GetLocalInt (GetArea (oPC), "0_Area_Level");
        if (nValue == 0) {nValue = 1; SetLocalInt (oTarget, "0_TreasureLevel", 1); }
        NuiSetBind (oPC, nToken, "level_value", JsonString (IntToString (nValue)));
        NuiSetBindWatch (oPC, nToken, "level_value", TRUE);
        nValue = GetEventScript (oTarget, EVENT_SCRIPT_PLACEABLE_ON_OPEN) == "0e_rolltreasure";
        NuiSetBind (oPC, nToken, "gen_treasure_check", JsonBool (nValue));
        NuiSetBindWatch (oPC, nToken, "gen_treasure_check", TRUE);
    }
    // Lock Group
    nValue = GetLocked (oTarget);
    NuiSetBind (oPC, nToken, "locked_check", JsonBool (nValue));
    NuiSetBindWatch (oPC, nToken, "locked_check", TRUE);
    nValue = GetLockLockable (oTarget);
    NuiSetBind (oPC, nToken, "relocked_check", JsonBool (nValue));
    NuiSetBindWatch (oPC, nToken, "relocked_check", TRUE);
    nValue = NWNX_Object_GetAutoRemoveKey (oTarget);
    NuiSetBind (oPC, nToken, "remove_key_check", JsonBool (nValue));
    NuiSetBindWatch (oPC, nToken, "remove_key_check", TRUE);
    nValue = GetLockKeyRequired (oTarget);
    NuiSetBind (oPC, nToken, "key_required_check", JsonBool (nValue));
    NuiSetBindWatch (oPC, nToken, "key_required_check", TRUE);
    string sValue = GetLockKeyTag (oTarget);
    NuiSetBind (oPC, nToken, "key_tag_value", JsonString (sValue));
    NuiSetBindWatch (oPC, nToken, "key_tag_value", TRUE);
    nValue = GetLockUnlockDC (oTarget);
    NuiSetBind (oPC, nToken, "open_dc_value", JsonString (IntToString (nValue)));
    NuiSetBindWatch (oPC, nToken, "open_dc_value", TRUE);
    nValue = GetLockLockDC (oTarget);
    NuiSetBind (oPC, nToken, "close_dc_value", JsonString (IntToString (nValue)));
    NuiSetBindWatch (oPC, nToken, "close_dc_value", TRUE);
    nValue = GetLocalInt (oTarget, "0_BashDC");
    NuiSetBind (oPC, nToken, "bash_dc_value", JsonString (IntToString (nValue)));
    NuiSetBindWatch (oPC, nToken, "bash_dc_value", TRUE);
    // Trap Group
    NuiSetBind (oPC, nToken, "trap_opt_selected", JsonInt (GetTrapBaseType (oTarget)));
    NuiSetBind (oPC, nToken, "trap_opt_event", JsonBool (TRUE));
    NuiSetBindWatch (oPC, nToken, "trap_opt_selected", TRUE);
    nValue = GetLocalInt (oTarget, "0_AOE_Trap");
    NuiSetBind (oPC, nToken, "aoe_check", JsonBool (nValue));
    NuiSetBindWatch (oPC, nToken, "aoe_check", TRUE);
    nValue = GetTrapOneShot (oTarget);
    NuiSetBind (oPC, nToken, "oneshot_check", JsonBool (nValue));
    NuiSetBindWatch (oPC, nToken, "oneshot_check", TRUE);
    nValue = GetTrapDetectable (oTarget);
    NuiSetBind (oPC, nToken, "detect_trap_check", JsonBool (nValue));
    NuiSetBindWatch (oPC, nToken, "detect_trap_check", TRUE);
    nValue = GetTrapDisarmable (oTarget);
    NuiSetBind (oPC, nToken, "disarm_trap_check", JsonBool (nValue));
    NuiSetBindWatch (oPC, nToken, "disarm_trap_check", TRUE);
    nValue = GetTrapDetectDC (oTarget);
    NuiSetBind (oPC, nToken, "detect_dc_value", JsonString (IntToString (nValue)));
    NuiSetBindWatch (oPC, nToken, "detect_dc_value", TRUE);
    nValue = GetTrapDisarmDC (oTarget);
    NuiSetBind (oPC, nToken, "disarm_dc_value", JsonString (IntToString (nValue)));
    NuiSetBindWatch (oPC, nToken, "disarm_dc_value", TRUE);
    nValue = GetLocalInt (oTarget, "0_Trap_Level");
    if (nValue == 0) nValue = GetLocalInt (GetArea (oTarget), "0_Area_Level");
    NuiSetBind (oPC, nToken, "trap_level_value", JsonString (IntToString (nValue)));
    NuiSetBindWatch (oPC, nToken, "trap_level_value", TRUE);
    sValue = GetDescription (oTarget);
    // DC buttons
    NuiSetBind (oPC, nToken, "btn_dc_1_event", JsonBool (TRUE));
    NuiSetBind (oPC, nToken, "btn_dc_2_event", JsonBool (TRUE));
    NuiSetBind (oPC, nToken, "btn_dc_3_event", JsonBool (TRUE));
    NuiSetBind (oPC, nToken, "btn_dc_4_event", JsonBool (TRUE));
    NuiSetBind (oPC, nToken, "btn_dc_5_event", JsonBool (TRUE));
    NuiSetBind (oPC, nToken, "btn_dc_6_event", JsonBool (TRUE));
    NuiSetBind (oPC, nToken, "btn_dc_7_event", JsonBool (TRUE));
    NuiSetBind (oPC, nToken, "btn_dc_8_event", JsonBool (TRUE));
    // Description
    NuiSetBind (oPC, nToken, "desc_value", JsonString (sValue));
    NuiSetBindWatch (oPC, nToken, "desc_value", TRUE);
    NuiSetBind (oPC, nToken, "btn_variables_event", JsonBool (TRUE));
    if (nObjectType == OBJECT_TYPE_DOOR)
    {
        if (GetIsOpen (oTarget)) NuiSetBind (oPC, nToken, "btn_open_label", JsonString ("Close"));
        else NuiSetBind (oPC, nToken, "btn_open_label", JsonString ("Open"));
        NuiSetBind (oPC, nToken, "btn_open_event", JsonBool (TRUE));
    }
    else if (nObjectType == OBJECT_TYPE_PLACEABLE)
    {
        NuiSetBind (oPC, nToken, "btn_move_event", JsonBool (TRUE));
        if (bContainer) NuiSetBind (oPC, nToken, "btn_container", JsonBool (TRUE));
        else NuiSetBind (oPC, nToken, "btn_container", JsonBool (FALSE));
        NuiSetBind (oPC, nToken, "btn_container_event", JsonBool (TRUE));
        if (bContainer) NuiSetBind (oPC, nToken, "btn_inventory_event", JsonBool (TRUE));
    }
}

void PopUpDMTriggerGUIPanel (object oPC)
{
    // Set window to not save until it has been created.
    SetLocalInt (oPC, "0_No_Win_Save", TRUE);
    DelayCommand (0.5f, DeleteLocalInt (oPC, "0_No_Win_Save"));
    // Get the DM target.
    object oTarget = GetLocalObject (oPC, "0_DM_Target");
    // Row 1 (Name)************************************************************* 45
    json jRow = CreateLabel (JsonArray (), "Name", "name_title", 45.0f, 20.0f, -1.0, NUI_HALIGN_LEFT);
    jRow = CreateTextEditBox (jRow, "name_placeholder", "name_value", 30, FALSE, 353.0f, 20.0f);
    // Add row to the column.
    json jCol = JsonArrayInsert (JsonArray (), NuiRow (jRow));
    // Row 2 (Tag)************************************************************** 73
    jRow = CreateLabel (JsonArray (), "Tag", "tag_title", 45.0f, 20.0f, -1.0, NUI_HALIGN_LEFT);
    jRow = CreateTextEditBox (jRow, "name_placeholder", "tag_value", 30, FALSE, 353.0f, 20.0f);
    // Add row to the column.
    jCol = JsonArrayInsert (jCol, NuiRow (jRow));
    // Row 3 (Lock/Trap Groups)************************************************* 101
    // Trap Group
    // Create trap options.
    json jGroupRow = CreateCombo (JsonArray (), JsonArrayInsertTraps (), "trap_opt", 180.0, 20.0);
    json jGroupCol = JsonArrayInsert (JsonArray (), NuiRow (jGroupRow));
    jGroupRow = CreateCheckBox (JsonArray (), "Area of Effect", "aoe", 180.0, 10.0f);
    jGroupCol = JsonArrayInsert (jGroupCol, NuiRow (jGroupRow));
    jGroupRow = CreateCheckBox (JsonArray (), "One shot", "oneshot", 180.0, 10.0f);
    jGroupCol = JsonArrayInsert (jGroupCol, NuiRow (jGroupRow));
    jGroupRow = CreateCheckBox (JsonArray (), "Detectable trap", "detect_trap", 180.0, 10.0f);
    jGroupCol = JsonArrayInsert (jGroupCol, NuiRow (jGroupRow));
    jGroupRow = CreateCheckBox (JsonArray (), "Disarmable trap", "disarm_trap", 180.0, 10.0f);
    jGroupCol = JsonArrayInsert (jGroupCol, NuiRow (jGroupRow));
    jGroupRow = CreateLabel (JsonArray (), "Detection DC", "key_tag_title", 135.0f, 20.0f, -1.0, NUI_HALIGN_LEFT);
    jGroupRow = CreateTextEditBox (jGroupRow, "name_placeholder", "detect_dc_value", 4, FALSE, 45.0f, 20.0f);
    jGroupCol = JsonArrayInsert (jGroupCol, NuiRow (jGroupRow));
    jGroupRow = CreateLabel (JsonArray (), "Disarm DC", "disarm_dc_title", 135.0f, 20.0f, -1.0, NUI_HALIGN_LEFT);
    jGroupRow = CreateTextEditBox (jGroupRow, "name_placeholder", "disarm_dc_value", 4, FALSE, 45.0f, 20.0f);
    jGroupCol = JsonArrayInsert (jGroupCol, NuiRow (jGroupRow));
    jGroupRow = CreateLabel (JsonArray (), "Trap Level", "trap_level_title", 135.0f, 20.0f, -1.0, NUI_HALIGN_LEFT);
    jGroupRow = CreateTextEditBox (jGroupRow, "name_placeholder", "trap_level_value", 4, FALSE, 45.0f, 20.0f);
    // Add group rows to group column and group column to group layout
    jGroupCol = JsonArrayInsert (jGroupCol, NuiRow (jGroupRow));
    json jGroupLayout = NuiCol (jGroupCol);
    // Add group to row.
    jRow = JsonArrayInsert (JsonArray (), NuiWidth (NuiGroup (jGroupLayout), 198.0));
    // Add the row to the column.
    jCol = JsonArrayInsert (jCol, NuiRow (jRow));
    // Row 4 (DC levels)******************************************************** 285
    jGroupRow = CreateButton (JsonArray (), "Area Level", "btn_dc_1", 90.0, 25.0);
    jRow = JsonArrayInsert (jRow, NuiSpacer ());
    jGroupRow = CreateButton (jGroupRow, "Easy", "btn_dc_2", 90.0, 25.0);
    jRow = JsonArrayInsert (jRow, NuiSpacer ());
    jGroupRow = CreateButton (jGroupRow, "Average", "btn_dc_3", 90.0, 25.0);
    jRow = JsonArrayInsert (jRow, NuiSpacer ());
    jGroupRow = CreateButton (jGroupRow, "Tough", "btn_dc_4", 90.0, 25.0);
    // Add group row to the group column.
    jGroupCol = JsonArrayInsert (JsonArray (), NuiRow (jGroupRow));
    // Row 5 (DC levels)******************************************************** 318
    jGroupRow = CreateButton (JsonArray (), "Challenge", "btn_dc_5", 90.0, 25.0);
    jRow = JsonArrayInsert (jRow, NuiSpacer ());
    jGroupRow = CreateButton (jGroupRow, "Formidable", "btn_dc_6", 90.0, 25.0);
    jRow = JsonArrayInsert (jRow, NuiSpacer ());
    jGroupRow = CreateButton (jGroupRow, "Heroic", "btn_dc_7", 90.0, 25.0);
    jRow = JsonArrayInsert (jRow, NuiSpacer ());
    jGroupRow = CreateButton (jGroupRow, "Godly", "btn_dc_8", 90.0, 25.0);
    // Add group rows to group column and group column to group layout
    jGroupCol = JsonArrayInsert (jGroupCol, NuiRow (jGroupRow));
    jGroupLayout = NuiCol (jGroupCol);
    // Add group to row.
    jRow = JsonArrayInsert (JsonArray (), NuiHeight (NuiWidth (NuiGroup (jGroupLayout), 400.0), 74.0));
    // Add the row to the column.
    jCol = JsonArrayInsert (jCol, NuiRow (jRow));
    // Row 6 (Buttons)********************************************************** 633 / 351
    jRow = JsonArray ();
    jRow = JsonArrayInsert (jRow, NuiSpacer());
    jRow = CreateButton (JsonArray (), "Variables", "btn_variables", 95.0, 25.0);
    jRow = JsonArrayInsert(jRow, NuiSpacer());
    // Add row to the column.
    jCol = JsonArrayInsert (jCol, NuiRow (jRow));
    // Set the layout of the window.
    json jLayout = NuiCol (jCol);
    // Get the window location to restore it from the database.
    string sPCWindow = GetServerDatabaseString (oPC, PLAYER_TABLE, "dmobjectwin");
    float fX = StringToFloat (GetStringArray (sPCWindow, 1));
    float fY = StringToFloat (GetStringArray (sPCWindow, 2));
    // Get the window location to restore it from the database.
    int nToken = SetWindow (oPC, jLayout, "dmobjectwin", "Trigger menu",
                            fX, fY, 426.0, 388.0, FALSE, FALSE, TRUE, FALSE, TRUE);
    // Set the buttons to show events to 0e_window.
    NuiSetBind (oPC, nToken, "name_value", JsonString (GetName (oTarget)));
    NuiSetBindWatch (oPC, nToken, "name_value", TRUE);
    NuiSetBind (oPC, nToken, "tag_value", JsonString (GetTag (oTarget)));
    NuiSetBindWatch (oPC, nToken, "tag_value", TRUE);
    // Trap Group
    NuiSetBind (oPC, nToken, "trap_opt_selected", JsonInt (GetTrapBaseType (oTarget)));
    NuiSetBind (oPC, nToken, "trap_opt_event", JsonBool (TRUE));
    NuiSetBindWatch (oPC, nToken, "trap_opt_selected", TRUE);
    int nValue = GetLocalInt (oTarget, "0_AOE_Trap");
    NuiSetBind (oPC, nToken, "aoe_check", JsonBool (nValue));
    NuiSetBindWatch (oPC, nToken, "aoe_check", TRUE);
    nValue = GetTrapOneShot (oTarget);
    NuiSetBind (oPC, nToken, "oneshot_check", JsonBool (nValue));
    NuiSetBindWatch (oPC, nToken, "oneshot_check", TRUE);
    nValue = GetTrapDetectable (oTarget);
    NuiSetBind (oPC, nToken, "detect_trap_check", JsonBool (nValue));
    NuiSetBindWatch (oPC, nToken, "detect_trap_check", TRUE);
    nValue = GetTrapDisarmable (oTarget);
    NuiSetBind (oPC, nToken, "disarm_trap_check", JsonBool (nValue));
    NuiSetBindWatch (oPC, nToken, "disarm_trap_check", TRUE);
    nValue = GetTrapDetectDC (oTarget);
    NuiSetBind (oPC, nToken, "detect_dc_value", JsonString (IntToString (nValue)));
    NuiSetBindWatch (oPC, nToken, "detect_dc_value", TRUE);
    nValue = GetTrapDisarmDC (oTarget);
    NuiSetBind (oPC, nToken, "disarm_dc_value", JsonString (IntToString (nValue)));
    NuiSetBindWatch (oPC, nToken, "disarm_dc_value", TRUE);
    nValue = GetLocalInt (oTarget, "0_Trap_Level");
    if (nValue == 0) nValue = GetLocalInt (GetArea (oTarget), "0_Area_Level");
    NuiSetBind (oPC, nToken, "trap_level_value", JsonString (IntToString (nValue)));
    NuiSetBindWatch (oPC, nToken, "trap_level_value", TRUE);
    string sValue = GetDescription (oTarget);
    // DC buttons
    NuiSetBind (oPC, nToken, "btn_dc_1_event", JsonBool (TRUE));
    NuiSetBind (oPC, nToken, "btn_dc_2_event", JsonBool (TRUE));
    NuiSetBind (oPC, nToken, "btn_dc_3_event", JsonBool (TRUE));
    NuiSetBind (oPC, nToken, "btn_dc_4_event", JsonBool (TRUE));
    NuiSetBind (oPC, nToken, "btn_dc_5_event", JsonBool (TRUE));
    NuiSetBind (oPC, nToken, "btn_dc_6_event", JsonBool (TRUE));
    NuiSetBind (oPC, nToken, "btn_dc_7_event", JsonBool (TRUE));
    NuiSetBind (oPC, nToken, "btn_dc_8_event", JsonBool (TRUE));
    NuiSetBind (oPC, nToken, "btn_variables_event", JsonBool (TRUE));
}

void PopUpDMInventoryGUIPanel (object oPC)
{
    // Set window to not save until it has been created.
    SetLocalInt (oPC, "0_No_Win_Save", TRUE);
    DelayCommand (0.5f, DeleteLocalInt (oPC, "0_No_Win_Save"));
    // Get the DM target.
    object oTarget = GetLocalObject (oPC, "0_DM_Target");
    // Row 1 (Treasure labels)************************************************** 45
    json jRow = JsonArrayInsert (JsonArray (), NuiSpacer ());
    jRow = CreateLabel (jRow, "Treasure Type", "treasure_type_title", 150.0f, 10.0f);
    jRow = JsonArrayInsert (jRow, NuiSpacer ());
    jRow = CreateLabel (jRow, "Treasure Level", "treasure_level_title", 150.0f, 10.0f);
    jRow = JsonArrayInsert (jRow, NuiSpacer ());
    // Add row to the column.
    json jCol = JsonArrayInsert (JsonArray (), NuiRow (jRow));
    // Row 2 (Type of treasure and level)*************************************** 63
    // Insert elements into the combo box array.
    jRow = JsonArrayInsert(JsonArray (), NuiSpacer());
    json jCombo = JsonArrayInsert (JsonArray (), NuiComboEntry ("Any", 0));
    jCombo = JsonArrayInsert (jCombo, NuiComboEntry ("Weapon", 1));
    jCombo = JsonArrayInsert (jCombo, NuiComboEntry ("Simple Weapon", 2));
    jCombo = JsonArrayInsert (jCombo, NuiComboEntry ("Martial Weapon", 3));
    jCombo = JsonArrayInsert (jCombo, NuiComboEntry ("Exotic Weapon", 4));
    jCombo = JsonArrayInsert (jCombo, NuiComboEntry ("Melee Weapon", 5));
    jCombo = JsonArrayInsert (jCombo, NuiComboEntry ("Thrown Weapon", 6));
    jCombo = JsonArrayInsert (jCombo, NuiComboEntry ("Ranged Weapon", 7));
    jCombo = JsonArrayInsert (jCombo, NuiComboEntry ("Arrows", 8));
    jCombo = JsonArrayInsert (jCombo, NuiComboEntry ("Bolts", 9));
    jCombo = JsonArrayInsert (jCombo, NuiComboEntry ("Bullets", 10));
    jCombo = JsonArrayInsert (jCombo, NuiComboEntry ("Armor", 11));
    jCombo = JsonArrayInsert (jCombo, NuiComboEntry ("Light Armor", 12));
    jCombo = JsonArrayInsert (jCombo, NuiComboEntry ("Medium Armor", 13));
    jCombo = JsonArrayInsert (jCombo, NuiComboEntry ("Heavy Armor", 14));
    jCombo = JsonArrayInsert (jCombo, NuiComboEntry ("Shields", 15));
    jCombo = JsonArrayInsert (jCombo, NuiComboEntry ("Wondrous Items", 16));
    jCombo = JsonArrayInsert (jCombo, NuiComboEntry ("Amulets", 17));
    jCombo = JsonArrayInsert (jCombo, NuiComboEntry ("Belts", 18));
    jCombo = JsonArrayInsert (jCombo, NuiComboEntry ("Boots", 19));
    jCombo = JsonArrayInsert (jCombo, NuiComboEntry ("Bracers", 20));
    jCombo = JsonArrayInsert (jCombo, NuiComboEntry ("Cloaks", 21));
    jCombo = JsonArrayInsert (jCombo, NuiComboEntry ("Clothing", 22));
    jCombo = JsonArrayInsert (jCombo, NuiComboEntry ("Gloves", 23));
    jCombo = JsonArrayInsert (jCombo, NuiComboEntry ("Helmets", 24));
    jCombo = JsonArrayInsert (jCombo, NuiComboEntry ("Head Gear", 25));
    jCombo = JsonArrayInsert (jCombo, NuiComboEntry ("Potions", 26));
    jCombo = JsonArrayInsert (jCombo, NuiComboEntry ("Rings", 27));
    jCombo = JsonArrayInsert (jCombo, NuiComboEntry ("Unique Items", 28));
    jRow = CreateCombo (jRow, jCombo, "treasure_type", 150.0, 25.0);
    jRow = JsonArrayInsert (jRow, NuiSpacer ());
    // Add Treasure level combo
    int nObjectLevel, nLevel, nCount = 0;
    string sText;
    int nObjectType = GetObjectType (oTarget);
    if (nObjectType == OBJECT_TYPE_CREATURE) nLevel = GetCharacterLevels (oTarget);
    else if (nObjectType == OBJECT_TYPE_PLACEABLE)
    {
        nLevel = GetLocalInt (oTarget, "0_TreasureLevel");
        if (nLevel == 0) GetLocalInt (GetArea (oTarget), "0_Area_Level");
    }
    jCombo = JsonArray ();
    while (nCount < 20)
    {
        sText = IntToString (nCount + 1);
        if (nCount + 1 == nLevel)
        {
            sText = sText + " Target Level";
            nObjectLevel = nCount;
        }
        jCombo = JsonArrayInsert (jCombo, NuiComboEntry (sText, nCount));
        nCount ++;
    }
    jRow = CreateCombo (jRow, jCombo, "treasure_level", 150.0, 25.0);
    jRow = JsonArrayInsert (jRow, NuiSpacer ());
    // Add the row to the column.
    jCol = JsonArrayInsert (jCol, NuiRow (jRow));
    // Row 3 (Treasure buttons)************************************************* 96
    jRow = CreateButton (JsonArray (), "Give Item", "btn_give_treasure", 130.0, 20.0);
    jRow = JsonArrayInsert (jRow, NuiSpacer());
    jRow = CreateButton (jRow, "Fully Equip", "btn_fully_equip", 130.0, 20.0);
    jRow = JsonArrayInsert (jRow, NuiSpacer());
    jRow = CreateButton (jRow, "Generate Loot", "btn_gen_loot", 130.0, 20.0);
    // Add the row to the column.
    jCol = JsonArrayInsert (jCol, NuiRow (jRow));
    // Row 4 (Identify/Droppable)*********************************************** 124
    jRow = CreateButton (JsonArray (), "Identify All", "btn_id_all", 130.0, 20.0);
    jRow = JsonArrayInsert(jRow, NuiSpacer());
    jRow = CreateButton (jRow, "All Droppable", "btn_all_drop", 130.0, 20.0);
    jRow = JsonArrayInsert (jRow, NuiSpacer());
    jRow = CreateButton (jRow, "None Droppable", "btn_none_drop", 130.0, 20.0);
    // Add the row to the column.
    jCol = JsonArrayInsert (jCol, NuiRow (jRow));
    // Row 4 (Destroy Inventory)************************************************ 152
    jRow = CreateButton (JsonArray (), "Destory all Items", "btn_destroy_all", 200.0, 20.0);
    jRow = JsonArrayInsert(jRow, NuiSpacer());
    jRow = CreateButton (jRow, "Destroy all unequiped", "btn_destroy_unequip", 200.0, 20.0);
    // Add the row to the column.
    jCol = JsonArrayInsert (jCol, NuiRow (jRow));
    // Set the layout of the window.
    json jLayout = NuiCol (jCol);
    // Get the window location to restore it from the database.
    string sPCWindow = GetServerDatabaseString (oPC, PLAYER_TABLE, "dminventorywin");
    float fX = StringToFloat (GetStringArray (sPCWindow, 1));
    float fY = StringToFloat (GetStringArray (sPCWindow, 2));
    string sName = StripColorCodes (GetName (oTarget));
    int nToken = SetWindow (oPC, jLayout, "dminventorywin", sName + "'s inventory menu",
                            fX, fY, 428.0, 184.0, FALSE, FALSE, TRUE, FALSE, TRUE);
    // Setup watch so we can save this windows position to the database.
    NuiSetBindWatch (oPC, nToken, "window_geometry", TRUE);
    // Set the buttons to show events to 0e_window.
    NuiSetBind (oPC, nToken, "treasure_type_selected", JsonInt (0));
    NuiSetBind (oPC, nToken, "treasure_level_selected", JsonInt (nObjectLevel));
    NuiSetBind (oPC, nToken, "treasure_type_event", JsonBool (TRUE));
    NuiSetBind (oPC, nToken, "treasure_level_event", JsonBool (TRUE));
    NuiSetBind (oPC, nToken, "btn_give_treasure_event", JsonBool (TRUE));
    NuiSetBind (oPC, nToken, "btn_fully_equip_event", JsonBool (TRUE));
    NuiSetBind (oPC, nToken, "btn_gen_loot_event", JsonBool (TRUE));
    NuiSetBind (oPC, nToken, "btn_id_all_event", JsonBool (TRUE));
    NuiSetBind (oPC, nToken, "btn_all_drop_event", JsonBool (TRUE));
    NuiSetBind (oPC, nToken, "btn_none_drop_event", JsonBool (TRUE));
    if (!GetIsPC (oTarget))
    {
        NuiSetBind (oPC, nToken, "btn_destroy_all_event", JsonBool (TRUE));
        NuiSetBind (oPC, nToken, "btn_destroy_unequip_event", JsonBool (TRUE));
    }
}

void PopUpDMMovePlaceableGUIPanel (object oPC)
{
    // Get the DM target.
    object oTarget = GetLocalObject (oPC, "0_DM_Target");
    // Row 1 (RotateRight/North/RotateLeft)************************************* 45
    json jRow = JsonArrayInsert (JsonArray (), NuiSpacer());
    jRow = CreateButton (jRow, "Rotate Right", "btn_rotate_right", 110.0, 25.0);
    jRow = JsonArrayInsert (jRow, NuiSpacer());
    jRow = CreateButton (jRow, "North", "btn_north", 110.0, 25.0);
    jRow = JsonArrayInsert (jRow, NuiSpacer());
    jRow = CreateButton (jRow, "Rotate Left", "btn_rotate_left", 110.0, 25.0);
    jRow = JsonArrayInsert(jRow, NuiSpacer());
    // Add the row to the column.
    json jCol = JsonArrayInsert (JsonArray (), NuiRow (jRow));
    // Row 2 (West/Reset/East)************************************************** 78
    jRow = CreateButton (JsonArray (), "West", "btn_west", 110.0, 25.0);
    jRow = CreateButton (jRow, "Reset", "btn_reset", 110.0, 25.0);
    jRow = CreateButton (jRow, "East", "btn_east", 110.0, 25.0);
    // Add the row to the column.
    jCol = JsonArrayInsert (jCol, NuiRow (jRow));
    // Row 3 (Up/South/Down)**************************************************** 111
    jRow = CreateButton (JsonArray (), "Up", "btn_up", 110.0, 25.0);
    jRow = CreateButton (jRow, "South", "btn_south", 110.0, 25.0);
    jRow = CreateButton (jRow, "Down", "btn_down", 110.0, 25.0);
    // Add the row to the column.
    jCol = JsonArrayInsert (jCol, NuiRow (jRow));
    // Row 5 (Placeable label)************************************************** 144
    jRow = JsonArrayInsert (JsonArray (), NuiSpacer());
    jRow = CreateLabel (jRow, "", "name", 300.0, 25.0, -1.0, NUI_HALIGN_CENTER, NUI_VALIGN_MIDDLE);
    jRow = JsonArrayInsert (jRow, NuiSpacer());
    // Add the row to the column.
    jCol = JsonArrayInsert (jCol, NuiRow (jRow));
    // Row 5 (Destroy)********************************************************** 177
    jRow = CreateButton (JsonArray (), "Get Placeable", "btn_get_placeable", 167.0, 25.0);
    jRow = CreateButton (jRow, "Destroy", "btn_destroy", 167.0, 25.0);
    // Add the row to the column.
    jCol = JsonArrayInsert (jCol, NuiRow (jRow));
    // Set the layout of the window.
    json jLayout = NuiCol (jCol);
    string sName = StripColorCodes (GetName (oTarget));
    int nToken = SetWindow (oPC, jLayout, "dmmoveplaceablewin", "Placeable menu",
                            -3.0, -3.0, 362.0, 214.0, FALSE, FALSE, TRUE, FALSE, TRUE);
    // Set the buttons to show events to 0e_window.
    if (NWNX_Object_GetPlaceableIsStatic (oTarget))
    {
        NuiSetBind (oPC, nToken, "btn_rotate_right_event", JsonBool (FALSE));
        NuiSetBind (oPC, nToken, "btn_north_event", JsonBool (FALSE));
        NuiSetBind (oPC, nToken, "btn_rotate_left_event", JsonBool (FALSE));
        NuiSetBind (oPC, nToken, "btn_west_event", JsonBool (FALSE));
        NuiSetBind (oPC, nToken, "btn_reset_event", JsonBool (FALSE));
        NuiSetBind (oPC, nToken, "btn_east_event", JsonBool (FALSE));
        NuiSetBind (oPC, nToken, "btn_up_event", JsonBool (FALSE));
        NuiSetBind (oPC, nToken, "btn_south_event", JsonBool (FALSE));
        NuiSetBind (oPC, nToken, "btn_down_event", JsonBool (FALSE));
        NuiSetBind (oPC, nToken, "btn_destroy_event", JsonBool (FALSE));
    }
    else
    {
        SetLocalLocation (oTarget, "0_Reset_Location", GetLocation (oTarget));
        NuiSetBind (oPC, nToken, "btn_rotate_right_event", JsonBool (TRUE));
        NuiSetBind (oPC, nToken, "btn_north_event", JsonBool (TRUE));
        NuiSetBind (oPC, nToken, "btn_rotate_left_event", JsonBool (TRUE));
        NuiSetBind (oPC, nToken, "btn_west_event", JsonBool (TRUE));
        NuiSetBind (oPC, nToken, "btn_reset_event", JsonBool (TRUE));
        NuiSetBind (oPC, nToken, "btn_east_event", JsonBool (TRUE));
        NuiSetBind (oPC, nToken, "btn_up_event", JsonBool (TRUE));
        NuiSetBind (oPC, nToken, "btn_south_event", JsonBool (TRUE));
        NuiSetBind (oPC, nToken, "btn_down_event", JsonBool (TRUE));
        NuiSetBind (oPC, nToken, "btn_destroy_event", JsonBool (TRUE));
    }
    NuiSetBind (oPC, nToken, "btn_get_placeable_event", JsonBool (TRUE));
    NuiSetBind (oPC, nToken, "name_label", JsonString (GetName (oTarget)));
}

void PopUpDMItemGUIPanel (object oPC)
{
    // Get the DM target.
    object oTarget = GetLocalObject (oPC, "0_DM_Target");
    // Row 1 (Name)************************************************************* 45
    json jRow = CreateLabel (JsonArray (), "Name", "name_title", 35.0f, 20.0f, -1.0, NUI_HALIGN_LEFT);
    jRow = CreateTextEditBox (jRow, "name_placeholder", "name_value", 60, FALSE, 303.0f, 20.0f);
    // Add row to the column.
    json jCol = JsonArrayInsert (JsonArray (), NuiRow (jRow));
    // Row 2 (Tag)************************************************************** 73
    jRow = CreateLabel (JsonArray (), "Tag", "tag_title", 35.0f, 20.0f, -1.0, NUI_HALIGN_LEFT);
    jRow = CreateTextEditBox (jRow, "name_placeholder", "tag_value", 60, FALSE, 303.0f, 20.0f);
    // Row 3 (Base Item/Weight)************************************************* 101
    jRow = CreateLabel (JsonArray (), "Base Item: ", "baseitem_title", 75.0f, 20.0f, -1.0, NUI_HALIGN_LEFT);
    jRow = CreateLabel (jRow, "", "baseitem", 114.0f, 20.0f, -1.0, NUI_HALIGN_LEFT);
    jRow = CreateLabel (jRow, "Weight: ", "weight_title", 55.0f, 20.0f, -1.0, NUI_HALIGN_LEFT);
    jRow = CreateLabel (jRow, "", "weight", 86.0f, 20.0f, -1.0,NUI_HALIGN_LEFT);
    // Add row to the column.
    jCol = JsonArrayInsert (jCol, NuiRow (jRow));
    // Row 4 (Gold Value)******************************************************* 129
    jRow = CreateLabel (JsonArray (), "Gold Base: ", "base_gold_title", 75.0f, 20.0f, -1.0, NUI_HALIGN_LEFT);
    jRow = CreateLabel (jRow, "", "base_gold", 105.0f, 20.0f, -1.0, NUI_HALIGN_LEFT);
    jRow = CreateLabel (jRow, "Added", "add_gold_title", 45.0f, 20.0f, -1.0, NUI_HALIGN_LEFT);
    jRow = CreateTextEditBox  (jRow, "name_placeholder", "add_gold_value", 10, FALSE, 105.0f, 20.0f);
    // Add row to the column.
    jCol = JsonArrayInsert (jCol, NuiRow (jRow));
    // Row 5 (Plot/Stolen)****************************************************** 157
    jRow = CreateCheckBox (JsonArray (), " Plot", "plot", 180.0, 20.0f);
    jRow = CreateCheckBox (jRow, " Stolen", "stolen", 158.0, 20.0f);
    // Add row to the column.
    jCol = JsonArrayInsert (jCol, NuiRow (jRow));
    // Row 6 (Identified/Droppable)********************************************* 185
    jRow = CreateCheckBox (JsonArray (), " Identified", "identified", 180.0, 20.0f);
    jRow = CreateCheckBox (jRow, " Droppable", "droppable", 158.0, 20.0f);
    // Add row to the column.
    jCol = JsonArrayInsert (jCol, NuiRow (jRow));
    // Create quality options.
    // Row 7 (Quality/Creator)************************************************** 213
    // Insert elements into the combo box array.
    json jCombo = JsonArrayInsert (JsonArray (), NuiComboEntry ("None", 0));
    jCombo = JsonArrayInsert (jCombo, NuiComboEntry ("Masterwork", 1));
    jCombo = JsonArrayInsert (jCombo, NuiComboEntry ("Exquisite", 2));
    jCombo = JsonArrayInsert (jCombo, NuiComboEntry ("Legendary", 3));
    jCombo = JsonArrayInsert (jCombo, NuiComboEntry ("Relic", 4));
    jCombo = JsonArrayInsert (jCombo, NuiComboEntry ("Artifact", 5));
    jRow = CreateCombo (JsonArray (), jCombo, "quality", 169.0, 25.0);
    jRow = CreateLabel (jRow, "Creator: ", "creator_title", 55.0f, 20.0f, -1.0, NUI_HALIGN_LEFT);
    jRow = CreateLabel (jRow, "", "creator", 110.0f, 20.0f, -1.0, NUI_HALIGN_LEFT);
    jCol = JsonArrayInsert (jCol, NuiRow (jRow));
    // Row 8 (Base Item/Weight)************************************************* 241
    jRow = CreateLabel (JsonArray (), "Minimum Level: ", "min_lvl_title", 105.0f, 20.0f, -1.0, NUI_HALIGN_LEFT);
    jRow = CreateLabel (jRow, "", "min_lvl", 60.0f, 20.0f, -1.0, NUI_HALIGN_LEFT);
    jRow = CreateLabel (jRow, "Binded: ", "binded_title", 55.0f, 20.0f, -1.0, NUI_HALIGN_LEFT);
    jRow = CreateLabel (jRow, "", "binded", 110.0f, 20.0f, -1.0, NUI_HALIGN_LEFT);
    // Add row to the column.
    jCol = JsonArrayInsert (jCol, NuiRow (jRow));
    // Row 9 (Stack/Variables/Destroy/Charges)********************************** 269
    jRow = CreateButton (JsonArray (), "Variables", "btn_variables", 80.0, 25.0);
    jRow = CreateLabel (jRow, "Stack", "stack_title", 50.0f, 20.0f, -1.0, NUI_HALIGN_LEFT);
    jRow = CreateTextEditBox (jRow, "name_placeholder", "stack_value", 4, FALSE, 35.0f, 25.0f);
    jRow = CreateLabel (jRow, "Charges", "charges_title", 60.0f, 20.0f, -1.0, NUI_HALIGN_LEFT);
    jRow = CreateTextEditBox (jRow, "name_placeholder", "charges_value", 4, FALSE, 35.0f, 25.0f);
    jRow = CreateButton (jRow, "Destroy", "btn_destroy", 80.0, 25.0);
    // Add row to the column.
    jCol = JsonArrayInsert (jCol, NuiRow (jRow));
    // Row 11 (Description)***************************************************** 302
    jRow = CreateTextEditBox (JsonArray (), "desc_placeholder", "desc_value", 1000, TRUE, 342.0, 150.0, "desc_tooltip");
    // Add row to the column.
    jCol = JsonArrayInsert (jCol, NuiRow (jRow));
    // Set the layout of the window.
    json jLayout = NuiCol (jCol);
    object oOwner = GetItemPossessor (oTarget);
    string sName = StripColorCodes (GetName (oOwner));
    int nToken = SetWindow (oPC, jLayout, "dmitemwin", sName + "'s item menu",
                            -3.0, -3.0, 366.0, 464.0, FALSE, FALSE, TRUE, FALSE, TRUE);
    // Set the buttons to show events to 0e_window.
    NuiSetBind (oPC, nToken, "name_value", JsonString (GetName (oTarget)));
    NuiSetBindWatch (oPC, nToken, "name_value", TRUE);
    NuiSetBind (oPC, nToken, "tag_value", JsonString (GetTag (oTarget)));
    NuiSetBindWatch (oPC, nToken, "tag_value", TRUE);
    int nBaseItemType = GetBaseItemType (oTarget);
    string sValue = Get2DAString ("baseitems", "label", nBaseItemType);
    NuiSetBind (oPC, nToken, "baseitem_label", JsonString (sValue));
    float fValue = StringToFloat (Get2DAString ("baseitems", "TenthLBS", nBaseItemType));
    sValue = FloatToString (fValue * 0.1f, 0, 1);
    NuiSetBind (oPC, nToken, "weight_label", JsonString (sValue));
    int nValue = NWNX_Item_GetBaseGoldPieceValue (oTarget);
    NuiSetBind (oPC, nToken, "base_gold_label", JsonString (IntToString (nValue)));
    nValue = NWNX_Item_GetAddGoldPieceValue (oTarget);
    NuiSetBind (oPC, nToken, "add_gold_value", JsonString (IntToString (nValue)));
    NuiSetBindWatch (oPC, nToken, "add_gold_value", TRUE);
    nValue = GetPlotFlag (oTarget);
    NuiSetBind (oPC, nToken, "plot_check", JsonBool (nValue));
    NuiSetBindWatch (oPC, nToken, "plot_check", TRUE);
    nValue = GetStolenFlag (oTarget);
    NuiSetBind (oPC, nToken, "stolen_check", JsonBool (nValue));
    NuiSetBindWatch (oPC, nToken, "stolen_check", TRUE);
    nValue = GetIdentified (oTarget);
    NuiSetBind (oPC, nToken, "identified_check", JsonBool (nValue));
    NuiSetBindWatch (oPC, nToken, "identified_check", TRUE);
    nValue = GetDroppableFlag (oTarget);
    NuiSetBind (oPC, nToken, "droppable_check", JsonBool (nValue));
    NuiSetBindWatch (oPC, nToken, "droppable_check", TRUE);
    itemproperty ipQuality = HasProperty (oTarget, 86);
    int nQuality = GetItemPropertyCostTableValue (ipQuality);
    NuiSetBind (oPC, nToken, "quality_selected", JsonInt (nQuality));
    NuiSetBind (oPC, nToken, "quality_event", JsonBool (TRUE));
    NuiSetBindWatch (oPC, nToken, "quality_selected", TRUE);
    sValue = GetLocalString (oTarget, "0_Creator");
    NuiSetBind (oPC, nToken, "creator_label", JsonString (sValue));
    sValue = IntToString (NWNX_Item_GetMinEquipLevel (oTarget));
    NuiSetBind (oPC, nToken, "min_lvl_label", JsonString (sValue));
    sValue = GetLocalString (oTarget, "0_Binded");
    NuiSetBind (oPC, nToken, "binded_label", JsonString (sValue));
    nValue = GetItemStackSize (oTarget);
    NuiSetBind (oPC, nToken, "stack_value", JsonString (IntToString (nValue)));
    NuiSetBindWatch (oPC, nToken, "stack_value", TRUE);
    nValue = GetItemCharges (oTarget);
    NuiSetBind (oPC, nToken, "charges_value", JsonString (IntToString (nValue)));
    NuiSetBindWatch (oPC, nToken, "charges_value", TRUE);
    // Description
    NuiSetBindWatch (oPC, nToken, "desc_value", TRUE);
    NuiSetBind (oPC, nToken, "desc_tooltip", JsonString ("Color codes can be used!"));
    sValue = GetDescription (oTarget);
    NuiSetBind (oPC, nToken, "desc_value", JsonString (sValue));
    NuiSetBind (oPC, nToken, "btn_destroy_event", JsonBool (TRUE));
    NuiSetBind (oPC, nToken, "btn_variables_event", JsonBool (TRUE));
}

void PopUpDMQuestItemGUIPanel(object oPC)
{
    // Set window to not save until it has been created.
    SetLocalInt(oPC, "0_No_Win_Save", TRUE);
    DelayCommand(0.5f, DeleteLocalInt(oPC, "0_No_Win_Save"));
    // Get the DM target.
    object oTarget = GetLocalObject(oPC, "0_DM_Target");
    // Row 1 (Name)************************************************************* 45
    json jRow = CreateLabel(JsonArray(), "Name", "name_title", 38.0f, 20.0f, -1.0, NUI_HALIGN_LEFT);
    jRow = CreateTextEditBox(jRow, "name_placeholder", "name_value", 60, FALSE, 300.0f, 20.0f);
    json jCol = JsonArrayInsert(JsonArray(), NuiRow(jRow));
    // Row 2 (strref/plot)****************************************************** 73
    jRow = CreateLabel (JsonArray(), "StrRef", "strref_title", 45.0f, 20.0f, -1.0, NUI_HALIGN_LEFT);
    jRow = CreateLabel (jRow, "", "strref", 65.0f, 20.0f, -1.0, NUI_HALIGN_RIGHT);
    // Insert elements into the combo box array.
    json jCombo = JsonArrayInsert(JsonArray(), NuiComboEntry("1: Destroy object", 0));
    jCombo = JsonArrayInsert(jCombo, NuiComboEntry("2: Deliver item", 1));
    jCombo = JsonArrayInsert(jCombo, NuiComboEntry("3: Retrieve item", 2));
    jCombo = JsonArrayInsert(jCombo, NuiComboEntry("4: Find npc", 3));
    jCombo = JsonArrayInsert(jCombo, NuiComboEntry("5: Kill villain", 4));
    jCombo = JsonArrayInsert(jCombo, NuiComboEntry("6: Take npc to finish area", 5));
    jCombo = JsonArrayInsert(jCombo, NuiComboEntry("7: Take npc to finisher", 6));
    jCombo = JsonArrayInsert(jCombo, NuiComboEntry("8: Clear area of monsters", 7));
    jCombo = JsonArrayInsert(jCombo, NuiComboEntry("9: Talk to npc", 8));
    jCombo = JsonArrayInsert(jCombo, NuiComboEntry("10: Do x special tasks", 9));
    jRow = CreateLabel(jRow, " Plot:", "plot_title", 35.0f, 20.0f, -1.0, NUI_HALIGN_LEFT);
    jRow = CreateCombo(jRow, jCombo, "plot", 190.0, 25.0);
    jCol = JsonArrayInsert(jCol, NuiRow(jRow));
    // Row 3 (Quest)************************************************************ 101
    jRow = CreateLabel(JsonArray(), "Quest", "quest_title", 70.0f, 20.0f, -1.0, NUI_HALIGN_LEFT, 0, "quest_tooltip");
    jRow = CreateTextEditBox(jRow, "name_placeholder", "quest_value", 200, FALSE, 268.0f, 20.0f, "quest_tooltip");
    jCol = JsonArrayInsert(jCol, NuiRow(jRow));
    // Row 4 (Start location)*************************************************** 129
    jRow = CreateLabel(JsonArray(), "Start Loc", "startloc_title", 70.0f, 20.0f, -1.0, NUI_HALIGN_LEFT, 0, "start_tooltip");
    jRow = CreateTextEditBox(jRow, "name_placeholder", "startloc_value", 200, FALSE, 268.0f, 20.0f, "start_tooltip");
    // Add row to the column.
    jCol = JsonArrayInsert(jCol, NuiRow(jRow));
    // Row 5 (Quest giver)****************************************************** 157
    jRow = CreateLabel(JsonArray(), "Giver", "giver_title", 70.0f, 20.0f, -1.0, NUI_HALIGN_LEFT, 0, "npc_tooltip");
    jRow = CreateTextEditBox(jRow, "name_placeholder", "giver_value", 200, FALSE, 268.0f, 20.0f, "npc_tooltip");
    // Add row to the column.
    jCol = JsonArrayInsert(jCol, NuiRow(jRow));
    // Row 6 (Area)************************************************************* 185
    jRow = CreateLabel (JsonArray(), "Area", "area_title", 70.0f, 20.0f, -1.0, NUI_HALIGN_LEFT, 0, "area_tooltip");
    jRow = CreateTextEditBox(jRow, "name_placeholder", "area_value", 200, FALSE, 268.0f, 20.0f, "area_tooltip");
    jCol = JsonArrayInsert (jCol, NuiRow(jRow));
    // Create quality options.
    // Row 7 (NPC)************************************************************** 213
    jRow = CreateLabel (JsonArray(), "NPC", "npc_title", 70.0f, 20.0f, -1.0, NUI_HALIGN_LEFT, 0, "npc_tooltip");
    jRow = CreateTextEditBox(jRow, "name_placeholder", "npc_value", 200, FALSE, 268.0f, 20.0f, "npc_tooltip");
    jCol = JsonArrayInsert (jCol, NuiRow(jRow));
    // Row 8 (Villain)********************************************************** 241
    jRow = CreateLabel (JsonArray(), "Villain", "villain_title", 70.0f, 20.0f, -1.0, NUI_HALIGN_LEFT, 0, "npc_tooltip");
    jRow = CreateTextEditBox (jRow, "name_placeholder", "villain_value", 200, FALSE, 268.0f, 20.0f, "npc_tooltip");
    jCol = JsonArrayInsert (jCol, NuiRow(jRow));
    // Row 9 (Creatures)******************************************************** 269
    jRow = CreateLabel (JsonArray(), "Creatures", "creatures_title", 70.0f, 20.0f, -1.0, NUI_HALIGN_LEFT, 0, "creatures_tooltip");
    jRow = CreateTextEditBox(jRow, "name_placeholder", "creatures_value", 200, FALSE, 268.0f, 20.0f, "creatures_tooltip");
    jCol = JsonArrayInsert(jCol, NuiRow(jRow));
    // Row 10 (Enemies)********************************************************** 297
    jRow = CreateLabel(JsonArray(), "Enemies", "enemies_title", 70.0f, 20.0f, -1.0, NUI_HALIGN_LEFT, 0, "creatures_tooltip");
    jRow = CreateTextEditBox(jRow, "name_placeholder", "enemies_value", 200, FALSE, 268.0f, 20.0f, "creatures_tooltip");
    jCol = JsonArrayInsert(jCol, NuiRow(jRow));
    // Row 10 (Allies)********************************************************** 325
    jRow = CreateLabel(JsonArray(), "Allies", "allies_title", 70.0f, 20.0f, -1.0, NUI_HALIGN_LEFT, 0, "creatures_tooltip");
    jRow = CreateTextEditBox(jRow, "name_placeholder", "allies_value", 200, FALSE, 268.0f, 20.0f, "creatures_tooltip");
    jCol = JsonArrayInsert(jCol, NuiRow(jRow));
    // Row 11 (Followers)******************************************************* 353
    jRow = CreateLabel(JsonArray(), "Followers", "followers_title", 70.0f, 20.0f, -1.0, NUI_HALIGN_LEFT, 0, "creatures_tooltip");
    jRow = CreateTextEditBox(jRow, "name_placeholder", "followers_value", 200, FALSE, 268.0f, 20.0f, "creatures_tooltip");
    jCol = JsonArrayInsert(jCol, NuiRow(jRow));
    // Row 12 (Give item)******************************************************* 381
    jRow = CreateLabel(JsonArray(), "Give Item", "giveitem_title", 70.0f, 20.0f, -1.0, NUI_HALIGN_LEFT, 0, "giveitem_tooltip");
    jRow = CreateTextEditBox(jRow, "name_placeholder", "giveitem_value", 200, FALSE, 268.0f, 20.0f, "giveitem_tooltip");
    jCol = JsonArrayInsert(jCol, NuiRow(jRow));
    // Row 13 (Plot item)******************************************************* 409
    jRow = CreateLabel(JsonArray(), "Plot Item", "plotitem_title", 70.0f, 20.0f, -1.0, NUI_HALIGN_LEFT, 0, "item_tooltip");
    jRow = CreateTextEditBox(jRow, "name_placeholder", "plotitem_value", 200, FALSE, 268.0f, 20.0f, "item_tooltip");
    jCol = JsonArrayInsert(jCol, NuiRow(jRow));
    // Row 14 (placeable)******************************************************* 437
    jRow = CreateLabel(JsonArray(), "Placeable", "placeable_title", 70.0f, 20.0f, -1.0, NUI_HALIGN_LEFT, 0, "placeable_tooltip");
    jRow = CreateTextEditBox(jRow, "name_placeholder", "placeable_value", 200, FALSE, 268.0f, 20.0f, "placeable_tooltip");
    jCol = JsonArrayInsert(jCol, NuiRow(jRow));
    // Row 14 (fplaceable)****************************************************** 465
    jRow = CreateLabel(JsonArray(), "Fin Placeable", "fplaceable_title", 70.0f, 20.0f, -1.0, NUI_HALIGN_LEFT, 0, "placeable_tooltip");
    jRow = CreateTextEditBox(jRow, "name_placeholder", "fplaceable_value", 200, FALSE, 268.0f, 20.0f, "placeable_tooltip");
    jCol = JsonArrayInsert(jCol, NuiRow(jRow));
    // Row 15 (Finish location)************************************************* 493
    jRow = CreateLabel(JsonArray(), "Finish Loc", "finloc_title", 70.0f, 20.0f, -1.0, NUI_HALIGN_LEFT, 0, "area_tooltip");
    jRow = CreateTextEditBox(jRow, "name_placeholder", "finloc_value", 200, FALSE, 268.0f, 20.0f, "area_tooltip");
    jCol = JsonArrayInsert(jCol, NuiRow(jRow));
    // Row 16 (Finisher)*******************************************************  521
    jRow = CreateLabel(JsonArray(), "Finisher", "finisher_title", 70.0f, 20.0f, -1.0, NUI_HALIGN_LEFT, 0, "npc_tooltip");
    jRow = CreateTextEditBox(jRow, "name_placeholder", "finisher_value", 200, FALSE, 268.0f, 20.0f, "npc_tooltip");
    jCol = JsonArrayInsert(jCol, NuiRow(jRow));
    // Row 17 (Rewards)********************************************************* 549
    jRow = CreateLabel(JsonArray(), "Rewards", "rewards_title", 70.0f, 20.0f, -1.0, NUI_HALIGN_LEFT, 0, "rewards_tooltip");
    jRow = CreateTextEditBox(jRow, "name_placeholder", "rewards_value", 200, FALSE, 268.0f, 20.0f, "rewards_tooltip");
    jCol = JsonArrayInsert (jCol, NuiRow(jRow));
    // Row 18 (States)********************************************************** 577
    jRow = CreateLabel(JsonArray(), "States", "states_title", 70.0f, 20.0f, -1.0, NUI_HALIGN_LEFT, 0, "states_tooltip");
    jRow = CreateTextEditBox(jRow, "name_placeholder", "states_value", 200, FALSE, 268.0f, 20.0f, "states_tooltip");
    jCol = JsonArrayInsert(jCol, NuiRow(jRow));
    // Row 18 (States)********************************************************** 577
    jRow = CreateButton(JsonArray(), "Delete", "btn_delete", 100.0f, 25.0f);
    jCol = JsonArrayInsert(jCol, NuiRow(jRow));
    // Row 20 (Description)***************************************************** 602
    jRow = CreateTextEditBox(JsonArray (), "desc_placeholder", "desc_value", 1000, TRUE, 342.0, 150.0, "desc_tooltip");
    // Add row to the column.
    jCol = JsonArrayInsert(jCol, NuiRow(jRow));
    // Set the layout of the window.
    json jLayout = NuiCol (jCol);
    // Get the window location to restore it from the database.
    string sPCWindow = GetServerDatabaseString (oPC, PLAYER_TABLE, "dmareawin");
    float fX = StringToFloat(GetStringArray(sPCWindow, 1));
    float fY = StringToFloat(GetStringArray(sPCWindow, 2));
    object oOwner = GetItemPossessor(oTarget);
    string sName = StripColorCodes (GetName(oOwner));
    int nToken = SetWindow (oPC, jLayout, "dmquestswin", sName + " quest item menu",
                            fX, fY, 366.0, 767.0, FALSE, FALSE, TRUE, FALSE, TRUE);
    // Setup watch so we can save this windows position to the database.
    NuiSetBindWatch(oPC, nToken, "window_geometry", TRUE);
    // Set the buttons to show events to 0e_window.
    NuiSetBind(oPC, nToken, "name_value", JsonString(GetName(oTarget)));
    NuiSetBindWatch(oPC, nToken, "name_value", TRUE);
    // Is this quest owned by a player?
    if(GetIsCharacter(oOwner))
    {
        string sQuestArray = GetLocalString(oTarget, "0_Q_QUEST");
        string sQuestName = GetStringArray(sQuestArray, 0, "-");
        string sQuestID = GetQuestIDByQuestName(oOwner, sQuestName);
        string sValue = GetServerDatabaseString(oOwner, QUEST_TABLE, "strref", sQuestID);
        NuiSetBind(oPC, nToken, "strref_label", JsonString (sValue));
        int nValue = StringToInt(GetServerDatabaseString(oOwner, QUEST_TABLE, "plot", sQuestID)) - 1;
        NuiSetBind(oPC, nToken, "plot_selected", JsonInt (nValue));
        NuiSetBind(oPC, nToken, "plot_event", JsonBool(FALSE));
        NuiSetBindWatch(oPC, nToken, "plot_selected", FALSE);
        sValue = GetServerDatabaseString(oOwner, QUEST_TABLE, "quest", sQuestID);
        NuiSetBind(oPC, nToken, "quest_value", JsonString(sValue));
        NuiSetBindWatch(oPC, nToken, "quest_value", TRUE);
        sValue = "(  -Quest_Name-CR-Quest_Pointer-Next_Quest_Pointer-Tasks-Quest_Type-Journal_ID-Visual_Effect-Sound_Effect-Leave_Method-ID-)";
        NuiSetBind(oPC, nToken, "quest_tooltip", JsonString(sValue));
        sValue = GetServerDatabaseString(oOwner, QUEST_TABLE, "start", sQuestID);
        NuiSetBind(oPC, nToken, "startloc_value", JsonString(sValue));
        NuiSetBindWatch(oPC, nToken, "startloc_value", TRUE);
        sValue = "(  -Area_Name-Area_Tag-Town_Area-)";
        NuiSetBind(oPC, nToken, "start_tooltip", JsonString(sValue));
        sValue = GetServerDatabaseString(oOwner, QUEST_TABLE, "giver", sQuestID);
        NuiSetBind(oPC, nToken, "giver_value", JsonString(sValue));
        NuiSetBindWatch(oPC, nToken, "giver_value", TRUE);
        sValue = "(  -Name-ResRef-ID-Gender-Race-Class-Package-level-Align1-Align2-Faction-Waypoint_spawn-Items-)";
        NuiSetBind(oPC, nToken, "npc_tooltip", JsonString(sValue));
        sValue = GetServerDatabaseString(oOwner, QUEST_TABLE, "area", sQuestID);
        NuiSetBind(oPC, nToken, "area_value", JsonString(sValue));
        NuiSetBindWatch(oPC, nToken, "area_value", TRUE);
        sValue = "(  -Area_Name-Area_Tag-)";
        NuiSetBind(oPC, nToken, "area_tooltip", JsonString(sValue));
        sValue = GetServerDatabaseString(oOwner, QUEST_TABLE, "npc", sQuestID);
        NuiSetBind(oPC, nToken, "npc_value", JsonString(sValue));
        NuiSetBindWatch(oPC, nToken, "npc_value", TRUE);
        sValue = GetServerDatabaseString(oOwner, QUEST_TABLE, "villain", sQuestID);
        NuiSetBind(oPC, nToken, "villain_value", JsonString(sValue));
        NuiSetBindWatch(oPC, nToken, "villain_value", TRUE);
        sValue = GetServerDatabaseString(oOwner, QUEST_TABLE, "creatures", sQuestID);
        NuiSetBind(oPC, nToken, "creatures_value", JsonString(sValue));
        NuiSetBindWatch(oPC, nToken, "creatures_value", TRUE);
        sValue = "(  -Name-ResRef-ID-Number-Waypoint_spawn-Wounded%-Size-RacialType-)";
        NuiSetBind(oPC, nToken, "creatures_tooltip", JsonString(sValue));
        sValue = GetServerDatabaseString(oOwner, QUEST_TABLE, "enemies", sQuestID);
        NuiSetBind(oPC, nToken, "enemies_value", JsonString(sValue));
        NuiSetBindWatch (oPC, nToken, "enemies_value", TRUE);
        sValue = GetServerDatabaseString(oOwner, QUEST_TABLE, "allies", sQuestID);
        NuiSetBind(oPC, nToken, "allies_value", JsonString(sValue));
        NuiSetBindWatch (oPC, nToken, "allies_value", TRUE);
        sValue = GetServerDatabaseString(oOwner, QUEST_TABLE, "followers", sQuestID);
        NuiSetBind(oPC, nToken, "followers_value", JsonString(sValue));
        NuiSetBindWatch (oPC, nToken, "followers_value", TRUE);
        sValue = GetServerDatabaseString(oOwner, QUEST_TABLE, "giveitem", sQuestID);
        NuiSetBind(oPC, nToken, "giveitem_value", JsonString(sValue));
        NuiSetBindWatch (oPC, nToken, "giveitem_value", TRUE);
        sValue = "(  -Name-BaseName-BaseItemType-ResRef-ID-)";
        NuiSetBind(oPC, nToken, "giveitem_tooltip", JsonString(sValue));
        sValue = GetServerDatabaseString(oOwner, QUEST_TABLE, "item", sQuestID);
        NuiSetBind(oPC, nToken, "plotitem_value", JsonString(sValue));
        NuiSetBindWatch(oPC, nToken, "plotitem_value", TRUE);
        sValue = "(  -Name-BaseName-BaseItemType-ResRef-ID-Container_tag-)";
        NuiSetBind(oPC, nToken, "item_tooltip", JsonString(sValue));
        sValue = GetServerDatabaseString(oOwner, QUEST_TABLE, "placeable", sQuestID);
        NuiSetBind(oPC, nToken, "placeable_value", JsonString(sValue));
        NuiSetBindWatch(oPC, nToken, "placeable_value", TRUE);
        sValue = "(  -Name-ResRef-ID-Waypoint spawn)";
        NuiSetBind(oPC, nToken, "placeable_tooltip", JsonString(sValue));
        sValue = GetServerDatabaseString(oOwner, QUEST_TABLE, "fplaceable", sQuestID);
        NuiSetBind(oPC, nToken, "fplaceable_value", JsonString(sValue));
        NuiSetBindWatch(oPC, nToken, "fplaceable_value", TRUE);
        sValue = GetLocalString(oTarget, "0_Q_FINISH");
        sValue = GetServerDatabaseString(oOwner, QUEST_TABLE, "finish", sQuestID);
        NuiSetBind(oPC, nToken, "finloc_value", JsonString(sValue));
        NuiSetBindWatch(oPC, nToken, "finloc_value", TRUE);
        sValue = GetLocalString(oTarget, "0_Q_FINISHER");
        sValue = GetServerDatabaseString(oOwner, QUEST_TABLE, "finisher", sQuestID);
        NuiSetBind(oPC, nToken, "finisher_value", JsonString(sValue));
        NuiSetBindWatch(oPC, nToken, "finisher_value", TRUE);
        sValue = GetServerDatabaseString(oOwner, QUEST_TABLE, "rewards", sQuestID);
        NuiSetBind(oPC, nToken, "rewards_value", JsonString(sValue));
        NuiSetBindWatch(oPC, nToken, "rewards_value", TRUE);
        sValue = "(  -Fame-Infamy-Xp-Gold-KEEP-Journal ID-Visual_Effect-Sound_Effect-Leave_Method-)";
        NuiSetBind(oPC, nToken, "rewards_tooltip", JsonString(sValue));
        sValue = GetServerDatabaseString(oOwner, QUEST_TABLE, "state", sQuestID);
        NuiSetBind(oPC, nToken, "states_value", JsonString(sValue));
        NuiSetBindWatch(oPC, nToken, "states_value", TRUE);
        sValue = "  -Object Destroyed-Villain Killed-Creature Killed-Item picked up-NCP picked up-Area found-Has Allies-Area Cleared-NPC Dead-Tasks done-";
        NuiSetBind(oPC, nToken, "states_tooltip", JsonString(sValue));
        // Buttons
        NuiSetBind(oPC, nToken, "btn_delete_event", JsonBool(TRUE));
        // Description
        NuiSetBindWatch(oPC, nToken, "desc_value", TRUE);
        NuiSetBind(oPC, nToken, "desc_tooltip", JsonString("  Color codes can be used!"));
        sValue = GetServerDatabaseString(oOwner, QUEST_TABLE, "description", sQuestID);
        NuiSetBind(oPC, nToken, "desc_value", JsonString(sValue));
    }
    else
    {
        string sValue = GetLocalString (oTarget, "0_Q_STRREF");
        NuiSetBind (oPC, nToken, "strref_label", JsonString (sValue));
        int nValue = StringToInt (GetLocalString (oTarget, "0_Q_PLOT")) - 1;
        NuiSetBind (oPC, nToken, "plot_selected", JsonInt (nValue));
        NuiSetBind (oPC, nToken, "plot_event", JsonBool (FALSE));
        NuiSetBindWatch (oPC, nToken, "plot_selected", FALSE);
        sValue = GetLocalString (oTarget, "0_Q_QUEST");
        NuiSetBind (oPC, nToken, "quest_value", JsonString (sValue));
        NuiSetBindWatch (oPC, nToken, "quest_value", TRUE);
        sValue = "(  -Quest_Name-CR-Quest_Pointer-Next_Quest_Pointer-Tasks-Quest_Type-Journal_ID-Visual_Effect-Sound_Effect-Leave_Method-ID-)";
        NuiSetBind(oPC, nToken, "quest_tooltip", JsonString(sValue));
        sValue = GetLocalString (oTarget, "0_Q_START");
        NuiSetBind (oPC, nToken, "startloc_value", JsonString (sValue));
        NuiSetBindWatch (oPC, nToken, "startloc_value", TRUE);
        sValue = "(  -Area_Name-Area_Tag-Town_Area-)";
        NuiSetBind(oPC, nToken, "start_tooltip", JsonString(sValue));
        sValue = GetLocalString (oTarget, "0_Q_GIVER");
        NuiSetBind (oPC, nToken, "giver_value", JsonString (sValue));
        NuiSetBindWatch (oPC, nToken, "giver_value", TRUE);
        sValue = "(  -Name-ResRef-ID-Gender-Race-Class-Package-level-Align1-Align2-Faction-Waypoint_spawn-Items-)";
        NuiSetBind(oPC, nToken, "npc_tooltip", JsonString(sValue));
        sValue = GetLocalString (oTarget, "0_Q_AREA");
        NuiSetBind (oPC, nToken, "area_value", JsonString (sValue));
        NuiSetBindWatch (oPC, nToken, "area_value", TRUE);
        sValue = "(  -Area_Name-Area_Tag-)";
        NuiSetBind(oPC, nToken, "area_tooltip", JsonString(sValue));
        sValue = GetLocalString (oTarget, "0_Q_NPC");
        NuiSetBind (oPC, nToken, "npc_value", JsonString (sValue));
        NuiSetBindWatch (oPC, nToken, "npc_value", TRUE);
        sValue = GetLocalString (oTarget, "0_Q_VILLAIN");
        NuiSetBind (oPC, nToken, "villain_value", JsonString (sValue));
        NuiSetBindWatch (oPC, nToken, "villain_value", TRUE);
        sValue = GetLocalString (oTarget, "0_Q_CREATURES");
        NuiSetBind (oPC, nToken, "creatures_value", JsonString (sValue));
        NuiSetBindWatch (oPC, nToken, "creatures_value", TRUE);
        sValue = "(  -Name-ResRef-ID-Number-Waypoint_spawn-Wounded%-Size-RacialType-)";
        NuiSetBind(oPC, nToken, "creatures_tooltip", JsonString(sValue));
        sValue = GetLocalString (oTarget, "0_Q_ENEMIES");
        NuiSetBind (oPC, nToken, "enemies_value", JsonString (sValue));
        NuiSetBindWatch (oPC, nToken, "enemies_value", TRUE);
        sValue = GetLocalString (oTarget, "0_Q_ALLIES");
        NuiSetBind (oPC, nToken, "allies_value", JsonString (sValue));
        NuiSetBindWatch (oPC, nToken, "allies_value", TRUE);
        sValue = GetLocalString (oTarget, "0_Q_FOLLOWERS");
        NuiSetBind (oPC, nToken, "followers_value", JsonString (sValue));
        NuiSetBindWatch (oPC, nToken, "followers_value", TRUE);
        sValue = GetLocalString (oTarget, "0_Q_GIVEITEM");
        NuiSetBind (oPC, nToken, "giveitem_value", JsonString (sValue));
        NuiSetBindWatch (oPC, nToken, "giveitem_value", TRUE);
        sValue = "(  -Name-BaseName-BaseItemType-ResRef-ID-)";
        NuiSetBind(oPC, nToken, "giveitem_tooltip", JsonString(sValue));
        sValue = GetLocalString (oTarget, "0_Q_ITEM");
        NuiSetBind (oPC, nToken, "plotitem_value", JsonString (sValue));
        NuiSetBindWatch (oPC, nToken, "plotitem_value", TRUE);
        sValue = "(  -Name-BaseName-BaseItemType-ResRef-ID-Container_tag-)";
        NuiSetBind(oPC, nToken, "item_tooltip", JsonString(sValue));
        sValue = GetLocalString (oTarget, "0_Q_PLACEABLE");
        NuiSetBind (oPC, nToken, "placeable_value", JsonString (sValue));
        NuiSetBindWatch (oPC, nToken, "placeable_value", TRUE);
        sValue = "(  -Name-ResRef-ID-Waypoint spawn)";
        NuiSetBind(oPC, nToken, "placeable_tooltip", JsonString(sValue));
        sValue = GetLocalString (oTarget, "0_Q_FPLACEABLE");
        NuiSetBind (oPC, nToken, "fplaceable_value", JsonString (sValue));
        NuiSetBindWatch (oPC, nToken, "fplaceable_value", TRUE);
        sValue = GetLocalString (oTarget, "0_Q_FINISH");
        NuiSetBind (oPC, nToken, "finloc_value", JsonString (sValue));
        NuiSetBindWatch (oPC, nToken, "finloc_value", TRUE);
        sValue = GetLocalString (oTarget, "0_Q_FINISHER");
        NuiSetBind (oPC, nToken, "finisher_value", JsonString (sValue));
        NuiSetBindWatch (oPC, nToken, "finisher_value", TRUE);
        sValue = GetLocalString (oTarget, "0_Q_REWARDS");
        NuiSetBind (oPC, nToken, "rewards_value", JsonString (sValue));
        NuiSetBindWatch (oPC, nToken, "rewards_value", TRUE);
        sValue = "(  -Fame-Infamy-Xp-Gold-KEEP-Journal ID-Visual_Effect-Sound_Effect-Leave_Method-)";
        NuiSetBind(oPC, nToken, "rewards_tooltip", JsonString(sValue));
        sValue = GetLocalString (oTarget, "0_Q_STATE");
        NuiSetBind (oPC, nToken, "states_value", JsonString (sValue));
        NuiSetBindWatch (oPC, nToken, "states_value", TRUE);
        sValue = "  -Object Destroyed-Villain Killed-Creature Killed-Item picked up-NCP picked up-Area found-Has Allies-Area Cleared-NPC Dead-Tasks done-";
        NuiSetBind(oPC, nToken, "states_tooltip", JsonString(sValue));
        NuiSetBind(oPC, nToken, "btn_delete_event", JsonBool(TRUE));
        // Description
        NuiSetBindWatch (oPC, nToken, "desc_value", TRUE);
        NuiSetBind (oPC, nToken, "desc_tooltip", JsonString ("Color codes can be used!"));
        sValue = GetDescription (oTarget);
        NuiSetBind (oPC, nToken, "desc_value", JsonString (sValue));
    }
}

void PopupDMVariablesGUIPanel (object oPC)
{
    // Get the DM target.
    object oTarget = GetLocalObject (oPC, "0_DM_Target");
    // Row 1 (text)************************************************************* 45
    json jRow = CreateTextBox (JsonArray (), "items_text", 440.0f, 300.0f);
    // Add the row to the column.
    json jCol = JsonArrayInsert (JsonArray (), NuiRow (jRow));
    // Row 2 (variable label)*************************************************** 353
    jRow = CreateLabel (JsonArray (), "Variable Name", "v_name_title", 200.0f, 16.0f);
    jRow = JsonArrayInsert (jRow, NuiSpacer());
    jRow = CreateLabel (jRow, "Variable Value", "v_value_title", 200.0f, 16.0f);
    // Add the row to the column.
    jCol = JsonArrayInsert (jCol, NuiRow (jRow));
    // Row 3 (variable box)***************************************************** 377
    jRow = CreateTextEditBox (JsonArray (), "name_placeholder", "name_value", 40, FALSE, 220.0f, 20.0f);
    jRow = JsonArrayInsert (jRow, NuiSpacer());
    jRow = CreateTextEditBox (jRow, "name_placeholder", "value_value", 40, FALSE, 220.0f, 20.0f);
    // Add the row to the column.
    jCol = JsonArrayInsert (jCol, NuiRow (jRow));
    // Row 3 (variable buttons)************************************************* 405
    jRow = CreateButton (JsonArray (), "Set Int", "btn_int", 80.0, 20.0);
    jRow = JsonArrayInsert (jRow, NuiSpacer());
    jRow = CreateButton (jRow, "Set Float", "btn_float", 80.0, 20.0);
    jRow = JsonArrayInsert (jRow, NuiSpacer());
    jRow = CreateButton (jRow, "Set String", "btn_string", 80.0, 20.0);
    jRow = JsonArrayInsert (jRow, NuiSpacer());
    jRow = CreateButton (jRow, "Set Object", "btn_object", 80.0, 20.0);
    jRow = JsonArrayInsert (jRow, NuiSpacer());
    jRow = CreateButtonSelect (jRow, "Delete", "btn_delete", 80.0, 20.0);
    // Add the row to the column.
    jCol = JsonArrayInsert (jCol, NuiRow (jRow));
    // Set the Layout of the window.
    json jLayout = NuiCol (jCol);
    float fY = GetGUIHeightMiddle (oPC, 437.0);
    string sName = StripColorCodes (GetName (oTarget));
    int nToken = SetWindow (oPC, jLayout, "dmvariableswin", sName + " variables",
                            0.0, fY, 464.0, 437.0, FALSE, FALSE, TRUE, FALSE, TRUE);
    // Set all binds, events, and watches.
    NuiSetBind (oPC, nToken, "items_text", JsonString (GetVariableText (oTarget)));
    NuiSetBind (oPC, nToken, "btn_int_event", JsonBool (TRUE));
    NuiSetBind (oPC, nToken, "btn_float_event", JsonBool (TRUE));
    NuiSetBind (oPC, nToken, "btn_string_event", JsonBool (TRUE));
    NuiSetBind (oPC, nToken, "btn_object_event", JsonBool (TRUE));
    NuiSetBind (oPC, nToken, "btn_delete_event", JsonBool (TRUE));
    // Display creatures event scripts.
    if(GetObjectType(oTarget) == OBJECT_TYPE_CREATURE)
    {
        string sScript = GetEventScript(oTarget, EVENT_SCRIPT_CREATURE_ON_HEARTBEAT);
        SendMessageToPC(oPC, "ON_HEARTBEAT: " + sScript);
        sScript = GetEventScript(oTarget, EVENT_SCRIPT_CREATURE_ON_NOTICE);
        SendMessageToPC(oPC, "ON_NOTICE: " + sScript);
        sScript = GetEventScript(oTarget, EVENT_SCRIPT_CREATURE_ON_END_COMBATROUND);
        SendMessageToPC(oPC, "ON_END_COMBATROUND: " + sScript);
        sScript = GetEventScript(oTarget, EVENT_SCRIPT_CREATURE_ON_DIALOGUE);
        SendMessageToPC(oPC, "ON_DIALOGUE: " + sScript);
        sScript = GetEventScript(oTarget, EVENT_SCRIPT_CREATURE_ON_MELEE_ATTACKED);
        SendMessageToPC(oPC, "ON_MELEE_ATTACKED: " + sScript);
        sScript = GetEventScript(oTarget, EVENT_SCRIPT_CREATURE_ON_DAMAGED);
        SendMessageToPC(oPC, "ON_DAMAGED: " + sScript);
        sScript = GetEventScript(oTarget, EVENT_SCRIPT_CREATURE_ON_DISTURBED);
        SendMessageToPC(oPC, "ON_DISTURBED: " + sScript);
        sScript = GetEventScript(oTarget, EVENT_SCRIPT_CREATURE_ON_RESTED);
        SendMessageToPC(oPC, "ON_RESTED: " + sScript);
        sScript = GetEventScript(oTarget, EVENT_SCRIPT_CREATURE_ON_SPELLCASTAT);
        SendMessageToPC(oPC, "ON_SPELLCASTAT: " + sScript);
        sScript = GetEventScript(oTarget, EVENT_SCRIPT_CREATURE_ON_BLOCKED_BY_DOOR);
        SendMessageToPC(oPC, "ON_BLOCKED_BY_DOOR: " + sScript);
    }
}

void PopUpDMAreaGUIPanel (object oPC, object oArea = OBJECT_INVALID)
{
    // Set window to not save until it has been created.
    SetLocalInt (oPC, "0_No_Win_Save", TRUE);
    DelayCommand (0.5f, DeleteLocalInt (oPC, "0_No_Win_Save"));
    // Get the DM target.
    object oTarget = oArea;
    if (oTarget == OBJECT_INVALID)
    {
        oTarget = GetArea (oPC);
    }
    SetLocalObject (oPC, "0_DM_Target", oTarget);
    SetPlayerWinTarget (oPC, GetName (oTarget));
    int nDMToken;
    float fHeigth = 334.0;
    // Row 1 (Name)************************************************************* 45
    json jRow = CreateLabel (JsonArray (), "Name", "name_title", 35.0f, 20.0f, -1.0, NUI_HALIGN_LEFT);
    jRow = CreateTextEditBox (jRow, "name_placeholder", "name_value", 60, FALSE, 303.0f, 20.0f);
    // Add row to the column.
    json jCol = JsonArrayInsert (JsonArray (), NuiRow (jRow));
    // Row 2 (Tag)************************************************************** 73
    jRow = CreateLabel (JsonArray (), "Tag: ", "tag_title", 45.0f, 20.0f, -1.0, NUI_HALIGN_LEFT);
    jRow = CreateLabel (jRow, "", "tag", 293.0f, 20.0f, -1.0, NUI_HALIGN_LEFT);
    // Add row to the column.
    jCol = JsonArrayInsert (jCol, NuiRow (jRow));
    // Row 3 (Generate Treasure/Give XP***************************************** 101
    jRow = CreateCheckBox (JsonArray (), " Generate Treasure", "g_treasure", 174.0, 20.0f);
    jRow = CreateCheckBox (jRow, " Give Experience", "give_xp", 164.0, 20.0f);
    // Add row to the column.
    jCol = JsonArrayInsert (jCol, NuiRow (jRow));
    // Row 4 (Populate/Clear)*************************************************** 129
    jRow = CreateCheckBox (JsonArray (), " Populate when empty", "populate_empty", 174.0, 20.0f);
    jRow = CreateCheckBox (jRow, " Clear when empty", "clear_empty", 164.0, 20.0f);
    // Add row to the column.
    jCol = JsonArrayInsert (jCol, NuiRow (jRow));
    // Row 5 (Resting/Animations)*********************************************** 157
    jRow = CreateCheckBox (JsonArray (), " Allow Resting", "allow_resting", 174.0, 20.0f);
    jRow = CreateCheckBox (jRow, " Creature Animations", "animations", 164.0, 20.0f);
    // Add row to the column.
    jCol = JsonArrayInsert (jCol, NuiRow (jRow));
    // Row 6 (lock level/blank)************************************************* 185
    jRow = CreateCheckBox (JsonArray (), " Lock area level", "lock_level", 174.0, 20.0f);
    jRow = CreateCheckBox (jRow, " Blank", "blank", 164.0, 20.0f);
    // Add row to the column.
    jCol = JsonArrayInsert (jCol, NuiRow (jRow));
    // Row 7 (Combo labels)***************************************************** 213
    jRow = CreateLabel (JsonArray (), "Area Level", "area_lvl_title", 114.0f, 10.0f, -1.0, NUI_HALIGN_CENTER);
    jRow = CreateLabel (jRow, "Encounter", "encounter_title", 160.0f, 10.0f, -1.0, NUI_HALIGN_CENTER);
    jRow = CreateLabel (jRow, "Chance", "chance_title", 60.0f, 10.0f, -1.0, NUI_HALIGN_CENTER);
    // Add row to the column.
    jCol = JsonArrayInsert (jCol, NuiRow (jRow));
    // Row 8 (Level/Encounters/Enc Chance)************************************** 231
    jRow = JsonArrayInsert(JsonArray (), NuiSpacer());
    // Insert elements into the combo box array.
    // Add Area level
    int nAreaLevel, nCount = 0;
    string sText;
    json jCombo = JsonArray ();
    int nLevel = GetLocalInt (oTarget, "0_Area_Level");
    if (nLevel == 0) nLevel = 1;
    while (nCount < 20)
    {
        sText = IntToString (nCount + 1);
        if (nCount + 1 == nLevel)
        {
            sText = sText + " Target Level";
            nAreaLevel = nCount;
        }
        jCombo = JsonArrayInsert (jCombo, NuiComboEntry (sText, nCount));
        nCount ++;
    }
    jRow = CreateCombo (jRow, jCombo, "area_level", 114.0, 25.0);
    jRow = JsonArrayInsert (jRow, NuiSpacer ());
    // Add Encounter Charts
    nCount = 1;
    int nMaxEncounter = StringToInt (Get2DAString ("quest_list", "Encounter", 0));
    jCombo = JsonArrayInsert (JsonArray (), NuiComboEntry ("None", 0));
    while (nCount < nMaxEncounter)
    {
        sText = Get2DAString ("quest_list", "Label", nCount);
        jCombo = JsonArrayInsert (jCombo, NuiComboEntry (sText, nCount));
        nCount ++;
    }
    jRow = CreateCombo (jRow, jCombo, "encounter", 160.0, 25.0);
    jRow = JsonArrayInsert (jRow, NuiSpacer ());
    // Add encounter chance
    nCount = 0;
    jCombo = JsonArray ();
    while (nCount < 21)
    {
        sText = IntToString (nCount * 5);
        jCombo = JsonArrayInsert (jCombo, NuiComboEntry (sText, nCount));
        nCount ++;
    }
    jRow = CreateCombo (jRow, jCombo, "enc_chance", 60.0, 25.0);
    jRow = JsonArrayInsert (jRow, NuiSpacer ());
    // Add the row to the column.
    jCol = JsonArrayInsert (jCol, NuiRow (jRow));
    // Row 9 (Variables/Destroy)************************************************ 264
    jRow = CreateButton (JsonArray (), "Variables", "btn_variables", 80.0, 25.0);
    jRow = JsonArrayInsert (jRow, NuiSpacer ());
    jRow = CreateButton (jRow, "Populate", "btn_populate", 80.0, 25.0);
    jRow = JsonArrayInsert (jRow, NuiSpacer ());
    jRow = CreateButton (jRow, "Clear", "btn_clear", 80.0, 25.0);
    // Add row to the column.
    jCol = JsonArrayInsert (jCol, NuiRow (jRow));
    // Row 10 (Lights/Sound/Wild/Dead)****************************************** 297
    jRow = CreateButtonSelect (JsonArray (), "Wild magic", "btn_wild_magic", 100.0, 25.0);
    jRow = CreateButtonSelect (jRow, "Dead magic", "btn_dead_magic", 100.0, 25.0);
    jRow = CreateButton (jRow, "Colors", "btn_colors", 65.0, 25.0);
    jRow = CreateButton (jRow, "Sounds", "btn_sounds", 65.0, 25.0);
    // Add row to the column.
    jCol = JsonArrayInsert (jCol, NuiRow (jRow));
    object oAreaLevelWP = GetNearestObjectByTag ("ip_area_level", GetFirstObjectInArea (oArea));
    int nInfoStrRef = GetLocalInt (oAreaLevelWP, "0_Info_StrRef");
    if (nInfoStrRef)
    {
        // Row 11 (Area information) *********************************************** 330
        jRow = CreateTextBox (JsonArray (), "Info_text", 342.0, 200.0);
        // Add row to the column.
        jCol = JsonArrayInsert (jCol, NuiRow (jRow));
        fHeigth += 200.0;
    }
    // Set the layout of the window.
    json jLayout = NuiCol (jCol);
    // Get the window location to restore it from the database.
    string sPCWindow = GetServerDatabaseString (oPC, PLAYER_TABLE, "dmareawin");
    float fX = StringToFloat (GetStringArray (sPCWindow, 1));
    float fY = StringToFloat (GetStringArray (sPCWindow, 2));
    int nToken = SetWindow (oPC, jLayout, "dmareawin", "Area menu",
                            fX, fY, 366.0, fHeigth, FALSE, FALSE, TRUE, FALSE, TRUE);
    // Setup watch so we can save this windows position to the database.
    NuiSetBindWatch (oPC, nToken, "window_geometry", TRUE);
    // Set the buttons to show events to 0e_window.
    NuiSetBind (oPC, nToken, "name_value", JsonString (GetName (oTarget)));
    NuiSetBindWatch (oPC, nToken, "name_value", TRUE);
    NuiSetBind (oPC, nToken, "tag_label", JsonString (GetTag (oTarget)));
    int nValue = !GetLocalInt (oTarget, "0_LootOFF");
    NuiSetBind (oPC, nToken, "g_treasure_check", JsonBool (nValue));
    NuiSetBindWatch (oPC, nToken, "g_treasure_check", TRUE);
    nValue = !GetLocalInt (oTarget, "0_XPOFF");
    NuiSetBind (oPC, nToken, "give_xp_check", JsonBool (nValue));
    NuiSetBindWatch (oPC, nToken, "give_xp_check", TRUE);
    nValue = !GetLocalInt (oTarget, "0_PopulateOFF");
    NuiSetBind (oPC, nToken, "populate_empty_check", JsonBool (nValue));
    NuiSetBindWatch (oPC, nToken, "populate_empty_check", TRUE);
    nValue = !GetLocalInt (oTarget, "0_CleanOFF");
    NuiSetBind (oPC, nToken, "clear_empty_check", JsonBool (nValue));
    NuiSetBindWatch (oPC, nToken, "clear_empty_check", TRUE);
    object oNoRestWP = GetNearestObjectByTag ("ip_no_rest", oPC);
    if (oNoRestWP == OBJECT_INVALID) nValue = TRUE;
    else nValue = FALSE;
    NuiSetBind (oPC, nToken, "allow_resting_check", JsonBool (nValue));
    NuiSetBindWatch (oPC, nToken, "allow_resting_check", TRUE);
    nValue = !GetLocalInt (oTarget, "0_AnimationsOFF");
    NuiSetBind (oPC, nToken, "animations_check", JsonBool (nValue));
    NuiSetBindWatch (oPC, nToken, "animations_check", TRUE);
    nValue = GetLocalInt (oTarget, "0_DM_Level_Set");
    NuiSetBind (oPC, nToken, "lock_level_check", JsonBool (nValue));
    NuiSetBindWatch (oPC, nToken, "lock_level_check", TRUE);
    NuiSetBind (oPC, nToken, "area_level_selected", JsonInt (nAreaLevel));
    NuiSetBind (oPC, nToken, "area_level_event", JsonBool (TRUE));
    NuiSetBindWatch (oPC, nToken, "area_level_selected", TRUE);
    sText = GetLocalString (oAreaLevelWP, "0_Encounter_2da");
    if (sText == "") nValue = 0;
    else
    {
        // Find the encounter in the 2da.
        // Get the max number of encounters in the 2da via the count column.
        int nMaxList = StringToInt (Get2DAString ("quest_list", "Encounter", 0));
        nCount = 1;
        while (nCount <= nMaxList)
        {
            if (sText == Get2DAString ("quest_list", "Encounter", nCount))
            {
                nValue = nCount;
                nCount = nMaxList;
            }
            nCount ++;
        }
     }
    NuiSetBind (oPC, nToken, "encounter_selected", JsonInt (nValue));
    NuiSetBind (oPC, nToken, "encounter_event", JsonBool (TRUE));
    NuiSetBindWatch (oPC, nToken, "encounter_selected", TRUE);
    object oRandomEncoutnerWP = GetNearestObjectByTag ("ip_randomencounter", oPC);
    nValue = GetLocalInt (oRandomEncoutnerWP, "0_Enc_Chance") / 5;
    NuiSetBind (oPC, nToken, "enc_chance_selected", JsonInt (nValue));
    NuiSetBind (oPC, nToken, "enc_chance_event", JsonBool (TRUE));
    NuiSetBindWatch (oPC, nToken, "enc_chance_selected", TRUE);
    NuiSetBind (oPC, nToken, "btn_variables_event", JsonBool (TRUE));
    NuiSetBind (oPC, nToken, "btn_populate_event", JsonBool (TRUE));
    NuiSetBind (oPC, nToken, "btn_clear_event", JsonBool (TRUE));
    nValue = GetLocalInt (oTarget, "0_Spell_State");
    if (nValue == 2) nValue = TRUE; else nValue = FALSE;
    NuiSetBind (oPC, nToken, "btn_wild_magic", JsonBool (nValue));
    NuiSetBind (oPC, nToken, "btn_wild_magic_event", JsonBool (TRUE));
    if (nValue == 1) nValue = TRUE; else nValue = FALSE;
    NuiSetBind (oPC, nToken, "btn_dead_magic", JsonBool (nValue));
    NuiSetBind (oPC, nToken, "btn_dead_magic_event", JsonBool (TRUE));
    NuiSetBind (oPC, nToken, "btn_colors_event", JsonBool (TRUE));
    NuiSetBind (oPC, nToken, "btn_sounds_event", JsonBool (TRUE));
    if (nInfoStrRef) NuiSetBind (oPC, nToken, "Info_text", JsonString (GetStringByStrRef (nInfoStrRef)));
}

void PopUpDMColorsGUIPanel (object oPC)
{
    // Set window to not save until it has been created.
    SetLocalInt (oPC, "0_No_Color_Save", TRUE);
    DelayCommand (0.5f, DeleteLocalInt (oPC, "0_No_Color_Save"));
    // Get the DM target.
    object oTarget = GetLocalObject (oPC, "0_DM_Target");
    // Row 1 (Main Lights label)************************************************ 45
    json jRow = CreateLabel (JsonArray (), "Main Lights 1", "main_lights_1_title", 169.0f, 10.0f, -1.0, NUI_HALIGN_CENTER);
    jRow = CreateLabel (jRow, "Main Lights 2", "main_lights_2_title", 169.0f, 10.0f, -1.0, NUI_HALIGN_CENTER);
    // Add the row to the column.
    json jCol = JsonArrayInsert (JsonArray (), NuiRow (jRow));
    // Row 2 (Main Lights)***************************************************** 63
    jRow = JsonArrayInsert (JsonArray (), NuiSpacer());
    // Add main lights 1
    jRow = CreateCombo (jRow, JsonArrayInsertTileLightMainColors (), "lights_m1", 169.0, 25.0);
    jRow = JsonArrayInsert (jRow, NuiSpacer ());
    // Add main lights 2
    jRow = CreateCombo (jRow, JsonArrayInsertTileLightMainColors (), "lights_m2", 169.0, 25.0);
    jRow = JsonArrayInsert (jRow, NuiSpacer ());
    // Add the row to the column.
    jCol = JsonArrayInsert (jCol, NuiRow (jRow));
    // Row 3 (Source Lights label)********************************************** 96
    jRow = CreateLabel (JsonArray (), "Source Lights 1", "source_lights_1_title", 169.0f, 10.0f, -1.0,NUI_HALIGN_CENTER);
    jRow = CreateLabel (jRow, "Source Lights 2", "source_lights_2_title", 169.0f, 10.0f, -1.0, NUI_HALIGN_CENTER);
    // Add the row to the column.
    jCol = JsonArrayInsert (jCol, NuiRow (jRow));
    // Row 4 (Source Lights)**************************************************** 114
    jRow = JsonArrayInsert (JsonArray (), NuiSpacer());
    // Add source lights 1
    jRow = CreateCombo (jRow, JsonArrayInsertTileLightSourceColors (), "lights_s1", 169.0, 25.0);
    jRow = JsonArrayInsert (jRow, NuiSpacer ());
    // Add Source lights 2
    jRow = CreateCombo (jRow, JsonArrayInsertTileLightSourceColors (), "lights_s2", 169.0, 25.0);
    jRow = JsonArrayInsert (jRow, NuiSpacer ());
    // Add the row to the column.
    jCol = JsonArrayInsert (jCol, NuiRow (jRow));
    // Row 5 (Ambient colors label)******************************************** 147
    jRow = CreateLabel (JsonArray (), "Sun ambient colors", "sun_ambient_title", 169.0f, 10.0f, -1.0, NUI_HALIGN_CENTER);
    jRow = CreateLabel (jRow, "Moon ambient colors", "moon_ambient_title", 169.0f, 10.0f, -1.0, NUI_HALIGN_CENTER);
    // Add the row to the column.
    jCol = JsonArrayInsert (jCol, NuiRow (jRow));
    // Row 6 (Ambient colors)*************************************************** 165
    jRow = JsonArrayInsert (JsonArray (), NuiSpacer());
    // Add Sun ambient colors
    jRow = CreateCombo (jRow, JsonArrayInsertFogColors (), "sun_ambient", 169.0, 25.0);
    jRow = JsonArrayInsert (jRow, NuiSpacer ());
    // Add Moon ambient colors
    jRow = CreateCombo (jRow, JsonArrayInsertFogColors (), "moon_ambient", 169.0, 25.0);
    jRow = JsonArrayInsert (jRow, NuiSpacer ());
    // Add the row to the column.
    jCol = JsonArrayInsert (jCol, NuiRow (jRow));
    // Row 7 (Diffuse colors label)********************************************* 198
    jRow = CreateLabel (JsonArray (), "Sun diffuse colors", "sun_diffuse_title", 169.0f, 10.0f, -1.0, NUI_HALIGN_CENTER);
    jRow = CreateLabel (jRow, "Moon diffuse colors", "moon_diffuse_title", 169.0f, 10.0f, -1.0, NUI_HALIGN_CENTER);
    // Add the row to the column.
    jCol = JsonArrayInsert (jCol, NuiRow (jRow));
    // Row 8 (Diffuse colors)*************************************************** 216
    jRow = JsonArrayInsert (JsonArray (), NuiSpacer());
    // Add Sun diffuse colors
    jRow = CreateCombo (jRow, JsonArrayInsertFogColors (), "sun_diffuse", 169.0, 25.0);
    jRow = JsonArrayInsert (jRow, NuiSpacer ());
    // Add Moon diffuse colors
    jRow = CreateCombo (jRow, JsonArrayInsertFogColors (), "moon_diffuse", 169.0, 25.0);
    jRow = JsonArrayInsert (jRow, NuiSpacer ());
    // Add the row to the column.
    jCol = JsonArrayInsert (jCol, NuiRow (jRow));
    // Row 9 (Fog colors label)************************************************* 249
    jRow = CreateLabel (JsonArray (), "Sun fog colors", "sun_fog_title", 169.0f, 10.0f, -1.0, NUI_HALIGN_CENTER);
    jRow = CreateLabel (jRow, "Moon fog colors", "moon_fog_title", 169.0f, 10.0f, -1.0, NUI_HALIGN_CENTER);
    // Add the row to the column.
    jCol = JsonArrayInsert (jCol, NuiRow (jRow));
    // Row 10 (Fog colors)****************************************************** 267
    // Insert elements into the combo box array.
    jRow = JsonArrayInsert (JsonArray (), NuiSpacer());
    // Add sun fog colors
    jRow = CreateCombo (jRow, JsonArrayInsertFogColors (), "sun_fog", 169.0, 25.0);
    jRow = JsonArrayInsert (jRow, NuiSpacer ());
    // Add moon fog colors
    jRow = CreateCombo (jRow, JsonArrayInsertFogColors (), "moon_fog", 169.0, 25.0);
    jRow = JsonArrayInsert (jRow, NuiSpacer ());
    // Add the row to the column.
    jCol = JsonArrayInsert (jCol, NuiRow (jRow));
    // Set the layout of the window.
    json jLayout = NuiCol (jCol);
    float fY = GetGUIHeightMiddle (oPC, 304.0);
    int nToken = SetWindow (oPC, jLayout, "dmcolorswin", GetName (oTarget) + " (Area color menu)",
                            0.0, fY, 366.0, 304.0, FALSE, FALSE, TRUE, FALSE, TRUE);
    // Set the buttons to show events to 0e_window.
    location lLocation = Location (oTarget, Vector (0.0, 0.0, 0.0), 0.0);
    int nValue = GetTileMainLight1Color (lLocation);
    NuiSetBind (oPC, nToken, "lights_m1_selected", JsonInt (nValue));
    NuiSetBind (oPC, nToken, "lights_m1_event", JsonBool (TRUE));
    NuiSetBindWatch (oPC, nToken, "lights_m1_selected", TRUE);
    nValue = GetTileMainLight2Color (lLocation);
    NuiSetBind (oPC, nToken, "lights_m2_selected", JsonInt (nValue));
    NuiSetBind (oPC, nToken, "lights_m2_event", JsonBool (TRUE));
    NuiSetBindWatch (oPC, nToken, "lights_m2_selected", TRUE);
    nValue = GetTileSourceLight1Color (lLocation);
    NuiSetBind (oPC, nToken, "lights_s1_selected", JsonInt (nValue));
    NuiSetBind (oPC, nToken, "lights_s1_event", JsonBool (TRUE));
    NuiSetBindWatch (oPC, nToken, "lights_s1_selected", TRUE);
    nValue = GetTileSourceLight2Color (lLocation);
    NuiSetBind (oPC, nToken, "lights_s2_selected", JsonInt (nValue));
    NuiSetBind (oPC, nToken, "lights_s2_event", JsonBool (TRUE));
    NuiSetBindWatch (oPC, nToken, "lights_s2_selected", TRUE);
    nValue = FogColorToComboNumber (NWNX_Area_GetSunMoonColors (oTarget, NWNX_AREA_COLOR_TYPE_SUN_AMBIENT));
    NuiSetBind (oPC, nToken, "sun_ambient_selected", JsonInt (nValue));
    NuiSetBind (oPC, nToken, "sun_ambient_event", JsonBool (TRUE));
    NuiSetBindWatch (oPC, nToken, "sun_ambient_selected", TRUE);
    nValue = FogColorToComboNumber (NWNX_Area_GetSunMoonColors (oTarget, NWNX_AREA_COLOR_TYPE_SUN_DIFFUSE));
    NuiSetBind (oPC, nToken, "sun_diffuse_selected", JsonInt (nValue));
    NuiSetBind (oPC, nToken, "sun_diffuse_event", JsonBool (TRUE));
    NuiSetBindWatch (oPC, nToken, "sun_diffuse_selected", TRUE);
    nValue = FogColorToComboNumber (NWNX_Area_GetSunMoonColors (oTarget, NWNX_AREA_COLOR_TYPE_MOON_AMBIENT));
    NuiSetBind (oPC, nToken, "moon_ambient_selected", JsonInt (nValue));
    NuiSetBind (oPC, nToken, "moon_ambient_event", JsonBool (TRUE));
    NuiSetBindWatch (oPC, nToken, "moon_ambient_selected", TRUE);
    nValue = FogColorToComboNumber (NWNX_Area_GetSunMoonColors (oTarget, NWNX_AREA_COLOR_TYPE_MOON_DIFFUSE));
    NuiSetBind (oPC, nToken, "moon_diffuse_selected", JsonInt (nValue));
    NuiSetBind (oPC, nToken, "moon_diffuse_event", JsonBool (TRUE));
    NuiSetBindWatch (oPC, nToken, "moon_diffuse_selected", TRUE);
    nValue = FogColorToComboNumber (GetFogColor (FOG_TYPE_SUN, oTarget));
    NuiSetBind (oPC, nToken, "sun_fog_selected", JsonInt (nValue));
    NuiSetBind (oPC, nToken, "sun_fog_event", JsonBool (TRUE));
    NuiSetBindWatch (oPC, nToken, "sun_fog_selected", TRUE);
    nValue = FogColorToComboNumber (GetFogColor (FOG_TYPE_MOON, oTarget));
    NuiSetBind (oPC, nToken, "moon_fog_selected", JsonInt (nValue));
    NuiSetBind (oPC, nToken, "moon_fog_event", JsonBool (TRUE));
    NuiSetBindWatch (oPC, nToken, "moon_fog_selected", TRUE);
}

void PopUpDMSoundsGUIPanel (object oPC)
{
    // Get the DM target.
    object oTarget = GetLocalObject (oPC, "0_DM_Target");
    // Row 1 (Sounds label)***************************************************** 45
    json jRow = CreateLabel (JsonArray (), "Daytime Ambient", "day_sounds_title", 169.0f, 10.0f, -1.0, NUI_HALIGN_CENTER);
    jRow = CreateLabel (jRow, "Nighttime Ambient", "night_sounds_title", 169.0f, 10.0f, -1.0, NUI_HALIGN_CENTER);
    // Add the row to the column.
    json jCol = JsonArrayInsert (JsonArray (), NuiRow (jRow));
    // Row 2 (Combo box Sounds)************************************************* 63
    jRow = JsonArrayInsert (JsonArray (), NuiSpacer());
    jRow = CreateCombo (jRow, JsonArrayInsertAmbientSounds (), "day_sounds", 169.0, 25.0);
    jRow = JsonArrayInsert (jRow, NuiSpacer ());
    jRow = CreateCombo (jRow, JsonArrayInsertAmbientSounds (), "night_sounds", 169.0, 25.0);
    jRow = JsonArrayInsert (jRow, NuiSpacer ());
    // Add the row to the column.
    jCol = JsonArrayInsert (jCol, NuiRow (jRow));
    // Row 3 (Sound volume label)*********************************************** 96
    jRow = CreateLabel (JsonArray (), "Daytime volume", "day_volume_title", 169.0f, 10.0f, -1.0, NUI_HALIGN_CENTER);
    jRow = CreateLabel (jRow, "Nighttime volume", "night_volume_title", 169.0f, 10.0f, -1.0, NUI_HALIGN_CENTER);
    // Add the row to the column.
    jCol = JsonArrayInsert (jCol, NuiRow (jRow));
    // Row 4 (Sounds volume)****************************************************** 114
    jRow = CreateSlider (JsonArray (), "day_volume", 169.0, 25.0);
    jRow = CreateSlider (jRow, "night_volume", 169.0, 25.0);
    // Add the row to the column.
    jCol = JsonArrayInsert (jCol, NuiRow (jRow));
    // Row 5 (Play Sounds)****************************************************** 147
    jRow = CreateButton (JsonArray (), "Play Ambient Sound", "btn_play_sound", 169.0, 25.0);
    jRow = CreateButton (jRow, "Stop Ambient Sound", "btn_stop_sound", 169.0, 25.0);
    // Add the row to the column.
    jCol = JsonArrayInsert (jCol, NuiRow (jRow));
    // Set the layout of the window.
    json jLayout = NuiCol (jCol);
    float fY = GetGUIHeightMiddle (oPC, 184.0);
    int nToken = SetWindow (oPC, jLayout, "dmsoundswin", GetName (oTarget) + " (Area sound menu)",
                            0.0, fY, 366.0, 184.0, FALSE, FALSE, TRUE, FALSE, TRUE);
    // Set the buttons to show events to 0e_window.
    int nValue = NWNX_Area_GetAmbientSoundDay (oTarget);
    NuiSetBind (oPC, nToken, "day_sounds_selected", JsonInt (nValue));
    NuiSetBind (oPC, nToken, "day_sounds_event", JsonBool (TRUE));
    NuiSetBindWatch (oPC, nToken, "day_sounds_selected", TRUE);
    nValue = NWNX_Area_GetAmbientSoundNight (oTarget);
    NuiSetBind (oPC, nToken, "night_sounds_selected", JsonInt (nValue));
    NuiSetBind (oPC, nToken, "night_sounds_event", JsonBool (TRUE));
    NuiSetBindWatch (oPC, nToken, "night_sounds_selected", TRUE);
    nValue = NWNX_Area_GetAmbientSoundDayVolume (oTarget);
    NuiSetBind (oPC, nToken, "day_volume_min", JsonInt (0));
    NuiSetBind (oPC, nToken, "day_volume_max", JsonInt (100));
    NuiSetBind (oPC, nToken, "day_volume_stepsize", JsonInt (1));
    NuiSetBind (oPC, nToken, "day_volume_value", JsonInt (nValue));
    NuiSetBindWatch (oPC, nToken, "day_volume_value", TRUE);
    NuiSetBind (oPC, nToken, "day_volume_event", JsonBool (TRUE));
    nValue = NWNX_Area_GetAmbientSoundNightVolume (oTarget);
    NuiSetBind (oPC, nToken, "night_volume_min", JsonInt (0));
    NuiSetBind (oPC, nToken, "night_volume_max", JsonInt (100));
    NuiSetBind (oPC, nToken, "night_volume_stepsize", JsonInt (1));
    NuiSetBind (oPC, nToken, "night_volume_value", JsonInt (nValue));
    NuiSetBindWatch (oPC, nToken, "night_volume_value", TRUE);
    NuiSetBind (oPC, nToken, "night_volume_event", JsonBool (TRUE));
    NuiSetBind (oPC, nToken, "btn_play_sound", JsonBool (TRUE));
    NuiSetBind (oPC, nToken, "btn_play_sound_event", JsonBool (TRUE));
    NuiSetBind (oPC, nToken, "btn_stop_sound", JsonBool (TRUE));
    NuiSetBind (oPC, nToken, "btn_stop_sound_event", JsonBool (TRUE));
}

void PopUpDMNPCGUIPanel (object oPC)
{
    // Set window to not save until it has been created.
    SetLocalInt (oPC, "0_No_Win_Save", TRUE);
    DelayCommand (0.5f, DeleteLocalInt (oPC, "0_No_Win_Save"));
    string sID, sValue;
    // Create the column.
    // Row 1 (NPC Name)********************************************************* 45
    json jRow = CreateLabel (JsonArray (), "Name", "npc_name_lbl", 40.0f, 20.0f, -1.0, NUI_HALIGN_LEFT);
    jRow = CreateTextEditBox (jRow, "name_placeholder", "npc_name", 30, FALSE, 298.0, 20.0);
    // Add the row to the column.
    json jCol = JsonArrayInsert (JsonArray (), NuiRow (jRow));
    // Row 2 (Portrait Name/Deity)********************************************** 73
    jRow = CreateTextEditBox (JsonArray (), "port_placeholder", "npc_port_resref", 16, FALSE, 150.0, 20.0, "npc_port_tooltip");
    jRow = CreateLabel (jRow, "Deity", "npc_deity_lbl", 40.0f, 20.0f, -1.0, NUI_HALIGN_LEFT);
    jRow = CreateTextEditBox (jRow, "place_holder", "npc_deity", 25, FALSE, 144.0, 20.0f);
    // Add the row to the column.
    jCol = JsonArrayInsert (jCol, NuiRow (jRow));
    // Row 3 (Race line)******************************************************** 101
    jRow = CreateLabel (JsonArray (), "Gender", "npc_gender_lbl", 50.0f, 20.0f);
    json jCombo = JsonArrayInsert (JsonArray (), NuiComboEntry ("Male", 0));
    jCombo = JsonArrayInsert (jCombo, NuiComboEntry ("Female", 1));
    jCombo = JsonArrayInsert (jCombo, NuiComboEntry ("Random", 2));
    jRow = CreateCombo (jRow, jCombo, "npc_gender", 74.0f, 20.0f);
    jRow = CreateLabel (jRow, "Race", "npc_race_lbl", 40.0f, 20.0f);
    jRow = CreateCombo (jRow, JArrayInsertNPCRaces (), "npc_race", 166.0f, 20.0f);
    // Add the row to the column.
    jCol = JsonArrayInsert (jCol, NuiRow (jRow));
    // Row 4 (Class1 line)****************************************************** 129
    json jPos = NuiRect (0.0, 0.0, 128.0, 200.0);
    json jLabel = NuiLabel (JsonString (""), JsonInt (0), JsonInt (0));
    jLabel = NuiHeight (NuiWidth (jLabel, 128.0), 20.0);
    // Create image to the left of the window.
    json jImage = JsonArrayInsert (JsonArray (), NuiDrawListImage (JsonBool (TRUE), NuiBind ("npc_port_image"), jPos, JsonInt (NUI_ASPECT_EXACTSCALED), JsonInt (NUI_HALIGN_LEFT), JsonInt (NUI_VALIGN_TOP)));
    jRow = JsonArrayInsert (JsonArray (), NuiDrawList (jLabel, JsonBool (FALSE), jImage));
    jRow = CreateCombo (jRow, JArrayInsertNPCBaseClasses (), "npc_class1", 160.0f, 20.0f);
    jRow = CreateCombo (jRow, JArrayInsertNPCLevels (), "npc_level1", 46.0f, 20.0f);
    // Add the row to the column.
    jCol = JsonArrayInsert (jCol, NuiRow (jRow));
    // Row 5 (Class2 line)****************************************************** 157
    jRow = CreateLabel (JsonArray (), "", "blk_lbl", 128.0f, 20.0f);
    jRow = CreateCombo (jRow, JArrayInsertNPCClasses (), "npc_class2", 160.0f, 20.0f);
    jRow = CreateCombo (jRow, JArrayInsertNPCLevels (), "npc_level2", 46.0f, 20.0f);
    // Add the row to the column.
    jCol = JsonArrayInsert (jCol, NuiRow (jRow));
    // Row 6 (Class3 line)****************************************************** 185
    jRow = CreateLabel (JsonArray (), "", "blk_lbl", 128.0f, 20.0f);
    jRow = CreateCombo (jRow, JArrayInsertNPCClasses (), "npc_class3", 160.0f, 20.0f);
    jRow = CreateCombo (jRow, JArrayInsertNPCLevels (), "npc_level3", 46.0f, 20.0f);
    // Add the row to the column.
    jCol = JsonArrayInsert (jCol, NuiRow (jRow));
    // Row 7 (Str line)********************************************************* 213
    jRow = CreateLabel (JsonArray (), "", "blk_lbl", 128.0f, 10.0f);
    jRow = CreateLabel (jRow, "Strength", "str_lbl", 90.0f, 16.0f, -1.0, NUI_HALIGN_LEFT);
    jRow = CreateImage (jRow, "gui_chrsht_str", "str_img", NUI_ASPECT_EXACTSCALED, NUI_HALIGN_CENTER, NUI_VALIGN_MIDDLE, 16.0f, 16.0f);
    jRow = CreateLabel (jRow, "", "str_value", 20.0f, 16.0f);
    jRow = CreateLabel (jRow, "", "str_mod", 20.0f, 16.0f);
    jRow = CreateButtonImage (jRow, "nui_cnt_up", "btn_up_str", 20.0, 16.0);
    jRow = CreateButtonImage (jRow, "nui_cnt_down", "btn_down_str", 20.0, 16.0);
    // Add the row to the column.
    jCol = JsonArrayInsert (jCol, NuiRow (jRow));
    // Row 8 (Dex line)********************************************************* 237
    jRow = CreateLabel (JsonArray (), "", "blk_lbl", 128.0f, 10.0f);
    jRow = CreateLabel (jRow, "Dexterity", "dex_lbl", 90.0f, 16.0f, -1.0, NUI_HALIGN_LEFT);
    jRow = CreateImage (jRow, "gui_chrsht_dex", "str_img", NUI_ASPECT_EXACTSCALED, NUI_HALIGN_CENTER, NUI_VALIGN_MIDDLE, 16.0f, 16.0f);
    jRow = CreateLabel (jRow, "", "dex_value", 20.0f, 16.0f);
    jRow = CreateLabel (jRow, "", "dex_mod", 20.0f, 16.0f);
    jRow = CreateButtonImage (jRow, "nui_cnt_up", "btn_up_dex", 20.0, 16.0);
    jRow = CreateButtonImage (jRow, "nui_cnt_down", "btn_down_dex", 20.0, 16.0);
    // Add the row to the column.
    jCol = JsonArrayInsert (jCol, NuiRow (jRow));
    // Row 9 (Con line)********************************************************* 261
    jRow = CreateLabel (JsonArray (), "", "blk_lbl", 128.0f, 10.0f);
    jRow = CreateLabel (jRow, "Constitution", "con_lbl", 90.0f, 16.0f, -1.0, NUI_HALIGN_LEFT);
    jRow = CreateImage (jRow, "gui_chrsht_con", "con_img", NUI_ASPECT_EXACTSCALED, NUI_HALIGN_CENTER, NUI_VALIGN_MIDDLE, 16.0f, 16.0f);
    jRow = CreateLabel (jRow, "", "con_value", 20.0f, 16.0f);
    jRow = CreateLabel (jRow, "", "con_mod", 20.0f, 16.0f);
    jRow = CreateButtonImage (jRow, "nui_cnt_up", "btn_up_con", 20.0, 16.0);
    jRow = CreateButtonImage (jRow, "nui_cnt_down", "btn_down_con", 20.0, 16.0);
    // Add the row to the column.
    jCol = JsonArrayInsert (jCol, NuiRow (jRow));
    // Row 10 (Int line)******************************************************** 285
    jRow = CreateLabel (JsonArray (), "", "blk_lbl", 128.0f, 10.0f);
    jRow = CreateLabel (jRow, "Intelligence", "int_lbl", 90.0f, 16.0f, -1.0, NUI_HALIGN_LEFT);
    jRow = CreateImage (jRow, "gui_chrsht_int", "int_img", NUI_ASPECT_EXACTSCALED, NUI_HALIGN_CENTER, NUI_VALIGN_MIDDLE, 16.0f, 16.0f);
    jRow = CreateLabel (jRow, "", "int_value", 20.0f, 16.0f);
    jRow = CreateLabel (jRow, "", "int_mod", 20.0f, 16.0f);
    jRow = CreateButtonImage (jRow, "nui_cnt_up", "btn_up_int", 20.0, 16.0);
    jRow = CreateButtonImage (jRow, "nui_cnt_down", "btn_down_int", 20.0, 16.0);
    // Add the row to the column.
    jCol = JsonArrayInsert (jCol, NuiRow (jRow));
    // Row 11 (Wis line)******************************************************** 309
    jRow = CreateLabel (JsonArray (), "", "blk_lbl", 128.0f, 10.0f);
    jRow = CreateLabel (jRow, "Wisdom", "wis_lbl", 90.0f, 16.0f, -1.0, NUI_HALIGN_LEFT);
    jRow = CreateImage (jRow, "gui_chrsht_wis", "wis_img", NUI_ASPECT_EXACTSCALED, NUI_HALIGN_CENTER, NUI_VALIGN_MIDDLE, 16.0f, 16.0f);
    jRow = CreateLabel (jRow, "", "wis_value", 20.0f, 16.0f);
    jRow = CreateLabel (jRow, "", "wis_mod", 20.0f, 16.0f);
    jRow = CreateButtonImage (jRow, "nui_cnt_up", "btn_up_wis", 20.0, 16.0);
    jRow = CreateButtonImage (jRow, "nui_cnt_down", "btn_down_wis", 20.0, 16.0);
    // Add the row to the column.
    jCol = JsonArrayInsert (jCol, NuiRow (jRow));
    // Row 12 (Cha line)******************************************************** 333
    jRow = CreateButton (JsonArray (), "<", "btn_portrait_prev", 32.0f, 16.0f);
    jRow = CreateLabel (jRow, "", "npc_port_id", 58.0, 16.0f);
    jRow = CreateButton (jRow, ">", "btn_portrait_next", 32.0f, 16.0f);
    jRow = CreateLabel (jRow, "Charisma", "cha_lbl", 90.0f, 16.0f, -1.0, NUI_HALIGN_LEFT);
    jRow = CreateImage (jRow, "gui_chrsht_cha", "cha_img", NUI_ASPECT_EXACTSCALED, NUI_HALIGN_CENTER, NUI_VALIGN_MIDDLE, 16.0f, 16.0f);
    jRow = CreateLabel (jRow, "", "cha_value", 20.0f, 16.0f);
    jRow = CreateLabel (jRow, "", "cha_mod", 20.0f, 16.0f);
    jRow = CreateButtonImage (jRow, "nui_cnt_up", "btn_up_cha", 20.0, 16.0);
    jRow = CreateButtonImage (jRow, "nui_cnt_down", "btn_down_cha", 20.0, 16.0);
    // Add the row to the column.
    jCol = JsonArrayInsert (jCol, NuiRow (jRow));
    // Row 13 (Description)***************************************************** 357
    jRow = CreateTextEditBox (JsonArray (), "desc_placeholder", "desc_value", 1000, TRUE, 342.0, 150.0, "desc_tooltip");
    // Add the row to the column.
    jCol = JsonArrayInsert (jCol, NuiRow (jRow));
    // Row 14 (Align/Faction labels)******************************************** 515
    jRow = CreateLabel (JsonArray (), "Alignment", "align_label", 224.0, 10.0f);
    jRow = CreateLabel (jRow, "Faction", "faction_label", 113.0f, 10.0f);
    // Add the row to the column.
    jCol = JsonArrayInsert (jCol, NuiRow (jRow));
    // Row 15 (Align/Faction combo)********************************************* 533
    jRow = CreateCombo (JsonArray (), JArrayInsertNPCAlign1 (), "npc_align1", 112.0f, 20.0f);
    jRow = CreateCombo (jRow, JArrayInsertNPCAlign2 (), "npc_align2", 112.0f, 20.0f);
    jRow = CreateCombo (jRow, JArrayInsertNPCFactions (), "npc_faction", 113.0f, 20.0f);
    // Add the row to the column.
    jCol = JsonArrayInsert (jCol, NuiRow (jRow));
    // Row 16 (NPC buttons)***************************************************** 561
    jRow = CreateButton (JsonArray (), "Clear", "btn_clear", 111.0, 20.0);
    jRow = CreateButton (jRow, "Randomize", "btn_random", 111.0, 20.0);
    jRow = CreateButton (jRow, "Create", "btn_create", 111.0, 20.0);
    // Add the row to the column.
    jCol = JsonArrayInsert (jCol, NuiRow (jRow));
    // Set the Layout of the window.
    json jLayout = NuiCol (jCol);
    // Get the window location to restore it from the database.
    string sPCWindow = GetServerDatabaseString (oPC, PLAYER_TABLE, "dmnpcwin");
    float fX = StringToFloat (GetStringArray (sPCWindow, 1));
    float fY = StringToFloat (GetStringArray (sPCWindow, 2));
    int nToken = SetWindow (oPC, jLayout, "dmnpcwin", "Create non-player character",
                            fX, fY, 366.0, 593.0, FALSE, FALSE, TRUE, FALSE, TRUE);
    // Setup watch so we can save this windows position to the database.
    NuiSetBindWatch (oPC, nToken, "window_geometry", TRUE);
    // Set all binds, events, and watches.
    json jNPC = GetLocalJson (oPC, "0_JNPC");
    if (JsonGetType (jNPC) == JSON_TYPE_NULL) jNPC = SetJsonNPC (oPC);
    NuiSetBindWatch (oPC, nToken, "npc_name", TRUE);
    NuiSetBindWatch (oPC, nToken, "npc_deity", TRUE);
    NuiSetBind (oPC, nToken, "npc_gender_event", JsonBool (TRUE));
    NuiSetBindWatch (oPC, nToken, "npc_gender_selected", TRUE);
    NuiSetBind (oPC, nToken, "npc_race_event", JsonBool (TRUE));
    NuiSetBindWatch (oPC, nToken, "npc_race_selected", TRUE);
    NuiSetBind (oPC, nToken, "npc_class1_event", JsonBool (TRUE));
    NuiSetBindWatch (oPC, nToken, "npc_class1_selected", TRUE);
    NuiSetBind (oPC, nToken, "npc_level1_event", JsonBool (TRUE));
    NuiSetBindWatch (oPC, nToken, "npc_level1_selected", TRUE);
    NuiSetBindWatch (oPC, nToken, "npc_class2_selected", TRUE);
    NuiSetBindWatch (oPC, nToken, "npc_level2_selected", TRUE);
    int nClass1 = JsonGetInt (JsonObjectGet (jNPC, "class1"));
    if (nClass1 != 13)
    {
        NuiSetBind (oPC, nToken, "npc_class2_event", JsonBool (TRUE));
        NuiSetBind (oPC, nToken, "npc_level2_event", JsonBool (TRUE));
    }
    int nClass3 = JsonGetInt (JsonObjectGet (jNPC, "class3"));
    nClass3 = GetNPCClassForCombo (nClass3);
    NuiSetBind (oPC, nToken, "npc_class3_selected", JsonInt (nClass3));
    NuiSetBindWatch (oPC, nToken, "npc_class3_selected", TRUE);
    int nClass2 = JsonGetInt (JsonObjectGet (jNPC, "class2"));
    if (nClass2 < 29)
    {
        NuiSetBind (oPC, nToken, "npc_class3_event", JsonBool (TRUE));
        NuiSetBind (oPC, nToken, "npc_level3_event", JsonBool (TRUE));
    }
    NuiSetBind (oPC, nToken, "btn_up_str_event", JsonBool (TRUE));
    NuiSetBind (oPC, nToken, "btn_down_str_event", JsonBool (TRUE));
    NuiSetBind (oPC, nToken, "str_img_event", JsonBool (TRUE));
    NuiSetBind (oPC, nToken, "btn_up_dex_event", JsonBool (TRUE));
    NuiSetBind (oPC, nToken, "btn_down_dex_event", JsonBool (TRUE));
    NuiSetBind (oPC, nToken, "dex_img_event", JsonBool (TRUE));
    NuiSetBind (oPC, nToken, "btn_up_con_event", JsonBool (TRUE));
    NuiSetBind (oPC, nToken, "btn_down_con_event", JsonBool (TRUE));
    NuiSetBind (oPC, nToken, "con_img_event", JsonBool (TRUE));
    NuiSetBind (oPC, nToken, "btn_up_int_event", JsonBool (TRUE));
    NuiSetBind (oPC, nToken, "btn_down_int_event", JsonBool (TRUE));
    NuiSetBind (oPC, nToken, "int_img_event", JsonBool (TRUE));
    NuiSetBind (oPC, nToken, "btn_up_wis_event", JsonBool (TRUE));
    NuiSetBind (oPC, nToken, "btn_down_wis_event", JsonBool (TRUE));
    NuiSetBind (oPC, nToken, "wis_img_event", JsonBool (TRUE));
    NuiSetBind (oPC, nToken, "btn_up_cha_event", JsonBool (TRUE));
    NuiSetBind (oPC, nToken, "btn_down_cha_event", JsonBool (TRUE));
    NuiSetBind (oPC, nToken, "cha_img_event", JsonBool (TRUE));
    // Portrait
    NuiSetBindWatch (oPC, nToken, "npc_port_resref", TRUE);
    NuiSetBind (oPC, nToken, "npc_port_resref_event", JsonBool (TRUE));
    NuiSetBind (oPC, nToken, "npc_port_tooltip", JsonString ("You may also type the portrait file name."));
    NuiSetBind (oPC, nToken, "btn_portrait_prev_event", JsonBool (TRUE));
    NuiSetBind (oPC, nToken, "btn_portrait_next_event", JsonBool (TRUE));
    // Alignment
    NuiSetBind (oPC, nToken, "npc_align1_event", JsonBool (TRUE));
    NuiSetBindWatch (oPC, nToken, "npc_align1_selected", TRUE);
    NuiSetBind (oPC, nToken, "npc_align2_event", JsonBool (TRUE));
    NuiSetBindWatch (oPC, nToken, "npc_align2_selected", TRUE);
    // Factions
    NuiSetBind (oPC, nToken, "npc_faction_event", JsonBool (TRUE));
    NuiSetBindWatch (oPC, nToken, "npc_faction_selected", TRUE);
    // Description
    NuiSetBind (oPC, nToken, "desc_tooltip", JsonString ("Color codes can be used!"));
    NuiSetBindWatch (oPC, nToken, "desc_value", TRUE);
    // Buttons
    NuiSetBind (oPC, nToken, "btn_clear", JsonBool (TRUE));
    NuiSetBind (oPC, nToken, "btn_clear_event", JsonBool (TRUE));
    NuiSetBind (oPC, nToken, "btn_random", JsonBool (TRUE));
    NuiSetBind (oPC, nToken, "btn_random_event", JsonBool (TRUE));
    NuiSetBind (oPC, nToken, "btn_create", JsonBool (TRUE));
    NuiSetBind (oPC, nToken, "btn_create_event", JsonBool (TRUE));
    UpdateNPCWindow (oPC, nToken);
}

void PopUpDMServerGUIPanel (object oPC)
{
    // Set window to not save until it has been created.
    SetLocalInt (oPC, "0_No_Win_Save", TRUE);
    DelayCommand (0.5f, DeleteLocalInt (oPC, "0_No_Win_Save"));
    int nCurrentLevel, nCount = 0;
    string sText;
    object oModule = GetModule ();
    // Row 1 (labels)*********************************************************** 45
    json jRow = CreateLabel (JsonArray (), "Starting Level", "char_lvl_title", 111.0f, 10.0f);
    jRow = CreateLabel (jRow, "", "xp_title", 111.0f, 10.0f);
    jRow = CreateLabel (jRow, "", "treasure_title", 111.0f, 10.0f);
    // Add row to the column.
    json jCol = JsonArrayInsert (JsonArray (), NuiRow (jRow));
    // Row 2 (Combo/Sliders)**************************************************** 63
    int nLevel = GetServerDatabaseInt (oModule, SERVER_TABLE, "startlevel");
    json jCombo = JsonArray ();
    while (nCount < 20)
    {
        sText = IntToString (nCount + 1);
        if (nCount + 1 == nLevel)
        {
            sText = sText + " Current Level";
            nCurrentLevel = nCount;
        }
        jCombo = JsonArrayInsert (jCombo, NuiComboEntry (sText, nCount));
        nCount ++;
    }
    jRow = CreateCombo (JsonArray (), jCombo, "start_char_lvl", 111.0, 20.0);
    jRow = CreateSlider (jRow, "xp_slider", 111.0, 20.0);
    jRow = CreateSlider (jRow, "treasure_slider", 111.0, 20.0);
    // Add row to the column.
    jCol = JsonArrayInsert (jCol, NuiRow (jRow));
    // Row 3 (labels)*********************************************************** 91
    jRow = CreateLabel (JsonArray (), "", "villain_title", 169.0f, 10.0f);
    jRow = CreateLabel (jRow, "", "unique_title", 169.0f, 10.0f);
    // Add row to the column.
    jCol = JsonArrayInsert (jCol, NuiRow (jRow));
    // Row 4 (Sliders)********************************************************** 109
    jRow = CreateSlider (JsonArray (), "villain_slider", 169.0, 20.0);
    jRow = CreateSlider (jRow, "unique_slider", 169.0, 20.0);
    // Add row to the column.
    jCol = JsonArrayInsert (jCol, NuiRow (jRow));
    // Row 5 (Buttons)********************************************************** 137
    jRow = CreateButtonSelect (JsonArray (), "Restrict Rest", "btn_rest", 125.0, 20.0);
    jRow = JsonArrayInsert (jRow, NuiSpacer ());
    jRow = CreateButtonSelect (jRow, "Restart Server", "btn_restart", 125.0, 20.0);
    // Add row to the column.
    jCol = JsonArrayInsert (jCol, NuiRow (jRow));
    // Row 6 (Wind direction)*************************************************** 165
    jRow = CreateLabel (JsonArray (), "East/West", "x_title", 95.0f, 25.0f);
    jRow = CreateTextEditBox (jRow, "name_placeholder", "x_value", 6, FALSE, 70.0, 20.0);
    jRow = CreateLabel (jRow, "North/South", "y_title", 95.0f, 25.0f);
    jRow = CreateTextEditBox (jRow, "name_placeholder", "y_value", 6, FALSE, 70.0, 20.0);
    // Add row to the column.
    jCol = JsonArrayInsert (jCol, NuiRow (jRow));
    // Row 7 (Wind changes)***************************************************** 193
    jRow = CreateLabel (JsonArray (), "Up/Down", "z_title", 95.0f, 20.0f);
    jRow = CreateTextEditBox (jRow, "name_placeholder", "z_value", 30, FALSE, 70.0, 20.0);
    jRow = CreateLabel (jRow, "Magnitude", "magnitude_title", 95.0f, 20.0f);
    jRow = CreateTextEditBox (jRow, "name_placeholder", "magnitude_value", 30, FALSE, 70.0, 20.0);
    // Add row to the column.
    jCol = JsonArrayInsert (jCol, NuiRow (jRow));
    // Row 8 (Wind changes)***************************************************** 221
    jRow = CreateLabel (JsonArray (), "Pitch", "pitch_title", 95.0f, 20.0f);
    jRow = CreateTextEditBox (jRow, "name_placeholder", "pitch_value", 30, FALSE, 70.0, 20.0);
    jRow = CreateLabel (jRow, "Yaw", "yaw_title", 95.0f, 20.0f);
    jRow = CreateTextEditBox (jRow, "name_placeholder", "yaw_value", 30, FALSE, 70.0, 20.0);
    // Add row to the column.
    jCol = JsonArrayInsert (jCol, NuiRow (jRow));
    // Row 9 (labels)*********************************************************** 249
    jRow = CreateLabel (JsonArray (), "Advance Time", "change_time_title", 110.0f, 10.0f);
    jRow = CreateLabel (jRow, "Temperature", "temp_title", 104.0f, 10.0f);
    jRow = CreateLabel (jRow, "Precipitation", "precipitation_title", 120.0f, 10.0f);
    // Add row to the column.
    jCol = JsonArrayInsert (jCol, NuiRow (jRow));
    // Row 10 (Day/Night)******************************************************** 267
    jCombo = JsonArrayInsert (JsonArray (), NuiComboEntry ("No Change", 0));
    jCombo = JsonArrayInsert (jCombo, NuiComboEntry ("Dawn", 1));
    jCombo = JsonArrayInsert (jCombo, NuiComboEntry ("Midday", 3));
    jCombo = JsonArrayInsert (jCombo, NuiComboEntry ("Dusk", 4));
    jCombo = JsonArrayInsert (jCombo, NuiComboEntry ("Midnight", 4));
    jRow = CreateCombo (JsonArray (), jCombo, "change_time", 110.0, 20.0);
    jCombo = JsonArray ();
    nCount = 0;
    while (nCount < 21)
    {
        sText = IntToString (nCount * 5);
        jCombo = JsonArrayInsert (jCombo, NuiComboEntry (sText, nCount));
        nCount ++;
    }
    jRow = CreateCombo (jRow, jCombo, "temperature", 104.0, 20.0);
    jCombo = JsonArrayInsert (JsonArray (), NuiComboEntry ("Normal", 0));
    jCombo = JsonArrayInsert (jCombo, NuiComboEntry ("Clear", 1));
    jCombo = JsonArrayInsert (jCombo, NuiComboEntry ("Raining", 2));
    jCombo = JsonArrayInsert (jCombo, NuiComboEntry ("Snowing", 3));
    jCombo = JsonArrayInsert (jCombo, NuiComboEntry ("Storming", 4));
    jRow = CreateCombo (jRow, jCombo, "precipitation", 120.0, 20.0);
    // Add row to the column.
    jCol = JsonArrayInsert (jCol, NuiRow (jRow));
    // Set the layout of the window.
    json jLayout = NuiCol (jCol);
    // Get the window location to restore it from the database.
    string sPCWindow = GetServerDatabaseString (oPC, PLAYER_TABLE, "dmserverwin");
    float fX = StringToFloat (GetStringArray (sPCWindow, 1));
    float fY = StringToFloat (GetStringArray (sPCWindow, 2));
    int nToken = SetWindow (oPC, jLayout, "dmserverwin", "Server menu",
                            fX, fY, 366.0, 299.0, FALSE, FALSE, TRUE, FALSE, TRUE);
    // Setup watch so we can save this windows position to the database.
    NuiSetBindWatch (oPC, nToken, "window_geometry", TRUE);
    // Set the buttons to show events to 0e_window.
    NuiSetBind (oPC, nToken, "start_char_lvl_selected", JsonInt (nLevel - 1));
    NuiSetBind (oPC, nToken, "start_char_lvl_event", JsonBool (TRUE));
    NuiSetBindWatch (oPC, nToken, "start_char_lvl_selected", TRUE);
    int nValue = GetServerDatabaseInt (oModule, SERVER_TABLE, "xpslider");
    string sValue = IntToString (nValue + 100);
    NuiSetBind (oPC, nToken, "xp_title_label", JsonString ("Experience " + sValue + "%"));
    NuiSetBind (oPC, nToken, "xp_slider_min", JsonInt (-100));
    NuiSetBind (oPC, nToken, "xp_slider_max", JsonInt (100));
    NuiSetBind (oPC, nToken, "xp_slider_stepsize", JsonInt (1));
    NuiSetBind (oPC, nToken, "xp_slider_value", JsonInt (nValue));
    NuiSetBind (oPC, nToken, "xp_slider_event", JsonBool (TRUE));
    NuiSetBindWatch (oPC, nToken, "xp_slider_value", TRUE);
    nValue = GetServerDatabaseInt (oModule, SERVER_TABLE, "treasureslider");
    sValue = IntToString (nValue + 100);
    NuiSetBind (oPC, nToken, "treasure_title_label", JsonString ("Treasure " + sValue + "%"));
    NuiSetBind (oPC, nToken, "treasure_slider_min", JsonInt (-100));
    NuiSetBind (oPC, nToken, "treasure_slider_max", JsonInt (100));
    NuiSetBind (oPC, nToken, "treasure_slider_stepsize", JsonInt (1));
    NuiSetBind (oPC, nToken, "treasure_slider_value", JsonInt (nValue));
    NuiSetBind (oPC, nToken, "treasure_slider_event", JsonBool (TRUE));
    NuiSetBindWatch (oPC, nToken, "treasure_slider_value", TRUE);
    nValue = GetServerDatabaseInt (oModule, SERVER_TABLE, "villainchance");
    sValue = IntToString (nValue);
    NuiSetBind (oPC, nToken, "villain_title_label", JsonString ("Villain Chance " + sValue + "%"));
    NuiSetBind (oPC, nToken, "villain_slider_min", JsonInt (0));
    NuiSetBind (oPC, nToken, "villain_slider_max", JsonInt (100));
    NuiSetBind (oPC, nToken, "villain_slider_stepsize", JsonInt (1));
    NuiSetBind (oPC, nToken, "villain_slider_value", JsonInt (nValue));
    NuiSetBind (oPC, nToken, "villain_slider_event", JsonBool (TRUE));
    NuiSetBindWatch (oPC, nToken, "villain_slider_value", TRUE);
    nValue = GetServerDatabaseInt (oModule, SERVER_TABLE, "uniquechance");
    sValue = IntToString (nValue);
    NuiSetBind (oPC, nToken, "unique_title_label", JsonString ("Unique Item Chance " + sValue + "%"));
    NuiSetBind (oPC, nToken, "unique_slider_min", JsonInt (0));
    NuiSetBind (oPC, nToken, "unique_slider_max", JsonInt (100));
    NuiSetBind (oPC, nToken, "unique_slider_stepsize", JsonInt (1));
    NuiSetBind (oPC, nToken, "unique_slider_value", JsonInt (nValue));
    NuiSetBind (oPC, nToken, "unique_slider_event", JsonBool (TRUE));
    NuiSetBindWatch (oPC, nToken, "unique_slider_value", TRUE);
    nValue = GetServerDatabaseInt (oModule, SERVER_TABLE, "restrictrest");
    NuiSetBind (oPC, nToken, "btn_rest", JsonBool (nValue));
    NuiSetBind (oPC, nToken, "btn_rest_event", JsonBool (TRUE));
    NuiSetBind (oPC, nToken, "btn_restart", JsonBool (FALSE));
    NuiSetBind (oPC, nToken, "btn_restart_event", JsonBool (TRUE));
    sValue = FloatToString (GetServerDatabaseFloat (oModule, SERVER_TABLE, "windx"), 0, 1);
    NuiSetBind (oPC, nToken, "x_value", JsonString (sValue));
    NuiSetBindWatch (oPC, nToken, "x_value", TRUE);
    sValue = FloatToString (GetServerDatabaseFloat (oModule, SERVER_TABLE, "windy"), 0, 1);
    NuiSetBind (oPC, nToken, "y_value", JsonString (sValue));
    NuiSetBindWatch (oPC, nToken, "y_value", TRUE);
    sValue = FloatToString (GetServerDatabaseFloat (oModule, SERVER_TABLE, "windz"), 0, 1);
    NuiSetBind (oPC, nToken, "z_value", JsonString (sValue));
    NuiSetBindWatch (oPC, nToken, "z_value", TRUE);
    sValue = FloatToString (GetServerDatabaseFloat (oModule, SERVER_TABLE, "windmagnitude"), 0, 1);
    NuiSetBind (oPC, nToken, "magnitude_value", JsonString (sValue));
    NuiSetBindWatch (oPC, nToken, "magnitude_value", TRUE);
    sValue = FloatToString (GetServerDatabaseFloat (oModule, SERVER_TABLE, "windyaw"), 0, 1);
    NuiSetBind (oPC, nToken, "yaw_value", JsonString (sValue));
    NuiSetBindWatch (oPC, nToken, "yaw_value", TRUE);
    sValue = FloatToString (GetServerDatabaseFloat (oModule, SERVER_TABLE, "windpitch"), 0, 1);
    NuiSetBind (oPC, nToken, "pitch_value", JsonString (sValue));
    NuiSetBindWatch (oPC, nToken, "pitch_value", TRUE);
    NuiSetBind (oPC, nToken, "change_time_selected", JsonInt (0));
    NuiSetBind (oPC, nToken, "change_time_event", JsonBool (TRUE));
    NuiSetBindWatch (oPC, nToken, "change_time_selected", TRUE);
    nValue = GetServerDatabaseInt (oModule, SERVER_TABLE, "temperature");
    nValue = nValue / 5;
    NuiSetBind (oPC, nToken, "temperature_selected", JsonInt (nValue));
    NuiSetBind (oPC, nToken, "temperature_event", JsonBool (TRUE));
    NuiSetBindWatch (oPC, nToken, "temperature_selected", TRUE);
    nValue = GetLocalInt (oModule, "0_DMWeather");
    NuiSetBind (oPC, nToken, "precipitation_selected", JsonInt (nValue));
    NuiSetBind (oPC, nToken, "precipitation_event", JsonBool (TRUE));
    NuiSetBindWatch (oPC, nToken, "precipitation_selected", TRUE);
}

void PopUpDMTransitionsGUIPanel (object oPC)
{
    // Row 1 (buttons)**********************************************************
    json jRow = CreateButton (JsonArray (), "Overland", "btn_overland", 100.0, 20.0);
    jRow = CreateButton (jRow, "Ladder", "btn_ladder", 100.0, 20.0);
    // Add the row to the column.
    json jCol = JsonArrayInsert (JsonArray (), NuiRow (jRow));
    // Row 2 (buttons)**********************************************************
    jRow = CreateButton (JsonArray (), "Wooden door", "btn_w_door", 100.0, 20.0);
    jRow = CreateButton (jRow, "Stone door", "btn_s_door", 100.0, 20.0);
    // Add the row to the column.
    jCol = JsonArrayInsert (jCol, NuiRow (jRow));
    // Row 3 (buttons)**********************************************************
    jRow = CreateButton (JsonArray (), "Grate", "btn_grate", 100.0, 20.0);
    jRow = CreateButton (jRow, "Hole", "btn_hole", 100.0, 20.0);
    // Add the row to the column.
    jCol = JsonArrayInsert (jCol, NuiRow (jRow));
    // Row 4 (buttons)**********************************************************
    jRow = CreateButton (JsonArray (), "Yellow portal", "btn_y_portal", 100.0, 20.0);
    jRow = CreateButton (jRow, "Purple portal", "btn_p_portal", 100.0, 20.0);
    // Add the row to the column.
    jCol = JsonArrayInsert (jCol, NuiRow (jRow));
    // Row 5 (buttons)**********************************************************
    jRow = CreateButton (JsonArray (), "Green portal", "btn_g_portal", 100.0, 20.0);
    jRow = CreateButton (jRow, "Red portal", "btn_r_portal", 100.0, 20.0);
    // Add the row to the column.
    jCol = JsonArrayInsert (jCol, NuiRow (jRow));
    // Row 6 (buttons)**********************************************************
    jRow = CreateButton (JsonArray (), "White portal", "btn_w_portal", 100.0, 20.0);
    jRow = CreateButton (jRow, "Clear", "btn_clear", 100.0f, 20.0f);
    // Add the row to the column.
    jCol = JsonArrayInsert (jCol, NuiRow (jRow));
    // Set the layout of the window.
    json jLayout = NuiCol (jCol);
    float fY = GetGUIHeightMiddle (oPC, 217.0);
    int nToken = SetWindow (oPC, jLayout, "dmtransitionswin", "Transition Menu",
                            0.0, fY, 228.0, 217.0, FALSE, FALSE, TRUE, FALSE, TRUE);
    // Set the buttons to show events to 0e_window.
    NuiSetBind (oPC, nToken, "btn_overland_event", JsonBool (TRUE));
    NuiSetBind (oPC, nToken, "btn_ladder_event", JsonBool (TRUE));
    NuiSetBind (oPC, nToken, "btn_w_door_event", JsonBool (TRUE));
    NuiSetBind (oPC, nToken, "btn_s_door_event", JsonBool (TRUE));
    NuiSetBind (oPC, nToken, "btn_grate_event", JsonBool (TRUE));
    NuiSetBind (oPC, nToken, "btn_hole_event", JsonBool (TRUE));
    NuiSetBind (oPC, nToken, "btn_y_portal_event", JsonBool (TRUE));
    NuiSetBind (oPC, nToken, "btn_p_portal_event", JsonBool (TRUE));
    NuiSetBind (oPC, nToken, "btn_g_portal_event", JsonBool (TRUE));
    NuiSetBind (oPC, nToken, "btn_r_portal_event", JsonBool (TRUE));
    NuiSetBind (oPC, nToken, "btn_w_portal_event", JsonBool (TRUE));
    NuiSetBind (oPC, nToken, "btn_clear_event", JsonBool (TRUE));
}

void PopUpDMFactionsGUIPanel (object oPC)
{
    object oTarget = GetLocalObject (oPC, "0_DM_Target");
    // Row 1 (buttons)********************************************************** 73
    json jRow = CreateButton (JsonArray (), "Show Current", "btn_show_c_factions", 150.0, 20.0);
    jRow = CreateButton (jRow, "Show Permanent", "btn_show_p_factions", 150.0, 20.0);
    // Add the row to the column.
    json jCol = JsonArrayInsert (JsonArray (), NuiRow (jRow));
    // Row 2 (Choice)*********************************************************** 45
    json jLabels = JsonArrayInsert (JsonArray (), JsonString ("Current Target"));
    jLabels = JsonArrayInsert (jLabels, JsonString ("All creatures"));
    jRow = CreateOption (JsonArray (), "targets", NUI_DIRECTION_HORIZONTAL, jLabels, 150.0f, 20.0f);
    // Add row to the column.
    jCol = JsonArrayInsert (jCol, NuiRow (jRow));
    // Row 3 (labels)*********************************************************** 101
    jRow = CreateLabel (JsonArray (), "Current Faction", "c_faction_title", 150.0f, 10.0f);
    jRow = JsonArrayInsert (jRow, NuiSpacer ());
    jRow = CreateLabel (jRow, "Permanent Faction", "p_faction_title", 150.0f, 10.0f);
    // Add row to the column.
    jCol = JsonArrayInsert (jCol, NuiRow (jRow));
    // Row 4 (Combo)************************************************************ 119
    json jCombo = JsonArrayInsert (JsonArray (), NuiComboEntry ("Hostile", 0));
    jCombo = JsonArrayInsert (jCombo, NuiComboEntry ("Commoner", 1));
    jCombo = JsonArrayInsert (jCombo, NuiComboEntry ("Merchant", 2));
    jCombo = JsonArrayInsert (jCombo, NuiComboEntry ("Defender", 3));
    jCombo = JsonArrayInsert (jCombo, NuiComboEntry ("Neutral", 4));
    jRow = CreateCombo (JsonArray (), jCombo, "c_faction", 150.0, 20.0);
    jRow = JsonArrayInsert (jRow, NuiSpacer ());
    jRow = CreateCombo (jRow, jCombo, "p_faction", 150.0, 20.0);
    // Add row to the column.
    jCol = JsonArrayInsert (jCol, NuiRow (jRow));
    // Set the layout of the window.
    json jLayout = NuiCol (jCol);
    float fY = GetGUIHeightMiddle (oPC, 151.0);
    int nToken = SetWindow (oPC, jLayout, "dmfactionswin", GetName (oTarget) + "'s factions menu",
                            0.0, fY, 328.0, 151.0, FALSE, FALSE, TRUE, FALSE, TRUE);
    // Set the buttons to show events to 0e_window.
    NuiSetBind (oPC, nToken, "targets_event", JsonBool (TRUE));
    int nFaction = GetLocalInt (oTarget, "0_CurrentFaction");
    NuiSetBind (oPC, nToken, "btn_show_c_factions_event", JsonBool (TRUE));
    NuiSetBind (oPC, nToken, "btn_show_p_factions_event", JsonBool (TRUE));
    NuiSetBind (oPC, nToken, "c_faction_selected", JsonInt (nFaction));
    NuiSetBind (oPC, nToken, "c_faction_event", JsonBool (TRUE));
    NuiSetBindWatch (oPC, nToken, "c_faction_selected", TRUE);
    nFaction = GetLocalInt (oTarget, "0_PermanentFaction");
    NuiSetBind (oPC, nToken, "p_faction_selected", JsonInt (nFaction));
    NuiSetBind (oPC, nToken, "p_faction_event", JsonBool (TRUE));
    NuiSetBindWatch (oPC, nToken, "p_faction_selected", TRUE);
}

void PopUpDMAdvLoadGUIPanel (object oPC)
{

    // Row 1 (List of adventures)*********************************************** 45
    // Create the button template for the List.
    json jButton = NuiId (NuiButton (NuiBind ("btns_adventure")), "btn_load");
    json jList = JsonArrayInsert (JsonArray (), NuiListTemplateCell (jButton, 200.0, TRUE));
    // Create the list with the template.
    json jRow = CreateList (JsonArray (), jList, "btns_adventure", 25.0, 250.0, 200.0);
    // Add row to the column.
    json jCol = JsonArrayInsert (JsonArray (), NuiRow (jRow));
    // Set the layout of the window.
    json jLayout = NuiCol (jCol);
    float fY = GetGUIHeightMiddle (oPC, 257.0);
    int nToken = SetWindow (oPC, jLayout, "dmadvloadwin", "Select an Adventure to load",
                            0.0, fY, 274.0, 257.0, FALSE, FALSE, TRUE, FALSE, TRUE);
    // Set the elements to show events to 0e_window.
    // Create buttons with adventures.
    json jButtons = JsonArray ();
    int nSlot = 1;
    string sName;
    while (nSlot < 11)
    {
        sName = GetServerDatabaseString (oPC, DM_TABLE, "slot" + IntToString (nSlot));
        jButtons = JsonArrayInsert (jButtons, JsonString (sName));
        nSlot ++;
    }
    // Add the buttons to the list.
    NuiSetBind (oPC, nToken, "btns_adventure", jButtons);
}

void PopUpDMAdventureGUIPanel (object oPC, int nIndex, object oArea = OBJECT_INVALID)
{
    // Set window to not save until it has been created.
    SetLocalInt (oPC, "0_No_Win_Save", TRUE);
    DelayCommand (0.5f, DeleteLocalInt (oPC, "0_No_Win_Save"));
    // Row 1 (Adventure)******************************************************** 45
    json jRow = CreateLabel (JsonArray (), "Adventure:", "name_title", 75.0f, 20.0f, -1.0, NUI_HALIGN_LEFT);
    jRow = CreateTextEditBox (jRow, "name_placeholder", "name_value", 60, FALSE, 263.0f, 20.0f);
    // Add row to the column.
    json jCol = JsonArrayInsert (JsonArray (), NuiRow (jRow));
    // Row 2 (adventure buttons)************************************************
    jRow = CreateButton (JsonArray (), "Load", "btn_load_adv", 80.0, 20.0);
    jRow = JsonArrayInsert (jRow, NuiSpacer ());
    jRow = CreateButton (jRow, "Save", "btn_save_adv", 80.0, 20.0);
    jRow = JsonArrayInsert (jRow, NuiSpacer ());
    jRow = CreateButton (jRow, "Clear", "btn_clear_adv", 80.0, 20.0);
    // Add the row to the column.
    jCol = JsonArrayInsert (jCol, NuiRow (jRow));
    // Row 3 (Area title)******************************************************* 73
    jRow = CreateLabel (JsonArray (), "Areas", "areas_title", 342.0f, 10.0f, -1.0, NUI_HALIGN_CENTER);
    // Add row to the column.
    jCol = JsonArrayInsert (jCol, NuiRow (jRow));
    // Row 4 (List of areas)**************************************************** 91
    // Create the button template for the List.
    json jButton = NuiId (NuiButton (NuiBind ("btns_area")), "btn_area");
    json jList = JsonArrayInsert (JsonArray (), NuiListTemplateCell (jButton, 250.0, TRUE));
    // Create the list with the template.
    jRow = JsonArrayInsert (JsonArray (), NuiSpacer ());
    jRow = CreateList (jRow, jList, "btns_area", 25.0, 300.0, 200.0);
    jRow = JsonArrayInsert (jRow, NuiSpacer ());
    // Add row to the column.
    jCol = JsonArrayInsert (jCol, NuiRow (jRow));
    // Row 5 (adventure buttons)************************************************ 299
    jRow = CreateButton (JsonArray (), "Jump to area", "btn_jump_area", 100.0, 20.0);
    jRow = JsonArrayInsert (jRow, NuiSpacer ());
    jRow = CreateButton (jRow, "Examine area", "btn_open_area", 100.0, 20.0);
    jRow = JsonArrayInsert (jRow, NuiSpacer ());
    jRow = CreateButton (jRow, "Save area", "btn_save_area", 100.0, 20.0);
    // Add the row to the column.
    jCol = JsonArrayInsert (jCol, NuiRow (jRow));
    // Row 6 (Area title)******************************************************* 327
    jRow = CreateLabel (JsonArray (), "", "area_selected", 342.0f, 10.0f, -1.0, NUI_HALIGN_CENTER);
    // Add row to the column.
    jCol = JsonArrayInsert (jCol, NuiRow (jRow));
    // Row 7 (adventure buttons)************************************************ 345
    jRow = CreateButton (JsonArray (), "Load area", "btn_load_area", 150.0, 20.0);
    jRow = JsonArrayInsert (jRow, NuiSpacer ());
    jRow = CreateButton (jRow, "Remove area", "btn_remove_area", 150.0, 20.0);
    // Add the row to the column.
    jCol = JsonArrayInsert (jCol, NuiRow (jRow));
    // Set the layout of the window.
    json jLayout = NuiCol (jCol);
    // Get the window location to restore it from the database.
    string sPCWindow = GetServerDatabaseString (oPC, PLAYER_TABLE, "dmadventurewin");
    float fX = StringToFloat (GetStringArray (sPCWindow, 1));
    float fY = StringToFloat (GetStringArray (sPCWindow, 2));
    int nToken = SetWindow (oPC, jLayout, "dmadventurewin", "Adventure menu",
                            fX, fY, 366.0, 377.0, FALSE, FALSE, TRUE, FALSE, TRUE);
    // Setup watch so we can save this windows position to the database.
    NuiSetBindWatch (oPC, nToken, "window_geometry", TRUE);
    // Set the elements to show events to 0e_window.
    string sName = GetServerDatabaseString (oPC, DM_TABLE, "slot" + IntToString (nIndex));
    if (sName == "Empty") sName = "Adventure " + IntToString (nIndex);
    NuiSetBind (oPC, nToken, "name_value", JsonString (sName));
    NuiSetBind (oPC, nToken, "btn_load_adv_event", JsonBool (TRUE));
    NuiSetBind (oPC, nToken, "btn_save_adv_event", JsonBool (TRUE));
    NuiSetBind (oPC, nToken, "btn_clear_adv_event", JsonBool (TRUE));
    // Create buttons with adventures.
    json jButtons = JsonArray ();
    int nSlot = 1;
    string sAreaTag, sDBTag, sIndex = IntToString (nIndex);
    while (nSlot < 11)
    {
        sDBTag = "Slot" + sIndex + "_Area" + IntToString (nSlot);
        sAreaTag = GetServerDatabaseString (oPC, AREA_TABLE, "areatag", sDBTag);
        if (sAreaTag == "") sName = "Area " + IntToString (nSlot);
        else sName = GetServerDatabaseString (oPC, AREA_TABLE, "areaname", sDBTag);
        jButtons = JsonArrayInsert (jButtons, JsonString (sName));
        nSlot ++;
    }
    // Add the buttons to the list.
    NuiSetBind (oPC, nToken, "btns_area", jButtons);
    if (oArea == OBJECT_INVALID)
    {
        oArea = GetArea (oPC);
        SetLocalObject (oPC, "0_DM_Target", oArea);
        SetPlayerWinTarget (oPC, GetName (oArea));
        NuiSetBind (oPC, nToken, "btn_jump_area_event", JsonBool (FALSE));
        NuiSetBind (oPC, nToken, "btn_load_area_event", JsonBool (FALSE));
        NuiSetBind (oPC, nToken, "btn_remove_area_event", JsonBool (FALSE));
    }
    else
    {
        NuiSetBind (oPC, nToken, "btn_jump_area_event", JsonBool (TRUE));
        NuiSetBind (oPC, nToken, "btn_load_area_event", JsonBool (TRUE));
        NuiSetBind (oPC, nToken, "btn_remove_area_event", JsonBool (TRUE));
    }
    NuiSetBind (oPC, nToken, "area_selected_label", JsonString (GetName (oArea)));
    NuiSetBind (oPC, nToken, "btn_save_area_event", JsonBool (TRUE));
    NuiSetBind (oPC, nToken, "btn_open_area_event", JsonBool (TRUE));
    SetLocalInt (oPC, "0_Adventure_Num", nIndex);
}

