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
    if(AI_DEBUG) ai_Debug("nw_ch_ac5", "14", GetName(oCreature) + " was attacked by " +
                 GetName(oAttacker) + ".");
    SetLocalObject(oAttacker, AI_ATTACKED_PHYSICAL, oCreature);
    if(ai_GetIsBusy(oCreature) || ai_Disabled(oCreature)) return;
    if(GetSpawnInCondition(NW_FLAG_ATTACK_EVENT))
    {
        SignalEvent(OBJECT_SELF, EventUserDefined(1005));
    }
    if(ai_GetIsInCombat(oCreature)) return;
    // We only inform others if attacked when not busy, not disabled, & not in combat.
    SetLocalObject(oCreature, AI_MY_TARGET, oAttacker);
    SpeakString(AI_ATKED_BY_WEAPON, TALKVOLUME_SILENT_TALK);
    // If they are using a melee weapon then make sure we are using our perception range.
    // Don't go running towards them just yet, but if its a ranged weapon then react.
    if(ai_GetIsMeleeWeapon(GetItemInSlot(INVENTORY_SLOT_RIGHTHAND, oAttacker)))
    {
        float fDistance = GetDistanceBetween(oCreature, oAttacker);
        float fPerceptionDistance = GetLocalFloat(oCreature, AI_ASSOC_PERCEPTION_DISTANCE);
        if(fDistance > fPerceptionDistance) return;
    }
    int nAction = GetCurrentAction(oCreature);
    float fDistance = GetDistanceBetween(oCreature, oAttacker);
    if(!ai_CanIAttack(oCreature))
    {
        // We should defend ourselves if we are in Hold mode.
        if(!ai_GetAIMode(oCreature, AI_MODE_STAND_GROUND)) return;
        // Only defend against melee attacks.
        if(fDistance > AI_RANGE_MELEE) return;
    }
    // The only way to get here is to not be in combat.
    if(fDistance < AI_RANGE_CLOSE)
    {
        ai_StartAssociateCombat(oCreature);
    }
    else ActionMoveToObject(oAttacker, TRUE, AI_RANGE_CLOSE - 1.0);
}


