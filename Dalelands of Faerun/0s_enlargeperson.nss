/*/////////////////////////////////////////////////////////////////////////////////////////////////////
 Script Name: 0s_enlargeperson
 Programmer: Philos
//////////////////////////////////////////////////////////////////////////////////////////////////////
Transmutation
Level:  Sor/Wiz 1, Strength 1
Components: V, S, M
Casting Time:   1 round
Range:  Close (25 ft. + 5 ft./2 levels)
Target: One humanoid creature
Duration:   1 min./level (D)
Saving Throw:   Fortitude negates
Spell Resistance:   Yes

This spell causes instant growth of a humanoid creature, doubling its height and
multiplying its weight by 8. This increase changes the creature�s size category
to the next larger one. The target gains a +2 size bonus to Strength, a -2 size
penalty to Dexterity (to a minimum of 1), and a -1 penalty on attack rolls and
AC due to its increased size.

Enlarge person counters and dispels reduce person.
Material Component: A pinch of powdered iron.
*/////////////////////////////////////////////////////////////////////////////////////////////////////
#include "0i_spells"

void main()
{
    // ***********************************************************
    // *************** Set Spell Structure ***********************
    // ***********************************************************
    // Setup the spell in the structured variables, then pass through the SetSpell function.
    Spell.iSubType = SUBTYPE_MAGICAL;
    Spell.iAreaShape = SHAPE_RANGE_TARGET;
    Spell.iTargetType = TARGET_TYPE_ALL;
    Spell.iObjectFilter = OBJECT_TYPE_CREATURE;
    Spell.sArcaneComponent = COMPONENT_POUCH;
    Spell.iDurationType = DURATION_TYPE_MINUTES;
    Spell.iDuration = 1;
    Spell.iDurPerLvl = 1;
    Spell.iSave = SAVING_THROW_FORT;
    Spell.iSpellResistance = TRUE;
    // Setup the spell.
    Spell = SetSpell (Spell);
    // Check to see if we should still fire off the spell.
    if (Spell.iSpellID == STOP_SPELL) return;
    // Get the duration of the spell.
    Spell = GetDuration (Spell);
    // *******************************************************************
    // ********************** Spell effects ******************************
    // *******************************************************************
    effect eStr = EffectAbilityIncrease (ABILITY_STRENGTH, 2);
    effect eDex = EffectAbilityDecrease (ABILITY_DEXTERITY, 2);
    effect eAC =  EffectACDecrease (1);
    effect eAttack = EffectAttackDecrease (1);
    effect eImpact = EffectVisualEffect (VFX_IMP_MAGBLUE);
    effect eLink = EffectLinkEffects(eStr, eDex);
    eLink = EffectLinkEffects (eLink, eAC);
    eLink = EffectLinkEffects (eLink, eAttack);
    eLink = SetEffectCasterLevel(eLink, Spell.iCasterLevel);
    //Get the spells target(s).
    Spell = GetSpellTarget (Spell);
    while(GetIsObjectValid(Spell.oAreaTarget))
    {
        // Now has this been cast at an enemy?
        if (GetIsEnemy (Spell.oAreaTarget, Spell.oCaster))
        {
            // Make a resistance and save check.
            Spell = ResistAndSave (Spell);
            if (!Spell.iSaveResult)
            {
                // If the spell does not then set the spell as hostile and continue.
                //Fire cast spell at event for the specified target
                SignalEvent (Spell.oAreaTarget, EventSpellCastAt (Spell.oCaster, Spell.iSpellID, TRUE));
            }
        }
        // Not a hostile creature so set the spell as not hostile.
        //Fire cast spell at event for the specified target
        else
        {
            SignalEvent (Spell.oAreaTarget, EventSpellCastAt (Spell.oCaster, Spell.iSpellID, FALSE));
            Spell.iSaveResult = 0;
        }
        // If enemy fails save or it is friendly then do the effect.
        if (Spell.iSaveResult == 0)
        {
            //Apply the VFX impact and effects
            DelayCommand (Spell.fDelay, ApplyEffectToObject (DURATION_TYPE_TEMPORARY, eLink, Spell.oAreaTarget, Spell.fDuration));
            DelayCommand (Spell.fDelay, ApplyEffectToObject (DURATION_TYPE_INSTANT, eImpact, Spell.oAreaTarget));
            // Now enlarge the creature.
            ChangeSize (Spell.oAreaTarget, 1.5f);
            // At the end of the effect reduce back to normal size.
            DelayCommand (Spell.fDelay + Spell.fDuration + 0.1f, ChangeSize (Spell.oAreaTarget, 1.0f));
        }
        //Get the spells target(s).
        Spell = GetSpellTarget (Spell);
    }
    CleanUpSpell (Spell);
}
