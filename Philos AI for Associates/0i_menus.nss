/*//////////////////////////////////////////////////////////////////////////////
// Script Name: 0i_menus
////////////////////////////////////////////////////////////////////////////////
 Include script for handling NUI menus.
*///////////////////////////////////////////////////////////////////////////////
#include "0i_nui"
#include "0i_associates"
//#include "0i_assoc_debug"
// Bitwise menu constants for Widget buttons that are used with Get/SetAssociateWidgetButtons().
const string sAssociateWidgetButtonsVarname = "ASSOCIATE_WIDGET_BUTTONS";
const int BTN_WIDGET      = 0x00000001; // Defines if the widget is on the screen or not.
const int BTN_WIDGET_LOCK = 0x00000002; // Locks the widget to the current coordinates.
const int BTN_CMD_GUARD   = 0x00000004; // Command All associates to Guard Me. PC widget only.
const int BTN_CMD_FOLLOW  = 0x00000008; // Command All associates to Follow. PC widget only.
const int BTN_CMD_HOLD    = 0x00000010; // Command All associates to Stand Ground. PC widget only.
const int BTN_CMD_ATTACK  = 0x00000020; // Command All associates to Attack Nearest. PC widget only.
const int BTN_BUFF_REST   = 0x00000040; // Buffs with long duration spells after resting. Associate widget only.
const int BTN_BUFF_SHORT  = 0x00000080; // Buffs with short duration spells.
const int BTN_BUFF_LONG   = 0x00000100; // Buffs with long duration spells.
const int BTN_BUFF_ALL    = 0x00000200; // Buffs with all spells.
// Bitwise menu constants for Associate AI buttons that are used with Get/SetAssociateAIButtons().
const string sAssociateAIButtonsVarname = "ASSOCIATE_AI_BUTTONS";
const int BTN_AI_FOR_PC            = 0x00000001; // PC use AI. PC widget only.
const int BTN_AI_USE_RANGED        = 0x00000002; // AI uses ranged attacks.
const int BTN_AI_USE_SEARCH        = 0x00000004; // AI uses Search.
const int BTN_AI_USE_STEALTH       = 0x00000008; // AI uses Stealth.
const int BTN_AI_REMOVE_TRAPS      = 0x00000010; // AI seeks out and removes traps.
const int BTN_AI_BYPASS_LOCKS      = 0x00000020; // AI will attempt to bypass locks.
const int BTN_AI_MAGIC_USE_PLUS    = 0x00000040; // Increase chance to use magic in battle.
const int BTN_AI_MAGIC_USE_MINUS   = 0x00000080; // Decrease chance to use magic in battle.
const int BTN_AI_NO_MAGIC_USE      = 0x00000100; // Will not use magic in battle.
const int BTN_AI_ALL_MAGIC_USE     = 0x00000200; // Will use all types of magic in battle.
const int BTN_AI_DEF_MAGIC_USE     = 0x00000400; // Will use Defensive spells only in battle.
const int BTN_AI_OFF_MAGIC_USE     = 0x00000800; // Will use Offensive spells only in battle.
const int BTN_AI_PICKUP_NO_LOOT    = 0x00001000; // Will not pickup loot.
const int BTN_AI_PICKUP_ALL_LOOT   = 0x00002000; // Will auto pickup all loot.
const int BTN_AI_PICKUP_GEMS_LOOT  = 0x00004000; // Will auto pickup gems, magic items, and gold.
const int BTN_AI_PICKUP_MAGIC_LOOT = 0x00008000; // Will auto pickup magic items and gold.
const int BTN_AI_HEAL_OUT_PLUS     = 0x00010000; // Will increase minimum hp required before ai heals out of combat.
const int BTN_AI_HEAL_OUT_MINUS    = 0x00020000; // Will decrease minimum hp required before ai heals out of combat.
const int BTN_AI_HEAL_IN_PLUS      = 0x00040000; // Will increase minimum hp required before ai heals in combat.
const int BTN_AI_HEAL_IN_MINUS     = 0x00080000; // Will decrease minimum hp required before ai heals in combat.
const int BTN_AI_STOP_HEALING      = 0x00100000; // Stops AI from using any healing.
// Use by NUI windows to stop saving move states while loading.
const string AI_NO_NUI_SAVE = "AI_NO_NUI_SAVE";
// Maximum number of Plugins allowed on the players widget.
const int WIDGET_MAX_PLUGINS = 5;

// Set one of the BTN_* "Widget" bitwise constants on oPlayer to bValid.
void ai_SetAssociateWidgetButton(object oPlayer, int nButton, string sAssociateType, int bOn = TRUE);
// Return if nButton is set on oPlayer. Uses the BTN_* "Widget" bitwise constants.
int ai_GetAssociateWidgetButton(object oPlayer, int nButton, string sAssociateType);
// Set one of the BTN_AI_*  bitwise constants on oPlayer to bValid.
void ai_SetAssociateAIButton(object oPlayer, int nButton, string sAssociateType, int bOn = TRUE);
// Return if nButton is set on oPlayer. Uses the BTN_AI_* "Widget" bitwise constants.
int ai_GetAssociateAIButton(object oPlayer, int nButton, string sAssociateType);
// Creates the AI options menu.
void ai_CreateAIOptionsNUI(object oPC);
// Creates an associates AI NUI.
void ai_CreateAssociateAINUI(object oPC, object oAssociate);
// Creates the AI Widget.
void ai_CreateAIWidgetNUI(object oPC);

