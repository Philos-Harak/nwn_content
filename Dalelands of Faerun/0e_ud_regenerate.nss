/*//////////////////////////////////////////////////////////////////////////////
 Script: 0e_ud_regenerate
 Programmer: Naomi Novik
////////////////////////////////////////////////////////////////////////////////
  UserDefined script for Regenerating creatures.
  This adds regeneration the the creature using the userdefined events

/*//////////////////////////////////////////////////////////////////////////////
//const int NW_FLAG_PERCIEVE_EVENT              = 0x00000200;
//const int NW_FLAG_ATTACK_EVENT                = 0x00000400;
const int NW_FLAG_DAMAGED_EVENT               = 0x00000800;
//const int NW_FLAG_SPELL_CAST_AT_EVENT         = 0x00001000;
//const int NW_FLAG_DISTURBED_EVENT             = 0x00002000;
//const int NW_FLAG_END_COMBAT_ROUND_EVENT      = 0x00004000;
//const int NW_FLAG_ON_DIALOGUE_EVENT           = 0x00008000;
//const int NW_FLAG_RESTED_EVENT                = 0x00010000;
const int NW_FLAG_HEARTBEAT_EVENT             = 0x00100000;

#include "0i_effects"
void main()
{
    int nEvent = GetUserDefinedEventNumber();
    //WriteTimestampedLogEntry("nEvent: " + IntToString(nEvent));
    switch(nEvent)
    {
        // We define 1000 as OnSpawn.
        case 1000:
        {
            // *****************************************************************
            // ********** Regenerating: OnSpawn Event  *************************
            // *****************************************************************
            SetSpawnInCondition(NW_FLAG_HEARTBEAT_EVENT);
            SetSpawnInCondition(NW_FLAG_DAMAGED_EVENT);
            SetImmortal(OBJECT_SELF, TRUE);
            break;
        }
        case EVENT_HEARTBEAT:
        {
            // *****************************************************************
            // ********** Regenerating: OnHeartBeat Event  *********************
            // *****************************************************************
            object oCreature = OBJECT_SELF;
            int nTempDmg = GetLocalInt(oCreature, "0_TempDmg" );
            int nTotalDmg = nTempDmg + GetLocalInt(oCreature, "0_PermDmg");
            // If healed above 0 and is unconsious then get up!
            if(GetLocalInt (oCreature, "0_Unconscious"))
            {
                if(nTotalDmg < GetMaxHitPoints())
                {
                    SetCommandable (TRUE);
                    // Force the creature up off the ground won't unless it has an attack target.
                    ActionForceMoveToLocation(GetLocation(oCreature));
                    SetLocalInt(oCreature, "0_Unconscious", FALSE);
                }
                else return;
            }
            if(nTempDmg > 0) Regenerate();
            break;
        }
        case EVENT_DAMAGED:
        {
            // *****************************************************************
            // ********** Regenerating: OnDamage Event  ************************
            // *****************************************************************
            int nMaxHPs = GetMaxHitPoints ();
            if (CalculateRegeneratingCreatureDamage ())
            {
                int nTempDmg = GetLocalInt (OBJECT_SELF, "0_TempDmg");
                int nPermDmg = GetLocalInt (OBJECT_SELF, "0_PermDmg");
                int nTotalDmg = nTempDmg + nPermDmg;
                // If total dmg exceeds max hps then knock it down!
                if (nTotalDmg >= nMaxHPs)
                {
                    float fDuration = (2.0f * IntToFloat (nTotalDmg - nMaxHPs));
                    SetCommandable (TRUE);
                    ClearAllActions ();
                    PlayAnimation (ANIMATION_LOOPING_DEAD_FRONT, 1.0, fDuration);
                    SetLocalInt (OBJECT_SELF, "0_Unconscious", TRUE);
                    DelayCommand (0.05, SetCommandable (FALSE));
                }
                // Check if they stick it with a torch while it is down!
                int nBaseItemType = GetBaseItemType (GetItemInSlot (INVENTORY_SLOT_LEFTHAND, GetLastAttacker()));
                if (GetLocalInt (OBJECT_SELF, "0_Unconscious" ) && nBaseItemType == BASE_ITEM_TORCH )
                {
                    object oTroll = OBJECT_SELF;
                    AssignCommand (GetLastAttacker(), KillRegeneratingCreature (oTroll, FALSE, TRUE));
                }
            }
            break;
        }
    }

}

