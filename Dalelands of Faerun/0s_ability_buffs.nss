/*////////////////////////////////////////////////
 Script: 0s_ability_buffs
 Programmer: Brenon Holmes
/////////////////////////////////////////////////
Transmutation
Level:  Varies
Components: V, S, M/DF
Casting Time:   1 standard action
Range:  Touch
Target: Creature touched
Duration:   varies by spell.
Saving Throw:   Will negates (harmless)
Spell Resistance:   Yes (harmless)

The subjects ability score becomes better.

These spells grant an enhancement bonus to ,an ability score, adding
the usual benefits to melee attack rolls, melee damage rolls, and other uses of
an ability modifier.

The general spells grant a +4 and has a duraton of 1 round per level.

The greater spells grant a +6 and has a duration of 1 hour per level.

Arcane Material Components vary by spell.
/*////////////////////////////////////////////////
#include "0i_spells"
void main()
{
    // ***********************************************************
    // *************** Set Spell Structure ***********************
    // ***********************************************************
    // Setup the spell in the structured variables, then pass through the SetSpell function.
    Spell.iSubType = SUBTYPE_MAGICAL;
    Spell.sArcaneComponent = COMPONENT_POUCH;
    Spell.iDivineFocus = TRUE;
    Spell.sEnhancingComp = "ruby_dust";
    Spell.iCompAmount = 20; // 500gp worth of Ruby Dust.
    Spell.iAreaShape = SHAPE_TOUCH_TARGET;
    Spell.iObjectFilter = OBJECT_TYPE_CREATURE;
    Spell.iTargetType = TARGET_TYPE_ALL;
    Spell.iDuration = 1;
    Spell.iDurPerLvl = 1;
    int nSpellCheck, nNormalAbilityBoost;
    // Set which spell this is structure variables.
    int iAbility;
    switch (GetSpellId ())
    {
        case SPELL_BULLS_STRENGTH :
        {
            Spell.iImpact = 1010;
            Spell.iDurationType = DURATION_TYPE_MINUTES;
            iAbility = ABILITY_STRENGTH;
            Spell.iModifier = 4;
            nSpellCheck = SPELL_GREATER_BULLS_STRENGTH;
            nNormalAbilityBoost = TRUE;
            break;
        }
        case SPELL_CATS_GRACE :
        {
            Spell.iImpact = 1011;
            Spell.iDurationType = DURATION_TYPE_MINUTES;
            iAbility = ABILITY_DEXTERITY;
            Spell.iModifier = 4;
            nSpellCheck = SPELL_GREATER_CATS_GRACE;
            nNormalAbilityBoost = TRUE;
            break;
        }
        case SPELL_ENDURANCE :
        {
            Spell.iImpact = 1012;
            Spell.iDurationType = DURATION_TYPE_MINUTES;
            iAbility = ABILITY_CONSTITUTION;
            Spell.iModifier = 4;
            nSpellCheck = SPELL_GREATER_ENDURANCE;
            nNormalAbilityBoost = TRUE;
            break;
        }
        case SPELL_FOXS_CUNNING :
        {
            Spell.iImpact = 1013;
            Spell.iDurationType = DURATION_TYPE_MINUTES;
            iAbility = ABILITY_INTELLIGENCE;
            Spell.iModifier = 4;
            nSpellCheck = SPELL_GREATER_CATS_GRACE;
            nNormalAbilityBoost = TRUE;
            break;
        }
        case SPELL_OWLS_WISDOM :
        {
            Spell.iImpact = 1014;
            Spell.iDurationType = DURATION_TYPE_MINUTES;
            iAbility = ABILITY_WISDOM;
            Spell.iModifier = 4;
            nSpellCheck = SPELL_GREATER_OWLS_WISDOM;
            nNormalAbilityBoost = TRUE;
            break;
        }
        case SPELL_EAGLE_SPLEDOR :
        {
            Spell.iImpact = 1015;
            Spell.iDurationType = DURATION_TYPE_MINUTES;
            iAbility = ABILITY_CHARISMA;
            Spell.iModifier = 4;
            nSpellCheck = SPELL_GREATER_EAGLE_SPLENDOR;
            nNormalAbilityBoost = TRUE;
            break;
        }
        case SPELL_GREATER_BULLS_STRENGTH :
        {
            Spell.iImpact = 1010;
            Spell.iDurationType = DURATION_TYPE_HOURS;
            iAbility = ABILITY_STRENGTH;
            Spell.iModifier = 6;
            nSpellCheck = SPELL_BULLS_STRENGTH;
            break;
        }
        case SPELL_GREATER_CATS_GRACE :
        {
            Spell.iImpact = 1011;
            Spell.iDurationType = DURATION_TYPE_HOURS;
            iAbility = ABILITY_DEXTERITY;
            Spell.iModifier = 6;
            nSpellCheck = SPELL_CATS_GRACE;
            break;
        }
        case SPELL_GREATER_ENDURANCE :
        {
            Spell.iImpact = 1012;
            Spell.iDurationType = DURATION_TYPE_HOURS;
            iAbility = ABILITY_CONSTITUTION;
            Spell.iModifier = 6;
            nSpellCheck = SPELL_ENDURANCE;
            break;
        }
        case SPELL_GREATER_FOXS_CUNNING :
        {
            Spell.iImpact = 1013;
            Spell.iDurationType = DURATION_TYPE_HOURS;
            iAbility = ABILITY_INTELLIGENCE;
            Spell.iModifier = 6;
            nSpellCheck = SPELL_FOXS_CUNNING;
            break;
        }
        case SPELL_GREATER_OWLS_WISDOM :
        {
            Spell.iImpact = 1014;
            Spell.iDurationType = DURATION_TYPE_HOURS;
            iAbility = ABILITY_WISDOM;
            Spell.iModifier = 6;
            nSpellCheck = SPELL_OWLS_WISDOM;
            break;
        }
        case SPELL_GREATER_EAGLE_SPLENDOR :
        {
            Spell.iImpact = 1015;
            Spell.iDurationType = DURATION_TYPE_HOURS;
            iAbility = ABILITY_CHARISMA;
            Spell.iModifier = 6;
            nSpellCheck = SPELL_EAGLE_SPLEDOR;
            break;
        }
        case 964/*SPELL_CHARM_DOMAIN_POWER*/ :
        {
            Spell.iImpact = 1015;
            Spell.sArcaneComponent = "";
            Spell.iDivineFocus = FALSE;
            Spell.iAreaShape = SHAPE_PERSONAL;
            Spell.iObjectFilter = 0;
            Spell.iTargetType = 0;
            int nDeity, bHasDomain;
            if(GetIsCharacter(Spell.oCaster))
            {
                nDeity = GetObjectDatabaseInt (Spell.oCaster, CHARACTER_TABLE, "deity");
                bHasDomain = StringToInt (Get2DAString ("deities", "Charm_Domain", nDeity));
            }
            // All NPC's are assumed to have the Deity of their selected domains.
            else bHasDomain = TRUE;
            if (bHasDomain) Spell.iDurationType = DURATION_TYPE_HOURS;
            else Spell.iDurationType = DURATION_TYPE_MINUTES;
            Spell.iDurPerLvl = 0;
            iAbility = ABILITY_CHARISMA;
            Spell.iModifier = 4;
            break;
        }
    }
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
    if(Spell.sEnhancingComp == "TRUE") Spell.iResult += 2;
    effect eImpact = EffectVisualEffect (Spell.iImpact);
    effect eDur = EffectVisualEffect (VFX_DUR_CESSATE_POSITIVE);
    effect eAbility = EffectAbilityIncrease (iAbility,Spell.iResult);
    effect eLink = EffectLinkEffects (eAbility, eDur);
    eLink = SetEffectCasterLevel(eLink, Spell.iCasterLevel);
    //Get the spells target(s).
    Spell = GetSpellTarget (Spell);
    while(GetIsObjectValid (Spell.oAreaTarget))
    {
        //Signal the spell cast at event
        SignalEvent(Spell.oAreaTarget, EventSpellCastAt (Spell.oCaster, Spell.iSpellID, FALSE));
        RemoveSpellEffects(Spell.iSpellID, Spell.oAreaTarget);
        if(!nNormalAbilityBoost) RemoveSpellEffects(nSpellCheck, Spell.oAreaTarget);
        // If we are casting a normal ability boost lets not remove the greater one.
        if(nNormalAbilityBoost && !GetHasSpellEffect(nSpellCheck, Spell.oAreaTarget) ||
           !nNormalAbilityBoost)
        {
            DelayCommand (Spell.fDelay, ApplyEffectToObject (Spell.iDurationType, eLink, Spell.oAreaTarget, Spell.fDuration));
            DelayCommand (Spell.fDelay, ApplyEffectToObject (DURATION_TYPE_INSTANT, eImpact, Spell.oAreaTarget));
        }
        //Get the spells target(s).
        Spell = GetSpellTarget (Spell);
    }
    CleanUpSpell (Spell);
}
