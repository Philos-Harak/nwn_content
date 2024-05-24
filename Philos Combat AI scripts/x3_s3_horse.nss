/*//////////////////////////////////////////////////////////////////////////////
 Script: x3_s3_horse
 Programmer: Philos
////////////////////////////////////////////////////////////////////////////////
    We have hijacked this script so a player can add the AI to the player!
    If the module uses horses this must be removed for it to work properly!
*///////////////////////////////////////////////////////////////////////////////
#include "0i_associates"
void main()
{
    object oPC = GetFirstPC();
    object oTarget = GetSpellTargetObject();
    SetTlkOverride(111877, "AI OFF"); // Horse Mount
    SetTlkOverride(111879, "AI MELEE/RANGED"); // Horse Dismount
    SetTlkOverride(111883, "AI SPELLS"); // Horse Party Mount
    SetTlkOverride(111885, "AI STEALTH"); // Horse Party Dismount
    SetTlkOverride(111887, "AI LOOT"); // Horse Assign Mount
    int nSpell = GetSpellId();
    // AI scripts off.
    if(nSpell == SPELL_HORSE_MOUNT)
    {
        SendMessageToPC(oPC, "AI Turned off for " + GetName(oTarget) + ".");
        SetEventScript(oTarget, EVENT_SCRIPT_CREATURE_ON_HEARTBEAT, "");
        SetEventScript(oTarget, EVENT_SCRIPT_CREATURE_ON_NOTICE, "");
        SetEventScript(oTarget, EVENT_SCRIPT_CREATURE_ON_END_COMBATROUND, "");
        SetEventScript(oTarget, EVENT_SCRIPT_CREATURE_ON_DIALOGUE, "");
        SetEventScript(oTarget, EVENT_SCRIPT_CREATURE_ON_MELEE_ATTACKED, "");
        SetEventScript(oTarget, EVENT_SCRIPT_CREATURE_ON_DAMAGED, "");
        //SetEventScript(oTarget, EVENT_SCRIPT_CREATURE_ON_DEATH, "");
        SetEventScript(oTarget, EVENT_SCRIPT_CREATURE_ON_DISTURBED, "");
        //SetEventScript(oTarget, EVENT_SCRIPT_CREATURE_ON_SPAWN_IN, "");
        //SetEventScript(oTarget, EVENT_SCRIPT_CREATURE_ON_RESTED, "");
        SetEventScript(oTarget, EVENT_SCRIPT_CREATURE_ON_SPELLCASTAT, "");
        SetEventScript(oTarget, EVENT_SCRIPT_CREATURE_ON_BLOCKED_BY_DOOR, "");
        //SetEventScript(oTarget, EVENT_SCRIPT_CREATURE_ON_USER_DEFINED_EVENT, "");
        DeleteLocalString(oTarget, "AIScript");
    }
    // AI scripts on
    else
    {
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

        //**************** Special modes that can be turned on *****************
        // Must recompile this script for them to work if you change them.
        // Stops the excessive combat chatter if set to TRUE.
        ai_SetAssociateMode(oTarget, AI_MODE_DO_NOT_SPEAK, FALSE);
        // Ignore Familiars, Animal companions, and Summons in combat if TRUE.
        ai_SetAssociateMode(oTarget, AI_MODE_IGNORE_ASSOCIATES, FALSE);
        // One of these three must be TRUE, the others must be FALSE.
        // Sets when the target will heal an ally. 25 is when an ally has only 25% health left.
        ai_SetAssociateMode(oTarget, AI_MODE_HEAL_IN_COMBAT_25, FALSE);
        ai_SetAssociateMode(oTarget, AI_MODE_HEAL_IN_COMBAT_50, TRUE);
        ai_SetAssociateMode(oTarget, AI_MODE_HEAL_IN_COMBAT_75, FALSE);
        ai_SetAssociateMode(oTarget, AI_MODE_HEAL_OUT_COMBAT_25, FALSE);
        ai_SetAssociateMode(oTarget, AI_MODE_HEAL_OUT_COMBAT_50, FALSE);
        ai_SetAssociateMode(oTarget, AI_MODE_HEAL_OUT_COMBAT_75, TRUE);

        // Targeting adjustment code.
        if(nSpell == SPELL_HORSE_DISMOUNT) // Melee_Ranged
        {
            int nControl = GetLocalInt(oTarget, "AI_CONTROL");
            if(!nControl)
            {
                SendMessageToPC(oPC, GetName(oTarget) + " is using ranged combat.");
                // TRUE: Use ranged weapons, FALSE: Don't use ranged weapons.
                ai_SetAssociateMode(oTarget, AI_MODE_STOP_RANGED, FALSE);
                ai_SetAssociateMode(oTarget, AI_MODE_SCOUT_AHEAD, FALSE);
                ai_ClearCreatureActions(oTarget);
                ai_EquipBestRangedWeapon(oTarget);
                SetLocalInt(oTarget, "AI_CONTROL", 1);
            }
            else if(nControl == 1)
            {
                SendMessageToPC(oPC, GetName(oTarget) + " is using melee combat only.");
                // TRUE: Use ranged weapons, FALSE: Don't use ranged weapons.
                ai_SetAssociateMode(oTarget, AI_MODE_STOP_RANGED, TRUE);
                ai_SetAssociateMode(oTarget, AI_MODE_SCOUT_AHEAD, FALSE);
                ai_ClearCreatureActions(oTarget);
                ai_EquipBestMeleeWeapon(oTarget);
                SetLocalInt(oTarget, "AI_CONTROL", 0);
            }
        }
        if(nSpell == SPELL_HORSE_PARTY_MOUNT) // Spells
        {
            int nSpellControl = GetLocalInt(oTarget, "AI_SPELL_CONTROL");
            if(!nSpellControl)
            {
                SendMessageToPC(oPC, GetName(oTarget) + " is sparingly casting spells (-10).");
                SetLocalInt(oTarget, AI_MAGIC_ADJUSTMENT, -10);
                ai_SetAssociateMagicMode(oTarget, AI_MAGIC_NO_MAGIC, FALSE);
                ai_SetAssociateMagicMode(oTarget, AI_MAGIC_DEFENSIVE_CASTING, FALSE);
                ai_SetAssociateMagicMode(oTarget, AI_MAGIC_OFFENSIVE_CASTING, FALSE);
                SetLocalInt(oTarget, "AI_SPELL_CONTROL", 1);
            }
            else if(nSpellControl == 1)
            {
                SendMessageToPC(oPC, GetName(oTarget) + " is casting spells (+0).");
                SetLocalInt(oTarget, AI_MAGIC_ADJUSTMENT, 0);
                ai_SetAssociateMagicMode(oTarget, AI_MAGIC_NO_MAGIC, FALSE);
                ai_SetAssociateMagicMode(oTarget, AI_MAGIC_DEFENSIVE_CASTING, FALSE);
                ai_SetAssociateMagicMode(oTarget, AI_MAGIC_OFFENSIVE_CASTING, FALSE);
                SetLocalInt(oTarget, "AI_SPELL_CONTROL", 2);
            }
            else if(nSpellControl == 2)
            {
                SendMessageToPC(oPC, GetName(oTarget) + " is heavily casting spells (+10).");
                SetLocalInt(oTarget, AI_MAGIC_ADJUSTMENT, 10);
                ai_SetAssociateMagicMode(oTarget, AI_MAGIC_NO_MAGIC, FALSE);
                ai_SetAssociateMagicMode(oTarget, AI_MAGIC_DEFENSIVE_CASTING, FALSE);
                ai_SetAssociateMagicMode(oTarget, AI_MAGIC_OFFENSIVE_CASTING, FALSE);
                SetLocalInt(oTarget, "AI_SPELL_CONTROL", 3);
            }
            else if(nSpellControl == 3)
            {
                SendMessageToPC(oPC, GetName(oTarget) + " is always casting spells (+40).");
                SetLocalInt(oTarget, AI_MAGIC_ADJUSTMENT, 40);
                ai_SetAssociateMagicMode(oTarget, AI_MAGIC_NO_MAGIC, FALSE);
                ai_SetAssociateMagicMode(oTarget, AI_MAGIC_DEFENSIVE_CASTING, FALSE);
                ai_SetAssociateMagicMode(oTarget, AI_MAGIC_OFFENSIVE_CASTING, FALSE);
                SetLocalInt(oTarget, "AI_SPELL_CONTROL", 4);
            }
            else if(nSpellControl == 4)
            {
                SendMessageToPC(oPC, GetName(oTarget) + " is not casting spells.");
                ai_SetAssociateMagicMode(oTarget, AI_MAGIC_NO_MAGIC, TRUE);
                ai_SetAssociateMagicMode(oTarget, AI_MAGIC_DEFENSIVE_CASTING, FALSE);
                ai_SetAssociateMagicMode(oTarget, AI_MAGIC_OFFENSIVE_CASTING, FALSE);
                SetLocalInt(oTarget, "AI_SPELL_CONTROL", 0);
            }
        }
        if(nSpell == SPELL_HORSE_PARTY_DISMOUNT) // Stealth
        {
            if(ai_GetAssociateMode(oTarget, AI_MODE_AGGRESSIVE_STEALTH))
            {
                SetActionMode(oTarget, ACTION_MODE_STEALTH, FALSE);
                SendMessageToPC(oPC, GetName(oTarget) + " is turning stealth off.");
                ai_SetAssociateMode(oTarget, AI_MODE_AGGRESSIVE_STEALTH, FALSE);
            }
            else
            {
                SendMessageToPC(oPC, GetName(oTarget) + " is turning stealth on.");
                ai_SetAssociateMode(oTarget, AI_MODE_AGGRESSIVE_STEALTH, TRUE);
            }
        }
        if(nSpell == SPELL_HORSE_ASSIGN_MOUNT) // Loot
        {
            int nLootControl = GetLocalInt(oTarget, "AI_LOOT_CONTROL");
            if(!nLootControl)
            {
                SendMessageToPC(oPC, GetName(oTarget) + " will not pickup loot.");
                ai_SetAssociateMode(oTarget, AI_MODE_PICKUP_ITEMS, FALSE);
                ai_SetAssociateMode(oTarget, AI_MODE_PICKUP_GEMS_ITEMS, FALSE);
                ai_SetAssociateMode(oTarget, AI_MODE_PICKUP_MAGIC_ITEMS, FALSE);
                ai_SetAssociateMode(oTarget, AI_MODE_OPEN_LOCKS, FALSE);
                ai_SetAssociateMode(oTarget, AI_MODE_DISARM_TRAPS, FALSE);
                SetLocalInt(oTarget, "AI_LOOT_CONTROL", 1);
            }
            else if(nLootControl == 1)
            {
                SendMessageToPC(oPC, GetName(oTarget) + " will pickup all loot.");
                ai_SetAssociateMode(oTarget, AI_MODE_PICKUP_ITEMS, TRUE);
                ai_SetAssociateMode(oTarget, AI_MODE_PICKUP_GEMS_ITEMS, FALSE);
                ai_SetAssociateMode(oTarget, AI_MODE_PICKUP_MAGIC_ITEMS, FALSE);
                ai_SetAssociateMode(oTarget, AI_MODE_OPEN_LOCKS, FALSE);
                ai_SetAssociateMode(oTarget, AI_MODE_DISARM_TRAPS, FALSE);
                SetLocalInt(oTarget, "AI_LOOT_CONTROL", 2);
            }
            else if(nLootControl == 2)
            {
                SendMessageToPC(oPC, GetName(oTarget) + " will pickup gems, gold, and magic items.");
                ai_SetAssociateMode(oTarget, AI_MODE_PICKUP_ITEMS, TRUE);
                ai_SetAssociateMode(oTarget, AI_MODE_PICKUP_GEMS_ITEMS, TRUE);
                ai_SetAssociateMode(oTarget, AI_MODE_PICKUP_MAGIC_ITEMS, FALSE);
                ai_SetAssociateMode(oTarget, AI_MODE_OPEN_LOCKS, FALSE);
                ai_SetAssociateMode(oTarget, AI_MODE_DISARM_TRAPS, FALSE);
                SetLocalInt(oTarget, "AI_LOOT_CONTROL", 3);
            }
            else if(nLootControl == 3)
            {
                SendMessageToPC(oPC, GetName(oTarget) + " will pickup gold and magic items only.");
                ai_SetAssociateMode(oTarget, AI_MODE_PICKUP_ITEMS, TRUE);
                ai_SetAssociateMode(oTarget, AI_MODE_PICKUP_GEMS_ITEMS, FALSE);
                ai_SetAssociateMode(oTarget, AI_MODE_PICKUP_MAGIC_ITEMS, TRUE);
                ai_SetAssociateMode(oTarget, AI_MODE_OPEN_LOCKS, FALSE);
                ai_SetAssociateMode(oTarget, AI_MODE_DISARM_TRAPS, FALSE);
                SetLocalInt(oTarget, "AI_LOOT_CONTROL", 0);
            }
        }
    }
}
