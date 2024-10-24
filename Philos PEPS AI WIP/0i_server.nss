/*//////////////////////////////////////////////////////////////////////////////
// Script Name: 0i_single_player
////////////////////////////////////////////////////////////////////////////////
 Include script for handling event scripts for online servers.
*///////////////////////////////////////////////////////////////////////////////
#include "0i_associates"
//#include "0i_assoc_debug"
#include "0i_constants"
#include "0i_messages"
// Sets the events for oCreature that use event scripts for monsters.
void ai_SetMonsterEventScripts(object oCreature);
// Sets the events for oCreature that use event scripts for associates.
void ai_SetAssociateEventScripts(object oCreature);
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
    SetLocalInt(oCreature, AI_HEAL_IN_COMBAT_LIMIT, 50);
    SetLocalInt(oCreature, AI_HEAL_OUT_OF_COMBAT_LIMIT, 70);
    // If we have already seen an enemy then we need to begin combat!
    object oEnemy = GetNearestEnemy(oCreature);
    //ai_Debug("0i_default", "42", GetName(oCreature) + " nearest enemy: " + GetName(oEnemy) +
    //         " Distance: " + FloatToString(GetDistanceBetween(oCreature, oEnemy), 0, 2));
    if(oEnemy != OBJECT_INVALID && GetDistanceBetween(oCreature, oEnemy) < AI_RANGE_PERCEPTION)
    {
        if(!GetLocalInt(oCreature, AI_TALENTS_SET))
        {
            ai_SetCreatureTalents(oCreature, FALSE);
        }
        //ai_Debug("0i_default", "50", GetName(oCreature) + " is starting combat!");
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
    //ai_Debug("0i_default", "92", "Changing " + GetName(oCreature) + "'s event scripts.");
    string sScript = GetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_HEARTBEAT);
    SetLocalString(oCreature, "AI_ON_HEARTBEAT", sScript);
    if(sScript == "nw_c2_default1") SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_HEARTBEAT, "0e_c2_1_hb");
    else if(sScript == "x2_def_heartbeat") SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_HEARTBEAT, "0e_c2_1_hb");
    else if(AI_OVERWRITE_EVENT_SCRIPTS) SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_HEARTBEAT, "0e_c2_1_hb");
    else WriteTimestampedLogEntry("ON_HEARTBEAT SCRIPT ERROR: AI did not capture " + sScript + " script for " + GetName(oCreature) + ".");
    sScript = GetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_NOTICE);
    SetLocalString(oCreature, "AI_ON_NOTICE", sScript);
    if(sScript == "nw_c2_default2") SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_NOTICE, "0e_c2_2_percept");
    else if(sScript == "x2_def_percept") SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_NOTICE, "0e_c2_2_percept");
    else if(AI_OVERWRITE_EVENT_SCRIPTS) SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_NOTICE, "0e_c2_2_percept");
    else WriteTimestampedLogEntry("ON_NOTICE SCRIPT ERROR: AI did not capture " + sScript + " script for " + GetName(oCreature) + ".");
    sScript = GetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_END_COMBATROUND);
    SetLocalString(oCreature, "AI_ON_END_COMBATROUND", sScript);
    if(sScript == "nw_c2_default3") SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_END_COMBATROUND, "0e_c2_3_endround");
    else if(sScript == "x2_def_endcombat") SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_END_COMBATROUND, "0e_c2_3_endround");
    else if(AI_OVERWRITE_EVENT_SCRIPTS) SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_END_COMBATROUND, "0e_c2_3_endround");
    else WriteTimestampedLogEntry("ON_END_COMBATROUND SCRIPT ERROR: AI did not capture " + sScript + " script for " + GetName(oCreature) + ".");
    sScript = GetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_DIALOGUE);
    SetLocalString(oCreature, "AI_ON_DIALOGUE", sScript);
    if(sScript == "nw_c2_default4") SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_DIALOGUE, "0e_c2_4_convers");
    else if(sScript == "x2_def_onconv") SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_DIALOGUE, "0e_c2_4_convers");
    else if(AI_OVERWRITE_EVENT_SCRIPTS) SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_DIALOGUE, "0e_c2_4_convers");
    else WriteTimestampedLogEntry("ON_DIALOGUE_SCRIPT ERROR: AI did not capture " + sScript + " script for " + GetName(oCreature) + ".");
    sScript = GetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_MELEE_ATTACKED);
    SetLocalString(oCreature, "AI_ON_MELEE_ATTACKED", sScript);
    if(sScript == "nw_c2_default5") SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_MELEE_ATTACKED, "0e_c2_5_phyatked");
    else if(sScript == "x2_def_attacked") SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_MELEE_ATTACKED, "0e_c2_5_phyatked");
    else if(AI_OVERWRITE_EVENT_SCRIPTS) SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_MELEE_ATTACKED, "0e_c2_5_phyatked");
    else WriteTimestampedLogEntry("ON_MELEE_ATTACKED_SCRIPT ERROR: AI did not capture " + sScript + " script for " + GetName(oCreature) + ".");
    sScript = GetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_DAMAGED);
    SetLocalString(oCreature, "AI_ON_DAMAGED", sScript);
    if(sScript == "nw_c2_default6") SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_DAMAGED, "0e_c2_6_damaged");
    else if(sScript == "x2_def_ondamage") SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_DAMAGED, "0e_c2_6_damaged");
    else if(AI_OVERWRITE_EVENT_SCRIPTS) SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_DAMAGED, "0e_c2_6_damaged");
    else WriteTimestampedLogEntry("ON_DAMAGED_SCRIPT ERROR: AI did not capture " + sScript + " script for " + GetName(oCreature) + ".");
    //SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_DEATH, "");
    sScript = GetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_DISTURBED);
    SetLocalString(oCreature, "AI_ON_DISTURBED", sScript);
    if(sScript == "nw_c2_default8") SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_DISTURBED, "0e_c2_8_disturb");
    else if(sScript == "x2_def_ondisturb") SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_DISTURBED, "0e_c2_8_disturb");
    else if(AI_OVERWRITE_EVENT_SCRIPTS) SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_DISTURBED, "0e_c2_8_disturb");
    else WriteTimestampedLogEntry("ON_DISTURBED_SCRIPT ERROR: AI did not capture " + sScript + " script for " + GetName(oCreature) + ".");
    //SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_SPAWN_IN, "");
    //SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_RESTED, "");
    sScript = GetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_SPELLCASTAT);
    SetLocalString(oCreature, "AI_ON_SPELLCASTAT", sScript);
    if(sScript == "nw_c2_defaultb") SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_SPELLCASTAT, "0e_c2_b_castat");
    else if(sScript == "x2_def_spellcast") SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_SPELLCASTAT, "0e_c2_b_castat");
    else if(AI_OVERWRITE_EVENT_SCRIPTS) SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_SPELLCASTAT, "0e_c2_b_castat");
    else WriteTimestampedLogEntry("ON_SPELLCASTAT_SCRIPT ERROR: AI did not capture " + sScript + " script for " + GetName(oCreature) + ".");
    sScript = GetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_BLOCKED_BY_DOOR);
    SetLocalString(oCreature, "AI_ON_BLOCKED_BY_DOOR", sScript);
    if(sScript == "nw_c2_defaulte") SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_BLOCKED_BY_DOOR, "0e_c2_e_blocked");
    else if(sScript == "x2_def_onblocked") SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_BLOCKED_BY_DOOR, "0e_c2_e_blocked");
    else if(AI_OVERWRITE_EVENT_SCRIPTS) SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_BLOCKED_BY_DOOR, "0e_c2_e_blocked");
    else WriteTimestampedLogEntry("ON_BLOCKED_BY_DOOR SCRIPT ERROR: AI did not capture " + sScript + " script for " + GetName(oCreature) + ".");
    //SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_USER_DEFINED_EVENT, "");
}
void ai_SetAssociateEventScripts(object oCreature)
{
    //ai_Debug("0i_default", "145", "Changing " + GetName(oCreature) + "'s event scripts.");
    string sScript = GetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_HEARTBEAT);
    if(sScript == "nw_ch_ac1") SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_HEARTBEAT, "0e_ch_1_hb");
    else if(sScript == "0e_hen_hrtbeat_1") SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_HEARTBEAT, "0e_ch_1_hb");
    else if(AI_OVERWRITE_EVENT_SCRIPTS) SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_HEARTBEAT, "0e_ch_1_hb");
    else WriteTimestampedLogEntry("ON_HEARTBEAT SCRIPT ERROR: AI did not capture " + sScript + " script for " + GetName(oCreature) + ".");
    sScript = GetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_NOTICE);
    if(sScript == "nw_ch_ac2") SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_NOTICE, "0e_ch_2_percept");
    else if(sScript == "0e_hen_onperce_2") SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_NOTICE, "0e_ch_2_percept");
    else if(AI_OVERWRITE_EVENT_SCRIPTS) SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_NOTICE, "0e_ch_2_percept");
    else WriteTimestampedLogEntry("ON_NOTICE SCRIPT ERROR: AI did not capture " + sScript + " script for " + GetName(oCreature) + ".");
    sScript = GetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_END_COMBATROUND);
    if(sScript == "nw_ch_ac3") SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_END_COMBATROUND, "0e_ch_3_endround");
    else if(sScript == "0e_hen_onendrd_3") SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_END_COMBATROUND, "0e_ch_3_endround");
    else if(AI_OVERWRITE_EVENT_SCRIPTS) SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_END_COMBATROUND, "0e_ch_3_endround");
    else WriteTimestampedLogEntry("ON_END_COMBATROUND SCRIPT ERROR: AI did not capture " + sScript + " script for " + GetName(oCreature) + ".");
    sScript = GetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_DIALOGUE);
    if(sScript == "nw_ch_ac4") SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_DIALOGUE, "0e_ch_4_convers");
    else if(sScript == "0e_hen_ondialg_4") SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_DIALOGUE, "0e_ch_4_convers");
    else if(AI_OVERWRITE_EVENT_SCRIPTS) SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_DIALOGUE, "0e_ch_4_convers");
    else WriteTimestampedLogEntry("ON_DIALOGUE SCRIPT ERROR: AI did not capture " + sScript + " script for " + GetName(oCreature) + ".");
    sScript = GetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_MELEE_ATTACKED);
    if(sScript == "nw_ch_ac5") SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_MELEE_ATTACKED, "0e_ch_5_phyatked");
    else if(sScript == "0e_hen_onatked_5") SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_MELEE_ATTACKED, "0e_ch_5_phyatked");
    else if(AI_OVERWRITE_EVENT_SCRIPTS) SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_MELEE_ATTACKED, "0e_ch_5_phyatked");
    else WriteTimestampedLogEntry("ON_MELEE_ATTACKED SCRIPT ERROR: AI did not capture " + sScript + " script for " + GetName(oCreature) + ".");
    sScript = GetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_DAMAGED);
    if(sScript == "nw_ch_ac6") SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_DAMAGED, "0e_ch_6_damaged");
    else if(sScript == "0e_hen_ondmg_6") SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_DAMAGED, "0e_ch_6_damaged");
    else if(AI_OVERWRITE_EVENT_SCRIPTS) SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_DAMAGED, "0e_ch_6_damaged");
    else WriteTimestampedLogEntry("ON_DAMAGED SCRIPT ERROR: AI did not capture " + sScript + " script for " + GetName(oCreature) + ".");
    // SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_DEATH, "");
    sScript = GetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_DISTURBED);
    if(sScript == "nw_ch_ac8") SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_DISTURBED, "0e_ch_8_disturb");
    else if(sScript == "0e_hen_ondstrb_8") SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_DISTURBED, "0e_ch_8_disturb");
    else if(AI_OVERWRITE_EVENT_SCRIPTS) SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_DISTURBED, "0e_ch_8_disturb");
    else WriteTimestampedLogEntry("ON_DISTURBED SCRIPT ERROR: AI did not capture " + sScript + " script for " + GetName(oCreature) + ".");
    //SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_SPAWN_IN, "");
    sScript = GetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_RESTED);
    SetLocalString(oCreature, "AI_ON_RESTED", sScript);
    if(sScript == "nw_ch_aca") SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_RESTED, "0e_ch_a_rested");
    else if(sScript == "0e_hen_onrest_a") SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_RESTED, "0e_ch_a_rested");
    else if(AI_OVERWRITE_EVENT_SCRIPTS) SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_RESTED, "0e_ch_a_rested");
    else WriteTimestampedLogEntry("ON_RESTED SCRIPT ERROR: AI did not capture " + sScript + " script for " + GetName(oCreature) + ".");
    sScript = GetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_SPELLCASTAT);
    if(sScript == "nw_ch_acb") SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_SPELLCASTAT, "0e_ch_b_castat");
    else if(sScript == "0e_hen_onspell_b") SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_SPELLCASTAT, "0e_ch_b_castat");
    else if(AI_OVERWRITE_EVENT_SCRIPTS) SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_SPELLCASTAT, "0e_ch_b_castat");
    else WriteTimestampedLogEntry("ON_SPELLCASTAT SCRIPT ERROR: AI did not capture " + sScript + " script for " + GetName(oCreature) + ".");
    sScript = GetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_BLOCKED_BY_DOOR);
    if(sScript == "nw_ch_ace") SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_BLOCKED_BY_DOOR, "0e_ch_e_blocked");
    else if(sScript == "0e_hen_onblck_e") SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_BLOCKED_BY_DOOR, "0e_ch_e_blocked");
    else if(AI_OVERWRITE_EVENT_SCRIPTS) SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_BLOCKED_BY_DOOR, "0e_ch_e_blocked");
    else WriteTimestampedLogEntry("ON_BLOCKED_BY_DOOR SCRIPT ERROR: AI did not capture " + sScript + " script for " + GetName(oCreature) + ".");
    //SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_USER_DEFINED_EVENT, "");
}
