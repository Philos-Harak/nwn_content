/*//////////////////////////////////////////////////////////////////////////////
 Script: xx_pc_e_blocked
 Programmer: Philos
////////////////////////////////////////////////////////////////////////////////
  Associates OnBlocked event script;
  Can be blocked by a creature or door.
*///////////////////////////////////////////////////////////////////////////////
#include "0i_messages"
void main()
{
    object oCreature = OBJECT_SELF;
    // This actually gets either a Creature or Door that is blocking OBJECT_SELF.
    object oObject = GetBlockingDoor();
    //ai_Debug("xx_pc_e_blocked", "14", GetName(oCreature) + " is being blocked by " + GetName(oObject));
    if(GetObjectType(oObject) != OBJECT_TYPE_DOOR) return;
    if(GetLockKeyTag(oObject) != "") return;
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
