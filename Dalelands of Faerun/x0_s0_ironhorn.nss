/*////////////////////////////////////////////////
 Script Name:x0_s0_ironhorn.nss
 Programmer: Aidan Scanlan
////////////////////////////////////////////////
Caster Level(s): Bard 1, Sorcerer/Wizard 2
Innate Level: 2
School: Transmutation
Descriptor(s): Sonic
Component(s): Verbal, Somatic
Range: Short
Area of Effect / Target: Sphere on Caster
Duration: Instantaneous
Save: None (See)
Spell Resistance: Yes

You create a deep, resonant vibration that can shake creatures off their feet as
if they were being tripped.
Make a single Strength check as if your Strength were 20.
Creatures in the area make individual opposed Dexterity or Strength checks against your roll.
Those who fail are tripped and fall prone.
Those who succeed are unaffected.
/*///////////////////////////////////////////////
#include "0i_spells"
void main()
{
    // ***********************************************************
    // *************** Set Spell Structure ***********************
    // ***********************************************************
    // Setup the spell in the structured variables, then pass through the SetSpell function.
    Spell.iSubType = SUBTYPE_MAGICAL;
    Spell.iDescriptor = DESC_SONIC;
    Spell.iAreaShape = SHAPE_SPHERE;
    Spell.fAreaSize = 20.0f;
    Spell.iLineOfSight = TRUE;
    Spell.iObjectFilter = OBJECT_TYPE_CREATURE;
    Spell.iTargetType = TARGET_TYPE_ALL;
    Spell.iDurationType = DURATION_TYPE_INSTANT;
    Spell.iSpellResistance = TRUE;
    Spell.iImpact = VFX_IMP_HEAD_NATURE;
    Spell = SetSpell (Spell);
    if (Spell.iSpellID == STOP_SPELL) return;
    // *******************************************************************
    // ********************** Spell effects ******************************
    // *******************************************************************
    int nStrCheck;
    Spell.lTarget = GetLocation (Spell.oCaster);
    effect eTrip = EffectKnockdown ();
    eTrip = SetEffectCasterLevel(eTrip, Spell.iCasterLevel);
    effect eExplode = EffectVisualEffect (VFX_FNF_HOWL_WAR_CRY);
    effect eVis = EffectVisualEffect (VFX_IMP_HEAD_NATURE);
    effect eShake = EffectVisualEffect (VFX_FNF_SCREEN_BUMP);
    // Apply visual effect to show the power of the spell.
    ApplyEffectToObject (DURATION_TYPE_TEMPORARY, eShake, Spell.oCaster, RoundsToSeconds(d3()));
    // Apply epicenter explosion on caster
    ApplyEffectAtLocation (DURATION_TYPE_INSTANT, eExplode, Spell.lTarget);
    //Get the spells target(s).
    Spell = GetSpellTarget (Spell);
    while (GetIsObjectValid (Spell.oAreaTarget))
    {
        // Does not effect the caster.
        if (Spell.oAreaTarget != Spell.oCaster)
        {
            //Fire cast spell at event for the specified target
            SignalEvent (Spell.oAreaTarget, EventSpellCastAt (Spell.oCaster, Spell.iSpellID));
            // Make a resistance and save check.
            Spell = ResistAndSave (Spell);
            if (!Spell.iSaveResult)
            {
                // Show effect on all creatures in area of effect.
                DelayCommand (Spell.fDelay, ApplyEffectToObject (DURATION_TYPE_INSTANT, eVis, Spell.oAreaTarget));
                // * DO a strength check vs. Strength 20
                nStrCheck = GetAbilityCheck (Spell.oAreaTarget, ABILITY_STRENGTH, 0, d20 () + 5, TRUE);
                if (nStrCheck < 0)
                {
                    // Apply effects to the currently selected target.
                    DelayCommand (Spell.fDelay, ApplyEffectToObject (DURATION_TYPE_TEMPORARY, eTrip, Spell.oAreaTarget, 6.0f));
                }
            }
        }
        //Get the spells target(s).
        Spell = GetSpellTarget (Spell);
    }
    CleanUpSpell (Spell);
}







