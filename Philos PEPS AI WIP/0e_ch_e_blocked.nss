/*//////////////////////////////////////////////////////////////////////////////
 Script: 0e_ch_e_blocked
 Programmer: Philos
////////////////////////////////////////////////////////////////////////////////
  Associates OnBlocked event script;
  Can be blocked by a creature or door.
*///////////////////////////////////////////////////////////////////////////////
#include "0i_associates"
//#include "0i_assoc_debug"
void main()
{
    object oCreature = OBJECT_SELF;
    // This actually gets either a Creature or Door that is blocking OBJECT_SELF.
    object oObject = GetBlockingDoor();
    ai_Debug("0e_ch_e_blocked", "15", GetName(oCreature) + " is being blocked by " + GetName(oObject));
    int nObjectType = GetObjectType(oObject);
    if(nObjectType == OBJECT_TYPE_CREATURE && GetIsEnemy(oObject, oCreature))
    {
        if(ai_CanIAttack(oCreature) && ai_GetIsInCombat(oCreature))
        {
            ai_DoAssociateCombatRound(oCreature);
            return;
        }
        if(ai_CheckForCombat(oCreature)) return;
    }
    if(nObjectType != OBJECT_TYPE_DOOR) return;
    //if(GetLockKeyTag(oObject) != "") return;
    if(GetIsDoorActionPossible(oObject, DOOR_ACTION_OPEN) &&
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
    }
}
