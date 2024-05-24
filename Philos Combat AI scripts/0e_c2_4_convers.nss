/*//////////////////////////////////////////////////////////////////////////////
 Script: 0e_c2_4_convers
 Programmer: Philos
////////////////////////////////////////////////////////////////////////////////
  Monster OnConversation when not in combat;
  Fires when oCreature has been clicked on for conversation.
  Fires when oCreature hears a shout from another creature.
  If SetListening is FALSE then oCreature will not "hear" anything.
*///////////////////////////////////////////////////////////////////////////////
#include "0i_actions"
//#include "0i_actions_debug"
void ai_MonsterCommands(object oCreature, object oSpeaker, int nMatch);
void main()
{
    object oCreature = OBJECT_SELF;
    //ai_Debug("0e_c2_4_convers", "16", GetName(oCreature) + " listens " +
    //         IntToString(GetListenPatternNumber()) + " to " + GetName(GetLastSpeaker()) + "." +
    //         " Searching: " + IntToString(GetLocalInt(oCreature, AI_AM_I_SEARCHING)));
    if(ai_GetIsBusy(oCreature) || ai_Disabled(oCreature) ||
       GetLocalInt(oCreature, AI_AM_I_SEARCHING)) return;
    int nMatch = GetListenPatternNumber();
    if(nMatch > 0) ai_MonsterCommands(oCreature, GetLastSpeaker(), nMatch);
    else if(nMatch == -1)
    {
        ai_ClearCreatureActions(oCreature);
        BeginConversation();
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
    float fDistance = GetDistanceBetween(oCreature, oTarget);
    //ai_Debug("0e_c2_4_convers", "39", " Distance: " + FloatToString(fDistance, 0, 2));
    if(fDistance <= AI_MAX_LISTENING_DISTANCE)
    {
        if(LineOfSightObject(oCreature, oSpeaker))
        {
            if(fDistance > AI_RANGE_CLOSE)
            {
                //ai_Debug("0e_c2_4_convers", "46", "Moving towards " + GetName(oTarget));
                ActionMoveToObject(oTarget, TRUE, AI_RANGE_CLOSE);
                SetLocalInt(oCreature, AI_AM_I_SEARCHING, TRUE);
                ActionDoCommand(DeleteLocalInt(oCreature, AI_AM_I_SEARCHING));
                return;
            }
            //ai_Debug("0e_c2_4_convers", "52", "Searching for " + GetName(oTarget));
            SetActionMode(oCreature, ACTION_MODE_DETECT, TRUE);
            ActionMoveToObject(oTarget, FALSE, AI_RANGE_MELEE);
            SetLocalInt(oCreature, AI_AM_I_SEARCHING, TRUE);
            ActionDoCommand(DeleteLocalInt(oCreature, AI_AM_I_SEARCHING));
            return;
        }
        //ai_Debug("0e_c2_4_convers", "59", "Looking for " + GetName(oSpeaker));
        ActionMoveToObject(oSpeaker, TRUE, AI_RANGE_MELEE);
        SetLocalInt(oCreature, AI_AM_I_SEARCHING, TRUE);
        ActionDoCommand(DeleteLocalInt(oCreature, AI_AM_I_SEARCHING));
    }
}
void ai_MonsterCommands(object oCreature, object oSpeaker, int nMatch)
{
    if(ai_GetIsCharacter(oSpeaker) || !GetIsFriend(oSpeaker, oCreature)) return;
    if(nMatch == AI_ALLY_IS_WOUNDED)
    {
        //ai_Debug("nw_c2_default4", "54", GetName(oCreature) + " heard " +
        //         GetName(oSpeaker) + " is wounded!");
        if(ai_TryHealingOutOfCombat(oCreature, oSpeaker)) return;
    }
    else if(nMatch == AI_ALLY_SEES_AN_ENEMY || nMatch == AI_ALLY_HEARD_AN_ENEMY)
    {
        //ai_Debug("nw_c2_default4", "62", GetName(oCreature) + " heard " +
        //         GetName(oSpeaker) + " has seen an enemy!");
        ai_ReactToAlly(oCreature, oSpeaker);
    }
    else if(nMatch == AI_ALLY_ATKED_BY_WEAPON ||
            nMatch == AI_ALLY_ATKED_BY_SPELL)
    {
        //ai_Debug("nw_c2_default4", "69", GetName(oCreature) + " heard " +
        //         GetName(oSpeaker) + " has been attacked by " +
        //         GetName(GetLocalObject(oSpeaker, AI_MY_TARGET)) + "!");
        ai_ReactToAlly(oCreature, oSpeaker);
    }
    /*else if(nMatch == AI_ALLY_IS_DEAD)
    {
    } */
}

