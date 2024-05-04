/*//////////////////////////////////////////////////////////////////////////////
 Script: nw_ch_ac5
 Programmer: Philos
////////////////////////////////////////////////////////////////////////////////
  Associates (Summons, Familiars, Companions) OnPhysicalAttacked event script;
  Fires for all physical attacks, claws, weapons, fists, bow, etc.
  Fires for taunt skill, animal empathy skill.
*///////////////////////////////////////////////////////////////////////////////
#include "0i_associates"
void main()
{
    object oCreature = OBJECT_SELF;
    object oAttacker = GetLastAttacker();
    //ai_Debug("nw_c2_default5", "14", GetName(oCreature) + " was attacked by " +
    //         GetName(oAttacker) + ".");
    SetLocalObject (oAttacker, AI_ATTACKED_PHYSICAL, oCreature);
    if(ai_GetIsBusy(oCreature) || ai_Disabled(oCreature)) return;
    if(ai_GetIsInCombat(oCreature))
    {
        if(ai_CanIAttack(oCreature)) ai_DoAssociateCombatRound(oCreature);
        return;
    }
    // We only inform others if attacked when not busy, not disabled, & not in combat.
    SetLocalObject(oCreature, AI_MY_TARGET, oAttacker);
    SpeakString(AI_ATKED_BY_WEAPON, TALKVOLUME_SILENT_SHOUT);
    // The only way to get here is to not be in combat thus we have not
    // perceived them so lets look for them.
    if(ai_CanIAttack(oCreature)) ai_SearchForInvisibleCreature(oCreature);
}


