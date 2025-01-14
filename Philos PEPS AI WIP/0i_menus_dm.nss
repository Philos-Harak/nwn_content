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
    DelayCommand(2.0f, DeleteLocalInt (oPC, AI_NO_NUI_SAVE));
    string sName = ai_RemoveIllegalCharacters(GetName(oPC));
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
    int nIndex;
    string sButton;
    json jPlugins = ai_UpdatePluginsForDM(oPC);
    json jScript = JsonArrayGet(jPlugins, nIndex);
    while(JsonGetType(jScript) != JSON_TYPE_NULL)
    {
        jScript = JsonArrayGet(jPlugins, ++nIndex);
        if(JsonGetInt(jScript))
        {
            sButton = IntToString((nIndex + 1) / 2);
            CreateButtonImage(jRow, "is_summon" + sButton, "btn_exe_plugin_" + sButton, 35.0f, 35.0f, 0.0, "btn_exe_plugin_" + sButton + "_tooltip");
            fButtons += 1.0;
        }
        jScript = JsonArrayGet(jPlugins, ++nIndex);
    }
    if(fButtons > 1.0f) fWidth = fWidth + ((fButtons - 1.0) * 39.0f);
    // Add the row to the column.
    json jCol = JsonArray();
    JsonArrayInsertInplace(jCol, NuiRow(jRow));
    // Get the window location to restore it from the database.
    json jGeometry = ai_GetCampaignDbJson("location", sName, AI_DM_TABLE);
    float fX = JsonGetFloat(JsonObjectGet(jGeometry, "x"));
    float fY = JsonGetFloat(JsonObjectGet(jGeometry, "y"));
    float fGUI_Scale = IntToFloat(GetPlayerDeviceProperty(oPC, PLAYER_DEVICE_PROPERTY_GUI_SCALE)) / 100.0;
    if(fGUI_Scale == 0.0) fGUI_Scale = 1.0;
    if(bAIWidgetLock)
    {
        fX = fX + 4.0f;
        fY = fY + 37.0f;
    }
    else if(fY == 1.0 && fX == 1.0) fY = 1.0;
    //fY = fY * fGUI_Scale;
    // Set the layout of the window.
    json jLayout = NuiCol(jCol);
    int nToken;
    string sHeal, sText, sRange;
    string sDisplayName = GetName(oPC);
    if(GetStringRight(sDisplayName, 1) == "s") sDisplayName = sDisplayName + "'";
    else sDisplayName = sDisplayName + "'s";
    if(bAIWidgetLock) nToken = SetWindow(oPC, jLayout, "dm_widget", sDisplayName + " Widget", fX, fY, fWidth + 8.0f, fHeight, FALSE, FALSE, FALSE, TRUE, FALSE, "0e_nui_dm");
    else nToken = SetWindow(oPC, jLayout, "dm_widget", sDisplayName + " Widget", fX, fY, fWidth + 12.0f, fHeight, FALSE, FALSE, FALSE, TRUE, TRUE, "0e_nui_dm");
    // Set event watches for window inspector and save window location.
    NuiSetBindWatch(oPC, nToken, "window_geometry", TRUE);
    // Set the buttons to show events.
    NuiSetBind(oPC, nToken, "btn_open_main_image", JsonString(GetPortraitResRef(oPC) + "s"));
    NuiSetBind(oPC, nToken, "btn_open_main_event", JsonBool(TRUE));
    NuiSetBind(oPC, nToken, "btn_open_main_tooltip", JsonString("  " + sDisplayName + " widget menu"));
    string sUUID;
    if(bCmdGroup1)
    {
        NuiSetBind(oPC, nToken, "btn_cmd_group1_event", JsonBool(TRUE));
        sUUID = JsonGetString(JsonArrayGet(GetLocalJson(oPC, "DM_GROUP1"), 0));
        if(sUUID == "") sText = "Group1";
        else sText = GetName(GetObjectByUUID(sUUID)) + "'s group";
        NuiSetBind(oPC, nToken, "btn_cmd_group1_tooltip", JsonString("  " + sText + " (Left Action/Right Add)"));
    }
    if(bCmdGroup2)
    {
        NuiSetBind(oPC, nToken, "btn_cmd_group2_event", JsonBool(TRUE));
        sUUID = JsonGetString(JsonArrayGet(GetLocalJson(oPC, "DM_GROUP2"), 0));
        if(sUUID == "") sText = "Group2";
        else sText = GetName(GetObjectByUUID(sUUID)) + "'s group";
        NuiSetBind(oPC, nToken, "btn_cmd_group2_tooltip", JsonString("  " + sText + " (Left Action/Right Add)"));
    }
    if(bCmdGroup3)
    {
        NuiSetBind(oPC, nToken, "btn_cmd_group3_event", JsonBool(TRUE));
        sUUID = JsonGetString(JsonArrayGet(GetLocalJson(oPC, "DM_GROUP3"), 0));
        if(sUUID == "") sText = "Group3";
        else sText = GetName(GetObjectByUUID(sUUID)) + "'s group";
        NuiSetBind(oPC, nToken, "btn_cmd_group3_tooltip", JsonString("  " + sText + " (Left Action/Right Add)"));
    }
    if(bCmdGroup4)
    {
        NuiSetBind(oPC, nToken, "btn_cmd_group4_event", JsonBool(TRUE));
        sUUID = JsonGetString(JsonArrayGet(GetLocalJson(oPC, "DM_GROUP4"), 0));
        if(sUUID == "") sText = "Group4";
        else sText = GetName(GetObjectByUUID(sUUID)) + "'s group";
        NuiSetBind(oPC, nToken, "btn_cmd_group4_tooltip", JsonString("  " + sText + " (Left Action/Right Add)"));
    }
    if(bCmdGroup5)
    {
        NuiSetBind(oPC, nToken, "btn_cmd_group5_event", JsonBool(TRUE));
        sUUID = JsonGetString(JsonArrayGet(GetLocalJson(oPC, "DM_GROUP5"), 0));
        if(sUUID == "") sText = "Group5";
        else sText = GetName(GetObjectByUUID(sUUID)) + "'s group";
        NuiSetBind(oPC, nToken, "btn_cmd_group5_tooltip", JsonString("  " + sText + " (Left Action/Right Add)"));
    }
    if(bCmdGroup6)
    {
        NuiSetBind(oPC, nToken, "btn_cmd_group6_event", JsonBool(TRUE));
        sUUID = JsonGetString(JsonArrayGet(GetLocalJson(oPC, "DM_GROUP6"), 0));
        if(sUUID == "") sText = "Group6";
        else sText = GetName(GetObjectByUUID(sUUID)) + "'s group";
        NuiSetBind(oPC, nToken, "btn_cmd_group6_tooltip", JsonString("  " + sText + " (Left Action/Right Add)"));
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
    jPlugins = ai_GetCampaignDbJson("plugins", sName, AI_DM_TABLE);
    jScript = JsonArrayGet(jPlugins, nIndex);
    while(JsonGetType(jScript) != JSON_TYPE_NULL)
    {
        sScript = JsonGetString(jScript);
        jScript = JsonArrayGet(jPlugins, ++nIndex);
        if(JsonGetInt(jScript))
        {
            sButton = IntToString((nIndex + 1) / 2);
            if(ResManGetAliasFor(sScript, RESTYPE_NCS) == "") sText = "  " + sScript + " not found by ResMan!";
            else sText = "  Executes " + sScript + " plugin";
            NuiSetBind(oPC, nToken, "btn_exe_plugin_" + sButton + "_event", JsonBool (TRUE));
            NuiSetBind(oPC, nToken, "btn_exe_plugin_" + sButton + "_tooltip", JsonString(sText));
        }
        jScript = JsonArrayGet(jPlugins, ++nIndex);
    }
}
void ai_CreateDMOptionsNUI(object oPC)
{
    int nMonsterAI = (ResManGetAliasFor("0e_c2_1_hb", RESTYPE_NCS) != "");
    int nAssociateAI = (ResManGetAliasFor("0e_ch_1_hb", RESTYPE_NCS) != "");
    // ************************************************************************* Width / Height
    string sText = " [Single player]";
    if(AI_SERVER) sText = " [Server]";
    // Row 1 ******************************************************************* 500 / 73
    json jRow = JsonArray();
    JsonArrayInsertInplace(jRow, NuiSpacer());
    CreateLabel(jRow, PHILOS_VERSION + sText, "lbl_version", 475.0f, 20.0f, NUI_HALIGN_CENTER);
    JsonArrayInsertInplace(jRow, NuiSpacer());
    // Add row to the column.
    json jCol = JsonArray();
    JsonArrayInsertInplace(jCol, NuiRow(jRow));
    // Row 2 ******************************************************************* 500 / 101
    jRow = JsonArray();
    CreateLabel(jRow, "", "lbl_ai_info", 475.0f, 20.0f, NUI_HALIGN_CENTER);
    // Add row to the column.
    JsonArrayInsertInplace(jCol, NuiRow(jRow));
    // Row 3 ******************************************************************* 500 / 129
    jRow = JsonArray();
    CreateButton(jRow, "Plugin Manager", "btn_plugin_manager", 150.0f, 20.0f, -1.0, "btn_plugin_manager_tooltip");
    JsonArrayInsertInplace(jRow, NuiSpacer());
    // Add row to the column.
    JsonArrayInsertInplace(jCol, NuiRow(jRow));
    // Row 4 ******************************************************************* 500 / 157
    jRow = JsonArray();
    JsonArrayInsertInplace(jRow, NuiSpacer());
    CreateLabel(jRow, "AI RULES", "lbl_ai_rules", 80.0f, 20.0f, NUI_HALIGN_CENTER);
    JsonArrayInsertInplace(jRow, NuiSpacer());
    // Add row to the column.
    JsonArrayInsertInplace(jCol, NuiRow(jRow));
    float fHeight = 157.0;
    // Row 5 ******************************************************************* 500 / --- (26)
    jRow = JsonArray();
    // Make the AI options a Group.
    json jGroupRow = JsonArray();
    json jGroupCol = JsonArray();
    CreateTextEditBox(jGroupRow, "sPlaceHolder", "txt_max_henchman", 2, FALSE, 30.0f, 20.0f, "txt_max_henchman_tooltip");
    CreateLabel(jGroupRow, "Max number of henchmen allowed on the server.", "lbl_max_hench", 416.0f, 20.0f, NUI_HALIGN_LEFT, 0, -1.0, "txt_max_henchman_tooltip");
    JsonArrayInsertInplace(jGroupCol, NuiRow(jGroupRow));
    fHeight += 52.0;
    jGroupRow = JsonArray();
    if(nMonsterAI)
    {
        CreateTextEditBox(jGroupRow, "sPlaceHolder", "txt_ai_difficulty", 3, FALSE, 40.0f, 20.0f, "txt_ai_difficulty_tooltip");
        CreateLabel(jGroupRow, "% chance monsters will attack the weakest target.", "lbl_ai_difficulty", 406.0f, 20.0f, NUI_HALIGN_LEFT, 0, -1.0, "txt_ai_difficulty_tooltip");
        JsonArrayInsertInplace(jGroupCol, NuiRow(jGroupRow));
        jGroupRow = JsonArray();
        CreateCheckBox(jGroupRow, " Allow monsters to prebuff before combat starts.", "chbx_buff_monsters", 450.0, 20.0);
        JsonArrayInsertInplace(jGroupCol, NuiRow(jGroupRow));
        jGroupRow = JsonArray();
        CreateCheckBox(jGroupRow, " Allow monsters to use summons before combat starts.", "chbx_buff_summons", 450.0, 20.0);
        JsonArrayInsertInplace(jGroupCol, NuiRow(jGroupRow));
        jGroupRow = JsonArray();
        CreateCheckBox(jGroupRow, " Allow monsters to use tactics (ambush, defensive, etc).", "chbx_ambush_monsters", 450.0, 20.0);
        JsonArrayInsertInplace(jGroupCol, NuiRow(jGroupRow));
        jGroupRow = JsonArray();
        CreateCheckBox(jGroupRow, " Allow monsters to summon companions.", "chbx_companions", 450.0, 20.0);
        JsonArrayInsertInplace(jGroupCol, NuiRow(jGroupRow));
        jGroupRow = JsonArray();
        CreateCheckBox(jGroupRow, " Summoned associates to remain after masters death.", "chbx_perm_assoc", 450.0, 20.0);
        JsonArrayInsertInplace(jGroupCol, NuiRow(jGroupRow));
        jGroupRow = JsonArray();
        CreateTextEditBox(jGroupRow, "sPlaceHolder", "txt_perception_distance", 2, FALSE, 35.0f, 20.0f, "txt_perception_distance_tooltip");
        CreateLabel(jGroupRow, "meters is the distance a monster can respond to allies.", "lbl_perception_distance", 411.0f, 20.0f, NUI_HALIGN_LEFT, 0, 0.0, "txt_perception_distance_tooltip");
        JsonArrayInsertInplace(jGroupCol, NuiRow(jGroupRow));
        jGroupRow = JsonArray();
        CreateLabel(jGroupRow, "", "lbl_perc_dist", 450.0f, 20.0f, NUI_HALIGN_LEFT, 0, 0.0, "lbl_perc_dist_tooltip");
        JsonArrayInsertInplace(jGroupCol, NuiRow(jGroupRow));
        jGroupRow = JsonArray();
        CreateCheckBox(jGroupRow, " Enemy corpses remain, this can break some modules!", "chbx_corpses_stay", 450.0, 20.0);
        JsonArrayInsertInplace(jGroupCol, NuiRow(jGroupRow));
        jGroupRow = JsonArray();
        CreateCheckBox(jGroupRow, " Allow monsters to wander, this can break some modules!", "chbx_wander", 450.0, 20.0);
        JsonArrayInsertInplace(jGroupCol, NuiRow(jGroupRow));
        jGroupRow = JsonArray();
        CreateTextEditBox(jGroupRow, "sPlaceHolder", "txt_inc_hp", 3, FALSE, 40.0f, 20.0f, "txt_inc_hp_tooltip");
        CreateLabel(jGroupRow, "% increase to all monster's hitpoints.", "lbl_inc_percentage", 406.0, 20.0, NUI_HALIGN_LEFT);
        JsonArrayInsertInplace(jGroupCol, NuiRow(jGroupRow));
        fHeight += 286.0;
    }
    if(nMonsterAI || nAssociateAI)
    {
        jGroupRow = JsonArray();
        CreateCheckBox(jGroupRow, " Allow creatures to use advanced combat movement.", "chbx_advanced_movement", 450.0, 20.0);
        JsonArrayInsertInplace(jGroupCol, NuiRow(jGroupRow));
        jGroupRow = JsonArray();
        CreateCheckBox(jGroupRow, " Use item level restrictions for creatures [Default is off].", "chbx_ilr", 450.0, 20.0);
        JsonArrayInsertInplace(jGroupCol, NuiRow(jGroupRow));
        jGroupRow = JsonArray();
        CreateCheckBox(jGroupRow, " Allow creatures to use the skill Use Magic Device.", "chbx_umd", 450.0, 20.0);
        JsonArrayInsertInplace(jGroupCol, NuiRow(jGroupRow));
        jGroupRow = JsonArray();
        CreateCheckBox(jGroupRow, " Allow creatures to use Healing kits.", "chbx_use_healingkits", 450.0, 20.0);
        JsonArrayInsertInplace(jGroupCol, NuiRow(jGroupRow));
        jGroupRow = JsonArray();
        CreateCheckBox(jGroupRow, " Moral checks, wounded creatures may flee during combat.", "chbx_moral", 450.0, 20.0);
        JsonArrayInsertInplace(jGroupCol, NuiRow(jGroupRow));
        fHeight += 130.0;
    }
    JsonArrayInsertInplace(jRow, NuiGroup(NuiCol(jGroupCol)));
    // Add row to the column.
    JsonArrayInsertInplace(jCol, NuiRow(jRow));
    // Set the Layout of the window.
    json jLayout = NuiCol(jCol);
    string sName = GetName(oPC);
    if(GetStringRight(sName, 1) == "s") sName = sName + "'";
    else sName = sName + "'s";
    int nToken = SetWindow(oPC, jLayout, "dm_main_nui", sName + " PEPS Main Menu",
                             -1.0, -1.0, 500.0f, fHeight + 12.0f, FALSE, FALSE, TRUE, FALSE, TRUE, "0e_nui_dm");
    // Save the associate to the nui for use in 0e_nui
    json jData = JsonArray();
    JsonArrayInsertInplace(jData, JsonString(ObjectToString(oPC)));
    NuiSetUserData(oPC, nToken, jData);
    object oModule = GetModule();
    // Set all binds, events, and watches.
    // Row 1 - Version label.
    // Row 2
    int nUsing;
    // Check the monster AI.
    string sLocation = ResManGetAliasFor("0e_c2_1_hb", RESTYPE_NCS);
    if(sLocation != "") sText = "Monster AI is loaded";
    else sText = "Monster AI not loaded";
    // Check the associate AI.
    sLocation = ResManGetAliasFor("0e_ch_1_hb", RESTYPE_NCS);
    if(sLocation != "") sText += ", Associate AI is loaded";
    else sText += ", Associate AI not loaded";
    // Check the player AI.
    sLocation = ResManGetAliasFor("xx_pc_1_hb", RESTYPE_NCS);
    if(sLocation != "") sText += ", Player AI loaded.";
    else sText += ", Player AI not loaded.";
    NuiSetBind(oPC, nToken, "lbl_ai_info_label", JsonString(sText));
    // Row 3
    NuiSetBind(oPC, nToken, "btn_plugin_manager_event", JsonBool(TRUE));
    NuiSetBind(oPC, nToken, "btn_plugin_manager_tooltip", JsonString("  Manages external executable scripts."));
    // Row 3 Label for AI RULES
    // Row 4
    NuiSetBind(oPC, nToken, "txt_max_henchman", JsonString(IntToString(GetLocalInt(oModule, AI_RULE_MAX_HENCHMAN))));
    NuiSetBindWatch (oPC, nToken, "txt_max_henchman", TRUE);
    NuiSetBind(oPC, nToken, "txt_max_henchman_tooltip", JsonString("  Set max number of henchman allowed (1-12)."));
    if(nMonsterAI)
    {
        NuiSetBind(oPC, nToken, "txt_ai_difficulty", JsonString(IntToString(GetLocalInt(oModule, AI_RULE_AI_DIFFICULTY))));
        NuiSetBindWatch (oPC, nToken, "txt_ai_difficulty", TRUE);
        NuiSetBind(oPC, nToken, "chbx_buff_monsters_check", JsonBool(GetLocalInt(oModule, AI_RULE_BUFF_MONSTERS)));
        NuiSetBindWatch (oPC, nToken, "chbx_buff_monsters_check", TRUE);
        NuiSetBind(oPC, nToken, "chbx_buff_summons_check", JsonBool(GetLocalInt(oModule, AI_RULE_PRESUMMON)));
        NuiSetBindWatch (oPC, nToken, "chbx_buff_summons_check", TRUE);
        NuiSetBind(oPC, nToken, "chbx_ambush_monsters_check", JsonBool(GetLocalInt(oModule, AI_RULE_AMBUSH)));
        NuiSetBindWatch (oPC, nToken, "chbx_ambush_monsters_check", TRUE);
        NuiSetBind(oPC, nToken, "chbx_companions_check", JsonBool(GetLocalInt(oModule, AI_RULE_SUMMON_COMPANIONS)));
        NuiSetBindWatch (oPC, nToken, "chbx_companions_check", TRUE);
        NuiSetBind(oPC, nToken, "chbx_perm_assoc_check", JsonBool(GetLocalInt(oModule, AI_RULE_PERM_ASSOC)));
        NuiSetBindWatch (oPC, nToken, "chbx_perm_assoc_check", TRUE);
        NuiSetBind(oPC, nToken, "txt_perception_distance", JsonString(FloatToString(GetLocalFloat(oModule, AI_RULE_PERCEPTION_DISTANCE), 0, 0)));
        NuiSetBindWatch (oPC, nToken, "txt_perception_distance", TRUE);
        NuiSetBind(oPC, nToken, "txt_perception_distance_tooltip", JsonString("  Range [10 to 60 meters] from the player."));
        NuiSetBindWatch (oPC, nToken, "lbl_perc_dist", TRUE);
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
        NuiSetBind(oPC, nToken, "chbx_corpses_stay_check", JsonBool(GetLocalInt(oModule, AI_RULE_CORPSES_STAY)));
        NuiSetBindWatch (oPC, nToken, "chbx_corpses_stay_check", TRUE);
        NuiSetBind(oPC, nToken, "chbx_wander_check", JsonBool(GetLocalInt(oModule, AI_RULE_WANDER)));
        NuiSetBindWatch (oPC, nToken, "chbx_wander_check", TRUE);
        NuiSetBind(oPC, nToken, "txt_inc_hp", JsonString(IntToString(GetLocalInt(oModule, AI_INCREASE_MONSTERS_HP))));
        NuiSetBindWatch (oPC, nToken, "txt_inc_hp", TRUE);
    }
    if(nMonsterAI || nAssociateAI)
    {
        NuiSetBind(oPC, nToken, "chbx_moral_check", JsonBool(GetLocalInt(oModule, AI_RULE_MORAL_CHECKS)));
        NuiSetBindWatch (oPC, nToken, "chbx_moral_check", TRUE);
        NuiSetBind(oPC, nToken, "chbx_advanced_movement_check", JsonBool(GetLocalInt(oModule, AI_RULE_ADVANCED_MOVEMENT)));
        NuiSetBindWatch (oPC, nToken, "chbx_advanced_movement_check", TRUE);
        NuiSetBind(oPC, nToken, "chbx_ilr_check", JsonBool(GetLocalInt(oModule, AI_RULE_ILR)));
        NuiSetBindWatch (oPC, nToken, "chbx_ilr_check", TRUE);
        NuiSetBind(oPC, nToken, "chbx_umd_check", JsonBool(GetLocalInt(oModule, AI_RULE_ALLOW_UMD)));
        NuiSetBindWatch (oPC, nToken, "chbx_umd_check", TRUE);
        NuiSetBind(oPC, nToken, "chbx_use_healingkits_check", JsonBool(GetLocalInt(oModule, AI_RULE_HEALERSKITS)));
        NuiSetBindWatch (oPC, nToken, "chbx_use_healingkits_check", TRUE);
    }
}
void ai_CreateDMCommandNUI(object oPC)
{
    // ************************************************************************* Width / Height
    // Row 1 ******************************************************************* 500 / 73
    json jRow = JsonArray();
    CreateButtonSelect(jRow, "Lock Widget", "btn_widget_lock", 200.0, 20.0, "btn_widget_lock_tooltip");
    CreateLabel(jRow, "", "blank_label_1", 25.0, 20.0);
    JsonArrayInsertInplace(jRow, NuiSpacer());
    CreateButton(jRow, "Main Options", "btn_options", 200.0, 20.0, -1.0, "btn_options_tooltip");
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
    // Set the plugins the player can use.
    int nIndex, nButton;
    string sButton;
    json jScript = JsonArrayGet(jDMPlugins, nIndex);
    while(JsonGetType(jScript) != JSON_TYPE_NULL)
    {
        jRow = JsonArray();
        sButton = IntToString(++nButton);
        CreateButton(jRow, JsonGetString(jScript), "btn_plugin_" + sButton, 200.0f, 20.0f, -1.0, "btn_plugin_" + sButton + "_tooltip");
        CreateCheckBox(jRow, "", "chbx_plugin_" + sButton, 25.0, 20.0, "chbx_plugin_tooltip");
        JsonArrayInsertInplace(jRow, NuiSpacer());
        nIndex += 2;
        jScript = JsonArrayGet(jDMPlugins, nIndex);
        if(JsonGetType(jScript) != JSON_TYPE_NULL)
        {
            sButton = IntToString(++nButton);
            CreateButton(jRow, JsonGetString(jScript), "btn_plugin_" + sButton, 200.0f, 20.0f, -1.0, "btn_plugin_" + sButton + "_tooltip");
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
        nIndex += 2;
        jScript = JsonArrayGet(jDMPlugins, nIndex);
    }
    // Row 7 ****************************************************************** 500 / ---
    jRow = JsonArray();
    JsonArrayInsertInplace(jRow, NuiSpacer());
    CreateLabel(jRow, "", "lbl_info_1", 475.0, 20.0, NUI_HALIGN_CENTER);
    JsonArrayInsertInplace(jRow, NuiSpacer());
    JsonArrayInsertInplace(jCol, NuiRow(jRow));
    fHeight = fHeight + 28.0;
    // Set the Layout of the window.
    json jLayout = NuiCol(jCol);
    string sDMName = GetName(oPC);
    if(GetStringRight(sDMName, 1) == "s") sDMName = sDMName + "'";
    else sDMName = sDMName + "'s";
    int nToken = SetWindow(oPC, jLayout, "dm_cmd_menu", sDMName + " Command Menu",
                           -1.0, -1.0, 500.0, fHeight + 12.0, FALSE, FALSE, TRUE, FALSE, TRUE, "0e_nui_dm");
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
    // Set all binds, events, and watches.
    // Row 1
    NuiSetBind(oPC, nToken, "btn_widget_lock_event", JsonBool(TRUE));
    NuiSetBind(oPC, nToken, "btn_widget_lock", JsonBool(bAIWidgetLock));
    NuiSetBind(oPC, nToken, "btn_widget_lock_tooltip", JsonString(
               "  Locks widget to the current location."));
    NuiSetBind(oPC, nToken, "btn_options_event", JsonBool (TRUE));
    NuiSetBind(oPC, nToken, "btn_options", JsonInt(TRUE));
    NuiSetBind(oPC, nToken, "btn_options_tooltip", JsonString("  Additional options"));
    NuiSetBind(oPC, nToken, "btn_group_options_event", JsonBool (TRUE));
    NuiSetBind(oPC, nToken, "btn_group_options", JsonInt(TRUE));
    //NuiSetBind(oPC, nToken, "btn_empty_button_event", JsonBool (TRUE));
    //NuiSetBind(oPC, nToken, "btn_empty_button", JsonInt(TRUE));
    //sText = "  Copy AI and command settings for one creature to others.";
    //NuiSetBind(oPC, nToken, "btn_empty_button_tooltip", JsonString(sText));
    // Row 2
    NuiSetBind(oPC, nToken, "chbx_cmd_group1_check", JsonBool (bCmdGroup1));
    NuiSetBindWatch (oPC, nToken, "chbx_cmd_group1_check", TRUE);
    NuiSetBind(oPC, nToken, "btn_cmd_group1_event", JsonBool (TRUE));
    string sText;
    string sUUID = JsonGetString(JsonArrayGet(GetLocalJson(oPC, "DM_GROUP1"), 0));
    if(sUUID == "") sText = "Group1";
    else sText = GetName(GetObjectByUUID(sUUID)) + "'s group";
    NuiSetBind(oPC, nToken, "btn_cmd_group1_label", JsonString(sText));
    NuiSetBind(oPC, nToken, "btn_cmd_group1_tooltip", JsonString("  " + sText + " (Left Action/Right Add)"));
    NuiSetBind(oPC, nToken, "chbx_cmd_group2_check", JsonBool (bCmdGroup2));
    NuiSetBindWatch (oPC, nToken, "chbx_cmd_group2_check", TRUE);
    NuiSetBind(oPC, nToken, "btn_cmd_group2_event", JsonBool (TRUE));
    sUUID = JsonGetString(JsonArrayGet(GetLocalJson(oPC, "DM_GROUP2"), 0));
    if(sUUID == "") sText = "Group2";
    else sText = GetName(GetObjectByUUID(sUUID)) + "'s group";
    NuiSetBind(oPC, nToken, "btn_cmd_group2_label", JsonString(sText));
    NuiSetBind(oPC, nToken, "btn_cmd_group2_tooltip", JsonString("  " + sText + " (Left Action/Right Add)"));
    // Row 3
    NuiSetBind(oPC, nToken, "chbx_cmd_group3_check", JsonBool (bCmdGroup3));
    NuiSetBindWatch (oPC, nToken, "chbx_cmd_group3_check", TRUE);
    NuiSetBind(oPC, nToken, "btn_cmd_group3_event", JsonBool (TRUE));
    sUUID = JsonGetString(JsonArrayGet(GetLocalJson(oPC, "DM_GROUP3"), 0));
    if(sUUID == "") sText = "Group3";
    else sText = GetName(GetObjectByUUID(sUUID)) + "'s group";
    NuiSetBind(oPC, nToken, "btn_cmd_group3_label", JsonString(sText));
    NuiSetBind(oPC, nToken, "btn_cmd_group3_tooltip", JsonString("  " + sText + " (Left Action/Right Add)"));
    NuiSetBind(oPC, nToken, "chbx_cmd_group4_check", JsonBool (bCmdGroup4));
    NuiSetBindWatch (oPC, nToken, "chbx_cmd_group4_check", TRUE);
    NuiSetBind(oPC, nToken, "btn_cmd_group4_label", JsonString(sText));
    NuiSetBind(oPC, nToken, "btn_cmd_group4_event", JsonBool (TRUE));
    sUUID = JsonGetString(JsonArrayGet(GetLocalJson(oPC, "DM_GROUP4"), 0));
    if(sUUID == "") sText = "Group4";
    else sText = GetName(GetObjectByUUID(sUUID)) + "'s group";
    NuiSetBind(oPC, nToken, "btn_cmd_group4_tooltip", JsonString("  " + sText + " (Left Action/Right Add)"));
    // Row 4
    NuiSetBind(oPC, nToken, "chbx_cmd_group5_check", JsonBool (bCmdGroup5));
    NuiSetBindWatch (oPC, nToken, "chbx_cmd_group5_check", TRUE);
    NuiSetBind(oPC, nToken, "btn_cmd_group5_label", JsonString(sText));
    NuiSetBind(oPC, nToken, "btn_cmd_group5_event", JsonBool (TRUE));
    sUUID = JsonGetString(JsonArrayGet(GetLocalJson(oPC, "DM_GROUP5"), 0));
    if(sUUID == "") sText = "Group5";
    else sText = GetName(GetObjectByUUID(sUUID)) + "'s group";
    NuiSetBind(oPC, nToken, "btn_cmd_group5_tooltip", JsonString("  " + sText + " (Left Action/Right Add)"));
    NuiSetBind(oPC, nToken, "chbx_cmd_group6_check", JsonBool (bCmdGroup6));
    NuiSetBindWatch (oPC, nToken, "chbx_cmd_group6_check", TRUE);
    NuiSetBind(oPC, nToken, "btn_cmd_group6_event", JsonBool (TRUE));
    sUUID = JsonGetString(JsonArrayGet(GetLocalJson(oPC, "DM_GROUP6"), 0));
    if(sUUID == "") sText = "Group6";
    else sText = GetName(GetObjectByUUID(sUUID)) + "'s group";
    NuiSetBind(oPC, nToken, "btn_cmd_group6_label", JsonString(sText));
    NuiSetBind(oPC, nToken, "btn_cmd_group6_tooltip", JsonString("  " + sText + " (Left Action/Right Add)"));
    // Row 5
    NuiSetBind(oPC, nToken, "chbx_camera_check", JsonBool (bCmdCamera));
    NuiSetBindWatch (oPC, nToken, "chbx_camera_check", TRUE);
    NuiSetBind(oPC, nToken, "btn_camera_event", JsonBool (TRUE));
    NuiSetBind(oPC, nToken, "btn_camera_tooltip", JsonString (
               "  Toggle camera view for " + sDMName));
    NuiSetBind(oPC, nToken, "chbx_inventory_check", JsonBool (bCmdInventory));
    NuiSetBindWatch (oPC, nToken, "chbx_inventory_check", TRUE);
    NuiSetBind(oPC, nToken, "btn_inventory_event", JsonBool (TRUE));
    NuiSetBind(oPC, nToken, "btn_inventory_tooltip", JsonString (
               "  Open " + sDMName + " inventory"));
    // Row 6+
    nIndex = 0;
    nButton = 0;
    int bWidget;
    jScript = JsonArrayGet(jDMPlugins, nIndex);
    while(JsonGetType(jScript) != JSON_TYPE_NULL)
    {
        sText = JsonGetString(jScript);
        sButton = IntToString(++nButton);
        NuiSetBind(oPC, nToken, "btn_plugin_" + sButton + "_event", JsonBool(TRUE));
        bWidget = JsonGetInt(JsonArrayGet(jDMPlugins, nIndex + 1));
        NuiSetBind(oPC, nToken, "chbx_plugin_" + sButton + "_check", JsonBool(bWidget));
        NuiSetBindWatch (oPC, nToken, "chbx_plugin_" + sButton + "_check", TRUE);
        sText = "  Execute script: " + sText;
        NuiSetBind(oPC, nToken, "btn_plugin_" + sButton + "_tooltip", JsonString(sText));
        jScript = JsonArrayGet(jDMPlugins, ++nIndex);
    }
    NuiSetBind(oPC, nToken, "chbx_plugin_tooltip", JsonString("  Adds the plugin to your widget."));
    // Row 7
    sText = ai_GetRandomDMTip();
    NuiSetBind(oPC, nToken, "lbl_info_1_label", JsonString(sText));
}
void ai_CreateDMPluginNUI(object oPC)
{
    int nIndex, nButton;
    string sButton;
    json jRow = JsonArray();
    json jCol = JsonArray();
    // Row 2 ******************************************************************* 500 / 73
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
    string sName = ai_RemoveIllegalCharacters(GetName(oPC));
    json jPlugins = ai_GetCampaignDbJson("plugins");
    json jScript = JsonArrayGet(jPlugins, nIndex);
    while(JsonGetType(jScript) != JSON_TYPE_NULL)
    {
        jRow = JsonArray();
        sButton = IntToString(++nButton);
        JsonArrayInsertInplace(jRow, NuiSpacer());
        CreateButton(jRow, "Remove Plugin", "btn_remove_plugin_" + sButton, 105.0f, 20.0f);
        JsonArrayInsertInplace(jRow, NuiSpacer());
        CreateButton(jRow, JsonGetString(jScript), "btn_plugin_" + sButton, 290.0f, 20.0f, -1.0, "btn_plugin_" + sButton + "_tooltip");
        CreateCheckBox(jRow, "Allow", "chbx_plugin_" + sButton, 65.0, 20.0, "chbx_plugin_tooltip");
        JsonArrayInsertInplace(jRow, NuiSpacer());
        // Add row to the column.
        JsonArrayInsertInplace(jCol, NuiRow(jRow));
        fHeight += 28.0;
        nIndex += 2;
        jScript = JsonArrayGet(jPlugins, nIndex);
    }
    // Set the Layout of the window.
    json jLayout = NuiCol(jCol);
    sName = GetName(oPC);
    if(GetStringRight(sName, 1) == "s") sName = sName + "'";
    else sName = sName + "'s";
    int nToken = SetWindow(oPC, jLayout, "dm_plugin_nui", sName + " PEPS Plugin Manager",
                             -1.0, -1.0, 500.0f, fHeight + 12.0f, FALSE, FALSE, TRUE, FALSE, TRUE, "0e_nui_dm");
    // Row 1
    NuiSetBind(oPC, nToken, "btn_load_plugins_event", JsonBool(TRUE));
    NuiSetBind(oPC, nToken, "btn_load_plugins_tooltip", JsonString("  Load all known PEPS plugins that are in the game files."));
    NuiSetBind(oPC, nToken, "btn_check_plugins_event", JsonBool(TRUE));
    NuiSetBind(oPC, nToken, "btn_check_plugins_tooltip", JsonString("  Add all plugins to be allowed for players widget."));
    NuiSetBind(oPC, nToken, "btn_clear_plugins_event", JsonBool(TRUE));
    NuiSetBind(oPC, nToken, "btn_clear_plugins_tooltip", JsonString("  Remove all plugins to be allowed for players widget."));
    // Row 2
    NuiSetBind(oPC, nToken, "btn_add_plugin_event", JsonBool(TRUE));
    NuiSetBind(oPC, nToken, "txt_plugin_event", JsonBool(TRUE));
    NuiSetBind(oPC, nToken, "txt_plugin_tooltip", JsonString("  Enter an executable script name."));
    // Row 3+
    nIndex = 0;
    nButton = 0;
    string sText;
    jScript = JsonArrayGet(jPlugins, nIndex);
    while(JsonGetType(jScript) != JSON_TYPE_NULL)
    {
        sText = JsonGetString(jScript);
        sButton = IntToString(++nButton);
        NuiSetBind(oPC, nToken, "btn_remove_plugin_" + sButton + "_event", JsonBool(TRUE));
        NuiSetBind(oPC, nToken, "btn_plugin_" + sButton + "_event", JsonBool(TRUE));
        jScript = JsonArrayGet(jPlugins, ++nIndex);
        NuiSetBind(oPC, nToken, "chbx_plugin_" + sButton + "_check", JsonBool(JsonGetInt(jScript)));
        NuiSetBindWatch (oPC, nToken, "chbx_plugin_" + sButton + "_check", TRUE);
        sText = "  Execute script: " + sText;
        NuiSetBind(oPC, nToken, "btn_plugin_" + sButton + "_tooltip", JsonString(sText));
        jScript = JsonArrayGet(jPlugins, ++nIndex);
    }
    NuiSetBind(oPC, nToken, "chbx_plugin_tooltip", JsonString("  Allows players to use this plugin."));
}

