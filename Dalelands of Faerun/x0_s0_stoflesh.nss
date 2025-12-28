/*////////////////////////////////////////////////
 Script: x0_s0_stoflesh
 Programmer: Brent
////////////////////////////////////////////////
Transmutation
Level:  Sor/Wiz 6
Components: V, S, M
Casting Time:   1 standard action
Range:  Medium (100 ft. + 10 ft./level)
Target: One petrified creatur.
Duration:   Instantaneous
Saving Throw:   Fortitude negates (object); see text
Spell Resistance:   Yes

This spell restores a petrified creature to its normal state, restoring life and goods.
The creature must make a DC 15 Fortitude save to survive the process.
Any petrified creature, regardless of size, can be restored.

Material Component: A pinch of earth and a drop of blood.
/*//////////////////////////////////////////////
#include "0i_spells"
void main()
{
    // ***********************************************************
    // *************** Set Spell Structure ***********************
    // ***********************************************************
    // Setup the spell in the structured variables, then pass through the SetSpell function.
    Spell.iSubType = SUBTYPE_MAGICAL;
    Spell.sArcaneComponent = COMPONENT_POUCH;
    Spell.iAreaShape = SHAPE_RANGE_TARGET;
    Spell.iLineOfSight = TRUE;
    Spell.iObjectFilter = OBJECT_TYPE_CREATURE;
    Spell.iTargetType = TARGET_TYPE_ALLIES;
    Spell.iDurationType = DURATION_TYPE_INSTANT;
    Spell.iSave = SAVING_THROW_FORT;
    Spell.iImpact = VFX_IMP_DISPEL;
    // Setup the spell.
    Spell = SetSpell (Spell);
    // Check to see if we should still fire off the spell.
    if (Spell.iSpellID == STOP_SPELL) return;
    // *******************************************************************
    // ********************** Spell effects ******************************
    // *******************************************************************
    int nToken;
    string sHenchTag;
    object oMaster;
    effect eImpact = EffectVisualEffect (Spell.iImpact);
    //Get the spells target(s).
    Spell = GetSpellTarget (Spell);
    while(GetIsObjectValid(Spell.oAreaTarget))
    {
        //Check to make sure the creature has not been set up to be a statue.
        if (GetLocalInt(Spell.oAreaTarget, "NW_STATUE") != 1)
        {
            //Signal spell cast at event
            SignalEvent(Spell.oAreaTarget, EventSpellCastAt (Spell.oCaster, Spell.iSpellID, FALSE));
            //Remove effects
            DelayCommand(Spell.fDelay, RemoveASpecificEffect(Spell.oAreaTarget, EFFECT_TYPE_PETRIFY));
            DelayCommand(Spell.fDelay, SetCommandable(TRUE, Spell.oAreaTarget));
            if(GetIsCharacter(Spell.oAreaTarget))
            {
                nToken = NuiFindWindow(Spell.oAreaTarget, "pldeathpanel");
                if(nToken) DelayCommand(Spell.fDelay, NuiDestroy(Spell.oAreaTarget, nToken));
            }
            else if(GetAssociateType(Spell.oAreaTarget) == ASSOCIATE_TYPE_HENCHMAN)
            {
                oMaster = GetMaster(Spell.oAreaTarget);
                if(GetIsCharacter(oMaster)) SaveAssociateToDatabase(oMaster, Spell.oAreaTarget);
            }
            //Apply Visual Effect
            ApplyEffectToObject (DURATION_TYPE_INSTANT, eImpact, Spell.oAreaTarget);
        }
        //Get the spells target(s).
        Spell = GetSpellTarget (Spell);
    }
    CleanUpSpell (Spell);
}



