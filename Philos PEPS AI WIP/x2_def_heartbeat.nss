/*//////////////////////////////////////////////////////////////////////////////
 Script: x2_def_heartbeat
 Programmer: Philos
////////////////////////////////////////////////////////////////////////////////
  !!!!! Used in Development Folder
  !!!!! Commands creatures in the module: Neverwinter Nights - Infinite Dungeons

  In all other modules it will run the default creature script nw_c2_default1.
  Monster OnHeartbeat script
  We use this to change the creatures event scripts to the new AI event scripts.
*///////////////////////////////////////////////////////////////////////////////
//#include "0i_server"
#include "0i_single_player"
#include "x2_inc_switches"

void ai_SetIDMonsterEventScripts(object oCreature);
void main()
{
    string sModuleName = GetModuleName();
    if(sModuleName != "Neverwinter Nights - Infinite Dungeons") ExecuteScript("nw_c2_default1");
    object oCreature = OBJECT_SELF;
    ai_SetIDMonsterEventScripts(oCreature);
    if(GetCreatureFlag(OBJECT_SELF, CREATURE_VAR_IS_INCORPOREAL))
    {
        string sCombatAI = GetLocalString(oCreature, AI_DEFAULT_SCRIPT);
        if (sCombatAI == "") SetLocalString(oCreature, AI_DEFAULT_SCRIPT, "ai_incorporeal");
    }
    ai_SetListeningPatterns(oCreature);
    ai_SetCreatureAIScript(oCreature);
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
void ai_SetIDMonsterEventScripts(object oCreature)
{
    //WriteTimestampedLogEntry("x2_def_heartbeat [49] Changing " + GetName(oCreature) + "'s event scripts.");
    string sScript = GetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_HEARTBEAT);
    SetLocalString(oCreature, "AI_ON_HEARTBEAT", sScript);
    if(sScript == "x2_def_heartbeat") SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_HEARTBEAT, "00e_inf_dungeons");
    else WriteTimestampedLogEntry("ON_HEARTBEAT SCRIPT ERROR: AI did not capture " + sScript + " script for " + GetName(oCreature) + ".");
    sScript = GetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_NOTICE);
    SetLocalString(oCreature, "AI_ON_NOTICE", sScript);
    if(sScript == "x2_def_percept") SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_NOTICE, "00e_inf_dungeons");
    else WriteTimestampedLogEntry("ON_NOTICE SCRIPT ERROR: AI did not capture " + sScript + " script for " + GetName(oCreature) + ".");
    sScript = GetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_END_COMBATROUND);
    SetLocalString(oCreature, "AI_ON_END_COMBATROUND", sScript);
    if(sScript == "x2_def_endcombat") SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_END_COMBATROUND, "00e_inf_dungeons");
    else WriteTimestampedLogEntry("ON_END_COMBATROUND SCRIPT ERROR: AI did not capture " + sScript + " script for " + GetName(oCreature) + ".");
    sScript = GetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_DIALOGUE);
    SetLocalString(oCreature, "AI_ON_DIALOGUE", sScript);
    if(sScript == "x2_def_onconv") SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_DIALOGUE, "00e_inf_dungeons");
    else WriteTimestampedLogEntry("ON_DIALOGUE_SCRIPT ERROR: AI did not capture " + sScript + " script for " + GetName(oCreature) + ".");
    sScript = GetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_MELEE_ATTACKED);
    SetLocalString(oCreature, "AI_ON_MELEE_ATTACKED", sScript);
    if(sScript == "x2_def_attacked") SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_MELEE_ATTACKED, "00e_inf_dungeons");
    else WriteTimestampedLogEntry("ON_MELEE_ATTACKED_SCRIPT ERROR: AI did not capture " + sScript + " script for " + GetName(oCreature) + ".");
    sScript = GetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_DAMAGED);
    SetLocalString(oCreature, "AI_ON_DAMAGED", sScript);
    if(sScript == "x2_def_ondamage") SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_DAMAGED, "00e_inf_dungeons");
    else WriteTimestampedLogEntry("ON_DAMAGED_SCRIPT ERROR: AI did not capture " + sScript + " script for " + GetName(oCreature) + ".");
    // This is always set incase they have permanent summons turned on.
    sScript = GetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_DEATH);
    SetLocalString(oCreature, "AI_ON_DEATH", sScript);
    SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_DEATH, "0e_c2_7_ondeath");
    sScript = GetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_DISTURBED);
    SetLocalString(oCreature, "AI_ON_DISTURBED", sScript);
    if(sScript == "x2_def_ondisturb") SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_DISTURBED, "00e_inf_dungeons");
    else WriteTimestampedLogEntry("ON_DISTURBED_SCRIPT ERROR: AI did not capture " + sScript + " script for " + GetName(oCreature) + ".");
    //SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_SPAWN_IN, "");
    sScript = GetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_RESTED);
    SetLocalString(oCreature, "AI_ON_RESTED", sScript);
    if(sScript == "x2_def_rested") SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_RESTED, "00e_inf_dungeons");
    else WriteTimestampedLogEntry("ON_RESTED SCRIPT ERROR: AI did not capture " + sScript + " script for " + GetName(oCreature) + ".");
    sScript = GetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_SPELLCASTAT);
    SetLocalString(oCreature, "AI_ON_SPELLCASTAT", sScript);
    if(sScript == "x2_def_spellcast") SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_SPELLCASTAT, "00e_inf_dungeons");
    else WriteTimestampedLogEntry("ON_SPELLCASTAT_SCRIPT ERROR: AI did not capture " + sScript + " script for " + GetName(oCreature) + ".");
    sScript = GetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_BLOCKED_BY_DOOR);
    SetLocalString(oCreature, "AI_ON_BLOCKED_BY_DOOR", sScript);
    if(sScript == "x2_def_onblocked") SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_BLOCKED_BY_DOOR, "00e_inf_dungeons");
    else WriteTimestampedLogEntry("ON_BLOCKED_BY_DOOR SCRIPT ERROR: AI did not capture " + sScript + " script for " + GetName(oCreature) + ".");
    //SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_USER_DEFINED_EVENT, "");
}

