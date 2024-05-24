/*//////////////////////////////////////////////////////////////////////////////
 Script: 0e_c2_b_castat
 Programmer: Philos
////////////////////////////////////////////////////////////////////////////////
  Monster OnSpellCastAt event script;
  Fires when oCreature becomes the target of a spell via SignalEvent.
  Fires when a healing kit is used on a creature.
*///////////////////////////////////////////////////////////////////////////////
#include "0i_actions"
//#include "0i_actions_debug"
void main()
{
    object oCreature = OBJECT_SELF;
    object oCaster = GetLastSpellCaster();
    SetLocalObject(oCaster, AI_ATTACKED_SPELL, oCreature);
    if(ai_Disabled(oCreature)) return;
    if(!GetLastSpellHarmful()) return;
    // If the spell came from an ally, we don't want to hold it against them.
    if(GetFactionEqual(oCaster, oCreature))
    {
        ClearPersonalReputation(oCaster, oCreature);
    }
    // Lets see what kind of area of effect this is and select an appropriate action.
    int nSpell = GetLastSpell();
    //ai_Debug("0e_c2_b_castat", "25", GetName(oCreature) + " has been hit by a harmful spell(" +
    //      Get2DAString("spells", "Label", nSpell) + ")!");
    if(ai_GetInAOEReaction(oCreature, oCaster, nSpell) &&
       !ai_CreatureImmuneToEffect(oCaster, oCreature, nSpell))
    {
        ai_MoveOutOfAOE(oCreature, oCaster);
    }
    else if(!ai_GetIsBusy(oCreature))
    {
        // We have been attacked, so let our allies know.
        SetLocalObject(oCreature, AI_MY_TARGET, oCaster);
        SpeakString(AI_ATKED_BY_SPELL, TALKVOLUME_SILENT_TALK);
        if(ai_GetIsInCombat(oCreature))
        {
            if(ai_GetBehaviorState(NW_FLAG_BEHAVIOR_SPECIAL)) ai_DetermineSpecialBehavior(oCreature);
            else ai_DoMonsterCombatRound(oCreature);
        }
        else ai_SearchForInvisibleCreature(oCreature);
    }
    // Send the user-defined event as appropriate
    if(GetSpawnInCondition(NW_FLAG_SPELL_CAST_AT_EVENT))
    {
        SignalEvent(OBJECT_SELF, EventUserDefined(EVENT_SPELL_CAST_AT));
    }
}
