/*//////////////////////////////////////////////////////////////////////////////
 Script: nw_c2_defaulte
 Programmer: Philos
////////////////////////////////////////////////////////////////////////////////
  Monsters OnBlocked event script;
  Can be blocked by a creature or door.
*///////////////////////////////////////////////////////////////////////////////
#include "0i_associates"
void main()
{
    object oCreature = OBJECT_SELF;
    // This actually gets either a Creature or Door that is blocking OBJECT_SELF.
    object oObject = GetBlockingDoor();
    if(AI_DEBUG) ai_Debug("nw_c2_defaulte", "14", GetName(oCreature) + " is being blocked by " + GetName(oObject));
    int nObjectType = GetObjectType(oObject);
    if(nObjectType == OBJECT_TYPE_CREATURE && GetIsEnemy(oObject, oCreature))
    {
        if(ai_CanIAttack(oCreature) && ai_GetIsInCombat(oCreature))
        {
            ai_DoMonsterCombatRound(oCreature);
            return;
        }
        if(ai_CheckForCombat(oCreature, TRUE)) return;
    }
    // Anything below blocking us is a door.
    if(nObjectType != OBJECT_TYPE_DOOR) return;
    //if(GetLockKeyTag(oObject) != "") return;
    else if(GetIsDoorActionPossible(oObject, DOOR_ACTION_OPEN) &&
       GetAbilityScore(oCreature, ABILITY_INTELLIGENCE) >= 5)
    {
        DoDoorAction(oObject, DOOR_ACTION_OPEN);
        return;
    }
    // If we are in combat we should ignore doors that do not easily open.
    if(GetIsDoorActionPossible(oObject, DOOR_ACTION_BASH) &&
       ai_GetWeaponDamage(oCreature, 3, TRUE) > GetHardness(oObject) &&
       GetLockKeyTag(oObject) == "")
    {
        ActionWait(1.0);
        ActionAttack(oObject);
        // Give them 3 rounds to break through a door.
        DelayCommand(18.0, ai_ClearCreatureActions(TRUE));
        return;
    }
}
