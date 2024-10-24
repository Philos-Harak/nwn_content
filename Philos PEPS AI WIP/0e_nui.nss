/*//////////////////////////////////////////////////////////////////////////////
 Script Name: 0e_nui
 Programmer: Philos
////////////////////////////////////////////////////////////////////////////////
 Menu event script
    sEvent: close, click, mousedown, mouseup, watch (if bindwatch is set).
/*//////////////////////////////////////////////////////////////////////////////
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
// Will update a tooltip for two menus Made for a menu + the widget.
void ai_UpdateToolTipUI(object oPC, string sWindowID1, string sWindowID2, string sToolTipBind, string sText);
// Gets the colorId from a image of the color pallet.
// Thanks Zunath for the base code.
int GetColorPalletId(object oPC);
// Locks/Unlocks specific buttons when an item has been changed.
void LockItemInCraftingWindow(object oPC, object oItem, int nToken);
// Locks/Unlocks specific buttons when an item has been cleared.
void ClearItemInCraftingWindow(object oPC, object oItem, int nToken);
// Change the button or item based on this buttons special function.
void DoSpecialButton(object oPC, object oItem, int nToken);
// Saves the crafted item for the player removing the original.
void SaveCraftedItem(object oPC, object oTarget, int nToken);
// Can hide or unhide text while crafting.
void HideFeedbackForCraftText(object oPC, int bHidden);
// Turns on oAssociate AI, Setting all event scripts.
void ai_TurnOn(object oPC, object oAssociate, string sAssociateType);
// Turns off oAssociate AI, Setting all event scripts.
void ai_TurnOff(object oPC, object oAssociate, string sAssociateType);
// Increments/Decrements the following distance of associates.
void ai_FollowIncrement(object oPC, object oAssociate, float fIncrement, string sAssociateType);
// Turns on/off Ranged combat for oAssociate.
void ai_Ranged(object oPC, object oAssociate, string sAssociateType);
// Turns on/off Search for oAssociate.
void ai_Search(object oPC, object oAssociate, string sAssociateType);
// Turns on/off Stealth for oAssociate.
void ai_Stealth(object oPC, object oAssociate, string sAssociateType);
// Turns on/off Picking/Bashing locks for oAssociate.
void ai_Locks(object oPC, object oAssociate, string sAssociateType, int nMode);
// Turns on/off Disarming of Traps for oAssociate.
void ai_Traps(object oPC, object oAssociate, string sAssociateType);
// Turns on/off the amount of speaking for oAssociate.
void ai_ReduceSpeech(object oPC, object oAssociate, string sAssociateType);
// Adjust magic use options for oAssociate.
void ai_UseMagic(object oPC, object oAssociate, int bNoMagic, int bDefMagic, int bOffMagic, string sAssociateType);
// Adjusts loot options for oAssociate
void ai_Loot(object oPC, object oAssociate, string sAssociateType);
// Adjust loot options for oAssociate
void ai_Spontaneous(object oPC, object oAssociate, string sAssociateType);
// Increments/Decrements the magic use variable for the AI.
void ai_MagicIncrement(object oPC, object oAssociate, int nIncrement, string sAssociateType);
// Increments/Decrements the Loot Range use variable for the AI.
void ai_LootRangeIncrement(object oPC, object oAssociate, float fIncrement, string sAssociateType);
// Increments/Decrements the Lock Range use variable for the AI.
void ai_LockRangeIncrement(object oPC, object oAssociate, float fIncrement, string sAssociateType);
// Increments/Decrements the Trap Range use variable for the AI.
void ai_TrapRangeIncrement(object oPC, object oAssociate, float fIncrement, string sAssociateType);
// Saves a new AI script for oAssociate.
void ai_SaveAIScript(object oPC, object oAssociate, int nToken);
// Button action for buffing a PC.
void ai_Buff_Button(object oPC, object oAssociate, int nOption, string sAssociateType);
// Button action for setting healing ranges.
void ai_Heal_Button(object oPC, object oAssociate, int nIncrement, string sVar, string sAssociateType);
// Button action for turning healing on/off.
void ai_Heal_OnOff(object oPC, object oAssociate, string sAssociateType, int nMode);
// Button action for selecting a target to follow.
void ai_FollowTarget(object oPC, object oAssociate);
// Button action to allow associates to walk through creatures.
void ai_Ghost_Mode(object oPC, object oAssociate, string sAssociateType);
// Button action for giving commands to associates.
void ai_DoCommand(object oPC, object oAssociate, int nCommand);
// Button action to have associate do an action based on the target via OnPlayer Target event.
void ai_Action(object oPC, object oAssociate);
// Toggles between normal ai script and special tactic ai scripts.
void ai_AIScript(object oPC, object oAssociate, string sAssociate);
// Enters targeting mode to place a trap on the ground for oAssociate.
void ai_PlaceTrap(object oPC, object oAssociate);
// Executes an installed plugin.
void ai_PlugIn_Execute(object oPC, string sElem);

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
    //ai_Debug ("0e_nui", "92", "sWndId: " + sWndId + " sEvent: " + sEvent + " sElem: " + sElem +
    //          " nToken: " + IntToString(nToken) + " oPC: " + GetName(oPC));
    // Get if the menu has an associate attached.
    json jData = NuiGetUserData(oPC, nToken);
    object oAssociate = StringToObject(JsonGetString(JsonArrayGet(jData, 0)));
    if(!ai_GetIsCharacter(oAssociate) && (oAssociate == OBJECT_INVALID ||
       GetMaster(oAssociate) != oPC))
    {
        ai_SendMessages("This creature is no longer in your party!", AI_COLOR_RED, oPC);
        NuiDestroy(oPC, nToken);
        return;
    }
    string sAssociateType = ai_GetAssociateType(oPC, oAssociate);
    //ai_Debug("0e_nui", "78", "oAssociate: " + GetName(oAssociate) + " sAssociateType: " + sAssociateType);
    //**************************************************************************
    if(sWndId == sAssociateType + "_widget")
    {
        // Watch to see if the window moves and save.
        if(sElem == "window_geometry" && sEvent == "watch")
        {
            if(GetLocalInt(oPC, AI_NO_NUI_SAVE)) return;
            json jGeometry = NuiGetBind(oPC, nToken, "window_geometry");
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
                        for(nIndex = 1; nIndex < 7; nIndex++)
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
                        for(nIndex = 1; nIndex < 7; nIndex++)
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
                for(nIndex = 1; nIndex < 7; nIndex++)
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
                JsonArrayDelInplace(jPlugins, nIndex);
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
                if(nMaxHenchman > 6)
                {
                    nMaxHenchman = 6;
                    ai_SendMessages("The maximum henchman for this mod is 6!", AI_COLOR_RED, oPC);
                }
                SetMaxHenchmen(nMaxHenchman);
                ai_SendMessages("Maximum henchman has been changed to " + IntToString(nMaxHenchman), AI_COLOR_YELLOW, oPC);
            }
            else if(sElem == "txt_debug_creature")
            {
                object oModule = GetModule();
                string sDebugName = JsonGetString(NuiGetBind(oPC, nToken, sElem));
                SetLocalString(oModule, AI_RULE_DEBUG_CREATURE, sDebugName);
                json jRules = ai_GetCampaignDbJson("rules");
                JsonObjectSetInplace(jRules, AI_RULE_DEBUG_CREATURE, JsonString(sDebugName));
                ai_SetCampaignDbJson("rules", jRules);
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
            else if(sElem == "btn_cmd_attack") ai_DoCommand(oPC, oAssociate, 4);
            else if(sElem == "btn_cmd_follow") ai_DoCommand(oPC, oAssociate, 2);
            else if(sElem == "btn_follow_target") ai_FollowTarget(oPC, oAssociate);
            else if(sElem == "btn_cmd_ai_script") ai_AIScript(oPC, oAssociate, sAssociateType);
            else if(sElem == "btn_cmd_place_trap") ai_PlaceTrap(oPC, oAssociate);
            else if(sElem == "btn_buff_short") ai_Buff_Button(oPC, oAssociate, 2, sAssociateType);
            else if(sElem == "btn_buff_long") ai_Buff_Button(oPC, oAssociate, 3, sAssociateType);
            else if(sElem == "btn_buff_all") ai_Buff_Button(oPC, oAssociate, 1, sAssociateType);
            else if(sElem == "btn_buff_rest") ai_Buff_Button(oPC, oAssociate, 0, sAssociateType);
        }
        else if(sEvent == "watch")
        {
            if(sElem == "chbx_buff_rest_check") ai_SetWidgetButtonToCheckbox(oPC, BTN_BUFF_REST, oAssociate, sAssociateType, nToken, sElem);
            else if(sElem == "chbx_cmd_action_check") ai_SetWidgetButtonToCheckbox(oPC, BTN_CMD_ACTION, oAssociate, sAssociateType, nToken, sElem);
            else if(sElem == "chbx_cmd_guard_check") ai_SetWidgetButtonToCheckbox(oPC, BTN_CMD_GUARD, oAssociate, sAssociateType, nToken, sElem);
            else if(sElem == "chbx_cmd_hold_check") ai_SetWidgetButtonToCheckbox(oPC, BTN_CMD_HOLD, oAssociate, sAssociateType, nToken, sElem);
            else if(sElem == "chbx_cmd_attack_check") ai_SetWidgetButtonToCheckbox(oPC, BTN_CMD_ATTACK, oAssociate, sAssociateType, nToken, sElem);
            else if(sElem == "chbx_cmd_follow_check") ai_SetWidgetButtonToCheckbox(oPC, BTN_CMD_FOLLOW, oAssociate, sAssociateType, nToken, sElem);
            else if(sElem == "chbx_cmd_ai_script_check") ai_SetWidgetButtonToCheckbox(oPC, BTN_CMD_AI_SCRIPT, oAssociate, sAssociateType, nToken, sElem);
            else if(sElem == "chbx_cmd_place_trap_check") ai_SetWidgetButtonToCheckbox(oPC, BTN_CMD_PLACE_TRAP, oAssociate, sAssociateType, nToken, sElem);
            else if(sElem == "chbx_follow_target_check") ai_SetAIButtonToCheckbox(oPC, BTN_AI_FOLLOW_TARGET, oAssociate, sAssociateType, nToken, sElem);
            else if(sElem == "chbx_buff_short_check") ai_SetWidgetButtonToCheckbox(oPC, BTN_BUFF_SHORT, oAssociate, sAssociateType, nToken, sElem);
            else if(sElem == "chbx_buff_long_check") ai_SetWidgetButtonToCheckbox(oPC, BTN_BUFF_LONG, oAssociate, sAssociateType, nToken, sElem);
            else if(sElem == "chbx_buff_all_check") ai_SetWidgetButtonToCheckbox(oPC, BTN_BUFF_ALL, oAssociate, sAssociateType, nToken, sElem);
            NuiDestroy(oPC, NuiFindWindow(oPC, sAssociateType + "_widget"));
            ai_CreateWidgetNUI(oPC, oAssociate);
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
            else if(sElem == "btn_ranged") AssignCommand(oAssociate, ai_Ranged(oPC, oAssociate, sAssociateType));
            else if(sElem == "btn_follow_minus") ai_FollowIncrement(oPC, oAssociate, -1.0, sAssociateType);
            else if(sElem == "btn_follow_plus") ai_FollowIncrement(oPC, oAssociate, 1.0, sAssociateType);
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
            else if(sElem == "btn_heal_out_minus") ai_Heal_Button(oPC, oAssociate, -5, AI_HEAL_OUT_OF_COMBAT_LIMIT, sAssociateType);
            else if(sElem == "btn_heal_out_plus") ai_Heal_Button(oPC, oAssociate, 5, AI_HEAL_OUT_OF_COMBAT_LIMIT, sAssociateType);
            else if(sElem == "btn_heal_in_minus") ai_Heal_Button(oPC, oAssociate, -5, AI_HEAL_IN_COMBAT_LIMIT, sAssociateType);
            else if(sElem == "btn_heal_in_plus") ai_Heal_Button(oPC, oAssociate, 5, AI_HEAL_IN_COMBAT_LIMIT, sAssociateType);
            else if(sElem == "btn_heals_onoff") ai_Heal_OnOff(oPC, oAssociate, sAssociateType, 1);
            else if(sElem == "btn_healp_onoff") ai_Heal_OnOff(oPC, oAssociate, sAssociateType, 2);
            else if(sElem == "btn_loot_range_minus") ai_LootRangeIncrement(oPC, oAssociate, -1.0, sAssociateType);
            else if(sElem == "btn_loot_range_plus") ai_LootRangeIncrement(oPC, oAssociate, 1.0, sAssociateType);
            else if(sElem == "btn_lock_range_minus") ai_LockRangeIncrement(oPC, oAssociate, -1.0, sAssociateType);
            else if(sElem == "btn_lock_range_plus") ai_LockRangeIncrement(oPC, oAssociate, 1.0, sAssociateType);
            else if(sElem == "btn_trap_range_minus") ai_TrapRangeIncrement(oPC, oAssociate, -1.0, sAssociateType);
            else if(sElem == "btn_trap_range_plus") ai_TrapRangeIncrement(oPC, oAssociate, 1.0, sAssociateType);
            else if(sElem == "btn_ai_script") ai_SaveAIScript(oPC, oAssociate, nToken);
        }
        else if(sEvent == "watch")
        {
            SetLocalInt (oPC, AI_NO_NUI_SAVE, TRUE);
            if(sElem == "chbx_ai_check") ai_SetAIButtonToCheckbox(oPC, BTN_AI_FOR_PC, oAssociate, sAssociateType, nToken, sElem);
            else if(sElem == "chbx_ranged_check") ai_SetAIButtonToCheckbox(oPC, BTN_AI_USE_RANGED, oAssociate, sAssociateType, nToken, sElem);
            else if(sElem == "chbx_follow_minus_check") ai_SetAIButtonToCheckbox(oPC, BTN_AI_FOLLOW_MINUS, oAssociate, sAssociateType, nToken, sElem);
            else if(sElem == "chbx_follow_plus_check") ai_SetAIButtonToCheckbox(oPC, BTN_AI_FOLLOW_PLUS, oAssociate, sAssociateType, nToken, sElem);
            else if(sElem == "chbx_search_check") ai_SetAIButtonToCheckbox(oPC, BTN_AI_USE_SEARCH, oAssociate, sAssociateType, nToken, sElem);
            else if(sElem == "chbx_stealth_check") ai_SetAIButtonToCheckbox(oPC, BTN_AI_USE_STEALTH, oAssociate, sAssociateType, nToken, sElem);
            else if(sElem == "chbx_pick_locks_check") ai_SetAIButtonToCheckbox(oPC, BTN_AI_PICK_LOCKS, oAssociate, sAssociateType, nToken, sElem);
            else if(sElem == "chbx_bash_locks_check") ai_SetAIButtonToCheckbox(oPC, BTN_AI_BASH_LOCKS, oAssociate, sAssociateType, nToken, sElem);
            else if(sElem == "chbx_traps_check") ai_SetAIButtonToCheckbox(oPC, BTN_AI_REMOVE_TRAPS, oAssociate, sAssociateType, nToken, sElem);
            else if(sElem == "chbx_quiet_check") ai_SetAIButtonToCheckbox(oPC, BTN_AI_REDUCE_SPEECH, oAssociate, sAssociateType, nToken, sElem);
            else if(sElem == "chbx_magic_minus_check") ai_SetAIButtonToCheckbox(oPC, BTN_AI_MAGIC_USE_MINUS, oAssociate, sAssociateType, nToken, sElem);
            else if(sElem == "chbx_magic_plus_check") ai_SetAIButtonToCheckbox(oPC, BTN_AI_MAGIC_USE_PLUS, oAssociate, sAssociateType, nToken, sElem);
            else if(sElem == "chbx_no_magic_check") ai_SetAIButtonToCheckbox(oPC, BTN_AI_NO_MAGIC_USE, oAssociate, sAssociateType, nToken, sElem);
            else if(sElem == "chbx_all_magic_check") ai_SetAIButtonToCheckbox(oPC, BTN_AI_ALL_MAGIC_USE, oAssociate, sAssociateType, nToken, sElem);
            else if(sElem == "chbx_def_magic_check") ai_SetAIButtonToCheckbox(oPC, BTN_AI_DEF_MAGIC_USE, oAssociate, sAssociateType, nToken, sElem);
            else if(sElem == "chbx_off_magic_check") ai_SetAIButtonToCheckbox(oPC, BTN_AI_OFF_MAGIC_USE, oAssociate, sAssociateType, nToken, sElem);
            else if(sElem == "chbx_loot_check") ai_SetAIButtonToCheckbox(oPC, BTN_AI_LOOT, oAssociate, sAssociateType, nToken, sElem);
            else if(sElem == "chbx_spontaneous_check") ai_SetAIButton2ToCheckbox(oPC, BTN2_AI_NO_SPONTANEOUS, oAssociate, sAssociateType, nToken, sElem);
            else if(sElem == "chbx_heal_out_minus_check") ai_SetAIButtonToCheckbox(oPC, BTN_AI_HEAL_OUT_MINUS, oAssociate, sAssociateType, nToken, sElem);
            else if(sElem == "chbx_heal_out_plus_check") ai_SetAIButtonToCheckbox(oPC, BTN_AI_HEAL_OUT_PLUS, oAssociate, sAssociateType, nToken, sElem);
            else if(sElem == "chbx_heal_in_minus_check") ai_SetAIButtonToCheckbox(oPC, BTN_AI_HEAL_IN_MINUS, oAssociate, sAssociateType, nToken, sElem);
            else if(sElem == "chbx_heal_in_plus_check") ai_SetAIButtonToCheckbox(oPC, BTN_AI_HEAL_IN_PLUS, oAssociate, sAssociateType, nToken, sElem);
            else if(sElem == "chbx_heals_onoff_check") ai_SetAIButtonToCheckbox(oPC, BTN_AI_STOP_SELF_HEALING, oAssociate, sAssociateType, nToken, sElem);
            else if(sElem == "chbx_healp_onoff_check") ai_SetAIButtonToCheckbox(oPC, BTN_AI_STOP_PARTY_HEALING, oAssociate, sAssociateType, nToken, sElem);
            else if(sElem == "chbx_loot_range_minus_check") ai_SetAIButtonToCheckbox(oPC, BTN_AI_LOOT_RANGE_MINUS, oAssociate, sAssociateType, nToken, sElem);
            else if(sElem == "chbx_loot_range_plus_check") ai_SetAIButtonToCheckbox(oPC, BTN_AI_LOOT_RANGE_PLUS, oAssociate, sAssociateType, nToken, sElem);
            else if(sElem == "chbx_lock_range_minus_check") ai_SetAIButtonToCheckbox(oPC, BTN_AI_UNLOCK_RANGE_MINUS, oAssociate, sAssociateType, nToken, sElem);
            else if(sElem == "chbx_lock_range_plus_check") ai_SetAIButtonToCheckbox(oPC, BTN_AI_UNLOCK_RANGE_PLUS, oAssociate, sAssociateType, nToken, sElem);
            else if(sElem == "chbx_trap_range_minus_check") ai_SetAIButtonToCheckbox(oPC, BTN_AI_TRAPS_RANGE_MINUS, oAssociate, sAssociateType, nToken, sElem);
            else if(sElem == "chbx_trap_range_plus_check") ai_SetAIButtonToCheckbox(oPC, BTN_AI_TRAPS_RANGE_PLUS, oAssociate, sAssociateType, nToken, sElem);
            NuiDestroy(oPC, NuiFindWindow(oPC, sAssociateType + "_widget"));
            ai_CreateWidgetNUI(oPC, oAssociate);
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
                IsWindowClosed(oPC, "ai_main_nui");
            }
            else
            {
                if(sElem == "btn_ai")
                {
                    if(GetEventScript(oAssociate, EVENT_SCRIPT_CREATURE_ON_HEARTBEAT) == "xx_pc_1_hb") ai_TurnOff(oPC, oAssociate, sAssociateType);
                    else ai_TurnOn(oPC, oAssociate, sAssociateType);
                }
                else if(sElem == "btn_ranged") AssignCommand(oAssociate, ai_Ranged(oPC, oAssociate, sAssociateType));
                else if(sElem == "btn_follow_minus") ai_FollowIncrement(oPC, oAssociate, -1.0, sAssociateType);
                else if(sElem == "btn_follow_plus") ai_FollowIncrement(oPC, oAssociate, 1.0, sAssociateType);
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
                else if(sElem == "btn_heal_out_minus") ai_Heal_Button(oPC, oAssociate, -5, AI_HEAL_OUT_OF_COMBAT_LIMIT, sAssociateType);
                else if(sElem == "btn_heal_out_plus") ai_Heal_Button(oPC, oAssociate, 5, AI_HEAL_OUT_OF_COMBAT_LIMIT, sAssociateType);
                else if(sElem == "btn_heal_in_minus") ai_Heal_Button(oPC, oAssociate, -5, AI_HEAL_IN_COMBAT_LIMIT, sAssociateType);
                else if(sElem == "btn_heal_in_plus") ai_Heal_Button(oPC, oAssociate, 5, AI_HEAL_IN_COMBAT_LIMIT, sAssociateType);
                else if(sElem == "btn_heals_onoff") ai_Heal_OnOff(oPC, oAssociate, sAssociateType, 1);
                else if(sElem == "btn_healp_onoff") ai_Heal_OnOff(oPC, oAssociate, sAssociateType, 2);
                else if(sElem == "btn_cmd_action") ai_Action(oPC, oAssociate);
                else if(sElem == "btn_cmd_guard") ai_DoCommand(oPC, oAssociate, 1);
                else if(sElem == "btn_cmd_hold") ai_DoCommand(oPC, oAssociate, 3);
                else if(sElem == "btn_cmd_attack") ai_DoCommand(oPC, oAssociate, 4);
                else if(sElem == "btn_cmd_follow") ai_DoCommand(oPC, oAssociate, 2);
                else if(sElem == "btn_cmd_ai_script") ai_AIScript(oPC, oAssociate, sAssociateType);
                else if(sElem == "btn_cmd_place_trap") ai_PlaceTrap(oPC, oAssociate);
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
                for(nIndex = 1; nIndex < 7; nIndex++)
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
void ai_UpdateToolTipUI(object oPC, string sWindowID1, string sWindowID2, string sToolTipBind, string sText)
{
    int nMenuToken = NuiFindWindow(oPC, sWindowID1);
    if(nMenuToken) NuiSetBind (oPC, nMenuToken, sToolTipBind, JsonString (sText));
    int nWidgetToken = NuiFindWindow(oPC, sWindowID2);
    if(nWidgetToken) NuiSetBind (oPC, nWidgetToken, sToolTipBind, JsonString (sText));
}
void ai_TurnOn(object oPC, object oTarget, string sAssociateType)
{
    ai_UpdateToolTipUI(oPC, sAssociateType + "_ai_menu", sAssociateType + "_widget", "btn_ai_tooltip", "  AI [On] Turn off");
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
    ai_UpdateToolTipUI(oPC, sAssociateType + "_ai_menu", sAssociateType + "_widget", "btn_ai_tooltip", "  AI [Off] Turn on");
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
void ai_Ranged(object oPC, object oAssociate, string sAssociateType)
{
    ai_ClearCreatureActions();
    if(ai_GetAIMode(oAssociate, AI_MODE_STOP_RANGED))
    {
        SendMessageToPC(oPC, GetName(oAssociate) + " is using ranged combat.");
        ai_UpdateToolTipUI(oPC, sAssociateType + "_ai_menu", sAssociateType + "_widget", "btn_ranged_tooltip", "  Ranged [On] Turn off");
        ai_SetAIMode(oAssociate, AI_MODE_STOP_RANGED, FALSE);
        ai_EquipBestRangedWeapon(oAssociate);
    }
    else
    {
        SendMessageToPC(oPC, GetName(oAssociate) + " is using melee combat only.");
        ai_UpdateToolTipUI(oPC, sAssociateType + "_ai_menu", sAssociateType + "_widget", "btn_ranged_tooltip", "  Ranged [Off] Turn on");
        ai_SetAIMode(oAssociate, AI_MODE_STOP_RANGED, TRUE);
        ai_EquipBestMeleeWeapon(oAssociate);
    }
    aiSaveAssociateAIModesToDb(oPC, oAssociate);
}
void ai_FollowIncrement(object oPC, object oAssociate, float fIncrement, string sAssociateType)
{
    float fAdjustment = GetLocalFloat(oAssociate, AI_FOLLOW_RANGE) + fIncrement;
    if(fAdjustment > 10.0) fAdjustment = 10.0;
    else if(fAdjustment < 1.0) fAdjustment = 1.0;
    SetLocalFloat(oAssociate, AI_FOLLOW_RANGE, fAdjustment);
    json jAIData = ai_GetAssociateDbJson(oPC, sAssociateType, "aidata");
    JsonArraySetInplace(jAIData, 6, JsonFloat(fAdjustment));
    ai_SetAssociateDbJson(oPC, sAssociateType, "aidata", jAIData);
    float fRange = fAdjustment +
                   StringToFloat(Get2DAString("appearance", "PREFATCKDIST", GetAppearanceType(oAssociate)));
    string sFollow = FloatToString(fRange, 0, 0);
    ai_UpdateToolTipUI(oPC, sAssociateType + "_ai_menu", sAssociateType + "_widget", "btn_follow_minus_tooltip", "  Follow distance [" + sFollow + " meters] Decrease");
    ai_UpdateToolTipUI(oPC, sAssociateType + "_ai_menu", sAssociateType + "_widget", "btn_follow_plus_tooltip", "  Follow distance [" + sFollow + " meters] Increase");
}
void ai_Search(object oPC, object oAssociate, string sAssociateType)
{
    if(ai_GetAIMode(oAssociate, AI_MODE_AGGRESSIVE_SEARCH))
    {
        SendMessageToPC(oPC, GetName(oAssociate) + " is turning search off.");
        ai_UpdateToolTipUI(oPC, sAssociateType + "_ai_menu", sAssociateType + "_widget", "btn_search_tooltip", "  Search [Off] Turn on");
        SetActionMode(oPC, ACTION_MODE_DETECT, FALSE);
        ai_SetAIMode(oAssociate, AI_MODE_AGGRESSIVE_SEARCH, FALSE);
    }
    else
    {
        SendMessageToPC(oPC, GetName(oAssociate) + " is turning search on.");
        ai_UpdateToolTipUI(oPC, sAssociateType + "_ai_menu", sAssociateType + "_widget", "btn_search_tooltip", "  Search [On] Turn off");
        ai_SetAIMode(oPC, ACTION_MODE_DETECT, TRUE);
        SetActionMode(oPC, ACTION_MODE_DETECT, TRUE);
        ai_SetAIMode(oAssociate, AI_MODE_AGGRESSIVE_SEARCH, TRUE);
    }
    aiSaveAssociateAIModesToDb(oPC, oAssociate);
}
void ai_Stealth(object oPC, object oAssociate, string sAssociateType)
{
    if(ai_GetAIMode(oAssociate, AI_MODE_AGGRESSIVE_STEALTH))
    {
        SendMessageToPC(oPC, GetName(oAssociate) + " is turning stealth off.");
        ai_UpdateToolTipUI(oPC, sAssociateType + "_ai_menu", sAssociateType + "_widget", "btn_stealth_tooltip", "  Stealth [Off] Turn on");
        SetActionMode(oAssociate, ACTION_MODE_STEALTH, FALSE);
        ai_SetAIMode(oAssociate, AI_MODE_AGGRESSIVE_STEALTH, FALSE);
    }
    else
    {
        SendMessageToPC(oPC, GetName(oAssociate) + " is turning stealth on.");
        ai_UpdateToolTipUI(oPC, sAssociateType + "_ai_menu", sAssociateType + "_widget", "btn_stealth_tooltip", "  Stealth [On] Turn off");
        SetActionMode(oAssociate, ACTION_MODE_STEALTH, TRUE);
        ai_SetAIMode(oAssociate, AI_MODE_AGGRESSIVE_STEALTH, TRUE);
    }
    aiSaveAssociateAIModesToDb(oPC, oAssociate);
}
void ai_Locks(object oPC, object oAssociate, string sAssociateType, int nMode)
{
    if(nMode == 1)
    {
        if(ai_GetAIMode(oAssociate, AI_MODE_PICK_LOCKS))
        {
            SendMessageToPC(oPC, GetName(oAssociate) + " will stop picking locks.");
            ai_UpdateToolTipUI(oPC, sAssociateType + "_ai_menu", sAssociateType + "_widget", "btn_pick_locks_tooltip", "  Pick Locks [Off] Turn on");
            ai_SetAIMode(oAssociate, AI_MODE_PICK_LOCKS, FALSE);
        }
        else
        {
            SendMessageToPC(oPC, GetName(oAssociate) + " will now pick locks.");
            ai_UpdateToolTipUI(oPC, sAssociateType + "_ai_menu", sAssociateType + "_widget", "btn_pick_locks_tooltip", "  Pick locks [On] Turn off");
            ai_SetAIMode(oAssociate, AI_MODE_PICK_LOCKS, TRUE);
        }
    }
    else if(nMode == 2)
    {
        if(ai_GetAIMode(oAssociate, AI_MODE_BASH_LOCKS))
        {
            SendMessageToPC(oPC, GetName(oAssociate) + " will stop bashing locks.");
            ai_UpdateToolTipUI(oPC, sAssociateType + "_ai_menu", sAssociateType + "_widget", "btn_bash_locks_tooltip", "  Bash Locks [Off] Turn on");
            ai_SetAIMode(oAssociate, AI_MODE_BASH_LOCKS, FALSE);
        }
        else
        {
            SendMessageToPC(oPC, GetName(oAssociate) + " will now bash locks.");
            ai_UpdateToolTipUI(oPC, sAssociateType + "_ai_menu", sAssociateType + "_widget", "btn_bash_locks_tooltip", "  Bash locks [On] Turn off");
            ai_SetAIMode(oAssociate, AI_MODE_BASH_LOCKS, TRUE);
        }
    }
    aiSaveAssociateAIModesToDb(oPC, oAssociate);
}
void ai_Traps(object oPC, object oAssociate, string sAssociateType)
{
    if(ai_GetAIMode(oAssociate, AI_MODE_DISARM_TRAPS))
    {
        SendMessageToPC(oPC, GetName(oAssociate) + " will stop disarming traps.");
        ai_UpdateToolTipUI(oPC, sAssociateType + "_ai_menu", sAssociateType + "_widget", "btn_traps_tooltip", "  Disable Traps [Off] Turn on");
        ai_SetAIMode(oAssociate, AI_MODE_DISARM_TRAPS, FALSE);
    }
    else
    {
        SendMessageToPC(oPC, GetName(oAssociate) + " will now disarm traps.");
        ai_UpdateToolTipUI(oPC, sAssociateType + "_ai_menu", sAssociateType + "_widget", "btn_traps_tooltip", "  Disable Traps [On] Turn off");
        ai_SetAIMode(oAssociate, AI_MODE_DISARM_TRAPS, TRUE);
    }
    aiSaveAssociateAIModesToDb(oPC, oAssociate);
}
void ai_ReduceSpeech(object oPC, object oAssociate, string sAssociateType)
{
    if(ai_GetAIMode(oAssociate, AI_MODE_DO_NOT_SPEAK))
    {
        SendMessageToPC(oPC, GetName(oAssociate) + " will increase speech.");
        ai_UpdateToolTipUI(oPC, sAssociateType + "_ai_menu", sAssociateType + "_widget", "btn_quiet_tooltip", "  Reduce Speech [Off] Turn on");
        ai_SetAIMode(oAssociate, AI_MODE_DO_NOT_SPEAK, FALSE);
    }
    else
    {
        SendMessageToPC(oPC, GetName(oAssociate) + " will reduce speech.");
        ai_UpdateToolTipUI(oPC, sAssociateType + "_ai_menu", sAssociateType + "_widget", "btn_quiet_tooltip", "  Reduce Speech [On] Turn off");
        ai_SetAIMode(oAssociate, AI_MODE_DO_NOT_SPEAK, TRUE);
    }
    aiSaveAssociateAIModesToDb(oPC, oAssociate);
}
void ai_UseMagic(object oPC, object oAssociate, int bNoMagic, int bDefMagic, int bOffMagic, string sAssociateType)
{
    string sText = " is using any magic in combat.";
    if(bNoMagic) sText = " is not using magic in combat.";
    else if(bDefMagic) sText = " is only using defensive spells in combat.";
    else if(bOffMagic) sText = " is only using Offensive spells in combat.";
    SendMessageToPC(oPC, GetName(oAssociate) + sText);
    ai_SetMagicMode(oAssociate, AI_MAGIC_NO_MAGIC, bNoMagic);
    ai_SetMagicMode(oAssociate, AI_MAGIC_DEFENSIVE_CASTING, bDefMagic);
    ai_SetMagicMode(oAssociate, AI_MAGIC_OFFENSIVE_CASTING, bOffMagic);
    sText = "  [Any]";
    if(ai_GetMagicMode(oAssociate, AI_MAGIC_NO_MAGIC)) sText = "  [None]";
    else if(ai_GetMagicMode(oAssociate, AI_MAGIC_DEFENSIVE_CASTING)) sText = "  [Defense]";
    else if(ai_GetMagicMode(oAssociate, AI_MAGIC_OFFENSIVE_CASTING)) sText = "  [Offense]";
    ai_UpdateToolTipUI(oPC, sAssociateType + "_ai_menu", sAssociateType + "_widget", "btn_no_magic_tooltip", sText + " Turn magic use off");
    ai_UpdateToolTipUI(oPC, sAssociateType + "_ai_menu", sAssociateType + "_widget", "btn_all_magic_tooltip", sText + " Use any magic");
    ai_UpdateToolTipUI(oPC, sAssociateType + "_ai_menu", sAssociateType + "_widget", "btn_def_magic_tooltip", sText + " Use defensive magic only");
    ai_UpdateToolTipUI(oPC, sAssociateType + "_ai_menu", sAssociateType + "_widget", "btn_off_magic_tooltip", sText + " Use offensive magic only");
    aiSaveAssociateAIModesToDb(oPC, oAssociate);
}
void ai_Loot(object oPC, object oAssociate, string sAssociateType)
{
    int bLooting = !ai_GetAIMode(oAssociate, AI_MODE_PICKUP_ITEMS);
    string sMessage, sText;

    if(bLooting)
    {
        sMessage = " is picking up items.";
        sText = "  [On] Turn off looting";
    }
    else
    {
        sMessage = " is not picking up items.";
        sText = "  [Off] Turn on looting";
    }
    SendMessageToPC(oPC, GetName(oAssociate) + sMessage);
    ai_SetAIMode(oAssociate, AI_MODE_PICKUP_ITEMS, bLooting);
    ai_UpdateToolTipUI(oPC, sAssociateType + "_ai_menu", sAssociateType + "_widget", "btn_loot_tooltip", sText);
    aiSaveAssociateAIModesToDb(oPC, oAssociate);
}
void ai_Spontaneous(object oPC, object oAssociate, string sAssociateType)
{
    int bSpontaneous = !ai_GetMagicMode(oAssociate, AI_MAGIC_NO_SPONTANEOUS_CURE);
    string sMessage, sText;

    if(bSpontaneous)
    {
        sMessage = " has stop casting spontaneous cure spells.";
        sText = "  [Off] Turn on Spontaneous casting";
    }
    else
    {
        sMessage = " will now cast spontaneous cure spells.";
        sText = "  [On] Turn off Spontaneous casting";
    }
    SendMessageToPC(oPC, GetName(oAssociate) + sMessage);
    ai_SetMagicMode(oAssociate, AI_MAGIC_NO_SPONTANEOUS_CURE, bSpontaneous);
    ai_UpdateToolTipUI(oPC, sAssociateType + "_ai_menu", sAssociateType + "_widget", "btn_spontaneous_tooltip", sText);
    aiSaveAssociateAIModesToDb(oPC, oAssociate);
}
void ai_MagicIncrement(object oPC, object oAssociate, int nIncrement, string sAssociateType)
{
    int nAdjustment = GetLocalInt(oAssociate, AI_DIFFICULTY_ADJUSTMENT) + nIncrement;
    if(nAdjustment > 100) nAdjustment = 100;
    else if(nAdjustment < -100) nAdjustment = -100;
    SetLocalInt(oAssociate, AI_DIFFICULTY_ADJUSTMENT, nAdjustment);
    json jAIData = ai_GetAssociateDbJson(oPC, sAssociateType, "aidata");
    JsonArraySetInplace(jAIData, 0, JsonInt(nAdjustment));
    ai_SetAssociateDbJson(oPC, sAssociateType, "aidata", jAIData);
    string sMagic = IntToString(nAdjustment);
    ai_UpdateToolTipUI(oPC, sAssociateType + "_ai_menu", sAssociateType + "_widget", "btn_m_minus_tooltip", "  Magic use [" + sMagic + "] Decrease");
    ai_UpdateToolTipUI(oPC, sAssociateType + "_ai_menu", sAssociateType + "_widget", "btn_m_plus_tooltip", "  Magic use [" + sMagic + "] Increase");
}
void ai_LootRangeIncrement(object oPC, object oAssociate, float fIncrement, string sAssociateType)
{
    float fAdjustment = GetLocalFloat(oAssociate, AI_LOOT_CHECK_RANGE) + fIncrement;
    if(fAdjustment > 40.0) fAdjustment = 40.0;
    else if(fAdjustment < 0.0) fAdjustment = 0.0;
    SetLocalFloat(oAssociate, AI_LOOT_CHECK_RANGE, fAdjustment);
    json jAIData = ai_GetAssociateDbJson(oPC, sAssociateType, "aidata");
    JsonArraySetInplace(jAIData, 3, JsonFloat(fAdjustment));
    ai_SetAssociateDbJson(oPC, sAssociateType, "aidata", jAIData);
    string sRange = FloatToString(fAdjustment, 0, 0);
    ai_UpdateToolTipUI(oPC, sAssociateType + "_ai_menu", sAssociateType + "_widget", "btn_lootr_minus_tooltip", "  Loot range [" + sRange + "] Decrease");
    ai_UpdateToolTipUI(oPC, sAssociateType + "_ai_menu", sAssociateType + "_widget", "btn_lootr_plus_tooltip", "  Loot range [" + sRange + "] Increase");
}
void ai_LockRangeIncrement(object oPC, object oAssociate, float fIncrement, string sAssociateType)
{
    float fAdjustment = GetLocalFloat(oAssociate, AI_LOCK_CHECK_RANGE) + fIncrement;
    if(fAdjustment > 40.0) fAdjustment = 40.0;
    else if(fAdjustment < 0.0) fAdjustment = 0.0;
    SetLocalFloat(oAssociate, AI_LOCK_CHECK_RANGE, fAdjustment);
    json jAIData = ai_GetAssociateDbJson(oPC, sAssociateType, "aidata");
    JsonArraySetInplace(jAIData, 4, JsonFloat(fAdjustment));
    ai_SetAssociateDbJson(oPC, sAssociateType, "aidata", jAIData);
    string sRange = FloatToString(fAdjustment, 0, 0);
    ai_UpdateToolTipUI(oPC, sAssociateType + "_ai_menu", sAssociateType + "_widget", "btn_lockr_minus_tooltip", "  Lock range [" + sRange + "] Decrease");
    ai_UpdateToolTipUI(oPC, sAssociateType + "_ai_menu", sAssociateType + "_widget", "btn_lockr_plus_tooltip", "  Lock range [" + sRange + "] Increase");
}
void ai_TrapRangeIncrement(object oPC, object oAssociate, float fIncrement, string sAssociateType)
{
    float fAdjustment = GetLocalFloat(oAssociate, AI_TRAP_CHECK_RANGE) + fIncrement;
    if(fAdjustment > 40.0) fAdjustment = 40.0;
    else if(fAdjustment < 0.0) fAdjustment = 0.0;
    SetLocalFloat(oAssociate, AI_TRAP_CHECK_RANGE, fAdjustment);
    json jAIData = ai_GetAssociateDbJson(oPC, sAssociateType, "aidata");
    JsonArraySetInplace(jAIData, 5, JsonFloat(fAdjustment));
    ai_SetAssociateDbJson(oPC, sAssociateType, "aidata", jAIData);
    string sRange = FloatToString(fAdjustment, 0, 0);
    ai_UpdateToolTipUI(oPC, sAssociateType + "_ai_menu", sAssociateType + "_widget", "btn_trapr_minus_tooltip", "  Trap range [" + sRange + "] Decrease");
    ai_UpdateToolTipUI(oPC, sAssociateType + "_ai_menu", sAssociateType + "_widget", "btn_trapr_plus_tooltip", "  Trap range [" + sRange + "] Increase");
}
void ai_SaveAIScript(object oPC, object oAssociate, int nToken)
{
    string sScript = JsonGetString(NuiGetBind(oPC, nToken, "txt_ai_script"));
    string sOldScript = GetLocalString(oAssociate, AI_COMBAT_SCRIPT);
    if(GetStringLeft(sScript, 5) != "ai_a_") ai_SendMessages(sScript + " does not have correct prefix it must have ai_a_ for associates! Did not change AI script.", AI_COLOR_RED, oPC);
    else if(ResManGetAliasFor(sScript, RESTYPE_NCS) == "")
    {
        ai_SendMessages(sScript + " not found by ResMan! This is not a valid AI script.", AI_COLOR_RED, oPC);
    }
    else if(sScript != sOldScript)
    {
        SetLocalString(oAssociate, AI_COMBAT_SCRIPT, sScript);
        SetLocalString(oAssociate, AI_DEFAULT_SCRIPT, sScript);
        ai_SendMessages(GetName(oAssociate) + " is now using " + sScript + " AI script!", AI_COLOR_GREEN, oPC);
    }
    else ai_SendMessages(GetName(oAssociate) + " is already using this script! Did not change AI script.", AI_COLOR_RED, oPC);
}
void ai_Buff_Button(object oPC, object oAssociate, int nOption, string sAssociateType)
{
    if(nOption == 0)
    {
        int bRestBuff = !ai_GetMagicMode(oAssociate, AI_MAGIC_BUFF_AFTER_REST);
        ai_SetMagicMode(oAssociate, AI_MAGIC_BUFF_AFTER_REST, bRestBuff);
        if(bRestBuff)
        {
            SendMessageToPC(oPC, GetName(oAssociate) + " will cast long buffs after resting.");
            ai_UpdateToolTipUI(oPC, sAssociateType + "_cmd_menu", sAssociateType + "_widget", "btn_buff_rest_tooltip", "  [On] Turn buffing after resting off.");
        }
        else
        {
            SendMessageToPC(oPC, GetName(oAssociate) + " will not cast long buffs after resting.");
            ai_UpdateToolTipUI(oPC, sAssociateType + "_cmd_menu", sAssociateType + "_widget", "btn_buff_rest_tooltip", "  [Off] Turn buffing after resting on.");
        }
        aiSaveAssociateAIModesToDb(oPC, oAssociate);
    }
    else
    {
        if(!GetIsPossessedFamiliar(oAssociate))
        {
            object oEnemy = GetNearestEnemy(oAssociate);
            //ai_Debug("0e_nui", "865", "oEnemy: " + GetName(oEnemy) + " fDistance: " +
            //         FloatToString(GetDistanceBetween(oAssociate, oEnemy), 0, 2));
            if(GetDistanceBetween(oAssociate, oEnemy) > 30.0 ||
               oEnemy == OBJECT_INVALID)
            {
                ai_CastBuffs(oAssociate, nOption, 0, oPC);
            }
            else ai_SendMessages("You cannot buff while there are enemies nearby.", AI_COLOR_RED, oPC);
        }
        else ai_SendMessages("You cannot buff while possessing your familiar.", AI_COLOR_RED, oPC);
    }
}
void ai_Heal_Button(object oPC, object oAssociate, int nIncrement, string sVar, string sAssociateType)
{
    int nHeal = GetLocalInt(oAssociate, sVar);
    if(nIncrement > 0 && nHeal > 100 - nIncrement) nHeal = 100 - nIncrement;
    if(nIncrement < 0 && nHeal < abs(nIncrement)) nHeal = abs(nIncrement);
    nHeal += nIncrement;
    SetLocalInt(oAssociate, sVar, nHeal);
    string sHeal = IntToString(nHeal);
    json jAIData = ai_GetAssociateDbJson(oPC, sAssociateType, "aidata");
    if(sVar == AI_HEAL_OUT_OF_COMBAT_LIMIT)
    {
        string sText = "  Will heal at or below [" + sHeal + "%] health out of combat";
        ai_UpdateToolTipUI(oPC, sAssociateType + "_ai_menu", sAssociateType + "_widget", "btn_heal_out_plus_tooltip", sText);
        ai_UpdateToolTipUI(oPC, sAssociateType + "_ai_menu", sAssociateType + "_widget", "btn_heal_out_minus_tooltip", sText);
        JsonArraySetInplace(jAIData, 1, JsonInt(nHeal));
    }
    else if(sVar == AI_HEAL_IN_COMBAT_LIMIT)
    {
        string sText = "  Will heal at or below [" + sHeal + "%] health in combat";
        ai_UpdateToolTipUI(oPC, sAssociateType + "_ai_menu", sAssociateType + "_widget", "btn_heal_in_plus_tooltip", sText);
        ai_UpdateToolTipUI(oPC, sAssociateType + "_ai_menu", sAssociateType + "_widget", "btn_heal_in_minus_tooltip", sText);
        JsonArraySetInplace(jAIData, 2, JsonInt(nHeal));
    }
    ai_SetAssociateDbJson(oPC, sAssociateType, "aidata", jAIData);
}
void ai_Heal_OnOff(object oPC, object oAssociate, string sAssociateType, int nMode)
{
    string sText, sText2;
    if(nMode == 1)
    {
        if(ai_GetAIMode(oAssociate, AI_MODE_SELF_HEALING_OFF))
        {
            ai_SetAIMode(oAssociate, AI_MODE_SELF_HEALING_OFF, FALSE);
            sText = "  Self healing is [On] turn off";
            sText2 = " will now use healing on themselves.";
        }
        else
        {
            ai_SetAIMode(oAssociate, AI_MODE_SELF_HEALING_OFF, TRUE);
            sText = "  Self healing is [Off] turn on";
            sText2 = " will stop using healing on themselves.";
        }
        ai_UpdateToolTipUI(oPC, sAssociateType + "_ai_menu", sAssociateType + "_widget", "btn_heals_onoff_tooltip", sText);
    }
    else
    {
        if(ai_GetAIMode(oAssociate, AI_MODE_PARTY_HEALING_OFF))
        {
            ai_SetAIMode(oAssociate, AI_MODE_PARTY_HEALING_OFF, FALSE);
            sText = "  Party healing is [On] turn off";
            sText2 = " will now use healing on party members.";
        }
        else
        {
            ai_SetAIMode(oAssociate, AI_MODE_PARTY_HEALING_OFF, TRUE);
            sText = "  Party healing is [Off] turn on";
            sText2 = " will stop using healing on party members.";
        }
        ai_UpdateToolTipUI(oPC, sAssociateType + "_ai_menu", sAssociateType + "_widget", "btn_healp_onoff_tooltip", sText);
    }
    SendMessageToPC(oPC, GetName(oAssociate) + sText2);
    aiSaveAssociateAIModesToDb(oPC, oAssociate);
}
void ai_FollowTarget(object oPC, object oAssociate)
{
    SetLocalObject(oPC, AI_TARGET_ASSOCIATE, oAssociate);
    SetLocalString(oPC, AI_TARGET_MODE, "ASSOCIATE_FOLLOW_TARGET");
    EnterTargetingMode(oPC, OBJECT_TYPE_CREATURE, MOUSECURSOR_ACTION, MOUSECURSOR_NOWALK);
}
void ai_Original_Guard()
{
    ResetHenchmenState();
    //Companions will only attack the Masters Last Attacker
    SetAssociateState(NW_ASC_MODE_DEFEND_MASTER);
    SetAssociateState(NW_ASC_MODE_STAND_GROUND, FALSE);
    object oMaster = GetMaster();
    object oLastAttacker = GetLastHostileActor(oMaster);
    // * for some reason this is too often invalid. still the routine
    // * works corrrectly
    SetLocalInt(OBJECT_SELF, "X0_BATTLEJOINEDMASTER", TRUE);
    HenchmenCombatRound(oLastAttacker);
    ai_SendMessages(GetName(OBJECT_SELF) + " is now guarding you!", AI_COLOR_YELLOW, oMaster);
}
void ai_Original_Follow()
{
    ResetHenchmenState();
    SetAssociateState(NW_ASC_MODE_STAND_GROUND, FALSE);
    DelayCommand(2.5, VoiceCanDo());
    object oMaster = GetMaster();
    ActionForceFollowObject(oMaster, GetFollowDistance());
    SetAssociateState(NW_ASC_IS_BUSY);
    DelayCommand(5.0, SetAssociateState(NW_ASC_IS_BUSY, FALSE));
    ai_SendMessages(GetName(OBJECT_SELF) + " is now following You!", AI_COLOR_YELLOW, oMaster);
}
void ai_Original_StandGround()
{
    SetAssociateState(NW_ASC_MODE_STAND_GROUND);
    SetAssociateState(NW_ASC_MODE_DEFEND_MASTER, FALSE);
    DelayCommand(2.0, VoiceCanDo());
    ActionAttack(OBJECT_INVALID);
    ClearActions(CLEAR_X0_INC_HENAI_RespondToShout1);
    ai_SendMessages(GetName(OBJECT_SELF) + " is now standing their ground!", AI_COLOR_YELLOW, GetMaster());}
void ai_Original_AttackNearest()
{
    ResetHenchmenState();
    SetAssociateState(NW_ASC_MODE_DEFEND_MASTER, FALSE);
    SetAssociateState(NW_ASC_MODE_STAND_GROUND, FALSE);
    DetermineCombatRound();
    // * bonus feature. If master is attacking a door or container, issues VWE Attack Nearest
    // * will make henchman join in on the fun
    object oMaster = GetMaster();
    object oTarget = GetAttackTarget(oMaster);
    if (GetIsObjectValid(oTarget) == TRUE)
    {
        if (GetObjectType(oTarget) == OBJECT_TYPE_PLACEABLE || GetObjectType(oTarget) == OBJECT_TYPE_DOOR)
        {
            ActionAttack(oTarget);
        }
    }
    ai_SendMessages(GetName(OBJECT_SELF) + " is now in normal mode!", AI_COLOR_YELLOW, oMaster);
}
void ai_Philos_Guard(object oCreature)
{
    ai_SetAIMode(oCreature, AI_MODE_SCOUT_AHEAD, FALSE);
    ai_SetAIMode(oCreature, AI_MODE_DEFEND_MASTER, TRUE);
    ai_SetAIMode(oCreature, AI_MODE_STAND_GROUND, FALSE);
    ai_SetAIMode(oCreature, AI_MODE_FOLLOW, FALSE);
    ai_SetAIMode(oCreature, AI_MODE_COMMANDED, FALSE);
    object oMaster = GetMaster(oCreature);
    if(!ai_GetIsBusy(oCreature) && ai_GetIsInCombat(oCreature))
    {
        object oLastAttacker = GetLastHostileActor(oMaster);
        if(oLastAttacker != OBJECT_INVALID) ai_DoAssociateCombatRound(oCreature, oLastAttacker);
        else AssignCommand(oCreature, ActionMoveToObject(oMaster, TRUE));
    }
    ai_SendMessages(GetName(oCreature) + " is now guarding you!", AI_COLOR_YELLOW, oMaster);
    aiSaveAssociateAIModesToDb(oMaster, oCreature);
}
void ai_Philos_Follow()
{
    object oCreature = OBJECT_SELF;
    ai_SetAIMode(oCreature, AI_MODE_SCOUT_AHEAD, FALSE);
    ai_SetAIMode(oCreature, AI_MODE_STAND_GROUND, FALSE);
    ai_SetAIMode(oCreature, AI_MODE_FOLLOW, TRUE);
    ai_SetAIMode(oCreature, AI_MODE_COMMANDED, FALSE);
    object oMaster = GetMaster(oCreature);
    aiSaveAssociateAIModesToDb(oMaster, oCreature);
    // To follow we probably should be running and not searching or hiding.
    if(GetDetectMode(oCreature) && !GetHasFeat(FEAT_KEEN_SENSE, oCreature)) SetActionMode(oCreature, ACTION_MODE_DETECT, FALSE);
    if(GetStealthMode(oCreature)) SetActionMode(oCreature, ACTION_MODE_STEALTH, FALSE);
    ai_PassActionToAssociates(oCreature, ACTION_FOLLOW);
    ai_ClearCreatureActions(TRUE);
    if(ai_IsInCombatRound(oCreature)) ai_ClearCombatState(oCreature);
    object oTarget = GetLocalObject(oCreature, AI_FOLLOW_TARGET);
    if(oTarget == OBJECT_INVALID) oTarget = oMaster;
    ActionMoveToObject(oTarget, TRUE, ai_GetFollowDistance(oCreature));
    ai_SendMessages(GetName(oCreature) + " is now following " + GetName(oTarget) + "!", AI_COLOR_YELLOW, oMaster);
}
void ai_Philos_StandGround()
{
    object oCreature = OBJECT_SELF;
    ai_SetAIMode(oCreature, AI_MODE_SCOUT_AHEAD, FALSE);
    ai_SetAIMode(oCreature, AI_MODE_STAND_GROUND, TRUE);
    ai_SetAIMode(oCreature, AI_MODE_DEFEND_MASTER, FALSE);
    ai_SetAIMode(oCreature, AI_MODE_FOLLOW, FALSE);
    ai_PassActionToAssociates(oCreature, ACTION_FOLLOW, FALSE);
    ai_SetAIMode(oCreature, AI_MODE_COMMANDED, FALSE);
    if(ai_IsInCombatRound(oCreature))
    {
        ai_EndCombatRound(oCreature);
        ai_ClearCombatState(oCreature);
        DeleteLocalObject(oCreature, AI_ATTACKED_PHYSICAL);
        DeleteLocalObject(oCreature, AI_ATTACKED_SPELL);
    }
    ai_ClearCreatureActions(TRUE);
    object oMaster = GetMaster(oCreature);
    ai_SendMessages(GetName(oCreature) + " is now standing their ground!", AI_COLOR_YELLOW, oMaster);
    aiSaveAssociateAIModesToDb(oMaster, oCreature);
}
void ai_Philos_AttackNearest(object oCreature)
{
    ai_SetAIMode(oCreature, AI_MODE_SCOUT_AHEAD, FALSE);
    ai_SetAIMode(oCreature, AI_MODE_DEFEND_MASTER, FALSE);
    ai_SetAIMode(oCreature, AI_MODE_STAND_GROUND, FALSE);
    ai_SetAIMode(oCreature, AI_MODE_FOLLOW, FALSE);
    ai_PassActionToAssociates(oCreature, ACTION_FOLLOW, FALSE);
    ai_SetAIMode(oCreature, AI_MODE_COMMANDED, FALSE);
    // This resets a henchmens failed Moral save in combat.
    string sScript = GetLocalString(oCreature, AI_COMBAT_SCRIPT);
    if(sScript == "ai_coward")
    {
        sScript = GetLocalString(oCreature, AI_DEFAULT_SCRIPT);
        SetLocalString(oCreature, AI_COMBAT_SCRIPT, sScript);
    }
    object oMaster = GetMaster(oCreature);
    if(!ai_GetIsBusy(oCreature))
    {
        object oEnemy = ai_GetNearestEnemy(oCreature, 1, 7, 7);
        if(oEnemy != OBJECT_INVALID && GetDistanceBetween(oCreature, oEnemy) < AI_RANGE_BATTLEFIELD)
        {
            ai_HaveCreatureSpeak(oCreature, 5, ":0:1:2:3:6:");
            // If master is attacking a target we will attack them too!
            if(!ai_GetIsInCombat(oCreature)) ai_SetCreatureTalents(oCreature, FALSE);
            object oTarget = ai_GetAttackedTarget(oMaster);
            if(oTarget != OBJECT_INVALID) ai_DoAssociateCombatRound(oCreature);
            else ai_DoAssociateCombatRound(oCreature, oTarget);
        }
        else
        {
            object oTarget = GetLocalObject(oCreature, AI_FOLLOW_TARGET);
            if(oTarget == OBJECT_INVALID) oTarget = oMaster;
            AssignCommand(oCreature, ActionMoveToObject(oMaster, TRUE, ai_GetFollowDistance(oCreature)));
        }
    }
    ai_SendMessages(GetName(oCreature) + " is now in normal mode!", AI_COLOR_YELLOW, oMaster);
    aiSaveAssociateAIModesToDb(oMaster, oCreature);
}
void ai_DoCommand(object oPC, object oAssociate, int nCommand)
{
    int nIndex = 1;
    if(oPC == oAssociate)
    {
        if(nCommand == 1)
        {
            // Not using Philos Henchman AI. Use vanilla commands.
            if(ResManGetAliasFor("0e_ch_1_hb", RESTYPE_NCS) == "")
            {
                for(nIndex = 1; nIndex < 7; nIndex++)
                {
                    oAssociate = GetAssociate(ASSOCIATE_TYPE_HENCHMAN, oPC, nIndex);
                    if(oAssociate != OBJECT_INVALID) AssignCommand(oAssociate, ai_Original_Guard());
                }
                for(nIndex = 2; nIndex < 6; nIndex++)
                {
                    oAssociate = GetAssociate(nIndex, oPC);
                    if(oAssociate != OBJECT_INVALID) AssignCommand(oAssociate, ai_Original_Guard());
                }
            }
            // Use Philos AI commands.
            else
            {
                for(nIndex = 1; nIndex < 7; nIndex++)
                {
                    oAssociate = GetAssociate(ASSOCIATE_TYPE_HENCHMAN, oPC, nIndex);
                    if(oAssociate != OBJECT_INVALID) ai_Philos_Guard(oAssociate);
                }
                for(nIndex = 2; nIndex < 6; nIndex++)
                {
                    oAssociate = GetAssociate(nIndex, oPC);
                    if(oAssociate != OBJECT_INVALID) ai_Philos_Guard(oAssociate);
                }
            }
        }
        else if(nCommand == 2)
        {
            // Not using Philos Henchman AI. Use vanilla commands.
            if(ResManGetAliasFor("0e_ch_1_hb", RESTYPE_NCS) == "")
            {
                for(nIndex = 1; nIndex < 7; nIndex++)
                {
                    oAssociate = GetAssociate(ASSOCIATE_TYPE_HENCHMAN, oPC, nIndex);
                    if(oAssociate != OBJECT_INVALID) AssignCommand(oAssociate, ai_Original_Follow());
                }
                for(nIndex = 2; nIndex < 6; nIndex++)
                {
                    oAssociate = GetAssociate(nIndex, oPC);
                    if(oAssociate != OBJECT_INVALID) AssignCommand(oAssociate, ai_Original_Follow());
                }
            }
            // Use Philos AI commands.
            else
            {
                for(nIndex = 1; nIndex < 7; nIndex++)
                {
                    oAssociate = GetAssociate(ASSOCIATE_TYPE_HENCHMAN, oPC, nIndex);
                    if(oAssociate != OBJECT_INVALID) AssignCommand(oAssociate, ai_Philos_Follow());
                }
                for(nIndex = 2; nIndex < 6; nIndex++)
                {
                    oAssociate = GetAssociate(nIndex, oPC);
                    if(oAssociate != OBJECT_INVALID) AssignCommand(oAssociate, ai_Philos_Follow());
                }
            }
        }
        else if(nCommand == 3)
        {
            // Not using Philos Henchman AI. Use vanilla commands.
            if(ResManGetAliasFor("0e_ch_1_hb", RESTYPE_NCS) == "")
            {
                for(nIndex = 1; nIndex < 7; nIndex++)
                {
                    oAssociate = GetAssociate(ASSOCIATE_TYPE_HENCHMAN, oPC, nIndex);
                    if(oAssociate != OBJECT_INVALID) AssignCommand(oAssociate, ai_Original_StandGround());
                }
                for(nIndex = 2; nIndex < 6; nIndex++)
                {
                    oAssociate = GetAssociate(nIndex, oPC);
                    if(oAssociate != OBJECT_INVALID) AssignCommand(oAssociate, ai_Original_StandGround());
                }
            }
            // Use Philos AI commands.
            else
            {
                for(nIndex = 1; nIndex < 7; nIndex++)
                {
                    oAssociate = GetAssociate(ASSOCIATE_TYPE_HENCHMAN, oPC, nIndex);
                    if(oAssociate != OBJECT_INVALID) AssignCommand(oAssociate, ai_Philos_StandGround());
                }
                for(nIndex = 2; nIndex < 6; nIndex++)
                {
                    oAssociate = GetAssociate(nIndex, oPC);
                    if(oAssociate != OBJECT_INVALID) AssignCommand(oAssociate, ai_Philos_StandGround());
                }
            }
        }
        else if(nCommand == 4)
        {
            // Not using Philos Henchman AI. Use vanilla commands.
            if(ResManGetAliasFor("0e_ch_1_hb", RESTYPE_NCS) == "")
            {
                for(nIndex = 1; nIndex < 7; nIndex++)
                {
                    oAssociate = GetAssociate(ASSOCIATE_TYPE_HENCHMAN, oPC, nIndex);
                    if(oAssociate != OBJECT_INVALID) AssignCommand(oAssociate, ai_Original_AttackNearest());
                }
                for(nIndex = 2; nIndex < 6; nIndex++)
                {
                    oAssociate = GetAssociate(nIndex, oPC);
                    if(oAssociate != OBJECT_INVALID) AssignCommand(oAssociate, ai_Original_AttackNearest());
                }
            }
            // Use Philos AI commands.
            else
            {
                for(nIndex = 1; nIndex < 7; nIndex++)
                {
                    oAssociate = GetAssociate(ASSOCIATE_TYPE_HENCHMAN, oPC, nIndex);
                    if(oAssociate != OBJECT_INVALID) ai_Philos_AttackNearest(oAssociate);
                }
                for(nIndex = 2; nIndex < 6; nIndex++)
                {
                    oAssociate = GetAssociate(nIndex, oPC);
                    if(oAssociate != OBJECT_INVALID) ai_Philos_AttackNearest(oAssociate);
                }
            }
        }
    }
    else
    {
        if(nCommand == 1)
        {
            // Not using Philos Henchman AI. Use vanilla commands.
            if(ResManGetAliasFor("0e_ch_1_hb", RESTYPE_NCS) == "")
            {
                AssignCommand(oAssociate, ai_Original_Guard());
            }
            else ai_Philos_Guard(oAssociate);
        }
        else if(nCommand == 2)
        {
            // Not using Philos Henchman AI. Use vanilla commands.
            if(ResManGetAliasFor("0e_ch_1_hb", RESTYPE_NCS) == "")
            {
                AssignCommand(oAssociate, ai_Original_Follow());
            }
            else AssignCommand(oAssociate, ai_Philos_Follow());
        }
        else if(nCommand == 3)
        {
            // Not using Philos Henchman AI. Use vanilla commands.
            if(ResManGetAliasFor("0e_ch_1_hb", RESTYPE_NCS) == "")
            {
                AssignCommand(oAssociate, ai_Original_StandGround());
            }
            else AssignCommand(oAssociate, ai_Philos_StandGround());
        }
        else if(nCommand == 4)
        {
            // Not using Philos Henchman AI. Use vanilla commands.
            if(ResManGetAliasFor("0e_ch_1_hb", RESTYPE_NCS) == "")
            {
                AssignCommand(oAssociate, ai_Original_AttackNearest());
            }
            else ai_Philos_AttackNearest(oAssociate);
        }
    }
}
void ai_Action(object oPC, object oAssociate)
{
    if(oPC == oAssociate)
    {
        DeleteLocalObject(oPC, "NW_ASSOCIATE_COMMAND");
        SetLocalString(oPC, AI_TARGET_MODE, "ASSOCIATE_ACTION_ALL");
        ai_SendMessages("Party is in action mode!", AI_COLOR_YELLOW, oPC);
    }
    else
    {
        SetLocalObject(oPC, AI_TARGET_ASSOCIATE, oAssociate);
        SetLocalString(oPC, AI_TARGET_MODE, "ASSOCIATE_ACTION");
        ai_SendMessages(GetName(oAssociate) + " is in action mode!", AI_COLOR_YELLOW, oPC);
    }
    EnterTargetingMode(oPC, OBJECT_TYPE_ALL, MOUSECURSOR_ACTION, MOUSECURSOR_NOWALK);
}
void ai_AIScript(object oPC, object oAssociate, string sAssociateType)
{
    if(ResManGetAliasFor("0e_ch_1_hb", RESTYPE_NCS) != "")
    {
        string sScript = GetLocalString(oAssociate, AI_COMBAT_SCRIPT);
        if(sScript == "ai_a_ambusher")
        {
            SetLocalString(oAssociate, AI_COMBAT_SCRIPT, "ai_a_peaceful");
            ai_SendMessages(GetName(oAssociate) + " is now using peaceful tactics in combat.", AI_COLOR_YELLOW, oPC);
            ai_UpdateToolTipUI(oPC, sAssociateType + "_cmd_menu", sAssociateType + "_widget", "btn_cmd_ai_script_tooltip", "  Using peaceful tactics");
        }
        else if(sScript == "ai_a_peaceful")
        {
            SetLocalString(oAssociate, AI_COMBAT_SCRIPT, "ai_a_defensive");
            ai_SendMessages(GetName(oAssociate) + " is now using defensive tactics in combat.", AI_COLOR_YELLOW, oPC);
            ai_UpdateToolTipUI(oPC, sAssociateType + "_cmd_menu", sAssociateType + "_widget", "btn_cmd_ai_script_tooltip", "  Using defensive tactics");
        }
        else if(sScript == "ai_a_defensive")
        {
            SetLocalString(oAssociate, AI_COMBAT_SCRIPT, "ai_a_ranged");
            ai_SendMessages(GetName(oAssociate) + " is now using ranged tactics in combat.", AI_COLOR_YELLOW, oPC);
            ai_UpdateToolTipUI(oPC, sAssociateType + "_cmd_menu", sAssociateType + "_widget", "btn_cmd_ai_script_tooltip", "  Using ranged tactics");
        }
        else if(sScript == "ai_a_ranged")
        {
            SetLocalString(oAssociate, AI_COMBAT_SCRIPT, "ai_a_cntrspell");
            ai_SendMessages(GetName(oAssociate) + " is now using counter spell tactics in combat.", AI_COLOR_YELLOW, oPC);
            ai_UpdateToolTipUI(oPC, sAssociateType + "_cmd_menu", sAssociateType + "_widget", "btn_cmd_ai_script_tooltip", "  Using counter spell tactics");
        }
        else if(sScript == "ai_a_cntrspell")
        {
            sScript = GetLocalString(oAssociate, AI_DEFAULT_SCRIPT);
            SetLocalString(oAssociate, AI_COMBAT_SCRIPT, sScript);
            string sText;
            if(sScript == "ai_a_ambusher") sText = "ambush";
            else sText = "normal";
            ai_SendMessages(GetName(oAssociate) + " is now using " + sText + " tactics in combat.", AI_COLOR_YELLOW, oPC);
            ai_UpdateToolTipUI(oPC, sAssociateType + "_cmd_menu", sAssociateType + "_widget", "btn_cmd_ai_script_tooltip", "  Using " + sText + " tactics");
        }
        else
        {
            SetLocalString(oAssociate, AI_COMBAT_SCRIPT, "ai_a_ambusher");
            ai_SendMessages(GetName(oAssociate) + " is now using ambush tactics in combat.", AI_COLOR_YELLOW, oPC);
            ai_UpdateToolTipUI(oPC, sAssociateType + "_cmd_menu", sAssociateType + "_widget", "btn_cmd_ai_script_tooltip", "  Using ambush tactics");
        }
    }
    else
    {
        if(GetCombatCondition(X0_COMBAT_FLAG_AMBUSHER, oAssociate))
        {
            SetCombatCondition(X0_COMBAT_FLAG_AMBUSHER, FALSE, oAssociate);
            SetCombatCondition(X0_COMBAT_FLAG_COWARDLY, TRUE, oAssociate);
            SetCombatCondition(X0_COMBAT_FLAG_DEFENSIVE, FALSE, oAssociate);
            SetCombatCondition(X0_COMBAT_FLAG_RANGED, FALSE, oAssociate);
            ai_SendMessages(GetName(oAssociate) + " is now using coward tactics in combat.", AI_COLOR_YELLOW, oPC);
            ai_UpdateToolTipUI(oPC, sAssociateType + "_cmd_menu", sAssociateType + "_widget", "btn_cmd_ai_script_tooltip", "  Using coward tactics");
        }
        else if(GetCombatCondition(X0_COMBAT_FLAG_COWARDLY, oAssociate))
        {
            SetCombatCondition(X0_COMBAT_FLAG_AMBUSHER, FALSE, oAssociate);
            SetCombatCondition(X0_COMBAT_FLAG_COWARDLY, FALSE, oAssociate);
            SetCombatCondition(X0_COMBAT_FLAG_DEFENSIVE, TRUE, oAssociate);
            SetCombatCondition(X0_COMBAT_FLAG_RANGED, FALSE, oAssociate);
            ai_SendMessages(GetName(oAssociate) + " is now using defensive tactics in combat.", AI_COLOR_YELLOW, oPC);
            ai_UpdateToolTipUI(oPC, sAssociateType + "_cmd_menu", sAssociateType + "_widget", "btn_cmd_ai_script_tooltip", "  Using defensive tactics");
        }
        else if(GetCombatCondition(X0_COMBAT_FLAG_DEFENSIVE, oAssociate))
        {
            SetCombatCondition(X0_COMBAT_FLAG_AMBUSHER, FALSE, oAssociate);
            SetCombatCondition(X0_COMBAT_FLAG_COWARDLY, FALSE, oAssociate);
            SetCombatCondition(X0_COMBAT_FLAG_DEFENSIVE, FALSE, oAssociate);
            SetCombatCondition(X0_COMBAT_FLAG_RANGED, TRUE, oAssociate);
            ai_SendMessages(GetName(oAssociate) + " is now using ranged tactics in combat.", AI_COLOR_YELLOW, oPC);
            ai_UpdateToolTipUI(oPC, sAssociateType + "_cmd_menu", sAssociateType + "_widget", "btn_cmd_ai_script_tooltip", "  Using ranged tactics");
        }
        else if(GetCombatCondition(X0_COMBAT_FLAG_RANGED, oAssociate))
        {
            SetCombatCondition(X0_COMBAT_FLAG_AMBUSHER, FALSE, oAssociate);
            SetCombatCondition(X0_COMBAT_FLAG_COWARDLY, FALSE, oAssociate);
            SetCombatCondition(X0_COMBAT_FLAG_DEFENSIVE, FALSE, oAssociate);
            SetCombatCondition(X0_COMBAT_FLAG_RANGED, FALSE, oAssociate);
            ai_SendMessages(GetName(oAssociate) + " is now using normal tactics in combat.", AI_COLOR_YELLOW, oPC);
            ai_UpdateToolTipUI(oPC, sAssociateType + "_cmd_menu", sAssociateType + "_widget", "btn_cmd_ai_script_tooltip", "  Using ambush tactics");
        }
        else
        {
            SetCombatCondition(X0_COMBAT_FLAG_AMBUSHER, TRUE, oAssociate);
            SetCombatCondition(X0_COMBAT_FLAG_COWARDLY, FALSE, oAssociate);
            SetCombatCondition(X0_COMBAT_FLAG_DEFENSIVE, FALSE, oAssociate);
            SetCombatCondition(X0_COMBAT_FLAG_RANGED, FALSE, oAssociate);
            ai_SendMessages(GetName(oAssociate) + " is now using ambush tactics in combat.", AI_COLOR_YELLOW, oPC);
            ai_UpdateToolTipUI(oPC, sAssociateType + "_cmd_menu", sAssociateType + "_widget", "btn_cmd_ai_script_tooltip", "  Using ambush tactics");
        }
    }
}
void ai_PlaceTrap(object oPC, object oAssociate)
{
    SetLocalObject(oPC, AI_TARGET_ASSOCIATE, oAssociate);
    SetLocalString(oPC, AI_TARGET_MODE, "ASSOCIATE_GET_TRAP");
    ai_SendMessages(GetName(oAssociate) + " select a trap to place.", AI_COLOR_YELLOW, oPC);
    OpenInventory(oAssociate, oPC);
    EnterTargetingMode(oPC, OBJECT_TYPE_ITEM, MOUSECURSOR_ACTION, MOUSECURSOR_NOWALK);
}
void ai_PlugIn_Execute(object oPC, string sElem)
{
    int nIndex = StringToInt(GetStringRight(sElem, 1)) - 1;
    json jPlugins = ai_GetAssociateDbJson(oPC, "pc", "plugins");
    string sScript = JsonGetString(JsonArrayGet(jPlugins, nIndex));
    if(ResManGetAliasFor(sScript, RESTYPE_NCS) == "")
    {
        ai_SendMessages(sScript + " not found by ResMan!", AI_COLOR_RED, oPC);
    }
    else
    {
        ai_SendMessages("Executing " + sScript + " script.", AI_COLOR_GREEN, oPC);
        ExecuteScript(sScript, oPC);
    }
}
