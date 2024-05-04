/*//////////////////////////////////////////////////////////////////////////////
 Script: nw_c2_default5
 Programmer: Philos
////////////////////////////////////////////////////////////////////////////////
  Monster OnPhysicalAttacked event script;
  Fires for all physical attacks, claws, weapons, fists, bow, etc.
  Fires for taunt skill, animal empathy skill.
*///////////////////////////////////////////////////////////////////////////////
#include "0i_actions"
//#include "0i_actions_debug"
void main()
{
    object oCreature = OBJECT_SELF;
    object oAttacker = GetLastAttacker(oCreature);
    //ai_Debug("nw_c2_default5", "15", GetName(oCreature) + " was attacked by " +
    //         GetName(oAttacker) + ".");
    SetLocalObject(oAttacker, AI_ATTACKED_PHYSICAL, oCreature);
    if(ai_GetIsBusy(oCreature) || ai_Disabled(oCreature)) return;
    if(ai_GetIsInCombat(oCreature))
    {
        ai_DoMonsterCombatRound(oCreature);
        return;
    }
    // We only inform others if attacked when not busy, not disabled & not in combat.
    //ai_Debug("nw_c2_default5", "25", "Tell my allies I've been attacked!");
    SetLocalObject (oCreature, AI_MY_TARGET, oAttacker);
    SpeakString(AI_ATKED_BY_WEAPON, TALKVOLUME_SILENT_TALK);
    // The only way to get here is to not be in combat thus we have not
    // perceived them so lets look for them.
    ai_SearchForInvisibleCreature (oCreature);
}
