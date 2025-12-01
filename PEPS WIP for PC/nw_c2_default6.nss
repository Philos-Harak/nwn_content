/*//////////////////////////////////////////////////////////////////////////////
 Script: nw_c2_default6
 Programmer: Philos
////////////////////////////////////////////////////////////////////////////////
  Monster OnDamaged event script;
  Does not fire if the creature dies from the damage.
  Does not fire for plot creatures as they take no damage.
  May fire before or after OnPhysicalAttacked event.
  Fires when EffectDamage is applied to oCreature even if 0 damage.
  Fires when a weapon damages a oCreature, but not if resisted.
*///////////////////////////////////////////////////////////////////////////////
#include "0i_actions"
void main()
{
    object oCreature = OBJECT_SELF;
    ExecuteScript("prc_npc_damaged", oCreature);
    // Send the user-defined event signal
    if(GetSpawnInCondition(NW_FLAG_DAMAGED_EVENT))
    {
        SignalEvent(oCreature, EventUserDefined(EVENT_DAMAGED));
        return;
    }
    if(ai_Disabled(oCreature)) return;
    // Make sure to clear wounded shout limit if we take damage. See ai_TryHealing.
    DeleteLocalInt(oCreature, "AI_WOUNDED_SHOUT_LIMIT");
    object oDamager = GetLastDamager(oCreature);
    if(AI_DEBUG) ai_Debug("nw_c2_default6", "23", GetName(oCreature) + " has been damaged by " + GetName(oDamager));
    if(ai_GetFleeToExit(oCreature)) return;
    if(GetObjectType(oDamager) == OBJECT_TYPE_AREA_OF_EFFECT &&
       ai_IsInADangerousAOE(oCreature, AI_RANGE_BATTLEFIELD, TRUE)) return;
    if(ai_GetIsBusy(oCreature) || ai_GetIsInCombat(oCreature)) return;
    if(GetDistanceBetween(oCreature, oDamager) < AI_RANGE_CLOSE) ai_DoMonsterCombatRound(oCreature);
    else ActionMoveToObject(oDamager, TRUE, AI_RANGE_CLOSE - 1.0);
}
