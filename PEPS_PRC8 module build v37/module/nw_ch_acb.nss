/*//////////////////////////////////////////////////////////////////////////////
 Script: nw_ch_acb
 Programmer: Philos
////////////////////////////////////////////////////////////////////////////////
  Associates (Summons, Familiars, Companions) OnSpellCastAt event script;
  Fires when oCreature becomes the target of a spell via SignalEvent.
  Fires when a healing kit is used on a creature.
*///////////////////////////////////////////////////////////////////////////////
#include "0i_associates"
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
        if(GetSpawnInCondition(NW_FLAG_SPELL_CAST_AT_EVENT))
        {
            SignalEvent(OBJECT_SELF, EventUserDefined(EVENT_SPELL_CAST_AT));
        }
    }
    // Lets see what kind of area of effect this is and select an appropriate action.
    int nSpell = GetLastSpell();
    if(AI_DEBUG) ai_Debug("nw_ch_acb", "21", GetName(OBJECT_SELF) + " has been hit by a harmful spell(" +
                 Get2DAString("spells", "Label", nSpell) + ")!");
    object oMaster = GetMaster(oCreature);
    if((!GetLocalInt(oMaster, AI_TARGET_MODE_ON) ||
       GetLocalObject(oMaster, AI_TARGET_MODE_ASSOCIATE) != oCreature) &&
       ai_GetInAOEReaction(oCreature, oCaster, nSpell) &&
       ai_IsInADangerousAOE(oCreature, AI_RANGE_BATTLEFIELD, TRUE)) return;
    if(ai_GetIsBusy(oCreature)) return;
    if(ai_CheckForCombat(oCreature, FALSE)) return;
    // We were attacked by an enemy out of combat, so let our allies know.
    SetLocalObject(oCreature, AI_MY_TARGET, oCaster);
    SpeakString(AI_ATKED_BY_SPELL, TALKVOLUME_SILENT_TALK);
    if(!ai_CanIAttack(oCreature)) return;
    if(GetDistanceBetween(oCreature, oCaster) < AI_RANGE_CLOSE) ai_DoAssociateCombatRound(oCreature);
    else ActionMoveToObject(oCaster, TRUE, AI_RANGE_CLOSE - 1.0);
}


