/*////////////////////////////////////////////////////////////////////////////////////////////////////
 Script Name: 0e_trignpctalk
 Programmer: Philos
//////////////////////////////////////////////////////////////////////////////////////////////////////
 Event script for trigger to to have a quest NPC speak in the PC's part.
 0_QuestLocation is "start", "area" or "finish"
 0_SpeakString - NPC will do a speakstring of the text. if "" then it will be skipped.
 0_PlayVoiceChat - (string) see VOICE_CHAT_* NPC will play a voice chat. If "" then it will be skipped.
    Attack - 0                      GAttack - 11, 12, 13      No - 36
    BadIdea - 47                    TalkToMe - 45             GoodIdea - 46
    BattleCry1, 2, 3 - 1, 2, 3      TaskComplete - 31         Hold - 10
    Cheer - 44                      Taunt - 8                 LookHere - 23
    Cuss - 43                       Thanks - 41               Search - 27
    Enemies - 6                     Yes - 35                  Stop - 37
*/////////////////////////////////////////////////////////////////////////////////////////////////////
#include "0i_quest"
void main ()
{
    object oPC = GetEnteringObject ();
    if (GetIsCharacter (oPC))
    {
        object oTrigger = OBJECT_SELF;
        if (GetLocalInt(oTrigger, GetObjectUUID(oPC) + "_Quest")) return;
        string sDBArea = GetLocalString(oTrigger, "0_QuestLocation");
        object oArea = GetArea(oTrigger);
        string sQuestID = GetQuestIDByAreaTag(oArea, oPC, sDBArea);
        Debug("0e_trignpctalk", "27", "sQuestID: " + sQuestID);
        if(sQuestID == "") return;
        string sNPCArray = GetServerDatabaseString(oPC, QUEST_TABLE, "npc", sQuestID);
        string sNPCID;
        int nCount = 1;
        object oHenchman = GetHenchman(oPC, nCount);
        while(oHenchman != OBJECT_INVALID)
        {
            sNPCID = GetLocalString(oHenchman, "0_QUEST_ID");
            Debug("0e_trignpctalk", "36", GetName(oHenchman) + " sNPCID: " + sNPCID);
            if(sNPCID == sQuestID) break;
            oHenchman = GetHenchman(oPC, ++nCount);
        }
        if(oHenchman != OBJECT_INVALID)
        {
            SetLocalInt(oTrigger, GetObjectUUID(oPC) + "_Quest", TRUE);
            string sSpeakString = GetLocalString (oTrigger, "0_SpeakString");
            if(sSpeakString != "")
            {
                AssignCommand(oHenchman, SpeakString (sSpeakString));
            }
            string sPlayVoiceChat = GetLocalString(oTrigger, "0_PlayVoiceChat");
            if(sPlayVoiceChat != "")
            {
                PlayVoiceChat(StringToInt(sPlayVoiceChat), oHenchman);
            }
        }
    }
}

