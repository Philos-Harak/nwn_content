/*////////////////////////////////////////////////
 Script Name: X2_S0_InfestMag
 Programmer: Andrew Nobbs
////////////////////////////////////////////////
Caster Level(s): Druid 3
Innate Level: 3
School: Necromancy
Descriptor(s): Disease
Component(s): Verbal, Somatic, Material
Range: Touch
Area of Effect / Target: Creature touched
Duration: 1 round / 2 levels
Additional Counter Spells: Remove Disease, Heal
Save: Fortitude negates
Spell Resistance: Yes

With a successful melee touch attack, you infest a target with maggotlike
creatures. They deal 1d4 points of temporary Constitution damage each round.
Each round the subject makes a new Fortitude save. The spell ends if the target
succeeds at its saving throw.

Material Component: A handful of dead, dried flies.

    If the targets constitution would drop to 0
    through this spell, and the player is playing
    on hardcore difficulty, the target is
    is killed instantly.
/*///////////////////////////////////////////////
#include "0i_spells"

void RunInfestImpact (struct stSpell Spell);

void main()
{
    // ***********************************************************
    // *************** Set Spell Structure ***********************
    // ***********************************************************
    // Setup the spell in the structured variables, then pass through the SetSpell function.
    Spell.iSubType = SUBTYPE_MAGICAL;
    Spell.sArcaneComponent = COMPONENT_POUCH;
    Spell.sDivineComponent = COMPONENT_POUCH;
    Spell.iAreaShape = SHAPE_TOUCH_TARGET;
    Spell.iDurationType = DURATION_TYPE_ROUNDS;
    Spell.iDuration = 1;
    Spell.iDurPerLvl = 2;
    Spell.iSpellResistance = TRUE;
    Spell.iSave = SAVING_THROW_FORT;
    Spell.iSaveType = SAVING_THROW_TYPE_DISEASE;
    Spell.iModNumOfDice = 1;
    Spell.iModifierDie = 4;
    Spell.iImpact = VFX_IMP_DISEASE_S;
    // Setup the spell.
    Spell = SetSpell (Spell);
    // Check to see if we should still fire off the spell.
    if (Spell.iSpellID == STOP_SPELL) return;
    // Get the duration of the spell, sets Spell.fDuration.
    Spell = GetDuration (Spell);
    // *******************************************************************
    // ********************** Spell effects ******************************
    // *******************************************************************
    // Create visual effect.
    effect eDur = EffectVisualEffect (VFX_DUR_FLIES);
    //Get the spells target(s).
    Spell = GetSpellTarget (Spell);
    while(GetIsObjectValid (Spell.oAreaTarget))
    {
        //Make a touch attack to afflict target.
        if (TouchAttackMelee (Spell.oAreaTarget, GetSpellCastItem () == OBJECT_INVALID) > 0)
        {
            // Makes sure we don't duplicate effects.
            if (GetHasSpellEffect (Spell.iSpellID, Spell.oAreaTarget))
            {
                FloatingTextStrRefOnCreature (100775, Spell.oAreaTarget, FALSE);
                return;
            }
            SignalEvent (Spell.oAreaTarget, EventSpellCastAt (Spell.oCaster, Spell.iSpellID));
            DelayCommand (Spell.fDelay, ApplyEffectToObject (Spell.iDurationType, eDur, Spell.oAreaTarget, Spell.fDuration));
            DelayCommand (Spell.fDelay + 0.1f, RunInfestImpact (Spell));
        }
        //Get the spells target(s).
        Spell = GetSpellTarget (Spell);
    }
    CleanUpSpell (Spell);
}

void RunInfestImpact (struct stSpell Spell)
{
    effect eDmg;
    // Check if the spell has expired (check also removes effects)
    if (GetSpellEffectsExpired (Spell.iSpellID, Spell.oAreaTarget, Spell.oCaster)) return;
    // Make sure if the target is dead then end the spell.
    if (GetIsDead (Spell.oAreaTarget) == FALSE)
    {
        // Make a resistance and save check.
        Spell = ResistAndSave (Spell);
        if (!Spell.iSaveResult)
        {
            // Create visual effect.
            effect eImpact = EffectVisualEffect (Spell.iImpact);
            // Get the result for the effect, sets Spell.iResult.
            Spell = GetModifier (Spell);
            // Create effect.
            eDmg = ExtraordinaryEffect (EffectAbilityDecrease (ABILITY_CONSTITUTION, Spell.iResult));
            eDmg = SetEffectCasterLevel(eDmg, Spell.iCasterLevel);
            //------------------------------------------------------------------
            // The trick that allows this spellscript to do stacking ability
            // score damage (which is not possible to do from normal scripts)
            // is that the ability score damage is done from a delaycommanded
            // function which will sever the connection between the effect
            // and the SpellId
            //------------------------------------------------------------------
            ApplyEffectToObject (DURATION_TYPE_INSTANT, eImpact, Spell.oAreaTarget);
            //------------------------------------------------------------------
            // If the target already is down to 3 points of constitution,
            // kill him. For immortal creatures, end the spell
            //------------------------------------------------------------------
            if (GetAbilityScore (Spell.oAreaTarget, ABILITY_CONSTITUTION) <= 3)
            {
                  if (!GetImmortal (Spell.oAreaTarget))
                 {
                     FloatingTextStrRefOnCreature (100932, Spell.oAreaTarget);
                     effect eKill = EffectDamage (GetCurrentHitPoints (Spell.oAreaTarget) + 10);
                     ApplyEffectToObject (DURATION_TYPE_INSTANT, eKill, Spell.oAreaTarget);
                     effect eVfx = EffectVisualEffect (VFX_IMP_DEATH_L);
                     ApplyEffectToObject (DURATION_TYPE_INSTANT, eVfx, Spell.oAreaTarget);
                 }
            }
            else
            {
                 ApplyEffectToObject (DURATION_TYPE_PERMANENT, eDmg, Spell.oAreaTarget);
                 DelayCommand(6.0, RunInfestImpact (Spell));
            }

         }
         else RemoveEffectsFromSpell (Spell.oAreaTarget, Spell.iSpellID);
    }
}

