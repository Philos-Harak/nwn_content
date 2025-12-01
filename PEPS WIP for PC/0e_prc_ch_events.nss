/*//////////////////////////////////////////////////////////////////////////////
// Script Name: 0e_prc_ch_events
////////////////////////////////////////////////////////////////////////////////
    associate event handler while using the PRC.
*///////////////////////////////////////////////////////////////////////////////
#include "0i_actions"
#include "x0_i0_assoc"
void main()
{
    object oCreature = OBJECT_SELF;
    int nEvent = GetCurrentlyRunningEvent();
    //WriteTimestampedLogEntry("0e_prc_ch_events [13] " + GetName(oCreature) + " nEvent: " + IntToString(nEvent));
    switch (nEvent)
    {
        case EVENT_SCRIPT_CREATURE_ON_HEARTBEAT:
        {
            if(GetLocalInt(oCreature, "CohortID")) ExecuteScript("prc_ai_coh_hb");
            ExecuteScript("nw_ch_ac1", oCreature);
            ExecuteScript("prc_npc_hb", oCreature);
            break;
        }
        case EVENT_SCRIPT_CREATURE_ON_NOTICE:
        {
            ExecuteScript("nw_ch_ac2", oCreature);
            ExecuteScript("prc_npc_percep", oCreature);
            break;
        }
        case EVENT_SCRIPT_CREATURE_ON_DIALOGUE:
        {
            //if(GetLocalInt(oCreature, "CohortID")) ExecuteScript("prc_ai_coh_conv");
            ExecuteScript("nw_ch_ac4", oCreature);
            //ExecuteScript("prc_npc_conv", oCreature);
            break;
        }
        case EVENT_SCRIPT_CREATURE_ON_MELEE_ATTACKED:
        {
            ExecuteScript("nw_ch_ac5", oCreature);
            ExecuteScript("prc_npc_physatt", oCreature);
            break;
        }
        case EVENT_SCRIPT_CREATURE_ON_DAMAGED:
        {
            ExecuteScript("nw_ch_ac6", oCreature);
            ExecuteScript("prc_npc_damaged", oCreature);
            break;
        }
        case EVENT_SCRIPT_CREATURE_ON_SPELLCASTAT:
        {
            ExecuteScript("nw_ch_acb", oCreature);
            ExecuteScript("prc_npc_spellat", oCreature);
            break;
        }
        case EVENT_SCRIPT_CREATURE_ON_END_COMBATROUND:
        {
            ExecuteScript("nw_ch_ac3", oCreature);
            ExecuteScript("prc_npc_combat", oCreature);
            break;
        }
        case EVENT_SCRIPT_CREATURE_ON_BLOCKED_BY_DOOR:
        {
            ExecuteScript("nw_ch_ace", oCreature);
            ExecuteScript("prc_npc_blocked", oCreature);
            break;
        }
        case EVENT_SCRIPT_CREATURE_ON_RESTED:
        {
            ExecuteScript("nw_ch_aca", oCreature);
            //ExecuteScript("prc_npc_rested", oCreature);
            break;
        }
        case EVENT_SCRIPT_CREATURE_ON_DISTURBED:
        {
            ExecuteScript("nw_ch_ac8", oCreature);
            ExecuteScript("prc_npc_disturb", oCreature);
            break;
        }
    }
}
