/*////////////////////////////////////////////////
 Script Name: NW_S0_LightnBolt
 Programmer: Noel Borstad
////////////////////////////////////////////////
Caster Level(s): Wizard / Sorcerer 3
Innate Level: 3
School: Evocation
Descriptor(s): Electricity
Component(s): Verbal, Somati, Material
Range: Medium
Area of Effect / Target: Chain of targets in a straight line
Duration: Instant
Save: Reflex 1/2
Spell Resistance: Yes

The caster fires a bolt of lightning that passes through all creatures in a
straight line from the caster. The bolt does 1d6 points of electricity damage
per caster level, to a maximum of 10d6.

Material Component
A bit of fur and an amber, crystal, or glass rod.

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
    Spell.iAreaShape = SHAPE_SPELLCYLINDER;
    Spell.fAreaSize = 120.0f;
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
    Spell.iMaxModNumOfDice = 10;
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
    //Set the lightning stream to start at the caster's hands
    effect eDmg, eRay;
    effect eImpact = EffectVisualEffect(Spell.iImpact);
    //Get the spells beam target(s).
    Spell = GetSpellBeamTarget (Spell);
    while(GetIsObjectValid (Spell.oAreaTarget))
    {
        //Fire cast spell at event for the specified target
        SignalEvent (Spell.oAreaTarget, EventSpellCastAt (Spell.oCaster, Spell.iSpellID));
        eRay = EffectBeam (Spell.iBeam, Spell.oBeamEffector, BODY_NODE_MONSTER_0);
        DelayCommand (Spell.fDelay, ApplyEffectToObject (DURATION_TYPE_TEMPORARY, eRay, Spell.oAreaTarget, 1.7f));
        // Set damage effect, sets Spell.iResult
        Spell = GetModifier (Spell);
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

