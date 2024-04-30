/*//////////////////////////////////////////////////////////////////////////////
 Script: nw_ch_ac4
 Programmer: Philos
////////////////////////////////////////////////////////////////////////////////
  Associate(Summons, Familiar, Companion) OnDialoge event script when not in combat;
  Fires when oCreature has been clicked on for conversation.
  Fires when oCreature hears a shout from another creature.
  If SetListening is FALSE then oCreature will not "hear" anything.
*///////////////////////////////////////////////////////////////////////////////
#include "0i_associates"
void main()
{
    object oCreature = OBJECT_SELF;
    int nMatch = GetListenPatternNumber();
    //ai_Debug("nw_ch_ac4", "15", GetName(oCreature) + " listens " +
    //         IntToString(GetListenPatternNumber()) + " to " + GetName(GetLastSpeaker()) + "." +
    //         " Searching: " + IntToString(GetLocalInt(oCreature, AI_AM_I_SEARCHING)));
    // Skip ASSOCIATE_COMMAND_MASTERUNDERATTACK(11) since it fires for
    // every physical attack made on our master. This fires alot!
    if(nMatch == ASSOCIATE_COMMAND_MASTERUNDERATTACK) return;
    // If we are disabled then we can't listen or talk, Busy is checked in ai_SelectAssociateCommand().
    if(ai_Disabled(oCreature) || GetLocalInt(oCreature, AI_AM_I_SEARCHING)) return;
    if(nMatch != -1) ai_SelectAssociateCommand(oCreature, GetLastSpeaker(), nMatch);
    else
    {
        if (!ai_GetIsBusy(oCreature))
        {
            ai_ClearCreatureActions(oCreature);
            BeginConversation("oc_ai_henchmen", GetPCSpeaker());
        }
    }
    // Some commands override being busy so we check in ai_SelectAssociateCommand.

}

