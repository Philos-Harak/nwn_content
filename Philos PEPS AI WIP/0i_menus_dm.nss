/*//////////////////////////////////////////////////////////////////////////////
// Script Name: 0i_menus_dm
////////////////////////////////////////////////////////////////////////////////
 Include script for handling NUI menus for DMs.
*///////////////////////////////////////////////////////////////////////////////
#include "0i_nui"
#include "0i_associates"
string ai_GetRandomDMTip()
{
    int nRoll = Random(44);
    return Get2DAString("ai_messages", "Text", nRoll);
}
void ai_SetDMWidgetButton(object oPlayer, int nButton, int bOn = TRUE)
{
    int nWidgetButtons = GetLocalInt(oPlayer, sDMWidgetButtonVarname);
    string sName = ai_RemoveIllegalCharacters(GetName(oPlayer));
    json jButtons = ai_GetCampaignDbJson("buttons", sName, AI_DM_TABLE);
    if(nWidgetButtons == 0) nWidgetButtons = JsonGetInt(JsonArrayGet(jButtons, 0));
    if(bOn) nWidgetButtons = nWidgetButtons | nButton;
    else nWidgetButtons = nWidgetButtons & ~nButton;
    SetLocalInt(oPlayer, sDMWidgetButtonVarname, nWidgetButtons);
    JsonArraySetInplace(jButtons, 0, JsonInt(nWidgetButtons));
    ai_SetCampaignDbJson("buttons", jButtons, sName, AI_DM_TABLE);
}
int ai_GetDMWidgetButton(object oPlayer, int nButton)
{
    int nWidgetButtons = GetLocalInt(oPlayer, sDMWidgetButtonVarname);
    if(nWidgetButtons == 0)
    {
        string sName = ai_RemoveIllegalCharacters(GetName(oPlayer));
        json jButtons = ai_GetCampaignDbJson("buttons", sName, AI_DM_TABLE);
        nWidgetButtons = JsonGetInt(JsonArrayGet(jButtons, 0));
    }
    return nWidgetButtons & nButton;
}
void ai_CreateDMWidgetNUI(object oPC)
{
    // Set window to not save until it has been created.
    SetLocalInt(oPC, AI_NO_NUI_SAVE, TRUE);
    DelayCommand(0.5f, DeleteLocalInt (oPC, AI_NO_NUI_SAVE));
    int bAIWidgetLock = ai_GetDMWidgetButton(oPC, BTN_DM_WIDGET_LOCK);
    int bCmdGroup1 = ai_GetDMWidgetButton(oPC, BTN_DM_CMD_GROUP1);
    int bCmdGroup2 = ai_GetDMWidgetButton(oPC, BTN_DM_CMD_GROUP2);
    int bCmdGroup3 = ai_GetDMWidgetButton(oPC, BTN_DM_CMD_GROUP3);
    int bCmdGroup4 = ai_GetDMWidgetButton(oPC, BTN_DM_CMD_GROUP4);
    int bCmdGroup5 = ai_GetDMWidgetButton(oPC, BTN_DM_CMD_GROUP5);
    int bCmdGroup6 = ai_GetDMWidgetButton(oPC, BTN_DM_CMD_GROUP6);
    int bCmdCamera = ai_GetDMWidgetButton(oPC, BTN_DM_CMD_CAMERA);
    int bCmdInventory = ai_GetDMWidgetButton(oPC, BTN_DM_CMD_INVENTORY);
    // Get which buttons are activated.
    float fHeight = 92.0f;
    if(bAIWidgetLock) fHeight = 59.0f;
    float fButtons, fWidth = 86.0f;
    // ************************************************************************* Width / Height
    // Row 1 (buttons)**********************************************************
    json jRow = JsonArray();
    // Setup the main associate button to use their portrait.
    json jButton = NuiEnabled(NuiId (NuiButtonImage(NuiBind("btn_open_main_image")), "btn_open_main"), NuiBind("btn_open_main_event"));
    jButton = NuiWidth(jButton, 35.0);
    jButton = NuiHeight(jButton, 35.0);
    jButton = NuiMargin(jButton, 0.0);
    jButton = NuiTooltip(jButton, NuiBind ("btn_open_main_tooltip"));
    jButton = NuiImageRegion(jButton, NuiRect(0.0, 0.0, 32.0, 35.0));
    JsonArrayInsertInplace(jRow, jButton);
    if(bCmdGroup1)
    {
        CreateButtonImage(jRow, "ir_level1", "btn_cmd_group1", 35.0f, 35.0f, 0.0, "btn_cmd_group1_tooltip");
        fButtons += 1.0;
    }
    if(bCmdGroup2)
    {
        CreateButtonImage(jRow, "ir_level2", "btn_cmd_group2", 35.0f, 35.0f, 0.0, "btn_cmd_group2_tooltip");
        fButtons += 1.0;
    }
    if(bCmdGroup3)
    {
        CreateButtonImage(jRow, "ir_level3", "btn_cmd_group3", 35.0f, 35.0f, 0.0, "btn_cmd_group3_tooltip");
        fButtons += 1.0;
    }
    if(bCmdGroup4)
    {
        CreateButtonImage(jRow, "ir_level4", "btn_cmd_group4", 35.0f, 35.0f, 0.0, "btn_cmd_group4_tooltip");
        fButtons += 1.0;
    }
    if(bCmdGroup5)
    {
        CreateButtonImage(jRow, "ir_level5", "btn_cmd_group5", 35.0f, 35.0f, 0.0, "btn_cmd_group5_tooltip");
        fButtons += 1.0;
    }
    if(bCmdGroup6)
    {
        CreateButtonImage(jRow, "ir_level6", "btn_cmd_group6", 35.0f, 35.0f, 0.0, "btn_cmd_group6_tooltip");
        fButtons += 1.0;
    }
    if(bCmdCamera)
    {
        CreateButtonImage(jRow, "ir_examine", "btn_camera", 35.0f, 35.0f, 0.0, "btn_camera_tooltip");
        fButtons += 1.0;
    }
    if(bCmdInventory)
    {
        CreateButtonImage(jRow, "ir_pickup", "btn_inventory", 35.0f, 35.0f, 0.0, "btn_inventory_tooltip");
        fButtons += 1.0;
    }
    // Plug in buttons *********************************************************
    int nIndex, bWidget;
    string sButton, sIcon;
    json jPlugins = ai_UpdatePluginsForDM(oPC);
    json jPlugin = JsonArrayGet(jPlugins, nIndex);
    while(JsonGetType(jPlugin) != JSON_TYPE_NULL)
    {
        bWidget = JsonGetInt(JsonArrayGet(jPlugin, 1));
        if(bWidget)
        {
            sIcon = JsonGetString(JsonArrayGet(jPlugin, 3));
            sButton = IntToString(nIndex);
            CreateButtonImage(jRow, sIcon, "btn_exe_plugin_" + sButton, 35.0f, 35.0f, 0.0, "btn_exe_plugin_" + sButton + "_tooltip");
            fButtons += 1.0;
        }
        jPlugin = JsonArrayGet(jPlugins, ++nIndex);
    }
    if(fButtons > 1.0f) fWidth = fWidth + ((fButtons - 1.0) * 39.0f);
    // Add the row to the column.
    json jCol = JsonArray();
    JsonArrayInsertInplace(jCol, NuiRow(jRow));
    // Get the window location to restore it from the database.
    string sName = ai_RemoveIllegalCharacters(GetName(oPC));
    json jLocations = ai_GetCampaignDbJson("locations", sName, AI_DM_TABLE);
    jLocations = JsonObjectGet(jLocations, "dm" + AI_WIDGET_NUI);
    float fX = JsonGetFloat(JsonObjectGet(jLocations, "x"));
    float fY = JsonGetFloat(JsonObjectGet(jLocations, "y"));
    if(bAIWidgetLock)
    {
        fX = fX + 4.0f;
        fY = fY + 37.0f;
    }
    // Set the layout of the window.
    json jLayout = NuiCol(jCol);
    int nToken;
    string sHeal, sText, sRange;
    string sDisplayName = GetName(oPC);
    if(GetStringRight(sDisplayName, 1) == "s") sDisplayName = sDisplayName + "'";
    else sDisplayName = sDisplayName + "'s";
    if(bAIWidgetLock) nToken = SetWindow(oPC, jLayout, "dm" + AI_WIDGET_NUI, sDisplayName + " Widget", fX, fY, fWidth + 8.0f, fHeight, FALSE, FALSE, FALSE, TRUE, FALSE, "0e_nui_dm");
    else nToken = SetWindow(oPC, jLayout, "dm" + AI_WIDGET_NUI, sDisplayName + " Widget", fX, fY, fWidth + 12.0f, fHeight, FALSE, FALSE, FALSE, TRUE, TRUE, "0e_nui_dm");
    // Set event watches for window inspector and save window location.
    NuiSetBindWatch(oPC, nToken, "window_geometry", TRUE);
    // Set the buttons to show events.
    NuiSetBind(oPC, nToken, "btn_open_main_image", JsonString(GetPortraitResRef(oPC) + "s"));
    NuiSetBind(oPC, nToken, "btn_open_main_event", JsonBool(TRUE));
    NuiSetBind(oPC, nToken, "btn_open_main_tooltip", JsonString("  " + sDisplayName + " widget menu"));
    string sUUID, sText2, sSpeed;
    string sAction = " (Left Action/Right Add)";
    if(bCmdGroup1)
    {
        NuiSetBind(oPC, nToken, "btn_cmd_group1_event", JsonBool(TRUE));
        json jGroup = GetLocalJson(oPC, "DM_GROUP1");
        if(JsonGetInt(JsonArrayGet(jGroup, 0)) == 0) sSpeed = " [Walk]";
        else sSpeed = " [Run]";
        string sUUID = JsonGetString(JsonArrayGet(jGroup, 1));
        if(sUUID == "") { sText = "Group 1"; sText2 = sAction; }
        else { sText = GetName(GetObjectByUUID(sUUID)) + "'s group"; sText2 = sSpeed; }
        NuiSetBind(oPC, nToken, "btn_cmd_group1_tooltip", JsonString("  " + sText + sText2));
    }
    if(bCmdGroup2)
    {
        NuiSetBind(oPC, nToken, "btn_cmd_group2_event", JsonBool(TRUE));
        json jGroup = GetLocalJson(oPC, "DM_GROUP2");
        if(JsonGetInt(JsonArrayGet(jGroup, 0)) == 0) sSpeed = " [Walk]";
        else sSpeed = " [Run]";
        string sUUID = JsonGetString(JsonArrayGet(jGroup, 1));
        if(sUUID == "") { sText = "Group 2"; sText2 = sAction; }
        else { sText = GetName(GetObjectByUUID(sUUID)) + "'s group"; sText2 = sSpeed; }
        NuiSetBind(oPC, nToken, "btn_cmd_group2_tooltip", JsonString("  " + sText + sText2));
    }
    if(bCmdGroup3)
    {
        NuiSetBind(oPC, nToken, "btn_cmd_group3_event", JsonBool(TRUE));
        json jGroup = GetLocalJson(oPC, "DM_GROUP3");
        if(JsonGetInt(JsonArrayGet(jGroup, 0)) == 0) sSpeed = " [Walk]";
        else sSpeed = " [Run]";
        string sUUID = JsonGetString(JsonArrayGet(jGroup, 1));
        if(sUUID == "") { sText = "Group 3"; sText2 = sAction; }
        else { sText = GetName(GetObjectByUUID(sUUID)) + "'s group"; sText2 = sSpeed; }
        NuiSetBind(oPC, nToken, "btn_cmd_group3_tooltip", JsonString("  " + sText + sText2));
    }
    if(bCmdGroup4)
    {
        NuiSetBind(oPC, nToken, "btn_cmd_group4_event", JsonBool(TRUE));
        json jGroup = GetLocalJson(oPC, "DM_GROUP4");
        if(JsonGetInt(JsonArrayGet(jGroup, 0)) == 0) sSpeed = " [Walk]";
        else sSpeed = " [Run]";
        string sUUID = JsonGetString(JsonArrayGet(jGroup, 1));
        if(sUUID == "") { sText = "Group 4"; sText2 = sAction; }
        else { sText = GetName(GetObjectByUUID(sUUID)) + "'s group"; sText2 = sSpeed; }
        NuiSetBind(oPC, nToken, "btn_cmd_group4_tooltip", JsonString("  " + sText + sText2));
    }
    if(bCmdGroup5)
    {
        NuiSetBind(oPC, nToken, "btn_cmd_group5_event", JsonBool(TRUE));
        json jGroup = GetLocalJson(oPC, "DM_GROUP5");
        if(JsonGetInt(JsonArrayGet(jGroup, 0)) == 0) sSpeed = " [Walk]";
        else sSpeed = " [Run]";
        string sUUID = JsonGetString(JsonArrayGet(jGroup, 1));
        if(sUUID == "") { sText = "Group 5"; sText2 = sAction; }
        else { sText = GetName(GetObjectByUUID(sUUID)) + "'s group"; sText2 = sSpeed; }
        NuiSetBind(oPC, nToken, "btn_cmd_group5_tooltip", JsonString("  " + sText + sText2));
    }
    if(bCmdGroup6)
    {
        NuiSetBind(oPC, nToken, "btn_cmd_group6_event", JsonBool(TRUE));
        json jGroup = GetLocalJson(oPC, "DM_GROUP6");
        if(JsonGetInt(JsonArrayGet(jGroup, 0)) == 0) sSpeed = " [Walk]";
        else sSpeed = " [Run]";
        string sUUID = JsonGetString(JsonArrayGet(jGroup, 1));
        if(sUUID == "") { sText = "Group 6"; sText2 = sAction; }
        else { sText = GetName(GetObjectByUUID(sUUID)) + "'s group"; sText2 = sSpeed; }
        NuiSetBind(oPC, nToken, "btn_cmd_group6_tooltip", JsonString("  " + sText + sText2));
    }
    if(bCmdCamera)
    {
        NuiSetBind(oPC, nToken, "btn_camera_event", JsonBool(TRUE));
        NuiSetBind(oPC, nToken, "btn_camera_tooltip", JsonString("  Select new object to have the camera view."));
    }
    if(bCmdInventory)
    {
        NuiSetBind(oPC, nToken, "btn_inventory_event", JsonBool(TRUE));
        NuiSetBind(oPC, nToken, "btn_inventory_tooltip", JsonString("  Open selected creatures inventory."));
    }
    /*if(bSearch)
    {
        NuiSetBind(oPC, nToken, "btn_search_event", JsonBool(TRUE));
        if(ai_GetAIMode(oAssociate, AI_MODE_AGGRESSIVE_SEARCH)) sText = "  Search On";
        else sText = "  Search Off";
        NuiSetBind(oPC, nToken, "btn_search_tooltip", JsonString(sText));
    }
    if(bStealth)
    {
        NuiSetBind(oPC, nToken, "btn_stealth_event", JsonBool(TRUE));
        if(ai_GetAIMode(oAssociate, AI_MODE_AGGRESSIVE_STEALTH)) sText = "  Stealth On";
        else sText = "  Stealth Off";
        NuiSetBind(oPC, nToken, "btn_stealth_tooltip", JsonString(sText));
    } */
    nIndex = 0;
    string sScript;
    jPlugin = JsonArrayGet(jPlugins, nIndex);
    while(JsonGetType(jPlugin) != JSON_TYPE_NULL)
    {
        bWidget = JsonGetInt(JsonArrayGet(jPlugin, 1));
        if(bWidget)
        {
            sButton = IntToString(nIndex);
            sScript = JsonGetString(JsonArrayGet(jPlugin, 0));
            if(ResManGetAliasFor(sScript, RESTYPE_NCS) == "")
            {
                sText = "  " + sScript + " not found by ResMan!";
            }
            else sName = "  " + JsonGetString(JsonArrayGet(jPlugin, 2));
            NuiSetBind(oPC, nToken, "btn_exe_plugin_" + sButton + "_event", JsonBool (TRUE));
            NuiSetBind(oPC, nToken, "btn_exe_plugin_" + sButton + "_tooltip", JsonString(sName));
        }
        jPlugin = JsonArrayGet(jPlugins, ++nIndex);
    }
}
void ai_CreateDMOptionsNUI(object oPC)
{
    // Set window to not save until it has been created.
    SetLocalInt (oPC, AI_NO_NUI_SAVE, TRUE);
    DelayCommand (2.0, DeleteLocalInt (oPC, AI_NO_NUI_SAVE));
    int nMonsterAI = (ResManGetAliasFor("ai_default", RESTYPE_NCS) != "");
    int nAssociateAI = (ResManGetAliasFor("ai_a_default", RESTYPE_NCS) != "");
    string sText = " [Single player]";
    if(AI_SERVER) sText = " [Server]";
    // ************************************************************************* Width / Height
    // Row 1 ******************************************************************* 500 / 73
    json jRow = JsonArray();
    JsonArrayInsertInplace(jRow, NuiSpacer());
    CreateLabel(jRow, PHILOS_VERSION  + sText, "lbl_version ", 510.0f, 20.0f, NUI_HALIGN_CENTER);
    JsonArrayInsertInplace(jRow, NuiSpacer());
    // Add row to the column.
    json jCol = JsonArray();
    JsonArrayInsertInplace(jCol, NuiRow(jRow));
    // Row 2 ******************************************************************* 500 / 101
    jRow = JsonArray();
    CreateLabel(jRow, "", "lbl_ai_info", 510.0f, 20.0f, NUI_HALIGN_CENTER);
    // Add row to the column.
    JsonArrayInsertInplace(jCol, NuiRow(jRow));
    // Row 3 ******************************************************************* 500 / 129
    jRow = JsonArray();
    CreateButton(jRow, "Plugin Manager", "btn_plugin_manager", 160.0f, 20.0f, -1.0, "btn_plugin_manager_tooltip");
    JsonArrayInsertInplace(jRow, NuiSpacer());
    CreateButton(jRow, "Widget Manager", "btn_widget_manager", 160.0f, 20.0f, -1.0, "btn_widget_manager_tooltip");
    // Add row to the column.
    JsonArrayInsertInplace(jCol, NuiRow(jRow));
    // Row 4 ******************************************************************* 500 / 157
    jRow = JsonArray();
    JsonArrayInsertInplace(jRow, NuiSpacer());
    CreateLabel(jRow, "SERVER RULES", "lbl_ai_rules", 80.0f, 20.0f, NUI_HALIGN_CENTER);
    JsonArrayInsertInplace(jRow, NuiSpacer());
    // Add row to the column.
    JsonArrayInsertInplace(jCol, NuiRow(jRow));
    float fHeight = 157.0;
    // Row 5 ******************************************************************* 500 / --- (28)
    jRow = JsonArray();
    // Make the AI options a Group.
    json jGroupRow = JsonArray();
    json jGroupCol = JsonArray();
    CreateTextEditBox(jGroupRow, "sPlaceHolder", "txt_max_henchman", 2, FALSE, 30.0f, 20.0f, "txt_max_henchman_tooltip");
    CreateLabel(jGroupRow, "Max number of henchmen that is allowed in your party.", "lbl_max_hench", 416.0f, 20.0f, NUI_HALIGN_LEFT, 0, -1.0, "txt_max_henchman_tooltip");
    JsonArrayInsertInplace(jGroupCol, NuiRow(jGroupRow));
    jGroupRow = JsonArray();
    CreateTextEditBox(jGroupRow, "sPlaceHolder", "txt_xp_scale", 3, FALSE, 40.0f, 20.0f, "txt_xp_scale_tooltip");
    CreateLabel(jGroupRow, "Modules experience scale.", "lbl_xp_scale", 175.0f, 20.0f, NUI_HALIGN_LEFT, 0, -1.0, "txt_xp_scale_tooltip");
    CreateCheckBox(jGroupRow, " scale to party.", "chbx_party_scale", 150.0, 20.0, "chbx_party_scale_tooltip");
    CreateButton(jGroupRow, "Default", "btn_default_xp", 70.0f, 20.0f, -1.0, "btn_default_xp_tooltip");
    JsonArrayInsertInplace(jGroupCol, NuiRow(jGroupRow));
    fHeight += 78.0;
    if(nMonsterAI || nAssociateAI)
    {
        jGroupRow = JsonArray();
        CreateCheckBox(jGroupRow, " Creatures will use advanced combat movement.", "chbx_advanced_movement", 450.0, 20.0);
        JsonArrayInsertInplace(jGroupCol, NuiRow(jGroupRow));
        jGroupRow = JsonArray();
        CreateCheckBox(jGroupRow, " Use item level restrictions for creatures [Default is off].", "chbx_ilr", 450.0, 20.0);
        JsonArrayInsertInplace(jGroupCol, NuiRow(jGroupRow));
        jGroupRow = JsonArray();
        CreateCheckBox(jGroupRow, " Creatures can use the skill Use Magic Device.", "chbx_umd", 450.0, 20.0);
        JsonArrayInsertInplace(jGroupCol, NuiRow(jGroupRow));
        jGroupRow = JsonArray();
        CreateCheckBox(jGroupRow, " Creatures can use Healing kits.", "chbx_use_healingkits", 450.0, 20.0);
        JsonArrayInsertInplace(jGroupCol, NuiRow(jGroupRow));
        jGroupRow = JsonArray();
        CreateCheckBox(jGroupRow, " Moral checks, wounded creatures may flee during combat.", "chbx_moral", 450.0, 20.0);
        jGroupRow = JsonArray();
        CreateLabel(jGroupRow, " Spells the AI will not use:", "lbl_restrict_spells", 190.0, 20.0, NUI_HALIGN_LEFT);
        CreateCheckBox(jGroupRow, " Darkness", "chbx_darkness", 90.0, 20.0, "chbx_darkness_tooltip");
        CreateCheckBox(jGroupRow, " Dispels", "chbx_dispels", 90.0, 20.0, "chbx_dispels_tooltip");
        CreateCheckBox(jGroupRow, " Time Stop", "chbx_timestop", 90.0, 20.0, "chbx_timestop_tooltip");
        JsonArrayInsertInplace(jGroupCol, NuiRow(jGroupRow));
        fHeight += 168.0;
    }
    if(nMonsterAI)
    {
        jGroupRow = JsonArray();
        CreateTextEditBox(jGroupRow, "sPlaceHolder", "txt_ai_difficulty", 3, FALSE, 40.0f, 20.0f, "txt_ai_difficulty_tooltip");
        CreateLabel(jGroupRow, "% chance monsters will attack the weakest target.", "lbl_ai_difficulty", 406.0f, 20.0f, NUI_HALIGN_LEFT, 0, -1.0, "txt_ai_difficulty_tooltip");
        JsonArrayInsertInplace(jGroupCol, NuiRow(jGroupRow));
        jGroupRow = JsonArray();
        CreateTextEditBox(jGroupRow, "sPlaceHolder", "txt_perception_distance", 2, FALSE, 35.0f, 20.0f, "txt_perception_distance_tooltip");
        CreateLabel(jGroupRow, "meters is the distance a monster can respond to allies.", "lbl_perception_distance", 411.0f, 20.0f, NUI_HALIGN_LEFT, 0, 0.0, "txt_perception_distance_tooltip");
        JsonArrayInsertInplace(jGroupCol, NuiRow(jGroupRow));
        jGroupRow = JsonArray();
        CreateCheckBox(jGroupRow, " Monsters can prebuff before combat starts.", "chbx_buff_monsters", 450.0, 20.0);
        JsonArrayInsertInplace(jGroupCol, NuiRow(jGroupRow));
        jGroupRow = JsonArray();
        CreateCheckBox(jGroupRow, " Monsters can use summons before combat starts.", "chbx_buff_summons", 450.0, 20.0);
        JsonArrayInsertInplace(jGroupCol, NuiRow(jGroupRow));
        jGroupRow = JsonArray();
        CreateCheckBox(jGroupRow, " Monsters can use tactics (ambush, defensive, flanker, etc).", "chbx_ambush_monsters", 450.0, 20.0);
        JsonArrayInsertInplace(jGroupCol, NuiRow(jGroupRow));
        jGroupRow = JsonArray();
        CreateLabel(jGroupRow, "Add ", "lbl_inc_enc", 30.0, 20.0, NUI_HALIGN_LEFT, 0, -1.0);
        CreateTextEditBox(jGroupRow, "sPlaceHolder", "txt_inc_enc", 4, FALSE, 55.0f, 20.0f, "txt_inc_enc_tooltip");
        CreateLabel(jGroupRow, "monsters per spawned encounter monster.", "lbl_inc_enc", 357.0, 20.0, NUI_HALIGN_LEFT, NUI_VALIGN_MIDDLE, 0.0, "txt_inc_enc_tooltip");
        JsonArrayInsertInplace(jGroupCol, NuiRow(jGroupRow));
        jGroupRow = JsonArray();
        CreateTextEditBox(jGroupRow, "sPlaceHolder", "txt_inc_hp", 3, FALSE, 40.0f, 20.0f, "txt_inc_hp_tooltip");
        CreateLabel(jGroupRow, "% increase in all monster's hitpoints.", "lbl_inc_hp", 406.0, 20.0, NUI_HALIGN_LEFT);
        JsonArrayInsertInplace(jGroupCol, NuiRow(jGroupRow));
        jGroupRow = JsonArray();
        CreateLabel(jGroupRow, "***** WARNING! The options below may break the module! *****", "lbl_warning", 450.0f, 20.0f, NUI_HALIGN_LEFT, 0, 0.0, "lbl_warning_tooltip");
        JsonArrayInsertInplace(jGroupCol, NuiRow(jGroupRow));
        jGroupRow = JsonArray();
        CreateCheckBox(jGroupRow, " Monsters can wander upto ", "chbx_wander", 220.0, 20.0, "chbx_wander_tooltip");
        CreateTextEditBox(jGroupRow, "sPlaceHolder", "txt_wander_distance", 2, FALSE, 35.0f, 20.0f, "chbx_wander_tooltip");
        CreateLabel(jGroupRow, "meters and ", "lbl_wander_distance", 80.0f, 20.0f, NUI_HALIGN_LEFT, NUI_VALIGN_MIDDLE, 0.0, "chbx_wander_tooltip");
        CreateCheckBox(jGroupRow, "open doors.", "chbx_open_doors", 100.0, 20.0, "chbx_wander_tooltip");
        JsonArrayInsertInplace(jGroupCol, NuiRow(jGroupRow));
        jGroupRow = JsonArray();
        CreateCheckBox(jGroupRow, " Monsters can summon companions.", "chbx_companions", 450.0, 20.0, "chbx_companions_tooltip");
        JsonArrayInsertInplace(jGroupCol, NuiRow(jGroupRow));
        jGroupRow = JsonArray();
        CreateCheckBox(jGroupRow, " Summoned associates to remain after masters death.", "chbx_perm_assoc", 450.0, 20.0);
        JsonArrayInsertInplace(jGroupCol, NuiRow(jGroupRow));
        jGroupRow = JsonArray();
        CreateCheckBox(jGroupRow, " Make enemy corpses remain.", "chbx_corpses_stay", 490.0, 20.0, "chbx_corpses_stay_tooltip");
        JsonArrayInsertInplace(jGroupCol, NuiRow(jGroupRow));
        jGroupRow = JsonArray();
        CreateLabel(jGroupRow, "", "lbl_perc_dist", 450.0f, 20.0f, NUI_HALIGN_LEFT, 0, 0.0, "lbl_perc_dist_tooltip");
        JsonArrayInsertInplace(jGroupCol, NuiRow(jGroupRow));
        fHeight += 336.0;
    }
    JsonArrayInsertInplace(jRow, NuiGroup(NuiCol(jGroupCol)));
    // Add row to the column.
    JsonArrayInsertInplace(jCol, NuiRow(jRow));
    // Get the window location to restore it from the database.
    string sName = ai_RemoveIllegalCharacters(GetName(oPC));
    json jLocations = ai_GetCampaignDbJson("locations", sName, AI_DM_TABLE);
    jLocations = JsonObjectGet(jLocations, "dm" + AI_MAIN_NUI);
    float fX = JsonGetFloat(JsonObjectGet(jLocations, "x"));
    float fY = JsonGetFloat(JsonObjectGet(jLocations, "y"));
    // Set the Layout of the window.
    json jLayout = NuiCol(jCol);
    sName = GetName(oPC);
    if(GetStringRight(sName, 1) == "s") sName = sName + "'";
    else sName = sName + "'s";
    int nToken = SetWindow(oPC, jLayout, "dm" + AI_MAIN_NUI, sName + " PEPS Main Menu",
                             fX, fY, 534.0f, fHeight, FALSE, FALSE, TRUE, FALSE, TRUE, "0e_nui_dm");
    // Save the associate to the nui for use in 0e_nui
    json jData = JsonArray();
    JsonArrayInsertInplace(jData, JsonString(ObjectToString(oPC)));
    NuiSetUserData(oPC, nToken, jData);
    object oModule = GetModule();
    // Set event watches for save window location.
    NuiSetBindWatch(oPC, nToken, "window_geometry", TRUE);
    // Set all binds, events, and watches.
    // Row 1 - Version label.
    // Row 2
    int nUsing;
    // Check the monster AI.
    string sLocation = ResManGetAliasFor("ai_default", RESTYPE_NCS);
    if(sLocation != "")
    {
        nUsing = TRUE;
        string sLocation = ResManGetAliasFor("nw_c2_default1", RESTYPE_NCS);
        if(sLocation != "OVERRIDE:" && sLocation != "PATCH:peps" && sLocation != "DEVELOPMENT:") nUsing = FALSE;
        if(nUsing) sText = "Monster AI working";
        else sText = "Monster AI not working";
    }
    else sText = "Monster AI not loaded";
    // Check the associate AI.
    sLocation = ResManGetAliasFor("ai_a_default", RESTYPE_NCS);
    if(sLocation != "")
    {
        nUsing = TRUE;
        string sLocation = ResManGetAliasFor("nw_ch_ac1", RESTYPE_NCS);
        if(sLocation != "OVERRIDE:" && sLocation != "PATCH:peps" && sLocation != "DEVELOPMENT:") nUsing = FALSE;
        if(nUsing) sText += ", Associate AI working";
        else sText += ", Associate AI not working";
    }
    else sText += ", Associate AI not loaded";
    // Check for PRC.
    sLocation = ResManGetAliasFor("prc_ai_fam_percp", RESTYPE_NCS);
    if(sLocation != "") sText += ", PRC loaded.";
    else
    {
        // Check the player AI.
        sLocation = ResManGetAliasFor("xx_pc_1_hb", RESTYPE_NCS);
        if(sLocation != "") sText += ", Player AI loaded.";
        else sText += ", Player AI not loaded.";
    }
    NuiSetBind(oPC, nToken, "lbl_ai_info_label", JsonString(sText));
    // Row 3
    NuiSetBind(oPC, nToken, "btn_plugin_manager_event", JsonBool(TRUE));
    NuiSetBind(oPC, nToken, "btn_plugin_manager_tooltip", JsonString("  Manages external executable scripts."));
    NuiSetBind(oPC, nToken, "btn_widget_manager_event", JsonBool(TRUE));
    NuiSetBind(oPC, nToken, "btn_widget_manager_tooltip", JsonString("  Manages widgets the players have access to."));
    // Row 3 Label for AI RULES
    // Row 4
    NuiSetBind(oPC, nToken, "txt_max_henchman_event", JsonBool(TRUE));
    NuiSetBind(oPC, nToken, "txt_max_henchman", JsonString(IntToString(GetLocalInt(oModule, AI_RULE_MAX_HENCHMAN))));
    NuiSetBindWatch (oPC, nToken, "txt_max_henchman", TRUE);
    NuiSetBind(oPC, nToken, "txt_max_henchman_tooltip", JsonString("  Set max number of henchman allowed (1-12)."));
    NuiSetBind(oPC, nToken, "txt_xp_scale_event", JsonBool(TRUE));
    NuiSetBind(oPC, nToken, "txt_xp_scale", JsonString(IntToString(GetModuleXPScale())));
    NuiSetBindWatch (oPC, nToken, "txt_xp_scale", TRUE);
    NuiSetBind(oPC, nToken, "txt_xp_scale_tooltip", JsonString("  Set the modules XP scale (0 - 200) Normal D&D is 10."));
    NuiSetBind(oPC, nToken, "chbx_party_scale_check", JsonBool(GetLocalInt(oModule, AI_RULE_PARTY_SCALE)));
    NuiSetBindWatch(oPC, nToken, "chbx_party_scale_check", TRUE);
    NuiSetBind(oPC, nToken, "chbx_party_scale_event", JsonBool(TRUE));
    sText = IntToString(GetLocalInt(oModule, AI_BASE_PARTY_SCALE_XP));
    NuiSetBind(oPC, nToken, "chbx_party_scale_tooltip", JsonString("  PEPS adjusts your XP based on party size from (" + sText + ")."));
    NuiSetBind(oPC, nToken, "btn_default_xp_event", JsonBool(TRUE));
    sText = IntToString(GetLocalInt(oModule, AI_RULE_DEFAULT_XP_SCALE));
    NuiSetBind(oPC, nToken, "btn_default_xp_tooltip", JsonString("  Reset the Modules XP to (" + sText + ")."));
    if(nMonsterAI)
    {
        NuiSetBind(oPC, nToken, "txt_ai_difficulty_event", JsonBool(TRUE));
        NuiSetBind(oPC, nToken, "txt_ai_difficulty", JsonString(IntToString(GetLocalInt(oModule, AI_RULE_AI_DIFFICULTY))));
        NuiSetBindWatch(oPC, nToken, "txt_ai_difficulty", TRUE);
        NuiSetBind(oPC, nToken, "chbx_buff_monsters_check", JsonBool(GetLocalInt(oModule, AI_RULE_BUFF_MONSTERS)));
        NuiSetBindWatch(oPC, nToken, "chbx_buff_monsters_check", TRUE);
        NuiSetBind(oPC, nToken, "chbx_buff_monsters_event", JsonBool(TRUE));
        NuiSetBind(oPC, nToken, "chbx_buff_summons_check", JsonBool(GetLocalInt(oModule, AI_RULE_PRESUMMON)));
        NuiSetBindWatch(oPC, nToken, "chbx_buff_summons_check", TRUE);
        NuiSetBind(oPC, nToken, "chbx_buff_summons_event", JsonBool(TRUE));
        NuiSetBind(oPC, nToken, "chbx_ambush_monsters_check", JsonBool(GetLocalInt(oModule, AI_RULE_AMBUSH)));
        NuiSetBindWatch(oPC, nToken, "chbx_ambush_monsters_check", TRUE);
        NuiSetBind(oPC, nToken, "chbx_ambush_monsters_event", JsonBool(TRUE));
        NuiSetBind(oPC, nToken, "chbx_companions_check", JsonBool(GetLocalInt(oModule, AI_RULE_SUMMON_COMPANIONS)));
        NuiSetBindWatch(oPC, nToken, "chbx_companions_check", TRUE);
        NuiSetBind(oPC, nToken, "chbx_companions_event", JsonBool(TRUE));
        NuiSetBind(oPC, nToken, "chbx_companions_tooltip", JsonString("  ** This will break some modules! ** See Readme for issues!"));
        NuiSetBind(oPC, nToken, "chbx_perm_assoc_check", JsonBool(GetLocalInt(oModule, AI_RULE_PERM_ASSOC)));
        NuiSetBindWatch(oPC, nToken, "chbx_perm_assoc_check", TRUE);
        NuiSetBind(oPC, nToken, "chbx_perm_assoc_event", JsonBool(TRUE));
        NuiSetBind(oPC, nToken, "chbx_corpses_stay_check", JsonBool(GetLocalInt(oModule, AI_RULE_CORPSES_STAY)));
        NuiSetBindWatch(oPC, nToken, "chbx_corpses_stay_check", TRUE);
        NuiSetBind(oPC, nToken, "chbx_corpses_stay_event", JsonBool(TRUE));
        NuiSetBind(oPC, nToken, "chbx_corpses_stay_tooltip", JsonString("  ** This will break some modules! ** See Readme for issues!"));
        NuiSetBind(oPC, nToken, "txt_perception_distance_event", JsonBool(TRUE));
        NuiSetBind(oPC, nToken, "txt_perception_distance", JsonString(FloatToString(GetLocalFloat(oModule, AI_RULE_PERCEPTION_DISTANCE), 0, 0)));
        NuiSetBindWatch(oPC, nToken, "txt_perception_distance", TRUE);
        NuiSetBind(oPC, nToken, "txt_perception_distance_tooltip", JsonString("  Range [10 to 60 meters] from the player."));
        NuiSetBindWatch(oPC, nToken, "lbl_perc_dist", TRUE);
        int nPercDist = GetLocalInt(oModule, AI_RULE_MON_PERC_DISTANCE);
        if(nPercDist < 8 || nPercDist > 11)
        {
            nPercDist = 11;
            SetLocalInt(oModule, AI_RULE_MON_PERC_DISTANCE, 11);
        }
        if(nPercDist == 8) sText = " Monster perception: Short [10 Sight / 10 Listen]";
        else if(nPercDist == 9) sText = " Monster perception: Medium [20 Sight / 20 Listen]";
        else if(nPercDist == 10) sText = " Monster perception: Long [35 Sight / 20 Listen]";
        else sText = " Monster perception: Default [Monster's default values]";
        NuiSetBind(oPC, nToken, "lbl_perc_dist_label", JsonString(sText));
        NuiSetBind(oPC, nToken, "lbl_perc_dist_tooltip", JsonString("  Use the mouse wheel to change values."));
        int bWander = GetLocalInt(oModule, AI_RULE_WANDER);
        NuiSetBind(oPC, nToken, "chbx_wander_check", JsonBool(bWander));
        NuiSetBindWatch(oPC, nToken, "chbx_wander_check", TRUE);
        NuiSetBind(oPC, nToken, "chbx_wander_event", JsonBool(TRUE));
        NuiSetBind(oPC, nToken, "txt_wander_distance_event", JsonBool(bWander));
        NuiSetBind(oPC, nToken, "txt_wander_distance", JsonString(FloatToString(GetLocalFloat(oModule, AI_RULE_WANDER_DISTANCE), 0, 0)));
        NuiSetBindWatch(oPC, nToken, "txt_wander_distance", TRUE);
        NuiSetBind(oPC, nToken, "chbx_wander_tooltip", JsonString("  ** This will break some modules! ** See Readme for issues!"));
        NuiSetBind(oPC, nToken, "chbx_open_doors_check", JsonBool(GetLocalInt(oModule, AI_RULE_OPEN_DOORS)));
        NuiSetBindWatch(oPC, nToken, "chbx_open_doors_check", TRUE);
        NuiSetBind(oPC, nToken, "chbx_open_doors_event", JsonBool(TRUE));
        NuiSetBind(oPC, nToken, "chbx_open_doors_tooltip", JsonString("  This allows monsters to open doors to hunt you down!"));
        NuiSetBind(oPC, nToken, "txt_inc_enc_event", JsonBool(TRUE));
        NuiSetBind(oPC, nToken, "txt_inc_enc_tooltip", JsonString("  Spawns one extra monster per counter above 1. Adds value to counter per encounter monster spawned."));
        NuiSetBind(oPC, nToken, "txt_inc_enc", JsonString(FloatToString(GetLocalFloat(oModule, AI_INCREASE_ENC_MONSTERS), 0, 2)));
        NuiSetBindWatch(oPC, nToken, "txt_inc_enc", TRUE);
        NuiSetBind(oPC, nToken, "txt_inc_hp_event", JsonBool(TRUE));
        NuiSetBind(oPC, nToken, "txt_inc_hp", JsonString(IntToString(GetLocalInt(oModule, AI_INCREASE_MONSTERS_HP))));
        NuiSetBindWatch(oPC, nToken, "txt_inc_hp", TRUE);
    }
    if(nMonsterAI || nAssociateAI)
    {
        NuiSetBind(oPC, nToken, "chbx_moral_check", JsonBool(GetLocalInt(oModule, AI_RULE_MORAL_CHECKS)));
        NuiSetBindWatch (oPC, nToken, "chbx_moral_check", TRUE);
        NuiSetBind(oPC, nToken, "chbx_moral_event", JsonBool(TRUE));
        NuiSetBind(oPC, nToken, "chbx_advanced_movement_check", JsonBool(GetLocalInt(oModule, AI_RULE_ADVANCED_MOVEMENT)));
        NuiSetBindWatch (oPC, nToken, "chbx_advanced_movement_check", TRUE);
        NuiSetBind(oPC, nToken, "chbx_advanced_movement_event", JsonBool(TRUE));
        NuiSetBind(oPC, nToken, "chbx_ilr_check", JsonBool(GetLocalInt(oModule, AI_RULE_ILR)));
        NuiSetBindWatch (oPC, nToken, "chbx_ilr_check", TRUE);
        NuiSetBind(oPC, nToken, "chbx_ilr_event", JsonBool(TRUE));
        NuiSetBind(oPC, nToken, "chbx_umd_check", JsonBool(GetLocalInt(oModule, AI_RULE_ALLOW_UMD)));
        NuiSetBindWatch (oPC, nToken, "chbx_umd_check", TRUE);
        NuiSetBind(oPC, nToken, "chbx_umd_event", JsonBool(TRUE));
        NuiSetBind(oPC, nToken, "chbx_use_healingkits_check", JsonBool(GetLocalInt(oModule, AI_RULE_HEALERSKITS)));
        NuiSetBindWatch (oPC, nToken, "chbx_use_healingkits_check", TRUE);
        NuiSetBind(oPC, nToken, "chbx_use_healingkits_event", JsonBool(TRUE));
        NuiSetBind(oPC, nToken, "chbx_darkness_check", JsonBool(ai_SpellRestricted(SPELL_DARKNESS)));
        NuiSetBindWatch (oPC, nToken, "chbx_darkness_check", TRUE);
        NuiSetBind(oPC, nToken, "chbx_darkness_event", JsonBool(TRUE));
        NuiSetBind(oPC, nToken, "chbx_darkness_tooltip", JsonString("  AI will not use the Darkness spell in combat."));
        NuiSetBind(oPC, nToken, "chbx_dispels_check", JsonBool(ai_SpellRestricted(SPELL_DISPEL_MAGIC)));
        NuiSetBindWatch (oPC, nToken, "chbx_dispels_check", TRUE);
        NuiSetBind(oPC, nToken, "chbx_dispels_event", JsonBool(TRUE));
        NuiSetBind(oPC, nToken, "chbx_dispels_tooltip", JsonString("  AI will not use any of the Dispel spells in combat."));
        NuiSetBind(oPC, nToken, "chbx_timestop_check", JsonBool(ai_SpellRestricted(SPELL_TIME_STOP)));
        NuiSetBindWatch (oPC, nToken, "chbx_timestop_check", TRUE);
        NuiSetBind(oPC, nToken, "chbx_timestop_event", JsonBool(TRUE));
        NuiSetBind(oPC, nToken, "chbx_timestop_tooltip", JsonString("  AI will not use the Time Stop spell in combat."));
    }
}
void ai_CreateDMCommandNUI(object oPC)
{
    SetLocalInt(oPC, AI_NO_NUI_SAVE, TRUE);
    DelayCommand(0.5f, DeleteLocalInt (oPC, AI_NO_NUI_SAVE));
    // ************************************************************************* Width / Height
    // Row 1 ******************************************************************* 500 / 73
    json jRow = JsonArray();
    CreateButtonSelect(jRow, "Lock Widget", "btn_widget_lock", 200.0, 20.0, "btn_widget_lock_tooltip");
    CreateLabel(jRow, "", "blank_label_1", 25.0, 20.0);
    JsonArrayInsertInplace(jRow, NuiSpacer());
    CreateButton(jRow, "Main Menu", "btn_main_menu", 200.0, 20.0, -1.0, "btn_main_menu_tooltip");
    CreateLabel(jRow, "", "blank_label_2", 25.0, 20.0);
    json jCol = JsonArray();
    JsonArrayInsertInplace(jCol, NuiRow(jRow));
    // Row 2 ******************************************************************* 500 / 101
    jRow = JsonArray();
    CreateButton(jRow, "", "btn_cmd_group1", 200.0, 20.0, -1.0, "btn_cmd_group1_tooltip");
    CreateCheckBox(jRow, "", "chbx_cmd_group1", 25.0, 20.0);
    JsonArrayInsertInplace(jRow, NuiSpacer());
    CreateButton(jRow, "", "btn_cmd_group2", 200.0, 20.0, -1.0, "btn_cmd_group2_tooltip");
    CreateCheckBox(jRow, "", "chbx_cmd_group2", 25.0, 20.0);
    JsonArrayInsertInplace(jCol, NuiRow(jRow));
    // Row 3 ******************************************************************* 500 / 129
    jRow = JsonArray();
    CreateButton(jRow, "", "btn_cmd_group3", 200.0, 20.0, -1.0, "btn_cmd_group3_tooltip");
    CreateCheckBox(jRow, "", "chbx_cmd_group3", 25.0, 20.0);
    JsonArrayInsertInplace(jRow, NuiSpacer());
    CreateButton(jRow, "", "btn_cmd_group4", 200.0, 20.0, -1.0, "btn_cmd_group4_tooltip");
    CreateCheckBox(jRow, "", "chbx_cmd_group4", 25.0, 20.0);
    JsonArrayInsertInplace(jCol, NuiRow(jRow));
    // Row 4 ******************************************************************* 500 / 157
    jRow = JsonArray();
    CreateButton(jRow, "", "btn_cmd_group5", 200.0, 20.0, -1.0, "btn_cmd_group5_tooltip");
    CreateCheckBox(jRow, "", "chbx_cmd_group5", 25.0, 20.0);
    JsonArrayInsertInplace(jRow, NuiSpacer());
    CreateButton(jRow, "", "btn_cmd_group6", 200.0, 20.0, -1.0, "btn_cmd_group6_tooltip");
    CreateCheckBox(jRow, "", "chbx_cmd_group6", 25.0, 20.0);
    JsonArrayInsertInplace(jCol, NuiRow(jRow));
    float fHeight = 157.0;
    // Row 5 ******************************************************************* 500 / ---
    jRow = JsonArray();
    CreateButton(jRow, "Toggle Camera Focus", "btn_camera", 200.0, 20.0, -1.0, "btn_camera_tooltip");
    CreateCheckBox(jRow, "", "chbx_camera", 25.0, 20.0);
    JsonArrayInsertInplace(jRow, NuiSpacer());
    CreateButton(jRow, "Open/Close Inventory", "btn_inventory", 200.0, 20.0, -1.0, "btn_inventory_tooltip");
    CreateCheckBox(jRow, "", "chbx_inventory", 25.0, 20.0);
    // Add row to the column.
    JsonArrayInsertInplace(jCol, NuiRow(jRow));
    fHeight = fHeight + 28.0;
    // Row 6+ ****************************************************************** 500 / ---
    json jDMPlugins = ai_UpdatePluginsForDM(oPC);
    // Set the plugins the dm can use.
    int nIndex;
    string sButton, sName;
    json jPlugin = JsonArrayGet(jDMPlugins, nIndex);
    while(JsonGetType(jPlugin) != JSON_TYPE_NULL)
    {
        jRow = JsonArray();
        sButton = IntToString(nIndex);
        sName = JsonGetString(JsonArrayGet(jPlugin, 2));
        CreateButton(jRow, sName, "btn_plugin_" + sButton, 200.0f, 20.0f, -1.0, "btn_plugin_" + sButton + "_tooltip");
        CreateCheckBox(jRow, "", "chbx_plugin_" + sButton, 25.0, 20.0, "chbx_plugin_tooltip");
        JsonArrayInsertInplace(jRow, NuiSpacer());
        jPlugin = JsonArrayGet(jDMPlugins, ++nIndex);
        if(JsonGetType(jPlugin) != JSON_TYPE_NULL)
        {
            sButton = IntToString(nIndex);
            sName = JsonGetString(JsonArrayGet(jPlugin, 2));
            CreateButton(jRow, sName, "btn_plugin_" + sButton, 200.0f, 20.0f, -1.0, "btn_plugin_" + sButton + "_tooltip");
            CreateCheckBox(jRow, "", "chbx_plugin_" + sButton, 25.0, 20.0, "chbx_plugin_tooltip");
            // Add row to the column.
            JsonArrayInsertInplace(jCol, NuiRow(jRow));
            fHeight += 28.0;
        }
        else
        {
            // Add row to the column.
            JsonArrayInsertInplace(jCol, NuiRow(jRow));
            fHeight += 28.0;
            break;
        }
        jPlugin = JsonArrayGet(jDMPlugins, ++nIndex);
    }
    // Row 7 ****************************************************************** 500 / ---
    jRow = JsonArray();
    JsonArrayInsertInplace(jRow, NuiSpacer());
    CreateLabel(jRow, "", "lbl_info_1", 475.0, 20.0, NUI_HALIGN_CENTER);
    JsonArrayInsertInplace(jRow, NuiSpacer());
    JsonArrayInsertInplace(jCol, NuiRow(jRow));
    fHeight = fHeight + 28.0;
    // Get the window location to restore it from the database.
    sName = ai_RemoveIllegalCharacters(GetName(oPC));
    json jLocations = ai_GetCampaignDbJson("locations", sName, AI_DM_TABLE);
    jLocations = JsonObjectGet(jLocations, "dm" + AI_COMMAND_NUI);
    float fX = JsonGetFloat(JsonObjectGet(jLocations, "x"));
    float fY = JsonGetFloat(JsonObjectGet(jLocations, "y"));
    // Set the Layout of the window.
    json jLayout = NuiCol(jCol);
    string sDMName = GetName(oPC);
    if(GetStringRight(sDMName, 1) == "s") sDMName = sDMName + "'";
    else sDMName = sDMName + "'s";
    int nToken = SetWindow(oPC, jLayout, "dm" + AI_COMMAND_NUI, sDMName + " Command Menu",
                           fX, fY, 500.0, fHeight + 12.0, FALSE, FALSE, TRUE, FALSE, TRUE, "0e_nui_dm");
    // Get which buttons are activated.
    int bAIWidgetLock = ai_GetDMWidgetButton(oPC, BTN_DM_WIDGET_LOCK);
    int bCmdGroup1 = ai_GetDMWidgetButton(oPC, BTN_DM_CMD_GROUP1);
    int bCmdGroup2 = ai_GetDMWidgetButton(oPC, BTN_DM_CMD_GROUP2);
    int bCmdGroup3 = ai_GetDMWidgetButton(oPC, BTN_DM_CMD_GROUP3);
    int bCmdGroup4 = ai_GetDMWidgetButton(oPC, BTN_DM_CMD_GROUP4);
    int bCmdGroup5 = ai_GetDMWidgetButton(oPC, BTN_DM_CMD_GROUP5);
    int bCmdGroup6 = ai_GetDMWidgetButton(oPC, BTN_DM_CMD_GROUP6);
    int bCmdCamera = ai_GetDMWidgetButton(oPC, BTN_DM_CMD_CAMERA);
    int bCmdInventory = ai_GetDMWidgetButton(oPC, BTN_DM_CMD_INVENTORY);
    // Set event watches for save window location.
    NuiSetBindWatch(oPC, nToken, "window_geometry", TRUE);
    // Set all binds, events, and watches.
    // Row 1
    NuiSetBind(oPC, nToken, "btn_widget_lock_event", JsonBool(TRUE));
    NuiSetBind(oPC, nToken, "btn_widget_lock", JsonBool(bAIWidgetLock));
    NuiSetBind(oPC, nToken, "btn_widget_lock_tooltip", JsonString(
               "  Locks widget to the current location."));
    NuiSetBind(oPC, nToken, "btn_main_menu_event", JsonBool (TRUE));
    NuiSetBind(oPC, nToken, "btn_main_menu", JsonInt(TRUE));
    NuiSetBind(oPC, nToken, "btn_main_menu_tooltip", JsonString("  Server menu options"));
    NuiSetBind(oPC, nToken, "btn_group_options_event", JsonBool (TRUE));
    NuiSetBind(oPC, nToken, "btn_group_options", JsonInt(TRUE));
    //NuiSetBind(oPC, nToken, "btn_empty_button_event", JsonBool (TRUE));
    //NuiSetBind(oPC, nToken, "btn_empty_button", JsonInt(TRUE));
    //sText = "  Copy AI and command settings for one creature to others.";
    //NuiSetBind(oPC, nToken, "btn_empty_button_tooltip", JsonString(sText));
    // Row 2
    NuiSetBind(oPC, nToken, "chbx_cmd_group1_event", JsonBool (TRUE));
    NuiSetBind(oPC, nToken, "chbx_cmd_group1_check", JsonBool (bCmdGroup1));
    NuiSetBindWatch (oPC, nToken, "chbx_cmd_group1_check", TRUE);
    NuiSetBind(oPC, nToken, "btn_cmd_group1_event", JsonBool (TRUE));
    string sText, sText2, sSpeed;
    string sAction = " (Left Action/Right Add)";
    json jGroup = GetLocalJson(oPC, "DM_GROUP1");
    if(JsonGetInt(JsonArrayGet(jGroup, 0)) == 0) sSpeed = " [Walk]";
    else sSpeed = " [Run]";
    string sUUID = JsonGetString(JsonArrayGet(jGroup, 1));
    if(sUUID == "") { sText = "Group 1"; sText2 = sText + sAction; }
    else { sText = GetName(GetObjectByUUID(sUUID)) + "'s group"; sText2 = sText + sSpeed; }
    NuiSetBind(oPC, nToken, "btn_cmd_group1_label", JsonString(sText));
    NuiSetBind(oPC, nToken, "btn_cmd_group1_tooltip", JsonString("  " + sText2));
    NuiSetBind(oPC, nToken, "chbx_cmd_group2_event", JsonBool (TRUE));
    NuiSetBind(oPC, nToken, "chbx_cmd_group2_check", JsonBool (bCmdGroup2));
    NuiSetBindWatch (oPC, nToken, "chbx_cmd_group2_check", TRUE);
    NuiSetBind(oPC, nToken, "btn_cmd_group2_event", JsonBool (TRUE));
    jGroup = GetLocalJson(oPC, "DM_GROUP2");
    if(JsonGetInt(JsonArrayGet(jGroup, 0)) == 0) sSpeed = " [Walk]";
    else sSpeed = " [Run]";
    sUUID = JsonGetString(JsonArrayGet(jGroup, 1));
    if(sUUID == "") { sText = "Group 2"; sText2 = sText + sAction; }
    else { sText = GetName(GetObjectByUUID(sUUID)) + "'s group"; sText2 = sText + sSpeed; }
    NuiSetBind(oPC, nToken, "btn_cmd_group2_label", JsonString(sText));
    NuiSetBind(oPC, nToken, "btn_cmd_group2_tooltip", JsonString("  " + sText2));
    // Row 3
    NuiSetBind(oPC, nToken, "chbx_cmd_group3_event", JsonBool (TRUE));
    NuiSetBind(oPC, nToken, "chbx_cmd_group3_check", JsonBool (bCmdGroup3));
    NuiSetBindWatch (oPC, nToken, "chbx_cmd_group3_check", TRUE);
    NuiSetBind(oPC, nToken, "btn_cmd_group3_event", JsonBool (TRUE));
    jGroup = GetLocalJson(oPC, "DM_GROUP3");
    if(JsonGetInt(JsonArrayGet(jGroup, 0)) == 0) sSpeed = " [Walk]";
    else sSpeed = " [Run]";
    sUUID = JsonGetString(JsonArrayGet(jGroup, 1));
    if(sUUID == "") { sText = "Group 3"; sText2 = sText + sAction; }
    else { sText = GetName(GetObjectByUUID(sUUID)) + "'s group"; sText2 = sText + sSpeed; }
    NuiSetBind(oPC, nToken, "btn_cmd_group3_label", JsonString(sText));
    NuiSetBind(oPC, nToken, "btn_cmd_group3_tooltip", JsonString("  " + sText2));
    NuiSetBind(oPC, nToken, "chbx_cmd_group4_event", JsonBool (TRUE));
    NuiSetBind(oPC, nToken, "chbx_cmd_group4_check", JsonBool (bCmdGroup4));
    NuiSetBindWatch (oPC, nToken, "chbx_cmd_group4_check", TRUE);
    NuiSetBind(oPC, nToken, "btn_cmd_group4_event", JsonBool (TRUE));
    jGroup = GetLocalJson(oPC, "DM_GROUP4");
    if(JsonGetInt(JsonArrayGet(jGroup, 0)) == 0) sSpeed = " [Walk]";
    else sSpeed = " [Run]";
    sUUID = JsonGetString(JsonArrayGet(jGroup, 1));
    if(sUUID == "") { sText = "Group 4"; sText2 = sText + sAction; }
    else { sText = GetName(GetObjectByUUID(sUUID)) + "'s group"; sText2 = sText + sSpeed; }
    NuiSetBind(oPC, nToken, "btn_cmd_group4_label", JsonString(sText));
    NuiSetBind(oPC, nToken, "btn_cmd_group4_tooltip", JsonString("  " + sText2));
    // Row 4
    NuiSetBind(oPC, nToken, "chbx_cmd_group5_event", JsonBool (TRUE));
    NuiSetBind(oPC, nToken, "chbx_cmd_group5_check", JsonBool (bCmdGroup5));
    NuiSetBindWatch (oPC, nToken, "chbx_cmd_group5_check", TRUE);
    NuiSetBind(oPC, nToken, "btn_cmd_group5_event", JsonBool (TRUE));
    jGroup = GetLocalJson(oPC, "DM_GROUP5");
    if(JsonGetInt(JsonArrayGet(jGroup, 0)) == 0) sSpeed = " [Walk]";
    else sSpeed = " [Run]";
    sUUID = JsonGetString(JsonArrayGet(jGroup, 1));
    if(sUUID == "") { sText = "Group 5"; sText2 = sText + sAction; }
    else { sText = GetName(GetObjectByUUID(sUUID)) + "'s group"; sText2 = sText + sSpeed; }
    NuiSetBind(oPC, nToken, "btn_cmd_group5_label", JsonString(sText));
    NuiSetBind(oPC, nToken, "btn_cmd_group5_tooltip", JsonString("  " + sText2));
    NuiSetBind(oPC, nToken, "chbx_cmd_group6_event", JsonBool (TRUE));
    NuiSetBind(oPC, nToken, "chbx_cmd_group6_check", JsonBool (bCmdGroup6));
    NuiSetBindWatch (oPC, nToken, "chbx_cmd_group6_check", TRUE);
    NuiSetBind(oPC, nToken, "btn_cmd_group6_event", JsonBool (TRUE));
    jGroup = GetLocalJson(oPC, "DM_GROUP6");
    if(JsonGetInt(JsonArrayGet(jGroup, 0)) == 0) sSpeed = " [Walk]";
    else sSpeed = " [Run]";
    sUUID = JsonGetString(JsonArrayGet(jGroup, 1));
    if(sUUID == "") { sText = "Group 6"; sText2 = sText + sAction; }
    else { sText = GetName(GetObjectByUUID(sUUID)) + "'s group"; sText2 = sText + sSpeed; }
    NuiSetBind(oPC, nToken, "btn_cmd_group6_label", JsonString(sText));
    NuiSetBind(oPC, nToken, "btn_cmd_group6_tooltip", JsonString("  " + sText2));
    // Row 5
    NuiSetBind(oPC, nToken, "chbx_camera_event", JsonBool (TRUE));
    NuiSetBind(oPC, nToken, "chbx_camera_check", JsonBool (bCmdCamera));
    NuiSetBindWatch (oPC, nToken, "chbx_camera_check", TRUE);
    NuiSetBind(oPC, nToken, "btn_camera_event", JsonBool (TRUE));
    NuiSetBind(oPC, nToken, "btn_camera_tooltip", JsonString (
               "  Toggle camera view for " + sDMName));
    NuiSetBind(oPC, nToken, "chbx_inventory_event", JsonBool (TRUE));
    NuiSetBind(oPC, nToken, "chbx_inventory_check", JsonBool (bCmdInventory));
    NuiSetBindWatch (oPC, nToken, "chbx_inventory_check", TRUE);
    NuiSetBind(oPC, nToken, "btn_inventory_event", JsonBool (TRUE));
    NuiSetBind(oPC, nToken, "btn_inventory_tooltip", JsonString (
               "  Open " + sDMName + " inventory"));
    // Row 6+
    nIndex = 0;
    int bWidget;
    jPlugin = JsonArrayGet(jDMPlugins, nIndex);
    while(JsonGetType(jPlugin) != JSON_TYPE_NULL)
    {
        sButton = IntToString(nIndex);
        NuiSetBind(oPC, nToken, "btn_plugin_" + sButton + "_event", JsonBool(TRUE));
        bWidget = JsonGetInt(JsonArrayGet(jPlugin, 1));
        NuiSetBind(oPC, nToken, "chbx_plugin_" + sButton + "_check", JsonBool(bWidget));
        NuiSetBindWatch (oPC, nToken, "chbx_plugin_" + sButton + "_check", TRUE);
        NuiSetBind(oPC, nToken, "chbx_plugin_" + sButton + "_event", JsonBool(TRUE));
        sText = "  " + JsonGetString(JsonArrayGet(jPlugin, 2));
        NuiSetBind(oPC, nToken, "btn_plugin_" + sButton + "_tooltip", JsonString(sText));
        jPlugin = JsonArrayGet(jDMPlugins, ++nIndex);
    }
    NuiSetBind(oPC, nToken, "chbx_plugin_tooltip", JsonString("  Adds the plugin to your widget."));
    // Row 7
    sText = ai_GetRandomDMTip();
    NuiSetBind(oPC, nToken, "lbl_info_1_label", JsonString(sText));
}
void ai_CreateDMPluginManagerNUI(object oPC)
{
    SetLocalInt(oPC, AI_NO_NUI_SAVE, TRUE);
    DelayCommand(0.5f, DeleteLocalInt (oPC, AI_NO_NUI_SAVE));
    json jRow = JsonArray();
    json jCol = JsonArray();
    // Row 1 ******************************************************************* 500 / 73
    JsonArrayInsertInplace(jRow, NuiSpacer());
    CreateButton(jRow, "Load All Plugins", "btn_load_plugins", 150.0f, 20.0f, -1.0, "btn_load_plugins_tooltip");
    JsonArrayInsertInplace(jRow, NuiSpacer());
    CreateButton(jRow, "Check All", "btn_check_plugins", 150.0f, 20.0f, -1.0, "btn_check_plugins_tooltip");
    JsonArrayInsertInplace(jRow, NuiSpacer());
    CreateButton(jRow, "Clear All", "btn_clear_plugins", 150.0f, 20.0f, -1.0, "btn_clear_plugins_tooltip");
    JsonArrayInsertInplace(jRow, NuiSpacer());
    // Add row to the column.
    JsonArrayInsertInplace(jCol, NuiRow(jRow));
    // Row 2 ******************************************************************* 500 / 101
    jRow = JsonArray();
    JsonArrayInsertInplace(jRow, NuiSpacer());
    CreateButton(jRow, "Add Plugin", "btn_add_plugin", 150.0f, 20.0f);
    JsonArrayInsertInplace(jRow, NuiSpacer());
    CreateTextEditBox(jRow, "sPlaceHolder", "txt_plugin", 16, FALSE, 310.0f, 20.0f, "txt_plugin_tooltip");
    JsonArrayInsertInplace(jRow, NuiSpacer());
    // Add row to the column.
    JsonArrayInsertInplace(jCol, NuiRow(jRow));
    float fHeight = 101.0;
    // Row 3+ ****************************************************************** 500 / ---
    json jPlugins = ai_GetCampaignDbJson("plugins");
    int nIndex = 0;
    json jPlugin = JsonArrayGet(jPlugins, nIndex);
    string sName, sButton;
    while(JsonGetType(jPlugin) != JSON_TYPE_NULL)
    {
        jRow = JsonArray();
        sButton = IntToString(nIndex);
        JsonArrayInsertInplace(jRow, NuiSpacer());
        CreateButton(jRow, "Remove Plugin", "btn_remove_plugin_" + sButton, 150.0f, 20.0f);
        JsonArrayInsertInplace(jRow, NuiSpacer());
        sName = JsonGetString(JsonArrayGet(jPlugin, 2));
        CreateButton(jRow, sName, "btn_plugin_" + sButton, 290.0f, 20.0f, -1.0, "btn_plugin_" + sButton + "_tooltip");
        CreateCheckBox(jRow, "", "chbx_plugin_" + sButton, 25.0, 20.0);
        JsonArrayInsertInplace(jRow, NuiSpacer());
        // Add row to the column.
        JsonArrayInsertInplace(jCol, NuiRow(jRow));
        fHeight += 28.0;
        jPlugin = JsonArrayGet(jPlugins, ++nIndex);
    }
    // Get the window location to restore it from the database.
    sName = ai_RemoveIllegalCharacters(GetName(oPC));
    json jLocations = ai_GetCampaignDbJson("locations", sName, AI_DM_TABLE);
    jLocations = JsonObjectGet(jLocations, "dm" + AI_PLUGIN_NUI);
    float fX = JsonGetFloat(JsonObjectGet(jLocations, "x"));
    float fY = JsonGetFloat(JsonObjectGet(jLocations, "y"));
    // Set the Layout of the window.
    json jLayout = NuiCol(jCol);
    sName = GetName(oPC);
    if(GetStringRight(sName, 1) == "s") sName = sName + "'";
    else sName = sName + "'s";
    int nToken = SetWindow(oPC, jLayout, "dm" + AI_PLUGIN_NUI, sName + " PEPS Plugin Manager",
                             fX, fY, 500.0f, fHeight + 12.0f, FALSE, FALSE, TRUE, FALSE, TRUE, "0e_nui_dm");
    // Set event watches for save window location.
    NuiSetBindWatch(oPC, nToken, "window_geometry", TRUE);
    // Row 1
    NuiSetBind(oPC, nToken, "btn_load_plugins_event", JsonBool(TRUE));
    NuiSetBind(oPC, nToken, "btn_load_plugins_tooltip", JsonString("  Load all known PEPS plugins that are in the game files."));
    NuiSetBind(oPC, nToken, "btn_check_plugins_event", JsonBool(TRUE));
    NuiSetBind(oPC, nToken, "btn_check_plugins_tooltip", JsonString("  Add all plugins to the players widget."));
    NuiSetBind(oPC, nToken, "btn_clear_plugins_event", JsonBool(TRUE));
    NuiSetBind(oPC, nToken, "btn_clear_plugins_tooltip", JsonString("  Remove all plugins from the players widget."));
    // Row 2
    NuiSetBind(oPC, nToken, "btn_add_plugin_event", JsonBool(TRUE));
    NuiSetBind(oPC, nToken, "txt_plugin_event", JsonBool(TRUE));
    NuiSetBind(oPC, nToken, "txt_plugin_tooltip", JsonString("  Enter an executable script name."));
    // Row 3+
    nIndex = 0;
    int bCheck;
    string sText;
    jPlugin = JsonArrayGet(jPlugins, nIndex);
    while(JsonGetType(jPlugin) != JSON_TYPE_NULL)
    {
        sButton = IntToString(nIndex);
        NuiSetBind(oPC, nToken, "btn_remove_plugin_" + sButton + "_event", JsonBool(TRUE));
        NuiSetBind(oPC, nToken, "btn_plugin_" + sButton + "_event", JsonBool(TRUE));
        bCheck = JsonGetInt(JsonArrayGet(jPlugin, 1));
        NuiSetBind(oPC, nToken, "chbx_plugin_" + sButton + "_check", JsonBool(bCheck));
        NuiSetBind(oPC, nToken, "chbx_plugin_" + sButton + "_event", JsonBool(TRUE));
        NuiSetBindWatch (oPC, nToken, "chbx_plugin_" + sButton + "_check", TRUE);
        sText = "  " + JsonGetString(JsonArrayGet(jPlugin, 2));
        NuiSetBind(oPC, nToken, "btn_plugin_" + sButton + "_tooltip", JsonString(sText));
        jPlugin = JsonArrayGet(jPlugins, ++nIndex);
    }
    NuiSetBind(oPC, nToken, "chbx_plugin_tooltip", JsonString("  Allows players to use this plugin."));
}
void ai_CreateDMWidgetManagerNUI(object oPC)
{
    SetLocalInt(oPC, AI_NO_NUI_SAVE, TRUE);
    DelayCommand(0.5f, DeleteLocalInt (oPC, AI_NO_NUI_SAVE));
    json jRow = JsonArray();
    json jCol = JsonArray();
    // Row 1 ******************************************************************* 575 / 73
    JsonArrayInsertInplace(jRow, NuiSpacer());
    CreateButton(jRow, "Check All", "btn_check_buttons", 150.0f, 20.0f, -1.0, "btn_check_buttons_tooltip");
    JsonArrayInsertInplace(jRow, NuiSpacer());
    CreateButton(jRow, "Clear All", "btn_clear_buttons", 150.0f, 20.0f, -1.0, "btn_clear_buttons_tooltip");
    JsonArrayInsertInplace(jRow, NuiSpacer());
    JsonArrayInsertInplace(jCol, NuiRow(jRow));
    // Row 2 ******************************************************************* 575 / 96
    jRow = JsonArray();
    CreateLabel(jRow, "This menu manages the PEPS buttons a player may have access to.", "lbl_info1", 636.0, 15.0);
    JsonArrayInsertInplace(jCol, NuiRow(jRow));
    // Row 3 ******************************************************************* 575 / 119
    jRow = JsonArray();
    CreateLabel(jRow, "Having a check next to a button will remove that button from the players menus.", "lbl_info2", 636.0, 15.0);
    JsonArrayInsertInplace(jCol, NuiRow(jRow));
    // Row 4 ******************************************************************* 575 / 162
    jRow = JsonArray();
    CreateButtonImage(jRow, "ir_action", "btn_cmd_action", 35.0f, 35.0f, 0.0, "btn_cmd_action_tooltip");
    CreateCheckBox(jRow, "", "chbx_cmd_action", 25.0, 20.0, "btn_cmd_action_tooltip");

    CreateButtonImage(jRow, "ir_guard", "btn_cmd_guard", 35.0f, 35.0f, 0.0, "btn_cmd_guard_tooltip");
    CreateCheckBox(jRow, "", "chbx_cmd_guard", 25.0, 20.0, "btn_cmd_guard_tooltip");

    CreateButtonImage(jRow, "ir_standground", "btn_cmd_hold", 35.0f, 35.0f, 0.0, "btn_cmd_hold_tooltip");
    CreateCheckBox(jRow, "", "chbx_cmd_hold", 25.0, 20.0, "btn_cmd_hold_tooltip");

    CreateButtonImage(jRow, "ir_attacknearest", "btn_cmd_attack", 35.0f, 35.0f, 0.0, "btn_cmd_attack_tooltip");
    CreateCheckBox(jRow, "", "chbx_cmd_attack", 25.0, 20.0, "btn_cmd_attack_tooltip");

    CreateButtonImage(jRow, "ir_follow", "btn_cmd_follow", 35.0f, 35.0f, 0.0, "btn_cmd_follow_tooltip");
    CreateCheckBox(jRow, "", "chbx_cmd_follow", 25.0, 20.0, "btn_cmd_follow_tooltip");

    CreateButtonImage(jRow, "ir_dmchat", "btn_follow_target", 35.0f, 35.0f, 0.0, "btn_follow_target_tooltip");
    CreateCheckBox(jRow, "", "chbx_follow_target", 25.0, 20.0, "btn_follow_target_tooltip");

    CreateButtonImage(jRow, "ife_foc_search", "btn_cmd_search", 35.0f, 35.0f, 0.0, "btn_cmd_search_tooltip");
    CreateCheckBox(jRow, "", "chbx_cmd_search", 25.0, 20.0, "btn_cmd_search_tooltip");

    CreateButtonImage(jRow, "ife_foc_hide", "btn_cmd_stealth", 35.0f, 35.0f, 0.0, "btn_cmd_stealth_tooltip");
    CreateCheckBox(jRow, "", "chbx_cmd_stealth", 25.0, 20.0, "btn_cmd_stealth_tooltip");

    CreateButtonImage(jRow, "ir_scommand", "btn_cmd_ai_script", 35.0f, 35.0f, 0.0, "btn_cmd_ai_script_tooltip");
    CreateCheckBox(jRow, "", "chbx_cmd_ai_script", 25.0, 20.0, "btn_cmd_ai_script_tooltip");

    CreateButtonImage(jRow, "isk_settrap", "btn_cmd_place_trap", 35.0f, 35.0f, 0.0, "btn_cmd_place_trap_tooltip");
    CreateCheckBox(jRow, "", "chbx_cmd_place_trap", 25.0, 20.0, "btn_cmd_place_trap_tooltip");
    JsonArrayInsertInplace(jCol, NuiRow(jRow));
    // Row 5 ******************************************************************* 575 / 205
    jRow = JsonArray();
    CreateButtonImage(jRow, "isk_spellcraft", "btn_quick_widget", 35.0f, 35.0f, 0.0, "btn_quick_widget_tooltip");
    CreateCheckBox(jRow, "", "chbx_quick_widget", 25.0, 20.0, "btn_quick_widget_tooltip");

    CreateButtonImage(jRow, "isk_lore", "btn_spell_memorize", 35.0f, 35.0f, 0.0, "btn_spell_memorize_tooltip");
    CreateCheckBox(jRow, "", "chbx_spell_memorize", 25.0, 20.0, "btn_spell_memorize_tooltip");

    CreateButtonImage(jRow, "ir_cantrips", "btn_buff_short", 35.0f, 35.0f, 0.0, "btn_buff_short_tooltip");
    CreateCheckBox(jRow, "", "chbx_buff_short", 25.0, 20.0, "btn_buff_short_tooltip");

    CreateButtonImage(jRow, "ir_cast", "btn_buff_long", 35.0f, 35.0f, 0.0, "btn_buff_long_tooltip");
    CreateCheckBox(jRow, "", "chbx_buff_long", 25.0, 20.0, "btn_buff_long_tooltip");

    CreateButtonImage(jRow, "ir_level789", "btn_buff_all", 35.0f, 35.0f, 0.0, "btn_buff_all_tooltip");
    CreateCheckBox(jRow, "", "chbx_buff_all", 25.0, 20.0, "btn_buff_all_tooltip");

    CreateButtonImage(jRow, "ir_rest", "btn_buff_rest", 35.0f, 35.0f, 0.0, "btn_buff_rest_tooltip");
    CreateCheckBox(jRow, "", "chbx_buff_rest", 25.0, 20.0, "btn_buff_rest_tooltip");

    CreateButtonImage(jRow, "dm_jump", "btn_jump_to", 35.0f, 35.0f, 0.0, "btn_jump_to_tooltip");
    CreateCheckBox(jRow, "", "chbx_jump_to", 25.0, 20.0, "btn_jump_to_tooltip");

    CreateButtonImage(jRow, "dm_limbo", "btn_ghost_mode", 35.0f, 35.0f, 0.0, "btn_ghost_mode_tooltip");
    CreateCheckBox(jRow, "", "chbx_ghost_mode", 25.0, 20.0, "btn_ghost_mode_tooltip");

    CreateButtonImage(jRow, "ir_examine", "btn_camera", 35.0f, 35.0f, 0.0, "btn_camera_tooltip");
    CreateCheckBox(jRow, "", "chbx_camera", 25.0, 20.0, "btn_camera_tooltip");

    CreateButtonImage(jRow, "ir_pickup", "btn_inventory", 35.0f, 35.0f, 0.0, "btn_inventory_tooltip");
    CreateCheckBox(jRow, "", "chbx_inventory", 25.0, 20.0, "btn_inventory_tooltip");
    JsonArrayInsertInplace(jCol, NuiRow(jRow));
    // Row 6 ******************************************************************* 575 / 248
    jRow = JsonArray();

    CreateButtonImage(jRow, "ife_familiar", "btn_familiar", 35.0f, 35.0f, 0.0, "btn_familiar_tooltip");
    CreateCheckBox(jRow, "", "chbx_familiar", 25.0, 20.0, "btn_familiar_tooltip");

    CreateButtonImage(jRow, "ife_animal", "btn_companion", 35.0f, 35.0f, 0.0, "btn_companion_tooltip");
    CreateCheckBox(jRow, "", "chbx_companion", 25.0, 20.0, "btn_companion_tooltip");

    CreateButtonImage(jRow, "dm_ai", "btn_ai", 35.0f, 35.0f, 0.0, "btn_ai_tooltip");
    CreateCheckBox(jRow, "", "chbx_ai", 25.0, 20.0, "btn_companion_tooltip");

    CreateButtonImage(jRow, "isk_movsilent", "btn_quiet", 35.0f, 35.0f, 0.0, "btn_quiet_tooltip");
    CreateCheckBox(jRow, "", "chbx_quiet", 25.0, 20.0, "btn_quiet_tooltip");

    CreateButtonImage(jRow, "ir_archer", "btn_ranged", 35.0f, 35.0f, 0.0, "btn_ranged_tooltip");
    CreateCheckBox(jRow, "", "chbx_ranged", 25.0, 20.0, "btn_ranged_tooltip");

    CreateButtonImage(jRow, "ir_ignore", "btn_ignore_assoc", 35.0f, 35.0f, 0.0, "btn_ignore_assoc_tooltip");
    CreateCheckBox(jRow, "", "chbx_ignore_assoc", 25.0, 20.0, "btn_ignore_assoc_tooltip");

    CreateButtonImage(jRow, "isk_search", "btn_search", 35.0f, 35.0f, 0.0, "btn_search_tooltip");
    CreateCheckBox(jRow, "", "chbx_search", 25.0, 20.0, "btn_search_tooltip");

    CreateButtonImage(jRow, "isk_hide", "btn_stealth", 35.0f, 35.0f, 0.0, "btn_stealth_tooltip");
    CreateCheckBox(jRow, "", "chbx_stealth", 25.0, 20.0, "btn_stealth_tooltip");

    CreateButtonImage(jRow, "ir_open", "btn_open_door", 35.0f, 35.0f, 0.0, "btn_open_door_tooltip");
    CreateCheckBox(jRow, "", "chbx_open_door", 25.0, 20.0, "btn_open_door_tooltip");

    CreateButtonImage(jRow, "isk_distrap", "btn_traps", 35.0f, 35.0f, 0.0, "btn_traps_tooltip");
    CreateCheckBox(jRow, "", "chbx_traps", 25.0, 20.0, "btn_traps_tooltip");
    JsonArrayInsertInplace(jCol, NuiRow(jRow));
    // Row 7 ******************************************************************* 575 / 291
    jRow = JsonArray();

    CreateButtonImage(jRow, "isk_olock", "btn_pick_locks", 35.0f, 35.0f, 0.0, "btn_pick_locks_tooltip");
    CreateCheckBox(jRow, "", "chbx_pick_locks", 25.0, 20.0, "btn_pick_locks_tooltip");

    CreateButtonImage(jRow, "ir_bash", "btn_bash_locks", 35.0f, 35.0f, 0.0, "btn_bash_locks_tooltip");
    CreateCheckBox(jRow, "", "chbx_bash_locks", 25.0, 20.0, "btn_bash_locks_tooltip");

    CreateButtonImage(jRow, "dm_control", "btn_magic_level", 35.0f, 35.0f, 0.0, "btn_magic_level_tooltip");
    CreateCheckBox(jRow, "", "chbx_magic_level", 25.0, 20.0, "btn_magic_level_tooltip");

    CreateButtonImage(jRow, "ir_xability", "btn_spontaneous", 35.0f, 35.0f, 0.0, "btn_spontaneous_tooltip");
    CreateCheckBox(jRow, "", "chbx_spontaneous", 25.0, 20.0, "btn_spontaneous_tooltip");

    CreateButtonImage(jRow, "ir_cntrspell", "btn_magic", 35.0f, 35.0f, 0.0, "btn_magic_tooltip");
    CreateCheckBox(jRow, "", "chbx_magic", 25.0, 20.0, "btn_magic_tooltip");

    CreateButtonImage(jRow, "ir_moreattacks", "btn_magic_items", 35.0f, 35.0f, 0.0, "btn_magic_items_tooltip");
    CreateCheckBox(jRow, "", "chbx_magic_items", 25.0, 20.0, "btn_magic_items_tooltip");

    CreateButtonImage(jRow, "ir_orisons", "btn_def_magic", 35.0f, 35.0f, 0.0, "btn_def_magic_tooltip");
    CreateCheckBox(jRow, "", "chbx_def_magic", 25.0, 20.0, "btn_def_magic_tooltip");

    CreateButtonImage(jRow, "ir_metamagic", "btn_off_magic", 35.0f, 35.0f, 0.0, "btn_off_magic_tooltip");
    CreateCheckBox(jRow, "", "chbx_off_magic", 25.0, 20.0, "btn_off_magic_tooltip");

    CreateButtonImage(jRow, "isk_heal", "btn_heal_out", 35.0f, 35.0f, 0.0, "btn_heal_out_tooltip");
    CreateCheckBox(jRow, "", "chbx_heal_out", 25.0, 20.0, "btn_heal_out_tooltip");

    CreateButtonImage(jRow, "dm_heal", "btn_heal_in", 35.0f, 35.0f, 0.0, "btn_heal_in_tooltip");
    CreateCheckBox(jRow, "", "chbx_heal_in", 25.0, 20.0, "btn_heal_in_tooltip");
    JsonArrayInsertInplace(jCol, NuiRow(jRow));
    // Row 8 ******************************************************************* 575 / 334
    jRow = JsonArray();
    CreateButtonImage(jRow, "ir_heal", "btn_heals_onoff", 35.0f, 35.0f, 0.0, "btn_heals_onoff_tooltip");
    CreateCheckBox(jRow, "", "chbx_heals_onoff", 25.0, 20.0, "btn_heals_onoff_tooltip");

    CreateButtonImage(jRow, "ir_party", "btn_healp_onoff", 35.0f, 35.0f, 0.0, "btn_healp_onoff_tooltip");
    CreateCheckBox(jRow, "", "chbx_healp_onoff", 25.0, 20.0, "btn_healp_onoff_tooltip");

    CreateButtonImage(jRow, "ir_barter", "btn_loot", 35.0f, 35.0f, 0.0, "btn_loot_tooltip");
    CreateCheckBox(jRow, "", "chbx_loot", 25.0, 20.0, "btn_loot_tooltip");

    CreateButtonImage(jRow, "ir_dmchat", "btn_perc_range", 35.0f, 35.0f, 0.0, "btn_perc_range_tooltip");
    CreateCheckBox(jRow, "", "chbx_perc_range", 25.0, 20.0, "btn_perc_range_tooltip");

    // Add row to the column.
    JsonArrayInsertInplace(jCol, NuiRow(jRow));
    float fHeight = 334.0;
    // Get the window location to restore it from the database.
    string sName = ai_RemoveIllegalCharacters(GetName(oPC));
    json jLocations = ai_GetCampaignDbJson("locations", sName, AI_DM_TABLE);
    jLocations = JsonObjectGet(jLocations, "dm_widget_manager_nui");
    float fX = JsonGetFloat(JsonObjectGet(jLocations, "x"));
    float fY = JsonGetFloat(JsonObjectGet(jLocations, "y"));
    // Set the Layout of the window.
    json jLayout = NuiCol(jCol);
    sName = GetName(oPC);
    if(GetStringRight(sName, 1) == "s") sName = sName + "'";
    else sName = sName + "'s";
    int nToken = SetWindow(oPC, jLayout, "dm_widget_manager_nui", sName + " PEPS DM Widget Manager",
                             fX, fY, 660.0f, fHeight + 12.0f, FALSE, FALSE, TRUE, FALSE, TRUE, "0e_nui_dm");
    // Set event watches for save window location.
    NuiSetBindWatch(oPC, nToken, "window_geometry", TRUE);
    // Row 1
    NuiSetBind(oPC, nToken, "btn_check_buttons_event", JsonBool(TRUE));
    NuiSetBind(oPC, nToken, "btn_check_buttons_tooltip", JsonString("  Check all buttons, removing them for all players."));
    NuiSetBind(oPC, nToken, "btn_clear_buttons_event", JsonBool(TRUE));
    NuiSetBind(oPC, nToken, "btn_clear_buttons_tooltip", JsonString("  Clear all buttons, allowing use for all players."));
    // Row 2 & 3 Labels.
    // Load all the buttons states.
    //int bAIWidgetLock = ai_GetDMWAccessButton(BTN_WIDGET_LOCK);
    int bCmdAction = ai_GetDMWAccessButton(BTN_CMD_ACTION);
    int bCmdGuard = ai_GetDMWAccessButton(BTN_CMD_GUARD);
    int bCmdHold = ai_GetDMWAccessButton(BTN_CMD_HOLD);
    int bCmdSearch = ai_GetDMWAccessButton(BTN_CMD_SEARCH);
    int bCmdStealth = ai_GetDMWAccessButton(BTN_CMD_STEALTH);
    int bCmdAttack = ai_GetDMWAccessButton(BTN_CMD_ATTACK);
    int bCmdFollow = ai_GetDMWAccessButton(BTN_CMD_FOLLOW);
    int bCmdAIScript = ai_GetDMWAccessButton(BTN_CMD_AI_SCRIPT);
    int bCmdPlacetrap = ai_GetDMWAccessButton(BTN_CMD_PLACE_TRAP);
    int bSpellWidget = ai_GetDMWAccessButton(BTN_CMD_SPELL_WIDGET);
    int bMemorizeSpells = ai_GetDMWAccessButton(BTN_DM_CMD_MEMORIZE);
    int bBuffShort = ai_GetDMWAccessButton(BTN_BUFF_SHORT);
    int bBuffLong = ai_GetDMWAccessButton(BTN_BUFF_LONG);
    int bBuffAll = ai_GetDMWAccessButton(BTN_BUFF_ALL);
    int bBuffRest = ai_GetDMWAccessButton(BTN_BUFF_REST);
    int bJumpTo = ai_GetDMWAccessButton(BTN_CMD_JUMP_TO);
    int bGhostMode = ai_GetDMWAccessButton(BTN_CMD_GHOST_MODE);
    int bCamera = ai_GetDMWAccessButton(BTN_CMD_CAMERA);
    int bInventory = ai_GetDMWAccessButton(BTN_CMD_INVENTORY);
    int bFamiliar = ai_GetDMWAccessButton(BTN_CMD_FAMILIAR);
    int bCompanion = ai_GetDMWAccessButton(BTN_CMD_COMPANION);
    int bFollowTarget = ai_GetDMAIAccessButton(BTN_AI_FOLLOW_TARGET);
    int bAI = ai_GetDMAIAccessButton(BTN_AI_FOR_PC);
    int bReduceSpeech = ai_GetDMAIAccessButton(BTN_AI_REDUCE_SPEECH);
    int bRanged = ai_GetDMAIAccessButton(BTN_AI_USE_RANGED);
    int bIgnoreAssociates = ai_GetDMAIAccessButton(BTN_AI_IGNORE_ASSOCIATES);
    int bSearch = ai_GetDMAIAccessButton(BTN_AI_USE_SEARCH);
    int bStealth = ai_GetDMAIAccessButton(BTN_AI_USE_STEALTH);
    int bOpenDoors = ai_GetDMAIAccessButton(BTN_AI_OPEN_DOORS);
    int bTraps = ai_GetDMAIAccessButton(BTN_AI_REMOVE_TRAPS);
    int bPickLocks = ai_GetDMAIAccessButton(BTN_AI_PICK_LOCKS);
    int bBashLocks = ai_GetDMAIAccessButton(BTN_AI_BASH_LOCKS);
    int bMagicLevel = ai_GetDMAIAccessButton(BTN_AI_MAGIC_LEVEL);
    int bSpontaneous = ai_GetDMAIAccessButton(BTN_AI_NO_SPONTANEOUS);
    int bNoMagic = ai_GetDMAIAccessButton(BTN_AI_NO_MAGIC_USE);
    int bNoMagicItems = ai_GetDMAIAccessButton(BTN_AI_NO_MAGIC_ITEM_USE);
    int bDefMagic = ai_GetDMAIAccessButton(BTN_AI_DEF_MAGIC_USE);
    int bOffMagic = ai_GetDMAIAccessButton(BTN_AI_OFF_MAGIC_USE);
    int bHealOut = ai_GetDMAIAccessButton(BTN_AI_HEAL_OUT);
    int bHealIn = ai_GetDMAIAccessButton(BTN_AI_HEAL_IN);
    int bSelfHealOnOff = ai_GetDMAIAccessButton(BTN_AI_STOP_SELF_HEALING);
    int bPartyHealOnOff = ai_GetDMAIAccessButton(BTN_AI_STOP_PARTY_HEALING);
    int bLoot = ai_GetDMAIAccessButton(BTN_AI_LOOT);
    int bPercRange = ai_GetDMAIAccessButton(BTN_AI_PERC_RANGE);
    int bBtnFamiliar = ai_GetDMWAccessButton(BTN_CMD_FAMILIAR);
    int bBtnCompanion = ai_GetDMWAccessButton(BTN_CMD_COMPANION);
    SetLocalInt(oPC, "CHBX_SKIP", TRUE);
    DelayCommand(2.0, DeleteLocalInt(oPC, "CHBX_SKIP"));
    // Row 4
    NuiSetBind(oPC, nToken, "chbx_cmd_action_check", JsonBool (bCmdAction));
    NuiSetBindWatch(oPC, nToken, "chbx_cmd_action_check", TRUE);
    NuiSetBind(oPC, nToken, "chbx_cmd_action_event", JsonBool(TRUE));
    NuiSetBind(oPC, nToken, "btn_cmd_action_event", JsonBool (TRUE));
    NuiSetBind(oPC, nToken, "btn_cmd_action_tooltip", JsonString("  Action button"));

    NuiSetBind(oPC, nToken, "chbx_cmd_guard_check", JsonBool (bCmdGuard));
    NuiSetBindWatch (oPC, nToken, "chbx_cmd_guard_check", TRUE);
    NuiSetBind(oPC, nToken, "chbx_cmd_guard_event", JsonBool(TRUE));
    NuiSetBind(oPC, nToken, "btn_cmd_guard_event", JsonBool (TRUE));
    NuiSetBind(oPC, nToken, "btn_cmd_guard_tooltip", JsonString("  Guard button"));

    NuiSetBind(oPC, nToken, "chbx_cmd_hold_check", JsonBool (bCmdHold));
    NuiSetBindWatch (oPC, nToken, "chbx_cmd_hold_check", TRUE);
    NuiSetBind(oPC, nToken, "chbx_cmd_hold_event", JsonBool(TRUE));
    NuiSetBind(oPC, nToken, "btn_cmd_hold_event", JsonBool (TRUE));
    NuiSetBind(oPC, nToken, "btn_cmd_hold_tooltip", JsonString("  Hold button"));

    NuiSetBind(oPC, nToken, "chbx_cmd_attack_check", JsonBool (bCmdAttack));
    NuiSetBindWatch (oPC, nToken, "chbx_cmd_attack_check", TRUE);
    NuiSetBind(oPC, nToken, "chbx_cmd_attack_event", JsonBool(TRUE));
    NuiSetBind(oPC, nToken, "btn_cmd_attack_event", JsonBool (TRUE));
    NuiSetBind(oPC, nToken, "btn_cmd_attack_tooltip", JsonString("  Attack button"));

    NuiSetBind(oPC, nToken, "chbx_cmd_follow_check", JsonBool (bCmdFollow));
    NuiSetBindWatch (oPC, nToken, "chbx_cmd_follow_check", TRUE);
    NuiSetBind(oPC, nToken, "chbx_cmd_follow_event", JsonBool(TRUE));
    NuiSetBind(oPC, nToken, "btn_cmd_follow_event", JsonBool (TRUE));
    NuiSetBind(oPC, nToken, "btn_cmd_follow_tooltip", JsonString("  Follow button"));

    NuiSetBind(oPC, nToken, "chbx_follow_target_check", JsonBool (bFollowTarget));
    NuiSetBindWatch (oPC, nToken, "chbx_follow_target_check", TRUE);
    NuiSetBind(oPC, nToken, "chbx_follow_target_event", JsonBool(TRUE));
    NuiSetBind(oPC, nToken, "btn_follow_target_event", JsonBool (TRUE));
    NuiSetBind(oPC, nToken, "btn_follow_target_tooltip", JsonString("  Follow Target button"));

    NuiSetBind(oPC, nToken, "chbx_cmd_search_check", JsonBool (bCmdSearch));
    NuiSetBindWatch (oPC, nToken, "chbx_cmd_search_check", TRUE);
    NuiSetBind(oPC, nToken, "chbx_cmd_search_event", JsonBool(TRUE));
    NuiSetBind(oPC, nToken, "btn_cmd_search_event", JsonBool (TRUE));
    NuiSetBind(oPC, nToken, "btn_cmd_search_tooltip", JsonString("  Search All button"));

    NuiSetBind(oPC, nToken, "chbx_cmd_stealth_check", JsonBool (bCmdStealth));
    NuiSetBindWatch (oPC, nToken, "chbx_cmd_stealth_check", TRUE);
    NuiSetBind(oPC, nToken, "chbx_cmd_stealth_event", JsonBool(TRUE));
    NuiSetBind(oPC, nToken, "btn_cmd_stealth_event", JsonBool (TRUE));
    NuiSetBind(oPC, nToken, "btn_cmd_stealth_tooltip", JsonString("  Stealth All button"));

    NuiSetBind(oPC, nToken, "chbx_cmd_ai_script_check", JsonBool (bCmdAIScript));
    NuiSetBindWatch (oPC, nToken, "chbx_cmd_ai_script_check", TRUE);
    NuiSetBind(oPC, nToken, "chbx_cmd_ai_script_event", JsonBool(TRUE));
    NuiSetBind(oPC, nToken, "btn_cmd_ai_script_event", JsonBool (TRUE));
    NuiSetBind(oPC, nToken, "btn_cmd_ai_script_tooltip", JsonString("  Combat Tactics button"));

    NuiSetBind(oPC, nToken, "chbx_cmd_place_trap_check", JsonBool (bCmdPlacetrap));
    NuiSetBindWatch (oPC, nToken, "chbx_cmd_place_trap_check", TRUE);
    NuiSetBind(oPC, nToken, "chbx_cmd_place_trap_event", JsonBool(TRUE));
    NuiSetBind(oPC, nToken, "btn_cmd_place_trap_event", JsonBool (TRUE));
    NuiSetBind(oPC, nToken, "btn_cmd_place_trap_tooltip", JsonString ("  Place Trap button"));
    // Row 5
    NuiSetBind(oPC, nToken, "chbx_quick_widget_check", JsonBool (bSpellWidget));
    NuiSetBindWatch (oPC, nToken, "chbx_quick_widget_check", TRUE);
    NuiSetBind(oPC, nToken, "chbx_quick_widget_event", JsonBool(TRUE));
    NuiSetBind(oPC, nToken, "btn_quick_widget_event", JsonBool(TRUE));
    NuiSetBind (oPC, nToken, "btn_quick_widget_tooltip", JsonString("  Quick Use button"));

    NuiSetBind(oPC, nToken, "chbx_spell_memorize_check", JsonBool (bMemorizeSpells));
    NuiSetBindWatch (oPC, nToken, "chbx_spell_memorize_check", TRUE);
    NuiSetBind(oPC, nToken, "chbx_spell_memorize_event", JsonBool(TRUE));
    NuiSetBind(oPC, nToken, "btn_spell_memorize_event", JsonBool(TRUE));
    NuiSetBind (oPC, nToken, "btn_spell_memorize_tooltip", JsonString("  Memorize Spells button"));

    NuiSetBind(oPC, nToken, "chbx_buff_short_check", JsonBool (bBuffShort));
    NuiSetBindWatch (oPC, nToken, "chbx_buff_short_check", TRUE);
    NuiSetBind(oPC, nToken, "chbx_buff_short_event", JsonBool(TRUE));
    NuiSetBind(oPC, nToken, "btn_buff_short_event", JsonBool (TRUE));
    NuiSetBind (oPC, nToken, "btn_buff_short_tooltip", JsonString("  Short Buffing button"));

    NuiSetBind(oPC, nToken, "chbx_buff_long_check", JsonBool (bBuffLong));
    NuiSetBindWatch (oPC, nToken, "chbx_buff_long_check", TRUE);
    NuiSetBind(oPC, nToken, "chbx_buff_long_event", JsonBool(TRUE));
    NuiSetBind(oPC, nToken, "btn_buff_long_event", JsonBool (TRUE));
    NuiSetBind(oPC, nToken, "btn_buff_long_tooltip", JsonString("  Long Buffing button"));

    NuiSetBind(oPC, nToken, "chbx_buff_all_check", JsonBool (bBuffAll));
    NuiSetBindWatch (oPC, nToken, "chbx_buff_all_check", TRUE);
    NuiSetBind(oPC, nToken, "chbx_buff_all_event", JsonBool(TRUE));
    NuiSetBind(oPC, nToken, "btn_buff_all_event", JsonBool (TRUE));
    NuiSetBind(oPC, nToken, "btn_buff_all_tooltip", JsonString("  All Buffing button"));

    NuiSetBind(oPC, nToken, "chbx_buff_rest_check", JsonBool (bBuffRest));
    NuiSetBindWatch (oPC, nToken, "chbx_buff_rest_check", TRUE);
    NuiSetBind(oPC, nToken, "chbx_buff_rest_event", JsonBool(TRUE));
    NuiSetBind(oPC, nToken, "btn_buff_rest_event", JsonBool (TRUE));
    NuiSetBind (oPC, nToken, "btn_buff_rest_tooltip", JsonString("  Rest Buffing button"));

    NuiSetBind(oPC, nToken, "chbx_jump_to_check", JsonBool(bJumpTo));
    NuiSetBindWatch (oPC, nToken, "chbx_jump_to_check", TRUE);
    NuiSetBind(oPC, nToken, "chbx_jump_to_event", JsonBool(TRUE));
    NuiSetBind(oPC, nToken, "btn_jump_to_event", JsonBool(TRUE));
    NuiSetBind(oPC, nToken, "btn_jump_to_tooltip", JsonString("  Jump Associates button"));

    NuiSetBind(oPC, nToken, "chbx_ghost_mode_check", JsonBool (bGhostMode));
    NuiSetBindWatch (oPC, nToken, "chbx_ghost_mode_check", TRUE);
    NuiSetBind(oPC, nToken, "chbx_ghost_mode_event", JsonBool(TRUE));
    NuiSetBind(oPC, nToken, "btn_ghost_mode_event", JsonBool (TRUE));
    NuiSetBind(oPC, nToken, "btn_ghost_mode_tooltip", JsonString("  Ghost mode button"));

    NuiSetBind(oPC, nToken, "chbx_camera_check", JsonBool (bCamera));
    NuiSetBindWatch (oPC, nToken, "chbx_camera_check", TRUE);
    NuiSetBind(oPC, nToken, "chbx_camera_event", JsonBool(TRUE));
    NuiSetBind(oPC, nToken, "btn_camera_event", JsonBool (TRUE));
    NuiSetBind(oPC, nToken, "btn_camera_tooltip", JsonString("  Change Camera button"));

    NuiSetBind(oPC, nToken, "chbx_inventory_check", JsonBool (bInventory));
    NuiSetBindWatch (oPC, nToken, "chbx_inventory_check", TRUE);
    NuiSetBind(oPC, nToken, "chbx_inventory_event", JsonBool(TRUE));
    NuiSetBind(oPC, nToken, "btn_inventory_event", JsonBool (TRUE));
    NuiSetBind(oPC, nToken, "btn_inventory_tooltip", JsonString("  Open Inventory button"));
    // Row 6
    NuiSetBind(oPC, nToken, "chbx_familiar_check", JsonBool(bBtnFamiliar));
    NuiSetBindWatch (oPC, nToken, "chbx_familiar_check", TRUE);
    NuiSetBind(oPC, nToken, "chbx_familiar_event", JsonBool(TRUE));
    NuiSetBind(oPC, nToken, "btn_familiar_event", JsonBool (TRUE));
    NuiSetBind(oPC, nToken, "btn_familiar_tooltip", JsonString("  Change Familiar buttons"));

    NuiSetBind(oPC, nToken, "chbx_companion_check", JsonBool(bBtnCompanion));
    NuiSetBindWatch (oPC, nToken, "chbx_companion_check", TRUE);
    NuiSetBind(oPC, nToken, "chbx_companion_event", JsonBool(TRUE));
    NuiSetBind(oPC, nToken, "btn_companion_event", JsonBool (TRUE));
    NuiSetBind(oPC, nToken, "btn_companion_tooltip", JsonString("  Change Animal Companion buttons"));

    NuiSetBind(oPC, nToken, "chbx_ai_check", JsonBool(bAI));
    NuiSetBindWatch (oPC, nToken, "chbx_ai_check", TRUE);
    NuiSetBind(oPC, nToken, "chbx_ai_event", JsonBool(TRUE));
    NuiSetBind(oPC, nToken, "btn_ai_event", JsonBool(TRUE));
    NuiSetBind(oPC, nToken, "btn_ai_tooltip", JsonString("  Player AI button"));

    NuiSetBind(oPC, nToken, "chbx_quiet_check", JsonBool(bReduceSpeech));
    NuiSetBindWatch (oPC, nToken, "chbx_quiet_check", TRUE);
    NuiSetBind(oPC, nToken, "chbx_quiet_event", JsonBool(TRUE));
    NuiSetBind(oPC, nToken, "btn_quiet_event", JsonBool(TRUE));
    NuiSetBind (oPC, nToken, "btn_quiet_tooltip", JsonString("  Reduce Speech button"));

    NuiSetBind(oPC, nToken, "chbx_ranged_check", JsonBool(bRanged));
    NuiSetBindWatch(oPC, nToken, "chbx_ranged_check", TRUE);
    NuiSetBind(oPC, nToken, "chbx_ranged_event", JsonBool(TRUE));
    NuiSetBind(oPC, nToken, "btn_ranged_event", JsonBool(TRUE));
    NuiSetBind (oPC, nToken, "btn_ranged_tooltip", JsonString("  Ranged button"));

    NuiSetBind(oPC, nToken, "chbx_ignore_assoc_check", JsonBool(bIgnoreAssociates));
    NuiSetBindWatch(oPC, nToken, "chbx_ignore_assoc_check", TRUE);
    NuiSetBind(oPC, nToken, "chbx_ignore_assoc_event", JsonBool(TRUE));
    NuiSetBind(oPC, nToken, "btn_ignore_assoc_event", JsonBool(TRUE));
    NuiSetBind (oPC, nToken, "btn_ignore_assoc_tooltip", JsonString("  Ignore Associates button"));

    NuiSetBind(oPC, nToken, "chbx_search_check", JsonBool(bSearch));
    NuiSetBindWatch (oPC, nToken, "chbx_search_check", TRUE);
    NuiSetBind(oPC, nToken, "chbx_search_event", JsonBool(TRUE));
    NuiSetBind(oPC, nToken, "btn_search_event", JsonBool(TRUE));
    NuiSetBind (oPC, nToken, "btn_search_tooltip", JsonString("  Search button"));

    NuiSetBind(oPC, nToken, "chbx_stealth_check", JsonBool(bStealth));
    NuiSetBindWatch(oPC, nToken, "chbx_stealth_check", TRUE);
    NuiSetBind(oPC, nToken, "chbx_stealth_event", JsonBool(TRUE));
    NuiSetBind(oPC, nToken, "btn_stealth_event", JsonBool(TRUE));
    NuiSetBind (oPC, nToken, "btn_stealth_tooltip", JsonString("  Stealth button"));

    NuiSetBind(oPC, nToken, "chbx_open_door_check", JsonBool(bOpenDoors));
    NuiSetBindWatch (oPC, nToken, "chbx_open_door_check", TRUE);
    NuiSetBind(oPC, nToken, "chbx_open_door_event", JsonBool(TRUE));
    NuiSetBind(oPC, nToken, "btn_open_door_event", JsonBool(TRUE));
    NuiSetBind (oPC, nToken, "btn_open_door_tooltip", JsonString("  Open Door button"));

    NuiSetBind(oPC, nToken, "chbx_traps_check", JsonBool(bTraps));
    NuiSetBindWatch (oPC, nToken, "chbx_traps_check", TRUE);
    NuiSetBind(oPC, nToken, "chbx_traps_event", JsonBool(TRUE));
    NuiSetBind(oPC, nToken, "btn_traps_event", JsonBool(TRUE));
    NuiSetBind (oPC, nToken, "btn_traps_tooltip", JsonString("  Disable Traps button"));
    // Row 7
    NuiSetBind(oPC, nToken, "chbx_pick_locks_check", JsonBool(bPickLocks));
    NuiSetBindWatch(oPC, nToken, "chbx_pick_locks_check", TRUE);
    NuiSetBind(oPC, nToken, "chbx_pick_locks_event", JsonBool(TRUE));
    NuiSetBind(oPC, nToken, "btn_pick_locks_event", JsonBool(TRUE));
    NuiSetBind (oPC, nToken, "btn_pick_locks_tooltip", JsonString("  Pick Locks button"));

    NuiSetBind(oPC, nToken, "chbx_bash_locks_check", JsonBool(bBashLocks));
    NuiSetBindWatch(oPC, nToken, "chbx_bash_locks_check", TRUE);
    NuiSetBind(oPC, nToken, "chbx_bash_locks_event", JsonBool(TRUE));
    NuiSetBind(oPC, nToken, "btn_bash_locks_event", JsonBool(TRUE));
    NuiSetBind (oPC, nToken, "btn_bash_locks_tooltip", JsonString("  Bash button"));

    NuiSetBind(oPC, nToken, "chbx_magic_level_check", JsonBool(bMagicLevel));
    NuiSetBindWatch (oPC, nToken, "chbx_magic_level_check", TRUE);
    NuiSetBind(oPC, nToken, "chbx_magic_level_event", JsonBool(TRUE));
    NuiSetBind(oPC, nToken, "btn_magic_level_event", JsonBool(TRUE));
    NuiSetBind (oPC, nToken, "btn_magic_level_tooltip", JsonString("  Magic Level button"));

    NuiSetBind(oPC, nToken, "chbx_spontaneous_check", JsonBool(bSpontaneous));
    NuiSetBindWatch (oPC, nToken, "chbx_spontaneous_check", TRUE);
    NuiSetBind(oPC, nToken, "chbx_spontaneous_event", JsonBool(TRUE));
    NuiSetBind(oPC, nToken, "btn_spontaneous_event", JsonBool(TRUE));
    NuiSetBind(oPC, nToken, "btn_spontaneous_tooltip", JsonString("  Spontaneous Spells button"));

    NuiSetBind(oPC, nToken, "chbx_magic_check", JsonBool(bNoMagic));
    NuiSetBindWatch (oPC, nToken, "chbx_magic_check", TRUE);
    NuiSetBind(oPC, nToken, "chbx_magic_event", JsonBool(TRUE));
    NuiSetBind(oPC, nToken, "btn_magic_event", JsonBool(TRUE));
    NuiSetBind(oPC, nToken, "btn_magic_tooltip", JsonString("  Use Magic button"));

    NuiSetBind(oPC, nToken, "chbx_magic_items_check", JsonBool(bNoMagicItems));
    NuiSetBindWatch (oPC, nToken, "chbx_magic_items_check", TRUE);
    NuiSetBind(oPC, nToken, "chbx_magic_items_event", JsonBool(TRUE));
    NuiSetBind(oPC, nToken, "btn_magic_items_event", JsonBool(TRUE));
    NuiSetBind(oPC, nToken, "btn_magic_items_tooltip", JsonString("  Use Magic Items button"));

    NuiSetBind(oPC, nToken, "chbx_def_magic_check", JsonBool (bDefMagic));
    NuiSetBindWatch (oPC, nToken, "chbx_def_magic_check", TRUE);
    NuiSetBind(oPC, nToken, "chbx_def_magic_event", JsonBool(TRUE));
    NuiSetBind(oPC, nToken, "btn_def_magic_event", JsonBool(TRUE));
    NuiSetBind(oPC, nToken, "btn_def_magic_tooltip", JsonString("  Use Defensive Magic button"));

    NuiSetBind(oPC, nToken, "chbx_off_magic_check", JsonBool(bOffMagic));
    NuiSetBindWatch (oPC, nToken, "chbx_off_magic_check", TRUE);
    NuiSetBind(oPC, nToken, "chbx_off_magic_event", JsonBool(TRUE));
    NuiSetBind(oPC, nToken, "btn_off_magic_event", JsonBool(TRUE));
    NuiSetBind(oPC, nToken, "btn_off_magic_tooltip", JsonString("  Use Offensive Magic button"));

    NuiSetBind(oPC, nToken, "chbx_heal_out_check", JsonBool(bHealOut));
    NuiSetBindWatch (oPC, nToken, "chbx_heal_out_check", TRUE);
    NuiSetBind(oPC, nToken, "chbx_heal_out_event", JsonBool(TRUE));
    NuiSetBind(oPC, nToken, "btn_heal_out_event", JsonBool(TRUE));
    NuiSetBind(oPC, nToken, "btn_heal_out_tooltip", JsonString("  Heal Out of Combat button"));

    NuiSetBind(oPC, nToken, "chbx_heal_in_check", JsonBool(bHealIn));
    NuiSetBindWatch (oPC, nToken, "chbx_heal_in_check", TRUE);
    NuiSetBind(oPC, nToken, "chbx_heal_in_event", JsonBool(TRUE));
    NuiSetBind(oPC, nToken, "btn_heal_in_event", JsonBool (TRUE));
    NuiSetBind(oPC, nToken, "btn_heal_in_tooltip", JsonString("  Heal In Combat button"));
    // Row 8
    NuiSetBind(oPC, nToken, "chbx_heals_onoff_check", JsonBool(bSelfHealOnOff));
    NuiSetBindWatch (oPC, nToken, "chbx_heals_onoff_check", TRUE);
    NuiSetBind(oPC, nToken, "chbx_heals_onoff_event", JsonBool(TRUE));
    NuiSetBind(oPC, nToken, "btn_heals_onoff_event", JsonBool(TRUE));
    NuiSetBind(oPC, nToken, "btn_heals_onoff_tooltip", JsonString("  Heal Self button"));

    NuiSetBind(oPC, nToken, "chbx_healp_onoff_check", JsonBool(bPartyHealOnOff));
    NuiSetBind(oPC, nToken, "chbx_healp_onoff_event", JsonBool(TRUE));
    NuiSetBindWatch (oPC, nToken, "chbx_healp_onoff_check", TRUE);
    NuiSetBind(oPC, nToken, "btn_healp_onoff_event", JsonBool(TRUE));
    NuiSetBind(oPC, nToken, "btn_healp_onoff_tooltip", JsonString("  Heal Party button"));

    NuiSetBind(oPC, nToken, "chbx_loot_check", JsonBool(bLoot));
    NuiSetBindWatch (oPC, nToken, "chbx_loot_check", TRUE);
    NuiSetBind(oPC, nToken, "chbx_loot_event", JsonBool(TRUE));
    NuiSetBind(oPC, nToken, "btn_loot_event", JsonBool(TRUE));
    NuiSetBind(oPC, nToken, "btn_loot_tooltip", JsonString("  Auto Looting button"));

    NuiSetBind(oPC, nToken, "chbx_perc_range_check", JsonBool(bPercRange));
    NuiSetBindWatch (oPC, nToken, "chbx_perc_range_check", TRUE);
    NuiSetBind(oPC, nToken, "chbx_perc_range_event", JsonBool(TRUE));
    NuiSetBind(oPC, nToken, "btn_perc_range_event", JsonBool(TRUE));
    NuiSetBind(oPC, nToken, "btn_perc_range_tooltip", JsonString("  Perception Range button"));
}

