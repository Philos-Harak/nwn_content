/*////////////////////////////////////////////////
 Script Name: x0_s0_gmagicfang
 Programmer: Brent Knowles
////////////////////////////////////////////////
Caster Level(s): Druid 3,  Ranger 3
Innate Level: 3
School: Transmutation
Component(s): Verbal, Somatic, Divine Focus
Range: Personal
Area of Effect / Target: Caster
Duration: 1 Hour / level
Save: None
Spell Resistance: No

This spell strengthens the caster's animal companion, giving it +1 to hit and
+1 to damage for every three levels of the caster (maximum of +5).
It also grants the creature an enchantment bonus equal to the hit/damage bonus
given.
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
    Spell.iDurationType = DURATION_TYPE_HOURS;
    Spell.iDuration = 1;
    Spell.iDurPerLvl = 1;
    Spell.iModifier = 1;
    Spell.iModPerLvl = 4;
    Spell.iMaxModifier = 5;
    // Setup the spell.
    Spell = SetSpell (Spell);
    // Check to see if we should still fire off the spell.
    if (Spell.iSpellID == STOP_SPELL) return;
    // Get the duration of the spell, sets Spell.fDuration.
    Spell = GetDuration (Spell);
    // Get the result for the effect, sets Spell.iResult.
    Spell = GetModifier (Spell);
    // *******************************************************************
    // ********************** Spell effects ******************************
    // *******************************************************************
    int iDamagePower;
    switch (Spell.iResult)
    {
        case 1: iDamagePower = DAMAGE_POWER_PLUS_ONE; break;
        case 2: iDamagePower = DAMAGE_POWER_PLUS_TWO; break;
        case 3: iDamagePower = DAMAGE_POWER_PLUS_THREE; break;
        case 4: iDamagePower = DAMAGE_POWER_PLUS_FOUR; break;
        case 5: iDamagePower = DAMAGE_POWER_PLUS_FIVE; break;
        default : iDamagePower = DAMAGE_POWER_PLUS_ONE; break;
    }
    object oTarget = GetAssociate (ASSOCIATE_TYPE_ANIMALCOMPANION);
    // Does not have an animal companion.
    if (oTarget == OBJECT_INVALID)
    {
        FloatingTextStrRefOnCreature(8962, OBJECT_SELF, FALSE);
        return;
    }
    //Remove effects of anyother fang spells
    RemoveSpellEffects (452, oTarget);
    RemoveSpellEffects (453, oTarget);
    // Setup effects.
    effect eVis = EffectVisualEffect (VFX_IMP_HOLY_AID);
    effect eAttack = EffectAttackIncrease (Spell.iResult);
    effect eDamage = EffectDamageIncrease (Spell.iResult);
    // Use this to create a true enhancement bonus.
    effect eReduction = EffectDamageReduction(Spell.iResult, iDamagePower);
    effect eDur = EffectVisualEffect (VFX_DUR_CESSATE_POSITIVE);
    // Link the effects.
    effect eLink = EffectLinkEffects(eAttack, eDur);
    eLink = EffectLinkEffects(eLink, eDamage);
    eLink = EffectLinkEffects(eLink, eReduction);
    eLink = SetEffectCasterLevel(eLink, Spell.iCasterLevel);
    //Fire spell cast at event for target
    SignalEvent (oTarget, EventSpellCastAt (Spell.oCaster, Spell.iSpellID, FALSE));
    //Apply VFX impact and bonus effects
    ApplyEffectToObject (DURATION_TYPE_INSTANT, eVis, oTarget);
    ApplyEffectToObject (DURATION_TYPE_TEMPORARY, eLink, oTarget, Spell.fDuration);
    CleanUpSpell (Spell);
}
