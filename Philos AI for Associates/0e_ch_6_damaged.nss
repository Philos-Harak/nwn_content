/*//////////////////////////////////////////////////////////////////////////////
 Script: 0e_ch_6_damaged
 Programmer: Philos
////////////////////////////////////////////////////////////////////////////////
  Player OnDamaged script for PC AI;
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
    //ai_Debug("0e_ch_6_damaged", "19", GetName(oCreature) + " has been damaged by " + GetName(oDamager));
    if(ai_IsInADangerousAOE(oCreature)) ai_MoveOutOfAOE(oCreature, GetAreaOfEffectCreator(oDamager));
    else if(!ai_GetIsBusy(oCreature) && ai_GetIsInCombat(oCreature)) ai_DoAssociateCombatRound(oCreature);
}

