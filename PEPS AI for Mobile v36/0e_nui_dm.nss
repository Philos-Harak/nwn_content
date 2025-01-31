/*//////////////////////////////////////////////////////////////////////////////
 Script Name: 0e_nui_dm
 Programmer: Philos
////////////////////////////////////////////////////////////////////////////////
 Menu event script
    sEvent: close, click, mousedown, mouseup, watch (if bindwatch is set).
/*//////////////////////////////////////////////////////////////////////////////
#include "0i_menus_dm"
void ai_SetDMWidgetButtonToCheckbox(object oPC, int nButton, int nToken, string sElem);
void ai_RulePercDistInc(object oPC, object oModule, int nIncrement, int nToken);
// Adds a selected creature to the group.
void ai_AddToGroup(object oPC, int nGroup);
// Does a selected action for nGroup.
void ai_DMSelectAction(object oPC, int nGroup);
void main()
{
    object oPC = NuiGetEventPlayer();
    int nToken  = NuiGetEventWindow();
    string sEvent = NuiGetEventType();
    string sElem  = NuiGetEventElement();
    int nIndex = NuiGetEventArrayIndex();
    string sWndId = NuiGetWindowId(oPC, nToken);
    //if(AI_DEBUG) ai_Debug ("0e_nui", "58", "sWndId: " + sWndId + " sEvent: " + sEvent + " sElem: " + sElem +
    //             " nToken: " + IntToString(nToken) + " oPC: " + GetName(oPC));
    //**************************************************************************
    string sName = ai_RemoveIllegalCharacters(GetName(oPC));
    // Watch to see if the window moves and save.
    if(sElem == "window_geometry" && sEvent == "watch")
    {
        if(GetLocalInt(oPC, AI_NO_NUI_SAVE)) return;
        json jGeometry = NuiGetBind(oPC, nToken, "window_geometry");
        float fX = JsonGetFloat(JsonObjectGet(jGeometry, "x"));
        float fY = JsonGetFloat(JsonObjectGet(jGeometry, "y"));
        string sNUI;
        if(sWndId == "dm" + AI_WIDGET_NUI) sNUI = AI_WIDGET_NUI;
        else if(sWndId == AI_MAIN_NUI) sNUI = AI_MAIN_NUI;
        else if(sWndId == AI_PLUGIN_NUI) sNUI = AI_PLUGIN_NUI;
        json jLocations = ai_GetCampaignDbJson("locations", sName, AI_DM_TABLE);
        json jNUI = JsonObjectGet(jLocations, sNUI);
        if(JsonGetType(jNUI) == JSON_TYPE_NULL) jNUI = JsonObject();
        jNUI = JsonObjectSet(jNUI, "x", JsonFloat(fX));
        jNUI = JsonObjectSet(jNUI, "y", JsonFloat(fY));
        jLocations = JsonObjectSet(jLocations, sNUI, jNUI);
        ai_SetCampaignDbJson("locations", jLocations, sName, AI_DM_TABLE);
    }
    if(sWndId == "dm" + AI_WIDGET_NUI)
    {
        // Watch to see if the window moves and save.
        if(sElem == "window_geometry" && sEvent == "watch")
        {
            if(GetLocalInt(oPC, AI_NO_NUI_SAVE)) return;
            json jGeometry = NuiGetBind(oPC, nToken, "window_geometry");
            ai_SetCampaignDbJson("location", jGeometry, sName, AI_DM_TABLE);
        }
    }
    //**************************************************************************
    // Widget events.
    if(sWndId == "dm" + AI_WIDGET_NUI)
    {
        //if(GetLocalInt(oPC, AI_NO_NUI_SAVE)) return;
        if(sEvent == "click")
        {
            if(sElem == "btn_open_main")
            {
                if(IsWindowClosed(oPC, "dm" + AI_COMMAND_NUI)) ai_CreateDMCommandNUI(oPC);
                IsWindowClosed(oPC, "dm" + AI_MAIN_NUI);
            }
            else if(sElem == "btn_camera") ai_SelectCameraView(oPC);
            else if(sElem == "btn_inventory") ai_SelectOpenInventory(oPC);
            else if(GetStringLeft(sElem, 13) == "btn_cmd_group")
            {
                ai_DMSelectAction(oPC, StringToInt(GetStringRight(sElem, 1)));
            }
            else if(GetStringLeft(sElem, 15) == "btn_exe_plugin_") ai_Plugin_Execute(oPC, sElem, TRUE);
        }
        if(sEvent == "mousedown")
        {
            int nMouseButton = JsonGetInt(JsonObjectGet(NuiGetEventPayload(), "mouse_btn"));
            if(nMouseButton == NUI_MOUSE_BUTTON_RIGHT)
            {
                if(sElem == "btn_open_main")
                {
                    if(IsWindowClosed(oPC, "dm" + AI_MAIN_NUI)) ai_CreateDMOptionsNUI(oPC);
                }
                else if(GetStringLeft(sElem, 13) == "btn_cmd_group")
                {
                    ai_AddToGroup(oPC, StringToInt(GetStringRight(sElem, 1)));
                }
            }
        }
    }
    else if(sWndId == "dm" + AI_COMMAND_NUI)
    {
        if(sEvent == "click")
        {
            if(sElem == "btn_widget_lock")
            {
                if(ai_GetDMWidgetButton(oPC, BTN_DM_WIDGET_LOCK))
                {
                    ai_SendMessages(GetName(oPC) + " AI widget unlocked.", AI_COLOR_YELLOW, oPC);
                    ai_SetDMWidgetButton(oPC, BTN_DM_WIDGET_LOCK, FALSE);
                }
                else
                {
                    // Get the height, width, x, and y of the window.
                    json jGeom = NuiGetBind(oPC, NuiFindWindow(oPC, "dm" + AI_WIDGET_NUI), "window_geometry");
                    // Save the window location on the player using the sWndId.
                    SetLocalFloat(oPC, sWndId + "_X", JsonGetFloat (JsonObjectGet (jGeom, "x")));
                    SetLocalFloat(oPC, sWndId + "_Y", JsonGetFloat (JsonObjectGet (jGeom, "y")));
                    ai_SendMessages(GetName(oPC) + " AI widget locked.", AI_COLOR_YELLOW, oPC);
                    ai_SetDMWidgetButton(oPC, BTN_DM_WIDGET_LOCK, TRUE);
                }
                NuiDestroy(oPC, NuiFindWindow(oPC, "dm" + AI_WIDGET_NUI));
                ai_CreateDMWidgetNUI(oPC);
            }
            else if(sElem == "btn_options")
            {
                NuiDestroy(oPC, nToken);
                ai_CreateDMOptionsNUI(oPC);
            }
            else if(sElem == "btn_camera") ai_SelectCameraView(oPC);
            else if(sElem == "btn_inventory") ai_SelectOpenInventory(oPC);
            else if(GetStringLeft(sElem, 13) == "btn_cmd_group")
            {
                ai_DMSelectAction(oPC, StringToInt(GetStringRight(sElem, 1)));
            }
            else if(GetStringLeft(sElem, 11) == "btn_plugin_") ai_Plugin_Execute(oPC, sElem, 1);
        }
        else if(sEvent == "watch")
        {
            if(sElem == "chbx_cmd_group1_check") ai_SetDMWidgetButtonToCheckbox(oPC, BTN_DM_CMD_GROUP1, nToken, sElem);
            else if(sElem == "chbx_cmd_group2_check") ai_SetDMWidgetButtonToCheckbox(oPC, BTN_DM_CMD_GROUP2, nToken, sElem);
            else if(sElem == "chbx_cmd_group3_check") ai_SetDMWidgetButtonToCheckbox(oPC, BTN_DM_CMD_GROUP3, nToken, sElem);
            else if(sElem == "chbx_cmd_group4_check") ai_SetDMWidgetButtonToCheckbox(oPC, BTN_DM_CMD_GROUP4, nToken, sElem);
            else if(sElem == "chbx_cmd_group5_check") ai_SetDMWidgetButtonToCheckbox(oPC, BTN_DM_CMD_GROUP5, nToken, sElem);
            else if(sElem == "chbx_cmd_group6_check") ai_SetDMWidgetButtonToCheckbox(oPC, BTN_DM_CMD_GROUP6, nToken, sElem);
            else if(sElem == "chbx_camera_check") ai_SetDMWidgetButtonToCheckbox(oPC, BTN_DM_CMD_CAMERA, nToken, sElem);
            else if(sElem == "chbx_inventory_check") ai_SetDMWidgetButtonToCheckbox(oPC, BTN_DM_CMD_INVENTORY, nToken, sElem);
            if(GetStringLeft(sElem, 12) == "chbx_plugin_" && GetStringRight(sElem, 6) == "_check")
            {
                string sName = ai_RemoveIllegalCharacters(GetName(oPC));
                json jPlugins = ai_GetCampaignDbJson("plugins", sName, AI_DM_TABLE);
                int nIndex = ((StringToInt(GetSubString(sElem, 12, 1))- 1) * 2) + 1;
                int bCheck = JsonGetInt(NuiGetBind(oPC, nToken, sElem));
                JsonArraySetInplace(jPlugins, nIndex, JsonBool(bCheck));
                ai_SetCampaignDbJson("plugins", jPlugins, sName, AI_DM_TABLE);
            }
            NuiDestroy(oPC, NuiFindWindow(oPC, "dm" + AI_WIDGET_NUI));
            ai_CreateDMWidgetNUI(oPC);
        }
        if(sEvent == "mousedown")
        {
            int nMouseButton = JsonGetInt(JsonObjectGet(NuiGetEventPayload(), "mouse_btn"));
            if(nMouseButton == NUI_MOUSE_BUTTON_RIGHT)
            {
                if(GetStringLeft(sElem, 13) == "btn_cmd_group")
                {
                    ai_AddToGroup(oPC, StringToInt(GetStringRight(sElem, 1)));
                }
            }
        }
        else if(sEvent == "mousescroll")
        {
            float nMouseScroll = JsonGetFloat(JsonObjectGet(JsonObjectGet(NuiGetEventPayload(), "mouse_scroll"), "y"));
            if(nMouseScroll == 1.0) // Scroll up
            {
            }
            else if(nMouseScroll == -1.0) // Scroll down
            {
            }
        }
    }
    //**************************************************************************
    // Main AI events.
    if(sWndId == "dm_main_nui")
    {
        if(sEvent == "click")
        {
            if(sElem == "btn_plugin_manager")
            {
                NuiDestroy(oPC, nToken);
                ai_CreateDMPluginNUI(oPC);
            }
        }
        if(sEvent == "watch")
        {
            if(sElem == "txt_max_henchman")
            {
                int nMaxHenchmen = StringToInt(JsonGetString(NuiGetBind(oPC, nToken, sElem)));
                if(nMaxHenchmen < 1) nMaxHenchmen = 1;
                if(nMaxHenchmen > 12)
                {
                    nMaxHenchmen = 12;
                    ai_SendMessages("The maximum henchmen for this mod is 12!", AI_COLOR_RED, oPC);
                }
                SetMaxHenchmen(nMaxHenchmen);
                json jRules = ai_GetCampaignDbJson("rules");
                JsonObjectSetInplace(jRules, AI_RULE_MAX_HENCHMAN, JsonInt(nMaxHenchmen));
                ai_SetCampaignDbJson("rules", jRules);
                ai_SendMessages("Maximum henchmen has been changed to " + IntToString(nMaxHenchmen), AI_COLOR_YELLOW, oPC);
            }
            else if(sElem == "txt_ai_difficulty")
            {
                int nChance = StringToInt(JsonGetString(NuiGetBind(oPC, nToken, sElem)));
                if(nChance < 0) nChance = 0;
                else if(nChance > 100) nChance = 100;
                SetLocalInt(GetModule(), AI_RULE_AI_DIFFICULTY, nChance);
                json jRules = ai_GetCampaignDbJson("rules");
                JsonObjectSetInplace(jRules, AI_RULE_AI_DIFFICULTY, JsonInt(nChance));
                ai_SetCampaignDbJson("rules", jRules);
            }
            else if(sElem == "txt_perception_distance")
            {
                float fDistance = StringToFloat(JsonGetString(NuiGetBind(oPC, nToken, sElem)));
                if(fDistance < 10.0) fDistance = 10.0;
                else if(fDistance > 60.0) fDistance = 60.0;
                SetLocalFloat(GetModule(), AI_RULE_PERCEPTION_DISTANCE, fDistance);
                json jRules = ai_GetCampaignDbJson("rules");
                JsonObjectSetInplace(jRules, AI_RULE_PERCEPTION_DISTANCE, JsonFloat(fDistance));
                ai_SetCampaignDbJson("rules", jRules);
            }
            else if(sElem == "txt_inc_hp")
            {
                int nNumber = StringToInt(JsonGetString(NuiGetBind(oPC, nToken, sElem)));
                if(nNumber < 0) nNumber = 0;
                else if(nNumber > 100) nNumber = 100;
                SetLocalInt(GetModule(), AI_INCREASE_MONSTERS_HP, nNumber);
                json jRules = ai_GetCampaignDbJson("rules");
                JsonObjectSetInplace(jRules, AI_INCREASE_MONSTERS_HP, JsonInt(nNumber));
                ai_SetCampaignDbJson("rules", jRules);
            }
            else if(GetStringLeft(sElem, 4) == "chbx")
            {
                object oModule = GetModule();
                int bCheck = JsonGetInt(NuiGetBind(oPC, nToken, sElem));
                json jRules = ai_GetCampaignDbJson("rules");
                if(sElem == "chbx_moral_check")
                {
                    SetLocalInt(oModule, AI_RULE_MORAL_CHECKS, bCheck);
                    JsonObjectSetInplace(jRules, AI_RULE_MORAL_CHECKS, JsonInt(bCheck));
                }
                else if(sElem == "chbx_buff_monsters_check")
                {
                    SetLocalInt(oModule, AI_RULE_BUFF_MONSTERS, bCheck);
                    JsonObjectSetInplace(jRules, AI_RULE_BUFF_MONSTERS, JsonInt(bCheck));
                }
                else if(sElem == "chbx_buff_summons_check")
                {
                    SetLocalInt(oModule, AI_RULE_PRESUMMON, bCheck);
                    JsonObjectSetInplace(jRules, AI_RULE_PRESUMMON, JsonInt(bCheck));
                }
                else if(sElem == "chbx_ambush_monsters_check")
                {
                    SetLocalInt(oModule, AI_RULE_AMBUSH, bCheck);
                    JsonObjectSetInplace(jRules, AI_RULE_AMBUSH, JsonInt(bCheck));
                }
                else if(sElem == "chbx_companions_check")
                {
                    SetLocalInt(oModule, AI_RULE_SUMMON_COMPANIONS, bCheck);
                    JsonObjectSetInplace(jRules, AI_RULE_SUMMON_COMPANIONS, JsonInt(bCheck));
                }
                else if(sElem == "chbx_advanced_movement_check")
                {
                    SetLocalInt(oModule, AI_RULE_ADVANCED_MOVEMENT, bCheck);
                    JsonObjectSetInplace(jRules, AI_RULE_ADVANCED_MOVEMENT, JsonInt(bCheck));
                }
                else if(sElem == "chbx_ilr_check")
                {
                    SetLocalInt(oModule, AI_RULE_ILR, bCheck);
                    JsonObjectSetInplace(jRules, AI_RULE_ILR, JsonInt(bCheck));
                }
                else if(sElem == "chbx_umd_check")
                {
                    SetLocalInt(oModule, AI_RULE_ALLOW_UMD, bCheck);
                    JsonObjectSetInplace(jRules, AI_RULE_ALLOW_UMD, JsonInt(bCheck));
                }
                else if(sElem == "chbx_use_healingkits_check")
                {
                    SetLocalInt(oModule, AI_RULE_HEALERSKITS, bCheck);
                    JsonObjectSetInplace(jRules, AI_RULE_HEALERSKITS, JsonInt(bCheck));
                }
                else if(sElem == "chbx_perm_assoc_check")
                {
                    SetLocalInt(oModule, AI_RULE_PERM_ASSOC, bCheck);
                    JsonObjectSetInplace(jRules, AI_RULE_PERM_ASSOC, JsonInt(bCheck));
                }
                else if(sElem == "chbx_corpses_stay_check")
                {
                    SetLocalInt(oModule, AI_RULE_CORPSES_STAY, bCheck);
                    JsonObjectSetInplace(jRules, AI_RULE_CORPSES_STAY, JsonInt(bCheck));
                }
                else if(sElem == "chbx_wander_check")
                {
                    SetLocalInt(oModule, AI_RULE_WANDER, bCheck);
                    JsonObjectSetInplace(jRules, AI_RULE_CORPSES_STAY, JsonInt(bCheck));
                }
                ai_SetCampaignDbJson("rules", jRules);
            }
        }
        else if(sEvent == "mousescroll")
        {
            float nMouseScroll = JsonGetFloat(JsonObjectGet(JsonObjectGet(NuiGetEventPayload(), "mouse_scroll"), "y"));
            if(nMouseScroll == 1.0) // Scroll up
            {
                // Follow range is only changed on non-pc's
                if(sElem == "lbl_perc_dist") ai_RulePercDistInc(oPC, GetModule(), 1, nToken);
            }
            else if(nMouseScroll == -1.0) // Scroll down
            {
                // Follow range is only changed on non-pc's
                if(sElem == "lbl_perc_dist") ai_RulePercDistInc(oPC, GetModule(), -1, nToken);
            }
        }
    }
    //**************************************************************************
    // Plugins events.
    if(sWndId == "dm_plugin_nui")
    {
        string sName = ai_RemoveIllegalCharacters(GetName(oPC));
        json jPlugins = ai_GetCampaignDbJson("plugins");
        if(sEvent == "click")
        {
            if(sElem == "btn_load_plugins")
            {
                string sScript = JsonGetString(NuiGetBind (oPC, nToken, "txt_plugin"));
                if(JsonGetType(JsonArrayGet(jPlugins, 0)) == JSON_TYPE_NULL) jPlugins = JsonArray();
                ai_Plugin_Add(oPC, jPlugins, "pi_buffing");
                ai_Plugin_Add(oPC, jPlugins, "pi_debug");
                ai_Plugin_Add(oPC, jPlugins, "pi_test");
                ai_SetCampaignDbJson("plugins", jPlugins);
                NuiDestroy(oPC, nToken);
                ai_CreateDMPluginNUI(oPC);
                NuiDestroy(oPC, NuiFindWindow(oPC, "dm" + AI_WIDGET_NUI));
                ai_CreateDMWidgetNUI(oPC);
            }
            if(sElem == "btn_check_plugins")
            {
                int nIndex = 1;
                json jCheck = JsonArrayGet(jPlugins, nIndex);
                while(JsonGetType(jCheck) != JSON_TYPE_NULL)
                {
                    JsonArraySetInplace(jPlugins, nIndex, JsonBool(TRUE));
                    nIndex += 2;
                    jCheck = JsonArrayGet(jPlugins, nIndex);
                }
                ai_SetCampaignDbJson("plugins", jPlugins);
                NuiDestroy(oPC, nToken);
                ai_CreateDMPluginNUI(oPC);
                NuiDestroy(oPC, NuiFindWindow(oPC, "dm" + AI_WIDGET_NUI));
                ai_CreateDMWidgetNUI(oPC);
            }
            if(sElem == "btn_clear_plugins")
            {
                int nIndex = 1;
                json jCheck = JsonArrayGet(jPlugins, nIndex);
                while(JsonGetType(jCheck) != JSON_TYPE_NULL)
                {
                    JsonArraySetInplace(jPlugins, nIndex, JsonBool(FALSE));
                    nIndex += 2;
                    jCheck = JsonArrayGet(jPlugins, nIndex);
                }
                ai_SetCampaignDbJson("plugins", jPlugins);
                NuiDestroy(oPC, nToken);
                ai_CreateDMPluginNUI(oPC);
                NuiDestroy(oPC, NuiFindWindow(oPC, "dm" + AI_WIDGET_NUI));
                ai_CreateDMWidgetNUI(oPC);
            }
            else if(sElem == "btn_add_plugin")
            {
                string sScript = JsonGetString(NuiGetBind (oPC, nToken, "txt_plugin"));
                if(JsonGetType(JsonArrayGet(jPlugins, 0)) == JSON_TYPE_NULL) jPlugins = JsonArray();
                ai_Plugin_Add(oPC, jPlugins, sScript);
                ai_SetCampaignDbJson("plugins", jPlugins);
                NuiDestroy(oPC, nToken);
                ai_CreateDMPluginNUI(oPC);
            }
            else if(GetStringLeft(sElem, 18) == "btn_remove_plugin_")
            {
                int nIndex = (StringToInt(GetStringRight(sElem, 1)) - 1) * 2;
                JsonArrayDelInplace(jPlugins, nIndex + 1);
                JsonArrayDelInplace(jPlugins, nIndex);
                ai_SetCampaignDbJson("plugins", jPlugins);
                NuiDestroy(oPC, nToken);
                ai_CreateDMPluginNUI(oPC);
                NuiDestroy(oPC, NuiFindWindow(oPC, "dm" + AI_WIDGET_NUI));
                ai_CreateDMWidgetNUI(oPC);
            }
            else if(GetStringLeft(sElem, 11) == "btn_plugin_") ai_Plugin_Execute(oPC, sElem, 2);
        }
        else if(sEvent == "watch")
        {
            if(GetStringLeft(sElem, 12) == "chbx_plugin_" && GetStringRight(sElem, 6) == "_check")
            {
                int nIndex = ((StringToInt(GetSubString(sElem, 12, 1))- 1) * 2) + 1;
                int bCheck = JsonGetInt(NuiGetBind(oPC, nToken, sElem));
                JsonArraySetInplace(jPlugins, nIndex, JsonBool(bCheck));
                ai_SetCampaignDbJson("plugins", jPlugins);
                NuiDestroy(oPC, NuiFindWindow(oPC, "dm" + AI_WIDGET_NUI));
                ai_CreateDMWidgetNUI(oPC);
            }
        }
    }
}
void ai_SetDMWidgetButtonToCheckbox(object oPC, int nButton, int nToken, string sElem)
{
    int bCheck = JsonGetInt(NuiGetBind(oPC, nToken, sElem));
    ai_SetDMWidgetButton(oPC, nButton, bCheck);
}
void ai_RulePercDistInc(object oPC, object oModule, int nIncrement, int nToken)
{
    int nAdjustment = GetLocalInt(oModule, AI_RULE_MON_PERC_DISTANCE) + nIncrement;
    if(nAdjustment < 8 || nAdjustment > 11) return;
    SetLocalInt(oModule, AI_RULE_MON_PERC_DISTANCE, nAdjustment);
    string sText;
    if(nAdjustment == 8) sText = " Monster perception: Short [10 Sight / 10 Listen]";
    else if(nAdjustment == 9) sText = " Monster perception: Medium [20 Sight / 20 Listen]";
    else if(nAdjustment == 10) sText = " Monster perception: Long [35 Sight / 20 Listen]";
    else sText = " Monster perception: Default [Monster's default values]";
    NuiSetBind(oPC, nToken, "lbl_perc_dist_label", JsonString(sText));
    json jRules = ai_GetCampaignDbJson("rules");
    JsonObjectSetInplace(jRules, AI_RULE_MON_PERC_DISTANCE, JsonInt(nAdjustment));
    ai_SetCampaignDbJson("rules", jRules);
}
void ai_AddToGroup(object oPC, int nGroup)
{
    string sGroup = IntToString(nGroup);
    SetLocalString(oPC, AI_TARGET_MODE, "DM_SELECT_GROUP" + sGroup);
    ai_SendMessages("Select a creature to add to group " + sGroup + ". Selecting yourself will clear group1.", AI_COLOR_YELLOW, oPC);
    EnterTargetingMode(oPC, OBJECT_TYPE_CREATURE, MOUSECURSOR_PICKUP, MOUSECURSOR_PICKUP_DOWN);
}
void ai_DMSelectAction(object oPC, int nGroup)
{
    string sGroup = IntToString(nGroup);
    SetLocalString(oPC, AI_TARGET_MODE, "DM_ACTION_GROUP" + sGroup);
    ai_SendMessages(GetName(oPC) + " select an action for group" + sGroup + ".", AI_COLOR_YELLOW, oPC);
    EnterTargetingMode(oPC, OBJECT_TYPE_ALL, MOUSECURSOR_ACTION, MOUSECURSOR_NOWALK);
}

