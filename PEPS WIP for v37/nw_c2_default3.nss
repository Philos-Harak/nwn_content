/*//////////////////////////////////////////////////////////////////////////////
 Script: nw_c2_default3
 Programmer: Philos
////////////////////////////////////////////////////////////////////////////////
  Monster OnCombatRoundEnd event script;
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
    ExecuteScript("prc_npc_combat", oCreature);
    if(AI_DEBUG) ai_Debug("nw_c2_default3", "20", GetName(oCreature) + " ends combat round." +
                 " Current action: " + IntToString(GetCurrentAction(oCreature)));
    if(GetSpawnInCondition(NW_FLAG_END_COMBAT_ROUND_EVENT))
    {
        SignalEvent(OBJECT_SELF, EventUserDefined(1003));
    }
    if(ai_Disabled(oCreature)) return;
    // Action modes get cleared prior to each OnCombatRoundEnd!
    // We do this to keep the action mode going.
    int nActionMode = GetLocalInt(oCreature, AI_CURRENT_ACTION_MODE);
    if(nActionMode > 0)
    {
        SetActionMode(oCreature, nActionMode, TRUE);
        // We don't want to use up all of the Dwarven Defenders uses!
        if(nActionMode == 12) IncrementRemainingFeatUses(oCreature, FEAT_DWARVEN_DEFENDER_DEFENSIVE_STANCE);
    }
    int nAction = GetCurrentAction(oCreature);
    if(AI_DEBUG) ai_Debug("nw_c2_default3", "37", "nAction: " + IntToString(nAction));
    switch(nAction)
    {
        // These actions are uninteruptable.
        case ACTION_MOVETOPOINT :
        case ACTION_CASTSPELL :
        case ACTION_ITEMCASTSPELL :
        case ACTION_COUNTERSPELL : return;
        // Might be doing a special action that is not a defined action.
        case ACTION_INVALID :
        {
            int nCombatWait = GetLocalInt(oCreature, AI_COMBAT_WAIT_IN_SECONDS);
            if(AI_DEBUG) ai_Debug("nw_c2_default3", "49", "nCombatWait: " + IntToString(nCombatWait));
            if(nCombatWait)
            {
                if(ai_IsInCombatRound(oCreature, nCombatWait)) return;
                DeleteLocalInt(oCreature, AI_COMBAT_WAIT_IN_SECONDS);
            }
        }
        // We always want to interupt an attack action at the end of a round.
        //case ACTION_ATTACKOBJECT :
    }
    if(ai_GetIsInCombat(oCreature))
    {
        ai_DoMonsterCombatRound (oCreature);
        return;
    }
    if(ai_GetBehaviorState(NW_FLAG_BEHAVIOR_SPECIAL)) ai_DetermineSpecialBehavior(oCreature);
}




