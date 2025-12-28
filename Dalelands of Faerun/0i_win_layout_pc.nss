/*//////////////////////////////////////////////////////////////////////////////
// Script Name: 0i_win_layout_pc
////////////////////////////////////////////////////////////////////////////////
 Include script for creating player and DM layouts for NUI.

 Layout pixel sizes:
 Pixel width Title bar 33.
 Pixel height Top edge 12, between widgets 8, bottom edge 12.
 Pixel width Left edge 12, between widgets 4, right edge 12.
*///////////////////////////////////////////////////////////////////////////////
// Programmer: Philos
////////////////////////////////////////////////////////////////////////////////
#include "nw_inc_nui_insp"
#include "0i_window"
#include "0i_items"
#include "0i_character"
#include "0i_crafting"

// Returns the geometry data of sWindowID.
// If the data does not exist in the database it will create a blank window
// geometry where the window will start in the top middle.
// sWindowID is the ID of the window to get the data from.
json GetWindowGeometryFromDB(object oPC, string sWindowID);
struct stComboBox CreateUseLangCombo (object oPC, struct stComboBox stCBox, string sComboBind);
struct stComboBox CreateTakeLangCombo (object oPC, struct stComboBox stCBox, string sComboBind);
int GetNumOfLanguages (object oPC);
struct stComboBox GetSummons (object oPC);
struct stComboBox CreateSummonCombo (object oPC, struct stComboBox stCBox, string sSpellName, string sComboBind, int nSummons);
string GetRollText (object oPlayer);
json CreateNumOfDiceCombo (json jRow, string sComboBind);
json CreateRollTypeCombo (object oTarget, json jRow, string sComboBind);
json CreateDieBonusCombo (json jRowx, string sComboBind);
json CreateBroadcastCombo (object oPC, json jRowx, string sComboBind);
json CreateItemCombo (object oPC, json jRow, string sComboBind);
json CreateModelCombo (object oPC, json jRow, string sComboBind);
json CreateMaterialCombo (object oPC, json jRow, string sComboBind);
// Pops up a Yes/No panel to be used to answer a yes no question.
// fTextBoxX must be at least 108.0f.
// fTextBoxY must be at least 30.0f.
// SetLocalString(oCaster, "YES_NO_MENU", ""); then add code to 0e_window to use the yes/no menu.
void PopUpYesNoPanel(object oPC, string sTitle, string sMessage, float fTextBoxX, float fTextBoxY);

json CreateWindowGeometry()
{
    json jGeometry = JsonObjectSet(JsonObject(), "h", JsonFloat(0.0));
    jGeometry = JsonObjectSet(jGeometry, "w", JsonFloat(0.0));
    jGeometry = JsonObjectSet(jGeometry, "x", JsonFloat(-1.0));
    return JsonObjectSet(jGeometry, "y", JsonFloat(0.0));
}
json GetWindowGeometryFromDB(object oPC, string sWindowID)
{
    json jGeometry, jWindows = GetServerDatabaseJson(oPC, PLAYER_TABLE, "playerwindows");
    if(JsonGetType(jWindows) == JSON_TYPE_NULL)
    {
        jGeometry = CreateWindowGeometry();
        jWindows = JsonObjectSet(JsonObject(), sWindowID, jGeometry);
        SetServerDatabaseJson(oPC, PLAYER_TABLE, "playerwindows", jWindows);
    }
    else
    {
        jGeometry = JsonObjectGet(jWindows, sWindowID);
        if(JsonGetType(jGeometry) == JSON_TYPE_NULL)
        {
            jGeometry = CreateWindowGeometry();
            jWindows = JsonObjectSet(jWindows, sWindowID, jGeometry);
            SetServerDatabaseJson(oPC, PLAYER_TABLE, "playerwindows", jWindows);
        }
    }
    return jGeometry;
}
// Finishes the player GUIPanel after the layout is set.
void SetupPlayerGUIPanel (object oPC, json jCol, float fWinLength, float fWinHeight)
{
    // Get the window location from the database.
    json jGeometry = GetWindowGeometryFromDB(oPC, "plplayerwin");
    float fX = JsonGetFloat(JsonObjectGet(jGeometry, "x"));
    float fY = JsonGetFloat(JsonObjectGet(jGeometry, "y"));
    // Set the layout of the window.
    json jLayout = NuiCol(jCol);
    int nToken = SetWindow(oPC, jLayout, "plplayerwin", "Player Menu",
                            fX, fY, fWinLength, fWinHeight, FALSE, TRUE, FALSE, FALSE, TRUE);
    // Save token incase we need to change layout.
    SetLocalInt (oPC, "0_Menu_Token", nToken);
    // Set event watches for save window location.
    NuiSetBindWatch (oPC, nToken, "window_geometry", TRUE);
    // Set the buttons to show events to 0e_window.
    NuiSetBind (oPC, nToken, "btn_options_event", JsonBool (TRUE));
    NuiSetBind (oPC, nToken, "btn_stats_event", JsonBool (TRUE));
    NuiSetBind (oPC, nToken, "btn_magic_event", JsonBool (TRUE));
    NuiSetBind (oPC, nToken, "btn_lang_event", JsonBool (TRUE));
    NuiSetBind (oPC, nToken, "btn_desc_event", JsonBool (TRUE));
    NuiSetBind (oPC, nToken, "btn_craft_event", JsonBool (TRUE));
    NuiSetBind (oPC, nToken, "btn_dice_event", JsonBool (TRUE));
    NuiSetBind (oPC, nToken, "btn_bug_report_event", JsonBool (TRUE));
    // Check for special buttons that admins use.
    int nPCStatus = GetServerDatabaseInt (oPC, PLAYER_TABLE, "status");
    if (nPCStatus == 5)
    {
        //NuiSetBind (oPC, nToken, "btn_cynosure", JsonBool (TRUE));
        //NuiSetBind (oPC, nToken, "btn_dm_mode", JsonBool (FALSE));
        NuiSetBind (oPC, nToken, "btn_cynosure_event", JsonBool (TRUE));
        NuiSetBind (oPC, nToken, "btn_dm_mode_event", JsonBool (TRUE));
    }
}

void PopUpPlayerVerGUIPanel (object oPC)
{
    // Set window to not save until it has been created.
    SetLocalInt (oPC, "0_No_Win_Save", TRUE);
    DelayCommand (0.5f, DeleteLocalInt (oPC, "0_No_Win_Save"));
    float fWinHeight = 157.0f;
    int nPCStatus = GetServerDatabaseInt (oPC, PLAYER_TABLE, "status");
    // Row 1 (buttons)********************************************************** 45
    json jRow = CreateButton (JsonArray (), "Options", "btn_options", 100.0f, 20.0f);
    jRow = CreateButton (jRow, "Stats", "btn_stats", 100.0f, 20.0f);
    // Add the row to the column.
    json jCol = JsonArrayInsert (JsonArray (), NuiRow (jRow));
    // Row 2 (buttons)********************************************************** 73
    jRow = CreateButton (JsonArray (), "Magic", "btn_magic", 100.0f, 20.0f);
    jRow = CreateButton (jRow, "Languages", "btn_lang", 100.0f, 20.0f);
    // Add the row to the column.
    jCol = JsonArrayInsert (jCol, NuiRow (jRow));
    // Row 3 (buttons)********************************************************** 101
    jRow = CreateButton (JsonArray (), "Description", "btn_desc", 100.0f, 20.0f);
    jRow = CreateButton (jRow, "Crafting", "btn_craft", 100.0f, 20.0f);
    // Add the row to the column.
    jCol = JsonArrayInsert (jCol, NuiRow (jRow));
    // Row 4 (buttons)********************************************************** 129
    jRow = CreateButton (JsonArray (), "Dice", "btn_dice", 100.0f, 20.0f);
    jRow = CreateButton (jRow, "Bug Report", "btn_bug_report", 100.0f, 20.0f);
    // Add the row to the column.
    jCol = JsonArrayInsert (jCol, NuiRow (jRow));
    // If we are an admin then create another row of buttons.
    if (nPCStatus == 5)
    {
        // Row 5 (buttons)****************************************************** 157
        jRow = CreateButton (JsonArray (), "Cynosure", "btn_cynosure", 100.0f, 20.0f);
        jRow = CreateButton (jRow, "DM Mode", "btn_dm_mode", 100.0f, 20.0f);
        fWinHeight = 185.0f;
        // Add the row to the column and set column height.
        jCol = JsonArrayInsert (jCol, NuiRow (jRow));
    }
    SetupPlayerGUIPanel (oPC, jCol, 228.0f, fWinHeight);
}

void PopUpSmallGUIPanel (object oPC)
{
    // Set window to not save until it has been created.
    SetLocalInt (oPC, "0_No_Win_Save", TRUE);
    DelayCommand (0.5f, DeleteLocalInt (oPC, "0_No_Win_Save"));
    // Row 1 (buttons)**********************************************************
    json jRow = CreateButton (JsonArray (), "Menu", "btn_open", 45.0f, 25.0f);
    // Add the row to the column.
    json jCol = JsonArrayInsert (JsonArray (), NuiRow (jRow));
    // Set the layout of the window.
    json jLayout = NuiCol (jCol);
    float fGUI_Width = IntToFloat (GetPlayerDeviceProperty (oPC, PLAYER_DEVICE_PROPERTY_GUI_WIDTH));
    int nToken = SetWindow (oPC, jLayout, "plsmallwin", "", fGUI_Width, 0.0, 70.0, 50.0, FALSE, FALSE, FALSE, TRUE, FALSE);
    // Save token incase we need to change layout.
    SetLocalInt (oPC, "0_Menu_Token", nToken);
    // Set event watches for window inspector and save window location.
    NuiSetBindWatch (oPC, nToken, "collapsed", TRUE);
    NuiSetBindWatch (oPC, nToken, "window_geometry", TRUE);
    NuiSetBind (oPC, nToken, "window_title", JsonBool (FALSE));
    // Set the buttons to show events to 0e_window.
    NuiSetBind (oPC, nToken, "btn_open_event", JsonBool (TRUE));
}

void PopUpPlayerOptionsGUIPanel (object oPC)
{
    // Set window to not save until it has been created.
    SetLocalInt (oPC, "0_No_Win_Save", TRUE);
    DelayCommand (0.5f, DeleteLocalInt (oPC, "0_No_Win_Save"));
    // Row 1 (title)************************************************************ 45
    json jRow = CreateLabel (JsonArray (), "Player Menu", "menu_opt_title", 150.0, 10.0);
    jRow = CreateLabel (jRow, "Sleep Animation", "sleep_opt_title", 150.0, 10.0);
    // Add the row to the column and set column height.
    json jCol = JsonArrayInsert (JsonArray (), NuiRow (jRow));
    // Row 2 (combo boxes)****************************************************** 63
    // Create small display option button.
    jRow = JsonArrayInsert (JsonArray (), NuiSpacer ());
    jRow = CreateButton (jRow, "Minimize", "btn_minimize", 150.0f, 25.0f);
    jRow = JsonArrayInsert (jRow, NuiSpacer ());
    // Insert elements into the combo box array.
    json jCombo = JsonArrayInsert (JsonArray (), NuiComboEntry ("Sit down", 0));
    jCombo = JsonArrayInsert (jCombo, NuiComboEntry ("Stand up", 1));
    jCombo = JsonArrayInsert (jCombo, NuiComboEntry ("Lay facedown", 2));
    jCombo = JsonArrayInsert (jCombo, NuiComboEntry ("Lay faceup", 3));
    jCombo = JsonArrayInsert (jCombo, NuiComboEntry ("Meditate", 4));
    jCombo = JsonArrayInsert (jCombo, NuiComboEntry ("Worship", 5));
    jRow = CreateCombo (jRow, jCombo, "sleep_opt", 150.0, 25.0);
    jRow = JsonArrayInsert (jRow, NuiSpacer ());
    // Add row to the column.
    jCol = JsonArrayInsert (jCol, NuiRow (jRow));
    // Row 3 (label)************************************************************ 88
    jRow = JsonArrayInsert (JsonArray (), NuiSpacer ());
    jRow = CreateLabel (jRow, "Enter your character name to delete them!", "delete_char_title", 300.0, 20.0f);
    jRow = JsonArrayInsert (jRow, NuiSpacer ());
    // Add row to the column.
    jCol = JsonArrayInsert (jCol, NuiRow (jRow));
    // Row 4 (text edit box)**************************************************** 116
    jRow = JsonArrayInsert (JsonArray (), NuiSpacer ());
    jRow = CreateTextEditBox (jRow, "delete_char_placeholder", "delete_char_value", 30, FALSE, 300.0f, 20.0f, "delete_char_tooltip");
    jRow = JsonArrayInsert (jRow, NuiSpacer ());
    // Add row to the column.
    jCol = JsonArrayInsert (jCol, NuiRow (jRow));
    // Row 5 (buttons)********************************************************** 144
    jRow = JsonArrayInsert (JsonArray (), NuiSpacer ());
    jRow = CreateButton (jRow, "Delete Character", "btn_delete_char", 160.0f, 20.0f);
    jRow = JsonArrayInsert (jRow, NuiSpacer ());
    jRow = CreateButton (jRow, "Credits", "btn_credits", 100.0f, 20.0f);
    jRow = JsonArrayInsert (jRow, NuiSpacer ());
    // Add row to the column.
    jCol = JsonArrayInsert (jCol, NuiRow (jRow));
    // Row 6 (password label)*************************************************** 172
    jRow = JsonArrayInsert (JsonArray (), NuiSpacer ());
    jRow = CreateLabel (jRow, "Set Password", "password_title", 300.0, 10.0f);
    jRow = JsonArrayInsert (jRow, NuiSpacer ());
    // Add row to the column.
    jCol = JsonArrayInsert (jCol, NuiRow (jRow));
    // Row 6 (password)********************************************************* 190
    jRow = JsonArrayInsert (JsonArray (), NuiSpacer ());
    jRow = CreateTextEditBox (jRow, "password_placeholder", "password_value", 30, FALSE, 160.0f, 20.0f);
    jRow = JsonArrayInsert (jRow, NuiSpacer ());
    jRow = CreateButton (jRow, "Set Password", "btn_set_password", 100.0f, 20.0f);
    jRow = JsonArrayInsert (jRow, NuiSpacer ());
    // Add row to the column.
    jCol = JsonArrayInsert (jCol, NuiRow (jRow));
    // Get the window location from the database.
    json jGeometry = GetWindowGeometryFromDB(oPC, "ploptionwin");
    float fX = JsonGetFloat(JsonObjectGet(jGeometry, "x"));
    float fY = JsonGetFloat(JsonObjectGet(jGeometry, "y"));
    // Set the Layout of the window.
    json jLayout = NuiCol(jCol);
    int nToken = SetWindow(oPC, jLayout, "ploptionwin", "Options",
                            fX, fY, 328.0f, 240.0f, FALSE, FALSE, TRUE, FALSE, TRUE);
    // Set all binds, events, and watches.
    NuiSetBindWatch (oPC, nToken, "window_geometry", TRUE);
    NuiSetBind (oPC, nToken, "btn_minimize_event", JsonBool (TRUE));
    string sOptions = GetObjectDatabaseString (oPC, CHARACTER_TABLE, "appearance");
    int nMenuOption = StringToInt (GetStringArray (sOptions, 3));
    NuiSetBind (oPC, nToken, "sleep_opt_selected", JsonInt (nMenuOption));
    NuiSetBind (oPC, nToken, "sleep_opt_event", JsonBool (TRUE));
    NuiSetBind (oPC, nToken, "btn_credits_event", JsonBool (TRUE));
    NuiSetBind (oPC, nToken, "btn_delete_char_event", JsonBool (TRUE));
    NuiSetBind (oPC, nToken, "delete_char_tooltip", JsonString (
      "Enter character name, hit delete button to delete them permanently!"));
    NuiSetBind (oPC, nToken, "btn_set_password_event", JsonBool (TRUE));
    NuiSetBindWatch (oPC, nToken, "sleep_opt_selected", TRUE);
}

