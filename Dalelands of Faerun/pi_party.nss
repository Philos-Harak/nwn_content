/*//////////////////////////////////////////////////////////////////////////////
// Script Name: pi_party
////////////////////////////////////////////////////////////////////////////////
 Executable plug in script for Philos Module Extentions.

 UI to save a players as Henchmen.
*///////////////////////////////////////////////////////////////////////////////
#include "pinc_party"
// Does startup check if the game has just been loaded.
int StartingUp(object oPC);
// Inserts base classes to an array for a combo box.
json JArrayInsertBaseClasses();
void main()
{
    object oPC = OBJECT_SELF;
    if(StartingUp(oPC)) return;
    object oArea = GetArea(oPC);
    // Only run if the player is in a Civilized area!
    if(!GetLocalInt(oArea, "0_No_Difficulty") && !GetIsDungeonMaster(oPC) && 
      (GetTag(oArea) != "cynosure"))
    {
        SendMessages("You must be in a safe area such as a Town or City to look at your adventuring party!", COLOR_RED, oPC);
        return;
    }
    // Set window to not save until it has been created.
    SetLocalInt (oPC, "AI_NO_NUI_SAVE", TRUE);
    DelayCommand (0.5f, DeleteLocalInt (oPC, "AI_NO_NUI_SAVE"));
    // Row 1 (Party Buttons) *************************************************** 775 / 73
    json jRow = CreateButtonSelect(JsonArray(), "Party 1", "btn_party1", 150.0f, 20.0f);
    jRow = JsonArrayInsert(jRow, NuiSpacer());
    jRow = CreateButtonSelect(jRow, "Party 2", "btn_party2", 150.0f, 20.0f);
    jRow = JsonArrayInsert(jRow, NuiSpacer());
    jRow = CreateButtonSelect(jRow, "Party 3", "btn_party3", 150.0f, 20.0f);
    jRow = JsonArrayInsert(jRow, NuiSpacer());
    jRow = CreateButtonSelect(jRow, "Party 4", "btn_party4", 150.0f, 20.0f);
    jRow = JsonArrayInsert(jRow, NuiSpacer());
    jRow = CreateButtonSelect(jRow, "Dead", "btn_party8", 150.0f, 20.0f);
    json jCol = JsonArrayInsert(JsonArray(), NuiRow(jRow));
    // Row 2 (Option Buttons)*************************************************** 775 / 101
    jRow = CreateButton(JsonArray(), "Party Join", "btn_join_party", 120.0f, 20.0f, -1.0, "btn_join_party_tooltip");
    int bDungeonMaster = GetIsDungeonMaster(oPC);
    if((bDungeonMaster))
    {
        jRow = JsonArrayInsert(jRow, NuiSpacer());
        jRow = CreateButton(jRow, "Options", "btn_options", 100.0, 20.0);
    }
    jRow = JsonArrayInsert(jRow, NuiSpacer());
    jRow = CreateButton(jRow, "Move Party", "btn_move_party", 120.0f, 20.0f, -1.0, "btn_move_party_tooltip");
    jCol = JsonArrayInsert(jCol, NuiRow(jRow));
    // Row 3 (Names and List titles) ******************************************* 775 / 124
    jRow = CreateLabel(JsonArray(), "", "lbl_save_char_name", 175.0, 20.0, 0.0, 0, 0);
    jRow = CreateLabel(jRow, "", "lbl_save_list_name", 200.0, 20.0, 0.0, 0, 0);
    jRow = CreateLabel(jRow, "Current Party", "lbl_cur_list_name", 200.0, 20.0, 0.0, 0, 0);
    jRow = CreateLabel(jRow, "", "lbl_cur_char_name", 175.0, 20.0, 0.0, 0, 0);
    jCol = JsonArrayInsert(jCol, NuiRow(jRow));
    // Row 4 (List Characters) ************************************************* 775 / 488 (364)
    // Saved Characters for Party #
    // ***** Adding character saved group next to the button list **************
    json jGroupRow = JsonArrayInsert(JsonArray(), NuiSpacer());
    jGroupRow = CreateImage(jGroupRow, "", "img_saved_portrait", NUI_ASPECT_EXACTSCALED, NUI_HALIGN_CENTER, NUI_VALIGN_TOP, 128.0, 200.0);
    jGroupRow = JsonArrayInsert(jGroupRow, NuiSpacer());
    json jGroupCol = JsonArrayInsert(JsonArray(), NuiRow(jGroupRow));
    jGroupRow = CreateLabel(JsonArray(), "", "lbl_saved_stats", 150.0, 15.0, 0.0, 0, 0);
    jGroupCol = JsonArrayInsert(jGroupCol, NuiRow(jGroupRow));
    jGroupRow = CreateLabel(JsonArray(), "", "lbl_saved_classes", 150.0, 15.0, 0.0, 0, 0);
    jGroupCol = JsonArrayInsert(jGroupCol, NuiRow(jGroupRow));
    jGroupRow = CreateButton(JsonArray(), "", "btn_saved_join", 150.0, 20.0);
    jGroupCol = JsonArrayInsert(jGroupCol, NuiRow(jGroupRow));
    jRow = JsonArrayInsert(JsonArray(), NuiGroup(NuiCol(jGroupCol)));
    // Create the button template for the List.
    json jButton = NuiId(NuiButton(NuiBind("btns_saved_char")), "btn_saved_char");
    json jList = JsonArrayInsert(JsonArray(), NuiListTemplateCell(jButton, 170.0, TRUE));
    // Create the list with the template.
    jRow = CreateList(jRow, jList, "btns_saved_char", 25.0, 200.0, 325.0);
    // Current Characters.
    // Create the button template for the List.
    jButton = NuiId(NuiButton(NuiBind ("btns_cur_char")), "btn_cur_char");
    jList = JsonArrayInsert(JsonArray (), NuiListTemplateCell(jButton, 170.0, TRUE));
    // Create the list with the template.
    jRow = CreateList(jRow, jList, "btns_cur_char", 25.0, 200.0, 325.0);
    // ***** Adding character current group next to the button list ************
    jGroupRow = JsonArrayInsert(JsonArray(), NuiSpacer());
    jGroupRow = CreateImage(jGroupRow, "", "img_cur_portrait", NUI_ASPECT_EXACTSCALED, NUI_HALIGN_CENTER, NUI_VALIGN_TOP, 128.0, 200.0);
    jGroupRow = JsonArrayInsert(jGroupRow, NuiSpacer());
    jGroupCol = JsonArrayInsert(JsonArray(), NuiRow(jGroupRow));
    jGroupRow = CreateLabel(JsonArray(), "", "lbl_cur_gender", 150.0, 15.0, 0.0, 0, 0);
    jGroupCol = JsonArrayInsert(jGroupCol, NuiRow(jGroupRow));
    jGroupRow = CreateLabel(JsonArray(), "", "lbl_cur_race", 150.0, 15.0, 0.0, 0, 0);
    jGroupCol = JsonArrayInsert(jGroupCol, NuiRow(jGroupRow));
    jGroupRow = CreateLabel(JsonArray(), "", "lbl_cur_classes", 150.0, 15.0, 0.0, 0, 0);
    jGroupCol = JsonArrayInsert(jGroupCol, NuiRow(jGroupRow));
    jGroupRow = CreateButton(JsonArray(), "Move", "btn_cur_move", 150.0, 20.0, -1.0, "btn_cur_move_tooltip");
    jGroupCol = JsonArrayInsert(jGroupCol, NuiRow(jGroupRow));
    jGroupRow = CreateButton(JsonArray(), "Edit", "btn_cur_edit", 150.0, 20.0);
    jGroupCol = JsonArrayInsert(jGroupCol, NuiRow(jGroupRow));
    jRow = JsonArrayInsert(jRow, NuiGroup(NuiCol(jGroupCol)));
    // Add the row to the column.
    jCol = JsonArrayInsert(jCol, NuiRow(jRow));
    // Set the layout of the window.
    json jLayout = NuiCol(jCol);
    // Get the window location to restore it from the database.
    CheckHenchmanDataAndInitialize(oPC, "Data");
    json jData = GetHenchmanDbJson(oPC, "classes", "Data");
    jData = GetHenchmanDbJson(oPC, "henchman", "Data");
    json jGeometry = JsonObjectGet(jData, "party_nui");
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
    int nToken = SetWindow (oPC, jLayout, "party_nui", sName + " adventuring party",
                            fX, fY, 775.0, 488.0, FALSE, FALSE, TRUE, FALSE, TRUE, "pe_party");
    // Setup watch for saving location.
    NuiSetBindWatch (oPC, nToken, "window_geometry", TRUE);
    // Set the elements to show events.
    //NuiSetBind(oPC, nToken, "btn_save_pc_event", JsonBool (TRUE));
    //NuiSetBind(oPC, nToken, "btn_current_party_event", JsonBool (TRUE));
    string sParty = GetHenchmanDbString(oPC, "henchname", "Data");
    if(sParty == "")
    {
        SetHenchmanDbString(oPC, "henchname", "1", "Data");
        sParty = "1";
    }
    // Set the party # buttons.
    int nIndex;
    string sIndex;
    // Your adventuring group size is based on the main players character level.
    // Number of parties is (character level / 5);
    int nLevel = (GetCharacterLevels(oPC) / 5);
    if(nLevel < 1) nLevel = 1;
    for(nIndex = 1; nIndex < 5; nIndex++)
    {
        sIndex = IntToString(nIndex);
        if(sParty == sIndex) NuiSetBind(oPC, nToken, "btn_party" + sIndex, JsonBool(TRUE));
        else NuiSetBind(oPC, nToken, "btn_party" + sIndex, JsonBool(FALSE));
        if(nLevel >= nIndex) NuiSetBind(oPC, nToken, "btn_party" + sIndex + "_event", JsonBool (TRUE));
    }
    if(bDungeonMaster) NuiSetBind(oPC, nToken, "btn_options_event", JsonBool(TRUE));
    // ********** Saved Henchman in party # *********
    nIndex = 0;
    object oModule = GetModule();
    CheckHenchmanDataAndInitialize(oModule, "Data");
    jData = GetHenchmanDbJson(oModule, "classes", "Data");
    if(JsonGetType(jData) == JSON_TYPE_NULL) jData = SetPartyOptions();
    int nSlot, nMaxPartySize = JsonGetInt(JsonObjectGet(jData, "Max_Party_Size")) + 1;
    json jButtons = JsonArray();
    string sFirstHenchman, sButtonText;
    json jNPCs, jNPC;
    // Add saved party members from sParty to the button list.
    while(nIndex < 11)
    {
        sIndex = IntToString(nIndex);
        sButtonText = GetHenchmanDbString(oPC, "henchname", sParty + sIndex);
        if(sButtonText != "")
        {
            jButtons = JsonArrayInsert(jButtons, JsonString(sButtonText));
            SetHenchmanDbString(oPC, "slot", sParty + IntToString(nSlot++), sParty + sIndex);
        }
        nIndex++;
    }
    // Add the buttons to the list.
    NuiSetBind(oPC, nToken, "btns_saved_char", jButtons);
    // Set up button lables for henchman.
    NuiSetBind(oPC, nToken, "lbl_save_list_name_label", JsonString("Party " + sParty));
    AddSavedCharacterInfo(oPC, nToken, sParty);
    // ********** Current Party *********
    NuiSetBind(oPC, nToken, "btn_current_party", JsonBool(TRUE));
    NuiSetBind(oPC, nToken, "lbl_move_char", JsonBool(TRUE));
    // Set up button labels for henchman.
    NuiSetBind(oPC, nToken, "btn_join_save_label", JsonString("Save"));
    nIndex = 0;
    jButtons = JsonArray();
    object oPartyMember, oCharacter = OBJECT_INVALID;
    // Add current party members to the button list.
    while(nIndex < nMaxPartySize + 1)
    {
        if(nIndex == 0)
        {
            jButtons = JsonArrayInsert(jButtons, JsonString(GetName(oPC)));
        }
        else oPartyMember = GetAssociate(ASSOCIATE_TYPE_HENCHMAN, oPC, nIndex);
        if(oPartyMember != OBJECT_INVALID &&
          ((RESTRICT_HENCHMAN_TYPES && GetLocalInt(oPartyMember, PC_ASSOCIATE) == 1) ||
          !RESTRICT_HENCHMAN_TYPES))
        {
            jButtons = JsonArrayInsert(jButtons, JsonString(GetName(oPartyMember)));
        }
        nIndex++;
    }
    // Add the buttons to the list.
    NuiSetBind(oPC, nToken, "btns_cur_char", jButtons);
    AddCurrentCharacterInfo(oPC, nToken, sParty);
}
int StartingUp(object oPC)
{
    if(GetLocalInt(oPC, "AI_ADD_PLUGIN"))
    {
        json jPlugin = JsonArray();
        jPlugin = JsonArrayInsert(jPlugin, JsonString("pi_party"));
        jPlugin = JsonArrayInsert(jPlugin, JsonInt(FALSE));
        jPlugin = JsonArrayInsert(jPlugin, JsonString("Party Manager"));
        jPlugin = JsonArrayInsert(jPlugin, JsonString("dm_creator"));
        json jPlugins = GetLocalJson(oPC, "AI_JSON_PLUGINS");
        jPlugins = JsonArrayInsert(jPlugins, jPlugin);
        SetLocalJson(oPC, "AI_JSON_PLUGINS", jPlugin);
        SetLocalInt(oPC, "AI_PLUGIN_SET", TRUE);
        return TRUE;
    }
    if(!GetLocalInt(oPC, "AI_STARTING_UP")) return FALSE;
    return TRUE;
}

