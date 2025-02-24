/*//////////////////////////////////////////////////////////////////////////////
// Script Name: 0e_prc_mon_event
////////////////////////////////////////////////////////////////////////////////
    PRC Monster event handler.
*///////////////////////////////////////////////////////////////////////////////
#include "inc_prc_npc"
#include "inc_eventhook"
void main()
{
    object oCreature = OBJECT_SELF;
    int nEvent = GetCurrentlyRunningEvent();
    //WriteTimestampedLogEntry("0e_prc_mon_event [12] " + GetName(oCreature) + " nEvent: " + IntToString(nEvent) +
    //                         " bFollower: " + IntToString(bFollower));
    switch (nEvent)
    {
        case EVENT_SCRIPT_CREATURE_ON_HEARTBEAT:
        {
            ExecuteScript("0e_c2_1_hb", oCreature);
            ExecuteScript("prc_npc_hb", oCreature);
            break;
        }
        case EVENT_SCRIPT_CREATURE_ON_NOTICE:
        {
            ExecuteScript("0e_c2_2_percept", oCreature);
            ExecuteScript("prc_npc_percep", oCreature);
            break;
        }
        case EVENT_SCRIPT_CREATURE_ON_DIALOGUE:
        {
            ExecuteScript("0e_c2_4_convers", oCreature);
            ExecuteScript("prc_npc_conv", oCreature);
            break;
        }
        case EVENT_SCRIPT_CREATURE_ON_MELEE_ATTACKED:
        {
            ExecuteScript("0e_c2_5_phyatked", oCreature);
            ExecuteScript("prc_npc_physatt", oCreature);
            break;
        }
        case EVENT_SCRIPT_CREATURE_ON_DAMAGED:
        {
            ExecuteScript("0e_c2_6_damaged", oCreature);
            ExecuteScript("prc_npc_damaged", oCreature);
            break;
        }
        case EVENT_SCRIPT_CREATURE_ON_SPELLCASTAT:
        {
            ExecuteScript("0e_c2_b_castat", oCreature);
            ExecuteScript("prc_npc_spellat", oCreature);
            break;
        }
        case EVENT_SCRIPT_CREATURE_ON_END_COMBATROUND:
        {
            ExecuteScript("0e_c2_3_endround", oCreature);
            ExecuteScript("prc_npc_combat", oCreature);
            break;
        }
        case EVENT_SCRIPT_CREATURE_ON_BLOCKED_BY_DOOR:
        {
            ExecuteScript("0e_c2_e_blocked", oCreature);
            ExecuteScript("prc_npc_blocked", oCreature);
            break;
        }
        case EVENT_SCRIPT_CREATURE_ON_RESTED:
        {
            ExecuteScript("0e_c2_a_rested", oCreature);
            ExecuteScript("prc_npc_rested", oCreature);
            break;
        }
        case EVENT_SCRIPT_CREATURE_ON_DISTURBED:
        {
            ExecuteScript("0e_c2_8_disturb", oCreature);
            ExecuteScript("prc_npc_disturb", oCreature);
            break;
        }
    }
}
