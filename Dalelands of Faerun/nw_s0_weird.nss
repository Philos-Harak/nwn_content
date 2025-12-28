/*////////////////////////////////////////////////
 Script: NW_S0_Weird
 Programmer: Preston Watamaniuk
////////////////////////////////////////////////
Illusion (Phantasm) [Fear, Mind-Affecting]
Level:  Sor/Wiz 9
Components: V, S
Casting Time:   1 standard action
Range:  Medium (100 ft. + 10 ft./level)
Target: 30' sphere
Duration:   Instantaneous
Saving Throw:   Will disbelief (if interacted with), then Fortitude partial; see text
Spell Resistance:   Yes

You create a phantasmal image of the most fearsome creature imaginable to the
subjects simply by forming the fears of the subject’s subconscious mind into
something that its conscious mind can visualize: this most horrible beast.
Only the spell’s subjects can see the phantasmal killer. You see only a vague
shape. The target first gets a Will save to recognize the image as unreal. If
that save fails, the phantasm touches the subject, and the subject must succeed
on a Fortitude save or die from fear. Even if the Fortitude save is successful,
the subject takes 3d6 points of damage and 1d4 strength damage.
/*///////////////////////////////////////////////
#include "0i_spells"
void main()
{
    // ***********************************************************
    // *************** Set Spell Structure ***********************
    // ***********************************************************
    // Setup the spell in the structured variables, then pass through the SetSpell function.
    Spell.iSubType = SUBTYPE_MAGICAL;
    Spell.iSubSchool = SUBSCHOOL_PHANTASM;
    Spell.iDescriptor = DESC_MIND;
    Spell.iAreaShape = SHAPE_RANGE_TARGET;
    Spell.fAreaSize = 30.0f;
    Spell.iLineOfSight = TRUE;
    Spell.iObjectFilter = OBJECT_TYPE_CREATURE;
    Spell.iTargetType = TARGET_TYPE_ENEMIES;
    Spell.iDurationType = DURATION_TYPE_INSTANT;
    Spell.iSpellResistance = TRUE;
    Spell.iSave = SAVING_THROW_WILL;
    Spell.iSaveType = SAVING_THROW_TYPE_MIND_SPELLS;
    Spell.iModNumOfDice = 3;
    Spell.iModifierDie = 6;
    Spell.iImpact = VFX_IMP_SONIC;
    // Setup the spell.
    Spell = SetSpell (Spell);
    // Check to see if we should still fire off the spell.
    if (Spell.iSpellID == STOP_SPELL) return;
    // *******************************************************************
    // ********************** Spell effects ******************************
    // *******************************************************************
    // Declare variables
    effect eDmg;
    // Create effects.
    // This is not an actual death effect thus immunity to death should not work.
    effect eDeath = SupernaturalEffect (EffectDeath());
    // Create visual effects
    effect eImpact = EffectVisualEffect (Spell.iImpact);
    effect eCenter = EffectVisualEffect(VFX_FNF_WEIRD);
    //Apply the spells center effect.
    ApplyEffectAtLocation (DURATION_TYPE_INSTANT, eCenter, Spell.lTarget);
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
            // Immunity to fear, makes you immune to Phantasmal Killer.
            if (!GetIsImmune (Spell.oAreaTarget, IMMUNITY_TYPE_FEAR))
            {
                // Make a Fort save and take damage.
                if (SavingThrowWithEffects (SAVING_THROW_FORT, Spell.oAreaTarget, Spell.iSaveDC))
                {
                     // Get the result for the effect, sets Spell.iResult.
                     Spell = GetModifier (Spell);
                     //Set the damage property
                     eDmg = EffectDamage (Spell.iResult, DAMAGE_TYPE_MAGICAL);
                     // Apply effects
                     DelayCommand (Spell.fDelay, ApplyEffectToObject (DURATION_TYPE_INSTANT, eDmg, Spell.oAreaTarget));
                     DelayCommand (Spell.fDelay, ApplyEffectToObject (DURATION_TYPE_INSTANT, eImpact, Spell.oAreaTarget));
                }
                // Failed the save and die!
                else
                {
                     // Apply the death effect and VFX impact
                     DelayCommand (Spell.fDelay, ApplyEffectToObject (DURATION_TYPE_INSTANT, eDeath, Spell.oAreaTarget));
                }
            }
        }
        //Get the spells target(s).
        Spell = GetSpellTarget (Spell);
    }
    CleanUpSpell (Spell);
}
