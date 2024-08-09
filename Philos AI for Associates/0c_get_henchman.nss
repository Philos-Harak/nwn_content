/*//////////////////////////////////////////////////////////////////////////////
 Script: 0e_get_henchman
 Programmer: Philos
////////////////////////////////////////////////////////////////////////////////
 Action taken script that adds oCreature to oPC's party as a henchman
 while giving a random message.
*///////////////////////////////////////////////////////////////////////////////
#include "0i_associates"
void main()
{
    object oCreature = OBJECT_SELF;
    object oPC = GetPCSpeaker();
    SetMaxHenchmen(2);
    AddHenchman(oPC, oCreature);
    ai_SetAssociateData(oPC, oCreature);
    int nVoice;
    switch(d4())
    {
        case 1: nVoice = VOICE_CHAT_CANDO; break;
        case 2: nVoice = VOICE_CHAT_CHEER; break;
        case 3: nVoice = VOICE_CHAT_GOODIDEA; break;
        case 4: nVoice = VOICE_CHAT_LAUGH; break;
   }
   PlayVoiceChat(nVoice, oCreature);
}


