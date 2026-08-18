/*////////////////////////////////////////////////
 Script: NW_S0_Bless.nss
 Programmer: Preston Watamaniuk
////////////////////////////////////////////////
Enchantment (Compulsion) [Mind-Affecting]
Level: Clr 1, Pal 1
Components: V, S, DF
Casting Time: 1 standard action
Range: Long
Area: The caster and all allies within a 50-ft. burst, centered on the caster
Duration: 1 minue / level
Saving Throw: None
Spell Resistance: Yes (harmless)
Bless fills your allies with courage. Each ally gains a +1 morale bonus on
attack rolls and on saving throws against fear effects.
/*///////////////////////////////////////////////
#include "0i_spells"
#include "x2_inc_itemprop"
void main()
{
    // ***********************************************************
    // *************** Set Spell Structure ***********************
    // ***********************************************************
    // Setup the spell in the structured variables, then pass through the SetSpell function.
    Spell.iSubType = SUBTYPE_MAGICAL;
    Spell.iSubSchool = SUBSCHOOL_COMPULSION;
    Spell.iDescriptor = DESC_MIND;
    Spell.iDivineFocus = TRUE;
    Spell.iAreaShape = SHAPE_SPHERE;
    Spell.fAreaSize = 50.0f;
    Spell.iLineOfSight = FALSE;
    Spell.iObjectFilter = OBJECT_TYPE_CREATURE;
    Spell.iTargetType = TARGET_TYPE_ALLIES;
    Spell.iDurationType = DURATION_TYPE_MINUTES;
    Spell.iDuration = 1;
    Spell.iDurPerLvl = 1;
    Spell.iModifier = 1;
    Spell.iImpact = VFX_IMP_HEAD_HOLY;
    // Setup the spell.
    Spell = SetSpell (Spell);
    // Check to see if we should still fire off the spell.
    if (Spell.iSpellID == STOP_SPELL) return;
    // Get the duration of the spell.
    Spell = GetDuration (Spell);
    // Get the modifier for the effect.
    Spell = GetModifier (Spell);
    // *******************************************************************
    // ********************** Spell effects ******************************
    // *******************************************************************
    // Create visual effects.
    effect eCenter = EffectVisualEffect (VFX_FNF_LOS_HOLY_30);
    effect eImpact = EffectVisualEffect (Spell.iImpact);
    effect eDuration = EffectVisualEffect (VFX_DUR_CESSATE_POSITIVE);
    // Was the object target an Item?
    if (GetObjectType(Spell.oTarget) == OBJECT_TYPE_ITEM)
    {
        // special handling for blessing crossbow bolts that can slay rakshasa's
        if (GetBaseItemType(Spell.oTarget) ==  BASE_ITEM_BOLT)
        {
           SignalEvent (GetItemPossessor (Spell.oTarget), EventSpellCastAt (Spell.oCaster, Spell.iSpellID, FALSE));
           IPSafeAddItemProperty (Spell.oTarget, ItemPropertyOnHitCastSpell(IP_CONST_ONHIT_CASTSPELL_ONHIT_SLAYRAKSHASA, 1), Spell.fDuration, X2_IP_ADDPROP_POLICY_KEEP_EXISTING );
           ApplyEffectToObject(DURATION_TYPE_INSTANT, eImpact, GetItemPossessor (Spell.oTarget));
           ApplyEffectToObject(DURATION_TYPE_TEMPORARY, eDuration, GetItemPossessor (Spell.oTarget), Spell.fDuration);
           return;
        }
    }
    // If not cast on an item then it is cast from the caster, thus change target to caster.
    Spell.oTarget = Spell.oCaster;
    Spell.lTarget = GetLocation (Spell.oCaster);
    // Create effects.
    effect eAttack = EffectAttackIncrease (Spell.iResult);
    effect eSave = EffectSavingThrowIncrease (SAVING_THROW_ALL, Spell.iResult, SAVING_THROW_TYPE_FEAR);
    // Link effects.
    effect eLink = EffectLinkEffects (eAttack, eSave);
    eLink = EffectLinkEffects(eLink, eDuration);
    eLink = SetEffectCasterLevel(eLink, Spell.iCasterLevel);
    // Apply visual effect at the center of the effect area.
    ApplyEffectAtLocation (DURATION_TYPE_INSTANT, eCenter, Spell.lTarget);
    //Get the spells target(s).
    Spell = GetSpellTarget (Spell);
    while(GetIsObjectValid(Spell.oAreaTarget))
    {
        // Fire spell cast at event for target
        SignalEvent (Spell.oAreaTarget, EventSpellCastAt (Spell.oCaster, Spell.iSpellID, FALSE));
        // Remove any previously cast spell on this target.
        RemoveSpellEffects (Spell.iSpellID, Spell.oAreaTarget);
        // Apply VFX impact
        DelayCommand (Spell.fDelay, ApplyEffectToObject(DURATION_TYPE_INSTANT, eImpact, Spell.oAreaTarget));
        // Apply the effect.
        DelayCommand (Spell.fDelay, ApplyEffectToObject(Spell.iDurationType, eLink, Spell.oAreaTarget, Spell.fDuration));
        //Get the spells target(s).
        Spell = GetSpellTarget (Spell);
    }
    if (Spell.iSpellID == 958/*Imbue_with_Spell_Ability_Bless*/)
        NWNX_Creature_RemoveFeat (Spell.oCaster, 1546/*FEAT_IWSA_Cast_Bless*/);
    CleanUpSpell (Spell);
}

