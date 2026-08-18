/*////////////////////////////////////////////////
 Script: nw_s0_bladebar
 Programmer: Preston Watamaniuk
////////////////////////////////////////////////
Evocation [Force]
Level:  Clr 6, Good 6, War 6
Components: V, S
Casting Time:   1 standard action
Range:  Medium (100 ft. + 10 ft./level)
Effect: Wall of whirling blades up to 20 ft
Duration:   1 min./level (D)
Saving Throw:   Reflex half or Reflex negates; see text
Spell Resistance:   Yes

An immobile, vertical curtain of whirling blades shaped of pure force springs
into existence. Any creature passing through the wall takes 1d6 points of damage
per caster level (maximum 15d6), with a Reflex save for half damage.
/*///////////////////////////////////////////////
#include "0i_spells"

void main()
{
    // ***********************************************************
    // *************** Set Spell Structure ***********************
    // ***********************************************************
    // Setup the spell in the structured variables, then pass through the SetSpell function.
    Spell.iSubType = SUBTYPE_MAGICAL;
    Spell.iDurationType = DURATION_TYPE_MINUTES;
    Spell.iDuration = 1;
    Spell.iDurPerLvl = 1;
    // Setup the spell.
    Spell = SetSpell (Spell);
    // Check to see if we should still fire off the spell.
    if (Spell.iSpellID == STOP_SPELL) return;
    // Get the duration of the spell.
    Spell = GetDuration (Spell);
    // *******************************************************************
    // ********************** Spell effects ******************************
    // *******************************************************************
    // Check to make sure we don't overlap area of effect spells.
    if (AOESpellOverlaps (Spell.lTarget, AOE_PER_WALLBLADE))
    {
        if (GetIsCharacter (Spell.oCaster)) SendMessages ("You cannot cast multiple Blade barrier spells together!", COLOR_RED, Spell.oCaster);
    }
    else
    {
        // Create effect.
        effect eAOE = EffectAreaOfEffect (AOE_PER_WALLBLADE);
        eAOE = SetEffectCasterLevel(eAOE, Spell.iCasterLevel);
        // Create an instance of the AOE Object using the Apply Effect function
        ApplyEffectAtLocation (Spell.iDurationType, eAOE, Spell.lTarget, Spell.fDuration);
        CleanUpSpell (Spell);
    }
}

