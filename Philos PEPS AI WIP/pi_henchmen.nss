/*//////////////////////////////////////////////////////////////////////////////
// Script Name: pi_henchmen
////////////////////////////////////////////////////////////////////////////////
 Executable plug in script for Philos Module Extentions.

 UI to save a players as Henchmen.
*///////////////////////////////////////////////////////////////////////////////
#include "pinc_henchmen"
// Does startup check if the game has just been loaded.
int StartingUp(object oPC);
// Inserts base classes to an array for a combo box.
json JArrayInsertBaseClasses();
void main()
{
    object oPC = OBJECT_SELF;
    if(StartingUp(oPC)) return;
    // Set window to not save until it has been created.
    SetLocalInt (oPC, "AI_NO_NUI_SAVE", TRUE);
    DelayCommand (0.5f, DeleteLocalInt (oPC, "AI_NO_NUI_SAVE"));
    // Row 1 (Buttons) ********************************************************* 775 / 73
    json jRow = JsonArray();
    CreateButtonSelect(jRow, "Party 1", "btn_party1", 90.0f, 20.0f);
    JsonArrayInsertInplace(jRow, NuiSpacer());
    CreateButtonSelect(jRow, "Party 2", "btn_party2", 90.0f, 20.0f);
    JsonArrayInsertInplace(jRow, NuiSpacer());
    CreateButtonSelect(jRow, "Party 3", "btn_party3", 90.0f, 20.0f);
    JsonArrayInsertInplace(jRow, NuiSpacer());
    CreateButtonSelect(jRow, "Party 4", "btn_party4", 90.0f, 20.0f);
    CreateButtonSelect(jRow, "Party 5", "btn_party5", 90.0f, 20.0f);
    JsonArrayInsertInplace(jRow, NuiSpacer());
    CreateButtonSelect(jRow, "Party 6", "btn_party6", 90.0f, 20.0f);
    JsonArrayInsertInplace(jRow, NuiSpacer());
    CreateButtonSelect(jRow, "Party 7", "btn_party7", 90.0f, 20.0f);
    JsonArrayInsertInplace(jRow, NuiSpacer());
    CreateButtonSelect(jRow, "Party 8", "btn_party8", 90.0f, 20.0f);
    // Add the row to the column.
    json jCol = JsonArray();
    JsonArrayInsertInplace(jCol, NuiRow(jRow));
    // Row 2 (Options)********************************************************** 775 / 101
    jRow = JsonArray();
    CreateButton(jRow, "Clear Party", "btn_clear_party", 120.0f, 20.0f, -1.0, "btn_clear_party_tooltip");
    JsonArrayInsertInplace(jRow, NuiSpacer());
    CreateButton(jRow, "Party Join", "btn_join_party", 120.0f, 20.0f, -1.0, "btn_join_party_tooltip");
    JsonArrayInsertInplace(jRow, NuiSpacer());
    CreateButtonSelect(jRow, "Create NPC Henchman", "btn_npc_henchman", 200.0f, 20.0f, "btn_npc_henchman_tooltip");
    JsonArrayInsertInplace(jRow, NuiSpacer());
    CreateButton(jRow, "Save Party", "btn_save_party", 120.0f, 20.0f, -1.0, "btn_save_party_tooltip");
    JsonArrayInsertInplace(jRow, NuiSpacer());
    CreateButton(jRow, "Remove Party", "btn_remove_party", 120.0f, 20.0f, -1.0, "btn_remove_party_tooltip");
    // Add the row to the column.
    JsonArrayInsertInplace(jCol, NuiRow(jRow));
    // Row 3 (Names and List titles) ******************************************* 775 / 124
    jRow = JsonArray();
    CreateLabel(jRow, "", "lbl_save_char", 150.0, 15.0, 0, 0);
    CreateLabel(jRow, "", "lbl_save_list", 200.0, 15.0, 0, 0);
    CreateLabel(jRow, "In game party", "lbl_game_list", 200.0, 15.0, 0, 0);
    CreateLabel(jRow, "", "lbl_game_char", 150.0, 15.0, 0, 0);
    // Add the row to the column.
    JsonArrayInsertInplace(jCol, NuiRow(jRow));
    // Row 4 (List Characters) ************************************************* 775 / 488 (364)
    // Saved Characters for Party #
    // ***** Adding character saved group next to the button list **************
    jRow = JsonArray();
    json jGroupRow = JsonArray();
    json jGroupCol = JsonArray();
    JsonArrayInsertInplace(jGroupRow, NuiSpacer());
    CreateImage(jGroupRow, "", "img_saved_portrait", NUI_ASPECT_EXACTSCALED, NUI_HALIGN_CENTER, NUI_VALIGN_TOP, 128.0, 200.0, 0.0);
    JsonArrayInsertInplace(jGroupRow, NuiSpacer());
    JsonArrayInsertInplace(jGroupCol, NuiRow(jGroupRow));
    jGroupRow = JsonArray();
    CreateLabel(jGroupRow, "", "lbl_saved_stats", 150.0, 15.0, 0, 0, 0.0);
    JsonArrayInsertInplace(jGroupCol, NuiRow(jGroupRow));
    jGroupRow = JsonArray();
    CreateLabel(jGroupRow, "", "lbl_saved_classes", 150.0, 15.0, 0, 0, 0.0);
    JsonArrayInsertInplace(jGroupCol, NuiRow(jGroupRow));
    jGroupRow = JsonArray();
    CreateButton(jGroupRow, "", "btn_saved_join", 75.0, 20.0);
    CreateButton(jGroupRow, "Remove", "btn_saved_remove", 75.0, 20.0);
    JsonArrayInsertInplace(jGroupCol, NuiRow(jGroupRow));
    //jGroupRow = JsonArray();
    //CreateButton(jGroupRow, "Edit", "btn_saved_edit", 150.0, 20.0);
    //JsonArrayInsertInplace(jGroupCol, NuiRow(jGroupRow));
    JsonArrayInsertInplace(jRow, NuiGroup(NuiCol(jGroupCol)));
    // Create the button template for the List.
    json jButton = NuiId(NuiButton(NuiBind ("btns_saved_char")), "btn_saved_char");
    json jList = JsonArrayInsert(JsonArray (), NuiListTemplateCell(jButton, 170.0, TRUE));
    // Create the list with the template.
    CreateList(jRow, jList, "btns_saved_char", 25.0, 200.0, 325.0);
    // Current Characters.
    // Create the button template for the List.
    jButton = NuiId(NuiButton(NuiBind ("btns_cur_char")), "btn_cur_char");
    jList = JsonArrayInsert(JsonArray (), NuiListTemplateCell(jButton, 170.0, TRUE));
    // Create the list with the template.
    CreateList(jRow, jList, "btns_cur_char", 25.0, 200.0, 325.0);
    // ***** Adding character current group next to the button list ************
    jGroupRow = JsonArray();
    jGroupCol = JsonArray();
    JsonArrayInsertInplace(jGroupRow, NuiSpacer());
    CreateImage(jGroupRow, "", "img_cur_portrait", NUI_ASPECT_EXACTSCALED, NUI_HALIGN_CENTER, NUI_VALIGN_TOP, 128.0, 200.0, 0.0);
    JsonArrayInsertInplace(jGroupRow, NuiSpacer());
    JsonArrayInsertInplace(jGroupCol, NuiRow(jGroupRow));
    jGroupRow = JsonArray();
    CreateLabel(jGroupRow, "", "lbl_cur_stats", 150.0, 15.0, 0, 0, 0.0);
    JsonArrayInsertInplace(jGroupCol, NuiRow(jGroupRow));
    jGroupRow = JsonArray();
    CreateLabel(jGroupRow, "", "lbl_cur_classes", 150.0, 15.0, 0, 0, 0.0);
    JsonArrayInsertInplace(jGroupCol, NuiRow(jGroupRow));
    jGroupRow = JsonArray();
    CreateButton(jGroupRow, "", "btn_cur_save", 75.0, 20.0);
    CreateButton(jGroupRow, "Remove", "btn_cur_remove", 75.0, 20.0);
    JsonArrayInsertInplace(jGroupCol, NuiRow(jGroupRow));
    jGroupRow = JsonArray();
    CreateButton(jGroupRow, "Edit", "btn_cur_edit", 150.0, 20.0);
    JsonArrayInsertInplace(jGroupCol, NuiRow(jGroupRow));
    JsonArrayInsertInplace(jRow, NuiGroup(NuiCol(jGroupCol)));
    // Add the row to the column.
    JsonArrayInsertInplace(jCol, NuiRow(jRow));
    // Set the layout of the window.
    json jLayout = NuiCol(jCol);
    // Get the window location to restore it from the database.
    CheckHenchmanDataAndInitialize(oPC, "0");
    json jData = GetHenchmanDbJson(oPC, "henchman", "0");
    json jGeometry = JsonObjectGet(jData, "henchman_nui");
    float fX = JsonGetFloat(JsonObjectGet(jGeometry, "x"));
    float fY = JsonGetFloat(JsonObjectGet(jGeometry, "y"));
    if(fX == 0.0 && fY == 0.0)
    {
        fX = -1.0;
        fY = -1.0;
    }
    string sName = GetName(oPC);
    if(GetStringRight(sName, 1) == "s") sName = sName + "'";
    else sName = sName + "'s";
    int nToken = SetWindow (oPC, jLayout, "henchman_nui", sName + " party",
                            fX, fY, 775.0, 488.0, FALSE, FALSE, TRUE, FALSE, TRUE, "pe_henchmen");
    // Lets set MaxHenchman here.
    if(GetMaxHenchmen() < 6) SetMaxHenchmen(6);
    // Setup watch for saving location.
    NuiSetBindWatch (oPC, nToken, "window_geometry", TRUE);
    // Set the elements to show events.
    NuiSetBind(oPC, nToken, "btn_save_pc_event", JsonBool (TRUE));
    NuiSetBind(oPC, nToken, "btn_current_party_event", JsonBool (TRUE));
    string sParty = GetHenchmanDbString(oPC, "henchname", "0");
    if(sParty == "")
    {
        SetHenchmanDbString(oPC, "henchname", "1", "0");
        sParty = "1";
    }
    // Set the party # buttons.
    int nIndex;
    string sIndex;
    for(nIndex = 1; nIndex < 9; nIndex++)
    {
        sIndex = IntToString(nIndex);
        if(sParty == sIndex) NuiSetBind(oPC, nToken, "btn_party" + sIndex, JsonBool(TRUE));
        else NuiSetBind(oPC, nToken, "btn_party" + sIndex, JsonBool(FALSE));
        NuiSetBind(oPC, nToken, "btn_party" + sIndex + "_event", JsonBool (TRUE));
    }
    NuiSetBind(oPC, nToken, "btn_npc_henchman_event", JsonBool(TRUE));
    string sText = "  Select a creature to copy and have them join you.";
    NuiSetBind(oPC, nToken, "btn_npc_henchman_tooltip", JsonString(sText));
    // ********** Saved Henchman in party # *********
    nIndex = 0;
    int nSlot, nMaxHenchman = AI_MAX_HENCHMAN + 1;
    json jButtons = JsonArray();
    string sFirstHenchman, sButtonText;
    json jNPCs, jNPC;
    // Add saved party members from sParty to the button list.
    while(nIndex < nMaxHenchman)
    {
        sIndex = IntToString(nIndex);
        sButtonText = GetHenchmanDbString(oPC, "henchname", sParty + sIndex);
        if(sButtonText != "")
        {
            JsonArrayInsertInplace(jButtons, JsonString(sButtonText));
            SetHenchmanDbString(oPC, "slot", sParty + IntToString(nSlot++), sParty + sIndex);
        }
        nIndex++;
    }
    // Add the buttons to the list.
    NuiSetBind(oPC, nToken, "btns_saved_char", jButtons);
    // Set up button lables for henchman.
    NuiSetBind(oPC, nToken, "lbl_save_list_label", JsonString("Party Save " + sParty));
    AddSavedCharacterInfo(oPC, nToken, sParty);
    // ********** Current Party *********
    NuiSetBind(oPC, nToken, "btn_current_party", JsonBool(TRUE));
    NuiSetBind(oPC, nToken, "btn_clear_party", JsonBool(FALSE));
    NuiSetBind(oPC, nToken, "lbl_save_char", JsonBool(TRUE));
    // Set up button labels for henchman.
    NuiSetBind(oPC, nToken, "btn_join_save_label", JsonString("Save"));
    nIndex = 0;
    jButtons = JsonArray();
    object oPartyMember, oCharacter = OBJECT_INVALID;
    // Add current party members to the button list.
    while(nIndex < AI_MAX_HENCHMAN)
    {
        if(nIndex == 0) oPartyMember = oPC;
        else oPartyMember = GetAssociate(ASSOCIATE_TYPE_HENCHMAN, oPC, nIndex);
        if(oPartyMember != OBJECT_INVALID) JsonArrayInsertInplace(jButtons, JsonString(GetName(oPartyMember)));
        else break;
        nIndex++;
    }
    // Add the buttons to the list.
    NuiSetBind(oPC, nToken, "btns_cur_char", jButtons);
    AddCurrentCharacterInfo(oPC, nToken, sParty);
}
int StartingUp(object oPC)
{
    if(GetLocalInt(oPC, AI_ADD_PLUGIN))
    {
        json jPlugin = JsonArray();
        jPlugin = JsonArrayInsert(jPlugin, JsonString("pi_henchmen"));
        jPlugin = JsonArrayInsert(jPlugin, JsonBool(FALSE));
        jPlugin = JsonArrayInsert(jPlugin, JsonString("Henchmen Menu"));
        jPlugin = JsonArrayInsert(jPlugin, JsonString("dm_creator"));
        json jPlugins = GetLocalJson(oPC, AI_JSON_PLUGINS);
        jPlugins = JsonArrayInsert(jPlugins, jPlugin);
        SetLocalJson(oPC, AI_JSON_PLUGINS, jPlugin);
        SetLocalInt(oPC, AI_PLUGIN_SET, TRUE);
        return TRUE;
    }
    if(!GetLocalInt(oPC, AI_STARTING_UP)) return FALSE;
    return TRUE;
}

