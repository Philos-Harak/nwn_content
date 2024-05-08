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
        SetEventScript(oTarget, EVENT_SCRIPT_CREATURE_ON_USER_DEFINED_EVENT, "");
        DeleteLocalString(oTarget, "AIScript");
    }
    // AI scripts on
    else
    {
        SendMessageToPC(oPC, "AI turned on for " + GetName(oTarget) + ".");
        SetEventScript(oTarget, EVENT_SCRIPT_CREATURE_ON_HEARTBEAT, "xx_pc_ac1");
        SetEventScript(oTarget, EVENT_SCRIPT_CREATURE_ON_NOTICE, "xx_pc_ac2");
        SetEventScript(oTarget, EVENT_SCRIPT_CREATURE_ON_END_COMBATROUND, "xx_pc_ac3");
        SetEventScript(oTarget, EVENT_SCRIPT_CREATURE_ON_DIALOGUE, "xx_pc_ac4");
        SetEventScript(oTarget, EVENT_SCRIPT_CREATURE_ON_MELEE_ATTACKED, "xx_pc_ac5");
        SetEventScript(oTarget, EVENT_SCRIPT_CREATURE_ON_DAMAGED, "xx_pc_ac6");
        SetEventScript(oTarget, EVENT_SCRIPT_CREATURE_ON_DEATH, "");
        SetEventScript(oTarget, EVENT_SCRIPT_CREATURE_ON_DISTURBED, "xx_pc_ac8");
        SetEventScript(oTarget, EVENT_SCRIPT_CREATURE_ON_SPAWN_IN, "");
        SetEventScript(oTarget, EVENT_SCRIPT_CREATURE_ON_RESTED, "");
        SetEventScript(oTarget, EVENT_SCRIPT_CREATURE_ON_SPELLCASTAT, "xx_pc_acb");
        SetEventScript(oTarget, EVENT_SCRIPT_CREATURE_ON_BLOCKED_BY_DOOR, "xx_pc_ace");
        SetEventScript(oTarget, EVENT_SCRIPT_CREATURE_ON_USER_DEFINED_EVENT, "");
        // This sets the script for the PC to run AI based on class.
        ai_SetAssociateAIScript(oTarget, FALSE);

        //**************** Special modes that can be turned on *****************
        // Must recompile this script for them to work if you change them.
        // Stops the excessive combat chatter if set to TRUE.
        ai_SetAssociateMode(oTarget, AI_MODE_DO_NOT_SPEAK, FALSE);
        // Ignore Familiars, Animal companions, and Summons in combat if TRUE.
        ai_SetAssociateMode(oTarget, AI_MODE_IGNORE_ASSOCIATES, FALSE);
        // One of these three must be TRUE, the others must be FALSE.
        // Sets when the target will heal an ally. 25 is when an ally has only 25% health left.
        ai_SetAssociateMode(oTarget, AI_MODE_HEAL_AT_25, FALSE);
        ai_SetAssociateMode(oTarget, AI_MODE_HEAL_AT_50, TRUE);
        ai_SetAssociateMode(oTarget, AI_MODE_HEAL_AT_75, FALSE);

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
                SendMessageToPC(oPC, GetName(oTarget) + " is casting spells with no Adjustment.");
                SetLocalInt(oTarget, AI_DIFFICULTY_ADJUSTMENT, 0);
                ai_SetAssociateMode(oTarget, AI_MODE_NO_MAGIC, FALSE);
                ai_SetAssociateMode(oTarget, AI_MODE_DEFENSIVE_CASTING, FALSE);
                ai_SetAssociateMode(oTarget, AI_MODE_OFFENSIVE_CASTING, FALSE);
                SetLocalInt(oTarget, "AI_SPELL_CONTROL", 1);
            }
            else if(nSpellControl == 1)
            {
                SendMessageToPC(oPC, GetName(oTarget) + " is casting spells with +10 Adjustment.");
                SetLocalInt(oTarget, AI_DIFFICULTY_ADJUSTMENT, 10);
                ai_SetAssociateMode(oTarget, AI_MODE_NO_MAGIC, FALSE);
                ai_SetAssociateMode(oTarget, AI_MODE_DEFENSIVE_CASTING, FALSE);
                ai_SetAssociateMode(oTarget, AI_MODE_OFFENSIVE_CASTING, FALSE);
                SetLocalInt(oTarget, "AI_SPELL_CONTROL", 2);
            }
            else if(nSpellControl == 2)
            {
                SendMessageToPC(oPC, GetName(oTarget) + " is casting spells with +15 Adjustment.");
                SetLocalInt(oTarget, AI_DIFFICULTY_ADJUSTMENT, 15);
                ai_SetAssociateMode(oTarget, AI_MODE_NO_MAGIC, FALSE);
                ai_SetAssociateMode(oTarget, AI_MODE_DEFENSIVE_CASTING, FALSE);
                ai_SetAssociateMode(oTarget, AI_MODE_OFFENSIVE_CASTING, FALSE);
                SetLocalInt(oTarget, "AI_SPELL_CONTROL", 3);
            }
            else if(nSpellControl == 3)
            {
                SendMessageToPC(oPC, GetName(oTarget) + " is casting spells with +30 Adjustment.");
                SetLocalInt(oTarget, AI_DIFFICULTY_ADJUSTMENT, 30);
                ai_SetAssociateMode(oTarget, AI_MODE_NO_MAGIC, FALSE);
                ai_SetAssociateMode(oTarget, AI_MODE_DEFENSIVE_CASTING, FALSE);
                ai_SetAssociateMode(oTarget, AI_MODE_OFFENSIVE_CASTING, FALSE);
                SetLocalInt(oTarget, "AI_SPELL_CONTROL", 4);
            }
            else if(nSpellControl == 4)
            {
                SendMessageToPC(oPC, GetName(oTarget) + " is not casting spells.");
                ai_SetAssociateMode(oTarget, AI_MODE_NO_MAGIC, TRUE);
                ai_SetAssociateMode(oTarget, AI_MODE_DEFENSIVE_CASTING, FALSE);
                ai_SetAssociateMode(oTarget, AI_MODE_OFFENSIVE_CASTING, FALSE);
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
