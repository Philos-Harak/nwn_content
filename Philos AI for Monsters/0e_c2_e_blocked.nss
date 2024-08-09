/*//////////////////////////////////////////////////////////////////////////////
 Script: 0e_c2_e_blocked
 Programmer: Philos
////////////////////////////////////////////////////////////////////////////////
  Monsters OnBlocked event script;
  Can be blocked by a creature or door.
*///////////////////////////////////////////////////////////////////////////////
#include "0i_associates"
//#include "0i_assoc_debug"
void main()
{
    object oCreature = OBJECT_SELF;
    // This actually gets either a Creature or Door that is blocking OBJECT_SELF.
    object oObject = GetBlockingDoor();
    //ai_Debug("0e_c2_e_blocked", "14", GetName(oCreature) + " is being blocked by " + GetName(oObject));
    int nObjectType = GetObjectType(oObject);
    if(nObjectType == OBJECT_TYPE_CREATURE && GetIsEnemy(oObject, oCreature))
    {
        if(ai_CanIAttack(oCreature) && ai_GetIsInCombat(oCreature))
        {
            ai_DoMonsterCombatRound(oCreature);
            return;
        }
        if(ai_CheckForCombat(oCreature)) return;
    }
    if(nObjectType != OBJECT_TYPE_DOOR) return;
    if(GetLockKeyTag(oObject) != "") return;
    // If we are in combat we should ignore doors we run into.
    if(ai_GetIsInCombat(oCreature)) return;
    if(GetIsDoorActionPossible(oObject, DOOR_ACTION_OPEN) &&
       GetAbilityScore(oCreature, ABILITY_INTELLIGENCE) >= 5)
    {
        DoDoorAction(oObject, DOOR_ACTION_OPEN);
    }
    else if(GetIsDoorActionPossible(oObject, DOOR_ACTION_BASH) &&
            GetAbilityScore(oCreature, ABILITY_STRENGTH) >= 7)
    {
        ActionWait(1.0);
        ActionAttack(oObject);
    }
}
