/*//////////////////////////////////////////////////////////////////////////////
 Script: nw_ch_ac4
 Programmer: Philos
////////////////////////////////////////////////////////////////////////////////
  Associate(Summons, Familiar, Companion) OnDialoge event script;
  Fires when oCreature has been clicked on for conversation.
  Fires when oCreature hears a shout from another creature.
  If SetListening is FALSE then oCreature will not "hear" anything.
*///////////////////////////////////////////////////////////////////////////////
#include "0i_associates"
#include "nw_inc_gff"
void main()
{
    object oCreature = OBJECT_SELF;
    int nMatch = GetListenPatternNumber();
    if(AI_DEBUG) ai_Debug("nw_ch_ac4", "16", GetName(oCreature) + " listens " +
                 IntToString(nMatch) + " to " + GetName(GetLastSpeaker()) + ".");
    // Skip ASSOCIATE_COMMAND_MASTERUNDERATTACK(11) since it fires for
    // every physical attack made on our master. This fires alot!
    if(nMatch == ASSOCIATE_COMMAND_MASTERUNDERATTACK) return;
    // If we are disabled then we can't listen or talk, Busy is checked in ai_SelectAssociateCommand().
    if(ai_Disabled(oCreature)) return;
    object oLastSpeaker = GetLastSpeaker();
    // Some commands override being busy so we check in ai_SelectAssociateCommand.
    if(nMatch != -1)
    {
        if(GetFactionEqual(oLastSpeaker, oCreature)) ai_SelectAssociateCommand(oCreature, oLastSpeaker, nMatch);
    }
    else
    {
        if (!ai_GetIsBusy(oCreature))
        {
            ai_ClearCreatureActions();
            if(GetAssociateType(oCreature) == ASSOCIATE_TYPE_HENCHMAN) BeginConversation("oc_ai_henchmen", oLastSpeaker);
            else
            {
                json jHenchman = ObjectToJson(oCreature);
                string sConversation = JsonGetString(GffGetResRef(jHenchman, "Conversation"));
                if(sConversation == "") BeginConversation("oc_ai_henchmen", oLastSpeaker);
                BeginConversation();
            }
        }
    }
}
