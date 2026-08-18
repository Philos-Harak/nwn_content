/*////////////////////////////////////////////////
 Script: NW_S0_WailBansh
 Programmer: Preston Watamaniuk
////////////////////////////////////////////////
Necromancy [Death, Sonic]
Level:  Death 9, Sor/Wiz 9
Components: V
Casting Time:   1 standard action
Range:  Close (25 ft. + 5 ft./2 levels)
Area:   One living creature/level within a 40-ft.-radius spread
Duration:   Instantaneous
Saving Throw:   Fortitude negates
Spell Resistance:   Yes

You emit a terrible scream that kills creatures that hear it (except for yourself).
Creatures closest to the point of origin are affected first.
/*///////////////////////////////////////////////
#include "0i_spells"
void main()
{
    // ***********************************************************
    // *************** Set Spell Structure ***********************
    // ***********************************************************
    // Setup the spell in the structured variables, then pass through the SetSpell function.
    Spell.iSubType = SUBTYPE_MAGICAL;
    Spell.iDescriptor = DESC_DEATH;
    Spell.iAreaShape = SHAPE_SPHERE;
    Spell.fAreaSize = 40.0f;
    Spell.iLineOfSight = TRUE;
    Spell.iObjectFilter = OBJECT_TYPE_CREATURE;
    Spell.iTargetType = TARGET_TYPE_ALL;
    Spell.iSpellResistance = TRUE;
    Spell.iSave = SAVING_THROW_FORT;
    Spell.iSaveType = SAVING_THROW_TYPE_DEATH;
    Spell.iImpact = VFX_IMP_DEATH;
    // Setup the spell.
    Spell = SetSpell (Spell);
    // Check to see if we should still fire off the spell.
    if (Spell.iSpellID == STOP_SPELL) return;
    // *******************************************************************
    // ********************** Spell effects ******************************
    // *******************************************************************
    int iDeaths = Spell.iCasterLevel;
    effect eImpact = EffectVisualEffect (Spell.iImpact);
    effect eCenter = EffectVisualEffect (VFX_FNF_WAIL_O_BANSHEES);
    effect eDeath = EffectDeath ();
    eDeath = SetEffectCasterLevel(eDeath, Spell.iCasterLevel);
    //Apply the spell center effect.
    ApplyEffectAtLocation (DURATION_TYPE_INSTANT, eCenter, Spell.lTarget);
    //Get the spells target(s).
    Spell = GetSpellTarget (Spell);
    while (GetIsObjectValid(Spell.oAreaTarget) && iDeaths > 0)
    {
        if (Spell.oAreaTarget != Spell.oCaster)
        {
            iDeaths --;
            //Fire cast spell at event for the specified target
            SignalEvent (Spell.oAreaTarget, EventSpellCastAt (Spell.oCaster, Spell.iSpellID));
            // Make resistance and save check.
            Spell = ResistAndSave (Spell);
            if (!Spell.iSaveResult)
            {
                //Create an instance of the AOE Object using the Apply Effect function
                DelayCommand (Spell.fDelay, ApplyEffectToObject (DURATION_TYPE_INSTANT, eImpact, Spell.oAreaTarget));
                DelayCommand (Spell.fDelay, ApplyEffectToObject (DURATION_TYPE_INSTANT, eDeath, Spell.oAreaTarget));
                // Ressurect spells look for this variable and if set will require specific spell
                // based upon the value: 1 Raise Dead, 2 Ressurection, 3 True Ressurection.
                SetLocalInt (Spell.oAreaTarget, "0_Raise", 1);
            }
        }
        //Get the spells target(s).
        Spell = GetSpellTarget (Spell);
    }
    CleanUpSpell (Spell);
}
