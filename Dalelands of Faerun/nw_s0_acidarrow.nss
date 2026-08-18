/*////////////////////////////////////////////////
 Script: nw_s0_acidarrow
 Programmer: Aidan Scanlan
////////////////////////////////////////////////
Conjuration (Creation) [Acid]
Level:  Sor/Wiz 2
Components: V, S, M, F
Casting Time:   1 standard action
Range:  Long (400 ft. + 40 ft./level)
Effect: One arrow of acid
Duration:   1 round + 1 round per three levels
Saving Throw:   None
Spell Resistance: No

A magical arrow of acid springs from your hand and speeds to its target.
You must succeed on a ranged touch attack to hit your target. The arrow deals
2d4 points of acid damage with no splash damage. For every three caster levels
(to a maximum of 18th), the acid, unless somehow neutralized, lasts for another
round, dealing another 2d4 points of damage in that round.

Material Component: Powdered rhubarb leaf and an adder�s stomach.
Focus: A dart.
/*////////////////////////////////////////////////////////
#include "0i_spells"

void RunImpact (struct stSpell Spell);

void main()
{
    // ***********************************************************
    // *************** Set Spell Structure ***********************
    // ***********************************************************
    // Setup the spell in the structured variables, then pass through the SetSpell function.
    Spell.iSubType = SUBTYPE_MAGICAL;
    Spell.iSubSchool = SUBSCHOOL_CREATION;
    Spell.iDescriptor = DESC_ACID;
    Spell.sArcaneComponent = COMPONENT_POUCH;
    Spell.iAreaShape = SHAPE_RANGE_TARGET;
    Spell.iObjectFilter = OBJECT_TYPE_CREATURE;
    Spell.iTargetType = TARGET_TYPE_ENEMIES;
    Spell.iDurationType = DURATION_TYPE_ROUNDS;
    Spell.iDurNumOfDice = 1;
    Spell.iDurationDie = 1;
    Spell.iDuration = 1;
    Spell.iDurPerLvl = 3;
    Spell.iMaxDuration = 6;
    Spell.iDamageType = DAMAGE_TYPE_ACID;
    Spell.iModNumOfDice = 2;
    Spell.iModifierDie = 4;
    Spell.iImpact = VFX_IMP_ACID_L;
    // Setup the spell.
    Spell = SetSpell (Spell);
    // Check to see if we should still fire off the spell.
    if (Spell.iSpellID == STOP_SPELL) return;
    // Get the duration of the spell, sets Spell.fDuration.
    Spell = GetDuration (Spell);
    // *******************************************************************
    // ********************** Spell effects ******************************
    // *******************************************************************
    int iHit;
    effect eDmg;
    effect eImpact = EffectVisualEffect (Spell.iImpact);
    effect eDur = EffectVisualEffect (VFX_DUR_CESSATE_NEGATIVE);
    effect eArrow = EffectVisualEffect (VFX_DUR_MIRV_ACID);
    // Cannot be dispelled so make it extraordinary.
    eDur = ExtraordinaryEffect (eDur);
    //Get the spells target(s).
    Spell = GetSpellTarget (Spell);
    while(GetIsObjectValid (Spell.oAreaTarget))
    {
        // Makes sure we don't duplicate effects.
        if (GetHasSpellEffect (Spell.iSpellID, Spell.oAreaTarget))
        {
            FloatingTextStrRefOnCreature (100775, Spell.oAreaTarget, FALSE);
            return;
        }
        SignalEvent(Spell.oAreaTarget, EventSpellCastAt (Spell.oCaster, Spell.iSpellID));
        // Do arrow going to target.
        ApplyEffectToObject (DURATION_TYPE_INSTANT, eArrow, Spell.oAreaTarget);
        // Make a touch attack to hit.
        iHit = TouchAttackRanged (Spell.oAreaTarget);
        if (iHit)
        {
            // Get the result for the effect, sets Spell.iResult.
            Spell = GetModifier (Spell);
            // Create damage effect.
            eDmg = EffectDamage (Spell.iResult, Spell.iDamageType);
            eDmg = SetEffectCasterLevel(eDmg, Spell.iCasterLevel);
            // Apply the effect.
            DelayCommand (Spell.fDelay, ApplyEffectToObject (DURATION_TYPE_INSTANT, eImpact, Spell.oAreaTarget));
            DelayCommand (Spell.fDelay, ApplyEffectToObject (DURATION_TYPE_INSTANT, eDmg, Spell.oAreaTarget));
            // Apply duration effect.
            DelayCommand (Spell.fDelay, ApplyEffectToObject(Spell.iDurationType, eDur, Spell.oAreaTarget, Spell.fDuration));
            // Now run script to check each round to see if we do more damage.
            DelayCommand (6.0f, RunImpact (Spell));
        }
        //Get the spells target(s).
        Spell = GetSpellTarget (Spell);
    }
    CleanUpSpell (Spell);
}

void RunImpact (struct stSpell Spell)
{
    // Check if the spell has expired (check also removes effects)
    if (GetDelayedSpellEffectsExpired (Spell.iSpellID, Spell.oAreaTarget, Spell.oCaster)) return;
    if (!GetIsDead (Spell.oAreaTarget))
    {
        // Get the result for the effect, sets Spell.iResult.
        Spell = GetModifier (Spell);
        effect eDmg = EffectDamage (Spell.iResult, Spell.iDamageType);
        effect eImpact = EffectVisualEffect (Spell.iImpact);
        eDmg = EffectLinkEffects (eImpact, eDmg);
        ApplyEffectToObject (DURATION_TYPE_INSTANT, eDmg, Spell.oAreaTarget);
        DelayCommand (6.0f, RunImpact(Spell));
    }
}

