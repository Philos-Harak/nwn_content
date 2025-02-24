/*//////////////////////////////////////////////////////////////////////////////
// Script Name: 0e_prc_mob_event
////////////////////////////////////////////////////////////////////////////////
    PRC con ? event handler.
*///////////////////////////////////////////////////////////////////////////////
#include "inc_prc_npc"
#include "inc_eventhook"
void main()
{
    object oCreature = OBJECT_SELF;
    int nEvent = GetCurrentlyRunningEvent();
    //WriteTimestampedLogEntry("0e_prc_co_event [12] " + GetName(oCreature) + " nEvent: " + IntToString(nEvent) +
    //                         " bFollower: " + IntToString(bFollower));
    int bAssociate = GetIsObjectValid(GetMaster(oCreature));
    switch (nEvent)
    {
        case EVENT_SCRIPT_CREATURE_ON_HEARTBEAT:
        {
            if(bAssociate) ExecuteScript("0e_ch_1_hb", oCreature);
            else ExecuteScript("0e_c2_1_hb", oCreature);
            ExecuteScript("prc_npc_hb", oCreature);
            break;
        }
        case EVENT_SCRIPT_CREATURE_ON_NOTICE:
        {
            if(bAssociate) ExecuteScript("0e_ch_2_percept", oCreature);
            else ExecuteScript("0e_c2_2_percept", oCreature);
            ExecuteScript("prc_npc_percep", oCreature);
            break;
        }
        case EVENT_SCRIPT_CREATURE_ON_DIALOGUE:
        {
            if(bAssociate) ExecuteScript("0e_ch_4_convers", oCreature);
            else ExecuteScript("0e_c2_4_convers", oCreature);
            ExecuteScript("prc_npc_conv", oCreature);
            break;
        }
        case EVENT_SCRIPT_CREATURE_ON_MELEE_ATTACKED:
        {
            if(bAssociate) ExecuteScript("0e_ch_5_phyatked", oCreature);
            else ExecuteScript("0e_c2_5_phyatked", oCreature);
            ExecuteScript("prc_npc_physatt", oCreature);
            break;
        }
        case EVENT_SCRIPT_CREATURE_ON_DAMAGED:
        {
            if(bAssociate) ExecuteScript("0e_ch_6_damaged", oCreature);
            else ExecuteScript("0e_c2_6_damaged", oCreature);
            ExecuteScript("prc_npc_damaged", oCreature);
            break;
        }
        case EVENT_SCRIPT_CREATURE_ON_SPELLCASTAT:
        {
            if(bAssociate) ExecuteScript("0e_ch_b_castat", oCreature);
            else ExecuteScript("0e_c2_b_castat", oCreature);
            ExecuteScript("prc_npc_spellat", oCreature);
            break;
        }
        case EVENT_SCRIPT_CREATURE_ON_END_COMBATROUND:
        {
            if(bAssociate) ExecuteScript("0e_ch_3_endround", oCreature);
            else ExecuteScript("0e_c2_3_endround", oCreature);
            ExecuteScript("prc_npc_combat", oCreature);
            break;
        }
        case EVENT_SCRIPT_CREATURE_ON_BLOCKED_BY_DOOR:
        {
            if(bAssociate) ExecuteScript("0e_ch_e_blocked", oCreature);
            else ExecuteScript("0e_c2_e_blocked", oCreature);
            ExecuteScript("prc_npc_blocked", oCreature);
            break;
        }
        case EVENT_SCRIPT_CREATURE_ON_RESTED:
        {
            if(bAssociate) ExecuteScript("0e_ch_a_rested", oCreature);
            else ExecuteScript("0e_c2_a_rested", oCreature);
            ExecuteScript("prc_npc_rested", oCreature);
            break;
        }
        case EVENT_SCRIPT_CREATURE_ON_DISTURBED:
        {
            if(bAssociate) ExecuteScript("0e_ch_8_disturb", oCreature);
            else ExecuteScript("0e_c2_8_disturb", oCreature);
            ExecuteScript("prc_npc_disturb", oCreature);
            break;
        }
    }
}