void PopUpPlayerListGUIPanel (object oPC)
{
    // Set window to not save until it has been created.
    SetLocalInt (oPC, "0_No_Win_Save", TRUE);
    DelayCommand (0.5f, DeleteLocalInt (oPC, "0_No_Win_Save"));
    // Row 1 (buttons)********************************************************** 45
    // Create small display option button.
    json jRow = CreateButtonImage (JsonArray (), "ir_invite", "btn_p_invite", 32.0, 32.0, -1.0, "invite_tooltip");
    jRow = CreateButtonImage (jRow, "ir_kick", "btn_p_kick", 32.0, 32.0, -1.0, "kick_tooltip");
    jRow = CreateButtonImage (jRow, "ir_leave", "btn_p_leave", 32.0, 32.0, -1.0, "leave_tooltip");
    jRow = CreateButtonImage (jRow, "ir_transleader", "btn_p_ch_leader", 32.0, 32.0, -1.0, "change_leader_tooltip");
    jRow = CreateButtonImage (jRow, "ir_examine", "btn_p_examine", 32.0, 32.0, -1.0, "examine_tooltip");
    jRow = CreateLabel (jRow, "", "blank_label", 58.0, 32.0);
    jRow = CreateButton (jRow, "", "btn_role_play", 70.0f, 32.0f, -1.0, "role_play_tooltip");
    jRow = CreateButton (jRow, "", "btn_party_interest", 70.0f, 32.0f, -1.0, "party_interest_tooltip");
    jRow = CreateButton (jRow, "", "btn_dm_events", 70.0f, 32.0f, -1.0, "dm_events_tooltip");
    // Add row to the column.
    json jCol = JsonArrayInsert (JsonArray (), NuiRow (jRow));
    // Row 2 (Labels)*********************************************************** 85
    jRow = CreateLabel (JsonArray (), "Character [Player]", "char_player_name", 237.0, 20.0f);
    jRow = CreateLabel (jRow, "RolePlay", "list_rp_lb", 65.0, 20.0f, -1.0, 1);
    jRow = CreateLabel (jRow, "Party", "list_party_lb", 65.0, 20.0f, -1.0, 1);
    jRow = CreateLabel (jRow, "DM Events", "list_dm_events_lb", 65.0, 20.0f, -1.0, 1);
    // Add row to the column.
    jCol = JsonArrayInsert (jCol, NuiRow (jRow));
    // Row 3 (player list)****************************************************** 113
    // Create the list with the template.
    // Character picture.
    json jCharacterPic = NuiImage (NuiBind ("char_pic"), JsonInt (NUI_ASPECT_EXACTSCALED), JsonInt (NUI_HALIGN_CENTER), JsonInt (NUI_VALIGN_TOP));
    jCharacterPic = NuiMargin (jCharacterPic, 0.0);
    jCharacterPic = NuiGroup (jCharacterPic, FALSE, NUI_SCROLLBARS_NONE);
    jCharacterPic = NuiHeight (jCharacterPic,50.0);
    jCharacterPic = NuiId (jCharacterPic, "character_pic");
    json jList = JsonArrayInsert (JsonArray (), NuiListTemplateCell (jCharacterPic, 32.0, FALSE));
    // Character name.
    json jCharacterName = NuiLabel (NuiBind ("char_name"), JsonInt (NUI_HALIGN_LEFT), JsonInt (NUI_VALIGN_TOP));
    jCharacterName = NuiStyleForegroundColor (jCharacterName, NuiBind ("text_color"));
    json jBorderPoints = JsonArray ();
    jBorderPoints = JsonArrayInsert (jBorderPoints, JsonFloat (0.0));
    jBorderPoints = JsonArrayInsert (jBorderPoints, JsonFloat (0.0));
    jBorderPoints = JsonArrayInsert (jBorderPoints, JsonFloat (536.0));
    jBorderPoints = JsonArrayInsert (jBorderPoints, JsonFloat (0.0));
    json jBorder = JsonArrayInsert (JsonArray (), NuiDrawListPolyLine (JsonBool (TRUE), NuiColor (255, 255, 255), JsonBool (FALSE), JsonFloat (1.0), jBorderPoints));
    jCharacterName = NuiDrawList (jCharacterName, JsonBool (TRUE), jBorder);
    json jPlayerName = JsonArrayInsert (JsonArray (), NuiDrawListText (JsonBool (TRUE), NuiColor (255, 255, 255), NuiRect (0.0, 15.0, 200.0, 25.0), NuiBind ("player_name")));
    jCharacterName = NuiDrawList (jCharacterName, JsonBool (TRUE), jPlayerName);
    jCharacterName = NuiId (jCharacterName, "character_name");
    jList = JsonArrayInsert (jList, NuiListTemplateCell (jCharacterName, 200.0, FALSE));
    // Character roleplay.
    json jCharacterRP = NuiLabel (NuiBind ("char_roleplay"), JsonInt (NUI_HALIGN_LEFT), JsonInt (NUI_VALIGN_TOP));
    jCharacterRP = NuiId (jCharacterRP, "character_roleplay");
    jList = JsonArrayInsert (jList, NuiListTemplateCell (jCharacterRP, 65.0, FALSE));
    // Character party option.
    json jCharacterParty = NuiLabel (NuiBind ("char_party"), JsonInt (NUI_HALIGN_LEFT), JsonInt (NUI_VALIGN_TOP));
    jCharacterParty = NuiId (jCharacterParty, "character_party");
    jList = JsonArrayInsert (jList, NuiListTemplateCell (jCharacterParty, 65.0, FALSE));
    // Character DM events.
    json jCharacterEvents = NuiLabel (NuiBind ("char_events"), JsonInt (NUI_HALIGN_LEFT), JsonInt (NUI_VALIGN_TOP));
    jCharacterEvents = NuiId (jCharacterEvents, "character_events");
    jList = JsonArrayInsert (jList, NuiListTemplateCell (jCharacterEvents, 65.0, FALSE));
    jRow = CreateList (JsonArray (), jList, "char_name", 50.0, 512.0, 200.0);
    // Add row to the column.
    jCol = JsonArrayInsert (jCol, NuiRow (jRow));
    // Row 4 (Labels)*********************************************************** 321
    jRow = CreateLabel (JsonArray (), "", "player_target", 32.0, 32.0f, -1.0, 1);
    json jLabel = JsonArray ();
    jLabel = NuiLabel (NuiBind ("target_label"), JsonInt (1), JsonInt (0));
    jLabel = NuiWidth (jLabel, 200.0);
    jLabel = NuiHeight (jLabel, 32.0);
    jLabel = NuiStyleForegroundColor (jLabel, NuiBind ("target_color"));
    jRow = JsonArrayInsert (jRow, jLabel);
    // Create small texting option buttons.
    jRow = CreateButtonImage (jRow, "ir_chat", "btn_chat", 32.0, 32.0, -1.0, "chat_tooltip");
    jRow = CreateButtonImage (jRow, "ir_partychat", "btn_partychat", 32.0, 32.0, -1.0, "partychat_tooltip");
    jRow = CreateButtonImage (jRow, "ir_shouts", "btn_shout", 32.0, 32.0, -1.0, "shout_tooltip");
    jRow = CreateButtonImage (jRow, "ir_dmchat", "btn_dmchat", 32.0, 32.0, -1.0, "dmchat_tooltip");
    jRow = CreateButton (jRow, "Send", "btn_send", 70.0f, 32.0f);
    // Add row to the column.
    jCol = JsonArrayInsert (jCol, NuiRow (jRow));
    // Row 5 (chat box)********************************************************* 361
    jRow = CreateTextEditBox (JsonArray (), "chat_placeholder", "chat_value", 1000, TRUE, 512.0, 40.0);
    // Add row to the column.
    jCol = JsonArrayInsert (jCol, NuiRow (jRow));
    // Get the window location from the database.
    json jGeometry = GetWindowGeometryFromDB(oPC, "pllistwin");
    float fX = JsonGetFloat(JsonObjectGet(jGeometry, "x"));
    float fY = JsonGetFloat(JsonObjectGet(jGeometry, "y"));
    // Set the Layout of the window.
    json jLayout = NuiCol (jCol);
    int nToken = SetWindow (oPC, jLayout, "pllistwin", "Player List",
                            fX, fY, 536.0f, 409.0f, FALSE, FALSE, TRUE, FALSE, TRUE);
    // Set all binds, events, and watches.
    NuiSetBindWatch (oPC, nToken, "window_geometry", TRUE);
    NuiSetBind (oPC, nToken, "btn_p_invite_event", JsonBool (FALSE));
    NuiSetBind (oPC, nToken, "invite_tooltip", JsonString (
      "  Invite Into Party"));
    NuiSetBind (oPC, nToken, "btn_p_kick_event", JsonBool (FALSE));
    NuiSetBind (oPC, nToken, "kick_tooltip", JsonString (
      "  Kick From Party"));
    NuiSetBind (oPC, nToken, "btn_p_leave_event", JsonBool (FALSE));
    NuiSetBind (oPC, nToken, "leave_tooltip", JsonString (
      "  Leave Party"));
    NuiSetBind (oPC, nToken, "btn_p_ch_leader_event", JsonBool (FALSE));
    NuiSetBind (oPC, nToken, "change_leader_tooltip", JsonString (
      "  Change Leadership"));
    NuiSetBind (oPC, nToken, "btn_p_examine_event", JsonBool (FALSE));
    NuiSetBind (oPC, nToken, "examine_tooltip", JsonString (
      "  Examine player"));
    NuiSetBind (oPC, nToken, "btn_role_play_event", JsonBool (TRUE));
    int nOption = GetLocalInt (oPC, "0_ROLE_PLAY");
    if (nOption == 0) NuiSetBind (oPC, nToken, "btn_role_play_label", JsonString ("None"));
    else if (nOption == 1) NuiSetBind (oPC, nToken, "btn_role_play_label", JsonString ("Light"));
    else if (nOption == 2) NuiSetBind (oPC, nToken, "btn_role_play_label", JsonString ("Heavy"));
    else if (nOption == 3) NuiSetBind (oPC, nToken, "btn_role_play_label", JsonString ("Always"));
    NuiSetBind (oPC, nToken, "role_play_tooltip", JsonString (
      "  Willing to Role Play?"));
    NuiSetBind (oPC, nToken, "btn_party_interest_event", JsonBool (TRUE));
    nOption = GetLocalInt (oPC, "0_PARTY");
    if (nOption == 0) NuiSetBind (oPC, nToken, "btn_party_interest_label", JsonString ("None"));
    else if (nOption == 1) NuiSetBind (oPC, nToken, "btn_party_interest_label", JsonString ("Small"));
    else if (nOption == 2) NuiSetBind (oPC, nToken, "btn_party_interest_label", JsonString ("Any"));
    NuiSetBind (oPC, nToken, "party_interest_tooltip", JsonString (
      "  Willing to Party up?"));
    NuiSetBind (oPC, nToken, "btn_dm_events_event", JsonBool (TRUE));
    nOption = GetLocalInt (oPC, "0_DM_EVENTS");
    if (nOption == 0) NuiSetBind (oPC, nToken, "btn_dm_events_label", JsonString ("None"));
    else if (nOption == 1) NuiSetBind (oPC, nToken, "btn_dm_events_label", JsonString ("Short"));
    else if (nOption == 2) NuiSetBind (oPC, nToken, "btn_dm_events_label", JsonString ("Long"));
    else if (nOption == 3) NuiSetBind (oPC, nToken, "btn_dm_events_label", JsonString ("Any"));
    NuiSetBind (oPC, nToken, "dm_events_tooltip", JsonString (
      "  Willing to play in a DM event?"));
    // Create buttons with players.
    string sAreaName;
    json jListCharPics = JsonArray ();
    json jListCharNames = JsonArray ();
    json jListPlayerNames = JsonArray ();
    json jListCharRP = JsonArray ();
    json jListCharParty = JsonArray ();
    json jListCharEvents = JsonArray ();
    json jListTextColor = JsonArray ();
    json jObjectList = JsonArray ();
    object oPlayer = GetFirstObjectInArea (GetArea (oPC), OBJECT_TYPE_CREATURE);
    while (oPlayer != OBJECT_INVALID)
    {
        jListCharPics = JsonArrayInsert (jListCharPics, JsonString (GetPortraitResRef (oPlayer) + "s"));
        jListCharNames = JsonArrayInsert (jListCharNames, JsonString (StripColorCodes (GetName (oPlayer))));
        if (GetIsCharacter (oPlayer))
        {
            jListTextColor = JsonArrayInsert (jListTextColor, NuiColor (210, 160, 0));
            jListPlayerNames = JsonArrayInsert (jListPlayerNames, JsonString ("[" + GetPCPlayerName (oPlayer) + "]"));
        }
        else
        {
            jListTextColor = JsonArrayInsert (jListTextColor, NuiColor (255, 255, 255));
            jListPlayerNames = JsonArrayInsert (jListPlayerNames, JsonString ("[NPC]"));
        }
        int nOption = GetLocalInt (oPlayer, "0_ROLE_PLAY");
        string sOption;
        if (nOption == 0) sOption = "None";
        else if (nOption == 1) sOption = "Light";
        else if (nOption == 2) sOption = "Heavy";
        else if (nOption == 3) sOption = "Always";
        jListCharRP = JsonArrayInsert (jListCharRP, JsonString (sOption));
        nOption = GetLocalInt (oPlayer, "0_PARTY");
        if (nOption == 0) sOption = "None";
        else if (nOption == 1) sOption = "Small";
        else if (nOption == 2) sOption = "Any";
        jListCharParty = JsonArrayInsert (jListCharParty, JsonString (sOption));
        nOption = GetLocalInt (oPlayer, "0_DM_EVENTS");
        if (nOption == 0) sOption = "None";
        else if (nOption == 1) sOption = "Short";
        else if (nOption == 2) sOption = "Long";
        else if (nOption == 3) sOption = "Any";
        jListCharEvents = JsonArrayInsert (jListCharEvents, JsonString (sOption));
        jObjectList = JsonArrayInsert (jObjectList, JsonString (GetObjectUUID (oPlayer)));
        NuiSetUserData (oPC, nToken, jObjectList);
        oPlayer = GetNextObjectInArea (GetArea (oPC), OBJECT_TYPE_CREATURE);
    }
    // Add the cells to the list.
    NuiSetBind (oPC, nToken, "char_pic", jListCharPics);
    NuiSetBind (oPC, nToken, "char_name", jListCharNames);
    NuiSetBind (oPC, nToken, "text_color", jListTextColor);
    NuiSetBind (oPC, nToken, "player_name", jListPlayerNames);
    NuiSetBind (oPC, nToken, "char_roleplay", jListCharRP);
    NuiSetBind (oPC, nToken, "char_party", jListCharParty);
    NuiSetBind (oPC, nToken, "char_events", jListCharEvents);
    oPlayer = GetLocalObject (oPC, "0_List_Target");
    string sTarget = GetName (oPlayer);
    if (sTarget != "")
    {
        if (GetIsCharacter (oPlayer)) NuiSetBind (oPC, nToken, "target_color", NuiColor (210, 160, 0));
        else NuiSetBind (oPC, nToken, "target_color", NuiColor (255, 255, 255));
    }
    NuiSetBind (oPC, nToken, "target_label", JsonString (sTarget));
    NuiSetBind (oPC, nToken, "target_color", NuiColor (255, 255, 255));
    NuiSetBind (oPC, nToken, "btn_chat_event", JsonBool (TRUE));
    NuiSetBind (oPC, nToken, "chat_tooltip", JsonString (
      "  Normal Chat"));
    NuiSetBind (oPC, nToken, "btn_partychat_event", JsonBool (TRUE));
    NuiSetBind (oPC, nToken, "partychat_tooltip", JsonString (
      "  Party Chat"));
    NuiSetBind (oPC, nToken, "btn_shout_event", JsonBool (TRUE));
    NuiSetBind (oPC, nToken, "shout_tooltip", JsonString (
      "  Shout"));
    NuiSetBind (oPC, nToken, "btn_dmchat_event", JsonBool (TRUE));
    NuiSetBind (oPC, nToken, "dmchat_tooltip", JsonString (
      "  DM Chat"));
    NuiSetBind (oPC, nToken, "btn_send_event", JsonBool (FALSE));
    //NuiSetBind (oPC, nToken, "chat_value", JsonString (""));
}

