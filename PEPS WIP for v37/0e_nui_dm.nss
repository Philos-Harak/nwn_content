/*//////////////////////////////////////////////////////////////////////////////
 Script Name: 0e_nui_dm
 Programmer: Philos
////////////////////////////////////////////////////////////////////////////////
 Menu event script
    sEvent: close, click, mousedown, mouseup, watch (if bindwatch is set).
/*//////////////////////////////////////////////////////////////////////////////
#include "0i_menus"
#include "0i_menus_dm"
void ai_SetDMWidgetButtonToCheckbox(object oDM, int nButton, int nToken, string sElem);
void ai_SetDMWAccessButtonToCheckbox(object oDM, int nButton, int nToken, string sElem);
void ai_SetDMAIAccessButtonToCheckbox(object oDM, int nButton, int nToken, string sElem);
void ai_SetDMAIAccessButtonToCheckbox(object oDM, int nButton, int nToken, string sElem);
void ai_RulePercDistInc(object oDM, object oModule, int nIncrement, int nToken);
// Adds a spell to a json AI restricted spell list then returns jRules.
// bRestrict = TRUE will add to the list FALSE will remove it from the list.
json ai_AddRestrictedSpell(json jRules, int nSpell, int bRestrict = TRUE);
// Adds a selected creature to the group.
void ai_SelectToGroup(object oDM, string sElem);
// Does a selected action for nGroup.
void ai_DMSelectAction(object oDM, string sElem);
// Changes if the group will run (nSpeed: 1) or walk (nSpeed: 0).
void ai_DMChangeMoveSpeed(object oDM, string sElem, int nSpeed);
void main()
{
    object oDM = NuiGetEventPlayer();
    int nToken  = NuiGetEventWindow();
    string sEvent = NuiGetEventType();
    string sElem  = NuiGetEventElement();
    int nIndex = NuiGetEventArrayIndex();
    string sWndId = NuiGetWindowId(oDM, nToken);
    //if(AI_DEBUG) ai_Debug ("0e_nui", "58", "sWndId: " + sWndId + " sEvent: " + sEvent + " sElem: " + sElem +
    //             " nToken: " + IntToString(nToken) + " oPC: " + GetName(oPC));
    //WriteTimestampedLogEntry("0e_nui, 58, sWndId: " + sWndId + " sEvent: " + sEvent + " sElem: " + sElem +
    //             " nToken: " + IntToString(nToken) + " oDM: " + GetName(oDM));
    if(ai_GetIsCharacter(oDM))
    {
        if(!NuiFindWindow(oDM, "pc" + AI_WIDGET_NUI))
        {
            ai_SendMessages(GetName(oDM) + " is now a Player! Loading player widget.", AI_COLOR_YELLOW, oDM);
            ai_CreateWidgetNUI(oDM, oDM);
        }
        DelayCommand(0.0, NuiDestroy(oDM, nToken));
        return;
    }
    //**************************************************************************
    string sName = ai_RemoveIllegalCharacters(GetName(oDM));
    // Watch to see if the window moves and save.
    if(sElem == "window_geometry" && sEvent == "watch")
    {
        if(GetLocalInt(oDM, AI_NO_NUI_SAVE)) return;
        SaveMenuToCampaignDb(oDM, nToken, sWndId);
    }
    //**************************************************************************
    // Widget events.
    if(sWndId == "dm" + AI_WIDGET_NUI)
    {
        //if(GetLocalInt(oDM, AI_NO_NUI_SAVE)) return;
        if(sEvent == "click")
        {
            if(sElem == "btn_open_main")
            {
                if(IsWindowClosed(oDM, "dm" + AI_COMMAND_NUI)) ai_CreateDMCommandNUI(oDM);
                IsWindowClosed(oDM, "dm" + AI_MAIN_NUI);
            }
            else if(sElem == "btn_camera") ai_SelectCameraView(oDM);
            else if(sElem == "btn_inventory") ai_SelectOpenInventory(oDM);
            else if(GetStringLeft(sElem, 13) == "btn_cmd_group")
            {
                ai_DMSelectAction(oDM, sElem);
            }
            else if(GetStringLeft(sElem, 15) == "btn_exe_plugin_") ai_Plugin_Execute(oDM, sElem, TRUE);
        }
        else if(sEvent == "mousescroll")
        {
            float nMouseScroll = JsonGetFloat(JsonObjectGet(JsonObjectGet(NuiGetEventPayload(), "mouse_scroll"), "y"));
            if(nMouseScroll == 1.0) // Scroll up
            {
                if(GetStringLeft(sElem, 13) == "btn_cmd_group") ai_DMChangeMoveSpeed(oDM, sElem, 1);
            }
            if(nMouseScroll == -1.0) // Scroll down
            {
                if(GetStringLeft(sElem, 13) == "btn_cmd_group") ai_DMChangeMoveSpeed(oDM, sElem, 0);
            }
        }
       else if(sEvent == "mousedown")
        {
            int nMouseButton = JsonGetInt(JsonObjectGet(NuiGetEventPayload(), "mouse_btn"));
            if(nMouseButton == NUI_MOUSE_BUTTON_RIGHT)
            {
                if(sElem == "btn_open_main")
                {
                    if(IsWindowClosed(oDM, "dm" + AI_MAIN_NUI)) ai_CreateDMOptionsNUI(oDM);
                }
                else if(GetStringLeft(sElem, 13) == "btn_cmd_group")
                {
                    ai_SelectToGroup(oDM, sElem);
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
                if(ai_GetDMWidgetButton(oDM, BTN_DM_WIDGET_LOCK))
                {
                    ai_SendMessages(GetName(oDM) + " AI widget unlocked.", AI_COLOR_YELLOW, oDM);
                    ai_SetDMWidgetButton(oDM, BTN_DM_WIDGET_LOCK, FALSE);
                }
                else
                {
                    ai_SendMessages(GetName(oDM) + " AI widget locked.", AI_COLOR_YELLOW, oDM);
                    ai_SetDMWidgetButton(oDM, BTN_DM_WIDGET_LOCK, TRUE);
                }
                DelayCommand(0.0, NuiDestroy(oDM, NuiFindWindow(oDM, "dm" + AI_WIDGET_NUI)));
                DelayCommand(0.1, ai_CreateDMWidgetNUI(oDM));
            }
            else if(sElem == "btn_main_menu")
            {
                DelayCommand(0.0, NuiDestroy(oDM, nToken));
                DelayCommand(0.1, ai_CreateDMOptionsNUI(oDM));
            }
            else if(sElem == "btn_camera") ai_SelectCameraView(oDM);
            else if(sElem == "btn_inventory") ai_SelectOpenInventory(oDM);
            else if(GetStringLeft(sElem, 13) == "btn_cmd_group") ai_DMSelectAction(oDM, sElem);
            else if(GetStringLeft(sElem, 11) == "btn_plugin_") ai_Plugin_Execute(oDM, sElem, 1);
        }
        else if(sEvent == "watch")
        {
            if(sElem == "chbx_cmd_group1_check") ai_SetDMWidgetButtonToCheckbox(oDM, BTN_DM_CMD_GROUP1, nToken, sElem);
            else if(sElem == "chbx_cmd_group2_check") ai_SetDMWidgetButtonToCheckbox(oDM, BTN_DM_CMD_GROUP2, nToken, sElem);
            else if(sElem == "chbx_cmd_group3_check") ai_SetDMWidgetButtonToCheckbox(oDM, BTN_DM_CMD_GROUP3, nToken, sElem);
            else if(sElem == "chbx_cmd_group4_check") ai_SetDMWidgetButtonToCheckbox(oDM, BTN_DM_CMD_GROUP4, nToken, sElem);
            else if(sElem == "chbx_cmd_group5_check") ai_SetDMWidgetButtonToCheckbox(oDM, BTN_DM_CMD_GROUP5, nToken, sElem);
            else if(sElem == "chbx_cmd_group6_check") ai_SetDMWidgetButtonToCheckbox(oDM, BTN_DM_CMD_GROUP6, nToken, sElem);
            else if(sElem == "chbx_camera_check") ai_SetDMWidgetButtonToCheckbox(oDM, BTN_DM_CMD_CAMERA, nToken, sElem);
            else if(sElem == "chbx_inventory_check") ai_SetDMWidgetButtonToCheckbox(oDM, BTN_DM_CMD_INVENTORY, nToken, sElem);
            if(GetStringLeft(sElem, 12) == "chbx_plugin_" && GetStringRight(sElem, 6) == "_check")
            {
                int nIndex = StringToInt(GetSubString(sElem, 12, 1));
                json jPlugins = ai_GetCampaignDbJson("plugins", sName, AI_DM_TABLE);
                json jPlugin = JsonArrayGet(jPlugins, nIndex);
                int bCheck = JsonGetInt(NuiGetBind(oDM, nToken, sElem));
                jPlugin = JsonArraySet(jPlugin, 1, JsonBool(bCheck));
                jPlugins = JsonArraySet(jPlugins, nIndex, jPlugin);
                ai_SetCampaignDbJson("plugins", jPlugins, sName, AI_DM_TABLE);
            }
            DelayCommand(0.0, NuiDestroy(oDM, NuiFindWindow(oDM, "dm" + AI_WIDGET_NUI)));
            DelayCommand(0.1, ai_CreateDMWidgetNUI(oDM));
        }
        else if(sEvent == "mousescroll")
        {
            float nMouseScroll = JsonGetFloat(JsonObjectGet(JsonObjectGet(NuiGetEventPayload(), "mouse_scroll"), "y"));
            if(nMouseScroll == 1.0) // Scroll up
            {
                if(GetStringLeft(sElem, 13) == "btn_cmd_group") ai_DMChangeMoveSpeed(oDM, sElem, 1);
            }
            if(nMouseScroll == -1.0) // Scroll down
            {
                if(GetStringLeft(sElem, 13) == "btn_cmd_group") ai_DMChangeMoveSpeed(oDM, sElem, 0);
            }
        }
        else if(sEvent == "mousedown")
        {
            int nMouseButton = JsonGetInt(JsonObjectGet(NuiGetEventPayload(), "mouse_btn"));
            if(nMouseButton == NUI_MOUSE_BUTTON_RIGHT)
            {
                if(GetStringLeft(sElem, 13) == "btn_cmd_group")
                {
                    ai_SelectToGroup(oDM, sElem);
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
    if(sWndId == "dm" + AI_MAIN_NUI)
    {
        if(sEvent == "click")
        {
            if(sElem == "btn_plugin_manager")
            {
                DelayCommand(0.0, NuiDestroy(oDM, nToken));
                DelayCommand(0.1, ai_CreateDMPluginManagerNUI(oDM));
            }
            if(sElem == "btn_widget_manager")
            {
                DelayCommand(0.0, NuiDestroy(oDM, nToken));
                DelayCommand(0.1, ai_CreateDMWidgetManagerNUI(oDM));
            }
        }
        if(sEvent == "watch")
        {
            if(sElem == "txt_max_henchman")
            {
                int nMaxHenchmen = StringToInt(JsonGetString(NuiGetBind(oDM, nToken, sElem)));
                if(nMaxHenchmen < 1) nMaxHenchmen = 1;
                if(nMaxHenchmen > AI_MAX_HENCHMAN)
                {
                    nMaxHenchmen = AI_MAX_HENCHMAN;
                    ai_SendMessages("The maximum henchmen for this mod is " + IntToString(AI_MAX_HENCHMAN) + "!", AI_COLOR_RED, oDM);
                }
                SetMaxHenchmen(nMaxHenchmen);
                json jRules = ai_GetCampaignDbJson("rules");
                jRules = JsonObjectSet(jRules, AI_RULE_MAX_HENCHMAN, JsonInt(nMaxHenchmen));
                ai_SetCampaignDbJson("rules", jRules);
                ai_SendMessages("Maximum henchmen has been changed to " + IntToString(nMaxHenchmen), AI_COLOR_YELLOW, oDM);
            }
            else if(sElem == "txt_ai_difficulty")
            {
                int nChance = StringToInt(JsonGetString(NuiGetBind(oDM, nToken, sElem)));
                if(nChance < 0) nChance = 0;
                else if(nChance > 100) nChance = 100;
                SetLocalInt(GetModule(), AI_RULE_AI_DIFFICULTY, nChance);
                json jRules = ai_GetCampaignDbJson("rules");
                jRules = JsonObjectSet(jRules, AI_RULE_AI_DIFFICULTY, JsonInt(nChance));
                ai_SetCampaignDbJson("rules", jRules);
            }
            else if(sElem == "txt_perception_distance")
            {
                float fDistance = StringToFloat(JsonGetString(NuiGetBind(oDM, nToken, sElem)));
                if(fDistance < 10.0) fDistance = 10.0;
                else if(fDistance > 60.0) fDistance = 60.0;
                SetLocalFloat(GetModule(), AI_RULE_PERCEPTION_DISTANCE, fDistance);
                json jRules = ai_GetCampaignDbJson("rules");
                jRules = JsonObjectSet(jRules, AI_RULE_PERCEPTION_DISTANCE, JsonFloat(fDistance));
                ai_SetCampaignDbJson("rules", jRules);
            }
            else if(sElem == "txt_inc_hp")
            {
                int nNumber = StringToInt(JsonGetString(NuiGetBind(oDM, nToken, sElem)));
                if(nNumber < 0) nNumber = 0;
                else if(nNumber > 500) nNumber = 500;
                SetLocalInt(GetModule(), AI_INCREASE_MONSTERS_HP, nNumber);
                json jRules = ai_GetCampaignDbJson("rules");
                jRules = JsonObjectSet(jRules, AI_INCREASE_MONSTERS_HP, JsonInt(nNumber));
                ai_SetCampaignDbJson("rules", jRules);
            }
            else if(GetStringLeft(sElem, 4) == "chbx")
            {
                object oModule = GetModule();
                int bCheck = JsonGetInt(NuiGetBind(oDM, nToken, sElem));
                json jRules = ai_GetCampaignDbJson("rules");
                if(sElem == "chbx_moral_check")
                {
                    SetLocalInt(oModule, AI_RULE_MORAL_CHECKS, bCheck);
                    jRules = JsonObjectSet(jRules, AI_RULE_MORAL_CHECKS, JsonInt(bCheck));
                }
                else if(sElem == "chbx_buff_monsters_check")
                {
                    SetLocalInt(oModule, AI_RULE_BUFF_MONSTERS, bCheck);
                    jRules = JsonObjectSet(jRules, AI_RULE_BUFF_MONSTERS, JsonInt(bCheck));
                }
                else if(sElem == "chbx_full_buff_check")
                {
                    SetLocalInt(oModule, AI_RULE_FULL_BUFF_MONSTERS, bCheck);
                    jRules = JsonObjectSet(jRules, AI_RULE_FULL_BUFF_MONSTERS, JsonInt(bCheck));
                }
                else if(sElem == "chbx_buff_summons_check")
                {
                    SetLocalInt(oModule, AI_RULE_PRESUMMON, bCheck);
                    jRules = JsonObjectSet(jRules, AI_RULE_PRESUMMON, JsonInt(bCheck));
                }
                else if(sElem == "chbx_ambush_monsters_check")
                {
                    SetLocalInt(oModule, AI_RULE_AMBUSH, bCheck);
                    jRules = JsonObjectSet(jRules, AI_RULE_AMBUSH, JsonInt(bCheck));
                }
                else if(sElem == "chbx_companions_check")
                {
                    SetLocalInt(oModule, AI_RULE_SUMMON_COMPANIONS, bCheck);
                    jRules = JsonObjectSet(jRules, AI_RULE_SUMMON_COMPANIONS, JsonInt(bCheck));
                }
                else if(sElem == "chbx_advanced_movement_check")
                {
                    SetLocalInt(oModule, AI_RULE_ADVANCED_MOVEMENT, bCheck);
                    jRules = JsonObjectSet(jRules, AI_RULE_ADVANCED_MOVEMENT, JsonInt(bCheck));
                }
                else if(sElem == "chbx_ilr_check")
                {
                    SetLocalInt(oModule, AI_RULE_ILR, bCheck);
                    jRules = JsonObjectSet(jRules, AI_RULE_ILR, JsonInt(bCheck));
                }
                else if(sElem == "chbx_umd_check")
                {
                    SetLocalInt(oModule, AI_RULE_ALLOW_UMD, bCheck);
                    jRules = JsonObjectSet(jRules, AI_RULE_ALLOW_UMD, JsonInt(bCheck));
                }
                else if(sElem == "chbx_use_healingkits_check")
                {
                    SetLocalInt(oModule, AI_RULE_HEALERSKITS, bCheck);
                    jRules = JsonObjectSet(jRules, AI_RULE_HEALERSKITS, JsonInt(bCheck));
                }
                else if(sElem == "chbx_perm_assoc_check")
                {
                    SetLocalInt(oModule, AI_RULE_PERM_ASSOC, bCheck);
                    jRules = JsonObjectSet(jRules, AI_RULE_PERM_ASSOC, JsonInt(bCheck));
                }
                else if(sElem == "chbx_corpses_stay_check")
                {
                    SetLocalInt(oModule, AI_RULE_CORPSES_STAY, bCheck);
                    jRules = JsonObjectSet(jRules, AI_RULE_CORPSES_STAY, JsonInt(bCheck));
                }
                else if(sElem == "chbx_wander_check")
                {
                    SetLocalInt(oModule, AI_RULE_WANDER, bCheck);
                    jRules = JsonObjectSet(jRules, AI_RULE_CORPSES_STAY, JsonInt(bCheck));
                }
                else if(sElem == "chbx_open_doors_check")
                {
                    SetLocalInt(oModule, AI_RULE_OPEN_DOORS, bCheck);
                    jRules = JsonObjectSet(jRules, AI_RULE_OPEN_DOORS, JsonInt(bCheck));
                }
                else if(sElem == "chbx_party_scale_check")
                {
                    if(bCheck)
                    {
                        SetLocalInt(oModule, AI_BASE_PARTY_SCALE_XP, GetModuleXPScale());
                        ai_CheckXPPartyScale(oDM);
                    }
                    else
                    {
                        SetModuleXPScale(GetLocalInt(oModule, AI_RULE_DEFAULT_XP_SCALE));
                    }
                    SetLocalInt(oModule, AI_RULE_PARTY_SCALE, bCheck);
                    jRules = JsonObjectSet(jRules, AI_RULE_PARTY_SCALE, JsonInt(bCheck));
                    string sText = IntToString(GetLocalInt(oModule, AI_BASE_PARTY_SCALE_XP));
                    NuiSetBind(oDM, nToken, "chbx_party_scale_tooltip", JsonString("  PEPS adjusts your XP based on party size from (" + sText + ")."));
                    sText = IntToString(GetModuleXPScale());
                    NuiSetBind(oDM, nToken, "txt_xp_scale", JsonString(sText));
                }
                else if(sElem == "chbx_darkness_check")
                {
                    if(bCheck)
                    {
                        jRules = ai_AddRestrictedSpell(jRules, SPELL_DARKNESS);
                        jRules = ai_AddRestrictedSpell(jRules, 159);
                        jRules = ai_AddRestrictedSpell(jRules, SPELLABILITY_AS_DARKNESS);
                        jRules = ai_AddRestrictedSpell(jRules, 688); // WildShape_Darkness
                    }
                    else
                    {
                        jRules = ai_AddRestrictedSpell(jRules, SPELL_DARKNESS, FALSE);
                        jRules = ai_AddRestrictedSpell(jRules, 159, FALSE);
                        jRules = ai_AddRestrictedSpell(jRules, SPELLABILITY_AS_DARKNESS, FALSE);
                        jRules = ai_AddRestrictedSpell(jRules, 688, FALSE); // WildShape_Darkness
                    }
                }
                else if(sElem == "chbx_dispels_check")
                {
                    if(bCheck)
                    {
                        jRules = ai_AddRestrictedSpell(jRules, SPELL_LESSER_DISPEL);
                        jRules = ai_AddRestrictedSpell(jRules, SPELL_DISPEL_MAGIC);
                        jRules = ai_AddRestrictedSpell(jRules, SPELL_GREATER_DISPELLING);
                        jRules = ai_AddRestrictedSpell(jRules, SPELL_MORDENKAINENS_DISJUNCTION);
                    }
                    else
                    {
                        jRules = ai_AddRestrictedSpell(jRules, SPELL_LESSER_DISPEL, FALSE);
                        jRules = ai_AddRestrictedSpell(jRules, SPELL_DISPEL_MAGIC, FALSE);
                        jRules = ai_AddRestrictedSpell(jRules, SPELL_GREATER_DISPELLING, FALSE);
                        jRules = ai_AddRestrictedSpell(jRules, SPELL_MORDENKAINENS_DISJUNCTION, FALSE);
                    }
                }
                else if(sElem == "chbx_timestop_check")
                {
                    if(bCheck) jRules = ai_AddRestrictedSpell(jRules, SPELL_TIME_STOP);
                    else jRules = ai_AddRestrictedSpell(jRules, SPELL_TIME_STOP, FALSE);
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
                if(sElem == "lbl_perc_dist") ai_RulePercDistInc(oDM, GetModule(), 1, nToken);
            }
            else if(nMouseScroll == -1.0) // Scroll down
            {
                // Follow range is only changed on non-pc's
                if(sElem == "lbl_perc_dist") ai_RulePercDistInc(oDM, GetModule(), -1, nToken);
            }
        }
    }
    //**************************************************************************
    // Plugins events.
    if(sWndId == "dmai_plugin_nui")
    {
        string sName = ai_RemoveIllegalCharacters(GetName(oDM));
        json jPlugins = ai_GetCampaignDbJson("plugins");
        if(sEvent == "click")
        {
            if(sElem == "btn_load_plugins")
            {
                string sScript = JsonGetString(NuiGetBind (oDM, nToken, "txt_plugin"));
                if(JsonGetType(JsonArrayGet(jPlugins, 0)) == JSON_TYPE_NULL) jPlugins = JsonArray();
                jPlugins = ai_Plugin_Add(oDM, jPlugins, "pi_buffing");
                jPlugins = ai_Plugin_Add(oDM, jPlugins, "pi_forcerest");
                jPlugins = ai_Plugin_Add(oDM, jPlugins, "pi_henchmen");
                jPlugins = ai_Plugin_Add(oDM, jPlugins, "pi_crafting");
                jPlugins = ai_Plugin_Add(oDM, jPlugins, "pi_mod_set");
                jPlugins = ai_Plugin_Add(oDM, jPlugins, "pi_debug");
                jPlugins = ai_Plugin_Add(oDM, jPlugins, "pi_test");
                ai_SetCampaignDbJson("plugins", jPlugins);
                DelayCommand(0.0, NuiDestroy(oDM, nToken));
                DelayCommand(0.1, ai_CreateDMPluginManagerNUI(oDM));
                DelayCommand(0.0, NuiDestroy(oDM, NuiFindWindow(oDM, "dm" + AI_WIDGET_NUI)));
                DelayCommand(0.1, ai_CreateDMWidgetNUI(oDM));
            }
            if(sElem == "btn_check_plugins")
            {
                int nIndex;
                json jPlugin = JsonArrayGet(jPlugins, nIndex);
                while(JsonGetType(jPlugin) != JSON_TYPE_NULL)
                {
                    jPlugin = JsonArraySet(jPlugin, 1, JsonBool(TRUE));
                    jPlugins = JsonArraySet(jPlugins, nIndex, jPlugin);
                    jPlugin = JsonArrayGet(jPlugins, ++nIndex);
                }
                ai_SetCampaignDbJson("plugins", jPlugins);
                DelayCommand(0.0, NuiDestroy(oDM, nToken));
                DelayCommand(0.1, ai_CreateDMPluginManagerNUI(oDM));
                DelayCommand(0.0, NuiDestroy(oDM, NuiFindWindow(oDM, "dm" + AI_WIDGET_NUI)));
                DelayCommand(0.1, ai_CreateDMWidgetNUI(oDM));
            }
            if(sElem == "btn_clear_plugins")
            {
                int nIndex;
                json jPlugin = JsonArrayGet(jPlugins, nIndex);
                while(JsonGetType(jPlugin) != JSON_TYPE_NULL)
                {
                    jPlugin = JsonArraySet(jPlugin, 1, JsonBool(FALSE));
                    jPlugins = JsonArraySet(jPlugins, nIndex, jPlugin);
                    jPlugin = JsonArrayGet(jPlugins, ++nIndex);
                }
                ai_SetCampaignDbJson("plugins", jPlugins);
                DelayCommand(0.0, NuiDestroy(oDM, nToken));
                DelayCommand(0.1, ai_CreateDMPluginManagerNUI(oDM));
                DelayCommand(0.0, NuiDestroy(oDM, NuiFindWindow(oDM, "dm" + AI_WIDGET_NUI)));
                DelayCommand(0.1, ai_CreateDMWidgetNUI(oDM));
            }
            else if(sElem == "btn_add_plugin")
            {
                string sScript = JsonGetString(NuiGetBind (oDM, nToken, "txt_plugin"));
                if(JsonGetType(JsonArrayGet(jPlugins, 0)) == JSON_TYPE_NULL) jPlugins = JsonArray();
                jPlugins = ai_Plugin_Add(oDM, jPlugins, sScript);
                ai_SetCampaignDbJson("plugins", jPlugins);
                DelayCommand(0.0, NuiDestroy(oDM, nToken));
                DelayCommand(0.1, ai_CreateDMPluginManagerNUI(oDM));
            }
            else if(GetStringLeft(sElem, 18) == "btn_remove_plugin_")
            {
                int nIndex = StringToInt(GetStringRight(sElem, 1));
                jPlugins = JsonArrayDel(jPlugins, nIndex);
                ai_SetCampaignDbJson("plugins", jPlugins);
                DelayCommand(0.0, NuiDestroy(oDM, nToken));
                DelayCommand(0.1, ai_CreateDMPluginManagerNUI(oDM));
                DelayCommand(0.0, NuiDestroy(oDM, NuiFindWindow(oDM, "dm" + AI_WIDGET_NUI)));
                DelayCommand(0.1, ai_CreateDMWidgetNUI(oDM));
            }
            else if(GetStringLeft(sElem, 11) == "btn_plugin_") ai_Plugin_Execute(oDM, sElem, 2);
        }
        else if(sEvent == "watch")
        {
            if(GetStringLeft(sElem, 12) == "chbx_plugin_" && GetStringRight(sElem, 6) == "_check")
            {
                int nIndex = StringToInt(GetSubString(sElem, 12, 1));
                json jPlugin = JsonArrayGet(jPlugins, nIndex);
                int bCheck = JsonGetInt(NuiGetBind(oDM, nToken, sElem));
                jPlugin = JsonArraySet(jPlugin, 1, JsonBool(bCheck));
                jPlugins = JsonArraySet(jPlugins, nIndex, jPlugin);
                ai_SetCampaignDbJson("plugins", jPlugins);
                DelayCommand(0.0, NuiDestroy(oDM, NuiFindWindow(oDM, "dm" + AI_WIDGET_NUI)));
                DelayCommand(0.1, ai_CreateDMWidgetNUI(oDM));
            }
        }
    }
    if(sWndId == "dm_widget_manager_nui")
    {
        //SendMessageToDM(oDM, "sEvent: " + sEvent + " sElem: " + sElem);
        if(sEvent == "click")
        {
            if(sElem == "btn_clear_buttons")
            {
                object oModule = GetModule();
                SetLocalInt(oModule, sDMWidgetAccessVarname, 0);
                SetLocalInt(oModule, sDMAIAccessVarname, 0);
                json jRules = ai_GetCampaignDbJson("rules");
                jRules = JsonObjectSet(jRules, sDMWidgetAccessVarname, JsonInt(0));
                jRules = JsonObjectSet(jRules, sDMAIAccessVarname, JsonInt(0));
                ai_SetCampaignDbJson("rules", jRules);
                DelayCommand(0.0, NuiDestroy(oDM, nToken));
                DelayCommand(0.1, ai_CreateDMWidgetManagerNUI(oDM));
                return;
            }
            else if(sElem == "btn_check_buttons")
            {
                object oModule = GetModule();
                SetLocalInt(oModule, sDMWidgetAccessVarname, 7340028);
                SetLocalInt(oModule, sDMAIAccessVarname, 203423743);
                json jRules = ai_GetCampaignDbJson("rules");
                jRules = JsonObjectSet(jRules, sDMWidgetAccessVarname, JsonInt(7340028));
                jRules = JsonObjectSet(jRules, sDMAIAccessVarname, JsonInt(203423743));
                ai_SetCampaignDbJson("rules", jRules);
                DelayCommand(0.0, NuiDestroy(oDM, nToken));
                DelayCommand(0.1, ai_CreateDMWidgetManagerNUI(oDM));
                return;
            }
            SetLocalInt(oDM, "CHBX_SKIP", TRUE);
            DelayCommand(2.0, DeleteLocalInt(oDM, "CHBX_SKIP"));
            if(sElem == "btn_cmd_action") NuiSetBind(oDM, nToken, "chbx_cmd_action_check", JsonBool(!ai_GetDMWAccessButton(BTN_CMD_ACTION)));
            else if(sElem == "btn_cmd_guard") NuiSetBind(oDM, nToken, "chbx_cmd_guard_check", JsonBool(!ai_GetDMWAccessButton(BTN_CMD_GUARD)));
            else if(sElem == "btn_cmd_hold") NuiSetBind(oDM, nToken, "chbx_cmd_hold_check", JsonBool(!ai_GetDMWAccessButton(BTN_CMD_HOLD)));
            else if(sElem == "btn_cmd_attack") NuiSetBind(oDM, nToken, "chbx_cmd_attack_check", JsonBool(!ai_GetDMWAccessButton(BTN_CMD_ATTACK)));
            else if(sElem == "btn_cmd_follow") NuiSetBind(oDM, nToken, "chbx_cmd_follow_check", JsonBool(!ai_GetDMWAccessButton(BTN_CMD_FOLLOW)));
            else if(sElem == "btn_follow_target") NuiSetBind(oDM, nToken, "chbx_follow_target_check", JsonBool(!ai_GetDMAIAccessButton(BTN_AI_FOLLOW_TARGET)));
            else if(sElem == "btn_cmd_search") NuiSetBind(oDM, nToken, "chbx_cmd_search_check", JsonBool(!ai_GetDMWAccessButton(BTN_CMD_SEARCH)));
            else if(sElem == "btn_cmd_stealth") NuiSetBind(oDM, nToken, "chbx_cmd_stealth_check", JsonBool(!ai_GetDMWAccessButton(BTN_CMD_STEALTH)));
            else if(sElem == "btn_cmd_ai_script") NuiSetBind(oDM, nToken, "chbx_cmd_ai_script_check", JsonBool(!ai_GetDMWAccessButton(BTN_CMD_AI_SCRIPT)));
            else if(sElem == "btn_cmd_place_trap") NuiSetBind(oDM, nToken, "chbx_cmd_place_trap_check", JsonBool(!ai_GetDMWAccessButton(BTN_CMD_PLACE_TRAP)));
            else if(sElem == "btn_quick_widget") NuiSetBind(oDM, nToken, "chbx_quick_widget_check", JsonBool(!ai_GetDMWAccessButton(BTN_CMD_SPELL_WIDGET)));
            else if(sElem == "btn_spell_memorize") NuiSetBind(oDM, nToken, "chbx_spell_memorize_check", JsonBool(!ai_GetDMWAccessButton(BTN_DM_CMD_MEMORIZE)));
            else if(sElem == "btn_buff_short") NuiSetBind(oDM, nToken, "chbx_buff_short_check", JsonBool(!ai_GetDMWAccessButton(BTN_BUFF_SHORT)));
            else if(sElem == "btn_buff_long") NuiSetBind(oDM, nToken, "chbx_buff_long_check", JsonBool(!ai_GetDMWAccessButton(BTN_BUFF_LONG)));
            else if(sElem == "btn_buff_all") NuiSetBind(oDM, nToken, "chbx_buff_all_check", JsonBool(!ai_GetDMWAccessButton(BTN_BUFF_ALL)));
            else if(sElem == "btn_buff_rest") NuiSetBind(oDM, nToken, "chbx_buff_rest_check", JsonBool(!ai_GetDMWAccessButton(BTN_BUFF_REST)));
            else if(sElem == "btn_jump_to") NuiSetBind(oDM, nToken, "chbx_jump_to_check", JsonBool(!ai_GetDMWAccessButton(BTN_CMD_JUMP_TO)));
            else if(sElem == "btn_ghost_mode") NuiSetBind(oDM, nToken, "chbx_ghost_mode_check", JsonBool(!ai_GetDMWAccessButton(BTN_CMD_GHOST_MODE)));
            else if(sElem == "btn_camera") NuiSetBind(oDM, nToken, "chbx_camera_check", JsonBool(!ai_GetDMWAccessButton(BTN_CMD_CAMERA)));
            else if(sElem == "btn_inventory") NuiSetBind(oDM, nToken, "chbx_inventory_check", JsonBool(!ai_GetDMWAccessButton(BTN_CMD_INVENTORY)));
            else if(sElem == "btn_familiar") NuiSetBind(oDM, nToken, "chbx_familiar_check", JsonBool(!ai_GetDMWAccessButton(BTN_CMD_FAMILIAR)));
            else if(sElem == "btn_companion") NuiSetBind(oDM, nToken, "chbx_companion_check", JsonBool(!ai_GetDMWAccessButton(BTN_CMD_COMPANION)));
            else if(sElem == "btn_ai") NuiSetBind(oDM, nToken, "chbx_ai_check", JsonBool(!ai_GetDMAIAccessButton(BTN_AI_FOR_PC)));
            else if(sElem == "btn_quiet") NuiSetBind(oDM, nToken, "chbx_quiet_check", JsonBool(!ai_GetDMAIAccessButton(BTN_AI_REDUCE_SPEECH)));
            else if(sElem == "btn_ranged") NuiSetBind(oDM, nToken, "chbx_ranged_check", JsonBool(!ai_GetDMAIAccessButton(BTN_AI_USE_RANGED)));
            else if(sElem == "btn_search") NuiSetBind(oDM, nToken, "chbx_search_check", JsonBool(!ai_GetDMAIAccessButton(BTN_AI_USE_SEARCH)));
            else if(sElem == "btn_stealth") NuiSetBind(oDM, nToken, "chbx_stealth_check", JsonBool(!ai_GetDMAIAccessButton(BTN_AI_USE_STEALTH)));
            else if(sElem == "btn_open_door") NuiSetBind(oDM, nToken, "chbx_open_door_check", JsonBool(!ai_GetDMAIAccessButton(BTN_AI_OPEN_DOORS)));
            else if(sElem == "btn_traps") NuiSetBind(oDM, nToken, "chbx_traps_check", JsonBool(!ai_GetDMAIAccessButton(BTN_AI_REMOVE_TRAPS)));
            else if(sElem == "btn_pick_locks") NuiSetBind(oDM, nToken, "chbx_pick_locks_check", JsonBool(!ai_GetDMAIAccessButton(BTN_AI_PICK_LOCKS)));
            else if(sElem == "btn_bash_locks") NuiSetBind(oDM, nToken, "chbx_bash_locks_check", JsonBool(!ai_GetDMAIAccessButton(BTN_AI_BASH_LOCKS)));
            else if(sElem == "btn_magic_level") NuiSetBind(oDM, nToken, "chbx_magic_level_check", JsonBool(!ai_GetDMAIAccessButton(BTN_AI_MAGIC_LEVEL)));
            else if(sElem == "btn_spontaneous") NuiSetBind(oDM, nToken, "chbx_spontaneous_check", JsonBool(!ai_GetDMAIAccessButton(BTN_AI_NO_SPONTANEOUS)));
            else if(sElem == "btn_magic") NuiSetBind(oDM, nToken, "chbx_magic_check", JsonBool(!ai_GetDMAIAccessButton(BTN_AI_NO_MAGIC_USE)));
            else if(sElem == "btn_magic_items") NuiSetBind(oDM, nToken, "chbx_magic_items_check", JsonBool(!ai_GetDMAIAccessButton(BTN_AI_NO_MAGIC_ITEM_USE)));
            else if(sElem == "btn_def_magic") NuiSetBind(oDM, nToken, "chbx_def_magic_check", JsonBool(!ai_GetDMAIAccessButton(BTN_AI_DEF_MAGIC_USE)));
            else if(sElem == "btn_off_magic") NuiSetBind(oDM, nToken, "chbx_off_magic_check", JsonBool(!ai_GetDMAIAccessButton(BTN_AI_OFF_MAGIC_USE)));
            else if(sElem == "btn_heal_out") NuiSetBind(oDM, nToken, "chbx_heal_out_check", JsonBool(!ai_GetDMAIAccessButton(BTN_AI_HEAL_OUT)));
            else if(sElem == "btn_heal_in") NuiSetBind(oDM, nToken, "chbx_heal_in_check", JsonBool(!ai_GetDMAIAccessButton(BTN_AI_HEAL_IN)));
            else if(sElem == "btn_heals_onoff") NuiSetBind(oDM, nToken, "chbx_heals_onoff_check", JsonBool(!ai_GetDMAIAccessButton(BTN_AI_STOP_SELF_HEALING)));
            else if(sElem == "btn_healp_onoff") NuiSetBind(oDM, nToken, "chbx_healp_onoff_check", JsonBool(!ai_GetDMAIAccessButton(BTN_AI_STOP_PARTY_HEALING)));
            else if(sElem == "btn_loot") NuiSetBind(oDM, nToken, "chbx_loot_check", JsonBool(!ai_GetDMAIAccessButton(BTN_AI_LOOT)));
            else if(sElem == "btn_ignore_assoc") NuiSetBind(oDM, nToken, "chbx_ignore_assoc_check", JsonBool(!ai_GetDMAIAccessButton(BTN_AI_IGNORE_ASSOCIATES)));
            else if(sElem == "btn_ignore_traps") NuiSetBind(oDM, nToken, "chbx_ignore_traps_check", JsonBool(!ai_GetDMAIAccessButton(BTN_AI_IGNORE_TRAPS)));
            else if(sElem == "btn_perc_range") NuiSetBind(oDM, nToken, "chbx_perc_range_check", JsonBool(!ai_GetDMAIAccessButton(BTN_AI_PERC_RANGE)));
        }
        if(sEvent == "watch")
        {
            if(GetLocalInt(oDM, "CHBX_SKIP")) return;
            if(sElem == "chbx_cmd_action_check") ai_SetDMWAccessButtonToCheckbox(oDM, BTN_CMD_ACTION, nToken, sElem);
            else if(sElem == "chbx_cmd_guard_check") ai_SetDMWAccessButtonToCheckbox(oDM, BTN_CMD_GUARD, nToken, sElem);
            else if(sElem == "chbx_cmd_hold_check") ai_SetDMWAccessButtonToCheckbox(oDM, BTN_CMD_HOLD, nToken, sElem);
            else if(sElem == "chbx_cmd_attack_check") ai_SetDMWAccessButtonToCheckbox(oDM, BTN_CMD_ATTACK, nToken, sElem);
            else if(sElem == "chbx_cmd_follow_check") ai_SetDMWAccessButtonToCheckbox(oDM, BTN_CMD_FOLLOW, nToken, sElem);
            else if(sElem == "chbx_follow_target_check") ai_SetDMAIAccessButtonToCheckbox(oDM, BTN_AI_FOLLOW_TARGET, nToken, sElem);
            else if(sElem == "chbx_cmd_search_check") ai_SetDMWAccessButtonToCheckbox(oDM, BTN_CMD_SEARCH, nToken, sElem);
            else if(sElem == "chbx_cmd_stealth_check") ai_SetDMWAccessButtonToCheckbox(oDM, BTN_CMD_STEALTH, nToken, sElem);
            else if(sElem == "chbx_cmd_ai_script_check") ai_SetDMWAccessButtonToCheckbox(oDM, BTN_CMD_AI_SCRIPT, nToken, sElem);
            else if(sElem == "chbx_cmd_place_trap_check") ai_SetDMWAccessButtonToCheckbox(oDM, BTN_CMD_PLACE_TRAP, nToken, sElem);
            else if(sElem == "chbx_quick_widget_check") ai_SetDMWAccessButtonToCheckbox(oDM, BTN_CMD_SPELL_WIDGET, nToken, sElem);
            else if(sElem == "chbx_spell_memorize_check") ai_SetDMWAccessButtonToCheckbox(oDM, BTN_DM_CMD_MEMORIZE, nToken, sElem);
            else if(sElem == "chbx_buff_short_check") ai_SetDMWAccessButtonToCheckbox(oDM, BTN_BUFF_SHORT, nToken, sElem);
            else if(sElem == "chbx_buff_long_check") ai_SetDMWAccessButtonToCheckbox(oDM, BTN_BUFF_LONG, nToken, sElem);
            else if(sElem == "chbx_buff_all_check") ai_SetDMWAccessButtonToCheckbox(oDM, BTN_BUFF_ALL, nToken, sElem);
            else if(sElem == "chbx_buff_rest_check") ai_SetDMWAccessButtonToCheckbox(oDM, BTN_BUFF_REST, nToken, sElem);
            else if(sElem == "chbx_jump_to_check") ai_SetDMWAccessButtonToCheckbox(oDM, BTN_CMD_JUMP_TO, nToken, sElem);
            else if(sElem == "chbx_ghost_mode_check") ai_SetDMWAccessButtonToCheckbox(oDM, BTN_CMD_GHOST_MODE, nToken, sElem);
            else if(sElem == "chbx_camera_check") ai_SetDMWAccessButtonToCheckbox(oDM, BTN_CMD_CAMERA, nToken, sElem);
            else if(sElem == "chbx_inventory_check") ai_SetDMWAccessButtonToCheckbox(oDM, BTN_CMD_INVENTORY, nToken, sElem);
            else if(sElem == "chbx_familiar_check") ai_SetDMWAccessButtonToCheckbox(oDM, BTN_CMD_FAMILIAR, nToken, sElem);
            else if(sElem == "chbx_companion_check") ai_SetDMWAccessButtonToCheckbox(oDM, BTN_CMD_COMPANION, nToken, sElem);
            else if(sElem == "chbx_ai_check") ai_SetDMAIAccessButtonToCheckbox(oDM, BTN_AI_FOR_PC, nToken, sElem);
            else if(sElem == "chbx_quiet_check") ai_SetDMAIAccessButtonToCheckbox(oDM, BTN_AI_REDUCE_SPEECH, nToken, sElem);
            else if(sElem == "chbx_ranged_check") ai_SetDMAIAccessButtonToCheckbox(oDM, BTN_AI_USE_RANGED, nToken, sElem);
            else if(sElem == "chbx_search_check") ai_SetDMAIAccessButtonToCheckbox(oDM, BTN_AI_USE_SEARCH, nToken, sElem);
            else if(sElem == "chbx_stealth_check") ai_SetDMAIAccessButtonToCheckbox(oDM, BTN_AI_USE_STEALTH, nToken, sElem);
            else if(sElem == "chbx_open_door_check") ai_SetDMAIAccessButtonToCheckbox(oDM, BTN_AI_OPEN_DOORS, nToken, sElem);
            else if(sElem == "chbx_traps_check") ai_SetDMAIAccessButtonToCheckbox(oDM, BTN_AI_REMOVE_TRAPS, nToken, sElem);
            else if(sElem == "chbx_pick_locks_check") ai_SetDMAIAccessButtonToCheckbox(oDM, BTN_AI_PICK_LOCKS, nToken, sElem);
            else if(sElem == "chbx_bash_locks_check") ai_SetDMAIAccessButtonToCheckbox(oDM, BTN_AI_BASH_LOCKS, nToken, sElem);
            else if(sElem == "chbx_magic_level_check") ai_SetDMAIAccessButtonToCheckbox(oDM, BTN_AI_MAGIC_LEVEL, nToken, sElem);
            else if(sElem == "chbx_spontaneous_check") ai_SetDMAIAccessButtonToCheckbox(oDM, BTN_AI_NO_SPONTANEOUS, nToken, sElem);
            else if(sElem == "chbx_magic_check") ai_SetDMAIAccessButtonToCheckbox(oDM, BTN_AI_NO_MAGIC_USE, nToken, sElem);
            else if(sElem == "chbx_magic_items_check") ai_SetDMAIAccessButtonToCheckbox(oDM, BTN_AI_NO_MAGIC_ITEM_USE, nToken, sElem);
            else if(sElem == "chbx_def_magic_check") ai_SetDMAIAccessButtonToCheckbox(oDM, BTN_AI_DEF_MAGIC_USE, nToken, sElem);
            else if(sElem == "chbx_off_magic_check") ai_SetDMAIAccessButtonToCheckbox(oDM, BTN_AI_OFF_MAGIC_USE, nToken, sElem);
            else if(sElem == "chbx_heal_out_check") ai_SetDMAIAccessButtonToCheckbox(oDM, BTN_AI_HEAL_OUT, nToken, sElem);
            else if(sElem == "chbx_heal_in_check") ai_SetDMAIAccessButtonToCheckbox(oDM, BTN_AI_HEAL_IN, nToken, sElem);
            else if(sElem == "chbx_heals_onoff_check") ai_SetDMAIAccessButtonToCheckbox(oDM, BTN_AI_STOP_SELF_HEALING, nToken, sElem);
            else if(sElem == "chbx_healp_onoff_check") ai_SetDMAIAccessButtonToCheckbox(oDM, BTN_AI_STOP_PARTY_HEALING, nToken, sElem);
            else if(sElem == "chbx_loot_check") ai_SetDMAIAccessButtonToCheckbox(oDM, BTN_AI_LOOT, nToken, sElem);
            else if(sElem == "chbx_ignore_assoc_check") ai_SetDMAIAccessButtonToCheckbox(oDM, BTN_AI_IGNORE_ASSOCIATES, nToken, sElem);
            else if(sElem == "chbx_ignore_traps_check") ai_SetDMAIAccessButtonToCheckbox(oDM, BTN_AI_IGNORE_TRAPS, nToken, sElem);
            else if(sElem == "chbx_perc_range_check") ai_SetDMAIAccessButtonToCheckbox(oDM, BTN_AI_PERC_RANGE, nToken, sElem);
        }
    }
}
void ai_SetDMWidgetButtonToCheckbox(object oDM, int nButton, int nToken, string sElem)
{
    int bCheck = JsonGetInt(NuiGetBind(oDM, nToken, sElem));
    ai_SetDMWidgetButton(oDM, nButton, bCheck);
}
void ai_SetDMWAccessButtonToCheckbox(object oDM, int nButton, int nToken, string sElem)
{
    int bCheck = JsonGetInt(NuiGetBind(oDM, nToken, sElem));
    ai_SetDMWAccessButton(nButton, bCheck);
}
void ai_SetDMAIAccessButtonToCheckbox(object oDM, int nButton, int nToken, string sElem)
{
    int bCheck = JsonGetInt(NuiGetBind(oDM, nToken, sElem));
    ai_SetDMAIAccessButton(nButton, bCheck);
}
void ai_RulePercDistInc(object oDM, object oModule, int nIncrement, int nToken)
{
    int nAdjustment = GetLocalInt(oModule, AI_RULE_MON_PERC_DISTANCE) + nIncrement;
    if(nAdjustment < 8 || nAdjustment > 11) return;
    SetLocalInt(oModule, AI_RULE_MON_PERC_DISTANCE, nAdjustment);
    string sText;
    if(nAdjustment == 8) sText = " Monster perception: Short [10 Sight / 10 Listen]";
    else if(nAdjustment == 9) sText = " Monster perception: Medium [20 Sight / 20 Listen]";
    else if(nAdjustment == 10) sText = " Monster perception: Long [35 Sight / 20 Listen]";
    else sText = " Monster perception: Default [Monster's default values]";
    NuiSetBind(oDM, nToken, "lbl_perc_dist_label", JsonString(sText));
    json jRules = ai_GetCampaignDbJson("rules");
    jRules = JsonObjectSet(jRules, AI_RULE_MON_PERC_DISTANCE, JsonInt(nAdjustment));
    ai_SetCampaignDbJson("rules", jRules);
}
json ai_AddRestrictedSpell(json jRules, int nSpell, int bRestrict = TRUE)
{
    object oModule = GetModule();
    json jRSpells = GetLocalJson(oModule, AI_RULE_RESTRICTED_SPELLS);
    int nIndex, nMaxIndex = JsonGetLength(jRSpells);
    if(bRestrict)
    {
        while(nIndex < nMaxIndex)
        {
            if(JsonGetInt(JsonArrayGet(jRSpells, nIndex)) == nSpell) return jRules;
            nIndex++;
        }
        jRSpells = JsonArrayInsert(jRSpells, JsonInt(nSpell));
    }
    else
    {
        while(nIndex < nMaxIndex)
        {
            if(JsonGetInt(JsonArrayGet(jRSpells, nIndex)) == nSpell)
            {
                jRSpells = JsonArrayDel(jRSpells, nIndex);
                break;
            }
            nIndex++;
        }
    }
    SetLocalJson(oModule, AI_RULE_RESTRICTED_SPELLS, jRSpells);
    return JsonObjectSet(jRules, AI_RULE_RESTRICTED_SPELLS, jRSpells);
}
void ai_SelectToGroup(object oDM, string sElem)
{
    string sGroup = GetStringRight(sElem, 1);
    SetLocalString(oDM, AI_TARGET_MODE, "DM_SELECT_GROUP" + sGroup);
    ai_SendMessages("Select a creature to add to group " + sGroup + ". Selecting yourself will clear group1.", AI_COLOR_YELLOW, oDM);
    EnterTargetingMode(oDM, OBJECT_TYPE_CREATURE, MOUSECURSOR_PICKUP, MOUSECURSOR_PICKUP_DOWN);
}
void ai_DMSelectAction(object oDM, string sElem)
{
    string sGroup = GetStringRight(sElem, 1);
    SetLocalString(oDM, AI_TARGET_MODE, "DM_ACTION_GROUP" + sGroup);
    ai_SendMessages(GetName(oDM) + " select an action for group" + sGroup + ".", AI_COLOR_YELLOW, oDM);
    EnterTargetingMode(oDM, OBJECT_TYPE_ALL, MOUSECURSOR_ACTION, MOUSECURSOR_NOWALK);
}
void ai_DMChangeMoveSpeed(object oDM, string sElem, int nSpeed)
{
    string sGroup = GetStringRight(sElem, 1);
    json jGroup = GetLocalJson(oDM, "DM_GROUP" + sGroup);
    if(JsonGetType(jGroup) == JSON_TYPE_NULL)
    {
        ai_SendMessages("This group does not contain any creatures!", AI_COLOR_RED, oDM);
        return;
    }
    jGroup = JsonArraySet(jGroup, 0, JsonInt(nSpeed));
    SetLocalJson(oDM, "DM_GROUP" + sGroup, jGroup);
    object oLeader = GetObjectByUUID(JsonGetString(JsonArrayGet(jGroup, 1)));
    string sName = GetName(oLeader);
    string sText = "  " + sName + "'s group";
    if(nSpeed == 0) sText += " [Walk]";
    else sText += " [Run]";
    NuiSetBind(oDM, NuiFindWindow(oDM, "dm" + AI_WIDGET_NUI), "btn_cmd_group" + sGroup + "_tooltip", JsonString(sText));
    NuiSetBind(oDM, NuiFindWindow(oDM, "dm" + AI_COMMAND_NUI), "btn_cmd_group" + sGroup + "_tooltip", JsonString(sText));
}
