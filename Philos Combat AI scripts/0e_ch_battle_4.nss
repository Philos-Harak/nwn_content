/*//////////////////////////////////////////////////////////////////////////////
 Script: 0e_ch_battle_4
 Programmer: Philos
////////////////////////////////////////////////////////////////////////////////
    Associate(Summons, Familiar, Companion) on dialoge script used for commands
    while in combat.
*///////////////////////////////////////////////////////////////////////////////
//#include "0i_associates"
#include "0i_assoc_debug"
void main()
{
    object oCreature = OBJECT_SELF;
    int nMatch = GetListenPatternNumber();
    //ai_Debug("0e_ch_battle_4", "14", GetName(oCreature) + " listens " +
    //         IntToString(GetListenPatternNumber()) + " to " + GetName(GetLastSpeaker()) + "!");
    // Skip ASSOCIATE_COMMAND_MASTERUNDERATTACK(11) since it fires for
    // every physical attack made on our master. This fires alot!
    if(nMatch == ASSOCIATE_COMMAND_MASTERUNDERATTACK) return;
    // If we are disabled then we can't talk.
    if(ai_Disabled(oCreature)) return;
    // Some commands override being busy so we check in HenchmanCommands.
    ai_SelectAssociateCommand(oCreature, GetLastSpeaker(), nMatch);
}

