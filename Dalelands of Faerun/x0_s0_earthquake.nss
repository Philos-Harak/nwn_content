/*////////////////////////////////////////////////
 Script: X0_S0_Earthquake
 Programmer: Brent
////////////////////////////////////////////////
Level:  Clr 8, Destruction 8, Drd 8, Earth 7
Components: V, S, DF
Casting Time:   1 standard action
Range:  Long (400 ft. + 40 ft./level)
Area: Current area.
Duration:   1 round
Saving Throw:   See text
Spell Resistance:   No

When you cast earthquake, an intense but highly localized tremor rips the ground.
The shock knocks creatures down on a failed reflex save and has the following effects.
Caster and all allies are not effected.
Enemies take 8d6 points of bludgeoning damage. A reflex save halves the damage and
the do not get knocked to the ground. If the failed the reflex save then they must
make a Fortitude save or die.
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
    Spell.iTargetType = TARGET_TYPE_ENEMIES;
    Spell.iSave = SAVING_THROW_REFLEX;
    Spell.iSaveHalf = TRUE;
    Spell.iDamageType = DAMAGE_TYPE_BLUDGEONING;
    Spell.iDurationType = DURATION_TYPE_ROUNDS;
    Spell.iDuration = 1;
    Spell.iDurPerLvl = 5;
    Spell.iModNumOfDice = 8;
    Spell.iModifierDie = 6;
    Spell.iImpact = VFX_IMP_HEAD_NATURE;
    // Setup the spell.
    Spell = SetSpell (Spell);
    // Check to see if we should still fire off the spell.
    if (Spell.iSpellID == STOP_SPELL) return;
    // Get the duration of the spell, sets Spell.fDuration.
    Spell = GetDuration (Spell);
    // *******************************************************************
    // ********************** Spell effects ******************************
    // *******************************************************************
    // Create variables.
    int iCounter = 1;
    object oArea = GetArea (Spell.oCaster);
    effect eDmg;
    // Create effects.
    // This is not an actual death effect thus immunity to death should not work.
    effect eDeath = SupernaturalEffect (EffectDeath ());
    effect eKnockdown = EffectKnockdown ();
    // Create visual effects.
    effect eShake = EffectVisualEffect (356); /*VFX_FNF_SCREEN_SHAKE2*/
    effect eCrack = EffectVisualEffect (VFX_FNF_SUMMON_GATE);
    effect eDuration = EffectVisualEffect (VFX_DUR_CESSATE_NEGATIVE);
    effect eImpact = EffectVisualEffect (Spell.iImpact);
    // Link effects
    effect eLink = EffectLinkEffects (eKnockdown, eDuration);
    // Do earthquake shake.
    ApplyEffectToObject (DURATION_TYPE_INSTANT, eShake, Spell.oCaster);
    //Get the area target(s).
    Spell.oAreaTarget = GetObjectInArea (oArea, iCounter, OBJECT_TYPE_CREATURE);
    while (GetIsObjectValid (Spell.oAreaTarget))
    {
        // Check for hostile creatures.
        if (GetIsSpellTargetValid (Spell.oAreaTarget, Spell.iTargetType, Spell.oCaster) && Spell.oCaster != Spell.oAreaTarget)
        {
            //Fire cast spell at event for the specified target
            SignalEvent (Spell.oAreaTarget, EventSpellCastAt (Spell.oCaster, Spell.iSpellID));
            // Get the result for the effect, sets Spell.iResult.
            Spell = GetModifier (Spell);
            // Make a save check.
            Spell = ResistAndSave (Spell);
            // Failed the save check for death.
            if (!Spell.iSaveResult)
            {
                // Make a Fort save or die.
                if (!SavingThrowWithEffects (SAVING_THROW_FORT, Spell.oAreaTarget, Spell.iSaveDC))
                {
                    DelayCommand (Spell.fDelay, ApplyEffectToObject (DURATION_TYPE_INSTANT, eCrack, Spell.oAreaTarget));
                    DelayCommand (Spell.fDelay + 3.0f, ApplyEffectToObject (DURATION_TYPE_INSTANT, eDeath, Spell.oAreaTarget));
                }
                else
                {
                    DelayCommand (Spell.fDelay, ApplyEffectToObject (Spell.iDurationType, eLink, Spell.oAreaTarget, Spell.fDuration));
                }
            }
            if (Spell.iResult > 0)
            {
                // Set the damage effect
                eDmg = EffectDamage (Spell.iResult, Spell.iDamageType);
                // Apply effect.
                DelayCommand (Spell.fDelay, ApplyEffectToObject (DURATION_TYPE_INSTANT, eDmg, Spell.oAreaTarget));
                // Apply impact effect.
                DelayCommand (Spell.fDelay, ApplyEffectToObject (DURATION_TYPE_INSTANT, eImpact, Spell.oAreaTarget));
            }
        }
        //Get the area target(s).
        iCounter ++;
        Spell.oAreaTarget = GetObjectInArea (oArea, iCounter, OBJECT_TYPE_CREATURE);
    }
    CleanUpSpell (Spell);
}
