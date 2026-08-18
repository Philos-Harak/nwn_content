/*////////////////////////////////////////////////
 Script Name: x0_s0_spikegro
 Programmer: Brent
////////////////////////////////////////////////
Caster Level(s): Druid 3
Innate Level: 3
School: Transmutation
Descriptor(s):
Component(s): Verbal, Somatic, Divine Focus
Range: Long
Area of Effect / Target: Large
Duration: 1 hour / level
Additional Counter Spells:
Save: Reflex partial
Spell Resistance: Yes

Covers the terrain with small spikes. Any creature will suffer 1d4 points of
damage each round that they remain within the afflicted area. These spikes can
damage the victim's legs, so that even once they are free of the spike growth,
their movement rate is slowed for a day.
/*///////////////////////////////////////////////
#include "0i_spells"

void main()
{
    // ***********************************************************
    // *************** Set Spell Structure ***********************
    // ***********************************************************
    // Setup the spell in the structured variables, then pass through the SetSpell function.
    Spell.iSubType = SUBTYPE_MAGICAL;
    Spell.iDivineFocus = TRUE;
    Spell.iAreaShape = SHAPE_RANGE_TARGET;
    Spell.iDurationType = DURATION_TYPE_HOURS;
    Spell.iDuration = 1;
    Spell.iDurPerLvl = 1;
    // Setup the spell.
    Spell = SetSpell (Spell);
    // Check to see if we should still fire off the spell.
    if (Spell.iSpellID == STOP_SPELL) return;
    // Get the duration of the spell, sets Spell.fDuration.
    Spell = GetDuration (Spell);
    // *******************************************************************
    // ********************** Spell effects ******************************
    // *******************************************************************
    // Check to make sure we don't overlap area of effect spells.
    if (AOESpellOverlaps (Spell.lTarget, AOE_PER_ENTANGLE))
    {
        if (GetIsCharacter (Spell.oCaster)) SendMessages ("You cannot cast multiple Spike growth spells together!", COLOR_RED, Spell.oCaster);
    }
    else
    {
        // Create area of effect.
        // * passing dirge script for exit because it is an empty script (i.e., there is no special exit effects)
        effect eAOE = EffectAreaOfEffect (AOE_PER_ENTANGLE, "x0_s0_spikegroEN", "x0_s0_spikegroHB", "x0_s0_dirgeEX");
        eAOE = SetEffectCasterLevel(eAOE, Spell.iCasterLevel);
        //Create an instance of the AOE Object using the Apply Effect function
        ApplyEffectAtLocation (Spell.iDurationType, eAOE, Spell.lTarget, Spell.fDuration);
        CleanUpSpell (Spell);
    }
}


