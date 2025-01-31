/*//////////////////////////////////////////////////////////////////////////////
// Script Name: 0e_fam_event
////////////////////////////////////////////////////////////////////////////////
    PRC Familiar/Companion event handler.
*///////////////////////////////////////////////////////////////////////////////
#include "inc_eventhook"
object GetMasterNPC(object oAssociate=OBJECT_SELF)
{
   object oMaster = GetLocalObject(oAssociate, "oMaster");
   if(GetIsObjectValid(oMaster)) return oMaster;
   else return GetMaster(oAssociate);
}
void AddAssociate(object oMaster, object oAssociate)
{
    int nMaxHenchmen = GetMaxHenchmen();
    SetMaxHenchmen(99);
    AddHenchman(oMaster, oAssociate);
    SetMaxHenchmen(nMaxHenchmen);
}
void DestroyAssociate(object oAssociate)
{
    AssignCommand(oAssociate, SetIsDestroyable(TRUE));
    ApplyEffectAtLocation(DURATION_TYPE_INSTANT, EffectVisualEffect(VFX_IMP_UNSUMMON), GetLocation(oAssociate));
    DestroyObject(oAssociate);
}
void main()
{
    object oCreature = OBJECT_SELF;
    int nEvent = GetCurrentlyRunningEvent();
    int bFollower = GetLocalInt(oCreature, "bFollower");
    //WriteTimestampedLogEntry("0e_prc_sum_event [24] " + GetName(oCreature) + " nEvent: " + IntToString(nEvent) +
    //                         " bFollower: " + IntToString(bFollower));
    switch (nEvent)
    {
        case EVENT_SCRIPT_CREATURE_ON_HEARTBEAT:
        {
            object oMaster = GetMasterNPC(oCreature);
            //check if master is valid, if not unsummon
            if(!GetIsObjectValid(oMaster)) DestroyAssociate(oCreature);
            if(GetStringLeft(GetResRef(oCreature), 11) == "prc_pnpfam_")
            {
                if(!GetIsDead(oCreature) && GetLocalInt(oCreature, "Familiar_Died"))
                {
                    SetIsDestroyable(TRUE, TRUE, TRUE);
                    DeleteLocalInt(oCreature, "Familiar_Died");
                }
            }
            else if(!GetIsObjectValid(GetMaster(oCreature)))
            {
                RemoveHenchman(oMaster, oCreature);
                AddAssociate(oMaster, oCreature);
            }
            ExecuteScript("0e_ch_1_hb", oCreature);
            ExecuteAllScriptsHookedToEvent(oCreature, EVENT_NPC_ONHEARTBEAT);
            break;
        }
        case EVENT_SCRIPT_CREATURE_ON_NOTICE:
        {
            ExecuteScript("0e_ch_2_percept", oCreature);
            ExecuteScript("prc_npc_percep", oCreature);
            break;
        }
        case EVENT_SCRIPT_CREATURE_ON_DIALOGUE:
        {
            if(GetLastSpeaker() == GetMasterNPC(oCreature)
            && GetStringLeft(GetResRef(oCreature), 11) != "prc_pnpfam_")
            {
                if(GetListenPatternNumber() == ASSOCIATE_COMMAND_LEAVEPARTY)
                {
                    DestroyAssociate(oCreature);
                    return;
                }
            }
            ExecuteScript("0e_ch_4_convers", oCreature);
            ExecuteScript("prc_npc_conv", oCreature);
            break;
        }
        case EVENT_SCRIPT_CREATURE_ON_MELEE_ATTACKED:
        {
            ExecuteScript("0e_ch_5_phyatked", oCreature);
            ExecuteScript("prc_npc_physatt", oCreature);
            break;
        }
        case EVENT_SCRIPT_CREATURE_ON_DAMAGED:
        {
            ExecuteScript("0e_ch_6_damaged", oCreature);
            ExecuteScript("prc_npc_damaged", oCreature);
            break;
        }
        case EVENT_SCRIPT_CREATURE_ON_SPELLCASTAT:
        {
            ExecuteScript("0e_ch_b_castat", oCreature);
            ExecuteScript("prc_npc_spellat", oCreature);
            break;
        }
        case EVENT_SCRIPT_CREATURE_ON_END_COMBATROUND:
        {
            ExecuteScript("0e_ch_3_endround", oCreature);
            ExecuteScript("prc_npc_combat", oCreature);
            break;
        }
        case EVENT_SCRIPT_CREATURE_ON_BLOCKED_BY_DOOR:
        {
            ExecuteScript("0e_ch_e_blocked", oCreature);
            ExecuteScript("prc_npc_blocked", oCreature);
            break;
        }
        case EVENT_SCRIPT_CREATURE_ON_RESTED:
        {
            ExecuteScript("0e_ch_a_rested", oCreature);
            ExecuteScript("prc_npc_rested", oCreature);
            if(GetPRCSwitch(PRC_PNP_FAMILIARS))
            {
                object oPC = GetMasterNPC();
                DelayCommand(6.0f, AssignCommand(oPC, ActionCastSpellAtLocation(318, GetLocation(oPC))));
            }
            break;
        }
        case EVENT_SCRIPT_CREATURE_ON_DISTURBED:
        {
            ExecuteScript("0e_ch_8_disturb", oCreature);
            ExecuteScript("prc_npc_disturb", oCreature);
            break;
        }
    }
}
