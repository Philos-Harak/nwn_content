/*////////////////////////////////////////////////
 Script Name: NW_S0_CloudKillac.nss
 Programmer: Preston Watamaniuk
////////////////////////////////////////////////
Conjuration (Creation)
Level:  Sor/Wiz 5
Components: V, S
Casting Time:   1 standard action
Range:  Medium (100 ft. + 10 ft./level)
Effect: Cloud spreads in 20-ft. radius, 20 ft. high
Duration:   1 min./level
Saving Throw:   Fortitude partial; see text
Spell Resistance:   No
This spell generates a bank of fog, similar to a fog cloud, except that its
vapors are yellowish green and poisonous. These vapors automatically kill any
living creature with 3 or fewer HD (no save). A living creature with 4 to 6 HD
is slain unless it succeeds on a Fortitude save (in which case it takes 1d4
points of Constitution damage on your turn each round while in the cloud).

A living creature with 6 or more HD takes 1d4 points of Constitution damage on
your turn each round while in the cloud (a successful Fortitude save halves
this damage). Holding one’s breath doesn’t help, but creatures immune to poison
are unaffected by the spell.
/*///////////////////////////////////////////////
#include "0i_spells"

void main()
{
    object oTarget;
    int iHD, iDmg, iMetaMagic = GetMetaMagicFeat();;
    effect eDeath = EffectDeath ();
    effect eImpactDeath = EffectVisualEffect (VFX_IMP_DEATH);
    effect eImpactNegative = EffectVisualEffect (VFX_IMP_NEGATIVE_ENERGY);
    effect eDmg;
    float fDelay;
    //--------------------------------------------------------------------------
    // GZ 2003-Oct-15
    // When the caster is no longer there, all functions calling
    // GetAreaOfEffectCreator will fail. Its better to remove the spell then
    //--------------------------------------------------------------------------
    if (!GetIsObjectValid(GetAreaOfEffectCreator()))
    {
        DestroyObject(OBJECT_SELF);
        return;
    }
    //Get the first object in the persistant AOE
    oTarget = GetFirstInPersistentObject();
    while (GetIsObjectValid(oTarget))
    {
        fDelay = GetRandomDelay();
        iHD = GetHitDice (oTarget);
        //Fire cast spell at event for the specified target
        SignalEvent (oTarget, EventSpellCastAt (OBJECT_SELF, SPELL_CLOUDKILL));
        //Determine spell effect based on the targets HD
        if (iHD <= 3)
        {
            if (!GetIsImmune (oTarget, IMMUNITY_TYPE_POISON))
            {
                DelayCommand (fDelay, ApplyEffectToObject (DURATION_TYPE_INSTANT, eImpactDeath, oTarget));
                DelayCommand (fDelay, ApplyEffectToObject (DURATION_TYPE_INSTANT, eDeath, oTarget));
            }
        }
        else if (iHD >= 4 && iHD <= 6)
        {
            // Make a save or die
            if (!SavingThrowWithEffects (SAVING_THROW_FORT, oTarget, GetSpellSaveDC(), SAVING_THROW_TYPE_DEATH, OBJECT_SELF, fDelay))
            {
                DelayCommand(fDelay, ApplyEffectToObject(DURATION_TYPE_INSTANT, eImpactDeath, oTarget));
                DelayCommand(fDelay, ApplyEffectToObject(DURATION_TYPE_INSTANT, eDeath, oTarget));
            }
            // If the save is made then do constitution damage.
            else
            {
                DelayCommand (fDelay, ApplyEffectToObject(DURATION_TYPE_INSTANT, eImpactNegative, oTarget));
                DelayCommand (fDelay, ApplyEffectToObject(DURATION_TYPE_INSTANT, eDmg, oTarget));
            }
        }
        // over 6 hit dice.
        else
        {
            // Make fortitude save to halve the constitution damage.
            if (SavingThrowWithEffects (SAVING_THROW_FORT, oTarget, GetSpellSaveDC(), SAVING_THROW_TYPE_DEATH, OBJECT_SELF, fDelay))
            {
                iDmg = iDmg / 2;
                if (iDmg = 0) iDmg = 1;
                eDmg = EffectAbilityDecrease (IP_CONST_ABILITY_CON, iDmg);
            }
            DelayCommand(fDelay, ApplyEffectToObject(DURATION_TYPE_INSTANT, eImpactNegative, oTarget));
            DelayCommand(fDelay, ApplyEffectToObject(DURATION_TYPE_INSTANT, eDmg, oTarget));
        }
        //Get the next target in the AOE
        oTarget = GetNextInPersistentObject();
    }
}
