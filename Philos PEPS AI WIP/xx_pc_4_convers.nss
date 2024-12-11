/*//////////////////////////////////////////////////////////////////////////////
 Script: xx_pc_4_convers
 Programmer: Philos
////////////////////////////////////////////////////////////////////////////////
  Player OnDialoge event script for PC AI;
  Fires when oCreature has been clicked on for conversation.
  Fires when oCreature hears a shout from another creature.
  If SetListening is FALSE then oCreature will not "hear" anything.
*///////////////////////////////////////////////////////////////////////////////
#include "0i_associates"
void main()
{
    object oCreature = OBJECT_SELF;
    int nMatch = GetListenPatternNumber();
    object oLastSpeaker = GetLastSpeaker();
    if(AI_DEBUG) ai_Debug("xx_pc_4_convers", "17", GetName(oCreature) + " listens " +
                 IntToString(nMatch) + " to " + GetName(oLastSpeaker) + "." +
                 " Searching: " + IntToString(GetLocalInt(oCreature, AI_AM_I_SEARCHING)));
    // If we are disabled then we can't listen or talk, Busy is checked in ai_SelectAssociateCommand().
    // Some modules disable the player then talk to them! So it should be ok
    // to keep this remarked out.
    // Some commands override being busy so we check in ai_SelectAssociateCommand.
    if(nMatch != -1)
    {
        if(!GetFactionEqual(oLastSpeaker, oCreature)) return;
        if(!ai_Disabled(oCreature)) ai_SelectAssociateCommand(oCreature, oLastSpeaker, nMatch);
    }
    else BeginConversation("", oLastSpeaker);
}

