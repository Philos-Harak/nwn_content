/*//////////////////////////////////////////////////////////////////////////////
 Script: pi_debug
 Programmer: Philos
////////////////////////////////////////////////////////////////////////////////
  Plugin for debugging.
*///////////////////////////////////////////////////////////////////////////////
#include "0i_nui"
#include "0i_player_target"
// Does startup check if the game has just been loaded.
int StartingUp(object oPC);
void main()
{
    object oPC = OBJECT_SELF;
    if(StartingUp(oPC)) return;
    // Set window to not save until it has been created.
    //SetLocalInt (oPC, AI_NO_NUI_SAVE, TRUE);
    //DelayCommand (0.5f, DeleteLocalInt (oPC, AI_NO_NUI_SAVE));
    string sText = " [Single player]";
    if(ai_GetIsServer()) sText = " [Server]";
    // ************************************************************************* Width / Height
    // Row 1 ******************************************************************* 500 / 73
    json jRow = JsonArrayInsert(JsonArray(), NuiSpacer());
    jRow = CreateLabel(jRow, PHILOS_VERSION + sText, "lbl_version", 470.0f, 20.0f, NUI_HALIGN_CENTER);
    jRow = JsonArrayInsert(jRow, NuiSpacer());
    // Add row to the column.
    json jCol = JsonArrayInsert(JsonArray(), NuiRow(jRow));
    // Row 2 ******************************************************************* 500 / 129
    sText = "Module: " + GetModuleName() + " [" + GetTag(GetModule()) + "]";
    jRow = CreateLabel(JsonArray(), sText, "lbl_module_name", 470.0f, 20.0f, NUI_HALIGN_CENTER);
    // Add row to the column.
    jCol = JsonArrayInsert(jCol, NuiRow(jRow));
    // Row 3 ******************************************************************* 500 / 101
    sText = ResManGetAliasFor("nw_c2_default1", RESTYPE_NCS);
    if(sText != "")
    {
        jRow = CreateLabel(JsonArray(), "Monster AI (nw_c2_default1): " + sText, "monster_1_ai", 470.0f, 20.0f);
        jCol = JsonArrayInsert(jCol, NuiRow(jRow));
    }
    // Row 4 ******************************************************************* 500 / 157
    sText = ResManGetAliasFor("j_ai_onheartbeat", RESTYPE_NCS);
    if(sText != "")
    {
        jRow = CreateLabel(JsonArray(), "Monster AI (j_ai_onheartbeat): " + sText, "monster_2_ai", 470.0f, 20.0f);
        jCol = JsonArrayInsert(jCol, NuiRow(jRow));
    }
    // Row 5 ******************************************************************* 500 / 213
    sText = ResManGetAliasFor("nw_ch_ac1", RESTYPE_NCS);
    if(sText != "")
    {
        jRow = CreateLabel(JsonArray(), "Associate AI (nw_ch_ac1): " + sText, "henchman_ai", 470.0f, 20.0f);
        jCol = JsonArrayInsert(jCol, NuiRow(jRow));
    }
    // Row 6 ******************************************************************* 500 / 241
    jRow = JsonArrayInsert(JsonArray(), NuiSpacer());
    jRow = CreateButton(jRow, "Set NPC's scripts", "btn_npc_scripts", 150.0f, 20.0f, -1.0, "btn_npc_scripts_tooltip");
    jRow = JsonArrayInsert(jRow, NuiSpacer());
    jRow = CreateButton(jRow, "Set Commandable", "btn_set_commandable", 150.0f, 20.0f, -1.0, "btn_set_commandable_tooltip");
    jRow = JsonArrayInsert(jRow, NuiSpacer());
    jRow = CreateButton(jRow, "Clear Party Rep.", "btn_clear_reputation", 150.0f, 20.0f, -1.0, "btn_clear_reputation_tooltip");
    jRow = JsonArrayInsert(jRow, NuiSpacer());
    // Add row to the column.
    jCol = JsonArrayInsert(jCol, NuiRow(jRow));
    // Row 7 ******************************************************************* 500 / 269
    jRow = JsonArrayInsert(JsonArray(), NuiSpacer());
    jRow = CreateButton(jRow, "Display Target Info", "btn_info", 150.0f, 20.0f, -1.0, "btn_info_tooltip");
    jRow = JsonArrayInsert(jRow, NuiSpacer());
    jRow = CreateButton(jRow, "Dump Object to Json", "btn_obj_json", 150.0f, 20.0f, -1.0, "btn_obj_json_tooltip");
    jRow = JsonArrayInsert(jRow, NuiSpacer());
    jRow = CreateButton(jRow, "List Object Variables", "btn_obj_var", 150.0f, 20.0f, -1.0, "btn_obj_var_tooltip");
    jRow = JsonArrayInsert(jRow, NuiSpacer());
    // Add row to the column.
    jCol = JsonArrayInsert(jCol, NuiRow(jRow));
    // Row 8 ******************************************************************* 500 / 297    jRow = JsonArray();
    jRow = CreateButton(JsonArray(), "Delete Variable", "btn_delete_var", 115.0f, 25.0f, -1.0, "btn_delete_var_tooltip");
    jRow = JsonArrayInsert(jRow, NuiSpacer());
    jRow = CreateButton(jRow, "Set Variable", "btn_set_var", 115.0f, 25.0f, -1.0, "btn_set_var_tooltip");
    jRow = JsonArrayInsert(jRow, NuiSpacer());
    jRow = CreateButton(jRow, "Get Variable", "btn_get_var", 115.0f, 25.0f, -1.0, "btn_get_var_tooltip");
    jRow = JsonArrayInsert(jRow, NuiSpacer());
    json jCombo = JsonArrayInsert(JsonArray(), NuiComboEntry("int", 0));
    jCombo = JsonArrayInsert(jCombo, NuiComboEntry("float", 1));
    jCombo = JsonArrayInsert(jCombo, NuiComboEntry("string", 2));
    jCombo = JsonArrayInsert(jCombo, NuiComboEntry("object", 3));
    jCombo = JsonArrayInsert(jCombo, NuiComboEntry("location", 4));
    jRow = CreateCombo(jRow, jCombo, "cmb_var_type", 115.0, 25.0);
    // Add row to the column.
    jCol = JsonArrayInsert(jCol, NuiRow(jRow));
    // Row 9 ******************************************************************* 500 / 329
    jRow = JsonArrayInsert(JsonArray(), NuiSpacer());
    jRow = CreateLabel(jRow, "Name:", "lbl_name", 40.0f, 20.0f);
    jRow = CreateTextEditBox(jRow, "sPlaceHolder", "txt_var_name", 40, FALSE, 425.0f, 20.0f, "txt_var_name_tooltip");
    jRow = JsonArrayInsert(jRow, NuiSpacer());
    // Add row to the column.
    jCol = JsonArrayInsert(jCol, NuiRow(jRow));
    // Row 10 ******************************************************************* 500 / 357
    jRow = JsonArrayInsert(JsonArray(), NuiSpacer());
    jRow = CreateLabel(jRow, "Value:", "lbl_value", 40.0f, 20.0f);
    jRow = CreateTextEditBox(jRow, "sPlaceHolder", "txt_var_value", 40, FALSE, 425.0f, 20.0f, "txt_var_value_tooltip");
    jRow = JsonArrayInsert(jRow, NuiSpacer());
    // Add row to the column.
    jCol = JsonArrayInsert(jCol, NuiRow(jRow));
    // Row 11 ******************************************************************* 500 / 385
    // Make the debug creature group.
    // Group Row 1 ******************************************************************* 500 / 385
    json jGroupRow = CreateButton(JsonArray(), "Debug Creature", "btn_debug_creature", 120.0f, 20.0f, -1.0, "btn_debug_creature_tooltip");
    jGroupRow = JsonArrayInsert(jGroupRow, NuiSpacer());
    jGroupRow = CreateButton(jGroupRow, "Clear Event Scripts", "btn_clear_events", 150.0f, 20.0f, -1.0, "btn_clear_events_tooltip");
    jGroupRow = JsonArrayInsert(jGroupRow, NuiSpacer());
    jGroupRow = CreateButton(jGroupRow, "Clear Debug", "btn_clear_debug", 120.0f, 20.0f, -1.0, "btn_clear_debug_tooltip");
    // Add group row to the group column.
    json jGroupCol = JsonArrayInsert(JsonArray(), NuiRow(jGroupRow));
    float fHeight = 431.0;
    // Group Row 2 ******************************************************************* 500 / ---
    object oDebugCreature = GetLocalObject(oPC, "AI_RULE_DEBUG_CREATURE_OBJECT");
    if(GetIsObjectValid(oDebugCreature))
    {
        string sScript = GetEventScript(oDebugCreature, EVENT_SCRIPT_CREATURE_ON_HEARTBEAT);
        if(sScript == "nw_c2_default1") sText = GetName(oDebugCreature) + " is using monster AI scripts (" + sScript + ").";
        else if(sScript == "nw_ch_ac1") sText = GetName(oDebugCreature) + " is using associate AI scripts (" + sScript + ").";
        else if(sScript == "xx_pc_1_hb") sText = GetName(oDebugCreature) + " is using player AI scripts (" + sScript + ").";
        else if(sScript == "0e_id_events") sText = GetName(oDebugCreature) + " is using Infinite Dungeons AI scripts (" + sScript + ").";
        else if(sScript == "0e_prc_id_events") sText = GetName(oDebugCreature) + " is using PRC Infinite Dungeons AI scripts (" + sScript + ").";
        else sText = GetName(oDebugCreature) + " is using unknown AI scripts (" + sScript + ").";
        jGroupRow = CreateLabel(JsonArray(), sText, "debug_info", 455.0f, 20.0f, NUI_HALIGN_CENTER);
        // Add group row to the group column.
        jGroupCol = JsonArrayInsert(jGroupCol, NuiRow(jGroupRow));
        fHeight = fHeight + 28;
    }
    // Group Row 3 ******************************************************************* 500 / ---
    sText = GetLocalString(GetModule(), AI_RULE_DEBUG_CREATURE);
    if(sText != "") sText = sText + " is sending AI debug to the log file.";
    else sText = "Nothing is sending AI debug to the log file.";
    jGroupRow = CreateLabel(JsonArray(), sText, "debug_log", 455.0f, 20.0f, NUI_HALIGN_CENTER);
    // Add group row to the group column.
    jGroupCol = JsonArrayInsert(jGroupCol, NuiRow(jGroupRow));
    fHeight = fHeight + 28;
    // Add group to the row.
    jRow = JsonArrayInsert(JsonArray(), NuiGroup(NuiCol(jGroupCol)));
    // Add row to the column.
    jCol = JsonArrayInsert(jCol, NuiRow(jRow));
    // Set the Layout of the window.
    json jLayout = NuiCol(jCol);
    string sName = GetName(oPC);
    if(GetStringRight(sName, 1) == "s") sName = sName + "'";
    else sName = sName + "'s";
    int nToken = SetWindow(oPC, jLayout, "pi_debug_nui", sName + " PEPS Debug Menu",
                             -1.0, -1.0, 500.0f, fHeight + 12.0f, FALSE, FALSE, TRUE, FALSE, TRUE, "pe_debug");
    // Set all binds, events, and watches.
    // Row 1 - Version label.
    // Row 2 Module Name.
    // Row 3 - 5 Script locations.
    // Row 6
    NuiSetBind(oPC, nToken, "btn_npc_scripts_event", JsonBool(TRUE));
    NuiSetBind(oPC, nToken, "btn_npc_scripts_tooltip", JsonString("  Forces NPC to use Philos AI scripts!"));
    NuiSetBind(oPC, nToken, "btn_set_commandable_event", JsonBool(TRUE));
    NuiSetBind(oPC, nToken, "btn_set_commandable_tooltip", JsonString("  Sets a creatures to commandable."));
    NuiSetBind(oPC, nToken, "btn_clear_reputation_event", JsonBool(TRUE));
    NuiSetBind(oPC, nToken, "btn_clear_reputation_tooltip", JsonString("  Clears the party's reputation with creature's faction."));
    // Row 7
    NuiSetBind(oPC, nToken, "btn_info_event", JsonBool(TRUE));
    NuiSetBind(oPC, nToken, "btn_info_tooltip", JsonString("  Displays a target object's information to the log screen."));
    NuiSetBind(oPC, nToken, "btn_obj_json_event", JsonBool(TRUE));
    NuiSetBind(oPC, nToken, "btn_obj_json_tooltip", JsonString("  Sends a Json Dump to the log file for the targeted object."));
    NuiSetBind(oPC, nToken, "btn_obj_var_event", JsonBool(TRUE));
    NuiSetBind(oPC, nToken, "btn_obj_var_tooltip", JsonString("  Sends a list of variables for the targeted object."));
    // Row 8
    NuiSetBind(oPC, nToken, "btn_delete_var_tooltip", JsonString("  Delete the variable for the targeted object or Right click for the Module."));
    NuiSetBind(oPC, nToken, "btn_set_var_tooltip", JsonString("  Set the variable for the targeted object or Right click for the Module."));
    NuiSetBind(oPC, nToken, "btn_get_var_tooltip", JsonString("  Get the variable for the targeted object or Right click for the Module."));
    NuiSetBind(oPC, nToken, "cmb_var_type_event", JsonBool(TRUE));
    NuiSetBindWatch(oPC, nToken, "cmb_var_type_selected", TRUE);
    // Row 9
    NuiSetBind(oPC, nToken, "txt_var_name_event", JsonBool(TRUE));
    NuiSetBindWatch (oPC, nToken, "txt_var_name", TRUE);
    NuiSetBind(oPC, nToken, "txt_var_name_tooltip", JsonString("  Name of the variable we are setting."));
    // Row 10
    NuiSetBind(oPC, nToken, "txt_var_value_event", JsonBool(TRUE));
    NuiSetBindWatch (oPC, nToken, "txt_var_value", TRUE);
    NuiSetBind(oPC, nToken, "txt_var_value_tooltip", JsonString("  The value to set on the variable, Objects/Locations will need to be selected."));
    // Row 11
    NuiSetBind(oPC, nToken, "btn_debug_creature_event", JsonBool(TRUE));
    NuiSetBind(oPC, nToken, "btn_debug_creature_tooltip", JsonString("  Sets target creature to send AI debug to the log file."));
    NuiSetBind(oPC, nToken, "btn_clear_events_event", JsonBool(TRUE));
    NuiSetBind(oPC, nToken, "btn_clear_events_tooltip", JsonString("  Sets a creature's event scripts to default."));
    NuiSetBind(oPC, nToken, "btn_clear_debug_event", JsonBool(TRUE));
    NuiSetBind(oPC, nToken, "btn_clear_debug_tooltip", JsonString("  Clears a creature from sending AI debug to the log file."));
}
int StartingUp(object oPC)
{
    if(GetLocalInt(oPC, AI_ADD_PLUGIN))
    {
        json jPlugin = JsonArray();
        jPlugin = JsonArrayInsert(jPlugin, JsonString("pi_debug"));
        jPlugin = JsonArrayInsert(jPlugin, JsonInt(FALSE));
        jPlugin = JsonArrayInsert(jPlugin, JsonString("Debug Menu"));
        jPlugin = JsonArrayInsert(jPlugin, JsonString("dm_tagsearch"));
        json jPlugins = GetLocalJson(oPC, AI_JSON_PLUGINS);
        jPlugins = JsonArrayInsert(jPlugins, jPlugin);
        SetLocalJson(oPC, AI_JSON_PLUGINS, jPlugin);
        SetLocalInt(oPC, AI_PLUGIN_SET, TRUE);
        return TRUE;
    }
    if(!GetLocalInt(oPC, AI_STARTING_UP)) return FALSE;
    return TRUE;
}

