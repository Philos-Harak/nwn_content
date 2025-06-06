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
    if(AI_SERVER) sText = " [Server]";
    // ************************************************************************* Width / Height
    // Row 1 ******************************************************************* 500 / 73
    json jRow = JsonArray();
    JsonArrayInsertInplace(jRow, NuiSpacer());
    CreateLabel(jRow, PHILOS_VERSION + sText, "lbl_version", 470.0f, 20.0f, NUI_HALIGN_CENTER);
    JsonArrayInsertInplace(jRow, NuiSpacer());
    // Add row to the column.
    json jCol = JsonArray();
    JsonArrayInsertInplace(jCol, NuiRow(jRow));
    // Row 2 ******************************************************************* 500 / 129
    jRow = JsonArray();
    sText = "Module: " + GetModuleName() + " [" + GetTag(GetModule()) + "]";
    CreateLabel(jRow, sText, "lbl_module_name", 470.0f, 20.0f, NUI_HALIGN_CENTER);
    // Add row to the column.
    JsonArrayInsertInplace(jCol, NuiRow(jRow));
    // Row 3 ******************************************************************* 500 / 101
    jRow = JsonArray();
    sText = "Monster AI (nw_c2_default1): " + ResManGetAliasFor("nw_c2_default1", RESTYPE_NCS);
    CreateLabel(jRow, sText, "monster_1_ai", 470.0f, 20.0f, NUI_HALIGN_CENTER);
    // Add row to the column.
    JsonArrayInsertInplace(jCol, NuiRow(jRow));
    // Row 4 ******************************************************************* 500 / 157
    jRow = JsonArray();
    sText = "Monster AI (j_ai_onheartbeat): " + ResManGetAliasFor("j_ai_onheartbeat", RESTYPE_NCS);
    CreateLabel(jRow, sText, "monster_2_ai", 470.0f, 20.0f, NUI_HALIGN_CENTER);
    // Add row to the column.
    JsonArrayInsertInplace(jCol, NuiRow(jRow));
    // Row 5 ******************************************************************* 500 / 213
    jRow = JsonArray();
    sText = "Associate AI (nw_ch_ac1): " + ResManGetAliasFor("nw_ch_ac1", RESTYPE_NCS);
    CreateLabel(jRow, sText, "henchman_ai", 470.0f, 20.0f, NUI_HALIGN_CENTER);
    // Add row to the column.
    JsonArrayInsertInplace(jCol, NuiRow(jRow));
    // Row 6 ******************************************************************* 500 / 241
    jRow = JsonArray();
    JsonArrayInsertInplace(jRow, NuiSpacer());
    CreateButton(jRow, "Set NPC's scripts", "btn_npc_scripts", 150.0f, 20.0f, -1.0, "btn_npc_scripts_tooltip");
    JsonArrayInsertInplace(jRow, NuiSpacer());
    CreateButton(jRow, "Set Reputations", "btn_set_reputation", 150.0f, 20.0f, -1.0, "btn_set_reputation_tooltip");
    JsonArrayInsertInplace(jRow, NuiSpacer());
    CreateButton(jRow, "Clear Party Rep.", "btn_clear_reputation", 150.0f, 20.0f, -1.0, "btn_clear_reputation_tooltip");
    JsonArrayInsertInplace(jRow, NuiSpacer());
    // Add row to the column.
    JsonArrayInsertInplace(jCol, NuiRow(jRow));
    // Row 7 ******************************************************************* 500 / 269
    jRow = JsonArray();
    JsonArrayInsertInplace(jRow, NuiSpacer());
    CreateButton(jRow, "Display Target Info", "btn_info", 150.0f, 20.0f, -1.0, "btn_info_tooltip");
    JsonArrayInsertInplace(jRow, NuiSpacer());
    CreateButton(jRow, "Dump Object to Json", "btn_obj_json", 150.0f, 20.0f, -1.0, "btn_obj_json_tooltip");
    JsonArrayInsertInplace(jRow, NuiSpacer());
    CreateButton(jRow, "List Object Variables", "btn_obj_var", 150.0f, 20.0f, -1.0, "btn_obj_var_tooltip");
    JsonArrayInsertInplace(jRow, NuiSpacer());
    // Add row to the column.
    JsonArrayInsertInplace(jCol, NuiRow(jRow));
    // Row 8 ******************************************************************* 500 / 297    jRow = JsonArray();
    jRow = JsonArray();
    CreateButton(jRow, "Delete Variable", "btn_delete_var", 115.0f, 25.0f, -1.0, "btn_delete_var_tooltip");
    JsonArrayInsertInplace(jRow, NuiSpacer());
    CreateButton(jRow, "Set Variable", "btn_set_var", 115.0f, 25.0f, -1.0, "btn_set_var_tooltip");
    JsonArrayInsertInplace(jRow, NuiSpacer());
    CreateButton(jRow, "Get Variable", "btn_get_var", 115.0f, 25.0f, -1.0, "btn_get_var_tooltip");
    JsonArrayInsertInplace(jRow, NuiSpacer());
    json jCombo = JsonArray();
    JsonArrayInsertInplace(jCombo, NuiComboEntry("int", 0));
    JsonArrayInsertInplace(jCombo, NuiComboEntry("float", 1));
    JsonArrayInsertInplace(jCombo, NuiComboEntry("string", 2));
    JsonArrayInsertInplace(jCombo, NuiComboEntry("object", 3));
    JsonArrayInsertInplace(jCombo, NuiComboEntry("location", 4));
    CreateCombo(jRow, jCombo, "cmb_var_type", 115.0, 25.0);
    // Add row to the column.
    JsonArrayInsertInplace(jCol, NuiRow(jRow));
    // Row 9 ******************************************************************* 500 / 329
    jRow = JsonArray();
    JsonArrayInsertInplace(jRow, NuiSpacer());
    CreateLabel(jRow, "Name:", "lbl_name", 40.0f, 20.0f);
    CreateTextEditBox(jRow, "sPlaceHolder", "txt_var_name", 40, FALSE, 425.0f, 20.0f, "txt_var_name_tooltip");
    JsonArrayInsertInplace(jRow, NuiSpacer());
    // Add row to the column.
    JsonArrayInsertInplace(jCol, NuiRow(jRow));
    // Row 10 ******************************************************************* 500 / 357
    jRow = JsonArray();
    JsonArrayInsertInplace(jRow, NuiSpacer());
    CreateLabel(jRow, "Value:", "lbl_value", 40.0f, 20.0f);
    CreateTextEditBox(jRow, "sPlaceHolder", "txt_var_value", 40, FALSE, 425.0f, 20.0f, "txt_var_value_tooltip");
    JsonArrayInsertInplace(jRow, NuiSpacer());
    // Add row to the column.
    JsonArrayInsertInplace(jCol, NuiRow(jRow));
    // Row 11 ******************************************************************* 500 / 385
    jRow = JsonArray();
    // Make the debug creature group.
    json jGroupRow = JsonArray();
    json jGroupCol = JsonArray();
    // Group Row 1 ******************************************************************* 500 / 385
    CreateButton(jGroupRow, "Debug Creature", "btn_debug_creature", 120.0f, 20.0f, -1.0, "btn_debug_creature_tooltip");
    JsonArrayInsertInplace(jGroupRow, NuiSpacer());
    CreateButton(jGroupRow, "Clear Debug", "btn_clear_debug", 120.0f, 20.0f, -1.0, "btn_clear_debug_tooltip");
    // Add group row to the group column.
    JsonArrayInsertInplace(jGroupCol, NuiRow(jGroupRow));
    float fHeight = 431.0;
    // Group Row 2 ******************************************************************* 500 / ---
    object oDebugCreature = GetLocalObject(oPC, "AI_RULE_DEBUG_CREATURE_OBJECT");
    if(GetIsObjectValid(oDebugCreature))
    {
        jGroupRow = JsonArray();
        string sScript = GetEventScript(oDebugCreature, EVENT_SCRIPT_CREATURE_ON_HEARTBEAT);
        if(sScript == "nw_c2_default1") sText = GetName(oDebugCreature) + " is using monster AI scripts (" + sScript + ").";
        else if(sScript == "nw_ch_ac1") sText = GetName(oDebugCreature) + " is using associate AI scripts (" + sScript + ").";
        else if(sScript == "xx_pc_1_hb") sText = GetName(oDebugCreature) + " is using player AI scripts (" + sScript + ").";
        else if(sScript == "0e_id_events") sText = GetName(oDebugCreature) + " is using Infinite Dungeons AI scripts (" + sScript + ").";
        else if(sScript == "0e_prc_id_events") sText = GetName(oDebugCreature) + " is using PRC Infinite Dungeons AI scripts (" + sScript + ").";
        else sText = GetName(oDebugCreature) + " is using unknown AI scripts (" + sScript + ").";
        CreateLabel(jGroupRow, sText, "debug_info", 455.0f, 20.0f, NUI_HALIGN_CENTER);
        // Add group row to the group column.
        JsonArrayInsertInplace(jGroupCol, NuiRow(jGroupRow));
        fHeight = fHeight + 28;
    }
    // Group Row 3 ******************************************************************* 500 / ---
    jGroupRow = JsonArray();
    sText = GetLocalString(GetModule(), AI_RULE_DEBUG_CREATURE);
    if(sText != "") sText = sText + " is sending AI debug to the log file.";
    else sText = "Nothing is sending AI debug to the log file.";
    CreateLabel(jGroupRow, sText, "debug_log", 455.0f, 20.0f, NUI_HALIGN_CENTER);
    // Add group row to the group column.
    JsonArrayInsertInplace(jGroupCol, NuiRow(jGroupRow));
    fHeight = fHeight + 28;
    // Add group to the row.
    JsonArrayInsertInplace(jRow, NuiGroup(NuiCol(jGroupCol)));
    // Add row to the column.
    JsonArrayInsertInplace(jCol, NuiRow(jRow));
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
    NuiSetBind(oPC, nToken, "btn_set_reputation_event", JsonBool(TRUE));
    NuiSetBind(oPC, nToken, "btn_set_reputation_tooltip", JsonString("  Sets a creatures faction to neutral for all standard factions."));
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
    NuiSetBind(oPC, nToken, "btn_clear_debug_event", JsonBool(TRUE));
    NuiSetBind(oPC, nToken, "btn_clear_debug_tooltip", JsonString("  Clears a creature from sending AI debug to the log file."));
}
int StartingUp(object oPC)
{
    if(GetLocalInt(oPC, AI_ADD_PLUGIN))
    {
        json jPlugin = JsonArray();
        jPlugin = JsonArrayInsert(jPlugin, JsonString("pi_debug"));
        jPlugin = JsonArrayInsert(jPlugin, JsonBool(FALSE));
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

