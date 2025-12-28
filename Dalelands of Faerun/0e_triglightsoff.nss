/*////////////////////////////////////////////////////////////////////////////////////////////////////
 Script Name: 0e_triglightsoff
 Programmer: Philos
//////////////////////////////////////////////////////////////////////////////////////////////////////
 Event script for trigger to to have a quest NPC speak in the PC's part.
 And then turn the nearest lights off.
 0_QuestLocation is "start", "area" or "finish"
 0_SpeakString - NPC will do a speakstring of the text. if "" then it will be skipped.
 0_PlayVoiceChat - (int) see VOICE_CHAT_* NPC will play a voice chat. If "" then it will be skipped.
    Attack - 0                      GAttack1, 2, 3 - 11, 12, 13
    BadIdea - 47                    TalkToMe - 45
    BattleCry1, 2, 3 - 1, 2, 3      TaskComplete - 31
    Cheer - 44                      Taunt - 8
    Cuss - 43                       Thanks - 41
    Enemies - 6                     Yes - 35
*/////////////////////////////////////////////////////////////////////////////////////////////////////
#include "0i_quest"
void main ()
{
    object oPC = GetEnteringObject ();
    if(GetIsCharacter (oPC))
    {
        if(GetLocalInt(OBJECT_SELF, "0_Spoken")) return;
        string sPaperArea = GetLocalString(OBJECT_SELF, "0_QuestLocation");
        object oArea = GetArea (OBJECT_SELF);
        string sQuestID = GetQuestIDByAreaTag(oArea, oPC, sPaperArea);
        if(sQuestID != "")
        {
            string sNPCArray = GetServerDatabaseString(oPC, QUEST_TABLE, "npc", sQuestID);
            string sNPCID, sPaperID = GetStringArray(sNPCArray, 2, "-");
            int nCount = 1;
            object oHenchman = GetHenchman (oPC, nCount);
            while(oHenchman != OBJECT_INVALID)
            {
                sNPCID = GetLocalString(oHenchman, "0_QUEST_ID");
                if (sNPCID == sPaperID) break;
                oHenchman = GetHenchman(oPC, ++nCount);
            }
            if(oHenchman != OBJECT_INVALID)
            {
                SetLocalInt(OBJECT_SELF, "0_Spoken", TRUE);
                string sSpeakString = GetLocalString(OBJECT_SELF, "0_SpeakString");
                if (sSpeakString != "")
                {
                    AssignCommand(oHenchman, SpeakString(sSpeakString));
                }
                string sPlayVoiceChat = GetLocalString(OBJECT_SELF, "0_PlayVoiceChat");
                if (sPlayVoiceChat != "")
                {
                    PlayVoiceChat(StringToInt(sPlayVoiceChat), oHenchman);
                }
            }
        }
    }
    // Turn off the nearest 2 lights.
    int iCounter = 1;
    effect eEffect;
    object oLight = GetNearestObjectByTag("0_Light", oPC, iCounter);
    while(GetIsObjectValid(oLight) && iCounter < 3)
    {
        DeleteLocalInt(oLight, "0_Placeable_On");
        AssignCommand(oLight, PlayAnimation(ANIMATION_PLACEABLE_DEACTIVATE));
        eEffect = GetFirstEffect (oLight);
        while(GetIsEffectValid (eEffect))
        {
            if(GetEffectType(eEffect) == EFFECT_TYPE_VISUALEFFECT) RemoveEffect(oLight, eEffect);
            eEffect = GetNextEffect(oLight);
        }
        iCounter ++;
        oLight = GetNearestObjectByTag("0_Light", oPC, iCounter);
    }
    // Turn off sounds too.
    iCounter = 1;
    object oSound = GetNearestObjectByTag("0_torch_sound", oPC, iCounter);
    while(GetIsObjectValid (oSound) && iCounter < 3)
    {
        SoundObjectStop(oSound);
        iCounter ++;
        oSound = GetNearestObjectByTag("0_torch_sound", oPC, iCounter);
    }
}

