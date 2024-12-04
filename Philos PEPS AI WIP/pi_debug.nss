/*//////////////////////////////////////////////////////////////////////////////
 Script: pi_debug
 Programmer: Philos
////////////////////////////////////////////////////////////////////////////////
  Plugin for debugging.
*///////////////////////////////////////////////////////////////////////////////
#include "0i_nui"
#include "0i_player_target"
void main()
{
    object oPC = OBJECT_SELF;
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
    // Row 2 ******************************************************************* 482 / 101
    jRow = JsonArray();
    JsonArrayInsertInplace(jRow, NuiSpacer());
    if(ResManGetAliasFor("0e_c2_1_hb", RESTYPE_NCS) == "") sText = "Philos' Monster AI scripts are not loaded!";
    else sText = "Philos' Monster AI scripts are loaded.";
    CreateLabel(jRow, sText, "monster_ai", 400.0f, 20.0f, NUI_HALIGN_CENTER);
    JsonArrayInsertInplace(jRow, NuiSpacer());
    // Add row to the column.
    JsonArrayInsertInplace(jCol, NuiRow(jRow));
    // Row 3 ******************************************************************* 482 / 129
    jRow = JsonArray();
    JsonArrayInsertInplace(jRow, NuiSpacer());
    if(ResManGetAliasFor("0e_ch_1_hb", RESTYPE_NCS) == "") sText = "Philos' Associate AI scripts are not loaded!";
    else sText = "Philos' Associate AI scripts are loaded.";
    CreateLabel(jRow, sText, "henchman_ai", 400.0f, 20.0f, NUI_HALIGN_CENTER);
    JsonArrayInsertInplace(jRow, NuiSpacer());
    // Add row to the column.
    JsonArrayInsertInplace(jCol, NuiRow(jRow));
    // Row 4 ******************************************************************* 482 / 157
    jRow = JsonArray();
    JsonArrayInsertInplace(jRow, NuiSpacer());
    CreateButton(jRow, "Display Target Event Scripts", "btn_event_scripts", 230.0f, 20.0f, -1.0, "btn_event_scripts_tooltip");
    JsonArrayInsertInplace(jRow, NuiSpacer());
    CreateButton(jRow, "Fix Associate Scripts", "btn_fix_associate", 230.0f, 20.0f, -1.0, "btn_fix_associate_tooltip");
    JsonArrayInsertInplace(jRow, NuiSpacer());
    // Add row to the column.
    JsonArrayInsertInplace(jCol, NuiRow(jRow));
    // Row 5 ******************************************************************* 482 / 213
    jRow = JsonArray();
    // Make the debug creature group.
    json jGroupRow = JsonArray();
    json jGroupCol = JsonArray();
    // Group Row 1 ******************************************************************* 482 / 241
    JsonArrayInsertInplace(jGroupRow, NuiSpacer());
    CreateButton(jGroupRow, "Debug Creature", "btn_debug_creature", 120.0f, 20.0f, -1.0, "btn_debug_creature_tooltip");
    JsonArrayInsertInplace(jGroupRow, NuiSpacer());
    CreateButton(jGroupRow, "Clear Debug", "btn_clear_debug", 120.0f, 20.0f, -1.0, "btn_clear_debug_tooltip");
    JsonArrayInsertInplace(jGroupRow, NuiSpacer());
    // Add group row to the group column.
    JsonArrayInsertInplace(jGroupCol, NuiRow(jGroupRow));
    float fHeight = 241.0;
    // Group Row 2 ******************************************************************* 482 / ---
    object oDebugCreature = GetLocalObject(oPC, "AI_RULE_DEBUG_CREATURE_OBJECT");
    if(GetIsObjectValid(oDebugCreature))
    {
        jGroupRow = JsonArray();
        string sScript = GetEventScript(oDebugCreature, EVENT_SCRIPT_CREATURE_ON_HEARTBEAT);
        if(sScript == "0e_c2_1_hb") sText = GetName(oDebugCreature) + " is using Philos' monster AI scripts.";
        else if(sScript == "0e_ch_1_hb") sText = GetName(oDebugCreature) + " is using Philos' associate AI scripts.";
        else if(sScript == "xx_pc_1_hb") sText = GetName(oDebugCreature) + " is using Philos' player AI scripts.";
        else sText = GetName(oDebugCreature) + " is not using any Philos' AI scripts.";
        CreateLabel(jGroupRow, sText, "debug_info", 400.0f, 20.0f, NUI_HALIGN_CENTER);
        // Add group row to the group column.
        JsonArrayInsertInplace(jGroupCol, NuiRow(jGroupRow));
        fHeight = fHeight + 28;
    }
    // Group Row 3 ******************************************************************* 482 / ---
    jGroupRow = JsonArray();
    sText = GetLocalString(GetModule(), AI_RULE_DEBUG_CREATURE);
    if(sText != "") sText = sText + " is sending AI debug to the log file.";
    else sText = "Nothing is sending AI debug to the log file.";
    CreateLabel(jGroupRow, sText, "debug_log", 400.0f, 20.0f, NUI_HALIGN_CENTER);
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
                             -1.0, -1.0, 482.0f, fHeight + 12.0f, FALSE, FALSE, TRUE, FALSE, TRUE, "pe_debug");
    // Set all binds, events, and watches.
    // Row 1 - Version label.
    // Row 2
    object oModule = GetModule();
    NuiSetBind(oPC, nToken, "btn_debug_creature_event", JsonBool(TRUE));
    NuiSetBind(oPC, nToken, "btn_debug_creature_tooltip", JsonString("  Sets target creature to send AI debug to the log file."));
    NuiSetBind(oPC, nToken, "btn_clear_debug_event", JsonBool(TRUE));
    NuiSetBind(oPC, nToken, "btn_clear_debug_tooltip", JsonString("  Clears a creature from sending AI debug to the log file."));
    // Row 3 Label showing if monster AI is in use.
    // Row 4 Label showing if associate AI is in use.
    // Row 5
    NuiSetBind(oPC, nToken, "btn_event_scripts_event", JsonBool(TRUE));
    NuiSetBind(oPC, nToken, "btn_event_scripts_tooltip", JsonString("  Displays target creatures event scripts to log screen."));
    NuiSetBind(oPC, nToken, "btn_fix_associate_event", JsonBool(TRUE));
    NuiSetBind(oPC, nToken, "txt_fix_associate_tooltip", JsonString("  Resets an associates event scripts to work with PEPS."));
}
