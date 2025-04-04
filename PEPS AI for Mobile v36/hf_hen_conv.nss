/*//////////////////////////////////////////////////////////////////////////////
 Script: hf_hen_conv
 Programmer: Philos
////////////////////////////////////////////////////////////////////////////////
  Darkness over Daggerford - henchman developement script.
  Associate(Summons, Familiar, Companion) OnDialoge event script;
  Fires when oCreature has been clicked on for conversation.
  Fires when oCreature hears a shout from another creature.
*///////////////////////////////////////////////////////////////////////////////
#include "0i_associates"
#include "x0_inc_henai"

void main()
{
    if(GetAssociateState(NW_ASC_MODE_DYING)) return;
    object oShouter = GetLastSpeaker();
    object oMaster = GetMaster();
    int nMatch = GetListenPatternNumber();
    // Leaving this here so the module conversation works.
    if (nMatch == -1)
    {
        // no pattern matched, so start our default dialog
        if (GetCommandable(OBJECT_SELF) == TRUE &&
            !ai_Disabled(OBJECT_SELF)  &&
            GetCurrentAction() != ACTION_OPENLOCK)
        {
            string sDialogFile = GetLocalString(OBJECT_SELF, "HF_HENCHMAN_DIALOG");
            ClearAllActions();
            BeginConversation(sDialogFile);
        }
    }
    else
    {
        if(!GetIsObjectValid(oMaster) &&
                 GetIsObjectValid(oShouter) &&
                 !GetIsPC(oShouter) &&
                 GetIsFriend(oShouter))
        {
             // we don't have a master, so behave in default way
             object oIntruder = OBJECT_INVALID;
             // Determine the intruder if any
             if(nMatch == 4)
             {
                 oIntruder = GetLocalObject(oShouter, "NW_BLOCKER_INTRUDER");
             }
             else if (nMatch == 5)
             {
                 oIntruder = GetLastHostileActor(oShouter);
                 if(!GetIsObjectValid(oIntruder))
                 {
                     oIntruder = GetAttemptedAttackTarget();
                     if(!GetIsObjectValid(oIntruder))
                     {
                         oIntruder = GetAttemptedSpellTarget();
                     }
                 }
             }
             // Actually respond to the shout
             RespondToShout(oShouter, nMatch, oIntruder);
         }
    }
    // Signal user-defined event
    if(GetSpawnInCondition(NW_FLAG_ON_DIALOGUE_EVENT))
    {
        SignalEvent(OBJECT_SELF, EventUserDefined(EVENT_DIALOGUE));
    }
    ExecuteScript("nw_ch_ac4");
}


