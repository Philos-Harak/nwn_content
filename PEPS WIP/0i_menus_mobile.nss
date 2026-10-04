/*//////////////////////////////////////////////////////////////////////////////
// Script Name: 0i_menus_mobile
////////////////////////////////////////////////////////////////////////////////
 Include script for handling NUI menus for mobile use.
*///////////////////////////////////////////////////////////////////////////////
#include "0i_menus"

void ai_CreateAIMainMobileNUI(object oPC)
{
    // Set window to not save until it has been created.
    SetLocalInt (oPC, AI_NO_NUI_SAVE, TRUE);
    DelayCommand (2.0, DeleteLocalInt (oPC, AI_NO_NUI_SAVE));
    int nMonsterAI = (ResManGetAliasFor("ai_default", RESTYPE_NCS) != "");
    int nAssociateAI = (ResManGetAliasFor("ai_a_default", RESTYPE_NCS) != "");
    string sText = " [Single player]";
    if(ai_GetIsServer()) sText = " [Server]";
    // ************************************************************************* Width / Height
    // Row 1 ******************************************************************* 500 / 73
    json jRow = JsonArrayInsert(JsonArray(), NuiSpacer());
    jRow = CreateLabel(jRow, PHILOS_VERSION  + sText, "lbl_version ", 510.0f, 20.0f, NUI_HALIGN_CENTER);
    jRow = JsonArrayInsert(jRow, NuiSpacer());
    // Add row to the column.
    json jCol = JsonArrayInsert(JsonArray(), NuiRow(jRow));
    // Row 2 ******************************************************************* 500 / 101
    jRow = CreateLabel(JsonArray(), "", "lbl_ai_info", 510.0f, 20.0f, NUI_HALIGN_CENTER);
    // Add row to the column.
    jCol = JsonArrayInsert(jCol, NuiRow(jRow));
    // Row 3 ******************************************************************* 500 / 134
    jRow = CreateButton(JsonArray(), "Plugin Manager", "btn_plugin_manager", 168.0f, 25.0f, -1.0, "btn_plugin_manager_tooltip");
    jRow = JsonArrayInsert(jRow, NuiSpacer());
    jRow = CreateButtonSelect(jRow, "Action Ghost Mode", "btn_action_ghost", 168.0f, 25.0f, -1.0, "btn_action_ghost_tooltip");
    jRow = JsonArrayInsert(jRow, NuiSpacer());
    jRow = CreateButton(jRow, "Close", "btn_close", 168.0f, 25.0f);
    // Add row to the column.
    jCol = JsonArrayInsert(jCol, NuiRow(jRow));
    // Row 4 ******************************************************************* 500 / 161
    //jRow = JsonArrayInsert(JsonArray(), NuiSpacer());
    //jRow = CreateLabel(jRow, "AI RULES", "lbl_ai_rules", 80.0f, 20.0f, NUI_HALIGN_CENTER);
    //jRow = JsonArrayInsert(jRow, NuiSpacer());
    //jCol = JsonArrayInsert(jCol, NuiRow(jRow));
    float fHeight = 134.0;
    // Row 5 ******************************************************************* 500 / --- (28)
    // Make the AI options a Group.
    json jGroupRow = CreateTextEditBox(JsonArray(), "sPlaceHolder", "txt_max_henchman", 6, FALSE, 40.0f, 35.0f, "txt_max_henchman_tooltip");
    jGroupRow = CreateButtonImage(jGroupRow, "nui_cnt_up", "btn_max_hench_up", 35.0, 35.0, 0.0);
    jGroupRow = CreateButtonImage(jGroupRow, "nui_cnt_down", "btn_max_hench_down", 35.0, 35.0, 0.0);
    jGroupRow = CreateLabel(jGroupRow, "Maximum henchmen that is allowed in your party.", "lbl_max_hench", 370.0f, 35.0f, NUI_HALIGN_LEFT, 0, -1.0, "txt_max_henchman_tooltip");
    json jGroupCol = JsonArrayInsert(JsonArray(), NuiRow(jGroupRow));
    jGroupRow = CreateTextEditBox(JsonArray(), "sPlaceHolder", "txt_xp_scale", 3, FALSE, 40.0f, 35.0f, "txt_xp_scale_tooltip");
    jGroupRow = CreateButtonImage(jGroupRow, "nui_cnt_up", "btn_xp_scale_up", 35.0, 35.0, 0.0);
    jGroupRow = CreateButtonImage(jGroupRow, "nui_cnt_down", "btn_xp_scale_down", 35.0, 35.0, 0.0);
    jGroupRow = CreateLabel(jGroupRow, "Module experience scale.", "lbl_xp_scale", 170.0f, 35.0f, NUI_HALIGN_LEFT, 0, -1.0, "txt_xp_scale_tooltip");
    jGroupRow = CreateCheckBox(jGroupRow, "scale to party.", "chbx_party_scale", 115.0, 35.0, "chbx_party_scale_tooltip");
    jGroupRow = CreateButton(jGroupRow, "Default", "btn_default_xp", 60.0f, 35.0f, -1.0, "btn_default_xp_tooltip");
    jGroupCol = JsonArrayInsert(jGroupCol, NuiRow(jGroupRow));
    fHeight += 108.0;
    if(nMonsterAI || nAssociateAI)
    {
        jGroupRow = CreateCheckBox(JsonArray(), " Creatures will use advanced combat movement.", "chbx_advanced_movement", 450.0, 20.0);
        jGroupCol = JsonArrayInsert(jGroupCol, NuiRow(jGroupRow));
        jGroupRow = CreateCheckBox(JsonArray(), " Use item level restrictions for creatures [Default is off].", "chbx_ilr", 450.0, 20.0);
        jGroupCol = JsonArrayInsert(jGroupCol, NuiRow(jGroupRow));
        jGroupRow = CreateCheckBox(JsonArray(), " Creatures can use the skill Use Magic Device.", "chbx_umd", 450.0, 20.0);
        jGroupCol = JsonArrayInsert(jGroupCol, NuiRow(jGroupRow));
        jGroupRow = CreateCheckBox(JsonArray(), " Creatures can use Healing kits.", "chbx_use_healingkits", 450.0, 20.0);
        jGroupRow = JsonArrayInsert(jGroupCol, NuiRow(jGroupRow));
        jGroupRow = CreateCheckBox(JsonArray(), " Moral checks, wounded creatures may flee during combat.", "chbx_moral", 450.0, 20.0);
        jGroupCol = JsonArrayInsert(jGroupCol, NuiRow(jGroupRow));
        jGroupRow = CreateLabel(JsonArray(), " Spells the AI will not use:", "lbl_restrict_spells", 190.0, 20.0, NUI_HALIGN_LEFT);
        jGroupRow = CreateCheckBox(jGroupRow, " Darkness", "chbx_darkness", 90.0, 20.0, "chbx_darkness_tooltip");
        jGroupRow = CreateCheckBox(jGroupRow, " Dispels", "chbx_dispels", 90.0, 20.0, "chbx_dispels_tooltip");
        jGroupRow = CreateCheckBox(jGroupRow, " Time Stop", "chbx_timestop", 90.0, 20.0, "chbx_timestop_tooltip");
        jGroupCol = JsonArrayInsert(jGroupCol, NuiRow(jGroupRow));
        fHeight += 168.0;
    }
    if(nMonsterAI)
    {
        jGroupRow = CreateTextEditBox(JsonArray(), "sPlaceHolder", "txt_ai_difficulty", 6, FALSE, 40.0f, 35.0f, "txt_ai_difficulty_tooltip");
        jGroupRow = CreateButtonImage(jGroupRow, "nui_cnt_up", "btn_ai_diff_up", 35.0, 35.0, 0.0);
        jGroupRow = CreateButtonImage(jGroupRow, "nui_cnt_down", "btn_ai_diff_down", 35.0, 35.0, 0.0);
        jGroupRow = CreateLabel(jGroupRow, "% chance monsters will attack the weakest target.", "lbl_ai_difficulty", 370.0f, 35.0f, NUI_HALIGN_LEFT, 0, -1.0, "txt_ai_difficulty_tooltip");
        jGroupCol = JsonArrayInsert(jGroupCol, NuiRow(jGroupRow));
        jGroupRow = CreateTextEditBox(JsonArray(), "sPlaceHolder", "txt_perception_distance", 6, FALSE, 40.0f, 35.0f, "txt_perception_distance_tooltip");
        jGroupRow = CreateButtonImage(jGroupRow, "nui_cnt_up", "btn_perc_up", 35.0, 35.0, 0.0);
        jGroupRow = CreateButtonImage(jGroupRow, "nui_cnt_down", "btn_perc_down", 35.0, 35.0, 0.0);
        jGroupRow = CreateLabel(jGroupRow, "meters a monster can respond to allies.", "lbl_perception_distance", 370.0f, 35.0f, NUI_HALIGN_LEFT, 0, 0.0, "txt_perception_distance_tooltip");
        jGroupCol = JsonArrayInsert(jGroupCol, NuiRow(jGroupRow));
        jGroupRow = CreateCheckBox(JsonArray(), " Monsters buff before combat starts.", "chbx_buff_monsters", 275.0, 20.0, "chbx_buff_monsters_tooltip");
        jGroupRow = CreateCheckBox(jGroupRow, " Will use all buff spells!", "chbx_full_buff", 210.0, 20.0, "chbx_full_buff_tooltip");
        jGroupCol = JsonArrayInsert(jGroupCol, NuiRow(jGroupRow));
        jGroupRow = CreateCheckBox(JsonArray(), " Monsters can use summons before combat starts.", "chbx_buff_summons", 450.0, 20.0);
        jGroupCol = JsonArrayInsert(jGroupCol, NuiRow(jGroupRow));
        jGroupRow = CreateCheckBox(JsonArray(), " Monsters can use tactics (ambush, defensive, etc).", "chbx_ambush_monsters", 450.0, 20.0);
        jGroupCol = JsonArrayInsert(jGroupCol, NuiRow(jGroupRow));
        jGroupRow = CreateLabel(JsonArray(), "***** WARNING! The options below may break the module! *****", "lbl_warning", 450.0f, 20.0f, NUI_HALIGN_LEFT, 0, 0.0, "all_warning_tooltip");
        jGroupCol = JsonArrayInsert(jGroupCol, NuiRow(jGroupRow));
        jGroupRow = CreateLabel(JsonArray(), "Add ", "lbl_inc_enc", 30.0, 35.0, NUI_HALIGN_LEFT, 0, -1.0, "txt_inc_enc_tooltip");
        jGroupRow = CreateTextEditBox(jGroupRow, "sPlaceHolder", "txt_inc_enc", 4, FALSE, 55.0f, 35.0f, "txt_inc_enc_tooltip");
        jGroupRow = CreateButtonImage(jGroupRow, "nui_cnt_up", "btn_encounter_up", 35.0, 35.0, 0.0);
        jGroupRow = CreateButtonImage(jGroupRow, "nui_cnt_down", "btn_encounter_down", 35.0, 35.0, 0.0);
        jGroupRow = CreateLabel(jGroupRow, "monsters per spawned encounter monster.", "lbl_inc_enc", 325.0, 35.0, NUI_HALIGN_LEFT, NUI_VALIGN_MIDDLE, 0.0, "txt_inc_enc_tooltip");
        jGroupCol = JsonArrayInsert(jGroupCol, NuiRow(jGroupRow));
        jGroupRow = CreateTextEditBox(JsonArray(), "sPlaceHolder", "txt_inc_hp", 6, FALSE, 40.0f, 35.0f, "all_warning_tooltip");
        jGroupRow = CreateButtonImage(jGroupRow, "nui_cnt_up", "btn_inc_hp_up", 35.0, 35.0, 0.0);
        jGroupRow = CreateButtonImage(jGroupRow, "nui_cnt_down", "btn_inc_hp_down", 35.0, 35.0, 0.0);
        jGroupRow = CreateLabel(jGroupRow, "% increase in all monster's hitpoints.", "lbl_inc_percentage", 370.0, 35.0, NUI_HALIGN_LEFT, 0, 0.0, "all_warning_tooltip");
        jGroupCol = JsonArrayInsert(jGroupCol, NuiRow(jGroupRow));
        jGroupRow = CreateCheckBox(JsonArray(), " Monsters can wander ", "chbx_wander", 175.0, 35.0, "all_warning_tooltip");
        jGroupRow = CreateTextEditBox(jGroupRow, "sPlaceHolder", "txt_wander_distance", 6, FALSE, 40.0f, 35.0f, "all_warning_tooltip");
        jGroupRow = CreateButtonImage(jGroupRow, "nui_cnt_up", "btn_wander_up", 35.0, 35.0, 0.0);
        jGroupRow = CreateButtonImage(jGroupRow, "nui_cnt_down", "btn_wander_down", 35.0, 35.0, 0.0);
        jGroupRow = CreateLabel(jGroupRow, " meters & ", "lbl_wander_distance", 70.0f, 35.0f, NUI_HALIGN_LEFT, NUI_VALIGN_MIDDLE, 0.0, "all_warning_tooltip");
        jGroupRow = CreateCheckBox(jGroupRow, "open doors.", "chbx_open_doors", 100.0, 35.0, "all_warning_tooltip");
        jGroupCol = JsonArrayInsert(jGroupCol, NuiRow(jGroupRow));
        jGroupRow = CreateCheckBox(JsonArray(), " Monsters can summon companions.", "chbx_companions", 450.0, 20.0, "all_warning_tooltip");
        jGroupCol = JsonArrayInsert(jGroupCol, NuiRow(jGroupRow));
        jGroupRow = CreateCheckBox(JsonArray(), " Summoned associates to remain after masters death.", "chbx_perm_assoc", 450.0, 20.0, "all_warning_tooltip");
        jGroupCol = JsonArrayInsert(jGroupCol, NuiRow(jGroupRow));
        jGroupRow = CreateCheckBox(JsonArray(), " Make enemy corpses remain.", "chbx_corpses_stay", 490.0, 20.0, "all_warning_tooltip");
        jGroupCol = JsonArrayInsert(jGroupCol, NuiRow(jGroupRow));
        jGroupRow = CreateButtonImage(JsonArray(), "nui_cnt_up", "btn_perc_dist_up", 35.0, 35.0, 0.0);
        jGroupRow = CreateButtonImage(jGroupRow, "nui_cnt_down", "btn_perc_dist_down", 35.0, 35.0, 0.0);
        jGroupRow = CreateLabel(jGroupRow, "", "lbl_perc_dist", 400.0f, 35.0f, NUI_HALIGN_LEFT, NUI_VALIGN_MIDDLE, 0.0, "all_warning_tooltip");
        jGroupCol = JsonArrayInsert(jGroupCol, NuiRow(jGroupRow));
        fHeight += 448.0;
    }
    jRow = JsonArrayInsert(JsonArray(), NuiGroup(NuiCol(jGroupCol)));
    // Add row to the column.
    jCol = JsonArrayInsert(jCol, NuiRow(jRow));
    // Get the window location to restore it from the database.
    float fX, fY;
    json jLocations = ai_GetAssociateDbJson(oPC, "pc", "locations");
    jLocations = JsonObjectGet(jLocations, AI_MAIN_NUI);
    if(JsonGetType(jLocations) == JSON_TYPE_NULL) { fX = -1.0; fY = -1.0; }
    else
    {
        fX = JsonGetFloat(JsonObjectGet(jLocations, "x"));
        fY = JsonGetFloat(JsonObjectGet(jLocations, "y"));
    }
    // Set the Layout of the window.
    json jLayout = NuiCol(jCol);
    string sName = GetName(oPC);
    if(GetStringRight(sName, 1) == "s") sName = sName + "'";
    else sName = sName + "'s";
    int nToken = SetWindow(oPC, jLayout, AI_MAIN_NUI, sName + " PEPS Main Menu",
                             fX, fY, 534.0f, fHeight + 12.0, FALSE, FALSE, TRUE, FALSE, TRUE, "0e_nui");
    // Save the associate to the nui for use in 0e_nui
    json jData = JsonArrayInsert(JsonArray(), JsonString(ObjectToString(oPC)));
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
        if(sLocation != "OVERRIDE:" && sLocation != "PATCH:peps" && sLocation != "PATCH:peps_mobile" && sLocation != "DEVELOPMENT:") nUsing = FALSE;
        if(nUsing) sText = TXT_MONSTER_AI_FOUND;
        else sText = TXT_MONSTER_AI_NOT_FOUND;
    }
    else sText = TXT_MONSTER_AI_NOT_FOUND;
    // Check the associate AI.
    sLocation = ResManGetAliasFor("ai_a_default", RESTYPE_NCS);
    if(sLocation != "")
    {
        nUsing = TRUE;
        string sLocation = ResManGetAliasFor("nw_ch_ac1", RESTYPE_NCS);
        if(sLocation != "OVERRIDE:" && sLocation != "PATCH:peps" && sLocation != "PATCH:peps_mobile" && sLocation != "DEVELOPMENT:") nUsing = FALSE;
        if(nUsing) sText += TXT_ASSOCIATE_AI_FOUND;
        else sText += TXT_ASSOCIATE_AI_NOT_FOUND;
    }
    else sText += TXT_ASSOCIATE_AI_NOT_FOUND;
    // Check for PRC.
    sLocation = ResManGetAliasFor("prc_ai_fam_percp", RESTYPE_NCS);
    if(sLocation != "") sText += TXT_PRC_FOUND;
    else
    {
        // Check the player AI.
        sLocation = ResManGetAliasFor("xx_pc_1_hb", RESTYPE_NCS);
        if(sLocation != "") sText += TXT_PLAYER_AI_FOUND;
        else sText += TXT_PLAYER_AI_NOT_FOUND;
    }
    NuiSetBind(oPC, nToken, "lbl_ai_info_label", JsonString(sText));
    // Row 3
    NuiSetBind(oPC, nToken, "btn_plugin_manager_event", JsonBool(TRUE));
    NuiSetBind(oPC, nToken, "btn_plugin_manager_tooltip", JsonString("  Manages external executable scripts."));
    int bActionGhost = ai_GetAIMode(oPC, AI_MODE_ACTION_GHOST);
    NuiSetBind(oPC, nToken, "btn_action_ghost", JsonBool (bActionGhost));
    NuiSetBind(oPC, nToken, "btn_action_ghost_event", JsonBool(TRUE));
    if(bActionGhost) NuiSetBind(oPC, nToken, "btn_action_ghost_tooltip", JsonString(TOOL_TXT_ACTION_GHOST_MODE_ON));
    else NuiSetBind(oPC, nToken, "btn_action_ghost_tooltip", JsonString(TOOL_TXT_ACTION_GHOST_MODE_OFF));
    NuiSetBind(oPC, nToken, "btn_close_event", JsonBool(TRUE));
    // Row 3 Label for AI RULES
    // Row 4
    NuiSetBind(oPC, nToken, "txt_max_henchman_event", JsonBool(TRUE));
    NuiSetBind(oPC, nToken, "btn_max_hench_up_event", JsonBool(TRUE));
    NuiSetBind(oPC, nToken, "btn_max_hench_down_event", JsonBool(TRUE));
    NuiSetBind(oPC, nToken, "txt_max_henchman", JsonString(IntToString(GetLocalInt(oModule, AI_RULE_MAX_HENCHMAN))));
    NuiSetBindWatch (oPC, nToken, "txt_max_henchman", TRUE);
    NuiSetBind(oPC, nToken, "txt_max_henchman_tooltip", JsonString("  Set max number of henchman allowed in your party (1-12)."));
    NuiSetBind(oPC, nToken, "txt_xp_scale_event", JsonBool(TRUE));
    NuiSetBind(oPC, nToken, "btn_xp_scale_up_event", JsonBool(TRUE));
    NuiSetBind(oPC, nToken, "btn_xp_scale_down_event", JsonBool(TRUE));
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
    if(nMonsterAI)
    {
        NuiSetBind(oPC, nToken, "txt_ai_difficulty_event", JsonBool(TRUE));
        NuiSetBind(oPC, nToken, "btn_ai_diff_up_event", JsonBool(TRUE));
        NuiSetBind(oPC, nToken, "btn_ai_diff_down_event", JsonBool(TRUE));
        NuiSetBind(oPC, nToken, "txt_ai_difficulty", JsonString(IntToString(GetLocalInt(oModule, AI_RULE_AI_DIFFICULTY))));
        NuiSetBindWatch(oPC, nToken, "txt_ai_difficulty", TRUE);
        int bMonsterBuff = GetLocalInt(oModule, AI_RULE_BUFF_MONSTERS);
        NuiSetBind(oPC, nToken, "chbx_buff_monsters_check", JsonBool(GetLocalInt(oModule, AI_RULE_BUFF_MONSTERS)));
        NuiSetBindWatch(oPC, nToken, "chbx_buff_monsters_check", TRUE);
        NuiSetBind(oPC, nToken, "chbx_buff_monsters_event", JsonBool(TRUE));
        NuiSetBind(oPC, nToken, "chbx_buff_monsters_tooltip", JsonString("  Monsters will cast all longer duration buff spells just before combat starts."));
        NuiSetBind(oPC, nToken, "chbx_full_buff_check", JsonBool(GetLocalInt(oModule, AI_RULE_FULL_BUFF_MONSTERS)));
        NuiSetBindWatch(oPC, nToken, "chbx_full_buff_check", TRUE);
        NuiSetBind(oPC, nToken, "chbx_full_buff_event", JsonBool(bMonsterBuff));
        NuiSetBind(oPC, nToken, "chbx_full_buff_tooltip", JsonString("  Monsters will cast all buff spells just before combat starts! VERY DIFFICULTY!"));
        NuiSetBind(oPC, nToken, "chbx_buff_summons_check", JsonBool(GetLocalInt(oModule, AI_RULE_PRESUMMON)));
        NuiSetBindWatch(oPC, nToken, "chbx_buff_summons_check", TRUE);
        NuiSetBind(oPC, nToken, "chbx_buff_summons_event", JsonBool(TRUE));
        NuiSetBind(oPC, nToken, "chbx_ambush_monsters_check", JsonBool(GetLocalInt(oModule, AI_RULE_AMBUSH)));
        NuiSetBindWatch(oPC, nToken, "chbx_ambush_monsters_check", TRUE);
        NuiSetBind(oPC, nToken, "chbx_ambush_monsters_event", JsonBool(TRUE));
        NuiSetBind(oPC, nToken, "chbx_companions_check", JsonBool(GetLocalInt(oModule, AI_RULE_SUMMON_COMPANIONS)));
        NuiSetBindWatch(oPC, nToken, "chbx_companions_check", TRUE);
        NuiSetBind(oPC, nToken, "chbx_companions_event", JsonBool(TRUE));
        NuiSetBind(oPC, nToken, "chbx_perm_assoc_check", JsonBool(GetLocalInt(oModule, AI_RULE_PERM_ASSOC)));
        NuiSetBindWatch(oPC, nToken, "chbx_perm_assoc_check", TRUE);
        NuiSetBind(oPC, nToken, "chbx_perm_assoc_event", JsonBool(TRUE));
        NuiSetBind(oPC, nToken, "txt_perception_distance_event", JsonBool(TRUE));
        NuiSetBind(oPC, nToken, "btn_perc_up_event", JsonBool(TRUE));
        NuiSetBind(oPC, nToken, "btn_perc_down_event", JsonBool(TRUE));
        NuiSetBind(oPC, nToken, "txt_perception_distance", JsonString(FloatToString(GetLocalFloat(oModule, AI_RULE_PERCEPTION_DISTANCE), 0, 0)));
        NuiSetBindWatch(oPC, nToken, "txt_perception_distance", TRUE);
        NuiSetBind(oPC, nToken, "txt_perception_distance_tooltip", JsonString("  Range [10 to 60 meters] from the player."));
        NuiSetBind(oPC, nToken, "btn_perc_dist_up_event", JsonBool(TRUE));
        NuiSetBind(oPC, nToken, "btn_perc_dist_down_event", JsonBool(TRUE));
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
        NuiSetBind(oPC, nToken, "chbx_corpses_stay_check", JsonBool(GetLocalInt(oModule, AI_RULE_CORPSES_STAY)));
        NuiSetBindWatch(oPC, nToken, "chbx_corpses_stay_check", TRUE);
        NuiSetBind(oPC, nToken, "chbx_corpses_stay_event", JsonBool(TRUE));
        int bWander = GetLocalInt(oModule, AI_RULE_WANDER);
        NuiSetBind(oPC, nToken, "chbx_wander_check", JsonBool(bWander));
        NuiSetBindWatch(oPC, nToken, "chbx_wander_check", TRUE);
        NuiSetBind(oPC, nToken, "chbx_wander_event", JsonBool(TRUE));
        NuiSetBind(oPC, nToken, "txt_wander_distance_event", JsonBool(bWander));
        NuiSetBind(oPC, nToken, "txt_wander_distance", JsonString(FloatToString(GetLocalFloat(oModule, AI_RULE_WANDER_DISTANCE), 0, 0)));
        NuiSetBindWatch(oPC, nToken, "txt_wander_distance", TRUE);
        NuiSetBind(oPC, nToken, "btn_wander_up_event", JsonBool(bWander));
        NuiSetBind(oPC, nToken, "btn_wander_down_event", JsonBool(bWander));
        NuiSetBind(oPC, nToken, "chbx_open_doors_check", JsonBool(GetLocalInt(oModule, AI_RULE_OPEN_DOORS)));
        NuiSetBindWatch(oPC, nToken, "chbx_open_doors_check", TRUE);
        NuiSetBind(oPC, nToken, "chbx_open_doors_event", JsonBool(TRUE));
        NuiSetBind(oPC, nToken, "txt_inc_enc_event", JsonBool(TRUE));
        NuiSetBind(oPC, nToken, "btn_encounter_up_event", JsonBool(TRUE));
        NuiSetBind(oPC, nToken, "btn_encounter_down_event", JsonBool(TRUE));
        NuiSetBind(oPC, nToken, "txt_inc_enc_tooltip", JsonString("  Spawns one extra monster per counter above 1. Adds value to counter per encounter monster spawned."));
        NuiSetBind(oPC, nToken, "txt_inc_enc", JsonString(FloatToString(GetLocalFloat(oModule, AI_INCREASE_ENC_MONSTERS), 0, 2)));
        NuiSetBindWatch(oPC, nToken, "txt_inc_enc", TRUE);
        NuiSetBind(oPC, nToken, "txt_inc_hp_event", JsonBool(TRUE));
        NuiSetBind(oPC, nToken, "btn_inc_hp_up_event", JsonBool(TRUE));
        NuiSetBind(oPC, nToken, "btn_inc_hp_down_event", JsonBool(TRUE));
        NuiSetBind(oPC, nToken, "txt_inc_hp", JsonString(IntToString(GetLocalInt(oModule, AI_INCREASE_MONSTERS_HP))));
        NuiSetBindWatch(oPC, nToken, "txt_inc_hp", TRUE);
        NuiSetBind(oPC, nToken, "all_warning_tooltip", JsonString("  ** This can break some modules! **"));
    }
}
void ai_CreateAssociateCommandMobileNUI(object oPC, object oAssociate) 
{
    // Set window to not save until it has been created.
    SetLocalInt (oPC, AI_NO_NUI_SAVE, TRUE);
    DelayCommand (2.0, DeleteLocalInt (oPC, AI_NO_NUI_SAVE));
    // ************************************************************************* Width / Height
    int bRight, bLeft;
    int bIsPC = ai_GetIsCharacter(oAssociate);
    int bUsingPCAI = ResManGetAliasFor("xx_pc_1_hb", RESTYPE_NCS) != "";
    int bUsingHenchAI = ResManGetAliasFor("nw_ch_ac1", RESTYPE_NCS) != "";
    float fHeight = 73.0;
    // Row 1 ******************************************************************* 500 / 81
    json jRow = JsonArray();
    json jCol = JsonArray();
    // If all the AI buttons are blocked then don't load the menu.
    if(GetLocalInt(GetModule(), sDMAIAccessVarname) != 203423743)
    {
        if(bIsPC)
        {
            bLeft = ai_GetIsServer();
            if(bUsingPCAI || !bLeft)
            {
                if(bUsingPCAI)
                {
                    jRow = CreateButton(jRow, BTN_TXT_AI_MENU, "btn_ai_menu", 170.0, 30.0, -1.0, "btn_ai_menu_tooltip");
                }
                if(!bLeft)
                {
                    jRow = CreateButton(jRow, BTN_TXT_MAIN_MENU, "btn_main_menu", 170.0, 30.0, -1.0, "btn_main_menu_tooltip");
                }
            }
        }
        else
        {
            if(bUsingHenchAI)
            {
                jRow = CreateButton(jRow, BTN_TXT_AI_MENU, "btn_ai_menu", 170.0, 30.0, -1.0, "btn_ai_menu_tooltip");
            }
            jRow = CreateButtonSelect(jRow, BTN_TXT_ASSOCIATE_WIDGET, "btn_widget_onoff", 170.0, 30.0, -1.0, "btn_widget_onoff_tooltip");
        }
    }
    jRow = CreateButton(jRow, BTN_TXT_CLOSE, "btn_close", 170.0f, 30.0f);
    jCol = JsonArrayInsert(jCol, NuiRow(jRow));
    fHeight += 38.0;
    // Row 2 ******************************************************************* 500 / 119
    bRight = !ai_GetDMWAccessButton(BTN_ASSOC_WIDGETS_OFF);
    if(bRight)
    {
        jRow = CreateButtonSelect(JsonArray(), BTN_TXT_LOCK_WIDGET, "btn_widget_lock", 256.0, 30.0, -1.0, "btn_widget_lock_tooltip");
        jRow = CreateButtonSelect(jRow, BTN_TXT_VERITCAL_WIDGET, "btn_vertical_widget", 256.0, 30.0, -1.0, "btn_vertical_widget_tooltip");
        jCol = JsonArrayInsert(jCol, NuiRow(jRow));
        fHeight += 38.0;
    }
    // Row 3 ******************************************************************* 500 / 129
    jRow = CreateButton(JsonArray(), BTN_TXT_COPY_SETTINGS, "btn_copy_settings", 256.0, 30.0, -1.0, "btn_copy_settings_tooltip");
    if(bIsPC) jRow = CreateButton(jRow,BTN_TXT_PC_MENU, "btn_mobile_nui", 256.0f, 30.0f, -1.0, "btn_mobile_nui_tooltip");
    else jRow = CreateButton(jRow, "", "btn_portrait_settings", 256.0, 30.0, -1.0, "btn_portrait_settings_tooltip");
    jCol = JsonArrayInsert(jCol, NuiRow(jRow));
    fHeight += 38.0;
    // Row 4 ******************************************************************* 500 / 129
    if(bIsPC)
    {
        jRow = JsonArray();
        if(bUsingHenchAI)
        {
            jRow = CreateButtonSelect(JsonArray(), BTN_TXT_ALL_ASSOCIATE_WIDGETS, "btn_toggle_assoc_widget", 230.0f, 30.0f, -1.0,"btn_toggle_assoc_widget_tooltip");
            jRow = CreateCheckBox(jRow, "", "chbx_toggle_assoc_widget", 25.0, 30.0);
        }
        jRow = JsonArrayInsert(jRow, NuiSpacer());
        jCol = JsonArrayInsert(jCol, NuiRow(jRow));
        fHeight += 38.0;
    }
    // Row 5 ******************************************************************* 500 / 157
    bRight = !ai_GetDMWAccessButton(BTN_CMD_ACTION);
    bLeft = !ai_GetDMWAccessButton(BTN_CMD_GUARD);
    if(bRight || bLeft)
    {
        jRow = JsonArray();
        if(bRight)
        {
            if(bIsPC) jRow = CreateButton(JsonArray(), BTN_TXT_CMD_ALL_ACTION, "btn_cmd_action", 230.0, 30.0, -1.0, "btn_cmd_action_tooltip");
            else jRow = CreateButton(JsonArray(), BTN_TXT_CMD_ACTION, "btn_cmd_action", 230.0, 30.0, -1.0, "btn_cmd_action_tooltip");
            jRow = CreateCheckBox(jRow, "", "chbx_cmd_action", 25.0, 30.0);
        }
        jRow = JsonArrayInsert(jRow, NuiSpacer());
        if(bLeft)
        {
            if(bIsPC) jRow = CreateButtonSelect(jRow, BTN_TXT_CMD_ALL_GUARD, "btn_cmd_guard", 230.0, 30.0, -1.0, "btn_cmd_guard_tooltip");
            else jRow = CreateButtonSelect(jRow, BTN_TXT_CMD_GUARD, "btn_cmd_guard", 230.0, 30.0, -1.0, "btn_cmd_guard_tooltip");
            jRow = CreateCheckBox(jRow, "", "chbx_cmd_guard", 25.0, 30.0);
        }
        jCol = JsonArrayInsert(jCol, NuiRow(jRow));
        fHeight += 38.0;
    }
    // Row 6 ******************************************************************* 500 / 195
    bRight = !ai_GetDMWAccessButton(BTN_CMD_HOLD);
    bLeft = !ai_GetDMWAccessButton(BTN_CMD_ATTACK);
    if(bRight || bLeft)
    {
        jRow = JsonArray();
        if(bRight)
        {
            if(bIsPC) jRow = CreateButtonSelect(JsonArray(), BTN_TXT_CMD_ALL_HOLD, "btn_cmd_hold", 230.0, 30.0, -1.0, "btn_cmd_hold_tooltip");
            else jRow = CreateButtonSelect(JsonArray(), BTN_TXT_CMD_HOLD, "btn_cmd_hold", 230.0, 30.0, -1.0, "btn_cmd_hold_tooltip");
            jRow = CreateCheckBox(jRow, "", "chbx_cmd_hold", 25.0, 30.0);
        }
        jRow = JsonArrayInsert(jRow, NuiSpacer());
        if(bLeft)
        {
            if(bIsPC) jRow = CreateButtonSelect(jRow, BTN_TXT_CMD_ALL_ATTACK, "btn_cmd_attack", 230.0, 30.0, -1.0, "btn_cmd_attack_tooltip");
            else jRow = CreateButtonSelect(jRow, BTN_TXT_CMD_ATTACK, "btn_cmd_attack", 230.0, 30.0, -1.0, "btn_cmd_attack_tooltip");
            jRow = CreateCheckBox(jRow, "", "chbx_cmd_attack", 25.0, 30.0);
        }
        jCol = JsonArrayInsert(jCol, NuiRow(jRow));
        fHeight += 38.0;
    }
    // Row 7 ******************************************************************* 500 / 233 
    bRight = !ai_GetDMWAccessButton(BTN_CMD_FOLLOW);
    bLeft = !ai_GetDMAIAccessButton(BTN_AI_FOLLOW_TARGET);
    if(bRight || bLeft)
    {
        jRow = JsonArray();
        if(bRight)
        {
            jRow = CreateButtonImage(JsonArray(), "nui_cnt_up", "btn_follow_up", 30.0, 30.0, -1.0, "btn_cmd_follow_tooltip");
            jRow = CreateButtonImage(jRow, "nui_cnt_down", "btn_follow_down", 30.0, 30.0, -1.0, "btn_cmd_follow_tooltip");
            if(bIsPC) jRow = CreateButtonSelect(jRow, BTN_TXT_CMD_ALL_FOLLOW, "btn_cmd_follow", 162.0, 30.0, -1.0, "btn_cmd_follow_tooltip");
            else jRow = CreateButtonSelect(jRow, "", "btn_cmd_follow", 162.0, 30.0, -1.0, "btn_cmd_follow_tooltip");
            jRow = CreateCheckBox(jRow, "", "chbx_cmd_follow", 25.0, 30.0);
        }    
        jRow = JsonArrayInsert(jRow, NuiSpacer());
        if(bLeft)
        {
            jRow = CreateButtonImage(jRow, "nui_cnt_up", "btn_follow_up", 30.0, 30.0, -1.0, "btn_follow_target_tooltip");
            jRow = CreateButtonImage(jRow, "nui_cnt_down", "btn_follow_down", 30.0, 30.0, -1.0, "btn_follow_target_tooltip");
            jRow = CreateButton(jRow, "", "btn_follow_target", 162.0, 30.0, -1.0, "btn_follow_target_tooltip");
            jRow = CreateCheckBox(jRow, "", "chbx_follow_target", 25.0, 30.0);
        }
        jCol = JsonArrayInsert(jCol, NuiRow(jRow));
        fHeight += 38.0;
    }
    // Row 8 ******************************************************************* 500 / 271
    if(bIsPC)
    {
        bRight = !ai_GetDMWAccessButton(BTN_CMD_SEARCH);
        bLeft = !ai_GetDMWAccessButton(BTN_CMD_STEALTH);
        if(bRight || bLeft)
        {
            jRow = JsonArray();
            if(bRight)
            {
                jRow = CreateButtonSelect(JsonArray(), BTN_TXT_CMD_ALL_SEARCH, "btn_cmd_search", 230.0, 30.0, -1.0, "btn_cmd_search_tooltip");
                jRow = CreateCheckBox(jRow, "", "chbx_cmd_search", 25.0, 30.0);
            }
            jRow = JsonArrayInsert(jRow, NuiSpacer());
            if(bLeft)
            {
                jRow = CreateButtonSelect(jRow, BTN_TXT_CMD_ALL_STEALTH, "btn_cmd_stealth", 230.0, 30.0, -1.0, "btn_cmd_stealth_tooltip");
                jRow = CreateCheckBox(jRow, "", "chbx_cmd_stealth", 25.0, 30.0);
            }
        }
        jCol = JsonArrayInsert(jCol, NuiRow(jRow));
        fHeight = fHeight + 38.0;
    }
    // Row 9 ******************************************************************* 500 / 309
    bRight = !ai_GetDMWAccessButton(BTN_CMD_AI_SCRIPT);
    bLeft = !ai_GetDMWAccessButton(BTN_CMD_PLACE_TRAP);
    if(bRight || bLeft)
    {
        jRow = JsonArray();
        if(bRight)
        {
            jRow = CreateButton(JsonArray(), "", "btn_cmd_ai_script", 230.0, 30.0, -1.0, "btn_cmd_ai_script_tooltip");
            jRow = CreateCheckBox(jRow, "", "chbx_cmd_ai_script", 25.0, 30.0);
        }
        jRow = JsonArrayInsert(jRow, NuiSpacer());
        if(bLeft)
        {
            jRow = CreateButton(jRow, BTN_TXT_PLACE_TRAP, "btn_cmd_place_trap", 230.0, 30.0, -1.0, "btn_cmd_place_trap_tooltip");
            jRow = CreateCheckBox(jRow, "", "chbx_cmd_place_trap", 25.0, 30.0);
        }
    }
    jCol = JsonArrayInsert(jCol, NuiRow(jRow));
    fHeight = fHeight + 38.0;
    // Row 10 ******************************************************************* 500 / 347
    int bMemorize = ai_GetIsSpellCaster(oAssociate);
    int bSpellbook = ai_GetIsSpellBookRestrictedCaster(oAssociate);
    bRight = !ai_GetDMWAccessButton(BTN_CMD_SPELL_WIDGET);
    bLeft = !ai_GetDMWAccessButton(BTN_DM_CMD_MEMORIZE);
    if(bRight || bLeft)
    {
        jRow = JsonArray();
        if(bRight)
        {
            jRow = CreateButton(JsonArray(), BTN_TXT_QUICK_WIDGET, "btn_quick_widget", 230.0, 30.0, -1.0, "btn_quick_widget_tooltip");
            jRow = CreateCheckBox(jRow, "", "chbx_quick_widget", 25.0, 30.0);
        }
        jRow = JsonArrayInsert(jRow, NuiSpacer());
        if(bLeft)
        {
            if(bMemorize == 2 && bSpellbook && !ai_GetIsCharacter(oAssociate))
            {
                jRow = CreateButton(jRow, "Set Memorized", "btn_spell_memorize", 114.0, 30.0, -1.0, "btn_spell_memorize_tooltip");
                jRow = CreateButton(jRow, "Set Known", "btn_spell_known", 110.0, 30.0, -1.0, "btn_spell_known_tooltip");
                jRow = CreateLabel(jRow, "", "blank_label_1", 25.0, 30.0);
            }
            else if(bMemorize == 2) // Memorizes their spells.
            {
                jRow = CreateButton(jRow, BTN_TXT_MEMORIZE_SPELLS, "btn_spell_memorize", 230.0, 30.0, -1.0, "btn_spell_memorize_tooltip");
                jRow = CreateLabel(jRow, "", "blank_label_1", 25.0, 30.0);
            }
            else if(bSpellbook && !ai_GetIsCharacter(oAssociate))
            {
                jRow = CreateButton(jRow, BTN_TXT_KNOWN_SPELLS, "btn_spell_known", 230.0, 30.0, -1.0, "btn_spell_known_tooltip");
                jRow = CreateLabel(jRow, "", "blank_label_1", 25.0, 30.0);
            }
        }
        jCol = JsonArrayInsert(jCol, NuiRow(jRow));
        fHeight = fHeight + 38.0;
    }
    // Row 11 ******************************************************************* 500 / 385
    bRight = !ai_GetDMWAccessButton(BTN_BUFF_SHORT);
    bLeft = !ai_GetDMWAccessButton(BTN_BUFF_LONG);
    if(bRight || bLeft)
    {
        jRow = JsonArray();
        if(bRight)
        {
            jRow = CreateButtonImage(JsonArray(), "nui_cnt_up", "btn_buff_short_up", 30.0, 30.0, -1.0, "btn_buff_short_tooltip");
            jRow = CreateButtonImage(jRow, "nui_cnt_down", "btn_buff_short_down", 30.0, 30.0, -1.0, "btn_buff_short_tooltip");
            jRow = CreateButton(jRow, "", "btn_buff_short", 162.0, 30.0, -1.0, "btn_buff_short_tooltip");
            jRow = CreateCheckBox(jRow, "", "chbx_buff_short", 25.0, 30.0);
        }
        jRow = JsonArrayInsert(jRow, NuiSpacer());
        if(bLeft)
        {
            jRow = CreateButtonImage(jRow, "nui_cnt_up", "btn_buff_long_up", 30.0, 30.0, -1.0, "btn_buff_long_tooltip");
            jRow = CreateButtonImage(jRow, "nui_cnt_down", "btn_buff_long_down", 30.0, 30.0, -1.0, "btn_buff_long_tooltip");
            jRow = CreateButton(jRow, "", "btn_buff_long", 162.0, 30.0, -1.0, "btn_buff_long_tooltip");
            jRow = CreateCheckBox(jRow, "", "chbx_buff_long", 25.0, 30.0);
        }    
        jCol = JsonArrayInsert(jCol, NuiRow(jRow));
        fHeight = fHeight + 38.0;
    }
    // Row 12 ****************************************************************** 500 / 423
    bRight = !ai_GetDMWAccessButton(BTN_BUFF_ALL);
    bLeft = !ai_GetDMWAccessButton(BTN_BUFF_REST);
    if(bRight || bLeft)
    {
        jRow = JsonArray();
        if(bRight)
        {
            jRow = CreateButtonImage(JsonArray(), "nui_cnt_up", "btn_buff_all_up", 30.0, 30.0, -1.0, "btn_buff_all_tooltip");
            jRow = CreateButtonImage(jRow, "nui_cnt_down", "btn_buff_all_down", 30.0, 30.0, -1.0, "btn_buff_all_tooltip");
            jRow = CreateButton(jRow, "", "btn_buff_all", 162.0, 30.0, -1.0, "btn_buff_all_tooltip");
            jRow = CreateCheckBox(jRow, "", "chbx_buff_all", 25.0, 30.0);
        }
        jRow = JsonArrayInsert(jRow, NuiSpacer());
        if(bLeft)
        {
            jRow = CreateButtonSelect(jRow, BTN_TXT_BUFF_AFTER_RESTING, "btn_buff_rest", 230.0, 30.0, -1.0, "btn_buff_rest_tooltip");
            jRow = CreateCheckBox(jRow, "", "chbx_buff_rest", 25.0, 30.0);
        }
        jCol = JsonArrayInsert(jCol, NuiRow(jRow));
        fHeight = fHeight + 38.0;
    }
    // Row 13 ******************************************************************* 500 / 461
    bRight = !ai_GetDMWAccessButton(BTN_CMD_JUMP_TO);
    bLeft = !ai_GetDMWAccessButton(BTN_CMD_GHOST_MODE);
    if(bRight || bLeft)
    {
        jRow = JsonArray();
        if(bRight)
        {
            jRow = CreateButton(JsonArray(), "", "btn_jump_to", 230.0, 30.0, -1.0, "btn_jump_to_tooltip");
            jRow = CreateCheckBox(jRow, "", "chbx_jump_to", 25.0, 30.0);
        }
        jRow = JsonArrayInsert(jRow, NuiSpacer());
        if(bLeft)
        {
            jRow = CreateButtonSelect(jRow, BTN_TXT_GHOST_MODE, "btn_ghost_mode", 230.0, 30.0, -1.0, "btn_ghost_mode_tooltip");
            jRow = CreateCheckBox(jRow, "", "chbx_ghost_mode", 25.0, 30.0);
        }
        jCol = JsonArrayInsert(jCol, NuiRow(jRow));
        fHeight = fHeight + 38.0;
    }
    // Row 14 ****************************************************************** 500 / 499
    bRight = !ai_GetDMWAccessButton(BTN_CMD_CAMERA);
    bLeft = !ai_GetDMWAccessButton(BTN_CMD_INVENTORY);
    if(bRight || bLeft)
    {
        jRow = JsonArray();
        if(bRight)
        {
            jRow = CreateButton(JsonArray(), BTN_TXT_CAMERA_FOCUS, "btn_camera", 230.0, 30.0, -1.0, "btn_camera_tooltip");
            jRow = CreateCheckBox(jRow, "", "chbx_camera", 25.0, 30.0);
        }
        jRow = JsonArrayInsert(jRow, NuiSpacer());
        if(bLeft)
        {
            jRow = CreateButton(jRow, BTN_TXT_OPEN_INVENTORY, "btn_inventory", 230.0, 30.0, -1.0, "btn_inventory_tooltip");
            jRow = CreateCheckBox(jRow, "", "chbx_inventory", 25.0, 30.0);
        }
        jCol = JsonArrayInsert(jCol, NuiRow(jRow));
        fHeight = fHeight + 38.0;
    }
    // Row 15 ****************************************************************** 500 / 527
    int bFamiliar = GetHasFeat(FEAT_SUMMON_FAMILIAR, oAssociate, TRUE);
    if(!ai_GetDMWAccessButton(BTN_CMD_FAMILIAR) && bFamiliar)
    {
        jRow = CreateLabel(JsonArray(), "", "lbl_familiar_type", 225.0, 20.0);
        jRow = JsonArrayInsert(jRow, NuiSpacer());
        jRow = CreateLabel(jRow, "", "lbl_familiar_name", 225.0, 20.0);
        jCol = JsonArrayInsert(jCol, NuiRow(jRow));
        fHeight = fHeight + 28.0;
    // Row 16 ******************************************************************* 500 / 565
        jRow = CreateCombo(JsonArray(), ai_CreateCompanionJson(oPC, "hen_familiar"), "cmb_familiar", 200.0, 35.0);
        jRow = CreateCheckBox(jRow, "", "chbx_familiar", 25.0, 35.0);
        jRow = CreateTextEditBox(jRow, "txtbox", "txt_familiar_name", 50, FALSE, 240.0, 35.0);
        jRow = CreateButton(jRow, "", "btn_familiar_name", 55.0, 35.0);
        jCol = JsonArrayInsert(jCol, NuiRow(jRow));
        fHeight = fHeight + 28.0;
    }
    // Row 17 ****************************************************************** 500 / 593
    int bCompanion = GetHasFeat(FEAT_ANIMAL_COMPANION, oAssociate, TRUE);
    if(!ai_GetDMWAccessButton(BTN_CMD_COMPANION) && bCompanion)
    {
        jRow = CreateLabel(JsonArray(), "", "lbl_companion_type", 225.0, 25.0);
        jRow = JsonArrayInsert(jRow, NuiSpacer());
        jRow = CreateLabel(jRow, "", "lbl_companion_name", 225.0, 25.0);
        jCol = JsonArrayInsert(jCol, NuiRow(jRow));
        fHeight = fHeight + 28.0;
        // Row 18 ****************************************************************** 500 / 631
        jRow = CreateCombo(JsonArray(), ai_CreateCompanionJson(oPC, "hen_companion"), "cmb_companion", 200.0, 35.0);
        jRow = CreateCheckBox(jRow, "", "chbx_companion", 25.0, 35.0);
        jRow = CreateTextEditBox(jRow, "txtbox", "txt_companion_name", 50, FALSE, 228.0, 35.0);
        jRow = CreateButton(jRow, "", "btn_companion_name", 55.0, 35.0);
        jCol = JsonArrayInsert(jCol, NuiRow(jRow));
        fHeight = fHeight + 38.0;
    }
    // Row 19+ ****************************************************************** 500 / ---
    string sAssociateType = ai_GetAssociateType(oPC, oAssociate);
    json jPCPlugins;
    if(bIsPC)
    {
        jPCPlugins = ai_UpdatePluginsForPC(oPC);
        // Set the plugins the player can use.
        int nIndex;
        string sButton, sName;
        json jPlugin = JsonArrayGet(jPCPlugins, nIndex);
        while(JsonGetType(jPlugin) != JSON_TYPE_NULL)
        {
            sButton = IntToString(nIndex);
            sName = JsonGetString(JsonArrayGet(jPlugin, 2));
            jRow = CreateButton(JsonArray(), sName, "btn_plugin_" + sButton, 230.0f, 30.0f, -1.0, "btn_plugin_" + sButton + "_tooltip");
            jRow = CreateCheckBox(jRow, "", "chbx_plugin_" + sButton, 25.0, 30.0, "chbx_plugin_tooltip");
            jRow = JsonArrayInsert(jRow, NuiSpacer());
            jPlugin = JsonArrayGet(jPCPlugins, ++nIndex);
            if(JsonGetType(jPlugin) != JSON_TYPE_NULL)
            {
                sButton = IntToString(nIndex);
                sName = JsonGetString(JsonArrayGet(jPlugin, 2));
                jRow = CreateButton(jRow, sName, "btn_plugin_" + sButton, 230.0f, 30.0f, -1.0, "btn_plugin_" + sButton + "_tooltip");
                jRow = CreateCheckBox(jRow, "", "chbx_plugin_" + sButton, 25.0, 30.0, "chbx_plugin_tooltip");
                // Add row to the column.
                jCol = JsonArrayInsert(jCol, NuiRow(jRow));
                fHeight += 38.0;
            }
            else
            {
                // Add row to the column.
                jCol = JsonArrayInsert(jCol, NuiRow(jRow));
                fHeight += 38.0;
                break;
            }
            jPlugin = JsonArrayGet(jPCPlugins, ++nIndex);
        }
    }
    // Row 20+ ****************************************************************** 500 / ---
    jRow = JsonArrayInsert(JsonArray(), NuiSpacer());
    jRow = CreateLabel(jRow, "", "lbl_info_1", 475.0, 30.0, NUI_HALIGN_CENTER);
    jRow = JsonArrayInsert(jRow, NuiSpacer());
    jCol = JsonArrayInsert(jCol, NuiRow(jRow));
    fHeight = fHeight + 38.0;
    // Get the window location to restore it from the database.
    float fX, fY;
    json jLocations = ai_GetAssociateDbJson(oPC, sAssociateType, "locations");
    jLocations = JsonObjectGet(jLocations, sAssociateType + AI_COMMAND_NUI);
    if(JsonGetType(jLocations) == JSON_TYPE_NULL) { fX = -1.0; fY = -1.0; }
    else
    {
        fX = JsonGetFloat(JsonObjectGet(jLocations, "x"));
        fY = JsonGetFloat(JsonObjectGet(jLocations, "y"));
    }
    // Set the Layout of the window.
    json jLayout = NuiCol(jCol);
    string sPluralName, sName = ai_StripColorCodes(GetName(oAssociate));
    if(GetStringRight(sName, 1) == "s") sPluralName = sName + "'";
    else sPluralName = sName + "'s";
    int nToken = SetWindow(oPC, jLayout, sAssociateType + AI_COMMAND_NUI, sPluralName + " Command Menu",
                           fX, fY, 560.0, fHeight + 12.0, FALSE, FALSE, TRUE, FALSE, TRUE, "0e_nui");
    // Get which buttons are activated.
    int bAIWidgetLock = ai_GetWidgetButton(oPC, BTN_WIDGET_LOCK, oAssociate, sAssociateType);
    int bCmdAction = ai_GetWidgetButton(oPC, BTN_CMD_ACTION, oAssociate, sAssociateType);
    int bCmdGuard = ai_GetWidgetButton(oPC, BTN_CMD_GUARD, oAssociate, sAssociateType);
    int bCmdHold = ai_GetWidgetButton(oPC, BTN_CMD_HOLD, oAssociate, sAssociateType);
    int bCmdSearch = ai_GetWidgetButton(oPC, BTN_CMD_SEARCH, oAssociate, sAssociateType);
    int bCmdStealth = ai_GetWidgetButton(oPC, BTN_CMD_STEALTH, oAssociate, sAssociateType);
    int bCmdAttack = ai_GetWidgetButton(oPC, BTN_CMD_ATTACK, oAssociate, sAssociateType);
    int bCmdFollow = ai_GetWidgetButton(oPC, BTN_CMD_FOLLOW, oAssociate, sAssociateType);
    int bFollowTarget = ai_GetAIButton(oPC, BTN_AI_FOLLOW_TARGET, oAssociate, sAssociateType);
    int bCmdAIScript = ai_GetWidgetButton(oPC, BTN_CMD_AI_SCRIPT, oAssociate, sAssociateType);
    int bCmdPlacetrap = ai_GetWidgetButton(oPC, BTN_CMD_PLACE_TRAP, oAssociate, sAssociateType);
    int bSpellWidget = ai_GetWidgetButton(oPC, BTN_CMD_SPELL_WIDGET, oAssociate, sAssociateType);
    int bBuffRest = ai_GetWidgetButton(oPC, BTN_BUFF_REST, oAssociate, sAssociateType);
    int bBuffShort = ai_GetWidgetButton(oPC, BTN_BUFF_SHORT, oAssociate, sAssociateType);
    int bBuffLong = ai_GetWidgetButton(oPC, BTN_BUFF_LONG, oAssociate, sAssociateType);
    int bBuffAll = ai_GetWidgetButton(oPC, BTN_BUFF_ALL, oAssociate, sAssociateType);
    int bJumpTo = ai_GetWidgetButton(oPC, BTN_CMD_JUMP_TO, oAssociate, sAssociateType);
    int bGhostMode = ai_GetWidgetButton(oPC, BTN_CMD_GHOST_MODE, oAssociate, sAssociateType);
    int bCamera = ai_GetWidgetButton(oPC, BTN_CMD_CAMERA, oAssociate, sAssociateType);
    int bInventory = ai_GetWidgetButton(oPC, BTN_CMD_INVENTORY, oAssociate, sAssociateType);
    int bBtnFamiliar = ai_GetWidgetButton(oPC, BTN_CMD_FAMILIAR, oAssociate, sAssociateType);
    int bBtnCompanion = ai_GetWidgetButton(oPC, BTN_CMD_COMPANION, oAssociate, sAssociateType);
    int bAssocWidgetOff = ai_GetWidgetButton(oPC, BTN_ASSOC_WIDGETS_OFF, oAssociate, sAssociateType);
    int bVertical = ai_GetWidgetButton(oPC, BTN_WIDGET_VERTICAL, oAssociate, sAssociateType);
    // Save the associate to the nui for use in 0e_nui
    json jData = JsonArrayInsert(JsonArray(), JsonString(ObjectToString(oAssociate)));
    NuiSetUserData(oPC, nToken, jData);
    // Set event watches for save window location.
    NuiSetBindWatch(oPC, nToken, "window_geometry", TRUE);
    // Set all binds, events, and watches.
    string sText;  
    float fRange = GetLocalFloat(oAssociate, AI_FOLLOW_RANGE) +
                   StringToFloat(Get2DAString("appearance", "PREFATCKDIST", GetAppearanceType(oAssociate)));
    string sRange = FloatToString(fRange, 0, 0);
    // Row 1 
    // If all the AI buttons are blocked then don't load the menu.
    if(GetLocalInt(GetModule(), sDMAIAccessVarname) != 203423743)
    {
        if(bIsPC)
        {
            if(bUsingPCAI)
            {
                NuiSetBind(oPC, nToken, "btn_ai_menu_event", JsonBool (TRUE));
                NuiSetBind(oPC, nToken, "btn_ai_menu_tooltip", JsonString(TOOL_TXT_AI_MENU));
            }
            if(!ai_GetIsServer())
            {
                NuiSetBind(oPC, nToken, "btn_main_menu_event", JsonBool(TRUE));
                NuiSetBind(oPC, nToken, "btn_main_menu_tooltip", JsonString(TOOL_TXT_MAIN_MENU));
            }
        }
        else 
        {
            if(bUsingHenchAI) 
            {
                NuiSetBind(oPC, nToken, "btn_ai_menu_event", JsonBool (TRUE));
                NuiSetBind(oPC, nToken, "btn_ai_menu_tooltip", JsonString(TOOL_TXT_AI_MENU));
            }
            if(ai_GetWidgetButton(oPC, BTN_WIDGET_OFF, oAssociate, sAssociateType))
            {
                NuiSetBind(oPC, nToken, "btn_widget_onoff", JsonBool(FALSE));
                NuiSetBind(oPC, nToken, "btn_widget_onoff_tooltip", JsonString(TOOL_TXT_ASSOCIATE_WIDGETS_OFF));
            }
            else
            {
                NuiSetBind(oPC, nToken, "btn_widget_onoff", JsonBool(TRUE));
                NuiSetBind(oPC, nToken, "btn_widget_onoff_tooltip", JsonString(TOOL_TXT_ASSOCIATE_WIDGETS_ON));
            }
            NuiSetBind(oPC, nToken, "btn_widget_onoff_event", JsonBool(TRUE));
        }
        NuiSetBind(oPC, nToken, "btn_close_event", JsonBool(TRUE));
    }
    // Row 2 
    NuiSetBind(oPC, nToken, "btn_widget_lock_event", JsonBool(TRUE));
    NuiSetBind(oPC, nToken, "btn_widget_lock", JsonBool(bAIWidgetLock));
    if(bAIWidgetLock) NuiSetBind(oPC, nToken, "btn_widget_lock_tooltip", JsonString(TOOL_TXT_LOCK_WIDGET_OFF));
    else NuiSetBind(oPC, nToken, "btn_widget_lock_tooltip", JsonString(TOOL_TXT_LOCK_WIDGET_ON));
    NuiSetBind(oPC, nToken, "btn_vertical_widget_event", JsonBool(TRUE));
    NuiSetBind(oPC, nToken, "btn_vertical_widget", JsonBool(bVertical));
    if(bVertical) NuiSetBind(oPC, nToken, "btn_vertical_widget_tooltip", JsonString(TOOL_TXT_VERTICAL_WIDGET_ON));
    else NuiSetBind(oPC, nToken, "btn_vertical_widget_tooltip", JsonString(TOOL_TXT_VERTICAL_WIDGET_OFF));
    // Row 3 
    NuiSetBind(oPC, nToken, "btn_copy_settings_event", JsonBool (TRUE));
    NuiSetBind(oPC, nToken, "btn_copy_settings_tooltip", JsonString(TOOL_TXT_COPY_SETTINGS));
    NuiSetBind(oPC, nToken, "btn_portrait_settings_event", JsonBool(TRUE));
    int nPortrait = GetLocalInt(oAssociate, PORTRAIT_SETTING);
    if(nPortrait == PORTRAIT_SETTING_WIDGET) 
    {
        NuiSetBind(oPC, nToken, "btn_portrait_settings_label", JsonString(BTN_TXT_PORTRAIT_WIDGET));
        NuiSetBind(oPC, nToken, "btn_portrait_settings_tooltip", JsonString(TOOL_TXT_PORTRAIT_WIDGET));
    }
    if(nPortrait == PORTRAIT_SETTING_COMMAND) 
    {
        NuiSetBind(oPC, nToken, "btn_portrait_settings_label", JsonString(BTN_TXT_PORTRAIT_COMMAND));
        NuiSetBind(oPC, nToken, "btn_portrait_settings_tooltip", JsonString(TOOL_TXT_PORTRAIT_COMMAND));
    }
    if(nPortrait == PORTRAIT_SETTING_AI) 
    {
        NuiSetBind(oPC, nToken, "btn_portrait_settings_label", JsonString(BTN_TXT_PORTRAIT_AI));
        NuiSetBind(oPC, nToken, "btn_portrait_settings_tooltip", JsonString(TOOL_TXT_PORTRAIT_AI));
    }
    if(nPortrait == PORTRAIT_SETTING_ACTION) 
    {
        NuiSetBind(oPC, nToken, "btn_portrait_settings_label", JsonString(BTN_TXT_PORTRAIT_ACTION));
        NuiSetBind(oPC, nToken, "btn_portrait_settings_tooltip", JsonString(TOOL_TXT_PORTRAIT_ACTION));
    }
    if(nPortrait == PORTRAIT_SETTING_CAMERA)
    {
        NuiSetBind(oPC, nToken, "btn_portrait_settings_label", JsonString(BTN_TXT_PORTRAIT_CAMERA));
        NuiSetBind(oPC, nToken, "btn_portrait_settings_tooltip", JsonString(TOOL_TXT_PORTRAIT_CAMERA));
    }
    // Row 4
    if(bIsPC && bUsingHenchAI) 
    {
        NuiSetBind(oPC, nToken, "btn_toggle_assoc_widget_event", JsonBool(TRUE));
        if(ai_GetWidgetButton(oPC, BTN_WIDGET_OFF, oPC, "pc")) 
        {
            NuiSetBind(oPC, nToken, "btn_toggle_assoc_widget", JsonBool(FALSE));
            NuiSetBind(oPC, nToken, "btn_toggle_assoc_widget_tooltip", JsonString(TOOL_TXT_ALL_ASSOCIATE_WIDGETS_OFF));
        }
        else 
        {
            NuiSetBind(oPC, nToken, "btn_toggle_assoc_widget", JsonBool(TRUE));
            NuiSetBind(oPC, nToken, "btn_toggle_assoc_widget_tooltip", JsonString(TOOL_TXT_ALL_ASSOCIATE_WIDGETS_ON));
        }
        NuiSetBind(oPC, nToken, "chbx_toggle_assoc_widget_check", JsonBool (bAssocWidgetOff));
        NuiSetBindWatch (oPC, nToken, "chbx_toggle_assoc_widget_check", TRUE);
        NuiSetBind(oPC, nToken, "chbx_toggle_assoc_widget_event", JsonBool(TRUE));
    }
    NuiSetBind(oPC, nToken, "btn_mobile_nui_event", JsonBool(TRUE));
    NuiSetBind(oPC, nToken, "btn_mobile_nui_tooltip", JsonString(TOOL_TXT_PC_MENU));
    // Row 5 
    NuiSetBind(oPC, nToken, "chbx_cmd_action_check", JsonBool (bCmdAction));
    NuiSetBindWatch(oPC, nToken, "chbx_cmd_action_check", TRUE);
    NuiSetBind(oPC, nToken, "chbx_cmd_action_event", JsonBool(TRUE));
    NuiSetBind(oPC, nToken, "btn_cmd_action_event", JsonBool (TRUE));
    if(bIsPC) NuiSetBind(oPC, nToken, "btn_cmd_action_tooltip", JsonString(TOOL_TXT_CMD_ALL_ACTION));
    else NuiSetBind(oPC, nToken, "btn_cmd_action_tooltip", JsonString(TOOL_TXT_CMD_ACTION));
    NuiSetBind(oPC, nToken, "chbx_cmd_guard_check", JsonBool (bCmdGuard));
    NuiSetBindWatch (oPC, nToken, "chbx_cmd_guard_check", TRUE);
    NuiSetBind(oPC, nToken, "chbx_cmd_guard_event", JsonBool(TRUE));
    if(ai_GetAIMode(oAssociate, AI_MODE_DEFEND_MASTER)) 
    {
        NuiSetBind(oPC, nToken, "btn_cmd_guard", JsonBool (TRUE));        
    }
    else NuiSetBind(oPC, nToken, "btn_cmd_guard", JsonBool (FALSE));        
    NuiSetBind(oPC, nToken, "btn_cmd_guard_event", JsonBool (TRUE));
    if(bIsPC) NuiSetBind(oPC, nToken, "btn_cmd_guard_tooltip", JsonString(TOOL_TXT_CMD_ALL_GUARD));
    else NuiSetBind(oPC, nToken, "btn_cmd_guard_tooltip", JsonString(TOOL_TXT_CMD_GUARD));
    // Row 6
    NuiSetBind(oPC, nToken, "chbx_cmd_hold_check", JsonBool (bCmdHold));
    NuiSetBindWatch (oPC, nToken, "chbx_cmd_hold_check", TRUE);
    NuiSetBind(oPC, nToken, "chbx_cmd_hold_event", JsonBool(TRUE));
    if(ai_GetAIMode(oAssociate, AI_MODE_STAND_GROUND)) 
    {
        NuiSetBind(oPC, nToken, "btn_cmd_hold", JsonBool (TRUE));        
    }
    else NuiSetBind(oPC, nToken, "btn_cmd_hold", JsonBool (FALSE));        
    NuiSetBind(oPC, nToken, "btn_cmd_hold_event", JsonBool (TRUE));
    if(bIsPC) NuiSetBind(oPC, nToken, "btn_cmd_hold_tooltip", JsonString(TOOL_TXT_CMD_ALL_HOLD));
    else NuiSetBind(oPC, nToken, "btn_cmd_hold_tooltip", JsonString(TOOL_TXT_CMD_HOLD));
    NuiSetBind(oPC, nToken, "chbx_cmd_attack_check", JsonBool (bCmdAttack));
    NuiSetBindWatch (oPC, nToken, "chbx_cmd_attack_check", TRUE);
    NuiSetBind(oPC, nToken, "chbx_cmd_attack_event", JsonBool(TRUE));
    if(!ai_GetAIMode(oAssociate, AI_MODE_DEFEND_MASTER) &&
       !ai_GetAIMode(oAssociate, AI_MODE_STAND_GROUND) &&
       !ai_GetAIMode(oAssociate, AI_MODE_FOLLOW) && oPC != oAssociate)
    {
        NuiSetBind(oPC, nToken, "btn_cmd_attack", JsonBool (TRUE));        
    }
    else NuiSetBind(oPC, nToken, "btn_cmd_attack", JsonBool (FALSE));        
    NuiSetBind(oPC, nToken, "btn_cmd_attack_event", JsonBool (TRUE));
    if(bIsPC) NuiSetBind(oPC, nToken, "btn_cmd_attack_tooltip", JsonString(TOOL_TXT_CMD_ALL_ATTACK));
    else NuiSetBind(oPC, nToken, "btn_cmd_attack_tooltip", JsonString(TOOL_TXT_CMD_ATTACK));
    // Row 7 
    NuiSetBind(oPC, nToken, "btn_follow_up_event", JsonBool(TRUE));
    NuiSetBind(oPC, nToken, "btn_follow_down_event", JsonBool(TRUE));
    NuiSetBind(oPC, nToken, "chbx_cmd_follow_check", JsonBool (bCmdFollow));
    NuiSetBindWatch (oPC, nToken, "chbx_cmd_follow_check", TRUE);
    NuiSetBind(oPC, nToken, "chbx_cmd_follow_event", JsonBool(TRUE));
    if(ai_GetAIMode(oAssociate, AI_MODE_FOLLOW))  
    {
        NuiSetBind(oPC, nToken, "btn_cmd_follow", JsonBool (TRUE));        
    }
    else NuiSetBind(oPC, nToken, "btn_cmd_follow", JsonBool (FALSE));        
    NuiSetBind(oPC, nToken, "btn_cmd_follow_event", JsonBool (TRUE));
    if(bIsPC) NuiSetBind(oPC, nToken, "btn_cmd_follow_tooltip", JsonString(TOOL_TXT_CMD_ALL_FOLLOW));
    else 
    {
        NuiSetBind(oPC, nToken, "btn_cmd_follow_label", JsonString(BTN_TXT_CMD_FOLLOW + " [" + sRange + "]"));
        NuiSetBind(oPC, nToken, "btn_cmd_follow_tooltip", JsonString(TOOL_TXT_CMD_FOLLOW + " [" + sRange + "]"));
    }
    NuiSetBind(oPC, nToken, "chbx_follow_target_check", JsonBool (bFollowTarget));
    NuiSetBindWatch (oPC, nToken, "chbx_follow_target_check", TRUE);
    NuiSetBind(oPC, nToken, "chbx_follow_target_event", JsonBool(TRUE));
    NuiSetBind(oPC, nToken, "btn_follow_target_event", JsonBool (TRUE));
    NuiSetBind(oPC, nToken, "btn_follow_target_label", JsonString(BTN_TXT_CMD_SELECT_FOLLOW + " [" + sRange + "]"));
    object oTarget = GetLocalObject(oAssociate, AI_FOLLOW_TARGET);
    string sTarget;
    if(oTarget != OBJECT_INVALID) sTarget = GetName(oTarget);
    else
    {
        if(ai_GetIsCharacter(oAssociate)) sTarget = "nobody";
        else sTarget = GetName(oPC);
    }
    NuiSetBind(oPC, nToken, "btn_follow_target_tooltip", JsonString("  " + sName + TOOL_TXT_CMD_SELECT_FOLLOW + sTarget + " from " + sRange + " meters away."));
    // Row 8
    if(bIsPC)
    {
        NuiSetBind(oPC, nToken, "chbx_cmd_search_check", JsonBool (bCmdSearch));
        NuiSetBindWatch (oPC, nToken, "chbx_cmd_search_check", TRUE);
        NuiSetBind(oPC, nToken, "chbx_cmd_search_event", JsonBool(TRUE));
        NuiSetBind(oPC, nToken, "btn_cmd_search_event", JsonBool (TRUE));
        if(ai_GetAIMode(oPC, AI_MODE_AGGRESSIVE_SEARCH)) 
        {
            NuiSetBind(oPC, nToken, "btn_cmd_search", JsonBool(TRUE));
            NuiSetBind(oPC, nToken, "btn_cmd_search_tooltip", JsonString(TOOL_TXT_CMD_ALL_SEARCH_ON));
        }
        else NuiSetBind(oPC, nToken, "btn_cmd_search_tooltip", JsonString(TOOL_TXT_CMD_ALL_SEARCH_OFF));
        NuiSetBind(oPC, nToken, "chbx_cmd_stealth_check", JsonBool (bCmdStealth));
        NuiSetBindWatch (oPC, nToken, "chbx_cmd_stealth_check", TRUE);
        NuiSetBind(oPC, nToken, "chbx_cmd_stealth_event", JsonBool(TRUE));
        NuiSetBind(oPC, nToken, "btn_cmd_stealth_event", JsonBool (TRUE));
        if(ai_GetAIMode(oPC, AI_MODE_AGGRESSIVE_STEALTH)) 
        {
            NuiSetBind(oPC, nToken, "btn_cmd_stealth", JsonBool(TRUE));
            NuiSetBind(oPC, nToken, "btn_cmd_stealth_tooltip", JsonString(TOOL_TXT_CMD_ALL_STEALTH_ON));
        }
        else NuiSetBind(oPC, nToken, "btn_cmd_stealth_tooltip", JsonString(TOOL_TXT_CMD_ALL_STEALTH_OFF));
    }
    // Row 9
    NuiSetBind(oPC, nToken, "chbx_cmd_ai_script_check", JsonBool (bCmdAIScript));
    NuiSetBindWatch (oPC, nToken, "chbx_cmd_ai_script_check", TRUE);
    NuiSetBind(oPC, nToken, "chbx_cmd_ai_script_event", JsonBool(TRUE));
    NuiSetBind(oPC, nToken, "btn_cmd_ai_script_event", JsonBool (TRUE));
    string sScript = "Base AI";
    sText = TOOL_TXT_CMD_SCRIPT_DEFAULT;
    if(ResManGetAliasFor("ai_a_default", RESTYPE_NCS) != "")
    {
        sScript = GetLocalString(oAssociate, AI_COMBAT_SCRIPT);
        if(sScript == "ai_a_ambusher") sText = TOOL_TXT_CMD_SCRIPT_AMBUSHER;
        else if(sScript == "ai_a_flanker") sText = TOOL_TXT_CMD_SCRIPT_FLANKER;
        else if(sScript == "ai_a_peaceful") sText = TOOL_TXT_CMD_SCRIPT_PEACEFULL;
        else if(sScript == "ai_a_defensive") sText = TOOL_TXT_CMD_SCRIPT_DEFENSIVE;
        else if(sScript == "ai_a_ranged") sText = TOOL_TXT_CMD_SCRIPT_RANGED;
        else if(sScript == "ai_a_cntrspell") sText = TOOL_TXT_CMD_SCRIPT_COUNTERSPELL;
        else sScript = "ai_a_default";
    }
    else
    {
        if(GetCombatCondition(X0_COMBAT_FLAG_AMBUSHER, oAssociate)) sText = TOOL_TXT_CMD_SCRIPT_AMBUSHER;
        else if(GetCombatCondition(X0_COMBAT_FLAG_COWARDLY, oAssociate)) sText = TOOL_TXT_CMD_SCRIPT_PEACEFULL;
        else if(GetCombatCondition(X0_COMBAT_FLAG_DEFENSIVE, oAssociate)) sText = TOOL_TXT_CMD_SCRIPT_DEFENSIVE;
        else if(GetCombatCondition(X0_COMBAT_FLAG_RANGED, oAssociate)) sText = TOOL_TXT_CMD_SCRIPT_RANGED;
    }
    NuiSetBind(oPC, nToken, "btn_cmd_ai_script_label", JsonString(BTN_TXT_CMD_SCRIPT_NAME + sScript));
    NuiSetBind(oPC, nToken, "btn_cmd_ai_script_tooltip", JsonString(sText)); 
    if(GetSkillRank(SKILL_SET_TRAP, oAssociate, TRUE) > 0)
    {
        NuiSetBind(oPC, nToken, "chbx_cmd_place_trap_check", JsonBool (bCmdPlacetrap));
        NuiSetBindWatch (oPC, nToken, "chbx_cmd_place_trap_check", TRUE);
        NuiSetBind(oPC, nToken, "chbx_cmd_place_trap_event", JsonBool(TRUE));
        NuiSetBind(oPC, nToken, "btn_cmd_place_trap_event", JsonBool (TRUE));
        NuiSetBind(oPC, nToken, "btn_cmd_place_trap_tooltip", JsonString (TOOL_TXT_PLACE_TRAP));
    }
    // Row 10
    NuiSetBind(oPC, nToken, "btn_quick_widget_event", JsonBool(TRUE));
    NuiSetBind (oPC, nToken, "btn_quick_widget_tooltip", JsonString(TOOL_TXT_QUICK_WIDGET));
    NuiSetBind(oPC, nToken, "chbx_quick_widget_check", JsonBool (bSpellWidget));
    NuiSetBindWatch (oPC, nToken, "chbx_quick_widget_check", TRUE);
    NuiSetBind(oPC, nToken, "chbx_quick_widget_event", JsonBool(TRUE));
    if(bMemorize == 2) // Memorizes their spells.
    {
        NuiSetBind(oPC, nToken, "btn_spell_memorize_event", JsonBool(TRUE));
        NuiSetBind (oPC, nToken, "btn_spell_memorize_tooltip", JsonString(TOOL_TXT_MEMORIZE_SPELLS));
    }
    if(bSpellbook) // Change known spells.
    {
        NuiSetBind(oPC, nToken, "btn_spell_known_event", JsonBool(TRUE));
        NuiSetBind (oPC, nToken, "btn_spell_known_tooltip", JsonString(TOOL_TXT_KNOWN_SPELLS));
    }
    // Row 11
    NuiSetBind(oPC, nToken, "btn_buff_short_up_event", JsonBool(TRUE));
    NuiSetBind(oPC, nToken, "btn_buff_short_down_event", JsonBool(TRUE));
    NuiSetBind(oPC, nToken, "chbx_buff_short_check", JsonBool (bBuffShort));
    NuiSetBindWatch (oPC, nToken, "chbx_buff_short_check", TRUE);
    NuiSetBind(oPC, nToken, "chbx_buff_short_event", JsonBool(TRUE));
    NuiSetBind(oPC, nToken, "btn_buff_short_event", JsonBool (TRUE));
    float fDelay = GetLocalFloat(oAssociate, AI_DELAY_BUFF_CASTING);
    if(fDelay < 0.1) fDelay = 0.1;
    string sDelay = FloatToString(fDelay, 0, 1);
    NuiSetBind (oPC, nToken, "btn_buff_short_label", JsonString (
               BTN_TXT_SHORT_BUFFS + " [" + sDelay + "]"));
    NuiSetBind (oPC, nToken, "btn_buff_short_tooltip", JsonString (
               TOOL_TXT_SHORT_BUFFS  + sDelay + " seconds."));
    NuiSetBind(oPC, nToken, "btn_buff_long_up_event", JsonBool(TRUE));
    NuiSetBind(oPC, nToken, "btn_buff_long_down_event", JsonBool(TRUE));
    NuiSetBind(oPC, nToken, "chbx_buff_long_check", JsonBool (bBuffLong));
    NuiSetBindWatch (oPC, nToken, "chbx_buff_long_check", TRUE);
    NuiSetBind(oPC, nToken, "chbx_buff_long_event", JsonBool(TRUE));
    NuiSetBind(oPC, nToken, "btn_buff_long_event", JsonBool (TRUE));
    NuiSetBind (oPC, nToken, "btn_buff_long_label", JsonString (
               BTN_TXT_LONG_BUFFS + " [" + sDelay + "]"));
    NuiSetBind(oPC, nToken, "btn_buff_long_tooltip", JsonString (
               TOOL_TXT_LONG_BUFFS + sDelay + " seconds."));
    // Row 12
    NuiSetBind(oPC, nToken, "btn_buff_all_up_event", JsonBool(TRUE));
    NuiSetBind(oPC, nToken, "btn_buff_all_down_event", JsonBool(TRUE));
    NuiSetBind(oPC, nToken, "chbx_buff_all_check", JsonBool (bBuffAll));
    NuiSetBindWatch (oPC, nToken, "chbx_buff_all_check", TRUE);
    NuiSetBind(oPC, nToken, "chbx_buff_all_event", JsonBool(TRUE));
    NuiSetBind(oPC, nToken, "btn_buff_all_event", JsonBool (TRUE));
    NuiSetBind (oPC, nToken, "btn_buff_all_label", JsonString (
               BTN_TXT_ALL_BUFFS + " [" + sDelay + "]"));
    NuiSetBind(oPC, nToken, "btn_buff_all_tooltip", JsonString (
               TOOL_TXT_ALL_BUFFS + sDelay + " seconds."));
    if(!bIsPC)
    {
        NuiSetBind(oPC, nToken, "chbx_buff_rest_check", JsonBool (bBuffRest));
        NuiSetBindWatch (oPC, nToken, "chbx_buff_rest_check", TRUE);
        NuiSetBind(oPC, nToken, "chbx_buff_rest_event", JsonBool(TRUE));
        NuiSetBind(oPC, nToken, "btn_buff_rest_event", JsonBool (TRUE));
        if(ai_GetMagicMode(oAssociate, AI_MAGIC_BUFF_AFTER_REST)) sText = TOOL_TXT_BUFF_AFTER_RESTING_ON;
        else sText = TOOL_TXT_BUFF_AFTER_RESTING_OFF;
        NuiSetBind(oPC, nToken, "btn_buff_rest_label", JsonString(sText));
        NuiSetBind(oPC, nToken, "btn_buff_rest_tooltip", JsonString ("  " + sText));
    }
    else NuiSetBind(oPC, nToken, "btn_buff_rest_label", JsonString("Buff after Resting [Off]"));
    // Row 13
    NuiSetBind(oPC, nToken, "chbx_jump_to_check", JsonBool(bJumpTo));
    NuiSetBindWatch (oPC, nToken, "chbx_jump_to_check", TRUE);
    NuiSetBind(oPC, nToken, "chbx_jump_to_event", JsonBool(TRUE));
    NuiSetBind(oPC, nToken, "btn_jump_to_event", JsonBool(TRUE));
    if(oPC == oAssociate) 
    {
        NuiSetBind(oPC, nToken, "btn_jump_to_label", JsonString(BTN_TXT_JUMP_ALL_TO_PLAYER));
        NuiSetBind(oPC, nToken, "btn_jump_to_tooltip", JsonString (TOOL_TXT_JUMP_ALL_TO_PLAYER));
    }
    else
    {
        NuiSetBind(oPC, nToken, "btn_jump_to_label", JsonString(BTN_TXT_JUMP_TO_PLAYER));
        NuiSetBind(oPC, nToken, "btn_jump_to_tooltip", JsonString (TOOL_TXT_JUMP_TO_PLAYER));
    }
    NuiSetBind(oPC, nToken, "chbx_ghost_mode_check", JsonBool (bGhostMode));
    NuiSetBindWatch (oPC, nToken, "chbx_ghost_mode_check", TRUE);
    NuiSetBind(oPC, nToken, "chbx_ghost_mode_event", JsonBool(TRUE));
    NuiSetBind(oPC, nToken, "btn_ghost_mode_event", JsonBool (TRUE));
    if(ai_GetAIMode(oAssociate, AI_MODE_GHOST))  
    {
        NuiSetBind(oPC, nToken, "btn_ghost_mode", JsonBool (TRUE));        
        NuiSetBind(oPC, nToken, "btn_ghost_mode_tooltip", JsonString (TOOL_TXT_GHOST_MODE_ON));
    }
    else 
    {
        NuiSetBind(oPC, nToken, "btn_ghost_mode", JsonBool (FALSE));        
        NuiSetBind(oPC, nToken, "btn_ghost_mode_tooltip", JsonString (TOOL_TXT_GHOST_MODE_OFF));
    }
    // Row 14
    NuiSetBind(oPC, nToken, "chbx_camera_check", JsonBool (bCamera));
    NuiSetBindWatch (oPC, nToken, "chbx_camera_check", TRUE);
    NuiSetBind(oPC, nToken, "chbx_camera_event", JsonBool(TRUE));
    NuiSetBind(oPC, nToken, "btn_camera_event", JsonBool (TRUE));
    if(bIsPC) NuiSetBind(oPC, nToken, "btn_camera_tooltip", JsonString (TOOL_TXT_CAMERA_FOCUS_PC));
    else NuiSetBind(oPC, nToken, "btn_camera_tooltip", JsonString (TOOL_TXT_CAMERA_FOCUS_ASSOCIATE));
    NuiSetBind(oPC, nToken, "chbx_inventory_check", JsonBool (bInventory));
    NuiSetBindWatch (oPC, nToken, "chbx_inventory_check", TRUE);
    NuiSetBind(oPC, nToken, "chbx_inventory_event", JsonBool(TRUE));
    NuiSetBind(oPC, nToken, "btn_inventory_event", JsonBool (TRUE));
    NuiSetBind(oPC, nToken, "btn_inventory_tooltip", JsonString (TOOL_TXT_OPEN_INVENTORY));
    // Row 15 & 16
    if(bFamiliar)
    {
        NuiSetBind(oPC, nToken, "chbx_familiar_check", JsonBool(bBtnFamiliar));
        NuiSetBind(oPC, nToken, "chbx_familiar_event", JsonBool(TRUE));
        NuiSetBindWatch (oPC, nToken, "chbx_familiar_check", TRUE);
        int nFamiliar = GetFamiliarCreatureType(oAssociate);
        NuiSetBind(oPC, nToken, "cmb_familiar_selected", JsonInt(nFamiliar));
        string sFamiliarName = GetFamiliarName(oAssociate);
        NuiSetBind(oPC, nToken, "txt_familiar_name", JsonString(sFamiliarName));
        if(!bIsPC)
        {
            NuiSetBind(oPC, nToken, "lbl_familiar_type_label", JsonString(BTN_TXT_FAMILIAR_TYPE_ASSOCIATE));
            NuiSetBind(oPC, nToken, "lbl_familiar_name_label", JsonString(BTN_TXT_FAMILIAR_NAME_ASSOCIATE));
            NuiSetBind(oPC, nToken, "cmb_familiar_event", JsonBool(TRUE));
            NuiSetBindWatch(oPC, nToken, "cmb_familiar_selected", TRUE);
            NuiSetBindWatch(oPC, nToken, "txt_familiar_name", TRUE);
            NuiSetBind(oPC, nToken, "txt_familiar_name_event", JsonBool(TRUE));
            NuiSetBind(oPC, nToken, "btn_familiar_name_event", JsonBool(TRUE));
            NuiSetBind(oPC, nToken, "btn_familiar_name_label", JsonString("Save"));
        }
        else
        {
            NuiSetBind(oPC, nToken, "lbl_familiar_type_label", JsonString(BTN_TXT_FAMILIAR_TYPE_PC));
            NuiSetBind(oPC, nToken, "lbl_familiar_name_label", JsonString(BTN_TXT_FAMILIAR_NAME_PC));
        }
    }
    // Row 17 & 18
    if(bCompanion)
    {
        NuiSetBind(oPC, nToken, "chbx_companion_check", JsonBool(bBtnCompanion));
        NuiSetBind(oPC, nToken, "chbx_companion_event", JsonBool(TRUE));
        NuiSetBindWatch (oPC, nToken, "chbx_companion_check", TRUE);
        int nCompanion = GetAnimalCompanionCreatureType(oAssociate);
        NuiSetBind(oPC, nToken, "cmb_companion_selected", JsonInt(nCompanion));
        string sCompanionName = GetAnimalCompanionName(oAssociate);
        NuiSetBind(oPC, nToken, "txt_companion_name", JsonString(sCompanionName));
        if(!bIsPC)
        {
            NuiSetBind(oPC, nToken, "lbl_companion_type_label", JsonString(BTN_TXT_COMPANION_TYPE_ASSOCIATE));
            NuiSetBind(oPC, nToken, "lbl_companion_name_label", JsonString(BTN_TXT_COMPANION_NAME_ASSOCIATE));
            NuiSetBind(oPC, nToken, "cmb_companion_event", JsonBool(TRUE));
            NuiSetBindWatch(oPC, nToken, "cmb_companion_selected", TRUE);
            NuiSetBindWatch(oPC, nToken, "txt_companion_name", TRUE);
            NuiSetBind(oPC, nToken, "txt_companion_name_event", JsonBool(TRUE));
            NuiSetBind(oPC, nToken, "btn_companion_name_event", JsonBool(TRUE));
            NuiSetBind(oPC, nToken, "btn_companion_name_label", JsonString("Save"));
        }
        else
        {
            NuiSetBind(oPC, nToken, "lbl_companion_type_label", JsonString(BTN_TXT_COMPANION_TYPE_PC));
            NuiSetBind(oPC, nToken, "lbl_companion_name_label", JsonString(BTN_TXT_COMPANION_NAME_PC));
        }
    }
    if(bIsPC)
    {
        // Row 19+
        int nIndex, bWidget;
        string sButton, sText;
        json jPlugin = JsonArrayGet(jPCPlugins, nIndex);
        while(JsonGetType(jPlugin) != JSON_TYPE_NULL)
        {
            sButton = IntToString(nIndex);
            NuiSetBind(oPC, nToken, "btn_plugin_" + sButton + "_event", JsonBool(TRUE));
            bWidget = JsonGetInt(JsonArrayGet(jPlugin, 1));
            NuiSetBind(oPC, nToken, "chbx_plugin_" + sButton + "_check", JsonBool(bWidget));
            NuiSetBindWatch (oPC, nToken, "chbx_plugin_" + sButton + "_check", TRUE);
            NuiSetBind(oPC, nToken, "chbx_plugin_" + sButton + "_event", JsonBool(TRUE));
            sText = "  Execute " + JsonGetString(JsonArrayGet(jPlugin, 2)) + " plugin.";
            NuiSetBind(oPC, nToken, "btn_plugin_" + sButton + "_tooltip", JsonString(sText));
            jPlugin = JsonArrayGet(jPCPlugins, ++nIndex);
        }
        NuiSetBind(oPC, nToken, "chbx_plugin_tooltip", JsonString("  Adds the plugin to your widget."));
    }
    // Row 20+
    sText = ai_GetRandomTip();
    NuiSetBind(oPC, nToken, "lbl_info_1_label", JsonString(sText));
}
void ai_CreateAssociateAIMobileNUI(object oPC, object oAssociate)
{
    // Set window to not save until it has been created.
    SetLocalInt (oPC, AI_NO_NUI_SAVE, TRUE);
    DelayCommand (2.0, DeleteLocalInt (oPC, AI_NO_NUI_SAVE));
    int bRight, bLeft;
    int nAssociateType = GetAssociateType(oAssociate);
    float fHeight = 45.0;
    // ************************************************************************* Width / Height
    int bIsPC = ai_GetIsCharacter(oAssociate);
    string sAssociateType = ai_GetAssociateType(oPC, oAssociate);
    json jRow = JsonArray();
    json jCol = JsonArray();
    // Row 1 ******************************************************************* 500 / 73
    if(bIsPC)
    {
        // If all the Command buttons are blocked then don't load the menu.  
        bRight = GetLocalInt(GetModule(), sDMWidgetAccessVarname) != 7340028;
        bLeft = ai_GetIsServer();
        if(!bLeft || bRight)
        {
            if(bRight)
            {
                jRow = CreateButton(jRow, BTN_TXT_COMMAND_MENU, "btn_command_menu", 230.0, 30.0, -1.0, "btn_command_menu_tooltip");
                jRow = CreateLabel(jRow, "", "lbl_space", 30.0, 30.0);
                jRow = JsonArrayInsert(jRow, NuiSpacer());
            }
            jRow = JsonArrayInsert(jRow, NuiSpacer());
            if(!bLeft)
            {
                jRow = CreateButton(jRow, BTN_TXT_MAIN_MENU, "btn_main_menu", 230.0, 30.0, -1.0, "btn_main_menu_tooltip");
                jRow = CreateLabel(jRow, "", "lbl_space", 20.0, 30.0);
                jRow = JsonArrayInsert(jRow, NuiSpacer());
            }
        }
        jCol = JsonArrayInsert(jCol, NuiRow(jRow));
        fHeight += 38.0;
    }
    // Row 2 ******************************************************************* 500 / 101
    // If all the Command buttons are blocked then don't load the menu. 
    bRight = GetLocalInt(GetModule(), sDMWidgetAccessVarname) != 7340028;
    bLeft = !ai_GetDMAIAccessButton(BTN_AI_LOOT);
    if(bRight || bLeft)
    {
        float fWidth = 230.0;
        jRow = JsonArray();
        if(bRight && !bIsPC)
        {
            fWidth = 150.0;
            jRow = CreateButton(jRow, BTN_TXT_COMMAND_MENU, "btn_command_menu", fWidth, 30.0, -1.0, "btn_command_menu_tooltip");
            jRow = CreateLabel(jRow, "", "lbl_space", 25.0, 30.0);
            jRow = JsonArrayInsert(jRow, NuiSpacer());
        }
        if(bLeft)
        {
            jRow = CreateButton(jRow, BTN_TXT_AI_LOOT_FILTER, "btn_loot_filter", fWidth, 30.0);
            jRow = CreateLabel(jRow, "", "blank_label", 25.0, 30.0);
            jRow = JsonArrayInsert(jRow, NuiSpacer());
        }
        jRow = CreateButton(jRow, BTN_TXT_CLOSE, "btn_close", fWidth, 30.0f);
        jRow = CreateLabel(jRow, "", "lbl_space", 25.0, 30.0);
        jCol = JsonArrayInsert(jCol, NuiRow(jRow));
        fHeight += 38.0;
    }
    // Row 3 ******************************************************************* 500 / 129
    bRight = !ai_GetDMAIAccessButton(BTN_AI_FOR_PC);
    bLeft = !ai_GetDMAIAccessButton(BTN_AI_REDUCE_SPEECH);
    if(bRight || bLeft)
    {
        jRow = JsonArray();
        if(bRight)
        {
            jRow = CreateButtonSelect(JsonArray(), BTN_TXT_PLAYER_AI, "btn_ai", 230.0, 30.0, -1.0, "btn_ai_tooltip");
            jRow = CreateCheckBox(jRow, "", "chbx_ai", 25.0, 20.0);
        jRow = JsonArrayInsert(jRow, NuiSpacer());
        }
        if(bLeft)
        {
            jRow = CreateButtonSelect(jRow, BTN_TXT_REDUCE_SPEECH, "btn_quiet", 230.0, 30.0, -1.0, "btn_quiet_tooltip");
            jRow = CreateCheckBox(jRow, "", "chbx_quiet", 25.0, 20.0);
        }
        jCol = JsonArrayInsert(jCol, NuiRow(jRow));
        fHeight += 38.0;
    }
    // Row 4 ******************************************************************* 500 / 157
    bRight = !ai_GetDMAIAccessButton(BTN_AI_USE_RANGED);
    bLeft = !ai_GetDMAIAccessButton(BTN_AI_STOP_WEAPON_EQUIP);
    if(bRight || bLeft)
    {
        jRow = JsonArray();
        if(bRight)
        {
            jRow = CreateButtonSelect(JsonArray(), BTN_TXT_RANGED_COMBAT, "btn_ranged", 230.0, 30.0, -1.0, "btn_ranged_tooltip");
            jRow = CreateCheckBox(jRow, "", "chbx_ranged", 25.0, 30.0);
        }
    jRow = JsonArrayInsert(jRow, NuiSpacer());
        if(bLeft)
        {
            jRow = CreateButtonSelect(jRow, BTN_TXT_AUTO_EQUIP_WEAPONS, "btn_equip_weapon", 230.0, 30.0, -1.0, "btn_equip_weapon_tooltip");
            jRow = CreateCheckBox(jRow, "", "chbx_equip_weapon", 25.0, 30.0);
        }
        jCol = JsonArrayInsert(jCol, NuiRow(jRow));
        fHeight += 38.0;
    }
    // Row 5 ******************************************************************* 500 / 185
    bRight = !ai_GetDMAIAccessButton(BTN_AI_USE_SEARCH);
    bLeft = !ai_GetDMAIAccessButton(BTN_AI_USE_STEALTH);
    if(bRight || bLeft)
    {
        jRow = JsonArray();
        if(bRight)
        {
            jRow = CreateButtonSelect(JsonArray(), BTN_TXT_SEARCH_MODE, "btn_search", 230.0, 30.0, -1.0, "btn_search_tooltip");
            jRow = CreateCheckBox(jRow, "", "chbx_search", 25.0, 30.0);
        }
        jRow = JsonArrayInsert(jRow, NuiSpacer());
        if(bLeft)
        {
            jRow = CreateButtonSelect(jRow, BTN_TXT_STEALTH_MODE, "btn_stealth", 230.0, 30.0, -1.0, "btn_stealth_tooltip");
            jRow = CreateCheckBox(jRow, "", "chbx_stealth", 25.0, 30.0);
        }
        jCol = JsonArrayInsert(jCol, NuiRow(jRow));
        fHeight += 38.0;
    }
    // Row 6 ******************************************************************* 500 / 185
    bRight = !ai_GetDMAIAccessButton(BTN_AI_OPEN_DOORS);
    bLeft = !ai_GetDMAIAccessButton(BTN_AI_REMOVE_TRAPS);
    if(bRight || bLeft)
    {
        jRow = JsonArray();
        if(bRight)
        {
            jRow = CreateButtonImage(JsonArray(), "nui_cnt_up", "btn_door_up", 30.0, 30.0, -1.0, "btn_open_door_tooltip");
            jRow = CreateButtonImage(jRow, "nui_cnt_down", "btn_door_down", 30.0, 30.0, -1.0, "btn_open_door_tooltip");
            jRow = CreateButtonSelect(jRow, "", "btn_open_door", 170.0, 30.0, -1.0, "btn_open_door_tooltip");
            jRow = CreateCheckBox(jRow, "", "chbx_open_door", 25.0, 30.0);
        }
        jRow = JsonArrayInsert(jRow, NuiSpacer());
        if(bLeft)
        {
            jRow = CreateButtonImage(jRow, "nui_cnt_up", "btn_traps_up", 30.0, 30.0, -1.0, "btn_traps_tooltip");
            jRow = CreateButtonImage(jRow, "nui_cnt_down", "btn_traps_down", 30.0, 30.0, -1.0, "btn_traps_tooltip");
            jRow = CreateButtonSelect(jRow, "", "btn_traps", 170.0, 30.0, -1.0, "btn_traps_tooltip");
            jRow = CreateCheckBox(jRow, "", "chbx_traps", 25.0, 30.0);
        }
        jCol = JsonArrayInsert(jCol, NuiRow(jRow));
        fHeight += 38.0;
    }
    // Row 7 ******************************************************************* 500 / 213
    bRight = !ai_GetDMAIAccessButton(BTN_AI_PICK_LOCKS);
    bLeft = !ai_GetDMAIAccessButton(BTN_AI_BASH_LOCKS);
    if(bRight || bLeft)
    {
        jRow = JsonArray();
        if(bRight)
        {
            jRow = CreateButtonImage(JsonArray(), "nui_cnt_up", "btn_pick_up", 30.0, 30.0, -1.0, "btn_pick_locks_tooltip");
            jRow = CreateButtonImage(jRow, "nui_cnt_down", "btn_pick_down", 30.0, 30.0, -1.0, "btn_pick_locks_tooltip");
            jRow = CreateButtonSelect(jRow, "", "btn_pick_locks", 170.0, 30.0, -1.0, "btn_pick_locks_tooltip");
            jRow = CreateCheckBox(jRow, "", "chbx_pick_locks", 25.0, 30.0);
        }
        jRow = JsonArrayInsert(jRow, NuiSpacer());
        if(bLeft)
        {
            jRow = CreateButtonImage(jRow, "nui_cnt_up", "btn_bash_up", 30.0, 30.0, -1.0, "btn_bash_locks_tooltip");
            jRow = CreateButtonImage(jRow, "nui_cnt_down", "btn_bash_down", 30.0, 30.0, -1.0, "btn_bash_locks_tooltip");
            jRow = CreateButtonSelect(jRow, "", "btn_bash_locks", 170.0, 30.0, -1.0, "btn_bash_locks_tooltip");
            jRow = CreateCheckBox(jRow, "", "chbx_bash_locks", 25.0, 30.0);
        }
        jCol = JsonArrayInsert(jCol, NuiRow(jRow));
        fHeight += 38.0;
    }
    // Row 8 ******************************************************************* 500 / 241
    bRight = !ai_GetDMAIAccessButton(BTN_AI_MAGIC_LEVEL);
    bLeft = !ai_GetDMAIAccessButton(BTN_AI_LOOT);
    if(bRight || bLeft)
    {
        jRow = JsonArray();
        if(bRight)
        {
            jRow = CreateButtonImage(JsonArray(), "nui_cnt_up", "btn_magic_up", 30.0, 30.0, -1.0, "btn_magic_level_tooltip");
            jRow = CreateButtonImage(jRow, "nui_cnt_down", "btn_magic_down", 30.0, 30.0, -1.0, "btn_magic_level_tooltip");
            jRow = CreateButton(jRow, "", "btn_magic_level", 170.0, 30.0f, -1.0, "btn_magic_level_tooltip");
            jRow = CreateCheckBox(jRow, "", "chbx_magic_level", 25.0, 30.0);
        }
        jRow = JsonArrayInsert(jRow, NuiSpacer());
        if(bLeft)
        {
            if(nAssociateType != ASSOCIATE_TYPE_SUMMONED && nAssociateType != ASSOCIATE_TYPE_DOMINATED)
            {
                jRow = CreateButtonImage(jRow, "nui_cnt_up", "btn_loot_up", 30.0, 30.0, -1.0, "btn_loot_tooltip");
                jRow = CreateButtonImage(jRow, "nui_cnt_down", "btn_loot_down", 30.0, 30.0, -1.0, "btn_loot_tooltip");
                jRow = CreateButtonSelect(jRow, "", "btn_loot", 170.0, 30.0, -1.0, "btn_loot_tooltip");
                jRow = CreateCheckBox(jRow, "", "chbx_loot", 25.0, 30.0);
            }
        }
        jCol = JsonArrayInsert(jCol, NuiRow(jRow));
        fHeight += 38.0;
    }
    // Row 9 ******************************************************************* 500 / 269
    bRight = !ai_GetDMAIAccessButton(BTN_AI_NO_MAGIC_USE);
    bLeft = !ai_GetDMAIAccessButton(BTN_AI_NO_MAGIC_ITEM_USE);
    if(bRight || bLeft)
    {
        jRow = JsonArray();
        if(bRight)
        {
            jRow = CreateButtonSelect(jRow, BTN_TXT_USE_MAGIC, "btn_magic", 230.0, 30.0, -1.0, "btn_magic_tooltip");
            jRow = CreateCheckBox(jRow, "", "chbx_magic", 25.0, 30.0);
        }
        jRow = JsonArrayInsert(jRow, NuiSpacer());
        if(bLeft)
        {
            jRow = CreateButtonSelect(jRow, BTN_TXT_USE_MAGIC_ITEMS, "btn_magic_items", 230.0, 30.0, -1.0, "btn_magic_items_tooltip");
            jRow = CreateCheckBox(jRow, "", "chbx_magic_items", 25.0, 30.0);
        }
        jCol = JsonArrayInsert(jCol, NuiRow(jRow));
        fHeight += 38.0;
    }
    // Row 10 ****************************************************************** 500 / 297
    bRight = !ai_GetDMAIAccessButton(BTN_AI_MAGIC_USE);
    bLeft = !ai_GetDMAIAccessButton(BTN_AI_OFF_MAGIC_USE);
    if(bRight || bLeft)
    {
        jRow = JsonArray();
        if(bRight)
        {
            jRow = CreateButton(jRow, "", "btn_magic_use", 230.0, 30.0, -1.0,  "btn_magic_use_tooltip");
            jRow = CreateCheckBox(jRow, "", "chbx_magic_use", 25.0, 30.0f);
        }
        jRow = JsonArrayInsert(jRow, NuiSpacer());
        if(bLeft)
        {
            jRow = CreateButtonImage(jRow, "nui_cnt_up", "btn_off_magic_use_up", 30.0, 30.0, -1.0, "btn_off_magic_use_tooltip");
            jRow = CreateButtonImage(jRow, "nui_cnt_down", "btn_off_magic_use_down", 30.0, 30.0, -1.0, "btn_off_magic_use_tooltip");
            jRow = CreateButton(jRow, "", "btn_off_magic_use", 170.0, 30.0, -1.0, "btn_off_magic_use_tooltip");
            jRow = CreateCheckBox(jRow, "", "chbx_off_magic_use", 25.0, 30.0);
        }
        jCol = JsonArrayInsert(jCol, NuiRow(jRow));
        fHeight += 38.0;
    }
    // Row 11 ******************************************************************* 500 / 325
    bRight = !ai_GetDMAIAccessButton(BTN_AI_HEAL_OUT);
    bLeft = !ai_GetDMAIAccessButton(BTN_AI_HEAL_IN);
    if(bRight || bLeft)
    {
        jRow = JsonArray();
        if(bRight)
        {
            jRow = CreateButtonImage(JsonArray(), "nui_cnt_up", "btn_heal_out_up", 30.0, 30.0, -1.0, "btn_heal_out_tooltip");
            jRow = CreateButtonImage(jRow, "nui_cnt_down", "btn_heal_out_down", 30.0, 30.0, -1.0, "btn_heal_out_tooltip");
            jRow = CreateButton(jRow, "", "btn_heal_out", 170.0, 30.0, -1.0, "btn_heal_out_tooltip");
            jRow = CreateCheckBox(jRow, "", "chbx_heal_out", 25.0, 30.0);
        }
        jRow = JsonArrayInsert(jRow, NuiSpacer());
        if(bLeft)
        {
            jRow = CreateButtonImage(jRow, "nui_cnt_up", "btn_heal_in_up", 30.0, 30.0, -1.0, "btn_heal_in_tooltip");
            jRow = CreateButtonImage(jRow, "nui_cnt_down", "btn_heal_in_down", 30.0, 30.0, -1.0, "btn_heal_in_tooltip");
            jRow = CreateButton(jRow, "", "btn_heal_in", 170.0, 30.0, -1.0, "btn_heal_in_tooltip");
            jRow = CreateCheckBox(jRow, "", "chbx_heal_in", 25.0, 30.0);
        }
        jCol = JsonArrayInsert(jCol, NuiRow(jRow));
        fHeight += 38.0;
    }
    // Row 12 ****************************************************************** 500 / 353
    bRight = !ai_GetDMAIAccessButton(BTN_AI_STOP_SELF_HEALING);
    bLeft = !ai_GetDMAIAccessButton(BTN_AI_STOP_PARTY_HEALING);
    if(bRight || bLeft)
    {
        jRow = JsonArray();
        if(bRight)
        {
            jRow = CreateButtonSelect(JsonArray(), BTN_TXT_STOP_SELF_HEALING, "btn_heals_onoff", 230.0, 30.0, -1.0, "btn_heals_onoff_tooltip");
            jRow = CreateCheckBox(jRow, "", "chbx_heals_onoff", 25.0, 30.0);
        }
        jRow = JsonArrayInsert(jRow, NuiSpacer());
        if(bLeft)
        {
            jRow = CreateButtonSelect(jRow, BTN_TXT_STOP_PARTY_HEALING, "btn_healp_onoff", 230.0, 30.0, -1.0, "btn_healp_onoff_tooltip");
            jRow = CreateCheckBox(jRow, "", "chbx_healp_onoff", 25.0, 30.0);
        }
        jCol = JsonArrayInsert(jCol, NuiRow(jRow));
        fHeight += 38.0;
    }
    // Row 13 ****************************************************************** 500 / ---
    bRight = !ai_GetDMAIAccessButton(BTN_AI_STOP_CURE_SPELLS);
    bLeft = !ai_GetDMAIAccessButton(BTN_AI_NO_SPONTANEOUS);
    if(bRight || bLeft)
    {
        jRow = JsonArray();
        if(bRight)
        {
            jRow = CreateButtonSelect(JsonArray(), BTN_TXT_CAST_CURE_SPELLS, "btn_cure_onoff", 230.0, 30.0, -1.0, "btn_cure_onoff_tooltip");
            jRow = CreateCheckBox(jRow, "", "chbx_cure_onoff", 25.0, 30.0);
        }
        jRow = JsonArrayInsert(jRow, NuiSpacer());
        if(bLeft)
        {
            jRow = CreateButtonSelect(jRow, BTN_TXT_SPONTANEOUS_CASTING, "btn_spontaneous", 230.0, 30.0, -1.0, "btn_spontaneous_tooltip");
            jRow = CreateCheckBox(jRow, "", "chbx_spontaneous", 25.0, 30.0);
        }
        jCol = JsonArrayInsert(jCol, NuiRow(jRow));
        fHeight += 38.0;
    }
    // Row 14 ****************************************************************** 500 / ---
    bRight = !ai_GetDMAIAccessButton(BTN_AI_IGNORE_ASSOCIATES);
    bLeft = !ai_GetDMAIAccessButton(BTN_AI_IGNORE_TRAPS);
    if(bRight || bLeft)
    {
        jRow = JsonArray();
        if(bRight)
        {
            jRow = CreateButtonSelect(JsonArray(), BTN_IGNORE_ASSOCIATES, "btn_ignore_assoc", 230.0, 30.0, -1.0, "btn_ignore_assoc_tooltip");
            jRow = CreateCheckBox(jRow, "", "chbx_ignore_assoc", 25.0, 30.0);
        }
        jRow = JsonArrayInsert(jRow, NuiSpacer());
        if(bLeft)
        {
            jRow = CreateButtonSelect(jRow, BTN_IGNORE_TRAPS, "btn_ignore_traps", 230.0, 30.0, -1.0, "btn_ignore_traps_tooltip");
            jRow = CreateCheckBox(jRow, "", "chbx_ignore_traps", 25.0, 30.0);
        }
        jCol = JsonArrayInsert(jCol, NuiRow(jRow));
        fHeight += 38.0;
    }
    // Row 15 ****************************************************************** 500 / ---
    bRight = !ai_GetDMAIAccessButton(BTN_AI_PERC_RANGE);
    //bLeft = FALSE; 
    if(bRight || bLeft)
    {
        jRow = JsonArray();
        if(bRight)
        {
            if(GetAssociateType(oAssociate) == ASSOCIATE_TYPE_HENCHMAN)
            {
                jRow = CreateButton(JsonArray(), BTN_PERCEPTION_RANGE, "btn_perc_range", 230.0, 30.0, -1.0, "btn_perc_range_tooltip");
                jRow = JsonArrayInsert(jRow, NuiSpacer());
                jRow = CreateLabel(jRow, "", "lbl_perc_range", 296.0, 30.0);
            }
        }
        jRow = JsonArrayInsert(jRow, NuiSpacer());
        //if(bLeft)
        //{
        //}
        jCol = JsonArrayInsert(jCol, NuiRow(jRow));
        fHeight += 38.0;
    }
    // Row 16 ****************************************************************** 500 / ---
    bRight = !ai_GetDMWAccessButton(BTN_CMD_AI_SCRIPT);
    if(bRight)
    {
        jRow = CreateButton(JsonArray(), BTN_TXT_CURRENT_AI, "btn_ai_script", 175.0f, 30.0f, -1.0, "btn_ai_script_tooltip");
        jRow = CreateTextEditBox(jRow, "sPlaceHolder", "txt_ai_script", 16, FALSE, 175.0f, 30.0f, "txt_ai_script_tooltip");
        jRow = CreateButton(jRow, BTN_TXT_SELECT_AI, "btn_select_ai", 175.0f, 30.0f, -1.0, "btn_select_ai_tooltip");
        //jRow = CreateCombo(jRow, ai_CreateAIScriptJson(oPC), "cmb_ai_script", 176.0, 30.0);
        jCol = JsonArrayInsert(jCol, NuiRow(jRow));
        fHeight += 38.0;
    }
    // Row 17 ****************************************************************** 500 / ---
    jRow = JsonArrayInsert(JsonArray(), NuiSpacer());
    jRow = CreateLabel(jRow, "", "lbl_info", 475.0, 30.0, NUI_HALIGN_CENTER);
    jRow = JsonArrayInsert(jRow, NuiSpacer());
    jCol = JsonArrayInsert(jCol, NuiRow(jRow));
    fHeight += 38.0;
    // Get the window location to restore it from the database.
    float fX, fY;
    json jLocations = ai_GetAssociateDbJson(oPC, sAssociateType, "locations");
    jLocations = JsonObjectGet(jLocations, sAssociateType + AI_NUI);
    if(JsonGetType(jLocations) == JSON_TYPE_NULL) { fX = -1.0; fY = -1.0; }
    else
    {
        fX = JsonGetFloat(JsonObjectGet(jLocations, "x"));
        fY = JsonGetFloat(JsonObjectGet(jLocations, "y"));
    }
    // Set the Layout of the window.
    json jLayout = NuiCol(jCol);
    string sText, sName = GetName(oAssociate);
    if(GetStringRight(sName, 1) == "s") sName = sName + "'";
    else sName = sName + "'s";
    int nToken = SetWindow(oPC, jLayout, sAssociateType + AI_NUI, sName + " AI Menu",
                           fX, fY, 560.0, fHeight + 12.0, FALSE, FALSE, TRUE, FALSE, TRUE, "0e_nui");
    // Get which buttons are activated.
    int bAI = ai_GetAIButton(oPC, BTN_AI_FOR_PC, oAssociate, sAssociateType);
    int bReduceSpeech = ai_GetAIButton(oPC, BTN_AI_REDUCE_SPEECH, oAssociate, sAssociateType);
    int bRanged = ai_GetAIButton(oPC, BTN_AI_USE_RANGED, oAssociate, sAssociateType);
    int bEquipWeapons = ai_GetAIButton(oPC, BTN_AI_STOP_WEAPON_EQUIP, oAssociate, sAssociateType);
    int bSearch = ai_GetAIButton(oPC, BTN_AI_USE_SEARCH, oAssociate, sAssociateType);
    int bStealth = ai_GetAIButton(oPC, BTN_AI_USE_STEALTH, oAssociate, sAssociateType);
    int bOpenDoors = ai_GetAIButton(oPC, BTN_AI_OPEN_DOORS, oAssociate, sAssociateType);
    int bTraps = ai_GetAIButton(oPC, BTN_AI_REMOVE_TRAPS, oAssociate, sAssociateType);
    int bPickLocks = ai_GetAIButton(oPC, BTN_AI_PICK_LOCKS, oAssociate, sAssociateType);
    int bBashLocks = ai_GetAIButton(oPC, BTN_AI_BASH_LOCKS, oAssociate, sAssociateType);
    int bMagicLevel = ai_GetAIButton(oPC, BTN_AI_MAGIC_LEVEL, oAssociate, sAssociateType);
    int bSpontaneous = ai_GetAIButton(oPC, BTN_AI_NO_SPONTANEOUS, oAssociate, sAssociateType);
    int bNoMagic = ai_GetAIButton(oPC, BTN_AI_NO_MAGIC_USE, oAssociate, sAssociateType);
    int bNoMagicItems = ai_GetAIButton(oPC, BTN_AI_NO_MAGIC_ITEM_USE, oAssociate, sAssociateType);
    int bMagicUse = ai_GetAIButton(oPC, BTN_AI_MAGIC_USE, oAssociate, sAssociateType);
    int bOffMagicUse = ai_GetAIButton(oPC, BTN_AI_OFF_MAGIC_USE, oAssociate, sAssociateType);
    int bHealOut = ai_GetAIButton(oPC, BTN_AI_HEAL_OUT, oAssociate, sAssociateType);
    int bHealIn = ai_GetAIButton(oPC, BTN_AI_HEAL_IN, oAssociate, sAssociateType);
    int bSelfHealOnOff = ai_GetAIButton(oPC, BTN_AI_STOP_SELF_HEALING, oAssociate, sAssociateType);
    int bPartyHealOnOff = ai_GetAIButton(oPC, BTN_AI_STOP_PARTY_HEALING, oAssociate, sAssociateType);
    int bCureOnOff = ai_GetAIButton(oPC, BTN_AI_STOP_CURE_SPELLS, oAssociate, sAssociateType);
    int bIgnoreAssociates = ai_GetAIButton(oPC, BTN_AI_IGNORE_ASSOCIATES, oAssociate, sAssociateType);
    int bIgnoreTraps = ai_GetAIButton(oPC, BTN_AI_IGNORE_TRAPS, oAssociate, sAssociateType);
    int bLoot = ai_GetAIButton(oPC, BTN_AI_LOOT, oAssociate, sAssociateType);
    int bPercRange = ai_GetAIButton(oPC, BTN_AI_PERC_RANGE, oAssociate, sAssociateType);
    // Save the associate to the nui for use in 0e_nui
    json jData = JsonArrayInsert(JsonArray(), JsonString(ObjectToString(oAssociate)));
    NuiSetUserData(oPC, nToken, jData); 
    // Set event watches for save window location. 
    NuiSetBindWatch(oPC, nToken, "window_geometry", TRUE);
    // Set all binds, events, and watches.
    // Row 1
    // If all the AI buttons are blocked then don't load the menu.
    NuiSetBind(oPC, nToken, "btn_command_menu_event", JsonBool(TRUE));
    NuiSetBind(oPC, nToken, "btn_command_menu_tooltip", JsonString(TOOL_TXT_COMMAND_MENU));
    NuiSetBind(oPC, nToken, "btn_main_menu_event", JsonBool(TRUE));
    NuiSetBind(oPC, nToken, "btn_main_menu_tooltip", JsonString(TOOL_TXT_MAIN_MENU));
    NuiSetBind(oPC, nToken, "btn_close_event", JsonBool(TRUE));
    // Row 2
    NuiSetBind(oPC, nToken, "btn_loot_filter_event", JsonBool(TRUE));
    NuiSetBind(oPC, nToken, "btn_loot_filter", JsonInt(TRUE));
    // Row 3
    // Only activate ai on/off if this is for the pc.
    if(bIsPC)
    {
        NuiSetBind(oPC, nToken, "chbx_ai_check", JsonBool(bAI));
        NuiSetBindWatch (oPC, nToken, "chbx_ai_check", TRUE);
        NuiSetBind(oPC, nToken, "chbx_ai_event", JsonBool(TRUE));
        NuiSetBind(oPC, nToken, "btn_ai_event", JsonBool(TRUE));
        if(GetEventScript(oPC, EVENT_SCRIPT_CREATURE_ON_HEARTBEAT) == "xx_pc_1_hb") 
        {
            NuiSetBind(oPC, nToken, "btn_ai", JsonBool(TRUE));
            NuiSetBind(oPC, nToken, "btn_ai_tooltip", JsonString(TOOL_TXT_PLAYER_AI_ON));
        }
        else 
        {
            NuiSetBind(oPC, nToken, "btn_ai", JsonBool(FALSE));
            NuiSetBind(oPC, nToken, "btn_ai_tooltip", JsonString(TOOL_TXT_PLAYER_AI_OFF));
        }
    }
    NuiSetBind(oPC, nToken, "chbx_quiet_check", JsonBool(bReduceSpeech));
    NuiSetBindWatch (oPC, nToken, "chbx_quiet_check", TRUE);
    NuiSetBind(oPC, nToken, "chbx_quiet_event", JsonBool(TRUE));
    NuiSetBind(oPC, nToken, "btn_quiet_event", JsonBool(TRUE));
    if(ai_GetAIMode(oAssociate, AI_MODE_DO_NOT_SPEAK)) 
    {
        NuiSetBind(oPC, nToken, "btn_quiet", JsonBool(TRUE));
        NuiSetBind (oPC, nToken, "btn_quiet_tooltip", JsonString(TOOL_TXT_REDUCE_SPEECH_ON));
    }
    else 
    {
        NuiSetBind(oPC, nToken, "btn_quiet", JsonBool(FALSE));
        NuiSetBind (oPC, nToken, "btn_quiet_tooltip", JsonString(TOOL_TXT_REDUCE_SPEECH_OFF));
    }
    // Row 4
    NuiSetBind(oPC, nToken, "chbx_ranged_check", JsonBool(bRanged));
    NuiSetBindWatch(oPC, nToken, "chbx_ranged_check", TRUE);
    NuiSetBind(oPC, nToken, "chbx_ranged_event", JsonBool(TRUE));
    NuiSetBind(oPC, nToken, "btn_ranged_event", JsonBool(TRUE));
    if(ai_GetAIMode(oAssociate, AI_MODE_STOP_RANGED)) 
    {
        NuiSetBind(oPC, nToken, "btn_ranged", JsonBool(FALSE));
        NuiSetBind (oPC, nToken, "btn_ranged_tooltip", JsonString(TOOL_TXT_RANGED_COMBAT_OFF));
    }
    else 
    {
        NuiSetBind(oPC, nToken, "btn_ranged", JsonBool(TRUE));
        NuiSetBind (oPC, nToken, "btn_ranged_tooltip", JsonString(TOOL_TXT_RANGED_COMBAT_ON));
    }
    NuiSetBind(oPC, nToken, "chbx_equip_weapon_check", JsonBool(bEquipWeapons));
    NuiSetBindWatch(oPC, nToken, "chbx_equip_weapon_check", TRUE);
    NuiSetBind(oPC, nToken, "chbx_equip_weapon_event", JsonBool(TRUE));
    NuiSetBind(oPC, nToken, "btn_equip_weapon_event", JsonBool(TRUE));
    if(ai_GetAIMode(oAssociate, AI_MODE_EQUIP_WEAPON_OFF)) 
    {
        NuiSetBind(oPC, nToken, "btn_equip_weapon", JsonBool(FALSE));
        NuiSetBind (oPC, nToken, "btn_equip_weapon_tooltip", JsonString(TOOL_TXT_AUTO_EQUIP_WEAPONS_OFF));
    }
    else 
    {
        NuiSetBind(oPC, nToken, "btn_equip_weapon", JsonBool(TRUE));
        NuiSetBind (oPC, nToken, "btn_equip_weapon_tooltip", JsonString(TOOL_TXT_AUTO_EQUIP_WEAPONS_ON));
    }
    // Row 5
    if(GetRacialType(oAssociate) != RACIAL_TYPE_ELF)
    {
        NuiSetBind(oPC, nToken, "chbx_search_check", JsonBool(bSearch));
        NuiSetBindWatch (oPC, nToken, "chbx_search_check", TRUE);
        NuiSetBind(oPC, nToken, "chbx_search_event", JsonBool(TRUE));
        NuiSetBind(oPC, nToken, "btn_search_event", JsonBool(TRUE));
        if(ai_GetAIMode(oAssociate, AI_MODE_AGGRESSIVE_SEARCH)) 
        {
            NuiSetBind(oPC, nToken, "btn_search", JsonBool(TRUE));
            NuiSetBind (oPC, nToken, "btn_search_tooltip", JsonString(TOOL_TXT_SEARCH_MODE_ON));
        }
        else
        {
            NuiSetBind(oPC, nToken, "btn_search", JsonBool(FALSE));
            NuiSetBind (oPC, nToken, "btn_search_tooltip", JsonString(TOOL_TXT_SEARCH_MODE_OFF));
        }
    }
    NuiSetBind(oPC, nToken, "chbx_stealth_check", JsonBool(bStealth));
    NuiSetBindWatch(oPC, nToken, "chbx_stealth_check", TRUE);
    NuiSetBind(oPC, nToken, "chbx_stealth_event", JsonBool(TRUE));
    NuiSetBind(oPC, nToken, "btn_stealth_event", JsonBool(TRUE));
    if(ai_GetAIMode(oAssociate, AI_MODE_AGGRESSIVE_STEALTH)) 
    {
        NuiSetBind(oPC, nToken, "btn_stealth", JsonBool(TRUE));
        NuiSetBind (oPC, nToken, "btn_stealth_tooltip", JsonString(TOOL_TXT_STEALTH_MODE_ON));
    }
    else 
    {
        NuiSetBind(oPC, nToken, "btn_stealth", JsonBool(FALSE));
        NuiSetBind (oPC, nToken, "btn_stealth_tooltip", JsonString(TOOL_TXT_STEALTH_MODE_OFF));
    }
    // Row 6
    NuiSetBind(oPC, nToken, "btn_door_up_event", JsonBool(TRUE));
    NuiSetBind(oPC, nToken, "btn_door_down_event", JsonBool(TRUE));
    string sRange = FloatToString(GetLocalFloat(oAssociate, AI_OPEN_DOORS_RANGE), 0, 0);
    NuiSetBind(oPC, nToken, "chbx_open_door_check", JsonBool(bOpenDoors));
    NuiSetBindWatch (oPC, nToken, "chbx_open_door_check", TRUE);
    NuiSetBind(oPC, nToken, "chbx_open_door_event", JsonBool(TRUE));
    NuiSetBind(oPC, nToken, "btn_open_door_event", JsonBool(TRUE));
    NuiSetBind(oPC, nToken, "btn_open_door_label", JsonString(BTN_TXT_OPEN_DOORS + " [" + sRange + "]"));
    if(ai_GetAIMode(oAssociate, AI_MODE_OPEN_DOORS)) 
    {
        NuiSetBind(oPC, nToken, "btn_open_door", JsonBool(TRUE));
        NuiSetBind (oPC, nToken, "btn_open_door_tooltip", JsonString(TOOL_TXT_OPEN_DOORS_ON + sRange + " meters."));
    }
    else 
    {
        NuiSetBind(oPC, nToken, "btn_open_door", JsonBool(FALSE));
        NuiSetBind (oPC, nToken, "btn_open_door_tooltip", JsonString(TOOL_TXT_OPEN_DOORS_OFF));
    }
    NuiSetBind(oPC, nToken, "btn_traps_up_event", JsonBool(TRUE));
    NuiSetBind(oPC, nToken, "btn_traps_down_event", JsonBool(TRUE));
    sRange = FloatToString(GetLocalFloat(oAssociate, AI_TRAP_CHECK_RANGE), 0, 0);
    NuiSetBind(oPC, nToken, "chbx_traps_check", JsonBool(bTraps));
    NuiSetBindWatch (oPC, nToken, "chbx_traps_check", TRUE);
    NuiSetBind(oPC, nToken, "chbx_traps_event", JsonBool(TRUE));
    NuiSetBind(oPC, nToken, "btn_traps_event", JsonBool(TRUE));
    NuiSetBind(oPC, nToken, "btn_traps_label", JsonString(BTN_TXT_REMOVE_TRAPS + " [" + sRange + "]"));
    if(ai_GetAIMode(oAssociate, AI_MODE_DISARM_TRAPS)) 
    {
        NuiSetBind(oPC, nToken, "btn_traps", JsonBool(TRUE));
        NuiSetBind (oPC, nToken, "btn_traps_tooltip", JsonString(TOOL_TXT_REMOVE_TRAPS_ON + sRange + " meters."));
    }
    else 
    {
        NuiSetBind(oPC, nToken, "btn_traps", JsonBool(FALSE));
        NuiSetBind (oPC, nToken, "btn_traps_tooltip", JsonString(TOOL_TXT_REMOVE_TRAPS_OFF));
    }
    // Row 7
    NuiSetBind(oPC, nToken, "btn_pick_up_event", JsonBool(TRUE));
    NuiSetBind(oPC, nToken, "btn_pick_down_event", JsonBool(TRUE));
    sRange = FloatToString(GetLocalFloat(oAssociate, AI_LOCK_CHECK_RANGE), 0, 0);
    NuiSetBind(oPC, nToken, "chbx_pick_locks_check", JsonBool(bPickLocks));
    NuiSetBindWatch(oPC, nToken, "chbx_pick_locks_check", TRUE);
    NuiSetBind(oPC, nToken, "chbx_pick_locks_event", JsonBool(TRUE));
    NuiSetBind(oPC, nToken, "btn_pick_locks_event", JsonBool(TRUE));
    NuiSetBind(oPC, nToken, "btn_pick_locks_label", JsonString(BTN_TXT_PICK_LOCKS_MODE + " [" + sRange + "]"));
    if(ai_GetAIMode(oAssociate, AI_MODE_PICK_LOCKS)) 
    {
        NuiSetBind(oPC, nToken, "btn_pick_locks", JsonBool(TRUE));
        NuiSetBind (oPC, nToken, "btn_pick_locks_tooltip", JsonString(TOOL_TXT_PICK_LOCKS_MODE_ON + sRange + " meters."));
    }
    else 
    {
        NuiSetBind(oPC, nToken, "btn_pick_locks", JsonBool(FALSE));
        NuiSetBind (oPC, nToken, "btn_pick_locks_tooltip", JsonString(TOOL_TXT_PICK_LOCKS_MODE_OFF));
    }
    NuiSetBind(oPC, nToken, "btn_bash_up_event", JsonBool(TRUE));
    NuiSetBind(oPC, nToken, "btn_bash_down_event", JsonBool(TRUE));
    NuiSetBind(oPC, nToken, "chbx_bash_locks_check", JsonBool(bBashLocks));
    NuiSetBindWatch(oPC, nToken, "chbx_bash_locks_check", TRUE);
    NuiSetBind(oPC, nToken, "chbx_bash_locks_event", JsonBool(TRUE));
    NuiSetBind(oPC, nToken, "btn_bash_locks_event", JsonBool(TRUE));
    NuiSetBind(oPC, nToken, "btn_bash_locks_label", JsonString(BTN_TXT_BASH_LOCKS_MODE + " [" + sRange + "]"));
    if(ai_GetAIMode(oAssociate, AI_MODE_BASH_LOCKS))
    {
        NuiSetBind(oPC, nToken, "btn_bash_locks", JsonBool(TRUE));
        NuiSetBind (oPC, nToken, "btn_bash_locks_tooltip", JsonString(TOOL_TXT_BASH_LOCKS_MODE_ON + sRange + " meters."));
    }
    else
    {
        NuiSetBind(oPC, nToken, "btn_bash_locks", JsonBool(FALSE));
        NuiSetBind (oPC, nToken, "btn_bash_locks_tooltip", JsonString(TOOL_TXT_BASH_LOCKS_MODE_OFF));
    }
    // Row 8
    NuiSetBind(oPC, nToken, "btn_magic_up_event", JsonBool(TRUE));
    NuiSetBind(oPC, nToken, "btn_magic_down_event", JsonBool(TRUE));
    int nMagic = GetLocalInt(oAssociate, AI_DIFFICULTY_ADJUSTMENT);
    string sMagic = IntToString(nMagic);
    NuiSetBind(oPC, nToken, "chbx_magic_level_check", JsonBool(bMagicLevel));
    NuiSetBindWatch (oPC, nToken, "chbx_magic_level_check", TRUE);
    NuiSetBind(oPC, nToken, "chbx_magic_level_event", JsonBool(TRUE));
    NuiSetBind(oPC, nToken, "btn_magic_level_event", JsonBool(TRUE));
    NuiSetBind(oPC, nToken, "btn_magic_level_label", JsonString(BTN_TXT_MAGIC_LEVEL + " [" + sMagic + "]"));
    if(nMagic < -49) sText = "  Magic use level " + sMagic + ". " + TOOL_TXT_MAGIC_LEVEL_RARE;
    else if(nMagic < -25) sText = "  Magic use level " + sMagic + ". " + TOOL_TXT_MAGIC_LEVEL_LOW;
    else if(nMagic < 26) sText = "  Magic use level " + sMagic + ". " + TOOL_TXT_MAGIC_LEVEL_NORMAL;
    else if(nMagic < 50) sText = "  Magic use level " + sMagic + ". " + TOOL_TXT_MAGIC_LEVEL_HIGH;
    else if(nMagic > 49) sText = "  Magic use level " + sMagic + ". " + TOOL_TXT_MAGIC_LEVEL_EXCESSIVE;
    NuiSetBind (oPC, nToken, "btn_magic_level_tooltip", JsonString(sText));
    if(sAssociateType != "summons" && sAssociateType != "dominated")
    {
        sRange = FloatToString(GetLocalFloat(oAssociate, AI_LOOT_CHECK_RANGE), 0, 0);
        NuiSetBind(oPC, nToken, "chbx_loot_check", JsonBool(bLoot));
        NuiSetBindWatch (oPC, nToken, "chbx_loot_check", TRUE);
        NuiSetBind(oPC, nToken, "chbx_loot_event", JsonBool(TRUE));
        NuiSetBind(oPC, nToken, "btn_loot_up_event", JsonBool(TRUE));
        NuiSetBind(oPC, nToken, "btn_loot_down_event", JsonBool(TRUE));
        NuiSetBind(oPC, nToken, "btn_loot_event", JsonBool(TRUE));
        if(ai_GetAIMode(oAssociate, AI_MODE_PICKUP_ITEMS)) 
        {
            NuiSetBind(oPC, nToken, "btn_loot", JsonBool(TRUE));
            NuiSetBind(oPC, nToken, "btn_loot_label", JsonString(BTN_TXT_AUTO_LOOT + " [" + sRange + "]"));
            NuiSetBind(oPC, nToken, "btn_loot_tooltip", JsonString(TOOL_TXT_AUTO_LOOT_ON + sRange + " meters."));
        }
        else
        {
            NuiSetBind(oPC, nToken, "btn_loot", JsonBool(FALSE));
            NuiSetBind(oPC, nToken, "btn_loot_label", JsonString(BTN_TXT_AUTO_LOOT + " [" + sRange + "]"));
            NuiSetBind(oPC, nToken, "btn_loot_tooltip", JsonString(TOOL_TXT_AUTO_LOOT_OFF));
        }
    }
    // Row 9
    NuiSetBind(oPC, nToken, "chbx_magic_check", JsonBool(bNoMagic));
    NuiSetBindWatch (oPC, nToken, "chbx_magic_check", TRUE);
    NuiSetBind(oPC, nToken, "chbx_magic_event", JsonBool(TRUE));
    NuiSetBind(oPC, nToken, "btn_magic_event", JsonBool(TRUE));
    if(ai_GetMagicMode(oAssociate, AI_MAGIC_NO_MAGIC))
    {
        NuiSetBind(oPC, nToken, "btn_magic", JsonBool(FALSE));
        NuiSetBind(oPC, nToken, "btn_magic_tooltip", JsonString(TOOL_TXT_USE_MAGIC_OFF));
    }
    else
    {
        NuiSetBind(oPC, nToken, "btn_magic", JsonBool(TRUE));
        NuiSetBind(oPC, nToken, "btn_magic_tooltip", JsonString(TOOL_TXT_USE_MAGIC_ON));
    }
    NuiSetBind(oPC, nToken, "chbx_magic_items_check", JsonBool(bNoMagicItems));
    NuiSetBindWatch (oPC, nToken, "chbx_magic_items_check", TRUE);
    NuiSetBind(oPC, nToken, "chbx_magic_items_event", JsonBool(TRUE));
    NuiSetBind(oPC, nToken, "btn_magic_items_event", JsonBool(TRUE));
    if(ai_GetMagicMode(oAssociate, AI_MAGIC_NO_MAGIC_ITEMS))
    {
        NuiSetBind(oPC, nToken, "btn_magic_items", JsonBool(FALSE));
        NuiSetBind(oPC, nToken, "btn_magic_items_tooltip", JsonString(TOOL_TXT_USE_MAGIC_ITEMS_OFF));
    }
    else
    {
        NuiSetBind(oPC, nToken, "btn_magic_items", JsonBool(TRUE));
        NuiSetBind(oPC, nToken, "btn_magic_items_tooltip", JsonString(TOOL_TXT_USE_MAGIC_ITEMS_ON));
    }
    // Row 10
    NuiSetBind(oPC, nToken, "chbx_magic_use_check", JsonBool (bMagicUse));
    NuiSetBindWatch (oPC, nToken, "chbx_magic_use_check", TRUE);
    NuiSetBind(oPC, nToken, "chbx_magic_use_event", JsonBool(TRUE));
    NuiSetBind(oPC, nToken, "btn_magic_use_event", JsonBool(TRUE));
    if(ai_GetMagicMode(oAssociate, AI_MAGIC_DEFENSIVE_CASTING))
    {
        NuiSetBind(oPC, nToken, "btn_magic_use_label", JsonString(BTN_TXT_MAGIC_USE_DEF));
        NuiSetBind(oPC, nToken, "btn_magic_use_tooltip", JsonString(TOOL_TXT_MAGIC_USE_DEF));
    }
    else if(ai_GetMagicMode(oAssociate, AI_MAGIC_OFFENSIVE_CASTING))
    {
        NuiSetBind(oPC, nToken, "btn_magic_use_label", JsonString(BTN_TXT_MAGIC_USE_OFF));
        NuiSetBind(oPC, nToken, "btn_magic_use_tooltip", JsonString(TOOL_TXT_MAGIC_USE_OFF));
    }
    else 
    {
        NuiSetBind(oPC, nToken, "btn_magic_use_label", JsonString(BTN_TXT_MAGIC_USE_ALL));
        NuiSetBind(oPC, nToken, "btn_magic_use_tooltip", JsonString(TOOL_TXT_MAGIC_USE_ALL));
    }
    NuiSetBind(oPC, nToken, "btn_off_magic_use_up_event", JsonBool(TRUE));
    NuiSetBind(oPC, nToken, "btn_off_magic_use_down_event", JsonBool(TRUE));
    NuiSetBind(oPC, nToken, "chbx_off_magic_use_check", JsonBool(bOffMagicUse));
    NuiSetBindWatch (oPC, nToken, "chbx_off_magic_use_check", TRUE);
    NuiSetBind(oPC, nToken, "chbx_off_magic_use_event", JsonBool(TRUE));
    NuiSetBind(oPC, nToken, "btn_off_magic_use_event", JsonBool(TRUE));
    nMagic = GetLocalInt(oAssociate, AI_AOE_ALLY_LIMIT);
    sMagic = IntToString(nMagic);
    NuiSetBind(oPC, nToken, "btn_off_magic_use_label", JsonString(BTN_TXT_OFF_MAGIC_USE + " [" + sMagic + "]"));
    NuiSetBind(oPC, nToken, "btn_off_magic_use_tooltip", JsonString(TOOL_TXT_OFF_MAGIC_USE_START + sMagic + TOOL_TXT_OFF_MAGIC_USE_END));
    // Row 11
    NuiSetBind(oPC, nToken, "btn_heal_out_up_event", JsonBool(TRUE));
    NuiSetBind(oPC, nToken, "btn_heal_out_down_event", JsonBool(TRUE));
    string sHeal = IntToString(GetLocalInt(oAssociate, AI_HEAL_OUT_OF_COMBAT_LIMIT));
    NuiSetBind(oPC, nToken, "chbx_heal_out_check", JsonBool(bHealOut));
    NuiSetBindWatch (oPC, nToken, "chbx_heal_out_check", TRUE);
    NuiSetBind(oPC, nToken, "chbx_heal_out_event", JsonBool(TRUE));
    NuiSetBind(oPC, nToken, "btn_heal_out_event", JsonBool(TRUE));
    NuiSetBind(oPC, nToken, "btn_heal_out_label", JsonString(BTN_TXT_HEAL_OUT_OF_COMBAT + " [" + sHeal + "%]"));
    NuiSetBind(oPC, nToken, "btn_heal_out_tooltip", JsonString(TOOL_TXT_HEAL_OUT_OF_COMBAT + sHeal + "%."));
    NuiSetBind(oPC, nToken, "btn_heal_in_up_event", JsonBool(TRUE));
    NuiSetBind(oPC, nToken, "btn_heal_in_down_event", JsonBool(TRUE));
    string sHealIn = IntToString(GetLocalInt(oAssociate, AI_HEAL_IN_COMBAT_LIMIT));
    NuiSetBind(oPC, nToken, "chbx_heal_in_check", JsonBool(bHealIn));
    NuiSetBindWatch (oPC, nToken, "chbx_heal_in_check", TRUE);
    NuiSetBind(oPC, nToken, "chbx_heal_in_event", JsonBool(TRUE));
    NuiSetBind(oPC, nToken, "btn_heal_in_event", JsonBool (TRUE));
    NuiSetBind(oPC, nToken, "btn_heal_in_label", JsonString(BTN_TXT_HEAL_IN_COMBAT + " [" + sHealIn + "%]"));
    NuiSetBind(oPC, nToken, "btn_heal_in_tooltip", JsonString(TOOL_TXT_HEAL_IN_COMBAT + sHealIn + "%."));
    // Row 12
    NuiSetBind(oPC, nToken, "chbx_heals_onoff_check", JsonBool(bSelfHealOnOff));
    NuiSetBindWatch (oPC, nToken, "chbx_heals_onoff_check", TRUE);
    NuiSetBind(oPC, nToken, "chbx_heals_onoff_event", JsonBool(TRUE));
    NuiSetBind(oPC, nToken, "btn_heals_onoff_event", JsonBool(TRUE));
    if(ai_GetAIMode(oAssociate, AI_MODE_SELF_HEALING_OFF)) 
    {
        NuiSetBind(oPC, nToken, "btn_heals_onoff", JsonBool(FALSE));
        NuiSetBind(oPC, nToken, "btn_heals_onoff_tooltip", JsonString(TOOL_TXT_STOP_SELF_HEALING_OFF));
    }
    else
    {
        NuiSetBind(oPC, nToken, "btn_heals_onoff", JsonBool(TRUE));
        NuiSetBind(oPC, nToken, "btn_heals_onoff_tooltip", JsonString(TOOL_TXT_STOP_SELF_HEALING_ON));
    }
    NuiSetBind(oPC, nToken, "chbx_healp_onoff_check", JsonBool(bPartyHealOnOff));
    NuiSetBind(oPC, nToken, "chbx_healp_onoff_event", JsonBool(TRUE));
    NuiSetBindWatch (oPC, nToken, "chbx_healp_onoff_check", TRUE);
    NuiSetBind(oPC, nToken, "btn_healp_onoff_event", JsonBool(TRUE));
    if(ai_GetAIMode(oAssociate, AI_MODE_PARTY_HEALING_OFF)) 
    { 
        NuiSetBind(oPC, nToken, "btn_healp_onoff", JsonBool(FALSE));
        NuiSetBind(oPC, nToken, "btn_healp_onoff_tooltip", JsonString(TOOL_TXT_STOP_PARTY_HEALING_OFF));
    }
    else
    { 
        NuiSetBind(oPC, nToken, "btn_healp_onoff", JsonBool(TRUE));
        NuiSetBind(oPC, nToken, "btn_healp_onoff_tooltip", JsonString(TOOL_TXT_STOP_PARTY_HEALING_ON));
    }
    // Row 13
    NuiSetBind(oPC, nToken, "btn_cure_onoff_tooltip", JsonString(sText));
    NuiSetBind(oPC, nToken, "chbx_cure_onoff_check", JsonBool(bCureOnOff));
    NuiSetBind(oPC, nToken, "chbx_cure_onoff_event", JsonBool(TRUE));
    NuiSetBindWatch (oPC, nToken, "chbx_cure_onoff_check", TRUE);
    NuiSetBind(oPC, nToken, "btn_cure_onoff_event", JsonBool(TRUE));
    if(ai_GetMagicMode(oAssociate, AI_MAGIC_CURE_SPELLS_OFF)) 
    {
        NuiSetBind(oPC, nToken, "btn_cure_onoff", JsonBool(FALSE));
        NuiSetBind(oPC, nToken, "btn_cure_onoff_tooltip", JsonString(TOOL_TXT_CAST_CURE_SPELLS_OFF));
    }
    else 
    {
        NuiSetBind(oPC, nToken, "btn_cure_onoff", JsonBool(TRUE));
        NuiSetBind(oPC, nToken, "btn_cure_onoff_tooltip", JsonString(TOOL_TXT_CAST_CURE_SPELLS_ON));
    }
    NuiSetBind(oPC, nToken, "chbx_spontaneous_check", JsonBool(bSpontaneous));
    NuiSetBindWatch (oPC, nToken, "chbx_spontaneous_check", TRUE);
    NuiSetBind(oPC, nToken, "chbx_spontaneous_event", JsonBool(TRUE));
    NuiSetBind(oPC, nToken, "btn_spontaneous_event", JsonBool(TRUE));
    if(ai_GetMagicMode(oAssociate, AI_MAGIC_NO_SPONTANEOUS_CURE)) 
    {
        NuiSetBind(oPC, nToken, "btn_spontaneous", JsonBool(FALSE));
        NuiSetBind(oPC, nToken, "btn_spontaneous_tooltip", JsonString(TOOL_TXT_SPONTANEOUS_CASTING_OFF));
    }
    else 
    {
        NuiSetBind(oPC, nToken, "btn_spontaneous", JsonBool(TRUE));
        NuiSetBind(oPC, nToken, "btn_spontaneous_tooltip", JsonString(TOOL_TXT_SPONTANEOUS_CASTING_ON));
    }
    // Row 14
    NuiSetBind(oPC, nToken, "chbx_ignore_assoc_check", JsonBool(bIgnoreAssociates));
    NuiSetBindWatch(oPC, nToken, "chbx_ignore_assoc_check", TRUE);
    NuiSetBind(oPC, nToken, "chbx_ignore_assoc_event", JsonBool(TRUE));
    NuiSetBind(oPC, nToken, "btn_ignore_assoc_event", JsonBool(TRUE));
    if(ai_GetAIMode(oAssociate, AI_MODE_IGNORE_ASSOCIATES)) 
    {
        NuiSetBind(oPC, nToken, "btn_ignore_assoc", JsonBool(TRUE));
        NuiSetBind (oPC, nToken, "btn_ignore_assoc_tooltip", JsonString(TOOL_IGNORE_ASSOCIATES_ON));
    }
    else
    {
        NuiSetBind(oPC, nToken, "btn_ignore_assoc", JsonBool(FALSE));
        NuiSetBind (oPC, nToken, "btn_ignore_assoc_tooltip", JsonString(TOOL_IGNORE_ASSOCIATES_OFF));
    }
    NuiSetBind(oPC, nToken, "chbx_ignore_traps_check", JsonBool(bIgnoreTraps));
    NuiSetBindWatch(oPC, nToken, "chbx_ignore_traps_check", TRUE);
    NuiSetBind(oPC, nToken, "chbx_ignore_traps_event", JsonBool(TRUE));
    NuiSetBind(oPC, nToken, "btn_ignore_traps_event", JsonBool(TRUE));
    if(ai_GetAIMode(oAssociate, AI_MODE_IGNORE_TRAPS))
    {
        NuiSetBind(oPC, nToken, "btn_ignore_traps", JsonBool(TRUE));
        NuiSetBind (oPC, nToken, "btn_ignore_traps_tooltip", JsonString(TOOL_IGNORE_TRAPS_ON));
    }
    else
    {
        NuiSetBind(oPC, nToken, "btn_ignore_traps", JsonBool(FALSE));
        NuiSetBind (oPC, nToken, "btn_ignore_traps_tooltip", JsonString(TOOL_IGNORE_TRAPS_OFF));
    }
    if(GetAssociateType(oAssociate) == ASSOCIATE_TYPE_HENCHMAN)
    {
        int nRange = GetLocalInt(oAssociate, AI_ASSOCIATE_PERCEPTION + "_MENU");
        if(nRange < 8 || nRange > 11)
        {
            nRange = GetLocalInt(oAssociate, AI_ASSOCIATE_PERCEPTION);
            SetLocalInt(oAssociate, AI_ASSOCIATE_PERCEPTION + "_MENU", nRange);
        }
        if(nRange == 8) sText = TOOL_PERCEPTION_RANGE_8;
        else if(nRange == 9) sText = TOOL_PERCEPTION_RANGE_9;
        else if(nRange == 10) sText = TOOL_PERCEPTION_RANGE_10;
        else sText = TOOL_PERCEPTION_RANGE_DEFAULT;
        NuiSetBind(oPC, nToken, "chbx_perc_range_check", JsonBool(bPercRange));
        NuiSetBindWatch (oPC, nToken, "chbx_perc_range_check", TRUE);
        NuiSetBind(oPC, nToken, "chbx_perc_range_event", JsonBool(TRUE));
        NuiSetBind(oPC, nToken, "btn_perc_range_event", JsonBool(TRUE));
        NuiSetBind(oPC, nToken, "btn_perc_range_tooltip", JsonString(sText));
        NuiSetBind(oPC, nToken, "lbl_perc_range_label", JsonString(sText));
    }
    // Row 16
    string sScript = GetLocalString(oAssociate, AI_COMBAT_SCRIPT);
    if(sScript == "") sScript = GetLocalString(oAssociate, AI_COMBAT_SCRIPT);
    NuiSetBind(oPC, nToken, "btn_ai_script_event", JsonBool(TRUE));
    NuiSetBind(oPC, nToken, "btn_ai_script_tooltip", JsonString(TOOL_TXT_CURRENT_AI));
    NuiSetBind(oPC, nToken, "txt_ai_script_event", JsonBool(TRUE));
    NuiSetBind(oPC, nToken, "txt_ai_script", JsonString(sScript));
    NuiSetBind(oPC, nToken, "txt_ai_script_tooltip", JsonString(TXT_TXT_CURRENT_AI));
    NuiSetBind(oPC, nToken, "btn_select_ai_event", JsonBool(TRUE));
    NuiSetBind(oPC, nToken, "btn_select_ai_tooltip", JsonString(TOOL_TXT_SELECT_AI));    
    //NuiSetBind(oPC, nToken, "cmb_ai_script_event", JsonBool(TRUE));
    //NuiSetBindWatch(oPC, nToken, "cmb_ai_script_selected", TRUE);
    // Row 17
    sText = ai_GetRandomTip();
    NuiSetBind (oPC, nToken, "lbl_info_label", JsonString(sText));
}
void ai_CreateAISelectMobileNUI(object oPC, object oAssociate)
{
    // ************************************************************************* Width / Height
    // Row 1 ******************************************************************* 318 / 73
    json jButton = JsonArray();
    jButton = NuiButton(NuiBind("text_script"));
    jButton = NuiId(jButton, "btn_text_script");
    json jListTemplate = JsonArrayInsert(JsonArray(), NuiListTemplateCell(jButton, 325.0, FALSE));
    json jRow = JsonArrayInsert(JsonArray(), NuiHeight(NuiList(jListTemplate, NuiBind("list_script"), 35.0), 350.0));
    json jCol = JsonArrayInsert(JsonArray(), NuiRow(jRow));
    // Set the Layout of the window.
    json jLayout = NuiCol(jCol);
    string sName = ai_StripColorCodes(GetName(oAssociate));
    string sAssociateType = ai_GetAssociateType(oPC, oAssociate);
    int nToken = SetWindow(oPC, jLayout, sAssociateType + "AI_SELECT", " Select AI for " + sName,
                           -1.0, -1.0, 375.0, 475.0, FALSE, FALSE, TRUE, FALSE, TRUE, "0e_nui");
    // Save the associate to the nui.
    json jData = JsonArrayInsert(JsonArray(), JsonString(ObjectToString(oAssociate)));
    NuiSetUserData(oPC, nToken, jData);
    json jScript = JsonArrayInsert(JsonArray(), JsonString("Cancel"));
    int nIndex = 1;
    string sScript = ResManFindPrefix("ai_a_", RESTYPE_NCS, nIndex);
    while(sScript != "")
    {
        jScript = JsonArrayInsert(jScript, JsonString(sScript));
        sScript = ResManFindPrefix("ai_a_", RESTYPE_NCS, ++nIndex);
    }    
    NuiSetBind(oPC, nToken, "list_script", jScript); 
    NuiSetBind(oPC, nToken, "text_script", jScript); 
}
void ai_CreateLootFilterMobileNUI(object oPC, object oAssociate)
{
    // Set window to not save until it has been created.
    SetLocalInt (oPC, AI_NO_NUI_SAVE, TRUE);
    DelayCommand (2.0, DeleteLocalInt (oPC, AI_NO_NUI_SAVE));
    // ************************************************************************* Width / Height
    // Row 1 ******************************************************************* 318 / 73
    json jRow = JsonArrayInsert(JsonArray(), NuiSpacer());
    jRow = CreateCheckBox(jRow, "Give all loot to the player", "chbx_give_loot", 200.0, 20.0, "chbx_give_loot_tooltip");
    jRow = JsonArrayInsert(jRow, NuiSpacer());
    json jCol = JsonArrayInsert(JsonArray(), NuiRow(jRow));
    // Row 2 *************************************************************** 388 / 101
    jRow = JsonArrayInsert(JsonArray(), NuiSpacer());
    jRow = CreateTextEditBox(jRow, "plc_hold", "txt_max_weight", 9, FALSE, 50.0, 20.0, "txt_max_weight_tooltip");
    jRow = CreateLabel(jRow, "Maximum Weight to pickup", "lbl_weight", 200.0, 20.0, NUI_HALIGN_CENTER);
    jRow = JsonArrayInsert(jRow, NuiSpacer());
    jCol = JsonArrayInsert(jCol, NuiRow(jRow));
    // Row 3 *************************************************************** 388 / 129
    jRow = CreateButton(JsonArray(), "Set All", "btn_set_all", 110.0, 30.0);
    jRow = JsonArrayInsert(jRow, NuiSpacer());
    jRow = CreateButton(jRow, "Close", "btn_close", 110.0f, 30.0f);
    jRow = JsonArrayInsert(jRow, NuiSpacer());
    jRow = CreateButton(jRow, "Clear All", "btn_clear_all", 110.0, 30.0);
    jCol = JsonArrayInsert(jCol, NuiRow(jRow));
    // Row 4 *************************************************************** 388 / 129
    jRow = JsonArrayInsert(JsonArray(), NuiSpacer());
    jRow = CreateLabel(jRow, "Minimum Gold", "lbl_min_gold", 100.0, 20.0, NUI_HALIGN_CENTER);
    jRow = JsonArrayInsert(jRow, NuiSpacer());
    jRow = CreateLabel(jRow, "Items to Pickup", "lbl_pickup", 140.0, 20.0, NUI_HALIGN_CENTER);
    jRow = JsonArrayInsert(jRow, NuiSpacer());
    jCol = JsonArrayInsert(jCol, NuiRow(jRow));
    // Row 5 *************************************************************** 388 / 157
    jRow = ai_CreateLootFilterRow(JsonArray(), "Plot items", 2);
    jCol = JsonArrayInsert(jCol, NuiRow(jRow));
    // Row 6 *************************************************************** 388 / 185
    jRow = ai_CreateLootFilterRow(JsonArray(), "Armor", 3);
    jCol = JsonArrayInsert(jCol, NuiRow(jRow));
    // Row 7 *************************************************************** 388 / 213
    jRow = ai_CreateLootFilterRow(JsonArray(), "Belts", 4);
    jCol = JsonArrayInsert(jCol, NuiRow(jRow));
    // Row 8 *************************************************************** 388 / 241
    jRow = ai_CreateLootFilterRow(JsonArray(), "Boots", 5);
    jCol = JsonArrayInsert(jCol, NuiRow(jRow));
    // Row 9 *************************************************************** 388 / 269
    jRow = ai_CreateLootFilterRow(JsonArray(), "Cloaks", 6);
    jCol = JsonArrayInsert(jCol, NuiRow(jRow));
    // Row 10 *************************************************************** 388 / 297
    jRow = ai_CreateLootFilterRow(JsonArray(), "Gems", 7);
    jCol = JsonArrayInsert(jCol, NuiRow(jRow));
    // Row 11 *************************************************************** 388 / 325
    jRow = ai_CreateLootFilterRow(JsonArray(), "Gloves and Bracers", 8);
    jCol = JsonArrayInsert(jCol, NuiRow(jRow));
    // Row 12 *************************************************************** 388 / 353
    jRow = ai_CreateLootFilterRow(JsonArray(), "Headgear", 9);
    jCol = JsonArrayInsert(jCol, NuiRow(jRow));
    // Row 13 *************************************************************** 388 / 381
    jRow = ai_CreateLootFilterRow(JsonArray(), "Jewelry", 10);
    jCol = JsonArrayInsert(jCol, NuiRow(jRow));
    // Row 14 *************************************************************** 388 / 409
    jRow = ai_CreateLootFilterRow(JsonArray(), "Miscellaneous items", 11);
    jCol = JsonArrayInsert(jCol, NuiRow(jRow));
    // Row 15 *************************************************************** 388 / 437
    jRow = ai_CreateLootFilterRow(JsonArray(), "Potions", 12);
    jCol = JsonArrayInsert(jCol, NuiRow(jRow));
    // Row 16 *************************************************************** 388 / 465
    jRow = ai_CreateLootFilterRow(JsonArray(), "Scrolls", 13);
    jCol = JsonArrayInsert(jCol, NuiRow(jRow));
    // Row 17 *************************************************************** 388 / 493
    jRow = ai_CreateLootFilterRow(JsonArray(), "Shields", 14);
    jCol = JsonArrayInsert(jCol, NuiRow(jRow));
    // Row 18 *************************************************************** 388 / 521
    jRow = ai_CreateLootFilterRow(JsonArray(), "Wands, Rods, and Staves", 15);
    jCol = JsonArrayInsert(jCol, NuiRow(jRow));
    // Row 19 ************************************************************** 388 / 549
    jRow = ai_CreateLootFilterRow(JsonArray(), "Weapons", 16);
    jCol = JsonArrayInsert(jCol, NuiRow(jRow));
    // Row 20 ************************************************************** 388 / 577
    jRow = ai_CreateLootFilterRow(JsonArray(), "Arrows", 17);
    jCol = JsonArrayInsert(jCol, NuiRow(jRow));
    // Row 21 ************************************************************** 388 / 605
    jRow = ai_CreateLootFilterRow(JsonArray(), "Bolts", 18);
    jCol = JsonArrayInsert(jCol, NuiRow(jRow));
    // Row 22 ************************************************************** 388 / 633
    jRow = ai_CreateLootFilterRow(JsonArray(), "Bullets", 19);
    jCol = JsonArrayInsert(jCol, NuiRow(jRow));
    // Row 23 ************************************************************** 388 / 661
    jRow = ai_CreateLootFilterRow(JsonArray(), "Healing Kits", 20);
    jCol = JsonArrayInsert(jCol, NuiRow(jRow));
    // Row 24 ************************************************************** 388 / 661
    jRow = ai_CreateLootFilterRow(JsonArray(), "Thieves' Tools", 21);
    jCol = JsonArrayInsert(jCol, NuiRow(jRow));
    string sAssociateType = ai_GetAssociateType(oPC, oAssociate);
    // Get the window location to restore it from the database.
    float fX, fY;
    json jLocations = ai_GetAssociateDbJson(oPC, sAssociateType, "locations");
    jLocations = JsonObjectGet(jLocations, sAssociateType + AI_LOOTFILTER_NUI);
    if(JsonGetType(jLocations) == JSON_TYPE_NULL) { fX = -1.0; fY = -1.0; }
    else
    {
        fX = JsonGetFloat(JsonObjectGet(jLocations, "x"));
        fY = JsonGetFloat(JsonObjectGet(jLocations, "y"));
    }
    // Set the Layout of the window.
    json jLayout = NuiCol(jCol);
    string sText, sName = ai_StripColorCodes(GetName(oAssociate));
    if(GetStringRight(sName, 1) == "s") sName = sName + "'";
    else sName = sName + "'s";
    int nToken = SetWindow(oPC, jLayout, sAssociateType + AI_LOOTFILTER_NUI, sName + " Loot Filter",
                           fX, fY, 350.0, 729.0, FALSE, FALSE, TRUE, FALSE, TRUE, "0e_nui");
    // Save the associate to the nui.
    json jData = JsonArrayInsert(JsonArray(), JsonString(ObjectToString(oAssociate)));
    NuiSetUserData(oPC, nToken, jData);
    // Set event watches for save window location.
    NuiSetBindWatch(oPC, nToken, "window_geometry", TRUE);
    // Set all binds, events, and watches.
    // Row 1
    int bGiveLoot = ai_GetLootFilter(oAssociate, AI_LOOT_GIVE_TO_PC);
    NuiSetBind(oPC, nToken, "chbx_give_loot_check", JsonBool (bGiveLoot));
    NuiSetBindWatch (oPC, nToken, "chbx_give_loot_check", TRUE);
    NuiSetBind(oPC, nToken, "chbx_give_loot_event", JsonBool(TRUE));
    NuiSetBind(oPC, nToken, "chbx_give_loot_tooltip", JsonString(
               "  Check this to make henchman give any loot picked up to the player."));
    // Row 2
    int nWeight = GetLocalInt(oAssociate, AI_MAX_LOOT_WEIGHT);
    if(nWeight == 0)
    {
        nWeight = 200;
        SetLocalInt(oAssociate, AI_MAX_LOOT_WEIGHT, nWeight);
    }
    NuiSetBind(oPC, nToken, "txt_max_weight_event", JsonBool(TRUE));
    NuiSetBind(oPC, nToken, "txt_max_weight", JsonString(IntToString(nWeight)));
    NuiSetBindWatch (oPC, nToken, "txt_max_weight", TRUE);
    NuiSetBind(oPC, nToken, "txt_max_weight_tooltip", JsonString("  Max weighted item you will pickup from 1 to 1,000"));
    // Row 3
    NuiSetBind(oPC, nToken, "btn_set_all_event", JsonBool (TRUE));
    NuiSetBind(oPC, nToken, "btn_close_event", JsonBool(TRUE));
    NuiSetBind(oPC, nToken, "btn_clear_all_event", JsonBool (TRUE));
    // Row 4
    ai_SetupLootElements(oPC, oAssociate, nToken, AI_LOOT_PLOT, 2);
    // Row 5
    ai_SetupLootElements(oPC, oAssociate, nToken, AI_LOOT_ARMOR, 3);
    // Row 6
    ai_SetupLootElements(oPC, oAssociate, nToken, AI_LOOT_BELTS, 4);
    // Row 7
    ai_SetupLootElements(oPC, oAssociate, nToken, AI_LOOT_BOOTS, 5);
    // Row 8
    ai_SetupLootElements(oPC, oAssociate, nToken, AI_LOOT_CLOAKS, 6);
    // Row 9
    ai_SetupLootElements(oPC, oAssociate, nToken, AI_LOOT_GEMS, 7);
    // Row 10
    ai_SetupLootElements(oPC, oAssociate, nToken, AI_LOOT_GLOVES, 8);
    // Row 11
    ai_SetupLootElements(oPC, oAssociate, nToken, AI_LOOT_HEADGEAR, 9);
    // Row 12
    ai_SetupLootElements(oPC, oAssociate, nToken, AI_LOOT_JEWELRY, 10);
    // Row 13
    ai_SetupLootElements(oPC, oAssociate, nToken, AI_LOOT_MISC, 11);
    // Row 14
    ai_SetupLootElements(oPC, oAssociate, nToken, AI_LOOT_POTIONS, 12);
    // Row 15
    ai_SetupLootElements(oPC, oAssociate, nToken, AI_LOOT_SCROLLS, 13);
    // Row 16
    ai_SetupLootElements(oPC, oAssociate, nToken, AI_LOOT_SHIELDS, 14);
    // Row 17
    ai_SetupLootElements(oPC, oAssociate, nToken, AI_LOOT_WANDS_RODS_STAVES, 15);
    // Row 18
    ai_SetupLootElements(oPC, oAssociate, nToken, AI_LOOT_WEAPONS, 16);
    // Row 19
    ai_SetupLootElements(oPC, oAssociate, nToken, AI_LOOT_ARROWS, 17);
    // Row 20
    ai_SetupLootElements(oPC, oAssociate, nToken, AI_LOOT_BOLTS, 18);
    // Row 21
    ai_SetupLootElements(oPC, oAssociate, nToken, AI_LOOT_BULLETS, 19);
    // Row 22
    ai_SetupLootElements(oPC, oAssociate, nToken, AI_LOOT_HEALING_KITS, 20);
    // Row 23
    ai_SetupLootElements(oPC, oAssociate, nToken, AI_LOOT_THIEVES_TOOLS, 21);
}
void ai_CreateCopySettingsMobileNUI(object oPC, object oAssociate)
{
    // Set window to not save until it has been created.
    SetLocalInt (oPC, AI_NO_NUI_SAVE, TRUE);
    DelayCommand (2.0, DeleteLocalInt (oPC, AI_NO_NUI_SAVE));
    // ************************************************************************* Width / Height
    // Row 1 ******************************************************************* 244 / 73
    string sName = ai_StripColorCodes(GetName(oAssociate));
    if(GetStringRight(sName, 1) == "s") sName = sName + "'";
    else sName = sName + "'s";
    json jRow = JsonArrayInsert(JsonArray(), NuiSpacer());
    jRow = CreateLabel(jRow, "Copy settings to", "lbl_paste", 220.0, 20.0, NUI_HALIGN_CENTER);
    jRow = JsonArrayInsert(jRow, NuiSpacer());
    // Add row to the column.
    json jCol = JsonArrayInsert(JsonArray(), NuiRow(jRow));
    // Row 2 ******************************************************************* 244 / 101
    jRow = JsonArrayInsert(JsonArray(), NuiSpacer());
    jRow = CreateButton(jRow, "All Associates", "btn_paste_all", 220.0, 20.0);
    jRow = JsonArrayInsert(jRow, NuiSpacer());
    // Add row to the column.
    jCol = JsonArrayInsert(jCol, NuiRow(jRow));
    // Row 2 ******************************************************************* 244 / 129
    jRow = JsonArrayInsert(JsonArray(), NuiSpacer());
    jRow = CreateButton(jRow, "Familiar", "btn_paste_familiar", 220.0, 20.0);
    jRow = JsonArrayInsert(jRow, NuiSpacer());
    // Add row to the column.
    jCol = JsonArrayInsert(jCol, NuiRow(jRow));
    // Row 3 ******************************************************************* 244 / 157
    jRow = JsonArrayInsert(JsonArray(), NuiSpacer());
    jRow = CreateButton(jRow, "Companion", "btn_paste_companion", 220.0, 20.0);
    jRow = JsonArrayInsert(jRow, NuiSpacer());
    // Add row to the column.
    jCol = JsonArrayInsert(jCol, NuiRow(jRow));
    // Row 4 ******************************************************************* 244 / 213
    jRow = JsonArrayInsert(JsonArray(), NuiSpacer());
    jRow = CreateButton(jRow, "Dominated", "btn_paste_dominated", 220.0, 20.0);
    jRow = JsonArrayInsert(jRow, NuiSpacer());
    // Add row to the column.
    jCol = JsonArrayInsert(jCol, NuiRow(jRow));
    // Row 5+ ******************************************************************* 244 / 185
    float fHeight = 213.0;
    int nIndex;
    string sAssocName;
    object oAssoc;
    for(nIndex = 1; nIndex < AI_MAX_HENCHMAN; nIndex++)
    {
        oAssoc = GetAssociate(ASSOCIATE_TYPE_SUMMONED, oPC, nIndex);
        if(oAssoc != OBJECT_INVALID)
        {
            sAssocName = GetName(oAssoc);
            if(GetStringRight(sAssocName, 1) == "s") sAssocName = sAssocName + "'";
            else sAssocName = sAssocName + "'s";
            jRow = CreateButton(JsonArray(), sAssocName, "btn_paste_summons" + IntToString(nIndex), 220.0, 20.0);
            // Add row to the column.
            jCol = JsonArrayInsert(jCol, NuiRow(jRow));
            fHeight += 28.0;
        }
        else break;
    }
    // Row 5+ ****************************************************************** 244 / 241
    for(nIndex = 1; nIndex < AI_MAX_HENCHMAN; nIndex++)
    {
        oAssoc = GetAssociate(ASSOCIATE_TYPE_HENCHMAN, oPC, nIndex);
        if(oAssoc != OBJECT_INVALID)
        {
            sAssocName = GetName(oAssoc);
            if(GetStringRight(sAssocName, 1) == "s") sAssocName = sAssocName + "'";
            else sAssocName = sAssocName + "'s";
            jRow = CreateButton(JsonArray(), sAssocName, "btn_paste_henchman" + IntToString(nIndex), 220.0, 20.0);
            // Add row to the column.
            jCol = JsonArrayInsert(jCol, NuiRow(jRow));
            fHeight += 28.0;
        }
        else break;
    }
    string sAssociateType = ai_GetAssociateType(oPC, oAssociate);
    // Get the window location to restore it from the database.
    float fX, fY;
    json jLocations = ai_GetAssociateDbJson(oPC, sAssociateType, "locations");
    jLocations = JsonObjectGet(jLocations, sAssociateType + AI_COPY_NUI);
    if(JsonGetType(jLocations) == JSON_TYPE_NULL) { fX = -1.0; fY = -1.0; }
    else
    {
        fX = JsonGetFloat(JsonObjectGet(jLocations, "x"));
        fY = JsonGetFloat(JsonObjectGet(jLocations, "y"));
    }
    // Set the Layout of the window.
    json jLayout = NuiCol(jCol);
    int nToken = SetWindow(oPC, jLayout, sAssociateType + AI_COPY_NUI, sName + " Copy Settings Menu",
                           fX, fY, 244.0, fHeight + 12.0, FALSE, FALSE, TRUE, FALSE, TRUE, "0e_nui");
    // Save the associate to the nui.
    json jData = JsonArrayInsert(JsonArray(), JsonString(ObjectToString(oAssociate)));
    NuiSetUserData(oPC, nToken, jData);
    // Set event watches for save window location.
    NuiSetBindWatch(oPC, nToken, "window_geometry", TRUE);
    // Set all binds, events, and watches.
    // Row 1
    NuiSetBind(oPC, nToken, "btn_paste_all_event", JsonBool (TRUE));
    oAssoc = GetAssociate(ASSOCIATE_TYPE_FAMILIAR, oPC);
    NuiSetBind(oPC, nToken, "btn_paste_familiar_event", JsonBool(oAssoc != oAssociate && oAssoc != OBJECT_INVALID));
    oAssoc = GetAssociate(ASSOCIATE_TYPE_ANIMALCOMPANION, oPC);
    NuiSetBind(oPC, nToken, "btn_paste_companion_event", JsonBool(oAssoc != oAssociate && oAssoc != OBJECT_INVALID));
    oAssoc = GetAssociate(ASSOCIATE_TYPE_SUMMONED, oPC);
    NuiSetBind(oPC, nToken, "btn_paste_summons_event", JsonBool(oAssoc != oAssociate && oAssoc != OBJECT_INVALID));
    oAssoc = GetAssociate(ASSOCIATE_TYPE_DOMINATED, oPC);
    NuiSetBind(oPC, nToken, "btn_paste_dominated_event", JsonBool(oAssoc != oAssociate && oAssoc != OBJECT_INVALID));
    for(nIndex = 1; nIndex < AI_MAX_HENCHMAN; nIndex++)
    {
        oAssoc = GetAssociate(ASSOCIATE_TYPE_HENCHMAN, oPC, nIndex);
        if(oAssoc != OBJECT_INVALID)
        {
            NuiSetBind(oPC, nToken, "btn_paste_henchman" + IntToString(nIndex) + "_event", JsonBool(oAssoc != oAssociate));
        }
        else break;
    }
}
void ai_CreatePluginMobileNUI(object oPC)
{
    // Set window to not save until it has been created.
    SetLocalInt (oPC, AI_NO_NUI_SAVE, TRUE);
    DelayCommand (2.0, DeleteLocalInt (oPC, AI_NO_NUI_SAVE));
    int nIndex, nButton;
    string sButton;
    // Row 1 ******************************************************************* 500 / 73
    json jRow = CreateButton(JsonArray(), "Load Plugins", "btn_load_plugins", 150.0f, 20.0f, -1.0, "btn_load_plugins_tooltip");
    jRow = JsonArrayInsert(jRow, NuiSpacer());
    jRow = CreateButton(jRow, "Load Monster Mods", "btn_load_m_mods", 150.0f, 20.0f, -1.0, "btn_load_m_mods_tooltip");
    jRow = JsonArrayInsert(jRow, NuiSpacer());
    jRow = CreateButton(jRow, "Check All", "btn_check_plugins", 80.0f, 20.0f, -1.0, "btn_check_plugins_tooltip");
    jRow = JsonArrayInsert(jRow, NuiSpacer());
    jRow = CreateButton(jRow, "Clear All", "btn_clear_plugins", 80.0f, 20.0f, -1.0, "btn_clear_plugins_tooltip");
    // Add row to the column.
    json jCol = JsonArrayInsert(JsonArray(), NuiRow(jRow));
    // Row 2 ******************************************************************* 500 / 101
    jRow = JsonArrayInsert(JsonArray(), NuiSpacer());
    jRow = CreateButton(jRow, "Add Plugin", "btn_add_plugin", 150.0f, 20.0f);
    jRow = JsonArrayInsert(jRow, NuiSpacer());
    jRow = CreateTextEditBox(jRow, "sPlaceHolder", "txt_plugin", 16, FALSE, 310.0f, 20.0f, "txt_plugin_tooltip");
    jRow = JsonArrayInsert(jRow, NuiSpacer());
    // Add row to the column.
    jCol = JsonArrayInsert(jCol, NuiRow(jRow));
    float fHeight = 101.0;
    // Row 3+ ****************************************************************** 500 / ---
    json jPlugins = ai_GetAssociateDbJson(oPC, "pc", "plugins");
    nIndex = 0;
    json jPlugin = JsonArrayGet(jPlugins, nIndex);
    string sName;
    while(JsonGetType(jPlugin) != JSON_TYPE_NULL)
    {
        sButton = IntToString(nIndex);
        jRow = JsonArrayInsert(JsonArray(), NuiSpacer());
        jRow = CreateButton(jRow, "Remove Plugin", "btn_remove_plugin_" + sButton, 150.0f, 20.0f);
        jRow = JsonArrayInsert(jRow, NuiSpacer());
        sName = JsonGetString(JsonArrayGet(jPlugin, 2));
        jRow = CreateButton(jRow, sName, "btn_plugin_" + sButton, 290.0f, 20.0f, -1.0, "btn_plugin_" + sButton + "_tooltip");
        jRow = CreateCheckBox(jRow, "", "chbx_plugin_" + sButton, 25.0, 20.0);
        jRow = JsonArrayInsert(jRow, NuiSpacer());
        // Add row to the column.
        jCol = JsonArrayInsert(jCol, NuiRow(jRow));
        fHeight += 28.0;
        jPlugin = JsonArrayGet(jPlugins, ++nIndex);
    }
    // Get the window location to restore it from the database.
    json jLocations = ai_GetAssociateDbJson(oPC, "pc", "locations");
    float fX, fY;
    jLocations = JsonObjectGet(jLocations, AI_PLUGIN_NUI);
    if(JsonGetType(jLocations) == JSON_TYPE_NULL) { fX = -1.0; fY = -1.0; }
    else
    {
        fX = JsonGetFloat(JsonObjectGet(jLocations, "x"));
        fY = JsonGetFloat(JsonObjectGet(jLocations, "y"));
    }
    // Set the Layout of the window.
    json jLayout = NuiCol(jCol);
    sName = ai_StripColorCodes(GetName(oPC));
    if(GetStringRight(sName, 1) == "s") sName = sName + "'";
    else sName = sName + "'s";
    int nToken = SetWindow(oPC, jLayout, AI_PLUGIN_NUI, sName + " PEPS Plugin Manager",
                             fX, fY, 500.0f, fHeight + 12.0f, FALSE, FALSE, TRUE, FALSE, TRUE, "0e_nui");
    // Save the associate to the nui for use in 0e_nui
    json jData = JsonArrayInsert(JsonArray(), JsonString(ObjectToString(oPC)));
    NuiSetUserData(oPC, nToken, jData);
    // Set event watches for save window location.
    NuiSetBindWatch(oPC, nToken, "window_geometry", TRUE);
    // Row 1
    NuiSetBind(oPC, nToken, "btn_load_plugins_event", JsonBool(TRUE));
    NuiSetBind(oPC, nToken, "btn_load_plugins_tooltip", JsonString("  Load all known PEPS plugins that are in the game files."));
    NuiSetBind(oPC, nToken, "btn_load_m_mods_event", JsonBool(TRUE));
    NuiSetBind(oPC, nToken, "btn_load_m_mods_tooltip", JsonString("  Load all known PEPS monster mods that are in the game files."));
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
        if(bCheck < 3)
        {
            NuiSetBind(oPC, nToken, "chbx_plugin_" + sButton + "_check", JsonBool(bCheck));
            NuiSetBind(oPC, nToken, "chbx_plugin_" + sButton + "_event", JsonBool(TRUE));
            NuiSetBindWatch (oPC, nToken, "chbx_plugin_" + sButton + "_check", TRUE);
        }
        sText = "  " + JsonGetString(JsonArrayGet(jPlugin, 2));
        NuiSetBind(oPC, nToken, "btn_plugin_" + sButton + "_tooltip", JsonString(sText));
        jPlugin = JsonArrayGet(jPlugins, ++nIndex);
    }
}
void ai_CreateQuickWidgetSelectionMobileNUI(object oPC, object oAssociate) 
{
    string sAssociateType = ai_GetAssociateType(oPC, oAssociate);
    // Set window to not save until it has been created.
    SetLocalInt (oPC, AI_NO_NUI_SAVE, TRUE);
    DelayCommand (2.0, DeleteLocalInt (oPC, AI_NO_NUI_SAVE));
    json jRow = JsonArray();
    // Row 1 Classes************************************************************ 414 / 88
    int nClass, nLevel, nIndex;
    string sIndex, sClassIcon, sLevelIcon;
    for(nIndex = 1; nIndex <= AI_MAX_CLASSES_PER_CHARACTER; nIndex++)
    {
        nClass = GetClassByPosition(nIndex, oAssociate);
        if(nClass != CLASS_TYPE_INVALID)
        {
            // This saves the class position in the button id so we can get it later.
            sIndex = IntToString(nIndex);
            sClassIcon = Get2DAString("classes", "Icon", nClass);
            jRow = CreateButtonImage(jRow, sClassIcon, "btn_class_" + sIndex, 35.0f, 35.0f, 0.0, "btn_class_" + sIndex + "_tooltip");
        }
    }
    jRow = JsonArrayInsert(jRow, NuiSpacer());
    jRow = CreateButton(jRow, "Close", "btn_close", 100.0f, 35.0f);
    // Add row to the column.
    json jCol = JsonArrayInsert(JsonArray(), NuiRow(jRow));
    // Row 2 (Levels) ********************************************************** 414 / 131 
    jRow = CreateButtonImage(JsonArray(), "", "btn_level_11" , 35.0f, 35.0f, 0.0, "btn_level_11_tooltip");
    jRow = CreateButtonImage(jRow, "", "btn_level_10" , 35.0f, 35.0f, 0.0, "btn_level_10_tooltip");
    for(nIndex = 0; nIndex <= 9; nIndex++)
    {
        // This saves the level in the button id so we can get it later.
        sIndex = IntToString(nIndex);
        jRow = CreateButtonImage(jRow, "", "btn_level_" + sIndex, 35.0f, 35.0f, 0.0, "btn_level_" + sIndex + "_tooltip");
    }
    // Add row to the column.
    jCol = JsonArrayInsert(jCol, NuiRow(jRow));
    // Row 3 (Spell List)******************************************************* 414 / 433
    json jButton = JsonArray();
    jButton = NuiButton(NuiBind("text_spell"));
    jButton = NuiId(jButton, "btn_text_spell");
    json jRectangle = NuiRect(4.0, 4.0, 27.0, 27.0);
    json jDrawList = JsonArrayInsert(JsonArray(), NuiDrawListImage(JsonBool(TRUE), NuiBind("icon_spell"), jRectangle, JsonInt(NUI_ASPECT_FILL), JsonInt(NUI_HALIGN_CENTER), JsonInt(NUI_VALIGN_MIDDLE)));
    jRectangle = NuiRect(4.0, 24.0, 8.0, 8.0);
    json jMetaMagic = NuiDrawListImage(JsonBool(TRUE), NuiBind("metamagic_image"), jRectangle, JsonInt(4), JsonInt(1), JsonInt(1));
    jDrawList = JsonArrayInsert(jDrawList, jMetaMagic);
    jButton = NuiDrawList(jButton, JsonBool(TRUE), jDrawList);
    json jListTemplate = JsonArrayInsert(JsonArray(), NuiListTemplateCell(jButton, 345.0, FALSE));
    json jInfo = NuiButtonImage(JsonString("gui_cg_qstn_mark"));
    jInfo = NuiId(jInfo, "btn_info_spell");
    jListTemplate = JsonArrayInsert(jListTemplate, NuiListTemplateCell(jInfo, 35.0, FALSE));
    jRow = JsonArrayInsert(JsonArray(), NuiHeight(NuiList(jListTemplate, NuiBind("icon_spell"), 35.0), 282.0));
    // Add row to the column.
    jCol = JsonArrayInsert(jCol, NuiRow(jRow));
    // Row 4 (Widget Label)***************************************************** 414 / 461
    jRow = JsonArrayInsert(JsonArray(), NuiSpacer());
    jRow = CreateLabel(jRow, "Quick Widget List", "lbl_quick_list", 150.0, 20.0, 0, 0, 0.0);
    jRow = JsonArrayInsert(jRow, NuiSpacer());
    // Add row to the column.
    jCol = JsonArrayInsert(jCol, NuiRow(jRow));
    // Row 5 (Widget row 1)***************************************************** 414 / 504
    jRow = JsonArray();
    for(nIndex = 0; nIndex < 10; nIndex++)
    {
        // This saves the index location in the json jWidget in the button id for later use.
        sIndex = IntToString(nIndex);
        jButton = NuiButtonImage(NuiBind("btn_widget_" + sIndex + "_image"));
        jButton = NuiEnabled(jButton, NuiBind("btn_widget_" + sIndex + "_event"));
        jButton = NuiId(jButton, "btn_widget_" + sIndex);
        jButton = NuiWidth(NuiHeight(jButton, 35.0), 35.0);
        jButton = NuiMargin(jButton, 0.0);
        jButton = NuiTooltip(jButton, NuiBind("btn_widget_" + sIndex + "_tooltip"));
        jRectangle = NuiRect(4.0, 24.0, 8.0, 8.0);
        jMetaMagic = NuiDrawListImage(JsonBool(TRUE), NuiBind("metamagic_" + sIndex + "_image"), jRectangle, JsonInt(4), JsonInt(1), JsonInt(1));
        jDrawList = JsonArrayInsert(JsonArray(), jMetaMagic);
        jButton = NuiDrawList(jButton, JsonBool(TRUE), jDrawList);
        jRow = JsonArrayInsert(jRow, jButton);
    }
    // Add row to the column.
    jCol = JsonArrayInsert(jCol, NuiRow(jRow));
    // Row 6 (Widget row 2)***************************************************** 414 / 543
    jRow = JsonArray();
    for(nIndex = 10; nIndex < 20; nIndex++)
    {
        // This saves the index location in the json jWidget in the button id for later use.
        sIndex = IntToString(nIndex);
        jButton = NuiButtonImage(NuiBind("btn_widget_" + sIndex + "_image"));
        jButton = NuiEnabled(jButton, NuiBind("btn_widget_" + sIndex + "_event"));
        jButton = NuiId(jButton, "btn_widget_" + sIndex);
        jButton = NuiWidth(NuiHeight(jButton, 35.0), 35.0);
        jButton = NuiMargin(jButton, 0.0);
        jButton = NuiTooltip(jButton, NuiBind("btn_widget_" + sIndex + "_tooltip"));
        jRectangle = NuiRect(4.0, 24.0, 8.0, 8.0);
        jMetaMagic = NuiDrawListImage(JsonBool(TRUE), NuiBind("metamagic_" + sIndex + "_image"), jRectangle, JsonInt(4), JsonInt(1), JsonInt(1));
        jDrawList = JsonArrayInsert(JsonArray(), jMetaMagic);
        jButton = NuiDrawList(jButton, JsonBool(TRUE), jDrawList);
        jRow = JsonArrayInsert(jRow, jButton);
    }
    // Add row to the column.
    jCol = JsonArrayInsert(jCol, NuiRow(jRow));
    // Get the window location to restore it from the database. 
    float fX, fY;
    json jLocations = ai_GetAssociateDbJson(oPC, sAssociateType, "locations");
    jLocations = JsonObjectGet(jLocations, sAssociateType + AI_QUICK_WIDGET_NUI);
    if(JsonGetType(jLocations) == JSON_TYPE_NULL) { fX = -1.0; fY = -1.0; }
    else
    {
        fX = JsonGetFloat(JsonObjectGet(jLocations, "x"));
        fY = JsonGetFloat(JsonObjectGet(jLocations, "y"));
    }
    // Set the Layout of the window.
    json jLayout = NuiCol(jCol);
    string sText, sName = ai_StripColorCodes(GetName(oAssociate));
    if(GetStringRight(sName, 1) == "s") sName = sName + "'";
    else sName = sName + "'s";
    int nToken = SetWindow(oPC, jLayout, sAssociateType + AI_QUICK_WIDGET_NUI, sName + " Quick Widget Menu",
                           fX, fY, 414.0, 543.0 + 12.0, FALSE, FALSE, TRUE, FALSE, TRUE, "0e_nui");
    // Set the Layout of the window.
    // Save the associate to the nui for use in 0e_nui
    json jData = JsonArrayInsert(JsonArray(), JsonString(ObjectToString(oAssociate)));
    // Set event watches for save window location.
    NuiSetBindWatch(oPC, nToken, "window_geometry", TRUE);
    NuiSetBind(oPC, nToken, "btn_close_event", JsonBool(TRUE));
    json jSpells;
    json jAIData = ai_GetAssociateDbJson(oPC, sAssociateType, "aidata");
    // Temporary fix for error! :/ 
    if(JsonGetType(jAIData) == JSON_TYPE_NULL)
    {
        ai_CheckAssociateData(oPC, oAssociate, sAssociateType, TRUE);
        jAIData = ai_GetAssociateDbJson(oPC, sAssociateType, "aidata");
        jSpells = JsonArray();
        jSpells = JsonArrayInsert(jSpells, JsonInt(1));
        jSpells = JsonArrayInsert(jSpells, JsonInt(10));
        jAIData = JsonArrayInsert(jAIData, jSpells);
        ai_SetAssociateDbJson(oPC, sAssociateType, "aidata", jAIData);
        nLevel = 10;
    }
    /*if(JsonGetLength(jAIData) == 9)
    {
        jSpells = JsonArray();
        jSpells = JsonArrayInsert(jSpells, JsonInt(1));
        jSpells = JsonArrayInsert(jSpells, JsonInt(10));
        jSpells = JsonArrayInsert(jSpells, JsonArray());
        jAIData = JsonArrayInsert(jAIData, jSpells);
        ai_SetAssociateDbJson(oPC, sAssociateType, "aidata", jAIData);
        nLevel = 10;
    }*/
    else
    {
        jSpells = JsonArrayGet(jAIData, 10);
        if(JsonGetType(jSpells) == JSON_TYPE_NULL)
        {
            jSpells = JsonArray();
            jSpells = JsonArrayInsert(jSpells, JsonInt(1));
            jSpells = JsonArrayInsert(jSpells, JsonInt(10));
            jSpells = JsonArrayInsert(jSpells, JsonArray());
            jAIData = JsonArraySet(jAIData, 10, jSpells);
            ai_SetAssociateDbJson(oPC, sAssociateType, "aidata", jAIData);
            nLevel = 10;
        }
        else
        {
            nClass = JsonGetInt(JsonArrayGet(jSpells, 0));
            nLevel = JsonGetInt(JsonArrayGet(jSpells, 1));
        }
    }
    if(nClass < 1 || nClass > AI_MAX_CLASSES_PER_CHARACTER) nClass = 1; 
    nClass = GetClassByPosition(nClass, oAssociate);
    // Row 1 & 2 Class & Level
    int nSpellLevel, nLevelIndex, nClassIndex, nMaxSpellLevel;
    string sClass, sLevel, sLevelImage, sLevelIndex;
    NuiSetBind(oPC, nToken, "btn_level_11_event", JsonBool(TRUE));
    NuiSetBind(oPC, nToken, "btn_level_11_tooltip", JsonString("  Item Powers"));
    NuiSetBind(oPC, nToken, "btn_level_11_image", JsonString("ir_attack"));
    NuiSetBind(oPC, nToken, "btn_level_10_event", JsonBool(TRUE));
    NuiSetBind(oPC, nToken, "btn_level_10_tooltip", JsonString("  Special Abilities"));
    NuiSetBind(oPC, nToken, "btn_level_10_image", JsonString("dm_god"));
    for(nIndex = 1; nIndex <= AI_MAX_CLASSES_PER_CHARACTER; nIndex++)
    {
        nClassIndex = GetClassByPosition(nIndex, oAssociate);
        if(nClassIndex != CLASS_TYPE_INVALID)
        {
            sClass = GetStringByStrRef(StringToInt(Get2DAString("classes", "Name", nClassIndex)));
            sIndex = IntToString(nIndex);
            NuiSetBind(oPC, nToken, "btn_class_" + sIndex + "_event", JsonBool(TRUE));
            NuiSetBind(oPC, nToken, "btn_class_" + sIndex + "_tooltip", JsonString("  " + sClass));
            if(nClass == nClassIndex)
            {
                if(StringToInt(Get2DAString("classes", "SpellCaster", nClass)))
                {
                    int nClassLevel = ai_GetCasterTotalLevel(oAssociate, nClass);
                    string sSpellsGained = Get2DAString("classes", "SpellGainTable", nClass);
                    int nMaxSpellLevel = ai_GetClassMaxSpellLevel(oAssociate, nClass);
                    for(nLevelIndex = 0; nLevelIndex <= 9; nLevelIndex++)
                    {
                        sLevelIndex = IntToString(nLevelIndex);
                        if(nLevelIndex <= nMaxSpellLevel)
                        {
                            NuiSetBind(oPC, nToken, "btn_level_" + sLevelIndex + "_event", JsonBool(TRUE));
                            if(nLevelIndex == 0) sLevelImage = "ir_cantrips";
                            else if(nLevelIndex < 7)sLevelImage = "ir_level" + sLevelIndex;
                            else sLevelImage = "ir_level789";
                            NuiSetBind(oPC, nToken, "btn_level_" + sLevelIndex + "_image", JsonString(sLevelImage));
                            if(nLevelIndex == 0) sLevel = " Cantrips";
                            else if(nLevelIndex == 1) sLevel = " First level";
                            else if(nLevelIndex == 2) sLevel = " Second level";
                            else if(nLevelIndex == 3) sLevel = " Third level";
                            else if(nLevelIndex == 4) sLevel = " Fourth level";
                            else if(nLevelIndex == 5) sLevel = " Fifth level";
                            else if(nLevelIndex == 6) sLevel = " Sixth level";
                            else if(nLevelIndex == 7) sLevel = " Seventh level";
                            else if(nLevelIndex == 8) sLevel = " Eighth level";
                            else if(nLevelIndex == 9) sLevel = " Ninth level";
                            NuiSetBind(oPC, nToken, "btn_level_" + sLevelIndex + "_tooltip", JsonString("  " + sLevel));
                        }
                        else
                        {
                            NuiSetBind(oPC, nToken, "btn_level_" + sLevelIndex + "_event", JsonBool(TRUE));
                            NuiSetBind(oPC, nToken, "btn_level_" + sLevelIndex + "_image", JsonString("ctl_cg_btn_splvl"));
                            NuiSetBind(oPC, nToken, "btn_level_" + sLevelIndex + "_event", JsonBool(FALSE));
                        }
                    }
                    NuiSetBind(oPC, nToken, "btn_level_" + IntToString(nLevel) + "_encouraged", JsonBool(TRUE));
                }
                // Default to the abilities tab since they are not a caster.
                else
                {
                    if(nLevel < 10) nLevel = 10;
                    for(nLevelIndex = 0; nLevelIndex <= 9; nLevelIndex++)
                    {
                        sLevelIndex = IntToString(nLevelIndex);
                        NuiSetBind(oPC, nToken, "btn_level_" + sLevelIndex + "_event", JsonBool(TRUE));
                        NuiSetBind(oPC, nToken, "btn_level_" + sLevelIndex + "_image", JsonString("ctl_cg_btn_splvl"));
                        NuiSetBind(oPC, nToken, "btn_level_" + sLevelIndex + "_event", JsonBool(FALSE));
                    }
                    NuiSetBind(oPC, nToken, "btn_level_10_encouraged", JsonBool(TRUE));
                }
                NuiSetBind(oPC, nToken, "btn_class_" + IntToString(nClass) + "_encouraged", JsonBool(TRUE));
            }
        }
    }
    // Row 3 Items/Abilities/Skills/Spells
    int nSpell, nMetaMagic, nDomain, nSubSpell, nSubSpellIndex;
    int nSpellSlot, nCounter, nFeat;
    string sSpellIcon, sSpellName, sMetaMagicImage, sSubSpellIndex;
    object oItem;
    json jQuickListArray = JsonArray();  
    json jSpell;
    json jSpell_Icon = JsonArray();
    json jSpell_Text = JsonArray();
    json jMetaMagic_Image = JsonArray();
    SetLocalJson(oAssociate, "JSPELL_ICON", jSpell_Icon);
    SetLocalJson(oAssociate, "JSPELL_NAME", jSpell_Text);
    SetLocalJson(oAssociate, "JMETAMAGIC_IMAGE", jMetaMagic_Image);
    // Item powers
    if(nLevel == 11)
    {
        string sSlots;
        // Cycle through all the creatures inventory items.
        oItem = GetFirstItemInInventory(oAssociate);
        while(oItem != OBJECT_INVALID)
        {
            if(GetIdentified(oItem))
            {
                // Does the item need to be equiped to use its powers?
                sSlots = Get2DAString("baseitems", "EquipableSlots", GetBaseItemType(oItem));
                if(sSlots == "0x00000")
                {
                    jQuickListArray = ai_CheckItemAbilities(jQuickListArray, oAssociate, oItem, jSpell_Icon, jSpell_Text, jMetaMagic_Image, TRUE);
                    jSpell_Icon = GetLocalJson(oAssociate, "JSPELL_ICON");
                    jSpell_Text = GetLocalJson(oAssociate, "JSPELL_NAME");
                    jMetaMagic_Image = GetLocalJson(oAssociate, "JMETAMAGIC_IMAGE");
                    //WriteTimestampedLogEntry("0i_menus, 3643, oAssociate: " + GetName(oAssociate) +
                    //     " jSpell_Text: " + JsonDump(jSpell_Text, 4));
                }
            }
            oItem = GetNextItemInInventory(oAssociate);
        }
        int nSlot;
        // Cycle through all the creatures equiped items.
        oItem = GetItemInSlot(nSlot, oAssociate);
        while(nSlot < 11)
        {
            if(oItem != OBJECT_INVALID)
            {
                jQuickListArray = ai_CheckItemAbilities(jQuickListArray, oAssociate, oItem, jSpell_Icon, jSpell_Text, jMetaMagic_Image, TRUE);
                jSpell_Icon = GetLocalJson(oAssociate, "JSPELL_ICON");
                jSpell_Text = GetLocalJson(oAssociate, "JSPELL_NAME");
                jMetaMagic_Image = GetLocalJson(oAssociate, "JMETAMAGIC_IMAGE");
            }
            oItem = GetItemInSlot(++nSlot, oAssociate);
        }
        oItem = GetItemInSlot(INVENTORY_SLOT_CARMOUR, oAssociate);
        if(oItem != OBJECT_INVALID)
        {
            jQuickListArray = ai_CheckItemAbilities(jQuickListArray, oAssociate, oItem, jSpell_Icon, jSpell_Text, jMetaMagic_Image, TRUE);
            jSpell_Icon = GetLocalJson(oAssociate, "JSPELL_ICON");
            jSpell_Text = GetLocalJson(oAssociate, "JSPELL_NAME");
            jMetaMagic_Image = GetLocalJson(oAssociate, "JMETAMAGIC_IMAGE");
        }
        DeleteLocalJson(oAssociate, "JSPELL_ICON");
        DeleteLocalJson(oAssociate, "JSPELL_NAME");
        DeleteLocalJson(oAssociate, "JMETAMAGIC_IMAGE");
    }
    // Special abilities and skills.  
    else if(nLevel == 10)
    {
        json jCreature = ObjectToJson(oAssociate);
        json jFeatList = GffGetList(jCreature, "FeatList");
        int nIndex, nSuccessor;
        json jFeat = JsonArrayGet(jFeatList, nIndex);
        while(JsonGetType(jFeat) != JSON_TYPE_NULL)
        {
            nFeat = JsonGetInt(GffGetWord(jFeat, "Feat"));
            if(Get2DAString("feat", "USESPERDAY", nFeat) != "" ||
               Get2DAString("feat", "HostileFeat", nFeat) != "" ||
               Get2DAString("feat", "TARGETSELF", nFeat) != "")
            {
                // Check for subfeats.
                nSpell = StringToInt(Get2DAString("feat", "SPELLID", nFeat));
                nSubSpell = StringToInt(Get2DAString("spells", "SubRadSpell1", nSpell));
                //SendMessageToPC(oPC, "nFeat: " + IntToString(nFeat) +
                //            " nSpell: " + IntToString(nSpell) +
                //            " nSubSpell: " + IntToString(nSubSpell));
                if(nSubSpell)
                {
                    for(nSubSpellIndex = 1; nSubSpellIndex <= 5; nSubSpellIndex++)
                    {
                        sSubSpellIndex = IntToString(nSubSpellIndex);
                        nSubSpell = StringToInt(Get2DAString("spells", "SubRadSpell" + sSubSpellIndex, nSpell));
                        //SendMessageToPC(oPC, " nSpell: " + IntToString(nSpell) +
                        //            " nSubSpell: " + IntToString(nSubSpell));
                        if(nSubSpell != 0)
                        {
                            sSpellIcon = Get2DAString("spells", "iConResRef", nSubSpell);
                            jSpell_Icon = JsonArrayInsert(jSpell_Icon, JsonString(sSpellIcon));
                            sSpellName = GetStringByStrRef(StringToInt(Get2DAString("spells", "Name", nSubSpell)));
                            jSpell_Text = JsonArrayInsert(jSpell_Text, JsonString(sSpellName));
                            jMetaMagic_Image = JsonArrayInsert(jMetaMagic_Image, JsonString("mm_none"));
                            jSpell = JsonArray();
                            jSpell = JsonArrayInsert(jSpell, JsonInt(nSubSpell));
                            jSpell = JsonArrayInsert(jSpell, JsonInt(nClass));
                            jSpell = JsonArrayInsert(jSpell, JsonInt(-1)); // Level
                            jSpell = JsonArrayInsert(jSpell, JsonInt(255)); // MetaMagic
                            jSpell = JsonArrayInsert(jSpell, JsonInt(0)); // Domain
                            jSpell = JsonArrayInsert(jSpell, JsonInt(nFeat));
                            jQuickListArray = JsonArrayInsert(jQuickListArray, jSpell);
                        }
                    }
                }
                else if((nFeat < 71 || nFeat > 81)) 
                {
                    nSuccessor = StringToInt(Get2DAString("feat", "SUCCESSOR", nFeat));
                    if(nSuccessor && GetHasFeat(nSuccessor, oAssociate, TRUE))
                    { /* Don't do anything we just skip adding this feat. */}
                    else
                    {
                        sSpellIcon = Get2DAString("feat", "ICON", nFeat);
                        jSpell_Icon = JsonArrayInsert(jSpell_Icon, JsonString(sSpellIcon));
                        sSpellName = GetStringByStrRef(StringToInt(Get2DAString("feat", "FEAT", nFeat)));
                        jSpell_Text = JsonArrayInsert(jSpell_Text, JsonString(sSpellName));
                        jMetaMagic_Image = JsonArrayInsert(jMetaMagic_Image, JsonString("mm_none"));
                        jSpell = JsonArray();
                        jSpell = JsonArrayInsert(jSpell, JsonInt(nSpell));
                        jSpell = JsonArrayInsert(jSpell, JsonInt(nClass));
                        jSpell = JsonArrayInsert(jSpell, JsonInt(0)); // Level
                        jSpell = JsonArrayInsert(jSpell, JsonInt(0)); // MetaMagic
                        jSpell = JsonArrayInsert(jSpell, JsonInt(0)); // Domain
                        jSpell = JsonArrayInsert(jSpell, JsonInt(nFeat));
                        jQuickListArray = JsonArrayInsert(jQuickListArray, jSpell);
                    }
                }
            }
            jFeat = JsonArrayGet(jFeatList, ++nIndex);
        }
        // Checks for monsters special abilities.
        int nCounter = 0, nPreviousSpell = -1, nMaxSpellAbility = GetSpellAbilityCount(oAssociate);
        while(nCounter < nMaxSpellAbility)
        {
            nSpell = GetSpellAbilitySpell(oAssociate, nCounter);
            if(nPreviousSpell != nSpell)
            {
                nPreviousSpell = nSpell;
                // Check for subfeats.
                nSubSpell = StringToInt(Get2DAString("spells", "SubRadSpell1", nSpell));
                if(nSubSpell)
                {
                    for(nSubSpellIndex = 1; nSubSpellIndex <= 5; nSubSpellIndex++)
                    {
                        sSubSpellIndex = IntToString(nSubSpellIndex);
                        nSubSpell = StringToInt(Get2DAString("spells", "SubRadSpell" + sSubSpellIndex, nSpell));
                        if(nSubSpell != 0)
                        {
                            sSpellIcon = Get2DAString("spells", "iConResRef", nSubSpell);
                            jSpell_Icon = JsonArrayInsert(jSpell_Icon, JsonString(sSpellIcon));
                            sSpellName = GetStringByStrRef(StringToInt(Get2DAString("spells", "Name", nSubSpell)));
                            jSpell_Text = JsonArrayInsert(jSpell_Text, JsonString(sSpellName));
                            sMetaMagicImage = ai_GetSpellIconAttributes(oAssociate, nMetaMagic, nDomain);
                            jMetaMagic_Image = JsonArrayInsert(jMetaMagic_Image, JsonString(sMetaMagicImage));
                            jSpell = JsonArray();
                            jSpell = JsonArrayInsert(jSpell, JsonInt(nSubSpell));
                            jSpell = JsonArrayInsert(jSpell, JsonInt(nClass));
                            jSpell = JsonArrayInsert(jSpell, JsonInt(0)); // Level
                            jSpell = JsonArrayInsert(jSpell, JsonInt(255)); // MetaMagic
                            jSpell = JsonArrayInsert(jSpell, JsonInt(0)); // Domain
                            jSpell = JsonArrayInsert(jSpell, JsonInt(0)); // Feat
                            jQuickListArray = JsonArrayInsert(jQuickListArray, jSpell);
                        }
                    }
                }
                else
                {
                    sSpellIcon = Get2DAString("spells", "IconResRef", nSpell);
                    jSpell_Icon = JsonArrayInsert(jSpell_Icon, JsonString(sSpellIcon));
                    sSpellName = GetStringByStrRef(StringToInt(Get2DAString("spells", "Name", nSpell)));
                    jSpell_Text = JsonArrayInsert(jSpell_Text, JsonString(sSpellName));
                    sMetaMagicImage = ai_GetSpellIconAttributes(oAssociate, nMetaMagic, nDomain);
                    jMetaMagic_Image = JsonArrayInsert(jMetaMagic_Image, JsonString(sMetaMagicImage));
                    jSpell = JsonArray();
                    jSpell = JsonArrayInsert(jSpell, JsonInt(nSpell));
                    jSpell = JsonArrayInsert(jSpell, JsonInt(255)); // Class - Special abilities is always 255.
                    jSpell = JsonArrayInsert(jSpell, JsonInt(GetSpellAbilityCasterLevel(oAssociate, nCounter)));
                    jSpell = JsonArrayInsert(jSpell, JsonInt(0)); // metamagic
                    jSpell = JsonArrayInsert(jSpell, JsonInt(0)); // domain
                    jSpell = JsonArrayInsert(jSpell, JsonInt(0)); // feat
                    // Index of Special ability on monster.
                    jSpell = JsonArrayInsert(jSpell, JsonInt(nCounter));
                    jQuickListArray = JsonArrayInsert(jQuickListArray, jSpell);
                    //SendMessageToPC(oPC, "nSpell: " + IntToString(nSpell) +
                    //               " sSpellIcon: " + sSpellIcon +
                    //               " sSpellName: " + sSpellName+
                    //               " nMaxSlot: " + IntToString(nMaxSpellAbility) +
                    //               " nSpellAbilityIndex: " + IntToString(nCounter));
                }
            }
            nCounter++;
        }
        // Used in the execution script to get the special abilities.
        //jData = JsonArrayInsert(jData, jQuickListArray);
    }
    else // Anything else is for spells.
    {
        // Search all memorized spells for the spell.
        //SendMessageToPC(oPC, GetName(oAssociate) + " nClass: " + IntToString(nClass) +
        //               " nLevelSelected: " + IntToString(nLevel) +
        //               " nMemorizesSpells: " + Get2DAString("classes", "MemorizesSpells", nClass));
        if(Get2DAString("classes", "MemorizesSpells", nClass) == "1")
        {
            int nMaxSlot = GetMemorizedSpellCountByLevel(oAssociate, nClass, nLevel);
            while(nSpellSlot < nMaxSlot)
            {
                nSpell = GetMemorizedSpellId(oAssociate, nClass, nLevel, nSpellSlot);
                if(nSpell != -1 && ai_SpellNotInList(nSpell, jQuickListArray))
                {
                    nMetaMagic = GetMemorizedSpellMetaMagic(oAssociate, nClass, nLevel, nSpellSlot);
                    nDomain = GetMemorizedSpellIsDomainSpell(oAssociate, nClass, nLevel, nSpellSlot);
                    // Check for subspells.  
                    nSubSpell = StringToInt(Get2DAString("spells", "SubRadSpell1", nSpell));
                    if(nSubSpell)
                    {
                        for(nSubSpellIndex = 1; nSubSpellIndex < 6; nSubSpellIndex++)
                        {
                            sSubSpellIndex = IntToString(nSubSpellIndex);
                            nSubSpell = StringToInt(Get2DAString("spells", "SubRadSpell" + sSubSpellIndex, nSpell));
                            if(nSubSpell  && ai_SpellNotInList(nSubSpell, jQuickListArray))
                            {
                                sSpellIcon = Get2DAString("spells", "IconResRef", nSubSpell);
                                jSpell_Icon = JsonArrayInsert(jSpell_Icon, JsonString(sSpellIcon));
                                sSpellName = GetStringByStrRef(StringToInt(Get2DAString("spells", "Name", nSubSpell)));
                                jSpell_Text = JsonArrayInsert(jSpell_Text, JsonString(sSpellName));
                                sMetaMagicImage = ai_GetSpellIconAttributes(oAssociate, nMetaMagic, nDomain);
                                jMetaMagic_Image = JsonArrayInsert(jMetaMagic_Image, JsonString(sMetaMagicImage));
                                jSpell = JsonArray();
                                jSpell = JsonArrayInsert(jSpell, JsonInt(nSubSpell));
                                jSpell = JsonArrayInsert(jSpell, JsonInt(nClass));
                                jSpell = JsonArrayInsert(jSpell, JsonInt(nLevel));
                                jSpell = JsonArrayInsert(jSpell, JsonInt(nMetaMagic));
                                jSpell = JsonArrayInsert(jSpell, JsonInt(nDomain));
                                jSpell = JsonArrayInsert(jSpell, JsonInt(0)); // Feat
                                jQuickListArray = JsonArrayInsert(jQuickListArray, jSpell);
                            }
                        }
                    }
                    else
                    {
                        sSpellIcon = Get2DAString("spells", "IconResRef", nSpell);
                        jSpell_Icon = JsonArrayInsert(jSpell_Icon, JsonString(sSpellIcon));
                        sSpellName = GetStringByStrRef(StringToInt(Get2DAString("spells", "Name", nSpell)));
                        jSpell_Text = JsonArrayInsert(jSpell_Text, JsonString(sSpellName));
                        sMetaMagicImage = ai_GetSpellIconAttributes(oAssociate, nMetaMagic, nDomain);
                        jMetaMagic_Image = JsonArrayInsert(jMetaMagic_Image, JsonString(sMetaMagicImage));
                        jSpell = JsonArray();
                        jSpell = JsonArrayInsert(jSpell, JsonInt(nSpell));
                        jSpell = JsonArrayInsert(jSpell, JsonInt(nClass));
                        jSpell = JsonArrayInsert(jSpell, JsonInt(nLevel));
                        jSpell = JsonArrayInsert(jSpell, JsonInt(nMetaMagic));
                        if(nDomain) nDomain = nLevel;
                        jSpell = JsonArrayInsert(jSpell, JsonInt(nDomain));
                        jSpell = JsonArrayInsert(jSpell, JsonInt(0));
                        jQuickListArray = JsonArrayInsert(jQuickListArray, jSpell);
                        //SendMessageToPC(oPC, "nSpell: " + IntToString(nSpell) +
                        //               " sSpellIcon: " + sSpellIcon +
                        //               " sSpellName: " + sSpellName+
                        //               " nMaxSlot: " + IntToString(nMaxSlot) +
                        //               " nSpellSlot: " + IntToString(nSpellSlot));
                    }
                }
                ++nSpellSlot;
            }
        }
        // Non-memorized spells.
        else
        {
            int nMaxSlot = GetKnownSpellCount(oAssociate, nClass, nLevel);
            while(nSpellSlot < nMaxSlot)
            {
                nSpell = GetKnownSpellId(oAssociate, nClass, nLevel, nSpellSlot);
                if(nSpell != -1)// && ai_SpellNotInList(nSpell, jQuickListArray))
                {
                    sSpellIcon = Get2DAString("spells", "IconResRef", nSpell);
                    jSpell_Icon = JsonArrayInsert(jSpell_Icon, JsonString(sSpellIcon));
                    sSpellName = GetStringByStrRef(StringToInt(Get2DAString("spells", "Name", nSpell)));
                    jSpell_Text = JsonArrayInsert(jSpell_Text, JsonString(sSpellName));
                    jMetaMagic_Image = JsonArrayInsert(jMetaMagic_Image, JsonString("mm_none"));
                    jSpell = JsonArray();
                    jSpell = JsonArrayInsert(jSpell, JsonInt(nSpell));
                    jSpell = JsonArrayInsert(jSpell, JsonInt(nClass));
                    jSpell = JsonArrayInsert(jSpell, JsonInt(nLevel));
                    jSpell = JsonArrayInsert(jSpell, JsonInt(255));
                    jSpell = JsonArrayInsert(jSpell, JsonInt(0));
                    jQuickListArray = JsonArrayInsert(jQuickListArray, jSpell);
                }
                ++nSpellSlot;
            }
        }
    }
    NuiSetBind(oPC, nToken, "icon_spell", jSpell_Icon); 
    NuiSetBind(oPC, nToken, "text_spell", jSpell_Text);
    NuiSetBind(oPC, nToken, "metamagic_image", jMetaMagic_Image);
    jData = JsonArrayInsert(jData, jQuickListArray);
    NuiSetUserData(oPC, nToken, jData);
    // Row 4 Quick widget list label.
    // Row 5 Quick widget List 1
    ai_PopulateWidgetList(oPC, oAssociate, nToken, JsonArrayGet(jSpells, 2));
}
void ai_CreateSpellMemorizationMobileNUI(object oPC, object oAssociate) 
{
    // Set window to not save until it has been created.
    SetLocalInt (oPC, AI_NO_NUI_SAVE, TRUE);
    DelayCommand (2.0, DeleteLocalInt (oPC, AI_NO_NUI_SAVE));
    string sAssociateType = ai_GetAssociateType(oPC, oAssociate);
    json jRow = JsonArray();
    // Row 1 Classes************************************************************ 414 / 73
    int nClass, nIndex;
    string sIndex, sClassIcon, sLevelIcon;
    for(nIndex = 1; nIndex <= AI_MAX_CLASSES_PER_CHARACTER; nIndex++)
    {
        nClass = GetClassByPosition(nIndex, oAssociate);
        if(nClass != CLASS_TYPE_INVALID)
        {
            if(StringToInt(Get2DAString("classes", "MemorizesSpells", nClass)))
            {
                // This saves the class position in the button id so we can get it later.
                sIndex = IntToString(nIndex);
                sClassIcon = Get2DAString("classes", "Icon", nClass);
                jRow = CreateButtonImage(jRow, sClassIcon, "btn_class_" + sIndex, 35.0f, 35.0f, 0.0, "btn_class_" + sIndex + "_tooltip");
            }
        }
    }
    jRow = JsonArrayInsert(jRow, NuiSpacer());
    jRow = CreateButton(jRow, "Close", "btn_close", 100.0f, 35.0f);
    json jCol = JsonArrayInsert(JsonArray(), NuiRow(jRow));
    // Row 2 (Levels) ********************************************************** 414 / 116  
    jRow = JsonArray();
    for(nIndex = 0; nIndex <= 9; nIndex++)
    {
        // This saves the level in the button id so we can get it later.
        sIndex = IntToString(nIndex);
        jRow = CreateButtonImage(jRow, "", "btn_level_" + sIndex, 35.0f, 35.0f, 0.0, "btn_level_" + sIndex + "_tooltip");
    }
    jCol = JsonArrayInsert(jCol, NuiRow(jRow));
    // Row 3 (Filters)******************************************************* 414 / 159
    jRow = CreateButtonSelect( JsonArray(), "No", "btn_mm_normal", 35.0f, 35.0f, 0.0, "btn_mm_normal_tooltip");
    jRow = ai_CreateFilterButton(jRow, "btn_mm_empower", "Em", "mm_empower");  
    jRow = ai_CreateFilterButton(jRow, "btn_mm_extend", "Ex", "mm_extend");  
    jRow = ai_CreateFilterButton(jRow, "btn_mm_maximize", "Mx", "mm_maximize");  
    jRow = ai_CreateFilterButton(jRow, "btn_mm_quicken", "Qu", "mm_quicken");  
    jRow = ai_CreateFilterButton(jRow, "btn_mm_silent", "Si", "mm_silent");  
    jRow = ai_CreateFilterButton(jRow, "btn_mm_still", "St", "mm_still");  
    jRow = ai_CreateFilterButton(jRow, "btn_mm_domain", "Do", "mm_domain");  
    jCol = JsonArrayInsert(jCol, NuiRow(jRow));
    // Row 3 (Spell Lists)******************************************************* 414 / 398
    json jButton = JsonArray();
    jButton = NuiButton(NuiBind("text_spell"));
    jButton = NuiId(jButton, "btn_text_spell");
    json jRectangle = NuiRect(4.0, 4.0, 27.0, 27.0);
    json jDrawList = JsonArrayInsert(JsonArray(), NuiDrawListImage(JsonBool(TRUE), NuiBind("icon_spell"), jRectangle, JsonInt(NUI_ASPECT_FILL), JsonInt(NUI_HALIGN_CENTER), JsonInt(NUI_VALIGN_MIDDLE)));
    jRectangle = NuiRect(4.0, 24.0, 8.0, 8.0);
    json jMetaMagic = NuiDrawListImage(JsonBool(TRUE), NuiBind("metamagic_image"), jRectangle, JsonInt(4), JsonInt(1), JsonInt(1));
    jDrawList = JsonArrayInsert(jDrawList, jMetaMagic);
    jButton = NuiDrawList(jButton, JsonBool(TRUE), jDrawList);
    json jListTemplate = JsonArrayInsert(JsonArray(), NuiListTemplateCell(jButton, 275.0, FALSE));
    json jInfo = NuiButtonImage(JsonString("gui_cg_qstn_mark"));
    jInfo = NuiId(jInfo, "btn_info_spell");
    jListTemplate = JsonArrayInsert(jListTemplate, NuiListTemplateCell(jInfo, 35.0, FALSE));
    jRow = JsonArrayInsert(JsonArray(), NuiHeight(NuiList(jListTemplate, NuiBind("icon_spell"), 35.0), 305.0));
    jCol = JsonArrayInsert(jCol, NuiRow(jRow));
    // Row 4 (Widget Label)***************************************************** 414 / 426
    jRow = JsonArrayInsert(JsonArray(), NuiSpacer());
    jRow = CreateLabel(jRow, "Memorized Spell List", "lbl_spell_list", 150.0, 20.0, 0, 0, 0.0);
    jRow = JsonArrayInsert(jRow, NuiSpacer());
    // Add row to the column.
    jCol = JsonArrayInsert(jCol, NuiRow(jRow));
    // Row 5 (Memorize slots)*************************************************** 414 / 469
    // Get the class and level selected from the database.
    int nClassSelected, nLevelSelected;
    json jSpells;
    json jAIData = ai_GetAssociateDbJson(oPC, sAssociateType, "aidata");
    // Temporary fix for error! :/
    if(JsonGetType(jAIData) == JSON_TYPE_NULL)
    {
        ai_CheckAssociateData(oPC, oAssociate, sAssociateType, TRUE);
        jAIData = ai_GetAssociateDbJson(oPC, sAssociateType, "aidata");
    }
    /*if(JsonGetLength(jAIData) == 9)
    {
        jSpells = JsonArray();
        jSpells = JsonArrayInsert(jSpells, JsonInt(1));
        jSpells = JsonArrayInsert(jSpells, JsonInt(0));
        jAIData = JsonArrayInsert(jAIData, jSpells);
        ai_SetAssociateDbJson(oPC, sAssociateType, "aidata", jAIData);
    }*/
    else
    {
        jSpells = JsonArrayGet(jAIData, 10);
        if(JsonGetType(jSpells) == JSON_TYPE_NULL)
        {
            jSpells = JsonArray();
            jSpells = JsonArrayInsert(jSpells, JsonInt(1));
            jSpells = JsonArrayInsert(jSpells, JsonInt(0));
            jAIData = JsonArraySet(jAIData, 10, jSpells);
            ai_SetAssociateDbJson(oPC, sAssociateType, "aidata", jAIData);
        }
        else
        {
            nClassSelected = JsonGetInt(JsonArrayGet(jSpells, 0));
            nLevelSelected = JsonGetInt(JsonArrayGet(jSpells, 1));
        }
    }
    // If we left the Quick Use widget on Special Abilities (10) or Items (11) goto level 0
    if(nLevelSelected == 10 || nLevelSelected == 11) 
    {
        nLevelSelected = 0;
        jSpells = JsonArraySet(jSpells, 1, JsonInt(0));
        jAIData = JsonArraySet(jAIData, 10, jSpells);
        ai_SetAssociateDbJson(oPC, sAssociateType, "aidata", jAIData);
    }
    // Make sure we are on a spellcasting class.
    nClass = GetClassByPosition(nClassSelected, oAssociate);
    int bCaster = StringToInt(Get2DAString("classes", "SpellCaster", nClass));
    if(!bCaster || nClassSelected < 1 || nClassSelected > AI_MAX_CLASSES_PER_CHARACTER)
    {
        for(nIndex = 1; nIndex <= AI_MAX_CLASSES_PER_CHARACTER; nIndex++)
        {
            nClass = GetClassByPosition(nIndex, oAssociate);
            if(Get2DAString("classes", "SpellCaster", nClass) == "1") 
            {
                nClassSelected = nIndex;
                break;
            }
        }
        jSpells = JsonArraySet(jSpells, 0, JsonInt(nClassSelected));
        jAIData = JsonArraySet(jAIData, 10, jSpells);
        ai_SetAssociateDbJson(oPC, sAssociateType, "aidata", jAIData);
    }
    int nMaxMemorizationSlots = GetMemorizedSpellCountByLevel(oAssociate, nClass, nLevelSelected);
    jRow = JsonArray();
    for(nIndex = 0; nIndex < nMaxMemorizationSlots; nIndex++)
    {
        // This saves the index location of the spell in the list.
        sIndex = IntToString(nIndex);
        json jButton = NuiButtonImage(NuiBind("btn_memorized_" + sIndex + "_image"));
        jButton = NuiEnabled(jButton, NuiBind("btn_memorized_" + sIndex + "_event"));
        jButton = NuiId(jButton, "btn_memorized_" + sIndex);
        jButton = NuiWidth(NuiHeight(jButton, 35.0), 35.0);
        jButton = NuiMargin(jButton, 0.0);
        jButton = NuiTooltip(jButton, NuiBind("btn_memorized_" + sIndex + "_tooltip"));
        json jRectangle = NuiRect(4.0, 24.0, 8.0, 8.0);
        json jMetaMagic = NuiDrawListImage(JsonBool(TRUE), NuiBind("metamagic_" + sIndex + "_image"), jRectangle, JsonInt(4), JsonInt(1), JsonInt(1));
        jDrawList = JsonArrayInsert(JsonArray(), jMetaMagic);
        jButton = NuiDrawList(jButton, JsonBool(TRUE), jDrawList);
        jRow = JsonArrayInsert(jRow, jButton);
    }
    // Add row to the column.
    jCol = JsonArrayInsert(jCol, NuiRow(jRow));
    // Get the window location to restore it from the database.
    float fX, fY;
    json jLocations = ai_GetAssociateDbJson(oPC, sAssociateType, "locations");
    jLocations = JsonObjectGet(jLocations, sAssociateType + AI_SPELL_MEMORIZE_NUI);
    if(JsonGetType(jLocations) == JSON_TYPE_NULL) { fX = -1.0; fY = -1.0; }
    else
    {
        fX = JsonGetFloat(JsonObjectGet(jLocations, "x"));
        fY = JsonGetFloat(JsonObjectGet(jLocations, "y"));
    }
    string sText, sName = ai_StripColorCodes(GetName(oAssociate));
    if(GetStringRight(sName, 1) == "s") sName = sName + "'";
    else sName = sName + "'s";
    // Set the Layout of the window.
    json jLayout = NuiCol(jCol);
    int nToken = SetWindow(oPC, jLayout, sAssociateType + AI_SPELL_MEMORIZE_NUI, sName + " Spell Memorization Menu",
                           fX, fY, 375.0, 580.0 + 12.0, FALSE, FALSE, TRUE, FALSE, TRUE, "0e_nui");
    // Set the Layout of the window.
    // Save the associate to the nui for use in 0e_nui
    json jData = JsonArrayInsert(JsonArray(), JsonString(ObjectToString(oAssociate)));
    // Set event watches for save window location.
    NuiSetBindWatch(oPC, nToken, "window_geometry", TRUE);
    NuiSetBind(oPC, nToken, "btn_close_event", JsonBool(TRUE));
    // Row 1 & 2 Class & Level 
    int nIndexLevel, nMaxSpellLevel;
    string sClass, sLevel, sLevelImage, sIndexLevel;
    for(nIndex = 1; nIndex <= AI_MAX_CLASSES_PER_CHARACTER; nIndex++)
    {
        nClass = GetClassByPosition(nIndex, oAssociate);
        if(nClass != CLASS_TYPE_INVALID)
        {
            bCaster = StringToInt(Get2DAString("classes", "SpellCaster", nClass));
            if(bCaster)
            {
                sClass = GetStringByStrRef(StringToInt(Get2DAString("classes", "Name", nClass)));
                sIndex = IntToString(nIndex);
                NuiSetBind(oPC, nToken, "btn_class_" + sIndex + "_event", JsonBool(TRUE));
                NuiSetBind(oPC, nToken, "btn_class_" + sIndex + "_tooltip", JsonString("  " + sClass));
                if(nClassSelected == nIndex)
                {
                    int nMaxSpellLevel = ai_GetClassMaxSpellLevel(oAssociate, nClass);
                    for(nIndexLevel = 0; nIndexLevel <= 9; nIndexLevel++)
                    {
                        sIndexLevel = IntToString(nIndexLevel);
                        if(nIndexLevel <= nMaxSpellLevel)
                        {
                            if(nIndexLevel == 0) sLevelImage = "ir_cantrips";
                            else if(nIndexLevel < 7)sLevelImage = "ir_level" + sIndexLevel;
                            else sLevelImage = "ir_level789";
                            if(nIndexLevel == 0) sLevel = " Cantrips";
                            else if(nIndexLevel == 1) sLevel = " First level";
                            else if(nIndexLevel == 2) sLevel = " Second level";
                            else if(nIndexLevel == 3) sLevel = " Third level";
                            else if(nIndexLevel == 4) sLevel = " Fourth level";
                            else if(nIndexLevel == 5) sLevel = " Fifth level";
                            else if(nIndexLevel == 6) sLevel = " Sixth level";
                            else if(nIndexLevel == 7) sLevel = " Seventh level";
                            else if(nIndexLevel == 8) sLevel = " Eighth level";
                            else if(nIndexLevel == 9) sLevel = " Ninth level";
                            NuiSetBind(oPC, nToken, "btn_level_" + sIndexLevel + "_event", JsonBool(TRUE));
                            NuiSetBind(oPC, nToken, "btn_level_" + sIndexLevel + "_tooltip", JsonString("  " + sLevel));
                            NuiSetBind(oPC, nToken, "btn_level_" + sIndexLevel + "_image", JsonString(sLevelImage));
                        }
                        else
                        {
                            NuiSetBind(oPC, nToken, "btn_level_" + sIndexLevel + "_event", JsonBool(TRUE));
                            NuiSetBind(oPC, nToken, "btn_level_" + sIndexLevel + "_image", JsonString("ctl_cg_btn_splvl"));
                            NuiSetBind(oPC, nToken, "btn_level_" + sIndexLevel + "_event", JsonBool(FALSE));
                        }
                    }
                    NuiSetBind(oPC, nToken, "btn_level_" + IntToString(nLevelSelected) + "_encouraged", JsonBool(TRUE));
                    NuiSetBind(oPC, nToken, "btn_class_" + IntToString(nClassSelected) + "_encouraged", JsonBool(TRUE));
                }
            }
        }
    }
    // Row 3 Filters
    json jFilters = GetLocalJson(oPC, "SPELL_FILTERS");
    if(JsonGetType(jFilters) == JSON_TYPE_NULL) 
    {
        jFilters = JsonArrayInsert(JsonArray(), JsonBool(TRUE)); // Normal Spell filter.
        for(nIndex = 0; nIndex < 6; nIndex++)
        {
            jFilters = JsonArrayInsert(jFilters, JsonBool(FALSE)); // Other filters are off.        
        }
        jFilters = JsonArrayInsert(jFilters, JsonBool(TRUE)); // Domain filter start on.
        SetLocalJson(oPC, "SPELL_FILTERS", jFilters);
    }
    ai_SetFilterButtons(oPC, nToken, jFilters, 0, "btn_mm_normal", "are normally cast");
    if(GetHasFeat(FEAT_EMPOWER_SPELL, oAssociate)) ai_SetFilterButtons(oPC, nToken, jFilters, 1, "btn_mm_empower", "can be empowered");
    else NuiSetBind(oPC, nToken, "btn_mm_empower_event", JsonBool(FALSE));
    if(GetHasFeat(FEAT_EXTEND_SPELL, oAssociate)) ai_SetFilterButtons(oPC, nToken, jFilters, 2, "btn_mm_extend", "can be extended");
    else NuiSetBind(oPC, nToken, "btn_mm_extend_event", JsonBool(FALSE));
    if(GetHasFeat(FEAT_QUICKEN_SPELL, oAssociate)) ai_SetFilterButtons(oPC, nToken, jFilters, 3, "btn_mm_quicken", "can be quickened");
    else NuiSetBind(oPC, nToken, "btn_mm_quicken_event", JsonBool(FALSE));
    if(GetHasFeat(FEAT_SILENCE_SPELL, oAssociate)) ai_SetFilterButtons(oPC, nToken, jFilters, 4, "btn_mm_silent", "can be silenced");
    else NuiSetBind(oPC, nToken, "btn_mm_silent_event", JsonBool(FALSE));
    if(GetHasFeat(FEAT_STILL_SPELL, oAssociate)) ai_SetFilterButtons(oPC, nToken, jFilters, 5, "btn_mm_still", "can be stilled");
    else NuiSetBind(oPC, nToken, "btn_mm_still_event", JsonBool(FALSE));
    if(GetDomain(oAssociate) > -1) ai_SetFilterButtons(oPC, nToken, jFilters, 6, "btn_mm_domain", "are domain spells");
    else NuiSetBind(oPC, nToken, "btn_mm_domain_event", JsonBool(FALSE));
    // Row 4 Spells  
    int nSpellSlot, nSpell, nMetamagic;
    nClass = GetClassByPosition(nClassSelected, oAssociate);
    string sSpellIcon, sMetaMagicImage;
    SetLocalJson(oPC, "JS_MEMORIZE_SPELLOBJECT", JsonObject());
    SetLocalJson(oPC, "JS_MEMORIZE_METAMAGIC_IMAGE", JsonArray());
    SetLocalJson(oPC, "JS_MEMORIZE_SPELL_ICON", JsonArray());
    SetLocalJson(oPC, "JS_MEMORIZE_SPELL_TEXT", JsonArray());
    nIndex = 0;
    // List the spells they know from their spellbook.
    if(Get2DAString("classes", "SpellbookRestricted", nClass) == "1")
    {
        int bFilter = JsonGetInt(JsonArrayGet(jFilters, 0));
        if(bFilter) nIndex = ai_SetKnownSpellList(oPC, oAssociate, nIndex, nClass, nLevelSelected, METAMAGIC_ANY);
        bFilter = JsonGetInt(JsonArrayGet(jFilters, 1));
        if(GetHasFeat(FEAT_EMPOWER_SPELL, oAssociate) && bFilter && nLevelSelected > 1) nIndex = ai_SetKnownSpellList(oPC, oAssociate, nIndex, nClass, nLevelSelected - 2, METAMAGIC_EMPOWER);
        bFilter = JsonGetInt(JsonArrayGet(jFilters, 2));
        if(GetHasFeat(FEAT_EXTEND_SPELL, oAssociate) && bFilter && nLevelSelected > 0) nIndex = ai_SetKnownSpellList(oPC, oAssociate, nIndex, nClass, nLevelSelected - 1, METAMAGIC_EXTEND);
        bFilter = JsonGetInt(JsonArrayGet(jFilters, 3));
        if(GetHasFeat(FEAT_QUICKEN_SPELL, oAssociate) && bFilter && nLevelSelected > 3) nIndex = ai_SetKnownSpellList(oPC, oAssociate, nIndex, nClass, nLevelSelected - 4, METAMAGIC_QUICKEN);
        bFilter = JsonGetInt(JsonArrayGet(jFilters, 4));
        if(GetHasFeat(FEAT_SILENCE_SPELL, oAssociate) && bFilter && nLevelSelected > 0) nIndex = ai_SetKnownSpellList(oPC, oAssociate, nIndex, nClass, nLevelSelected - 1, METAMAGIC_SILENT);
        bFilter = JsonGetInt(JsonArrayGet(jFilters, 5));
        if(GetHasFeat(FEAT_STILL_SPELL, oAssociate) && bFilter && nLevelSelected > 0) nIndex = ai_SetKnownSpellList(oPC, oAssociate, nIndex, nClass, nLevelSelected - 1, METAMAGIC_STILL);
    }
    // List the spells from the spells.2da file (they get to choose from them all!). 
    else
    {
        int bFilter = JsonGetInt(JsonArrayGet(jFilters, 0));
        if(bFilter) nIndex = ai_SetSpellList(oPC, nIndex, nClass, nLevelSelected, METAMAGIC_ANY);
        bFilter = JsonGetInt(JsonArrayGet(jFilters, 1));
        if(GetHasFeat(FEAT_EMPOWER_SPELL, oAssociate) && bFilter && nLevelSelected > 1) nIndex = ai_SetSpellList(oPC, nIndex, nClass, nLevelSelected - 2, METAMAGIC_EMPOWER);
        bFilter = JsonGetInt(JsonArrayGet(jFilters, 2));
        if(GetHasFeat(FEAT_EXTEND_SPELL, oAssociate) && bFilter && nLevelSelected > 0) nIndex = ai_SetSpellList(oPC, nIndex, nClass, nLevelSelected - 1, METAMAGIC_EXTEND);
        bFilter = JsonGetInt(JsonArrayGet(jFilters, 3));
        if(GetHasFeat(FEAT_QUICKEN_SPELL, oAssociate) && bFilter && nLevelSelected > 3) nIndex = ai_SetSpellList(oPC, nIndex, nClass, nLevelSelected - 4, METAMAGIC_QUICKEN);
        bFilter = JsonGetInt(JsonArrayGet(jFilters, 4));
        if(GetHasFeat(FEAT_SILENCE_SPELL, oAssociate) && bFilter && nLevelSelected > 0) nIndex = ai_SetSpellList(oPC, nIndex, nClass, nLevelSelected - 1, METAMAGIC_SILENT);
        bFilter = JsonGetInt(JsonArrayGet(jFilters, 5));
        if(GetHasFeat(FEAT_STILL_SPELL, oAssociate) && bFilter && nLevelSelected > 0) nIndex = ai_SetSpellList(oPC, nIndex, nClass, nLevelSelected - 1, METAMAGIC_STILL);
        bFilter = JsonGetInt(JsonArrayGet(jFilters, 6));
        if(GetDomain(oAssociate) > -1 && bFilter) nIndex = ai_SetDomainSpellList(oPC, oAssociate, nIndex, nClass, nLevelSelected);
    }
    jData = JsonArrayInsert(jData, GetLocalJson(oPC, "JS_MEMORIZE_SPELLOBJECT"));
    NuiSetUserData(oPC, nToken, jData);
    NuiSetBind(oPC, nToken, "icon_spell", GetLocalJson(oPC, "JS_MEMORIZE_SPELL_ICON"));
    NuiSetBind(oPC, nToken, "text_spell", GetLocalJson(oPC, "JS_MEMORIZE_SPELL_TEXT"));
    NuiSetBind(oPC, nToken, "metamagic_image",GetLocalJson(oPC, "JS_MEMORIZE_METAMAGIC_IMAGE"));
    DeleteLocalJson(oPC, "JS_MEMORIZE_SPELLOBJECT");
    DeleteLocalJson(oPC, "JS_MEMORIZE_SPELL_ICON");
    DeleteLocalJson(oPC, "JS_MEMORIZE_SPELL_TEXT");
    DeleteLocalJson(oPC, "JS_MEMORIZE_METAMAGIC_IMAGE");
    // Row 4 Spell memorized list label.
    // Row 5 Spell memorized List
    int nMetaMagic, nDomain;
    nIndex = 0;
    nMaxMemorizationSlots = GetMemorizedSpellCountByLevel(oAssociate, nClass, nLevelSelected);
    while(nIndex < nMaxMemorizationSlots)
    {
        sIndex = IntToString(nIndex);
        NuiSetBind(oPC, nToken, "btn_memorized_" + sIndex + "_event", JsonBool(TRUE));
        if(GetMemorizedSpellId(oAssociate, nClass, nLevelSelected, nIndex) > -1)
        {  
            nSpell = GetMemorizedSpellId(oAssociate, nClass, nLevelSelected, nIndex);
            sName = GetStringByStrRef(StringToInt(Get2DAString("spells", "Name", nSpell)));
            nMetaMagic = GetMemorizedSpellMetaMagic(oAssociate, nClass, nLevelSelected, nIndex);
            nDomain = GetMemorizedSpellIsDomainSpell(oAssociate, nClass, nLevelSelected, nIndex);
            sSpellIcon = Get2DAString("spells", "IconResRef", nSpell);
            NuiSetBind(oPC, nToken, "btn_memorized_" + sIndex + "_image", JsonString(sSpellIcon));
            NuiSetBind(oPC, nToken, "btn_memorized_" + sIndex + "_tooltip", JsonString("  " + sName + " (" + sClass + " / " + IntToString(nLevelSelected) + ")"));
            sMetaMagicImage = ai_GetSpellIconAttributes(oAssociate, nMetaMagic, nDomain);
            NuiSetBind(oPC, nToken, "metamagic_" + sIndex + "_image", JsonString(sMetaMagicImage));
        }
        else
        {
            NuiSetBind(oPC, nToken, "btn_memorized_" + sIndex + "_image", JsonString("ctl_cg_btn_splvl"));
            NuiSetBind(oPC, nToken, "metamagic_" + sIndex + "_image", JsonString("mm_none"));
            NuiSetBind(oPC, nToken, "btn_memorized_" + sIndex + "_event", JsonBool(FALSE));
        }
        nIndex++;
    }
}
void ai_CreateSpellKnownMobileNUI(object oPC, object oAssociate) 
{
    // Set window to not save until it has been created.
    SetLocalInt (oPC, AI_NO_NUI_SAVE, TRUE);
    DelayCommand (2.0, DeleteLocalInt (oPC, AI_NO_NUI_SAVE));
    string sAssociateType = ai_GetAssociateType(oPC, oAssociate);
    json jRow = JsonArray();
    // Row 1 Classes************************************************************ 414 / 73
    int nClass, bCaster, nIndex;
    string sIndex, sClassIcon, sLevelIcon;
    for(nIndex = 1; nIndex <= AI_MAX_CLASSES_PER_CHARACTER; nIndex++)
    {
        nClass = GetClassByPosition(nIndex, oAssociate);
        if(nClass != CLASS_TYPE_INVALID)
        {
            if(StringToInt(Get2DAString("classes", "SpellbookRestricted", nClass)))
            {
                // This saves the class position in the button id so we can get it later.
                sIndex = IntToString(nIndex);
                sClassIcon = Get2DAString("classes", "Icon", nClass);
                jRow = CreateButtonImage(jRow, sClassIcon, "btn_class_" + sIndex, 35.0f, 35.0f, 0.0, "btn_class_" + sIndex + "_tooltip");
            }
        }
    }
    jRow = JsonArrayInsert(jRow, NuiSpacer());
    jRow = CreateButton(jRow, "Close", "btn_close", 100.0f, 35.0f);
    json jCol = JsonArrayInsert(JsonArray(), NuiRow(jRow));
    // Row 2 (Levels) ********************************************************** 414 / 116 
    jRow = JsonArray();
    for(nIndex = 0; nIndex <= 9; nIndex++)
    {
        // This saves the level in the button id so we can get it later.
        sIndex = IntToString(nIndex);
        jRow = CreateButtonImage(jRow, "", "btn_level_" + sIndex, 35.0f, 35.0f, 0.0, "btn_level_" + sIndex + "_tooltip");
    }
    jCol = JsonArrayInsert(jCol, NuiRow(jRow));
    // Row 3 (Spell List)******************************************************* 414 / 398 
    json jButton = JsonArray();
    jButton = NuiButton(NuiBind("text_spell"));
    jButton = NuiId(jButton, "btn_text_spell");
    json jRectangle = NuiRect(4.0, 4.0, 27.0, 27.0);
    json jDrawList = JsonArrayInsert(JsonArray(), NuiDrawListImage(JsonBool(TRUE), NuiBind("icon_spell"), jRectangle, JsonInt(NUI_ASPECT_FILL), JsonInt(NUI_HALIGN_CENTER), JsonInt(NUI_VALIGN_MIDDLE)));
    jButton = NuiDrawList(jButton, JsonBool(TRUE), jDrawList);
    json jListTemplate = JsonArrayInsert(JsonArray(), NuiListTemplateCell(jButton, 275.0, FALSE));
    json jInfo = NuiButtonImage(JsonString("gui_cg_qstn_mark"));
    jInfo = NuiId(jInfo, "btn_info_spell");
    jListTemplate = JsonArrayInsert(jListTemplate, NuiListTemplateCell(jInfo, 35.0, FALSE));
    jRow = JsonArrayInsert(JsonArray(), NuiHeight(NuiList(jListTemplate, NuiBind("icon_spell"), 35.0), 282.0));
    jCol = JsonArrayInsert(jCol, NuiRow(jRow));
    // Row 4 (Widget Label)***************************************************** 414 / 426
    jRow = JsonArrayInsert(JsonArray(), NuiSpacer());
    CreateLabel(jRow, "Known Spell List", "lbl_spell_list", 150.0, 20.0, 0, 0, 0.0);
    jRow = JsonArrayInsert(jRow, NuiSpacer());
    jCol = JsonArrayInsert(jCol, NuiRow(jRow));
    // Row 5 (Memorize slots)*************************************************** 414 / 469
    // Get the class and level selected from the database.
    int nClassSelected, nLevelSelected;
    json jSpells;
    json jAIData = ai_GetAssociateDbJson(oPC, sAssociateType, "aidata");
    // Temporary fix for error! :/
    if(JsonGetLength(jAIData) == 0)
    {
        ai_CheckAssociateData(oPC, oAssociate, sAssociateType, TRUE);
        jAIData = ai_GetAssociateDbJson(oPC, sAssociateType, "aidata");
    }
    if(JsonGetLength(jAIData) == 9)
    {
        jSpells = JsonArray();
        jSpells = JsonArrayInsert(jSpells, JsonInt(1));
        jSpells = JsonArrayInsert(jSpells, JsonInt(0));
        jAIData = JsonArrayInsert(jAIData, jSpells);
        ai_SetAssociateDbJson(oPC, sAssociateType, "aidata", jAIData);
    }
    else
    {
        jSpells = JsonArrayGet(jAIData, 10);
        if(JsonGetType(jSpells) == JSON_TYPE_NULL)
        {
            jSpells = JsonArray();
            jSpells = JsonArrayInsert(jSpells, JsonInt(1));
            jSpells = JsonArrayInsert(jSpells, JsonInt(0));
            jAIData = JsonArraySet(jAIData, 10, jSpells);
            ai_SetAssociateDbJson(oPC, sAssociateType, "aidata", jAIData);
        }
        else
        {
            nClassSelected = JsonGetInt(JsonArrayGet(jSpells, 0));
            nLevelSelected = JsonGetInt(JsonArrayGet(jSpells, 1));
        }
    }
    // If we left the Quick Use widget on Special Abilities (10) or Items (11) goto level 0
    if(nLevelSelected == 10 || nLevelSelected == 11)
    {
        nLevelSelected = 0;
        jSpells = JsonArraySet(jSpells, 1, JsonInt(0));
        jAIData = JsonArraySet(jAIData, 10, jSpells);
        ai_SetAssociateDbJson(oPC, sAssociateType, "aidata", jAIData);
    }
    if(nClassSelected < 1 || nClassSelected > AI_MAX_CLASSES_PER_CHARACTER)
    {
        nClassSelected = 1;
        jSpells = JsonArraySet(jSpells, 0, JsonInt(1));
        jAIData = JsonArraySet(jAIData, 10, jSpells);
        ai_SetAssociateDbJson(oPC, sAssociateType, "aidata", jAIData);
    }
    nClass = GetClassByPosition(nClassSelected, oAssociate);  
    jRow = JsonArray();
    for(nIndex = 0; nIndex < 10; nIndex++)
    {
        // This saves the index location of the spell in the list.
        sIndex = IntToString(nIndex);
        json jButton = NuiButtonImage(NuiBind("btn_known_" + sIndex + "_image"));
        jButton = NuiEnabled(jButton, NuiBind("btn_known_" + sIndex + "_event"));
        jButton = NuiId(jButton, "btn_known_" + sIndex);
        jButton = NuiWidth(NuiHeight(jButton, 35.0), 35.0);
        jButton = NuiMargin(jButton, 0.0);
        jButton = NuiTooltip(jButton, NuiBind("btn_known_" + sIndex + "_tooltip"));
        jRow = JsonArrayInsert(jRow, jButton);
    }
    jCol = JsonArrayInsert(jCol, NuiRow(jRow));
    // Do the second row.
    jRow = JsonArray();
    for(nIndex = 10; nIndex < 20; nIndex++)
    {
        // This saves the index location of the spell in the list.
        sIndex = IntToString(nIndex);
        json jButton = NuiButtonImage(NuiBind("btn_known_" + sIndex + "_image"));
        jButton = NuiEnabled(jButton, NuiBind("btn_known_" + sIndex + "_event"));
        jButton = NuiId(jButton, "btn_known_" + sIndex);
        jButton = NuiWidth(NuiHeight(jButton, 35.0), 35.0);
        jButton = NuiMargin(jButton, 0.0);
        jButton = NuiTooltip(jButton, NuiBind("btn_known_" + sIndex + "_tooltip"));
        jRow = JsonArrayInsert(jRow, jButton);
    }
    // Add row to the column.
    jCol = JsonArrayInsert(jCol, NuiRow(jRow));
    // Get the window location to restore it from the database.
    float fX, fY;
    json jLocations = ai_GetAssociateDbJson(oPC, sAssociateType, "locations");
    jLocations = JsonObjectGet(jLocations, sAssociateType + AI_SPELL_KNOWN_NUI);
    if(JsonGetType(jLocations) == JSON_TYPE_NULL) { fX = -1.0; fY = -1.0; }
    else
    {
        fX = JsonGetFloat(JsonObjectGet(jLocations, "x"));
        fY = JsonGetFloat(JsonObjectGet(jLocations, "y"));
    }
    string sText, sName = ai_StripColorCodes(GetName(oAssociate));
    if(GetStringRight(sName, 1) == "s") sName = sName + "'";
    else sName = sName + "'s";
    // Set the Layout of the window.
    json jLayout = NuiCol(jCol);
    int nToken = SetWindow(oPC, jLayout, sAssociateType + AI_SPELL_KNOWN_NUI, sName + " Spell Known Menu",
                           fX, fY, 375.0, 539.0 + 12.0, FALSE, FALSE, TRUE, FALSE, TRUE, "0e_nui");
    // Set the Layout of the window.
    // Save the associate to the nui for use in 0e_nui
    json jData = JsonArrayInsert(JsonArray(), JsonString(ObjectToString(oAssociate)));
    // Set event watches for save window location.
    NuiSetBindWatch(oPC, nToken, "window_geometry", TRUE);
    NuiSetBind(oPC, nToken, "btn_close_event", JsonBool(TRUE));
    // Row 1 & 2 Class & Level 
    int nSpellLevel, nIndexLevel, nMaxSpellLevel, nClassLevel;
    string sClass, sLevel, sLevelImage, sIndexLevel, sSpellsGained;
    for(nIndex = 1; nIndex <= AI_MAX_CLASSES_PER_CHARACTER; nIndex++)
    {
        nClass = GetClassByPosition(nIndex, oAssociate);
        if(nClass != CLASS_TYPE_INVALID)
        {
            bCaster = StringToInt(Get2DAString("classes", "SpellbookRestricted", nClass));
            if(bCaster)
            {
                sClass = GetStringByStrRef(StringToInt(Get2DAString("classes", "Name", nClass)));
                sIndex = IntToString(nIndex);
                NuiSetBind(oPC, nToken, "btn_class_" + sIndex + "_event", JsonBool(TRUE));
                NuiSetBind(oPC, nToken, "btn_class_" + sIndex + "_tooltip", JsonString("  " + sClass));
                if(nClassSelected == nIndex)
                {
                    nClassLevel = ai_GetCasterTotalLevel(oAssociate, nClass);
                    sSpellsGained = Get2DAString("classes", "SpellGainTable", nClass);
                    nMaxSpellLevel = ai_GetClassMaxSpellLevel(oAssociate, nClass);
                    for(nIndexLevel = 0; nIndexLevel <= 9; nIndexLevel++)
                    {
                        sIndexLevel = IntToString(nIndexLevel);
                        if(nIndexLevel <= nMaxSpellLevel)
                        {
                            if(nIndexLevel == 0) sLevelImage = "ir_cantrips";
                            else if(nIndexLevel < 7)sLevelImage = "ir_level" + sIndexLevel;
                            else sLevelImage = "ir_level789";
                            if(nIndexLevel == 0) sLevel = " Cantrips";
                            else if(nIndexLevel == 1) sLevel = " First level";
                            else if(nIndexLevel == 2) sLevel = " Second level";
                            else if(nIndexLevel == 3) sLevel = " Third level";
                            else if(nIndexLevel == 4) sLevel = " Fourth level";
                            else if(nIndexLevel == 5) sLevel = " Fifth level";
                            else if(nIndexLevel == 6) sLevel = " Sixth level";
                            else if(nIndexLevel == 7) sLevel = " Seventh level";
                            else if(nIndexLevel == 8) sLevel = " Eighth level";
                            else if(nIndexLevel == 9) sLevel = " Ninth level";
                            NuiSetBind(oPC, nToken, "btn_level_" + sIndexLevel + "_event", JsonBool(TRUE));
                            NuiSetBind(oPC, nToken, "btn_level_" + sIndexLevel + "_tooltip", JsonString("  " + sLevel));
                            NuiSetBind(oPC, nToken, "btn_level_" + sIndexLevel + "_image", JsonString(sLevelImage));
                        }
                        else
                        {
                            NuiSetBind(oPC, nToken, "btn_level_" + sIndexLevel + "_event", JsonBool(TRUE));
                            NuiSetBind(oPC, nToken, "btn_level_" + sIndexLevel + "_image", JsonString("ctl_cg_btn_splvl"));
                            NuiSetBind(oPC, nToken, "btn_level_" + sIndexLevel + "_event", JsonBool(FALSE));
                        }
                    }
                    NuiSetBind(oPC, nToken, "btn_level_" + IntToString(nLevelSelected) + "_encouraged", JsonBool(TRUE));
                    NuiSetBind(oPC, nToken, "btn_class_" + IntToString(nClassSelected) + "_encouraged", JsonBool(TRUE));
                }
            }
        }
    }
    // Row 3 Spells 
    int nSpellSlot, nSpell, nMetamagic;
    json jSpell;
    json jWidget = JsonArrayGet(jSpells, 2);
    nClass = GetClassByPosition(nClassSelected, oAssociate);
    string sSpellIcon, sSpellName, sMetaMagicText;
    json jSpellArray = JsonArray();
    json jSpell_Icon = JsonArray();
    json jSpell_Text = JsonArray();
    // List the spells from the spells.2da file (they get to choose from them all!).
    string sSpellTableColumn = Get2DAString("classes", "SpellTableColumn", nClass);
    int nMaxSpells = Get2DARowCount("spells");
    while(nSpell < nMaxSpells)
    {
        sLevel = Get2DAString("spells", sSpellTableColumn, nSpell);
        if(sLevel != "")
        {
            if(StringToInt(sLevel) == nLevelSelected)
            {
                jSpellArray = JsonArrayInsert(jSpellArray, JsonInt(nSpell));
                sSpellIcon = Get2DAString("spells", "IconResRef", nSpell);
                sSpellName = GetStringByStrRef(StringToInt(Get2DAString("spells", "Name", nSpell)));
                jSpell_Icon = JsonArrayInsert(jSpell_Icon, JsonString(sSpellIcon));
                jSpell_Text = JsonArrayInsert(jSpell_Text, JsonString(sSpellName));
            }
        }
        ++nSpell;
    }
    jData = JsonArrayInsert(jData, jSpellArray);
    NuiSetUserData(oPC, nToken, jData);
    NuiSetBind(oPC, nToken, "icon_spell", jSpell_Icon);
    NuiSetBind(oPC, nToken, "text_spell", jSpell_Text);
    // Row 4 Spell known list label.
    // Row 5 Spell known List
    int nMetaMagic, nDomain, nMaxKnownSlots;
    json jClassList = GetLocalJson(oAssociate, AI_CLASS_LIST_JSON);
    if(JsonGetType(jClassList) == JSON_TYPE_NULL)
    {
        jClassList = ObjectToJson(oAssociate);
        jClassList = GffGetList(jClassList, "ClassList");
        SetLocalJson(oAssociate, AI_CLASS_LIST_JSON, jClassList);
    }
    // Get the correct class array.
    nIndex = 0;
    json jClass = JsonArrayGet(jClassList, nIndex);
    while(JsonGetInt(GffGetInt(jClass, "Class")) != nClass)
    {
        jClass = JsonArrayGet(jClassList, ++nIndex);
    }
    json jKnownList = GffGetList(jClass, "KnownList" + IntToString(nLevelSelected));
    string sSpellKnownTable = Get2DAString("classes", "SpellKnownTable", nClass);
    if(sSpellKnownTable != "") nMaxKnownSlots = StringToInt(Get2DAString(sSpellKnownTable, "SpellLevel" + IntToString(nLevelSelected), nClassLevel - 1));
    else nMaxKnownSlots = 20;
    nIndex = 0;
    while(nIndex < 20)
    {
        sIndex = IntToString(nIndex);
        NuiSetBind(oPC, nToken, "btn_known_" + sIndex + "_event", JsonBool(TRUE));
        if(nIndex < nMaxKnownSlots)
        {
            jSpell = JsonArrayGet(jKnownList, nIndex);
            if(JsonGetType(jSpell) == JSON_TYPE_NULL)
            {
                NuiSetBind(oPC, nToken, "btn_known_" + sIndex + "_image", JsonString("ctl_cg_btn_splvl"));
                NuiSetBind(oPC, nToken, "btn_known_" + sIndex + "_tooltip", JsonString("  Empty known spell slot"));
            }
            else
            {
                nSpell = JsonGetInt(GffGetWord(jSpell, "Spell"));
                sName = GetStringByStrRef(StringToInt(Get2DAString("spells", "Name", nSpell)));
                sSpellIcon = Get2DAString("spells", "IconResRef", nSpell);
                NuiSetBind(oPC, nToken, "btn_known_" + sIndex + "_image", JsonString(sSpellIcon));
                NuiSetBind(oPC, nToken, "btn_known_" + sIndex + "_tooltip", JsonString("  " + sName + " (" + sClass + " / " + IntToString(nLevelSelected) + ")"));
            }
        }
        else
        {
            NuiSetBind(oPC, nToken, "btn_known_" + sIndex + "_image", JsonString("ctl_cg_btn_splvl"));
            NuiSetBind(oPC, nToken, "btn_known_" + sIndex + "_event", JsonBool(FALSE));
        }
        ++nIndex;
    }
}
void ai_CreateDescriptionMobileNUI(object oPC, json jSpell, int nSpell = 0) 
{
    // Row 1 ******************************************************************* 500 / 469
    json jRow = CreateImage(JsonArray(), "", "spell_icon", NUI_ASPECT_FIT, NUI_HALIGN_CENTER, NUI_VALIGN_MIDDLE, 40.0, 40.0);
    jRow = CreateTextBox(jRow, "spell_text", 380.0, 400.0, FALSE, NUI_SCROLLBARS_Y);
    // Add row to the column.
    json jCol = JsonArrayInsert(JsonArray(), NuiRow(jRow));
    // Row 1 ******************************************************************* 500 / 522
    jRow = JsonArrayInsert(JsonArray(), NuiSpacer());
    jRow = CreateButton(jRow, "OK", "btn_ok", 150.0f, 45.0f);
    // Add row to the column.
    jCol = JsonArrayInsert(jCol, NuiRow(jRow));
    // Set the Layout of the window.
    json jLayout = NuiCol(jCol);
    string sName, sIcon, sDescription;
    int nFeat, nDescription;
    int nClass;
    if(nSpell) nClass = 0;
    else
    {
        nSpell = JsonGetInt(JsonArrayGet(jSpell, 0));
        nClass = JsonGetInt(JsonArrayGet(jSpell, 1));
    }
    if(nClass == -1)
    {
        if(nSpell == SPELL_HEALINGKIT)
        {
            sName = "Healer's Kit";
            sIcon = "isk_heal";
            sDescription = GetStringByStrRef(1720);
        }
        else
        {
            sName = GetStringByStrRef(StringToInt(Get2DAString("spells", "Name", nSpell)));
            sIcon = Get2DAString("spells", "IconResRef", nSpell);
            nDescription = StringToInt(Get2DAString("spells", "SpellDesc", nSpell));
            if(nDescription) sDescription = GetStringByStrRef(nDescription);
            else
            {
                object oItem = GetObjectByUUID(JsonGetString(JsonArrayGet(jSpell, 5)));
                sDescription = GetDescription(oItem);
            }
        }
    }
    else
    {
        nFeat = JsonGetInt(JsonArrayGet(jSpell, 5));
        if(nFeat)
        {
            if(nSpell)
            {
                sName = GetStringByStrRef(StringToInt(Get2DAString("spells", "Name", nSpell)));
                sIcon = Get2DAString("spells", "IconResRef", nSpell);
            }
            else
            {
                sName = GetStringByStrRef(StringToInt(Get2DAString("feat", "FEAT", nFeat)));
                sIcon = Get2DAString("feat", "ICON", nFeat);
            }
            sDescription = GetStringByStrRef(StringToInt(Get2DAString("feat", "DESCRIPTION", nFeat)));
        }
        else
        {
            sName = GetStringByStrRef(StringToInt(Get2DAString("spells", "Name", nSpell)));
            sIcon = Get2DAString("spells", "IconResRef", nSpell);
            nDescription = StringToInt(Get2DAString("spells", "SpellDesc", nSpell));
            if(nDescription) sDescription = GetStringByStrRef(nDescription);
            else
            {
                object oItem = GetObjectByUUID(JsonGetString(JsonArrayGet(jSpell, 5)));
                sDescription = GetDescription(oItem);
            }
        }
    }
    int nToken = SetWindow(oPC, jLayout, AI_SPELL_DESCRIPTION_NUI, sName,
                             -1.0, -1.0, 460.0f, 537.0 + 12.0f, FALSE, FALSE, TRUE, FALSE, TRUE, "0e_nui");
    json jData = JsonArrayInsert(JsonArray(), JsonString(ObjectToString(oPC)));
    NuiSetUserData(oPC, nToken, jData);
    // Row 1
    NuiSetBind(oPC, nToken, "spell_icon_event", JsonBool(TRUE));
    NuiSetBind(oPC, nToken, "spell_icon_image", JsonString(sIcon));
    NuiSetBind(oPC, nToken, "spell_text_event", JsonBool(TRUE));
    NuiSetBind(oPC, nToken, "spell_text", JsonString(sDescription));
    // Row 2
    NuiSetBind(oPC, nToken, "btn_ok_event", JsonBool(TRUE));
}