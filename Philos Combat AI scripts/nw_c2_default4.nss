/*//////////////////////////////////////////////////////////////////////////////
 Script: nw_c2_default4
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
    //ai_Debug("nw_c2_default4", "16", GetName(oCreature) + " listens " +
    //         IntToString(GetListenPatternNumber()) + " to " + GetName(GetLastSpeaker()) + "." +
    //         " Searching: " + IntToString(GetLocalInt(oCreature, AI_AM_I_SEARCHING)));
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
        ai_ClearCreatureActions(oCreature);
        BeginConversation("", oCreature);
    }
}
void ai_ReactToAlly(object oCreature, object oSpeaker)
{
    // Check our allies target.
    object oTarget = GetLocalObject(oSpeaker, AI_MY_TARGET);
    if(GetDistanceBetween(oCreature, oTarget) < AI_RANGE_PERCEPTION && LineOfSightObject(oCreature, oTarget))
    {
        //ai_Debug("nw_c2_default4", "40", "Searching for " + GetName(oTarget));
        SetActionMode(oCreature, ACTION_MODE_DETECT, TRUE);
    }
    else
    {
        //ai_Debug("nw_c2_default4", "45", "Moving towards " + GetName(oTarget));
        ActionMoveToObject(oTarget, TRUE, AI_RANGE_CLOSE);
    }
}
void ai_MonsterCommands(object oCreature, object oSpeaker, int nMatch)
{
    if(ai_GetIsCharacter(oSpeaker) || !GetIsFriend(oSpeaker, oCreature)) return;
    if(nMatch == AI_ALLY_IS_WOUNDED)
    {
        //ai_Debug("nw_c2_default4", "54", GetName(oCreature) + " heard " +
        //         GetName(oSpeaker) + " is wounded!");
        if(ai_TryHealingTalentOutOfCombat(oCreature, oSpeaker)) return;
    }
    else if(nMatch == AI_ALLY_SEES_AN_ENEMY || nMatch == AI_ALLY_HEARD_AN_ENEMY)
    {
        //ai_Debug("nw_c2_default4", "60", GetName(oCreature) + " heard " +
        //         GetName(oSpeaker) + " has seen an enemy!");
        ai_ReactToAlly(oCreature, oSpeaker);
    }
    else if(nMatch == AI_ALLY_ATKED_BY_WEAPON ||
            nMatch == AI_ALLY_ATKED_BY_SPELL)
    {
        //ai_Debug("nw_c2_default4", "67", GetName(oCreature) + " heard " +
        //         GetName(oSpeaker) + " has been attacked by " +
        //         GetName(GetLocalObject(oSpeaker, AI_MY_TARGET)) + "!");
        ai_ReactToAlly(oCreature, oSpeaker);
    }
    else if(nMatch == AI_ALLY_IS_DEAD)
    {
    }
}

