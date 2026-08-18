/*////////////////////////////////////////////////
 Script: 0s_fan_machine
 Programmer: Philos
////////////////////////////////////////////////
Illusion (Shadow)
Level: Craft 6, Gnome 6
Components: V, S, DF
Casting Time: 1 action
Range: Medium
Target: One machine
Duration: 1 minute / level
Saving Throw: None
Spell Resistance: No

You create an illusionary noisy mechanical construct of impressively massive
appearance to attack your enemies.
It can slam opponents or hurl rocks at them.
/*///////////////////////////////////////////////
#include "0i_spells"

void main()
{
    // ***********************************************************
    // *************** Set Spell Structure ***********************
    // ***********************************************************
    // Setup the spell in the structured variables, then pass through the SetSpell function.
    Spell.iSubType = SUBTYPE_MAGICAL;
    Spell.iSubSchool = SUBSCHOOL_SHADOW;
    Spell.iDivineFocus = TRUE;
    Spell.iDurationType = DURATION_TYPE_MINUTES;
    Spell.iDuration = 1;
    Spell.iDurPerLvl = 1;
    // Setup the spell.
    Spell = SetSpell(Spell);
    // Check to see if we should still fire off the spell.
    if (Spell.iSpellID == STOP_SPELL) return;
    // Get the duration of the spell, sets Spell.fDuration.
    Spell = GetDuration(Spell);
    // *******************************************************************
    // ********************** Spell effects ******************************
    // *******************************************************************
    // Get the casters summons selected summons or select a default.
    // Casters can select a summons via the Players Handbook.
    int nIndex = 1;
    string sResRef;
    object oCreature;
    effect eSummons, eVisual;
    eSummons = EffectVisualEffect(VFX_DUR_GHOST_TRANSPARENT);
    eSummons = EffectLinkEffects(EffectCutsceneGhost(), eSummons);
    eSummons = EffectLinkEffects(EffectRunScript("", "0e_removesummons"), eSummons);
    // Remove any old Fantastic machines.
    oCreature = GetAssociate(ASSOCIATE_TYPE_HENCHMAN, Spell.oCaster, nIndex);
    while(oCreature != OBJECT_INVALID)
    {
        sResRef = GetResRef(oCreature);
        if(sResRef == "0_fan_machine" || sResRef == "0_g_fan_machine")
        {
            SetIsDestroyable(TRUE, FALSE, FALSE, oCreature );
            eVisual = EffectVisualEffect(VFX_IMP_UNSUMMON);
            ApplyEffectAtLocation(DURATION_TYPE_INSTANT, eVisual, GetLocation(oCreature));
            DestroyObject(oCreature);
        }
        oCreature = GetAssociate(ASSOCIATE_TYPE_HENCHMAN, Spell.oCaster, ++nIndex);
    }
    effect eImpact = EffectVisualEffect(VFX_FNF_SUMMON_MONSTER_3);
    if(Spell.iSpellID == 946/*SPELL_FANTATSIC_MACHINE*/) sResRef = "0_fan_machine";
    else if(Spell.iSpellID == 947/*SPELL_GREATER_FANTATSIC_MACHINE*/) sResRef = "0_g_fan_machine";
    if(sResRef == "") return;
    oCreature = CreateObject(OBJECT_TYPE_CREATURE, sResRef, Spell.lTarget);
    ApplyEffectAtLocation(DURATION_TYPE_INSTANT, eImpact, Spell.lTarget);
    eSummons = SetEffectCasterLevel(eSummons, Spell.iCasterLevel);
    ApplyEffectToObject(DURATION_TYPE_TEMPORARY, eSummons, oCreature, Spell.fDuration);
    AddHenchman(Spell.oCaster, oCreature);
    // Must mark them as a summons.
    SetLocalInt(oCreature, "0_Summon_ID", Spell.iSpellID);
    CleanUpSpell(Spell);
}


