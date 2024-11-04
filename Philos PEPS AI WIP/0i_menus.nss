/*//////////////////////////////////////////////////////////////////////////////
// Script Name: 0i_menus
////////////////////////////////////////////////////////////////////////////////
 Include script for handling NUI menus.
*///////////////////////////////////////////////////////////////////////////////
#include "0i_nui"
//#include "0i_associates"
#include "0i_assoc_debug"
// Use by NUI windows to stop saving move states while loading.
const string AI_NO_NUI_SAVE = "AI_NO_NUI_SAVE";
// Maximum number of Plugins allowed on the players widget.
const int WIDGET_MAX_PLUGINS = 5;

// Set one of the BTN_* "Widget" bitwise constants on oPlayer to bValid.
void ai_SetWidgetButton(object oPlayer, int nButton, object oAssociate, string sAssociateType, int bOn = TRUE);
// Return if nButton is set on oPlayer. Uses the BTN_* "Widget" bitwise constants.
int ai_GetWidgetButton(object oPlayer, int nButton, object oAssociate, string sAssociateType);
// Set one of the BTN_AI_*  bitwise constants on oPlayer to bValid.
void ai_SetAIButton(object oPlayer, int nButton, object oAssociate, string sAssociateType, int bOn = TRUE);
// Return if nButton is set on oPlayer. Uses the BTN_AI_* "Widget" bitwise constants.
int ai_GetAIButton(object oPlayer, int nButton, object oAssociate, string sAssociateType);
// Set one of the BTN2_AI_*  bitwise constants on oPlayer to bValid.
void ai_SetAIButton2(object oPlayer, int nButton, object oAssociate, string sAssociateType, int bOn = TRUE);
// Return if nButton is set on oPlayer. Uses the BTN2_AI_* "Widget" bitwise constants.
int ai_GetAIButton2(object oPlayer, int nButton, object oAssociate, string sAssociateType);
// Creates the AI options menu.
void ai_CreateAIOptionsNUI(object oPC);
// Creates the AI options menu.
void ai_CreateAssociateCommandNUI(object oPC, object oAssociate);
// Creates an associates AI NUI.
//void ai_CreateAssociateAINUI(object oPC, object oAssociate);
// Creates the AI Widget.
void ai_CreateAIWidgetNUI(object oPC);
// Creates the Loot filter menu.
void ai_CreateLootFilterNUI(object oPC, object oAssociate);

