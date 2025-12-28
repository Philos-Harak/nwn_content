/*////////////////////////////////////////////////
 Script:NW_S0_PrisSpray
 Programmer: Preston Watamaniuk
////////////////////////////////////////////////
Evocation
Level:  Sor/Wiz 7
Components: V, S
Casting Time:   1 standard action
Range:  60 ft.
Area:   Cone-shaped burst
Duration:   Instantaneous
Saving Throw:   See text
Spell Resistance:   Yes

This spell causes seven shimmering, intertwined, multicolored beams of light to
spray from your hand. Each beam has a different power. Creatures in the area of
the spell with 8 HD or less are automatically blinded for 2d4 rounds. Every
creature in the area is randomly struck by one or more beams, which have
additional effects.

1d8   Color     Effect
1     Red       20 points fire damage (Reflex half)
2     Orange  40 points acid damage (Reflex half)
3     Yellow  80 points electricity damage (Reflex half)
4     Green   Poison (DC:20, Take Constitution damage)
5     Blue    Turned to stone (Fortitude negates)
6     Indigo  Insane, as insanity spell (Will negates)
7     Violet  Death (Will negates)
8     Struck by two rays; roll twice more, ignoring any “8” result.
/*/////////////////////////////////////////////////////////////////////////////
int GetPrismaticEffect (int iEffect, struct stSpell Spell);
#include "0i_spells"
void main()
{
    // ***********************************************************
    // *************** Set Spell Structure ***********************
    // ***********************************************************
    // Setup the spell in the structured variables, then pass through the SetSpell function.
    Spell.iSubType = SUBTYPE_MAGICAL;
    Spell.iAreaShape = SHAPE_SPELLCONE;
    Spell.fAreaSize = 60.0f;
    Spell.iLineOfSight = TRUE;
    Spell.iObjectFilter = OBJECT_TYPE_CREATURE | OBJECT_TYPE_DOOR | OBJECT_TYPE_PLACEABLE;
    Spell.iTargetType = TARGET_TYPE_ALL;
    Spell.iDurationType = DURATION_TYPE_ROUNDS;
    Spell.iDurNumOfDice = 2;
    Spell.iDurationDie = 4;
    Spell.iSpellResistance = TRUE;
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
    int iRoll, iHitDice, iImpact1, iImpact2, iReroll;
    effect eDmg, eImpact;
    // Create effects.
    effect eBlind = EffectBlindness ();
    //Get the spells target(s).
    Spell = GetSpellTarget (Spell);
    while (GetIsObjectValid (Spell.oAreaTarget))
    {
        //Fire cast spell at event for the specified target
        SignalEvent (Spell.oAreaTarget, EventSpellCastAt (Spell.oCaster, Spell.iSpellID));
        // Make a resistance and save check.
        Spell = ResistAndSave (Spell);
        if (!Spell.iSaveResult)
        {
            iHitDice = GetHitDice (Spell.oAreaTarget);
            if (iHitDice <= 8) ApplyEffectToObject (Spell.iDurationType, eBlind, Spell.oAreaTarget, Spell.fDuration);
            // Now check beams!
            if (d8() == 8)
            {
                iImpact1 = GetPrismaticEffect (Random (7) + 1, Spell);
                iImpact2 = GetPrismaticEffect (Random (7) + 1, Spell);
            }
            else iImpact1 = GetPrismaticEffect (Random (7) + 1, Spell);
            // Do first visual impact.
            if (iImpact1 > 0)
            {
                eImpact = EffectVisualEffect (iImpact1);
                DelayCommand (Spell.fDelay, ApplyEffectToObject (DURATION_TYPE_INSTANT, eImpact, Spell.oAreaTarget));
            }
            // Do second visual impact.
            if (iImpact2 > 0)
            {
                eImpact = EffectVisualEffect (iImpact2);
                DelayCommand (Spell.fDelay, ApplyEffectToObject (DURATION_TYPE_INSTANT, eImpact, Spell.oAreaTarget));
            }
        }
        //Get the spells target(s).
        Spell = GetSpellTarget (Spell);
    }
    CleanUpSpell (Spell);
}
///////////////////////////////////////////////////////////////////////////////
//  ApplyPrismaticEffect
///////////////////////////////////////////////////////////////////////////////
/*  Given a reference integer and a target, this function will apply the effect
    of corresponding prismatic cone to the target.  To have any effect the
    reference integer (nEffect) must be from 1 to 7.*/
