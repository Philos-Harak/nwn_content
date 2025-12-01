/*//////////////////////////////////////////////////////////////////////////////
 Script: 0e_m1_3_endround
 Original Script: m1_combanter_3
 Programmer: Philos
////////////////////////////////////////////////////////////////////////////////
  Monster OnCombatRoundEnd event script used in the original campaign
  for monsters that may do a one liner during combat;

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
void main()
{
    object oCreature = OBJECT_SELF;
    if(AI_DEBUG) ai_Debug("0e_m1_3_endround", "23", GetName(oCreature) + " ends combat round.");
    // Action modes get cleared prior to each OnCombatRoundEnd!
    // We do this to keep the action mode going.
    int nActionMode = GetLocalInt(oCreature, AI_CURRENT_ACTION_MODE);
    if(nActionMode > 0)
    {
        SetActionMode(oCreature, nActionMode, TRUE);
        // We don't want to use up all of the Dwarven Defenders uses!
        if(nActionMode == 12) IncrementRemainingFeatUses(oCreature, FEAT_DWARVEN_DEFENDER_DEFENSIVE_STANCE);
    }
    if (ai_GetIsBusy(oCreature) || ai_Disabled(oCreature)) return;
    if(Random(4) == 0) SpeakOneLinerConversation();
    if(ai_GetIsInCombat(oCreature)) ai_DoMonsterCombatRound(oCreature);
    ai_SpellConcentrationCheck(oCreature);
    if(ai_GetBehaviorState(NW_FLAG_BEHAVIOR_SPECIAL)) ai_DetermineSpecialBehavior(oCreature);
    if(GetSpawnInCondition(NW_FLAG_END_COMBAT_ROUND_EVENT))
    {
        SignalEvent(OBJECT_SELF, EventUserDefined(1003));
    }
}




