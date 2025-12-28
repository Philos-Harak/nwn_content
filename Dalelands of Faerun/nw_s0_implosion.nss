/*///////////////////////////////////////////////
 Script: NW_S0_Implosion.nss
 Programmer: Preston Watamaniuk
////////////////////////////////////////////////
Evocation
Level: 	Clr 9, Destruction 9
Components:	V, S
Casting Time:	1 standard action
Range: Short
Targets: Medium
Duration:Instant
Saving Throw: 	Fortitude negates
Spell Resistance: 	Yes

You create a destructive resonance in a corporeal creature’s body.
All creatures within the area of effect are imploded into a central vortex of
destruction that kills them instantly.

Implosion has no effect on creatures in gaseous form or on incorporeal creatures.
/*//////////////////////////////////////////////////////
#include "0i_spells"
void main()
{
    // ***********************************************************
    // *************** Set Spell Structure ***********************
    // ***********************************************************
    // Setup the spell in the structured variables, then pass through the SetSpell function.
    Spell.iSubType = SUBTYPE_MAGICAL;
    Spell.iDescriptor = DESC_DEATH;
    Spell.iAreaShape = SHAPE_SPHERE;
    Spell.fAreaSize = 10.0f;
    Spell.iObjectFilter = OBJECT_TYPE_CREATURE;
    Spell.iTargetType = TARGET_TYPE_ALL;
    Spell.iSpellResistance = TRUE;
    Spell.iSave = SAVING_THROW_FORT;
    Spell.iSaveType = SAVING_THROW_TYPE_DEATH;
    Spell.iImpact = VFX_IMP_DEATH_L;
    // Setup the spell.
    Spell = SetSpell (Spell);
    // Check to see if we should still fire off the spell.
    if (Spell.iSpellID == STOP_SPELL) return;
    // *******************************************************************
    // ********************** Spell effects ******************************
    // *******************************************************************
    effect eImpact = EffectVisualEffect (Spell.iImpact);
    effect eDeath = EffectDeath (TRUE);
    eDeath = SupernaturalEffect (eDeath);
    effect eCenter = EffectVisualEffect(VFX_FNF_IMPLOSION);
    // Apply visual effect at the center of the effect area.
    ApplyEffectAtLocation (DURATION_TYPE_INSTANT, eCenter, Spell.lTarget);
    //Get the spells target(s).
    Spell = GetSpellTarget (Spell);
    while (GetIsObjectValid (Spell.oAreaTarget))
    {
        //Fire cast spell at event for the specified target
        SignalEvent (Spell.oAreaTarget, EventSpellCastAt (Spell.oCaster, Spell.iSpellID));
        // Make resistance and save check.
        Spell = ResistAndSave (Spell);
        if (!Spell.iSaveResult)
        {
            //Create an instance of the AOE Object using the Apply Effect function
            DelayCommand (Spell.fDelay, ApplyEffectToObject (DURATION_TYPE_INSTANT, eImpact, Spell.oAreaTarget));
            DelayCommand (Spell.fDelay, ApplyEffectToObject (DURATION_TYPE_INSTANT, eDeath, Spell.oAreaTarget));
        }
        //Get the spells target(s).
        Spell = GetSpellTarget (Spell);
    }
    CleanUpSpell (Spell);
}

