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
#include "0i_player_target"
// Save a window ID to the database.
void ai_SaveWindowLocation(object oPC, int nToken, string sAssociateType, string sWindowID);
// Sets the Widget Buttons state to sElem Checkbox state.
void ai_SetWidgetButtonToCheckbox(object oPC, int nButton, object oAssociate, string sAssociateType, int nToken, string sElem);
// Flips an AI Buttons state to sElem Checkbox state.
void ai_SetAIButtonToCheckbox(object oPC, int nButton, object oAssociate, string sAssociateType, int nToken, string sElem);
// Flips the flag for the loot filter to sElem Checkbox state.
void ai_SetLootFilterToCheckbox(object oPC, object oAssociate, int nFilterBit, int nToken, string sElem);
// Sets an associates companion type. Cannot set companion for a player!
void ai_SetCompanionType(object oPC, object oAssociate, int nToken, int nCompanionType);
// Sets an associates companion name. Cannot set companion for a player!
void ai_SetCompanionName(object oPC, object oAssociate, int nToken, int nCompanionType);
// Sets an associates AI script via a combo box.
void ai_SetAIScript(object oPC, object oAssociate, int nToken);
// Increments/Decrements the Perception Range use variable for the AI.
void ai_PercRangeIncrement(object oPC, object oAssociate, int nIncrement, string sAssociateType, int nToken);
// Saves an associates perception range changed on the button.
void ai_Perc_Range(object oPC, object oAssociate, int nToken, string sAssociateType);
// Changes Perception Distance Rule for monsters.
void ai_RulePercDistInc(object oPC, object oModule, int nIncrement, int nToken);
// Adds a spell to a json AI restricted spell list then returns jRules.
// bRestrict = TRUE will add to the list FALSE will remove it from the list.
json ai_AddRestrictedSpell(json jRules, int nSpell, int bRestrict = TRUE);
// Turns on oAssociate AI, Setting all event scripts.
void ai_TurnOn(object oPC, object oAssociate, string sAssociateType);
// Turns off oAssociate AI, Setting all event scripts.
void ai_TurnOff(object oPC, object oAssociate, string sAssociateType);

