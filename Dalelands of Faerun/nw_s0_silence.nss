/*////////////////////////////////////////////////
 Script: NW_S0_Silence
 Programmer: Preston Watamaniuk
////////////////////////////////////////////////
Illusion (Glamer)
Level:  Brd 2, Clr 2
Components: V, S
Casting Time:   1 standard action
Range:  Long (400 ft. + 40 ft./level)
Area:   20-ft.-radius emanation centered on a creature, object, or point in space
Duration:   1 min./level (D)
Saving Throw:   Will negates; see text or none (object)
Spell Resistance:   Yes; see text or no (object)

Upon the casting of this spell, complete silence prevails in the affected area.
All sound is stopped: Conversation is impossible, spells with verbal components
cannot be cast, and no noise whatsoever issues from, enters, or passes through
the area. The spell can be cast on a point in space, but the effect is stationary
unless cast on a mobile object. The spell can be centered on a creature, and the
effect then radiates from the creature and moves as it moves. An unwilling creature
can attempt a Will save to negate the spell and can use spell resistance, if any.

/*///////////////////////////////////////////////
#include "0i_spells"

void main()
{
    // ***********************************************************
    // *************** Set Spell Structure ***********************
    // ***********************************************************
    // Setup the spell in the structured variables, then pass through the SetSpell function.
    Spell.iSubType = SUBTYPE_MAGICAL;
    Spell.iSubSchool = SUBSCHOOL_GLAMER;
    Spell.iDurationType = DURATION_TYPE_MINUTES;
    Spell.iDuration = 1;
    Spell.iDurPerLvl = 1;
    Spell.iSpellResistance = TRUE;
    Spell.iSave = SAVING_THROW_WILL;
    // Setup the spell.
    Spell = SetSpell (Spell);
    // Check to see if we should still fire off the spell.
    if (Spell.iSpellID == STOP_SPELL) return;
    // Get the duration of the spell, sets Spell.fDuration.
    Spell = GetDuration (Spell);
    // *******************************************************************
    // ********************** Spell effects ******************************
    // *******************************************************************
    // Create effect.
    effect eAOE = EffectAreaOfEffect(AOE_MOB_SILENCE);
    eAOE = SetEffectCasterLevel(eAOE, Spell.iCasterLevel);
    // Check to see if the target is hostile.
    if (GetIsEnemy (Spell.oTarget, Spell.oCaster))
    {
        // Make resistance and save check.
        Spell = ResistAndSave (Spell);
        if (!Spell.iSaveResult)
        {
            // Fire cast spell at event for the specified target
            SignalEvent(Spell.oTarget, EventSpellCastAt (Spell.oCaster, Spell.iSpellID));
            // Create an instance of the AOE Object using the Apply Effect function
            ApplyEffectToObject (Spell.iDurationType, eAOE, Spell.oTarget, Spell.fDuration);
        }
    }
    // Else we are casting it on an ally.
    else
    {
        //Fire cast spell at event for the specified target
        SignalEvent (Spell.oTarget, EventSpellCastAt (Spell.oCaster, Spell.iSpellID, FALSE));
        //Create an instance of the AOE Object using the Apply Effect function
        ApplyEffectToObject (Spell.iDurationType, eAOE, Spell.oTarget, Spell.fDuration);
    }
    CleanUpSpell (Spell);
}

