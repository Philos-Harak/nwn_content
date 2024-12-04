/*//////////////////////////////////////////////////////////////////////////////
 Script Name: 0e_nui
 Programmer: Philos
////////////////////////////////////////////////////////////////////////////////
 Menu event script
    sEvent: close, click, mousedown, mouseup, watch (if bindwatch is set).
/*//////////////////////////////////////////////////////////////////////////////
#include "nw_inc_gff"
#include "x0_i0_assoc"
#include "0i_menus"
void ai_ToggleAssociateWidgetOnOff(object oPC, int nToken, string sAssociateType);
// Sets the Widget Buttons state to sElem Checkbox state.
void ai_SetWidgetButtonToCheckbox(object oPC, int nButton, object oAssociate, string sAssociateType, int nToken, string sElem);
// Flips an AI Buttons state to sElem Checkbox state.
void ai_SetAIButtonToCheckbox(object oPC, int nButton, object oAssociate, string sAssociateType, int nToken, string sElem);
// Flips an AI Buttons2 state to sElem Checkbox state.
void ai_SetAIButton2ToCheckbox(object oPC, int nButton, object oAssociate, string sAssociateType, int nToken, string sElem);
// Flips the flag for the loot filter to sElem Checkbox state.
void ai_SetLootFilterToCheckbox(object oPC, object oAssociate, int nFilterBit, int nToken, string sElem);
// Sets an associates companion type. Cannot set companion for a player!
void ai_SetCompanionType(object oPC, object oAssociate, int nToken, int nCompanionType);
// Sets an associates companion name. Cannot set companion for a player!
void ai_SetCompanionName(object oPC, object oAssociate, int nToken, int nCompanionType);
// Turns on oAssociate AI, Setting all event scripts.
void ai_TurnOn(object oPC, object oAssociate, string sAssociateType);
// Turns off oAssociate AI, Setting all event scripts.
void ai_TurnOff(object oPC, object oAssociate, string sAssociateType);

