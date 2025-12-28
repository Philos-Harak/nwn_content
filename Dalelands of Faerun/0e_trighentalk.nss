/*////////////////////////////////////////////////////////////////////////////////////////////////////
 Script Name: 0e_trighentalk
 Programmer: Philos
//////////////////////////////////////////////////////////////////////////////////////////////////////
 Event script for trigger to to have a henchmen speak about the area.
 0_SpeakString_* where * is 1 to 6 if they are not all defined it will use the first one.
 - henchman will do a speakstring of the text. if "" then it will be skipped.
 0_PlayVoiceChat - (string) see VOICE_CHAT_* NPC will play a voice chat. If "" then it will be skipped.
    Attack - 0                      GAttack - 11, 12, 13      No - 36
    BadIdea - 47                    TalkToMe - 45             GoodIdea - 46
    BattleCry1, 2, 3 - 1, 2, 3      TaskComplete - 31         Hold - 10
    Cheer - 44                      Taunt - 8                 LookHere - 23
    Cuss - 43                       Thanks - 41               Search - 27
    Enemies - 6                     Yes - 35                  Stop - 37
*/////////////////////////////////////////////////////////////////////////////////////////////////////
#include "0i_master"

void main ()
{
    object oSpeaker = OBJECT_INVALID;
    object oPC = GetEnteringObject ();
    if (GetIsCharacter (oPC))
    {
        if (GetLocalInt (OBJECT_SELF, "0_Spoken")) return;
        SetLocalInt (OBJECT_SELF, "0_Spoken", TRUE);
        object oArea = GetArea (OBJECT_SELF);
        int nCount = 1;
        object oNPC, oHenchman = GetHenchman (oPC, nCount);
        while (oHenchman != OBJECT_INVALID)
        {
            if (GetLocalInt (oHenchman, PC_ASSOCIATE_TYPE) == ASSOCIATE_TYPE_HENCHMAN) oSpeaker = oHenchman;
            oHenchman = GetHenchman (oPC, ++nCount);
        }
        if (oSpeaker != OBJECT_INVALID && d100() > 50)
        {
            string sSpeakString = GetLocalString (OBJECT_SELF, "0_SpeakString_" + IntToString (d6()));
            if (sSpeakString == "") sSpeakString = GetLocalString (OBJECT_SELF, "0_SpeakString_1");
            if (sSpeakString != "")
            {
                AssignCommand (oSpeaker, SpeakString (sSpeakString));
            }
            string sPlayVoiceChat = GetLocalString (OBJECT_SELF, "0_PlayVoiceChat");
            if (sPlayVoiceChat != "")
            {
                PlayVoiceChat (StringToInt (sPlayVoiceChat), oSpeaker);
            }
        }
    }
}