void PopUpPlayerStatsGUIPanel (object oPC)
{
    // Set window to not save until it has been created.
    SetLocalInt (oPC, "0_No_Win_Save", TRUE);
    DelayCommand (0.5f, DeleteLocalInt (oPC, "0_No_Win_Save"));
    // Row 1 (label)************************************************************45
    json jRow = JsonArrayInsert (JsonArray (), NuiHeight (NuiSpacer(), 10.0));
    jRow = CreateLabel (jRow, "", "player", 250.0f, 10.0f);
    jRow = JsonArrayInsert (jRow, NuiHeight (NuiSpacer(), 10.0));
    // Add the row to the column.
    json jCol = JsonArrayInsert (JsonArray (), NuiRow (jRow));
    // Row 2 (Text)************************************************************* 63
    jRow = CreateTextBox (JsonArray (), "player_text", 250.0f, 200.0f);
    // Add the row to the column.
    jCol = JsonArrayInsert (jCol, NuiRow (jRow));
    // Row 3 (label)************************************************************ 271
    jRow = JsonArrayInsert (JsonArray (), NuiHeight (NuiSpacer(), 10.0));
    jRow = CreateLabel (jRow, "", "char", 250.0f, 10.0f);
    jRow = JsonArrayInsert (jRow, NuiHeight (NuiSpacer(), 10.0));
    // Add the row to the column.
    jCol = JsonArrayInsert (jCol, NuiRow (jRow));
    // Row 4 (text)************************************************************* 289
    jRow = CreateTextBox (JsonArray (), "char_text", 250.0f, 200.0f);
    // Add the row to the column.
    jCol = JsonArrayInsert (jCol, NuiRow (jRow));
    // Get the window location from the database.
    json jGeometry = GetWindowGeometryFromDB(oPC, "plstatswin");
    float fX = JsonGetFloat(JsonObjectGet(jGeometry, "x"));
    float fY = JsonGetFloat(JsonObjectGet(jGeometry, "y"));
    // Set the Layout of the window.
    json jLayout = NuiCol (jCol);
    int nToken = SetWindow (oPC, jLayout, "plstatswin", "Player Statistics",
                            fX, fY, 274.0f, 501.0f, FALSE, FALSE, TRUE, FALSE, TRUE);
    // Set all binds, events, and watches.
    NuiSetBind (oPC, nToken, "player_label", JsonString (GetPCPlayerName (oPC)));
    NuiSetBind (oPC, nToken, "char_label", JsonString (GetName (oPC)));
    string sText;
    sText = "Number of Characters: " + IntToString (GetServerDatabaseInt (oPC, PLAYER_TABLE, "characters"));
    sText += "\nHighest Level Character: " + IntToString (GetServerDatabaseInt (oPC, PLAYER_TABLE, "highestlevel"));
    sText += "\nNumber of logins: " + IntToString (GetServerDatabaseInt (oPC, PLAYER_TABLE, "logins"));
    sText += "\nNumber of times resting: " + IntToString (GetServerDatabaseInt (oPC, PLAYER_TABLE, "rests"));
    sText += "\nNumber of times bleeding: " + IntToString (GetServerDatabaseInt (oPC, PLAYER_TABLE, "bleeds"));
    sText += "\nNumber of respawns: " + IntToString (GetServerDatabaseInt (oPC, PLAYER_TABLE, "respawns"));
    sText += "\nNumber of deaths: " + IntToString (GetServerDatabaseInt (oPC, PLAYER_TABLE, "deaths"));
    int nValue = GetServerDatabaseInt (oPC, PLAYER_TABLE, "kills") + GetLocalInt (oPC, "0_Kills");
    sText += "\nNumber of Kills: " + IntToString (nValue);
    NuiSetBind (oPC, nToken, "player_text", JsonString (sText));
    sText = "Number of times resting: " + IntToString (GetObjectDatabaseInt (oPC, CHARACTER_TABLE, "rests"));
    sText += "\nNumber of times bleeding: " + IntToString (GetObjectDatabaseInt (oPC, CHARACTER_TABLE, "bleeds"));
    sText += "\nNumber of respawns: " + IntToString (GetObjectDatabaseInt (oPC, CHARACTER_TABLE, "respawns"));
    sText += "\nNumber of deaths: " + IntToString (GetObjectDatabaseInt (oPC, CHARACTER_TABLE, "deaths"));
    nValue = GetObjectDatabaseInt (oPC, CHARACTER_TABLE, "kills") + GetLocalInt (oPC, "0_Kills");
    sText += "\nNumber of kills: " + IntToString (nValue);
    nValue = GetObjectDatabaseInt (oPC, CHARACTER_TABLE, "sidequests");
    sText += "\nCompleted side quests: " + IntToString (nValue);
    nValue = GetObjectDatabaseInt (oPC, CHARACTER_TABLE, "mainquests");
    sText += "\nCompleted main quests: " + IntToString (nValue);
    NuiSetBind (oPC, nToken, "char_text", JsonString (sText));
    NuiSetBindWatch (oPC, nToken, "window_geometry", TRUE);
}

void PopUpCharacterDescriptionGUIPanel (object oPC)
{
    // Set window to not save until it has been created.
    SetLocalInt (oPC, "0_No_Win_Save", TRUE);
    DelayCommand (0.5f, DeleteLocalInt (oPC, "0_No_Win_Save"));
    // Row 1 (Text edit box)**************************************************** 45
    json jRow = JsonArrayInsert (JsonArray (), NuiSpacer());
    jRow = CreateTextEditBox (jRow, "port_placeholder", "port_name", 15, FALSE, 140.0, 20.0, "port_tooltip");
    jRow = JsonArrayInsert (jRow, NuiSpacer());
    // Add the row to the column.
    json jCol = JsonArrayInsert (JsonArray (), NuiRow (jRow));
    // Row 2 (label)************************************************************ 73
    jRow = JsonArrayInsert (JsonArray (), NuiSpacer());
    jRow = CreateLabel (jRow, "", "port_id", 140.0, 10.0f);
    jRow = JsonArrayInsert (jRow, NuiSpacer());
    // Add the row to the column.
    jCol = JsonArrayInsert (jCol, NuiRow (jRow));
    // Row 3 (portrait)********************************************************* 91
    jRow = JsonArrayInsert (JsonArray (), NuiSpacer());
    jRow = CreateImage (jRow, "", "port_resref", NUI_ASPECT_EXACTSCALED, NUI_HALIGN_CENTER, NUI_VALIGN_TOP, 140.0f, 160.0f);
    jRow = JsonArrayInsert (jRow, NuiSpacer());
    // Add the row to the column.
    jCol = JsonArrayInsert (jCol, NuiRow (jRow));
    // Row 4 (buttons)********************************************************** 259
    jRow = JsonArrayInsert (JsonArray (), NuiSpacer());
    jRow = CreateButton (jRow, "<", "btn_portrait_prev", 42.0f, 16.0f);
    jRow = CreateButton (jRow, "Set", "btn_portrait_ok", 44.0f, 16.0f);
    jRow = CreateButton (jRow, ">", "btn_portrait_next", 42.0f, 16.0f);
    jRow = JsonArrayInsert (jRow, NuiSpacer());
    // Add row to the column.
    jCol = JsonArrayInsert (jCol, NuiRow (jRow));
    // Row 5 (label)************************************************************ 283
    jRow = CreateLabel (JsonArray (), "", "description_title", 300.0f, 10.0f);
    // Add row to the column.
    jCol = JsonArrayInsert (jCol, NuiRow (jRow));
    // Row 6 (text edit box)**************************************************** 301
    jRow = CreateTextEditBox (JsonArray (), "desc_placeholder", "desc_value", 1000, TRUE, 300.0, 200.0, "desc_tooltip");
    // Add the row to the column.
    jCol = JsonArrayInsert (jCol, NuiRow (jRow));
    // Row 7 (button)*********************************************************** 509
    jRow = JsonArrayInsert (JsonArray (), NuiSpacer());
    jRow = CreateButton (jRow, "Save Description", "btn_desc_save", 150.0f, 20.0f);
    jRow = JsonArrayInsert (jRow, NuiSpacer());
    // Add row to the column.
    jCol = JsonArrayInsert (jCol, NuiRow (jRow));
    // Get the window location from the database.
    json jGeometry = GetWindowGeometryFromDB(oPC, "pcdescwin");
    float fX = JsonGetFloat(JsonObjectGet(jGeometry, "x"));
    float fY = JsonGetFloat(JsonObjectGet(jGeometry, "y"));
    // Set the Layout of the window.
    json jLayout = NuiCol (jCol);
    int nToken = SetWindow (oPC, jLayout, "pcdescwin", GetName (oPC) + "'s Options",
                            fX, fY, 324.0, 541.0, FALSE, FALSE, TRUE, FALSE, TRUE);
    // Set all binds, events, and watches.
    int nID = GetPortraitId (oPC);
    NuiSetUserData (oPC, nToken, JsonInt (nID));
    string sResRef = GetPortraitResRef (oPC);
    string sID;
    if (nID == 65535) sID = "Custom Portrait";
    else sID = IntToString (nID);
    NuiSetBindWatch (oPC, nToken, "port_name", TRUE);
    NuiSetBind (oPC, nToken, "port_name", JsonString (sResRef));
    NuiSetBind (oPC, nToken, "port_id", JsonString (sID));
    NuiSetBind (oPC, nToken, "port_resref_event", JsonBool (TRUE));
    NuiSetBind (oPC, nToken, "port_resref_image", JsonString (sResRef + "l"));
    NuiSetBind (oPC, nToken, "port_tooltip", JsonString ("You may also type the portrait file name."));
    // Set buttons active.
    NuiSetBind (oPC, nToken, "btn_portrait_prev_event", JsonBool (TRUE));
    NuiSetBind (oPC, nToken, "btn_portrait_next_event", JsonBool (TRUE));
    NuiSetBind (oPC, nToken, "btn_desc_save_event", JsonBool (TRUE));
    NuiSetBind (oPC, nToken, "btn_portrait_ok_event", JsonBool (TRUE));
    NuiSetBind (oPC, nToken, "desc_tooltip", JsonString ("Use enter to keep text within the box and you can use color codes!"));
    NuiSetBind (oPC, nToken, "description_title_label", JsonString (GetName (oPC) + "'s Description"));
    string sDescription = GetDescription (oPC);
    NuiSetBind (oPC, nToken, "desc_value", JsonString (sDescription));
    NuiSetBindWatch (oPC, nToken, "window_geometry", TRUE);
}

void PopUpCharacterMagicGUIPanel (object oPC)
{
    // Set window to not save until it has been created.
    SetLocalInt (oPC, "0_No_Win_Save", TRUE);
    DelayCommand (0.5f, DeleteLocalInt (oPC, "0_No_Win_Save"));
    int i;
    struct stComboBox stCBox = GetSummons (oPC);
    // Row 1 (button)*********************************************************** 45
    json jRow = JsonArrayInsert (JsonArray (), NuiSpacer ());
    jRow = CreateButton (jRow, "Fast Buffing", "btn_fast_buff", 125.0f, 25.0f);
    jRow = JsonArrayInsert (jRow, NuiSpacer ());
    jRow = CreateButton (jRow, "Teleport", "btn_teleport", 125.0f, 25.0f);
    jRow = JsonArrayInsert (jRow, NuiSpacer ());
    jRow = CreateButtonSelect (jRow, "Use Enhanced Components", "btn_enh_comp", 200.0f, 25.0f);
    jRow = JsonArrayInsert (jRow, NuiSpacer ());
    // Add row to the column.
    json jCol = JsonArrayInsert (JsonArray (), NuiRow (jRow));
    // Row 1 (label)************************************************************ 78
    jRow = CreateLabel (JsonArray (), "Summon Monster I", "sm_title_1", 225.0, 10.0f);
    jRow = CreateLabel (jRow, "Summon Monster II", "sm_title_2", 225.0, 10.0f);
    // Add row to the column.
    jCol = JsonArrayInsert (jCol, NuiRow (jRow));
    // Row 2 (combo boxes)****************************************************** 96
    stCBox = CreateSummonCombo (oPC, stCBox, "Summon Monster I", "sm_combo_1", 1);
    stCBox = CreateSummonCombo (oPC, stCBox, "Summon Monster II", "sm_combo_2", 2);
    jCol = JsonArrayInsert (jCol, NuiHeight (NuiRow (stCBox.jRow), 25.0f));
    // Add a space between each row.
    jCol = JsonArrayInsert (jCol, NuiHeight (NuiSpacer (), 10.0f));
    // Row 3 label)************************************************************* 129
    jRow = CreateLabel (JsonArray (), "Summon Monster III", "sm_title_3", 225.0, 10.0f);
    jRow = CreateLabel (jRow, "Summon Monster IV", "sm_title_4", 225.0, 10.0f);
    // Add row to the column.
    jCol = JsonArrayInsert (jCol, NuiRow (jRow));
    // Row 4 (combo boxes)****************************************************** 147
    stCBox.jRow = JsonArray ();
    stCBox = CreateSummonCombo (oPC, stCBox, "Summon Monster III", "sm_combo_3", 3);
    stCBox = CreateSummonCombo (oPC, stCBox, "Summon Monster IV", "sm_combo_4", 4);
    // Add row to the column.
    jCol = JsonArrayInsert (jCol, NuiHeight (NuiRow (stCBox.jRow), 25.0f));
    // Add a space between each row.
    jCol = JsonArrayInsert (jCol, NuiHeight (NuiSpacer (), 10.0f));
    // Row 5 (label)************************************************************ 180
    jRow = CreateLabel (JsonArray (), "Summon Monster V", "sm_title_5", 225.0, 10.0f);
    jRow = CreateLabel (jRow, "Summon Monster VI", "sm_title_6", 225., 10.0f);
    // Add row to the column.
    jCol = JsonArrayInsert (jCol, NuiRow (jRow));
    // Row 6 (combo boxes)****************************************************** 198
    stCBox.jRow = JsonArray ();
    stCBox = CreateSummonCombo (oPC, stCBox, "Summon Monster V", "sm_combo_5", 5);
    stCBox = CreateSummonCombo (oPC, stCBox, "Summon Monster VI", "sm_combo_6", 6);
    // Add row to the column.
    jCol = JsonArrayInsert (jCol, NuiHeight (NuiRow (stCBox.jRow), 25.0f));
    // Add a space between each row.
    jCol = JsonArrayInsert (jCol, NuiHeight (NuiSpacer (), 10.0f));
    // Row 7 (label)************************************************************ 231
    jRow = CreateLabel (JsonArray (), "Summon Monster VII", "sm_title_7", 225.0, 10.0f);
    jRow = CreateLabel (jRow, "Summon Monster VIII", "sm_title_8", 225.0, 10.0f);
    // Add row to the column.
    jCol = JsonArrayInsert (jCol, NuiRow (jRow));
    // Row 8 (combo boxes)****************************************************** 249
    stCBox.jRow = JsonArray ();
    stCBox = CreateSummonCombo (oPC, stCBox, "Summon Monster VII", "sm_combo_7", 7);
    stCBox = CreateSummonCombo (oPC, stCBox, "Summon Monster VIII", "sm_combo_8", 8);
    // Add row to the column.
    jCol = JsonArrayInsert (jCol, NuiHeight (NuiRow (stCBox.jRow), 25.0f));
    // Add a space between each row.
    jCol = JsonArrayInsert (jCol, NuiHeight (NuiSpacer (), 10.0f));
    // Row 9 (label)************************************************************ 282
    jRow = CreateLabel (JsonArray (), "Summon Monster IX", "sm_title_9", 225.0, 10.0f);
    jRow = CreateLabel (jRow, "Create Undead", "sm_title_10", 225.0, 10.0f);
    // Add row to the column.
    jCol = JsonArrayInsert (jCol, NuiRow (jRow));
    // Row 10 (combo boxes)***************************************************** 300
    stCBox.jRow = JsonArray ();
    stCBox = CreateSummonCombo (oPC, stCBox, "Summon Monster IX", "sm_combo_9", 9);
    stCBox = CreateSummonCombo (oPC, stCBox, "Create Undead", "sm_combo_10", 10);
    // Add row to the column.
    jCol = JsonArrayInsert (jCol, NuiHeight (NuiRow (stCBox.jRow), 25.0f));
    // Add a space between each row.
    jCol = JsonArrayInsert (jCol, NuiHeight (NuiSpacer (), 10.0f));
    // Row 11 (label)*********************************************************** 333
    jRow = CreateLabel (JsonArray (), "Create Greater Undead", "sm_title_11", 225.0, 10.0f);
    jRow = CreateLabel (jRow, "Lesser Planar Portal", "sm_title_12", 225.0, 10.0f);
    // Add row to the column.
    jCol = JsonArrayInsert (jCol, NuiRow (jRow));
    // Row 12 (combo boxes)***************************************************** 351
    stCBox.jRow = JsonArray ();
    stCBox = CreateSummonCombo (oPC, stCBox, "Create Greater Undead", "sm_combo_11", 11);
    stCBox = CreateSummonCombo (oPC, stCBox, "Lesser Planar Portal", "sm_combo_12", 12);
    // Add row to the column.
    jCol = JsonArrayInsert (jCol, NuiHeight (NuiRow (stCBox.jRow), 25.0f));
    // Add a space between each row.
    jCol = JsonArrayInsert (jCol, NuiHeight (NuiSpacer (), 10.0f));
    // Row 13 (label)*********************************************************** 384
    jRow = CreateLabel (JsonArray (), "Planar Portal", "sm_title_13", 225.0, 10.0f);
    jRow = CreateLabel (jRow, "Greater Planar Portal", "sm_title_14", 225.0, 10.0f);
    // Add row to the column.
    jCol = JsonArrayInsert (jCol, NuiRow (jRow));
    // Row 14 (combo boxes)***************************************************** 402
    stCBox.jRow = JsonArray ();
    stCBox = CreateSummonCombo (oPC, stCBox, "Planar Portal", "sm_combo_13", 13);
    stCBox = CreateSummonCombo (oPC, stCBox, "Greater Planar Portal", "sm_combo_14", 14);
    // Add row to the column.
    jCol = JsonArrayInsert (jCol, NuiHeight (NuiRow (stCBox.jRow), 25.0f));
    // Add a space between each row.
    jCol = JsonArrayInsert (jCol, NuiHeight (NuiSpacer (), 10.0f));
    // Row 15 (label)*********************************************************** 435
    jRow = CreateLabel (JsonArray (), "Gate", "sm_title_15", 225.0, 10.0f);
    jRow = CreateLabel (jRow, "Minor Creation", "sm_title_16", 225.0, 10.0f);
    // Add row to the column.
    jCol = JsonArrayInsert (jCol, NuiRow (jRow));
    // Row 16 (combo boxes)***************************************************** 453
    stCBox.jRow = JsonArray ();
    stCBox = CreateSummonCombo (oPC, stCBox, "Gate", "sm_combo_15", 15);
    stCBox = CreateSummonCombo (oPC, stCBox, "Minor Creation", "sm_combo_16", 16);
    // Add row to the column.
    jCol = JsonArrayInsert (jCol, NuiHeight (NuiRow (stCBox.jRow), 25.0f));
    // Add a space between each row.
    //jCol = JsonArrayInsert (jCol, NuiHeight (NuiSpacer (), 10.0f));
    // Row 17 (label)***********************************************************
    /*jRow = JsonArray ();
    jRow = JsonArrayInsert (jRow, CreateLabel ("Polymorph Self", "po_title_2", 225.0, 10.0f));
    jRow = JsonArrayInsert (jRow, CreateLabel ("Spider Form", "po_title_1", 225.0, 10.0f));
    // Add row to the column.
    jCol = JsonArrayInsert (jCol, NuiRow (jRow));
    // Row 18 (combo boxes)*****************************************************
    stCBox.jRow = JsonArray ();
    jRow = CreatePolymorphCombo (oPC, jRow, "Polymorph Self", "po_combo_1", 1);
    jRow = CreatePolymorphCombo (oPC, jRow, "Spider Form", "po_combo_2", 2);
    // Add row to the column.
    jCol = JsonArrayInsert (jCol, NuiRow (jRow));
    */
    // Get the window location from the database.
    json jGeometry = GetWindowGeometryFromDB(oPC, "pcmagicwin");
    float fX = JsonGetFloat(JsonObjectGet(jGeometry, "x"));
    float fY = JsonGetFloat(JsonObjectGet(jGeometry, "y"));
    // Set the Layout of the window.
    json jLayout = NuiCol (jCol);
    int nToken = SetWindow (oPC, jLayout, "pcmagicwin", "Players Magic Options",
                            fX, fY, 478.0f, 490.0f, FALSE, FALSE, TRUE, FALSE, TRUE);
    // Set all binds, events, and watches.
    for (i = 1;i < 17;i ++)
    {
        NuiSetBind (oPC, nToken, "sm_combo_" + IntToString (i) + "_selected", JsonArrayGet (stCBox.jIndex, i - 1));
        NuiSetBind (oPC, nToken, "sm_combo_" + IntToString (i) + "_event", JsonBool (TRUE));
        NuiSetBindWatch (oPC, nToken, "sm_combo_" + IntToString (i) + "_selected", TRUE);
    }
    NuiSetBind (oPC, nToken, "btn_fast_buff_event", JsonBool (TRUE));
    NuiSetBind (oPC, nToken, "btn_teleport_event", JsonBool (TRUE));
    int bEnhComp = GetLocalInt (oPC, "0_Use_Enhancing_Component");
    NuiSetBind (oPC, nToken, "btn_enh_comp", JsonBool (bEnhComp));
    NuiSetBind (oPC, nToken, "btn_enh_comp_event", JsonBool (TRUE));
    NuiSetBindWatch (oPC, nToken, "window_geometry", TRUE);
    // Save the ResRef's to the window.
    NuiSetUserData (oPC, nToken, stCBox.jWinArray);
}

