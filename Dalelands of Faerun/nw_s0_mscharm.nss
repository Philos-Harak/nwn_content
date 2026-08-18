/*////////////////////////////////////////////////
 Script: NW_S0_MsCharm
 Programmer: Preston Watamaniuk
////////////////////////////////////////////////
Enchantment (Charm) [Mind-Affecting]
Level:  Brd 3, Sor/Wiz 4
Components: V, S
Casting Time: 1 standard action
Range:  Short
Target: One humanoid creature
Duration:   24 hours
Saving Throw:   Will negates
Spell Resistance:   Yes

This charm makes a humanoid creature regard you as its trusted friend and ally
(the personal reputation of the caster is improved by 50%).

In the eyes of all non-allied creatures within the area of affect, the personal
reputation of the caster is improved by 50%. The caster can charm up to twice
his hit dice in creatures.
/*///////////////////////////////////////////////
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
    Spell.iAreaShape = SHAPE_SPHERE;
    Spell.fAreaSize = 30.0f;
    Spell.iLineOfSight = TRUE;
    Spell.iTargetType = TARGET_TYPE_ENEMIES;
    Spell.iObjectFilter = OBJECT_TYPE_CREATURE;
    Spell.iDurationType = DURATION_TYPE_HOURS;
    Spell.iDuration = 24;
    Spell.iSave = SAVING_THROW_WILL;
    Spell.iSaveType = SAVING_THROW_TYPE_MIND_SPELLS;
    Spell.iSpellResistance = TRUE;
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
    int iTargetHitDice, iHitDice = Spell.iCasterLevel * 2;
    // Create effects.
    effect eCharm = EffectCharmed ();
    // Create visual effects.
    effect eImpact = EffectVisualEffect (Spell.iImpact);
    effect eMind = EffectVisualEffect (VFX_DUR_MIND_AFFECTING_NEGATIVE);
    effect eDuration = EffectVisualEffect (VFX_DUR_CESSATE_NEGATIVE);
    effect eCenter = EffectVisualEffect (VFX_FNF_LOS_NORMAL_20);
    //Link persistant effects
    effect eLink = EffectLinkEffects(eMind, eDuration);
    eLink = EffectLinkEffects(eLink, eCharm);
    eLink = SetEffectCasterLevel(eLink, Spell.iCasterLevel);
    // Apply vfx at the spells location.
    ApplyEffectAtLocation (DURATION_TYPE_INSTANT, eCenter, Spell.lTarget);
    //Get the spells target(s).
    Spell = GetSpellTarget (Spell);
    while(GetIsObjectValid(Spell.oAreaTarget) && iHitDice > 0)
    {
        iTargetHitDice = GetHitDice (Spell.oAreaTarget);
        if (iHitDice > iTargetHitDice)
        {
            //Fire cast spell at event for the specified target
            SignalEvent (Spell.oAreaTarget, EventSpellCastAt (Spell.oCaster, Spell.iSpellID, FALSE));
            // Make a resistance and save check.
            Spell = ResistAndSave (Spell);
            if (!Spell.iSaveResult)
            {
               //Apply impact and linked effects
                DelayCommand (Spell.fDelay, ApplyEffectToObject(Spell.iDurationType, eLink, Spell.oAreaTarget, Spell.fDuration));
                DelayCommand (Spell.fDelay, ApplyEffectToObject(DURATION_TYPE_INSTANT, eImpact, Spell.oAreaTarget));
            }
            iHitDice = iHitDice - iTargetHitDice;
        }
        //Get the spells target(s).
        Spell = GetSpellTarget (Spell);
    }
    CleanUpSpell (Spell);
}
