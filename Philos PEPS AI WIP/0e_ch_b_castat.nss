/*//////////////////////////////////////////////////////////////////////////////
 Script: 0e_ch_b_castat
 Programmer: Philos
////////////////////////////////////////////////////////////////////////////////
  Associates (Summons, Familiars, Companions) OnSpellCastAt event script;
  Fires when oCreature becomes the target of a spell via SignalEvent.
  Fires when a healing kit is used on a creature.
*///////////////////////////////////////////////////////////////////////////////
#include "0i_associates"
//#include "0i_assoc_debug"
void main()
{
    object oCreature = OBJECT_SELF;
    object oCaster = GetLastSpellCaster();
    SetLocalObject(oCaster, AI_ATTACKED_SPELL, oCreature);
    if(ai_Disabled(oCreature)) return;
    if(!GetLastSpellHarmful()) return;
    // If the spell came from an ally, we don't want to hold it against them.
    if(GetFactionEqual(oCaster, oCreature)) ClearPersonalReputation(oCaster, oCreature);
    // Lets see what kind of area of effect this is and select an appropriate action.
    int nSpell = GetLastSpell();
    //ai_Debug("0e_ch_b_castat", "22", GetName(OBJECT_SELF) + " has been hit by a harmful spell(" +
    //       Get2DAString("spells", "Label", nSpell) + ")!");
    if(ai_GetInAOEReaction(oCreature, oCaster, nSpell) &&
       !ai_CreatureImmuneToEffect(oCaster, oCreature, nSpell))
    {
        ai_MoveOutOfAOE(oCreature, oCaster);
        return;
    }
    if(ai_GetIsBusy(oCreature)) return;
    if(ai_CheckForCombat(oCreature)) return;
    // We were attacked by an enemy out of combat, so let our allies know.
    SetLocalObject(oCreature, AI_MY_TARGET, oCaster);
    SpeakString(AI_ATKED_BY_SPELL, TALKVOLUME_SILENT_SHOUT);
    if(!ai_CanIAttack(oCreature)) return;
    if(GetDistanceBetween(oCreature, oCaster) < AI_RANGE_CLOSE) ai_DoAssociateCombatRound(oCreature);
    else ActionMoveToObject(oCaster, TRUE, AI_RANGE_CLOSE - 1.0);
}


