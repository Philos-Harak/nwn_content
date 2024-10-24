/*//////////////////////////////////////////////////////////////////////////////
// Script Name: 0i_single_player
////////////////////////////////////////////////////////////////////////////////
 Include script for handling event scripts for the campaign and most single
 player modules.
*///////////////////////////////////////////////////////////////////////////////
#include "0i_associates"
//#include "0i_assoc_debug"
#include "0i_constants"
#include "0i_messages"
// Sets the events for oCreature that use event scripts for monsters in most modules.
void ai_SetMonsterEventScripts(object oCreature);
// Sets the events for oCreature that use event scripts for monsters in Infinite Dungeons.
void ai_SetIDMonsterEventScripts(object oCreature);
// Sets the events for oCreature that use event scripts for associates.
void ai_SetAssociateEventScripts(object oCreature);
// Reverts a single players monsters, NPC's and associate event scripts back to their default.
void ai_FixEventScripts(object oCreature);
//******************************************************************************
//********************* Creature event scripts *********************************
//******************************************************************************
// These scripts are one line inserts for the creature event they go at the end.
// example ai_OnDeath goes at the end of the OnDeath event (nw_c2_default7).

// Add to nw_c2_default9 OnSpawn event script of monsters and
void ai_OnMonsterSpawn(object oCreature, int bIncorporeal);
// Add to nw_ch_ac9 OnSpawn event script of henchman.
void ai_OnAssociateSpawn(object oCreature);

