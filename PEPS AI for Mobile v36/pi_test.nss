/*//////////////////////////////////////////////////////////////////////////////
 Script: pi_test
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
    string sText;
    // Set window to not save until it has been created.
    //SetLocalInt (oPC, AI_NO_NUI_SAVE, TRUE);
    //DelayCommand (0.5f, DeleteLocalInt (oPC, AI_NO_NUI_SAVE));
    // ************************************************************************* Width / Height
    // Row 1 ******************************************************************* 636 / 73
    json jRow = JsonArray();
    JsonArrayInsertInplace(jRow, NuiSpacer());
    CreateButton(jRow, "Level Up Creature", "btn_level", 150.0f, 20.0f, -1.0, "btn_level_tooltip");
    JsonArrayInsertInplace(jRow, NuiSpacer());
    CreateButton(jRow, "Gold for Creature", "btn_gold", 150.0f, 20.0f, -1.0, "btn_gold_tooltip");
    JsonArrayInsertInplace(jRow, NuiSpacer());
    CreateButton(jRow, "Force Rest Creature", "btn_rest", 150.0f, 20.0f, -1.0, "btn_rest_tooltip");
    JsonArrayInsertInplace(jRow, NuiSpacer());
    CreateButton(jRow, "ID/UnID Item", "btn_id_item", 150.0f, 20.0f, -1.0, "btn_id_item_tooltip");
    JsonArrayInsertInplace(jRow, NuiSpacer());
    // Add row to the column.
    json jCol = JsonArray();
    JsonArrayInsertInplace(jCol, NuiRow(jRow));
    // Row 2 ******************************************************************* 636 / 101
    jRow = JsonArray();
    JsonArrayInsertInplace(jRow, NuiSpacer());
    CreateButton(jRow, "Heal Creature", "btn_heal", 150.0f, 20.0f, -1.0, "btn_heal_tooltip");
    JsonArrayInsertInplace(jRow, NuiSpacer());
    CreateButton(jRow, "Clear Creature Actions", "btn_clear", 150.0f, 20.0f, -1.0, "btn_clear_tooltip");
    JsonArrayInsertInplace(jRow, NuiSpacer());
    CreateButton(jRow, "Kill Creature", "btn_kill", 150.0f, 20.0f, -1.0, "btn_kill_tooltip");
    JsonArrayInsertInplace(jRow, NuiSpacer());
    CreateButton(jRow, "Remove Object", "btn_remove", 150.0f, 20.0f, -1.0, "btn_remove_tooltip");
    JsonArrayInsertInplace(jRow, NuiSpacer());
    // Add row to the column.
    JsonArrayInsertInplace(jCol, NuiRow(jRow));
    float fHeight = 101.0;
    // Set the Layout of the window.
    json jLayout = NuiCol(jCol);
    string sName = GetName(oPC);
    if(GetStringRight(sName, 1) == "s") sName = sName + "'";
    else sName = sName + "'s";
    int nToken = SetWindow(oPC, jLayout, "pi_test_nui", sName + " PEPS Testing Menu",
                             -1.0, -1.0, 636.0f, fHeight + 12.0f, FALSE, FALSE, TRUE, FALSE, TRUE, "pe_test");
    // Set all binds, events, and watches.
    // Row 1
    NuiSetBind(oPC, nToken, "btn_level_event", JsonBool(TRUE));
    NuiSetBind(oPC, nToken, "btn_level_tooltip", JsonString("  Give level to target creature."));
    NuiSetBind(oPC, nToken, "btn_gold_event", JsonBool(TRUE));
    NuiSetBind(oPC, nToken, "btn_gold_tooltip", JsonString("  Give Gold to target creature."));
    NuiSetBind(oPC, nToken, "btn_rest_event", JsonBool(TRUE));
    NuiSetBind(oPC, nToken, "btn_rest_tooltip", JsonString("  Force rest target creature."));
    NuiSetBind(oPC, nToken, "btn_id_item_event", JsonBool(TRUE));
    NuiSetBind(oPC, nToken, "btn_id_item_tooltip", JsonString("  Identify or UnIdentify the target item."));
    // Row 2
    NuiSetBind(oPC, nToken, "btn_heal_event", JsonBool(TRUE));
    NuiSetBind(oPC, nToken, "btn_heal_tooltip", JsonString("  Heal target creature to max hitpoints."));
    NuiSetBind(oPC, nToken, "btn_clear_event", JsonBool(TRUE));
    NuiSetBind(oPC, nToken, "btn_clear_tooltip", JsonString("  Clears a creature's actions including combat."));
    NuiSetBind(oPC, nToken, "btn_kill_event", JsonBool(TRUE));
    NuiSetBind(oPC, nToken, "btn_kill_tooltip", JsonString("  Kill target creature doing 10,000 magic damage."));
    NuiSetBind(oPC, nToken, "btn_remove_event", JsonBool(TRUE));
    NuiSetBind(oPC, nToken, "btn_remove_tooltip", JsonString("  Remove selected object or the nearest object to ground selection."));
}
int StartingUp(object oPC)
{
    if(GetLocalInt(oPC, AI_ADD_PLUGIN))
    {
        json jPlugin = JsonArray();
        jPlugin = JsonArrayInsert(jPlugin, JsonString("pi_test"));
        jPlugin = JsonArrayInsert(jPlugin, JsonBool(FALSE));
        jPlugin = JsonArrayInsert(jPlugin, JsonString("Testing Menu"));
        jPlugin = JsonArrayInsert(jPlugin, JsonString("ir_charsheet"));
        json jPlugins = GetLocalJson(oPC, AI_JSON_PLUGINS);
        jPlugins = JsonArrayInsert(jPlugins, jPlugin);
        SetLocalJson(oPC, AI_JSON_PLUGINS, jPlugin);
        SetLocalInt(oPC, AI_PLUGIN_SET, TRUE);
        return TRUE;
    }
    if(!GetLocalInt(oPC, AI_STARTING_UP)) return FALSE;
    return TRUE;
}
