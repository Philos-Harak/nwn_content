/*//////////////////////////////////////////////////////////////////////////////
// Script Name: pi_henchman
////////////////////////////////////////////////////////////////////////////////
 Executable plug in script for Philos Module Extentions.

 UI to save a players as Henchman.
*///////////////////////////////////////////////////////////////////////////////
#include "pinc_henchman"
// Inserts base classes to an array for a combo box.
json JArrayInsertBaseClasses();
// Returns a two letter alignment string.
string GetAlignText(object oHenchman);
#include "0i_nui"
void main()
{
    object oPC = OBJECT_SELF;
    // Set window to not save until it has been created.
    SetLocalInt (oPC, "AI_NO_NUI_SAVE", TRUE);
    DelayCommand (0.5f, DeleteLocalInt (oPC, "AI_NO_NUI_SAVE"));
    // Row 1 (Buttons) ********************************************************* 468 / 73
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
    // Row 2 (Options)********************************************************** 468 / 101
    jRow = JsonArray();
    CreateButton(jRow, "Clear Party", "btn_clear_party", 120.0f, 20.0f, -1.0, "btn_clear_party_tooltip");
    JsonArrayInsertInplace(jRow, NuiSpacer());
    CreateButton(jRow, "Party Join", "btn_party_join", 120.0f, 20.0f, -1.0, "btn_party_join_tooltip");
    JsonArrayInsertInplace(jRow, NuiSpacer());
    CreateButtonSelect(jRow, "Options", "btn_options", 120.0f, 20.0f);
    JsonArrayInsertInplace(jRow, NuiSpacer());
    CreateButton(jRow, "Save Party", "btn_save_party", 120.0f, 20.0f, -1.0, "btn_save_party_tooltip");
    JsonArrayInsertInplace(jRow, NuiSpacer());
    CreateButton(jRow, "Remove Party", "btn_remove_party", 120.0f, 20.0f, -1.0, "btn_remove_party_tooltip");
    // Add the row to the column.
    JsonArrayInsertInplace(jCol, NuiRow(jRow));
    // Row 4 (List Characters) ************************************************* 468 / 465
    // Saved Characters for Party #
    // ***** Adding character sheet group next to the button list *****
    jRow = JsonArray();
    json jGroupRow = JsonArray();
    json jGroupCol = JsonArray();
    CreateLabel(jGroupRow, "", "lbl_saved_name", 150.0, 15.0, 0, 0, 0.0);
    JsonArrayInsertInplace(jGroupCol, NuiRow(jGroupRow));
    jGroupRow = JsonArray();
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
    jGroupRow = JsonArray();
    CreateButton(jGroupRow, "Edit", "btn_saved_edit", 150.0, 20.0);
    JsonArrayInsertInplace(jGroupCol, NuiRow(jGroupRow));
    JsonArrayInsertInplace(jRow, NuiGroup(NuiCol(jGroupCol)));
    // Create the button template for the List.
    json jButton = NuiId(NuiButton(NuiBind ("btns_saved_char")), "btn_saved_char");
    json jList = JsonArrayInsert(JsonArray (), NuiListTemplateCell(jButton, 190.0, TRUE));
    // Create the list with the template.
    CreateList(jRow, jList, "btns_saved_char", 25.0, 250.0, 325.0);
    // Current Characters.
    // Create the button template for the List.
    jButton = NuiId(NuiButton(NuiBind ("btns_cur_char")), "btn_cur_char");
    jList = JsonArrayInsert(JsonArray (), NuiListTemplateCell(jButton, 190.0, TRUE));
    // Create the list with the template.
    CreateList(jRow, jList, "btns_cur_char", 25.0, 250.0, 325.0);
    if(AI_DEBUG) ai_Debug("pi_henchman", "91", "json: " + JsonDump(jRow, 1));
    // ***** Adding character sheet group next to the button list *****
    jGroupRow = JsonArray();
    jGroupCol = JsonArray();
    CreateLabel(jGroupRow, "", "lbl_cur_name", 150.0, 15.0, 0, 0, 0.0);
    JsonArrayInsertInplace(jGroupCol, NuiRow(jGroupRow));
    jGroupRow = JsonArray();
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
    json jData = GetHenchmanDbJson(oPC, "data", "0");
    json jGeometry = JsonArrayGet(jData, 0);
    float fX = JsonGetFloat(JsonObjectGet(jGeometry, "x"));
    float fY = JsonGetFloat(JsonObjectGet(jGeometry, "y"));
    string sName = GetName(oPC);
    if(GetStringRight(sName, 1) == "s") sName = sName + "'";
    else sName = sName + "'s";
    int nToken = SetWindow (oPC, jLayout, "henchman_nui", sName + " party",
                            fX, fY, 875.0, 435.0, FALSE, FALSE, TRUE, FALSE, TRUE, "pe_henchman");
    // Lets set MaxHenchman here.
    SetMaxHenchmen(6);
    // Setup watch for saving location.
    NuiSetBindWatch (oPC, nToken, "window_geometry", TRUE);
    // Set the elements to show events.
    NuiSetBind (oPC, nToken, "btn_save_pc", JsonBool (TRUE));
    NuiSetBind (oPC, nToken, "btn_save_pc_event", JsonBool (TRUE));
    NuiSetBind (oPC, nToken, "btn_current_party_pc", JsonBool (TRUE));
    NuiSetBind (oPC, nToken, "btn_current_party_event", JsonBool (TRUE));
    string sParty = GetHenchmanDbString("name", "0");
    if(sParty == "")
    {
        CheckHenchmanDataAndInitialize("0");
        SetHenchmanDbString("name", "1", "0");
        sParty = "1";
    }
    if(sParty == "1")NuiSetBind(oPC, nToken, "btn_party1", JsonBool(TRUE));
    else NuiSetBind(oPC, nToken, "btn_party1", JsonBool(FALSE));
    NuiSetBind(oPC, nToken, "btn_party1_event", JsonBool (TRUE));
    if(sParty == "2") NuiSetBind(oPC, nToken, "btn_party2", JsonBool(TRUE));
    else NuiSetBind(oPC, nToken, "btn_party2", JsonBool(FALSE));
    NuiSetBind(oPC, nToken, "btn_party2_event", JsonBool(TRUE));
    if(sParty == "3") NuiSetBind(oPC, nToken, "btn_party3", JsonBool(TRUE));
    else NuiSetBind(oPC, nToken, "btn_party3", JsonBool(FALSE));
    NuiSetBind(oPC, nToken, "btn_party3_event", JsonBool(TRUE));
    if(sParty == "4") NuiSetBind(oPC, nToken, "btn_party4", JsonBool(TRUE));
    else NuiSetBind(oPC, nToken, "btn_party4", JsonBool(FALSE));
    NuiSetBind(oPC, nToken, "btn_party4_event", JsonBool(TRUE));
    NuiSetBind(oPC, nToken, "btn_clear", JsonBool (FALSE));
    NuiSetBind(oPC, nToken, "btn_clear_event", JsonBool(TRUE));
    // ********** Saved Henchman in party # *********
    int nIndex = 1;
    json jButtons = JsonArray();
    string sIndex, sFirstHenchman, sButtonText;
    json jNPCs, jNPC;
    // Add saved party members from sParty to the button list.
    while(nIndex < 7)
    {
        sIndex = IntToString(nIndex);
        sButtonText = GetHenchmanDbString("name", sParty + sIndex);
        if(sButtonText != "")
        {
            if(sFirstHenchman == "") sFirstHenchman = sIndex;
            JsonArrayInsertInplace(jButtons, JsonString(sButtonText));
        }
        nIndex++;
    }
        // Add the buttons to the list.
        NuiSetBind(oPC, nToken, "btns_saved_char", jButtons);
        // Set up button lables for henchman.
        // Add Henchman information.
        if(sFirstHenchman != "")
        {
            NuiSetBind(oPC, nToken, "btn_clear_party", JsonBool(TRUE));
            string sText = "  Clears Party " + sParty + "'s entire list!";
            NuiSetBind(oPC, nToken, "btn_clear_party_tooltip", JsonString(sText));
            NuiSetBind(oPC, nToken, "btn_party_join", JsonBool (TRUE));
            NuiSetBind(oPC, nToken, "btn_party_join_event", JsonBool (TRUE));
            sText = "  Saved party joins the current party!";
            NuiSetBind(oPC, nToken, "btn_party_join_tooltip", JsonString(sText));
            // Setup the henchman window.
            string sName = GetHenchmanDbString("name", sParty + sFirstHenchman);
            string sImage = GetHenchmanDbString("image", sParty + sFirstHenchman);
            string sStats = GetHenchmanDbString("stats", sParty + sFirstHenchman);
            string sClasses = GetHenchmanDbString("classes", sParty + sFirstHenchman);
            NuiSetBind(oPC, nToken, "lbl_saved_name_label", JsonString(sName));
            NuiSetBind(oPC, nToken, "img_saved_portrait_event", JsonBool(TRUE));
            NuiSetBind(oPC, nToken, "img_saved_portrait_image", JsonString(sImage + "l"));
            NuiSetBind(oPC, nToken, "lbl_saved_stats_label", JsonString(sStats));
            NuiSetBind(oPC, nToken, "lbl_saved_classes_label", JsonString(sClasses));
            NuiSetBind(oPC, nToken, "btn_saved_join_event", JsonBool(GetJoinButtonActive(oPC, sName)));
            NuiSetBind(oPC, nToken, "btn_saved_remove_event", JsonBool(TRUE));
            NuiSetBind(oPC, nToken, "btn_saved_edit_event", JsonBool(TRUE));
            NuiSetBind(oPC, nToken, "btn_saved_edit_event", JsonBool(TRUE));
            NuiSetUserData(oPC, nToken, JsonString(sFirstHenchman));
        }
        else
        {
            NuiSetBind(oPC, nToken, "btn_clear_party", JsonBool(FALSE));
            NuiSetBind (oPC, nToken, "btn_clear_party_event", JsonBool (FALSE));
            NuiSetBind (oPC, nToken, "btn_party_join", JsonBool (FALSE));
            NuiSetBind (oPC, nToken, "btn_party_join_event", JsonBool (FALSE));
            // Setup the henchman window.
            NuiSetBind(oPC, nToken, "lbl_name", JsonString(""));
            NuiSetBind(oPC, nToken, "img_portrait_image", JsonString("hu_m_01_l"));
            NuiSetBind(oPC, nToken, "lbl_stats", JsonString(""));
            NuiSetBind(oPC, nToken, "lbl_classes", JsonString(""));
            NuiSetBind(oPC, nToken, "btn_join_save_event", JsonBool(FALSE));
            NuiSetBind(oPC, nToken, "btn_remove_event", JsonBool(FALSE));
        }
        // ********** Current Party *********
        NuiSetBind(oPC, nToken, "btn_current_party", JsonBool(TRUE));
        NuiSetBind(oPC, nToken, "btn_clear_party", JsonBool(FALSE));
        // Set up button lables for henchman.
        NuiSetBind(oPC, nToken, "btn_join_save_label", JsonString("Save"));
        nIndex = 1;
        jButtons = JsonArray();
        object oPartyMember, oFirstMember = OBJECT_INVALID;
        // Add current party members to the button list.
        while(nIndex < 8)
        {
            if(nIndex == 7) oPartyMember = oPC;
            else oPartyMember = GetAssociate(ASSOCIATE_TYPE_HENCHMAN, oPC, nIndex);
            sButtonText = GetName(oPartyMember);
            if(sButtonText != "")
            {
                if(oFirstMember == OBJECT_INVALID) oFirstMember = oPartyMember;
                JsonArrayInsertInplace(jButtons, JsonString(sButtonText));
            }
            nIndex++;
        }
        // Add the buttons to the list.
        NuiSetBind(oPC, nToken, "btns_cur_char", jButtons);
        // Add information to character sheet.
        if(oFirstMember != OBJECT_INVALID)
        {
            int bParty = !GetIsPC(oFirstMember);
            NuiSetBind(oPC, nToken, "btn_save_party", JsonBool (bParty));
            NuiSetBind(oPC, nToken, "btn_save_party_event", JsonBool (bParty));
            NuiSetBind(oPC, nToken, "btn_remove_party", JsonBool (bParty));
            NuiSetBind(oPC, nToken, "btn_remove_party_event", JsonBool (bParty));
            if(bParty)
            {
                string sText = "  Removes all henchman from your current party!";
                NuiSetBind(oPC, nToken, "btn_remove_party_tooltip", JsonString(sText));
            }
            // Setup the henchman window.
            string sName = GetName(oPartyMember);
            string sImage = GetPortraitResRef(oPartyMember);
            string sStats = GetAlignText(oPartyMember) + " ";
            if(GetGender(oPartyMember) == GENDER_MALE) sStats += "Male ";
            else sStats += "Female ";
            int nPosition = 1;
            sStats += GetStringByStrRef (StringToInt (Get2DAString ("racialtypes", "Name", GetRacialType (oPartyMember))));
            string sClasses = GetStringByStrRef (StringToInt (Get2DAString ("classes", "Short", GetClassByPosition (nPosition, oPartyMember))));
            sClasses += IntToString (GetLevelByPosition (nPosition, oPartyMember));
            int nClass = GetClassByPosition(++nPosition, oPartyMember);
            while(nClass != CLASS_TYPE_INVALID)
            {
                sClasses += ", " + GetStringByStrRef (StringToInt (Get2DAString ("classes", "Short", GetClassByPosition (nPosition, oPartyMember))));
                nClass = GetClassByPosition(++nPosition, oPartyMember);
            }
            NuiSetBind(oPC, nToken, "lbl_cur_name_label", JsonString(sName));
            NuiSetBind(oPC, nToken, "img_cur_portrait_event", JsonBool(TRUE));
            NuiSetBind(oPC, nToken, "img_cur_portrait_image", JsonString(sImage + "l"));
            NuiSetBind(oPC, nToken, "lbl_cur_stats_label", JsonString(sStats));
            NuiSetBind(oPC, nToken, "lbl_cur_classes_label", JsonString(sClasses));
            NuiSetBind(oPC, nToken, "btn_cur_save_event", JsonBool(GetJoinButtonActive(oPC, sName)));
            NuiSetBind(oPC, nToken, "btn_cur_remove_event", JsonBool(TRUE));
            NuiSetUserData(oPC, nToken, JsonString(sFirstHenchman));
        }
}
string GetAlignText(object oHenchman)
{
    string sAlign1, sAlign2;
    switch (GetAlignmentLawChaos(oHenchman))
    {
        case ALIGNMENT_LAWFUL : sAlign1 = "L"; break;
        case ALIGNMENT_NEUTRAL : sAlign1 = "N"; break;
        case ALIGNMENT_CHAOTIC : sAlign1 = "C"; break;
    }
    switch (GetAlignmentGoodEvil(oHenchman))
    {
        case ALIGNMENT_GOOD : sAlign2 = "G"; break;
        case ALIGNMENT_NEUTRAL : sAlign2 = "N"; break;
        case ALIGNMENT_EVIL : sAlign2 = "E"; break;
    }
    string sAlign = sAlign1 + sAlign2;
    if (sAlign == "NN") sAlign = "TN";
    return sAlign;
}