void ai_SetAssociateWidgetButton(object oPlayer, int nButton, string sAssociateType, int bOn = TRUE)
{
    string sVarName = sAssociateWidgetButtonsVarname + sAssociateType;
    int nAssociateWidgetButtons = GetLocalInt(oPlayer, sVarName);
    if(bOn) nAssociateWidgetButtons = nAssociateWidgetButtons | nButton;
    else nAssociateWidgetButtons = nAssociateWidgetButtons & ~nButton;
    SetLocalInt(oPlayer, sVarName, nAssociateWidgetButtons);
}
int ai_GetAssociateWidgetButton(object oPlayer, int nButton, string sAssociateType)
{
    string sVarName = sAssociateWidgetButtonsVarname + sAssociateType;
    return (GetLocalInt(oPlayer, sVarName) & nButton);
}
void ai_SetAssociateAIButton(object oPlayer, int nButton, string sAssociateType, int bOn = TRUE)
{
    string sVarName = sAssociateAIButtonsVarname + sAssociateType;
    int nAssociateAIButtons = GetLocalInt(oPlayer, sVarName);
    if(bOn) nAssociateAIButtons = nAssociateAIButtons | nButton;
    else nAssociateAIButtons = nAssociateAIButtons & ~nButton;
    SetLocalInt(oPlayer, sVarName, nAssociateAIButtons);
}
int ai_GetAssociateAIButton(object oPlayer, int nButton, string sAssociateType)
{
    string sVarName = sAssociateAIButtonsVarname + sAssociateType;
    return (GetLocalInt(oPlayer, sVarName) & nButton);
}
void ai_CreateAIOptionsNUI(object oPC)
{
    // ************************************************************************* Width / Height
    // Row 1 ******************************************************************* 482 / 73
    json jRow = JsonArray();
    JsonArrayInsertInplace(jRow, NuiSpacer());
    CreateLabel(jRow, PHILOS_VERSION, "lbl_version", 400.0f, 20.0f, NUI_HALIGN_CENTER);
    JsonArrayInsertInplace(jRow, NuiSpacer());
    // Add row to the column.
    json jCol = JsonArray();
    JsonArrayInsertInplace(jCol, NuiRow(jRow));
    float fHeight = 73.0;
    if(ResManGetAliasFor("0e_c2_1_hb", RESTYPE_NCS) != "")
    {
        // Row 2 ******************************************************************* 482 / 28
        json jRow = JsonArray();
        JsonArrayInsertInplace(jRow, NuiSpacer());
        CreateLabel(jRow, "Monster AI is loaded.", "monster_ai", 400.0f, 20.0f, NUI_HALIGN_CENTER);
        JsonArrayInsertInplace(jRow, NuiSpacer());
        // Add row to the column.
        JsonArrayInsertInplace(jCol, NuiRow(jRow));
        fHeight += 28.0;
    }
    // Row 3 ******************************************************************* 482 / 28
    jRow = JsonArray();
    JsonArrayInsertInplace(jRow, NuiSpacer());
    CreateButton(jRow, "Familiar Widget", "btn_familiar_widget", 150.0f, 20.0f);
    JsonArrayInsertInplace(jRow, NuiSpacer());
    CreateButton(jRow, "Companion Widget", "btn_companion_widget", 150.0f, 20.0f);
    JsonArrayInsertInplace(jRow, NuiSpacer());
    CreateButton(jRow, "Summons Widget", "btn_summons_widget", 150.0f, 20.0f);
    JsonArrayInsertInplace(jRow, NuiSpacer());
    // Add row to the column.
    JsonArrayInsertInplace(jCol, NuiRow(jRow));
    // Row 4 ******************************************************************* 482 / 56
    jRow = JsonArray();
    JsonArrayInsertInplace(jRow, NuiSpacer());
    CreateButtonSelect(jRow, "Toggle All Associate Widgets On/Off", "btn_toggle_assoc_widget", 300.0f, 20.0f);
    JsonArrayInsertInplace(jRow, NuiSpacer());
    // Add row to the column.
    JsonArrayInsertInplace(jCol, NuiRow(jRow));
    // Row 5 ******************************************************************* 482 / 84
    jRow = JsonArray();
    JsonArrayInsertInplace(jRow, NuiSpacer());
    CreateButton(jRow, "Add Plugin", "btn_add_plugin", 230.0f, 20.0f);
    JsonArrayInsertInplace(jRow, NuiSpacer());
    CreateTextEditBox(jRow, "sPlaceHolder", "txt_plugin", 16, FALSE, 230.0f, 20.0f, "txt_exe_plugin_tooltip");
    JsonArrayInsertInplace(jRow, NuiSpacer());
    // Add row to the column.
    JsonArrayInsertInplace(jCol, NuiRow(jRow));
    // Row 6+ ******************************************************************* 482 / 112
    fHeight += 112.0;
    int nIndex = 1;
    string sIndex = "1";
    string sScript = GetLocalString(oPC, "AI_PLUGIN_SCRIPT_1");
    while (nIndex <= WIDGET_MAX_PLUGINS)
    {
        if(sScript != "")
        {
            jRow = JsonArray();
            JsonArrayInsertInplace(jRow, NuiSpacer());
            CreateButton(jRow, "Remove Plugin", "btn_remove_plugin_" + sIndex, 230.0f, 20.0f);
            JsonArrayInsertInplace(jRow, NuiSpacer());
            CreateLabel(jRow, sScript, "txt_plugin_" + sIndex, 230.0f, 20.0f);
            JsonArrayInsertInplace(jRow, NuiSpacer());
            // Add row to the column.
            JsonArrayInsertInplace(jCol, NuiRow(jRow));
            fHeight += 28.0;
        }
        sIndex = IntToString(++nIndex);
        sScript = GetLocalString(oPC, "AI_PLUGIN_SCRIPT_" + sIndex);
    }
    // Set the Layout of the window.
    json jLayout = NuiCol(jCol);
    string sName = GetName(oPC);
    if(GetStringRight(sName, 1) == "s") sName = sName + "'";
    else sName = sName + "'s";
    int nToken = SetWindow(oPC, jLayout, "ai_main_nui", sName + " PEPS Main Menu",
                             -1.0, -1.0, 482.0f, fHeight + 12.0f, FALSE, FALSE, TRUE, FALSE, TRUE, "0e_nui");
    // Set all binds, events, and watches.
    // Row 1 - Version label.
    // Row 2
    if(ResManGetAliasFor("0e_ch_1_hb", RESTYPE_NCS) != "")
    {
        NuiSetBind(oPC, nToken, "btn_familiar_widget_event", JsonBool(TRUE));
        NuiSetBind(oPC, nToken, "btn_companion_widget_event", JsonBool(TRUE));
        NuiSetBind(oPC, nToken, "btn_summons_widget_event", JsonBool(TRUE));
        // Row 3
        NuiSetBind(oPC, nToken, "btn_toggle_assoc_widget_event", JsonBool(TRUE));
        NuiSetBind(oPC, nToken, "btn_toggle_assoc_widget", JsonInt(!GetLocalInt(oPC, "AI_ASSOCIATE_WIDGET_OFF")));
    }
    // Row 4
    NuiSetBind(oPC, nToken, "btn_add_plugin_event", JsonBool(TRUE));
    NuiSetBind(oPC, nToken, "txt_plugin_event", JsonBool(TRUE));
    // Row 5+
    nIndex = 1;
    sIndex = "1";
    sScript = GetLocalString(oPC, "AI_PLUGIN_SCRIPT_1");
    while (nIndex <= WIDGET_MAX_PLUGINS)
    {
        if(sScript != "")
        {
            NuiSetBind(oPC, nToken, "btn_remove_plugin_" + sIndex + "_event", JsonBool(TRUE));
        }
        sIndex = IntToString(++nIndex);
        sScript = GetLocalString(oPC, "AI_PLUGIN_SCRIPT_" + sIndex);
    }
}
void ai_CreateAssociateAINUI(object oPC, object oAssociate)
{
    // ************************************************************************* Width / Height
    // Row 1 ******************************************************************* 388 / 73
    int bIsPC = ai_GetIsCharacter(oAssociate);
    json jRow = JsonArray();
    CreateButtonSelect(jRow, "Lock Widget", "btn_widget_lock", 150.0, 20.0, "btn_widget_lock_tooltip");
    CreateLabel(jRow, "", "blank_label_1", 25.0, 20.0);
    JsonArrayInsertInplace(jRow, NuiSpacer());
    CreateButton(jRow, "Options", "btn_options", 150.0, 20.0, -1.0, "btn_options_tooltip");
    CreateLabel(jRow, "", "blank_label_2", 25.0, 20.0);
    // Add row to the column.
    json jCol = JsonArray();
    JsonArrayInsertInplace(jCol, NuiRow(jRow));
    float fHeight = 73.0;
    // These buttons only show for the players widget.
    if(bIsPC)
    {
        // Row 2**************************************************************** 388 / 28
        jRow = JsonArray();
        CreateButton(jRow, "All - Guard Me", "btn_cmd_guard", 150.0, 20.0, -1.0, "btn_cmd_guard_tooltip");
        CreateCheckBox(jRow, "", "chbx_cmd_guard", 25.0, 20.0);
        JsonArrayInsertInplace(jRow, NuiSpacer());
        CreateButton(jRow, "All - Follow", "btn_cmd_follow", 150.0, 20.0, -1.0, "btn_cmd_follow_tooltip");
        CreateCheckBox(jRow, "", "chbx_cmd_follow", 25.0, 20.0);
        // Add row to the column.
        JsonArrayInsertInplace(jCol, NuiRow(jRow));
        // Row 3 *************************************************************** 388 / 56
        jRow = JsonArray();
        CreateButton(jRow, "All - Stand Ground", "btn_cmd_hold", 150.0, 20.0, -1.0, "btn_cmd_hold_tooltip");
        CreateCheckBox(jRow, "", "chbx_cmd_hold", 25.0, 20.0);
        JsonArrayInsertInplace(jRow, NuiSpacer());
        CreateButton(jRow, "All - Attack Nearest", "btn_cmd_attack", 150.0, 20.0, -1.0, "btn_cmd_attack_tooltip");
        CreateCheckBox(jRow, "", "chbx_cmd_attack", 25.0, 20.0);
        // Add row to the column.
        JsonArrayInsertInplace(jCol, NuiRow(jRow));
        fHeight += 56.0;
    }
    // Activate PC AI buttons if the PC AI scripts are present or this is not a PC.
    int bUsingPCAI = ResManGetAliasFor("xx_pc_1_hb", RESTYPE_NCS) != "";
    if(bUsingPCAI || !bIsPC)
    {
        // Row 4 *************************************************************** 388 / 28
        jRow = JsonArray();
        CreateButton(jRow, "AI On/Off", "btn_ai", 150.0, 20.0, -1.0, "btn_ai_tooltip");
        CreateCheckBox(jRow, "", "chbx_ai", 25.0, 20.0);
        JsonArrayInsertInplace(jRow, NuiSpacer());
        CreateButton(jRow, "Ranged", "btn_ranged", 150.0, 20.0, -1.0, "btn_ranged_tooltip");
        CreateCheckBox(jRow, "", "chbx_ranged", 25.0, 20.0);
        // Add row to the column.
        JsonArrayInsertInplace(jCol, NuiRow(jRow));
        // Row 5 *************************************************************** 388 / 56
        jRow = JsonArray();
        CreateButton(jRow, "Search", "btn_search", 150.0, 20.0, -1.0, "btn_search_tooltip");
        CreateCheckBox(jRow, "", "chbx_search", 25.0, 20.0);
        JsonArrayInsertInplace(jRow, NuiSpacer());
        CreateButton(jRow, "Stealth", "btn_stealth", 150.0, 20.0, -1.0, "btn_stealth_tooltip");
        CreateCheckBox(jRow, "", "chbx_stealth", 25.0, 20.0);
        // Add row to the column.
        JsonArrayInsertInplace(jCol, NuiRow(jRow));
        // Row 6 *************************************************************** 388 / 84
        jRow = JsonArray();
        CreateButton(jRow, "Disarm Traps", "btn_traps", 150.0, 20.0, -1.0, "btn_traps_tooltip");
        CreateCheckBox(jRow, "", "chbx_traps", 25.0, 20.0);
        JsonArrayInsertInplace(jRow, NuiSpacer());
        CreateButton(jRow, "Bypass Locks", "btn_locks", 150.0, 20.0, -1.0, "btn_locks_tooltip");
        CreateCheckBox(jRow, "", "chbx_locks", 25.0, 20.0);
        // Add row to the column.
        JsonArrayInsertInplace(jCol, NuiRow(jRow));
        // Row 7 *************************************************************** 388 / 112
        jRow = JsonArray();
        CreateButton(jRow, "Magic use -", "btn_magic_minus", 150.0, 20.0f, -1.0, "btn_m_minus_tooltip");
        CreateCheckBox(jRow, "", "chbx_magic_minus", 25.0, 20.0);
        JsonArrayInsertInplace(jRow, NuiSpacer());
        CreateButton(jRow, "Magic use +", "btn_magic_plus", 150.0, 20.0, -1.0, "btn_m_plus_tooltip");
        CreateCheckBox(jRow, "", "chbx_magic_plus", 25.0, 20.0);
        // Add row to the column.
        JsonArrayInsertInplace(jCol, NuiRow(jRow));
        // Row 8 *************************************************************** 388 / 140
        jRow = JsonArray();
        CreateButton(jRow, "No Magic", "btn_no_magic", 150.0, 20.0, -1.0, "btn_no_magic_tooltip");
        CreateCheckBox(jRow, "", "chbx_no_magic", 25.0, 20.0);
        JsonArrayInsertInplace(jRow, NuiSpacer());
        CreateButton(jRow, "All Magic", "btn_all_magic", 150.0, 20.0, -1.0, "btn_all_magic_tooltip");
        CreateCheckBox(jRow, "", "chbx_all_magic", 25.0, 20.0);
        // Add row to the column.
        JsonArrayInsertInplace(jCol, NuiRow(jRow));
        // Row 9 *************************************************************** 388 / 168
        jRow = JsonArray();
        CreateButton(jRow, "Def Magic", "btn_def_magic", 150.0, 20.0, -1.0, "btn_def_magic_tooltip");
        CreateCheckBox(jRow, "", "chbx_def_magic", 25.0, 20.0f);
        JsonArrayInsert(jRow, NuiSpacer());
        CreateButton(jRow, "Off Magic", "btn_off_magic", 150.0, 20.0, -1.0, "btn_off_magic_tooltip");
        CreateCheckBox(jRow, "", "chbx_off_magic", 25.0, 20.0);
        // Add row to the column.
        JsonArrayInsertInplace(jCol, NuiRow(jRow));
        // Row 10 *************************************************************** 388 / 196
        jRow = JsonArray();
        CreateButton(jRow, "No Looting", "btn_no_loot", 150.0, 20.0, -1.0, "btn_no_loot_tooltip");
        CreateCheckBox(jRow, "", "chbx_no_loot", 25.0, 20.0);
        JsonArrayInsertInplace(jRow, NuiSpacer());
        CreateButton(jRow, "Loot All", "btn_loot_all", 150.0, 20.0, -1.0, "btn_loot_all_tooltip");
        CreateCheckBox(jRow, "", "chbx_loot_all", 25.0, 20.0);
        // Add row to the column.
        JsonArrayInsertInplace(jCol, NuiRow(jRow));
        // Row 11 *************************************************************** 388 / 224
        jRow = JsonArray();
        CreateButton(jRow, "Loot Gems+", "btn_loot_gems", 150.0, 20.0, -1.0, "btn_loot_gems_tooltip");
        CreateCheckBox(jRow, "", "chbx_loot_gems", 25.0, 20.0);
        JsonArrayInsertInplace(jRow, NuiSpacer());
        CreateButton(jRow, "Loot Magic", "btn_loot_magic", 150.0, 20.0, -1.0, "btn_loot_magic_tooltip");
        CreateCheckBox(jRow, "", "chbx_loot_magic", 25.0, 20.0);
        // Add row to the column.
        JsonArrayInsertInplace(jCol, NuiRow(jRow));
        // Row 12 ************************************************************** 388 / 252
        jRow = JsonArray();
        CreateButton(jRow, "Heal % Chance -", "btn_heal_out_minus", 150.0, 20.0, -1.0, "btn_heal_out_minus_tooltip");
        CreateCheckBox(jRow, "", "chbx_heal_out_minus", 25.0, 20.0);
        JsonArrayInsertInplace(jRow, NuiSpacer());
        CreateButton(jRow, "Heal % Chance +", "btn_heal_out_plus", 150.0, 20.0, -1.0, "btn_heal_out_plus_tooltip");
        CreateCheckBox(jRow, "", "chbx_heal_out_plus", 25.0, 20.0);
        // Add row to the column.
        JsonArrayInsertInplace(jCol, NuiRow(jRow));
        // Row 13 ************************************************************** 388 / 280
        jRow = JsonArray();
        CreateButton(jRow, "Heal % Combat -", "btn_heal_in_minus", 150.0, 20.0, -1.0, "btn_heal_in_minus_tooltip");
        CreateCheckBox(jRow, "", "chbx_heal_in_minus", 25.0, 20.0);
        JsonArrayInsertInplace(jRow, NuiSpacer());
        CreateButton(jRow, "Heal % Combat +", "btn_heal_in_plus", 150.0, 20.0, -1.0, "btn_heal_in_plus_tooltip");
        CreateCheckBox(jRow, "", "chbx_heal_in_plus", 25.0, 20.0);
        // Add row to the column.
        JsonArrayInsertInplace(jCol, NuiRow(jRow));
        // Row 14 ************************************************************** 388 / 308
        jRow = JsonArray();
        CreateButton(jRow, "Heal On/Off", "btn_heal_onoff", 150.0, 20.0, -1.0, "btn_heal_onoff_tooltip");
        CreateCheckBox(jRow, "", "chbx_heal_onoff", 25.0, 20.0);
        if(!ai_GetIsCharacter(oAssociate))
        {
            JsonArrayInsertInplace(jRow, NuiSpacer());
            CreateButton(jRow, "Resting Buffs", "btn_buff_rest", 150.0, 20.0, -1.0, "btn_buff_rest_tooltip");
            CreateCheckBox(jRow, "", "chbx_buff_rest", 25.0, 20.0);
        }
        // Add row to the column.
        JsonArrayInsertInplace(jCol, NuiRow(jRow));
        fHeight += 308.0;
    }
    // Row 15 ************************************************************** 388 / 28
    jRow = JsonArray();
    CreateButton(jRow, "Short Buffs", "btn_buff_short", 150.0, 20.0, -1.0, "btn_buff_short_tooltip");
    CreateCheckBox(jRow, "", "chbx_buff_short", 25.0, 20.0);
    JsonArrayInsertInplace(jRow, NuiSpacer());
    CreateButton(jRow, "Long Buffs", "btn_buff_long", 150.0, 20.0, -1.0, "btn_buff_long_tooltip");
    CreateCheckBox(jRow, "", "chbx_buff_long", 25.0, 20.0);
    // Add row to the column.
    JsonArrayInsertInplace(jCol, NuiRow(jRow));
    // Row 16 ************************************************************** 388 / 56
    jRow = JsonArray();
    CreateButton(jRow, "All Buffs", "btn_buff_all", 150.0, 20.0, -1.0, "btn_buff_all_tooltip");
    CreateCheckBox(jRow, "", "chbx_buff_all", 25.0, 20.0);
    // Add row to the column.
    JsonArrayInsertInplace(jCol, NuiRow(jRow));
    fHeight += 56.0;
    // Set the Layout of the window.
    json jLayout = NuiCol(jCol);
    string sText, sName = GetName(oAssociate);
    if(GetStringRight(sName, 1) == "s") sName = sName + "'";
    else sName = sName + "'s";
    string sAssociateType = ai_GetAssociateType(oPC, oAssociate);
    int nToken = SetWindow(oPC, jLayout, sAssociateType + "_menu", sName + " Menu",
                           -1.0, -1.0, 388.0, fHeight + 12.0, FALSE, FALSE, TRUE, FALSE, TRUE, "0e_nui");
    // Get which buttons are activated.
    int bAIWidgetLock = ai_GetAssociateWidgetButton(oPC, BTN_WIDGET_LOCK, sAssociateType);
    int bCmdGuard = ai_GetAssociateWidgetButton(oPC, BTN_CMD_GUARD, sAssociateType);
    int bCmdFollow = ai_GetAssociateWidgetButton(oPC, BTN_CMD_FOLLOW, sAssociateType);
    int bCmdHold = ai_GetAssociateWidgetButton(oPC, BTN_CMD_HOLD, sAssociateType);
    int bCmdAttack = ai_GetAssociateWidgetButton(oPC, BTN_CMD_ATTACK, sAssociateType);
    int bBuffRest = ai_GetAssociateWidgetButton(oPC, BTN_BUFF_REST, sAssociateType);
    int bBuffShort = ai_GetAssociateWidgetButton(oPC, BTN_BUFF_SHORT, sAssociateType);
    int bBuffLong = ai_GetAssociateWidgetButton(oPC, BTN_BUFF_LONG, sAssociateType);
    int bBuffAll = ai_GetAssociateWidgetButton(oPC, BTN_BUFF_ALL, sAssociateType);
    int bAI = ai_GetAssociateAIButton(oPC, BTN_AI_FOR_PC, sAssociateType);
    int bRanged = ai_GetAssociateAIButton(oPC, BTN_AI_USE_RANGED, sAssociateType);
    int bSearch = ai_GetAssociateAIButton(oPC, BTN_AI_USE_SEARCH, sAssociateType);
    int bStealth = ai_GetAssociateAIButton(oPC, BTN_AI_USE_STEALTH, sAssociateType);
    int bTraps = ai_GetAssociateAIButton(oPC, BTN_AI_REMOVE_TRAPS, sAssociateType);
    int bLocks = ai_GetAssociateAIButton(oPC, BTN_AI_BYPASS_LOCKS, sAssociateType);
    int bPCMagicMinus = ai_GetAssociateAIButton(oPC, BTN_AI_MAGIC_USE_MINUS, sAssociateType);
    int bPCMagicPlus = ai_GetAssociateAIButton(oPC, BTN_AI_MAGIC_USE_PLUS, sAssociateType);
    int bNoMagic = ai_GetAssociateAIButton(oPC, BTN_AI_NO_MAGIC_USE, sAssociateType);
    int bAllMagic = ai_GetAssociateAIButton(oPC, BTN_AI_ALL_MAGIC_USE, sAssociateType);
    int bDefMagic = ai_GetAssociateAIButton(oPC, BTN_AI_DEF_MAGIC_USE, sAssociateType);
    int bOffMagic = ai_GetAssociateAIButton(oPC, BTN_AI_OFF_MAGIC_USE, sAssociateType);
    int bNoLoot = ai_GetAssociateAIButton(oPC, BTN_AI_PICKUP_NO_LOOT, sAssociateType);
    int bLootAll = ai_GetAssociateAIButton(oPC, BTN_AI_PICKUP_ALL_LOOT, sAssociateType);
    int bLootGems = ai_GetAssociateAIButton(oPC, BTN_AI_PICKUP_GEMS_LOOT, sAssociateType);
    int bLootMagic = ai_GetAssociateAIButton(oPC, BTN_AI_PICKUP_MAGIC_LOOT, sAssociateType);
    int bHealOutPlus = ai_GetAssociateAIButton(oPC, BTN_AI_HEAL_OUT_PLUS, sAssociateType);
    int bHealOutMinus = ai_GetAssociateAIButton(oPC, BTN_AI_HEAL_OUT_MINUS, sAssociateType);
    int bHealInPlus = ai_GetAssociateAIButton(oPC, BTN_AI_HEAL_IN_PLUS, sAssociateType);
    int bHealInMinus = ai_GetAssociateAIButton(oPC, BTN_AI_HEAL_IN_MINUS, sAssociateType);
    int bHealOnOff = ai_GetAssociateAIButton(oPC, BTN_AI_STOP_HEALING, sAssociateType);
    // Save the associate tag to the nui.
    json jData = JsonArray();
    JsonArrayInsertInplace(jData, JsonString(sAssociateType));
    NuiSetUserData(oPC, nToken, jData);
    // Set all binds, events, and watches.
    // Row 1
    NuiSetBind(oPC, nToken, "btn_widget_lock_event", JsonBool(TRUE));
    NuiSetBind(oPC, nToken, "btn_widget_lock", JsonInt(bAIWidgetLock));
    NuiSetBind(oPC, nToken, "btn_widget_lock_tooltip", JsonString(
               "  Locks widget to the current location."));
    NuiSetBind(oPC, nToken, "btn_options_event", JsonBool (TRUE));
    NuiSetBind(oPC, nToken, "btn_options", JsonInt(TRUE));
    NuiSetBind(oPC, nToken, "btn_options_tooltip", JsonString(
               "  Additional options"));
    if(bIsPC)
    {
        // Row 2
        NuiSetBind(oPC, nToken, "chbx_cmd_guard_check", JsonBool (bCmdGuard));
        NuiSetBindWatch (oPC, nToken, "chbx_cmd_guard_check", TRUE);
        NuiSetBind(oPC, nToken, "btn_cmd_guard_event", JsonBool (TRUE));
        NuiSetBind(oPC, nToken, "btn_cmd_guard_tooltip", JsonString("  All associates Guard Me"));
        NuiSetBind(oPC, nToken, "chbx_cmd_follow_check", JsonBool (bCmdFollow));
        NuiSetBindWatch (oPC, nToken, "chbx_cmd_follow_check", TRUE);
        NuiSetBind(oPC, nToken, "btn_cmd_follow_event", JsonBool (TRUE));
        NuiSetBind(oPC, nToken, "btn_cmd_follow_tooltip", JsonString("  All associates Follow"));
        // Row 3
        NuiSetBind(oPC, nToken, "chbx_cmd_hold_check", JsonBool (bCmdHold));
        NuiSetBindWatch (oPC, nToken, "chbx_cmd_hold_check", TRUE);
        NuiSetBind(oPC, nToken, "btn_cmd_hold_event", JsonBool (TRUE));
        NuiSetBind(oPC, nToken, "btn_cmd_hold_tooltip", JsonString("  All associates Stand Ground"));
        NuiSetBind(oPC, nToken, "chbx_cmd_attack_check", JsonBool (bCmdAttack));
        NuiSetBindWatch (oPC, nToken, "chbx_cmd_attack_check", TRUE);
        NuiSetBind(oPC, nToken, "btn_cmd_attack_event", JsonBool (TRUE));
        NuiSetBind(oPC, nToken, "btn_cmd_attack_tooltip", JsonString("  All associates Attack Nearest"));
    }
    // Only activate these if we are using PC AI or if this is not a PC.
    if(bUsingPCAI || !bIsPC)
    {
        // Row 4
        // Only activate ai on/off if this is for the pc.
        if(GetIsPC(oAssociate))
        {
            NuiSetBind(oPC, nToken, "chbx_ai_check", JsonBool (bAI));
            NuiSetBindWatch (oPC, nToken, "chbx_ai_check", TRUE);
            NuiSetBind(oPC, nToken, "btn_ai_event", JsonBool (TRUE));
            if(GetEventScript(oAssociate, EVENT_SCRIPT_CREATURE_ON_HEARTBEAT) == "xx_pc_1_hb") sText = "  AI [On] Turn off";
            else sText = "  AI [Off] Turn on";
            NuiSetBind(oPC, nToken, "btn_ai_tooltip", JsonString (sText));
        }
        NuiSetBind(oPC, nToken, "chbx_ranged_check", JsonBool (bRanged));
        NuiSetBindWatch(oPC, nToken, "chbx_ranged_check", TRUE);
        NuiSetBind(oPC, nToken, "btn_ranged_event", JsonBool (TRUE));
        if(ai_GetAssociateMode(oAssociate, AI_MODE_STOP_RANGED)) sText = "  Ranged [Off] Turn on";
        else sText = "  Ranged [On] Turn off";
        NuiSetBind (oPC, nToken, "btn_ranged_tooltip", JsonString (sText));
        // Row 5
        NuiSetBind(oPC, nToken, "chbx_search_check", JsonBool (bSearch));
        NuiSetBindWatch (oPC, nToken, "chbx_search_check", TRUE);
        NuiSetBind(oPC, nToken, "btn_search_event", JsonBool (TRUE));
        if(ai_GetAssociateMode(oAssociate, AI_MODE_AGGRESSIVE_SEARCH)) sText = "  Search [On] Turn off";
        else sText = "  Search [Off] Turn on";
        NuiSetBind (oPC, nToken, "btn_search_tooltip", JsonString (sText));
        NuiSetBind(oPC, nToken, "chbx_stealth_check", JsonBool (bStealth));
        NuiSetBindWatch(oPC, nToken, "chbx_stealth_check", TRUE);
        NuiSetBind(oPC, nToken, "btn_stealth_event", JsonBool (TRUE));
        if(ai_GetAssociateMode(oAssociate, AI_MODE_AGGRESSIVE_STEALTH)) sText = "  Stealth [On] Trun off";
        else sText = "  Stealth [Off] Turn on";
        NuiSetBind (oPC, nToken, "btn_stealth_tooltip", JsonString (sText));
        // Row 6
        NuiSetBind(oPC, nToken, "chbx_traps_check", JsonBool (bTraps));
        NuiSetBindWatch (oPC, nToken, "chbx_traps_check", TRUE);
        NuiSetBind(oPC, nToken, "btn_traps_event", JsonBool (TRUE));
        if(ai_GetAssociateMode(oAssociate, AI_MODE_DISARM_TRAPS)) sText = "  Disable Traps [On] Turn off";
        else sText = "  Disable Traps [Off] Turn on";
        NuiSetBind (oPC, nToken, "btn_traps_tooltip", JsonString (sText));
        NuiSetBind(oPC, nToken, "chbx_locks_check", JsonBool (bLocks));
        NuiSetBindWatch(oPC, nToken, "chbx_locks_check", TRUE);
        NuiSetBind(oPC, nToken, "btn_locks_event", JsonBool (TRUE));
        if(ai_GetAssociateMode(oAssociate, AI_MODE_OPEN_LOCKS)) sText = "  Bypass locks [On] Turn off";
        else sText = "  Bypass Locks [Off] Turn on";
        NuiSetBind (oPC, nToken, "btn_locks_tooltip", JsonString (sText));
        // Row 7
        string sMagic = IntToString(GetLocalInt(oAssociate, AI_DIFFICULTY_ADJUSTMENT));
        NuiSetBind(oPC, nToken, "chbx_magic_minus_check", JsonBool (bPCMagicMinus));
        NuiSetBindWatch (oPC, nToken, "chbx_magic_minus_check", TRUE);
        NuiSetBind(oPC, nToken, "btn_magic_minus_event", JsonBool (TRUE));
        NuiSetBind (oPC, nToken, "btn_m_minus_tooltip", JsonString (" Magic use [" + sMagic + "] Decrease"));
        NuiSetBind(oPC, nToken, "chbx_magic_plus_check", JsonBool (bPCMagicPlus));
        NuiSetBindWatch(oPC, nToken, "chbx_magic_plus_check", TRUE);
        NuiSetBind(oPC, nToken, "btn_magic_plus_event", JsonBool (TRUE));
        NuiSetBind (oPC, nToken, "btn_m_plus_tooltip", JsonString ("  Magic use [" + sMagic + "] Increase"));
        // Row 8
        sText = "  [Any]";
        if(ai_GetAssociateMagicMode(oAssociate, AI_MAGIC_NO_MAGIC)) sText = "  [None]";
        else if(ai_GetAssociateMagicMode(oAssociate, AI_MAGIC_DEFENSIVE_CASTING)) sText = "  [Defense]";
        else if(ai_GetAssociateMagicMode(oAssociate, AI_MAGIC_OFFENSIVE_CASTING)) sText = "  [Offense]";
        NuiSetBind(oPC, nToken, "chbx_no_magic_check", JsonBool (bNoMagic));
        NuiSetBindWatch (oPC, nToken, "chbx_no_magic_check", TRUE);
        NuiSetBind(oPC, nToken, "btn_no_magic_event", JsonBool (TRUE));
        NuiSetBind(oPC, nToken, "btn_no_magic_tooltip", JsonString (sText + " Turn magic use off"));
        NuiSetBind(oPC, nToken, "chbx_all_magic_check", JsonBool (bAllMagic));
        NuiSetBindWatch (oPC, nToken, "chbx_all_magic_check", TRUE);
        NuiSetBind(oPC, nToken, "btn_all_magic_event", JsonBool (TRUE));
        NuiSetBind(oPC, nToken, "btn_all_magic_tooltip", JsonString (sText + " Use any magic"));
        // Row 9
        NuiSetBind(oPC, nToken, "chbx_def_magic_check", JsonBool (bDefMagic));
        NuiSetBindWatch (oPC, nToken, "chbx_def_magic_check", TRUE);
        NuiSetBind(oPC, nToken, "btn_def_magic_event", JsonBool (TRUE));
        NuiSetBind(oPC, nToken, "btn_def_magic_tooltip", JsonString (sText + " Use defensive magic only"));
        NuiSetBind(oPC, nToken, "chbx_off_magic_check", JsonBool (bOffMagic));
        NuiSetBindWatch (oPC, nToken, "chbx_off_magic_check", TRUE);
        NuiSetBind(oPC, nToken, "btn_off_magic_event", JsonBool (TRUE));
        NuiSetBind(oPC, nToken, "btn_off_magic_tooltip", JsonString (sText + " Use offensive magic only"));
        // Row 10
        sText = "  [None]";
        if(ai_GetAssociateMode(oAssociate, AI_MODE_PICKUP_GEMS_ITEMS)) sText = "  [Gems]";
        else if(ai_GetAssociateMode(oAssociate, AI_MODE_PICKUP_MAGIC_ITEMS)) sText = "  [Magic]";
        else if(ai_GetAssociateMode(oAssociate, AI_MODE_PICKUP_ITEMS)) sText = "  [All]";
        NuiSetBind(oPC, nToken, "chbx_no_loot_check", JsonBool (bNoLoot));
        NuiSetBindWatch (oPC, nToken, "chbx_no_loot_check", TRUE);
        NuiSetBind(oPC, nToken, "btn_no_loot_event", JsonBool (TRUE));
        NuiSetBind(oPC, nToken, "btn_no_loot_tooltip", JsonString (sText + " Don't pickup items"));
        NuiSetBind(oPC, nToken, "chbx_loot_all_check", JsonBool (bLootAll));
        NuiSetBindWatch (oPC, nToken, "chbx_loot_all_check", TRUE);
        NuiSetBind(oPC, nToken, "btn_loot_all_event", JsonBool (TRUE));
        NuiSetBind(oPC, nToken, "btn_loot_all_tooltip", JsonString (sText + " Pickup all items"));
        // Row 11
        NuiSetBind(oPC, nToken, "chbx_loot_gems_check", JsonBool (bLootGems));
        NuiSetBindWatch (oPC, nToken, "chbx_loot_gems_check", TRUE);
        NuiSetBind(oPC, nToken, "btn_loot_gems_event", JsonBool (TRUE));
        NuiSetBind(oPC, nToken, "btn_loot_gems_tooltip", JsonString (sText + " Pickup gold, gems, and magic items"));
        NuiSetBind(oPC, nToken, "chbx_loot_magic_check", JsonBool (bLootMagic));
        NuiSetBindWatch (oPC, nToken, "chbx_loot_magic_check", TRUE);
        NuiSetBind(oPC, nToken, "btn_loot_magic_event", JsonBool (TRUE));
        NuiSetBind(oPC, nToken, "btn_loot_magic_tooltip", JsonString (sText + " Pickup gold and magic items"));
        // Row 12
        int nHeal = GetLocalInt(oAssociate, AI_HEAL_OUT_OF_COMBAT_LIMIT);
        NuiSetBind(oPC, nToken, "chbx_heal_out_minus_check", JsonBool (bHealOutMinus));
        NuiSetBindWatch (oPC, nToken, "chbx_heal_out_minus_check", TRUE);
        NuiSetBind(oPC, nToken, "btn_heal_out_minus_event", JsonBool (TRUE));
        sText = "  Decrease out of combat healing below [" + IntToString(nHeal) + "%]";
        NuiSetBind(oPC, nToken, "btn_heal_out_minus_tooltip", JsonString(sText));
        NuiSetBind(oPC, nToken, "chbx_heal_out_plus_check", JsonBool (bHealOutPlus));
        NuiSetBindWatch (oPC, nToken, "chbx_heal_out_plus_check", TRUE);
        NuiSetBind(oPC, nToken, "btn_heal_out_plus_event", JsonBool (TRUE));
        sText = "  Increase out of combat healing below [" + IntToString(nHeal) + "%]";
        NuiSetBind(oPC, nToken, "btn_heal_out_plus_tooltip", JsonString(sText));
        // Row 13
        nHeal = GetLocalInt(oAssociate, AI_HEAL_IN_COMBAT_LIMIT);
        NuiSetBind(oPC, nToken, "chbx_heal_in_minus_check", JsonBool (bHealOutMinus));
        NuiSetBindWatch (oPC, nToken, "chbx_heal_in_minus_check", TRUE);
        NuiSetBind(oPC, nToken, "btn_heal_in_minus_event", JsonBool (TRUE));
        sText = "  Decrease in combat healing below [" + IntToString(nHeal) + "%]";
        NuiSetBind(oPC, nToken, "btn_heal_in_minus_tooltip", JsonString(sText));
        NuiSetBind(oPC, nToken, "chbx_heal_in_plus_check", JsonBool (bHealInPlus));
        NuiSetBindWatch (oPC, nToken, "chbx_heal_in_plus_check", TRUE);
        NuiSetBind(oPC, nToken, "btn_heal_in_plus_event", JsonBool (TRUE));
        sText = "  Increase in combat healing below [" + IntToString(nHeal) + "%]";
        NuiSetBind(oPC, nToken, "btn_heal_in_plus_tooltip", JsonString(sText));
        // Row 14
        NuiSetBind(oPC, nToken, "chbx_heal_onoff_check", JsonBool (bHealOutMinus));
        NuiSetBindWatch (oPC, nToken, "chbx_heal_onoff_check", TRUE);
        NuiSetBind(oPC, nToken, "btn_heal_onoff_event", JsonBool (TRUE));
        if(ai_GetAssociateMode(oAssociate, AI_MODE_HEALING_OFF)) sText = "  Healing is [Off] turn on";
        else sText = "  Healing is [On] turn off";
        NuiSetBind(oPC, nToken, "btn_heal_onoff_tooltip", JsonString(sText));
        if(!ai_GetIsCharacter(oAssociate))
        {
            NuiSetBind(oPC, nToken, "chbx_buff_rest_check", JsonBool (bBuffRest));
            NuiSetBindWatch (oPC, nToken, "chbx_buff_rest_check", TRUE);
            NuiSetBind(oPC, nToken, "btn_buff_rest_event", JsonBool (TRUE));
            if(ai_GetAssociateMagicMode(oAssociate, AI_MAGIC_BUFF_AFTER_REST)) sText = "  Turn buffing after resting off";
            else sText = "  Turn buffing after resting on.";
            NuiSetBind (oPC, nToken, "btn_buff_rest_tooltip", JsonString (sText));
        }
    }
    // Row 15
    NuiSetBind(oPC, nToken, "chbx_buff_short_check", JsonBool (bBuffShort));
    NuiSetBindWatch (oPC, nToken, "chbx_buff_short_check", TRUE);
    NuiSetBind(oPC, nToken, "btn_buff_short_event", JsonBool (TRUE));
    NuiSetBind (oPC, nToken, "btn_buff_short_tooltip", JsonString (
               "  Buff the party with short duration spells."));
    NuiSetBind(oPC, nToken, "chbx_buff_long_check", JsonBool (bBuffLong));
    NuiSetBindWatch (oPC, nToken, "chbx_buff_long_check", TRUE);
    NuiSetBind(oPC, nToken, "btn_buff_long_event", JsonBool (TRUE));
    NuiSetBind(oPC, nToken, "btn_buff_long_tooltip", JsonString (
               "  Buff the party with long duration spells."));
    // Row 16
    NuiSetBind(oPC, nToken, "chbx_buff_all_check", JsonBool (bBuffAll));
    NuiSetBindWatch (oPC, nToken, "chbx_buff_all_check", TRUE);
    NuiSetBind(oPC, nToken, "btn_buff_all_event", JsonBool (TRUE));
    NuiSetBind(oPC, nToken, "btn_buff_all_tooltip", JsonString (
               "  Buff the party with all our defensive spells."));
}
void ai_CreateWidgetNUI(object oPC, object oAssociate)
{
    // Set window to not save until it has been created.
    SetLocalInt (oPC, AI_NO_NUI_SAVE, TRUE);
    DelayCommand (0.5f, DeleteLocalInt (oPC, AI_NO_NUI_SAVE));
    // Get which buttons are activated.
    string sAssociateType = ai_GetAssociateType(oPC, oAssociate);
    int bAIWidgetLock = ai_GetAssociateWidgetButton(oPC, BTN_WIDGET_LOCK, sAssociateType);
    int bCmdGuard = ai_GetAssociateWidgetButton(oPC, BTN_CMD_GUARD, sAssociateType);
    int bCmdFollow = ai_GetAssociateWidgetButton(oPC, BTN_CMD_FOLLOW, sAssociateType);
    int bCmdHold = ai_GetAssociateWidgetButton(oPC, BTN_CMD_HOLD, sAssociateType);
    int bCmdAttack = ai_GetAssociateWidgetButton(oPC, BTN_CMD_ATTACK, sAssociateType);
    int bBuffRest = ai_GetAssociateWidgetButton(oPC, BTN_BUFF_REST, sAssociateType);
    int bBuffShort = ai_GetAssociateWidgetButton(oPC, BTN_BUFF_SHORT, sAssociateType);
    int bBuffLong = ai_GetAssociateWidgetButton(oPC, BTN_BUFF_LONG, sAssociateType);
    int bBuffAll = ai_GetAssociateWidgetButton(oPC, BTN_BUFF_ALL, sAssociateType);
    int bAI = ai_GetAssociateAIButton(oPC, BTN_AI_FOR_PC, sAssociateType);
    int bRanged = ai_GetAssociateAIButton(oPC, BTN_AI_USE_RANGED, sAssociateType);
    int bSearch = ai_GetAssociateAIButton(oPC, BTN_AI_USE_SEARCH, sAssociateType);
    int bStealth = ai_GetAssociateAIButton(oPC, BTN_AI_USE_STEALTH, sAssociateType);
    int bTraps = ai_GetAssociateAIButton(oPC, BTN_AI_REMOVE_TRAPS, sAssociateType);
    int bLocks = ai_GetAssociateAIButton(oPC, BTN_AI_BYPASS_LOCKS, sAssociateType);
    int bPCMagicMinus = ai_GetAssociateAIButton(oPC, BTN_AI_MAGIC_USE_MINUS, sAssociateType);
    int bPCMagicPlus = ai_GetAssociateAIButton(oPC, BTN_AI_MAGIC_USE_PLUS, sAssociateType);
    int bNoMagic = ai_GetAssociateAIButton(oPC, BTN_AI_NO_MAGIC_USE, sAssociateType);
    int bAllMagic = ai_GetAssociateAIButton(oPC, BTN_AI_ALL_MAGIC_USE, sAssociateType);
    int bDefMagic = ai_GetAssociateAIButton(oPC, BTN_AI_DEF_MAGIC_USE, sAssociateType);
    int bOffMagic = ai_GetAssociateAIButton(oPC, BTN_AI_OFF_MAGIC_USE, sAssociateType);
    int bNoLoot = ai_GetAssociateAIButton(oPC, BTN_AI_PICKUP_NO_LOOT, sAssociateType);
    int bLootAll = ai_GetAssociateAIButton(oPC, BTN_AI_PICKUP_ALL_LOOT, sAssociateType);
    int bLootGems = ai_GetAssociateAIButton(oPC, BTN_AI_PICKUP_GEMS_LOOT, sAssociateType);
    int bLootMagic = ai_GetAssociateAIButton(oPC, BTN_AI_PICKUP_MAGIC_LOOT, sAssociateType);
    int bHealOutPlus = ai_GetAssociateAIButton(oPC, BTN_AI_HEAL_OUT_PLUS, sAssociateType);
    int bHealOutMinus = ai_GetAssociateAIButton(oPC, BTN_AI_HEAL_OUT_MINUS, sAssociateType);
    int bHealInPlus = ai_GetAssociateAIButton(oPC, BTN_AI_HEAL_IN_PLUS, sAssociateType);
    int bHealInMinus = ai_GetAssociateAIButton(oPC, BTN_AI_HEAL_IN_MINUS, sAssociateType);
    int bHealOnOff = ai_GetAssociateAIButton(oPC, BTN_AI_STOP_HEALING, sAssociateType);
    float fHeight = 92.0f;//87.0f;
    if(bAIWidgetLock) fHeight = 59.0f;//54.0f;
    float fButtons, fWidth = 86.0f;
    // ************************************************************************* Width / Height
    // Row 1 (buttons)**********************************************************
    json jRow = JsonArray();
    CreateButtonImage(jRow, "ir_message", "btn_open_main", 35.0f, 35.0f, -1.0, "btn_open_main_tooltip");
    if(bCmdGuard)
    {
        CreateButtonImage(jRow, "ir_guard", "btn_cmd_guard", 35.0f, 35.0f, -1.0, "btn_cmd_guard_tooltip");
        fButtons += 1.0;
    }
    if(bCmdFollow)
    {
        CreateButtonImage(jRow, "ir_follow", "btn_cmd_follow", 35.0f, 35.0f, -1.0, "btn_cmd_follow_tooltip");
        fButtons += 1.0;
    }
    if(bCmdHold)
    {
        CreateButtonImage(jRow, "ir_standground", "btn_cmd_hold", 35.0f, 35.0f, -1.0, "btn_cmd_hold_tooltip");
        fButtons += 1.0;
    }
    if(bCmdAttack)
    {
        CreateButtonImage(jRow, "ir_attacknearest", "btn_cmd_attack", 35.0f, 35.0f, -1.0, "btn_cmd_attack_tooltip");
        fButtons += 1.0;
    }
    int bUsingPCAI = ResManGetAliasFor("xx_pc_1_hb", RESTYPE_NCS) != "";
    int bIsPC = ai_GetIsCharacter(oAssociate);
    if(bUsingPCAI || !bIsPC)
    {
        if(bAI)
        {
            CreateButtonImage(jRow, "ir_cmbtinfo", "btn_ai", 35.0f, 35.0f, -1.0, "btn_ai_tooltip");
            fButtons += 1.0;
        }
        if(bRanged)
        {
            CreateButtonImage(jRow, "ir_archer", "btn_ranged", 35.0f, 35.0f, -1.0, "btn_ranged_tooltip");
            fButtons += 1.0;
        }
        if(bSearch)
        {
            CreateButtonImage(jRow, "isk_search", "btn_search", 35.0f, 35.0f, -1.0, "btn_search_tooltip");
            fButtons += 1.0;
        }
        if(bStealth)
        {
            CreateButtonImage(jRow, "isk_hide", "btn_stealth", 35.0f, 35.0f, -1.0, "btn_stealth_tooltip");
            fButtons += 1.0;
        }
        if(bTraps)
        {
            CreateButtonImage(jRow, "isk_distrap", "btn_traps", 35.0f, 35.0f, -1.0, "btn_traps_tooltip");
            fButtons += 1.0;
        }
        if(bLocks)
        {
            CreateButtonImage(jRow, "isk_olock", "btn_locks", 35.0f, 35.0f, -1.0, "btn_locks_tooltip");
            fButtons += 1.0;
        }
        if(bPCMagicMinus)
        {
            CreateButtonImage(jRow, "ief_skilldecr", "btn_magic_minus", 35.0f, 35.0f, -1.0, "btn_m_minus_tooltip");
            fButtons += 1.0;
        }
        if(bPCMagicPlus)
        {
            CreateButtonImage(jRow, "ief_skillincr", "btn_magic_plus", 35.0f, 35.0f, -1.0, "btn_m_plus_tooltip");
            fButtons += 1.0;
        }
        if(bNoMagic)
        {
            CreateButtonImage(jRow, "ir_standground", "btn_no_magic", 35.0f, 35.0f, -1.0, "btn_no_magic_tooltip");
            fButtons += 1.0;
        }
        if(bAllMagic)
        {
            CreateButtonImage(jRow, "ir_healme", "btn_all_magic", 35.0f, 35.0f, -1.0, "btn_all_magic_tooltip");
            fButtons += 1.0;
        }
        if(bDefMagic)
        {
            CreateButtonImage(jRow, "ir_xability", "btn_def_magic", 35.0f, 35.0f, -1.0, "btn_def_magic_tooltip");
            fButtons += 1.0;
        }
        if(bOffMagic)
        {
            CreateButtonImage(jRow, "ir_sorcerer", "btn_off_magic", 35.0f, 35.0f, -1.0, "btn_off_magic_tooltip");
            fButtons += 1.0;
        }
        if(bNoLoot)
        {
            CreateButtonImage(jRow, "ife_x3_dismount", "btn_no_loot", 35.0f, 35.0f, -1.0, "btn_no_loot_tooltip");
            fButtons += 1.0;
        }
        if(bLootAll)
        {
            CreateButtonImage(jRow, "ir_pickup", "btn_loot_all", 35.0f, 35.0f, -1.0, "btn_loot_all_tooltip");
            fButtons += 1.0;
        }
        if(bLootGems)
        {
            CreateButtonImage(jRow, "ir_barter", "btn_loot_gems", 35.0f, 35.0f, -1.0, "btn_loot_gems_tooltip");
            fButtons += 1.0;
        }
        if(bLootMagic)
        {
            CreateButtonImage(jRow, "ir_xattack", "btn_loot_magic", 35.0f, 35.0f, -1.0, "btn_loot_magic_tooltip");
            fButtons += 1.0;
        }
        if(bHealOutMinus)
        {
            CreateButtonImage(jRow, "ief_savedecr", "btn_heal_out_minus", 35.0f, 35.0f, -1.0, "btn_heal_out_minus_tooltip");
            fButtons += 1.0;
        }
        if(bHealOutPlus)
        {
            CreateButtonImage(jRow, "ief_saveincr", "btn_heal_out_plus", 35.0f, 35.0f, -1.0, "btn_heal_out_plus_tooltip");
            fButtons += 1.0;
        }
        if(bHealInMinus)
        {
            CreateButtonImage(jRow, "ief_srdecr", "btn_heal_in_minus", 35.0f, 35.0f, -1.0, "btn_heal_in_minus_tooltip");
            fButtons += 1.0;
        }
        if(bHealInPlus)
        {
            CreateButtonImage(jRow, "ief_srincr", "btn_heal_in_plus", 35.0f, 35.0f, -1.0, "btn_heal_in_plus_tooltip");
            fButtons += 1.0;
        }
        if(bHealOnOff)
        {
            CreateButtonImage(jRow, "ir_heal", "btn_heal_onoff", 35.0f, 35.0f, -1.0, "btn_heal_onoff_tooltip");
            fButtons += 1.0;
        }
    }
    if(bBuffShort)
    {
        CreateButtonImage(jRow, "ir_cantrips", "btn_buff_short", 35.0f, 35.0f, -1.0, "btn_buff_short_tooltip");
        fButtons += 1.0;
    }
    if(bBuffLong)
    {
        CreateButtonImage(jRow, "ir_cast", "btn_buff_long", 35.0f, 35.0f, -1.0, "btn_buff_long_tooltip");
        fButtons += 1.0;
    }
    if(bBuffAll)
    {
        CreateButtonImage(jRow, "ir_level789", "btn_buff_all", 35.0f, 35.0f, -1.0, "btn_buff_all_tooltip");
        fButtons += 1.0;
    }
    if(bBuffRest)
    {
        CreateButtonImage(jRow, "ir_rest", "btn_buff_rest", 35.0f, 35.0f, -1.0, "btn_buff_rest_tooltip");
        fButtons += 1.0;
    }
    if(bIsPC)
    {
        // Plug in buttons *********************************************************
        int nIndex = 1;
        string sIndex = "1";
        string sScript = GetLocalString(oPC, "AI_PLUGIN_SCRIPT_1");
        while (nIndex < 6)
        {
            if(sScript != "")
            {
                CreateButtonImage(jRow, "is_summon" + sIndex, "btn_exe_plugin_" + sIndex, 35.0f, 35.0f, -1.0, "btn_exe_plugin_" + sIndex + "_tooltip");
                fButtons += 1.0;
            }
            sIndex = IntToString(++nIndex);
            sScript = GetLocalString(oPC, "AI_PLUGIN_SCRIPT_" + sIndex);
        }
    }
    if(fButtons > 1.0f) fWidth = fWidth + ((fButtons - 1.0) * 39.0f);
    // Add the row to the column.
    json jCol = JsonArray();
    JsonArrayInsertInplace(jCol, NuiRow(jRow));
    string sName = GetName(oAssociate);
    if(GetStringRight(sName, 1) == "s") sName = sName + "'";
    else sName = sName + "'s";
    // Get the window location to restore it from the database.
    float fX = GetLocalFloat(oPC, sAssociateType + "_widget_X");
    float fY = GetLocalFloat(oPC, sAssociateType + "_widget_Y");
    if(fX == 0.0f && fY == 0.0f)
    {
        fX = 10.0f;
        fY = 10.0f;
    }
    if(bAIWidgetLock)
    {
        fX = fX + 4.0f;
        fY = fY + 45.0f;
    }
    // Set the layout of the window.
    json jLayout = NuiCol(jCol);
    int nToken;
    string sHeal, sMagic, sText;
    if(bAIWidgetLock) nToken = SetWindow(oPC, jLayout, sAssociateType + "_widget", "AI Widget", fX, fY, fWidth + 8.0f, fHeight, FALSE, FALSE, FALSE, TRUE, FALSE, "0e_nui");
    else nToken = SetWindow(oPC, jLayout, sAssociateType + "_widget", "AI Widget", fX, fY, fWidth + 12.0f, fHeight, FALSE, FALSE, FALSE, TRUE, TRUE, "0e_nui");
    // Save the associate tag to the nui.
    json jData = JsonArray();
    JsonArrayInsertInplace(jData, JsonString(sAssociateType));
    NuiSetUserData(oPC, nToken, jData);
    // Set event watches for window inspector and save window location.
    NuiSetBindWatch(oPC, nToken, "window_geometry", TRUE);
    // Set the buttons to show events.
    NuiSetBind(oPC, nToken, "btn_open_main_event", JsonBool(TRUE));
    NuiSetBind (oPC, nToken, "btn_open_main_tooltip", JsonString("  " + sName + " widget menu"));
    if(bCmdGuard)
    {
        NuiSetBind(oPC, nToken, "btn_cmd_guard_event", JsonBool (TRUE));
        NuiSetBind (oPC, nToken, "btn_cmd_guard_tooltip", JsonString ("  All associates Guard Me"));
    }
    if(bCmdFollow)
    {
        NuiSetBind(oPC, nToken, "btn_cmd_follow_event", JsonBool (TRUE));
        NuiSetBind (oPC, nToken, "btn_cmd_follow_tooltip", JsonString ("  All associates Follow"));
    }
    if(bCmdHold)
    {
        NuiSetBind(oPC, nToken, "btn_cmd_hold_event", JsonBool (TRUE));
        NuiSetBind (oPC, nToken, "btn_cmd_hold_tooltip", JsonString ("  All associates Stand Ground"));
    }
    if(bCmdAttack)
    {
        NuiSetBind(oPC, nToken, "btn_cmd_attack_event", JsonBool (TRUE));
        NuiSetBind (oPC, nToken, "btn_cmd_attack_tooltip", JsonString ("  All associates Attack Nearest"));
    }
    if(bUsingPCAI || !bIsPC)
    {
        if(bAI)
        {
            NuiSetBind(oPC, nToken, "btn_ai_event", JsonBool(TRUE));
            if(GetEventScript(oAssociate, EVENT_SCRIPT_CREATURE_ON_HEARTBEAT) == "xx_pc_1_hb") sText = "  AI [On] Turn off";
            else sText = "  AI [Off] Turn on";
            NuiSetBind(oPC, nToken, "btn_ai_tooltip", JsonString (sText));
        }
        if(bRanged)
        {
            NuiSetBind(oPC, nToken, "btn_ranged_event", JsonBool (TRUE));
            if(ai_GetAssociateMode(oAssociate, AI_MODE_STOP_RANGED)) sText = "  Ranged [Off] Turn on";
            else sText = "  Ranged [On] Turn off";
            NuiSetBind (oPC, nToken, "btn_ranged_tooltip", JsonString (sText));
        }
        if(bSearch)
        {
            NuiSetBind(oPC, nToken, "btn_search_event", JsonBool (TRUE));
            if(ai_GetAssociateMode(oAssociate, AI_MODE_AGGRESSIVE_SEARCH)) sText = "  Search [On] Turn off";
            else sText = "  Search [Off] Turn on";
            NuiSetBind (oPC, nToken, "btn_search_tooltip", JsonString (sText));
        }
        if(bStealth)
        {
            NuiSetBind(oPC, nToken, "btn_stealth_event", JsonBool (TRUE));
            if(ai_GetAssociateMode(oAssociate, AI_MODE_AGGRESSIVE_STEALTH)) sText = "  Stealth [On] Trun off";
            else sText = "  Stealth [Off] Turn on";
            NuiSetBind (oPC, nToken, "btn_stealth_tooltip", JsonString (sText));
        }
        if(bTraps)
        {
            NuiSetBind(oPC, nToken, "btn_traps_event", JsonBool (TRUE));
            if(ai_GetAssociateMode(oAssociate, AI_MODE_DISARM_TRAPS)) sText = "  Disable Traps [On] Turn off";
            else sText = "  Disable Traps [Off] Turn on";
            NuiSetBind (oPC, nToken, "btn_traps_tooltip", JsonString (sText));
        }
        if(bLocks)
        {
            NuiSetBind(oPC, nToken, "btn_locks_event", JsonBool (TRUE));
            if(ai_GetAssociateMode(oAssociate, AI_MODE_OPEN_LOCKS)) sText = "  Bypass locks [On] Turn off";
            else sText = "  Bypass Locks [Off] Turn on";
            NuiSetBind (oPC, nToken, "btn_locks_tooltip", JsonString (sText));
        }
        if(bPCMagicPlus)
        {
            NuiSetBind(oPC, nToken, "btn_magic_plus_event", JsonBool (TRUE));
            sMagic = IntToString(GetLocalInt(oAssociate, AI_DIFFICULTY_ADJUSTMENT));
            NuiSetBind (oPC, nToken, "btn_m_plus_tooltip", JsonString ("  Magic use [" + sMagic + "] Increase"));
        }
        if(bPCMagicMinus)
        {
            NuiSetBind(oPC, nToken, "btn_magic_minus_event", JsonBool (TRUE));
            sMagic = IntToString(GetLocalInt(oAssociate, AI_DIFFICULTY_ADJUSTMENT));
            NuiSetBind (oPC, nToken, "btn_m_minus_tooltip", JsonString (" Magic use [" + sMagic + "] Decrease"));
        }
        if(bNoMagic)
        {
            NuiSetBind(oPC, nToken, "btn_no_magic_event", JsonBool (TRUE));
            NuiSetBind (oPC, nToken, "btn_no_magic_tooltip", JsonString ("  Turn magic use off"));
        }
        if(bAllMagic)
        {
            NuiSetBind(oPC, nToken, "btn_all_magic_event", JsonBool (TRUE));
            NuiSetBind (oPC, nToken, "btn_all_magic_tooltip", JsonString ("  Use any magic"));
        }
        if(bDefMagic)
        {
            NuiSetBind(oPC, nToken, "btn_def_magic_event", JsonBool (TRUE));
            NuiSetBind (oPC, nToken, "btn_def_magic_tooltip", JsonString ("  Use defensive magic only"));
        }
        if(bOffMagic)
        {
            NuiSetBind(oPC, nToken, "btn_off_magic_event", JsonBool (TRUE));
            NuiSetBind (oPC, nToken, "btn_off_magic_tooltip", JsonString ("  Use offensive magic only"));
        }
        string sLoot = "  [None]";
        if(ai_GetAssociateMode(oAssociate, AI_MODE_PICKUP_GEMS_ITEMS)) sLoot = "  [Gems]";
        else if(ai_GetAssociateMode(oAssociate, AI_MODE_PICKUP_MAGIC_ITEMS)) sLoot = "  [Magic]";
        else if(ai_GetAssociateMode(oAssociate, AI_MODE_PICKUP_ITEMS)) sLoot = "  [All]";
        if(bNoLoot)
        {
            NuiSetBind(oPC, nToken, "btn_no_loot_event", JsonBool (TRUE));
            NuiSetBind (oPC, nToken, "btn_no_loot_tooltip", JsonString (sLoot + " Don't pickup items"));
        }
        if(bLootAll)
        {
            NuiSetBind(oPC, nToken, "btn_loot_all_event", JsonBool (TRUE));
            NuiSetBind (oPC, nToken, "btn_loot_all_tooltip", JsonString (sLoot + " Pickup all items"));
        }
        if(bLootGems)
        {
            NuiSetBind(oPC, nToken, "btn_loot_gems_event", JsonBool (TRUE));
            NuiSetBind (oPC, nToken, "btn_loot_gems_tooltip", JsonString (sLoot + " Pickup gold, gems, and magic items"));
        }
        if(bLootMagic)
        {
            NuiSetBind(oPC, nToken, "btn_loot_magic_event", JsonBool (TRUE));
            NuiSetBind (oPC, nToken, "btn_loot_magic_tooltip", JsonString (sLoot + " Pickup gold and magic items"));
        }
        if(bHealOutPlus)
        {
            NuiSetBind(oPC, nToken, "btn_heal_out_plus_event", JsonBool (TRUE));
            sHeal = IntToString(GetLocalInt(oAssociate, AI_HEAL_OUT_OF_COMBAT_LIMIT));
            sText = "  Increase out of combat healing below [" + sHeal + "%]";
            NuiSetBind(oPC, nToken, "btn_heal_out_plus_tooltip", JsonString(sText));
        }
        if(bHealOutMinus)
        {
            NuiSetBind(oPC, nToken, "btn_heal_out_minus_event", JsonBool (TRUE));
            sHeal = IntToString(GetLocalInt(oAssociate, AI_HEAL_OUT_OF_COMBAT_LIMIT));
            sText = "  Decrease out of combat healing below [" + sHeal + "%]";
            NuiSetBind(oPC, nToken, "btn_heal_out_minus_tooltip", JsonString(sText));
        }
        if(bHealInPlus)
        {
            NuiSetBind(oPC, nToken, "btn_heal_in_plus_event", JsonBool (TRUE));
            sHeal = IntToString(GetLocalInt(oAssociate, AI_HEAL_IN_COMBAT_LIMIT));
            sText = "  Increase in combat healing below [" + sHeal + "%]";
            NuiSetBind(oPC, nToken, "btn_heal_in_plus_tooltip", JsonString(sText));
        }
        if(bHealInMinus)
        {
            NuiSetBind(oPC, nToken, "btn_heal_in_minus_event", JsonBool (TRUE));
            sHeal = IntToString(GetLocalInt(oAssociate, AI_HEAL_IN_COMBAT_LIMIT));
            sText = "  Decrease in combat healing below [" + sHeal + "%]";
            NuiSetBind(oPC, nToken, "btn_heal_in_minus_tooltip", JsonString(sText));
        }
        if(bHealOnOff)
        {
            NuiSetBind(oPC, nToken, "btn_heal_onoff_event", JsonBool (TRUE));
            if(ai_GetAssociateMode(oAssociate, AI_MODE_HEALING_OFF)) sText = "  Healing is [Off] turn on";
            else sText = "  Healing is [On] turn off";
            NuiSetBind(oPC, nToken, "btn_heal_onoff_tooltip", JsonString(sText));
        }
    }
    if(bBuffShort)
    {
        NuiSetBind(oPC, nToken, "btn_buff_short_event", JsonBool (TRUE));
        NuiSetBind (oPC, nToken, "btn_buff_short_tooltip", JsonString ("  Buff the party with short duration spells"));
    }
    if(bBuffLong)
    {
        NuiSetBind(oPC, nToken, "btn_buff_long_event", JsonBool (TRUE));
        NuiSetBind (oPC, nToken, "btn_buff_long_tooltip", JsonString ("  Buff the party with long duration spells"));
    }
    if(bBuffAll)
    {
        NuiSetBind(oPC, nToken, "btn_buff_all_event", JsonBool (TRUE));
        NuiSetBind (oPC, nToken, "btn_buff_all_tooltip", JsonString ("  Buff the party with all our defensive spells"));
    }
    if(bBuffRest)
    {
        NuiSetBind(oPC, nToken, "btn_buff_rest_event", JsonBool (TRUE));
        if(ai_GetAssociateMagicMode(oAssociate, AI_MAGIC_BUFF_AFTER_REST)) sText = "  Turn buffing after resting off";
        else sText = "  Turn buffing after resting on.";
        NuiSetBind (oPC, nToken, "btn_buff_rest_tooltip", JsonString (sText));
    }
    if(bIsPC)
    {
        int nIndex = 1;
        string sIndex = "1";
        string sScript = GetLocalString(oPC, "AI_PLUGIN_SCRIPT_1");
        while (nIndex < 6)
        {
            if(sScript != "")
            {
                if(ResManGetAliasFor(sScript, RESTYPE_NCS) == "") sText = "  " + sScript + " not found by ResMan!";
                else sText = "  Executes " + sScript + " plugin";
                NuiSetBind(oPC, nToken, "btn_exe_plugin_" + sIndex + "_event", JsonBool (TRUE));
                NuiSetBind(oPC, nToken, "btn_exe_plugin_" + sIndex + "_tooltip", JsonString(sText));

            }
            sIndex = IntToString(++nIndex);
            sScript = GetLocalString(oPC, "AI_PLUGIN_SCRIPT_" + sIndex);
        }
    }
}