void ai_ToggleAssociateWidgetOnOff(object oPC, int nToken, string sAssociateType)
{
    object oAssociate = ai_GetAssociateByStringType(oPC, sAssociateType);
    string sText, sName = GetName(oAssociate);
    if(GetStringRight(sName, 1) == "s") sName = sName + "'";
    else sName = sName + "'s";
    int bWidget = !ai_GetWidgetButton(oPC, BTN_WIDGET_OFF, oAssociate, sAssociateType);
    ai_SetWidgetButton(oPC, BTN_WIDGET_OFF, oAssociate, sAssociateType, bWidget);
    NuiSetBind(oPC, nToken, "btn_options", JsonBool (!bWidget));
    if(bWidget)
    {
        sText = "on";
        IsWindowClosed(oPC, sAssociateType + "_widget");
    }
    else
    {
        sText = "off";
        ai_CreateWidgetNUI(oPC, oAssociate);
    }
    NuiSetBind(oPC, nToken, "btn_options_tooltip", JsonString("  Turn " + sName + " widget " + sText));
}
void main()
{
    object oPC = NuiGetEventPlayer();
    int nToken  = NuiGetEventWindow();
    string sEvent = NuiGetEventType();
    string sElem  = NuiGetEventElement();
    int nIndex = NuiGetEventArrayIndex();
    string sWndId = NuiGetWindowId(oPC, nToken);
    //ai_Debug ("0e_nui", "58", "sWndId: " + sWndId + " sEvent: " + sEvent + " sElem: " + sElem +
    //          " nToken: " + IntToString(nToken) + " oPC: " + GetName(oPC));
    // Get if the menu has an associate attached.
    json jData = NuiGetUserData(oPC, nToken);
    object oAssociate = StringToObject(JsonGetString(JsonArrayGet(jData, 0)));
    string sAssociateType = ai_GetAssociateType(oPC, oAssociate);
    if(sAssociateType == "") return;
    if(!ai_GetIsCharacter(oAssociate) && !GetLocalInt(oPC, "AI_IGNORE_NO_ASSOCIATE") &&
      (oAssociate == OBJECT_INVALID || GetMaster(oAssociate) != oPC))
    {
        ai_SendMessages("This creature is no longer in your party!", AI_COLOR_RED, oPC);
        NuiDestroy(oPC, nToken);
        return;
    }
    //ai_Debug("0e_nui", "78", "oAssociate: " + GetName(oAssociate) + " sAssociateType: " + sAssociateType +
    //         " AI_NO_NUI_SAVE: " + IntToString(GetLocalInt(oPC, AI_NO_NUI_SAVE)));
    //**************************************************************************
    if(sWndId == sAssociateType + "_widget")
    {
        // Watch to see if the window moves and save.
        if(sElem == "window_geometry" && sEvent == "watch")
        {
            if(GetLocalInt(oPC, AI_NO_NUI_SAVE)) return;
            json jGeometry = NuiGetBind(oPC, nToken, "window_geometry");
            ai_Debug("0e_nui", "82", "sAssociateType: " + sAssociateType + " jGeometry: " + JsonDump(jGeometry));
            ai_SetAssociateDbJson(oPC, sAssociateType, "locations", jGeometry);
        }
    }
    //**************************************************************************
    // Main AI events.
    if(sWndId == "ai_main_nui")
    {
        //if(GetLocalInt(oPC, AI_NO_NUI_SAVE)) return;
        if(sEvent == "click")
        {
            string sHenchman;
            if(sElem == "btn_ghost_mode")
            {
                // We set ghost mode differently for each AI.
                if(ResManGetAliasFor("0e_ch_1_hb", RESTYPE_NCS) == "")
                {
                    if(GetLocalInt(oPC, sGhostModeVarname))
                    {
                        DeleteLocalInt(oPC, sGhostModeVarname);
                        ai_SendMessages("Ghost mode is turned off when using commands.", AI_COLOR_YELLOW, oPC);
                        object oAssociate;
                        int nIndex;
                        for(nIndex = 1; nIndex <= AI_MAX_HENCHMAN; nIndex++)
                        {
                           oAssociate = GetAssociate(ASSOCIATE_TYPE_HENCHMAN, oPC, nIndex);
                           if(oAssociate != OBJECT_INVALID)
                           {
                                ai_RemoveASpecificEffect(oAssociate, EFFECT_TYPE_CUTSCENEGHOST);
                                DeleteLocalInt(oAssociate, sGhostModeVarname);
                           }
                        }
                        for(nIndex = 2; nIndex < 6; nIndex++)
                        {
                            oAssociate = GetAssociate(nIndex, oPC);
                            if(oAssociate != OBJECT_INVALID)
                            {
                                ai_RemoveASpecificEffect(oAssociate, EFFECT_TYPE_CUTSCENEGHOST);
                                DeleteLocalInt(oAssociate, sGhostModeVarname);
                            }
                        }
                    }
                    else
                    {
                        SetLocalInt(oPC, sGhostModeVarname, TRUE);
                        ai_SendMessages("Ghost mode is turned on when using commands.", AI_COLOR_YELLOW, oPC);
                    }
                }
                else
                {
                    if(ai_GetAIMode(oPC, AI_MODE_GHOST))
                    {
                        ai_SetAIMode(oPC, AI_MODE_GHOST, FALSE);
                        ai_SendMessages("Ghost mode is turned off when using commands.", AI_COLOR_YELLOW, oPC);
                        object oAssociate;
                        int nIndex;
                        for(nIndex = 1; nIndex <= AI_MAX_HENCHMAN; nIndex++)
                        {
                           oAssociate = GetAssociate(ASSOCIATE_TYPE_HENCHMAN, oPC, nIndex);
                           if(oAssociate != OBJECT_INVALID)
                           {
                                ai_RemoveASpecificEffect(oAssociate, EFFECT_TYPE_CUTSCENEGHOST);
                                DeleteLocalInt(oAssociate, sGhostModeVarname);
                           }
                        }
                        for(nIndex = 2; nIndex < 6; nIndex++)
                        {
                            oAssociate = GetAssociate(nIndex, oPC);
                            if(oAssociate != OBJECT_INVALID)
                            {
                                ai_RemoveASpecificEffect(oAssociate, EFFECT_TYPE_CUTSCENEGHOST);
                                DeleteLocalInt(oAssociate, sGhostModeVarname);
                            }
                        }
                    }
                    else
                    {
                        ai_SetAIMode(oPC, AI_MODE_GHOST, TRUE);
                        ai_SendMessages("Ghost mode is turned on when using commands.", AI_COLOR_YELLOW, oPC);
                    }
                    aiSaveAssociateAIModesToDb(oPC, oPC);
                }

            }
            else if(sElem == "btn_toggle_assoc_widget")
            {
                int bWidgetOff = !ai_GetWidgetButton(oPC, BTN_WIDGET_OFF, oPC, "pc");
                ai_SetWidgetButton(oPC, BTN_WIDGET_OFF, oPC, "pc", bWidgetOff);
                object oAssoc = GetAssociate(ASSOCIATE_TYPE_FAMILIAR, oPC);
                if(oAssoc != OBJECT_INVALID)
                {
                    ai_SetWidgetButton(oPC, BTN_WIDGET_OFF, oAssoc, "familiar", bWidgetOff);
                    if(bWidgetOff) IsWindowClosed(oPC, "familiar_widget");
                    else ai_CreateWidgetNUI(oPC, oAssoc);
                }
                oAssoc = GetAssociate(ASSOCIATE_TYPE_ANIMALCOMPANION, oPC);
                if(oAssoc != OBJECT_INVALID)
                {
                    ai_SetWidgetButton(oPC, BTN_WIDGET_OFF, oAssoc, "companion", bWidgetOff);
                    if(bWidgetOff) IsWindowClosed(oPC, "companion_widget");
                    else ai_CreateWidgetNUI(oPC, oAssoc);
                }
                oAssoc = GetAssociate(ASSOCIATE_TYPE_SUMMONED, oPC);
                if(oAssoc != OBJECT_INVALID)
                {
                    ai_SetWidgetButton(oPC, BTN_WIDGET_OFF, oAssoc, "summons", bWidgetOff);
                    if(bWidgetOff) IsWindowClosed(oPC, "summons_widget");
                    else ai_CreateWidgetNUI(oPC, oAssoc);
                }
                int nIndex;
                string sTag;
                object oHenchman;
                for(nIndex = 1; nIndex <= AI_MAX_HENCHMAN; nIndex++)
                {
                    oHenchman = GetAssociate(ASSOCIATE_TYPE_HENCHMAN, oPC, nIndex);
                    if(oHenchman != OBJECT_INVALID)
                    {
                        sTag = GetTag(oHenchman);
                        ai_SetWidgetButton(oPC, BTN_WIDGET_OFF, oHenchman, sTag, bWidgetOff);
                        if(bWidgetOff) IsWindowClosed(oPC, sTag + "_widget");
                        else ai_CreateWidgetNUI(oPC, oHenchman);
                    }
                }
            }
            else if(sElem == "btn_add_plugin")
            {
                string sScript = JsonGetString(NuiGetBind (oPC, nToken, "txt_plugin"));
                if(sScript == "") ai_SendMessages("You must type the name of the script!", AI_COLOR_RED, oPC);
                else if(ResManGetAliasFor(sScript, RESTYPE_NCS) == "")
                {
                    ai_SendMessages("The script was not found by ResMan!", AI_COLOR_RED, oPC);
                }
                else
                {
                    json jPlugins = ai_GetAssociateDbJson(oPC, "pc", "plugins");
                    if(JsonGetType(jPlugins) == JSON_TYPE_NULL) jPlugins = JsonArray();
                    else
                    {
                        int nIndex;
                        string sSavedScript = JsonGetString(JsonArrayGet(jPlugins, 0));
                        while(sSavedScript != "")
                        {
                            if(sSavedScript == sScript)
                            {
                                ai_SendMessages("This plugin is already installed!", AI_COLOR_RED, oPC);
                                return;
                            }
                            sSavedScript = JsonGetString(JsonArrayGet(jPlugins, ++nIndex));
                        }
                    }
                    JsonArrayInsertInplace(jPlugins, JsonString(sScript));
                    ai_SetAssociateDbJson(oPC, "pc", "plugins", jPlugins);
                    NuiDestroy(oPC, nToken);
                    ai_CreateAIOptionsNUI(oPC);
                    NuiDestroy(oPC, NuiFindWindow(oPC, "pc_widget"));
                    ai_CreateWidgetNUI(oPC, oPC);
                }
            }
            else if(GetStringLeft(sElem, 18) == "btn_remove_plugin_")
            {
                int nIndex = StringToInt(GetStringRight(sElem, 1));
                json jPlugins = ai_GetAssociateDbJson(oPC, "pc", "plugins");
                JsonArrayDelInplace(jPlugins, nIndex - 1);
                ai_SetAssociateDbJson(oPC, "pc", "plugins", jPlugins);
                NuiDestroy(oPC, nToken);
                ai_CreateAIOptionsNUI(oPC);
                NuiDestroy(oPC, NuiFindWindow(oPC, "pc_widget"));
                ai_CreateWidgetNUI(oPC, oPC);
            }
        }
        if(sEvent == "watch")
        {
            if(sElem == "txt_max_henchman")
            {
                int nMaxHenchman = StringToInt(JsonGetString(NuiGetBind(oPC, nToken, sElem)));
                if(nMaxHenchman < 1) nMaxHenchman = 1;
                if(nMaxHenchman > 12)
                {
                    nMaxHenchman = 12;
                    ai_SendMessages("The maximum henchman for this mod is 12!", AI_COLOR_RED, oPC);
                }
                SetMaxHenchmen(nMaxHenchman);
                ai_SendMessages("Maximum henchman has been changed to " + IntToString(nMaxHenchman), AI_COLOR_YELLOW, oPC);
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
                else if(fDistance > 40.0) fDistance = 40.0;
                SetLocalFloat(GetModule(), AI_RULE_PERCEPTION_DISTANCE, fDistance);
                json jRules = ai_GetCampaignDbJson("rules");
                JsonObjectSetInplace(jRules, AI_RULE_PERCEPTION_DISTANCE, JsonFloat(fDistance));
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
    }
    //**************************************************************************
    // Associate Command events.
    else if(sWndId == sAssociateType + "_cmd_menu")
    {
        if(sEvent == "click")
        {
            if(sElem == "btn_widget_lock")
            {
                if(ai_GetWidgetButton(oPC, BTN_WIDGET_LOCK, oAssociate, sAssociateType))
                {
                    SendMessageToPC(oPC, GetName(oAssociate) + " AI widget unlocked.");
                    ai_SetWidgetButton(oPC, BTN_WIDGET_LOCK, oAssociate, sAssociateType, FALSE);
                    if(!ai_GetWidgetButton(oPC, BTN_WIDGET_OFF, oAssociate, sAssociateType))
                    {
                        NuiDestroy(oPC, NuiFindWindow(oPC, sAssociateType + "_widget"));
                        ai_CreateWidgetNUI(oPC, oAssociate);
                    }
                }
                else
                {
                    // Get the height, width, x, and y of the window.
                    json jGeom = NuiGetBind(oPC, NuiFindWindow(oPC, sAssociateType + "_widget"), "window_geometry");
                    // Save the window location on the player using the sWndId.
                    SetLocalFloat(oPC, sWndId + "_X", JsonGetFloat (JsonObjectGet (jGeom, "x")));
                    SetLocalFloat(oPC, sWndId + "_Y", JsonGetFloat (JsonObjectGet (jGeom, "y")));
                    SendMessageToPC(oPC, GetName(oAssociate) + " AI widget locked.");
                    ai_SetWidgetButton(oPC, BTN_WIDGET_LOCK, oAssociate, sAssociateType, TRUE);
                    if(!ai_GetWidgetButton(oPC, BTN_WIDGET_OFF, oAssociate, sAssociateType))
                    {
                        NuiDestroy(oPC, NuiFindWindow(oPC, sAssociateType + "_widget"));
                        ai_CreateWidgetNUI(oPC, oAssociate);
                    }
                }
            }
            else if(sElem == "btn_options")
            {
                if(ai_GetIsCharacter(oAssociate))
                {
                    NuiDestroy(oPC, nToken);
                    ai_CreateAIOptionsNUI(oPC);
                }
                else
                {
                    ai_ToggleAssociateWidgetOnOff(oPC, nToken, sAssociateType);
                }
            }
            else if(sElem == "btn_ai_options")
            {
                NuiDestroy(oPC, nToken);
                ai_CreateAssociateAINUI(oPC, oAssociate);
            }
            else if(sElem == "btn_copy_settings")
            {
                ai_CreatePasteSettingsNUI(oPC, oAssociate);
            }
            else if(sElem == "btn_cmd_action") ai_Action(oPC, oAssociate);
            else if(sElem == "btn_cmd_guard") ai_DoCommand(oPC, oAssociate, 1);
            else if(sElem == "btn_cmd_hold") ai_DoCommand(oPC, oAssociate, 3);
            else if(sElem == "btn_cmd_search") ai_DoCommand(oPC, oAssociate, 5);
            else if(sElem == "btn_cmd_stealth") ai_DoCommand(oPC, oAssociate, 6);
            else if(sElem == "btn_cmd_attack") ai_DoCommand(oPC, oAssociate, 4);
            else if(sElem == "btn_cmd_follow") ai_DoCommand(oPC, oAssociate, 2);
            else if(sElem == "btn_follow_target") ai_FollowTarget(oPC, oAssociate);
            else if(sElem == "btn_cmd_ai_script") ai_AIScript(oPC, oAssociate, sAssociateType);
            else if(sElem == "btn_cmd_place_trap") ai_HavePCPlaceTrap(oPC, oAssociate);
            else if(sElem == "btn_buff_short") ai_Buff_Button(oPC, oAssociate, 2, sAssociateType);
            else if(sElem == "btn_buff_long") ai_Buff_Button(oPC, oAssociate, 3, sAssociateType);
            else if(sElem == "btn_buff_all") ai_Buff_Button(oPC, oAssociate, 1, sAssociateType);
            else if(sElem == "btn_buff_rest") ai_Buff_Button(oPC, oAssociate, 0, sAssociateType);
            else if(sElem == "btn_camera") ai_ChangeCameraView(oPC, oAssociate);
            else if(sElem == "btn_inventory") ai_OpenInventory(oAssociate, oPC);
            else if(sElem == "btn_familiar_name") ai_SetCompanionName(oPC, oAssociate, nToken, ASSOCIATE_TYPE_FAMILIAR);
            else if(sElem == "btn_companion_name") ai_SetCompanionName(oPC, oAssociate, nToken, ASSOCIATE_TYPE_ANIMALCOMPANION);
        }
        else if(sEvent == "watch")
        {
            if(sElem == "txt_familiar_name")
            {
                string sName = JsonGetString(NuiGetBind(oPC, nToken, sElem));
                if(sName != "") NuiSetBind(oPC, nToken, "btn_familiar_name_event", JsonBool(TRUE));
                else NuiSetBind(oPC, nToken, "btn_familiar_name_event", JsonBool(FALSE));
            }
            else if(sElem == "chbx_buff_rest_check") ai_SetWidgetButtonToCheckbox(oPC, BTN_BUFF_REST, oAssociate, sAssociateType, nToken, sElem);
            else if(sElem == "chbx_cmd_action_check") ai_SetWidgetButtonToCheckbox(oPC, BTN_CMD_ACTION, oAssociate, sAssociateType, nToken, sElem);
            else if(sElem == "chbx_cmd_guard_check") ai_SetWidgetButtonToCheckbox(oPC, BTN_CMD_GUARD, oAssociate, sAssociateType, nToken, sElem);
            else if(sElem == "chbx_cmd_hold_check") ai_SetWidgetButtonToCheckbox(oPC, BTN_CMD_HOLD, oAssociate, sAssociateType, nToken, sElem);
            else if(sElem == "chbx_cmd_search_check") ai_SetWidgetButtonToCheckbox(oPC, BTN_CMD_SEARCH, oAssociate, sAssociateType, nToken, sElem);
            else if(sElem == "chbx_cmd_stealth_check") ai_SetWidgetButtonToCheckbox(oPC, BTN_CMD_STEALTH, oAssociate, sAssociateType, nToken, sElem);
            else if(sElem == "chbx_cmd_attack_check") ai_SetWidgetButtonToCheckbox(oPC, BTN_CMD_ATTACK, oAssociate, sAssociateType, nToken, sElem);
            else if(sElem == "chbx_cmd_follow_check") ai_SetWidgetButtonToCheckbox(oPC, BTN_CMD_FOLLOW, oAssociate, sAssociateType, nToken, sElem);
            else if(sElem == "chbx_cmd_ai_script_check") ai_SetWidgetButtonToCheckbox(oPC, BTN_CMD_AI_SCRIPT, oAssociate, sAssociateType, nToken, sElem);
            else if(sElem == "chbx_cmd_place_trap_check") ai_SetWidgetButtonToCheckbox(oPC, BTN_CMD_PLACE_TRAP, oAssociate, sAssociateType, nToken, sElem);
            else if(sElem == "chbx_follow_target_check") ai_SetAIButtonToCheckbox(oPC, BTN_AI_FOLLOW_TARGET, oAssociate, sAssociateType, nToken, sElem);
            else if(sElem == "chbx_buff_short_check") ai_SetWidgetButtonToCheckbox(oPC, BTN_BUFF_SHORT, oAssociate, sAssociateType, nToken, sElem);
            else if(sElem == "chbx_buff_long_check") ai_SetWidgetButtonToCheckbox(oPC, BTN_BUFF_LONG, oAssociate, sAssociateType, nToken, sElem);
            else if(sElem == "chbx_buff_all_check") ai_SetWidgetButtonToCheckbox(oPC, BTN_BUFF_ALL, oAssociate, sAssociateType, nToken, sElem);
            else if(sElem == "chbx_camera_check") ai_SetWidgetButtonToCheckbox(oPC, BTN_CMD_CAMERA, oAssociate, sAssociateType, nToken, sElem);
            else if(sElem == "chbx_inventory_check") ai_SetWidgetButtonToCheckbox(oPC, BTN_CMD_INVENTORY, oAssociate, sAssociateType, nToken, sElem);
            else if(sElem == "chbx_familiar_check") ai_SetWidgetButtonToCheckbox(oPC, BTN_CMD_FAMILIAR, oAssociate, sAssociateType, nToken, sElem);
            else if(sElem == "chbx_companion_check") ai_SetWidgetButtonToCheckbox(oPC, BTN_CMD_COMPANION, oAssociate, sAssociateType, nToken, sElem);
            else if(sElem == "cmb_familiar_selected") ai_SetCompanionType(oPC, oAssociate, nToken, ASSOCIATE_TYPE_FAMILIAR);
            else if(sElem == "cmb_companion_selected") ai_SetCompanionType(oPC, oAssociate, nToken, ASSOCIATE_TYPE_ANIMALCOMPANION);
            NuiDestroy(oPC, NuiFindWindow(oPC, sAssociateType + "_widget"));
            ai_CreateWidgetNUI(oPC, oAssociate);
        }
        else if(sEvent == "mousescroll")
        {
            float nMouseScroll = JsonGetFloat(JsonObjectGet(JsonObjectGet(NuiGetEventPayload(), "mouse_scroll"), "y"));
            if(nMouseScroll == 1.0) // Scroll up
            {
                // Follow range is only changed on non-pc's
                if(sElem == "btn_cmd_follow" &&
                   oPC != oAssociate) ai_FollowIncrement(oPC, oAssociate, 1.0, sAssociateType);
                else if(sElem == "btn_follow_target") ai_FollowIncrement(oPC, oAssociate, 1.0, sAssociateType);
            }
            else if(nMouseScroll == -1.0) // Scroll down
            {
                // Follow range is only changed on non-pc's
                if(sElem == "btn_cmd_follow" &&
                oPC != oAssociate) ai_FollowIncrement(oPC, oAssociate, -1.0, sAssociateType);
                else if(sElem == "btn_follow_target") ai_FollowIncrement(oPC, oAssociate, -1.0, sAssociateType);
            }
        }
    }
    //**************************************************************************
    // Associate AI events.
    else if(sWndId == sAssociateType + "_ai_menu")
    {
        if(sEvent == "click")
        {
            if(sElem == "btn_loot_filter")
            {
                ai_CreateLootFilterNUI(oPC, oAssociate);
            }
            else if(sElem == "btn_ai")
            {
                if(GetEventScript(oAssociate, EVENT_SCRIPT_CREATURE_ON_HEARTBEAT) == "xx_pc_1_hb") ai_TurnOff(oPC, oAssociate, sAssociateType);
                else ai_TurnOn(oPC, oAssociate, sAssociateType);
            }
            else if(sElem == "btn_quiet") ai_ReduceSpeech(oPC, oAssociate, sAssociateType);
            else if(sElem == "btn_ranged") AssignCommand(oAssociate, ai_Ranged(oPC, oAssociate, sAssociateType));
            else if(sElem == "btn_traps") ai_Traps(oPC, oAssociate, sAssociateType);
            else if(sElem == "btn_search") ai_Search(oPC, oAssociate, sAssociateType);
            else if(sElem == "btn_stealth") ai_Stealth(oPC, oAssociate, sAssociateType);
            else if(sElem == "btn_pick_locks") ai_Locks(oPC, oAssociate, sAssociateType, 1);
            else if(sElem == "btn_bash_locks") ai_Locks(oPC, oAssociate, sAssociateType, 2);
            else if(sElem == "btn_no_magic") ai_UseMagic(oPC, oAssociate, TRUE, FALSE, FALSE, sAssociateType);
            else if(sElem == "btn_all_magic") ai_UseMagic(oPC, oAssociate, FALSE, FALSE, FALSE, sAssociateType);
            else if(sElem == "btn_def_magic") ai_UseMagic(oPC, oAssociate, FALSE, TRUE, FALSE, sAssociateType);
            else if(sElem == "btn_off_magic") ai_UseMagic(oPC, oAssociate, FALSE, FALSE, TRUE, sAssociateType);
            else if(sElem == "btn_spontaneous") ai_Spontaneous(oPC, oAssociate, sAssociateType);
            else if(sElem == "btn_heals_onoff") ai_Heal_OnOff(oPC, oAssociate, sAssociateType, 1);
            else if(sElem == "btn_healp_onoff") ai_Heal_OnOff(oPC, oAssociate, sAssociateType, 2);
            else if(sElem == "btn_loot") ai_Loot(oPC, oAssociate, sAssociateType);
            else if(sElem == "btn_ai_script") ai_SaveAIScript(oPC, oAssociate, nToken);
        }
        else if(sEvent == "watch")
        {
            SetLocalInt (oPC, AI_NO_NUI_SAVE, TRUE);
            if(sElem == "chbx_ai_check") ai_SetAIButtonToCheckbox(oPC, BTN_AI_FOR_PC, oAssociate, sAssociateType, nToken, sElem);
            else if(sElem == "chbx_quiet_check") ai_SetAIButtonToCheckbox(oPC, BTN_AI_REDUCE_SPEECH, oAssociate, sAssociateType, nToken, sElem);
            else if(sElem == "chbx_ranged_check") ai_SetAIButtonToCheckbox(oPC, BTN_AI_USE_RANGED, oAssociate, sAssociateType, nToken, sElem);
            else if(sElem == "chbx_traps_check") ai_SetAIButtonToCheckbox(oPC, BTN_AI_REMOVE_TRAPS, oAssociate, sAssociateType, nToken, sElem);
            else if(sElem == "chbx_search_check") ai_SetAIButtonToCheckbox(oPC, BTN_AI_USE_SEARCH, oAssociate, sAssociateType, nToken, sElem);
            else if(sElem == "chbx_stealth_check") ai_SetAIButtonToCheckbox(oPC, BTN_AI_USE_STEALTH, oAssociate, sAssociateType, nToken, sElem);
            else if(sElem == "chbx_pick_locks_check") ai_SetAIButtonToCheckbox(oPC, BTN_AI_PICK_LOCKS, oAssociate, sAssociateType, nToken, sElem);
            else if(sElem == "chbx_bash_locks_check") ai_SetAIButtonToCheckbox(oPC, BTN_AI_BASH_LOCKS, oAssociate, sAssociateType, nToken, sElem);
            else if(sElem == "chbx_magic_level_check") ai_SetAIButtonToCheckbox(oPC, BTN_AI_MAGIC_LEVEL, oAssociate, sAssociateType, nToken, sElem);
            else if(sElem == "chbx_spontaneous_check") ai_SetAIButtonToCheckbox(oPC, BTN_AI_NO_SPONTANEOUS, oAssociate, sAssociateType, nToken, sElem);
            else if(sElem == "chbx_no_magic_check") ai_SetAIButtonToCheckbox(oPC, BTN_AI_NO_MAGIC_USE, oAssociate, sAssociateType, nToken, sElem);
            else if(sElem == "chbx_all_magic_check") ai_SetAIButtonToCheckbox(oPC, BTN_AI_ALL_MAGIC_USE, oAssociate, sAssociateType, nToken, sElem);
            else if(sElem == "chbx_def_magic_check") ai_SetAIButtonToCheckbox(oPC, BTN_AI_DEF_MAGIC_USE, oAssociate, sAssociateType, nToken, sElem);
            else if(sElem == "chbx_off_magic_check") ai_SetAIButtonToCheckbox(oPC, BTN_AI_OFF_MAGIC_USE, oAssociate, sAssociateType, nToken, sElem);
            else if(sElem == "chbx_heal_out_check") ai_SetAIButtonToCheckbox(oPC, BTN_AI_HEAL_OUT, oAssociate, sAssociateType, nToken, sElem);
            else if(sElem == "chbx_heal_in_check") ai_SetAIButtonToCheckbox(oPC, BTN_AI_HEAL_IN, oAssociate, sAssociateType, nToken, sElem);
            else if(sElem == "chbx_heals_onoff_check") ai_SetAIButtonToCheckbox(oPC, BTN_AI_STOP_SELF_HEALING, oAssociate, sAssociateType, nToken, sElem);
            else if(sElem == "chbx_healp_onoff_check") ai_SetAIButtonToCheckbox(oPC, BTN_AI_STOP_PARTY_HEALING, oAssociate, sAssociateType, nToken, sElem);
            else if(sElem == "chbx_loot_check") ai_SetAIButtonToCheckbox(oPC, BTN_AI_LOOT, oAssociate, sAssociateType, nToken, sElem);
            NuiDestroy(oPC, NuiFindWindow(oPC, sAssociateType + "_widget"));
            ai_CreateWidgetNUI(oPC, oAssociate);
        }
        else if(sEvent == "mousescroll")
        {
            float nMouseScroll = JsonGetFloat(JsonObjectGet(JsonObjectGet(NuiGetEventPayload(), "mouse_scroll"), "y"));
            if(nMouseScroll == 1.0) // Scroll up
            {
                if(sElem == "btn_magic_level") ai_MagicIncrement(oPC, oAssociate, 1, sAssociateType);
                else if(sElem == "btn_pick_locks") ai_LockRangeIncrement(oPC, oAssociate, 1.0, sAssociateType);
                else if(sElem == "btn_bash_locks") ai_LockRangeIncrement(oPC, oAssociate, 1.0, sAssociateType);
                else if(sElem == "btn_traps") ai_TrapRangeIncrement(oPC, oAssociate, 1.0, sAssociateType);
                else if(sElem == "btn_heal_out") ai_Heal_Button(oPC, oAssociate, 5, AI_HEAL_OUT_OF_COMBAT_LIMIT, sAssociateType);
                else if(sElem == "btn_heal_in") ai_Heal_Button(oPC, oAssociate, 5, AI_HEAL_IN_COMBAT_LIMIT, sAssociateType);
                else if(sElem == "btn_loot") ai_LootRangeIncrement(oPC, oAssociate, 1.0, sAssociateType);
            }
            else if(nMouseScroll == -1.0) // Scroll down
            {
                if(sElem == "btn_magic_level") ai_MagicIncrement(oPC, oAssociate, -1, sAssociateType);
                else if(sElem == "btn_pick_locks") ai_LockRangeIncrement(oPC, oAssociate, -1.0, sAssociateType);
                else if(sElem == "btn_bash_locks") ai_LockRangeIncrement(oPC, oAssociate, -1.0, sAssociateType);
                else if(sElem == "btn_traps") ai_TrapRangeIncrement(oPC, oAssociate, -1.0, sAssociateType);
                else if(sElem == "btn_heal_out") ai_Heal_Button(oPC, oAssociate, -5, AI_HEAL_OUT_OF_COMBAT_LIMIT, sAssociateType);
                else if(sElem == "btn_heal_in") ai_Heal_Button(oPC, oAssociate, -5, AI_HEAL_IN_COMBAT_LIMIT, sAssociateType);
                else if(sElem == "btn_loot") ai_LootRangeIncrement(oPC, oAssociate, -1.0, sAssociateType);
            }
        }
    }
    //**************************************************************************
    // Associate Widget events.
    else if(sWndId == sAssociateType + "_widget")
    {
        if(sEvent == "click")
        {
            if(sElem == "btn_open_main")
            {
                if(IsWindowClosed(oPC, sAssociateType + "_cmd_menu")) ai_CreateAssociateCommandNUI(oPC, oAssociate);
                IsWindowClosed(oPC, sAssociateType + "_ai_menu");
                IsWindowClosed(oPC, sAssociateType + "_loot_menu");
                IsWindowClosed(oPC, sAssociateType + "_paste_menu");
                if(ai_GetIsCharacter(oAssociate)) IsWindowClosed(oPC, "ai_main_nui");
            }
            else
            {
                if(sElem == "btn_ai")
                {
                    if(GetEventScript(oAssociate, EVENT_SCRIPT_CREATURE_ON_HEARTBEAT) == "xx_pc_1_hb") ai_TurnOff(oPC, oAssociate, sAssociateType);
                    else ai_TurnOn(oPC, oAssociate, sAssociateType);
                }
                else if(sElem == "btn_ranged") AssignCommand(oAssociate, ai_Ranged(oPC, oAssociate, sAssociateType));
                else if(sElem == "btn_search") ai_Search(oPC, oAssociate, sAssociateType);
                else if(sElem == "btn_stealth") ai_Stealth(oPC, oAssociate, sAssociateType);
                else if(sElem == "btn_pick_locks") ai_Locks(oPC, oAssociate, sAssociateType, 1);
                else if(sElem == "btn_bash_locks") ai_Locks(oPC, oAssociate, sAssociateType, 2);
                else if(sElem == "btn_traps") ai_Traps(oPC, oAssociate, sAssociateType);
                else if(sElem == "btn_quiet") ai_ReduceSpeech(oPC, oAssociate, sAssociateType);
                else if(sElem == "btn_magic_minus") ai_MagicIncrement(oPC, oAssociate, -1, sAssociateType);
                else if(sElem == "btn_magic_plus") ai_MagicIncrement(oPC, oAssociate, 1, sAssociateType);
                else if(sElem == "btn_no_magic") ai_UseMagic(oPC, oAssociate, TRUE, FALSE, FALSE, sAssociateType);
                else if(sElem == "btn_all_magic") ai_UseMagic(oPC, oAssociate, FALSE, FALSE, FALSE, sAssociateType);
                else if(sElem == "btn_def_magic") ai_UseMagic(oPC, oAssociate, FALSE, TRUE, FALSE, sAssociateType);
                else if(sElem == "btn_off_magic") ai_UseMagic(oPC, oAssociate, FALSE, FALSE, TRUE, sAssociateType);
                else if(sElem == "btn_loot") ai_Loot(oPC, oAssociate, sAssociateType);
                else if(sElem == "btn_spontaneous") ai_Spontaneous(oPC, oAssociate, sAssociateType);
                else if(sElem == "btn_buff_short") ai_Buff_Button(oPC, oAssociate, 2, sAssociateType);
                else if(sElem == "btn_buff_long") ai_Buff_Button(oPC, oAssociate, 3, sAssociateType);
                else if(sElem == "btn_buff_all") ai_Buff_Button(oPC, oAssociate, 1, sAssociateType);
                else if(sElem == "btn_buff_rest") ai_Buff_Button(oPC, oAssociate, 0, sAssociateType);
                else if(sElem == "btn_camera") ai_ChangeCameraView(oPC, oAssociate);
                else if(sElem == "btn_inventory") ai_OpenInventory(oAssociate, oPC);
                else if(sElem == "btn_familiar")
                {
                    if(GetHasFeat(FEAT_SUMMON_FAMILIAR, oAssociate))
                    {
                        DecrementRemainingFeatUses(oAssociate, FEAT_SUMMON_FAMILIAR);
                        SummonFamiliar(oAssociate);
                    }
                }
                else if(sElem == "btn_companion")
                {
                    if(GetHasFeat(FEAT_ANIMAL_COMPANION, oAssociate))
                    {
                        DecrementRemainingFeatUses(oAssociate, FEAT_ANIMAL_COMPANION);
                        SummonAnimalCompanion(oAssociate);
                    }
                }
                else if(sElem == "btn_heal_out_minus") ai_Heal_Button(oPC, oAssociate, -5, AI_HEAL_OUT_OF_COMBAT_LIMIT, sAssociateType);
                else if(sElem == "btn_heal_out_plus") ai_Heal_Button(oPC, oAssociate, 5, AI_HEAL_OUT_OF_COMBAT_LIMIT, sAssociateType);
                else if(sElem == "btn_heal_in_minus") ai_Heal_Button(oPC, oAssociate, -5, AI_HEAL_IN_COMBAT_LIMIT, sAssociateType);
                else if(sElem == "btn_heal_in_plus") ai_Heal_Button(oPC, oAssociate, 5, AI_HEAL_IN_COMBAT_LIMIT, sAssociateType);
                else if(sElem == "btn_heals_onoff") ai_Heal_OnOff(oPC, oAssociate, sAssociateType, 1);
                else if(sElem == "btn_healp_onoff") ai_Heal_OnOff(oPC, oAssociate, sAssociateType, 2);
                else if(sElem == "btn_cmd_action") ai_Action(oPC, oAssociate);
                else if(sElem == "btn_cmd_guard") ai_DoCommand(oPC, oAssociate, 1);
                else if(sElem == "btn_cmd_hold") ai_DoCommand(oPC, oAssociate, 3);
                else if(sElem == "btn_cmd_search") ai_DoCommand(oPC, oAssociate, 5);
                else if(sElem == "btn_cmd_stealth") ai_DoCommand(oPC, oAssociate, 6);
                else if(sElem == "btn_cmd_attack") ai_DoCommand(oPC, oAssociate, 4);
                else if(sElem == "btn_cmd_follow") ai_DoCommand(oPC, oAssociate, 2);
                else if(sElem == "btn_cmd_ai_script") ai_AIScript(oPC, oAssociate, sAssociateType);
                else if(sElem == "btn_cmd_place_trap") ai_HavePCPlaceTrap(oPC, oAssociate);
                else if(sElem == "btn_follow_target") ai_FollowTarget(oPC, oAssociate);
                else if(sElem == "btn_loot_range_minus") ai_LootRangeIncrement(oPC, oAssociate, -1.0, sAssociateType);
                else if(sElem == "btn_loot_range_plus") ai_LootRangeIncrement(oPC, oAssociate, 1.0, sAssociateType);
                else if(sElem == "btn_lock_range_minus") ai_LockRangeIncrement(oPC, oAssociate, -1.0, sAssociateType);
                else if(sElem == "btn_lock_range_plus") ai_LockRangeIncrement(oPC, oAssociate, 1.0, sAssociateType);
                else if(sElem == "btn_trap_range_minus") ai_TrapRangeIncrement(oPC, oAssociate, -1.0, sAssociateType);
                else if(sElem == "btn_trap_range_plus") ai_TrapRangeIncrement(oPC, oAssociate, 1.0, sAssociateType);
                else if(GetStringLeft(sElem, 15) == "btn_exe_plugin_") ai_PlugIn_Execute(oPC, sElem);
            }
        }
        if(sEvent == "mousedown")
        {
            int nMouseButton = JsonGetInt(JsonObjectGet(NuiGetEventPayload(), "mouse_btn"));
            if(nMouseButton == NUI_MOUSE_BUTTON_RIGHT)
            {
                if(sElem == "btn_open_main")
                {
                    if(IsWindowClosed(oPC, sAssociateType + "_ai_menu")) ai_CreateAssociateAINUI(oPC, oAssociate);
                    if(sElem == "btn_follow_range") ai_FollowIncrement(oPC, oAssociate, -1.0, sAssociateType);
                }
            }
        }
        if(sEvent == "mousescroll")
        {
            float nMouseScroll = JsonGetFloat(JsonObjectGet(JsonObjectGet(NuiGetEventPayload(), "mouse_scroll"), "y"));
            if(nMouseScroll == 1.0) // Scroll up
            {
                if(sElem == "btn_cmd_follow" &&
                   oPC != oAssociate) ai_FollowIncrement(oPC, oAssociate, 1.0, sAssociateType);
                else if(sElem == "btn_follow_target") ai_FollowIncrement(oPC, oAssociate, 1.0, sAssociateType);
                else if(sElem == "btn_magic_level") ai_MagicIncrement(oPC, oAssociate, 1, sAssociateType);
                else if(sElem == "btn_pick_locks") ai_LockRangeIncrement(oPC, oAssociate, 1.0, sAssociateType);
                else if(sElem == "btn_bash_locks") ai_LockRangeIncrement(oPC, oAssociate, 1.0, sAssociateType);
                else if(sElem == "btn_traps") ai_TrapRangeIncrement(oPC, oAssociate, 1.0, sAssociateType);
                else if(sElem == "btn_heal_out") ai_Heal_Button(oPC, oAssociate, 5, AI_HEAL_OUT_OF_COMBAT_LIMIT, sAssociateType);
                else if(sElem == "btn_heal_in") ai_Heal_Button(oPC, oAssociate, 5, AI_HEAL_IN_COMBAT_LIMIT, sAssociateType);
                else if(sElem == "btn_loot") ai_LootRangeIncrement(oPC, oAssociate, 1.0, sAssociateType);
            }
            if(nMouseScroll == -1.0) // Scroll down
            {
                if(sElem == "btn_cmd_follow" &&
                   oPC != oAssociate) ai_FollowIncrement(oPC, oAssociate, -1.0, sAssociateType);
                else if(sElem == "btn_follow_target") ai_FollowIncrement(oPC, oAssociate, -1.0, sAssociateType);
                else if(sElem == "btn_magic_plus") ai_MagicIncrement(oPC, oAssociate, -1, sAssociateType);
                if(sElem == "btn_magic_level") ai_MagicIncrement(oPC, oAssociate, -1, sAssociateType);
                else if(sElem == "btn_pick_locks") ai_LockRangeIncrement(oPC, oAssociate, -1.0, sAssociateType);
                else if(sElem == "btn_bash_locks") ai_LockRangeIncrement(oPC, oAssociate, -1.0, sAssociateType);
                else if(sElem == "btn_traps") ai_TrapRangeIncrement(oPC, oAssociate, -1.0, sAssociateType);
                else if(sElem == "btn_heal_out") ai_Heal_Button(oPC, oAssociate, -5, AI_HEAL_OUT_OF_COMBAT_LIMIT, sAssociateType);
                else if(sElem == "btn_heal_in") ai_Heal_Button(oPC, oAssociate, -5, AI_HEAL_IN_COMBAT_LIMIT, sAssociateType);
                else if(sElem == "btn_loot") ai_LootRangeIncrement(oPC, oAssociate, -1.0, sAssociateType);
            }
        }
    }
    //**************************************************************************
    // Associate Loot events.
    else if(sWndId == sAssociateType + "_loot_menu")
    {
        if(sEvent == "click")
        {
            if(sElem == "btn_set_all")
            {
                SetLocalInt(oPC, "AI_BLOCK_CHECKS", TRUE);
                SetLocalInt(oAssociate, sLootFilterVarname, 65535);
                int nIndex;
                for(nIndex = 2; nIndex < 20; nIndex++)
                {
                    NuiSetBind(oPC, nToken, "chbx_" + IntToString(nIndex) + "_check", JsonBool (TRUE));
                }
                json jLootFilter = ai_GetAssociateDbJson(oPC, sAssociateType, "lootfilters");
                JsonArraySetInplace(jLootFilter, 1, JsonInt(65535));
                ai_SetAssociateDbJson(oPC, sAssociateType, "lootfilters", jLootFilter);
                DelayCommand(1.0, DeleteLocalInt(oPC, "AI_BLOCK_CHECKS"));
            }
            else if(sElem == "btn_clear_all")
            {
                SetLocalInt(oPC, "AI_BLOCK_CHECKS", TRUE);
                SetLocalInt(oAssociate, sLootFilterVarname, 0);
                int nIndex;
                for(nIndex = 2; nIndex < 20; nIndex++)
                {
                    NuiSetBind(oPC, nToken, "chbx_" + IntToString(nIndex) + "_check", JsonBool (FALSE));
                }
                json jLootFilter = ai_GetAssociateDbJson(oPC, sAssociateType, "lootfilters");
                JsonArraySetInplace(jLootFilter, 1, JsonInt(0));
                ai_SetAssociateDbJson(oPC, sAssociateType, "lootfilters", jLootFilter);
                DelayCommand(1.0, DeleteLocalInt(oPC, "AI_BLOCK_CHECKS"));
            }
        }
        else if(sEvent == "watch")
        {
            if(GetStringLeft(sElem, 5) == "chbx_")
            {
                if(GetLocalInt(oPC, "AI_BLOCK_CHECKS")) return;
                if(sElem == "chbx_2_check") ai_SetLootFilterToCheckbox(oPC, oAssociate, AI_LOOT_PLOT, nToken, sElem);
                else if(sElem == "chbx_3_check") ai_SetLootFilterToCheckbox(oPC, oAssociate, AI_LOOT_ARMOR, nToken, sElem);
                else if(sElem == "chbx_4_check") ai_SetLootFilterToCheckbox(oPC, oAssociate, AI_LOOT_BELTS, nToken, sElem);
                else if(sElem == "chbx_5_check") ai_SetLootFilterToCheckbox(oPC, oAssociate, AI_LOOT_BOOTS, nToken, sElem);
                else if(sElem == "chbx_6_check") ai_SetLootFilterToCheckbox(oPC, oAssociate, AI_LOOT_CLOAKS, nToken, sElem);
                else if(sElem == "chbx_7_check") ai_SetLootFilterToCheckbox(oPC, oAssociate, AI_LOOT_GEMS, nToken, sElem);
                else if(sElem == "chbx_8_check") ai_SetLootFilterToCheckbox(oPC, oAssociate, AI_LOOT_GLOVES, nToken, sElem);
                else if(sElem == "chbx_9_check") ai_SetLootFilterToCheckbox(oPC, oAssociate, AI_LOOT_HEADGEAR, nToken, sElem);
                else if(sElem == "chbx_10_check") ai_SetLootFilterToCheckbox(oPC, oAssociate, AI_LOOT_JEWELRY, nToken, sElem);
                else if(sElem == "chbx_11_check") ai_SetLootFilterToCheckbox(oPC, oAssociate, AI_LOOT_MISC, nToken, sElem);
                else if(sElem == "chbx_12_check") ai_SetLootFilterToCheckbox(oPC, oAssociate, AI_LOOT_POTIONS, nToken, sElem);
                else if(sElem == "chbx_13_check") ai_SetLootFilterToCheckbox(oPC, oAssociate, AI_LOOT_SCROLLS, nToken, sElem);
                else if(sElem == "chbx_14_check") ai_SetLootFilterToCheckbox(oPC, oAssociate, AI_LOOT_SHIELDS, nToken, sElem);
                else if(sElem == "chbx_15_check") ai_SetLootFilterToCheckbox(oPC, oAssociate, AI_LOOT_WANDS_RODS_STAVES, nToken, sElem);
                else if(sElem == "chbx_16_check") ai_SetLootFilterToCheckbox(oPC, oAssociate, AI_LOOT_WEAPONS, nToken, sElem);
                else if(sElem == "chbx_17_check") ai_SetLootFilterToCheckbox(oPC, oAssociate, AI_LOOT_ARROWS, nToken, sElem);
                else if(sElem == "chbx_18_check") ai_SetLootFilterToCheckbox(oPC, oAssociate, AI_LOOT_BOLTS, nToken, sElem);
                else if(sElem == "chbx_19_check") ai_SetLootFilterToCheckbox(oPC, oAssociate, AI_LOOT_BULLETS, nToken, sElem);
                json jLootFilter = ai_GetAssociateDbJson(oPC, sAssociateType, "lootfilters");
                int nLootFilter = GetLocalInt(oAssociate, sLootFilterVarname);
                JsonArraySetInplace(jLootFilter, 1, JsonInt(nLootFilter));
                ai_SetAssociateDbJson(oPC, sAssociateType, "lootfilters", jLootFilter);
            }
            else if(GetStringLeft(sElem, 4) == "txt_")
            {
                if(sElem == "txt_max_weight")
                {
                    int nMaxWeight = StringToInt(JsonGetString(NuiGetBind(oPC, nToken, sElem)));
                    if(nMaxWeight > 1000) nMaxWeight = 1000;
                    if(nMaxWeight < 1) nMaxWeight = 1;
                    SetLocalInt(oAssociate, AI_MAX_LOOT_WEIGHT, nMaxWeight);
                    json jLootFilters = ai_GetAssociateDbJson(oPC, sAssociateType, "lootfilters");
                    JsonArraySetInplace(jLootFilters, 0, JsonInt(nMaxWeight));
                    ai_SetAssociateDbJson(oPC, sAssociateType, "lootfilters", jLootFilters);
                    return;
                }
                if(GetStringLeft(sElem, 9) == "txt_gold_")
                {
                    int nAmount = StringToInt(JsonGetString(NuiGetBind(oPC, nToken, sElem)));
                    int nIndex;
                    if(GetStringLength(sElem) == 11) nIndex = StringToInt(GetStringRight(sElem, 2));
                    else nIndex = StringToInt(GetStringRight(sElem, 1));
                    SetLocalInt(oAssociate, AI_MIN_GOLD_ + IntToString(nIndex), nAmount);
                    json jLootFilters = ai_GetAssociateDbJson(oPC, sAssociateType, "lootfilters");
                    JsonArraySetInplace(jLootFilters, nIndex, JsonInt(nAmount));
                    ai_SetAssociateDbJson(oPC, sAssociateType, "lootfilters", jLootFilters);
                }
            }
        }
    }
    //**************************************************************************
    // Associate Paste events.
    else if(sWndId == sAssociateType + "_paste_menu")
    {
        if(sEvent == "click")
        {
            string sAssociateType = ai_GetAssociateType(oPC, oAssociate);
            object oAssoc;
            json jModes = ai_GetAssociateDbJson(oPC, sAssociateType, "modes");
            json jButtons = JsonArray();
            int nWidgetButtons = GetLocalInt(oAssociate, sWidgetButtonsVarname);
            int nAIButtons = GetLocalInt(oAssociate, sAIButtonsVarname);
            JsonArrayInsertInplace(jButtons, JsonInt(nWidgetButtons)); // Command buttons.
            JsonArrayInsertInplace(jButtons, JsonInt(nAIButtons)); // AI buttons.
            json jAIData = ai_GetAssociateDbJson(oPC, sAssociateType, "aidata");
            json jLootFilters = ai_GetAssociateDbJson(oPC, sAssociateType, "lootfilters");
            if(sElem == "btn_paste_all")
            {
                if(sAssociateType != "familiar")
                {
                    ai_SetAssociateDbJson(oPC, "familiar", "modes", jModes);
                    ai_SetAssociateDbJson(oPC, "familiar", "buttons", jButtons);
                    ai_SetAssociateDbJson(oPC, "familiar", "aidata", jAIData);
                    ai_SetAssociateDbJson(oPC, "familiar", "lootfilters", jLootFilters);
                    oAssoc = GetAssociate(ASSOCIATE_TYPE_FAMILIAR, oPC);
                    if(oAssoc != OBJECT_INVALID)
                    {
                        SetLocalInt(oAssoc, sWidgetButtonsVarname, nWidgetButtons);
                        SetLocalInt(oAssoc, sAIButtonsVarname, nAIButtons);
                        ai_GetAssociateDataFromDB(oPC, oAssoc);
                        if(!ai_GetWidgetButton(oPC, BTN_WIDGET_OFF, oAssoc, "familiar"))
                        {
                            NuiDestroy(oPC, NuiFindWindow(oPC, "familiar_widget"));
                            ai_CreateWidgetNUI(oPC, oAssoc);
                        }
                    }
                }
                if(sAssociateType != "companion")
                {
                    ai_SetAssociateDbJson(oPC, "companion", "modes", jModes);
                    ai_SetAssociateDbJson(oPC, "companion", "buttons", jButtons);
                    ai_SetAssociateDbJson(oPC, "companion", "aidata", jAIData);
                    ai_SetAssociateDbJson(oPC, "companion", "lootfilters", jLootFilters);
                    oAssoc = GetAssociate(ASSOCIATE_TYPE_ANIMALCOMPANION, oPC);
                    if(oAssoc != OBJECT_INVALID)
                    {
                        SetLocalInt(oAssoc, sWidgetButtonsVarname, nWidgetButtons);
                        SetLocalInt(oAssoc, sAIButtonsVarname, nAIButtons);
                        ai_GetAssociateDataFromDB(oPC, oAssoc);
                        if(!ai_GetWidgetButton(oPC, BTN_WIDGET_OFF, oAssoc, "companion"))
                        {
                            NuiDestroy(oPC, NuiFindWindow(oPC, "companion_widget"));
                            ai_CreateWidgetNUI(oPC, oAssoc);
                        }
                    }
                }
                if(sAssociateType != "summons")
                {
                    ai_SetAssociateDbJson(oPC, "summons", "modes", jModes);
                    ai_SetAssociateDbJson(oPC, "summons", "buttons", jButtons);
                    ai_SetAssociateDbJson(oPC, "summons", "aidata", jAIData);
                    ai_SetAssociateDbJson(oPC, "summons", "lootfilters", jLootFilters);
                    oAssoc = GetAssociate(ASSOCIATE_TYPE_SUMMONED, oPC);
                    if(oAssoc != OBJECT_INVALID)
                    {
                        SetLocalInt(oAssoc, sWidgetButtonsVarname, nWidgetButtons);
                        SetLocalInt(oAssoc, sAIButtonsVarname, nAIButtons);
                        ai_GetAssociateDataFromDB(oPC, oAssoc);
                        if(!ai_GetWidgetButton(oPC, BTN_WIDGET_OFF, oAssoc, "summons"))
                        {
                            NuiDestroy(oPC, NuiFindWindow(oPC, "summons_widget"));
                            ai_CreateWidgetNUI(oPC, oAssoc);
                        }
                    }
                }
                int nIndex;
                string sTag;
                for(nIndex = 1; nIndex <= AI_MAX_HENCHMAN; nIndex++)
                {
                    oAssoc = GetAssociate(ASSOCIATE_TYPE_HENCHMAN, oPC, nIndex);
                    if(oAssoc != OBJECT_INVALID)
                    {
                        sTag = GetTag(oAssoc);
                        ai_SetAssociateDbJson(oPC, sTag, "modes", jModes);
                        ai_SetAssociateDbJson(oPC, sTag, "buttons", jButtons);
                        ai_SetAssociateDbJson(oPC, sTag, "aidata", jAIData);
                        ai_SetAssociateDbJson(oPC, sTag, "lootfilters", jLootFilters);
                        SetLocalInt(oAssoc, sWidgetButtonsVarname, nWidgetButtons);
                        SetLocalInt(oAssoc, sAIButtonsVarname, nAIButtons);
                        ai_GetAssociateDataFromDB(oPC, oAssoc);
                        if(!ai_GetWidgetButton(oPC, BTN_WIDGET_OFF, oAssoc, sTag))
                        {
                            NuiDestroy(oPC, NuiFindWindow(oPC, sTag + "_widget"));
                            ai_CreateWidgetNUI(oPC, oAssoc);
                        }
                    }
                }
                ai_SendMessages(GetName(oAssociate) + "'s settings have been copied to all associates.", AI_COLOR_GREEN, oPC);
            }
            else if(sElem == "btn_paste_familiar")
            {
                ai_SetAssociateDbJson(oPC, "familiar", "modes", jModes);
                ai_SetAssociateDbJson(oPC, "familiar", "buttons", jButtons);
                ai_SetAssociateDbJson(oPC, "familiar", "aidata", jAIData);
                ai_SetAssociateDbJson(oPC, "familiar", "lootfilters", jLootFilters);
                oAssoc = GetAssociate(ASSOCIATE_TYPE_FAMILIAR, oPC);
                if(oAssoc != OBJECT_INVALID)
                {
                    SetLocalInt(oAssoc, sWidgetButtonsVarname, nWidgetButtons);
                    SetLocalInt(oAssoc, sAIButtonsVarname, nAIButtons);
                    ai_GetAssociateDataFromDB(oPC, oAssoc);
                    if(!ai_GetWidgetButton(oPC, BTN_WIDGET_OFF, oAssoc, "familiar"))
                    {
                        NuiDestroy(oPC, NuiFindWindow(oPC, "familiar_widget"));
                        ai_CreateWidgetNUI(oPC, oAssoc);
                    }
                }
                ai_SendMessages(GetName(oAssociate) + "'s settings have been copied to familiar.", AI_COLOR_GREEN, oPC);
            }
            else if(sElem == "btn_paste_companion")
            {
                ai_SetAssociateDbJson(oPC, "companion", "modes", jModes);
                ai_SetAssociateDbJson(oPC, "companion", "buttons", jButtons);
                ai_SetAssociateDbJson(oPC, "companion", "aidata", jAIData);
                ai_SetAssociateDbJson(oPC, "companion", "lootfilters", jLootFilters);
                oAssoc = GetAssociate(ASSOCIATE_TYPE_ANIMALCOMPANION, oPC);
                if(oAssoc != OBJECT_INVALID)
                {
                    SetLocalInt(oAssoc, sWidgetButtonsVarname, nWidgetButtons);
                    SetLocalInt(oAssoc, sAIButtonsVarname, nAIButtons);
                    ai_GetAssociateDataFromDB(oPC, oAssoc);
                    if(!ai_GetWidgetButton(oPC, BTN_WIDGET_OFF, oAssoc, "companion"))
                    {
                        NuiDestroy(oPC, NuiFindWindow(oPC, "companion_widget"));
                        ai_CreateWidgetNUI(oPC, oAssoc);
                    }
                }
                ai_SendMessages(GetName(oAssociate) + "'s settings have been copied to companion.", AI_COLOR_GREEN, oPC);
            }
            else if(sElem == "btn_paste_summons")
            {
                ai_SetAssociateDbJson(oPC, "summons", "modes", jModes);
                ai_SetAssociateDbJson(oPC, "summons", "buttons", jButtons);
                ai_SetAssociateDbJson(oPC, "summons", "aidata", jAIData);
                ai_SetAssociateDbJson(oPC, "summons", "lootfilters", jLootFilters);
                NuiDestroy(oPC, NuiFindWindow(oPC, "summons_widget"));
                oAssoc = GetAssociate(ASSOCIATE_TYPE_SUMMONED, oPC);
                if(oAssoc != OBJECT_INVALID)
                {
                    SetLocalInt(oAssoc, sWidgetButtonsVarname, nWidgetButtons);
                    SetLocalInt(oAssoc, sAIButtonsVarname, nAIButtons);
                    ai_GetAssociateDataFromDB(oPC, oAssoc);
                    if(!ai_GetWidgetButton(oPC, BTN_WIDGET_OFF, oAssoc, "summons"))
                    {
                        NuiDestroy(oPC, NuiFindWindow(oPC, "companion_widget"));
                        ai_CreateWidgetNUI(oPC, oAssoc);
                    }
                }
                ai_SendMessages(GetName(oAssociate) + "'s settings have been copied to summons.", AI_COLOR_GREEN, oPC);
            }
            else if(GetStringLeft(sElem, 18) == "btn_paste_henchman")
            {
                int nIndex = StringToInt(GetStringRight(sElem, 1));
                object oAssoc = GetAssociate(ASSOCIATE_TYPE_HENCHMAN, oPC, nIndex);
                string sTag = GetTag(oAssoc);
                ai_SetAssociateDbJson(oPC, sTag, "modes", jModes);
                ai_SetAssociateDbJson(oPC, sTag, "buttons", jButtons);
                ai_SetAssociateDbJson(oPC, sTag, "aidata", jAIData);
                ai_SetAssociateDbJson(oPC, sTag, "lootfilters", jLootFilters);
                SetLocalInt(oAssoc, sWidgetButtonsVarname, nWidgetButtons);
                SetLocalInt(oAssoc, sAIButtonsVarname, nAIButtons);
                ai_GetAssociateDataFromDB(oPC, oAssoc);
                if(!ai_GetWidgetButton(oPC, BTN_WIDGET_OFF, oAssoc, sTag))
                {
                    NuiDestroy(oPC, NuiFindWindow(oPC, sTag + "_widget"));
                    ai_CreateWidgetNUI(oPC, oAssoc);
                }
                ai_SendMessages(GetName(oAssociate) + "'s settings have been copied to " + GetName(oAssoc) + ".", AI_COLOR_GREEN, oPC);
            }
        }
    }
}
void ai_SetWidgetButtonToCheckbox(object oPC, int nButton, object oAssociate, string sAssociateType, int nToken, string sElem)
{
    int bCheck = JsonGetInt(NuiGetBind(oPC, nToken, sElem));
    ai_SetWidgetButton(oPC, nButton, oAssociate, sAssociateType, bCheck);
}
void ai_SetAIButtonToCheckbox(object oPC, int nButton, object oAssociate, string sAssociateType, int nToken, string sElem)
{
    int bCheck = JsonGetInt(NuiGetBind(oPC, nToken, sElem));
    ai_SetAIButton(oPC, nButton, oAssociate, sAssociateType, bCheck);
}
void ai_SetAIButton2ToCheckbox(object oPC, int nButton, object oAssociate, string sAssociateType, int nToken, string sElem)
{
    int bCheck = JsonGetInt(NuiGetBind(oPC, nToken, sElem));
    ai_SetAIButton2(oPC, nButton, oAssociate, sAssociateType, bCheck);
}
void ai_SetLootFilterToCheckbox(object oPC, object oAssociate, int nFilterBit, int nToken, string sElem)
{
    int bCheck = JsonGetInt(NuiGetBind(oPC, nToken, sElem));
    ai_SetLootFilter(oAssociate, nFilterBit, bCheck);
}
void ai_AddAssociate(object oPC, json jAssociate, location lLocation, int nToken)
{
    object oAssociate = JsonToObject(jAssociate, lLocation, OBJECT_INVALID, TRUE);
    AddHenchman(oPC, oAssociate);
    DeleteLocalInt(oPC, "AI_IGNORE_NO_ASSOCIATE");
    ai_CreateWidgetNUI(oPC, oAssociate);
    // Save the associate to the nui.
    //json jData = JsonArray();
    //JsonArrayInsertInplace(jData, JsonString(ObjectToString(oAssociate)));
    //NuiSetUserData(oPC, nToken, jData);
    //NuiSetUserData(oPC, NuiFindWindow(oPC, GetTag(oAssociate) + "_widget"), jData);
}
void ai_SetCompanionType(object oPC, object oAssociate, int nToken, int nAssociateType)
{
    if(ai_GetIsCharacter(oAssociate)) return;
    SetLocalInt(oPC, "AI_IGNORE_NO_ASSOCIATE", TRUE);
    string sAssociateType;
    if(nAssociateType == ASSOCIATE_TYPE_FAMILIAR) sAssociateType = "cmb_familiar_selected";
    else if(nAssociateType == ASSOCIATE_TYPE_ANIMALCOMPANION) sAssociateType = "cmb_companion_selected";
    int nSelection = JsonGetInt(NuiGetBind(oPC, nToken, sAssociateType));
    json jAssociate = ObjectToJson(oAssociate, TRUE);
    //ai_Debug("0e_nui", "916", JsonDump(jAssociate, 1));
    jAssociate = GffReplaceInt(jAssociate, "FamiliarType", nSelection);
    location lLocation = GetLocation(oAssociate);
    ai_FireHenchman(oPC, oAssociate);
    object oCompanion = GetAssociate(nAssociateType, oAssociate);
    if(oCompanion != OBJECT_INVALID) DestroyObject(oCompanion);
    SetIsDestroyable(TRUE, FALSE, FALSE, oAssociate);
    DestroyObject(oAssociate);
    DelayCommand(0.1, ai_AddAssociate(oPC, jAssociate, lLocation, nToken));
}
void ai_SetCompanionName(object oPC, object oAssociate, int nToken, int nAssociateType)
{
    if(ai_GetIsCharacter(oAssociate)) return;
    SetLocalInt(oPC, "AI_IGNORE_NO_ASSOCIATE", TRUE);
    string sAssociateType;
    if(nAssociateType == ASSOCIATE_TYPE_FAMILIAR) sAssociateType = "txt_familiar_name";
    else if(nAssociateType == ASSOCIATE_TYPE_ANIMALCOMPANION) sAssociateType = "txt_companion_name";
    string sName = JsonGetString(NuiGetBind(oPC, nToken, sAssociateType));
    json jAssociate = ObjectToJson(oAssociate, TRUE);
    jAssociate = GffReplaceString(jAssociate, "FamiliarName", sName);
    location lLocation = GetLocation(oAssociate);
    ai_FireHenchman(oPC, oAssociate);
    object oCompanion = GetAssociate(nAssociateType, oAssociate);
    if(oCompanion != OBJECT_INVALID) DestroyObject(oCompanion);
    SetIsDestroyable(TRUE, FALSE, FALSE, oAssociate);
    DestroyObject(oAssociate);
    DelayCommand(0.1, ai_AddAssociate(oPC, jAssociate, lLocation, nToken));
}
void ai_TurnOn(object oPC, object oTarget, string sAssociateType)
{
    ai_UpdateToolTipUI(oPC, sAssociateType + "_ai_menu", sAssociateType + "_widget", "btn_ai_tooltip", "  AI On");
    SendMessageToPC(oPC, "AI turned on for " + GetName(oTarget) + ".");
    SetEventScript(oTarget, EVENT_SCRIPT_CREATURE_ON_HEARTBEAT, "xx_pc_1_hb");
    SetEventScript(oTarget, EVENT_SCRIPT_CREATURE_ON_NOTICE, "xx_pc_2_percept");
    SetEventScript(oTarget, EVENT_SCRIPT_CREATURE_ON_END_COMBATROUND, "xx_pc_3_endround");
    SetEventScript(oTarget, EVENT_SCRIPT_CREATURE_ON_DIALOGUE, "xx_pc_4_convers");
    SetEventScript(oTarget, EVENT_SCRIPT_CREATURE_ON_MELEE_ATTACKED, "xx_pc_5_phyatked");
    SetEventScript(oTarget, EVENT_SCRIPT_CREATURE_ON_DAMAGED, "xx_pc_6_damaged");
    //SetEventScript(oTarget, EVENT_SCRIPT_CREATURE_ON_DEATH, "");
    SetEventScript(oTarget, EVENT_SCRIPT_CREATURE_ON_DISTURBED, "xx_pc_8_disturb");
    //SetEventScript(oTarget, EVENT_SCRIPT_CREATURE_ON_SPAWN_IN, "");
    //SetEventScript(oTarget, EVENT_SCRIPT_CREATURE_ON_RESTED, "");
    SetEventScript(oTarget, EVENT_SCRIPT_CREATURE_ON_SPELLCASTAT, "xx_pc_b_castat");
    SetEventScript(oTarget, EVENT_SCRIPT_CREATURE_ON_BLOCKED_BY_DOOR, "xx_pc_e_blocked");
    //SetEventScript(oTarget, EVENT_SCRIPT_CREATURE_ON_USER_DEFINED_EVENT, "");
    // This sets the script for the PC to run AI based on class.
    ai_SetAssociateAIScript(oTarget, FALSE);
    // Set so PC can hear associates talking in combat.
    ai_SetListeningPatterns(oTarget);
}
void ai_TurnOff(object oPC, object oAssociate, string sAssociateType)
{
    ai_UpdateToolTipUI(oPC, sAssociateType + "_ai_menu", sAssociateType + "_widget", "btn_ai_tooltip", "  AI Off");
    SendMessageToPC(oPC, "  AI Turned off for " + GetName(oAssociate) + ".");
    SetEventScript(oAssociate, EVENT_SCRIPT_CREATURE_ON_HEARTBEAT, "");
    SetEventScript(oAssociate, EVENT_SCRIPT_CREATURE_ON_NOTICE, "");
    SetEventScript(oAssociate, EVENT_SCRIPT_CREATURE_ON_END_COMBATROUND, "");
    SetEventScript(oAssociate, EVENT_SCRIPT_CREATURE_ON_DIALOGUE, "");
    SetEventScript(oAssociate, EVENT_SCRIPT_CREATURE_ON_MELEE_ATTACKED, "");
    SetEventScript(oAssociate, EVENT_SCRIPT_CREATURE_ON_DAMAGED, "");
    //SetEventScript(oAssociate, EVENT_SCRIPT_CREATURE_ON_DEATH, "");
    SetEventScript(oAssociate, EVENT_SCRIPT_CREATURE_ON_DISTURBED, "");
    //SetEventScript(oAssociate, EVENT_SCRIPT_CREATURE_ON_SPAWN_IN, "");
    //SetEventScript(oAssociate, EVENT_SCRIPT_CREATURE_ON_RESTED, "");
    SetEventScript(oAssociate, EVENT_SCRIPT_CREATURE_ON_SPELLCASTAT, "");
    SetEventScript(oAssociate, EVENT_SCRIPT_CREATURE_ON_BLOCKED_BY_DOOR, "");
    //SetEventScript(oAssociate, EVENT_SCRIPT_CREATURE_ON_USER_DEFINED_EVENT, "");
    DeleteLocalString(oAssociate, "AIScript");
    ai_ClearCreatureActions();
}

