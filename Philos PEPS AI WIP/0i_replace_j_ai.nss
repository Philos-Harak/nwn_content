/*//////////////////////////////////////////////////////////////////////////////
// Script Name: 0i_replace_j_ai
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
// Adds variables to the module that doesn't use the menu system.
void ai_SetModuleValues();
//******************************************************************************
//********************* Creature event scripts *********************************
//******************************************************************************
void ai_OnMonsterSpawn(object oCreature, int bIncorporeal)
{
    ai_SetModuleValues();
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
    //ai_Debug("0i_replace_j_ai", "46", GetName(oCreature) + " nearest enemy: " + GetName(oEnemy) +
    //         " Distance: " + FloatToString(GetDistanceBetween(oCreature, oEnemy), 0, 2) +
    //         " Talents set? " + IntToString(GetLocalInt(oCreature, AI_TALENTS_SET)));
    if(oEnemy != OBJECT_INVALID && GetDistanceBetween(oCreature, oEnemy) < AI_RANGE_PERCEPTION)
    {
        ai_SetupMonsterBuffTargets(oCreature);
        // To save steps and time we set the talenst while we buff!
        ai_SetCreatureTalents(oCreature, TRUE);
        ai_ClearBuffTargets(oCreature, "AI_ALLY_TARGET_");
        //ai_Debug("0i_replace_j_ai", "63", GetName(oCreature) + " is starting combat!");
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
    //ai_Debug("0i_replace_j_ai", "91", "Changing " + GetName(oCreature) + "'s event scripts.");
    string sScript = GetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_HEARTBEAT);
    SetLocalString(oCreature, "AI_ON_HEARTBEAT", sScript);
    if(sScript == "j_ai_onheartbeat") SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_HEARTBEAT, "0e_c2_1_hb");
    else if(sScript == "nw_c2_default1" || sScript == "x2_def_heartbeat") SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_HEARTBEAT, "0e_c2_1_hb");
    else if(AI_OVERWRITE_EVENT_SCRIPTS) SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_HEARTBEAT, "0e_c2_1_hb");
    else WriteTimestampedLogEntry("ON_HEARTBEAT SCRIPT ERROR: AI did not capture " + sScript + " script for " + GetName(oCreature) + ".");
    sScript = GetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_NOTICE);
    SetLocalString(oCreature, "AI_ON_NOTICE", sScript);
    if(sScript == "j_ai_onpercieve") SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_NOTICE, "0e_c2_2_percept");
    else if(sScript == "nw_c2_default2" || sScript == "x2_def_percept") SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_NOTICE, "0e_c2_2_percept");
    else if(AI_OVERWRITE_EVENT_SCRIPTS) SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_NOTICE, "0e_c2_2_percept");
    else WriteTimestampedLogEntry("ON_NOTICE SCRIPT ERROR: AI did not capture " + sScript + " script for " + GetName(oCreature) + ".");
    sScript = GetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_END_COMBATROUND);
    SetLocalString(oCreature, "AI_ON_END_COMBATROUND", sScript);
    if(sScript == "j_ai_oncombatrou") SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_END_COMBATROUND, "0e_c2_3_endround");
    else if(sScript == "nw_c2_default3" || sScript == "x2_def_endcombat") SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_END_COMBATROUND, "0e_c2_3_endround");
    else if(AI_OVERWRITE_EVENT_SCRIPTS) SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_END_COMBATROUND, "0e_c2_3_endround");
    else WriteTimestampedLogEntry("ON_END_COMBATROUND SCRIPT ERROR: AI did not capture " + sScript + " script for " + GetName(oCreature) + ".");
    sScript = GetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_DIALOGUE);
    SetLocalString(oCreature, "AI_ON_DIALOGUE", sScript);
    if(sScript == "j_ai_onconversat") SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_DIALOGUE, "0e_c2_4_convers");
    else if(sScript == "nw_c2_default4" || sScript == "x2_def_onconv") SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_DIALOGUE, "0e_c2_4_convers");
    else if(AI_OVERWRITE_EVENT_SCRIPTS) SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_DIALOGUE, "0e_c2_4_convers");
    else WriteTimestampedLogEntry("ON_DIALOGUE_SCRIPT ERROR: AI did not capture " + sScript + " script for " + GetName(oCreature) + ".");
    sScript = GetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_MELEE_ATTACKED);
    SetLocalString(oCreature, "AI_ON_MELEE_ATTACKED", sScript);
    if(sScript == "j_ai_onphiattack") SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_MELEE_ATTACKED, "0e_c2_5_phyatked");
    else if(sScript == "nw_c2_default5" || sScript == "x2_def_attacked") SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_MELEE_ATTACKED, "0e_c2_5_phyatked");
    else if(AI_OVERWRITE_EVENT_SCRIPTS) SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_MELEE_ATTACKED, "0e_c2_5_phyatked");
    else WriteTimestampedLogEntry("ON_MELEE_ATTACKED_SCRIPT ERROR: AI did not capture " + sScript + " script for " + GetName(oCreature) + ".");
    sScript = GetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_DAMAGED);
    SetLocalString(oCreature, "AI_ON_DAMAGED", sScript);
    if(sScript == "j_ai_ondamaged") SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_DAMAGED, "0e_c2_6_damaged");
    else if(sScript == "nw_c2_default6" || sScript == "x2_def_ondamage") SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_DAMAGED, "0e_c2_6_damaged");
    else if(AI_OVERWRITE_EVENT_SCRIPTS) SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_DAMAGED, "0e_c2_6_damaged");
    else WriteTimestampedLogEntry("ON_DAMAGED_SCRIPT ERROR: AI did not capture " + sScript + " script for " + GetName(oCreature) + ".");
    //SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_DEATH, "");
    sScript = GetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_DISTURBED);
    SetLocalString(oCreature, "AI_ON_DISTURBED", sScript);
    if(sScript == "j_ai_ondisturbed") SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_DISTURBED, "0e_c2_8_disturb");
    else if(sScript == "nw_c2_default8" || sScript == "x2_def_ondisturb") SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_DISTURBED, "0e_c2_8_disturb");
    else if(AI_OVERWRITE_EVENT_SCRIPTS) SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_DISTURBED, "0e_c2_8_disturb");
    else WriteTimestampedLogEntry("ON_DISTURBED_SCRIPT ERROR: AI did not capture " + sScript + " script for " + GetName(oCreature) + ".");
    //SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_SPAWN_IN, "");
    //SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_RESTED, "");
    sScript = GetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_SPELLCASTAT);
    SetLocalString(oCreature, "AI_ON_SPELLCASTAT", sScript);
    if(sScript == "j_ai_onspellcast") SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_SPELLCASTAT, "0e_c2_b_castat");
    else if(sScript == "nw_c2_defaultb" || sScript == "x2_def_spellcast") SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_SPELLCASTAT, "0e_c2_b_castat");
    else if(AI_OVERWRITE_EVENT_SCRIPTS) SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_SPELLCASTAT, "0e_c2_b_castat");
    else WriteTimestampedLogEntry("ON_SPELLCASTAT_SCRIPT ERROR: AI did not capture " + sScript + " script for " + GetName(oCreature) + ".");
    sScript = GetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_BLOCKED_BY_DOOR);
    SetLocalString(oCreature, "AI_ON_BLOCKED_BY_DOOR", sScript);
    if(sScript == "j_ai_onblocked") SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_BLOCKED_BY_DOOR, "0e_c2_e_blocked");
    else if(sScript == "nw_c2_defaulte" || sScript == "x2_def_onblocked") SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_BLOCKED_BY_DOOR, "0e_c2_e_blocked");
    else if(AI_OVERWRITE_EVENT_SCRIPTS) SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_BLOCKED_BY_DOOR, "0e_c2_e_blocked");
    else WriteTimestampedLogEntry("ON_BLOCKED_BY_DOOR SCRIPT ERROR: AI did not capture " + sScript + " script for " + GetName(oCreature) + ".");
    //SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_USER_DEFINED_EVENT, "");
}
void ai_SetAssociateEventScripts(object oCreature)
{
    //ai_Debug("0i_replace_j_ai", "153", "Changing " + GetName(oCreature) + "'s event scripts.");
    string sScript = GetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_HEARTBEAT);
    if(sScript == "nw_ch_ac1") SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_HEARTBEAT, "0e_ch_1_hb");
    else if(AI_OVERWRITE_EVENT_SCRIPTS) SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_HEARTBEAT, "0e_ch_1_hb");
    else WriteTimestampedLogEntry("ON_HEARTBEAT SCRIPT ERROR: AI did not capture " + sScript + " script for " + GetName(oCreature) + ".");
    sScript = GetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_NOTICE);
    if(sScript == "nw_ch_ac2") SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_NOTICE, "0e_ch_2_percept");
    else if(AI_OVERWRITE_EVENT_SCRIPTS) SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_NOTICE, "0e_ch_2_percept");
    else WriteTimestampedLogEntry("ON_NOTICE SCRIPT ERROR: AI did not capture " + sScript + " script for " + GetName(oCreature) + ".");
    sScript = GetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_END_COMBATROUND);
    if(sScript == "nw_ch_ac3") SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_END_COMBATROUND, "0e_ch_3_endround");
    else if(AI_OVERWRITE_EVENT_SCRIPTS) SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_END_COMBATROUND, "0e_ch_3_endround");
    else WriteTimestampedLogEntry("ON_END_COMBATROUND SCRIPT ERROR: AI did not capture " + sScript + " script for " + GetName(oCreature) + ".");
    sScript = GetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_DIALOGUE);
    if(sScript == "nw_ch_ac4") SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_DIALOGUE, "0e_ch_4_convers");
    else if(AI_OVERWRITE_EVENT_SCRIPTS) SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_DIALOGUE, "0e_ch_4_convers");
    else WriteTimestampedLogEntry("ON_DIALOGUE SCRIPT ERROR: AI did not capture " + sScript + " script for " + GetName(oCreature) + ".");
    sScript = GetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_MELEE_ATTACKED);
    if(sScript == "nw_ch_ac5") SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_MELEE_ATTACKED, "0e_ch_5_phyatked");
    else if(AI_OVERWRITE_EVENT_SCRIPTS) SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_MELEE_ATTACKED, "0e_ch_5_phyatked");
    else WriteTimestampedLogEntry("ON_MELEE_ATTACKED SCRIPT ERROR: AI did not capture " + sScript + " script for " + GetName(oCreature) + ".");
    sScript = GetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_DAMAGED);
    if(sScript == "nw_ch_ac6") SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_DAMAGED, "0e_ch_6_damaged");
    else if(AI_OVERWRITE_EVENT_SCRIPTS) SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_DAMAGED, "0e_ch_6_damaged");
    else WriteTimestampedLogEntry("ON_DAMAGED SCRIPT ERROR: AI did not capture " + sScript + " script for " + GetName(oCreature) + ".");
    // SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_DEATH, "");
    sScript = GetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_DISTURBED);
    if(sScript == "nw_ch_ac8") SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_DISTURBED, "0e_ch_8_disturb");
    else if(AI_OVERWRITE_EVENT_SCRIPTS) SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_DISTURBED, "0e_ch_8_disturb");
    else WriteTimestampedLogEntry("ON_DISTURBED SCRIPT ERROR: AI did not capture " + sScript + " script for " + GetName(oCreature) + ".");
    //SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_SPAWN_IN, "");
    sScript = GetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_RESTED);
    SetLocalString(oCreature, "AI_ON_RESTED", sScript);
    if(sScript == "nw_ch_aca") SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_RESTED, "0e_ch_a_rested");
    else if(AI_OVERWRITE_EVENT_SCRIPTS) SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_RESTED, "0e_ch_a_rested");
    else WriteTimestampedLogEntry("ON_RESTED SCRIPT ERROR: AI did not capture " + sScript + " script for " + GetName(oCreature) + ".");
    sScript = GetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_SPELLCASTAT);
    if(sScript == "nw_ch_acb") SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_SPELLCASTAT, "0e_ch_b_castat");
    else if(AI_OVERWRITE_EVENT_SCRIPTS) SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_SPELLCASTAT, "0e_ch_b_castat");
    else WriteTimestampedLogEntry("ON_SPELLCASTAT SCRIPT ERROR: AI did not capture " + sScript + " script for " + GetName(oCreature) + ".");
    sScript = GetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_BLOCKED_BY_DOOR);
    if(sScript == "nw_ch_ace") SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_BLOCKED_BY_DOOR, "0e_ch_e_blocked");
    else if(AI_OVERWRITE_EVENT_SCRIPTS) SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_BLOCKED_BY_DOOR, "0e_ch_e_blocked");
    else WriteTimestampedLogEntry("ON_BLOCKED_BY_DOOR SCRIPT ERROR: AI did not capture " + sScript + " script for " + GetName(oCreature) + ".");
    //SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_USER_DEFINED_EVENT, "");
}
void ai_SetModuleValues()
{
    object oModule = GetModule();
    if(GetLocalInt(oModule, "AI_RULES_SET")) return;
    SetLocalInt(oModule, "AI_RULES_SET", TRUE);
    // Allow the AI move during combat base on the situation and action taking.
    SetLocalInt(oModule, AI_RULE_ADVANCED_MOVEMENT, TRUE);
    // Monster AI's chance to attack the weakest target instead of the nearest.
    SetLocalInt(oModule, AI_RULE_AI_DIFFICULTY, 33);
    // Allow the AI to use Use Magic Device.
    SetLocalInt(oModule, AI_RULE_ALLOW_UMD, TRUE);
    // Allows monsters to use the ambush AI scripts.
    SetLocalInt(oModule, AI_RULE_AMBUSH, TRUE);
    // Allows monsters to prebuff before combat starts.
    SetLocalInt(oModule, AI_RULE_BUFF_MONSTERS, TRUE);
    // Allow the AI to use healing kits.
    SetLocalInt(oModule, AI_RULE_HEALERSKITS, TRUE);
    // Follow Item Level Restrictions for monsters/associates.
    // Usually off in Single player and on in Multi player.
    SetLocalInt(oModule, AI_RULE_ILR, TRUE);
    // Moral checks on or off.
    SetLocalInt(oModule, AI_RULE_MORAL_CHECKS, TRUE);
    // Variable that can change the distance creatures will come and attack after
    // hearing a shout from an ally that sees or hears an enemy.
    // Or when searching for an invisible, heard enemy.
    // 10.0 short, 20.0 Medium, 35.0 long, 35.0 player.
    SetLocalFloat(oModule, AI_RULE_PERCEPTION_DISTANCE, 30.0);
    // Summoned associates are permanent and don't disappear when the caster dies.
    SetLocalInt(oModule, AI_RULE_PERM_ASSOC, FALSE);
    // Allows monsters cast summons spells when prebuffing.
    SetLocalInt(oModule, AI_RULE_PRESUMMON, TRUE);
}