///////////////////////////////////////////////////////////////////////////////
//  Created By: Aidan Scanlan On: April 11, 2001
///////////////////////////////////////////////////////////////////////////////
int GetPrismaticEffect (int iEffect, struct stSpell Spell)
{
    int iImpact, iDamage;
    effect ePrism, eImpact, eLink;
    effect eDuration = EffectVisualEffect (VFX_DUR_CESSATE_NEGATIVE);
    // Get the effect passed in based on 1-7.
    switch (iEffect)
    {
        case 1://fire
            {
                iDamage = 20;
                iImpact = VFX_IMP_FLAME_S;
                iDamage = GetReflexAdjustedDamage (iDamage, Spell.oAreaTarget, Spell.iSaveDC, SAVING_THROW_TYPE_FIRE);
                ePrism = EffectDamage (iDamage, DAMAGE_TYPE_FIRE);
                DelayCommand (Spell.fDelay, ApplyEffectToObject (DURATION_TYPE_INSTANT, ePrism, Spell.oAreaTarget));
            }
        break;
        case 2: //Acid
            {
                iDamage = 40;
                iImpact = VFX_IMP_ACID_L;
                iDamage = GetReflexAdjustedDamage (iDamage, Spell.oAreaTarget, Spell.iSaveDC, SAVING_THROW_TYPE_ACID);
                ePrism = EffectDamage (iDamage, DAMAGE_TYPE_ACID);
                DelayCommand (Spell.fDelay, ApplyEffectToObject (DURATION_TYPE_INSTANT, ePrism, Spell.oAreaTarget));
            }
        break;
        case 3: //Electricity
            {
                iDamage = 80;
                iImpact = VFX_IMP_LIGHTNING_S;
                iDamage = GetReflexAdjustedDamage (iDamage, Spell.oAreaTarget, Spell.iSaveDC, SAVING_THROW_TYPE_ELECTRICITY);
                ePrism = EffectDamage (iDamage, DAMAGE_TYPE_ELECTRICAL);
                DelayCommand (Spell.fDelay, ApplyEffectToObject (DURATION_TYPE_INSTANT, ePrism, Spell.oAreaTarget));
            }
        break;
        case 4: //Poison
            {
                ePrism = EffectPoison (45/*PRISMATIC_POISON*/);
                DelayCommand (Spell.fDelay, ApplyEffectToObject (DURATION_TYPE_INSTANT, ePrism, Spell.oAreaTarget));
            }
        break;
        case 5: //Petrification
            {
                if (SavingThrowWithEffects (SAVING_THROW_FORT, Spell.oAreaTarget, Spell.iSaveDC) == 0)
                {
                    DelayCommand (Spell.fDelay, ApplyPetrificationEffect (Spell));
                }
            }
        break;
        case 6: //Confusion
            {
                effect eMind = EffectVisualEffect (VFX_DUR_MIND_AFFECTING_DISABLED);
                ePrism = EffectConfused ();
                eLink = EffectLinkEffects (eMind, ePrism);
                eLink = EffectLinkEffects (eLink, eDuration);

                if (!SavingThrowWithEffects (SAVING_THROW_WILL, Spell.oAreaTarget, Spell.iSaveDC, SAVING_THROW_TYPE_MIND_SPELLS, Spell.oCaster, Spell.fDelay))
                {
                    iImpact = VFX_IMP_CONFUSION_S;
                    DelayCommand (Spell.fDelay, ApplyEffectToObject(DURATION_TYPE_TEMPORARY, eLink, Spell.oAreaTarget, RoundsToSeconds(10)));
                }
            }
        break;
        case 7: //Death
            {
                if (!SavingThrowWithEffects (SAVING_THROW_WILL, Spell.oAreaTarget, Spell.iSaveDC, SAVING_THROW_TYPE_DEATH, Spell.oCaster, Spell.fDelay))
                {
                    ePrism = EffectDeath ();
                    DelayCommand (Spell.fDelay, ApplyEffectToObject (DURATION_TYPE_INSTANT, ePrism, Spell.oAreaTarget));
                }
            }
        break;
    }
    return iImpact;
}

