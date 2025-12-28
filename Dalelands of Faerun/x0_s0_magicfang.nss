/*////////////////////////////////////////////////
 Script: x0_s0_magicfang.nss
 Programmer: Brent Knowles
////////////////////////////////////////////////
Transmutation
Level:  Drd 1, Rgr 1
Components: V, S, DF
Casting Time:   1 standard action
Range:  Touch
Target: Living creature touched
Duration:   1 min./level
Saving Throw:   Will negates (harmless)
Spell Resistance:   Yes (harmless)

Magic fang gives one natural weapon of your animal companion a +1 enhancement
bonus on attack and damage rolls. The spell can affect a slam attack, fist,
bite, or other natural weapon.
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
    Spell.iAreaShape = SHAPE_TOUCH_TARGET;
    Spell.iDurationType = DURATION_TYPE_MINUTES;
    Spell.iDuration = 1;
    Spell.iDurPerLvl = 1;
    Spell.iModifier = 1;
    Spell.iImpact = VFX_IMP_HOLY_AID;
    // Setup the spell.
    Spell = SetSpell (Spell);
    // Check to see if we should still fire off the spell.
    if (Spell.iSpellID == STOP_SPELL) return;
    // Get the duration of the spell.
    Spell = GetDuration (Spell);
    // *******************************************************************
    // ********************** Spell effects ******************************
    // *******************************************************************
    effect eAttack, eDamage, eReduction, eLink;
    effect eImpact = EffectVisualEffect (Spell.iImpact);
    effect eDur = EffectVisualEffect (VFX_DUR_CESSATE_POSITIVE);
    //Get the spells target(s).
    Spell = GetSpellTarget (Spell);
    while(GetIsObjectValid(Spell.oAreaTarget))
    {
        // Spell only works on animal companions.
        Spell.oAreaTarget = GetAssociate (ASSOCIATE_TYPE_ANIMALCOMPANION);
        if (!GetIsObjectValid (Spell.oAreaTarget))
        {
            DelayCommand (Spell.fDelay, FloatingTextStrRefOnCreature (8962, Spell.oAreaTarget, FALSE));
            return;
        }
        // Remove any previously cast spell on this target.
        RemoveSpellEffects (Spell.iSpellID, Spell.oCaster, Spell.oAreaTarget);
        // Also check for greater magic fang.
        RemoveSpellEffects (SPELL_GREATER_MAGIC_FANG, Spell.oCaster, Spell.oAreaTarget);
        //Fire spell cast at event for target
        SignalEvent (Spell.oAreaTarget, EventSpellCastAt (Spell.oCaster, Spell.iSpellID, FALSE));
        // Get the modifier for the effect, sets Spell.iResult.
        Spell = GetModifier (Spell);
        // Create effects and link.
        // Add damage reduction to give creature ability to damage damage reduction creatures.
        eReduction = EffectDamageReduction(Spell.iResult, DAMAGE_POWER_PLUS_ONE);
        eAttack = EffectAttackIncrease (Spell.iResult);
        eDamage = EffectDamageIncrease (Spell.iResult);
        eLink = EffectLinkEffects (eAttack, eDur);
        eLink = EffectLinkEffects (eLink, eDamage);
        eLink = EffectLinkEffects (eLink, eReduction);
        //Apply VFX impact and bonus effects
        DelayCommand (Spell.fDelay, ApplyEffectToObject (DURATION_TYPE_INSTANT, eImpact, Spell.oAreaTarget));
        DelayCommand (Spell.fDelay, ApplyEffectToObject (Spell.iDurationType, eLink, Spell.oAreaTarget, Spell.fDuration));
        //Get the spells target(s).
        Spell = GetSpellTarget (Spell);
    }
    CleanUpSpell (Spell);
}