void PopUpPlayerTeleportGUIPanel (object oPC)
{
    // Set window to not save until it has been created.
    SetLocalInt (oPC, "0_No_Win_Save", TRUE);
    DelayCommand (0.5f, DeleteLocalInt (oPC, "0_No_Win_Save"));
    // Row 1 (titles)*********************************************************** 45
    json jRow = JsonArrayInsert (JsonArray (), NuiSpacer ());
    jRow = CreateLabel (jRow, "X Pos", "x_pos_title", 50.0, 10.0);
    jRow = CreateLabel (jRow, "Y Pos", "y_pos_title", 50.0, 10.0);
    jRow = CreateLabel (jRow, "Z Pos", "z_pos_title", 50.0, 10.0);
    jRow = CreateLabel (jRow, "Area Tag", "area_tag_title", 150.0, 10.0);
    jRow = JsonArrayInsert (jRow, NuiSpacer ());
    // Add the row to the column and set column height.
    json jCol = JsonArrayInsert (JsonArray (), NuiRow (jRow));
    // Row 2 (text boxes)******************************************************* 63
    jRow = JsonArrayInsert (JsonArray (), NuiSpacer ());
    jRow = CreateTextEditBox (jRow, "place_hold", "x_pos", 3, FALSE, 50.0f, 20.0f);
    jRow = CreateTextEditBox (jRow, "place_hold", "y_pos", 3, FALSE, 50.0f, 20.0f);
    jRow = CreateTextEditBox (jRow, "place_hold", "z_pos", 3, FALSE, 50.0f, 20.0f);
    jRow = CreateTextEditBox (jRow, "place_hold", "area_tag", 16, FALSE, 150.0f, 20.0f);
    jRow = JsonArrayInsert (jRow, NuiSpacer ());
    // Add row to the column.
    jCol = JsonArrayInsert (jCol, NuiRow (jRow));
    // Row 3 (buttons)********************************************************** 91
    jRow = JsonArrayInsert (JsonArray (), NuiSpacer ());
    jRow = CreateButton (jRow, "Save Location", "btn_save_location", 100.0f, 25.0f);
    jRow = JsonArrayInsert (jRow, NuiSpacer ());
    jRow = CreateButton (jRow, "Clear Location", "btn_clear_location", 110.0f, 25.0f);
    jRow = JsonArrayInsert (jRow, NuiSpacer ());
    jRow = CreateButton (jRow, "Teleport", "btn_cast_teleport", 90.0f, 25.0f);
    jRow = JsonArrayInsert (jRow, NuiSpacer ());
    // Add row to the column.
    jCol = JsonArrayInsert (jCol, NuiRow (jRow));
    // Row 4 (buttons)********************************************************** 124
    // Add row to the column.
    jRow = CreateButtonSelect (JsonArray (), "", "btn_loc_1", 150.0f, 25.0f);
    jRow = CreateButtonSelect (jRow, "", "btn_loc_2", 150.0f, 25.0f);
    // Add row to the column.
    jCol = JsonArrayInsert (jCol, NuiRow (jRow));
    // Row 5 (buttons)********************************************************** 157
    // Add row to the column.
    jRow = CreateButtonSelect (JsonArray (), "", "btn_loc_3", 150.0f, 25.0f);
    jRow = CreateButtonSelect (jRow, "", "btn_loc_4", 150.0f, 25.0f);
    // Add row to the column.
    jCol = JsonArrayInsert (jCol, NuiRow (jRow));
    // Row 6 (buttons)********************************************************** 190
    // Add row to the column.
    jRow = CreateButtonSelect (JsonArray (), "", "btn_loc_5", 150.0f, 25.0f);
    jRow = CreateButtonSelect (jRow, "", "btn_loc_6", 150.0f, 25.0f);
    // Add row to the column.
    jCol = JsonArrayInsert (jCol, NuiRow (jRow));
    // Row 7 (buttons)********************************************************** 223
    // Add row to the column.
    jRow = CreateButtonSelect (JsonArray (), "", "btn_loc_7", 150.0f, 25.0f);
    jRow = CreateButtonSelect (jRow, "", "btn_loc_8", 150.0f, 25.0f);
    // Add row to the column.
    jCol = JsonArrayInsert (jCol, NuiRow (jRow));
    // Row 8 (buttons)********************************************************** 256
    // Add row to the column.
    jRow = CreateButtonSelect (JsonArray (), "", "btn_loc_9", 150.0f, 25.0f);
    jRow = CreateButtonSelect (jRow, "", "btn_loc_10", 150.0f, 25.0f);
    // Add row to the column.
    jCol = JsonArrayInsert (jCol, NuiRow (jRow));
    // Get the window location from the database.
    json jGeometry = GetWindowGeometryFromDB(oPC, "plteleportwin");
    float fX = JsonGetFloat(JsonObjectGet(jGeometry, "x"));
    float fY = JsonGetFloat(JsonObjectGet(jGeometry, "y"));
    // Set the Layout of the window.
    json jLayout = NuiCol (jCol);
    int nToken = SetWindow (oPC, jLayout, "plteleportwin", "Magic - Teleport",
                            fX, fY, 340.0f, 293.0f, FALSE, FALSE, TRUE, FALSE, TRUE);
    // Set all binds, events, and watches.
    NuiSetBind (oPC, nToken, "btn_save_location_event", JsonBool (TRUE));
    NuiSetBind (oPC, nToken, "btn_clear_location_event", JsonBool (TRUE));
    int bCast;
    if (GetLocalInt (oPC, "0_Teleport_Spell") > 0) bCast = TRUE;
    NuiSetBind (oPC, nToken, "btn_cast_teleport_event", JsonBool (bCast));
    NuiSetBindWatch (oPC, nToken, "x_pos", TRUE);
    NuiSetBindWatch (oPC, nToken, "y_pos", TRUE);
    NuiSetBindWatch (oPC, nToken, "z_pos", TRUE);
    NuiSetBindWatch (oPC, nToken, "area_tag", TRUE);
    // Fill in button text for teleporting.
    string sAreaName, sSlot;
    json jTArray = GetObjectDatabaseJson (oPC, CHARACTER_TABLE, "teleport");
    int nSelected = JsonGetInt (JsonArrayGet (jTArray, 21));
    int nSlot = 1;
    while (nSlot < 11)
    {
        sAreaName = JsonGetString (JsonArrayGet (jTArray, nSlot + 10));
        if (sAreaName == "") sAreaName = "None";
        sSlot = IntToString (nSlot);
        NuiSetBind (oPC, nToken, "btn_loc_" + sSlot + "_label", JsonString (sAreaName));
        if (nSelected == nSlot) NuiSetBind (oPC, nToken, "btn_loc_" + sSlot, JsonBool (TRUE));
        else NuiSetBind (oPC, nToken, "btn_loc_" + sSlot, JsonBool (FALSE));
        NuiSetBind (oPC, nToken, "btn_loc_" + sSlot + "_event", JsonBool (TRUE));
        nSlot ++;
    }
}

void PopUpCharacterLanguageGUIPanel (object oPC)
{
    // Set window to not save until it has been created.
    SetLocalInt (oPC, "0_No_Win_Save", TRUE);
    DelayCommand (0.5f, DeleteLocalInt (oPC, "0_No_Win_Save"));
    struct stComboBox stCBox;
    // Row 1 (label)************************************************************ 45
    json jRow = CreateLabel (JsonArray (), "Language Using", "lang_use_title", 175.0, 10.0f);
    jRow = CreateLabel (jRow, "Unknown Languages", "lang_take_title", 175.0, 10.0f);
    // Add row to the column.
    json jCol = JsonArrayInsert (JsonArray (), NuiRow (jRow));
    // Row 2 (combo box)******************************************************** 63
    stCBox.jIndex = JsonArray ();
    stCBox.jWinArray = JsonArray ();
    stCBox.jRow = JsonArray ();
    stCBox = CreateUseLangCombo (oPC, stCBox, "use_combo");
    stCBox = CreateTakeLangCombo (oPC, stCBox, "take_combo");
    // Add row to the column.
    jCol = JsonArrayInsert (jCol, NuiRow (stCBox.jRow));
    // Row 3 (buttons)********************************************************** 96
    jRow = CreateButton (JsonArray (), "Throw voice Target", "btn_throw_voice", 175.0f, 20.0f);
    jRow = CreateButton (jRow, "Take Language", "btn_take_lang", 175.0f, 20.0f);
    // Add row to the column.
    jCol = JsonArrayInsert (jCol, NuiRow (jRow));
    // Row 4 (target)*********************************************************** 124
    jRow = JsonArrayInsert (JsonArray (), NuiSpacer ());
    jRow = CreateLabel (jRow, "Target:", "pc_target_title", 65.0, 10.0);
    jRow = CreateLabel (jRow, "", "pc_target_value", 135.0, 10.0, -1.0, NUI_HALIGN_LEFT);
    jRow = JsonArrayInsert (jRow, NuiSpacer ());
    // Add row to the column.
    jCol = JsonArrayInsert (jCol, NuiRow (jRow));
    // Get the window location from the database.
    json jGeometry = GetWindowGeometryFromDB(oPC, "pclangwin");
    float fX = JsonGetFloat(JsonObjectGet(jGeometry, "x"));
    float fY = JsonGetFloat(JsonObjectGet(jGeometry, "y"));
    // Set the Layout of the window.
    json jLayout = NuiCol (jCol);
    int nToken = SetWindow (oPC, jLayout, "pclangwin", "Players Language Options",
                            fX, fY, 378.0, 146.0, FALSE, FALSE, TRUE, FALSE, TRUE);
    // Set all binds, events, and watches.
    int bTakeLang;
    int nLanguagesToLearn = GetLanguagesToLearn (oPC) - GetLanguagesKnown (oPC);
    string sLanguagesToLearn = IntToString (nLanguagesToLearn);
    NuiSetBind (oPC, nToken, "lang_to_learn_title", JsonString ("Languages to learn: " + sLanguagesToLearn));
    NuiSetBind (oPC, nToken, "use_combo_selected", JsonArrayGet (stCBox.jIndex, 0));
    NuiSetBind (oPC, nToken, "use_combo_event", JsonBool (TRUE));
    NuiSetBindWatch (oPC, nToken, "use_combo_selected", TRUE);
    NuiSetBind (oPC, nToken, "take_combo_event", JsonBool (TRUE));
    if (nLanguagesToLearn > 0) bTakeLang = TRUE;
    NuiSetBind (oPC, nToken, "btn_take_lang", JsonBool (bTakeLang));
    NuiSetBind (oPC, nToken, "btn_take_lang_event", JsonBool (bTakeLang));
    NuiSetBind (oPC, nToken, "btn_throw_voice_event", JsonBool (TRUE));
    string sValue = GetName (GetLocalObject (oPC, "0_PLAYER_Target"));
    NuiSetBind (oPC, nToken, "pc_target_value_label", JsonString (sValue));
    NuiSetBindWatch (oPC, nToken, "window_geometry", TRUE);
    // Save the ResRef's to the window.
    NuiSetUserData (oPC, nToken, stCBox.jWinArray);
}

void PopUpBugReportGUIPanel (object oPC)
{
    // Set window to not save until it has been created.
    SetLocalInt (oPC, "0_No_Win_Save", TRUE);
    DelayCommand (0.5f, DeleteLocalInt (oPC, "0_No_Win_Save"));
    // Row 1 (label)************************************************************ 45
    json jRow = JsonArrayInsert (JsonArray (), NuiHeight (NuiSpacer(), 10.0));
    jRow = CreateLabel (jRow, "Bug Report", "bug_report_title", 300.0, 10.0f);
    jRow = JsonArrayInsert (jRow, NuiHeight (NuiSpacer(), 10.0));
    // Add row to the column.
    json jCol = JsonArrayInsert (JsonArray (), NuiRow (jRow));
    // Row 2 (text edit box)**************************************************** 63
    jRow = JsonArrayInsert (JsonArray (), NuiSpacer());
    jRow = CreateTextEditBox (jRow, "bug_Placeholder", "bug_value", 1000, TRUE, 300.0, 200.0, "bug_tooltip");
    jRow = JsonArrayInsert (jRow, NuiSpacer());
    // Add the row to the column.
    jCol = JsonArrayInsert (jCol, NuiRow (jRow));
    // Row 3 (button)*********************************************************** 271
    jRow = JsonArrayInsert (JsonArray (), NuiSpacer ());
    jRow = CreateButton (jRow, "Save Report", "btn_bug_save", 150.0f, 20.0f);
    jRow = JsonArrayInsert (jRow, NuiSpacer ());
    // Add row to the column.
    jCol = JsonArrayInsert (jCol, NuiRow (jRow));
    // Get the window location from the database.
    json jGeometry = GetWindowGeometryFromDB(oPC, "plbugwin");
    float fX = JsonGetFloat(JsonObjectGet(jGeometry, "x"));
    float fY = JsonGetFloat(JsonObjectGet(jGeometry, "y"));
    // Set the Layout of the window.
    json jLayout = NuiCol (jCol);
    int nToken = SetWindow (oPC, jLayout, "plbugwin", "Bug Reports",
                            fX, fY, 324.0, 303.0, FALSE, FALSE, TRUE, FALSE, TRUE);
    // Set all binds, events, and watches.
    // Watch to see if they have typed in the text box, this enables the save button.
    NuiSetBindWatch (oPC, nToken, "bug_value", TRUE);
    NuiSetBind (oPC, nToken, "bug_tooltip", JsonString ("Enter your bug information here!"));
    NuiSetBind (oPC, nToken, "bug_value", JsonString (""));
    NuiSetBindWatch (oPC, nToken, "window_geometry", TRUE);
}

