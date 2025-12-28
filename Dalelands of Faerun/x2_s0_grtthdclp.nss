/*////////////////////////////////////////////////
 Script: X2_S0_GrtThdclp
 Programmer: Andrew Nobbs
////////////////////////////////////////////////
Caster Level(s): Wizard / Sorcerer 7
Innate Level: 7
School: Evocation
Descriptor(s): Sonic
Component(s): Verbal, Somatic
Range: Medium
Area of Effect: 30' area
Duration: Instantaneous
Save: See Below
Spell Resistance: No

You create a loud noise equivalent to a peal of thunder and its accompanying
shock wave. The spell has three effects. First, all creatures in the area must
make Will saves to avoid being stunned for 1d4 rounds. Second, the creatures must
take 1d6 per level (max 15d6) sonic damage, save vs Fortitude to take half damage.
Third, they must make Reflex save or fall prone.
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
    Spell.fAreaSize = 30.0f;
    Spell.iTargetType = TARGET_TYPE_ALL;
    Spell.iObjectFilter = OBJECT_TYPE_CREATURE;
    Spell.iDurationType = DURATION_TYPE_ROUNDS;
    Spell.iDurNumOfDice = 1;
    Spell.iDurationDie = 4;
    Spell.iDamageType = DAMAGE_TYPE_SONIC;
    Spell.iModNumOfDice = 1;
    Spell.iModifierDie = 4;
    Spell.iModDicePerLvl = 1;
    Spell.iMaxModNumOfDice = 5;
    Spell.iImpact = VFX_IMP_SONIC;
    // Setup the spell.
    Spell = SetSpell (Spell);
    // Check to see if we should still fire off the spell.
    if (Spell.iSpellID == STOP_SPELL) return;
    // Get the duration of the spell.
    Spell = GetDuration (Spell);
    // *******************************************************************
    // ********************** Spell effects ******************************
    // *******************************************************************
    // Create visual effects.
    effect eImpact = EffectVisualEffect(Spell.iImpact);
    effect eCenter = EffectVisualEffect (VFX_FNF_MYSTICAL_EXPLOSION);
    effect eVStun = EffectVisualEffect (VFX_IMP_STUN);
    // Create effects.
    effect eDmg;
    effect eKnock = EffectKnockdown();
    effect eStun = EffectStunned();
    effect eShake = EffectVisualEffect (356); /*VFX_FNF_SCREEN_SHAKE2*/
    // Apply center vfx effect.
    ApplyEffectAtLocation (DURATION_TYPE_INSTANT, eCenter, Spell.lTarget);
    ApplyEffectToObject (DURATION_TYPE_TEMPORARY, eShake, Spell.oCaster, 2.0f);
    //Get the spells target(s).
    Spell = GetSpellTarget (Spell);
    while(GetIsObjectValid(Spell.oAreaTarget))
    {
        // Shake all creatures within the spell effect.
        ApplyEffectToObject (DURATION_TYPE_TEMPORARY, eShake, Spell.oAreaTarget, 2.0f);
        // Does not effect the caster.
        if (Spell.oCaster != Spell.oAreaTarget)
        {
            //Fire cast spell at event for the specified target
            SignalEvent (Spell.oAreaTarget, EventSpellCastAt (Spell.oCaster, Spell.iSpellID));
            DelayCommand(Spell.fDelay, ApplyEffectToObject (Spell.iDurationType, eImpact, Spell.oAreaTarget,4.0f));
            // Get the result for the effect, sets Spell.iResult.
            Spell = GetModifier (Spell);
            if (SavingThrowWithEffects (SAVING_THROW_FORT, Spell.oAreaTarget, Spell.iSaveDC, SAVING_THROW_TYPE_SONIC))
            {
                // Made the save and take 1/2 dmg.
                Spell.iResult = Spell.iResult / 2;
            }
            eDmg =  EffectDamage (Spell.iResult, Spell.iDamageType);
            DelayCommand(Spell.fDelay, ApplyEffectToObject (DURATION_TYPE_INSTANT, eDmg, Spell.oAreaTarget, Spell.fDuration * 10.0f));
            if (SavingThrowWithEffects (SAVING_THROW_WILL, Spell.oAreaTarget, Spell.iSaveDC, SAVING_THROW_TYPE_SONIC))
            {
                DelayCommand(Spell.fDelay, ApplyEffectToObject (Spell.iDurationType, eStun, Spell.oAreaTarget, Spell.fDuration));
                DelayCommand(Spell.fDelay, ApplyEffectToObject (DURATION_TYPE_INSTANT, eVStun, Spell.oAreaTarget));
            }
            if (!SavingThrowWithEffects (SAVING_THROW_REFLEX, Spell.oAreaTarget, Spell.iSaveDC, SAVING_THROW_TYPE_SONIC))
            {
                DelayCommand(Spell.fDelay, ApplyEffectToObject (Spell.iDurationType, eKnock, Spell.oAreaTarget, 6.0f));
            }
        }
        //Get the spells target(s).
        Spell = GetSpellTarget (Spell);
    }
    CleanUpSpell (Spell);
}
