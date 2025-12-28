/*////////////////////////////////////////////////
 Script Name:x0_s0_inferno.nss
 Programmer: Aidan Scanlan
////////////////////////////////////////////////
Caster Level(s): Druid 5
Innate Level: 5
School: Transmutation
Descriptor(s): Fire
Component(s): Verbal, Somatic
Range: Short
Area of Effect / Target: Single
Duration: 1 Round / level
Save: None
Spell Resistance: Yes

The caster causes a target to ignite into flame. Each round the target will
suffer 2d6 points of fire damage.

Enchanting:
Weapons and gloves gain fire damage.
Armors gains fire damage resistance.
Bracers, belts, cloaks, and helmets gain saving throw bonus vs fire.
/*///////////////////////////////////////////////
#include "0i_spells"
#include "x2_inc_toollib"
void RunImpact(object oTarget, object oCaster, int nMetamagic);

void main()
{
    // ***********************************************************
    // *************** Set Spell Structure ***********************
    // ***********************************************************
    // Setup the spell in the structured variables, then pass through the SetSpell function.
    Spell.iSubType = SUBTYPE_MAGICAL;
    Spell.iDescriptor = DESC_FIRE;
    Spell.iAreaShape = SHAPE_RANGE_TARGET;
    Spell.iObjectFilter = OBJECT_TYPE_CREATURE;
    Spell.iTargetType = TARGET_TYPE_ENEMIES;
    Spell.iDurationType = DURATION_TYPE_ROUNDS;
    Spell.iDuration = 1;
    Spell.iDurPerLvl = 1;
    Spell.iSpellResistance = TRUE;
    Spell.iImpact = VFX_IMP_FLAME_S;
    Spell.iBeam = 444; // Stream of fire.
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
    effect eRay;
    effect eDuration = EffectVisualEffect (498);
    effect eSmoke = EffectVisualEffect (VFX_IMP_REFLEX_SAVE_THROW_USE);
    // We need to get the Save DC for the burning effect.
    Spell = GetSaveDC (Spell);
    //Get the spells beam target(s).
    Spell = GetSpellBeamTarget (Spell);
    while(GetIsObjectValid (Spell.oAreaTarget))
    {
        //Fire cast spell at event for the specified target
        SignalEvent (Spell.oAreaTarget, EventSpellCastAt (Spell.oCaster, Spell.iSpellID));
        eRay = EffectBeam (Spell.iBeam, Spell.oBeamEffector, BODY_NODE_HAND);
        DelayCommand (Spell.fDelay, ApplyEffectToObject (DURATION_TYPE_TEMPORARY, eRay, Spell.oAreaTarget, 1.7f));
        // Make sure we do not stack this spells damage. Only one effect per target.
        if (GetHasSpellEffect (Spell.iSpellID, Spell.oAreaTarget) || GetHasSpellEffect (SPELL_COMBUST, Spell.oAreaTarget))
        {
            FloatingTextStrRefOnCreature (100775, Spell.oAreaTarget, FALSE);
        }
        // Spell not on target then create effects.
        else
        {
            // Make resistance check.
            Spell = ResistAndSave (Spell);
            // Check for resistance only 1,2,3.
            if (Spell.iSaveResult != 1 || Spell.iSaveResult != 2 || Spell.iSaveResult != 3)
            {
                // Apply vfx impact.
                DelayCommand (Spell.fDelay + 1.0f, TLVFXPillar (VFX_IMP_FLAME_M, GetLocation(Spell.oAreaTarget), 5, 0.1f, 0.0f, 2.0f));
                //Apply the visual duration and put creature on fire!
                DelayCommand (Spell.fDelay + 1.0f, ApplyEffectToObject (Spell.iDurationType, eDuration, Spell.oAreaTarget, Spell.fDuration));
                DelayCommand (6.0f, Burning (Spell, 2, 6, 0, FALSE));
            }
            // Creature has spellresistance.
            else DelayCommand (Spell.fDelay + 0.5f, ApplyEffectToObject(DURATION_TYPE_INSTANT, eSmoke, Spell.oAreaTarget));
        }
        //Get the spells beam target(s).
        Spell = GetSpellBeamTarget (Spell);
    }
    CleanUpSpell (Spell);
}
