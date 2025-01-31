/*//////////////////////////////////////////////////////////////////////////////
 Script: 0e_m1_3_endround
 Original Script: 0e_5_m1q2devour5
 Programmer: Philos
////////////////////////////////////////////////////////////////////////////////
  Monster OnPhysicalAttacked event script used in the original campaign
  for the devour boss;

  Fires for all physical attacks, claws, weapons, fists, bow, etc.
  Fires for taunt skill, animal empathy skill.
*///////////////////////////////////////////////////////////////////////////////
#include "0i_actions"
void main()
{
    object oCreature = OBJECT_SELF;
    object oAttacker = GetLastAttacker(oCreature);
    if(AI_DEBUG) ai_Debug("0e_c2_5_phyatked", "17", GetName(oCreature) + " was attacked by " +
                 GetName(oAttacker) + ".");
    SetLocalObject(oAttacker, AI_ATTACKED_PHYSICAL, oCreature);
    if(ai_GetIsBusy(oCreature) || ai_Disabled(oCreature)) return;
    if(ai_GetIsInCombat(oCreature))
    {
        object oFormerGuard = GetNearestObjectByTag("M1Q2_INTFORGUAR");
        object oPC = GetNearestCreature(CREATURE_TYPE_PLAYER_CHAR, PLAYER_CHAR_IS_PC);

        if(GetIsObjectValid(oFormerGuard) && GetCommandable(oFormerGuard))
        {
            ClearAllActions();
            SignalEvent(OBJECT_SELF,EventUserDefined(1));
            ActionAttack(oFormerGuard);
            SetLocalObject(OBJECT_SELF,"NW_G_M1Q2DevTarget",oFormerGuard);
        }
        else ai_DoMonsterCombatRound(oCreature);
        return;
    }
    // We only inform others if attacked when not busy, not disabled & not in combat.
    if(AI_DEBUG) ai_Debug("0e_c2_5_phyatked", "37", "Tell my allies I've been attacked!");
    SetLocalObject (oCreature, AI_MY_TARGET, oAttacker);
    SpeakString(AI_ATKED_BY_WEAPON, TALKVOLUME_SILENT_SHOUT);
    // Now move towards the attack in the hopes we can see them.
    ActionMoveToObject(oAttacker, TRUE, AI_RANGE_CLOSE);
}
