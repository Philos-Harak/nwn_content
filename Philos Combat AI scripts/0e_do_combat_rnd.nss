/*//////////////////////////////////////////////////////////////////////////////
 Script: 0e_do_combat_rnd
 Programmer: Philos
////////////////////////////////////////////////////////////////////////////////
    Used to execute a combat round just after the current action is over.
    Note: Do not use with an attack action since it will continue until
    the attacked enemy is dead. We end attack actions with a ClearAllActions
    command and would also end this one so it will not work with attack actions.
*///////////////////////////////////////////////////////////////////////////////
//#include "0i_actions"
#include "0i_actions_debug"
void main()
{
    object oCreature = OBJECT_SELF;
    //ai_Debug("0e_do_combat_rnd", "12", GetName(oCreature) + " is starting a new round.");
    if(GetAssociateType(oCreature) == ASSOCIATE_TYPE_NONE &&
       !ai_GetIsCharacter(oCreature)) ai_DoMonsterCombatRound(oCreature);
    else ai_DoAssociateCombatRound(oCreature);
}
