/*////////////////////////////////////////////////
Script Name:NW_S0_WarCry
Programmer: Preston Watamaniuk
////////////////////////////////////////////////
Caster Level(s): Bard 4
Innate Level: 4
School: Enchantment
Descriptor(s): Mind-Affecting, Sonic
Component(s): Verbal, Somatic
Range: Personal
Area of Effect / Target: Colossal
Duration: 1 Round / Level
Additional Counter Spells: Silence
Save: Will Negates
Spell Resistance: Yes

The caster lets out a powerful shout that grants the Bard a +2 bonus to attack
and damage. All enemies within the area of effect are stricken with fear.
/*///////////////////////////////////////////////
#include "0i_spells"

void main()
{
    // ***********************************************************
    // *************** Set Spell Structure ***********************
    // ***********************************************************
    // Setup the spell in the structured variables, then pass through the SetSpell function.
    Spell.iSubType = SUBTYPE_MAGICAL;
    Spell.iDescriptor = DESC_MIND;
    Spell.iAreaShape = SHAPE_SPHERE;
    Spell.fAreaSize = 30.0f;
    Spell.iObjectFilter = OBJECT_TYPE_CREATURE;
    Spell.iTargetType = TARGET_TYPE_ENEMIES;
    Spell.iDurationType = DURATION_TYPE_ROUNDS;
    Spell.iDuration = 1;
    Spell.iDurPerLvl = 1;
    Spell.iSpellResistance = TRUE;
    Spell.iSave = SAVING_THROW_WILL;
    Spell.iSaveType = SAVING_THROW_TYPE_MIND_SPELLS;
    Spell.iImpact = VFX_IMP_HEAD_SONIC;
    // Setup the spell.
    Spell = SetSpell (Spell);
    // Check to see if we should still fire off the spell.
    if (Spell.iSpellID == STOP_SPELL) return;
    // Get the duration of the spell, sets Spell.fDuration.
    Spell = GetDuration (Spell);
    // *******************************************************************
    // ********************** Spell effects ******************************
    // *******************************************************************
    // Create effects;
    effect eAttack = EffectAttackIncrease (2);
    effect eDamage = EffectDamageIncrease (2, DAMAGE_TYPE_SLASHING);
    effect eFear = EffectFrightened();
    // Create visual effects;
    effect eImpact = EffectVisualEffect (Spell.iImpact);
    effect eVisFear = EffectVisualEffect (VFX_DUR_MIND_AFFECTING_FEAR);
    effect ePoint;
    if (GetGender(OBJECT_SELF) == GENDER_FEMALE)  ePoint = EffectVisualEffect(290);
    else ePoint = EffectVisualEffect(VFX_FNF_HOWL_WAR_CRY);
    effect eDur = EffectVisualEffect(VFX_DUR_CESSATE_NEGATIVE);
    effect eDur2 = EffectVisualEffect(VFX_DUR_CESSATE_POSITIVE);
    // Link effects.
    effect eLink = EffectLinkEffects (eAttack, eDamage);
    eLink = SetEffectCasterLevel(eLink, Spell.iCasterLevel);
    eLink = EffectLinkEffects(eLink, eDur2);
    eLink = EffectLinkEffects (eLink, eDur);
    effect eLink2 = EffectLinkEffects (eVisFear, eFear);
    eLink = SetEffectCasterLevel(eLink, Spell.iCasterLevel);
    eLink2 = SetEffectCasterLevel(eLink2, Spell.iCasterLevel);
    //Apply Point effects.
    ApplyEffectAtLocation (DURATION_TYPE_INSTANT, ePoint, Spell.lTarget);
    //Get the spells target(s).
    Spell = GetSpellTarget (Spell);
    while(GetIsObjectValid(Spell.oAreaTarget))
    {
        //Fire cast spell at event for the specified target
        SignalEvent (Spell.oAreaTarget, EventSpellCastAt (Spell.oCaster, Spell.iSpellID));
        // Make a resistance and save check.
        Spell = ResistAndSave (Spell);
        if (!Spell.iSaveResult)
        {
           //Apply the linked effects and the VFX impact
           DelayCommand (Spell.fDelay, ApplyEffectToObject (Spell.iDurationType, eLink2, Spell.oAreaTarget, Spell.fDuration));
        }
        //Get the spells target(s).
        Spell = GetSpellTarget (Spell);
    }
    //Apply bonus and VFX effects to bard.
    RemoveSpellEffects (Spell.iSpellID, Spell.oCaster);
    ApplyEffectToObject (DURATION_TYPE_INSTANT, eImpact, Spell.oCaster);
    DelayCommand (0.01, ApplyEffectToObject (Spell.iDurationType, eLink, Spell.oCaster, Spell.fDuration));
    SignalEvent (Spell.oCaster, EventSpellCastAt (Spell.oCaster, Spell.iSpellID, FALSE));
    CleanUpSpell (Spell);
}
