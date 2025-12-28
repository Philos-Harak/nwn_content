/*////////////////////////////////////////////////
 Script: x0_s0_banishment
 Programmer: Preston Watamaniuk
////////////////////////////////////////////////
Abjuration
Level:  Clr 6, Sor/Wiz 7
Components: V, S, F
Casting Time:   1 standard action
Range:  Close (25 ft. + 5 ft./2 levels)
Targets: 30' area.
Duration:   Instantaneous
Saving Throw:   Will negates
Spell Resistance:   Yes

It enables you to force extraplanar creatures out of your home plane. As many as
2 Hit Dice of creatures per caster level can be banished.
Extraplanar creatures outsiders and summoned creatures.
/*///////////////////////////////////////////////
#include "0i_spells"
void main()
{
    // ***********************************************************
    // *************** Set Spell Structure ***********************
    // ***********************************************************
    // Setup the spell in the structured variables, then pass through the SetSpell function.
    Spell.iSubType = SUBTYPE_MAGICAL;
    Spell.iAreaShape = SHAPE_SPHERE;
    Spell.fAreaSize = 30.0f;
    Spell.iObjectFilter = OBJECT_TYPE_CREATURE;
    Spell.iTargetType = TARGET_TYPE_ENEMIES;
    Spell.iDurationType = DURATION_TYPE_INSTANT;
    Spell.iSpellResistance = TRUE;
    Spell.iModifier = 2;
    Spell.iModPerLvl = 1;
    Spell.iSave = SAVING_THROW_WILL;
    Spell.iImpact = VFX_IMP_UNSUMMON;
    // Setup the spell.
    Spell = SetSpell (Spell);
    // Check to see if we should still fire off the spell.
    if (Spell.iSpellID == STOP_SPELL) return;
    // Get the result for the effect, sets Spell.iResult.
    Spell = GetModifier (Spell);
    // *******************************************************************
    // ********************** Spell effects ******************************
    // *******************************************************************
    //Declare major variables
    int iHDPool, iHD;
    object oMaster;
    effect eDeath, eImpact = EffectVisualEffect (Spell.iImpact);
    effect eCenter = EffectVisualEffect (VFX_FNF_LOS_EVIL_30);
    // Apply visual effect at the center of the effect area.
    ApplyEffectAtLocation (DURATION_TYPE_INSTANT, eCenter, Spell.lTarget);
    //Get the spells target(s).
    Spell = GetSpellTarget (Spell);
    while(GetIsObjectValid (Spell.oAreaTarget))
    {
        //Fire cast spell at event for the specified target
        SignalEvent (Spell.oAreaTarget, EventSpellCastAt (Spell.oCaster, Spell.iSpellID));
        // All summoned creatures have a master.
        oMaster = GetMaster (Spell.oAreaTarget);
        // To prevent problems with invalid objects passed into GetAssociate.
        if (oMaster == OBJECT_INVALID) oMaster = OBJECT_SELF;
        // * Is the creature a summoned associate or is the creature an outsider
        if((GetAssociate(ASSOCIATE_TYPE_SUMMONED, oMaster) == Spell.oAreaTarget ||
            GetAssociate(ASSOCIATE_TYPE_FAMILIAR, oMaster) == Spell.oAreaTarget ||
            GetAssociate(ASSOCIATE_TYPE_ANIMALCOMPANION, oMaster) == Spell.oAreaTarget ) ||
           (GetRacialType((Spell.oAreaTarget)) == RACIAL_TYPE_OUTSIDER) && (iHDPool > 0))
        {
            // * March 2003. Added a check so that 'friendlies' will not be unsummoned.
            if (IsSpellTargetValid (Spell.oAreaTarget, TARGET_TYPE_ENEMIES, Spell.oCaster))
            {
                    //Fire cast spell at event for the specified target
                    SignalEvent (Spell.oAreaTarget, EventSpellCastAt (Spell.oCaster, Spell.iSpellID));
                    iHD = GetHitDice (Spell.oAreaTarget);
                    // * Must be enough points in the pool to destroy target
                    if (iHDPool >= iHD)
                    // Make a resistance and save check.
                    Spell = ResistAndSave (Spell);
                    if (Spell.iSaveResult == 0)
                    {
                         iHDPool = iHDPool - iHD;
                         ApplyEffectAtLocation  (DURATION_TYPE_INSTANT, eImpact, GetLocation (Spell.oAreaTarget));
                         // Can they be destroyed!
                         if (!GetPlotFlag (Spell.oAreaTarget) && !GetImmortal (Spell.oAreaTarget))
                         {
                            //bugfix: Simply destroying the object won't fire it's OnDeath script.
                            //Which is bad when you have plot-specific things being done in that
                            //OnDeath script... so lets kill it.
                            eDeath = EffectDeath(FALSE, FALSE);
                            DelayCommand(0.25, ApplyEffectToObject (DURATION_TYPE_INSTANT, eDeath, Spell.oAreaTarget));
                            DestroyObject (Spell.oAreaTarget, 0.3);
                         }
                    }
            }
        }
	//Get the spells target(s).
	Spell = GetSpellTarget (Spell);
    }
    CleanUpSpell (Spell);
}


