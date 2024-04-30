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
//#include "0i_actions_debug"
void main()
{
    object oCreature = OBJECT_SELF;
    if(ai_Disabled(oCreature)) return;
    object oDamager = GetLastDamager(oCreature);
    //ai_Debug("nw_c2_default6", "18", GetName(oCreature) + " has been damaged by " + GetName(oDamager));
    // This is every other object that may do damage.
    if(GetObjectType(oDamager) != OBJECT_TYPE_AREA_OF_EFFECT)
    {
        if(!ai_GetIsBusy(oCreature) && ai_GetIsInCombat(oCreature)) ai_DoMonsterCombatRound(oCreature);
        return;
    }
    // Anything below here is an AOE and if it did damage then lets get out of it!
    if(GetTotalDamageDealt() > 0) ai_MoveOutOfAOE(oCreature, GetAreaOfEffectCreator(oDamager));
}
