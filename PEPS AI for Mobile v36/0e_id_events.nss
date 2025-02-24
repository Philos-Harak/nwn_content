/*//////////////////////////////////////////////////////////////////////////////
// Script Name: 0e_id_events
////////////////////////////////////////////////////////////////////////////////
    Infinite Dungeons monster event handler.
*///////////////////////////////////////////////////////////////////////////////
#include "0i_actions"
#include "x0_i0_assoc"
// Followers special heartbeat script.
void ai_hen_id1_heart(object oCreature);
// Followers special conversation script.
void ai_hen_id1_convo(object oCreature, int nMatch);
// Followers special perception script.
void ai_hen_id1_percept(object oCreature);
// Followers special end of round script.
void ai_hen_id1_endcombat(object oCreature, int bFollower);
// Followers special castat script.
void ai_hen_id1_castat(object oCreature);

void main()
{
    object oCreature = OBJECT_SELF;
    int nEvent = GetCurrentlyRunningEvent();
    int bFollower = GetLocalInt(oCreature, "bFollower");
    //WriteTimestampedLogEntry("00e_inf_dungeons [25] " + GetName(oCreature) + " nEvent: " + IntToString(nEvent) +
    //                         " bFollower: " + IntToString(bFollower));
    switch (nEvent)
    {
        case EVENT_SCRIPT_CREATURE_ON_HEARTBEAT:
        {
            if(bFollower) ai_hen_id1_heart(oCreature);
            else ExecuteScript("nw_c2_default1", oCreature);
            break;
        }
        case EVENT_SCRIPT_CREATURE_ON_NOTICE:
        {
            if(bFollower) ai_hen_id1_percept(oCreature);
            else ExecuteScript("nw_c2_default2", oCreature);
            break;
        }
        case EVENT_SCRIPT_CREATURE_ON_DIALOGUE:
        {
            int nMatch = GetListenPatternNumber();
            if(nMatch == -1)
            {
                if(ai_GetIsBusy(oCreature) || ai_Disabled(oCreature) ||
                   GetLocalInt(oCreature, AI_AM_I_SEARCHING)) return;
                ai_ClearCreatureActions();
                string sConversation = GetLocalString(oCreature, "sConversation");
                if(sConversation != "") BeginConversation(sConversation);
                else BeginConversation();
            }
            if(bFollower) ai_hen_id1_convo(oCreature, nMatch);
            else ExecuteScript("nw_c2_default4", oCreature);
            break;
        }
        case EVENT_SCRIPT_CREATURE_ON_MELEE_ATTACKED:
        {
            if(bFollower) ExecuteScript("nw_ch_ac5", oCreature);
            else ExecuteScript("nw_c2_default5", oCreature);
            break;
        }
        case EVENT_SCRIPT_CREATURE_ON_DAMAGED:
        {
            if(bFollower) ExecuteScript("nw_ch_ac6", oCreature);
            else ExecuteScript("nw_c2_default6", oCreature);
            break;
        }
        case EVENT_SCRIPT_CREATURE_ON_SPELLCASTAT:
        {
            if(bFollower) ai_hen_id1_castat(oCreature);
            else ExecuteScript("nw_c2_defaultb", oCreature);
            break;
        }
        case EVENT_SCRIPT_CREATURE_ON_END_COMBATROUND:
        {
            ai_hen_id1_endcombat(oCreature, bFollower);
            break;
        }
        case EVENT_SCRIPT_CREATURE_ON_BLOCKED_BY_DOOR:
        {
            if(bFollower) ExecuteScript("nw_ch_ace", oCreature);
            else ExecuteScript("nw_c2_defaulte", oCreature);
            break;
        }
        case EVENT_SCRIPT_CREATURE_ON_RESTED:
        {
            if(bFollower) ExecuteScript("nw_ch_aca", oCreature);
            break;
        }
        case EVENT_SCRIPT_CREATURE_ON_DISTURBED:
        {
            if(bFollower) ExecuteScript("nw_ch_ac8", oCreature);
            else ExecuteScript("nw_c2_default8", oCreature);
            break;
        }
    }
}

void ai_hen_id1_heart(object oCreature)
{
    // Sometimes they slip out of this mode!
    if(GetAssociateState(NW_ASC_MODE_DYING, oCreature) &&
       GetCommandable())
    {
        ActionPlayAnimation(ANIMATION_LOOPING_DEAD_FRONT, 1.0, 65.0);
        SetCommandable(FALSE);
    }
    ExecuteScript("nw_ch_ac1", oCreature);
}
void ai_hen_id1_convo(object oCreature, int nMatch)
{
    if(nMatch == ASSOCIATE_COMMAND_INVENTORY)
    {
        // * cannot modify disabled equipment
        if(!GetLocalInt(OBJECT_SELF, "X2_JUST_A_DISABLEEQUIP"))
        {
            OpenInventory(oCreature, GetLastSpeaker());
        }
        // * feedback as to why
        else SendMessageToPCByStrRef(GetMaster(), 100895);
        return;
    }
    else if(nMatch == ASSOCIATE_COMMAND_LEAVEPARTY)
    {
        object oMaster = GetMaster();
        string sTag = GetTag(GetArea(oMaster));
        // * henchman cannot be kicked out in the reaper realm
        // * Followers can never be kicked out
        if (sTag == "GatesofCania" || GetIsFollower(oCreature)) return;
        if(GetIsObjectValid(oMaster))
        {
            ai_ClearCreatureActions();
            if(GetAssociateType(oCreature) == ASSOCIATE_TYPE_HENCHMAN)
            {
                string sConversation = GetLocalString(oCreature, "sConversation");
                if (sConversation == "id1_plotgiver")
                {
                    string sVariable = GetLocalString(oCreature, "sVariable");
                    object oDungeon = GetLocalObject(GetModule(), "oCurrentDungeon");
                    SetLocalInt(oDungeon, "b" + sVariable + "Gone", FALSE);
                }
                RemoveHenchman(oMaster);
                DestroyObject(oCreature);
            }
        }
        return;
    }
    ExecuteScript("nw_ch_ac4", oCreature);
}
void ai_hen_id1_percept(object oCreature)
{
    // If henchman is dying and Player disappears then force a respawn of the henchman
    if (GetIsHenchmanDying(oCreature))
    {
        // The henchman must be removed otherwise their corpse will follow the player
        object oOldMaster = GetMaster();
        object oPC = GetLastPerceived();
        int bVanish = GetLastPerceptionVanished();
        if(GetIsObjectValid(oPC) && bVanish)
        {
            if (oPC == oOldMaster)
            {
                RemoveHenchman(oPC, oCreature);
                // Only in chapter 1
                if(GetTag(GetModule()) == "x0_module1")
                {
                    SetCommandable(TRUE);
                    DoRespawn(oPC,  oCreature); // Should teleport henchman back
                }
            }
        }
    }
    ExecuteScript("nw_ch_ac2", oCreature);
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
            // Restore merchant faction to neutral
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
