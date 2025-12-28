/*//////////////////////////////////////////////////////////////////////////////
 Deathless Master Touch
 X2_S2_dthmsttch
 Created By: Georg Zoeller updated by Philos
////////////////////////////////////////////////////////////////////////////////
 Pale Master may use their undead arm to kill their foes.
 - Requires melee Touch attack
 - Save vs Fortitude DC 10 + Palemaster level to resist

    Epic:
    -SaveDC raised by +1 for each 2 levels past 10th
/*//////////////////////////////////////////////////////////////////////////////
#include "0i_specialevents"
#include "nwnx_creature"
#include "0i_spells"
#include "0i_s_message"
void AnimateCreature(object oCaster, object oCreature)
{
    effect eImpact = EffectVisualEffect(VFX_IMP_HARM);
    ApplyEffectToObject(DURATION_TYPE_INSTANT, eImpact, oCreature);
    effect eRise = EffectResurrection();
    ApplyEffectToObject(DURATION_TYPE_INSTANT, eRise, oCreature);
    NWNX_Creature_SetRacialType(oCreature, RACIAL_TYPE_UNDEAD);
    effect eImmune = EffectImmunity(IMMUNITY_TYPE_CRITICAL_HIT);
    eImmune = EffectLinkEffects(eImmune, EffectImmunity(IMMUNITY_TYPE_CHARM));
    eImmune = EffectLinkEffects(eImmune, EffectImmunity(IMMUNITY_TYPE_CONFUSED));
    eImmune = EffectLinkEffects(eImmune, EffectImmunity(IMMUNITY_TYPE_DAZED));
    eImmune = EffectLinkEffects(eImmune, EffectImmunity(IMMUNITY_TYPE_DISEASE));
    eImmune = EffectLinkEffects(eImmune, EffectImmunity(IMMUNITY_TYPE_FEAR));
    eImmune = EffectLinkEffects(eImmune, EffectImmunity(IMMUNITY_TYPE_MIND_SPELLS));
    eImmune = EffectLinkEffects(eImmune, EffectImmunity(IMMUNITY_TYPE_POISON));
    eImmune = UnyieldingEffect(eImmune);
    ApplyEffectToObject(DURATION_TYPE_PERMANENT, eImmune, oCreature);
    int nClassLevel = GetTotalUndeadControlledHitDice(oCaster);
    if(!IncreaseUndeadControlledHitDice(oCaster, oCreature, "TURNED_UNDEAD", nClassLevel))
    {
        ChangeToStandardFaction(oCreature, STANDARD_FACTION_DEFENDER);
    }
    else
    {
        SendMessages(GetName(oCreature) + "Rises under your control!", COLOR_GREEN, oCaster);
        // Save to creature so we know the variable to adjust for controlled undead.
        SetLocalString(oCreature, "0_SUMMON_SPELL", "TURNED_UNDEAD");
        AddHenchman(oCaster, oCreature);
        MyrkulSetCheck(oCaster, oCreature);
    }
    // Must mark them as a summons.
    SetLocalInt (oCreature, "0_Summon_ID", TRUE);
    SetEventScript (oCreature, EVENT_SCRIPT_CREATURE_ON_BLOCKED_BY_DOOR, "nw_ch_ace");
    SetEventScript (oCreature, EVENT_SCRIPT_CREATURE_ON_END_COMBATROUND, "nw_ch_ac3");
    SetEventScript (oCreature, EVENT_SCRIPT_CREATURE_ON_DIALOGUE, "nw_ch_ac4");
    SetEventScript (oCreature, EVENT_SCRIPT_CREATURE_ON_DAMAGED, "nw_ch_ac5");
    SetEventScript (oCreature, EVENT_SCRIPT_CREATURE_ON_DEATH, "nw_ch_ac7");
    SetEventScript (oCreature, EVENT_SCRIPT_CREATURE_ON_DISTURBED, "nw_ch_ac8");
    SetEventScript (oCreature, EVENT_SCRIPT_CREATURE_ON_HEARTBEAT, "nw_ch_ac1");
    SetEventScript (oCreature, EVENT_SCRIPT_CREATURE_ON_NOTICE, "nw_ch_ac2");
    SetEventScript (oCreature, EVENT_SCRIPT_CREATURE_ON_MELEE_ATTACKED, "nw_ch_ac5");
    SetEventScript (oCreature, EVENT_SCRIPT_CREATURE_ON_RESTED, "nw_ch_ac9");
    SetEventScript (oCreature, EVENT_SCRIPT_CREATURE_ON_SPAWN_IN, "nw_ch_acani9");
    SetEventScript (oCreature, EVENT_SCRIPT_CREATURE_ON_SPELLCASTAT, "nw_ch_acb");
}
void main()
{
    object oCaster = OBJECT_SELF;
    object oTarget = GetSpellTargetObject();
    if(GetCreatureSize(oTarget) > CREATURE_SIZE_LARGE)
    {
        if(GetIsCharacter(oCaster))
        {
            SendMessages(GetName(oTarget) + " is to large to affected by your death attack!", COLOR_RED, oCaster);
        }
        return;
    }
    effect eSlay = EffectDeath();
    effect eVis = EffectVisualEffect(VFX_IMP_NEGATIVE_ENERGY);
    effect eVis2 = EffectVisualEffect(VFX_IMP_DEATH);
    int nLevel = GetLevelByClass(CLASS_TYPE_PALEMASTER, oCaster);
    int nSave = 10 + nLevel;
    if(TouchAttackMelee(oTarget, TRUE) > 0)
    {
        SignalEvent(oTarget, EventSpellCastAt(OBJECT_SELF, 624));
        if(!FortitudeSave(oTarget, nSave, SAVING_THROW_TYPE_DEATH))
        {
            // Non-player creatures will rise under the palemasters power!
            if(!GetIsCharacter(oTarget)) DelayCommand(6.0, AnimateCreature(oCaster, oTarget));
            ApplyEffectToObject(DURATION_TYPE_INSTANT, eVis, oTarget);
            ApplyEffectToObject(DURATION_TYPE_INSTANT, eSlay, oTarget);
            ApplyEffectToObject(DURATION_TYPE_INSTANT, eVis2, oTarget);

        }
   }
}