void PopUpDiceGUIPanel (object oPC, object oTarget = OBJECT_INVALID)
{
    if (oTarget == OBJECT_INVALID) oTarget = oPC;
    // Set window to not save until it has been created.
    SetLocalInt (oPC, "0_No_Win_Save", TRUE);
    DelayCommand (0.5f, DeleteLocalInt (oPC, "0_No_Win_Save"));
    // Row 1 (label)************************************************************ 45
    json jRow = CreateLabel (JsonArray (), "Broadcast", "broadcast_title", 100.0, 10.0f);
    jRow = CreateLabel (jRow, "Number", "num_title", 75.0, 10.0f);
    jRow = CreateLabel (jRow, "Type of Roll", "type_title", 200.0, 10.0f);
    jRow = CreateLabel (jRow, "Modifier", "bonus_title", 75.0, 10.0f);
    jRow = CreateLabel (jRow, "Roll to be Made", "roll_title", 200.0, 10.0f);
    // Add row to the column.
    json jCol = JsonArrayInsert (JsonArray (), NuiRow (jRow));
    // Row 2 (combo box)******************************************************** 63
    jRow = CreateBroadcastCombo (oPC, JsonArray (), "broadcast_combo");
    jRow = CreateNumOfDiceCombo (jRow, "num_dice_combo");
    jRow = CreateRollTypeCombo (oTarget, jRow, "type_roll_combo");
    jRow = CreateDieBonusCombo (jRow, "die_bonus_combo");
    jRow = CreateTextEditBox (jRow, "roll_place", "roll_text", 30, FALSE, 200.0f, 25.0f);
    // Add row to the column.
    jCol = JsonArrayInsert (jCol, NuiRow (jRow));
    // Row 3 (button)*********************************************************** 96
    jRow = JsonArrayInsert (JsonArray (), NuiSpacer ());
    jRow = CreateButton (jRow, "Roll", "btn_roll", 200.0f, 20.0f);
    jRow = JsonArrayInsert (jRow, NuiSpacer ());
    // Add row to the column.
    jCol = JsonArrayInsert (jCol, NuiRow (jRow));
    // Get the window location from the database.
    json jGeometry = GetWindowGeometryFromDB(oPC, "pldicewin");
    float fX = JsonGetFloat(JsonObjectGet(jGeometry, "x"));
    float fY = JsonGetFloat(JsonObjectGet(jGeometry, "y"));
    // Set the Layout of the window.
    json jLayout = NuiCol (jCol);
    int nToken = SetWindow (oPC, jLayout, "pldicewin", "Dice Options",
                        fX, fY, 690.0, 128.0, FALSE, FALSE, TRUE, FALSE, TRUE);
    // Set all binds, events, and watches.
    NuiSetBind (oPC, nToken, "num_dice_combo_selected", JsonInt (GetLocalInt (oPC, "0_NumDice")));
    NuiSetBind (oPC, nToken, "num_dice_combo_event", JsonBool (TRUE));
    NuiSetBindWatch (oPC, nToken, "num_dice_combo_selected", TRUE);
    NuiSetBind (oPC, nToken, "type_roll_combo_selected", JsonInt (GetLocalInt (oPC, "0_TypeRoll")));
    NuiSetBind (oPC, nToken, "type_roll_combo_event", JsonBool (TRUE));
    NuiSetBindWatch (oPC, nToken, "type_roll_combo_selected", TRUE);
    NuiSetBind (oPC, nToken, "die_bonus_combo_selected", JsonInt (GetLocalInt (oPC, "0_DieBonus")));
    NuiSetBind (oPC, nToken, "die_bonus_combo_event", JsonBool (TRUE));
    NuiSetBindWatch (oPC, nToken, "die_bonus_combo_selected", TRUE);
    if (GetIsDungeonMaster (oPC) && GetLocalInt (oPC, "0_Broadcast") == 0) SetLocalInt (oPC, "0_Broadcast", 1);
    NuiSetBind (oPC, nToken, "broadcast_combo_selected", JsonInt (GetLocalInt (oPC, "0_Broadcast")));
    NuiSetBind (oPC, nToken, "broadcast_combo_event", JsonBool (TRUE));
    NuiSetBindWatch (oPC, nToken, "broadcast_combo_selected", TRUE);
    NuiSetBind (oPC, nToken, "btn_roll", JsonBool (TRUE));
    NuiSetBind (oPC, nToken, "btn_roll_event", JsonBool (TRUE));
    NuiSetBind (oPC, nToken, "roll_text", JsonString (GetRollText (oPC)));
    NuiSetBindWatch (oPC, nToken, "window_geometry", TRUE);
}

void PopUpCreditsGUIPanel (object oPC)
{
    // Set window to not save until it has been created.
    SetLocalInt (oPC, "0_No_Win_Save", TRUE);
    DelayCommand (0.5f, DeleteLocalInt (oPC, "0_No_Win_Save"));
    // Row 1 (text)************************************************************* 45
    json jRow = CreateTextBox (JsonArray (), "credits_text", 870.0f, 570.0f);
    // Add the row to the column.
    json jCol = JsonArrayInsert (JsonArray (), NuiRow (jRow));
    // Get the window location from the database.
    json jGeometry = GetWindowGeometryFromDB(oPC, "plcreditwin");
    float fX = JsonGetFloat(JsonObjectGet(jGeometry, "x"));
    float fY = JsonGetFloat(JsonObjectGet(jGeometry, "y"));
    // Set the Layout of the window.
    json jLayout = NuiCol (jCol);
    int nToken = SetWindow (oPC, jLayout, "plcreditwin", "Credits",
                            fX, fY, 894.0, 627.0, FALSE, FALSE, TRUE, FALSE, TRUE);
    // Set all binds, events, and watches.
    string sText = GetStringByStrRef (16777221);
    NuiSetBind (oPC, nToken, "credits_text", JsonString (sText));
    NuiSetBindWatch (oPC, nToken, "window_geometry", TRUE);
}

void PopUpCraftingGUIPanel (object oPC)
{
    SetLocalInt (oPC, "0_No_Win_Save", TRUE);
    DelayCommand (0.5f, DeleteLocalInt (oPC, "0_No_Win_Save"));
    // Row 1 (label)************************************************************ 45
    json jRow = CreateLabel (JsonArray (), "", "craft_ranks", 140.0f, 10.0f);
    json jLabel = NuiLabel (NuiBind ("craft_warning_label"), JsonInt (0), JsonInt (0));
    jLabel = NuiId (jLabel, "craft_warning");
    jLabel = NuiStyleForegroundColor (jLabel, NuiColor (255, 0, 0, 255));
    jLabel = NuiWidth (jLabel, 140.0);
    jRow = JsonArrayInsert (jRow, NuiHeight (jLabel, 10.0));
    jRow = CreateLabel (jRow, "", "craft_required", 140.0f, 10.0f);
    // Add the row to the column.
    json jCol = JsonArrayInsert (JsonArray (), NuiRow (jRow));
    // Row 2 (button)*********************************************************** 63
    jRow = CreateButtonSelect (JsonArray (), "Copy", "btn_copy", 140.0f, 25.0f);
    jRow = CreateButton (jRow, "Paste", "btn_paste", 140.0f, 25.0f);
    jRow = CreateButton (jRow, "Randomize", "btn_rand", 140.0f, 25.0f);
    // Add the row to the column.
    jCol = JsonArrayInsert (jCol, NuiRow (jRow));
    // Row 3 (image)************************************************************ 96
    jRow = CreateButtonImage (JsonArray (), "left_arrow", "btn_prev", 82.0f, 176.0f);
    jRow = CreateImage (jRow, "", "color_pallet", NUI_ASPECT_EXACTSCALED, NUI_HALIGN_CENTER, NUI_VALIGN_TOP, 256.0f, 176.0f);
    jRow = CreateButtonImage (jRow, "right_arrow", "btn_next", 82.0f, 176.0f);
    // Add the row to the column.
    jCol = JsonArrayInsert (jCol, NuiRow (jRow));
    // Row 4 (button)*********************************************************** 280
    jRow = JsonArrayInsert (JsonArray (), NuiSpacer ());
    jRow = CreateButton (jRow, "Save", "btn_save", 140.0f, 20.0f);
    jRow = CreateButton (jRow, "", "btn_special", 140.0f, 20.0f);
    jRow = CreateButton (jRow, "", "btn_cancel", 140.0f, 20.0f);
    jRow = JsonArrayInsert (jRow, NuiSpacer ());
    // Add the row to the column.
    jCol = JsonArrayInsert (jCol, NuiRow (jRow));
    // Row 5 (text)************************************************************* 308
    jRow = CreateLabel (JsonArray (), "Item to Craft", "item_title", 140.0f, 10.0f);
    jRow = CreateLabel (jRow, "Model to craft", "model_title", 140.0f, 10.0f);
    jRow = CreateLabel (jRow, "Material to color", "material_title", 140.0f, 10.0f);
    // Add the row to the column.
    jCol = JsonArrayInsert (jCol, NuiRow (jRow));
    // Row 6 (combo box)******************************************************** 326
    jRow = CreateItemCombo (oPC, JsonArray (), "item_combo");
    jRow = CreateModelCombo (oPC, jRow, "model_combo");
    jRow = CreateMaterialCombo (oPC, jRow, "material_combo");
    // Add the row to the column.
    jCol = JsonArrayInsert (jCol, NuiRow (jRow));
    // Set the Layout for column.
    json jLayout = NuiCol (jCol);
    // Get the window location to restore it from the database.
    string sPCWindow;
    // Check if we are a DM then use our target and DB table.
    object oTarget;
    sPCWindow = GetServerDatabaseString (oPC, PLAYER_TABLE, "plcraftwin");
    if (GetIsDungeonMaster (oPC)) oTarget = GetLocalObject (oPC, "0_DM_Target");
    else oTarget = oPC;
    float fX = StringToFloat (GetStringArray (sPCWindow, 1));
    float fY = StringToFloat (GetStringArray (sPCWindow, 2));
    int nToken = SetWindow (oPC, jLayout, "plcraftwin", "Crafting",
                            fX, fY, 452.0, 363.0, FALSE, FALSE, FALSE, FALSE, TRUE);
    // Set all binds, events, and watches.
    // Setup the crafting rank labels.
    int nRanks = GetSkillRank (SKILL_CRAFTING, oPC, TRUE);
    NuiSetBind (oPC, nToken, "craft_ranks", JsonString ("Craft ranks: " + IntToString (nRanks)));
    nRanks = GetLocalInt (oPC, "0_RANKS_REQUIRED");
    NuiSetBind (oPC, nToken, "craft_required", JsonString ("Ranks required: " + IntToString (nRanks)));
    // Setup the copy, paste, and random buttons.
    int nSelected = GetLocalInt (oPC, "0_COPY_ITEM");
    NuiSetBind (oPC, nToken, "btn_copy", JsonBool (nSelected));
    NuiSetBind (oPC, nToken, "btn_copy_event", JsonBool (TRUE));
    NuiSetBind (oPC, nToken, "btn_paste", JsonBool (TRUE));
    NuiSetBind (oPC, nToken, "btn_paste_event", JsonBool (nSelected));
    NuiSetBind (oPC, nToken, "btn_rand", JsonBool (TRUE));
    NuiSetBind (oPC, nToken, "btn_rand_event", JsonBool (TRUE));
    // Setup the Previous, Collor pallet, and Next buttons.
    NuiSetBind (oPC, nToken, "btn_prev", JsonBool (TRUE));
    NuiSetBind (oPC, nToken, "btn_prev_event", JsonBool (TRUE));
    string sColorPallet = GetLocalString (oPC, "0_COLOR_PALLET");
    if (sColorPallet == "") sColorPallet = "cloth_pallet";
    NuiSetBind (oPC, nToken, "color_pallet_image", JsonString (sColorPallet));
    NuiSetBind (oPC, nToken, "color_pallet_event", JsonBool (TRUE));
    NuiSetBind (oPC, nToken, "btn_next", JsonBool (TRUE));
    NuiSetBind (oPC, nToken, "btn_next_event", JsonBool (TRUE));
    // Setup the Item selection combo.
    int nItem = GetLocalInt (oPC, "0_CRAFT_ITEM_SELECTION");
    object oItem = GetSelectedItem (oTarget, nItem);
    NuiSetBind (oPC, nToken, "item_combo_selected", JsonInt (nItem));
    NuiSetBind (oPC, nToken, "item_combo_event", JsonBool (TRUE));
    NuiSetBindWatch (oPC, nToken, "item_combo_selected", TRUE);
    // Setup the model selection combo.
    nSelected = GetLocalInt (oPC, "0_CRAFT_MODEL_SELECTION");
    NuiSetBind (oPC, nToken, "model_combo_selected", JsonInt (nSelected));
    NuiSetBind (oPC, nToken, "model_combo_event", JsonBool (TRUE));
    NuiSetBindWatch (oPC, nToken, "model_combo_selected", TRUE);
    // Setup the material selection combo.
    nSelected = GetLocalInt (oPC, "0_CRAFT_MATERIAL_SELECTION");
    NuiSetBind (oPC, nToken, "material_combo_selected", JsonInt (nSelected));
    NuiSetBind (oPC, nToken, "material_combo_event", JsonBool (TRUE));
    NuiSetBindWatch (oPC, nToken, "material_combo_selected", TRUE);
    // Setup the save button.
    NuiSetBind (oPC, nToken, "btn_save", JsonBool (TRUE));
    NuiSetBind (oPC, nToken, "btn_save_event", JsonBool (FALSE));
    // Setup the special button.
    nSelected = GetLocalInt (oPC, "0_MODEL_SPECIAL");
    NuiSetBind (oPC, nToken, "btn_special", JsonBool (TRUE));
    NuiSetBind (oPC, nToken, "btn_special_event", JsonBool (TRUE));
    if (nItem == 3 || nItem == 4)
    {
        NuiSetBind (oPC, nToken, "btn_special_label", JsonString ("****"));
        NuiSetBind (oPC, nToken, "btn_special", JsonBool (FALSE));
        NuiSetBind (oPC, nToken, "btn_special_event", JsonBool (FALSE));
    }
    else if (nSelected == 0) NuiSetBind (oPC, nToken, "btn_special_label", JsonString ("Left/Right Linked"));
    else if (nSelected == 1) NuiSetBind (oPC, nToken, "btn_special_label", JsonString ("Left Model"));
    else if (nSelected == 2) NuiSetBind (oPC, nToken, "btn_special_label", JsonString ("Right Model"));
    else
    {
        nSelected = GetHiddenWhenEquipped (oItem);
        if (nSelected)
        {
            NuiSetBind (oPC, nToken, "btn_special_label", JsonString ("Model Hidden"));
            SetLocalInt (oPC, "0_MODEL_SPECIAL", 4);
        }
        else
        {
            NuiSetBind (oPC, nToken, "btn_special_label", JsonString ("Model Visible"));
            SetLocalInt (oPC, "0_MODEL_SPECIAL", 3);
        }
    }
    // Setup the Cancel/Exit button.
    NuiSetBind (oPC, nToken, "btn_cancel_label", JsonString ("Exit"));
    NuiSetBind (oPC, nToken, "btn_cancel", JsonBool (TRUE));
    NuiSetBind (oPC, nToken, "btn_cancel_event", JsonBool (TRUE));
    NuiSetBindWatch (oPC, nToken, "window_geometry", TRUE);
}

