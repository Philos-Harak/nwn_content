/*////////////////////////////////////////////////
 Script: nw_s0_calmemot
 Programmer: Philos
////////////////////////////////////////////////
Enchantment [Mind-Affecting]
SubSchool: Cumpulsion
Level:  Brd 3
Components: V, S, DF
Casting Time:   1 standard action
Range: Medium
Area: 20' radius
Duration: 1 round / level
Saving Throw:   Will negates
Spell Resistance:   Yes

This spell calms agitated creatures. You have no control over the affected
creatures, but calm emotions can stop raging creatures from fighting. Creatures
so affected cannot take violent actions (although they can defend themselves) or
do anything destructive. Any aggressive action against or damage dealt to a
calmed creature immediately breaks the spell on all calmed creatures.

This spell dispels any morale bonuses granted by spells such as bless, and rage,
as well as negating a bard’s ability to inspire courage or a barbarian’s rage
ability. It also suppresses any fear effects and removes the confused condition
from all targets.
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
    Spell.iDivineFocus = TRUE;
    Spell.iAreaShape = SHAPE_SPHERE;
    Spell.fAreaSize = 20.0f;
    Spell.iLineOfSight = TRUE;
    Spell.iObjectFilter = OBJECT_TYPE_CREATURE;
    Spell.iTargetType = TARGET_TYPE_ALL;
    Spell.iDurationType = DURATION_TYPE_ROUNDS;
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
    // Get the duration of the spell.
    Spell = GetDuration (Spell);
    // *******************************************************************
    // ********************** Spell effects ******************************
    // *******************************************************************
    // Define variables.
    int iSpell, iEffectType;
    effect eEffect;
    // Create visual effects.
    effect eImpact = EffectVisualEffect (Spell.iImpact);
    effect eCenter = EffectVisualEffect(VFX_FNF_LOS_NORMAL_20);
    //Apply Spell center effect.
    ApplyEffectAtLocation (DURATION_TYPE_INSTANT, eCenter, Spell.lTarget);
    //Get the spells target(s).
    Spell = GetSpellTarget (Spell);
    while(GetIsObjectValid(Spell.oAreaTarget))
    {
        // Make a resistance and save check.
        Spell = ResistAndSave (Spell);
        if (!Spell.iSaveResult)
        {
            SignalEvent (Spell.oAreaTarget, EventSpellCastAt (Spell.oCaster, Spell.iSpellID, FALSE));
            //Apply the VFX impact
            DelayCommand (Spell.fDelay, ApplyEffectToObject (Spell.iDurationType, eImpact, Spell.oAreaTarget, Spell.fDuration));
            if (!GetIsPC (Spell.oAreaTarget) && GetIsEnemy (Spell.oAreaTarget, Spell.oCaster))
            {
                // Remove Hostile setting if they are hostile.
                SetIsTemporaryFriend (Spell.oCaster, Spell.oAreaTarget, TRUE, Spell.fDuration);
                AssignCommand (Spell.oAreaTarget, ClearAllActions (TRUE));
            }
            // Clear all emotional effects.
            eEffect = GetFirstEffect (Spell.oAreaTarget);
            while (GetIsEffectValid (eEffect))
            {
                iEffectType = GetEffectType (eEffect);
                if (iEffectType == EFFECT_TYPE_CONFUSED) RemoveEffect (Spell.oAreaTarget, eEffect);
                if (iEffectType == EFFECT_TYPE_FRIGHTENED) RemoveEffect (Spell.oAreaTarget, eEffect);
                iSpell = GetEffectSpellId (eEffect);
                if (iSpell == SPELL_BLESS) RemoveEffect (Spell.oAreaTarget, eEffect);
                else if (iSpell == SPELL_DOOM) RemoveEffect (Spell.oAreaTarget, eEffect);
                else if (iSpell == 929/*SPELL_ARCANE_BARD_SONG*/) RemoveEffect (Spell.oAreaTarget, eEffect);
                else if (iSpell == 930/*SPELL_DIVINE_BARD_SONG*/) RemoveEffect (Spell.oAreaTarget, eEffect);
                else if (iSpell == 931/*SPELL_ROGUE_BARD_SONG*/) RemoveEffect (Spell.oAreaTarget, eEffect);
                else if (iSpell == 932/*SPELL_WARRIOR_BARD_SONG*/) RemoveEffect (Spell.oAreaTarget, eEffect);
                else if (iSpell == 644/*SPELL_CURSE_SONG*/) RemoveEffect (Spell.oAreaTarget, eEffect);
                else if (iSpell == 307/*SPELL_BARBARIAN_RAGE*/) RemoveEffect (Spell.oAreaTarget, eEffect);
                else if (iSpell == 904/*SPELL_PARTY_BARBARIAN_RAGE*/) RemoveEffect (Spell.oAreaTarget, eEffect);
                eEffect = GetNextEffect (Spell.oAreaTarget);
            }
        }
        else SignalEvent (Spell.oAreaTarget, EventSpellCastAt (Spell.oCaster, Spell.iSpellID));

        //Get the spells target(s).
        Spell = GetSpellTarget (Spell);
    }
    CleanUpSpell (Spell);
}

