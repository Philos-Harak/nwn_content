/*////////////////////////////////////////////////
 Script: X0_S0_Bane.nss
 Programmer: Preston Watamaniuk
////////////////////////////////////////////////
Enchantment (Compulsion) [Fear, Mind-Affecting]
Level:  Clr 1
Components: V, S, DF
Casting Time:   1 standard action
Range:  50 ft.
Area:   All enemies within 50 ft.
Duration:   1 min./level
Saving Throw:   Will negates
Spell Resistance:   Yes

Bane fills your enemies with fear and doubt. Each affected creature takes a -1
penalty on attack rolls and a -1 penalty on saving throws against fear effects.

Bane counters and dispels bless.
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
    Spell.iDescriptor = DESC_MIND | DESC_FEAR;
    Spell.iAreaShape = SHAPE_SPHERE;
    Spell.fAreaSize = 50.0f;
    Spell.iLineOfSight = FALSE;
    Spell.iObjectFilter = OBJECT_TYPE_CREATURE;
    Spell.iTargetType = TARGET_TYPE_ENEMIES;
    Spell.iDurationType = DURATION_TYPE_MINUTES;
    Spell.iDuration = 1;
    Spell.iDurPerLvl = 1;
    Spell.iSave = SAVING_THROW_WILL;
    Spell.iSaveType = SAVING_THROW_TYPE_FEAR;
    Spell.iSpellResistance = TRUE;
    Spell.iModifier = 1;
    Spell.iImpact = VFX_IMP_HEAD_EVIL;
    // Setup the spell.
    Spell = SetSpell (Spell);
    // Check to see if we should still fire off the spell.
    if (Spell.iSpellID == STOP_SPELL) return;
    // Get the duration of the spell.
    Spell = GetDuration (Spell);
    // *******************************************************************
    // ********************** Spell effects ******************************
    // *******************************************************************
    effect eAttack, eSave, eLink;
    effect eImpact = EffectVisualEffect (Spell.iImpact);
    effect ePointImpact = EffectVisualEffect (VFX_FNF_LOS_EVIL_30);
    effect eDur = EffectVisualEffect (VFX_DUR_CESSATE_POSITIVE);
    float fDelay;
    //Apply Impact
    ApplyEffectAtLocation (DURATION_TYPE_INSTANT, ePointImpact, Spell.lTarget);
    //Get the spells target(s).
    Spell = GetSpellTarget (Spell);
    while(GetIsObjectValid(Spell.oAreaTarget))
    {
        //Fire spell cast at event for target
        SignalEvent (Spell.oAreaTarget, EventSpellCastAt (Spell.oCaster, Spell.iSpellID));
        // Get the modifier for the effect, sets Spell.iResult.
        Spell = GetModifier (Spell);
        // Make resistance and save check.
        Spell = ResistAndSave (Spell);
        if (!Spell.iSaveResult)
        {
            // Create effects and link.
            eAttack = EffectAttackDecrease (Spell.iResult);
            eSave = EffectSavingThrowDecrease (SAVING_THROW_ALL, Spell.iResult, Spell.iSaveType);
            eLink = EffectLinkEffects (eAttack, eSave);
            eLink = EffectLinkEffects(eLink, eDur);
            //Apply VFX impact and bonus effects
            DelayCommand (Spell.fDelay, ApplyEffectToObject (DURATION_TYPE_INSTANT, eImpact, Spell.oAreaTarget));
            DelayCommand (Spell.fDelay, ApplyEffectToObject (Spell.iDurationType, eLink, Spell.oAreaTarget, Spell.fDuration));
        }
        //Get the spells target(s).
        Spell = GetSpellTarget (Spell);
    }
    CleanUpSpell (Spell);
}



