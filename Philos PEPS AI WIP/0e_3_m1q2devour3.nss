/*//////////////////////////////////////////////////////////////////////////////
 Script: 0e_m1_3_endround
 Original Script: 0e_3_m1q2devour3
 Programmer: Philos
////////////////////////////////////////////////////////////////////////////////
  Monster OnCombatRoundEnd event script used in the original campaign
  for the devour boss;

  Fires at the end of each combat round (6 seconds).
  This will fire as long as oCreature is in combat (GetIsInCombat()).
  This event starts counting once a combat action is started.
  Every time a spell is cast it will queue another end combat round so haste with
    two spells cast will fire this twice in one round.
  It will also fire at the end of a hostile effect that stops actions i.e Stunned, Knockdown etc.
  Action modes are also cleared prior to this event executing!
  GetAttemptedAttackTarget() & GetAttemptedSpellTarget() also get cleared prior to this event.
  This event can be canceled with ClearAllActions(TRUE) and SurrenderToEnemies.
*///////////////////////////////////////////////////////////////////////////////
#include "0i_actions"
//#include "0i_actions_debug"
void main()
{
    object oCreature = OBJECT_SELF;
    //ai_Debug("0e_m1_3_endround", "21", GetName(oCreature) + " ends combat round.");
    if (ai_GetIsBusy(oCreature) || ai_Disabled(oCreature)) return;
    if(ai_GetIsInCombat(oCreature))
    {
        if(GetIsObjectValid(GetLocalObject(OBJECT_SELF,"NW_G_M1Q2DevTarget")) == FALSE)
        {
            ai_DoMonsterCombatRound(oCreature);
        }
    }
}




