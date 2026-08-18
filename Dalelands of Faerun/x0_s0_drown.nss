/*////////////////////////////////////////////////
 Script: X0_S0_Drown
 Programmer:Brent
////////////////////////////////////////////////
Conjuration (Creation)
Level: Druid 6,
Components: V, S,
Casting Time: 1 action
Range: Close (25 ft. + 5 ft./2 levels)
Target: One living creature
Duration: Instantaneous
Saving Throw: Fortitude negates
Spell Resistance: Yes

You create water in the lungs of the subject, which begins to drown if it fails
a fortitude save.
The subject immediately falls unconscious, dropping to 0 hp.
Undead, constructs, creatures who do not need to breathe, and creatures who can
breathe water are unaffected by this spell.
/*//////////////////////////////////////////////
#include "0i_spells"

void main()
{
    // ***********************************************************
    // *************** Set Spell Structure ***********************
    // ***********************************************************
    // Setup the spell in the structured variables, then pass through the SetSpell function.
    Spell.iSubType = SUBTYPE_MAGICAL;
    Spell.iDescriptor = DESC_WATER;
    Spell.iAreaShape = SHAPE_RANGE_TARGET;
    Spell.iObjectFilter = OBJECT_TYPE_CREATURE;
    Spell.iTargetType = TARGET_TYPE_ENEMIES;
    Spell.iDurationType = DURATION_TYPE_INSTANT;
    Spell.iSpellResistance = TRUE;
    Spell.iSave = SAVING_THROW_FORT;
    Spell.iImpact = VFX_IMP_FROST_S;
    // Setup the spell.
    Spell = SetSpell (Spell);
    // Check to see if we should still fire off the spell.
    if (Spell.iSpellID == STOP_SPELL) return;
    // *******************************************************************
    // ********************** Spell effects ******************************
    // *******************************************************************
    int nDrown;
    //Set effects.
    effect eDrown, eImpact = EffectVisualEffect (Spell.iImpact);
    //Get the spells target(s).
    Spell = GetSpellTarget (Spell);
    while(GetIsObjectValid(Spell.oAreaTarget))
    {
        //Fire cast spell at event for the specified target
        SignalEvent (Spell.oAreaTarget, EventSpellCastAt (Spell.oCaster, Spell.iSpellID));
        // Make resistance and save check.
        Spell = ResistAndSave (Spell);
        if (!Spell.iSaveResult)
        {
            // * certain racial types are immune
            if ((GetRacialType (Spell.oAreaTarget) != RACIAL_TYPE_CONSTRUCT)
                &&(GetRacialType (Spell.oAreaTarget) != RACIAL_TYPE_UNDEAD)
                &&(GetRacialType (Spell.oAreaTarget) != RACIAL_TYPE_ELEMENTAL))
            {
                nDrown = GetCurrentHitPoints (Spell.oAreaTarget) + 10;
                eDrown = EffectDamage (nDrown, DAMAGE_TYPE_MAGICAL);
                eDrown = SetEffectCasterLevel(eDrown, Spell.iCasterLevel);
                //Apply the VFX impact and damage effect
                DelayCommand (Spell.fDelay, ApplyEffectToObject (DURATION_TYPE_INSTANT, eImpact, Spell.oAreaTarget));
                DelayCommand (Spell.fDelay, ApplyEffectToObject (Spell.iDurationType, eDrown, Spell.oAreaTarget));
            }
        }
        //Get the spells target(s).
        Spell = GetSpellTarget (Spell);
    }
    CleanUpSpell (Spell);
}





