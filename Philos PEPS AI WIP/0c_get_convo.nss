/*//////////////////////////////////////////////////////////////////////////////
 Script: 0e_get_convo
 Programmer: Philos
////////////////////////////////////////////////////////////////////////////////
 Action taken script that leaves the current conversation and starts a new
 conversation with oCreature using the linked conversation instead of the
 ai_Henchman conversation.

 Allows use of ai_conversation for henchman in other modules.
*///////////////////////////////////////////////////////////////////////////////
#include "0i_actions"
void BeginOriginalHenchmanConversation(object oPC)
{
    BeginConversation("", oPC);
}
void main()
{
    ai_ClearCreatureActions();
    DelayCommand(0.0, BeginOriginalHenchmanConversation(GetPCSpeaker()));
}
