/*//////////////////////////////////////////////////////////////////////////////
 Script Name: 0e_nui
 Programmer: Philos
////////////////////////////////////////////////////////////////////////////////
 Menu event script
    sEvent: close, click, mousedown, mouseup, watch (if bindwatch is set).
/*//////////////////////////////////////////////////////////////////////////////
#include "x0_i0_assoc"
#include "0i_menus"
// Flips a Widget Buttons state.
void ai_FlipWidgetButton(object oPC, int nButton, string sAssociateType);
// Flips an AI Buttons state.
void ai_FlipAIButton(object oPC, int nButton, string sAssociateType);
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
// Turns on oTargets AI, Setting all event scripts.
void ai_TurnOn(object oPC, object oAssociate, string sAssociateType);
// Turns off oTargets AI, Setting all event scripts.
void ai_TurnOff(object oPC, object oAssociate, string sAssociateType);
// Turns on/off Ranged combat for oTarget.
void ai_Ranged(object oPC, object oAssociate, string sAssociateType);
// Turns on/off Search for oTarget.
void ai_Search(object oPC, object oAssociate, string sAssociateType);
// Turns on/off Stealth for oTarget.
void ai_Stealth(object oPC, object oAssociate, string sAssociateType);
// Turns on/off Disarming of Traps for oTarget.
void ai_Traps(object oPC, object oAssociate, string sAssociateType);
// Turns on/off Picking locks for oTarget.
void ai_Locks(object oPC, object oAssociate, string sAssociateType);
// Adjust magic use options for oTarget.
void ai_UseMagic(object oPC, object oAssociate, int bNoMagic, int bDefMagic, int bOffMagic, string sAssociateType);
// Adjusts loot options for oTarget
void ai_Loot(object oPC, object oAssociate, int bLoot, int bLootGems, int bLootMagic, string sAssociateType);
// Increments/Decrements the magic use variable for the AI.
void ai_MagicIncrement(object oPC, object oAssociate, int nIncrement, string sAssociateType);
// Button action for buffing a PC.
void ai_Buff_Button(object oPC, object oAssociate, int nOption, string sAssociateType);
// Button action for setting healing ranges.
void ai_Heal_Button(object oPC, object oAssociate, int nIncrement, string sVar, string sAssociateType);
// Button action for turning healing on/off.
void ai_Heal_OnOff(object oPC, object oAssociate, string sAssociateType);
// Button action for giving commands.
void ai_DoCommand(object oPC, object oAssociate, int nCommand);
// Executes an installed plugin.
void ai_PlugIn_Execute(object oPC, string sElem);
void main()
{
    object oPC = NuiGetEventPlayer();
    int nToken  = NuiGetEventWindow();
    string sEvent = NuiGetEventType();
    string sElem  = NuiGetEventElement();
    int nIndex = NuiGetEventArrayIndex();
    string sWndId = NuiGetWindowId(oPC, nToken);
    //ai_Debug ("0e_nui", "61", "sWndId: " + sWndId + " sEvent: " + sEvent + " sElem: " + sElem);
    // Get if the menu has an associate attached.
    json jData = NuiGetUserData (oPC, nToken);
    string sAssociateType = JsonGetString(JsonArrayGet(jData, 0));
    object oAssociate = ai_GetAssociateByStringType(oPC, sAssociateType);
    //ai_Debug("0e_nui", "66", "oAssociate: " + GetName(oAssociate) + " sAssociateType: " + sAssociateType);
    //**************************************************************************
    // Watch to see if the window moves and save.
    if(sElem == "window_geometry" && sEvent == "watch")
    {
        if(!GetLocalInt (oPC, AI_NO_NUI_SAVE))
        {
            // Get the height, width, x, and y of the window.
            json jGeom = NuiGetBind(oPC, nToken, "window_geometry");
            // Save on the player using the sWndId.
            SetLocalFloat(oPC, sWndId + "_X", JsonGetFloat (JsonObjectGet (jGeom, "x")));
            SetLocalFloat(oPC, sWndId + "_Y", JsonGetFloat (JsonObjectGet (jGeom, "y")));
        }
        return;
    }
    //**************************************************************************
    // Main AI events.
    if(sWndId == "ai_main_nui")
    {
        if(sEvent == "click")
        {
            if(sElem == "btn_familiar_widget")
            {
                int nNuiToken = NuiFindWindow(oPC, "familiar_widget");
                if(nNuiToken) NuiDestroy(oPC, nNuiToken);
                else
                {
                    object oAssociate = GetAssociate(ASSOCIATE_TYPE_FAMILIAR, oPC);
                    if(oAssociate != OBJECT_INVALID) ai_CreateWidgetNUI(oPC, oAssociate);
                    else ai_SendMessages("You must have a familiar summoned to open the familiar widget!", COLOR_RED, oPC);
                }
            }
            else if(sElem == "btn_companion_widget")
            {
                int nNuiToken = NuiFindWindow(oPC, "companion_widget");
                if(nNuiToken) NuiDestroy(oPC, nNuiToken);
                else
                {
                    object oAssociate = GetAssociate(ASSOCIATE_TYPE_ANIMALCOMPANION, oPC);
                    if(oAssociate != OBJECT_INVALID) ai_CreateWidgetNUI(oPC, oAssociate);
                    else ai_SendMessages("You must have an animal companion summoned to open the companion widget!", COLOR_RED, oPC);
                }
            }
            else if(sElem == "btn_summons_widget")
            {
                int nNuiToken = NuiFindWindow(oPC, "summons_widget");
                if(nNuiToken) NuiDestroy(oPC, nNuiToken);
                else
                {
                    object oAssociate = GetAssociate(ASSOCIATE_TYPE_SUMMONED, oPC);
                    if(oAssociate != OBJECT_INVALID) ai_CreateWidgetNUI(oPC, oAssociate);
                    else ai_SendMessages("You must have a monster summoned to open the summons widget!", COLOR_RED, oPC);
                }
            }
            else if(sElem == "btn_toggle_assoc_widget")
            {
                if(GetLocalInt(oPC, "AI_ASSOCIATE_WIDGET_OFF"))
                {
                    DeleteLocalInt(oPC, "AI_ASSOCIATE_WIDGET_OFF");
                    object oAssociate = GetAssociate(ASSOCIATE_TYPE_FAMILIAR, oPC);
                    if(oAssociate != OBJECT_INVALID) ai_CreateWidgetNUI(oPC, oAssociate);
                    oAssociate = GetAssociate(ASSOCIATE_TYPE_ANIMALCOMPANION, oPC);
                    if(oAssociate != OBJECT_INVALID) ai_CreateWidgetNUI(oPC, oAssociate);
                    oAssociate = GetAssociate(ASSOCIATE_TYPE_SUMMONED, oPC);
                    if(oAssociate != OBJECT_INVALID) ai_CreateWidgetNUI(oPC, oAssociate);
                    oAssociate = GetAssociate(ASSOCIATE_TYPE_HENCHMAN, oPC, 1);
                    if(oAssociate != OBJECT_INVALID) ai_CreateWidgetNUI(oPC, oAssociate);
                    oAssociate = GetAssociate(ASSOCIATE_TYPE_HENCHMAN, oPC, 2);
                    if(oAssociate != OBJECT_INVALID) ai_CreateWidgetNUI(oPC, oAssociate);
                    oAssociate = GetAssociate(ASSOCIATE_TYPE_HENCHMAN, oPC, 3);
                    if(oAssociate != OBJECT_INVALID) ai_CreateWidgetNUI(oPC, oAssociate);
                    oAssociate = GetAssociate(ASSOCIATE_TYPE_HENCHMAN, oPC, 4);
                    if(oAssociate != OBJECT_INVALID) ai_CreateWidgetNUI(oPC, oAssociate);
                }
                else
                {
                    SetLocalInt(oPC, "AI_ASSOCIATE_WIDGET_OFF", TRUE);
                    NuiDestroy(oPC, NuiFindWindow(oPC, "familiar_widget"));
                    NuiDestroy(oPC, NuiFindWindow(oPC, "companion_widget"));
                    NuiDestroy(oPC, NuiFindWindow(oPC, "summons_widget"));
                    NuiDestroy(oPC, NuiFindWindow(oPC, "henchman1_widget"));
                    NuiDestroy(oPC, NuiFindWindow(oPC, "henchman2_widget"));
                    NuiDestroy(oPC, NuiFindWindow(oPC, "henchman3_widget"));
                    NuiDestroy(oPC, NuiFindWindow(oPC, "henchman4_widget"));
                    NuiDestroy(oPC, NuiFindWindow(oPC, "henchman5_widget"));
                    NuiDestroy(oPC, NuiFindWindow(oPC, "henchman6_widget"));
                }
            }
            else if(sElem == "btn_add_plugin")
            {
                string sScript = JsonGetString (NuiGetBind (oPC, nToken, "txt_plugin"));
                if(sScript == "") ai_SendMessages("You must type the name of the script!", COLOR_RED, oPC);
                else if(ResManGetAliasFor(sScript, RESTYPE_NCS) == "")
                {
                    ai_SendMessages("The script cannot be found by ResMan!", COLOR_RED, oPC);
                }
                else
                {
                    int nIndex = 1;
                    string sIndex = "1";
                    string sVariable = GetLocalString(oPC, "AI_PLUGIN_SCRIPT_1");
                    while (nIndex <= WIDGET_MAX_PLUGINS)
                    {
                        if(sVariable == "") break;
                        sIndex = IntToString(++nIndex);
                        sVariable = GetLocalString(oPC, "AI_PLUGIN_SCRIPT_" + sIndex);
                    }
                    if(nIndex == WIDGET_MAX_PLUGINS + 1)
                    {
                        ai_SendMessages("You can only have " + IntToString(WIDGET_MAX_PLUGINS) + " plugins at once!", COLOR_RED, oPC);
                    }
                    else
                    {
                        SetLocalString(oPC, "AI_PLUGIN_SCRIPT_" + sIndex, sScript);
                        NuiDestroy(oPC, nToken);
                        ai_CreateAIOptionsNUI(oPC);
                        NuiDestroy(oPC, NuiFindWindow(oPC, "pc_widget"));
                        ai_CreateWidgetNUI(oPC, oPC);
                    }
                }
            }
            else if(GetStringLeft(sElem, 18) == "btn_remove_plugin_")
            {
                string sIndex = GetStringRight(sElem, 1);
                DeleteLocalString(oPC, "AI_PLUGIN_SCRIPT_" + sIndex);
                NuiDestroy(oPC, nToken);
                ai_CreateAIOptionsNUI(oPC);
                NuiDestroy(oPC, NuiFindWindow(oPC, "pc_widget"));
                ai_CreateWidgetNUI(oPC, oPC);
            }
        }
    }
    //**************************************************************************
    // Associate AI events.
    else if(sWndId == sAssociateType + "_menu")
    {
        // Right now this only works for the PC, but we might expand this later!
        if(sEvent == "click")
        {
            if(sElem == "btn_widget_lock")
            {
                if(ai_GetAssociateWidgetButton(oPC, BTN_WIDGET_LOCK, sAssociateType))
                {
                    SendMessageToPC(oPC, GetName(oAssociate) + " AI widget unlocked.");
                    ai_SetAssociateWidgetButton(oPC, BTN_WIDGET_LOCK, sAssociateType, FALSE);
                    NuiDestroy(oPC, NuiFindWindow(oPC, sAssociateType + "_widget"));
                    ai_CreateWidgetNUI(oPC, oAssociate);
                }
                else
                {
                    // Get the height, width, x, and y of the window.
                    json jGeom = NuiGetBind(oPC, NuiFindWindow(oPC, sAssociateType + "_widget"), "window_geometry");
                    // Save the window location on the player using the sWndId.
                    SetLocalFloat(oAssociate, sWndId + "_X", JsonGetFloat (JsonObjectGet (jGeom, "x")));
                    SetLocalFloat(oAssociate, sWndId + "_Y", JsonGetFloat (JsonObjectGet (jGeom, "y")));
                    SendMessageToPC(oPC, GetName(oAssociate) + " AI widget locked.");
                    ai_SetAssociateWidgetButton(oPC, BTN_WIDGET_LOCK, sAssociateType, TRUE);
                    NuiDestroy(oPC, NuiFindWindow(oPC, sAssociateType + "_widget"));
                    ai_CreateWidgetNUI(oPC, oAssociate);
                }
            }
            else if(sElem == "btn_options")
            {
                NuiDestroy(oPC, nToken);
                ai_CreateAIOptionsNUI(oPC);
            }
            else if(sElem == "btn_ai")
            {
                if(GetEventScript(oAssociate, EVENT_SCRIPT_CREATURE_ON_HEARTBEAT) == "xx_pc_1_hb") ai_TurnOff(oPC, oAssociate, sAssociateType);
                else ai_TurnOn(oPC, oAssociate, sAssociateType);
            }
            else if(sElem == "btn_ranged") ai_Ranged(oPC, oAssociate, sAssociateType);
            else if(sElem == "btn_search") ai_Search(oPC, oAssociate, sAssociateType);
            else if(sElem == "btn_stealth") ai_Stealth(oPC, oAssociate, sAssociateType);
            else if(sElem == "btn_traps") ai_Traps(oPC, oAssociate, sAssociateType);
            else if(sElem == "btn_locks") ai_Locks(oPC, oAssociate, sAssociateType);
            else if(sElem == "btn_magic_plus") ai_MagicIncrement(oPC, oAssociate, 1, sAssociateType);
            else if(sElem == "btn_magic_minus") ai_MagicIncrement(oPC, oAssociate, -1, sAssociateType);
            else if(sElem == "btn_no_magic") ai_UseMagic(oPC, oAssociate, TRUE, FALSE, FALSE, sAssociateType);
            else if(sElem == "btn_all_magic") ai_UseMagic(oPC, oAssociate, FALSE, FALSE, FALSE, sAssociateType);
            else if(sElem == "btn_def_magic") ai_UseMagic(oPC, oAssociate, FALSE, TRUE, FALSE, sAssociateType);
            else if(sElem == "btn_off_magic") ai_UseMagic(oPC, oAssociate, FALSE, FALSE, TRUE, sAssociateType);
            else if(sElem == "btn_no_loot") ai_Loot(oPC, oAssociate, FALSE, FALSE, FALSE, sAssociateType);
            else if(sElem == "btn_loot_all") ai_Loot(oPC, oAssociate, TRUE, FALSE, FALSE, sAssociateType);
            else if(sElem == "btn_loot_gems") ai_Loot(oPC, oAssociate, TRUE, TRUE, FALSE, sAssociateType);
            else if(sElem == "btn_loot_magic") ai_Loot(oPC, oAssociate, TRUE, FALSE, TRUE, sAssociateType);
            else if(sElem == "btn_buff_short") ai_Buff_Button(oPC, oAssociate, 2, sAssociateType);
            else if(sElem == "btn_buff_long") ai_Buff_Button(oPC, oAssociate, 3, sAssociateType);
            else if(sElem == "btn_buff_all") ai_Buff_Button(oPC, oAssociate, 1, sAssociateType);
            else if(sElem == "btn_buff_rest") ai_Buff_Button(oPC, oAssociate, 0, sAssociateType);
            else if(sElem == "btn_heal_out_plus") ai_Heal_Button(oPC, oAssociate, 5, AI_HEAL_OUT_OF_COMBAT_LIMIT, sAssociateType);
            else if(sElem == "btn_heal_out_minus") ai_Heal_Button(oPC, oAssociate, -5, AI_HEAL_OUT_OF_COMBAT_LIMIT, sAssociateType);
            else if(sElem == "btn_heal_in_plus") ai_Heal_Button(oPC, oAssociate, 5, AI_HEAL_IN_COMBAT_LIMIT, sAssociateType);
            else if(sElem == "btn_heal_in_minus") ai_Heal_Button(oPC, oAssociate, -5, AI_HEAL_IN_COMBAT_LIMIT, sAssociateType);
            else if(sElem == "btn_heal_onoff") ai_Heal_OnOff(oPC, oAssociate, sAssociateType);
            else if(sElem == "btn_cmd_guard") ai_DoCommand(oPC, oAssociate, 1);
            else if(sElem == "btn_cmd_follow") ai_DoCommand(oPC, oAssociate, 2);
            else if(sElem == "btn_cmd_hold") ai_DoCommand(oPC, oAssociate, 3);
            else if(sElem == "btn_cmd_attack") ai_DoCommand(oPC, oAssociate, 4);
            ai_SaveAssociateData(oPC, oAssociate);
        }
        if(sEvent == "watch")
        {
            if(sElem == "chbx_buff_rest_check") ai_FlipWidgetButton(oPC, BTN_BUFF_REST, sAssociateType);
            else if(sElem == "chbx_cmd_guard_check") ai_FlipWidgetButton(oPC, BTN_CMD_GUARD, sAssociateType);
            else if(sElem == "chbx_cmd_follow_check") ai_FlipWidgetButton(oPC, BTN_CMD_FOLLOW, sAssociateType);
            else if(sElem == "chbx_cmd_hold_check") ai_FlipWidgetButton(oPC, BTN_CMD_HOLD, sAssociateType);
            else if(sElem == "chbx_cmd_attack_check") ai_FlipWidgetButton(oPC, BTN_CMD_ATTACK, sAssociateType);
            else if(sElem == "chbx_buff_short_check") ai_FlipWidgetButton(oPC, BTN_BUFF_SHORT, sAssociateType);
            else if(sElem == "chbx_buff_long_check") ai_FlipWidgetButton(oPC, BTN_BUFF_LONG, sAssociateType);
            else if(sElem == "chbx_buff_all_check") ai_FlipWidgetButton(oPC, BTN_BUFF_ALL, sAssociateType);
            else if(sElem == "chbx_ai_check") ai_FlipAIButton(oPC, BTN_AI_FOR_PC, sAssociateType);
            else if(sElem == "chbx_ranged_check") ai_FlipAIButton(oPC, BTN_AI_USE_RANGED, sAssociateType);
            else if(sElem == "chbx_search_check") ai_FlipAIButton(oPC, BTN_AI_USE_SEARCH, sAssociateType);
            else if(sElem == "chbx_stealth_check") ai_FlipAIButton(oPC, BTN_AI_USE_STEALTH, sAssociateType);
            else if(sElem == "chbx_traps_check") ai_FlipAIButton(oPC, BTN_AI_REMOVE_TRAPS, sAssociateType);
            else if(sElem == "chbx_locks_check") ai_FlipAIButton(oPC, BTN_AI_BYPASS_LOCKS, sAssociateType);
            else if(sElem == "chbx_magic_plus_check") ai_FlipAIButton(oPC, BTN_AI_MAGIC_USE_PLUS, sAssociateType);
            else if(sElem == "chbx_magic_minus_check") ai_FlipAIButton(oPC, BTN_AI_MAGIC_USE_MINUS, sAssociateType);
            else if(sElem == "chbx_no_magic_check") ai_FlipAIButton(oPC, BTN_AI_NO_MAGIC_USE, sAssociateType);
            else if(sElem == "chbx_all_magic_check") ai_FlipAIButton(oPC, BTN_AI_ALL_MAGIC_USE, sAssociateType);
            else if(sElem == "chbx_def_magic_check") ai_FlipAIButton(oPC, BTN_AI_DEF_MAGIC_USE, sAssociateType);
            else if(sElem == "chbx_off_magic_check") ai_FlipAIButton(oPC, BTN_AI_OFF_MAGIC_USE, sAssociateType);
            else if(sElem == "chbx_no_loot_check") ai_FlipAIButton(oPC, BTN_AI_PICKUP_NO_LOOT, sAssociateType);
            else if(sElem == "chbx_loot_all_check") ai_FlipAIButton(oPC, BTN_AI_PICKUP_ALL_LOOT, sAssociateType);
            else if(sElem == "chbx_loot_gems_check") ai_FlipAIButton(oPC, BTN_AI_PICKUP_GEMS_LOOT, sAssociateType);
            else if(sElem == "chbx_loot_magic_check") ai_FlipAIButton(oPC, BTN_AI_PICKUP_MAGIC_LOOT, sAssociateType);
            else if(sElem == "chbx_heal_out_plus_check") ai_FlipAIButton(oPC, BTN_AI_HEAL_OUT_PLUS, sAssociateType);
            else if(sElem == "chbx_heal_out_minus_check") ai_FlipAIButton(oPC, BTN_AI_HEAL_OUT_MINUS, sAssociateType);
            else if(sElem == "chbx_heal_in_plus_check") ai_FlipAIButton(oPC, BTN_AI_HEAL_IN_PLUS, sAssociateType);
            else if(sElem == "chbx_heal_in_minus_check") ai_FlipAIButton(oPC, BTN_AI_HEAL_IN_MINUS, sAssociateType);
            else if(sElem == "chbx_heal_onoff_check") ai_FlipAIButton(oPC, BTN_AI_STOP_HEALING, sAssociateType);
            NuiDestroy(oPC, NuiFindWindow(oPC, sAssociateType + "_widget"));
            ai_CreateWidgetNUI(oPC, oAssociate);
        }
    }
    else if(sWndId == sAssociateType + "_widget")
    {
        if(sEvent == "click")
        {
            if(sElem == "btn_open_main")
            {
                //ai_Debug("0e_nui", "293", "Code Break");
                if(IsWindowClosed(oPC, sAssociateType + "_menu")) ai_CreateAssociateAINUI(oPC, oAssociate);
            }
            else
            {
                if(sElem == "btn_ai")
                {
                if(GetEventScript(oAssociate, EVENT_SCRIPT_CREATURE_ON_HEARTBEAT) == "xx_pc_1_hb") ai_TurnOff(oPC, oAssociate, sAssociateType);
                else ai_TurnOn(oPC, oAssociate, sAssociateType);
                }
                else if(sElem == "btn_ranged") ai_Ranged(oPC, oAssociate, sAssociateType);
                else if(sElem == "btn_search") ai_Search(oPC, oAssociate, sAssociateType);
                else if(sElem == "btn_stealth") ai_Stealth(oPC, oAssociate, sAssociateType);
                else if(sElem == "btn_traps") ai_Traps(oPC, oAssociate, sAssociateType);
                else if(sElem == "btn_locks") ai_Locks(oPC, oAssociate, sAssociateType);
                else if(sElem == "btn_magic_minus") ai_MagicIncrement(oPC, oAssociate, -1, sAssociateType);
                else if(sElem == "btn_magic_plus") ai_MagicIncrement(oPC, oAssociate, 1, sAssociateType);
                else if(sElem == "btn_no_magic") ai_UseMagic(oPC, oAssociate, TRUE, FALSE, FALSE, sAssociateType);
                else if(sElem == "btn_all_magic") ai_UseMagic(oPC, oAssociate, FALSE, FALSE, FALSE, sAssociateType);
                else if(sElem == "btn_def_magic") ai_UseMagic(oPC, oAssociate, FALSE, TRUE, FALSE, sAssociateType);
                else if(sElem == "btn_off_magic") ai_UseMagic(oPC, oAssociate, FALSE, FALSE, TRUE, sAssociateType);
                else if(sElem == "btn_no_loot") ai_Loot(oPC, oAssociate, FALSE, FALSE, FALSE, sAssociateType);
                else if(sElem == "btn_loot_all") ai_Loot(oPC, oAssociate, TRUE, FALSE, FALSE, sAssociateType);
                else if(sElem == "btn_loot_gems") ai_Loot(oPC, oAssociate, TRUE, TRUE, FALSE, sAssociateType);
                else if(sElem == "btn_loot_magic") ai_Loot(oPC, oAssociate, TRUE, FALSE, TRUE, sAssociateType);
                else if(sElem == "btn_buff_short") ai_Buff_Button(oPC, oAssociate, 2, sAssociateType);
                else if(sElem == "btn_buff_long") ai_Buff_Button(oPC, oAssociate, 3, sAssociateType);
                else if(sElem == "btn_buff_all") ai_Buff_Button(oPC, oAssociate, 1, sAssociateType);
                else if(sElem == "btn_buff_rest") ai_Buff_Button(oPC, oAssociate, 1, sAssociateType);
                else if(sElem == "btn_heal_out_plus") ai_Heal_Button(oPC, oAssociate, 5, AI_HEAL_OUT_OF_COMBAT_LIMIT, sAssociateType);
                else if(sElem == "btn_heal_out_minus") ai_Heal_Button(oPC, oAssociate, -5, AI_HEAL_OUT_OF_COMBAT_LIMIT, sAssociateType);
                else if(sElem == "btn_heal_in_plus") ai_Heal_Button(oPC, oAssociate, 5, AI_HEAL_IN_COMBAT_LIMIT, sAssociateType);
                else if(sElem == "btn_heal_in_minus") ai_Heal_Button(oPC, oAssociate, -5, AI_HEAL_IN_COMBAT_LIMIT, sAssociateType);
                else if(sElem == "btn_heal_onoff") ai_Heal_OnOff(oPC, oAssociate, sAssociateType);
                else if(sElem == "btn_cmd_guard") ai_DoCommand(oPC, oAssociate, 1);
                else if(sElem == "btn_cmd_follow") ai_DoCommand(oPC, oAssociate, 2);
                else if(sElem == "btn_cmd_hold") ai_DoCommand(oPC, oAssociate, 3);
                else if(sElem == "btn_cmd_attack") ai_DoCommand(oPC, oAssociate, 4);
                else if(GetStringLeft(sElem, 15) == "btn_exe_plugin_") ai_PlugIn_Execute(oPC, sElem);
                ai_SaveAssociateData(oPC, oAssociate);
            }
        }
    }
}
void ai_FlipWidgetButton(object oPC, int nButton, string sAssociateType)
{
    ai_SetAssociateWidgetButton(oPC, nButton, sAssociateType, !ai_GetAssociateWidgetButton(oPC, nButton, sAssociateType));
}
void ai_FlipAIButton(object oPC, int nButton, string sAssociateType)
{
    ai_SetAssociateAIButton(oPC, nButton, sAssociateType, !ai_GetAssociateAIButton(oPC, nButton, sAssociateType));
}
void ai_UpdateToolTipUI(object oPC, string sAssociateType, string sToolTipBind, string sText)
{
    int nMenuToken = NuiFindWindow(oPC, sAssociateType + "_menu");
    if(nMenuToken)
    {
        NuiSetBind (oPC, nMenuToken, sToolTipBind, JsonString (sText));
        NuiSetBind (oPC, nMenuToken, sToolTipBind, JsonString (sText));
    }
    int nWidgetToken = NuiFindWindow(oPC, sAssociateType + "_widget");
    if(nWidgetToken)
    {
        NuiSetBind (oPC, nWidgetToken, sToolTipBind, JsonString (sText));
        NuiSetBind (oPC, nWidgetToken, sToolTipBind, JsonString (sText));
    }
}
void ai_TurnOn(object oPC, object oTarget, string sAssociateType)
{
    ai_UpdateToolTipUI(oPC, sAssociateType, "btn_ai_tooltip", "  AI [On] Turn off");
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
    ai_UpdateToolTipUI(oPC, sAssociateType, "btn_ai_tooltip", "  AI [Off] Turn on");
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
}
// Turns on/off Ranged combat for oTarget.
void ai_Ranged(object oPC, object oAssociate, string sAssociateType)
{
    if(ai_GetAssociateMode(oAssociate, AI_MODE_STOP_RANGED))
    {
        SendMessageToPC(oPC, GetName(oAssociate) + " is using ranged combat.");
        ai_UpdateToolTipUI(oPC, sAssociateType, "btn_ranged_tooltip", "  Ranged [On] Turn off");
        ai_SetAssociateMode(oAssociate, AI_MODE_STOP_RANGED, FALSE);
        ai_ClearCreatureActions(oAssociate);
        ai_EquipBestRangedWeapon(oAssociate);
    }
    else
    {
        SendMessageToPC(oPC, GetName(oAssociate) + " is using melee combat only.");
        ai_UpdateToolTipUI(oPC, sAssociateType, "btn_ranged_tooltip", "  Ranged [Off] Turn on");
        ai_SetAssociateMode(oAssociate, AI_MODE_STOP_RANGED, TRUE);
        ai_ClearCreatureActions(oAssociate);
        ai_EquipBestMeleeWeapon(oAssociate);
    }
}
// Turns on/off Search for oTarget.
void ai_Search(object oPC, object oAssociate, string sAssociateType)
{
    if(ai_GetAssociateMode(oAssociate, AI_MODE_AGGRESSIVE_SEARCH))
    {
        SetActionMode(oPC, ACTION_MODE_DETECT, FALSE);
        SendMessageToPC(oPC, GetName(oAssociate) + " is turning search off.");
        ai_UpdateToolTipUI(oPC, sAssociateType, "btn_search_tooltip", "  Search [Off] Turn on");
        ai_SetAssociateMode(oAssociate, AI_MODE_AGGRESSIVE_SEARCH, FALSE);
    }
    else
    {
        SetActionMode(oPC, ACTION_MODE_DETECT, TRUE);
        SendMessageToPC(oPC, GetName(oAssociate) + " is turning search on.");
        ai_UpdateToolTipUI(oPC, sAssociateType, "btn_search_tooltip", "  Search [On] Turn off");
        ai_SetAssociateMode(oAssociate, AI_MODE_AGGRESSIVE_SEARCH, TRUE);
    }
}
// Turns on/off Stealth for oTarget.
void ai_Stealth(object oPC, object oAssociate, string sAssociateType)
{
    if(ai_GetAssociateMode(oAssociate, AI_MODE_AGGRESSIVE_STEALTH))
    {
        SetActionMode(oAssociate, ACTION_MODE_STEALTH, FALSE);
        SendMessageToPC(oPC, GetName(oAssociate) + " is turning stealth off.");
        ai_UpdateToolTipUI(oPC, sAssociateType, "btn_stealth_tooltip", "  Stealth [Off] Turn on");
        ai_SetAssociateMode(oAssociate, AI_MODE_AGGRESSIVE_STEALTH, FALSE);
    }
    else
    {
        SendMessageToPC(oPC, GetName(oAssociate) + " is turning stealth on.");
        ai_UpdateToolTipUI(oPC, sAssociateType, "btn_stealth_tooltip", "  Stealth [On] Turn off");
        ai_SetAssociateMode(oAssociate, AI_MODE_AGGRESSIVE_STEALTH, TRUE);
    }
}
// Turns on/off Disarming of Traps for oTarget.
void ai_Traps(object oPC, object oAssociate, string sAssociateType)
{
    if(ai_GetAssociateMode(oAssociate, AI_MODE_DISARM_TRAPS))
    {
        SendMessageToPC(oPC, GetName(oAssociate) + " will stop disarming traps.");
        ai_UpdateToolTipUI(oPC, sAssociateType, "btn_traps_tooltip", "  Disable Traps [Off] Turn on");
        ai_SetAssociateMode(oAssociate, AI_MODE_DISARM_TRAPS, FALSE);
    }
    else
    {
        SendMessageToPC(oPC, GetName(oAssociate) + " will now disarm traps.");
        ai_UpdateToolTipUI(oPC, sAssociateType, "btn_traps_tooltip", "  Disable Traps [Off] Turn on");
        ai_SetAssociateMode(oAssociate, AI_MODE_DISARM_TRAPS, TRUE);
    }
}
// Turns on/off Picking locks for oTarget.
void ai_Locks(object oPC, object oAssociate, string sAssociateType)
{
    if(ai_GetAssociateMode(oAssociate, AI_MODE_OPEN_LOCKS))
    {
        SendMessageToPC(oPC, GetName(oAssociate) + " will stop bypassing locks.");
        ai_UpdateToolTipUI(oPC, sAssociateType, "btn_locks_tooltip", "  Bypass Locks [Off] Turn on");
        ai_SetAssociateMode(oAssociate, AI_MODE_OPEN_LOCKS, FALSE);
    }
    else
    {
        SendMessageToPC(oPC, GetName(oAssociate) + " will now bypass locks.");
        ai_UpdateToolTipUI(oPC, sAssociateType, "btn_locks_tooltip", "  Bypass locks [On] Turn off");
        ai_SetAssociateMode(oAssociate, AI_MODE_OPEN_LOCKS, TRUE);
    }
}
void ai_UseMagic(object oPC, object oAssociate, int bNoMagic, int bDefMagic, int bOffMagic, string sAssociateType)
{
    string sText = " is using any magic in combat.";
    if(bNoMagic) sText = " is not using magic in combat.";
    else if(bDefMagic) sText = " is only using defensive spells in combat.";
    else if(bOffMagic) sText = " is only using Offensive spells in combat.";
    SendMessageToPC(oPC, GetName(oAssociate) + sText);
    ai_SetAssociateMagicMode(oAssociate, AI_MAGIC_NO_MAGIC, bNoMagic);
    ai_SetAssociateMagicMode(oAssociate, AI_MAGIC_DEFENSIVE_CASTING, bDefMagic);
    ai_SetAssociateMagicMode(oAssociate, AI_MAGIC_OFFENSIVE_CASTING, bOffMagic);
    sText = "  [Any]";
    if(ai_GetAssociateMagicMode(oAssociate, AI_MAGIC_NO_MAGIC)) sText = "  [None]";
    else if(ai_GetAssociateMagicMode(oAssociate, AI_MAGIC_DEFENSIVE_CASTING)) sText = "  [Defense]";
    else if(ai_GetAssociateMagicMode(oAssociate, AI_MAGIC_OFFENSIVE_CASTING)) sText = "  [Offense]";
    ai_UpdateToolTipUI(oPC, sAssociateType, "btn_no_magic_tooltip", sText + " Turn magic use off");
    ai_UpdateToolTipUI(oPC, sAssociateType, "btn_all_magic_tooltip", sText + " Use any magic");
    ai_UpdateToolTipUI(oPC, sAssociateType, "btn_def_magic_tooltip", sText + " Use defensive magic only");
    ai_UpdateToolTipUI(oPC, sAssociateType, "btn_off_magic_tooltip", sText + " Use offensive magic only");
}
void ai_Loot(object oPC, object oAssociate, int bLoot, int bLootGems, int bLootMagic, string sAssociateType)
{
    string sText = " is not picking up any items.";
    if(bLoot)
    {
        sText = " is picking up all items.";
        if(bLootGems) sText = " is picking up gold, gems, and magic items only.";
        else if(bLootMagic) sText = " is picking up gold and magic items only.";
    }
    SendMessageToPC(oPC, GetName(oAssociate) + sText);
    ai_SetAssociateMode(oAssociate, AI_MODE_PICKUP_ITEMS, bLoot);
    ai_SetAssociateMode(oAssociate, AI_MODE_PICKUP_GEMS_ITEMS, bLootGems);
    ai_SetAssociateMode(oAssociate, AI_MODE_PICKUP_MAGIC_ITEMS, bLootMagic);
    sText = "  [None]";
    if(ai_GetAssociateMode(oAssociate, AI_MODE_PICKUP_GEMS_ITEMS)) sText = "  [Gems]";
    else if(ai_GetAssociateMode(oAssociate, AI_MODE_PICKUP_MAGIC_ITEMS)) sText = "  [Magic]";
    else if(ai_GetAssociateMode(oAssociate, AI_MODE_PICKUP_ITEMS)) sText = "  [All]";
    ai_UpdateToolTipUI(oPC, sAssociateType, "btn_no_loot_tooltip", sText + " Don't pickup items");
    ai_UpdateToolTipUI(oPC, sAssociateType, "btn_loot_all_tooltip", sText + " Pickup all items");
    ai_UpdateToolTipUI(oPC, sAssociateType, "btn_loot_gems_tooltip", sText + " Pickup gold, gems, and magic items");
    ai_UpdateToolTipUI(oPC, sAssociateType, "btn_loot_magic_tooltip", sText + " Pickup gold and magic items");
}
void ai_MagicIncrement(object oPC, object oAssociate, int nIncrement, string sAssociateType)
{
    int nAdjustment = GetLocalInt(oAssociate, AI_DIFFICULTY_ADJUSTMENT) + nIncrement;
    SetLocalInt(oAssociate, AI_DIFFICULTY_ADJUSTMENT, nAdjustment);
    string sMagic = IntToString(nAdjustment);
    if(nIncrement > 0)
    {
        ai_UpdateToolTipUI(oPC, sAssociateType, "btn_m_plus_tooltip", "  Magic use [" + sMagic + "] Increase");
        ai_UpdateToolTipUI(oPC, sAssociateType, "btn_m_minus_tooltip", "  Magic use [" + sMagic + "] Increase");
    }
    else
    {
        ai_UpdateToolTipUI(oPC, sAssociateType, "btn_m_plus_tooltip", "  Magic use [" + sMagic + "] Decrease");
        ai_UpdateToolTipUI(oPC, sAssociateType, "btn_m_minus_tooltip", "  Magic use [" + sMagic + "] Decrease");
    }
}
void ai_Buff_Button(object oPC, object oAssociate, int nOption, string sAssociateType)
{
    if(nOption == 0)
    {
        int bRestBuff = ai_GetAssociateMagicMode(oAssociate, AI_MAGIC_BUFF_AFTER_REST);
        ai_SetAssociateMagicMode(oAssociate, AI_MAGIC_BUFF_AFTER_REST, !bRestBuff);
        if(bRestBuff)
        {
            SendMessageToPC(oPC, GetName(oAssociate) + " will not cast long buffs after resting.");
            ai_UpdateToolTipUI(oPC, sAssociateType, "btn_buff_rest_tooltip", "  Turn buffing after resting on.");
        }
        else
        {
            SendMessageToPC(oPC, GetName(oAssociate) + " will now cast long buffs after resting.");
            ai_UpdateToolTipUI(oPC, sAssociateType, "btn_buff_rest_tooltip", "  Turn buffing after resting off.");
        }
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
            else ai_SendMessages("You cannot buff while there are enemies nearby.", COLOR_RED, oPC);
        }
        else ai_SendMessages("You cannot buff while possessing your familiar.", COLOR_RED, oPC);
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
    if(sVar == AI_HEAL_OUT_OF_COMBAT_LIMIT)
    {
        string sText = "  Increase out of combat healing below [" + sHeal + "%]";
        ai_UpdateToolTipUI(oPC, sAssociateType, "btn_heal_out_plus_tooltip", sText);
        sText = "  Decrease out of combat healing below [" + sHeal + "%]";
        ai_UpdateToolTipUI(oPC, sAssociateType, "btn_heal_out_minus_tooltip", sText);
    }
    else if(sVar == AI_HEAL_IN_COMBAT_LIMIT)
    {
        string sText = "  Increase in combat healing below [" + sHeal + "%]";
        ai_UpdateToolTipUI(oPC, sAssociateType, "btn_heal_in_plus_tooltip", sText);
        sText = "  Decrease in combat healing below [" + sHeal + "%]";
        ai_UpdateToolTipUI(oPC, sAssociateType, "btn_heal_in_minus_tooltip", sText);
    }
}
void ai_Heal_OnOff(object oPC, object oAssociate, string sAssociateType)
{
    string sText, sText2;
    if(ai_GetAssociateMode(oAssociate, AI_MODE_HEALING_OFF))
    {
        ai_SetAssociateMode(oAssociate, AI_MODE_HEALING_OFF, FALSE);
        sText = "  Healing is [On] turn off";
        sText2 = " will now use healing.";
    }
    else
    {
        ai_SetAssociateMode(oAssociate, AI_MODE_HEALING_OFF, TRUE);
        sText = "  Healing is [Off] turn on";
        sText2 = " will stop using healing.";
    }
    ai_UpdateToolTipUI(oPC, sAssociateType, "btn_heal_onoff_tooltip", sText);
    SendMessageToPC(oPC, GetName(oAssociate) + sText2);
    ai_SaveAssociateData(oPC, oAssociate);
}
void ai_Original_Guard()
{
    ResetHenchmenState();
    //Companions will only attack the Masters Last Attacker
    SetAssociateState(NW_ASC_MODE_DEFEND_MASTER);
    SetAssociateState(NW_ASC_MODE_STAND_GROUND, FALSE);
    object oLastAttacker = GetLastHostileActor(GetMaster());
    // * for some reason this is too often invalid. still the routine
    // * works corrrectly
    SetLocalInt(OBJECT_SELF, "X0_BATTLEJOINEDMASTER", TRUE);
    HenchmenCombatRound(oLastAttacker);
}
void ai_Original_Follow()
{
    ResetHenchmenState();
    SetAssociateState(NW_ASC_MODE_STAND_GROUND, FALSE);
    DelayCommand(2.5, VoiceCanDo());
    ActionForceFollowObject(GetMaster(), GetFollowDistance());
    SetAssociateState(NW_ASC_IS_BUSY);
    DelayCommand(5.0, SetAssociateState(NW_ASC_IS_BUSY, FALSE));
}
void ai_Original_StandGround()
{
    SetAssociateState(NW_ASC_MODE_STAND_GROUND);
    SetAssociateState(NW_ASC_MODE_DEFEND_MASTER, FALSE);
    DelayCommand(2.0, VoiceCanDo());
    ActionAttack(OBJECT_INVALID);
    ClearActions(CLEAR_X0_INC_HENAI_RespondToShout1);
}
void ai_Original_AttackNearest()
{
    ResetHenchmenState();
    SetAssociateState(NW_ASC_MODE_DEFEND_MASTER, FALSE);
    SetAssociateState(NW_ASC_MODE_STAND_GROUND, FALSE);
    DetermineCombatRound();
    // * bonus feature. If master is attacking a door or container, issues VWE Attack Nearest
    // * will make henchman join in on the fun
    object oTarget = GetAttackTarget(GetMaster());
    if (GetIsObjectValid(oTarget) == TRUE)
    {
        if (GetObjectType(oTarget) == OBJECT_TYPE_PLACEABLE || GetObjectType(oTarget) == OBJECT_TYPE_DOOR)
        {
            ActionAttack(oTarget);
        }
    }
}
void ai_Philos_Guard(object oCreature)
{
    ai_SetAssociateMode(oCreature, AI_MODE_SCOUT_AHEAD, FALSE);
    ai_SetAssociateMode(oCreature, AI_MODE_DEFEND_MASTER, TRUE);
    ai_SetAssociateMode(oCreature, AI_MODE_STAND_GROUND, FALSE);
    ai_SetAssociateMode(oCreature, AI_MODE_FOLLOW, FALSE);
    object oMaster = GetMaster(oCreature);
    if(!ai_GetIsBusy(oCreature) && ai_GetIsInCombat(oCreature))
    {
        object oLastAttacker = GetLastHostileActor(oMaster);
        if(oLastAttacker != OBJECT_INVALID) ai_DoAssociateCombatRound(oCreature, oLastAttacker);
        else ActionMoveToObject(oMaster, TRUE);
    }
    ai_SaveAssociateData(oMaster, oCreature);
    ai_SendMessages(GetName(oCreature) + " is now guarding you!", COLOR_GREEN, oMaster);
}
void ai_Philos_Follow(object oCreature)
{
    ai_SetAssociateMode(oCreature, AI_MODE_SCOUT_AHEAD, FALSE);
    ai_SetAssociateMode(oCreature, AI_MODE_STAND_GROUND, FALSE);
    ai_SetAssociateMode(oCreature, AI_MODE_FOLLOW, TRUE);
    // To follow we probably should be running and not searching or hiding.
    if(GetDetectMode(oCreature) && !GetHasFeat(FEAT_KEEN_SENSE, oCreature)) SetActionMode(oCreature, ACTION_MODE_DETECT, FALSE);
    if(GetStealthMode(oCreature)) SetActionMode(oCreature, ACTION_MODE_STEALTH, FALSE);
    ai_PassActionToAssociates(oCreature, ACTION_FOLLOW);
    if(ai_IsInCombatRound(oCreature)) ai_ClearCombatState(oCreature);
    else ai_ClearCreatureActions(oCreature, TRUE);
    object oMaster = GetMaster(oCreature);
    ActionMoveToObject(oMaster, TRUE, ai_GetFollowDistance(oCreature));
    ai_SaveAssociateData(oMaster, oCreature);
    ai_SendMessages(GetName(oCreature) + " is now following you!", COLOR_GREEN, oMaster);
}
void ai_Philos_StandGround(object oCreature)
{
    ai_SetAssociateMode(oCreature, AI_MODE_SCOUT_AHEAD, FALSE);
    ai_SetAssociateMode(oCreature, AI_MODE_STAND_GROUND, TRUE);
    ai_SetAssociateMode(oCreature, AI_MODE_DEFEND_MASTER, FALSE);
    ai_SetAssociateMode(oCreature, AI_MODE_FOLLOW, FALSE);
    ai_PassActionToAssociates(oCreature, ACTION_FOLLOW, FALSE);
    if(ai_IsInCombatRound(oCreature))
    {
        ai_EndCombatRound(oCreature);
        ai_ClearCombatState(oCreature);
        DeleteLocalObject(oCreature, AI_ATTACKED_PHYSICAL);
        DeleteLocalObject(oCreature, AI_ATTACKED_SPELL);
    }
    ai_ClearCreatureActions(oCreature, TRUE);
    object oMaster = GetMaster(oCreature);
    ai_SaveAssociateData(oMaster, oCreature);
    ai_SendMessages(GetName(oCreature) + " is now standing their ground!", COLOR_GREEN, oMaster);
}
void ai_Philos_AttackNearest(object oCreature)
{
    ai_SetAssociateMode(oCreature, AI_MODE_SCOUT_AHEAD, FALSE);
    ai_SetAssociateMode(oCreature, AI_MODE_DEFEND_MASTER, FALSE);
    ai_SetAssociateMode(oCreature, AI_MODE_STAND_GROUND, FALSE);
    ai_SetAssociateMode(oCreature, AI_MODE_FOLLOW, FALSE);
    ai_PassActionToAssociates(oCreature, ACTION_FOLLOW, FALSE);
    // This resets a henchmens failed Moral save in combat.
    ai_SetAssociateAIScript(oCreature);
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
        else ActionMoveToObject(oMaster, TRUE, ai_GetFollowDistance(oCreature));
    }
    ai_SaveAssociateData(oMaster, oCreature);
    ai_SendMessages(GetName(oCreature) + " is now attacking nearest enemy!", COLOR_GREEN, oMaster);
}
void ai_DoCommand(object oPC, object oAssociate, int nCommand)
{
    int nIndex = 1;
    object oCreature;
    if(nCommand == 1)
    {
        // Not using Philos Henchman AI. Use vanilla commands.
        if(ResManGetAliasFor("0e_c2_4_convers", RESTYPE_NCS) == "")
        {
            while(nIndex < 5)
            {
                oCreature = GetAssociate(ASSOCIATE_TYPE_HENCHMAN, oAssociate, nIndex);
                if(oCreature != OBJECT_INVALID) AssignCommand(oCreature, ai_Original_Guard());
                nIndex++;
            }
            while(nIndex < 6)
            {
                oCreature = GetAssociate(nIndex, oAssociate);
                if(oCreature != OBJECT_INVALID) AssignCommand(oCreature, ai_Original_Guard());
                nIndex++;
            }
        }
        // Use Philos AI commands.
        else
        {
            while(nIndex < 5)
            {
                oCreature = GetAssociate(ASSOCIATE_TYPE_HENCHMAN, oAssociate, nIndex);
                if(oCreature != OBJECT_INVALID) ai_Philos_Guard(oCreature);
                nIndex++;
            }
            while(nIndex < 6)
            {
                oCreature = GetAssociate(nIndex, oAssociate);
                if(oCreature != OBJECT_INVALID) ai_Philos_Guard(oCreature);
                nIndex++;
            }
        }
    }
    else if(nCommand == 2)
    {
        // Not using Philos Henchman AI. Use vanilla commands.
        if(ResManGetAliasFor("0e_c2_4_convers", RESTYPE_NCS) == "")
        {
            while(nIndex < 5)
            {
                oCreature = GetAssociate(ASSOCIATE_TYPE_HENCHMAN, oAssociate, nIndex);
                if(oCreature != OBJECT_INVALID) AssignCommand(oCreature, ai_Original_Follow());
                nIndex++;
            }
            while(nIndex < 6)
            {
                oCreature = GetAssociate(nIndex, oAssociate);
                if(oCreature != OBJECT_INVALID) AssignCommand(oCreature, ai_Original_Follow());
                nIndex++;
            }
        }
        // Use Philos AI commands.
        else
        {
            while(nIndex < 5)
            {
                oCreature = GetAssociate(ASSOCIATE_TYPE_HENCHMAN, oAssociate, nIndex);
                if(oCreature != OBJECT_INVALID) ai_Philos_Follow(oCreature);
                nIndex++;
            }
            while(nIndex < 6)
            {
                oCreature = GetAssociate(nIndex, oAssociate);
                if(oCreature != OBJECT_INVALID) ai_Philos_Follow(oCreature);
                nIndex++;
            }
        }
    }
    else if(nCommand == 3)
    {
        // Not using Philos Henchman AI. Use vanilla commands.
        if(ResManGetAliasFor("0e_c2_4_convers", RESTYPE_NCS) == "")
        {
            while(nIndex < 5)
            {
                oCreature = GetAssociate(ASSOCIATE_TYPE_HENCHMAN, oAssociate, nIndex);
                if(oCreature != OBJECT_INVALID) AssignCommand(oCreature, ai_Original_StandGround());
                nIndex++;
            }
            nIndex = 2;
            while(nIndex < 6)
            {
                oCreature = GetAssociate(nIndex, oAssociate);
                if(oCreature != OBJECT_INVALID) AssignCommand(oCreature, ai_Original_StandGround());
                nIndex++;
            }
        }
        // Use Philos AI commands.
        else
        {
            while(nIndex < 5)
            {
                oCreature = GetAssociate(ASSOCIATE_TYPE_HENCHMAN, oAssociate, nIndex);
                if(oCreature != OBJECT_INVALID) ai_Philos_StandGround(oCreature);
                nIndex++;
            }
            nIndex = 2;
            while(nIndex < 6)
            {
                oCreature = GetAssociate(nIndex, oAssociate);
                if(oCreature != OBJECT_INVALID) ai_Philos_StandGround(oCreature);
                nIndex++;
            }
        }
    }
    else if(nCommand == 4)
    {
        // Not using Philos Henchman AI. Use vanilla commands.
        if(ResManGetAliasFor("0e_c2_4_convers", RESTYPE_NCS) == "")
        {
            while(nIndex < 5)
            {
                oCreature = GetAssociate(ASSOCIATE_TYPE_HENCHMAN, oAssociate, nIndex);
                if(oCreature != OBJECT_INVALID) AssignCommand(oCreature, ai_Original_AttackNearest());
                nIndex++;
            }
            nIndex = 2;
            while(nIndex < 6)
            {
                oCreature = GetAssociate(nIndex, oAssociate);
                if(oCreature != OBJECT_INVALID) AssignCommand(oCreature, ai_Original_AttackNearest());
                nIndex++;
            }
        }
        // Use Philos AI commands.
        else
        {
            while(nIndex < 5)
            {
                oCreature = GetAssociate(ASSOCIATE_TYPE_HENCHMAN, oAssociate, nIndex);
                if(oCreature != OBJECT_INVALID) ai_Philos_AttackNearest(oCreature);
                nIndex++;
            }
            nIndex = 2;
            while(nIndex < 6)
            {
                oCreature = GetAssociate(nIndex, oAssociate);
                if(oCreature != OBJECT_INVALID) ai_Philos_AttackNearest(oCreature);
                nIndex++;
            }
        }
    }
}
void ai_PlugIn_Execute(object oPC, string sElem)
{
    string sIndex = GetStringRight(sElem, 1);
    string sScript = GetLocalString(oPC, "AI_PLUGIN_SCRIPT_" + sIndex);
    if(ResManGetAliasFor(sScript, RESTYPE_NCS) == "")
    {
        ai_SendMessages(sScript + " not found by ResMan!", COLOR_RED, oPC);
    }
    else
    {
        ai_SendMessages("Executing " + sScript + " script.", COLOR_GREEN, oPC);
        ExecuteScript(sScript, oPC);
    }
}
