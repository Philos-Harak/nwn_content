/*//////////////////////////////////////////////////////////////////////////////
 Script: pi_test
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
    CreateButton(jRow, "Level Up Creature", "btn_level", 150.0f, 20.0f, -1.0, "btn_level_tooltip");
    JsonArrayInsertInplace(jRow, NuiSpacer());
    CreateButton(jRow, "Gold for Creature", "btn_gold", 150.0f, 20.0f, -1.0, "btn_gold_tooltip");
    JsonArrayInsertInplace(jRow, NuiSpacer());
    CreateButton(jRow, "Force Rest Creature", "btn_rest", 150.0f, 20.0f, -1.0, "btn_rest_tooltip");
    JsonArrayInsertInplace(jRow, NuiSpacer());
    // Add row to the column.
    json jCol = JsonArray();
    JsonArrayInsertInplace(jCol, NuiRow(jRow));
    // Row 2 ******************************************************************* 482 / 101
    jRow = JsonArray();
    JsonArrayInsertInplace(jRow, NuiSpacer());
    CreateButton(jRow, "Heal Creature", "btn_heal", 150.0f, 20.0f, -1.0, "btn_heal_tooltip");
    JsonArrayInsertInplace(jRow, NuiSpacer());
    CreateButton(jRow, "Kill Creature", "btn_kill", 150.0f, 20.0f, -1.0, "btn_kill_tooltip");
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
                             -1.0, -1.0, 482.0f, fHeight + 12.0f, FALSE, FALSE, TRUE, FALSE, TRUE, "pe_test");
    // Set all binds, events, and watches.
    // Row 1
    NuiSetBind(oPC, nToken, "btn_level_event", JsonBool(TRUE));
    NuiSetBind(oPC, nToken, "btn_level_tooltip", JsonString("  Give level to target creature."));
    NuiSetBind(oPC, nToken, "btn_gold_event", JsonBool(TRUE));
    NuiSetBind(oPC, nToken, "btn_gold_tooltip", JsonString("  Give Gold to target creature."));
    NuiSetBind(oPC, nToken, "btn_rest_event", JsonBool(TRUE));
    NuiSetBind(oPC, nToken, "btn_rest_tooltip", JsonString("  Force rest target creature."));
    // Row 2
    NuiSetBind(oPC, nToken, "btn_heal_event", JsonBool(TRUE));
    NuiSetBind(oPC, nToken, "btn_heal_tooltip", JsonString("  Heal target creature to max hitpoints."));
    NuiSetBind(oPC, nToken, "btn_kill_event", JsonBool(TRUE));
    NuiSetBind(oPC, nToken, "btn_kill_tooltip", JsonString("  Kill target creature doing 10,000 magic damage."));
}
