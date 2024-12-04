/*//////////////////////////////////////////////////////////////////////////////
 Script: 0e_ch_e_blocked
 Programmer: Philos
////////////////////////////////////////////////////////////////////////////////
  Associates OnBlocked event script;
  Can be blocked by a creature or door.
*///////////////////////////////////////////////////////////////////////////////
//#include "0i_associates"
#include "0i_assoc_debug"
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
        if(ai_CheckForCombat(oCreature, FALSE)) return;
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
    // Anything below is ignored in combat.
    if(ai_GetIsInCombat(oCreature)) return;
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
    else if(GetLocked(oObject))
    {
        ai_Debug("0e_ch_e_blocked", "50", GetName(oObject) + " is locked!");
        string sID = ObjectToString(oCreature);
        if(!GetLocalInt(oObject, "AI_STATED_LOCKED_" + sID) &&
           !ai_GetAIMode(oCreature, AI_MODE_DO_NOT_SPEAK)) SpeakString("That " + GetName(oObject) + " is locked!");
        SetLocalInt(oObject, "AI_STATED_LOCKED_" + sID, TRUE);
        if(ai_GetAIMode(oCreature, AI_MODE_PICK_LOCKS) ||
           ai_GetAIMode(oCreature, AI_MODE_BASH_LOCKS))
        {
            ai_AttemptToByPassLock(oCreature, oObject);
        }
    }
    // Clear our action so we can move on to something else unless the door is open.
    else if(!GetIsOpen(oObject))
    {
        ai_ClearCreatureActions();
    }
}
