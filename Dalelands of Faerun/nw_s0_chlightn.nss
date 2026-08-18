/*////////////////////////////////////////////////
 Script: nw_s0_chlightn
 Programmer: Brennon Holmes
////////////////////////////////////////////////
Evocation [Electricity]
Level:  Air 6, Sor/Wiz 6
Components: V, S, F
Casting Time:   1 standard action
Range:  Long (400 ft. + 40 ft./level)
Targets:    One primary target, plus one secondary target/level
    (each of which must be within 30 ft. of the primary target)
Duration:   Instantaneous
Saving Throw:   Reflex half
Spell Resistance:   Yes
This spell creates an electrical discharge that begins as a single stroke
commencing from your fingertips. Unlike lightning bolt, chain lightning strikes
one object or creature initially, then arcs to other targets.

The bolt deals 1d6 points of electricity damage per caster level (maximum 20d6)
to the primary target. After it strikes, lightning can arc to a number of
secondary targets equal to your caster level (maximum 20). The secondary bolts
each strike one target and deal half as much damage as the primary one did
(rounded down).

Each target can attempt a Reflex saving throw for half damage. You choose
secondary targets as you like, but they must all be within 30 feet of the
primary target, and no target can be struck more than once. You can choose to
affect fewer secondary targets than the maximum.

Focus
A bit of fur; a piece of amber, glass, or a crystal rod;
plus one silver pin for each of your caster levels.

    The primary target is struck with 1d6 per caster,
    1/2 with a reflex save.  1 secondary target per
    level is struck for 1d6 / 2 caster levels.  No
    repeat targets can be chosen.
/*///////////////////////////////////////////////
#include "0i_spells"
void main()
{
    // ***********************************************************
    // *************** Set Spell Structure ***********************
    // ***********************************************************
    // Setup the spell in the structured variables, then pass through the SetSpell function.
    Spell.iSubType = SUBTYPE_MAGICAL;
    Spell.iDescriptor = DESC_ELECTRICITY;
    Spell.sArcaneComponent = COMPONENT_POUCH;
    Spell.iAreaShape = SHAPE_SPHERE;
    Spell.fAreaSize = 30.0f;
    Spell.iLineOfSight = TRUE;
    Spell.iObjectFilter = OBJECT_TYPE_CREATURE | OBJECT_TYPE_DOOR | OBJECT_TYPE_PLACEABLE;
    Spell.iTargetType = TARGET_TYPE_ALL;
    Spell.iDurationType = DURATION_TYPE_INSTANT;
   Spell.iSpellResistance = TRUE;
    Spell.iSave = SAVING_THROW_REFLEX;
    Spell.iSaveType = SAVING_THROW_TYPE_ELECTRICITY;
    Spell.iSaveHalf = TRUE;
    Spell.iDamageType = DAMAGE_TYPE_ELECTRICAL;
    Spell.iModNumOfDice = 1;
    Spell.iModifierDie = 6;
    Spell.iModDicePerLvl = 1;
    Spell.iMaxModNumOfDice = 20;
    Spell.iImpact = VFX_IMP_LIGHTNING_S;
    Spell.iBeam = VFX_BEAM_LIGHTNING;
    // Setup the spell.
    Spell = SetSpell (Spell);
    // Check to see if we should still fire off the spell.
    if (Spell.iSpellID == STOP_SPELL) return;
    // Get the result for the effect, sets Spell.iResult.
    Spell = GetModifier (Spell);
    // *******************************************************************
    // ********************** Spell effects ******************************
    // *******************************************************************
    // Used to define the primary target vs secondary targets.
    int iCounter;
    //Set the lightning stream to start at the caster's hands
    effect eDmg, eRay;
    effect eImpact = EffectVisualEffect(Spell.iImpact);
    //Get the spells beam target(s).
    Spell = GetSpellBeamTarget (Spell);
    while(GetIsObjectValid (Spell.oAreaTarget))
    {
        // Keep track of targets: Primary #1 takes full dmg. Secondary > 1 take 1/2 dmg.
        iCounter ++;
        //Fire cast spell at event for the specified target
        SignalEvent (Spell.oAreaTarget, EventSpellCastAt (Spell.oCaster, Spell.iSpellID));
        eRay = EffectBeam (Spell.iBeam, Spell.oBeamEffector, BODY_NODE_HAND);
        DelayCommand (Spell.fDelay, ApplyEffectToObject (DURATION_TYPE_TEMPORARY, eRay, Spell.oAreaTarget, 1.7f));
        // Set damage effect, sets Spell.iResult
        Spell = GetModifier (Spell);
        // Secondary targets take half the amount of damage as the primary target.
        if (iCounter > 1) Spell.iResult = Spell.iResult / 2;
        // Make resistance and save check.
        Spell = ResistAndSave (Spell);
        if (Spell.iResult > 0)
        {
            eDmg = EffectDamage (Spell.iResult, Spell.iDamageType);
            eDmg = SetEffectCasterLevel(eDmg, Spell.iCasterLevel);
            //Apply the VFX impact and damage effect
            DelayCommand (Spell.fDelay + 0.5f, ApplyEffectToObject (DURATION_TYPE_INSTANT, eImpact, Spell.oAreaTarget));
            DelayCommand (Spell.fDelay + 0.5f, ApplyEffectToObject (Spell.iDurationType, eDmg, Spell.oAreaTarget));
        }
        //Get the spells beam target(s).
        Spell = GetSpellBeamTarget (Spell);
    }
    CleanUpSpell (Spell);
}

