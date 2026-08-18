/*////////////////////////////////////////////////
 Script: X2_S0_StnBones
 Programmer: Andrew Nobbs
////////////////////////////////////////////////
Caster Level(s): Wizard / Sorcerer 2, Cleric 2
Innate Level: 2
School: Transmutation
Descriptor(s): Magical Armor
Component(s): Verbal, Somatic, Arcane Focus
Range: Touch
Area of Effect / Target: One undead creature
Duration: 10 minutes / level
Additional Counter Spells:
Save: Harmless
Spell Resistance: No

You cause the target undead to gain a +3 natural armor class bonus, due to the
thickening of its bones.    Gives the target +3 AC Bonus to Natural Armor.

Arcane Focus: A miniature skull carved of granite.
/*///////////////////////////////////////////////
#include "0i_spells"
//#include "nw_i0_spells"
//#include "x2_inc_spellhook"

void main()
{
    // ***********************************************************
    // *************** Set Spell Structure ***********************
    // ***********************************************************
    // Setup the spell in the structured variables, then pass through the SetSpell function.
    Spell.iSubType = SUBTYPE_MAGICAL;
    Spell.sArcaneComponent = COMPONENT_POUCH;
    Spell.iAreaShape = SHAPE_TOUCH_TARGET;
    Spell.iObjectFilter = OBJECT_TYPE_CREATURE;
    Spell.iTargetType = TARGET_TYPE_ALL;
    Spell.iDurationType = DURATION_TYPE_MINUTES;
    Spell.iDuration = 10;
    Spell.iDurPerLvl = 1;
    Spell.iModifier = 3;
    Spell.iImpact = VFX_IMP_AC_BONUS;
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
    effect eImpact = EffectVisualEffect(Spell.iImpact);
    effect eAC = EffectACIncrease (Spell.iResult, AC_VS_DAMAGE_TYPE_ALL);
    effect eDur = EffectVisualEffect(VFX_DUR_CESSATE_POSITIVE);
    effect eLink = EffectLinkEffects(eAC, eDur);
    eLink = SetEffectCasterLevel(eLink, Spell.iCasterLevel);
    //Get the spells target(s).
    Spell = GetSpellTarget (Spell);
    while(GetIsObjectValid(Spell.oAreaTarget))
    {
        //Fire cast spell at event for the specified target
        SignalEvent (Spell.oAreaTarget, EventSpellCastAt (Spell.oCaster, Spell.iSpellID, FALSE));
        if(GetRacialType(Spell.oAreaTarget) == RACIAL_TYPE_UNDEAD)
        {
            // Remove any previously cast spell on this target.
            RemoveSpellEffects (Spell.iSpellID, Spell.oAreaTarget);
            //Apply the armor bonuses and the VFX impact
            DelayCommand (Spell.fDelay, ApplyEffectToObject(Spell.iDuration, eLink, Spell.oAreaTarget, Spell.fDuration));
            DelayCommand (Spell.fDelay, ApplyEffectToObject (DURATION_TYPE_INSTANT, eImpact, Spell.oAreaTarget));
        }
        else
        {
            FloatingTextStrRefOnCreature (85390,Spell.oAreaTarget); // only affects undead;
        }
        //Get the spells target(s).
        Spell = GetSpellTarget (Spell);
    }
    CleanUpSpell (Spell);
}
