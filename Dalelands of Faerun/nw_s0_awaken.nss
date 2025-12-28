/*////////////////////////////////////////////////
 Script Name:NW_S0_Awaken
 Programmer: Preston Watamaniuk
////////////////////////////////////////////////
Transmutation
Level:	Drd 5
Components:	V, S, F
Casting Time:	24 hours
Range: Personal
Target:	Anima Companion
Duration:	Instantaneous
Saving Throw: 	Will negates
Spell Resistance:No

You awaken your animal companion to humanlike sentience.
To succeed, you must make a Will save (DC 10 + the animal’s current HD).
If successful your companion gains +4 Strength, +4 Constitution, +1d10 Wisdom,
and +2 to attack rolls for as long as it remains at your side.
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
    Spell.iAreaShape = SHAPE_PERSONAL;
    Spell.iObjectFilter = OBJECT_TYPE_CREATURE;
    Spell.iTargetType = TARGET_TYPE_ALLIES;
    Spell.iDurationType = DURATION_TYPE_PERMANENT;
    Spell.iSave = SAVING_THROW_WILL;
    Spell.iImpact = VFX_IMP_HOLY_AID;
    // Setup the spell.
    Spell = SetSpell (Spell);
    // Check to see if we should still fire off the spell.
    if (Spell.iSpellID == STOP_SPELL) return;
    // *******************************************************************
    // ********************** Spell effects ******************************
    // *******************************************************************
    // Create variables.
    effect eWis, eLink2;
    int iWis;
    object oCompanion;
    // Create visual effects.
    effect eImpact = EffectVisualEffect(Spell.iImpact);
    // Create effects.
    effect eStr = EffectAbilityIncrease(ABILITY_STRENGTH, 4);
    effect eCon = EffectAbilityIncrease(ABILITY_CONSTITUTION, 4);
    effect eDuration = EffectVisualEffect(VFX_DUR_CESSATE_POSITIVE);
    effect eAttack = EffectAttackIncrease(2);
    // Link effects.
    effect eLink = EffectLinkEffects (eStr, eCon);
    eLink = EffectLinkEffects (eLink, eAttack);
    eLink = EffectLinkEffects (eLink, eDuration);
    //Get the spells target(s).
    Spell = GetSpellTarget (Spell);
    while(GetIsObjectValid(Spell.oAreaTarget))
    {
        oCompanion = GetAssociate (ASSOCIATE_TYPE_ANIMALCOMPANION, Spell.oAreaTarget);
        if (!GetHasSpellEffect (SPELL_AWAKEN, oCompanion))
        {
            //Fire cast spell at event for the specified target
            SignalEvent (oCompanion, EventSpellCastAt (Spell.oCaster, Spell.iSpellID, FALSE));
            // Get Wisdom bonus.
            iWis = d10();
            //Enter Metamagic conditions
            if (Spell.iMetaMagic == METAMAGIC_MAXIMIZE) iWis = 10; // Maximimize
            else if (Spell.iMetaMagic == METAMAGIC_EMPOWER) iWis = iWis + (iWis / 2); // +50%
            eWis = EffectAbilityIncrease (ABILITY_WISDOM, iWis);
            eLink2 = EffectLinkEffects(eLink, eWis);
            eLink2 = SupernaturalEffect(eLink2);
            //Apply the VFX impact and effects
            DelayCommand (Spell.fDelay, ApplyEffectToObject(DURATION_TYPE_INSTANT, eImpact, oCompanion));
            DelayCommand (Spell.fDelay, ApplyEffectToObject(Spell.iDurationType, eLink2, oCompanion));
        }
        //Get the spells target(s).
        Spell = GetSpellTarget (Spell);
    }
    CleanUpSpell (Spell);
}
