/*////////////////////////////////////////////////
 Script: NW_S0_PWStun
 Programmer: Preston Watamaniuk
////////////////////////////////////////////////
Enchantment (Compulsion) [Mind-Affecting]
Level:	Sor/Wiz 8, War 8
Components:	V
Casting Time:	1 standard action
Range:	Close (25 ft. + 5 ft./2 levels)
Target:	One creature with 150 hp or less
Duration:	See text
Saving Throw:	None
Spell Resistance:	Yes

You utter a single word of power that instantly causes one creature of your choice
to become stunned, whether the creature can hear the word or not. The duration
of the spell depends on the target’s current hit point total. Any creature that
currently has 151 or more hit points is unaffected by power word stun.

Hit Points    	Duration
50 or less    	4d4 rounds
51-100        	2d4 rounds
101-150       	1d4 rounds
/*///////////////////////////////////////////////
#include "0i_spells"

void main()
{
    // ***********************************************************
    // *************** Set Spell Structure ***********************
    // ***********************************************************
    // Setup the spell in the structured variables, then pass through the SetSpell function.
    Spell.iSubType = SUBTYPE_MAGICAL;
    Spell.iSubSchool = SUBSCHOOL_COMPULSION;
    Spell.iDescriptor = DESC_MIND;
    Spell.iAreaShape = SHAPE_RANGE_TARGET;
    Spell.iLineOfSight = TRUE;
    Spell.iObjectFilter = OBJECT_TYPE_CREATURE;
    Spell.iTargetType = TARGET_TYPE_ENEMIES;
    Spell.iDurationType = DURATION_TYPE_ROUNDS;
    Spell.iDurationDie = 4;
    Spell.iSpellResistance = TRUE;
    Spell.iSave = SAVING_THROW_WILL;
    Spell.iSaveType = SAVING_THROW_TYPE_MIND_SPELLS;
    // Setup the spell.
    Spell = SetSpell (Spell);
    // Check to see if we should still fire off the spell.
    if (Spell.iSpellID == STOP_SPELL) return;
    // *******************************************************************
    // ********************** Spell effects ******************************
    // *******************************************************************
    // Declare variables.
    int iHitPoints;
    // Create visual effects.
    effect eMind = EffectVisualEffect (VFX_DUR_MIND_AFFECTING_DISABLED);
    effect eImpact = EffectVisualEffect (VFX_IMP_STUN);
    effect eCenter = EffectVisualEffect (VFX_FNF_PWSTUN);
    // Create effects.
    effect eStun = EffectStunned();
    // Link effects.
    effect eLink = EffectLinkEffects (eMind, eStun);
    // Apply the VFX center
    ApplyEffectAtLocation (DURATION_TYPE_INSTANT, eCenter, Spell.lTarget);
    //Get the spells target(s).
    Spell = GetSpellTarget (Spell);
    while(GetIsObjectValid(Spell.oAreaTarget))
    {
        //Fire cast spell at event for the specified target
        SignalEvent (Spell.oAreaTarget, EventSpellCastAt (Spell.oCaster, Spell.iSpellID));
        iHitPoints =  GetCurrentHitPoints (Spell.oAreaTarget);
        //Determine the number rounds the creature will be stunned
        if (iHitPoints >= 101 && iHitPoints <= 150) Spell.iDurNumOfDice = 1;
        else if (iHitPoints >= 51 && iHitPoints <= 100) Spell.iDurNumOfDice = 2;
        else if (iHitPoints <= 50) Spell.iDurNumOfDice = 4;
        // Get the duration of the spell, sets Spell.fDuration.
        Spell = GetDuration (Spell);
        // Make resistance and save check.
        Spell = ResistAndSave (Spell);
        if (!Spell.iSaveResult && Spell.iDurNumOfDice != 0)
        {
            //Apply paralyze effect and VFX impact
            DelayCommand (Spell.fDelay, ApplyEffectToObject(DURATION_TYPE_INSTANT, eImpact, Spell.oAreaTarget));
            DelayCommand (Spell.fDelay, ApplyEffectToObject (Spell.iDurationType, eLink, Spell.oAreaTarget, Spell.fDuration));
        }
        //Get the spells target(s).
        Spell = GetSpellTarget (Spell);
    }
    CleanUpSpell (Spell);
}
