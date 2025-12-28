/*////////////////////////////////////////////////
 Script: X2_S0_ElecLoop
 Programmer: Georg Zoeller
////////////////////////////////////////////////
Caster Level(s): Wizard / Sorcerer 2
Innate Level: 2
School: Evocation
Descriptor(s): Electrical, Mind-Affecting
Component(s): Verbal, Somatic, Material
Range: Short
Area of Effect / Target: Small
Duration: Instantaneous
Additional Counter Spells:
Save: Reflex 1/2 (See Below)
Spell Resistance: Yes

You create a small stroke of lightning that cycles through all creatures in the
area of effect. The spell deals 1d6 points of damage per 2 caster levels
(maximum 5d6). Those who fail their Reflex saves must succeed at a Will save
or be stunned for 1 round.

Material Component: A loop of copper wire and a magnet.

Enchanting:
Weapons and gloves gain electricity damage.
Armors gains electricity damage resistance.
Bracers, belts, cloaks, and helmets gain saving throw bonus vs electricity.
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
    Spell.fAreaSize = 5.0f;
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
    Spell.iModDicePerLvl = 2;
    Spell.iMaxModNumOfDice = 5;
    Spell.iImpact = VFX_IMP_LIGHTNING_S;
    Spell.iBeam = VFX_BEAM_LIGHTNING;
    // Setup the spell.
    Spell = SetSpell (Spell);
    // Check to see if we should still fire off the spell.
    if (Spell.iSpellID == STOP_SPELL) return;
    // Get the duration of the spell, sets Spell.fDuration.
    Spell = GetDuration (Spell);
    // Get the result for the effect, sets Spell.iResult.
    Spell = GetModifier (Spell);
    // *******************************************************************
    // ********************** Spell effects ******************************
    // *******************************************************************
    effect   eImpact    = EffectVisualEffect(Spell.iImpact);
    effect   eRay, eDmg;
    effect   eStun = EffectLinkEffects (EffectVisualEffect (VFX_IMP_STUN), EffectStunned());
    //Get the spells beam target(s).
    Spell = GetSpellBeamTarget (Spell);
    while(GetIsObjectValid (Spell.oAreaTarget))
    {
        //Fire cast spell at event for the specified target
        SignalEvent (Spell.oAreaTarget, EventSpellCastAt (Spell.oCaster, Spell.iSpellID));
        eRay = EffectBeam (Spell.iBeam, Spell.oBeamEffector, BODY_NODE_CHEST);
        DelayCommand (Spell.fDelay, ApplyEffectToObject (DURATION_TYPE_TEMPORARY, eRay, Spell.oAreaTarget, 1.7f));
        // Set damage effect, sets Spell.iResult
        Spell = GetModifier (Spell);
        // Make resistance and save check.
        Spell = ResistAndSave (Spell);
        if (!Spell.iSaveResult)
        {
            if (!SavingThrowWithEffects (SAVING_THROW_WILL, Spell.oAreaTarget, Spell.iSaveDC, SAVING_THROW_TYPE_MIND_SPELLS, Spell.oCaster, Spell.fDelay))
            {
                DelayCommand(Spell.fDelay, ApplyEffectToObject (DURATION_TYPE_TEMPORARY, eStun, Spell.oAreaTarget, Spell.fDuration));
            }
        }
        if (Spell.iResult > 0)
        {
            eDmg = EffectDamage (Spell.iResult, Spell.iDamageType);
            DelayCommand (Spell.fDelay, ApplyEffectToObject (DURATION_TYPE_INSTANT, eDmg, Spell.oAreaTarget));
            DelayCommand (Spell.fDelay, ApplyEffectToObject (DURATION_TYPE_INSTANT, eImpact, Spell.oAreaTarget));
        }
        //Get the spells beam target(s).
        Spell = GetSpellBeamTarget (Spell);
    }
    CleanUpSpell (Spell);
}


