/*//////////////////////////////////////////////////////////////////////////////
 Script:0c_set_questmenu
 Programmer: Philos
////////////////////////////////////////////////////////////////////////////////
 Text Appears When script that sets up the conversation tokens for quest menus.
*///////////////////////////////////////////////////////////////////////////////
#include "0i_master"
#include "0i_database"
#include "nwnx_player"
int  StartingConditional()
{
    string sStatus;
    object oPC = GetPCSpeaker ();
    // Get target
    object oTarget = GetLocalObject (oPC, "0_Creature_Target");
    // Quest Information
    string sQuestArray = GetLocalString (oTarget, "0_Q_QUEST");
    NWNX_Player_SetCustomToken (oPC, 500, GetStringArray (sQuestArray, 0, "-"));
    NWNX_Player_SetCustomToken (oPC, 501, GetStringArray (sQuestArray, 1, "-"));
    NWNX_Player_SetCustomToken (oPC, 502, GetStringArray (sQuestArray, 2, "-"));
    NWNX_Player_SetCustomToken (oPC, 503, GetStringArray (sQuestArray, 3, "-"));
    NWNX_Player_SetCustomToken (oPC, 504, GetStringArray (sQuestArray, 4, "-"));
    NWNX_Player_SetCustomToken (oPC, 505, GetStringArray (sQuestArray, 5, "-"));
    NWNX_Player_SetCustomToken (oPC, 506, GetStringArray (sQuestArray, 6, "-"));
    NWNX_Player_SetCustomToken (oPC, 507, GetStringArray (sQuestArray, 7, "-"));
    NWNX_Player_SetCustomToken (oPC, 508, GetStringArray (sQuestArray, 8, "-"));
    NWNX_Player_SetCustomToken (oPC, 509, GetStringArray (sQuestArray, 9, "-"));
    // Quest States
    string sStateArray = GetLocalString (oTarget, "0_Q_STATE");
    NWNX_Player_SetCustomToken (oPC, 441, GetStringArray (sStateArray, 1, "-"));
    NWNX_Player_SetCustomToken (oPC, 442, GetStringArray (sStateArray, 2, "-"));
    NWNX_Player_SetCustomToken (oPC, 443, GetStringArray (sStateArray, 3, "-"));
    NWNX_Player_SetCustomToken (oPC, 444, GetStringArray (sStateArray, 4, "-"));
    NWNX_Player_SetCustomToken (oPC, 445, GetStringArray (sStateArray, 5, "-"));
    NWNX_Player_SetCustomToken (oPC, 446, GetStringArray (sStateArray, 6, "-"));
    NWNX_Player_SetCustomToken (oPC, 447, GetStringArray (sStateArray, 7, "-"));
    NWNX_Player_SetCustomToken (oPC, 448, GetStringArray (sStateArray, 8, "-"));
    NWNX_Player_SetCustomToken (oPC, 449, GetStringArray (sStateArray, 9, "-"));
    NWNX_Player_SetCustomToken (oPC, 450, GetStringArray (sStateArray, 10, "-"));
    // Get quest areas
    string sStartArray = GetLocalString (oTarget, "0_Q_START");
    NWNX_Player_SetCustomToken (oPC, 451, GetStringArray (sStartArray, 0, "-") + " : " + GetStringArray (sStartArray, 1, "-"));
    string sAreaArray = GetLocalString (oTarget, "0_Q_AREA");
    NWNX_Player_SetCustomToken (oPC, 452, GetStringArray (sAreaArray, 0, "-") + " : " + GetStringArray (sAreaArray, 1, "-"));
    string sFinishArray = GetLocalString (oTarget, "0_Q_FINISH");
    NWNX_Player_SetCustomToken (oPC, 453, GetStringArray (sFinishArray, 0, "-") + " : " + GetStringArray (sFinishArray, 1, "-"));
    // Get NPC information
    string sNPCArray = GetLocalString (oTarget, "0_Q_NPC");
    NWNX_Player_SetCustomToken (oPC, 551, GetStringArray (sNPCArray, 0, "-"));
    NWNX_Player_SetCustomToken (oPC, 552, GetStringArray (sNPCArray, 1, "-"));
    NWNX_Player_SetCustomToken (oPC, 553, GetStringArray (sNPCArray, 2, "-"));
    int nValue = StringToInt (GetStringArray (sNPCArray, 3, "-"));
    NWNX_Player_SetCustomToken (oPC, 554, GetStringArray (":Male:Female:", nValue));
    NWNX_Player_SetCustomToken (oPC, 555, GetStringArray (sNPCArray, 4, "-"));
    NWNX_Player_SetCustomToken (oPC, 556, GetStringArray (sNPCArray, 5, "-"));
    NWNX_Player_SetCustomToken (oPC, 557, GetStringArray (sNPCArray, 7, "-"));
    nValue = StringToInt (GetStringArray (sNPCArray, 8, "-"));
    NWNX_Player_SetCustomToken (oPC, 558, GetStringArray ("::Neutral:Lawful:Chaotic:Good:Evil:", nValue));
    nValue = StringToInt (GetStringArray (sNPCArray, 9, "-"));
    NWNX_Player_SetCustomToken (oPC, 559, GetStringArray ("::Neutral:Lawful:Chaotic:Good:Evil:", nValue));
    nValue = StringToInt (GetStringArray (sNPCArray, 10, "-"));
    NWNX_Player_SetCustomToken (oPC, 560, GetStringArray (":Hostile:Commoner:Merchant:Defender:Neutral:", nValue));
    nValue = StringToInt (GetStringArray (sNPCArray, 12, "-"));
    NWNX_Player_SetCustomToken (oPC, 561, GetStringArray (":None:Clothing:Normal:Magical:", nValue));
    // Get Villain information
    string sVillainArray = GetLocalString (oTarget, "0_Q_VILLAIN");
    NWNX_Player_SetCustomToken (oPC, 571, GetStringArray (sVillainArray, 0, "-"));
    NWNX_Player_SetCustomToken (oPC, 572, GetStringArray (sVillainArray, 1, "-"));
    NWNX_Player_SetCustomToken (oPC, 573, GetStringArray (sVillainArray, 2, "-"));
    nValue = StringToInt (GetStringArray (sVillainArray, 3, "-"));
    NWNX_Player_SetCustomToken (oPC, 574, GetStringArray (":Male:Female:", nValue));
    NWNX_Player_SetCustomToken (oPC, 575, GetStringArray (sVillainArray, 4, "-"));
    NWNX_Player_SetCustomToken (oPC, 576, GetStringArray (sVillainArray, 5, "-"));
    NWNX_Player_SetCustomToken (oPC, 577, GetStringArray (sVillainArray, 7, "-"));
    nValue = StringToInt (GetStringArray (sVillainArray, 8, "-"));
    NWNX_Player_SetCustomToken (oPC, 578, GetStringArray ("::Neutral:Lawful:Chaotic:Good:Evil:", nValue));
    nValue = StringToInt (GetStringArray (sVillainArray, 9, "-"));
    NWNX_Player_SetCustomToken (oPC, 579, GetStringArray ("::Neutral:Lawful:Chaotic:Good:Evil:", nValue));
    nValue = StringToInt (GetStringArray (sVillainArray, 10, "-"));
    NWNX_Player_SetCustomToken (oPC, 580, GetStringArray (":Hostile:Commoner:Merchant:Defender:Neutral:", nValue));
    nValue = StringToInt (GetStringArray (sVillainArray, 12, "-"));
    NWNX_Player_SetCustomToken (oPC, 581, GetStringArray (":None:Clothing:Normal:Magical:", nValue));
    // Get Creature information
    string sCreatureArray = GetLocalString (oTarget, "0_Q_CREATURE");
    NWNX_Player_SetCustomToken (oPC, 582, GetStringArray (sVillainArray, 0, "-"));
    NWNX_Player_SetCustomToken (oPC, 583, GetStringArray (sVillainArray, 1, "-"));
    NWNX_Player_SetCustomToken (oPC, 584, GetStringArray (sVillainArray, 2, "-"));
    NWNX_Player_SetCustomToken (oPC, 585, GetStringArray (sVillainArray, 3, "-"));
    NWNX_Player_SetCustomToken (oPC, 586, GetStringArray (sVillainArray, 4, "-"));
    NWNX_Player_SetCustomToken (oPC, 587, GetStringArray (sVillainArray, 5, "-"));
    nValue = StringToInt (GetStringArray (sVillainArray, 6, "-"));
    NWNX_Player_SetCustomToken (oPC, 588, GetStringArray ("::Tiny:Small:Medium:Large:Huge:", nValue));
    return TRUE;
}