void PopUpBuffGUIPanel (object oPC)
{
    // Row 1 (Buttons) ********************************************************* 45
    json jRow = CreateButtonSelect (JsonArray (), "Save", "btn_save", 80.0f, 25.0f);
    jRow = JsonArrayInsert (jRow, NuiSpacer ());
    jRow = CreateButton (jRow, "Clear", "btn_clear", 80.0f, 25.0f);
    jRow = JsonArrayInsert (jRow, NuiSpacer ());
    jRow = CreateButton (jRow, "Buff", "btn_buff", 80.0f, 25.0f);
    // Add the row to the column.
    json jCol = JsonArrayInsert (JsonArray (), NuiRow (jRow));
    // Row 2 (Buttons) ********************************************************* 78
    jRow = JsonArrayInsert (JsonArray (), NuiSpacer ());
    jRow = CreateButtonSelect (jRow, "List 1", "btn_list1", 80.0f, 25.0f);
    jRow = JsonArrayInsert (jRow, NuiSpacer ());
    jRow = CreateButtonSelect (jRow, "List 2", "btn_list2", 80.0f, 25.0f);
    jRow = JsonArrayInsert (jRow, NuiSpacer ());
    jRow = CreateButtonSelect (jRow, "List 3", "btn_list3", 80.0f, 25.0f);
    jRow = JsonArrayInsert (jRow, NuiSpacer ());
    jRow = CreateButtonSelect (jRow, "List 4", "btn_list4", 80.0f, 25.0f);
    jRow = JsonArrayInsert (jRow, NuiSpacer ());
    // Add the row to the column.
    jCol = JsonArrayInsert (jCol, NuiRow (jRow));
    // Row 3 (Widget)********************************************************** 111
    jRow = JsonArrayInsert (JsonArray (), NuiSpacer ());
    jRow = CreateCheckBox (jRow, "Fast Buff Widget", "buff_widget", 150.0, 20.0f);
    jRow = CreateCheckBox (jRow, "Lock", "lock_buff_widget", 50.0, 20.0f);
    jRow = JsonArrayInsert (jRow, NuiSpacer ());
    // Add row to the column.
    jCol = JsonArrayInsert (jCol, NuiRow (jRow));
    // Row 4 (List of Spells) ************************************************** 129
    // Create the button template for the List.
    json jButton = NuiId (NuiButton (NuiBind ("btns_spell")), "btn_spell");
    json jList = JsonArrayInsert (JsonArray (), NuiListTemplateCell (jButton, 300.0, TRUE));
    // Create the list with the template.
    jRow = CreateList (JsonArray (), jList, "btns_spell", 25.0, 431.0, 300.0);
    // Add row to the column.
    jCol = JsonArrayInsert (jCol, NuiRow (jRow));
    // Set the layout of the window.
    json jLayout = NuiCol (jCol);
    float fY = GetGUIHeightMiddle (oPC, 257.0);
    int nToken = SetWindow (oPC, jLayout, "plbuffwin", "Fast Buffing Spells",
                            0.0, fY, 456.0, 441.0, FALSE, FALSE, TRUE, FALSE, TRUE);
    // Set the elements to show events to 0e_window.
    int nSelected = GetLocalInt (oPC, "0_SAVE_BUFF_SPELL");
    NuiSetBind (oPC, nToken, "btn_save", JsonBool (nSelected));
    NuiSetBind (oPC, nToken, "btn_save_event", JsonBool (TRUE));
    NuiSetBind (oPC, nToken, "btn_clear", JsonBool (TRUE));
    NuiSetBind (oPC, nToken, "btn_clear_event", JsonBool (TRUE));
    NuiSetBind (oPC, nToken, "btn_buff", JsonBool (TRUE));
    NuiSetBind (oPC, nToken, "btn_buff_event", JsonBool (TRUE));
    string sList = GetServerDatabaseString (oPC, BUFF_TABLE, "spells", "list");
    if (sList == "")
    {
        sList = "1";
        CheckServerDataAndInitialize (oPC, BUFF_TABLE, "list");
        SetServerDatabaseString (oPC, BUFF_TABLE, "spells", "1", "list");
    }
    if (sList == "1") NuiSetBind (oPC, nToken, "btn_list1", JsonBool (TRUE));
    else NuiSetBind (oPC, nToken, "btn_list1", JsonBool (FALSE));
    NuiSetBind (oPC, nToken, "btn_list1_event", JsonBool (TRUE));
    if (sList == "2") NuiSetBind (oPC, nToken, "btn_list2", JsonBool (TRUE));
    else NuiSetBind (oPC, nToken, "btn_list2", JsonBool (FALSE));
    NuiSetBind (oPC, nToken, "btn_list2_event", JsonBool (TRUE));
    if (sList == "3") NuiSetBind (oPC, nToken, "btn_list3", JsonBool (TRUE));
    else NuiSetBind (oPC, nToken, "btn_list3", JsonBool (FALSE));
    NuiSetBind (oPC, nToken, "btn_list3_event", JsonBool (TRUE));
    if (sList == "4") NuiSetBind (oPC, nToken, "btn_list4", JsonBool (TRUE));
    else NuiSetBind (oPC, nToken, "btn_list4", JsonBool (FALSE));
    NuiSetBind (oPC, nToken, "btn_list4_event", JsonBool (TRUE));
    object oPlayersHandbook = GetCreatureHasItem (oPC, "players_book");
    int nValue = GetLocalInt (oPlayersHandbook, "0_WIDGET_BUFF");
    NuiSetBind (oPC, nToken, "buff_widget_check", JsonBool (nValue));
    NuiSetBindWatch (oPC, nToken, "buff_widget_check", TRUE);
    if (nValue > 0) nValue --;
    NuiSetBind (oPC, nToken, "lock_buff_widget_check", JsonBool (nValue));
    NuiSetBindWatch (oPC, nToken, "lock_buff_widget_check", TRUE);
    // Create buttons with spells listed.
    json jButtons = JsonArray ();
    int nSpell, nClass, nLevel, nMetamagic, nDomain, nCntr;
    string sName;
    json jSpells, jSpell;
    sList = "list" + sList;
    while (nCntr <= 50)
    {
        jSpells = GetServerDatabaseJson (oPC, BUFF_TABLE, "spells", sList);
        jSpell = JsonArrayGet (jSpells, nCntr);
        if (JsonGetType (jSpell) != JSON_TYPE_NULL)
        {
            nSpell = JsonGetInt (JsonArrayGet (jSpell, 0));
            nClass = JsonGetInt (JsonArrayGet (jSpell, 1));
            nLevel = JsonGetInt (JsonArrayGet (jSpell, 2));
            nMetamagic = JsonGetInt (JsonArrayGet (jSpell, 3));
            nDomain = JsonGetInt (JsonArrayGet (jSpell, 4));
            string sTargetName = JsonGetString (JsonArrayGet (jSpell, 5));
            sName = GetStringByStrRef (StringToInt (Get2DAString ("spells", "Name", nSpell)));
            sName += " (" + GetStringByStrRef (StringToInt (Get2DAString ("classes", "Short", nClass)));
            sName += " / " + IntToString (nLevel);
            if (nMetamagic > 0)
            {
                if (nMetamagic == METAMAGIC_EMPOWER) sName += " / Empowered";
                else if (nMetamagic == METAMAGIC_EXTEND) sName += " / Extended";
                else if (nMetamagic == METAMAGIC_MAXIMIZE) sName += " / Maximized";
                else if (nMetamagic == METAMAGIC_QUICKEN) sName += " / Quickened";
                else if (nMetamagic == METAMAGIC_SILENT) sName += " / Silent";
                else if (nMetamagic == METAMAGIC_STILL) sName += " / Still";
            }
            if (nDomain > 0)
                sName += " / Domain";
            sName += ") " + sTargetName;
            jButtons = JsonArrayInsert (jButtons, JsonString (sName));
        }
        nCntr ++;
    }
    // Add the buttons to the list.
    NuiSetBind (oPC, nToken, "btns_spell", jButtons);
}

void PopupWidgetBuffGUIPanel (object oPC)
{
    // Set window to not save until it has been created.
    SetLocalInt (oPC, "0_No_Win_Save", TRUE);
    DelayCommand (0.5f, DeleteLocalInt (oPC, "0_No_Win_Save"));
    // Row 1 (buttons)**********************************************************
    json jRow = CreateButtonImage  (JsonArray (), "ic_fbuff_one", "btn_one", 30.0f, 30.0f);
    jRow = CreateButtonImage  (jRow, "ic_fbuff_two", "btn_two", 30.0f, 30.0f);
    jRow = CreateButtonImage  (jRow, "ic_fbuff_three", "btn_three", 30.0f, 30.0f);
    jRow = CreateButtonImage  (jRow, "ic_fbuff_four", "btn_four", 30.0f, 30.0f);
    // Add the row to the column.
    json jCol = JsonArrayInsert (JsonArray (), NuiRow (jRow));
    // Get the window location to restore it from the database.
    string sPCWindow;
    sPCWindow = GetServerDatabaseString (oPC, PLAYER_TABLE, "widgetbuffwin");
    float fX = StringToFloat (GetStringArray (sPCWindow, 1));
    float fY = StringToFloat (GetStringArray (sPCWindow, 2));
    // Set the layout of the window.
    json jLayout = NuiCol (jCol);
    int nToken = SetWindow (oPC, jLayout, "widgetbuffwin", "Fast Buff Widget", fX, fY, 136.0, 87.0, FALSE, FALSE, FALSE, TRUE, FALSE);
    // Set event watches for window inspector and save window location.
    NuiSetBindWatch (oPC, nToken, "collapsed", TRUE);
    NuiSetBindWatch (oPC, nToken, "window_geometry", TRUE);
    // Get if the widget is locked or not. 1 - not locked, 2 - locked.
    object oPlayersHandbook = GetCreatureHasItem (oPC, "players_book");
    int nValue = GetLocalInt (oPlayersHandbook, "0_WIDGET_BUFF");
    if (nValue == 2) NuiSetBind (oPC, nToken, "window_title", JsonBool (FALSE));
    // Set the buttons to show events to 0e_window.
    //NuiSetBind (oPC, nToken, "btn_one", JsonBool (TRUE));
    NuiSetBind (oPC, nToken, "btn_one_event", JsonBool (TRUE));
    NuiSetBind (oPC, nToken, "btn_two", JsonBool (TRUE));
    NuiSetBind (oPC, nToken, "btn_two_event", JsonBool (TRUE));
    NuiSetBind (oPC, nToken, "btn_three", JsonBool (TRUE));
    NuiSetBind (oPC, nToken, "btn_three_event", JsonBool (TRUE));
    NuiSetBind (oPC, nToken, "btn_four", JsonBool (TRUE));
    NuiSetBind (oPC, nToken, "btn_four_event", JsonBool (TRUE));
}


/*******************************************************************************
*  Helper functions for the layouts.                                           *
*******************************************************************************/

string GetRollText (object oPlayer)
{
    int nNum = GetLocalInt (oPlayer, "0_NumDice") + 1;
    int nType = GetLocalInt (oPlayer, "0_TypeRoll");
    int nBonus = GetLocalInt (oPlayer, "0_DieBonus");
    string sNum, sDie, sBonus;
    if (nType < 7)
    {
        sNum = IntToString (nNum);
        if (nType == 0) sDie = "d4";
        if (nType == 1) sDie = "d6";
        if (nType == 2) sDie = "d8";
        if (nType == 3) sDie = "d10";
        if (nType == 4) sDie = "d12";
        if (nType == 5) sDie = "d20";
        if (nType == 6) sDie = "d100";
        if (nBonus == 0) sBonus = "";
        else if (nBonus > 0) sBonus = "+" + IntToString (nBonus);
        else sBonus = "-" + IntToString (abs (nBonus));
        return sNum + sDie + sBonus;
    }
    else if (nType == 7) return "Fortitude Save";
    else if (nType == 8) return "Reflex Save";
    else if (nType == 9) return "Will Save";
    else if (nType == 10) return "Base Attack Roll";
    else if (nType == 11)return "Strength Check";
    else if (nType == 12) return "Dexterity Check";
    else if (nType == 13) return "Constitution Check";
    else if (nType == 14) return "Intelligence Check";
    else if (nType == 15) return "Wisdom Check";
    else if (nType == 16) return "Charisma Check";
    else return GetStringByStrRef (StringToInt (Get2DAString ("skills", "Name", nType - 17))) + " Check";
    return "";
}

json CreateNumOfDiceCombo (json jRow, string sComboBind)
{
    json jCombo = JsonArray ();
    int i;
    for (i = 0;i < 20; i ++)
    {
        jCombo = JsonArrayInsert (jCombo, NuiComboEntry (IntToString (i + 1), i));
    }
    return CreateCombo (jRow, jCombo, sComboBind, 75.0, 25.0);
}

json CreateRollTypeCombo (object oTarget, json jRow, string sComboBind)
{
    string sName, sRank;
    int i;
    json jCombo = JsonArray ();
    // Create the list.
    jCombo = JsonArrayInsert (jCombo, NuiComboEntry ("d4", 0));
    jCombo = JsonArrayInsert (jCombo, NuiComboEntry ("d6", 1));
    jCombo = JsonArrayInsert (jCombo, NuiComboEntry ("d8", 2));
    jCombo = JsonArrayInsert (jCombo, NuiComboEntry ("d10", 3));
    jCombo = JsonArrayInsert (jCombo, NuiComboEntry ("d12", 4));
    jCombo = JsonArrayInsert (jCombo, NuiComboEntry ("d20", 5));
    jCombo = JsonArrayInsert (jCombo, NuiComboEntry ("d100", 6));
    sRank = "(" + IntToString (GetFortitudeSavingThrow (oTarget)) + ") ";
    jCombo = JsonArrayInsert (jCombo, NuiComboEntry (sRank + "Fortitude", 7));
    sRank = "(" + IntToString (GetReflexSavingThrow (oTarget)) + ") ";
    jCombo = JsonArrayInsert (jCombo, NuiComboEntry (sRank + "Reflex", 8));
    sRank = "(" + IntToString (GetWillSavingThrow (oTarget)) + ") ";
    jCombo = JsonArrayInsert (jCombo, NuiComboEntry (sRank + "Will", 9));
    sRank = "(" + IntToString (GetBaseAttackBonus (oTarget)) + ") ";
    jCombo = JsonArrayInsert (jCombo, NuiComboEntry (sRank + "Base Attack", 10));
    sRank = "(" + IntToString (GetAbilityModifier (ABILITY_STRENGTH, oTarget)) + ") ";
    jCombo = JsonArrayInsert (jCombo, NuiComboEntry (sRank + "Strength", 11));
    sRank = "(" + IntToString (GetAbilityModifier (ABILITY_DEXTERITY, oTarget)) + ") ";
    jCombo = JsonArrayInsert (jCombo, NuiComboEntry (sRank + "Dexterity", 12));
    sRank = "(" + IntToString (GetAbilityModifier (ABILITY_CONSTITUTION, oTarget)) + ") ";
    jCombo = JsonArrayInsert (jCombo, NuiComboEntry (sRank + "Constitution", 13));
    sRank = "(" + IntToString (GetAbilityModifier (ABILITY_INTELLIGENCE, oTarget)) + ") ";
    jCombo = JsonArrayInsert (jCombo, NuiComboEntry (sRank + "Intelligence", 14));
    sRank = "(" + IntToString (GetAbilityModifier (ABILITY_WISDOM, oTarget)) + ") ";
    jCombo = JsonArrayInsert (jCombo, NuiComboEntry (sRank + "Wisdom", 15));
    sRank = "(" + IntToString (GetAbilityModifier (ABILITY_CHARISMA, oTarget)) + ") ";
    jCombo = JsonArrayInsert (jCombo, NuiComboEntry (sRank + "Charisma", 16));
    for (i = 0; i < 28; i ++)
    {
        sRank = "(" + IntToString (GetSkillRank (i, oTarget)) + ") ";
        sName = GetStringByStrRef (StringToInt (Get2DAString ("skills", "Name", i)));
        jCombo = JsonArrayInsert (jCombo, NuiComboEntry (sRank + sName, i + 17));
    }
    return CreateCombo (jRow, jCombo, sComboBind, 200.0, 25.0);
}

json CreateDieBonusCombo (json jRow, string sComboBind)
{
    json jCombo = JsonArray ();
    int i;
    jCombo = JsonArrayInsert (jCombo, NuiComboEntry ("0", 0));
    for (i = 1;i < 21; i ++)
    {
        jCombo = JsonArrayInsert (jCombo, NuiComboEntry ("+" + IntToString (i), i));
    }
    for (i = 1;i < 21; i ++)
    {
        jCombo = JsonArrayInsert (jCombo, NuiComboEntry ("-" + IntToString (i), i + 20));
    }
    return CreateCombo (jRow, jCombo, sComboBind, 75.0, 25.0);
}

json CreateBroadcastCombo (object oPC, json jRow, string sComboBind)
{
    json jCombo = JsonArray ();
    // Create the list.
    jCombo = JsonArrayInsert (jCombo, NuiComboEntry ("DM", 0));
    jCombo = JsonArrayInsert (jCombo, NuiComboEntry ("Local", 1));
    jCombo = JsonArrayInsert (jCombo, NuiComboEntry ("Party", 2));
    if (GetServerDatabaseInt (oPC, PLAYER_TABLE, "status") > 1 || GetIsDungeonMaster (oPC))
    {
        jCombo = JsonArrayInsert (jCombo, NuiComboEntry ("Global", 3));
        jCombo = JsonArrayInsert (jCombo, NuiComboEntry ("Target", 4));
    }
    else jCombo = JsonArrayInsert (jCombo, NuiComboEntry ("Target", 3));
    return CreateCombo (jRow, jCombo, sComboBind, 100.0, 25.0);
}

