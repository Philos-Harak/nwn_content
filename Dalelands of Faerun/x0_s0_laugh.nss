/*////////////////////////////////////////////////
 Script Name:x0_s0_laugh
 Programmer: Brent
////////////////////////////////////////////////
Caster Level(s): Bard 2, Sorcerer/Wizard 2
Innate Level: 2
Components:	V, S, M
Casting Time:	1 standard action
Range:	Close (25 ft. + 5 ft./2 levels)
Target:	One creature; see text
Duration:	1 round/level
Saving Throw:	Will negates
Spell Resistance:	Yes
This spell afflicts the subject with uncontrollable laughter. It collapses into
gales of manic laughter, falling prone. The subject can take no actions while
laughing, but is not considered helpless. After the spell ends, it can act normally.

A creature with an Intelligence score of 2 or lower is not affected. A creature
whose type is different from the caster’s receives a +4 bonus on its saving
throw, because humor doesn’t “translate” well.

Material Component
Tiny tarts that are thrown at the target and a feather that is waved in the air.
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
    Spell.sArcaneComponent = COMPONENT_POUCH;
    Spell.iAreaShape = SHAPE_RANGE_TARGET;
    Spell.iTargetType = TARGET_TYPE_ENEMIES;
    Spell.iDurationType = DURATION_TYPE_ROUNDS;
    Spell.iDuration = 1;
    Spell.iDurPerLvl = 1;
    Spell.iSpellResistance = TRUE;
    Spell.iSave = SAVING_THROW_WILL;
    Spell.iSaveType = SAVING_THROW_TYPE_MIND_SPELLS;
    Spell.iImpact = VFX_IMP_WILL_SAVING_THROW_USE;
    Spell = SetSpell (Spell);
    if (Spell.iSpellID == STOP_SPELL) return;
    Spell = GetDuration (Spell);
    // *******************************************************************
    // ********************** Spell effects ******************************
    // *******************************************************************
    int nCnt;
    effect eVis = EffectVisualEffect (VFX_IMP_WILL_SAVING_THROW_USE);
    effect eDur = EffectVisualEffect (VFX_DUR_MIND_AFFECTING_DISABLED);
    effect eLaugh = EffectKnockdown();
    int nModifier = 0;
    // * creatures of different race find different things funny
    if (GetRacialType (Spell.oAreaTarget) != GetRacialType (OBJECT_SELF)) Spell.iSaveDC - 4;
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
            DelayCommand (Spell.fDelay, ApplyEffectToObject (DURATION_TYPE_INSTANT, eVis, Spell.oAreaTarget));
            DelayCommand (Spell.fDelay, ApplyEffectToObject (Spell.iDurationType, eDur, Spell.oAreaTarget, Spell.fDuration));
            DelayCommand (Spell.fDelay, AssignCommand (Spell.oAreaTarget, ClearAllActions ()));
            DelayCommand (Spell.fDelay, AssignCommand (Spell.oAreaTarget, PlayVoiceChat (VOICE_CHAT_LAUGH)));
            DelayCommand (Spell.fDelay, AssignCommand (Spell.oAreaTarget, ActionPlayAnimation (ANIMATION_LOOPING_TALK_LAUGHING)));
            DelayCommand (Spell.fDelay + 0.3f, ApplyEffectToObject (DURATION_TYPE_TEMPORARY, eLaugh, Spell.oAreaTarget, Spell.fDuration));
        }
        //Get the spells target(s).
        Spell = GetSpellTarget (Spell);
    }
    CleanUpSpell (Spell);
}





