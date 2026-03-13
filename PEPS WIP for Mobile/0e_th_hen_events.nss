/*//////////////////////////////////////////////////////////////////////////////
// Script Name: 0e_th_hen_events
////////////////////////////////////////////////////////////////////////////////
    Tortured Hearts henchman event handler.
*///////////////////////////////////////////////////////////////////////////////
#include "0i_actions"
#include "x0_i0_assoc"
// Henchman Tortured Heart attacked script.
void ai_th_hen_attacked(object oCreature);
// Henchman Tortured Heart end of round script.
void ai_th_hen_endcombat(object oCreature, int bFollower);
// Henchman Tortured Heart special castat script.
void ai_th_hen_castat(object oCreature);
void main()
{
    object oCreature = OBJECT_SELF;
    int nEvent = GetCurrentlyRunningEvent();
    int bFollower = GetLocalInt(oCreature, "bFollower");
    //WriteTimestampedLogEntry("0e_th_hen_events [24] " + GetName(oCreature) + " nEvent: " + IntToString(nEvent));
    switch (nEvent)
    {
        case EVENT_SCRIPT_CREATURE_ON_HEARTBEAT:
        {
            int nStory = GetLocalInt(OBJECT_SELF,"END_ACTIVITY");
            if(nStory) return;
            ExecuteScript("nw_ch_ac1", oCreature);
            if(GetLocalInt(GetModule(), "AI_USING_PRC")) ExecuteScript("prc_npc_hb", oCreature);
            break;
        }
        case EVENT_SCRIPT_CREATURE_ON_NOTICE:
        {
            ExecuteScript("nw_ch_ac2", oCreature);
            if(GetLocalInt(GetModule(), "AI_USING_PRC")) ExecuteScript("prc_npc_percep", oCreature);
            break;
        }
        case EVENT_SCRIPT_CREATURE_ON_DIALOGUE:
        {
            string sName = GetLocalString(OBJECT_SELF,"FuckingFirstName");
            SetCustomToken(5007,sName);
            ExecuteScript("nw_ch_ac4", oCreature);
            if(GetLocalInt(GetModule(), "AI_USING_PRC")) ExecuteScript("prc_npc_conv", oCreature);
            break;
        }
        case EVENT_SCRIPT_CREATURE_ON_MELEE_ATTACKED:
        {
            ai_th_hen_attacked(oCreature);
            ExecuteScript("nw_ch_ac5", oCreature);
            if(GetLocalInt(GetModule(), "AI_USING_PRC")) ExecuteScript("prc_npc_physatt", oCreature);
            break;
        }
        case EVENT_SCRIPT_CREATURE_ON_DAMAGED:
        {
            ExecuteScript("nw_ch_ac6", oCreature);
            if(GetLocalInt(GetModule(), "AI_USING_PRC")) ExecuteScript("prc_npc_damaged", oCreature);
            break;
        }
        case EVENT_SCRIPT_CREATURE_ON_SPELLCASTAT:
        {
            ExecuteScript("nw_ch_acb", oCreature);
            if(GetLocalInt(GetModule(), "AI_USING_PRC")) ExecuteScript("prc_npc_spellat", oCreature);
            break;
        }
        case EVENT_SCRIPT_CREATURE_ON_END_COMBATROUND:
        {
            ExecuteScript("nw_ch_ac3", oCreature);
            if(GetLocalInt(GetModule(), "AI_USING_PRC")) ExecuteScript("prc_npc_combat", oCreature);
            break;
        }
        case EVENT_SCRIPT_CREATURE_ON_BLOCKED_BY_DOOR:
        {
            ExecuteScript("nw_ch_ace", oCreature);
            if(GetLocalInt(GetModule(), "AI_USING_PRC")) ExecuteScript("prc_npc_blocked", oCreature);
            break;
        }
        case EVENT_SCRIPT_CREATURE_ON_RESTED:
        {
            ExecuteScript("nw_ch_aca", oCreature);
            if(GetLocalInt(GetModule(), "AI_USING_PRC")) ExecuteScript("prc_npc_rested", oCreature);
            break;
        }
        case EVENT_SCRIPT_CREATURE_ON_DISTURBED:
        {
            ExecuteScript("nw_ch_ac8", oCreature);
            if(GetLocalInt(GetModule(), "AI_USING_PRC")) ExecuteScript("prc_npc_disturb", oCreature);
            break;
        }
        case EVENT_SCRIPT_CREATURE_ON_DEATH:
        {
            ExecuteScript("nw_ch_ac7", oCreature);
            break;
        }
    }
}
void ai_th_hen_attacked(object oCreature)
{
    string sOwnTag = GetLocalString(OBJECT_SELF,"sOwnTag");
    if(sOwnTag=="HS_YANOR")
    {
        int nStory = GetLocalInt(OBJECT_SELF,"OVER");
        int nEvent = GetLocalInt(OBJECT_SELF,"No_Leaving_event") ;
        if((nEvent==0) && (nStory==0))
            {
            if((GetIsInCombat(GetFirstPC())==TRUE) && (GetIsPC(GetLastAttacker())==FALSE))
            {
                RemoveHenchman(GetFirstPC(),OBJECT_SELF);
                SetMaxHenchmen(5);
                SetLocalInt(OBJECT_SELF,"OVER",1);
                ExecuteScript("exec_yanor_flees",OBJECT_SELF);
            }
        }
    }
}
void ai_hen_id1_endcombat(object oCreature, int bFollower)
{
    if (ai_GetIsInCombat(oCreature))
    {
        int nNum;
        int nLine;
        string sString;
        int nCreature;
        int bIntelligent;
        int nRandom = d100();
        // chance of a oneliner
        int nOnelinerPercentage = GetLocalInt(GetModule(), "nFlagCombatOneLinerFrequencyValue");
        if(nRandom <= nOnelinerPercentage)
        {
            string sCreature = GetLocalString(oCreature, "sVariable");
            // if the current creature is hostile towards PCs
            if(sCreature != "")
            {
                object oDungeon = GetLocalObject(GetModule(), "oCurrentDungeon");
                if(GetIsReactionTypeHostile(GetFirstPC()))
                {
                    nCreature = GetLocalInt(oDungeon, "n" + sCreature);
                    bIntelligent = GetLocalInt(oDungeon, "bListCreature" + IntToString(nCreature) + "Intelligent");
                    if(bIntelligent)
                    {
                        nNum = GetLocalInt(GetModule(), "nLinesHostileNum");
                        nLine = Random(nNum) + 1;
                        if(nLine > 0)
                        {
                            sString = GetLocalString(GetModule(), "sLinesHostile" + IntToString(nLine));
                            SpeakString(sString, TALKVOLUME_SHOUT);
                        }
                    }
                }
                else
                {
                    nCreature = GetLocalInt(oDungeon, "n" + sCreature);
                    bIntelligent = GetLocalInt(oDungeon, "bListCreature" + IntToString(nCreature) + "Intelligent");
                    if(bIntelligent)
                    {
                        nNum = GetLocalInt(GetModule(), "nLinesAlliesNum");
                        nLine = Random(nNum) + 1;
                        if (nLine > 0)
                        {
                            sString = GetLocalString(GetModule(), "sLinesAllies" + IntToString(nLine));
                            SpeakString(sString, TALKVOLUME_SHOUT);
                        }
                    }
                }
            }
        }
    }
    if(bFollower) ExecuteScript("nw_ch_ac3", oCreature);
    else ExecuteScript("nw_c2_default3", oCreature);
}
void ai_hen_id1_castat(object oCreature)
{
    if(!GetLastSpellHarmful())
    {
        int nSpell = GetLastSpell();
        if(nSpell == SPELL_RAISE_DEAD || nSpell  == SPELL_RESURRECTION)
        {
            object oCaster = GetLastSpellCaster();
            // Restore faction to neutral
            SetStandardFactionReputation(STANDARD_FACTION_MERCHANT, 100, oCaster);
            SetStandardFactionReputation(STANDARD_FACTION_COMMONER, 100, oCaster);
            SetStandardFactionReputation(STANDARD_FACTION_DEFENDER, 100, oCaster);
            ClearPersonalReputation(oCaster, oCreature);
            AssignCommand(oCreature, SurrenderToEnemies());
            AssignCommand(oCreature, ai_ClearCreatureActions(TRUE));
            // Reset henchmen attack state - Oct 28 (BK)
            ai_SetAIMode(oCreature, AI_MODE_DEFEND_MASTER, FALSE);
            ai_SetAIMode(oCreature, AI_MODE_STAND_GROUND, FALSE);
            ai_SetAIMode(oCreature, AI_MODE_SCOUT_AHEAD, FALSE);
            ai_SetAIMode(oCreature, AI_MODE_SCOUT_AHEAD, FALSE);
            ai_SetAIMode(oCreature, AI_MODE_COMMANDED, FALSE);
            // Oct 30 - If player previously hired this hench
            // then just have them rejoin automatically
            if(GetPlayerHasHired(oCaster, oCreature))
            {
                // Feb 11, 2004 - Jon: Don't fire the HireHenchman function if the
                // henchman is already oCaster's associate. Fixes a silly little problem
                // that occured when you try to raise a henchman who wasn't actually dead.
                if(GetMaster(oCreature)!= oCaster) HireHenchman(oCaster, oCreature, TRUE);
            }
            else
            {
                string sFile = GetDialogFileToUse(oCaster);
                AssignCommand(oCaster, ActionStartConversation(oCreature, sFile));
            }
        }
    }
    ExecuteScript("nw_ch_acb", oCreature);
}