// Gets all creatures the PC can summon a sets them in jCanSummon spell_summons.2da index(int).
struct stComboBox GetSummons (object oPC)
{
    int nCnt, nRow;
    string sResRef, sItemResRef;
    int nMaxRow = Get2DARowCount ("summons");
    struct stComboBox stCBox;
    stCBox.jIndex = JsonArray ();
    stCBox.jWinArray = JsonArray ();
    stCBox.jRow = JsonArray ();
    stCBox.jCanSummon = JsonArray ();
    // Initialize the jCanSummons array to all FALSE.
    for (nRow = 0; nRow <= nMaxRow; nRow ++)
    {
        stCBox.jCanSummon = JsonArrayInsert (stCBox.jCanSummon, JsonBool (FALSE));
    }
    // Check to see if we have an item that allows us to summon a creature.
    object oItem = GetFirstItemInInventory (oPC);
    while (oItem != OBJECT_INVALID)
    {
        sItemResRef = GetResRef (oItem);
        // Is this a summons item?
        if (GetStringLeft (sItemResRef, 5) == "0_sm_")
        {
            // Now check each summons to see if we have an item that matches the items resref.
            nRow = 1;
            sResRef = Get2DAString ("summons", "ObjectResRef", nRow);
            while (nRow <= nMaxRow)
            {
                if (sResRef == sItemResRef)
                {
                    stCBox.jCanSummon = JsonArraySet (stCBox.jCanSummon, nRow, JsonBool (TRUE));
                    break;
                }
                sResRef = Get2DAString ("summons", "ObjectResRef", ++nRow);
            }
        }
        oItem = GetNextItemInInventory (oPC);
    }
    // Setup to check the summons.2da for any creatures we can summon.
    int nDeity, nDomain, nDeityDomain, nRace, nSpell, nLevelNeeded;
    int nFeat, nClass, nClassLevel;
    int nDruidLevel = GetLevelByClass (CLASS_TYPE_DRUID, oPC);
    int nPCDeity = GetObjectDatabaseInt (oPC, CHARACTER_TABLE, "deity");
    int nPCRace = GetRacialType (oPC);
    int nPCDomain1 = GetDomain (oPC, 1);
    int nPCDomain2 = GetDomain (oPC, 2);
    string sDeity, sDomain, sSpellTableColumn, sFeat, sLevelNeeded;
    nRow = 1;
    while (nRow <= nMaxRow)
    {
        // Check to see if we have a domain that will allow us to summons a creature.
        sDomain = Get2DAString ("summons", "Domain", nRow);
        if (sDomain != "")
        {
            if (nPCDomain1 > 0 || nDruidLevel > 0)
            {
                nDomain = StringToInt (sDomain);
                // We have a matching domain, see if we can summon the creature.
                if (nDomain == nPCDomain1 || nDomain == nPCDomain2 ||
                    (nDruidLevel > 0 && nDomain == 1))
                {
                    nDeity = StringToInt (Get2DAString ("summons", "Deity", nRow));
                    // No Deity required or we have this Deity then set that we can summon the creature.
                    if (nDeity == nPCDeity)
                    {
                        stCBox.jCanSummon = JsonArraySet (stCBox.jCanSummon, nRow, JsonBool (TRUE));
                    }
                    // -1 means the Deity requires a specific Race to summon the creature.
                    else if (nDeity == -1)
                    {
                        nCnt = 1;
                        while (nCnt < 6)
                        {
                            nRace = StringToInt (Get2DAString ("summons", "Race_" + IntToString (nCnt++), nRow));
                            if (nPCRace == nRace)
                            {
                                stCBox.jCanSummon = JsonArraySet (stCBox.jCanSummon, nRow, JsonBool (TRUE));
                                break;
                            }
                        }
                    }
                    // Finally we check with no Specific Deity to see if they have a matching Domain.
                    else if (nDeity == 0)
                    {
                        nCnt = 1;
                        while (nCnt < 4)
                        {
                            nDeityDomain = StringToInt (Get2DAString ("deities", "DomainSummons" + IntToString (nCnt++), nPCDeity));
                            if (nDeityDomain == nDomain)
                            {
                                stCBox.jCanSummon = JsonArraySet (stCBox.jCanSummon, nRow, JsonBool (TRUE));
                                break;
                            }
                        }
                    }
                }
            }
        }
        // Check to see if they have enough levels adding all classes together.
        sLevelNeeded = Get2DAString ("summons", "Level", nRow);
        nSpell = StringToInt (Get2DAString ("summons", "Spell_ID", nRow));
        if (sLevelNeeded != "")
        {
            nLevelNeeded = StringToInt (sLevelNeeded);
            nClassLevel = 0;
            for (nCnt = 1; nCnt < 6; nCnt ++)
            {
                nClass = GetClassByPosition (nCnt, oPC);
                sSpellTableColumn = Get2DAString ("classes", "SpellTableColumn", nClass);
                if (Get2DAString ("spells", sSpellTableColumn, nSpell) != "")
                {
                    nClassLevel += GetLevelByClass (nClass, oPC);
                }
            }
            // Check for prestige classes that add levels too.
            nClassLevel += GetLevelByClass (CLASS_TYPE_MYSTIC_THEURGE, oPC);
            nClassLevel += GetLevelByClass (CLASS_TYPE_PALEMASTER, oPC);
            if (nClassLevel >= nLevelNeeded || nLevelNeeded == 0)
            {
                stCBox.jCanSummon = JsonArraySet (stCBox.jCanSummon, nRow, JsonBool (TRUE));
            }
        }
        // Check for feats that allow to summon the creature.
        for (nCnt = 1; nCnt < 4; nCnt ++)
        {
            sFeat = Get2DAString ("summons", "Feat" + IntToString (nCnt), nRow);
            if (sFeat == "") break;
            else if (GetHasFeat (StringToInt (sFeat), oPC))
            {
                stCBox.jCanSummon = JsonArraySet (stCBox.jCanSummon, nRow, JsonBool (TRUE));
                break;
            }
        }
        nRow++;
    }
    //Debug ("0i_win_layout_pc", "1076", JsonDump (stCBox.jCanSummon, 1));
    return stCBox;
}

struct stComboBox CreateUseLangCombo (object oPC, struct stComboBox stCBox, string sComboBind)
{
    stCBox.jResRefArray = JsonArray ();
    stCBox.jCombo = JsonArray ();
    string sLang;
    int nLanguageUsing = GetLocalInt (oPC, "0_Language");
    int nEntry, i = 1171;
    while (i < 1198)
    {
        if (GetHasFeat (i, oPC))
        {
            nEntry ++;
            sLang = Get2DAString ("feat", "LABEL", i);
            stCBox.jCombo = JsonArrayInsert (stCBox.jCombo, NuiComboEntry (sLang, nEntry));
            stCBox.jResRefArray = JsonArrayInsert (stCBox.jResRefArray, JsonInt (i));
            if (i == nLanguageUsing)
            {
                stCBox.jIndex = JsonArrayInsert (stCBox.jIndex, JsonInt (nEntry));
            }
        }
        i ++;
    }
    stCBox.jWinArray = JsonArrayInsert (stCBox.jWinArray, stCBox.jResRefArray);
    stCBox.jCombo = NuiId (NuiCombo (stCBox.jCombo, NuiBind (sComboBind + "_selected")), sComboBind);
    stCBox.jCombo = NuiEnabled  (stCBox.jCombo, NuiBind (sComboBind + "_event"));
    stCBox.jCombo = NuiWidth (stCBox.jCombo, 175.0);
    stCBox.jRow = JsonArrayInsert (stCBox.jRow, NuiHeight (stCBox.jCombo, 25.0));
    return stCBox;
}

struct stComboBox CreateTakeLangCombo (object oPC, struct stComboBox stCBox, string sComboBind)
{
    stCBox.jResRefArray = JsonArray ();
    stCBox.jCombo = JsonArray ();
    string sLang;
    int nEntry, i = 1171;
    while (i < 1198)
    {
        if (!GetHasFeat (i, oPC))
        {
            nEntry ++;
            sLang = Get2DAString ("feat", "LABEL", i);
            stCBox.jCombo = JsonArrayInsert (stCBox.jCombo, NuiComboEntry (sLang, nEntry));
            stCBox.jResRefArray = JsonArrayInsert (stCBox.jResRefArray, JsonInt (i));
        }
        i ++;
    }
    stCBox.jWinArray = JsonArrayInsert (stCBox.jWinArray, stCBox.jResRefArray);
    stCBox.jCombo = NuiId (NuiCombo (stCBox.jCombo, NuiBind (sComboBind + "_selected")), sComboBind);
    stCBox.jCombo = NuiEnabled  (stCBox.jCombo, NuiBind (sComboBind + "_event"));
    stCBox.jCombo = NuiWidth (stCBox.jCombo, 175.0);
    stCBox.jRow = JsonArrayInsert (stCBox.jRow, NuiHeight (stCBox.jCombo, 25.0));
    return stCBox;
}

// Creates the combo box for spells using change_spell.2da.
// jCombo - the combo box elements.
// sSpellName - the spell name to create for i.e. "Summon Creature I".
// nSummons is the index of the summons array in the database.
struct stComboBox CreateSummonComboBox (object oPC, struct stComboBox stCBox, string sSpellName, int nSummons)
{
    int nRow = 1, nEntry, bEntryAdded, nSummonIndex;
    stCBox.jResRefArray = JsonArray ();
    string sCreatureName, sCreatureResRef;
    string sSummons = GetObjectDatabaseString (oPC, CHARACTER_TABLE, "summons");
    sSummons = GetStringArray (sSummons, nSummons);
    string sSpell2DAName = Get2DAString ("change_spell", "SpellName", nRow);
    while (sSpell2DAName != "")
    {
        if (sSpell2DAName == sSpellName)
        {
            // Summons index is the line we reference in summons.2da for the creature of this spell.
            nSummonIndex = StringToInt (Get2DAString ("change_spell", "summons_index", nRow));
            if (JsonGetInt (JsonArrayGet (stCBox.jCanSummon, nSummonIndex)))
            {
                sCreatureName = Get2DAString ("change_spell", "CreatureName", nRow);
                stCBox.jCombo = JsonArrayInsert (stCBox.jCombo, NuiComboEntry (sCreatureName, nEntry));
                sCreatureResRef = Get2DAString ("change_spell", "CreatureResRef", nRow);
                stCBox.jResRefArray = JsonArrayInsert (stCBox.jResRefArray, JsonString (sCreatureResRef));
                if (sCreatureResRef == sSummons)
                {
                    stCBox.jIndex = JsonArrayInsert (stCBox.jIndex, JsonInt (nEntry));
                    bEntryAdded = TRUE;
                }
                nEntry ++;
            }
        }
        sSpell2DAName = Get2DAString ("change_spell", "SpellName", ++nRow);
    }
    if (!bEntryAdded) stCBox.jIndex = JsonArrayInsert (stCBox.jIndex, JsonInt (0));
    stCBox.jWinArray = JsonArrayInsert (stCBox.jWinArray, stCBox.jResRefArray);
    return stCBox;
}

struct stComboBox CreateSummonCombo (object oPC, struct stComboBox stCBox, string sSpellName, string sComboBind, int nSummons)
{
    // Creates the NuiComboEntry.
    stCBox.jCombo = JsonArray ();
    stCBox = CreateSummonComboBox (oPC, stCBox, sSpellName, nSummons);
    stCBox.jCombo = NuiId (NuiCombo (stCBox.jCombo, NuiBind (sComboBind + "_selected")), sComboBind);
    stCBox.jCombo = NuiEnabled  (stCBox.jCombo, NuiBind (sComboBind + "_event"));
    stCBox.jRow = JsonArrayInsert (stCBox.jRow, NuiWidth (stCBox.jCombo, 225.0));
    return stCBox;
}

json CreateItemCombo (object oPC, json jRow, string sComboBind)
{
    int nCnt;
    json jCombo = JsonArray ();
    // Create the list.
    jCombo = JsonArrayInsert (jCombo, NuiComboEntry ("Armor", 0));
    jCombo = JsonArrayInsert (jCombo, NuiComboEntry ("Cloak", 1));
    jCombo = JsonArrayInsert (jCombo, NuiComboEntry ("Headgear", 2));
    jCombo = JsonArrayInsert (jCombo, NuiComboEntry ("Right hand", 3));
    jCombo = JsonArrayInsert (jCombo, NuiComboEntry ("Left hand", 4));
    return CreateCombo (jRow, jCombo, sComboBind, 140.0, 25.0);
}

json CreateModelCombo (object oPC, json jRow, string sComboBind)
{
    float fFacing = GetFacing (oPC);
    json jCombo = JsonArray ();
    int nSelected = GetLocalInt (oPC, "0_CRAFT_ITEM_SELECTION");
    // Create the list.
    // Armor.
    if (nSelected == 0)
    {
        fFacing += 180.0f;
        if (fFacing > 359.0) fFacing -=359.0;
        AssignCommand (oPC, SetCameraFacing (fFacing, 4.5f, 75.0, CAMERA_TRANSITION_TYPE_VERY_FAST));
        jCombo = JsonArrayInsert (jCombo, NuiComboEntry ("Neck", 0));
        jCombo = JsonArrayInsert (jCombo, NuiComboEntry ("Shoulder", 1));
        jCombo = JsonArrayInsert (jCombo, NuiComboEntry ("Bicep", 2));
        jCombo = JsonArrayInsert (jCombo, NuiComboEntry ("Forearm", 3));
        jCombo = JsonArrayInsert (jCombo, NuiComboEntry ("Hand", 4));
        jCombo = JsonArrayInsert (jCombo, NuiComboEntry ("Torso", 5));
        jCombo = JsonArrayInsert (jCombo, NuiComboEntry ("Belt", 6));
        jCombo = JsonArrayInsert (jCombo, NuiComboEntry ("Pelvis", 7));
        jCombo = JsonArrayInsert (jCombo, NuiComboEntry ("Thigh", 8));
        jCombo = JsonArrayInsert (jCombo, NuiComboEntry ("Shin", 9));
        jCombo = JsonArrayInsert (jCombo, NuiComboEntry ("Foot", 10));
        jCombo = JsonArrayInsert (jCombo, NuiComboEntry ("Robe", 11));
    }
    // Cloak.
    else if (nSelected == 1)
    {
        if (fFacing > 359.0) fFacing -=359.0;
        AssignCommand (oPC, SetCameraFacing (fFacing, 4.5f, 75.0, CAMERA_TRANSITION_TYPE_VERY_FAST));
        jCombo = JsonArrayInsert (jCombo, NuiComboEntry ("Cloak", 0));
    }
    // Headgear.
    else if (nSelected == 2)
    {
        fFacing += 180.0f;
        if (fFacing > 359.0) fFacing -=359.0;
        AssignCommand (oPC, SetCameraFacing (fFacing, 2.5f, 75.0, CAMERA_TRANSITION_TYPE_VERY_FAST));
        jCombo = JsonArrayInsert (jCombo, NuiComboEntry ("Headgear", 0));
    }
    // Weapon.
    else if (nSelected == 3)
    {
        // If they are changing a bow then face the opposite side.
        object oItem = GetItemInSlot (INVENTORY_SLOT_RIGHTHAND, oPC);
        int nBaseItemType = GetBaseItemType (oItem);
        if (nBaseItemType == BASE_ITEM_LONGBOW || nBaseItemType == BASE_ITEM_SHORTBOW) fFacing -= 90.00;
        // This will make the camera face a melee weapon.
        else fFacing += 90.0;
        if (fFacing > 359.0) fFacing -=359.0;
        AssignCommand (oPC, SetCameraFacing (fFacing, 3.5f, 75.0, CAMERA_TRANSITION_TYPE_VERY_FAST));
        jCombo = JsonArrayInsert (jCombo, NuiComboEntry ("Bottom", 0));
        jCombo = JsonArrayInsert (jCombo, NuiComboEntry ("Middle", 1));
        jCombo = JsonArrayInsert (jCombo, NuiComboEntry ("Top", 2));
    }
    // Weapon/Shield.
    else if (nSelected == 4)
    {
        fFacing += 270.0f;
        if (fFacing > 359.0) fFacing -=359.0;
        AssignCommand (oPC, SetCameraFacing (fFacing, 3.5f, 75.0, CAMERA_TRANSITION_TYPE_VERY_FAST));
        object oItem = GetItemInSlot (INVENTORY_SLOT_LEFTHAND, oPC);
        if (GetIsWeapon (oItem))
        {
            jCombo = JsonArrayInsert (jCombo, NuiComboEntry ("Top", 0));
            jCombo = JsonArrayInsert (jCombo, NuiComboEntry ("Middle", 1));
            jCombo = JsonArrayInsert (jCombo, NuiComboEntry ("Bottom", 2));
        }
        else
        {
            jCombo = JsonArrayInsert (jCombo, NuiComboEntry ("Shield", 0));
        }
    }
    return CreateCombo (jRow, jCombo, sComboBind, 140.0, 25.0);
}

json CreateMaterialCombo (object oPC, json jRow, string sComboBind)
{
    int nCnt;
    json jCombo = JsonArray ();
    int nSelected = GetLocalInt (oPC, "0_CRAFT_ITEM_SELECTION");
    // Create the list.
    // Armor, Cloak, Headgear.
    if (nSelected == 0 || nSelected == 1 || nSelected == 2)
    {
        jCombo = JsonArrayInsert (jCombo, NuiComboEntry ("Cloth 1", 0));
        jCombo = JsonArrayInsert (jCombo, NuiComboEntry ("Cloth 2", 1));
        jCombo = JsonArrayInsert (jCombo, NuiComboEntry ("Leather 1", 2));
        jCombo = JsonArrayInsert (jCombo, NuiComboEntry ("Leather 2", 3));
        jCombo = JsonArrayInsert (jCombo, NuiComboEntry ("Metal 1", 4));
        jCombo = JsonArrayInsert (jCombo, NuiComboEntry ("Metal 2", 5));
    }
    else
    {
        jCombo = JsonArrayInsert (jCombo, NuiComboEntry ("None", 0));
    }
    return CreateCombo (jRow, jCombo, sComboBind, 140.0, 25.0);
}

