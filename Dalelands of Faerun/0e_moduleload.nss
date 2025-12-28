/*////////////////////////////////////////////////////////////////////////////////////////////////////
 Script Name: 0e_moduleload
 Programmer: Philos
//////////////////////////////////////////////////////////////////////////////////////////////////////
 Event script that runs when the module is loaded into the server.
*/////////////////////////////////////////////////////////////////////////////////////////////////////
#include "x2_inc_switches"
#include "0i_database"
#include "nwnx_events"
#include "nwnx_damage"
#include "nwnx_elc"
#include "nwnx_feedback"
#include "nwnx_race_2da"
#include "0i_character"
#include "0i_webhook"
void main ()
{
    int iValue;
    string sName;
    object oModule = GetModule();
    CheckServerDataTableAndCreateTable(SERVER_TABLE);
    CheckServerDataTableAndCreateTable(PLAYER_TABLE);
    CheckServerDataTableAndCreateTable(OBJECT_TABLE);
    CheckServerDataTableAndCreateTable(DM_TABLE);
    CheckServerDataTableAndCreateTable(QUEST_TABLE);
    CheckServerDataTableAndCreateTable(ADVENTURE_TABLE);
    CheckServerDataTableAndCreateTable(AREA_TABLE);
    CheckServerDataTableAndCreateTable(ADV_OBJ_TABLE);
    CheckServerDataTableAndCreateTable(BUFF_TABLE);
    CheckServerDataAndInitialize(oModule, SERVER_TABLE);
    GetServerCalendarFromDatabase();
    SetMaxHenchmen(SERVER_MAX_HENCHMAN);
    // Set Color Tokens for use in the TLK.
    SetColorTokens();
    // *************************************************
    // ***** Load database variables to the module *****
    // *************************************************
    SetLocalFloat(oModule, "0_XP_SLIDER", IntToFloat (GetServerDatabaseInt (oModule, SERVER_TABLE, "xpslider")));
    SetLocalInt(oModule, "0_TREASURE_SLIDER", GetServerDatabaseInt (oModule, SERVER_TABLE, "treasureslider"));
    SetLocalInt(oModule, "0_VILLAIN_CHANCE", GetServerDatabaseInt (oModule, SERVER_TABLE, "villainchance"));
    SetLocalInt(oModule, "0_UNIQUE_CHANCE", GetServerDatabaseInt (oModule, SERVER_TABLE, "uniquechance"));
    // *************************************
    // ***** Subscribe to events. *****
    // *************************************
    //SetEventScript(oModule, EVENT_SCRIPT_MODULE_ON_PLAYER_GUIEVENT, "0e_gui_events");
    // On entering stealth - used to time limit stealth use (an exploit).
    NWNX_Events_SubscribeEvent("NWNX_ON_ENTER_STEALTH_AFTER", "0e_oe_stealth_a");
    // Used instead of the base games on client leave.
    NWNX_Events_SubscribeEvent("NWNX_ON_CLIENT_DISCONNECT_BEFORE", "0e_clientleave");
    // On use skill - pickpocket skill.
    NWNX_Events_SubscribeEvent("NWNX_ON_USE_SKILL_BEFORE", "0e_ou_skill_b");
    // On use skill - disable traps requires tools.
    NWNX_Events_SubscribeEvent("NWNX_ON_TRAP_DISARM_BEFORE", "0e_ot_disarm_b");
    // On use skill - open locks requires tools.
    NWNX_Events_SubscribeEvent("NWNX_ON_OBJECT_UNLOCK_BEFORE", "0e_oo_unlock_b");
    // Used to setup some PRC classes variables when they hit the level up button.
    NWNX_Events_SubscribeEvent("NWNX_ON_CLIENT_LEVEL_UP_BEGIN_BEFORE", "0e_pclvlupbefore");
    // Used for web hook on discord after leveling up.
    NWNX_Events_SubscribeEvent("NWNX_ON_LEVEL_UP_AFTER", "0e_pclvlupafter");
    // Use for player input in map pins.
    NWNX_Events_SubscribeEvent("NWNX_ON_MAP_PIN_ADD_PIN_AFTER", "0e_pin_adda");
    // Used for henchman gold sink.
    //NWNX_Events_SubscribeEvent("NWNX_ON_INVENTORY_ADD_GOLD_BEFORE", "0e_oi_add_gold_b");
    // Used for system to replace transition triggers at edge of the maps.
    NWNX_Events_SubscribeEvent("NWNX_ON_INPUT_WALK_TO_WAYPOINT_BEFORE", "0e_oi_walk_wp_b");
    // Used to display different information on examine for PC's and DM's.
    NWNX_Events_SubscribeEvent("NWNX_ON_EXAMINE_OBJECT_BEFORE", "0e_oe_object_b");
    // DM spawn event - used to add variables to spawned items.
    NWNX_Events_SubscribeEvent("NWNX_ON_DM_SPAWN_OBJECT_AFTER", "0e_dm_spawn_a");
    // DM give event - used to add variables to items created by the dm.
    NWNX_Events_SubscribeEvent("NWNX_ON_DM_GIVE_ITEM_AFTER", "0e_dm_give_a");
    // PC character sheet open event - used to add information to character sheet.
    NWNX_Events_SubscribeEvent("NWNX_ON_CHARACTER_SHEET_OPEN_BEFORE", "0e_cs_open_b");
    // Sell Store event - Used to stop selling items that are equiped or have temp enchants.
    NWNX_Events_SubscribeEvent("NWNX_ON_STORE_REQUEST_SELL_BEFORE", "0e_osr_sell_b");
    // Acquire Item Events - Used to block players from aquiring other players quest items
    // Only works on items on the ground, or given via script.
    NWNX_Events_SubscribeEvent("NWNX_ON_ITEM_ACQUIRE_BEFORE", "0e_oi_acquire_b");
    // Barter start Event - Used to stop Henchmen from taking gold during a barter.
    //NWNX_Events_SubscribeEvent("NWNX_ON_BARTER_START_BEFORE", "0e_ob_start_b");
    // Barter end Event - Used to stop Henchmen from taking gold during a barter.
    //NWNX_Events_SubscribeEvent("NWNX_ON_BARTER_END_AFTER", "0e_ob_end_a");
    // Openface helms effect removal on client leave.
    NWNX_Events_SubscribeEvent("NWNX_ON_CLIENT_DISCONNECT_AFTER", "0e_oc_discon_a");
    // On damage event - Used to adjust damage or record damage when done.
    NWNX_Damage_SetDamageEventScript("0e_Damaged");
    // Must setup Item Level requirements here as the module loads.
    NWNX_Item_SetMinEquipLevelModifier(OBJECT_INVALID, 0, TRUE);
    // Script to run on any ELC.
    NWNX_ELC_SetELCScript("0e_elc");
    // Setup Racial abilities. These are defined in rmt_*.2da files for each race.
    NWNX_Race_LoadRacialModifiers();
    SetNewSkillFeats();
    // *************************************
    // ***** Adjust feedback messages. *****
    // *************************************
    // Stop "Weapon not Effective messages".
    NWNX_Feedback_SetFeedbackMessageHidden(NWNX_FEEDBACK_COMBAT_WEAPON_NOT_EFFECTIVE, TRUE);
    // *************************************
    // *****      Tlk Overrides.       *****
    // *************************************
    // Change alignments to initials so classes show up in character sheet.
    SetTlkOverride(112, "LG");
    SetTlkOverride(113, "LN");
    SetTlkOverride(114, "LE");
    SetTlkOverride(115, "NG");
    SetTlkOverride(116, "TN");
    SetTlkOverride(117, "NE");
    SetTlkOverride(118, "CG");
    SetTlkOverride(119, "CN");
    SetTlkOverride(120, "CE");
    // Renamed "Remove from party" on radial menu.
    SetTlkOverride(1068, "Patrol ahead");
    // Renamed "Attack Nearest" on radial menu.
    SetTlkOverride(5345, "Attack");
    // Rename "Pick Lock" on ...
    SetTlkOverride(1467, "Bypass Lock");
    // *************************************
    // *****     Run all switches.     *****
    // *************************************
    // Scrolls make a check 7 + (spell level * 3).
    //---------------------------------------------------------------------------
    // * Force Use Magic Device Skillchecks, Default = FALSE except for GAME_DIFFICULTY_CORE_RULES+
    // * If switched to TRUE, a rogue has to succeed in a UMD check against DC 7+SpellLevel*3
    // * in order to use a scroll. See x2_pc_umdcheck.nss for details
    //---------------------------------------------------------------------------
    SetLocalInt(oModule, MODULE_SWITCH_ENABLE_UMD_SCROLLS, TRUE);
    //---------------------------------------------------------------------------
    // * Some epic spells, namely Hellball, do damage to the caster. We found this too confusing
    // * in testing, so it was disabled. You can reactivate using this flag
    //---------------------------------------------------------------------------
    SetLocalInt(oModule, MODULE_SWITCH_EPIC_SPELLS_HURT_CASTER, TRUE);
    //---------------------------------------------------------------------------
    // * By default, all characters can use the various poisons that can be found to poison their weapons if
    // * they win a Dex check. Activating this flag will restrict the use of poison to chars with the UsePoison
    // * feat only
    //---------------------------------------------------------------------------
    SetLocalInt(oModule, MODULE_SWITCH_RESTRICT_USE_POISON_TO_FEAT, TRUE);
    //---------------------------------------------------------------------------
    // * Setting this switch to TRUE will make the Glyph of warding symbol disappear after 6 seconds, but
    // * the glyph will stay active....
    //---------------------------------------------------------------------------
    SetLocalInt(oModule, MODULE_SWITCH_ENABLE_INVISIBLE_GLYPH_OF_WARDING, TRUE);
    //---------------------------------------------------------------------------
    // * Setting this variable to TRUE will cause the Expertise/Improved Expertise
    // * modes to be disabled whenever a player is casting a spell.
    //---------------------------------------------------------------------------
    SetLocalInt(oModule, MODULE_VAR_AI_STOP_EXPERTISE_ABUSE, TRUE);
    //---------------------------------------------------------------------------
    // * Toggle on/off the Item Creation Feats, Default = O
    // * Disable the Item Creation Feats that come with Hordes of the Underdark for the module.
    //---------------------------------------------------------------------------
    SetLocalInt(oModule, MODULE_SWITCH_DISABLE_ITEM_CREATION_FEATS, TRUE);
    string s2DAText, sMessage = "The server is online.";
    s2DAText = "\\n" + Get2DAString ("Messages", "Text", 1);
    if (s2DAText != "") sMessage += s2DAText;
    s2DAText = "\\n" + Get2DAString ("Messages", "Text", 3);
    if (s2DAText != "") sMessage += "**" + s2DAText + "**";
    s2DAText = "\\n" + Get2DAString ("Messages", "Text", 4);
    if (s2DAText != "") sMessage += s2DAText;
    s2DAText = "\\n" + Get2DAString ("Messages", "Text", 5);
    if (s2DAText != "") sMessage += "**" + s2DAText + "**";
    s2DAText = "\\n" + Get2DAString ("Messages", "Text", 6);
    if (s2DAText != "") sMessage += s2DAText;
    s2DAText = "\\n" + Get2DAString ("Messages", "Text", 7);
    if (s2DAText != "") sMessage += "**" + s2DAText + "**";
    SendServerMessageToDiscord("", sMessage, SERVER_NAME, SERVER_COLOR, "https://nwn.wiki/download/thumbnails/3473429/logo-small.png");
}

