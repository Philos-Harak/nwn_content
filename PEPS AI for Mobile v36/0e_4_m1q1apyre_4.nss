/*//////////////////////////////////////////////////////////////////////////////
 Script: 0e_4_m1q1apyre_4
 Original Script: m1q1apyre_4
 Programmer: Philos
////////////////////////////////////////////////////////////////////////////////
  Monster OnConversation when not in combat;
  Fires when oCreature has been clicked on for conversation.
  Fires when oCreature hears a shout from another creature.
  If SetListening is FALSE then oCreature will not "hear" anything.
*///////////////////////////////////////////////////////////////////////////////
#include "0i_actions"
void ai_MonsterCommands(object oCreature, object oSpeaker, int nMatch);
void main()
{
    object oCreature = OBJECT_SELF;
    if(AI_DEBUG) ai_Debug("nw_c2_default4", "16", GetName(oCreature) + " listens " +
                 IntToString(GetListenPatternNumber()) + " to " + GetName(GetLastSpeaker()) + "." +
                 " Searching: " + IntToString(GetLocalInt(oCreature, AI_AM_I_SEARCHING)));
    if(ai_GetIsBusy(oCreature) || ai_Disabled(oCreature) ||
       GetLocalInt(oCreature, AI_AM_I_SEARCHING)) return;
    if(ai_GetIsInCombat(oCreature))
    {
        ai_DoMonsterCombatRound(oCreature);
        return;
    }
    int nMatch = GetListenPatternNumber();
    if(nMatch > 0) ai_MonsterCommands(oCreature, GetLastSpeaker(), nMatch);
    else if(nMatch == -1)
    {
       SpeakOneLinerConversation();
    }
    // Send the user-defined event if appropriate
    if(GetSpawnInCondition(NW_FLAG_ON_DIALOGUE_EVENT))
    {
        SignalEvent(OBJECT_SELF, EventUserDefined(EVENT_DIALOGUE));
    }
}
void ai_ReactToAlly(object oCreature, object oSpeaker)
{
    // Check our allies target.
    object oTarget = GetLocalObject(oSpeaker, AI_MY_TARGET);
    if(AI_DEBUG) ai_Debug("nw_c2_default4", "42", " Distance: " + FloatToString(GetDistanceBetween(oCreature, oTarget), 0, 2));
    if(GetDistanceBetween(oCreature, oTarget) <= GetLocalFloat(GetModule(), AI_RULE_PERCEPTION_DISTANCE) &&
       LineOfSightObject(oCreature, oSpeaker))
    {
        float fDistance = GetDistanceBetween(oCreature, oTarget);
        if(fDistance > AI_RANGE_CLOSE)
        {
            //ai_Debug("nw_c2_default4", "53", "Moving towards " + GetName(oTarget));
            ActionMoveToObject(oTarget, TRUE, AI_RANGE_CLOSE);
            SetLocalInt(oCreature, AI_AM_I_SEARCHING, TRUE);
        }
        else
        {
            //ai_Debug("nw_c2_default4", "49", "Searching for " + GetName(oTarget));
            SetActionMode(oCreature, ACTION_MODE_DETECT, TRUE);
            SetLocalInt(oCreature, AI_AM_I_SEARCHING, TRUE);
        }
    }
}
void ai_MonsterCommands(object oCreature, object oSpeaker, int nMatch)
{
    if(ai_GetIsCharacter(oSpeaker) || !GetIsFriend(oSpeaker, oCreature)) return;
    if(nMatch == AI_ALLY_IS_WOUNDED)
    {
        if(AI_DEBUG) ai_Debug("nw_c2_default4", "66", GetName(oCreature) + " heard " +
                     GetName(oSpeaker) + " is wounded!");
        if(ai_GetIsInCombat(oCreature)) ai_TryHealingTalent(oCreature, ai_GetNumOfEnemiesInRange(oCreature), oSpeaker);
        else ai_TryHealing(oCreature, oSpeaker);
    }
    else if(nMatch == AI_ALLY_SEES_AN_ENEMY || nMatch == AI_ALLY_HEARD_AN_ENEMY)
    {
        if(AI_DEBUG) ai_Debug("nw_c2_default4", "73", GetName(oCreature) + " heard " +
                     GetName(oSpeaker) + " has seen an enemy!");
        ai_ReactToAlly(oCreature, oSpeaker);
    }
    else if(nMatch == AI_ALLY_ATKED_BY_WEAPON ||
            nMatch == AI_ALLY_ATKED_BY_SPELL)
    {
        if(AI_DEBUG) ai_Debug("nw_c2_default4", "80", GetName(oCreature) + " heard " +
                     GetName(oSpeaker) + " has been attacked by " +
                     GetName(GetLocalObject(oSpeaker, AI_MY_TARGET)) + "!");
        ai_ReactToAlly(oCreature, oSpeaker);
    }
    else if(nMatch == AI_ALLY_IS_DEAD)
    {
    }
}

