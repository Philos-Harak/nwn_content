/*(////////////////////////////////////////////////
 Scipt Name: NW_S0_Fear
 Programmer: Preston Watamaniuk
////////////////////////////////////////////////
Necromancy [Fear, Mind-Affecting]
Level:  Brd 3, Sor/Wiz 4
Components: V, S, M
Casting Time:   1 standard action
Range:  30 ft.
Area: Shape Sphere
Duration:   1 round/level or 1 round; see text
Saving Throw:   Will partial
Spell Resistance:   Yes

An invisible cone of terror causes each living creature in the area to become
panicked (-6 Attack, Saves, and Skill Checks) unless it succeeds on a Will save.
If the Will save succeeds, the creature is shaken (-2 Attack, Saves, and Skill
checks) for 1 round.

Material Component
Either the heart of a hen or a white feather.
/*///////////////////////////////////////////////
#include "0i_spells"

void main()
{
    // ***********************************************************
    // *************** Set Spell Structure ***********************
    // ***********************************************************
    // Setup the spell in the structured variables, then pass through the SetSpell function.
    Spell.iSubType = SUBTYPE_MAGICAL;
    Spell.iDescriptor = DESC_MIND;
    Spell.sArcaneComponent = COMPONENT_POUCH;
    Spell.iAreaShape = SHAPE_SPHERE;
    Spell.fAreaSize = 5.0f;
    Spell.iLineOfSight = TRUE;
    Spell.iObjectFilter = OBJECT_TYPE_CREATURE;
    Spell.iTargetType = TARGET_TYPE_ALL;
    Spell.iDurationType = DURATION_TYPE_ROUNDS;
    Spell.iDuration = 1;
    Spell.iDurPerLvl = 1;
    Spell.iSpellResistance = TRUE;
    Spell.iSave = SAVING_THROW_WILL;
    Spell.iSaveType = SAVING_THROW_TYPE_MIND_SPELLS;
    Spell.iImpact = VFX_IMP_FEAR_S;
    // Setup the spell.
    Spell = SetSpell (Spell);
    // Check to see if we should still fire off the spell.
    if (Spell.iSpellID == STOP_SPELL) return;
    // Get the duration of the spell, sets Spell.fDuration.
    Spell = GetDuration(Spell);
    // *******************************************************************
    // ********************** Spell effects ******************************
    // *******************************************************************
    // Create visual effects.
    effect eCenter = EffectVisualEffect(VFX_FNF_LOS_NORMAL_20);
    effect eImpact = EffectVisualEffect(Spell.iImpact);
    //Apply Spell center effect.
    ApplyEffectAtLocation(DURATION_TYPE_INSTANT, eCenter, Spell.lTarget);
    //Get the spells target(s).
    Spell = GetSpellTarget(Spell);
    while(GetIsObjectValid(Spell.oAreaTarget))
    {
        //Fire cast spell at event for the specified target
        SignalEvent(Spell.oAreaTarget, EventSpellCastAt(Spell.oCaster, Spell.iSpellID));
        // Make a resistance and save check.
        Spell = ResistAndSave(Spell);
        if(!Spell.iSaveResult)
        {
            //Apply the linked effects and the VFX impact
            DelayCommand(Spell.fDelay, ApplyEffectToObject(DURATION_TYPE_INSTANT, eImpact, Spell.oAreaTarget));
            DelayCommand(Spell.fDelay, Panicked(Spell.oAreaTarget, Spell.fDuration, Spell.iCasterLevel));
        }
        // Shaken for one round if they make the save!
        else if(Spell.iSaveResult == 4)
        {
           //Apply the linked effects and the VFX impact for shaken.
           DelayCommand (Spell.fDelay, ApplyEffectToObject(DURATION_TYPE_INSTANT, eImpact, Spell.oAreaTarget));
           DelayCommand(Spell.fDelay, Shaken(Spell.oAreaTarget, 6.0f, Spell.iCasterLevel));
        }
        //Get the spells target(s).
        Spell = GetSpellTarget(Spell);
    }
    CleanUpSpell(Spell);
}

