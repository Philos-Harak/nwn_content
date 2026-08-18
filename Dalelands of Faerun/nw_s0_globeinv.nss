/*////////////////////////////////////////////////
 Script: NW_S0_GlobeInv.nss
 Programmer: Preston Watamaniuk
////////////////////////////////////////////////
Abjuration
Level:  Sor/iz 6
Components: V, S, M
Casting Time:   1 standard action
Range:  10 ft.
Area:   10-ft.-radius spherical emanation, centered on you
Duration:   1 round/level (D)
Saving Throw:   None
Spell Resistance:   No

A shimmering magical sphere surrounds you and excludes all spell effects of 4rd
level or lower. Spells of 5th level and higher are not affected by the globe, nor
are spells already in effect when the globe is cast.

Material Component
A glass or crystal bead that shatters at the expiration of the spell.
/*///////////////////////////////////////////////
#include "0i_spells"

void main()
{
    // ***********************************************************
    // *************** Set Spell Structure ***********************
    // ***********************************************************
    // Setup the spell in the structured variables, then pass through the SetSpell function.
    Spell.iSubType = SUBTYPE_MAGICAL;
    Spell.sArcaneComponent = COMPONENT_POUCH;
    Spell.sEnhancingComp = "star_sapphire_dust";
    Spell.iCompAmount = 20; // 500gp worth of Star Sapphire Dust.
    Spell.iAreaShape = SHAPE_PERSONAL;
    Spell.iObjectFilter = OBJECT_TYPE_CREATURE;
    Spell.iTargetType = TARGET_TYPE_ALLIES;
    Spell.iDurationType = DURATION_TYPE_ROUNDS;
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
    int nSpellLevel = 4;
    if(Spell.sEnhancingComp == "TRUE") nSpellLevel += 2;
    // Create visual effects
    effect eVisual = EffectVisualEffect (VFX_DUR_GLOBE_INVULNERABILITY);
    effect eDuration = EffectVisualEffect (VFX_DUR_CESSATE_POSITIVE);
    // Create effects
    effect eSpell = EffectSpellLevelAbsorption(nSpellLevel, 0);
    //Link Effects
    effect eLink = EffectLinkEffects (eVisual, eSpell);
    eLink = EffectLinkEffects(eLink, eDuration);
    eLink = SetEffectCasterLevel(eLink, Spell.iCasterLevel);
    //Get the spells target(s).
    Spell = GetSpellTarget (Spell);
    while(GetIsObjectValid(Spell.oAreaTarget))
    {
        //Fire cast spell at event for the specified target
        SignalEvent (Spell.oAreaTarget, EventSpellCastAt (Spell.oCaster, Spell.iSpellID, FALSE));
        // Remove any previously cast spell on this target.
        RemoveSpellEffects (Spell.iSpellID, Spell.oAreaTarget);
        // Apply effects
        DelayCommand (Spell.fDelay, ApplyEffectToObject (Spell.iDurationType, eLink, Spell.oAreaTarget, Spell.fDuration));
        //Get the spells target(s).
        Spell = GetSpellTarget (Spell);
    }
    CleanUpSpell (Spell);
}
