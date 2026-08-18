/*////////////////////////////////////////////////
 Script: NW_S0_charmani
 Programmer: Preston Watamaniuk
////////////////////////////////////////////////
Caster Level(s): Druid 2
Innate Level: 2
School: Enchantment
Descriptor(s): Mind-Affecting
Component(s): Verbal, Somatic
Range: Short
Area of Effect / Target: Single
Duration: 1 Hour / Level
Additional Counter Spells: Clarity
Save: Will Negates
Spell Resistance: Yes

In the eyes of the target animal or humanoid, the personal reputation of the
caster is improved by 50%.
//*//////////////////////////////////////////////
#include "0i_spells"

void main()
{
    // ***********************************************************
    // *************** Set Spell Structure ***********************
    // ***********************************************************
    // Setup the spell in the structured variables, then pass through the SetSpell function.
    Spell.iSubType = SUBTYPE_MAGICAL;
    Spell.iSubSchool = SUBSCHOOL_CHARM;
    Spell.iDescriptor = DESC_MIND;
    Spell.iAreaShape = SHAPE_RANGE_TARGET;
    Spell.iObjectFilter = OBJECT_TYPE_CREATURE;
    Spell.iTargetType = TARGET_TYPE_ENEMIES;
    Spell.iDurationType = DURATION_TYPE_HOURS;
    Spell.iDuration = 1;
    Spell.iDurPerLvl = 1;
    Spell.iSpellResistance = TRUE;
    Spell.iSave = SAVING_THROW_WILL;
    Spell.iSaveType = SAVING_THROW_TYPE_MIND_SPELLS;
    Spell.iImpact = VFX_IMP_CHARM;
    // Setup the spell.
    Spell = SetSpell (Spell);
    // Check to see if we should still fire off the spell.
    if (Spell.iSpellID == STOP_SPELL) return;
    // Get the duration of the spell, sets Spell.fDuration.
    Spell = GetDuration (Spell);
    // *******************************************************************
    // ********************** Spell effects ******************************
    // *******************************************************************
    effect eImpact = EffectVisualEffect(Spell.iImpact);
    effect eCharm = EffectCharmed();
    effect eMind = EffectVisualEffect(VFX_DUR_MIND_AFFECTING_NEGATIVE);
    effect eDur = EffectVisualEffect(VFX_DUR_CESSATE_NEGATIVE);
    //Link the charm and duration visual effects
    effect eLink = EffectLinkEffects(eMind, eDur);
    eLink = SetEffectCasterLevel(eLink, Spell.iCasterLevel);
   int iRacial;
    //Get the spells target(s).
    Spell = GetSpellTarget (Spell);
    while(GetIsObjectValid(Spell.oAreaTarget))
    {
        //Fire spell cast at event to fire on the target
        SignalEvent(Spell.oAreaTarget, EventSpellCastAt (Spell.oCaster, Spell.iSpellID, FALSE));
        // Make resistance and save check.
        Spell = ResistAndSave (Spell);
        if (!Spell.iSaveResult)
        {
            //Make sure the racial type of the target is applicable
            iRacial = GetRacialType (Spell.oAreaTarget);
            if  ((iRacial == RACIAL_TYPE_DWARF) ||
                (iRacial == RACIAL_TYPE_ANIMAL) ||
                (iRacial == RACIAL_TYPE_ELF) ||
                (iRacial == RACIAL_TYPE_GNOME) ||
                (iRacial == RACIAL_TYPE_HUMANOID_GOBLINOID) ||
                (iRacial == RACIAL_TYPE_HALFLING) ||
                (iRacial == RACIAL_TYPE_HUMAN) ||
                (iRacial == RACIAL_TYPE_HALFELF) ||
                (iRacial == RACIAL_TYPE_HALFORC) ||
                (iRacial == RACIAL_TYPE_HUMANOID_MONSTROUS) ||
                (iRacial == RACIAL_TYPE_HUMANOID_ORC) ||
                (iRacial == RACIAL_TYPE_HUMANOID_REPTILIAN))
            {
                // Link to visual effects.
                eLink = EffectLinkEffects(eLink, eCharm);
                //Apply impact effects and linked duration and charm effect
                DelayCommand (Spell.fDelay, ApplyEffectToObject (Spell.iDurationType, eLink, Spell.oAreaTarget, Spell.fDuration));
                DelayCommand (Spell.fDelay, ApplyEffectToObject (DURATION_TYPE_INSTANT, eImpact, Spell.oAreaTarget));
            }
        }
        //Get the spells target(s).
        Spell = GetSpellTarget (Spell);
    }
    CleanUpSpell (Spell);
}
