/*//////////////////////////////////////////////////////////////////////////////
 Script: 0c_if_identify
 Programmer: Philos
////////////////////////////////////////////////////////////////////////////////
 Text Appears When script that checks to see if the henchmen has a better lore
 skill than the speaker.
 Also checks AI_IDENTIFY_ON to see if the server wants them to help.
*///////////////////////////////////////////////////////////////////////////////
#include "0i_associates"
int StartingConditional()
{
    object oHenchman = OBJECT_SELF;
    if (!AI_IDENTIFY_ON && !ai_CanISpeak (oHenchman)) return FALSE;
    int nHenchmanLore = GetSkillRank(SKILL_LORE, oHenchman);
    int nMasterLore = GetSkillRank(SKILL_LORE, GetMaster(oHenchman));
    return (nHenchmanLore > nMasterLore);
}