void ai_SaveWindowLocation(object oPC, int nToken, string sAssociateType, string sWindowID)
{
    json jGeometry = NuiGetBind(oPC, nToken, "window_geometry");
    float fX = JsonGetFloat(JsonObjectGet(jGeometry, "x"));
    float fY = JsonGetFloat(JsonObjectGet(jGeometry, "y"));
    json jLocations = ai_GetAssociateDbJson(oPC, sAssociateType, "locations");
    if(JsonGetType(jLocations) == JSON_TYPE_NULL) jLocations = JsonObject();
    json jWindow = JsonObjectGet(jLocations, sWindowID);
    if(JsonGetType(jWindow) == JSON_TYPE_NULL) jWindow = JsonObject();
    jWindow = JsonObjectSet(jWindow, "x", JsonFloat(fX));
    jWindow = JsonObjectSet(jWindow, "y", JsonFloat(fY));
    jLocations = JsonObjectSet(jLocations, sWindowID, jWindow);
    //SendMessageToPC(oPC, "0e_nui, 52, sAssociateType: " + sAssociateType +
    //                     " sWindowID: " + sWindowID +
    //                     " jLocations: " + JsonDump(jLocations, 1));
    ai_SetAssociateDbJson(oPC, sAssociateType, "locations", jLocations);
}
void ai_ToggleAssociateWidgetOnOff(object oPC, int nToken, object oAssociate, string sAssociateType)
{
    string sText, sText2, sName = GetName(oAssociate);
    if(GetStringRight(sName, 1) == "s") sName = sName + "'";
    else sName = sName + "'s";
    int bWidget = !ai_GetWidgetButton(oPC, BTN_WIDGET_OFF, oAssociate, sAssociateType);
    ai_SetWidgetButton(oPC, BTN_WIDGET_OFF, oAssociate, sAssociateType, bWidget);
    NuiSetBind(oPC, nToken, "btn_widget_onoff", JsonBool (!bWidget));
    if(bWidget)
    {
        sText = "on";
        sText2 = "Off";
    IsWindowClosed(oPC, sAssociateType + AI_WIDGET_NUI);
    }
    else
    {
        sText = "off";
        sText2 = "On";
        ai_CreateWidgetNUI(oPC, oAssociate);
    }
    NuiSetBind(oPC, nToken, "btn_widget_onoff_label", JsonString("Widget " + sText2));
    NuiSetBind(oPC, nToken, "btn_widget_onoff_tooltip", JsonString("  Turn " + sName + " widget " + sText));
}
void main()
{
    object oPC = NuiGetEventPlayer();
    int nToken  = NuiGetEventWindow();
    string sEvent = NuiGetEventType();
    string sElem  = NuiGetEventElement();
    int nIndex = NuiGetEventArrayIndex();
    string sWndId = NuiGetWindowId(oPC, nToken);
    //SendMessageToPC(oPC, "0e_nui , 64 sWndId: " + sWndId + " sEvent: " + sEvent + " sElem: " + sElem +
    //              " nToken: " + IntToString(nToken) + " nIndex: " + IntToString(nIndex) +
    //             " oPC: " + GetName(oPC));
    // Get if the menu has an associate attached.
    json jData = NuiGetUserData(oPC, nToken);
    object oAssociate = StringToObject(JsonGetString(JsonArrayGet(jData, 0)));
    string sAssociateType = ai_GetAssociateType(oPC, oAssociate);
    if(!ai_GetIsCharacter(oAssociate) && !GetLocalInt(oPC, "AI_IGNORE_NO_ASSOCIATE") &&
      (oAssociate == OBJECT_INVALID || GetMaster(oAssociate) != oPC))
    {
        ai_SendMessages("This creature is no longer in your party!", AI_COLOR_RED, oPC);
        NuiDestroy(oPC, nToken);
        return;
    }
    if(sAssociateType == "") return;
    //**************************************************************************
    // Watch to see if the window moves and save.
    if(sElem == "window_geometry" && sEvent == "watch")
    {
        if(GetLocalInt(oPC, AI_NO_NUI_SAVE)) return;
        // If the widget is locked then don't save.
        if(sWndId == sAssociateType + AI_WIDGET_NUI &&
           ai_GetWidgetButton(oPC, BTN_WIDGET_LOCK, oAssociate, sAssociateType)) return;
        ai_SaveWindowLocation(oPC, nToken, sAssociateType, sWndId);
        return;
    }
    //**************************************************************************
    // Main AI events.
    if(sWndId == AI_MAIN_NUI)
    {
        //if(GetLocalInt(oPC, AI_NO_NUI_SAVE)) return;
        if(sEvent == "click")
        {
            if(sElem == "btn_plugin_manager")
            {
                NuiDestroy(oPC, nToken);
                ai_CreatePluginNUI(oPC);
            }
            if(sElem == "btn_close")
            {
                NuiDestroy(oPC, nToken);
            }
            if(sElem == "btn_action_ghost")
            {
                // We set ghost mode differently for each AI.
                if(ResManGetAliasFor("ai_a_default", RESTYPE_NCS) == "")
                {
                    if(GetLocalInt(oPC, sGhostModeVarname))
                    {
                        DeleteLocalInt(oPC, sGhostModeVarname);
                        ai_SendMessages("Action Ghost mode is turned off when using commands.", AI_COLOR_YELLOW, oPC);
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
                        ai_SendMessages("Action Ghost mode is turned on when using commands.", AI_COLOR_YELLOW, oPC);
                    }
                }
                else
                {
                    if(ai_GetAIMode(oPC, AI_MODE_ACTION_GHOST))
                    {
                        ai_SetAIMode(oPC, AI_MODE_ACTION_GHOST, FALSE);
                        ai_SendMessages("Action Ghost mode is turned off when using commands.", AI_COLOR_YELLOW, oPC);
                        object oAssociate;
                        int nIndex;
                        for(nIndex = 1; nIndex <= AI_MAX_HENCHMAN; nIndex++)
                        {
                           oAssociate = GetAssociate(ASSOCIATE_TYPE_HENCHMAN, oPC, nIndex);
                           if(oAssociate != OBJECT_INVALID && !ai_GetAIMode(oAssociate, AI_MODE_GHOST))
                           {
                                ai_RemoveASpecificEffect(oAssociate, EFFECT_TYPE_CUTSCENEGHOST);
                                DeleteLocalInt(oAssociate, sGhostModeVarname);
                           }
                        }
                        for(nIndex = 2; nIndex < 6; nIndex++)
                        {
                            oAssociate = GetAssociate(nIndex, oPC);
                            if(oAssociate != OBJECT_INVALID && !ai_GetAIMode(oAssociate, AI_MODE_GHOST))
                            {
                                ai_RemoveASpecificEffect(oAssociate, EFFECT_TYPE_CUTSCENEGHOST);
                                DeleteLocalInt(oAssociate, sGhostModeVarname);
                            }
                        }
                    }
                    else
                    {
                        ai_SetAIMode(oPC, AI_MODE_ACTION_GHOST);
                        ai_SendMessages("Action Ghost mode is turned on when using commands.", AI_COLOR_YELLOW, oPC);
                    }
                    aiSaveAssociateModesToDb(oPC, oPC);
                }
            }
            else if(sElem == "btn_toggle_assoc_widget")
            {
                int bWidgetOff = !ai_GetWidgetButton(oPC, BTN_WIDGET_OFF, oPC, "pc");
                string sAssocType;
                ai_SetWidgetButton(oPC, BTN_WIDGET_OFF, oPC, "pc", bWidgetOff);
                object oAssoc = GetAssociate(ASSOCIATE_TYPE_FAMILIAR, oPC);
                if(oAssoc != OBJECT_INVALID)
                {
                    sAssocType = ai_GetAssociateType(oPC, oAssoc);
                    ai_SetWidgetButton(oPC, BTN_WIDGET_OFF, oAssoc, sAssocType, bWidgetOff);
                    if(bWidgetOff) IsWindowClosed(oPC, sAssocType + AI_WIDGET_NUI);
                    else ai_CreateWidgetNUI(oPC, oAssoc);
                }
                oAssoc = GetAssociate(ASSOCIATE_TYPE_ANIMALCOMPANION, oPC);
                if(oAssoc != OBJECT_INVALID)
                {
                    sAssocType = ai_GetAssociateType(oPC, oAssoc);
                    ai_SetWidgetButton(oPC, BTN_WIDGET_OFF, oAssoc, sAssocType, bWidgetOff);
                    if(bWidgetOff) IsWindowClosed(oPC, sAssocType + AI_WIDGET_NUI);
                    else ai_CreateWidgetNUI(oPC, oAssoc);
                }
                oAssoc = GetAssociate(ASSOCIATE_TYPE_SUMMONED, oPC);
                if(oAssoc != OBJECT_INVALID)
                {
                    sAssocType = ai_GetAssociateType(oPC, oAssoc);
                    ai_SetWidgetButton(oPC, BTN_WIDGET_OFF, oAssoc, sAssocType, bWidgetOff);
                    if(bWidgetOff) IsWindowClosed(oPC, sAssocType + AI_WIDGET_NUI);
                    else ai_CreateWidgetNUI(oPC, oAssoc);
                }
                oAssoc = GetAssociate(ASSOCIATE_TYPE_DOMINATED, oPC);
                if(oAssoc != OBJECT_INVALID)
                {
                    sAssocType = ai_GetAssociateType(oPC, oAssoc);
                    ai_SetWidgetButton(oPC, BTN_WIDGET_OFF, oAssoc, sAssocType, bWidgetOff);
                    if(bWidgetOff) IsWindowClosed(oPC, sAssocType + AI_WIDGET_NUI);
                    else ai_CreateWidgetNUI(oPC, oAssoc);
                }
                int nIndex;
                object oHenchman;
                for(nIndex = 1; nIndex <= AI_MAX_HENCHMAN; nIndex++)
                {
                    oHenchman = GetAssociate(ASSOCIATE_TYPE_HENCHMAN, oPC, nIndex);
                    if(oHenchman != OBJECT_INVALID)
                    {
                        sAssocType = ai_GetAssociateType(oPC, oHenchman);
                        ai_SetWidgetButton(oPC, BTN_WIDGET_OFF, oHenchman, sAssocType, bWidgetOff);
                        if(bWidgetOff) IsWindowClosed(oPC, sAssocType + AI_WIDGET_NUI);
                        else ai_CreateWidgetNUI(oPC, oHenchman);
                    }
                }
            }
            if(sElem == "btn_default_xp")
            {
                int nDefaultXP = GetLocalInt(GetModule(), AI_RULE_DEFAULT_XP_SCALE);
                SetModuleXPScale(nDefaultXP);
                NuiSetBind(oPC, nToken, "txt_xp_scale", JsonString(IntToString(nDefaultXP)));
            }
        }
        if(sEvent == "watch")
        {
            string sPreElem = GetStringLeft(sElem, 4);
            if(sPreElem == "txt_")
            {
                object oModule = GetModule();
                json jRules = ai_GetCampaignDbJson("rules");
                string sText = JsonGetString(NuiGetBind(oPC, nToken, sElem));
                if(sElem == "txt_max_henchman")
                {
                    int nMaxHenchmen = StringToInt(sText);
                    if(nMaxHenchmen < 1) nMaxHenchmen = 1;
                    if(nMaxHenchmen > 12)
                    {
                        nMaxHenchmen = 12;
                        ai_SendMessages("The maximum henchmen for this mod is 12!", AI_COLOR_RED, oPC);
                    }
                    SetMaxHenchmen(nMaxHenchmen);
                    SetLocalInt(oModule, AI_RULE_MAX_HENCHMAN, nMaxHenchmen);
                    jRules = JsonObjectSet(jRules, AI_RULE_MAX_HENCHMAN, JsonInt(nMaxHenchmen));
                    ai_SendMessages("Maximum henchmen has been changed to " + IntToString(nMaxHenchmen), AI_COLOR_YELLOW, oPC);
                }
                else if(sElem == "txt_ai_difficulty")
                {
                    int nChance = StringToInt(sText);
                    if(nChance < 0) nChance = 0;
                    else if(nChance > 100) nChance = 100;
                    SetLocalInt(oModule, AI_RULE_AI_DIFFICULTY, nChance);
                    jRules = JsonObjectSet(jRules, AI_RULE_AI_DIFFICULTY, JsonInt(nChance));
                }
                else if(sElem == "txt_perception_distance")
                {
                    float fDistance = StringToFloat(sText);
                    if(fDistance < 10.0) fDistance = 10.0;
                    else if(fDistance > 60.0) fDistance = 60.0;
                    SetLocalFloat(oModule, AI_RULE_PERCEPTION_DISTANCE, fDistance);
                    jRules = JsonObjectSet(jRules, AI_RULE_PERCEPTION_DISTANCE, JsonFloat(fDistance));
                }
                else if(sElem == "txt_inc_enc")
                {
                    float fNumber = StringToFloat(sText);
                    if(fNumber < 0.0) fNumber = 0.0;
                    else if(fNumber > 9.0) fNumber = 9.0;
                    SetLocalFloat(oModule, AI_INCREASE_ENC_MONSTERS, fNumber);
                    jRules = JsonObjectSet(jRules, AI_INCREASE_ENC_MONSTERS, JsonFloat(fNumber));
                }
                else if(sElem == "txt_inc_hp")
                {
                    int nNumber = StringToInt(sText);
                    if(nNumber < 0) nNumber = 0;
                    else if(nNumber > 100) nNumber = 100;
                    SetLocalInt(oModule, AI_INCREASE_MONSTERS_HP, nNumber);
                    jRules = JsonObjectSet(jRules, AI_INCREASE_MONSTERS_HP, JsonInt(nNumber));
                }
                else if(sElem == "txt_wander_distance")
                {
                    float fDistance = StringToFloat(sText);
                    if(fDistance < 0.0) fDistance = 0.0;
                    else if(fDistance > 99.0) fDistance = 99.0;
                    SetLocalFloat(oModule, AI_RULE_WANDER_DISTANCE, fDistance);
                    jRules = JsonObjectSet(jRules, AI_RULE_WANDER_DISTANCE, JsonFloat(fDistance));
                }
                else if(sElem == "txt_xp_scale")
                {
                    int nNumber = StringToInt(sText);
                    if(nNumber < 0) nNumber = 0;
                    else if(nNumber > 200) nNumber = 200;
                    SetModuleXPScale(nNumber);
                    return;
                }
                ai_SetCampaignDbJson("rules", jRules);
            }
            else if(sPreElem == "chbx")
            {
                object oModule = GetModule();
                int bCheck = JsonGetInt(NuiGetBind(oPC, nToken, sElem));
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
                    jRules = JsonObjectSet(jRules, AI_RULE_WANDER, JsonInt(bCheck));
                    NuiSetBind(oPC, nToken, "txt_wander_distance_event", JsonBool(bCheck));
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
                        ai_CheckXPPartyScale(oPC);
                    }
                    else
                    {
                        SetModuleXPScale(GetLocalInt(oModule, AI_RULE_DEFAULT_XP_SCALE));
                    }
                    SetLocalInt(oModule, AI_RULE_PARTY_SCALE, bCheck);
                    jRules = JsonObjectSet(jRules, AI_RULE_PARTY_SCALE, JsonInt(bCheck));
                    string sText = IntToString(GetLocalInt(oModule, AI_BASE_PARTY_SCALE_XP));
                    NuiSetBind(oPC, nToken, "chbx_party_scale_tooltip", JsonString("  PEPS adjusts your XP based on party size from (" + sText + ")."));
                    sText = IntToString(GetModuleXPScale());
                    NuiSetBind(oPC, nToken, "txt_xp_scale", JsonString(sText));
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
        return;
    }
    //**************************************************************************
    // Associate Command events.
    if(sWndId == sAssociateType + AI_COMMAND_NUI)
    {
        if(sEvent == "click")
        {
            if(sElem == "btn_ai_menu")
            {
                NuiDestroy(oPC, nToken);
                ai_CreateAssociateAINUI(oPC, oAssociate);
            }
            else if(sElem == "btn_main_menu")
            {
                if(ai_GetIsCharacter(oAssociate)) ai_CreateAIMainNUI(oPC);
            }
            else if(sElem == "btn_widget_onoff")
            {
                ai_ToggleAssociateWidgetOnOff(oPC, nToken, oAssociate, sAssociateType);
            }
            else if(sElem == "btn_widget_lock")
            {
                int bLocked = !ai_GetWidgetButton(oPC, BTN_WIDGET_LOCK, oAssociate, sAssociateType);
                ai_SetWidgetButton(oPC, BTN_WIDGET_LOCK, oAssociate, sAssociateType, bLocked);
                if(!ai_GetWidgetButton(oPC, BTN_WIDGET_OFF, oAssociate, sAssociateType))
                {
                    NuiDestroy(oPC, NuiFindWindow(oPC, sAssociateType + AI_WIDGET_NUI));
                    ai_CreateWidgetNUI(oPC, oAssociate);
                }
            }
            if(sElem == "btn_vertical_widget")
            {
                int bVertical = !ai_GetWidgetButton(oPC, BTN_WIDGET_VERTICAL, oAssociate, sAssociateType);
                ai_SetWidgetButton(oPC, BTN_WIDGET_VERTICAL, oAssociate, sAssociateType, bVertical);
                if(!ai_GetWidgetButton(oPC, BTN_WIDGET_OFF, oAssociate, sAssociateType))
                {
                    NuiDestroy(oPC, NuiFindWindow(oPC, sAssociateType + AI_WIDGET_NUI));
                    ai_CreateWidgetNUI(oPC, oAssociate);
                }
            }
            else if(sElem == "btn_copy_settings")
            {
                ai_CreateCopySettingsNUI(oPC, oAssociate);
            }
            else if(sElem == "btn_cmd_action") ai_Action(oPC, oAssociate);
            else if(sElem == "btn_cmd_guard") ai_DoCommand(oPC, oAssociate, 1);
            else if(sElem == "btn_cmd_hold") ai_DoCommand(oPC, oAssociate, 3);
            else if(sElem == "btn_cmd_search") ai_DoCommand(oPC, oAssociate, 5);
            else if(sElem == "btn_cmd_stealth") ai_DoCommand(oPC, oAssociate, 6);
            else if(sElem == "btn_cmd_attack") ai_DoCommand(oPC, oAssociate, 4);
            else if(sElem == "btn_cmd_follow") ai_DoCommand(oPC, oAssociate, 2);
            else if(sElem == "btn_follow_up") ai_FollowIncrement(oPC, oAssociate, 1.0, sAssociateType, nToken);
            else if(sElem == "btn_follow_down") ai_FollowIncrement(oPC, oAssociate, -1.0, sAssociateType, nToken);
            else if(sElem == "btn_follow_target") ai_FollowTarget(oPC, oAssociate);
            else if(sElem == "btn_cmd_ai_script") ai_AIScript(oPC, oAssociate, sAssociateType, nToken);
            else if(sElem == "btn_cmd_place_trap") ai_HavePCPlaceTrap(oPC, oAssociate);
            else if(sElem == "btn_quick_widget")
            {
                NuiDestroy(oPC, nToken);
                ai_CreateQuickWidgetSelectionNUI(oPC, oAssociate);
            }
            else if(sElem == "btn_spell_memorize")
            {
                NuiDestroy(oPC, nToken);
                ai_CreateSpellMemorizationNUI(oPC, oAssociate);
            }
            else if(sElem == "btn_buff_short")
            {
                ai_Buff_Button(oPC, oAssociate, 2, sAssociateType);
                DelayCommand(6.0, ai_UpdateAssociateWidget(oPC, oAssociate));
            }
            else if(sElem == "btn_buff_long")
            {
                ai_Buff_Button(oPC, oAssociate, 3, sAssociateType);
                DelayCommand(6.0, ai_UpdateAssociateWidget(oPC, oAssociate));
            }
            else if(sElem == "btn_buff_all")
            {
                ai_Buff_Button(oPC, oAssociate, 1, sAssociateType);
                DelayCommand(6.0, ai_UpdateAssociateWidget(oPC, oAssociate));
            }
            else if(sElem == "btn_buff_rest") ai_Buff_Button(oPC, oAssociate, 0, sAssociateType);
            else if(sElem == "btn_jump_to") ai_JumpToPC(oPC, oAssociate);
            else if(sElem == "btn_ghost_mode") ai_GhostMode(oPC, oAssociate, nToken, sAssociateType);
            else if(sElem == "btn_camera") ai_ChangeCameraView(oPC, oAssociate);
            else if(sElem == "btn_inventory") ai_OpenInventory(oAssociate, oPC);
            else if(sElem == "btn_familiar_name") ai_SetCompanionName(oPC, oAssociate, nToken, ASSOCIATE_TYPE_FAMILIAR);
            else if(sElem == "btn_companion_name") ai_SetCompanionName(oPC, oAssociate, nToken, ASSOCIATE_TYPE_ANIMALCOMPANION);
            else if(GetStringLeft(sElem, 11) == "btn_plugin_") ai_Plugin_Execute(oPC, sElem);
        }
        else if(sEvent == "watch")
        {
            if(sElem == "txt_familiar_name")
            {
                string sName = JsonGetString(NuiGetBind(oPC, nToken, sElem));
                if(sName != "") NuiSetBind(oPC, nToken, "btn_familiar_name_event", JsonBool(TRUE));
                else NuiSetBind(oPC, nToken, "btn_familiar_name_event", JsonBool(FALSE));
            }
            if(GetStringLeft(sElem, 12) == "chbx_plugin_" && GetStringRight(sElem, 6) == "_check")
            {
                int nIndex = StringToInt(GetSubString(sElem, 12, 1));
                json jPlugins = ai_GetAssociateDbJson(oPC, "pc", "plugins");
                json jPlugin = JsonArrayGet(jPlugins, nIndex);
                int bCheck = JsonGetInt(NuiGetBind(oPC, nToken, sElem));
                jPlugin = JsonArraySet(jPlugin, 1, JsonBool(bCheck));
                jPlugins = JsonArraySet(jPlugins, nIndex, jPlugin);
                ai_SetAssociateDbJson(oPC, "pc", "plugins", jPlugins);
                NuiDestroy(oPC, NuiFindWindow(oPC, "pc" + AI_WIDGET_NUI));
                ai_CreateWidgetNUI(oPC, oPC);
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
            else if(sElem == "chbx_quick_widget_check") ai_SetWidgetButtonToCheckbox(oPC, BTN_CMD_SPELL_WIDGET, oAssociate, sAssociateType, nToken, sElem);
            else if(sElem == "chbx_follow_target_check") ai_SetAIButtonToCheckbox(oPC, BTN_AI_FOLLOW_TARGET, oAssociate, sAssociateType, nToken, sElem);
            else if(sElem == "chbx_buff_short_check") ai_SetWidgetButtonToCheckbox(oPC, BTN_BUFF_SHORT, oAssociate, sAssociateType, nToken, sElem);
            else if(sElem == "chbx_buff_long_check") ai_SetWidgetButtonToCheckbox(oPC, BTN_BUFF_LONG, oAssociate, sAssociateType, nToken, sElem);
            else if(sElem == "chbx_buff_all_check") ai_SetWidgetButtonToCheckbox(oPC, BTN_BUFF_ALL, oAssociate, sAssociateType, nToken, sElem);
            else if(sElem == "chbx_jump_to_check") ai_SetWidgetButtonToCheckbox(oPC, BTN_CMD_JUMP_TO, oAssociate, sAssociateType, nToken, sElem);
            else if(sElem == "chbx_ghost_mode_check") ai_SetWidgetButtonToCheckbox(oPC, BTN_CMD_GHOST_MODE, oAssociate, sAssociateType, nToken, sElem);
            else if(sElem == "chbx_camera_check") ai_SetWidgetButtonToCheckbox(oPC, BTN_CMD_CAMERA, oAssociate, sAssociateType, nToken, sElem);
            else if(sElem == "chbx_inventory_check") ai_SetWidgetButtonToCheckbox(oPC, BTN_CMD_INVENTORY, oAssociate, sAssociateType, nToken, sElem);
            else if(sElem == "chbx_familiar_check") ai_SetWidgetButtonToCheckbox(oPC, BTN_CMD_FAMILIAR, oAssociate, sAssociateType, nToken, sElem);
            else if(sElem == "chbx_companion_check") ai_SetWidgetButtonToCheckbox(oPC, BTN_CMD_COMPANION, oAssociate, sAssociateType, nToken, sElem);
            else if(sElem == "cmb_familiar_selected") ai_SetCompanionType(oPC, oAssociate, nToken, ASSOCIATE_TYPE_FAMILIAR);
            else if(sElem == "cmb_companion_selected") ai_SetCompanionType(oPC, oAssociate, nToken, ASSOCIATE_TYPE_ANIMALCOMPANION);
            NuiDestroy(oPC, NuiFindWindow(oPC, sAssociateType + AI_WIDGET_NUI));
            ai_CreateWidgetNUI(oPC, oAssociate);
        }
        else if(sEvent == "mousescroll")
        {
            float nMouseScroll = JsonGetFloat(JsonObjectGet(JsonObjectGet(NuiGetEventPayload(), "mouse_scroll"), "y"));
            if(nMouseScroll == 1.0) // Scroll up
            {
                // Follow range is only changed on non-pc's
                if(sElem == "btn_cmd_follow" &&
                   oPC != oAssociate) ai_FollowIncrement(oPC, oAssociate, 1.0, sAssociateType, nToken);
                else if(sElem == "btn_follow_target") ai_FollowIncrement(oPC, oAssociate, 1.0, sAssociateType, nToken);
            }
            else if(nMouseScroll == -1.0) // Scroll down
            {
                // Follow range is only changed on non-pc's
                if(sElem == "btn_cmd_follow" &&
                oPC != oAssociate) ai_FollowIncrement(oPC, oAssociate, -1.0, sAssociateType, nToken);
                else if(sElem == "btn_follow_target") ai_FollowIncrement(oPC, oAssociate, -1.0, sAssociateType, nToken);
            }
        }
        return;
    }
    //**************************************************************************
    // Associate AI events.
    if(sWndId == sAssociateType + AI_NUI)
    {
        if(sEvent == "click")
        {
            if(sElem == "btn_command_menu")
            {
                ai_CreateAssociateCommandNUI(oPC, oAssociate);
                NuiDestroy(oPC, nToken);
            }
            else if(sElem == "btn_main_menu")
            {
                if(ai_GetIsCharacter(oAssociate)) ai_CreateAIMainNUI(oPC);
            }
            else if(sElem == "btn_loot_filter")
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
            else if(sElem == "btn_ignore_assoc") ai_Ignore_Associates(oPC, oAssociate, sAssociateType);
            else if(sElem == "btn_search") ai_Search(oPC, oAssociate, sAssociateType);
            else if(sElem == "btn_stealth") ai_Stealth(oPC, oAssociate, sAssociateType);
            else if(sElem == "btn_open_door") ai_OpenDoor(oPC, oAssociate, sAssociateType, nToken);
            else if(sElem == "btn_traps") ai_Traps(oPC, oAssociate, sAssociateType, nToken);
            else if(sElem == "btn_pick_locks") ai_Locks(oPC, oAssociate, sAssociateType, 1, nToken);
            else if(sElem == "btn_bash_locks") ai_Locks(oPC, oAssociate, sAssociateType, 2, nToken);
            else if(sElem == "btn_magic") ai_UseMagic(oPC, oAssociate, sAssociateType);
            else if(sElem == "btn_magic_items") ai_UseMagicItems(oPC, oAssociate, sAssociateType);
            else if(sElem == "btn_def_magic") ai_UseOffensiveMagic(oPC, oAssociate, TRUE, FALSE, sAssociateType);
            else if(sElem == "btn_off_magic") ai_UseOffensiveMagic(oPC, oAssociate, FALSE, TRUE, sAssociateType);
            else if(sElem == "btn_spontaneous") ai_Spontaneous(oPC, oAssociate, sAssociateType);
            else if(sElem == "btn_heals_onoff") ai_Heal_OnOff(oPC, oAssociate, sAssociateType, 1);
            else if(sElem == "btn_healp_onoff") ai_Heal_OnOff(oPC, oAssociate, sAssociateType, 2);
            else if(sElem == "btn_loot") ai_Loot(oPC, oAssociate, sAssociateType, nToken);
            else if(sElem == "btn_perc_range") ai_Perc_Range(oPC, oAssociate, nToken, sAssociateType);
            else if(sElem == "btn_ai_script") ai_SaveAIScript(oPC, oAssociate, nToken);
            // ** Mobile up/down adjustments.
            else if(sElem == "btn_magic_up") ai_MagicIncrement(oPC, oAssociate, 1, sAssociateType, nToken);
            else if(sElem == "btn_door_up") ai_OpenDoorIncrement(oPC, oAssociate, 1.0, sAssociateType, nToken);
            else if(sElem == "btn_traps_up") ai_TrapRangeIncrement(oPC, oAssociate, 1.0, sAssociateType, nToken);
            else if(sElem == "btn_pick_up") ai_LockRangeIncrement(oPC, oAssociate, 1.0, sAssociateType, nToken);
            else if(sElem == "btn_bash_up") ai_LockRangeIncrement(oPC, oAssociate, 1.0, sAssociateType, nToken);
            else if(sElem == "btn_heal_out_up") ai_Heal_Button(oPC, oAssociate, 5, AI_HEAL_OUT_OF_COMBAT_LIMIT, sAssociateType, nToken);
            else if(sElem == "btn_heal_in_up") ai_Heal_Button(oPC, oAssociate, 5, AI_HEAL_IN_COMBAT_LIMIT, sAssociateType, nToken);
            else if(sElem == "btn_loot_up") ai_LootRangeIncrement(oPC, oAssociate, 1.0, sAssociateType, nToken);
            else if(sElem == "btn_magic_down") ai_MagicIncrement(oPC, oAssociate, -1, sAssociateType, nToken);
            else if(sElem == "btn_door_down") ai_OpenDoorIncrement(oPC, oAssociate, -1.0, sAssociateType, nToken);
            else if(sElem == "btn_traps_down") ai_TrapRangeIncrement(oPC, oAssociate, -1.0, sAssociateType, nToken);
            else if(sElem == "btn_pick_down") ai_LockRangeIncrement(oPC, oAssociate, -1.0, sAssociateType, nToken);
            else if(sElem == "btn_bash_down") ai_LockRangeIncrement(oPC, oAssociate, -1.0, sAssociateType, nToken);
            else if(sElem == "btn_heal_out_down") ai_Heal_Button(oPC, oAssociate, -5, AI_HEAL_OUT_OF_COMBAT_LIMIT, sAssociateType, nToken);
            else if(sElem == "btn_heal_in_down") ai_Heal_Button(oPC, oAssociate, -5, AI_HEAL_IN_COMBAT_LIMIT, sAssociateType, nToken);
            else if(sElem == "btn_loot_down") ai_LootRangeIncrement(oPC, oAssociate, -1.0, sAssociateType, nToken);
        }
        else if(sEvent == "watch")
        {
            SetLocalInt (oPC, AI_NO_NUI_SAVE, TRUE);
            if(sElem == "chbx_ai_check") ai_SetAIButtonToCheckbox(oPC, BTN_AI_FOR_PC, oAssociate, sAssociateType, nToken, sElem);
            else if(sElem == "chbx_quiet_check") ai_SetAIButtonToCheckbox(oPC, BTN_AI_REDUCE_SPEECH, oAssociate, sAssociateType, nToken, sElem);
            else if(sElem == "chbx_ranged_check") ai_SetAIButtonToCheckbox(oPC, BTN_AI_USE_RANGED, oAssociate, sAssociateType, nToken, sElem);
            else if(sElem == "chbx_ignore_assoc_check") ai_SetAIButtonToCheckbox(oPC, BTN_AI_IGNORE_ASSOCIATES, oAssociate, sAssociateType, nToken, sElem);
            else if(sElem == "chbx_search_check") ai_SetAIButtonToCheckbox(oPC, BTN_AI_USE_SEARCH, oAssociate, sAssociateType, nToken, sElem);
            else if(sElem == "chbx_stealth_check") ai_SetAIButtonToCheckbox(oPC, BTN_AI_USE_STEALTH, oAssociate, sAssociateType, nToken, sElem);
            else if(sElem == "chbx_open_door_check") ai_SetAIButtonToCheckbox(oPC, BTN_AI_OPEN_DOORS, oAssociate, sAssociateType, nToken, sElem);
            else if(sElem == "chbx_traps_check") ai_SetAIButtonToCheckbox(oPC, BTN_AI_REMOVE_TRAPS, oAssociate, sAssociateType, nToken, sElem);
            else if(sElem == "chbx_pick_locks_check") ai_SetAIButtonToCheckbox(oPC, BTN_AI_PICK_LOCKS, oAssociate, sAssociateType, nToken, sElem);
            else if(sElem == "chbx_bash_locks_check") ai_SetAIButtonToCheckbox(oPC, BTN_AI_BASH_LOCKS, oAssociate, sAssociateType, nToken, sElem);
            else if(sElem == "chbx_magic_level_check") ai_SetAIButtonToCheckbox(oPC, BTN_AI_MAGIC_LEVEL, oAssociate, sAssociateType, nToken, sElem);
            else if(sElem == "chbx_spontaneous_check") ai_SetAIButtonToCheckbox(oPC, BTN_AI_NO_SPONTANEOUS, oAssociate, sAssociateType, nToken, sElem);
            else if(sElem == "chbx_magic_check") ai_SetAIButtonToCheckbox(oPC, BTN_AI_NO_MAGIC_USE, oAssociate, sAssociateType, nToken, sElem);
            else if(sElem == "chbx_magic_items_check") ai_SetAIButtonToCheckbox(oPC, BTN_AI_NO_MAGIC_ITEM_USE, oAssociate, sAssociateType, nToken, sElem);
            else if(sElem == "chbx_def_magic_check") ai_SetAIButtonToCheckbox(oPC, BTN_AI_DEF_MAGIC_USE, oAssociate, sAssociateType, nToken, sElem);
            else if(sElem == "chbx_off_magic_check") ai_SetAIButtonToCheckbox(oPC, BTN_AI_OFF_MAGIC_USE, oAssociate, sAssociateType, nToken, sElem);
            else if(sElem == "chbx_heal_out_check") ai_SetAIButtonToCheckbox(oPC, BTN_AI_HEAL_OUT, oAssociate, sAssociateType, nToken, sElem);
            else if(sElem == "chbx_heal_in_check") ai_SetAIButtonToCheckbox(oPC, BTN_AI_HEAL_IN, oAssociate, sAssociateType, nToken, sElem);
            else if(sElem == "chbx_heals_onoff_check") ai_SetAIButtonToCheckbox(oPC, BTN_AI_STOP_SELF_HEALING, oAssociate, sAssociateType, nToken, sElem);
            else if(sElem == "chbx_healp_onoff_check") ai_SetAIButtonToCheckbox(oPC, BTN_AI_STOP_PARTY_HEALING, oAssociate, sAssociateType, nToken, sElem);
            else if(sElem == "chbx_loot_check") ai_SetAIButtonToCheckbox(oPC, BTN_AI_LOOT, oAssociate, sAssociateType, nToken, sElem);
            else if(sElem == "chbx_perc_range_check") ai_SetAIButtonToCheckbox(oPC, BTN_AI_PERC_RANGE, oAssociate, sAssociateType, nToken, sElem);
            else if(sElem == "cmb_ai_script_selected") ai_SetAIScript(oPC, oAssociate, nToken);
            NuiDestroy(oPC, NuiFindWindow(oPC, sAssociateType + AI_WIDGET_NUI));
            ai_CreateWidgetNUI(oPC, oAssociate);
        }
        else if(sEvent == "mousescroll")
        {
            float nMouseScroll = JsonGetFloat(JsonObjectGet(JsonObjectGet(NuiGetEventPayload(), "mouse_scroll"), "y"));
            if(nMouseScroll == 1.0) // Scroll up
            {
                if(sElem == "btn_magic_level") ai_MagicIncrement(oPC, oAssociate, 1, sAssociateType, nToken);
                else if(sElem == "btn_open_door") ai_OpenDoorIncrement(oPC, oAssociate, 1.0, sAssociateType, nToken);
                else if(sElem == "btn_traps") ai_TrapRangeIncrement(oPC, oAssociate, 1.0, sAssociateType, nToken);
                else if(sElem == "btn_pick_locks") ai_LockRangeIncrement(oPC, oAssociate, 1.0, sAssociateType, nToken);
                else if(sElem == "btn_bash_locks") ai_LockRangeIncrement(oPC, oAssociate, 1.0, sAssociateType, nToken);
                else if(sElem == "btn_heal_out") ai_Heal_Button(oPC, oAssociate, 5, AI_HEAL_OUT_OF_COMBAT_LIMIT, sAssociateType, nToken);
                else if(sElem == "btn_heal_in") ai_Heal_Button(oPC, oAssociate, 5, AI_HEAL_IN_COMBAT_LIMIT, sAssociateType, nToken);
                else if(sElem == "btn_loot") ai_LootRangeIncrement(oPC, oAssociate, 1.0, sAssociateType, nToken);
            }
            else if(nMouseScroll == -1.0) // Scroll down
            {
                if(sElem == "btn_magic_level") ai_MagicIncrement(oPC, oAssociate, -1, sAssociateType, nToken);
                else if(sElem == "btn_open_door") ai_OpenDoorIncrement(oPC, oAssociate, -1.0, sAssociateType, nToken);
                else if(sElem == "btn_traps") ai_TrapRangeIncrement(oPC, oAssociate, -1.0, sAssociateType, nToken);
                else if(sElem == "btn_pick_locks") ai_LockRangeIncrement(oPC, oAssociate, -1.0, sAssociateType, nToken);
                else if(sElem == "btn_bash_locks") ai_LockRangeIncrement(oPC, oAssociate, -1.0, sAssociateType, nToken);
                else if(sElem == "btn_heal_out") ai_Heal_Button(oPC, oAssociate, -5, AI_HEAL_OUT_OF_COMBAT_LIMIT, sAssociateType, nToken);
                else if(sElem == "btn_heal_in") ai_Heal_Button(oPC, oAssociate, -5, AI_HEAL_IN_COMBAT_LIMIT, sAssociateType, nToken);
                else if(sElem == "btn_loot") ai_LootRangeIncrement(oPC, oAssociate, -1.0, sAssociateType, nToken);
            }
        }
        return;
    }
    //**************************************************************************
    // Associate Widget events.
    if(sWndId == sAssociateType + AI_WIDGET_NUI)
    {
        if(sEvent == "click")
        {
            if(sElem == "btn_open_main")
            {
                if(IsWindowClosed(oPC, sAssociateType + AI_COMMAND_NUI)) ai_CreateAssociateCommandNUI(oPC, oAssociate);
                IsWindowClosed(oPC, sAssociateType + AI_NUI);
                IsWindowClosed(oPC, sAssociateType + AI_LOOTFILTER_NUI);
                IsWindowClosed(oPC, sAssociateType + AI_COPY_NUI);
                IsWindowClosed(oPC, sAssociateType + AI_QUICK_WIDGET_NUI);
                IsWindowClosed(oPC, sAssociateType + AI_SPELL_MEMORIZE_NUI);
                if(ai_GetIsCharacter(oAssociate))
                {
                    IsWindowClosed(oPC, AI_MAIN_NUI);
                    IsWindowClosed(oPC, AI_PLUGIN_NUI);
                }
            }
            else
            {
                if(sElem == "btn_ai")
                {
                    if(GetEventScript(oAssociate, EVENT_SCRIPT_CREATURE_ON_HEARTBEAT) == "xx_pc_1_hb")
                    {
                        ai_TurnOff(oPC, oAssociate, sAssociateType);
                    }
                    else ai_TurnOn(oPC, oAssociate, sAssociateType);
                }
                else if(sElem == "btn_quiet") ai_ReduceSpeech(oPC, oAssociate, sAssociateType);
                else if(sElem == "btn_ranged") AssignCommand(oAssociate, ai_Ranged(oPC, oAssociate, sAssociateType));
                else if(sElem == "btn_ignore_assoc") ai_Ignore_Associates(oPC, oAssociate, sAssociateType);
                else if(sElem == "btn_search") ai_Search(oPC, oAssociate, sAssociateType);
                else if(sElem == "btn_stealth") ai_Stealth(oPC, oAssociate, sAssociateType);
                else if(sElem == "btn_open_door") ai_OpenDoor(oPC, oAssociate, sAssociateType, nToken);
                else if(sElem == "btn_traps") ai_Traps(oPC, oAssociate, sAssociateType, nToken);
                else if(sElem == "btn_pick_locks") ai_Locks(oPC, oAssociate, sAssociateType, 1, nToken);
                else if(sElem == "btn_bash_locks") ai_Locks(oPC, oAssociate, sAssociateType, 2, nToken);
                else if(sElem == "btn_magic_minus") ai_MagicIncrement(oPC, oAssociate, -1, sAssociateType, nToken);
                else if(sElem == "btn_magic_plus") ai_MagicIncrement(oPC, oAssociate, 1, sAssociateType, nToken);
                else if(sElem == "btn_magic") ai_UseMagic(oPC, oAssociate, sAssociateType);
                else if(sElem == "btn_magic_items") ai_UseMagicItems(oPC, oAssociate, sAssociateType);
                else if(sElem == "btn_def_magic") ai_UseOffensiveMagic(oPC, oAssociate, TRUE, FALSE, sAssociateType);
                else if(sElem == "btn_off_magic") ai_UseOffensiveMagic(oPC, oAssociate, FALSE, TRUE, sAssociateType);
                else if(sElem == "btn_loot") ai_Loot(oPC, oAssociate, sAssociateType, nToken);
                else if(sElem == "btn_perc_range") ai_Perc_Range(oPC, oAssociate, nToken, sAssociateType);
                else if(sElem == "btn_spontaneous") ai_Spontaneous(oPC, oAssociate, sAssociateType);
                else if(sElem == "btn_buff_short")
                {
                    ai_Buff_Button(oPC, oAssociate, 2, sAssociateType);
                    DelayCommand(6.0, ai_UpdateAssociateWidget(oPC, oAssociate));
                }
                else if(sElem == "btn_buff_long")
                {
                    ai_Buff_Button(oPC, oAssociate, 3, sAssociateType);
                    DelayCommand(6.0, ai_UpdateAssociateWidget(oPC, oAssociate));
                }
                else if(sElem == "btn_buff_all")
                {
                    ai_Buff_Button(oPC, oAssociate, 1, sAssociateType);
                    DelayCommand(6.0, ai_UpdateAssociateWidget(oPC, oAssociate));
                }
                else if(sElem == "btn_buff_rest") ai_Buff_Button(oPC, oAssociate, 0, sAssociateType);
                else if(sElem == "btn_jump_to") ai_JumpToPC(oPC, oAssociate);
                else if(sElem == "btn_ghost_mode") ai_GhostMode(oPC, oAssociate, nToken, sAssociateType);
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
                else if(sElem == "btn_heals_onoff") ai_Heal_OnOff(oPC, oAssociate, sAssociateType, 1);
                else if(sElem == "btn_healp_onoff") ai_Heal_OnOff(oPC, oAssociate, sAssociateType, 2);
                else if(sElem == "btn_cmd_action") ai_Action(oPC, oAssociate);
                else if(sElem == "btn_cmd_guard") ai_DoCommand(oPC, oAssociate, 1);
                else if(sElem == "btn_cmd_hold") ai_DoCommand(oPC, oAssociate, 3);
                else if(sElem == "btn_cmd_search") ai_DoCommand(oPC, oAssociate, 5);
                else if(sElem == "btn_cmd_stealth") ai_DoCommand(oPC, oAssociate, 6);
                else if(sElem == "btn_cmd_attack") ai_DoCommand(oPC, oAssociate, 4);
                else if(sElem == "btn_cmd_follow") ai_DoCommand(oPC, oAssociate, 2);
                else if(sElem == "btn_cmd_ai_script") ai_AIScript(oPC, oAssociate, sAssociateType, nToken);
                else if(sElem == "btn_cmd_place_trap") ai_HavePCPlaceTrap(oPC, oAssociate);
                else if(sElem == "btn_follow_target") ai_FollowTarget(oPC, oAssociate);
                else if(sElem == "btn_update_widget") ai_UpdateAssociateWidget(oPC, oAssociate);
                else if(GetStringLeft(sElem, 15) == "btn_exe_plugin_") ai_Plugin_Execute(oPC, sElem);
                else if(GetStringLeft(sElem, 11) == "btn_widget_") ai_SelectWidgetSpellTarget(oPC, oAssociate, sElem);
            }
        }
        if(sEvent == "mousescroll")
        {
            float nMouseScroll = JsonGetFloat(JsonObjectGet(JsonObjectGet(NuiGetEventPayload(), "mouse_scroll"), "y"));
            if(nMouseScroll == 1.0) // Scroll up
            {
                if(sElem == "btn_cmd_follow" &&
                   oPC != oAssociate) ai_FollowIncrement(oPC, oAssociate, 1.0, sAssociateType, nToken);
                else if(sElem == "btn_follow_target") ai_FollowIncrement(oPC, oAssociate, 1.0, sAssociateType, nToken);
                else if(sElem == "btn_magic_level") ai_MagicIncrement(oPC, oAssociate, 1, sAssociateType, nToken);
                else if(sElem == "btn_pick_locks") ai_LockRangeIncrement(oPC, oAssociate, 1.0, sAssociateType, nToken);
                else if(sElem == "btn_bash_locks") ai_LockRangeIncrement(oPC, oAssociate, 1.0, sAssociateType, nToken);
                else if(sElem == "btn_traps") ai_TrapRangeIncrement(oPC, oAssociate, 1.0, sAssociateType, nToken);
                else if(sElem == "btn_open_door") ai_OpenDoorIncrement(oPC, oAssociate, 1.0, sAssociateType, nToken);
                else if(sElem == "btn_heal_out") ai_Heal_Button(oPC, oAssociate, 5, AI_HEAL_OUT_OF_COMBAT_LIMIT, sAssociateType, nToken);
                else if(sElem == "btn_heal_in") ai_Heal_Button(oPC, oAssociate, 5, AI_HEAL_IN_COMBAT_LIMIT, sAssociateType, nToken);
                else if(sElem == "btn_loot") ai_LootRangeIncrement(oPC, oAssociate, 1.0, sAssociateType, nToken);
            }
            if(nMouseScroll == -1.0) // Scroll down
            {
                if(sElem == "btn_cmd_follow" &&
                   oPC != oAssociate) ai_FollowIncrement(oPC, oAssociate, -1.0, sAssociateType, nToken);
                else if(sElem == "btn_follow_target") ai_FollowIncrement(oPC, oAssociate, -1.0, sAssociateType, nToken);
                else if(sElem == "btn_magic_plus") ai_MagicIncrement(oPC, oAssociate, -1, sAssociateType, nToken);
                if(sElem == "btn_magic_level") ai_MagicIncrement(oPC, oAssociate, -1, sAssociateType, nToken);
                else if(sElem == "btn_pick_locks") ai_LockRangeIncrement(oPC, oAssociate, -1.0, sAssociateType, nToken);
                else if(sElem == "btn_bash_locks") ai_LockRangeIncrement(oPC, oAssociate, -1.0, sAssociateType, nToken);
                else if(sElem == "btn_traps") ai_TrapRangeIncrement(oPC, oAssociate, -1.0, sAssociateType, nToken);
                else if(sElem == "btn_open_door") ai_OpenDoorIncrement(oPC, oAssociate, -1.0, sAssociateType, nToken);
                else if(sElem == "btn_heal_out") ai_Heal_Button(oPC, oAssociate, -5, AI_HEAL_OUT_OF_COMBAT_LIMIT, sAssociateType, nToken);
                else if(sElem == "btn_heal_in") ai_Heal_Button(oPC, oAssociate, -5, AI_HEAL_IN_COMBAT_LIMIT, sAssociateType, nToken);
                else if(sElem == "btn_loot") ai_LootRangeIncrement(oPC, oAssociate, -1.0, sAssociateType, nToken);
            }
        }
        if(sEvent == "mousedown")
        {
            int nMouseButton = JsonGetInt(JsonObjectGet(NuiGetEventPayload(), "mouse_btn"));
            if(nMouseButton == NUI_MOUSE_BUTTON_RIGHT)
            {
                AssignCommand(oPC, PlaySound("gui_button"));
                if(sElem == "btn_open_main")
                {
                    if(IsWindowClosed(oPC, sAssociateType + AI_NUI)) ai_CreateAssociateAINUI(oPC, oAssociate);
                    IsWindowClosed(oPC, sAssociateType + AI_COMMAND_NUI);
                    IsWindowClosed(oPC, sAssociateType + AI_LOOTFILTER_NUI);
                    IsWindowClosed(oPC, sAssociateType + AI_COPY_NUI);
                    IsWindowClosed(oPC, sAssociateType + AI_QUICK_WIDGET_NUI);
                    IsWindowClosed(oPC, sAssociateType + AI_SPELL_MEMORIZE_NUI);
                    if(ai_GetIsCharacter(oAssociate))
                    {
                        IsWindowClosed(oPC, AI_MAIN_NUI);
                        IsWindowClosed(oPC, AI_PLUGIN_NUI);
                    }
                }
                else if(sElem == "btn_follow_range") ai_FollowIncrement(oPC, oAssociate, -1.0, sAssociateType, nToken);
                else if(GetStringLeft(sElem, 11) == "btn_widget_")
                {
                    if(GetStringLength(sElem) == 13) nIndex = StringToInt(GetStringRight(sElem, 2));
                    else nIndex = StringToInt(GetStringRight(sElem, 1));
                    json jAIData = ai_GetAssociateDbJson(oPC, ai_GetAssociateType(oPC, oAssociate), "aidata");
                    json jSpells = JsonArrayGet(jAIData, 10);
                    json jWidget = JsonArrayGet(jSpells, 2);
                    json jSpell = JsonArrayGet(jWidget, nIndex);
                    int nSpell = JsonGetInt(JsonArrayGet(jSpell, 0));
                    int bSpell = JsonGetInt(JsonArrayGet(jSpell, 2));
                    if(bSpell == -1) bSpell = FALSE;
                    else bSpell = TRUE;
                    ai_CreateDescriptionNUI(oPC, jSpell);
                }
            }
        }
        return;
    }
    //**************************************************************************
    // Associate Loot events.
    if(sWndId == sAssociateType + AI_LOOTFILTER_NUI)
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
                if(sElem == "chbx_give_loot_check") ai_SetLootFilterToCheckbox(oPC, oAssociate, AI_LOOT_GIVE_TO_PC, nToken, sElem);
                else if(sElem == "chbx_2_check") ai_SetLootFilterToCheckbox(oPC, oAssociate, AI_LOOT_PLOT, nToken, sElem);
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
        return;
    }
    //**************************************************************************
    // Associate Paste events.
    if(sWndId == sAssociateType + AI_COPY_NUI)
    {
        if(sEvent == "click")
        {
            int nIndex, nAssociateType = GetAssociateType(oAssociate);
            string sAssociateType = ai_GetAssociateType(oPC, oAssociate);
            object oAssoc;
            string sAssocType;
            json jModes = ai_GetAssociateDbJson(oPC, sAssociateType, "modes");
            json jButtons = ai_GetAssociateDbJson(oPC, sAssociateType, "buttons");
            json jAIData = ai_GetAssociateDbJson(oPC, sAssociateType, "aidata");
            json jLootFilters = ai_GetAssociateDbJson(oPC, sAssociateType, "lootfilters");
            string sCombatScript = GetLocalString(oAssociate, AI_COMBAT_SCRIPT);
            string sDefaultScript = GetLocalString(oAssociate, AI_DEFAULT_SCRIPT);
            if(sElem == "btn_paste_all")
            {
                // Check all non-henchman associates.
                for(nIndex = 2; nIndex < 6; nIndex++)
                {
                    if(nAssociateType != nIndex)
                    {
                        oAssoc = GetAssociate(nIndex, oPC);
                        sAssocType = ai_GetAssociateType(oPC, oAssoc);
                        ai_SetAssociateDbJson(oPC, sAssocType, "modes", jModes);
                        ai_SetAssociateDbJson(oPC, sAssocType, "buttons", jButtons);
                        ai_SetAssociateDbJson(oPC, sAssocType, "aidata", jAIData);
                        ai_SetAssociateDbJson(oPC, sAssocType, "lootfilters", jLootFilters);
                        SetLocalString(oAssoc, AI_COMBAT_SCRIPT, sCombatScript);
                        SetLocalString(oAssoc, AI_DEFAULT_SCRIPT, sDefaultScript);
                        if(oAssoc != OBJECT_INVALID)
                        {
                            // Clear the creatures Perception distance so we can
                            // repopulate the local variables.
                            SetLocalFloat(oAssoc, AI_ASSOC_PERCEPTION_DISTANCE, 0.0);
                            ai_CheckAssociateData(oPC, oAssoc, sAssocType);
                            if(!ai_GetWidgetButton(oPC, BTN_WIDGET_OFF, oAssoc, sAssocType))
                            {
                                NuiDestroy(oPC, NuiFindWindow(oPC, sAssocType + AI_WIDGET_NUI));
                                ai_CreateWidgetNUI(oPC, oAssoc);
                            }
                        }
                    }
                }
                // Check all of our henchman.
                for(nIndex = 1; nIndex <= AI_MAX_HENCHMAN; nIndex++)
                {
                    oAssoc = GetAssociate(ASSOCIATE_TYPE_HENCHMAN, oPC, nIndex);
                    if(oAssoc != OBJECT_INVALID)
                    {
                        sAssocType = ai_GetAssociateType(oPC, oAssoc);
                        ai_SetAssociateDbJson(oPC, sAssocType, "modes", jModes);
                        ai_SetAssociateDbJson(oPC, sAssocType, "buttons", jButtons);
                        ai_SetAssociateDbJson(oPC, sAssocType, "aidata", jAIData);
                        ai_SetAssociateDbJson(oPC, sAssocType, "lootfilters", jLootFilters);
                        SetLocalString(oAssoc, AI_COMBAT_SCRIPT, sCombatScript);
                        SetLocalString(oAssoc, AI_DEFAULT_SCRIPT, sDefaultScript);
                        // Clear the creatures Perception distance so we can
                        // repopulate the local variables.
                        SetLocalFloat(oAssoc, AI_ASSOC_PERCEPTION_DISTANCE, 0.0);
                        ai_CheckAssociateData(oPC, oAssoc, sAssocType);
                        if(!ai_GetWidgetButton(oPC, BTN_WIDGET_OFF, oAssoc, sAssocType))
                        {
                            NuiDestroy(oPC, NuiFindWindow(oPC, sAssocType + AI_WIDGET_NUI));
                            ai_CreateWidgetNUI(oPC, oAssoc);
                        }
                    }
                    else break;
                }
                ai_SendMessages(GetName(oAssociate) + "'s settings have been copied to all associates.", AI_COLOR_GREEN, oPC);
                return;
            }
            else if(GetStringLeft(sElem, 18) == "btn_paste_henchman")
            {
                int nIndex = StringToInt(GetStringRight(sElem, 1));
                oAssoc = GetAssociate(ASSOCIATE_TYPE_HENCHMAN, oPC, nIndex);
                if(oAssoc != OBJECT_INVALID)
                {
                    sAssocType = ai_GetAssociateType(oPC, oAssoc);
                    ai_SetAssociateDbJson(oPC, sAssocType, "modes", jModes);
                    ai_SetAssociateDbJson(oPC, sAssocType, "buttons", jButtons);
                    ai_SetAssociateDbJson(oPC, sAssocType, "aidata", jAIData);
                    ai_SetAssociateDbJson(oPC, sAssocType, "lootfilters", jLootFilters);
                    SetLocalString(oAssoc, AI_COMBAT_SCRIPT, sCombatScript);
                    SetLocalString(oAssoc, AI_DEFAULT_SCRIPT, sDefaultScript);
                    // Clear the creatures Perception distance so we can
                    // repopulate the local variables.
                    SetLocalFloat(oAssoc, AI_ASSOC_PERCEPTION_DISTANCE, 0.0);
                    ai_CheckAssociateData(oPC, oAssoc, sAssocType);
                    if(!ai_GetWidgetButton(oPC, BTN_WIDGET_OFF, oAssoc, sAssocType))
                    {
                        NuiDestroy(oPC, NuiFindWindow(oPC, sAssocType + AI_WIDGET_NUI));
                        ai_CreateWidgetNUI(oPC, oAssoc);
                    }
                    ai_SendMessages(GetName(oAssociate) + "'s settings have been copied to " + GetName(oAssoc) + ".", AI_COLOR_GREEN, oPC);
                }
                return;
            }
            else if(sElem == "btn_paste_familiar") nIndex = ASSOCIATE_TYPE_FAMILIAR;
            else if(sElem == "btn_paste_companion") nIndex = ASSOCIATE_TYPE_ANIMALCOMPANION;
            else if(sElem == "btn_paste_summons") nIndex = ASSOCIATE_TYPE_SUMMONED;
            else if(sElem == "btn_paste_dominated") nIndex = ASSOCIATE_TYPE_DOMINATED;
            if(nIndex > 1 && nIndex < 6)
            {
                oAssoc = GetAssociate(nIndex, oPC);
                sAssocType = ai_GetAssociateType(oPC, oAssoc);
                ai_SetAssociateDbJson(oPC, sAssocType, "modes", jModes);
                ai_SetAssociateDbJson(oPC, sAssocType, "buttons", jButtons);
                ai_SetAssociateDbJson(oPC, sAssocType, "aidata", jAIData);
                ai_SetAssociateDbJson(oPC, sAssocType, "lootfilters", jLootFilters);
                SetLocalString(oAssoc, AI_COMBAT_SCRIPT, sCombatScript);
                SetLocalString(oAssoc, AI_DEFAULT_SCRIPT, sDefaultScript);
                if(oAssoc != OBJECT_INVALID)
                {
                    // Clear the creatures Perception distance so we can
                    // repopulate the local variables.
                    SetLocalFloat(oAssoc, AI_ASSOC_PERCEPTION_DISTANCE, 0.0);
                    ai_CheckAssociateData(oPC, oAssoc, sAssocType);
                    if(!ai_GetWidgetButton(oPC, BTN_WIDGET_OFF, oAssoc, sAssocType))
                    {
                        NuiDestroy(oPC, NuiFindWindow(oPC, sAssocType + AI_WIDGET_NUI));
                        ai_CreateWidgetNUI(oPC, oAssoc);
                    }
                    ai_SendMessages(GetName(oAssociate) + "'s settings have been copied to " + GetName(oAssoc) + ".", AI_COLOR_GREEN, oPC);
                }
            }
        }
        return;
    }
    //**************************************************************************
    // Plugins events.
    if(sWndId == AI_PLUGIN_NUI)
    {
        if(sEvent == "click")
        {
            if(sElem == "btn_load_plugins")
            {
                string sScript = JsonGetString(NuiGetBind (oPC, nToken, "txt_plugin"));
                json jPlugins = ai_GetAssociateDbJson(oPC, "pc", "plugins");
                jPlugins = ai_Plugin_Add(oPC, jPlugins, "pi_buffing");
                jPlugins = ai_Plugin_Add(oPC, jPlugins, "pi_forcerest");
                jPlugins = ai_Plugin_Add(oPC, jPlugins, "pi_henchmen");
                jPlugins = ai_Plugin_Add(oPC, jPlugins, "pi_crafting");
                jPlugins = ai_Plugin_Add(oPC, jPlugins, "pi_mod_set");
                jPlugins = ai_Plugin_Add(oPC, jPlugins, "pi_debug");
                jPlugins = ai_Plugin_Add(oPC, jPlugins, "pi_test");
                ai_SetAssociateDbJson(oPC, "pc", "plugins", jPlugins);
                NuiDestroy(oPC, nToken);
                ai_CreatePluginNUI(oPC);
            }
            if(sElem == "btn_check_plugins")
            {
                json jPlugins = ai_GetAssociateDbJson(oPC, "pc", "plugins");
                int nIndex;
                json jPlugin = JsonArrayGet(jPlugins, nIndex);
                while(JsonGetType(jPlugin) != JSON_TYPE_NULL)
                {
                    jPlugin = JsonArraySet(jPlugin, 1, JsonBool(TRUE));
                    jPlugins = JsonArraySet(jPlugins, nIndex, jPlugin);
                    jPlugin = JsonArrayGet(jPlugins, ++nIndex);
                }
                ai_SetAssociateDbJson(oPC, "pc", "plugins", jPlugins);
                NuiDestroy(oPC, nToken);
                ai_CreatePluginNUI(oPC);
                NuiDestroy(oPC, NuiFindWindow(oPC, "pc" + AI_WIDGET_NUI));
                ai_CreateWidgetNUI(oPC, oPC);
            }
            if(sElem == "btn_clear_plugins")
            {
                json jPlugins = ai_GetAssociateDbJson(oPC, "pc", "plugins");
                int nIndex;
                json jPlugin = JsonArrayGet(jPlugins, nIndex);
                while(JsonGetType(jPlugin) != JSON_TYPE_NULL)
                {
                    jPlugin = JsonArraySet(jPlugin, 1, JsonBool(FALSE));
                    jPlugins = JsonArraySet(jPlugins, nIndex, jPlugin);
                    jPlugin = JsonArrayGet(jPlugins, ++nIndex);
                }
                ai_SetAssociateDbJson(oPC, "pc", "plugins", jPlugins);
                NuiDestroy(oPC, nToken);
                ai_CreatePluginNUI(oPC);
                NuiDestroy(oPC, NuiFindWindow(oPC, "pc" + AI_WIDGET_NUI));
                ai_CreateWidgetNUI(oPC, oPC);
            }
            else if(sElem == "btn_add_plugin")
            {
                string sScript = JsonGetString(NuiGetBind (oPC, nToken, "txt_plugin"));
                json jPlugins = ai_GetAssociateDbJson(oPC, "pc", "plugins");
                jPlugins = ai_Plugin_Add(oPC, jPlugins, sScript);
                ai_SetAssociateDbJson(oPC, "pc", "plugins", jPlugins);
                NuiDestroy(oPC, nToken);
                ai_CreatePluginNUI(oPC);
            }
            else if(GetStringLeft(sElem, 18) == "btn_remove_plugin_")
            {
                int nIndex = StringToInt(GetStringRight(sElem, 1));
                json jPlugins = ai_GetAssociateDbJson(oPC, "pc", "plugins");
                jPlugins = JsonArrayDel(jPlugins, nIndex);
                ai_SetAssociateDbJson(oPC, "pc", "plugins", jPlugins);
                NuiDestroy(oPC, nToken);
                ai_CreatePluginNUI(oPC);
                NuiDestroy(oPC, NuiFindWindow(oPC, "pc" + AI_WIDGET_NUI));
                ai_CreateWidgetNUI(oPC, oPC);
            }
            else if(GetStringLeft(sElem, 11) == "btn_plugin_") ai_Plugin_Execute(oPC, sElem);
        }
        else if(sEvent == "watch")
        {
            if(GetStringLeft(sElem, 12) == "chbx_plugin_" && GetStringRight(sElem, 6) == "_check")
            {
                int nIndex = StringToInt(GetSubString(sElem, 12, 1));
                json jPlugins = ai_GetAssociateDbJson(oPC, "pc", "plugins");
                json jPlugin = JsonArrayGet(jPlugins, nIndex);
                int bCheck = JsonGetInt(NuiGetBind(oPC, nToken, sElem));
                jPlugin = JsonArraySet(jPlugin, 1, JsonBool(bCheck));
                jPlugins = JsonArraySet(jPlugins, nIndex, jPlugin);
                ai_SetAssociateDbJson(oPC, "pc", "plugins", jPlugins);
                NuiDestroy(oPC, NuiFindWindow(oPC, "pc" + AI_WIDGET_NUI));
                ai_CreateWidgetNUI(oPC, oPC);
            }
        }
        return;
    }
    //**************************************************************************
    // Quick Use Widget events.
    if(sWndId == sAssociateType + AI_QUICK_WIDGET_NUI)
    {
        if(sEvent == "click")
        {
            if(GetStringLeft(sElem, 10) == "btn_class_") // Changes the class.
            {
                string sClassPosition = GetStringRight(sElem, 1);
                json jAIData = ai_GetAssociateDbJson(oPC, sAssociateType, "aidata");
                json jSpells = JsonArrayGet(jAIData, 10);
                jSpells = JsonArraySet(jSpells, 0, JsonInt(StringToInt(sClassPosition)));
                jAIData = JsonArraySet(jAIData, 10, jSpells);
                ai_SetAssociateDbJson(oPC, sAssociateType, "aidata", jAIData);
                NuiDestroy(oPC, nToken);
                ai_CreateQuickWidgetSelectionNUI(oPC, oAssociate);
            }
            else if(GetStringLeft(sElem, 10) == "btn_level_") // Changes the level.
            {
                string sLevel;
                if(GetStringLength(sElem) == 12) sLevel = GetStringRight(sElem, 2);
                else sLevel = GetStringRight(sElem, 1);
                json jAIData = ai_GetAssociateDbJson(oPC, sAssociateType, "aidata");
                json jSpells = JsonArrayGet(jAIData, 10);
                jSpells = JsonArraySet(jSpells, 1, JsonInt(StringToInt(sLevel)));
                jAIData = JsonArraySet(jAIData, 10, jSpells);
                ai_SetAssociateDbJson(oPC, sAssociateType, "aidata", jAIData);
                NuiDestroy(oPC, nToken);
                ai_CreateQuickWidgetSelectionNUI(oPC, oAssociate);
            }
            else if(sElem == "btn_text_spell") // Adds abilities to quick use widget.
            {
                json jAIData = ai_GetAssociateDbJson(oPC, sAssociateType, "aidata");
                json jSpells = JsonArrayGet(jAIData, 10);
                json jWidget = JsonArrayGet(jSpells, 2);
                if(JsonGetType(jWidget) == JSON_TYPE_NULL)
                {
                    jWidget = JsonArray();
                    if(JsonGetLength(jSpells) == 2) jSpells = JsonArrayInsert(jSpells, JsonArray());
                }
                if(JsonGetLength(jWidget) < 20)
                {
                    json jData = NuiGetUserData(oPC, nToken);
                    json jQuickListArray = JsonArrayGet(jData, 1);
                    json jSpell = JsonArrayGet(jQuickListArray, nIndex);
                    jWidget = JsonArrayInsert(jWidget, jSpell);
                    jSpells = JsonArraySet(jSpells, 2, jWidget);
                    jAIData = JsonArraySet(jAIData, 10, jSpells);
                    ai_SetAssociateDbJson(oPC, sAssociateType, "aidata", jAIData);
                    NuiDestroy(oPC, nToken);
                    ai_CreateQuickWidgetSelectionNUI(oPC, oAssociate);
                }
                else ai_SendMessages("The quick widget can only have 20 abilities or spells!", AI_COLOR_RED, oPC);
            }
            else if(sElem == "btn_info_spell")
            {
                json jQuickListArray = JsonArrayGet(jData, 1);
                json jSpell = JsonArrayGet(jQuickListArray, nIndex);
                int nSpell = JsonGetInt(JsonArrayGet(jSpell, 0));
                int nFeat = JsonGetInt(JsonArrayGet(jSpell, 5));
                int bSpell;
                ai_CreateDescriptionNUI(oPC, jSpell);
            }
            else if(GetStringLeft(sElem, 11) == "btn_widget_")
            {
                string sIndex;
                if(GetStringLength(sElem) == 13) sIndex = GetStringRight(sElem, 2);
                else sIndex = GetStringRight(sElem, 1);
                json jAIData = ai_GetAssociateDbJson(oPC, sAssociateType, "aidata");
                json jSpells = JsonArrayGet(jAIData, 10);
                json jWidget = JsonArrayGet(jSpells, 2);
                jWidget = JsonArrayDel(jWidget, StringToInt(sIndex));
                jSpells = JsonArraySet(jSpells, 2, jWidget);
                jAIData = JsonArraySet(jAIData, 10, jSpells);
                ai_SetAssociateDbJson(oPC, sAssociateType, "aidata", jAIData);
                NuiDestroy(oPC, nToken);
                ai_CreateQuickWidgetSelectionNUI(oPC, oAssociate);
            }
        }
        else if(sEvent == "close")
        {
            int nUIToken = NuiFindWindow(oPC, sAssociateType + AI_QUICK_WIDGET_NUI);
            if(nUIToken)
            {
                NuiDestroy(oPC, nToken);
                ai_CreateWidgetNUI(oPC, oAssociate);
            }
        }
        return;
    }
    //**************************************************************************
    // Spell Memorization events.
    if(sWndId == sAssociateType + AI_SPELL_MEMORIZE_NUI)
    {
        if(sEvent == "click")
        {
            if(GetStringLeft(sElem, 10) == "btn_class_") // Changes the class.
            {
                string sClassPosition = GetStringRight(sElem, 1);
                json jAIData = ai_GetAssociateDbJson(oPC, sAssociateType, "aidata");
                json jSpells = JsonArrayGet(jAIData, 10);
                jSpells = JsonArraySet(jSpells, 0, JsonInt(StringToInt(sClassPosition)));
                jAIData = JsonArraySet(jAIData, 10, jSpells);
                ai_SetAssociateDbJson(oPC, sAssociateType, "aidata", jAIData);
                NuiDestroy(oPC, nToken);
                ai_CreateSpellMemorizationNUI(oPC, oAssociate);
            }
            else if(GetStringLeft(sElem, 10) == "btn_level_") // Changes the level.
            {
                string sLevel = GetStringRight(sElem, 1);
                json jAIData = ai_GetAssociateDbJson(oPC, sAssociateType, "aidata");
                json jSpells = JsonArrayGet(jAIData, 10);
                jSpells = JsonArraySet(jSpells, 1, JsonInt(StringToInt(sLevel)));
                jAIData = JsonArraySet(jAIData, 10, jSpells);
                ai_SetAssociateDbJson(oPC, sAssociateType, "aidata", jAIData);
                NuiDestroy(oPC, nToken);
                ai_CreateSpellMemorizationNUI(oPC, oAssociate);
            }
            else if(sElem == "btn_text_spell") // Adds spell to memorization.
            {
                json jAIData = ai_GetAssociateDbJson(oPC, sAssociateType, "aidata");
                json jSpells = JsonArrayGet(jAIData, 10);
                int nClass = GetClassByPosition(JsonGetInt(JsonArrayGet(jSpells, 0)), oAssociate);
                int nLevel = JsonGetInt(JsonArrayGet(jSpells, 1));
                json jSpellArray = JsonArrayGet(jData, 1);
                int nMaxMemorizationSlot = GetMemorizedSpellCountByLevel(oAssociate, nClass, nLevel);
                int nSlot, nSpell;
                while(nSlot < nMaxMemorizationSlot)
                {
                    if(GetMemorizedSpellId(oAssociate, nClass, nLevel, nSlot) == -1)
                    {
                        nSpell = JsonGetInt(JsonArrayGet(jSpellArray, nIndex));
                        SetMemorizedSpell(oAssociate, nClass, nLevel, nSlot, nSpell, FALSE);
                        //NuiDestroy(oPC, nToken);
                        //ai_CreateSpellMemorizationNUI(oPC, oAssociate);
                        string sClass = GetStringByStrRef(StringToInt(Get2DAString("classes", "Name", nClass)));
                        string sName = GetStringByStrRef(StringToInt(Get2DAString("spells", "Name", nSpell)));
                        string sSpellIcon = Get2DAString("spells", "IconResRef", nSpell);
                        string sIndex = IntToString(nSlot);
                        NuiSetBind(oPC, nToken, "btn_memorized_" + sIndex + "_event", JsonBool(TRUE));
                        NuiSetBind(oPC, nToken, "btn_memorized_" + sIndex + "_image", JsonString(sSpellIcon));
                        NuiSetBind(oPC, nToken, "btn_memorized_" + sIndex + "_tooltip", JsonString("  " + sName + " (" + sClass + " / " + IntToString(nLevel) + ")"));
                        return;
                    }
                    nSlot++;
                }
                if(nSlot >= nMaxMemorizationSlot) ai_SendMessages("All spell memorization slots are full!", AI_COLOR_RED, oPC);
            }
            else if(sElem == "btn_info_spell")
            {
                json jAIData = ai_GetAssociateDbJson(oPC, sAssociateType, "aidata");
                json jSpells = JsonArrayGet(jAIData, 10);
                json jSpell = JsonArrayGet(jData, 1);
                int nSpell = JsonGetInt(JsonArrayGet(jSpell, nIndex));
                ai_CreateDescriptionNUI(oPC, jSpell);
            }
            else if(GetStringLeft(sElem, 14) == "btn_memorized_")
            {
                json jAIData = ai_GetAssociateDbJson(oPC, sAssociateType, "aidata");
                json jSpells = JsonArrayGet(jAIData, 10);
                int nClass = GetClassByPosition(JsonGetInt(JsonArrayGet(jSpells, 0)), oAssociate);
                int nLevel = JsonGetInt(JsonArrayGet(jSpells, 1));
                string sIndex = GetStringRight(sElem, 1);
                ClearMemorizedSpell(oAssociate, nClass, nLevel, StringToInt(sIndex));
                NuiSetBind(oPC, nToken, "btn_memorized_" + sIndex + "_image", JsonString("ctl_cg_btn_splvl"));
                NuiSetBind(oPC, nToken, "btn_memorized_" + sIndex + "_tooltip", JsonString(""));
                NuiSetBind(oPC, nToken, "btn_memorized_" + sIndex + "_event", JsonBool(FALSE));
                //NuiDestroy(oPC, nToken);
                //ai_CreateSpellMemorizationNUI(oPC, oAssociate);
            }
        }
        else if(sEvent == "close")
        {
            int nUIToken = NuiFindWindow(oPC, sAssociateType + AI_QUICK_WIDGET_NUI);
            if(nUIToken)
            {
                NuiDestroy(oPC, nToken);
                ai_CreateWidgetNUI(oPC, oAssociate);
            }
        }
        return;
    }
    //**************************************************************************
    // Spell Description events.
    if(sWndId == AI_SPELL_DESCRIPTION_NUI)
    {
        if(sEvent == "click" && sElem == "btn_ok") NuiDestroy(oPC, nToken);
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
void ai_SetLootFilterToCheckbox(object oPC, object oAssociate, int nFilterBit, int nToken, string sElem)
{
    int bCheck = JsonGetInt(NuiGetBind(oPC, nToken, sElem));
    ai_SetLootFilter(oAssociate, nFilterBit, bCheck);
}
void ai_AddAssociate(object oPC, int nToken, json jAssociate, location lLocation, int nFamiliar, int nCompanion, int nRange = 0)
{
    object oAssociate = JsonToObject(jAssociate, lLocation, OBJECT_INVALID, TRUE);
    //ChangeToStandardFaction(oAssociate, STANDARD_FACTION_COMMONER);
    //SetStandardFactionReputation(STANDARD_FACTION_COMMONER, 50, oAssociate);
    //SetStandardFactionReputation(STANDARD_FACTION_DEFENDER, 50, oAssociate);
    //SetStandardFactionReputation(STANDARD_FACTION_MERCHANT, 50, oAssociate);
    //SetStandardFactionReputation(STANDARD_FACTION_HOSTILE, 0, oAssociate);
    AddHenchman(oPC, oAssociate);
    DeleteLocalInt(oPC, "AI_IGNORE_NO_ASSOCIATE");
    NuiDestroy(oPC, nToken);
    ai_CreateWidgetNUI(oPC, oAssociate);
    if(nRange) SetLocalInt(oAssociate, AI_ASSOCIATE_PERCEPTION, nRange);
    if(nFamiliar) SummonFamiliar(oAssociate);
    if(nCompanion) SummonAnimalCompanion(oAssociate);
}
void ai_SetCompanionType(object oPC, object oAssociate, int nToken, int nAssociateType)
{
    if(ai_GetIsCharacter(oAssociate)) return;
    SetLocalInt(oPC, "AI_IGNORE_NO_ASSOCIATE", TRUE);
    int nSelection;
    // Need to remove the henchman before we copy them to keep factions correct.
    ai_FireHenchman(oPC, oAssociate);
    json jAssociate = ObjectToJson(oAssociate, TRUE);
    if(nAssociateType == ASSOCIATE_TYPE_FAMILIAR)
    {
        nSelection = JsonGetInt(NuiGetBind(oPC, nToken, "cmb_familiar_selected"));
        jAssociate = GffReplaceInt(jAssociate, "FamiliarType", nSelection);
    }
    else if(nAssociateType == ASSOCIATE_TYPE_ANIMALCOMPANION)
    {
        nSelection = JsonGetInt(NuiGetBind(oPC, nToken, "cmb_companion_selected"));
        jAssociate = GffReplaceInt(jAssociate, "CompanionType", nSelection);
    }
    //ai_Debug("0e_nui", "916", JsonDump(jAssociate, 1));
    location lLocation = GetLocation(oAssociate);
    int nFamiliar, nCompanion;
    object oCompanion = GetAssociate(ASSOCIATE_TYPE_FAMILIAR, oAssociate);
    if(oCompanion != OBJECT_INVALID) nFamiliar = TRUE;
    oCompanion = GetAssociate(ASSOCIATE_TYPE_ANIMALCOMPANION, oAssociate);
    if(oCompanion != OBJECT_INVALID) nCompanion = TRUE;
    AssignCommand(oAssociate, SetIsDestroyable(TRUE, FALSE, FALSE));
    DestroyObject(oAssociate);
    DelayCommand(0.1, ai_AddAssociate(oPC, nToken, jAssociate, lLocation, nFamiliar, nCompanion));
}
void ai_SetCompanionName(object oPC, object oAssociate, int nToken, int nAssociateType)
{
    if(ai_GetIsCharacter(oAssociate)) return;
    SetLocalInt(oPC, "AI_IGNORE_NO_ASSOCIATE", TRUE);
    string sAssociateType;
    string sName;
    // Need to remove the henchman before we copy them to keep factions correct.
    ai_FireHenchman(oPC, oAssociate);
    json jAssociate = ObjectToJson(oAssociate, TRUE);
    if(nAssociateType == ASSOCIATE_TYPE_FAMILIAR)
    {
        sName = JsonGetString(NuiGetBind(oPC, nToken, "txt_familiar_name"));
        jAssociate = GffReplaceString(jAssociate, "FamiliarName", sName);
    }
    else if(nAssociateType == ASSOCIATE_TYPE_ANIMALCOMPANION)
    {
        sAssociateType = "txt_companion_name";
        sName = JsonGetString(NuiGetBind(oPC, nToken, "txt_companion_name"));
        jAssociate = GffReplaceString(jAssociate, "FamiliarName", sName);
    }
    location lLocation = GetLocation(oAssociate);
    int nFamiliar, nCompanion;
    object oCompanion = GetAssociate(ASSOCIATE_TYPE_FAMILIAR, oAssociate);
    if(oCompanion != OBJECT_INVALID) nFamiliar = TRUE;
    oCompanion = GetAssociate(ASSOCIATE_TYPE_ANIMALCOMPANION, oAssociate);
    if(oCompanion != OBJECT_INVALID) nCompanion = TRUE;
    AssignCommand(oAssociate, SetIsDestroyable(TRUE, FALSE, FALSE));
    DestroyObject(oAssociate);
    DelayCommand(0.1, ai_AddAssociate(oPC, nToken, jAssociate, lLocation, nFamiliar, nCompanion));
}
void ai_SetAIScript(object oPC, object oAssociate, int nToken)
{
    int nSelection = JsonGetInt(NuiGetBind(oPC, nToken, "cmb_ai_script_selected"));
    if(nSelection == 0) return;
    string sScript = sScript = ResManFindPrefix("ai_a_", RESTYPE_NCS, nSelection);
    NuiSetBind(oPC, nToken, "txt_ai_script", JsonString(sScript));
    string sOldScript = GetLocalString(oAssociate, AI_COMBAT_SCRIPT);
    if(sScript != sOldScript)
    {
        SetLocalString(oAssociate, AI_COMBAT_SCRIPT, sScript);
        SetLocalString(oAssociate, AI_DEFAULT_SCRIPT, sScript);
        string sAssociateType = ai_GetAssociateType(oPC, oAssociate);
        json jAIData = ai_GetAssociateDbJson(oPC, sAssociateType, "aidata");
        if(JsonGetType(JsonArrayGet(jAIData, 8)) == JSON_TYPE_NULL) JsonArrayInsertInplace(jAIData, JsonString(sScript));
        else JsonArraySetInplace(jAIData, 8, JsonString(sScript));
        ai_SetAssociateDbJson(oPC, sAssociateType, "aidata", jAIData);
        ai_SendMessages(GetName(oAssociate) + " is now using " + sScript + " AI script!", AI_COLOR_GREEN, oPC);
    }
    else ai_SendMessages(GetName(oAssociate) + " is already using this script! Did not change AI script.", AI_COLOR_RED, oPC);
}
void ai_PercRangeIncrement(object oPC, object oAssociate, int nIncrement, string sAssociateType, int nToken)
{
    int nAdjustment = GetLocalInt(oAssociate, AI_ASSOCIATE_PERCEPTION + "_MENU");
    nAdjustment += nIncrement;
    if(nAdjustment < 8 || nAdjustment > 11) return;
    SetLocalInt(oAssociate, AI_ASSOCIATE_PERCEPTION + "_MENU", nAdjustment);
    json jAssociate = ObjectToJson(oAssociate, TRUE);
    int nHenchPercRange = JsonGetInt(GffGetByte(jAssociate, "PerceptionRange"));
    string sText, sInfo;
    if(nAdjustment == nHenchPercRange)
    {
        if(nAdjustment == 8) sText = "  Perception Range Short [10 meters Sight / 10 meters Listen]";
        else if(nAdjustment == 9) sText = "  Perception Range Medium [20 meters Sight / 20 meters Listen]";
        else if(nAdjustment == 10) sText = "  Perception Range Long [35 meters Sight / 20 meters Listen]";
        else sText = "  Perception Range Default [20 meters Sight / 20 meters Listen]";
        sInfo = " ";
    }
    else
    {
        if(nAdjustment == 8) sText = "  !!! Click the Perception Range button to set to short range !!!";
        else if(nAdjustment == 9) sText = "  !!! Click the Perception Range button to set to medium range !!!";
        else if(nAdjustment == 10) sText = "  !!! Click the Perception Range button to set to long range !!!";
        else sText = "  !!! Click the Perception Range button to set to the default range !!!";
        sInfo = sText;
    }
    ai_UpdateToolTipUI(oPC, sAssociateType + AI_NUI, sAssociateType + AI_WIDGET_NUI, "btn_perc_range_tooltip", sText);
    if(nToken > -1) NuiSetBind (oPC, nToken, "lbl_info_label", JsonString(sInfo));
}
void ai_Perc_Range(object oPC, object oAssociate, int nToken, string sAssociateType)
{
    if(ai_GetIsCharacter(oAssociate)) return;
    SetLocalInt(oPC, "AI_IGNORE_NO_ASSOCIATE", TRUE);
    int nBtnPercRange = GetLocalInt(oAssociate, AI_ASSOCIATE_PERCEPTION + "_MENU");
    string sText, sText2;
    float fRange = 20.0;
    if(nBtnPercRange == 8)
    {
        sText = "short";
        sText2 = "  Perception Range Short [10 meters Sight / 10 meters Listen]";
        fRange = 10.0;
    }
    else if(nBtnPercRange == 9)
    {
        sText = "medium";
        sText2 = "  Perception Range Medium [20 meters Sight / 20 meters Listen]";
    }
    else if(nBtnPercRange == 10)
    {
        sText = "long";
        sText2 = "  Perception Range Long [35 meters Sight / 20 meters Listen]";
        fRange = 35.0;
    }
    else if(nBtnPercRange == 11)
    {
        sText = "default";
        sText2 = "  Perception Range Default [20 meters Sight / 20 meters Listen]";
    }
    SetLocalFloat(oAssociate, AI_ASSOC_PERCEPTION_DISTANCE, fRange);
    SetLocalInt(oAssociate, AI_ASSOCIATE_PERCEPTION, nBtnPercRange);
    json jAIData = ai_GetAssociateDbJson(oPC, sAssociateType, "aidata");
    JsonArraySetInplace(jAIData, 7, JsonInt(nBtnPercRange));
    ai_SetAssociateDbJson(oPC, sAssociateType, "aidata", jAIData);
    // Need to remove the henchman before we copy them to keep factions correct.
    ai_FireHenchman(oPC, oAssociate);
    json jAssociate = ObjectToJson(oAssociate, TRUE);
    int nHenchPercRange = JsonGetInt(GffGetByte(jAssociate, "PerceptionRange"));
    if(nBtnPercRange == nHenchPercRange)
    {
        ai_SendMessages(GetName(oAssociate) + " already has this perception set.", AI_COLOR_YELLOW, oPC);
        AddHenchman(oPC, oAssociate);
        DeleteLocalInt(oPC, "AI_IGNORE_NO_ASSOCIATE");
        return;
    }
    NuiDestroy(oPC, NuiFindWindow(oPC, sAssociateType + AI_NUI));
    ai_UpdateToolTipUI(oPC, sAssociateType + AI_NUI, sAssociateType + AI_WIDGET_NUI, "btn_perc_range_tooltip", sText2);
    ai_SendMessages(GetName(oAssociate) + " has updated their perception range to " + sText + ".", AI_COLOR_YELLOW, oPC);
    location lLocation = GetLocation(oAssociate);
    jAssociate = GffReplaceByte(jAssociate, "PerceptionRange", nBtnPercRange);
    int nFamiliar, nCompanion;
    object oCompanion = GetAssociate(ASSOCIATE_TYPE_FAMILIAR, oAssociate);
    if(oCompanion != OBJECT_INVALID) nFamiliar = TRUE;
    oCompanion = GetAssociate(ASSOCIATE_TYPE_ANIMALCOMPANION, oAssociate);
    if(oCompanion != OBJECT_INVALID) nCompanion = TRUE;
    AssignCommand(oAssociate, SetIsDestroyable(TRUE, FALSE, FALSE));
    DestroyObject(oAssociate);
    DelayCommand(0.1, ai_AddAssociate(oPC, nToken, jAssociate, lLocation, nFamiliar, nCompanion, nBtnPercRange));
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
void ai_TurnOn(object oPC, object oTarget, string sAssociateType)
{
    ai_UpdateToolTipUI(oPC, sAssociateType + AI_NUI, sAssociateType + AI_WIDGET_NUI, "btn_ai_tooltip", "  AI On");
    ai_SendMessages("AI turned on for " + GetName(oTarget) + ".", AI_COLOR_YELLOW, oPC);
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
    ai_UpdateToolTipUI(oPC, sAssociateType + AI_NUI, sAssociateType + AI_WIDGET_NUI, "btn_ai_tooltip", "  AI Off");
    ai_SendMessages("AI Turned off for " + GetName(oAssociate) + ".", AI_COLOR_YELLOW, oPC);
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
    DeleteLocalInt(oAssociate, "AI_I_AM_BEING_HEALED");
    DeleteLocalString(oAssociate, "AIScript");
    ai_ClearCreatureActions();
}
