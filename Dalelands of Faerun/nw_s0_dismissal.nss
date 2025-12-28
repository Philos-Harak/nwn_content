/*////////////////////////////////////////////////
 Script: NW_S0_Dismissal.nss
 Programmer: Preston Watamaniuk
////////////////////////////////////////////////
Abjuration
Level:  Clr 4, Sor/Wiz 5
Components: V, S, DF
Casting Time:   1 standard action
Range:  Close (25 ft. + 5 ft./2 levels)
Target: One extraplanar creature
Duration:   Instantaneous
Saving Throw:   Will negates; see text
Spell Resistance:   Yes
This spell forces any extraplanar creature in the area of effect back to thier
proper plane if they fail a special Will save
(DC = spell’s save DC - creature’s HD + your caster level).
/*///////////////////////////////////////////////
#include "0i_spells"

void main()
{
    // ***********************************************************
    // *************** Set Spell Structure ***********************
    // ***********************************************************
    // Setup the spell in the structured variables, then pass through the SetSpell function.
    Spell.iSubType = SUBTYPE_MAGICAL;
    Spell.iDivineFocus = TRUE;
    Spell.iAreaShape = SHAPE_SPHERE;
    Spell.fAreaSize = 30.0f;
    Spell.iLineOfSight = TRUE;
    Spell.iObjectFilter = OBJECT_TYPE_CREATURE;
    Spell.iTargetType = TARGET_TYPE_ALL;
    Spell.iDurationType = DURATION_TYPE_INSTANT;
    Spell.iSpellResistance = TRUE;
    Spell.iImpact = VFX_IMP_UNSUMMON;
    // Setup the spell.
    Spell = SetSpell (Spell);
    // Check to see if we should still fire off the spell.
    if (Spell.iSpellID == STOP_SPELL) return;
    // *******************************************************************
    // ********************** Spell effects ******************************
    // *******************************************************************
    //Declare major variables
    object oMaster;
    // Create visual effects.
    effect eImpact = EffectVisualEffect(VFX_IMP_UNSUMMON);
    effect eCenter = EffectVisualEffect(VFX_FNF_LOS_EVIL_30);
    // Apply visual effect at the center of the effect area.
    ApplyEffectAtLocation (DURATION_TYPE_INSTANT, eCenter, Spell.lTarget);
    // Get the spells target(s).
    Spell = GetSpellTarget (Spell);
    while(GetIsObjectValid(Spell.oAreaTarget))
    {
        // Does the creature have a master?
        oMaster = GetMaster (Spell.oAreaTarget);
        // Is that master valid and is he an enemy?
        if (GetIsObjectValid (oMaster))
        {
            //Is the creature a planar summons, i.e. not familiar or animal companion.
            if (GetAssociate (ASSOCIATE_TYPE_SUMMONED, oMaster) == Spell.oAreaTarget)
               // || GetAssociate(ASSOCIATE_TYPE_FAMILIAR, oMaster) == Spell.oAreaTarget ||
               //    GetAssociate(ASSOCIATE_TYPE_ANIMALCOMPANION, oMaster) == Spell.oAreaTarget )
            {
                // Fire cast spell at event for the specified target
                SignalEvent (Spell.oAreaTarget, EventSpellCastAt (Spell.oCaster, Spell.iSpellID));
                // Make a resistance check.
                Spell = ResistAndSave (Spell);
                if (!Spell.iSaveResult)
                {
                    //Determine correct save
                    Spell = GetSaveDC (Spell);
                    Spell.iSaveDC = Spell.iSaveDC + Spell.iCasterLevel - GetHitDice (Spell.oAreaTarget);
                    // Special Will save checks
                    if (!SavingThrowWithEffects (SAVING_THROW_WILL, Spell.oAreaTarget, Spell.iSaveDC))
                    {
                        //Apply the VFX and delay the destruction of the summoned monster so
                        //that the script and VFX can play.
                        DelayCommand (Spell.fDelay, ApplyEffectToObject (DURATION_TYPE_INSTANT, eImpact, Spell.oAreaTarget));
                        DestroyObject (Spell.oAreaTarget, Spell.fDelay + 0.5);
                    }
                }
            }
        }
        //Get the spells target(s).
        Spell = GetSpellTarget (Spell);
    }
    CleanUpSpell (Spell);
}
