/*//////////////////////////////////////////////////////////////////////////////
 Script: xx_pc_6_damaged
 Programmer: Philos
////////////////////////////////////////////////////////////////////////////////
  Associate (Summons, Familiars, Companions) OnDamaged script;
  Does not fire if the creature dies from the damage.
  Does not fire for plot creatures as they take no damage.
  May fire before or after OnPhysicalAttacked event.
  Fires when EffectDamage is applied to oCreature even if 0 damage.
  Fires when a weapon damages a oCreature, but not if resisted.
*///////////////////////////////////////////////////////////////////////////////
#include "0i_associates"
void main()
{
    object oCreature = OBJECT_SELF;
    if(ai_Disabled(oCreature)) return;
    // Make sure to clear wounded shout limit if we take damage. See ai_TryHealing.
    DeleteLocalInt(oCreature, "AI_WOUNDED_SHOUT_LIMIT");
    object oDamager = GetLastDamager(oCreature);
    if(AI_DEBUG) ai_Debug("xx_pc_6_damaged", "18", GetName(oCreature) + " has been damaged by " + GetName(oDamager));
    if(GetObjectType(oDamager) == OBJECT_TYPE_AREA_OF_EFFECT &&
       ai_IsInADangerousAOE(oCreature, AI_RANGE_BATTLEFIELD, TRUE)) return;
    if(ai_GetIsBusy(oCreature) || ai_GetIsInCombat(oCreature)) return;
    if(GetDistanceBetween(oCreature, oDamager) < AI_RANGE_CLOSE) ai_DoAssociateCombatRound(oCreature);
    else ActionMoveToObject(oDamager, TRUE, AI_RANGE_CLOSE - 1.0);
}
