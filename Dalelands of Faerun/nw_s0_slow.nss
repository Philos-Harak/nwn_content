/*////////////////////////////////////////////////
 Script Name: NW_S0_Slow
 Programmer: Preston Watamaniuk
////////////////////////////////////////////////
Caster Level(s): Bard 3, Wizard / Sorcerer 3
Innate Level: 3
School: Transmutation
Component(s): Verbal, Somatic, Material
Range: Short
Area of Effect / Target: Colossal, 1 Creature / Level
Duration: 1 Round / Level
Additional Counter Spells: Haste
Save: Will Negates
Spell Resistance: Yes

All enemy creatures within the area of effect have their movement lowered by 50%
and lose a single attack per round.

Material Component
A drop of molasses.
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
    Spell.iAreaShape = SHAPE_SPHERE;
    Spell.fAreaSize = 30.0f;
    Spell.iObjectFilter = OBJECT_TYPE_CREATURE;
    Spell.iTargetType = TARGET_TYPE_ENEMIES;
    Spell.iDurationType = DURATION_TYPE_ROUNDS;
    Spell.iDuration = 1;
    Spell.iDurPerLvl = 1;
    Spell.iSpellResistance = TRUE;
    Spell.iSave = SAVING_THROW_WILL;
    Spell.iImpact = VFX_IMP_SLOW;
    // Setup the spell.
    Spell = SetSpell (Spell);
    // Check to see if we should still fire off the spell.
    if (Spell.iSpellID == STOP_SPELL) return;
    // Get the duration of the spell, sets Spell.fDuration.
    Spell = GetDuration (Spell);
    // *******************************************************************
    // ********************** Spell effects ******************************
    // *******************************************************************
    // Set iCounter so we can hit only a number of creatures = to the casters level.
    int iCounter = 0;
    // Create effect.
    effect eSlow = EffectSlow();
    // Create visual effect.
    effect eDur = EffectVisualEffect (VFX_DUR_CESSATE_NEGATIVE);
    effect eImpact = EffectVisualEffect(Spell.iImpact);
    effect eCenter = EffectVisualEffect(VFX_FNF_LOS_NORMAL_30);
    // Link effects.
    effect eLink = EffectLinkEffects (eSlow, eDur);
    // Apply visual effect at the center of the effect area.
    ApplyEffectAtLocation (DURATION_TYPE_INSTANT, eCenter, Spell.lTarget);
    // Get the spells target(s).
    Spell = GetSpellTarget (Spell);
    while (GetIsObjectValid (Spell.oAreaTarget) && iCounter <= Spell.iCasterLevel)
    {
        // Fire cast spell at event for the specified target.
        SignalEvent (Spell.oAreaTarget, EventSpellCastAt (Spell.oCaster, Spell.iSpellID));
        // Make a resistance and save check.
        Spell = ResistAndSave (Spell);
        if (!Spell.iSaveResult)
        {
            // Apply effect.
            ApplyEffectToObject (Spell.iDurationType, eLink, Spell.oAreaTarget, Spell.fDuration);
            ApplyEffectToObject (DURATION_TYPE_INSTANT, eImpact, Spell.oAreaTarget);
            // Count the number of creatures affected.
            iCounter ++;
        }
        //Get the spells target(s).
        Spell = GetSpellTarget (Spell);
    }
    CleanUpSpell (Spell);
}

