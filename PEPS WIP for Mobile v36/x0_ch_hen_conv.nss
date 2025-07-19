//:://////////////////////////////////////////////////
//:: X0_CH_HEN_CONV
//  OnDialogue event handler for henchmen/associates.
//:://////////////////////////////////////////////////
//:: Copyright (c) 2002 Floodgate Entertainment
//:: Created By: Naomi Novik
//:: Created On: 01/05/2003
//:://////////////////////////////////////////////////
#include "x0_inc_henai"
#include "x0_i0_henchman"
#include "0i_associates"
//* GeorgZ - Put in a fix for henchmen talking even if they are petrified
int AbleToTalk(object oSelf)
{
   if (GetHasEffect(EFFECT_TYPE_CONFUSED, oSelf) || GetHasEffect(EFFECT_TYPE_DOMINATED, oSelf) ||
        GetHasEffect(EFFECT_TYPE_PETRIFY, oSelf) || GetHasEffect(EFFECT_TYPE_PARALYZE, oSelf)   ||
        GetHasEffect(EFFECT_TYPE_STUNNED, oSelf) || GetHasEffect(EFFECT_TYPE_FRIGHTENED, oSelf)
    )
    {
        return FALSE;
    }

   return TRUE;
}
void main()
{
    object oCreature = OBJECT_SELF;
    // * XP2, special handling code for interjections
    // * This script only fires if someone inits with me.
    // * with that in mind, I am now clearing any interjections
    // * that the character might have on themselves.
    if (GetLocalInt(GetModule(), "X2_L_XP2") == TRUE)
    {
        SetLocalInt(oCreature, "X2_BANTER_TRY", 0);
        SetHasInterjection(GetMaster(oCreature), FALSE);
        SetLocalInt(oCreature, "X0_L_BUSY_SPEAKING_ONE_LINER", 0);
        SetOneLiner(FALSE, 0);
    }
    object oLastSpeaker = GetLastSpeaker();
    if (GetTag(oCreature) == "x0_hen_dee")
    {
        string sCall = GetCampaignString("Deekin", "q6_Deekin_Call"+ GetName(oLastSpeaker), oLastSpeaker);
        if (sCall == "") SetCustomToken(1001, GetStringByStrRef(40570));
        else SetCustomToken(1001, sCall);
    }
    // If we are disabled then we can't listen or talk, Busy is checked in ai_SelectAssociateCommand().
    if (GetIsHenchmanDying(oCreature) || ai_Disabled(oCreature)) return;
    object oMaster = GetMaster();
    int nMatch = GetListenPatternNumber();
    object oIntruder;
    if (nMatch == -1)
    {
        if (!ai_GetIsBusy(oCreature))
        {
            ai_ClearCreatureActions();
            string sDialogFileToUse = GetDialogFileToUse(GetLastSpeaker());
            BeginConversation(sDialogFileToUse);
        }
    }
    else
    {
        // listening pattern matched
        if (GetIsObjectValid(oMaster)) ai_SelectAssociateCommand(oCreature, oLastSpeaker, nMatch);
        // we don't have a master, behave in default way
        else if (GetIsObjectValid(oLastSpeaker) &&
                 !GetIsPC(oLastSpeaker) &&
                 GetIsFriend(oLastSpeaker))
        {
            object oIntruder = OBJECT_INVALID;
            // Determine the intruder if any
            if(nMatch == 4) oIntruder = GetLocalObject(oLastSpeaker, "NW_BLOCKER_INTRUDER");
            else if (nMatch == 5)
            {
                oIntruder = GetLastHostileActor(oLastSpeaker);
                if(!GetIsObjectValid(oIntruder))
                {
                    oIntruder = GetAttemptedAttackTarget();
                    if(!GetIsObjectValid(oIntruder)) oIntruder = GetAttemptedSpellTarget();
                }
            }
             // Actually respond to the shout
             RespondToShout(oLastSpeaker, nMatch, oIntruder);
         }
    }
    // Signal user-defined event
    if(GetSpawnInCondition(NW_FLAG_ON_DIALOGUE_EVENT))
    {
        SignalEvent(oCreature, EventUserDefined(EVENT_DIALOGUE));
    }
}