//******************************************************************************
//********************* Creature event scripts *********************************
//******************************************************************************
void ai_OnMonsterSpawn(object oCreature, int bIncorporeal)
{
    if(bIncorporeal)
    {
        string sCombatAI = GetLocalString(oCreature, AI_DEFAULT_SCRIPT);
        if (sCombatAI == "") SetLocalString(oCreature, AI_DEFAULT_SCRIPT, "ai_incorporeal");
    }
    ai_SetListeningPatterns(oCreature);
    ai_SetCreatureAIScript(oCreature);
    ai_SetMonsterEventScripts(oCreature);
    ai_SetNormalAppearance(oCreature);
    ai_SetAura(oCreature);
    SetLocalInt(oCreature, AI_HEAL_IN_COMBAT_LIMIT, 70);
    SetLocalInt(oCreature, AI_HEAL_OUT_OF_COMBAT_LIMIT, 70);
    // If we have already seen an enemy then we need to begin combat!
    object oEnemy = GetNearestEnemy(oCreature);
    //ai_Debug("0i_single_player", "43", GetName(oCreature) + " nearest enemy: " + GetName(oEnemy) +
    //         " Distance: " + FloatToString(GetDistanceBetween(oCreature, oEnemy), 0, 2) +
    //         " Talents set? " + IntToString(GetLocalInt(oCreature, AI_TALENTS_SET)));
    if(oEnemy != OBJECT_INVALID && GetDistanceBetween(oCreature, oEnemy) < AI_RANGE_PERCEPTION)
    {
        ai_SetCreatureTalents(oCreature, FALSE);
        SetLocalInt(oCreature, AI_TALENTS_SET, TRUE);
        //ai_Debug("0i_single_player", "52", GetName(oCreature) + " is starting combat!");
        ai_DoMonsterCombatRound(oCreature);
    }
}
void ai_OnAssociateSpawn(object oCreature)
{
    // Initialize Associate modes for basic use.
    SetLocalFloat(oCreature, AI_FOLLOW_RANGE, 3.0);
    SetLocalInt(oCreature, AI_HEAL_IN_COMBAT_LIMIT, 50);
    SetLocalInt(oCreature, AI_HEAL_OUT_OF_COMBAT_LIMIT, 70);
    SetLocalFloat(oCreature, AI_LOOT_CHECK_RANGE, 20.0);
    SetLocalFloat(oCreature, AI_LOCK_CHECK_RANGE, 20.0);
    SetLocalFloat(oCreature, AI_TRAP_CHECK_RANGE, 20.0);
    ai_SetMagicMode(oCreature, AI_MAGIC_NORMAL_MAGIC_USE);
    ai_SetListeningPatterns(oCreature);
    ai_SetAssociateEventScripts(oCreature);
    ai_SetNormalAppearance(oCreature);
    ai_SetAssociateAIScript(oCreature, FALSE);
    ai_SetAura(oCreature);
    // Bioware summoned shadows are not incorporeal, also set the ai code.
    if (GetTag(OBJECT_SELF) == "NW_S_SHADOW")
    {
        SetLocalInt(OBJECT_SELF, "X2_L_IS_INCORPOREAL", TRUE);
        SetLocalString(OBJECT_SELF, AI_DEFAULT_SCRIPT, "ai_shadow");
    }
}
void ai_SetMonsterEventScripts(object oCreature)
{
    //ai_Debug("0i_single_player", "93", "Changing " + GetName(oCreature) + "'s event scripts.");
    string sScript = GetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_HEARTBEAT);
    SetLocalString(oCreature, "AI_ON_HEARTBEAT", sScript);
    if(sScript == "" || sScript == "nw_c2_default1") SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_HEARTBEAT, "0e_c2_1_hb");
    else if(sScript == "x2_def_heartbeat") SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_HEARTBEAT, "0e_c2_1_hb");
    else WriteTimestampedLogEntry("ON_HEARTBEAT SCRIPT ERROR: AI did not capture " + sScript + " script for " + GetName(oCreature) + ".");
    sScript = GetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_NOTICE);
    SetLocalString(oCreature, "AI_ON_NOTICE", sScript);
    if(sScript == "" || sScript == "nw_c2_default2") SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_NOTICE, "0e_c2_2_percept");
    else if(sScript == "x2_def_percept") SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_NOTICE, "0e_c2_2_percept");
    else if(sScript == "m1q5e01zombie2" || sScript == "m1q5dcultist_2") {/*Let the base script run*/}
    else if(sScript == "m0q0_mystmage_2") {/*Let the base script run*/}
    else if(sScript == "m1q0cboss2") SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_NOTICE, "0e_c2_2_percept");
    else WriteTimestampedLogEntry("ON_NOTICE SCRIPT ERROR: AI did not capture " + sScript + " script for " + GetName(oCreature) + ".");
    sScript = GetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_END_COMBATROUND);
    SetLocalString(oCreature, "AI_ON_END_COMBATROUND", sScript);
    if(sScript == "" || sScript == "nw_c2_default3") SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_END_COMBATROUND, "0e_c2_3_endround");
    else if(sScript == "x2_def_endcombat") SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_END_COMBATROUND, "0e_c2_3_endround");
    else if (sScript == "m1_combanter_3") SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_END_COMBATROUND, "0e_m1_3_endround");
    else if (sScript == "m1q0dboss") SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_END_COMBATROUND, "0e_3_m1q0dboss");
    else if (sScript == "m1q0dendboss3") SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_END_COMBATROUND, "0e_3_m1q0dboss");
    else if (sScript == "m1q2devour3") SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_END_COMBATROUND, "0e_3_m1q2devour3");
    else WriteTimestampedLogEntry("ON_END_COMBATROUND SCRIPT ERROR: AI did not capture " + sScript + " script for " + GetName(oCreature) + ".");
    sScript = GetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_DIALOGUE);
    SetLocalString(oCreature, "AI_ON_DIALOGUE", sScript);
    if(sScript == "" || sScript == "nw_c2_default4") SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_DIALOGUE, "0e_c2_4_convers");
    else if(sScript == "x2_def_onconv") SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_DIALOGUE, "0e_c2_4_convers");
    else if(sScript == "m1q2daelp_4") {/*Let the base script run*/}
    else if(sScript == "m1q3adryad4") SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_DIALOGUE, "0e_4_m1q3adryad4");
    else if(sScript == "m1q1apyre_4") SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_DIALOGUE, "0e_4_m1q1apyre_4");
    else WriteTimestampedLogEntry("ON_DIALOGUE_SCRIPT ERROR: AI did not capture " + sScript + " script for " + GetName(oCreature) + ".");
    sScript = GetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_MELEE_ATTACKED);
    SetLocalString(oCreature, "AI_ON_MELEE_ATTACKED", sScript);
    if(sScript == "" || sScript == "nw_c2_default5") SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_MELEE_ATTACKED, "0e_c2_5_phyatked");
    else if(sScript == "x2_def_attacked") SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_MELEE_ATTACKED, "0e_c2_5_phyatked");
    else if(sScript == "m1q02devour5") SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_MELEE_ATTACKED, "0e_5_m1q2devour5");
    else WriteTimestampedLogEntry("ON_MELEE_ATTACKED_SCRIPT ERROR: AI did not capture " + sScript + " script for " + GetName(oCreature) + ".");
    sScript = GetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_DAMAGED);
    SetLocalString(oCreature, "AI_ON_DAMAGED", sScript);
    if(sScript == "" || sScript == "nw_c2_default6") SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_DAMAGED, "0e_c2_6_damaged");
    else if(sScript == "x2_def_ondamage") SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_DAMAGED, "0e_c2_6_damaged");
    else WriteTimestampedLogEntry("ON_DAMAGED_SCRIPT ERROR: AI did not capture " + sScript + " script for " + GetName(oCreature) + ".");
    // This is always set incase they have permanent summons turned on.
    sScript = GetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_DEATH);
    SetLocalString(oCreature, "AI_ON_DEATH", sScript);
    SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_DEATH, "0e_c2_7_ondeath");
    sScript = GetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_DISTURBED);
    SetLocalString(oCreature, "AI_ON_DISTURBED", sScript);
    if(sScript == "" || sScript == "nw_c2_default8") SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_DISTURBED, "0e_c2_8_disturb");
    else if(sScript == "x2_def_ondisturb") SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_DISTURBED, "0e_c2_8_disturb");
    else WriteTimestampedLogEntry("ON_DISTURBED_SCRIPT ERROR: AI did not capture " + sScript + " script for " + GetName(oCreature) + ".");
    //SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_SPAWN_IN, "");
    sScript = GetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_RESTED);
    SetLocalString(oCreature, "AI_ON_RESTED", sScript);
    // We just save the monsters rest event script incase we need to revert it for a user.
    //if(sScript == "" || sScript == "nw_c2_defaulta") SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_RESTED, "0e_c2_a_rested);
    //else WriteTimestampedLogEntry("ON_RESTED SCRIPT ERROR: AI did not capture " + sScript + " script for " + GetName(oCreature) + ".");
    sScript = GetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_SPELLCASTAT);
    SetLocalString(oCreature, "AI_ON_SPELLCASTAT", sScript);
    if(sScript == "" || sScript == "nw_c2_defaultb") SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_SPELLCASTAT, "0e_c2_b_castat");
    else if(sScript == "x2_def_spellcast") SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_SPELLCASTAT, "0e_c2_b_castat");
    else WriteTimestampedLogEntry("ON_SPELLCASTAT_SCRIPT ERROR: AI did not capture " + sScript + " script for " + GetName(oCreature) + ".");
    sScript = GetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_BLOCKED_BY_DOOR);
    SetLocalString(oCreature, "AI_ON_BLOCKED_BY_DOOR", sScript);
    if(sScript == "" || sScript == "nw_c2_defaulte") SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_BLOCKED_BY_DOOR, "0e_c2_e_blocked");
    else if(sScript == "x2_def_onblocked") SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_BLOCKED_BY_DOOR, "0e_c2_e_blocked");
    else WriteTimestampedLogEntry("ON_BLOCKED_BY_DOOR SCRIPT ERROR: AI did not capture " + sScript + " script for " + GetName(oCreature) + ".");
    //SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_USER_DEFINED_EVENT, "");
}
void ai_SetAssociateEventScripts(object oCreature)
{
    //ai_Debug("0i_single_player", "146", "Changing " + GetName(oCreature) + "'s event scripts.");
    string sScript = GetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_HEARTBEAT);
    SetLocalString(oCreature, "AI_ON_HEARTBEAT", sScript);
    if(sScript == "" || sScript == "nw_ch_ac1") SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_HEARTBEAT, "0e_ch_1_hb");
    else if(sScript == "x0_ch_hen_heart") SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_HEARTBEAT, "0e_ch_1_hb");
    else WriteTimestampedLogEntry("ON_HEARTBEAT SCRIPT ERROR: AI did not capture " + sScript + " script for " + GetName(oCreature) + ".");
    sScript = GetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_NOTICE);
    SetLocalString(oCreature, "AI_ON_NOTICE", sScript);
    if(sScript == "" || sScript == "nw_ch_ac2") SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_NOTICE, "0e_ch_2_percept");
    else if(sScript == "x0_ch_hen_percep") SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_NOTICE, "0e_ch_2_percept");
    else WriteTimestampedLogEntry("ON_NOTICE SCRIPT ERROR: AI did not capture " + sScript + " script for " + GetName(oCreature) + ".");
    sScript = GetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_END_COMBATROUND);
    SetLocalString(oCreature, "AI_ON_END_COMBATROUND", sScript);
    if(sScript == "" || sScript == "nw_ch_ac3") SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_END_COMBATROUND, "0e_ch_3_endround");
    else if(sScript == "x0_ch_hen_combat") SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_END_COMBATROUND, "0e_ch_3_endround");
    else WriteTimestampedLogEntry("ON_END_COMBATROUND SCRIPT ERROR: AI did not capture " + sScript + " script for " + GetName(oCreature) + ".");
    sScript = GetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_DIALOGUE);
    SetLocalString(oCreature, "AI_ON_DIALOGUE", sScript);
    if(sScript == "" || sScript == "nw_ch_ac4") SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_DIALOGUE, "0e_ch_4_convers");
    else if(sScript == "x0_ch_hen_conv") SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_DIALOGUE, "0e_ch_4_convers");
    else WriteTimestampedLogEntry("ON_DIALOGUE SCRIPT ERROR: AI did not capture " + sScript + " script for " + GetName(oCreature) + ".");
    sScript = GetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_MELEE_ATTACKED);
    SetLocalString(oCreature, "AI_ON_MELEE_ATTACKED", sScript);
    if(sScript == "" || sScript == "nw_ch_ac5") SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_MELEE_ATTACKED, "0e_ch_5_phyatked");
    else if(sScript == "x0_ch_hen_attack") SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_MELEE_ATTACKED, "0e_ch_5_phyatked");
    else WriteTimestampedLogEntry("ON_MELEE_ATTACKED SCRIPT ERROR: AI did not capture " + sScript + " script for " + GetName(oCreature) + ".");
    sScript = GetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_DAMAGED);
    SetLocalString(oCreature, "AI_ON_DAMAGED", sScript);
    if(sScript == "" || sScript == "nw_ch_ac6") SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_DAMAGED, "0e_ch_6_damaged");
    // Added due to summon monsters having the incorrect script attached to the on damage event.
    else if(sScript == "nw_ch_ac5") SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_DAMAGED, "0e_c2_6_damaged");
    else if(sScript == "x0_ch_hen_damage") SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_DAMAGED, "0e_ch_6_damaged");
    else WriteTimestampedLogEntry("ON_DAMAGED SCRIPT ERROR: AI did not capture " + sScript + " script for " + GetName(oCreature) + ".");
    // This is always set incase they have permanent summons turned on.
    sScript = GetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_DEATH);
    SetLocalString(oCreature, "AI_ON_DEATH", sScript);
    SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_DEATH, "0e_ch_7_death");
    sScript = GetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_DISTURBED);
    SetLocalString(oCreature, "AI_ON_DISTURBED", sScript);
    if(sScript == "" || sScript == "nw_ch_ac8") SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_DISTURBED, "0e_ch_8_disturb");
    else if(sScript == "x0_ch_hen_distrb") SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_DISTURBED, "0e_ch_8_disturb");
    else WriteTimestampedLogEntry("ON_DISTURBED SCRIPT ERROR: AI did not capture " + sScript + " script for " + GetName(oCreature) + ".");
    //SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_SPAWN_IN, "");
    sScript = GetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_RESTED);
    SetLocalString(oCreature, "AI_ON_RESTED", sScript);
    if(sScript == "" || sScript == "nw_ch_aca") SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_RESTED, "0e_ch_a_rested");
    else if(sScript == "x0_ch_hen_rest") SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_RESTED, "0e_ch_a_rested");
    else WriteTimestampedLogEntry("ON_RESTED SCRIPT ERROR: AI did not capture " + sScript + " script for " + GetName(oCreature) + ".");
    sScript = GetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_SPELLCASTAT);
    SetLocalString(oCreature, "AI_ON_SPELLCASTAT", sScript);
    if(sScript == "" || sScript == "nw_ch_acb") SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_SPELLCASTAT, "0e_ch_b_castat");
    else if(sScript == "x0_ch_hen_spell") SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_SPELLCASTAT, "0e_ch_b_castat");
    else WriteTimestampedLogEntry("ON_SPELLCASTAT SCRIPT ERROR: AI did not capture " + sScript + " script for " + GetName(oCreature) + ".");
    sScript = GetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_BLOCKED_BY_DOOR);
    SetLocalString(oCreature, "AI_ON_BLOCKED_BY_DOOR", sScript);
    if(sScript == "" || sScript == "nw_ch_ace") SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_BLOCKED_BY_DOOR, "0e_ch_e_blocked");
    else if(sScript == "x0_ch_hen_block") SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_BLOCKED_BY_DOOR, "0e_ch_e_blocked");
    else WriteTimestampedLogEntry("ON_BLOCKED_BY_DOOR SCRIPT ERROR: AI did not capture " + sScript + " script for " + GetName(oCreature) + ".");
    //SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_USER_DEFINED_EVENT, "");
}
void ai_FixEventScriptsForMonster(object oCreature)
{
    ai_Debug("0i_main", "402", "Reverting " + GetName(oCreature) + "'s event scripts.");
    string sScript = GetLocalString(oCreature, "AI_ON_HEARTBEAT");
    if(sScript == "") sScript = "nw_c2_default1";
    ai_Debug("0i_main", "404", "Reverting ON_HEARTBEAT: " + sScript);
    SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_HEARTBEAT, sScript);
    sScript = GetLocalString(oCreature, "AI_ON_NOTICE");
    if(sScript == "") sScript = "nw_c2_default2";
    ai_Debug("0i_main", "404", "Reverting ON_NOTICE: " + sScript);
    SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_NOTICE, sScript);
    sScript = GetLocalString(oCreature, "AI_ON_END_COMBATROUND");
    if(sScript == "") sScript = "nw_c2_default3";
    ai_Debug("0i_main", "404", "Reverting ON_END_COMBATROUND: " + sScript);
    SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_END_COMBATROUND, sScript);
    sScript = GetLocalString(oCreature, "AI_ON_DIALOGUE");
    if(sScript == "") sScript = "nw_c2_default4";
    ai_Debug("0i_main", "404", "Reverting ON_DIALOGUE: " + sScript);
    SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_DIALOGUE, sScript);
    sScript = GetLocalString(oCreature, "AI_ON_MELEE_ATTACKED");
    if(sScript == "") sScript = "nw_c2_default5";
    ai_Debug("0i_main", "404", "Reverting ON_MELEE_ATTACKED: " + sScript);
    SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_MELEE_ATTACKED, sScript);
    sScript = GetLocalString(oCreature, "AI_ON_DAMAGED");
    if(sScript == "") sScript = "nw_c2_default6";
    ai_Debug("0i_main", "404", "Reverting ON_DAMAGED: " + sScript);
    SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_DAMAGED, sScript);
    //SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_DEATH, "");
    sScript = GetLocalString(oCreature, "AI_ON_DISTURBED");
    if(sScript == "") sScript = "nw_c2_default8";
    ai_Debug("0i_main", "404", "Reverting ON_DISTURBED: " + sScript);
    SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_DISTURBED, sScript);
    //SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_SPAWN_IN, "");
    sScript = GetLocalString(oCreature, "AI_ON_RESTED");
    if(sScript == "") sScript = "nw_c2_defaulta";
    ai_Debug("0i_main", "404", "Reverting ON_RESTED: " + sScript);
    SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_RESTED, sScript);
    sScript = GetLocalString(oCreature, "AI_ON_SPELLCASTAT");
    if(sScript == "") sScript = "nw_c2_defaultb";
    ai_Debug("0i_main", "404", "Reverting ON_SPELLCASTAT: " + sScript);
    SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_SPELLCASTAT, sScript);
    sScript = GetLocalString(oCreature, "AI_ON_BLOCKED_BY_DOOR");
    if(sScript == "") sScript = "nw_c2_defaulte";
    ai_Debug("0i_main", "404", "Reverting ON_BLOCKED_BY_DOOR: " + sScript);
    SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_BLOCKED_BY_DOOR, sScript);
    //SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_USER_DEFINED_EVENT, "");
}
void ai_FixEventScriptsForAssociate(object oCreature)
{
    ai_Debug("0i_main", "402", "Reverting " + GetName(oCreature) + "'s event scripts.");
    string sScript = GetLocalString(oCreature, "AI_ON_HEARTBEAT");
    if(sScript == "") sScript = "nw_ch_ac1";
    ai_Debug("0i_main", "404", "Reverting ON_HEARTBEAT: " + sScript);
    SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_HEARTBEAT, sScript);
    sScript = GetLocalString(oCreature, "AI_ON_NOTICE");
    if(sScript == "") sScript = "nw_ch_ac2";
    ai_Debug("0i_main", "404", "Reverting ON_NOTICE: " + sScript);
    SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_NOTICE, sScript);
    sScript = GetLocalString(oCreature, "AI_ON_END_COMBATROUND");
    if(sScript == "") sScript = "nw_ch_ac3";
    ai_Debug("0i_main", "404", "Reverting ON_END_COMBATROUND: " + sScript);
    SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_END_COMBATROUND, sScript);
    sScript = GetLocalString(oCreature, "AI_ON_DIALOGUE");
    if(sScript == "") sScript = "nw_ch_ac4";
    ai_Debug("0i_main", "404", "Reverting ON_DIALOGUE: " + sScript);
    SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_DIALOGUE, sScript);
    sScript = GetLocalString(oCreature, "AI_ON_MELEE_ATTACKED");
    if(sScript == "") sScript = "nw_ch_ac5";
    ai_Debug("0i_main", "404", "Reverting ON_MELEE_ATTACKED: " + sScript);
    SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_MELEE_ATTACKED, sScript);
    sScript = GetLocalString(oCreature, "AI_ON_DAMAGED");
    if(sScript == "") sScript = "nw_ch_ac6";
    ai_Debug("0i_main", "404", "Reverting ON_DAMAGED: " + sScript);
    SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_DAMAGED, sScript);
    //SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_DEATH, "");
    sScript = GetLocalString(oCreature, "AI_ON_DISTURBED");
    if(sScript == "") sScript = "nw_ch_ac8";
    ai_Debug("0i_main", "404", "Reverting ON_DISTURBED: " + sScript);
    SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_DISTURBED, sScript);
    //SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_SPAWN_IN, "");
    sScript = GetLocalString(oCreature, "AI_ON_RESTED");
    if(sScript == "") sScript = "nw_ch_aca";
    ai_Debug("0i_main", "404", "Reverting ON_RESTED: " + sScript);
    SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_RESTED, sScript);
    sScript = GetLocalString(oCreature, "AI_ON_SPELLCASTAT");
    if(sScript == "") sScript = "nw_ch_acb";
    ai_Debug("0i_main", "404", "Reverting ON_SPELLCASTAT: " + sScript);
    SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_SPELLCASTAT, sScript);
    sScript = GetLocalString(oCreature, "AI_ON_BLOCKED_BY_DOOR");
    if(sScript == "") sScript = "nw_ch_ace";
    ai_Debug("0i_main", "404", "Reverting ON_BLOCKED_BY_DOOR: " + sScript);
    SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_BLOCKED_BY_DOOR, sScript);
    //SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_USER_DEFINED_EVENT, "");
}
