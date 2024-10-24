/*//////////////////////////////////////////////////////////////////////////////
 Script: 0e_c2_5_phyatked
 Programmer: Philos
////////////////////////////////////////////////////////////////////////////////
  Monster OnPhysicalAttacked event script;
  Fires for all physical attacks, claws, weapons, fists, bow, etc.
  Fires for taunt skill, animal empathy skill.
*///////////////////////////////////////////////////////////////////////////////
//#include "0i_actions"
#include "0i_actions_debug"
void main()
{
    object oCreature = OBJECT_SELF;
    object oAttacker = GetLastAttacker(oCreature);
    ai_Debug("0e_c2_5_phyatked", "15", GetName(oCreature) + " was attacked by " +
             GetName(oAttacker) + ".");
    SetLocalObject(oAttacker, AI_ATTACKED_PHYSICAL, oCreature);
    // Run away!
    if(ai_GetFleeToExit(oCreature))
    {
        ai_ActivateFleeToExit(oCreature);
        return;
    }
    if(GetSpawnInCondition(NW_FLAG_ATTACK_EVENT))
    {
        SignalEvent(oCreature, EventUserDefined(EVENT_ATTACKED));
    }
    if(ai_GetIsBusy(oCreature) || ai_Disabled(oCreature)) return;
    if(ai_GetIsInCombat(oCreature)) return;
    // We only inform others if attacked when not busy, not disabled & not in combat.
    ai_Debug("0e_c2_5_phyatked", "31", "Tell my allies I've been attacked!");
    SetLocalObject (oCreature, AI_MY_TARGET, oAttacker);
    SpeakString(AI_ATKED_BY_WEAPON, TALKVOLUME_SILENT_TALK);
    // Now move towards the attack in the hopes we can see them.
    if(GetDistanceBetween(oCreature, oAttacker) < AI_RANGE_CLOSE) ai_DoMonsterCombatRound(oCreature);
    else ActionMoveToObject(oAttacker, TRUE, AI_RANGE_CLOSE);
}
