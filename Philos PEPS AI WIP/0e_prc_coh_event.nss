/*//////////////////////////////////////////////////////////////////////////////
// Script Name: 0e_prc_sum_event
////////////////////////////////////////////////////////////////////////////////
    PRC Associates/Summons event handler.
*///////////////////////////////////////////////////////////////////////////////
#include "inc_prc_npc"
#include "inc_eventhook"
void main()
{
    object oCreature = OBJECT_SELF;
    int nEvent = GetCurrentlyRunningEvent();
    //WriteTimestampedLogEntry("0e_prc_sum_event [12] " + GetName(oCreature) + " nEvent: " + IntToString(nEvent) +
    //                         " bFollower: " + IntToString(bFollower));
    switch (nEvent)
    {
        case EVENT_SCRIPT_CREATURE_ON_HEARTBEAT:
        {
            ExecuteScript("prc_ai_coh_hb", oCreature);
            ExecuteScript("0e_ch_1_hb", oCreature);
            break;
        }
        case EVENT_SCRIPT_CREATURE_ON_DIALOGUE:
        {
            ExecuteScript("prc_ai_coh_conv", oCreature);
            break;
        }
    }
}
