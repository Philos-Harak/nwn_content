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
//#include "0i_assoc_debug"
void main()
{
    object oCreature = OBJECT_SELF;
    if(ai_Disabled(oCreature)) return;
    object oDamager = GetLastDamager(oCreature);
    //ai_Debug("xx_pc_6_damaged", "19", GetName(oCreature) + " has been damaged by " + GetName(oDamager));
    if(ai_IsInADangerousAOE(oCreature))
    {
        ai_MoveOutOfAOE(oCreature, GetAreaOfEffectCreator(oDamager));
        return;
    }
    if(ai_GetIsBusy(oCreature) || ai_GetIsInCombat(oCreature)) return;
    if(GetDistanceBetween(oCreature, oDamager) < AI_RANGE_CLOSE) ai_DoAssociateCombatRound(oCreature);
    else ActionMoveToObject(oDamager, TRUE, AI_RANGE_CLOSE - 1.0);
}

