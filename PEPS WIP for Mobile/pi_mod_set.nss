/*//////////////////////////////////////////////////////////////////////////////
 Script: pi_mod_settings
 Programmer: Philos
////////////////////////////////////////////////////////////////////////////////
  Plugin for changing module and area settings.
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
    // Row 1 ******************************************************************* 450 / 73
    json jRow = JsonArrayInsert(JsonArray(), NuiSpacer());
    jRow = CreateButton(jRow, "Remove Combat Music from the Module", "btn_combat_music_off", 300.0f, 20.0f, -1.0, "btn_combat_music_offtooltip");
    jRow = JsonArrayInsert(jRow, NuiSpacer());
    // Add row to the column.
    json jCol = JsonArrayInsert(JsonArray(), NuiRow(jRow));
    float fHeight = 73.0;
    // Row 2 ******************************************************************* 450 / 73
    jRow = JsonArrayInsert(JsonArray(), NuiSpacer());
    jRow = CreateButton(jRow, "Auto Daytime", "btn_night_to_day", 300.0f, 20.0f, -1.0, "btn_night_to_day_tooltip");
    jRow = JsonArrayInsert(jRow, NuiSpacer());
    // Add row to the column.
    jCol = JsonArrayInsert(jCol, NuiRow(jRow));
    fHeight += 28.0;
    // Set the Layout of the window.
    json jLayout = NuiCol(jCol);
    string sName = GetName(oPC);
    if(GetStringRight(sName, 1) == "s") sName = sName + "'";
    else sName = sName + "'s";
    int nToken = SetWindow(oPC, jLayout, "pi_test_nui", sName + " Module Settings Menu",
                             -1.0, -1.0, 450.0f, fHeight + 12.0f, FALSE, FALSE, TRUE, FALSE, TRUE, "pe_mod_set");
    // Set all binds, events, and watches.
    // Row 1
    NuiSetBind(oPC, nToken, "btn_combat_music_off_event", JsonBool(TRUE));
    NuiSetBind(oPC, nToken, "btn_combat_music_off_tooltip", JsonString("  Removes the combat music from every area in the module."));
    // Row 2
    NuiSetBind(oPC, nToken, "btn_night_to_day_event", JsonBool(TRUE));
    NuiSetBind(oPC, nToken, "btn_night_to_day_tooltip", JsonString("  Automatically passes nighttime to make it morning!"));
}
int StartingUp(object oPC)
{
    if(GetLocalInt(oPC, AI_ADD_PLUGIN))
    {
        json jPlugin = JsonArray();
        jPlugin = JsonArrayInsert(jPlugin, JsonString("pi_mod_set"));
        jPlugin = JsonArrayInsert(jPlugin, JsonInt(FALSE));
        jPlugin = JsonArrayInsert(jPlugin, JsonString("Module settings Menu"));
        jPlugin = JsonArrayInsert(jPlugin, JsonString("ir_chatmenu"));
        json jPlugins = GetLocalJson(oPC, AI_JSON_PLUGINS);
        jPlugins = JsonArrayInsert(jPlugins, jPlugin);
        SetLocalJson(oPC, AI_JSON_PLUGINS, jPlugin);
        SetLocalInt(oPC, AI_PLUGIN_SET, TRUE);
        return TRUE;
    }
    if(!GetLocalInt(oPC, AI_STARTING_UP)) return FALSE;
    return TRUE;
}

