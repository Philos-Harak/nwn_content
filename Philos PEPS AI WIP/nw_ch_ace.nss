/*//////////////////////////////////////////////////////////////////////////////
 Script: 0e_ch_e_blocked
 Programmer: Philos
////////////////////////////////////////////////////////////////////////////////
  Associates OnBlocked event script;
  Can be blocked by a creature or door.
*///////////////////////////////////////////////////////////////////////////////
#include "0i_associates"
void main()
{
    object oCreature = OBJECT_SELF;
    // This actually gets either a Creature or Door that is blocking OBJECT_SELF.
    object oObject = GetBlockingDoor();
    if(AI_DEBUG) ai_Debug("nw_ch_ace", "14", GetName(oCreature) + " is being blocked by " + GetName(oObject));
    int nObjectType = GetObjectType(oObject);
    if(nObjectType == OBJECT_TYPE_CREATURE && GetIsEnemy(oObject, oCreature))
    {
        if(ai_CanIAttack(oCreature) && ai_GetIsInCombat(oCreature))
        {
            ai_DoAssociateCombatRound(oCreature);
            return;
        }
        if(ai_CheckForCombat(oCreature, FALSE)) return;
    }
    // Anything below blocking us is a door.
    if(nObjectType != OBJECT_TYPE_DOOR) return;
    if(!ai_GetAIMode(oCreature, AI_MODE_OPEN_DOORS)) return;
    //if(GetLockKeyTag(oObject) != "") return;
    else if(GetIsDoorActionPossible(oObject, DOOR_ACTION_OPEN) &&
       GetAbilityScore(oCreature, ABILITY_INTELLIGENCE) >= 5)
    {
        DoDoorAction(oObject, DOOR_ACTION_OPEN);
        return;
    }
    // Anything below is ignored in combat.
    if(ai_GetIsInCombat(oCreature)) return;
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
    else if(GetLocked(oObject))
    {
        if(AI_DEBUG) ai_Debug("nw_ch_ace", "49", GetName(oObject) + " is locked!");
        ai_AttemptToByPassLock(oCreature, oObject);
    }
    // Clear our action so we can move on to something else unless the door is open.
    else if(!GetIsOpen(oObject))
    {
        ai_ClearCreatureActions();
    }
}
