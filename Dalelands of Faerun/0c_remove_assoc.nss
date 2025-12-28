/*//////////////////////////////////////////////////////////////////////////////
 Script: 0c_hench_action
 Programmer: Philos
////////////////////////////////////////////////////////////////////////////////
 Action script used for all henchman conversations doing an action base on the
 sInput param sent.

 Param: Remove_Henchman - removes the henchman from the party.
*///////////////////////////////////////////////////////////////////////////////
#include "0i_henchmen"

void main()
{
    object oHenchman = OBJECT_SELF;
    string sInput = GetScriptParam("sInput");
    Debug("0c_quest_action", "16", "sInput: " + sInput);
    // Used for a workaround when using Executescript to run this script.
    object oPC = GetLocalObject(oHenchman, "0_PCSpeaker");
    if(sInput == "Remove_Henchman")
    {
        ClearAllActions(FALSE, oHenchman);
        FireHenchman(oPC, oHenchman);
        PlayVoiceChat(VOICE_CHAT_GOODBYE, oHenchman);
    }
}
