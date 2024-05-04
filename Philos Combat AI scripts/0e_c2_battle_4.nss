/*//////////////////////////////////////////////////////////////////////////////
 Script: 0e_c2_battle_4
 Programmer: Philos
////////////////////////////////////////////////////////////////////////////////
  Monster on conversation while in combat.
  // Yes this is basically the default dialogue script but...
  // We set this script up so we can add leader commands later...
*///////////////////////////////////////////////////////////////////////////////
#include "0i_actions"
//#include "0i_actions_debug"
void ai_MonsterCommands(object oCreature, object oSpeaker, int nMatch);
void main()
{
    object oCreature = OBJECT_SELF;
    //ai_Debug("0e_c2_battle_4", "15", GetName(oCreature) + " listens " +
    //         IntToString(GetListenPatternNumber()) + " to " + GetName(GetLastSpeaker()) + "!");
    if(ai_GetIsBusy(oCreature) || ai_Disabled(oCreature)) return;
    if(ai_GetIsInCombat(oCreature))
    {
        ai_DoMonsterCombatRound(oCreature);
        return;
    }
    int nMatch = GetListenPatternNumber();
    // If match is above 0 then someone is telling us something.
    if(nMatch > 0) ai_MonsterCommands(oCreature, GetLastSpeaker(), nMatch);
}
void ai_ReactToAlly(object oSpeaker, object oCreature)
{
    // Check our allies target.
    object oTarget = GetLocalObject(oSpeaker, AI_MY_TARGET);
    if(GetDistanceBetween(oCreature, oTarget) < AI_RANGE_PERCEPTION && LineOfSightObject(oCreature, oTarget))
    {
        //ai_Debug("nw_c2_battle4", "33", "Searching for " + GetName(oTarget));
        SetActionMode(oCreature, ACTION_MODE_DETECT, TRUE);
    }
    else
    {
        //ai_Debug("nw_c2_battle4", "38", "Moving towards " + GetName(oTarget));
        ActionMoveToObject(oTarget, TRUE, AI_RANGE_CLOSE);
    }
}
void ai_MonsterCommands(object oCreature, object oSpeaker, int nMatch)
{
    if(ai_GetIsCharacter(oSpeaker) || GetIsEnemy(oSpeaker, oCreature)) return;
    if(nMatch == AI_ALLY_IS_WOUNDED)
    {
        //ai_Debug("nw_c2_default4", "47", GetName(oCreature) + " heard " +
        //         GetName(oSpeaker) + " is wounded!");
        if(ai_TryHealingTalentOutOfCombat(oCreature, oSpeaker)) return;
    }
    else if(nMatch == AI_ALLY_SEES_AN_ENEMY || nMatch == AI_ALLY_HEARD_AN_ENEMY)
    {
        //ai_Debug("nw_c2_default4", "53", GetName(oCreature) + " heard " +
        //         GetName(oSpeaker) + " has seen an enemy!");
        ai_ReactToAlly(oCreature, oSpeaker);
    }
    else if(nMatch == AI_ALLY_ATKED_BY_WEAPON ||
            nMatch == AI_ALLY_ATKED_BY_SPELL)
    {
        //ai_Debug("nw_c2_default4", "60", GetName(oCreature) + " heard " +
        //         GetName(oSpeaker) + " has been attacked by " +
        //         GetName(GetLocalObject(oSpeaker, AI_MY_TARGET)) + "!");
        ai_ReactToAlly(oCreature, oSpeaker);
    }
    else if(nMatch == AI_ALLY_IS_DEAD)
    {
    }
}

