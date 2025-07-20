/*//////////////////////////////////////////////////////////////////////////////
 Script: 0e_c2_4_convers
 Programmer: Philos
////////////////////////////////////////////////////////////////////////////////
  Monster OnConversation;
  Fires when oCreature has been clicked on for conversation.
  Fires when oCreature hears a shout from another creature.
  If SetListening is FALSE then oCreature will not "hear" anything.
*///////////////////////////////////////////////////////////////////////////////
#include "0i_associates"
void ai_MonsterCommands(object oCreature, object oSpeaker, int nMatch);
void main()
{
    object oCreature = OBJECT_SELF;
    ExecuteScript("prc_npc_conv", oCreature);
    if(AI_DEBUG) ai_Debug("nw_c2_default4", "15", GetName(oCreature) + " listens " +
                 IntToString(GetListenPatternNumber()) + " to " + GetName(GetLastSpeaker()) + "." +
                 " AI_AM_I_SEARCHING: " + IntToString(GetLocalInt(oCreature, AI_AM_I_SEARCHING)));
    if(ai_GetIsBusy(oCreature) || ai_Disabled(oCreature) || GetLocalInt(oCreature, AI_AM_I_SEARCHING)) return;
    if(ai_GetIsInCombat(oCreature))
    {
        ai_DoMonsterCombatRound(oCreature);
        return;
    }
    object oLastSpeaker = GetLastSpeaker();
    int nMatch = GetListenPatternNumber();
    if(nMatch != -1)
    {
        if(GetFactionEqual(oLastSpeaker, oCreature)) ai_MonsterCommands(oCreature, oLastSpeaker, nMatch);
    }
    else
    {
        ai_ClearCreatureActions();
        BeginConversation();
    }
    // Send the user-defined event if appropriate
    if(GetSpawnInCondition(NW_FLAG_ON_DIALOGUE_EVENT))
    {
        SignalEvent(OBJECT_SELF, EventUserDefined(EVENT_DIALOGUE));
    }
}
void ai_MonsterCommands(object oCreature, object oSpeaker, int nMatch)
{
    object oTarget = GetLocalObject(oSpeaker, AI_MY_TARGET);
    if(nMatch == AI_ALLY_SEES_AN_ENEMY || nMatch == AI_ALLY_HEARD_AN_ENEMY)
    {
        if(AI_DEBUG) ai_Debug("nw_c2_default4", "46", GetName(oCreature) + " heard " +
                     GetName(oSpeaker) + " has seen an enemy!");
        if(ai_CanIAttack(oCreature)) ai_FindTheEnemy(oCreature, oSpeaker, oTarget, TRUE);
    }
    else if(nMatch == AI_ALLY_ATKED_BY_WEAPON ||
            nMatch == AI_ALLY_ATKED_BY_SPELL)
    {
        if(AI_DEBUG) ai_Debug("nw_c2_default4", "53", GetName(oCreature) + " heard " +
                     GetName(oSpeaker) + " has been attacked by " +
                     GetName(GetLocalObject(oSpeaker, AI_MY_TARGET)) + "!");
        if(ai_CanIAttack(oCreature)) ai_FindTheEnemy(oCreature, oSpeaker, oTarget, TRUE);
    }
    else if(nMatch == AI_ALLY_IS_WOUNDED)
    {
        if(AI_DEBUG) ai_Debug("nw_c2_default4", "60", GetName(oCreature) + " heard " +
                     GetName(oSpeaker) + " is wounded!");
        if(ai_GetIsInCombat(oCreature)) ai_TryHealingTalent(oCreature, ai_GetNumOfEnemiesInRange(oCreature), oSpeaker);
        else ai_TryHealing(oCreature, oSpeaker);
    }
    /*else if(nMatch == AI_ALLY_IS_DEAD)
    {
    } */
}

