/*//////////////////////////////////////////////////////////////////////////////
// Script Name: 0e_c2_mon_events
////////////////////////////////////////////////////////////////////////////////
    CEP2 monster event handler.
*///////////////////////////////////////////////////////////////////////////////
#include "0i_actions"
// Monster Tortured Heart heartbeat script.
void ai_c2_mon_heart(object oCreature);
void main()
{
    object oCreature = OBJECT_SELF;
    int nEvent = GetCurrentlyRunningEvent();
    WriteTimestampedLogEntry("0e_c2_mon_events [13] " + GetName(oCreature) + " nEvent: " + IntToString(nEvent));
    switch (nEvent)
    {
        case EVENT_SCRIPT_CREATURE_ON_HEARTBEAT:
        {
            ai_c2_mon_heart(oCreature);
            ExecuteScript("nw_c2_default1", oCreature);
            if(GetLocalInt(GetModule(), "AI_USING_PRC")) ExecuteScript("prc_npc_hb", oCreature);
            break;
        }
        case EVENT_SCRIPT_CREATURE_ON_NOTICE:
        {
            ExecuteScript("nw_c2_default2", oCreature);
            if(GetLocalInt(GetModule(), "AI_USING_PRC")) ExecuteScript("prc_npc_percep", oCreature);
            break;
        }
        case EVENT_SCRIPT_CREATURE_ON_END_COMBATROUND:
        {
            ExecuteScript("nw_c2_default3", oCreature);
            if(GetLocalInt(GetModule(), "AI_USING_PRC")) ExecuteScript("prc_npc_combat", oCreature);
            break;
        }
        case EVENT_SCRIPT_CREATURE_ON_DIALOGUE:
        {
            ExecuteScript("nw_c2_default4", oCreature);
            if(GetLocalInt(GetModule(), "AI_USING_PRC")) ExecuteScript("prc_npc_conv", oCreature);
            break;
        }
        case EVENT_SCRIPT_CREATURE_ON_MELEE_ATTACKED:
        {
            ExecuteScript("nw_c2_default5", oCreature);
            if(GetLocalInt(GetModule(), "AI_USING_PRC")) ExecuteScript("prc_npc_physatt", oCreature);
            break;
        }
        case EVENT_SCRIPT_CREATURE_ON_DAMAGED:
        {
            ExecuteScript("nw_c2_default6", oCreature);
            if(GetLocalInt(GetModule(), "AI_USING_PRC")) ExecuteScript("prc_npc_damaged", oCreature);
            break;
        }
        case EVENT_SCRIPT_CREATURE_ON_SPELLCASTAT:
        {
            ExecuteScript("nw_c2_defaultb", oCreature);
            if(GetLocalInt(GetModule(), "AI_USING_PRC")) ExecuteScript("prc_npc_spellat", oCreature);
            break;
        }
        case EVENT_SCRIPT_CREATURE_ON_BLOCKED_BY_DOOR:
        {
            ExecuteScript("nw_c2_defaulte", oCreature);
            if(GetLocalInt(GetModule(), "AI_USING_PRC")) ExecuteScript("prc_npc_blocked", oCreature);
            break;
        }
        case EVENT_SCRIPT_CREATURE_ON_RESTED:
        {
            if(GetLocalInt(GetModule(), "AI_USING_PRC")) ExecuteScript("prc_npc_rested", oCreature);
            break;
        }
        case EVENT_SCRIPT_CREATURE_ON_DISTURBED:
        {
            ExecuteScript("nw_c2_default8", oCreature);
            if(GetLocalInt(GetModule(), "AI_USING_PRC")) ExecuteScript("prc_npc_disturb", oCreature);
            break;
        }
        case EVENT_SCRIPT_CREATURE_ON_DEATH:
        {
            ExecuteScript("nw_c2_default7", oCreature);
            break;
        }
    }
}
void ai_c2_mon_heart(object oCreature)
{
    SetLocalInt(oCreature,"ArcTargetsDone",0);
    effect eAOE = EffectAreaOfEffect(50);
    ApplyEffectToObject(DURATION_TYPE_TEMPORARY, eAOE, oCreature, HoursToSeconds(100));
    if(GetSpawnInCondition(NW_FLAG_FAST_BUFF_ENEMY))
    {
        if(TalentAdvancedBuff(40.0))
        {
            SetSpawnInCondition(NW_FLAG_FAST_BUFF_ENEMY, FALSE);
            return;
        }
    }
    if(GetSpawnInCondition(NW_FLAG_DAY_NIGHT_POSTING))
    {
        int nDay = FALSE;
        if(GetIsDay() || GetIsDawn()) nDay = TRUE;
        if(GetLocalInt(oCreature, "NW_GENERIC_DAY_NIGHT") != nDay)
        {
            if(nDay == TRUE) SetLocalInt(oCreature, "NW_GENERIC_DAY_NIGHT", TRUE);
            else SetLocalInt(oCreature, "NW_GENERIC_DAY_NIGHT", FALSE);
            WalkWayPoints();
        }
    }
    if(!GetHasEffect(EFFECT_TYPE_SLEEP))
    {
        if(!GetIsPostOrWalking())
        {
            if(!GetIsObjectValid(GetAttemptedAttackTarget()) && !GetIsObjectValid(GetAttemptedSpellTarget()))
            {
                if(!GetIsObjectValid(GetNearestCreature(CREATURE_TYPE_REPUTATION, REPUTATION_TYPE_ENEMY, oCreature, 1, CREATURE_TYPE_PERCEPTION, PERCEPTION_SEEN)))
                {
                    if(!GetBehaviorState(NW_FLAG_BEHAVIOR_SPECIAL) && !IsInConversation(oCreature))
                    {
                        if(GetSpawnInCondition(NW_FLAG_AMBIENT_ANIMATIONS) || GetSpawnInCondition(NW_FLAG_AMBIENT_ANIMATIONS_AVIAN))
                        {
                            PlayMobileAmbientAnimations();
                        }
                        else if(GetIsEncounterCreature() &&
                        !GetIsObjectValid(GetNearestCreature(CREATURE_TYPE_REPUTATION, REPUTATION_TYPE_ENEMY, oCreature, 1, CREATURE_TYPE_PERCEPTION, PERCEPTION_SEEN)))
                        {
                            PlayMobileAmbientAnimations();
                        }
                        else if(GetSpawnInCondition(NW_FLAG_IMMOBILE_AMBIENT_ANIMATIONS) &&
                           !GetIsObjectValid(GetNearestCreature(CREATURE_TYPE_REPUTATION, REPUTATION_TYPE_ENEMY, oCreature, 1, CREATURE_TYPE_PERCEPTION, PERCEPTION_SEEN)))
                        {
                            PlayImmobileAmbientAnimations();
                        }
                    }
                    else {}//DetermineSpecialBehavior();
                }
                else {}//DetermineCombatRound();
            }
        }
    }
    else
    {
        if(GetSpawnInCondition(NW_FLAG_SLEEPING_AT_NIGHT))
        {
            effect eVis = EffectVisualEffect(VFX_IMP_SLEEP);
            if(d10() > 6) ApplyEffectToObject(DURATION_TYPE_INSTANT, eVis, OBJECT_SELF);
        }
    }
}