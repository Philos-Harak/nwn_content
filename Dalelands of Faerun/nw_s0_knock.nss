/*////////////////////////////////////////////////
 Script: NW_S0_Knock
 Programmer: Preston Watamaniuk
////////////////////////////////////////////////
Transmutation
Level:  Sor/Wiz 2
Components: V
Casting Time:   1 standard action
Range:  Medium (100 ft. + 10 ft./level)
Target: All doors, boxes, or chests with an area of up to 150 sq. ft.
Duration:   Instantaneous; see text
Saving Throw:   None
Spell Resistance:   No

The knock spell opens stuck, barred, locked, held, or arcane locked doors.
It opens secret doors, as well as locked or trick-opening boxes or chests.
If used to open a arcane locked door, the spell does not remove the arcane lock
but simply suspends its functioning for 10 minutes.
Each spell can undo as many as two means of preventing egress.
/*///////////////////////////////////////////////
#include "0i_spells"
void main()
{
    // ***********************************************************
    // *************** Set Spell Structure ***********************
    // ***********************************************************
    // Setup the spell in the structured variables, then pass through the SetSpell function.
    Spell.iSubType = SUBTYPE_MAGICAL;
    Spell.sEnhancingComp = "spodumene_dust";
    Spell.iAreaShape = SHAPE_SPHERE;
    Spell.fAreaSize = 150.0f;
    Spell.iLineOfSight = FALSE;
    Spell.iObjectFilter = OBJECT_TYPE_DOOR | OBJECT_TYPE_PLACEABLE;
    Spell.iTargetType = TARGET_TYPE_ALL;
    Spell.iDurationType = DURATION_TYPE_INSTANT;
    Spell.iImpact = VFX_IMP_KNOCK;
    // Setup the spell.
    Spell = SetSpell (Spell);
    // Check to see if we should still fire off the spell.
    if (Spell.iSpellID == STOP_SPELL) return;
    // *******************************************************************
    // ********************** Spell effects ******************************
    // *******************************************************************
    if(Spell.sEnhancingComp == "TRUE") Spell.fAreaSize *= 1.5;
    effect eImpact = EffectVisualEffect (Spell.iImpact);
    //Get the spells target(s).
    Spell = GetSpellTarget (Spell);
    while (Spell.oAreaTarget != OBJECT_INVALID)
    {
        SignalEvent (Spell.oAreaTarget, EventSpellCastAt (Spell.oCaster, Spell.iSpellID));
        if (GetLocked (Spell.oAreaTarget))
        {
            if (!GetLocalInt (Spell.oAreaTarget, "0_Resist_Knock"))
            {
                DelayCommand (Spell.fDelay, ApplyEffectToObject (DURATION_TYPE_INSTANT, eImpact, Spell.oAreaTarget));
                DelayCommand (Spell.fDelay, AssignCommand (Spell.oAreaTarget, ActionUnlockObject(Spell.oAreaTarget)));
            }
            else
            {
                // * Failure! - Door unaffected by magic *
                FloatingTextStrRefOnCreature (83887, Spell.oAreaTarget);
            }
        }
        //Get the spells target(s).
        Spell = GetSpellTarget (Spell);
    }
    CleanUpSpell (Spell);
}