void PopUpPasswordGUIPanel (object oPC)
{
    // Row 1 (title)************************************************************ 45
    json jRow = JsonArrayInsert (JsonArray (), NuiSpacer ());
    jRow = CreateLabel (jRow, "Player Password", "password_title", 150.0, 10.0);
    jRow = JsonArrayInsert (jRow, NuiSpacer ());
    // Add the row to the column and set column height.
    json jCol = JsonArrayInsert (JsonArray (), NuiRow (jRow));
    // Row 2 (text edit box)**************************************************** 63
    jRow = JsonArrayInsert (JsonArray (), NuiSpacer ());
    jRow = CreateTextEditBox (jRow, "password_placeholder", "password_value", 30, FALSE, 300.0f, 20.0f);
    jRow = JsonArrayInsert (jRow, NuiSpacer ());
    // Add row to the column.
    jCol = JsonArrayInsert (jCol, NuiRow (jRow));
    // Row 3 (buttons)********************************************************** 91
    jRow = JsonArrayInsert (JsonArray (), NuiSpacer ());
    jRow = CreateButton (jRow, "OK", "btn_ok", 100.0f, 20.0f);
    jRow = JsonArrayInsert (jRow, NuiSpacer ());
    // Add row to the column.
    jCol = JsonArrayInsert (jCol, NuiRow (jRow));
    // Row 4 (title)************************************************************ 119
    jRow = JsonArrayInsert (JsonArray (), NuiSpacer ());
    jRow = CreateLabel (jRow, "If this is your first login just hit enter.", "password_title1", 300.0, 10.0);
    jRow = JsonArrayInsert (jRow, NuiSpacer ());
    // Add the row to the column and set column height.
    jCol = JsonArrayInsert (jCol, NuiRow (jRow));
    // Row 5 (title)************************************************************ 137
    jRow = JsonArrayInsert (JsonArray (), NuiSpacer ());
    jRow = CreateLabel (jRow, "Then go to options to set your password.", "password_title2", 300.0, 10.0);
    jRow = JsonArrayInsert (jRow, NuiSpacer ());
    // Add the row to the column and set column height.
    jCol = JsonArrayInsert (jCol, NuiRow (jRow));
    float fX = GetGUIWidthMiddle (oPC, 324.0);
    float fY = GetGUIHeightMiddle (oPC, 159.0);
    // Set the Layout of the window.
    json jLayout = NuiCol (jCol);
    int nToken = SetWindow (oPC, jLayout, "plpasswordwin", "Password",
                            fX, fY, 324.0, 159.0, FALSE, FALSE, FALSE, FALSE, TRUE);
    // Set all binds, events, and watches.
    NuiSetBind (oPC, nToken, "btn_ok_event", JsonBool (TRUE));
    SetCommandable (FALSE, oPC);
}
void PopUpYesNoPanel (object oPC, string sTitle, string sMessage, float fTextBoxX, float fTextBoxY)
{
    // Row 1 (Message)********************************************************** 45
    json jRow = CreateTextBox (JsonArray (), "message_text", fTextBoxX, fTextBoxY);
    // Add the row to the column.
    json jCol = JsonArrayInsert (JsonArray (), NuiRow (jRow));
    // Row 2 (buttons)********************************************************** 153
    jRow = JsonArrayInsert (JsonArray(), NuiSpacer ());
    jRow = CreateButton (jRow, "Yes", "btn_yes", 50.0f, 25.0f);
    jRow = JsonArrayInsert (jRow, NuiSpacer ());
    jRow = CreateButton (jRow, "No", "btn_no", 50.0f, 25.0f);
    jRow = JsonArrayInsert (jRow, NuiSpacer ());
    // Add the row to the column.
    jCol = JsonArrayInsert (jCol, NuiRow (jRow));
    // Set the layout of the window.
    json jLayout = NuiCol (jCol);
    int nToken = SetWindow (oPC, jLayout, "plyesnowin", sTitle, -1.0, -1.0, fTextBoxX + 24.0, fTextBoxY + 90, FALSE, FALSE, FALSE, FALSE, TRUE);
    // Set the buttons to show events to 0e_window.
    NuiSetBind (oPC, nToken, "message_text", JsonString (sMessage));
    NuiSetBind (oPC, nToken, "btn_yes_event", JsonBool (TRUE));
    NuiSetBind (oPC, nToken, "btn_no_event", JsonBool (TRUE));
}
void PopUpDeathPanel(object oPC)
{
    // Create Background image in the center of the window.
    json jPos = NuiRect(0.0, 0.0, 350.0, 200.0);
    json jLabel = NuiLabel(JsonString(""), JsonInt(0), JsonInt(0));
    jLabel = NuiHeight(NuiWidth(jLabel, 350.0), 25.0);
    json jImage = JsonArrayInsert(JsonArray(), NuiDrawListImage(JsonBool(TRUE), JsonString("dth_deathopts"), jPos, JsonInt(NUI_ASPECT_EXACTSCALED), JsonInt(NUI_HALIGN_CENTER), JsonInt(NUI_VALIGN_MIDDLE)));
    json jRow = JsonArrayInsert(JsonArray(), NuiDrawList(jLabel, JsonBool(FALSE), jImage));
    json jCol = JsonArrayInsert(JsonArray(), NuiRow (jRow));
    // Row 1 (Message)********************************************************** 45
    jRow = JsonArrayInsert(JsonArray(), NuiSpacer());
    jRow = CreateLabel(jRow, "You have died!", "lbl_death_1", 175.00, 30.0, -1.0, NUI_HALIGN_CENTER, NUI_VALIGN_BOTTOM);
    jRow = JsonArrayInsert(jRow, NuiSpacer());
    jCol = JsonArrayInsert(jCol, NuiRow(jRow));
    jRow = CreateLabel(JsonArray(), "", "lbl_blank", 175.00, 5.0, 0.0, NUI_HALIGN_CENTER, NUI_VALIGN_MIDDLE);
    jCol = JsonArrayInsert(jCol, NuiRow(jRow));
    jRow = JsonArrayInsert(JsonArray(), NuiSpacer());
    jRow = CreateLabel(jRow, "", "lbl_death_2", 175.00, 10.0, 0.0, NUI_HALIGN_CENTER, NUI_VALIGN_MIDDLE);
    jRow = JsonArrayInsert(jRow, NuiSpacer());
    jCol = JsonArrayInsert(jCol, NuiRow(jRow));
    jRow = JsonArrayInsert(JsonArray(), NuiSpacer());
    jRow = CreateLabel(jRow, "", "lbl_death_3", 175.00, 10.0, 0.0, NUI_HALIGN_CENTER, NUI_VALIGN_MIDDLE);
    jRow = JsonArrayInsert(jRow, NuiSpacer());
    jCol = JsonArrayInsert(jCol, NuiRow(jRow));
    jRow = CreateLabel(JsonArray(), "", "lbl_blank", 175.00, 5.0, 0.0, NUI_HALIGN_CENTER, NUI_VALIGN_MIDDLE);
    jCol = JsonArrayInsert(jCol, NuiRow(jRow));
    if(GetAssociate(ASSOCIATE_TYPE_HENCHMAN, oPC) != OBJECT_INVALID)
    {
        jRow = JsonArrayInsert(JsonArray(), NuiSpacer());
        jRow = CreateLabel(jRow, "You can still control your", "lbl_death_3", 175.00, 10.0, 0.0, NUI_HALIGN_CENTER, NUI_VALIGN_MIDDLE);
        jRow = JsonArrayInsert(jRow, NuiSpacer());
        jCol = JsonArrayInsert(jCol, NuiRow(jRow));
        jRow = JsonArrayInsert(JsonArray(), NuiSpacer());
        jRow = CreateLabel(jRow, "henchmen when dead.", "lbl_death_4", 175.00, 10.0, 0.0, NUI_HALIGN_CENTER, NUI_VALIGN_MIDDLE);
        jRow = JsonArrayInsert(jRow, NuiSpacer());
        jCol = JsonArrayInsert(jCol, NuiRow(jRow));
    }
    // Row 2 (buttons)********************************************************** 153
    jRow = JsonArrayInsert(JsonArray(), NuiSpacer());
    jRow = CreateButton(jRow, "Respawn", "btn_respawn", 100.0f, 25.0f);
    jRow = JsonArrayInsert(jRow, NuiSpacer());
    jCol = JsonArrayInsert(jCol, NuiRow(jRow));
    // Set the layout of the window.
    json jLayout = NuiCol(jCol);
    int nToken = SetWindow(oPC, jLayout, "pldeathpanel", "", -1.0, 0.0, 350.0 + 24.0, 100.0 + 90, FALSE, FALSE, FALSE, TRUE, FALSE);
    int nDeaths = GetObjectDatabaseInt(oPC, CHARACTER_TABLE, "deaths");
    string sMessage, sMessage2;
    if(nDeaths == 1)
    {
        sMessage = "You will lose hardcore";
        sMessage2 = "status if you respawn!";
    }
    else sMessage = "You have died " + IntToString(nDeaths) + " times!";
    NuiSetBind(oPC, nToken, "lbl_death_2_label", JsonString(sMessage));
    if(sMessage2 != "") NuiSetBind(oPC, nToken, "lbl_death_3_label", JsonString(sMessage2));
    NuiSetBind(oPC, nToken, "btn_respawn_event", JsonBool (TRUE));
}
void PopUpNewsPanel(object oPC)
{
    // Create Background image in the center of the window.
    json jPos = NuiRect(0.0, 0.0, 300.0, 200.0);
    json jLabel = NuiLabel(JsonString(""), JsonInt(NUI_HALIGN_LEFT), JsonInt(0));
    jLabel = NuiHeight(NuiWidth(jLabel, 700.0), 25.0);
    json jImage = JsonArrayInsert(JsonArray(), NuiDrawListImage(JsonBool(TRUE), JsonString("gui_saveproxy"), jPos, JsonInt(NUI_ASPECT_FIT), JsonInt(NUI_HALIGN_CENTER), JsonInt(NUI_VALIGN_MIDDLE)));
    json jRow = JsonArrayInsert(JsonArray(), NuiDrawList(jLabel, JsonBool(FALSE), jImage));
    jLabel = NuiLabel(JsonString(""), JsonInt(NUI_HALIGN_RIGHT), JsonInt(0));
    jPos = NuiRect(0.0, 0.0, 300.0, 200.0);
    jLabel = NuiHeight(NuiWidth(jLabel, 300.0), 25.0);
    jImage = JsonArrayInsert(JsonArray(), NuiDrawListImage(JsonBool(TRUE), JsonString("gui_saveproxy"), jPos, JsonInt(NUI_ASPECT_FIT), JsonInt(NUI_HALIGN_CENTER), JsonInt(NUI_VALIGN_MIDDLE)));
    jRow = JsonArrayInsert(jRow, NuiDrawList(jLabel, JsonBool(FALSE), jImage));
    json jCol = JsonArrayInsert(JsonArray(), NuiRow (jRow));
    // Row 1 (Message)********************************************************** 45
    jRow = JsonArrayInsert(JsonArray(), NuiSpacer());
    jRow = CreateLabel(jRow, "", "lbl_title", 975.00, 30.0, -1.0, NUI_HALIGN_CENTER, NUI_VALIGN_BOTTOM);
    jRow = JsonArrayInsert(jRow, NuiSpacer());
    jCol = JsonArrayInsert(jCol, NuiRow(jRow));
    jRow = CreateLabel(JsonArray(), "", "lbl_blank", 975.00, 5.0, 0.0, NUI_HALIGN_CENTER, NUI_VALIGN_MIDDLE);
    jCol = JsonArrayInsert(jCol, NuiRow(jRow));
    jRow = JsonArrayInsert(JsonArray(), NuiSpacer());
    jRow = CreateLabel(jRow, "", "lbl_build", 975.00, 10.0, 0.0, NUI_HALIGN_CENTER, NUI_VALIGN_MIDDLE);
    jRow = JsonArrayInsert(jRow, NuiSpacer());
    jCol = JsonArrayInsert(jCol, NuiRow(jRow));
    jRow = JsonArrayInsert(JsonArray(), NuiSpacer());
    jRow = CreateLabel(jRow, "", "lbl_contact", 975.00, 10.0, 0.0, NUI_HALIGN_CENTER, NUI_VALIGN_MIDDLE);
    jRow = JsonArrayInsert(jRow, NuiSpacer());
    jCol = JsonArrayInsert(jCol, NuiRow(jRow));
    jRow = CreateLabel(JsonArray(), "", "lbl_blank", 975.00, 5.0, 0.0, NUI_HALIGN_CENTER, NUI_VALIGN_MIDDLE);
    jCol = JsonArrayInsert(jCol, NuiRow(jRow));
    jRow = JsonArrayInsert(JsonArray(), NuiSpacer());
    jRow = CreateLabel(jRow, "", "lbl_news_1", 975.00, 10.0, 0.0, NUI_HALIGN_LEFT, NUI_VALIGN_MIDDLE);
    jRow = JsonArrayInsert(jRow, NuiSpacer());
    jCol = JsonArrayInsert(jCol, NuiRow(jRow));
    jRow = CreateLabel(JsonArray(), "", "lbl_blank", 975.00, 5.0, 0.0, NUI_HALIGN_CENTER, NUI_VALIGN_MIDDLE);
    jCol = JsonArrayInsert(jCol, NuiRow(jRow));
    jRow = JsonArrayInsert(JsonArray(), NuiSpacer());
    jRow = CreateLabel(jRow, "", "lbl_news_2", 975.00, 10.0, 0.0, NUI_HALIGN_LEFT, NUI_VALIGN_MIDDLE);
    jRow = JsonArrayInsert(jRow, NuiSpacer());
    jCol = JsonArrayInsert(jCol, NuiRow(jRow));
    jRow = JsonArrayInsert(JsonArray(), NuiSpacer());
    jRow = CreateLabel(jRow, "", "lbl_news_3", 975.00, 10.0, 0.0, NUI_HALIGN_LEFT, NUI_VALIGN_MIDDLE);
    jRow = JsonArrayInsert(jRow, NuiSpacer());
    jCol = JsonArrayInsert(jCol, NuiRow(jRow));
    jRow = JsonArrayInsert(JsonArray(), NuiSpacer());
    jRow = CreateLabel(jRow, "", "lbl_news_4", 975.00, 10.0, 0.0, NUI_HALIGN_LEFT, NUI_VALIGN_MIDDLE);
    jRow = JsonArrayInsert(jRow, NuiSpacer());
    jCol = JsonArrayInsert(jCol, NuiRow(jRow));
    jRow = JsonArrayInsert(JsonArray(), NuiSpacer());
    jRow = CreateLabel(jRow, "", "lbl_news_5", 975.00, 10.0, 0.0, NUI_HALIGN_LEFT, NUI_VALIGN_MIDDLE);
    jRow = JsonArrayInsert(jRow, NuiSpacer());
    jCol = JsonArrayInsert(jCol, NuiRow(jRow));
    // Row 2 (buttons)********************************************************** 153
    jRow = JsonArrayInsert(JsonArray(), NuiSpacer());
    jRow = CreateButton(jRow, "OK", "btn_ok", 50.0f, 25.0f);
    jRow = JsonArrayInsert(jRow, NuiSpacer());
    jCol = JsonArrayInsert(jCol, NuiRow(jRow));
    // Set the layout of the window.
    json jLayout = NuiCol(jCol);
    int nToken = SetWindow(oPC, jLayout, "plnewspanel", "NEWS", -1.0, 0.0, 1000.0 + 24.0, 350.0 + 24, FALSE, FALSE, TRUE, FALSE, TRUE);
    int nDeaths = GetObjectDatabaseInt(oPC, CHARACTER_TABLE, "deaths");
    string sMessage, sMessage2;
    // Title
    string sText = Get2DAString("Messages", "Text", 0);
    NuiSetBind(oPC, nToken, "lbl_title_label", JsonString(sText));
    // Build version
    sText = Get2DAString("Messages", "Text", 1);
    NuiSetBind(oPC, nToken, "lbl_build_label", JsonString(sText));
    // Server Message
    sText = Get2DAString("Messages", "Text", 2);
    NuiSetBind(oPC, nToken, "lbl_contact_label", JsonString(sText));
    // Main News Message
    sText = Get2DAString("Messages", "Text", 3);
    NuiSetBind(oPC, nToken, "lbl_news_1_label", JsonString(sText));
    // News Message 2
    sText = Get2DAString("Messages", "Text", 4);
    if(sText != "") NuiSetBind(oPC, nToken, "lbl_news_2_label", JsonString(sText));
    // News Message 3
    sText = Get2DAString("Messages", "Text", 5);
    if(sText != "") NuiSetBind(oPC, nToken, "lbl_news_3_label", JsonString(sText));
    // News Message 4
    sText = Get2DAString("Messages", "Text", 6);
    if(sText != "") NuiSetBind(oPC, nToken, "lbl_news_4_label", JsonString(sText));
    // News Message 5
    sText = Get2DAString("Messages", "Text", 7);
    if(sText != "") NuiSetBind(oPC, nToken, "lbl_news_5_label", JsonString(sText));
    NuiSetBind(oPC, nToken, "btn_ok_event", JsonBool (TRUE));
    SetLocalInt(oPC, "0_NEWS_SEEN", TRUE);
}