void ai_SetWidgetButton(object oPlayer, int nButton, object oAssociate, string sAssociateType, int bOn = TRUE)
{
    int nWidgetButtons = GetLocalInt(oAssociate, sWidgetButtonsVarname);
    json jButtons = ai_GetAssociateDbJson(oPlayer, sAssociateType, "buttons");
    if(nWidgetButtons == 0) nWidgetButtons = JsonGetInt(JsonArrayGet(jButtons, 0));
    if(bOn) nWidgetButtons = nWidgetButtons | nButton;
    else nWidgetButtons = nWidgetButtons & ~nButton;
    SetLocalInt(oAssociate, sWidgetButtonsVarname, nWidgetButtons);
    JsonArraySetInplace(jButtons, 0, JsonInt(nWidgetButtons));
    ai_SetAssociateDbJson(oPlayer, sAssociateType, "buttons", jButtons);
}
int ai_GetWidgetButton(object oPlayer, int nButton, object oAssociate, string sAssociateType)
{
    int nWidgetButtons = GetLocalInt(oAssociate, sWidgetButtonsVarname);
    if(nWidgetButtons == 0)
    {
        json jButtons = ai_GetAssociateDbJson(oPlayer, sAssociateType, "buttons");
        nWidgetButtons = JsonGetInt(JsonArrayGet(jButtons, 0));
    }
    return nWidgetButtons & nButton;
}
void ai_SetAIButton(object oPlayer, int nButton, object oAssociate, string sAssociateType, int bOn = TRUE)
{
    int nAIButtons = GetLocalInt(oAssociate, sAIButtonsVarname);
    json jButtons = ai_GetAssociateDbJson(oPlayer, sAssociateType, "buttons");
    if(nAIButtons == 0) nAIButtons = JsonGetInt(JsonArrayGet(jButtons, 1));
    if(bOn) nAIButtons = nAIButtons | nButton;
    else nAIButtons = nAIButtons & ~nButton;
    SetLocalInt(oAssociate, sAIButtonsVarname, nAIButtons);
    JsonArraySetInplace(jButtons, 1, JsonInt(nAIButtons));
    ai_SetAssociateDbJson(oPlayer, sAssociateType, "buttons", jButtons);
}
int ai_GetAIButton(object oPlayer, int nButton, object oAssociate, string sAssociateType)
{
    int nAIButtons = GetLocalInt(oAssociate, sAIButtonsVarname);
    if(nAIButtons == 0)
    {
        json jButtons = ai_GetAssociateDbJson(oPlayer, sAssociateType, "buttons");
        nAIButtons = JsonGetInt(JsonArrayGet(jButtons, 1));
    }
    return nAIButtons & nButton;
}
void ai_SetAIButton2(object oPlayer, int nButton, object oAssociate, string sAssociateType, int bOn = TRUE)
{
    int bCreateButtons;
    int nAIButtons = GetLocalInt(oAssociate, sAIButtons2Varname);
    json jButtons = ai_GetAssociateDbJson(oPlayer, sAssociateType, "buttons");
    //ai_Debug("0i_menus", "84", "jButtons: " + JsonDump(jButtons));
    json jButton2 = JsonArrayGet(jButtons, 2);
    // *************************************************************************
    // This should be removed at a later date once we are past not having this button.
    // *************************************************************************
    if(JsonGetType(jButton2) == JSON_TYPE_NULL)
    {
        bCreateButtons = TRUE;
        jButton2 = JsonArray();
    }
    if(nAIButtons == 0) nAIButtons = JsonGetInt(jButton2);
    if(bOn) nAIButtons = nAIButtons | nButton;
    else nAIButtons = nAIButtons & ~nButton;
    SetLocalInt(oAssociate, sAIButtons2Varname, nAIButtons);
    if(bCreateButtons) JsonArrayInsertInplace(jButtons, JsonInt(nAIButtons));
    else JsonArraySetInplace(jButtons, 2, JsonInt(nAIButtons));
    //ai_Debug("0i_menus", "96", "jButtons: " + JsonDump(jButtons));
    ai_SetAssociateDbJson(oPlayer, sAssociateType, "buttons", jButtons);
}
int ai_GetAIButton2(object oPlayer, int nButton, object oAssociate, string sAssociateType)
{
    int nAIButtons = GetLocalInt(oAssociate, sAIButtons2Varname);
    if(nAIButtons == 0)
    {
        json jButtons = ai_GetAssociateDbJson(oPlayer, sAssociateType, "buttons");
        nAIButtons = JsonGetInt(JsonArrayGet(jButtons, 2));
    }
    return nAIButtons & nButton;
}
void ai_SetupHenchmanButton(object oPlayer, int nToken, int nIndex)
{
    string sName, sHenchman = "henchman" + IntToString(nIndex);
    int bWidgetOn = !ai_GetWidgetButton(oPlayer, BTN_WIDGET_OFF, OBJECT_INVALID, sHenchman);
    NuiSetBind(oPlayer, nToken, "btn_" + sHenchman + "_widget", JsonBool (bWidgetOn));
    object oHenchman = GetAssociate(ASSOCIATE_TYPE_HENCHMAN, oPlayer, nIndex);
    if(oHenchman != OBJECT_INVALID)
    {
        sName = GetName(oHenchman);
        if(GetStringLength(sName) > 13) sName = GetStringLeft(sName, 13);
    }
    else sName = "Empty";
    NuiSetBind(oPlayer, nToken, "btn_" + sHenchman + "_widget_label", JsonString(sName + " Widget"));
    NuiSetBind(oPlayer, nToken, "btn_" + sHenchman + "_widget_event", JsonBool(TRUE));
}
void ai_CreateAIOptionsNUI(object oPC)
{
    string sText;
    // Set window to not save until it has been created.
    //SetLocalInt (oPC, AI_NO_NUI_SAVE, TRUE);
    //DelayCommand (0.5f, DeleteLocalInt (oPC, AI_NO_NUI_SAVE));
    // ************************************************************************* Width / Height
    // Row 1 ******************************************************************* 482 / 73
    json jRow = JsonArray();
    JsonArrayInsertInplace(jRow, NuiSpacer());
    CreateLabel(jRow, PHILOS_VERSION, "lbl_version", 400.0f, 20.0f, NUI_HALIGN_CENTER);
    JsonArrayInsertInplace(jRow, NuiSpacer());
    // Add row to the column.
    json jCol = JsonArray();
    JsonArrayInsertInplace(jCol, NuiRow(jRow));
    // Row 2 ******************************************************************* 482 / 129
    jRow = JsonArray();
    CreateLabel(jRow, "Max Henchman:", "lbl_max_hench", 110.0f, 20.0f);
    CreateTextEditBox(jRow, "sPlaceHolder", "txt_max_henchman", 1, FALSE, 30.0f, 20.0f, "txt_max_henchman_tooltip");
    JsonArrayInsertInplace(jRow, NuiSpacer());
    CreateButtonSelect(jRow, "Associate Widgets", "btn_toggle_assoc_widget", 150.0f, 20.0f, "btn_assoc_widget_tooltip");
    JsonArrayInsertInplace(jRow, NuiSpacer());
    CreateButtonSelect(jRow, "Ghost Mode", "btn_ghost_mode", 150.0f, 20.0f, "btn_ghost_mode_tooltip");
    // Add row to the column.
    JsonArrayInsertInplace(jCol, NuiRow(jRow));
    // Row 3 ******************************************************************* 482 / 101
    jRow = JsonArray();
    CreateLabel(jRow, "Debug Creature:", "lbl_debug_creature", 120.0f, 20.0f);
    CreateTextEditBox(jRow, "sPlaceHolder", "txt_debug_creature", 40, FALSE, 340.0f, 20.0f, "txt_debug_creature_tooltip");
    // Add row to the column.
    JsonArrayInsertInplace(jCol, NuiRow(jRow));
    // Row 4 ******************************************************************* 482 / 129
    jRow = JsonArray();
    JsonArrayInsertInplace(jRow, NuiSpacer());
    if(ResManGetAliasFor("0e_c2_1_hb", RESTYPE_NCS) == "") sText = "Monsters are not using Philos' AI.";
    else sText = "Monsters are using Philos' AI!";
    CreateLabel(jRow, sText, "monster_ai", 400.0f, 20.0f, NUI_HALIGN_CENTER);
    JsonArrayInsertInplace(jRow, NuiSpacer());
    // Add row to the column.
    JsonArrayInsertInplace(jCol, NuiRow(jRow));
    // Row 5 ******************************************************************* 482 / 157
    jRow = JsonArray();
    JsonArrayInsertInplace(jRow, NuiSpacer());
    CreateLabel(jRow, "AI RULES", "lbl_ai_rules", 80.0f, 20.0f, NUI_HALIGN_CENTER);
    JsonArrayInsertInplace(jRow, NuiSpacer());
    // Add row to the column.
    JsonArrayInsertInplace(jCol, NuiRow(jRow));
    // Row 6 ******************************************************************* 482 / 417
    jRow = JsonArray();
    // Make the AI options a Group.
    json jGroupRow = JsonArray();
    json jGroupCol = JsonArray();
    CreateTextEditBox(jGroupRow, "sPlaceHolder", "txt_ai_difficulty", 3, FALSE, 35.0f, 20.0f, "txt_ai_difficulty_tooltip");
    CreateLabel(jGroupRow, " Chance monster AI attacks the weakest target.", "lbl_ai_difficulty", 330.0f, 20.0f, 0, 0, 0.0, "txt_ai_difficulty_tooltip");
    JsonArrayInsertInplace(jGroupCol, NuiRow(jGroupRow));
    jGroupRow = JsonArray();
    CreateCheckBox(jGroupRow, " Moral checks, wounded AI creatures may flee from combat", "chbx_moral", 450.0, 20.0);
    JsonArrayInsertInplace(jGroupCol, NuiRow(jGroupRow));
    jGroupRow = JsonArray();
    CreateCheckBox(jGroupRow, " Allow AI monsters to prebuff before combat starts", "chbx_buff_monsters", 450.0, 20.0);
    JsonArrayInsertInplace(jGroupCol, NuiRow(jGroupRow));
    jGroupRow = JsonArray();
    CreateCheckBox(jGroupRow, " Allow AI monsters to summon before combat starts", "chbx_buff_summons", 450.0, 20.0);
    JsonArrayInsertInplace(jGroupCol, NuiRow(jGroupRow));
    jGroupRow = JsonArray();
    CreateCheckBox(jGroupRow, " Summoned associates to remain after masters death.", "chbx_perm_assoc", 450.0, 20.0);
    JsonArrayInsertInplace(jGroupCol, NuiRow(jGroupRow));
    jGroupRow = JsonArray();
    CreateCheckBox(jGroupRow, " Use advanced AI movement during combat", "chbx_advanced_movement", 450.0, 20.0);
    JsonArrayInsertInplace(jGroupCol, NuiRow(jGroupRow));
    jGroupRow = JsonArray();
    CreateCheckBox(jGroupRow, " Item Level Restrictions for AI creatures. This defaults to off!", "chbx_ilr", 450.0, 20.0);
    JsonArrayInsertInplace(jGroupCol, NuiRow(jGroupRow));
    jGroupRow = JsonArray();
    CreateCheckBox(jGroupRow, " Allow AI to use Use Magic Device.", "chbx_umd", 450.0, 20.0);
    JsonArrayInsertInplace(jGroupCol, NuiRow(jGroupRow));
    jGroupRow = JsonArray();
    CreateCheckBox(jGroupRow, " Allow AI to use Healing kits.", "chbx_use_healingkits", 450.0, 20.0);
    JsonArrayInsertInplace(jGroupCol, NuiRow(jGroupRow));
    jGroupRow = JsonArray();
    CreateTextEditBox(jGroupRow, "sPlaceHolder", "txt_perception_distance", 2, FALSE, 35.0f, 20.0f, "txt_perception_distance_tooltip");
    CreateLabel(jGroupRow, " meters distance a monster can perceive the player.", "lbl_perception_distance", 355.0f, 20.0f, 0, 0, 0.0, "txt_perception_distance_tooltip");
    JsonArrayInsertInplace(jGroupCol, NuiRow(jGroupRow));
    JsonArrayInsertInplace(jRow, NuiGroup(NuiCol(jGroupCol)));
    // Add row to the column.
    JsonArrayInsertInplace(jCol, NuiRow(jRow));
    // Row 7 ******************************************************************* 482 / 445
    jRow = JsonArray();
    JsonArrayInsertInplace(jRow, NuiSpacer());
    CreateButton(jRow, "Add Plugin", "btn_add_plugin", 230.0f, 20.0f);
    JsonArrayInsertInplace(jRow, NuiSpacer());
    CreateTextEditBox(jRow, "sPlaceHolder", "txt_plugin", 16, FALSE, 230.0f, 20.0f, "txt_plugin_tooltip");
    JsonArrayInsertInplace(jRow, NuiSpacer());
    // Add row to the column.
    JsonArrayInsertInplace(jCol, NuiRow(jRow));
    float fHeight = 445.0;
    // Row 8+ ******************************************************************* 482 /
    int nIndex;
    string sIndex;
    json jPlugins = ai_GetAssociateDbJson(oPC, "pc", "plugins");
    json jScript = JsonArrayGet(jPlugins, nIndex);
    while(JsonGetType(jScript) != JSON_TYPE_NULL)
    {
        sIndex = IntToString(nIndex + 1);
        jRow = JsonArray();
        JsonArrayInsertInplace(jRow, NuiSpacer());
        CreateButton(jRow, "Remove Plugin", "btn_remove_plugin_" + sIndex, 230.0f, 20.0f);
        JsonArrayInsertInplace(jRow, NuiSpacer());
        CreateLabel(jRow, JsonGetString(jScript), "txt_plugin_" + sIndex, 230.0f, 20.0f);
        JsonArrayInsertInplace(jRow, NuiSpacer());
        // Add row to the column.
        JsonArrayInsertInplace(jCol, NuiRow(jRow));
        fHeight += 28.0;
        jScript = JsonArrayGet(jPlugins, ++nIndex);
    }
    // Set the Layout of the window.
    json jLayout = NuiCol(jCol);
    string sName = GetName(oPC);
    if(GetStringRight(sName, 1) == "s") sName = sName + "'";
    else sName = sName + "'s";
    int nToken = SetWindow(oPC, jLayout, "ai_main_nui", sName + " PEPS Main Menu",
                             -1.0, -1.0, 482.0f, fHeight + 12.0f, FALSE, FALSE, TRUE, FALSE, TRUE, "0e_nui");
    // Save the associate to the nui for use in 0e_nui
    json jData = JsonArray();
    JsonArrayInsertInplace(jData, JsonString(ObjectToString(oPC)));
    NuiSetUserData(oPC, nToken, jData);
    // Set all binds, events, and watches.
    // Row 1 - Version label.
    // Row 2
    NuiSetBind(oPC, nToken, "txt_max_henchman", JsonString(IntToString(GetMaxHenchmen())));
    NuiSetBindWatch (oPC, nToken, "txt_max_henchman", TRUE);
    NuiSetBind(oPC, nToken, "txt_max_henchman_tooltip", JsonString("  Set max number of henchman allowed (1-6)."));
    if(ResManGetAliasFor("0e_ch_1_hb", RESTYPE_NCS) != "")
    {
        NuiSetBind(oPC, nToken, "btn_toggle_assoc_widget_event", JsonBool(TRUE));
        int bWidgetOn = !ai_GetWidgetButton(oPC, BTN_WIDGET_OFF, OBJECT_INVALID, "pc");
        NuiSetBind(oPC, nToken, "btn_toggle_assoc_widget", JsonBool(bWidgetOn));
        NuiSetBind(oPC, nToken, "btn_assoc_widget_tooltip", JsonString("  Turns On/Off all associate widgets."));
    }
    int bGhostMode = ai_GetAIMode(oPC, AI_MODE_GHOST);
    NuiSetBind(oPC, nToken, "btn_ghost_mode", JsonBool (bGhostMode));
    NuiSetBind(oPC, nToken, "btn_ghost_mode_event", JsonBool(TRUE));
    NuiSetBind(oPC, nToken, "btn_ghost_mode_tooltip", JsonString("  Allows associates to move through creatures while in command mode."));
    // Row 3
    object oModule = GetModule();
    NuiSetBind(oPC, nToken, "txt_debug_creature", JsonString(GetLocalString(oModule, AI_RULE_DEBUG_CREATURE)));
    NuiSetBindWatch (oPC, nToken, "txt_debug_creature", TRUE);
    NuiSetBind(oPC, nToken, "txt_debug_creature_tooltip", JsonString("  Enter creature name to set debug mode for a creature (See Log file for data)."));
    // Row 4 Label showing if monster AI is in use.
    // Row 5 Label for AI RULES
    // Row 6
    NuiSetBind(oPC, nToken, "txt_ai_difficulty", JsonString(IntToString(GetLocalInt(oModule, AI_RULE_AI_DIFFICULTY))));
    NuiSetBindWatch (oPC, nToken, "txt_ai_difficulty", TRUE);
    NuiSetBind(oPC, nToken, "txt_ai_difficulty_tooltip", JsonString("  This is a percentage from 0 to 100."));
    NuiSetBind(oPC, nToken, "chbx_moral_check", JsonBool(GetLocalInt(oModule, AI_RULE_MORAL_CHECKS)));
    NuiSetBindWatch (oPC, nToken, "chbx_moral_check", TRUE);
    NuiSetBind(oPC, nToken, "chbx_buff_monsters_check", JsonBool(GetLocalInt(oModule, AI_RULE_BUFF_MONSTERS)));
    NuiSetBindWatch (oPC, nToken, "chbx_buff_monsters_check", TRUE);
    NuiSetBind(oPC, nToken, "chbx_buff_summons_check", JsonBool(GetLocalInt(oModule, AI_RULE_PRESUMMON)));
    NuiSetBindWatch (oPC, nToken, "chbx_buff_summons_check", TRUE);
    NuiSetBind(oPC, nToken, "chbx_perm_assoc_check", JsonBool(GetLocalInt(oModule, AI_RULE_PERM_ASSOC)));
    NuiSetBindWatch (oPC, nToken, "chbx_perm_assoc_check", TRUE);
    NuiSetBind(oPC, nToken, "chbx_advanced_movement_check", JsonBool(GetLocalInt(oModule, AI_RULE_ADVANCED_MOVEMENT)));
    NuiSetBindWatch (oPC, nToken, "chbx_advanced_movement_check", TRUE);
    NuiSetBind(oPC, nToken, "chbx_ilr_check", JsonBool(GetLocalInt(oModule, AI_RULE_ILR)));
    NuiSetBindWatch (oPC, nToken, "chbx_ilr_check", TRUE);
    NuiSetBind(oPC, nToken, "chbx_umd_check", JsonBool(GetLocalInt(oModule, AI_RULE_ALLOW_UMD)));
    NuiSetBindWatch (oPC, nToken, "chbx_umd_check", TRUE);
    NuiSetBind(oPC, nToken, "chbx_use_healingkits_check", JsonBool(GetLocalInt(oModule, AI_RULE_HEALERSKITS)));
    NuiSetBindWatch (oPC, nToken, "chbx_use_healingkits_check", TRUE);
    NuiSetBind(oPC, nToken, "txt_perception_distance", JsonString(FloatToString(GetLocalFloat(oModule, AI_RULE_PERCEPTION_DISTANCE), 0, 0)));
    NuiSetBindWatch (oPC, nToken, "txt_perception_distance", TRUE);
    NuiSetBind(oPC, nToken, "txt_perception_distance_tooltip", JsonString("  Distance can be 10 meters to 40 meters."));
    // Row 7
    NuiSetBind(oPC, nToken, "btn_add_plugin_event", JsonBool(TRUE));
    NuiSetBind(oPC, nToken, "txt_plugin_event", JsonBool(TRUE));
    NuiSetBind(oPC, nToken, "txt_plugin_tooltip", JsonString("  Enter a plugin file name that is in the override folder."));
    // Row 8+
    nIndex = 0;
    jScript = JsonArrayGet(jPlugins, nIndex);
    while(JsonGetType(jScript) != JSON_TYPE_NULL)
    {
        sIndex = IntToString(nIndex + 1);
        NuiSetBind(oPC, nToken, "btn_remove_plugin_" + sIndex + "_event", JsonBool(TRUE));
        jScript = JsonArrayGet(jPlugins, ++nIndex);
    }
}
void ai_CreateAssociateCommandNUI(object oPC, object oAssociate)
{
    // ************************************************************************* Width / Height
    int bIsPC = ai_GetIsCharacter(oAssociate);
    int bUsingPCAI = ResManGetAliasFor("xx_pc_1_hb", RESTYPE_NCS) != "";
    // Row 1 ******************************************************************* 388 / 73
    json jRow = JsonArray();
    CreateButtonSelect(jRow, "Lock Widget", "btn_widget_lock", 150.0, 20.0, "btn_widget_lock_tooltip");
    CreateLabel(jRow, "", "blank_label_1", 25.0, 20.0);
    JsonArrayInsertInplace(jRow, NuiSpacer());
    if(bIsPC) CreateButton(jRow, "Main Options", "btn_options", 150.0, 20.0, -1.0, "btn_options_tooltip");
    else CreateButtonSelect(jRow, "", "btn_options", 150.0, 20.0, "btn_options_tooltip");
    CreateLabel(jRow, "", "blank_label_2", 25.0, 20.0);
    json jCol = JsonArray();
    JsonArrayInsertInplace(jCol, NuiRow(jRow));
    // Row 2 ******************************************************************* 388 / 101
    jRow = JsonArray();
    CreateButton(jRow, "AI Options", "btn_ai_options", 150.0, 20.0, -1.0, "btn_ai_options_tooltip");
    CreateLabel(jRow, "", "blank_label_2", 25.0, 20.0);
    JsonArrayInsertInplace(jRow, NuiSpacer());
    CreateButton(jRow, "Copy Settings", "btn_copy_settings", 150.0, 20.0, -1.0, "btn_copy_settings_tooltip");
    CreateLabel(jRow, "", "blank_label_2", 25.0, 20.0);
    JsonArrayInsertInplace(jCol, NuiRow(jRow));
    // Row 3 ******************************************************************* 388 / 129
    jRow = JsonArray();
    CreateButton(jRow, "", "btn_cmd_action", 150.0, 20.0, -1.0, "btn_cmd_action_tooltip");
    CreateCheckBox(jRow, "", "chbx_cmd_action", 25.0, 20.0);
    JsonArrayInsertInplace(jRow, NuiSpacer());
    CreateButton(jRow, "", "btn_cmd_guard", 150.0, 20.0, -1.0, "btn_cmd_guard_tooltip");
    CreateCheckBox(jRow, "", "chbx_cmd_guard", 25.0, 20.0);
    JsonArrayInsertInplace(jCol, NuiRow(jRow));
    // Row 4 ******************************************************************* 388 / 157
    jRow = JsonArray();
    CreateButton(jRow, "", "btn_cmd_hold", 150.0, 20.0, -1.0, "btn_cmd_hold_tooltip");
    CreateCheckBox(jRow, "", "chbx_cmd_hold", 25.0, 20.0);
    JsonArrayInsertInplace(jRow, NuiSpacer());
    CreateButton(jRow, "", "btn_cmd_attack", 150.0, 20.0, -1.0, "btn_cmd_attack_tooltip");
    CreateCheckBox(jRow, "", "chbx_cmd_attack", 25.0, 20.0);
    JsonArrayInsertInplace(jCol, NuiRow(jRow));
    // Row 5 ******************************************************************* 388 / 185
    jRow = JsonArray();
    CreateButton(jRow, "", "btn_cmd_follow", 150.0, 20.0, -1.0, "btn_cmd_follow_tooltip");
    CreateCheckBox(jRow, "", "chbx_cmd_follow", 25.0, 20.0);
    JsonArrayInsertInplace(jRow, NuiSpacer());
    CreateButton(jRow, "Follow Target", "btn_follow_target", 150.0, 20.0, -1.0, "btn_follow_target_tooltip");
    CreateCheckBox(jRow, "", "chbx_follow_target", 25.0, 20.0);
    // Add row to the column.
    JsonArrayInsertInplace(jCol, NuiRow(jRow));
    // Row 6 ******************************************************************* 388 / 213
    jRow = JsonArray();
    CreateButton(jRow, "Combat Tactics", "btn_cmd_ai_script", 150.0, 20.0, -1.0, "btn_cmd_ai_script_tooltip");
    CreateCheckBox(jRow, "", "chbx_cmd_ai_script", 25.0, 20.0);
    JsonArrayInsertInplace(jRow, NuiSpacer());
    CreateButton(jRow, "Place Trap", "btn_cmd_place_trap", 150.0, 20.0, -1.0, "btn_cmd_place_trap_tooltip");
    CreateCheckBox(jRow, "", "chbx_cmd_place_trap", 25.0, 20.0);
    // Add row to the column.
    JsonArrayInsertInplace(jCol, NuiRow(jRow));
    // Row 7 ******************************************************************* 388 / 241
    jRow = JsonArray();
    CreateButton(jRow, "Cast Short Buffs", "btn_buff_short", 150.0, 20.0, -1.0, "btn_buff_short_tooltip");
    CreateCheckBox(jRow, "", "chbx_buff_short", 25.0, 20.0);
    JsonArrayInsertInplace(jRow, NuiSpacer());
    CreateButton(jRow, "Cast Long Buffs", "btn_buff_long", 150.0, 20.0, -1.0, "btn_buff_long_tooltip");
    CreateCheckBox(jRow, "", "chbx_buff_long", 25.0, 20.0);
    // Add row to the column.
    JsonArrayInsertInplace(jCol, NuiRow(jRow));
    // Row 8 ******************************************************************* 388 / 269
    jRow = JsonArray();
    CreateButton(jRow, "Cast All Buffs", "btn_buff_all", 150.0, 20.0, -1.0, "btn_buff_all_tooltip");
    CreateCheckBox(jRow, "", "chbx_buff_all", 25.0, 20.0);
    JsonArrayInsertInplace(jRow, NuiSpacer());
    CreateButton(jRow, "Resting Buffs", "btn_buff_rest", 150.0, 20.0, -1.0, "btn_buff_rest_tooltip");
    CreateCheckBox(jRow, "", "chbx_buff_rest", 25.0, 20.0);
    // Add row to the column.
    JsonArrayInsertInplace(jCol, NuiRow(jRow));
    float fHeight = 269.0;
    // Set the Layout of the window.
    json jLayout = NuiCol(jCol);
    string sText, sName = GetName(oAssociate);
    if(GetStringRight(sName, 1) == "s") sName = sName + "'";
    else sName = sName + "'s";
    string sAssociateType = ai_GetAssociateType(oPC, oAssociate);
    int nToken = SetWindow(oPC, jLayout, sAssociateType + "_cmd_menu", sName + " Command Menu",
                           -1.0, -1.0, 388.0, fHeight + 12.0, FALSE, FALSE, TRUE, FALSE, TRUE, "0e_nui");
    // Get which buttons are activated.
    int bAIWidgetLock = ai_GetWidgetButton(oPC, BTN_WIDGET_LOCK, oAssociate, sAssociateType);
    int bCmdAction = ai_GetWidgetButton(oPC, BTN_CMD_ACTION, oAssociate, sAssociateType);
    int bCmdGuard = ai_GetWidgetButton(oPC, BTN_CMD_GUARD, oAssociate, sAssociateType);
    int bCmdHold = ai_GetWidgetButton(oPC, BTN_CMD_HOLD, oAssociate, sAssociateType);
    int bCmdAttack = ai_GetWidgetButton(oPC, BTN_CMD_ATTACK, oAssociate, sAssociateType);
    int bCmdFollow = ai_GetWidgetButton(oPC, BTN_CMD_FOLLOW, oAssociate, sAssociateType);
    int bFollowTarget = ai_GetAIButton(oPC, BTN_AI_FOLLOW_TARGET, oAssociate, sAssociateType);
    int bCmdAIScript = ai_GetWidgetButton(oPC, BTN_CMD_AI_SCRIPT, oAssociate, sAssociateType);
    int bCmdPlacetrap = ai_GetWidgetButton(oPC, BTN_CMD_PLACE_TRAP, oAssociate, sAssociateType);
    int bBuffRest = ai_GetWidgetButton(oPC, BTN_BUFF_REST, oAssociate, sAssociateType);
    int bBuffShort = ai_GetWidgetButton(oPC, BTN_BUFF_SHORT, oAssociate, sAssociateType);
    int bBuffLong = ai_GetWidgetButton(oPC, BTN_BUFF_LONG, oAssociate, sAssociateType);
    int bBuffAll = ai_GetWidgetButton(oPC, BTN_BUFF_ALL, oAssociate, sAssociateType);
    // Save the associate to the nui for use in 0e_nui
    json jData = JsonArray();
    JsonArrayInsertInplace(jData, JsonString(ObjectToString(oAssociate)));
    NuiSetUserData(oPC, nToken, jData);
    // Set all binds, events, and watches.
    // Row 1
    NuiSetBind(oPC, nToken, "btn_widget_lock_event", JsonBool(TRUE));
    NuiSetBind(oPC, nToken, "btn_widget_lock", JsonBool(bAIWidgetLock));
    NuiSetBind(oPC, nToken, "btn_widget_lock_tooltip", JsonString(
               "  Locks widget to the current location."));
    NuiSetBind(oPC, nToken, "btn_options_event", JsonBool (TRUE));
    NuiSetBind(oPC, nToken, "btn_options", JsonInt(TRUE));
    if(bIsPC) NuiSetBind(oPC, nToken, "btn_options_tooltip", JsonString("  Additional options"));
    else
    {
        string sText, sText2;
        if(ai_GetAIButton(oPC, BTN_WIDGET_OFF, oAssociate, sAssociateType))
        {
            NuiSetBind(oPC, nToken, "btn_options", JsonBool(FALSE));
            sText = "off"; sText2 = "on";
        }
        else
        {
            NuiSetBind(oPC, nToken, "btn_options", JsonBool(TRUE));
            sText = "on"; sText2 = "off";
        }
        NuiSetBind(oPC, nToken, "btn_options_label", JsonString("Widget On/Off"));
        NuiSetBind(oPC, nToken, "btn_options_tooltip", JsonString(
                  "  Turn " + sName + " widget " + sText2));
    }
    // Only activate these if we are using PC AI or if this is not a PC.
    if(bUsingPCAI || !bIsPC)
    {
        NuiSetBind(oPC, nToken, "btn_ai_options_event", JsonBool (TRUE));
        NuiSetBind(oPC, nToken, "btn_ai_options", JsonInt(TRUE));
        NuiSetBind(oPC, nToken, "btn_copy_settings_event", JsonBool (TRUE));
        NuiSetBind(oPC, nToken, "btn_copy_settings", JsonInt(TRUE));
        sText = "  Copy AI and command settings for one creature to others.";
        NuiSetBind(oPC, nToken, "btn_copy_settings_tooltip", JsonString(sText));
    }
    // Row 3
    NuiSetBind(oPC, nToken, "chbx_cmd_action_check", JsonBool (bCmdAction));
    NuiSetBindWatch (oPC, nToken, "chbx_cmd_action_check", TRUE);
    NuiSetBind(oPC, nToken, "btn_cmd_action_event", JsonBool (TRUE));
    NuiSetBind(oPC, nToken, "chbx_cmd_guard_check", JsonBool (bCmdGuard));
    NuiSetBindWatch (oPC, nToken, "chbx_cmd_guard_check", TRUE);
    NuiSetBind(oPC, nToken, "btn_cmd_guard_event", JsonBool (TRUE));
    // Row 4
    NuiSetBind(oPC, nToken, "chbx_cmd_hold_check", JsonBool (bCmdHold));
    NuiSetBindWatch (oPC, nToken, "chbx_cmd_hold_check", TRUE);
    NuiSetBind(oPC, nToken, "btn_cmd_hold_event", JsonBool (TRUE));
    NuiSetBind(oPC, nToken, "chbx_cmd_attack_check", JsonBool (bCmdAttack));
    NuiSetBindWatch (oPC, nToken, "chbx_cmd_attack_check", TRUE);
    NuiSetBind(oPC, nToken, "btn_cmd_attack_event", JsonBool (TRUE));
    // Row 5
    NuiSetBind(oPC, nToken, "chbx_cmd_follow_check", JsonBool (bCmdFollow));
    NuiSetBindWatch (oPC, nToken, "chbx_cmd_follow_check", TRUE);
    NuiSetBind(oPC, nToken, "btn_cmd_follow_event", JsonBool (TRUE));
    // Only activate these if we are using PC AI or if this is not a PC.
    if(bUsingPCAI || !bIsPC)
    {
        NuiSetBind(oPC, nToken, "chbx_follow_target_check", JsonBool (bFollowTarget));
        NuiSetBindWatch (oPC, nToken, "chbx_follow_target_check", TRUE);
        NuiSetBind(oPC, nToken, "btn_follow_target_event", JsonBool (TRUE));
    }
    // Command labels
    if(bIsPC) sText = "  All ";
    else sText = "  ";
    NuiSetBind(oPC, nToken, "btn_cmd_action_label", JsonString(sText + "Action Mode"));
    NuiSetBind(oPC, nToken, "btn_cmd_guard_label", JsonString(sText + "Guard"));
    NuiSetBind(oPC, nToken, "btn_cmd_hold_label", JsonString(sText + "Stand Ground"));
    NuiSetBind(oPC, nToken, "btn_cmd_attack_label", JsonString(sText + "Normal Mode"));
    NuiSetBind(oPC, nToken, "btn_cmd_follow_label", JsonString(sText + "Follow"));
    NuiSetBind(oPC, nToken, "btn_follow_target_label", JsonString("  Follow Target"));
    if(bIsPC) sText = "  All associates";
    else sText = "  " + GetName(oAssociate);
    NuiSetBind(oPC, nToken, "btn_cmd_action_tooltip", JsonString(sText + " enter action mode"));
    NuiSetBind(oPC, nToken, "btn_cmd_guard_tooltip", JsonString(sText + " guard me"));
    NuiSetBind(oPC, nToken, "btn_cmd_hold_tooltip", JsonString(sText + " stand ground"));
    NuiSetBind(oPC, nToken, "btn_cmd_attack_tooltip", JsonString(sText + " enter normal mode"));
    NuiSetBind(oPC, nToken, "btn_cmd_follow_tooltip", JsonString(sText + " follow"));
    object oTarget = GetLocalObject(oAssociate, AI_FOLLOW_TARGET);
    string sTarget;
    if(oTarget != OBJECT_INVALID) sTarget = GetName(oTarget);
    else
    {
        if(ai_GetIsCharacter(oAssociate)) sTarget = "nobody";
        else sTarget = GetName(oPC);
    }
    NuiSetBind(oPC, nToken, "btn_follow_target_tooltip", JsonString("  " + GetName(oAssociate) + " following " + sTarget));
    // Row 6
    NuiSetBind(oPC, nToken, "chbx_cmd_ai_script_check", JsonBool (bCmdAIScript));
    NuiSetBindWatch (oPC, nToken, "chbx_cmd_ai_script_check", TRUE);
    NuiSetBind(oPC, nToken, "btn_cmd_ai_script_event", JsonBool (TRUE));
    sText = "  Using normal tactics";
    if(ResManGetAliasFor("0e_ch_1_hb", RESTYPE_NCS) != "")
    {
        string sScript = GetLocalString(oAssociate, AI_COMBAT_SCRIPT);
        if(sScript == "ai_a_ambusher") sText = "  Using ambush tactics";
        else if(sScript == "ai_a_peaceful") sText = "  Using peaceful tactics";
        else if(sScript == "ai_a_defensive") sText = "  Using defensive tactics";
        else if(sScript == "ai_a_ranged") sText = "  Using ranged tactics";
        else if(sScript == "ai_a_cntrspell") sText = "  Using counter spell tactics";
    }
    else
    {
        if(GetCombatCondition(X0_COMBAT_FLAG_AMBUSHER, oAssociate)) sText = "Using ambush tactics";
        else if(GetCombatCondition(X0_COMBAT_FLAG_COWARDLY, oAssociate)) sText = "Using coward tactics";
        else if(GetCombatCondition(X0_COMBAT_FLAG_DEFENSIVE, oAssociate)) sText = "Using defensive tactics";
        else if(GetCombatCondition(X0_COMBAT_FLAG_RANGED, oAssociate)) sText = "Using ranged tactics";
    }
    NuiSetBind(oPC, nToken, "btn_cmd_ai_script_tooltip", JsonString (sText));
    if(GetSkillRank(SKILL_SET_TRAP, oAssociate, TRUE) > 0)
    {
        NuiSetBind(oPC, nToken, "chbx_cmd_place_trap_check", JsonBool (bCmdPlacetrap));
        NuiSetBindWatch (oPC, nToken, "chbx_cmd_place_trap_check", TRUE);
        NuiSetBind(oPC, nToken, "btn_cmd_place_trap_event", JsonBool (TRUE));
        NuiSetBind(oPC, nToken, "btn_cmd_place_trap_tooltip", JsonString (
                   "  Place a trap at the location selected"));
    }
    // Row 7
    NuiSetBind(oPC, nToken, "chbx_buff_short_check", JsonBool (bBuffShort));
    NuiSetBindWatch (oPC, nToken, "chbx_buff_short_check", TRUE);
    NuiSetBind(oPC, nToken, "btn_buff_short_event", JsonBool (TRUE));
    NuiSetBind (oPC, nToken, "btn_buff_short_tooltip", JsonString (
               "  Buff the party with short duration spells"));
    NuiSetBind(oPC, nToken, "chbx_buff_long_check", JsonBool (bBuffLong));
    NuiSetBindWatch (oPC, nToken, "chbx_buff_long_check", TRUE);
    NuiSetBind(oPC, nToken, "btn_buff_long_event", JsonBool (TRUE));
    NuiSetBind(oPC, nToken, "btn_buff_long_tooltip", JsonString (
               "  Buff the party with long duration spells"));
    // Row 8
    NuiSetBind(oPC, nToken, "chbx_buff_all_check", JsonBool (bBuffAll));
    NuiSetBindWatch (oPC, nToken, "chbx_buff_all_check", TRUE);
    NuiSetBind(oPC, nToken, "btn_buff_all_event", JsonBool (TRUE));
    NuiSetBind(oPC, nToken, "btn_buff_all_tooltip", JsonString (
               "  Buff the party with all our defensive spells"));
    if(!bIsPC)
    {
        NuiSetBind(oPC, nToken, "chbx_buff_rest_check", JsonBool (bBuffRest));
        NuiSetBindWatch (oPC, nToken, "chbx_buff_rest_check", TRUE);
        NuiSetBind(oPC, nToken, "btn_buff_rest_event", JsonBool (TRUE));
        if(ai_GetMagicMode(oAssociate, AI_MAGIC_BUFF_AFTER_REST)) sText = "  [On] Turn buffing after resting off";
        else sText = "  [Off] Turn buffing after resting on";
        NuiSetBind (oPC, nToken, "btn_buff_rest_tooltip", JsonString (sText));
    }
}
void ai_CreateAssociateAINUI(object oPC, object oAssociate)
{
    // ************************************************************************* Width / Height
    int bIsPC = ai_GetIsCharacter(oAssociate);
    //int bUsingPCAI = ResManGetAliasFor("xx_pc_1_hb", RESTYPE_NCS) != "";
    // Row 1 ******************************************************************* 388 / 73
    json jRow = JsonArray();
    JsonArrayInsertInplace(jRow, NuiSpacer());
    CreateButton(jRow, "Loot Filter", "btn_loot_filter", 150.0, 20.0);
    CreateLabel(jRow, "", "blank_label_1", 25.0, 20.0);
    JsonArrayInsertInplace(jRow, NuiSpacer());
    json jCol = JsonArray();
    JsonArrayInsertInplace(jCol, NuiRow(jRow));
    // Row 2 ******************************************************************* 388 / 101
    jRow = JsonArray();
    CreateButton(jRow, "AI On/Off", "btn_ai", 150.0, 20.0, -1.0, "btn_ai_tooltip");
    CreateCheckBox(jRow, "", "chbx_ai", 25.0, 20.0);
    JsonArrayInsertInplace(jRow, NuiSpacer());
    CreateButton(jRow, "Ranged", "btn_ranged", 150.0, 20.0, -1.0, "btn_ranged_tooltip");
    CreateCheckBox(jRow, "", "chbx_ranged", 25.0, 20.0);
    JsonArrayInsertInplace(jCol, NuiRow(jRow));
    // Row 3 ******************************************************************* 388 / 129
    jRow = JsonArray();
    CreateButton(jRow, "Follow Range -", "btn_follow_minus", 150.0, 20.0, -1.0, "btn_follow_minus_tooltip");
    CreateCheckBox(jRow, "", "chbx_follow_minus", 25.0, 20.0);
    JsonArrayInsertInplace(jRow, NuiSpacer());
    CreateButton(jRow, "Follow Range +", "btn_follow_plus", 150.0, 20.0, -1.0, "btn_follow_plus_tooltip");
    CreateCheckBox(jRow, "", "chbx_follow_plus", 25.0, 20.0);
    JsonArrayInsertInplace(jCol, NuiRow(jRow));
    // Row 4 ******************************************************************* 388 / 157
    jRow = JsonArray();
    CreateButton(jRow, "Search", "btn_search", 150.0, 20.0, -1.0, "btn_search_tooltip");
    CreateCheckBox(jRow, "", "chbx_search", 25.0, 20.0);
    JsonArrayInsertInplace(jRow, NuiSpacer());
    CreateButton(jRow, "Stealth", "btn_stealth", 150.0, 20.0, -1.0, "btn_stealth_tooltip");
    CreateCheckBox(jRow, "", "chbx_stealth", 25.0, 20.0);
    JsonArrayInsertInplace(jCol, NuiRow(jRow));
    // Row 5 ******************************************************************* 388 / 185
    jRow = JsonArray();
    CreateButton(jRow, "Pick Locks", "btn_pick_locks", 150.0, 20.0, -1.0, "btn_pick_locks_tooltip");
    CreateCheckBox(jRow, "", "chbx_pick_locks", 25.0, 20.0);
    JsonArrayInsertInplace(jRow, NuiSpacer());
    CreateButton(jRow, "Bash Locks", "btn_bash_locks", 150.0, 20.0, -1.0, "btn_bash_locks_tooltip");
    CreateCheckBox(jRow, "", "chbx_bash_locks", 25.0, 20.0);
    JsonArrayInsertInplace(jCol, NuiRow(jRow));
    // Row 6 ******************************************************************* 388 / 213
    jRow = JsonArray();
    CreateButton(jRow, "Disarm Traps", "btn_traps", 150.0, 20.0, -1.0, "btn_traps_tooltip");
    CreateCheckBox(jRow, "", "chbx_traps", 25.0, 20.0);
    JsonArrayInsertInplace(jRow, NuiSpacer());
    CreateButton(jRow, "Reduce Speach", "btn_quiet", 150.0, 20.0, -1.0, "btn_quiet_tooltip");
    CreateCheckBox(jRow, "", "chbx_quiet", 25.0, 20.0);
    JsonArrayInsertInplace(jCol, NuiRow(jRow));
    // Row 7 ******************************************************************* 388 / 241
    jRow = JsonArray();
    CreateButton(jRow, "Magic use -", "btn_magic_minus", 150.0, 20.0f, -1.0, "btn_m_minus_tooltip");
    CreateCheckBox(jRow, "", "chbx_magic_minus", 25.0, 20.0);
    JsonArrayInsertInplace(jRow, NuiSpacer());
    CreateButton(jRow, "Magic use +", "btn_magic_plus", 150.0, 20.0, -1.0, "btn_m_plus_tooltip");
    CreateCheckBox(jRow, "", "chbx_magic_plus", 25.0, 20.0);
    JsonArrayInsertInplace(jCol, NuiRow(jRow));
    // Row 8 ******************************************************************* 388 / 269
    jRow = JsonArray();
    CreateButton(jRow, "No Magic", "btn_no_magic", 150.0, 20.0, -1.0, "btn_no_magic_tooltip");
    CreateCheckBox(jRow, "", "chbx_no_magic", 25.0, 20.0);
    JsonArrayInsertInplace(jRow, NuiSpacer());
    CreateButton(jRow, "All Magic", "btn_all_magic", 150.0, 20.0, -1.0, "btn_all_magic_tooltip");
    CreateCheckBox(jRow, "", "chbx_all_magic", 25.0, 20.0);
    JsonArrayInsertInplace(jCol, NuiRow(jRow));
    // Row 9 ******************************************************************* 388 / 297
    jRow = JsonArray();
    CreateButton(jRow, "Def Magic", "btn_def_magic", 150.0, 20.0, -1.0, "btn_def_magic_tooltip");
    CreateCheckBox(jRow, "", "chbx_def_magic", 25.0, 20.0f);
    JsonArrayInsert(jRow, NuiSpacer());
    CreateButton(jRow, "Off Magic", "btn_off_magic", 150.0, 20.0, -1.0, "btn_off_magic_tooltip");
    CreateCheckBox(jRow, "", "chbx_off_magic", 25.0, 20.0);
    JsonArrayInsertInplace(jCol, NuiRow(jRow));
    // Row 10 ****************************************************************** 388 / 325
    jRow = JsonArray();
    CreateButton(jRow, "Looting", "btn_loot", 150.0, 20.0, -1.0, "btn_loot_tooltip");
    CreateCheckBox(jRow, "", "chbx_loot", 25.0, 20.0);
    JsonArrayInsertInplace(jRow, NuiSpacer());
    CreateButton(jRow, "Spontaneous Casting", "btn_spontaneous", 150.0, 20.0, -1.0, "btn_spontaneous_tooltip");
    CreateCheckBox(jRow, "", "chbx_spontaneous", 25.0, 20.0);
    JsonArrayInsertInplace(jCol, NuiRow(jRow));
    // Row 11 ****************************************************************** 388 / 353
    jRow = JsonArray();
    CreateButton(jRow, "Heal % Chance -", "btn_heal_out_minus", 150.0, 20.0, -1.0, "btn_heal_out_minus_tooltip");
    CreateCheckBox(jRow, "", "chbx_heal_out_minus", 25.0, 20.0);
    JsonArrayInsertInplace(jRow, NuiSpacer());
    CreateButton(jRow, "Heal % Chance +", "btn_heal_out_plus", 150.0, 20.0, -1.0, "btn_heal_out_plus_tooltip");
    CreateCheckBox(jRow, "", "chbx_heal_out_plus", 25.0, 20.0);
    JsonArrayInsertInplace(jCol, NuiRow(jRow));
    // Row 12 ****************************************************************** 388 / 381
    jRow = JsonArray();
    CreateButton(jRow, "Heal % Combat -", "btn_heal_in_minus", 150.0, 20.0, -1.0, "btn_heal_in_minus_tooltip");
    CreateCheckBox(jRow, "", "chbx_heal_in_minus", 25.0, 20.0);
    JsonArrayInsertInplace(jRow, NuiSpacer());
    CreateButton(jRow, "Heal % Combat +", "btn_heal_in_plus", 150.0, 20.0, -1.0, "btn_heal_in_plus_tooltip");
    CreateCheckBox(jRow, "", "chbx_heal_in_plus", 25.0, 20.0);
    JsonArrayInsertInplace(jCol, NuiRow(jRow));
    // Row 13 ****************************************************************** 388 / 409
    jRow = JsonArray();
    CreateButton(jRow, "Heal Self On/Off", "btn_heals_onoff", 150.0, 20.0, -1.0, "btn_heals_onoff_tooltip");
    CreateCheckBox(jRow, "", "chbx_heals_onoff", 25.0, 20.0);
    CreateButton(jRow, "Heal Party On/Off", "btn_healp_onoff", 150.0, 20.0, -1.0, "btn_healp_onoff_tooltip");
    CreateCheckBox(jRow, "", "chbx_healp_onoff", 25.0, 20.0);
    JsonArrayInsertInplace(jCol, NuiRow(jRow));
    // Row 14 ****************************************************************** 388 / 437
    jRow = JsonArray();
    CreateButton(jRow, "Loot Range -", "btn_loot_range_minus", 150.0, 20.0f, -1.0, "btn_lootr_minus_tooltip");
    CreateCheckBox(jRow, "", "chbx_loot_range_minus", 25.0, 20.0);
    JsonArrayInsertInplace(jRow, NuiSpacer());
    CreateButton(jRow, "Loot Range +", "btn_loot_range_plus", 150.0, 20.0, -1.0, "btn_lootr_plus_tooltip");
    CreateCheckBox(jRow, "", "chbx_loot_range_plus", 25.0, 20.0);
    JsonArrayInsertInplace(jCol, NuiRow(jRow));
    // Row 15 ****************************************************************** 388 / 465
    jRow = JsonArray();
    CreateButton(jRow, "Lock Range -", "btn_lock_range_minus", 150.0, 20.0f, -1.0, "btn_lockr_minus_tooltip");
    CreateCheckBox(jRow, "", "chbx_lock_range_minus", 25.0, 20.0);
    JsonArrayInsertInplace(jRow, NuiSpacer());
    CreateButton(jRow, "Lock Range +", "btn_lock_range_plus", 150.0, 20.0, -1.0, "btn_lockr_plus_tooltip");
    CreateCheckBox(jRow, "", "chbx_lock_range_plus", 25.0, 20.0);
    JsonArrayInsertInplace(jCol, NuiRow(jRow));
    // Row 16 ****************************************************************** 388 / 493
    jRow = JsonArray();
    CreateButton(jRow, "Trap Range -", "btn_trap_range_minus", 150.0, 20.0f, -1.0, "btn_trapr_minus_tooltip");
    CreateCheckBox(jRow, "", "chbx_trap_range_minus", 25.0, 20.0);
    JsonArrayInsertInplace(jRow, NuiSpacer());
    CreateButton(jRow, "Trap Range +", "btn_trap_range_plus", 150.0, 20.0, -1.0, "btn_trapr_plus_tooltip");
    CreateCheckBox(jRow, "", "chbx_trap_range_plus", 25.0, 20.0);
    JsonArrayInsertInplace(jCol, NuiRow(jRow));
    // Row 17 ******************************************************************* 482 / 521
    jRow = JsonArray();
    CreateButton(jRow, "Set Current AI:", "btn_ai_script", 175.0f, 20.0f, -1.0, "btn_ai_script_tooltip");
    JsonArrayInsertInplace(jRow, NuiSpacer());
    CreateTextEditBox(jRow, "sPlaceHolder", "txt_ai_script", 16, FALSE, 175.0f, 20.0f, "txt_ai_script_tooltip");
    JsonArrayInsertInplace(jRow, NuiSpacer());
    // Add row to the column.
    JsonArrayInsertInplace(jCol, NuiRow(jRow));
    float fHeight = 521.0;
    // Set the Layout of the window.
    json jLayout = NuiCol(jCol);
    string sText, sName = GetName(oAssociate);
    if(GetStringRight(sName, 1) == "s") sName = sName + "'";
    else sName = sName + "'s";
    string sAssociateType = ai_GetAssociateType(oPC, oAssociate);
    int nToken = SetWindow(oPC, jLayout, sAssociateType + "_ai_menu", sName + " Menu",
                           -1.0, -1.0, 388.0, fHeight + 12.0, FALSE, FALSE, TRUE, FALSE, TRUE, "0e_nui");
    // Get which buttons are activated.
    int bAI = ai_GetAIButton(oPC, BTN_AI_FOR_PC, oAssociate, sAssociateType);
    int bRanged = ai_GetAIButton(oPC, BTN_AI_USE_RANGED, oAssociate, sAssociateType);
    int bPCFollowMinus = ai_GetAIButton(oPC, BTN_AI_FOLLOW_MINUS, oAssociate, sAssociateType);
    int bPCFollowPlus = ai_GetAIButton(oPC, BTN_AI_FOLLOW_PLUS, oAssociate, sAssociateType);
    int bSearch = ai_GetAIButton(oPC, BTN_AI_USE_SEARCH, oAssociate, sAssociateType);
    int bStealth = ai_GetAIButton(oPC, BTN_AI_USE_STEALTH, oAssociate, sAssociateType);
    int bPickLocks = ai_GetAIButton(oPC, BTN_AI_PICK_LOCKS, oAssociate, sAssociateType);
    int bBashLocks = ai_GetAIButton(oPC, BTN_AI_BASH_LOCKS, oAssociate, sAssociateType);
    int bTraps = ai_GetAIButton(oPC, BTN_AI_REMOVE_TRAPS, oAssociate, sAssociateType);
    int bReduceSpeach = ai_GetAIButton(oPC, BTN_AI_REDUCE_SPEECH, oAssociate, sAssociateType);
    int bPCMagicMinus = ai_GetAIButton(oPC, BTN_AI_MAGIC_USE_MINUS, oAssociate, sAssociateType);
    int bPCMagicPlus = ai_GetAIButton(oPC, BTN_AI_MAGIC_USE_PLUS, oAssociate, sAssociateType);
    int bNoMagic = ai_GetAIButton(oPC, BTN_AI_NO_MAGIC_USE, oAssociate, sAssociateType);
    int bAllMagic = ai_GetAIButton(oPC, BTN_AI_ALL_MAGIC_USE, oAssociate, sAssociateType);
    int bDefMagic = ai_GetAIButton(oPC, BTN_AI_DEF_MAGIC_USE, oAssociate, sAssociateType);
    int bOffMagic = ai_GetAIButton(oPC, BTN_AI_OFF_MAGIC_USE, oAssociate, sAssociateType);
    int bLoot = ai_GetAIButton(oPC, BTN_AI_LOOT, oAssociate, sAssociateType);
    int bSpontaneous = ai_GetAIButton2(oPC, BTN2_AI_NO_SPONTANEOUS, oAssociate, sAssociateType);
    int bHealOutPlus = ai_GetAIButton(oPC, BTN_AI_HEAL_OUT_PLUS, oAssociate, sAssociateType);
    int bHealOutMinus = ai_GetAIButton(oPC, BTN_AI_HEAL_OUT_MINUS, oAssociate, sAssociateType);
    int bHealInPlus = ai_GetAIButton(oPC, BTN_AI_HEAL_IN_PLUS, oAssociate, sAssociateType);
    int bHealInMinus = ai_GetAIButton(oPC, BTN_AI_HEAL_IN_MINUS, oAssociate, sAssociateType);
    int bSelfHealOnOff = ai_GetAIButton(oPC, BTN_AI_STOP_SELF_HEALING, oAssociate, sAssociateType);
    int bPartyHealOnOff = ai_GetAIButton(oPC, BTN_AI_STOP_PARTY_HEALING, oAssociate, sAssociateType);
    int bLootRangePlus = ai_GetAIButton(oPC, BTN_AI_LOOT_RANGE_PLUS, oAssociate, sAssociateType);
    int bLootRangeMinus = ai_GetAIButton(oPC, BTN_AI_LOOT_RANGE_MINUS, oAssociate, sAssociateType);
    int bLockRangePlus = ai_GetAIButton(oPC, BTN_AI_UNLOCK_RANGE_PLUS, oAssociate, sAssociateType);
    int bLockRangeMinus = ai_GetAIButton(oPC, BTN_AI_UNLOCK_RANGE_MINUS, oAssociate, sAssociateType);
    int bTrapRangePlus = ai_GetAIButton(oPC, BTN_AI_TRAPS_RANGE_PLUS, oAssociate, sAssociateType);
    int bTrapRangeMinus = ai_GetAIButton(oPC, BTN_AI_TRAPS_RANGE_MINUS, oAssociate, sAssociateType);
    // Save the associate to the nui for use in 0e_nui
    json jData = JsonArray();
    JsonArrayInsertInplace(jData, JsonString(ObjectToString(oAssociate)));
    NuiSetUserData(oPC, nToken, jData);
    // Set all binds, events, and watches.
    // Row 1
    NuiSetBind(oPC, nToken, "btn_loot_filter_event", JsonBool(TRUE));
    NuiSetBind(oPC, nToken, "btn_loot_filter", JsonInt(TRUE));
    // Row 2
    // Only activate ai on/off if this is for the pc.
    if(bIsPC)
    {
        NuiSetBind(oPC, nToken, "chbx_ai_check", JsonBool(bAI));
        NuiSetBindWatch (oPC, nToken, "chbx_ai_check", TRUE);
        NuiSetBind(oPC, nToken, "btn_ai_event", JsonBool(TRUE));
        if(GetEventScript(oAssociate, EVENT_SCRIPT_CREATURE_ON_HEARTBEAT) == "xx_pc_1_hb") sText = "  AI [On] Turn off";
        else sText = "  AI [Off] Turn on";
        NuiSetBind(oPC, nToken, "btn_ai_tooltip", JsonString(sText));
    }
    NuiSetBind(oPC, nToken, "chbx_ranged_check", JsonBool(bRanged));
    NuiSetBindWatch(oPC, nToken, "chbx_ranged_check", TRUE);
    NuiSetBind(oPC, nToken, "btn_ranged_event", JsonBool(TRUE));
    if(ai_GetAIMode(oAssociate, AI_MODE_STOP_RANGED)) sText = "  Ranged [Off] Turn on";
    else sText = "  Ranged [On] Turn off";
    NuiSetBind (oPC, nToken, "btn_ranged_tooltip", JsonString(sText));
    // Row 3
    NuiSetBind(oPC, nToken, "chbx_follow_minus_check", JsonBool(bPCFollowMinus));
    NuiSetBindWatch (oPC, nToken, "chbx_follow_minus_check", TRUE);
    NuiSetBind(oPC, nToken, "btn_follow_minus_event", JsonBool(TRUE));
    float fRange = GetLocalFloat(oAssociate, AI_FOLLOW_RANGE) +
                   StringToFloat(Get2DAString("appearance", "PREFATCKDIST", GetAppearanceType(oAssociate)));
    string sFollow = FloatToString(fRange, 0, 0);
    sText = " Follow distance [" + sFollow + " meters] Decrease";
    NuiSetBind (oPC, nToken, "btn_follow_minus_tooltip", JsonString(sText));
    NuiSetBind(oPC, nToken, "chbx_follow_plus_check", JsonBool(bPCFollowPlus));
    NuiSetBindWatch(oPC, nToken, "chbx_follow_plus_check", TRUE);
    NuiSetBind(oPC, nToken, "btn_follow_plus_event", JsonBool(TRUE));
    sText = " Follow distance [" + sFollow + " meters] Increase";
    NuiSetBind (oPC, nToken, "btn_follow_plus_tooltip", JsonString(sText));
    // Row 4
    NuiSetBind(oPC, nToken, "chbx_search_check", JsonBool(bSearch));
    NuiSetBindWatch (oPC, nToken, "chbx_search_check", TRUE);
    NuiSetBind(oPC, nToken, "btn_search_event", JsonBool(TRUE));
    if(ai_GetAIMode(oAssociate, AI_MODE_AGGRESSIVE_SEARCH)) sText = "  Search [On] Turn off";
    else sText = "  Search [Off] Turn on";
    NuiSetBind (oPC, nToken, "btn_search_tooltip", JsonString(sText));
    NuiSetBind(oPC, nToken, "chbx_stealth_check", JsonBool(bStealth));
    NuiSetBindWatch(oPC, nToken, "chbx_stealth_check", TRUE);
    NuiSetBind(oPC, nToken, "btn_stealth_event", JsonBool(TRUE));
    if(ai_GetAIMode(oAssociate, AI_MODE_AGGRESSIVE_STEALTH)) sText = "  Stealth [On] Trun off";
    else sText = "  Stealth [Off] Turn on";
    NuiSetBind (oPC, nToken, "btn_stealth_tooltip", JsonString(sText));
    // Row 5
    NuiSetBind(oPC, nToken, "chbx_pick_locks_check", JsonBool(bPickLocks));
    NuiSetBindWatch(oPC, nToken, "chbx_pick_locks_check", TRUE);
    NuiSetBind(oPC, nToken, "btn_pick_locks_event", JsonBool(TRUE));
    if(ai_GetAIMode(oAssociate, AI_MODE_PICK_LOCKS)) sText = "  Pick locks [On] Turn off";
    else sText = "  Pick Locks [Off] Turn on";
    NuiSetBind (oPC, nToken, "btn_pick_locks_tooltip", JsonString(sText));
    NuiSetBind(oPC, nToken, "chbx_bash_locks_check", JsonBool(bBashLocks));
    NuiSetBindWatch(oPC, nToken, "chbx_bash_locks_check", TRUE);
    NuiSetBind(oPC, nToken, "btn_bash_locks_event", JsonBool(TRUE));
    if(ai_GetAIMode(oAssociate, AI_MODE_BASH_LOCKS)) sText = "  Bash locks [On] Turn off";
    else sText = "  Bash Locks [Off] Turn on";
    NuiSetBind (oPC, nToken, "btn_bash_locks_tooltip", JsonString(sText));
    // Row 6
    NuiSetBind(oPC, nToken, "chbx_traps_check", JsonBool(bTraps));
    NuiSetBindWatch (oPC, nToken, "chbx_traps_check", TRUE);
    NuiSetBind(oPC, nToken, "btn_traps_event", JsonBool(TRUE));
    if(ai_GetAIMode(oAssociate, AI_MODE_DISARM_TRAPS)) sText = "  Disable Traps [On] Turn off";
    else sText = "  Disable Traps [Off] Turn on";
    NuiSetBind (oPC, nToken, "btn_traps_tooltip", JsonString(sText));
    NuiSetBind(oPC, nToken, "chbx_quiet_check", JsonBool(bTraps));
    NuiSetBindWatch (oPC, nToken, "chbx_quiet_check", TRUE);
    NuiSetBind(oPC, nToken, "btn_quiet_event", JsonBool(TRUE));
    if(ai_GetAIMode(oAssociate, AI_MODE_DO_NOT_SPEAK)) sText = "  Reduce Speach [On] Turn off";
    else sText = "  Reduce Speach [Off] Turn on";
    NuiSetBind (oPC, nToken, "btn_quiet_tooltip", JsonString(sText));
    // Row 7
    string sMagic = IntToString(GetLocalInt(oAssociate, AI_DIFFICULTY_ADJUSTMENT));
    NuiSetBind(oPC, nToken, "chbx_magic_minus_check", JsonBool(bPCMagicMinus));
    NuiSetBindWatch (oPC, nToken, "chbx_magic_minus_check", TRUE);
    NuiSetBind(oPC, nToken, "btn_magic_minus_event", JsonBool(TRUE));
    NuiSetBind (oPC, nToken, "btn_m_minus_tooltip", JsonString(" Magic use [" + sMagic + "] Decrease"));
    NuiSetBind(oPC, nToken, "chbx_magic_plus_check", JsonBool(bPCMagicPlus));
    NuiSetBindWatch(oPC, nToken, "chbx_magic_plus_check", TRUE);
    NuiSetBind(oPC, nToken, "btn_magic_plus_event", JsonBool(TRUE));
    NuiSetBind (oPC, nToken, "btn_m_plus_tooltip", JsonString("  Magic use [" + sMagic + "] Increase"));
    // Row 8
    sText = "  [Any]";
    if(ai_GetMagicMode(oAssociate, AI_MAGIC_NO_MAGIC)) sText = "  [None]";
    else if(ai_GetMagicMode(oAssociate, AI_MAGIC_DEFENSIVE_CASTING)) sText = "  [Defense]";
    else if(ai_GetMagicMode(oAssociate, AI_MAGIC_OFFENSIVE_CASTING)) sText = "  [Offense]";
    NuiSetBind(oPC, nToken, "chbx_no_magic_check", JsonBool(bNoMagic));
    NuiSetBindWatch (oPC, nToken, "chbx_no_magic_check", TRUE);
    NuiSetBind(oPC, nToken, "btn_no_magic_event", JsonBool(TRUE));
    NuiSetBind(oPC, nToken, "btn_no_magic_tooltip", JsonString(sText + " Turn magic use off"));
    NuiSetBind(oPC, nToken, "chbx_all_magic_check", JsonBool(bAllMagic));
    NuiSetBindWatch (oPC, nToken, "chbx_all_magic_check", TRUE);
    NuiSetBind(oPC, nToken, "btn_all_magic_event", JsonBool(TRUE));
    NuiSetBind(oPC, nToken, "btn_all_magic_tooltip", JsonString(sText + " Use any magic"));
    // Row 9
    NuiSetBind(oPC, nToken, "chbx_def_magic_check", JsonBool (bDefMagic));
    NuiSetBindWatch (oPC, nToken, "chbx_def_magic_check", TRUE);
    NuiSetBind(oPC, nToken, "btn_def_magic_event", JsonBool(TRUE));
    NuiSetBind(oPC, nToken, "btn_def_magic_tooltip", JsonString(sText + " Use defensive magic only"));
    NuiSetBind(oPC, nToken, "chbx_off_magic_check", JsonBool(bOffMagic));
    NuiSetBindWatch (oPC, nToken, "chbx_off_magic_check", TRUE);
    NuiSetBind(oPC, nToken, "btn_off_magic_event", JsonBool(TRUE));
    NuiSetBind(oPC, nToken, "btn_off_magic_tooltip", JsonString(sText + " Use offensive magic only"));
    // Row 10
    sText = "  [Off] Turn on looting";
    if(ai_GetAIMode(oAssociate, AI_MODE_PICKUP_ITEMS)) sText = "  [On] Turn off looting";
    NuiSetBind(oPC, nToken, "chbx_loot_check", JsonBool(bLoot));
    NuiSetBindWatch (oPC, nToken, "chbx_loot_check", TRUE);
    NuiSetBind(oPC, nToken, "btn_loot_event", JsonBool(TRUE));
    NuiSetBind(oPC, nToken, "btn_loot_tooltip", JsonString(sText + " Pickup items"));
    sText = "  [On] Turn off Spontaneous casting";
    if(ai_GetMagicMode(oAssociate, AI_MAGIC_NO_SPONTANEOUS_CURE)) sText = "  [Off] Turn on Spontaneous casting";
    NuiSetBind(oPC, nToken, "chbx_spontaneous_check", JsonBool(bSpontaneous));
    NuiSetBindWatch (oPC, nToken, "chbx_spontaneous_check", TRUE);
    NuiSetBind(oPC, nToken, "btn_spontaneous_event", JsonBool(TRUE));
    NuiSetBind(oPC, nToken, "btn_spontaneous_tooltip", JsonString(sText));
    // Row 11
    int nHeal = GetLocalInt(oAssociate, AI_HEAL_OUT_OF_COMBAT_LIMIT);
    NuiSetBind(oPC, nToken, "chbx_heal_out_minus_check", JsonBool(bHealOutMinus));
    NuiSetBindWatch (oPC, nToken, "chbx_heal_out_minus_check", TRUE);
    NuiSetBind(oPC, nToken, "btn_heal_out_minus_event", JsonBool(TRUE));
    sText = "  Will heal at or below [" + IntToString(nHeal) + "%] health out of combat";
    NuiSetBind(oPC, nToken, "btn_heal_out_minus_tooltip", JsonString(sText));
    NuiSetBind(oPC, nToken, "chbx_heal_out_plus_check", JsonBool(bHealOutPlus));
    NuiSetBindWatch (oPC, nToken, "chbx_heal_out_plus_check", TRUE);
    NuiSetBind(oPC, nToken, "btn_heal_out_plus_event", JsonBool (TRUE));
    sText = "  Will heal at or below [" + IntToString(nHeal) + "%] health out of combat";
    NuiSetBind(oPC, nToken, "btn_heal_out_plus_tooltip", JsonString(sText));
    // Row 12
    nHeal = GetLocalInt(oAssociate, AI_HEAL_IN_COMBAT_LIMIT);
    NuiSetBind(oPC, nToken, "chbx_heal_in_minus_check", JsonBool(bHealInMinus));
    NuiSetBindWatch (oPC, nToken, "chbx_heal_in_minus_check", TRUE);
    NuiSetBind(oPC, nToken, "btn_heal_in_minus_event", JsonBool (TRUE));
    sText = "  Will heal at or below [" + IntToString(nHeal) + "%] health in combat";
    NuiSetBind(oPC, nToken, "btn_heal_in_minus_tooltip", JsonString(sText));
    NuiSetBind(oPC, nToken, "chbx_heal_in_plus_check", JsonBool(bHealInPlus));
    NuiSetBindWatch (oPC, nToken, "chbx_heal_in_plus_check", TRUE);
    NuiSetBind(oPC, nToken, "btn_heal_in_plus_event", JsonBool(TRUE));
    sText = "  Will heal at or below [" + IntToString(nHeal) + "%] health in combat";
    NuiSetBind(oPC, nToken, "btn_heal_in_plus_tooltip", JsonString(sText));
    // Row 13
    NuiSetBind(oPC, nToken, "chbx_heals_onoff_check", JsonBool(bSelfHealOnOff));
    NuiSetBindWatch (oPC, nToken, "chbx_heals_onoff_check", TRUE);
    NuiSetBind(oPC, nToken, "btn_heals_onoff_event", JsonBool(TRUE));
    if(ai_GetAIMode(oAssociate, AI_MODE_SELF_HEALING_OFF)) sText = "  Self healing is [Off] turn on";
    else sText = "  Self healing is [On] turn off";
    NuiSetBind(oPC, nToken, "btn_heals_onoff_tooltip", JsonString(sText));
    NuiSetBind(oPC, nToken, "chbx_healp_onoff_check", JsonBool(bPartyHealOnOff));
    NuiSetBindWatch (oPC, nToken, "chbx_healp_onoff_check", TRUE);
    NuiSetBind(oPC, nToken, "btn_healp_onoff_event", JsonBool(TRUE));
    if(ai_GetAIMode(oAssociate, AI_MODE_PARTY_HEALING_OFF)) sText = "  Party healing is [Off] turn on";
    else sText = "  Party healing is [On] turn off";
    NuiSetBind(oPC, nToken, "btn_healp_onoff_tooltip", JsonString(sText));
    // Row 14
    string sRange = FloatToString(GetLocalFloat(oAssociate, AI_LOOT_CHECK_RANGE), 0, 0);
    NuiSetBind(oPC, nToken, "chbx_loot_range_minus_check", JsonBool (bLootRangeMinus));
    NuiSetBindWatch (oPC, nToken, "chbx_loot_range_minus_check", TRUE);
    NuiSetBind(oPC, nToken, "btn_loot_range_minus_event", JsonBool(TRUE));
    NuiSetBind (oPC, nToken, "btn_lootr_minus_tooltip", JsonString(" Loot range [" + sRange + "] Decrease"));
    NuiSetBind(oPC, nToken, "chbx_loot_range_plus_check", JsonBool(bLootRangePlus));
    NuiSetBindWatch(oPC, nToken, "chbx_loot_range_plus_check", TRUE);
    NuiSetBind(oPC, nToken, "btn_loot_range_plus_event", JsonBool(TRUE));
    NuiSetBind (oPC, nToken, "btn_lootr_plus_tooltip", JsonString("  Loot range [" + sRange + "] Increase"));
    // Row 15
    sRange = FloatToString(GetLocalFloat(oAssociate, AI_LOCK_CHECK_RANGE), 0, 0);
    NuiSetBind(oPC, nToken, "chbx_lock_range_minus_check", JsonBool(bLockRangeMinus));
    NuiSetBindWatch (oPC, nToken, "chbx_lock_range_minus_check", TRUE);
    NuiSetBind(oPC, nToken, "btn_lock_range_minus_event", JsonBool(TRUE));
    NuiSetBind (oPC, nToken, "btn_lockr_minus_tooltip", JsonString(" Lock range [" + sRange + "] Decrease"));
    NuiSetBind(oPC, nToken, "chbx_lock_range_plus_check", JsonBool(bLockRangePlus));
    NuiSetBindWatch(oPC, nToken, "chbx_lock_range_plus_check", TRUE);
    NuiSetBind(oPC, nToken, "btn_lock_range_plus_event", JsonBool(TRUE));
    NuiSetBind (oPC, nToken, "btn_lockr_plus_tooltip", JsonString("  Lock range [" + sRange + "] Increase"));
    // Row 16
    sRange = FloatToString(GetLocalFloat(oAssociate, AI_TRAP_CHECK_RANGE), 0, 0);
    NuiSetBind(oPC, nToken, "chbx_trap_range_minus_check", JsonBool(bTrapRangeMinus));
    NuiSetBindWatch (oPC, nToken, "chbx_trap_range_minus_check", TRUE);
    NuiSetBind(oPC, nToken, "btn_trap_range_minus_event", JsonBool(TRUE));
    NuiSetBind (oPC, nToken, "btn_trapr_minus_tooltip", JsonString(" Trap range [" + sRange + "] Decrease"));
    NuiSetBind(oPC, nToken, "chbx_trap_range_plus_check", JsonBool(bTrapRangePlus));
    NuiSetBindWatch(oPC, nToken, "chbx_trap_range_plus_check", TRUE);
    NuiSetBind(oPC, nToken, "btn_trap_range_plus_event", JsonBool(TRUE));
    NuiSetBind (oPC, nToken, "btn_trapr_plus_tooltip", JsonString("  Trap range [" + sRange + "] Increase"));
    // Row 17
    string sScript = GetLocalString(oAssociate, AI_COMBAT_SCRIPT);
    if(sScript == "") sScript = GetLocalString(oAssociate, AI_DEFAULT_SCRIPT);
    NuiSetBind(oPC, nToken, "btn_ai_script_event", JsonBool(TRUE));
    NuiSetBind(oPC, nToken, "btn_ai_script_tooltip", JsonString("  Sets " + GetName(oAssociate) + " to use the ai script in the text box."));
    NuiSetBind(oPC, nToken, "txt_ai_script", JsonString(sScript));
    NuiSetBind(oPC, nToken, "txt_ai_script_tooltip", JsonString("  Associate AI scripts must start with ai_a_"));
}
void ai_CreateWidgetNUI(object oPC, object oAssociate)
{
    // Set window to not save until it has been created.
    SetLocalInt (oPC, AI_NO_NUI_SAVE, TRUE);
    DelayCommand (0.5f, DeleteLocalInt (oPC, AI_NO_NUI_SAVE));
    // Get which buttons are activated.
    string sAssociateType = ai_GetAssociateType(oPC, oAssociate);
    int bAIWidgetLock = ai_GetWidgetButton(oPC, BTN_WIDGET_LOCK, oAssociate, sAssociateType);
    int bCmdAction = ai_GetWidgetButton(oPC, BTN_CMD_ACTION, oAssociate, sAssociateType);
    int bCmdGuard = ai_GetWidgetButton(oPC, BTN_CMD_GUARD, oAssociate, sAssociateType);
    int bCmdHold = ai_GetWidgetButton(oPC, BTN_CMD_HOLD, oAssociate, sAssociateType);
    int bCmdAttack = ai_GetWidgetButton(oPC, BTN_CMD_ATTACK, oAssociate, sAssociateType);
    int bCmdFollow = ai_GetWidgetButton(oPC, BTN_CMD_FOLLOW, oAssociate, sAssociateType);
    int bCmdAIScript = ai_GetWidgetButton(oPC, BTN_CMD_AI_SCRIPT, oAssociate, sAssociateType);
    int bCmdPlacetrap = ai_GetWidgetButton(oPC, BTN_CMD_PLACE_TRAP, oAssociate, sAssociateType);
    int bBuffRest = ai_GetWidgetButton(oPC, BTN_BUFF_REST, oAssociate, sAssociateType);
    int bBuffShort = ai_GetWidgetButton(oPC, BTN_BUFF_SHORT, oAssociate, sAssociateType);
    int bBuffLong = ai_GetWidgetButton(oPC, BTN_BUFF_LONG, oAssociate, sAssociateType);
    int bBuffAll = ai_GetWidgetButton(oPC, BTN_BUFF_ALL, oAssociate, sAssociateType);
    int bFollowTarget = ai_GetAIButton(oPC, BTN_AI_FOLLOW_TARGET, oAssociate, sAssociateType);
    int bAI = ai_GetAIButton(oPC, BTN_AI_FOR_PC, oAssociate, sAssociateType);
    int bRanged = ai_GetAIButton(oPC, BTN_AI_USE_RANGED, oAssociate, sAssociateType);
    int bPCFollowMinus = ai_GetAIButton(oPC, BTN_AI_FOLLOW_MINUS, oAssociate, sAssociateType);
    int bPCFollowPlus = ai_GetAIButton(oPC, BTN_AI_FOLLOW_PLUS, oAssociate, sAssociateType);
    int bSearch = ai_GetAIButton(oPC, BTN_AI_USE_SEARCH, oAssociate, sAssociateType);
    int bStealth = ai_GetAIButton(oPC, BTN_AI_USE_STEALTH, oAssociate, sAssociateType);
    int bPickLocks = ai_GetAIButton(oPC, BTN_AI_PICK_LOCKS, oAssociate, sAssociateType);
    int bBashLocks = ai_GetAIButton(oPC, BTN_AI_BASH_LOCKS, oAssociate, sAssociateType);
    int bTraps = ai_GetAIButton(oPC, BTN_AI_REMOVE_TRAPS, oAssociate, sAssociateType);
    int bReduceSpeech = ai_GetAIButton(oPC, BTN_AI_REDUCE_SPEECH, oAssociate, sAssociateType);
    int bPCMagicMinus = ai_GetAIButton(oPC, BTN_AI_MAGIC_USE_MINUS, oAssociate, sAssociateType);
    int bPCMagicPlus = ai_GetAIButton(oPC, BTN_AI_MAGIC_USE_PLUS, oAssociate, sAssociateType);
    int bNoMagic = ai_GetAIButton(oPC, BTN_AI_NO_MAGIC_USE, oAssociate, sAssociateType);
    int bAllMagic = ai_GetAIButton(oPC, BTN_AI_ALL_MAGIC_USE, oAssociate, sAssociateType);
    int bDefMagic = ai_GetAIButton(oPC, BTN_AI_DEF_MAGIC_USE, oAssociate, sAssociateType);
    int bOffMagic = ai_GetAIButton(oPC, BTN_AI_OFF_MAGIC_USE, oAssociate, sAssociateType);
    int bLoot = ai_GetAIButton(oPC, BTN_AI_LOOT, oAssociate, sAssociateType);
    int bSpontaneous = ai_GetAIButton2(oPC, BTN2_AI_NO_SPONTANEOUS, oAssociate, sAssociateType);
    int bHealOutPlus = ai_GetAIButton(oPC, BTN_AI_HEAL_OUT_PLUS, oAssociate, sAssociateType);
    int bHealOutMinus = ai_GetAIButton(oPC, BTN_AI_HEAL_OUT_MINUS, oAssociate, sAssociateType);
    int bHealInPlus = ai_GetAIButton(oPC, BTN_AI_HEAL_IN_PLUS, oAssociate, sAssociateType);
    int bHealInMinus = ai_GetAIButton(oPC, BTN_AI_HEAL_IN_MINUS, oAssociate, sAssociateType);
    int bSelfHealOnOff = ai_GetAIButton(oPC, BTN_AI_STOP_SELF_HEALING, oAssociate, sAssociateType);
    int bPartyHealOnOff = ai_GetAIButton(oPC, BTN_AI_STOP_PARTY_HEALING, oAssociate, sAssociateType);
    int bLootRangePlus = ai_GetAIButton(oPC, BTN_AI_LOOT_RANGE_PLUS, oAssociate, sAssociateType);
    int bLootRangeMinus = ai_GetAIButton(oPC, BTN_AI_LOOT_RANGE_MINUS, oAssociate, sAssociateType);
    int bLockRangePlus = ai_GetAIButton(oPC, BTN_AI_UNLOCK_RANGE_PLUS, oAssociate, sAssociateType);
    int bLockRangeMinus = ai_GetAIButton(oPC, BTN_AI_UNLOCK_RANGE_MINUS, oAssociate, sAssociateType);
    int bTrapRangePlus = ai_GetAIButton(oPC, BTN_AI_TRAPS_RANGE_PLUS, oAssociate, sAssociateType);
    int bTrapRangeMinus = ai_GetAIButton(oPC, BTN_AI_TRAPS_RANGE_MINUS, oAssociate, sAssociateType);
    float fHeight = 92.0f;
    if(bAIWidgetLock) fHeight = 59.0f;
    float fButtons, fWidth = 86.0f;
    // ************************************************************************* Width / Height
    // Row 1 (buttons)**********************************************************
    json jRow = JsonArray();
    // Setup the main associate button to use their portrait.
    json jButton = NuiEnabled(NuiId (NuiButtonImage(NuiBind("btn_open_main_image")), "btn_open_main"), NuiBind("btn_open_main_event"));
    jButton = NuiWidth(jButton, 35.0);
    jButton = NuiHeight(jButton, 35.0);
    jButton = NuiMargin(jButton, 0.0);
    jButton = NuiTooltip(jButton, NuiBind ("btn_open_main_tooltip"));
    jButton = NuiImageRegion(jButton, NuiRect(0.0, 0.0, 32.0, 35.0));
    JsonArrayInsertInplace(jRow, jButton);
    if(bCmdAction)
    {
        CreateButtonImage(jRow, "ir_action", "btn_cmd_action", 35.0f, 35.0f, 0.0, "btn_cmd_action_tooltip");
        fButtons += 1.0;
    }
    if(bCmdGuard)
    {
        CreateButtonImage(jRow, "ir_guard", "btn_cmd_guard", 35.0f, 35.0f, 0.0, "btn_cmd_guard_tooltip");
        fButtons += 1.0;
    }
    if(bCmdHold)
    {
        CreateButtonImage(jRow, "ir_standground", "btn_cmd_hold", 35.0f, 35.0f, 0.0, "btn_cmd_hold_tooltip");
        fButtons += 1.0;
    }
    if(bCmdAttack)
    {
        CreateButtonImage(jRow, "ir_attacknearest", "btn_cmd_attack", 35.0f, 35.0f, 0.0, "btn_cmd_attack_tooltip");
        fButtons += 1.0;
    }
    if(bCmdFollow)
    {
        CreateButtonImage(jRow, "ir_follow", "btn_cmd_follow", 35.0f, 35.0f, 0.0, "btn_cmd_follow_tooltip");
        fButtons += 1.0;
    }
    if(bFollowTarget)
    {
        CreateButtonImage(jRow, "ir_dmchat", "btn_follow_target", 35.0f, 35.0f, 0.0, "btn_follow_target_tooltip");
        fButtons += 1.0;
    }
    if(bCmdAIScript)
    {
        CreateButtonImage(jRow, "ir_scommand", "btn_cmd_ai_script", 35.0f, 35.0f, 0.0, "btn_cmd_ai_script_tooltip");
        fButtons += 1.0;
    }
    if(bCmdPlacetrap)
    {
        CreateButtonImage(jRow, "isk_settrap", "btn_cmd_place_trap", 35.0f, 35.0f, 0.0, "btn_cmd_place_trap_tooltip");
        fButtons += 1.0;
    }
    if(bBuffShort)
    {
        CreateButtonImage(jRow, "ir_cantrips", "btn_buff_short", 35.0f, 35.0f, 0.0, "btn_buff_short_tooltip");
        fButtons += 1.0;
    }
    if(bBuffLong)
    {
        CreateButtonImage(jRow, "ir_cast", "btn_buff_long", 35.0f, 35.0f, 0.0, "btn_buff_long_tooltip");
        fButtons += 1.0;
    }
    if(bBuffAll)
    {
        CreateButtonImage(jRow, "ir_level789", "btn_buff_all", 35.0f, 35.0f, 0.0, "btn_buff_all_tooltip");
        fButtons += 1.0;
    }
    if(bBuffRest)
    {
        CreateButtonImage(jRow, "ir_rest", "btn_buff_rest", 35.0f, 35.0f, 0.0, "btn_buff_rest_tooltip");
        fButtons += 1.0;
    }
    //int bUsingPCAI = ResManGetAliasFor("xx_pc_1_hb", RESTYPE_NCS) != "";
    int bIsPC = ai_GetIsCharacter(oAssociate);
    //if(bUsingPCAI || !bIsPC)
    //{
        if(bAI)
        {
            CreateButtonImage(jRow, "ir_cmbtinfo", "btn_ai", 35.0f, 35.0f, 0.0, "btn_ai_tooltip");
            fButtons += 1.0;
        }
        if(bRanged)
        {
            CreateButtonImage(jRow, "ir_archer", "btn_ranged", 35.0f, 35.0f, 0.0, "btn_ranged_tooltip");
            fButtons += 1.0;
        }
        if(bPCFollowMinus)
        {
            CreateButtonImage(jRow, "ief_movedecr", "btn_follow_minus", 35.0f, 35.0f, 0.0, "btn_follow_minus_tooltip");
            fButtons += 1.0;
        }
        if(bPCFollowPlus)
        {
            CreateButtonImage(jRow, "ief_moveincr", "btn_follow_plus", 35.0f, 35.0f, 0.0, "btn_follow_plus_tooltip");
            fButtons += 1.0;
        }
        if(bSearch)
        {
            CreateButtonImage(jRow, "isk_search", "btn_search", 35.0f, 35.0f, 0.0, "btn_search_tooltip");
            fButtons += 1.0;
        }
        if(bStealth)
        {
            CreateButtonImage(jRow, "isk_hide", "btn_stealth", 35.0f, 35.0f, 0.0, "btn_stealth_tooltip");
            fButtons += 1.0;
        }
        if(bPickLocks)
        {
            CreateButtonImage(jRow, "isk_olock", "btn_pick_locks", 35.0f, 35.0f, 0.0, "btn_pick_locks_tooltip");
            fButtons += 1.0;
        }
        if(bBashLocks)
        {
            CreateButtonImage(jRow, "ir_bash", "btn_bash_locks", 35.0f, 35.0f, 0.0, "btn_bash_locks_tooltip");
            fButtons += 1.0;
        }
        if(bTraps)
        {
            CreateButtonImage(jRow, "isk_distrap", "btn_traps", 35.0f, 35.0f, 0.0, "btn_traps_tooltip");
            fButtons += 1.0;
        }
        if(bReduceSpeech)
        {
            CreateButtonImage(jRow, "isk_movsilent", "btn_quiet", 35.0f, 35.0f, 0.0, "btn_quiet_tooltip");
            fButtons += 1.0;
        }
        if(bPCMagicMinus)
        {
            CreateButtonImage(jRow, "ief_skilldecr", "btn_magic_minus", 35.0f, 35.0f, 0.0, "btn_m_minus_tooltip");
            fButtons += 1.0;
        }
        if(bPCMagicPlus)
        {
            CreateButtonImage(jRow, "ief_skillincr", "btn_magic_plus", 35.0f, 35.0f, 0.0, "btn_m_plus_tooltip");
            fButtons += 1.0;
        }
        if(bNoMagic)
        {
            CreateButtonImage(jRow, "ir_cntrspell", "btn_no_magic", 35.0f, 35.0f, 0.0, "btn_no_magic_tooltip");
            fButtons += 1.0;
        }
        if(bAllMagic)
        {
            CreateButtonImage(jRow, "ir_splbook", "btn_all_magic", 35.0f, 35.0f, 0.0, "btn_all_magic_tooltip");
            fButtons += 1.0;
        }
        if(bDefMagic)
        {
            CreateButtonImage(jRow, "ir_orisons", "btn_def_magic", 35.0f, 35.0f, 0.0, "btn_def_magic_tooltip");
            fButtons += 1.0;
        }
        if(bOffMagic)
        {
            CreateButtonImage(jRow, "ir_metamagic", "btn_off_magic", 35.0f, 35.0f, 0.0, "btn_off_magic_tooltip");
            fButtons += 1.0;
        }
        if(bLoot)
        {
            CreateButtonImage(jRow, "ir_barter", "btn_loot", 35.0f, 35.0f, 0.0, "btn_loot_tooltip");
            fButtons += 1.0;
        }
        if(bSpontaneous)
        {
            CreateButtonImage(jRow, "ir_xability", "btn_spontaneous", 35.0f, 35.0f, 0.0, "btn_spontaneous_tooltip");
            fButtons += 1.0;
        }
        if(bHealOutMinus)
        {
            CreateButtonImage(jRow, "ief_savedecr", "btn_heal_out_minus", 35.0f, 35.0f, 0.0, "btn_heal_out_minus_tooltip");
            fButtons += 1.0;
        }
        if(bHealOutPlus)
        {
            CreateButtonImage(jRow, "ief_saveincr", "btn_heal_out_plus", 35.0f, 35.0f, 0.0, "btn_heal_out_plus_tooltip");
            fButtons += 1.0;
        }
        if(bHealInMinus)
        {
            CreateButtonImage(jRow, "ief_srdecr", "btn_heal_in_minus", 35.0f, 35.0f, 0.0, "btn_heal_in_minus_tooltip");
            fButtons += 1.0;
        }
        if(bHealInPlus)
        {
            CreateButtonImage(jRow, "ief_srincr", "btn_heal_in_plus", 35.0f, 35.0f, 0.0, "btn_heal_in_plus_tooltip");
            fButtons += 1.0;
        }
        if(bSelfHealOnOff)
        {
            CreateButtonImage(jRow, "ir_heal", "btn_heals_onoff", 35.0f, 35.0f, 0.0, "btn_heals_onoff_tooltip");
            fButtons += 1.0;
        }
        if(bPartyHealOnOff)
        {
            CreateButtonImage(jRow, "ir_party", "btn_healp_onoff", 35.0f, 35.0f, 0.0, "btn_healp_onoff_tooltip");
            fButtons += 1.0;
        }
        if(bLootRangeMinus)
        {
            CreateButtonImage(jRow, "ief_skilldecr", "btn_loot_range_minus", 35.0f, 35.0f, 0.0, "btn_lootr_minus_tooltip");
            fButtons += 1.0;
        }
        if(bLootRangePlus)
        {
            CreateButtonImage(jRow, "ief_skillincr", "btn_loot_range_plus", 35.0f, 35.0f, 0.0, "btn_lootr_plus_tooltip");
            fButtons += 1.0;
        }
        if(bLockRangeMinus)
        {
            CreateButtonImage(jRow, "ief_skilldecr", "btn_lock_range_minus", 35.0f, 35.0f, 0.0, "btn_lockr_minus_tooltip");
            fButtons += 1.0;
        }
        if(bLockRangePlus)
        {
            CreateButtonImage(jRow, "ief_skillincr", "btn_lock_range_plus", 35.0f, 35.0f, 0.0, "btn_lockr_plus_tooltip");
            fButtons += 1.0;
        }
        if(bTrapRangeMinus)
        {
            CreateButtonImage(jRow, "ief_skilldecr", "btn_trap_range_minus", 35.0f, 35.0f, 0.0, "btn_trapr_minus_tooltip");
            fButtons += 1.0;
        }
        if(bTrapRangePlus)
        {
            CreateButtonImage(jRow, "ief_skillincr", "btn_trap_range_plus", 35.0f, 35.0f, 0.0, "btn_trapr_plus_tooltip");
            fButtons += 1.0;
        }
    //}
    if(bIsPC)
    {
        // Plug in buttons *********************************************************
        int nIndex;
        string sIndex;
        json jPlugins = ai_GetAssociateDbJson(oPC, "pc", "plugins");
        json jScript = JsonArrayGet(jPlugins, nIndex);
        while(JsonGetType(jScript) != JSON_TYPE_NULL)
        {
            sIndex = IntToString(nIndex + 1);
            CreateButtonImage(jRow, "is_summon" + sIndex, "btn_exe_plugin_" + sIndex, 35.0f, 35.0f, 0.0, "btn_exe_plugin_" + sIndex + "_tooltip");
            fButtons += 1.0;
            jScript = JsonArrayGet(jPlugins, ++nIndex);
        }
    }
    if(fButtons > 1.0f) fWidth = fWidth + ((fButtons - 1.0) * 39.0f);
    // Add the row to the column.
    json jCol = JsonArray();
    JsonArrayInsertInplace(jCol, NuiRow(jRow));
    // Get the window location to restore it from the database.
    json jGeometry = ai_GetAssociateDbJson(oPC, sAssociateType, "locations");
    // Looks for legacy saves.
    float fX = JsonGetFloat(JsonObjectGet(jGeometry, "x"));
    float fY = JsonGetFloat(JsonObjectGet(jGeometry, "y"));
    float fGUI_Scale = IntToFloat(GetPlayerDeviceProperty(oPC, PLAYER_DEVICE_PROPERTY_GUI_SCALE)) / 100.0;
    if(fGUI_Scale == 0.0) fGUI_Scale = 1.0;
    if(bAIWidgetLock)
    {
        fX = fX + 4.0f;
        fY = fY + 37.0f;
    }
    else if(fY == 1.0 && fY == 1.0)
    {
        if(sAssociateType == "pc") fY = 1.0;
        else if(sAssociateType == "familiar") fY = 651.0;
        else if(sAssociateType == "companion") fY = 744.0;
        else if(sAssociateType == "summons") fY = 837.0;
        else if(sAssociateType == "dominated") fY = 930.0;
        else
        {
            int nIndex = 1;
            string sAssociateName = GetName(oAssociate);
            while(nIndex < 7)
            {
                if(sAssociateName == GetName(GetAssociate(ASSOCIATE_TYPE_HENCHMAN, oPC, nIndex)))
                {
                    fY = 68.0 + 28.0 * IntToFloat(nIndex);
                    break;
                }
                nIndex++;
            }
        }
        fY = fY * fGUI_Scale;
    }
    // Set the layout of the window.
    json jLayout = NuiCol(jCol);
    int nToken;
    string sHeal, sText;
    string sName = GetName(oAssociate);
    if(GetStringRight(sName, 1) == "s") sName = sName + "'";
    else sName = sName + "'s";
    if(bAIWidgetLock) nToken = SetWindow(oPC, jLayout, sAssociateType + "_widget", "AI Widget", fX, fY, fWidth + 8.0f, fHeight, FALSE, FALSE, FALSE, TRUE, FALSE, "0e_nui");
    else nToken = SetWindow(oPC, jLayout, sAssociateType + "_widget", sName + " Widget", fX, fY, fWidth + 12.0f, fHeight, FALSE, FALSE, FALSE, TRUE, TRUE, "0e_nui");
    // Save the associate to the nui.
    json jData = JsonArray();
    JsonArrayInsertInplace(jData, JsonString(ObjectToString(oAssociate)));
    NuiSetUserData(oPC, nToken, jData);
    // Set event watches for window inspector and save window location.
    NuiSetBindWatch(oPC, nToken, "window_geometry", TRUE);
    // Set the buttons to show events.
    NuiSetBind(oPC, nToken, "btn_open_main_image", JsonString(GetPortraitResRef(oAssociate) + "s"));
    NuiSetBind(oPC, nToken, "btn_open_main_event", JsonBool(TRUE));
    NuiSetBind(oPC, nToken, "btn_open_main_tooltip", JsonString("  " + sName + " widget menu"));
    if(bIsPC) sText = "  All associates";
    else sText = "  " + GetName(oAssociate);
    if(bCmdAction)
    {
        NuiSetBind(oPC, nToken, "btn_cmd_action_event", JsonBool(TRUE));
        NuiSetBind(oPC, nToken, "btn_cmd_action_tooltip", JsonString(sText + " enter action mode"));
    }
    if(bCmdGuard)
    {
        NuiSetBind(oPC, nToken, "btn_cmd_guard_event", JsonBool(TRUE));
        NuiSetBind(oPC, nToken, "btn_cmd_guard_tooltip", JsonString(sText + " guard me"));
    }
    if(bCmdHold)
    {
        NuiSetBind(oPC, nToken, "btn_cmd_hold_event", JsonBool(TRUE));
        NuiSetBind(oPC, nToken, "btn_cmd_hold_tooltip", JsonString(sText + " stand ground"));
    }
    if(bCmdAttack)
    {
        NuiSetBind(oPC, nToken, "btn_cmd_attack_event", JsonBool(TRUE));
        NuiSetBind(oPC, nToken, "btn_cmd_attack_tooltip", JsonString(sText + " enter normal mode"));
    }
    if(bCmdFollow)
    {
        NuiSetBind(oPC, nToken, "btn_cmd_follow_event", JsonBool(TRUE));
        NuiSetBind(oPC, nToken, "btn_cmd_follow_tooltip", JsonString(sText + " follow target"));
    }
    if(bFollowTarget)
    {
        NuiSetBind(oPC, nToken, "btn_follow_target_event", JsonBool(TRUE));
        object oTarget = GetLocalObject(oAssociate, AI_FOLLOW_TARGET);
        string sTarget;
        if(oTarget != OBJECT_INVALID) sTarget = GetName(oTarget);
        else
        {
            if(ai_GetIsCharacter(oAssociate)) sTarget = "nobody";
            else sTarget = GetName(oPC);
        }
        NuiSetBind(oPC, nToken, "btn_follow_target_tooltip", JsonString("  " + GetName(oAssociate) + " following " + sTarget));
    }
    if(bCmdAIScript)
    {
        sText = "  Using normal tactics";
        if(ResManGetAliasFor("0e_ch_1_hb", RESTYPE_NCS) != "")
        {
            string sScript = GetLocalString(oAssociate, AI_COMBAT_SCRIPT);
            if(sScript == "ai_a_ambusher") sText = "  Using ambush tactics";
            else if(sScript == "ai_a_peaceful") sText = "  Using peaceful tactics";
            else if(sScript == "ai_a_defensive") sText = "  Using defensive tactics";
            else if(sScript == "ai_a_ranged") sText = "  Using ranged tactics";
            else if(sScript == "ai_a_cntrspell") sText = "  Using counter spell tactics";
        }
        else
        {
            if(GetCombatCondition(X0_COMBAT_FLAG_AMBUSHER, oAssociate)) sText = "Using ambush tactics";
            if(GetCombatCondition(X0_COMBAT_FLAG_COWARDLY, oAssociate)) sText = "Using coward tactics";
            if(GetCombatCondition(X0_COMBAT_FLAG_DEFENSIVE, oAssociate)) sText = "Using defensive tactics";
            if(GetCombatCondition(X0_COMBAT_FLAG_RANGED, oAssociate)) sText = "Using ranged tactics";
        }
        NuiSetBind(oPC, nToken, "btn_cmd_ai_script_event", JsonBool(TRUE));
        NuiSetBind(oPC, nToken, "btn_cmd_ai_script_tooltip", JsonString(sText));
    }
    if(bCmdPlacetrap)
    {
        NuiSetBind(oPC, nToken, "btn_cmd_place_trap_event", JsonBool(TRUE));
        NuiSetBind(oPC, nToken, "btn_cmd_place_trap_tooltip", JsonString("    Place a trap at the location selected"));
    }
    if(bBuffShort)
    {
        NuiSetBind(oPC, nToken, "btn_buff_short_event", JsonBool(TRUE));
        NuiSetBind(oPC, nToken, "btn_buff_short_tooltip", JsonString("  Buff the party with short duration spells"));
    }
    if(bBuffLong)
    {
        NuiSetBind(oPC, nToken, "btn_buff_long_event", JsonBool(TRUE));
        NuiSetBind(oPC, nToken, "btn_buff_long_tooltip", JsonString("  Buff the party with long duration spells"));
    }
    if(bBuffAll)
    {
        NuiSetBind(oPC, nToken, "btn_buff_all_event", JsonBool(TRUE));
        NuiSetBind(oPC, nToken, "btn_buff_all_tooltip", JsonString("  Buff the party with all our defensive spells"));
    }
    if(bBuffRest)
    {
        NuiSetBind(oPC, nToken, "btn_buff_rest_event", JsonBool(TRUE));
        if(ai_GetMagicMode(oAssociate, AI_MAGIC_BUFF_AFTER_REST)) sText = "  Turn buffing after resting off";
        else sText = "  Turn buffing after resting on.";
        NuiSetBind(oPC, nToken, "btn_buff_rest_tooltip", JsonString(sText));
    }
    //if(bUsingPCAI || !bIsPC)
    //{
        if(bAI)
        {
            NuiSetBind(oPC, nToken, "btn_ai_event", JsonBool(TRUE));
            if(GetEventScript(oAssociate, EVENT_SCRIPT_CREATURE_ON_HEARTBEAT) == "xx_pc_1_hb") sText = "  AI [On] Turn off";
            else sText = "  AI [Off] Turn on";
            NuiSetBind(oPC, nToken, "btn_ai_tooltip", JsonString(sText));
        }
        if(bRanged)
        {
            NuiSetBind(oPC, nToken, "btn_ranged_event", JsonBool(TRUE));
            if(ai_GetAIMode(oAssociate, AI_MODE_STOP_RANGED)) sText = "  Ranged [Off] Turn on";
            else sText = "  Ranged [On] Turn off";
            NuiSetBind(oPC, nToken, "btn_ranged_tooltip", JsonString(sText));
        }
        if(bPCFollowMinus)
        {
            NuiSetBind(oPC, nToken, "btn_follow_minus_event", JsonBool(TRUE));
            float fRange = GetLocalFloat(oAssociate, AI_FOLLOW_RANGE) +
                           StringToFloat(Get2DAString("appearance", "PREFATCKDIST", GetAppearanceType(oAssociate)));
            string sFollow = FloatToString(fRange, 0, 0);
            NuiSetBind(oPC, nToken, "btn_follow_minus_tooltip", JsonString("  Follow distance [" + sFollow + " meters] Decrease"));
        }
        if(bPCFollowPlus)
        {
            NuiSetBind(oPC, nToken, "btn_follow_plus_event", JsonBool(TRUE));
            float fRange = GetLocalFloat(oAssociate, AI_FOLLOW_RANGE) +
                           StringToFloat(Get2DAString("appearance", "PREFATCKDIST", GetAppearanceType(oAssociate)));
            string sFollow = FloatToString(fRange, 0, 0);
            NuiSetBind(oPC, nToken, "btn_follow_plus_tooltip", JsonString("  Follow distance [" + sFollow + " meters] Increase"));
        }
        if(bSearch)
        {
            NuiSetBind(oPC, nToken, "btn_search_event", JsonBool(TRUE));
            if(ai_GetAIMode(oAssociate, AI_MODE_AGGRESSIVE_SEARCH)) sText = "  Search [On] Turn off";
            else sText = "  Search [Off] Turn on";
            NuiSetBind(oPC, nToken, "btn_search_tooltip", JsonString(sText));
        }
        if(bStealth)
        {
            NuiSetBind(oPC, nToken, "btn_stealth_event", JsonBool(TRUE));
            if(ai_GetAIMode(oAssociate, AI_MODE_AGGRESSIVE_STEALTH)) sText = "  Stealth [On] Turn off";
            else sText = "  Stealth [Off] Turn on";
            NuiSetBind(oPC, nToken, "btn_stealth_tooltip", JsonString(sText));
        }
        if(bPickLocks)
        {
            NuiSetBind(oPC, nToken, "btn_pick_locks_event", JsonBool(TRUE));
            if(ai_GetAIMode(oAssociate, AI_MODE_PICK_LOCKS)) sText = "  Pick locks [On] Turn off";
            else sText = "  Pick Locks [Off] Turn on";
            NuiSetBind(oPC, nToken, "btn_pick_locks_tooltip", JsonString(sText));
        }
        if(bBashLocks)
        {
            NuiSetBind(oPC, nToken, "btn_bash_locks_event", JsonBool(TRUE));
            if(ai_GetAIMode(oAssociate, AI_MODE_BASH_LOCKS)) sText = "  Bash locks [On] Turn off";
            else sText = "  Bash Locks [Off] Turn on";
            NuiSetBind(oPC, nToken, "btn_bash_locks_tooltip", JsonString(sText));
        }
        if(bTraps)
        {
            NuiSetBind(oPC, nToken, "btn_traps_event", JsonBool(TRUE));
            if(ai_GetAIMode(oAssociate, AI_MODE_DISARM_TRAPS)) sText = "  Disable Traps [On] Turn off";
            else sText = "  Disable Traps [Off] Turn on";
            NuiSetBind(oPC, nToken, "btn_traps_tooltip", JsonString(sText));
        }
        if(bReduceSpeech)
        {
            NuiSetBind(oPC, nToken, "btn_quiet_event", JsonBool(TRUE));
            if(ai_GetAIMode(oAssociate, AI_MODE_DO_NOT_SPEAK)) sText = "  Reduce Speech [On] Turn off";
            else sText = "  Reduce Speech [Off] Turn on";
            NuiSetBind(oPC, nToken, "btn_quiet_tooltip", JsonString(sText));
        }
        if(bPCMagicMinus)
        {
            NuiSetBind(oPC, nToken, "btn_magic_minus_event", JsonBool(TRUE));
            string sMagic = IntToString(GetLocalInt(oAssociate, AI_DIFFICULTY_ADJUSTMENT));
            NuiSetBind(oPC, nToken, "btn_m_minus_tooltip", JsonString(" Magic use [" + sMagic + "] Decrease"));
        }
        if(bPCMagicPlus)
        {
            NuiSetBind(oPC, nToken, "btn_magic_plus_event", JsonBool(TRUE));
            string sMagic = IntToString(GetLocalInt(oAssociate, AI_DIFFICULTY_ADJUSTMENT));
            NuiSetBind(oPC, nToken, "btn_m_plus_tooltip", JsonString("  Magic use [" + sMagic + "] Increase"));
        }
        if(bNoMagic)
        {
            NuiSetBind(oPC, nToken, "btn_no_magic_event", JsonBool(TRUE));
            NuiSetBind(oPC, nToken, "btn_no_magic_tooltip", JsonString("  Turn magic use off"));
        }
        if(bAllMagic)
        {
            NuiSetBind(oPC, nToken, "btn_all_magic_event", JsonBool(TRUE));
            NuiSetBind(oPC, nToken, "btn_all_magic_tooltip", JsonString("  Use any magic"));
        }
        if(bDefMagic)
        {
            NuiSetBind(oPC, nToken, "btn_def_magic_event", JsonBool(TRUE));
            NuiSetBind(oPC, nToken, "btn_def_magic_tooltip", JsonString("  Use defensive magic only"));
        }
        if(bOffMagic)
        {
            NuiSetBind(oPC, nToken, "btn_off_magic_event", JsonBool(TRUE));
            NuiSetBind(oPC, nToken, "btn_off_magic_tooltip", JsonString("  Use offensive magic only"));
        }
        if(bLoot)
        {
            string sLoot = "  [Off] Turn on looting";
            if(ai_GetAIMode(oAssociate, AI_MODE_PICKUP_ITEMS)) sLoot = "  [On] Turn off looting";
            NuiSetBind(oPC, nToken, "btn_loot_event", JsonBool(TRUE));
            NuiSetBind(oPC, nToken, "btn_loot_tooltip", JsonString(sLoot));
        }
        if(bSpontaneous)
        {
            string sCasting = "  [On] Turn off Spontaneous casting";
            if(ai_GetMagicMode(oAssociate, AI_MAGIC_NO_SPONTANEOUS_CURE)) sCasting = "  [Off] Turn on Spontaneous casting";
            NuiSetBind(oPC, nToken, "btn_spontaneous_event", JsonBool(TRUE));
            NuiSetBind(oPC, nToken, "btn_spontaneous_tooltip", JsonString(sCasting));
        }
        if(bHealOutMinus)
        {
            NuiSetBind(oPC, nToken, "btn_heal_out_minus_event", JsonBool(TRUE));
            sHeal = IntToString(GetLocalInt(oAssociate, AI_HEAL_OUT_OF_COMBAT_LIMIT));
            sText = "  Will heal at or below [" + sHeal + "%] health out of combat";
            NuiSetBind(oPC, nToken, "btn_heal_out_minus_tooltip", JsonString(sText));
        }
        if(bHealOutPlus)
        {
            NuiSetBind(oPC, nToken, "btn_heal_out_plus_event", JsonBool(TRUE));
            sHeal = IntToString(GetLocalInt(oAssociate, AI_HEAL_OUT_OF_COMBAT_LIMIT));
            sText = "  Will heal at or below [" + sHeal + "%] health out of combat";
            NuiSetBind(oPC, nToken, "btn_heal_out_plus_tooltip", JsonString(sText));
        }
        if(bHealInMinus)
        {
            NuiSetBind(oPC, nToken, "btn_heal_in_minus_event", JsonBool(TRUE));
            sHeal = IntToString(GetLocalInt(oAssociate, AI_HEAL_IN_COMBAT_LIMIT));
            sText = "  Will heal at or below [" + sHeal + "%] health in combat";
            NuiSetBind(oPC, nToken, "btn_heal_in_minus_tooltip", JsonString(sText));
        }
        if(bHealInPlus)
        {
            NuiSetBind(oPC, nToken, "btn_heal_in_plus_event", JsonBool(TRUE));
            sHeal = IntToString(GetLocalInt(oAssociate, AI_HEAL_IN_COMBAT_LIMIT));
            sText = "  Will heal at or below [" + sHeal + "%] health in combat";
            NuiSetBind(oPC, nToken, "btn_heal_in_plus_tooltip", JsonString(sText));
        }
        if(bSelfHealOnOff)
        {
            NuiSetBind(oPC, nToken, "btn_heals_onoff_event", JsonBool(TRUE));
            if(ai_GetAIMode(oAssociate, AI_MODE_SELF_HEALING_OFF)) sText = "  Self healing is [Off] turn on";
            else sText = "  Self healing is [On] turn off";
            NuiSetBind(oPC, nToken, "btn_heals_onoff_tooltip", JsonString(sText));
        }
        if(bPartyHealOnOff)
        {
            NuiSetBind(oPC, nToken, "btn_healp_onoff_event", JsonBool(TRUE));
            if(ai_GetAIMode(oAssociate, AI_MODE_PARTY_HEALING_OFF)) sText = "  Party healing is [Off] turn on";
            else sText = "  Party healing is [On] turn off";
            NuiSetBind(oPC, nToken, "btn_healp_onoff_tooltip", JsonString(sText));
        }
        if(bLootRangeMinus)
        {
            NuiSetBind(oPC, nToken, "btn_loot_range_minus_event", JsonBool(TRUE));
            string sRange = FloatToString(GetLocalFloat(oAssociate, AI_LOOT_CHECK_RANGE), 0, 0);
            NuiSetBind(oPC, nToken, "btn_lootr_minus_tooltip", JsonString("  Loot range [" + sRange + "] Decrease"));
        }
        if(bLootRangePlus)
        {
            NuiSetBind(oPC, nToken, "btn_loot_range_plus_event", JsonBool(TRUE));
            string sRange = FloatToString(GetLocalFloat(oAssociate, AI_LOOT_CHECK_RANGE), 0, 0);
            NuiSetBind(oPC, nToken, "btn_lootr_plus_tooltip", JsonString("  Loot range [" + sRange + "] Increase"));
        }
        if(bLockRangeMinus)
        {
            NuiSetBind(oPC, nToken, "btn_lock_range_minus_event", JsonBool(TRUE));
            string sRange = FloatToString(GetLocalFloat(oAssociate, AI_LOCK_CHECK_RANGE), 0, 0);
            NuiSetBind(oPC, nToken, "btn_lockr_minus_tooltip", JsonString("  Lock range [" + sRange + "] Decrease"));
        }
        if(bLockRangePlus)
        {
            NuiSetBind(oPC, nToken, "btn_lock_range_plus_event", JsonBool(TRUE));
            string sRange = FloatToString(GetLocalFloat(oAssociate, AI_LOCK_CHECK_RANGE), 0, 0);
            NuiSetBind(oPC, nToken, "btn_lockr_plus_tooltip", JsonString("  Lock range [" + sRange + "] Increase"));
        }
        if(bTrapRangeMinus)
        {
            NuiSetBind(oPC, nToken, "btn_trap_range_minus_event", JsonBool(TRUE));
            string sRange = FloatToString(GetLocalFloat(oAssociate, AI_TRAP_CHECK_RANGE), 0, 0);
            NuiSetBind(oPC, nToken, "btn_trapr_minus_tooltip", JsonString("  Trap range [" + sRange + "] Decrease"));
        }
        if(bTrapRangePlus)
        {
            NuiSetBind(oPC, nToken, "btn_trap_range_plus_event", JsonBool(TRUE));
            string sRange = FloatToString(GetLocalFloat(oAssociate, AI_TRAP_CHECK_RANGE), 0, 0);
            NuiSetBind(oPC, nToken, "btn_trapr_plus_tooltip", JsonString("  Trap range [" + sRange + "] Increase"));
        }
    //}
    if(bIsPC)
    {
        int nIndex;
        string sIndex, sText, sScript;
        json jPlugins = ai_GetAssociateDbJson(oPC, "pc", "plugins");
        json jScript = JsonArrayGet(jPlugins, nIndex);
        while(JsonGetType(jScript) != JSON_TYPE_NULL)
        {
            sIndex = IntToString(nIndex + 1);
            sScript = JsonGetString(jScript);
            if(ResManGetAliasFor(sScript, RESTYPE_NCS) == "") sText = "  " + sScript + " not found by ResMan!";
            else sText = "  Executes " + sScript + " plugin";
            NuiSetBind(oPC, nToken, "btn_exe_plugin_" + sIndex + "_event", JsonBool (TRUE));
            NuiSetBind(oPC, nToken, "btn_exe_plugin_" + sIndex + "_tooltip", JsonString(sText));
            jScript = JsonArrayGet(jPlugins, ++nIndex);
        }
    }
}
void ai_CreateLootFilterRow(json jRow, string sLabel, int nIndex)
{
    string sIndex = IntToString(nIndex);
    JsonArrayInsertInplace(jRow, NuiSpacer());
    CreateTextEditBox(jRow, "plc_hold", "txt_gold_" + sIndex, 9, FALSE, 90.0, 20.0);
    JsonArrayInsertInplace(jRow, NuiSpacer());
    CreateCheckBox(jRow, sLabel, "chbx_" + sIndex, 150.0, 20.0);
    JsonArrayInsertInplace(jRow, NuiSpacer());
}
void ai_SetupLootElements(object oPC, object oAssociate, int nToken, int nLootBit, int nIndex)
{
    string sIndex = IntToString(nIndex);
    int bLoot = ai_GetLootFilter(oAssociate, nLootBit);
    NuiSetBind(oPC, nToken, "chbx_" + sIndex + "_check", JsonBool(bLoot));
    NuiSetBindWatch (oPC, nToken, "chbx_" + sIndex + "_check", TRUE);
    string sGold = IntToString(GetLocalInt(oAssociate, AI_MIN_GOLD_ + sIndex));
    NuiSetBind(oPC, nToken, "txt_gold_" + sIndex, JsonString(sGold));
    NuiSetBindWatch (oPC, nToken, "txt_gold_" + sIndex, TRUE);
}
void ai_CreateLootFilterNUI(object oPC, object oAssociate)
{
    // ************************************************************************* Width / Height
    // Row 1 ******************************************************************* 318 / 73
    int bIsPC = ai_GetIsCharacter(oAssociate);
    json jRow = JsonArray();
    CreateButton(jRow, "Set All", "btn_set_all", 110.0, 20.0);
    JsonArrayInsertInplace(jRow, NuiSpacer());
    CreateButton(jRow, "Clear All", "btn_clear_all", 110.0, 20.0);
    // Add row to the column.
    json jCol = JsonArray();
    JsonArrayInsertInplace(jCol, NuiRow(jRow));
    // Row 2 *************************************************************** 388 / 101
    jRow = JsonArray();
    JsonArrayInsertInplace(jRow, NuiSpacer());
    CreateLabel(jRow, "Max Weight to pickup:", "lbl_weight", 180.0, 20.0, NUI_HALIGN_CENTER);
    CreateTextEditBox(jRow, "plc_hold", "txt_max_weight", 9, FALSE, 50.0, 20.0, "txt_max_weight_tooltip");
    JsonArrayInsertInplace(jRow, NuiSpacer());
    // Add row to the column.
    JsonArrayInsertInplace(jCol, NuiRow(jRow));
    // Row 2 *************************************************************** 388 / 101
    jRow = JsonArray();
    JsonArrayInsertInplace(jRow, NuiSpacer());
    CreateLabel(jRow, "Minimum Gold", "lbl_min_gold", 100.0, 20.0, NUI_HALIGN_CENTER);
    JsonArrayInsertInplace(jRow, NuiSpacer());
    CreateLabel(jRow, "Items to Pickup", "lbl_pickup", 140.0, 20.0, NUI_HALIGN_CENTER);
    JsonArrayInsertInplace(jRow, NuiSpacer());
    // Add row to the column.
    JsonArrayInsertInplace(jCol, NuiRow(jRow));
    // Row 3 *************************************************************** 388 / 129
    jRow = JsonArray();
    ai_CreateLootFilterRow(jRow, "Plot items", 2);
    // Add row to the column.
    JsonArrayInsertInplace(jCol, NuiRow(jRow));
    // Row 4 *************************************************************** 388 / 157
    jRow = JsonArray();
    ai_CreateLootFilterRow(jRow, "Armor", 3);
    // Add row to the column.
    JsonArrayInsertInplace(jCol, NuiRow(jRow));
    // Row 5 *************************************************************** 388 / 185
    jRow = JsonArray();
    ai_CreateLootFilterRow(jRow, "Belts", 4);
    // Add row to the column.
    JsonArrayInsertInplace(jCol, NuiRow(jRow));
    // Row 6 *************************************************************** 388 / 213
    jRow = JsonArray();
    ai_CreateLootFilterRow(jRow, "Boots", 5);
    // Add row to the column.
    JsonArrayInsertInplace(jCol, NuiRow(jRow));
    // Row 7 *************************************************************** 388 / 241
    jRow = JsonArray();
    ai_CreateLootFilterRow(jRow, "Cloaks", 6);
    // Add row to the column.
    JsonArrayInsertInplace(jCol, NuiRow(jRow));
    // Row 8 *************************************************************** 388 / 269
    jRow = JsonArray();
    ai_CreateLootFilterRow(jRow, "Gems", 7);
    // Add row to the column.
    JsonArrayInsertInplace(jCol, NuiRow(jRow));
    // Row 9 *************************************************************** 388 / 297
    jRow = JsonArray();
    ai_CreateLootFilterRow(jRow, "Gloves and Bracers", 8);
    // Add row to the column.
    JsonArrayInsertInplace(jCol, NuiRow(jRow));
    // Row 10 *************************************************************** 388 / 325
    jRow = JsonArray();
    ai_CreateLootFilterRow(jRow, "Headgear", 9);
    // Add row to the column.
    JsonArrayInsertInplace(jCol, NuiRow(jRow));
    // Row 11 *************************************************************** 388 / 353
    jRow = JsonArray();
    ai_CreateLootFilterRow(jRow, "Jewelry", 10);
    // Add row to the column.
    JsonArrayInsertInplace(jCol, NuiRow(jRow));
    // Row 12 *************************************************************** 388 / 381
    jRow = JsonArray();
    ai_CreateLootFilterRow(jRow, "Miscellaneous items", 11);
    // Add row to the column.
    JsonArrayInsertInplace(jCol, NuiRow(jRow));
    // Row 13 *************************************************************** 388 / 409
    jRow = JsonArray();
    ai_CreateLootFilterRow(jRow, "Potions", 12);
    // Add row to the column.
    JsonArrayInsertInplace(jCol, NuiRow(jRow));
    // Row 14 *************************************************************** 388 / 437
    jRow = JsonArray();
    ai_CreateLootFilterRow(jRow, "Scrolls", 13);
    // Add row to the column.
    JsonArrayInsertInplace(jCol, NuiRow(jRow));
    // Row 15 *************************************************************** 388 / 465
    jRow = JsonArray();
    ai_CreateLootFilterRow(jRow, "Shields", 14);
    // Add row to the column.
    JsonArrayInsertInplace(jCol, NuiRow(jRow));
    // Row 16 *************************************************************** 388 / 493
    jRow = JsonArray();
    ai_CreateLootFilterRow(jRow, "Wands, Rods, and Staves", 15);
    // Add row to the column.
    JsonArrayInsertInplace(jCol, NuiRow(jRow));
    // Row 17 ************************************************************** 388 / 521
    jRow = JsonArray();
    ai_CreateLootFilterRow(jRow, "Weapons", 16);
    // Add row to the column.
    JsonArrayInsertInplace(jCol, NuiRow(jRow));
    // Row 18 ************************************************************** 388 / 549
    jRow = JsonArray();
    ai_CreateLootFilterRow(jRow, "Arrows", 17);
    // Add row to the column.
    JsonArrayInsertInplace(jCol, NuiRow(jRow));
    // Row 18 ************************************************************** 388 / 577
    jRow = JsonArray();
    ai_CreateLootFilterRow(jRow, "Bolts", 18);
    // Add row to the column.
    JsonArrayInsertInplace(jCol, NuiRow(jRow));
    // Row 19 ************************************************************** 388 / 605
    jRow = JsonArray();
    ai_CreateLootFilterRow(jRow, "Bullets", 19);
    // Add row to the column.
    JsonArrayInsertInplace(jCol, NuiRow(jRow));
    float fHeight = 605.0;
    // Set the Layout of the window.
    json jLayout = NuiCol(jCol);
    string sText, sName = GetName(oAssociate);
    if(GetStringRight(sName, 1) == "s") sName = sName + "'";
    else sName = sName + "'s";
    string sAssociateType = ai_GetAssociateType(oPC, oAssociate);
    int nToken = SetWindow(oPC, jLayout, sAssociateType + "_loot_menu", sName + " Loot Filter",
                           -1.0, -1.0, 288.0, fHeight + 12.0, FALSE, FALSE, TRUE, FALSE, TRUE, "0e_nui");
    // Save the associate to the nui.
    json jData = JsonArray();
    JsonArrayInsertInplace(jData, JsonString(ObjectToString(oAssociate)));
    NuiSetUserData(oPC, nToken, jData);
    // Set all binds, events, and watches.
    // Row 1
    NuiSetBind(oPC, nToken, "btn_set_all_event", JsonBool (TRUE));
    NuiSetBind(oPC, nToken, "btn_set_all", JsonInt(TRUE));
    NuiSetBind(oPC, nToken, "btn_clear_all_event", JsonBool (TRUE));
    NuiSetBind(oPC, nToken, "btn_clear_all", JsonInt(TRUE));
    // Row 2
    int nWeight = GetLocalInt(oAssociate, AI_MAX_LOOT_WEIGHT);
    if(nWeight == 0)
    {
        nWeight = 200;
        SetLocalInt(oAssociate, AI_MAX_LOOT_WEIGHT, nWeight);
    }
    NuiSetBind(oPC, nToken, "txt_max_weight", JsonString(IntToString(nWeight)));
    NuiSetBindWatch (oPC, nToken, "txt_max_weight", TRUE);
    NuiSetBind(oPC, nToken, "txt_max_weight_tooltip", JsonString("Max weighted item you will pickup from 1 to 1,000"));
    // Row 3
    ai_SetupLootElements(oPC, oAssociate, nToken, AI_LOOT_PLOT, 2);
    // Row 4
    ai_SetupLootElements(oPC, oAssociate, nToken, AI_LOOT_ARMOR, 3);
    // Row 5
    ai_SetupLootElements(oPC, oAssociate, nToken, AI_LOOT_BELTS, 4);
    // Row 6
    ai_SetupLootElements(oPC, oAssociate, nToken, AI_LOOT_BOOTS, 5);
    // Row 7
    ai_SetupLootElements(oPC, oAssociate, nToken, AI_LOOT_CLOAKS, 6);
    // Row 8
    ai_SetupLootElements(oPC, oAssociate, nToken, AI_LOOT_GEMS, 7);
    // Row 9
    ai_SetupLootElements(oPC, oAssociate, nToken, AI_LOOT_GLOVES, 8);
    // Row 10
    ai_SetupLootElements(oPC, oAssociate, nToken, AI_LOOT_HEADGEAR, 9);
    // Row 11
    ai_SetupLootElements(oPC, oAssociate, nToken, AI_LOOT_JEWELRY, 10);
    // Row 12
    ai_SetupLootElements(oPC, oAssociate, nToken, AI_LOOT_MISC, 11);
    // Row 13
    ai_SetupLootElements(oPC, oAssociate, nToken, AI_LOOT_POTIONS, 12);
    // Row 14
    ai_SetupLootElements(oPC, oAssociate, nToken, AI_LOOT_SCROLLS, 13);
    // Row 15
    ai_SetupLootElements(oPC, oAssociate, nToken, AI_LOOT_SHIELDS, 14);
    // Row 16
    ai_SetupLootElements(oPC, oAssociate, nToken, AI_LOOT_WANDS_RODS_STAVES, 15);
    // Row 17
    ai_SetupLootElements(oPC, oAssociate, nToken, AI_LOOT_WEAPONS, 16);
    // Row 18
    ai_SetupLootElements(oPC, oAssociate, nToken, AI_LOOT_ARROWS, 17);
    // Row 19
    ai_SetupLootElements(oPC, oAssociate, nToken, AI_LOOT_BOLTS, 18);
    // Row 20
    ai_SetupLootElements(oPC, oAssociate, nToken, AI_LOOT_BULLETS, 19);
}
void ai_CreateHenchmanPasteButton(object oPC, int nIndex, json jRow)
{
    string sName, sIndex = IntToString(nIndex);
    object oHenchman = GetAssociate(ASSOCIATE_TYPE_HENCHMAN, oPC, nIndex);
    if(oHenchman != OBJECT_INVALID)
    {
        sName = GetName(oHenchman);
        if(GetStringRight(sName, 1) == "s") sName = sName + "'";
        else sName = sName + "'s";
        CreateButton(jRow, sName, "btn_paste_henchman" + sIndex, 220.0, 20.0);
    }
}
void ai_CreatePasteSettingsNUI(object oPC, object oAssociate)
{
    // ************************************************************************* Width / Height
    // Row 1 ******************************************************************* 244 / 73
    string sName = GetName(oAssociate);
    if(GetStringRight(sName, 1) == "s") sName = sName + "'";
    else sName = sName + "'s";
    json jRow = JsonArray();
    JsonArrayInsertInplace(jRow, NuiSpacer());
    CreateLabel(jRow, "Paste settings to", "lbl_paste", 220.0, 20.0, NUI_HALIGN_CENTER);
    JsonArrayInsertInplace(jRow, NuiSpacer());
    // Add row to the column.
    json jCol = JsonArray();
    JsonArrayInsertInplace(jCol, NuiRow(jRow));
    // Row 2 ******************************************************************* 244 / 101
    jRow = JsonArray();
    JsonArrayInsertInplace(jRow, NuiSpacer());
    CreateButton(jRow, "All associates", "btn_paste_all", 220.0, 20.0);
    JsonArrayInsertInplace(jRow, NuiSpacer());
    // Add row to the column.
    JsonArrayInsertInplace(jCol, NuiRow(jRow));
    // Row 2 ******************************************************************* 244 / 101
    jRow = JsonArray();
    JsonArrayInsertInplace(jRow, NuiSpacer());
    CreateButton(jRow, "Familiar", "btn_paste_familiar", 220.0, 20.0);
    JsonArrayInsertInplace(jRow, NuiSpacer());
    // Add row to the column.
    JsonArrayInsertInplace(jCol, NuiRow(jRow));
    // Row 3 ******************************************************************* 244 / 129
    jRow = JsonArray();
    JsonArrayInsertInplace(jRow, NuiSpacer());
    CreateButton(jRow, "Companion", "btn_paste_companion", 220.0, 20.0);
    JsonArrayInsertInplace(jRow, NuiSpacer());
    // Add row to the column.
    JsonArrayInsertInplace(jCol, NuiRow(jRow));
    // Row 4 ******************************************************************* 244 / 157
    jRow = JsonArray();
    JsonArrayInsertInplace(jRow, NuiSpacer());
    CreateButton(jRow, "Summons", "btn_paste_summons", 220.0, 20.0);
    JsonArrayInsertInplace(jRow, NuiSpacer());
    // Add row to the column.
    JsonArrayInsertInplace(jCol, NuiRow(jRow));
    // Row 5+ ****************************************************************** 244 / 185
    float fHeight = 185.0;
    int nIndex;
    for(nIndex = 1; nIndex < 7; nIndex++)
    {
        jRow = JsonArray();
        ai_CreateHenchmanPasteButton(oPC, nIndex, jRow);
        // Add row to the column.
        JsonArrayInsertInplace(jCol, NuiRow(jRow));
        fHeight += 28.0;
    }
    // Set the Layout of the window.
    json jLayout = NuiCol(jCol);
    sName = GetName(oAssociate);
    if(GetStringRight(sName, 1) == "s") sName = sName + "'";
    else sName = sName + "'s";
    string sAssociateType = ai_GetAssociateType(oPC, oAssociate);
    int nToken = SetWindow(oPC, jLayout, sAssociateType + "_paste_menu", sName + " Paste Menu",
                           -1.0, -1.0, 244.0, fHeight + 12.0, FALSE, FALSE, TRUE, FALSE, TRUE, "0e_nui");
    // Save the associate to the nui.
    json jData = JsonArray();
    JsonArrayInsertInplace(jData, JsonString(ObjectToString(oAssociate)));
    NuiSetUserData(oPC, nToken, jData);
    // Set all binds, events, and watches.
    // Row 1
    NuiSetBind(oPC, nToken, "btn_paste_all_event", JsonBool (TRUE));
    object oCreature = GetAssociate(ASSOCIATE_TYPE_FAMILIAR, oPC);
    NuiSetBind(oPC, nToken, "btn_paste_familiar_event", JsonBool(oCreature != oAssociate));
    oCreature = GetAssociate(ASSOCIATE_TYPE_ANIMALCOMPANION, oPC);
    NuiSetBind(oPC, nToken, "btn_paste_companion_event", JsonBool(oCreature != oAssociate));
    oCreature = GetAssociate(ASSOCIATE_TYPE_SUMMONED, oPC);
    NuiSetBind(oPC, nToken, "btn_paste_summons_event", JsonBool(oCreature != oAssociate));
    for(nIndex = 1; nIndex < 7; nIndex++)
    {
        oCreature = GetAssociate(ASSOCIATE_TYPE_HENCHMAN, oPC, 1);
        if(oCreature != OBJECT_INVALID)
        {
            NuiSetBind(oPC, nToken, "btn_paste_henchman" + IntToString(nIndex) + "_event", JsonBool(oCreature != oAssociate));
        }
    }
}
