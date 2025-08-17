/*//////////////////////////////////////////////////////////////////////////////
 Script: xx_pc_5_phyatked
 Programmer: Philos
////////////////////////////////////////////////////////////////////////////////
  Player OnPhysicalAttacked event script for PC AI;
  Fires for all physical attacks, claws, weapons, fists, bow, etc.
  Fires for taunt skill, animal empathy skill.
/*//////////////////////////////////////////////////////////////////////////////
#include "0i_associates"
void main()
{
    object oCreature = OBJECT_SELF;
    object oAttacker = GetLastAttacker();
    if(AI_DEBUG) ai_Debug("xx_pc_5_phyatked", "14", GetName(oCreature) + " was attacked by " +
                 GetName(oAttacker) + ".");
    SetLocalObject(oAttacker, AI_ATTACKED_PHYSICAL, oCreature);
    if(ai_GetIsBusy(oCreature) || ai_Disabled(oCreature)) return;
    if(ai_GetIsInCombat(oCreature)) return;
    // We only inform others if attacked when not busy, not disabled, & not in combat.
    SetLocalObject(oCreature, AI_MY_TARGET, oAttacker);
    SpeakString(AI_ATKED_BY_WEAPON, TALKVOLUME_SILENT_TALK);
    // The only way to get here is to not be in combat thus we have not
    // perceived them so lets look for them.
    if(!ai_CanIAttack(oCreature)) return;
    if(GetDistanceBetween(oCreature, oAttacker) < AI_RANGE_CLOSE) ai_DoAssociateCombatRound(oCreature);
    else ActionMoveToObject(oAttacker, TRUE, AI_RANGE_CLOSE - 1.0);
}


