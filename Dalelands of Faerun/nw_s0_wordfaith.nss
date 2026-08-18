/*////////////////////////////////////////////////
 Script: nw_s0_wordfaith
 Programmer: Preston Watamaniuk
////////////////////////////////////////////////
Caster Level(s): Cleric 7
Innate Level: 7
School: Evocation
Descriptor(s): See below.
Component(s): Verbal, Somatic, Divine Focus
Range: Medium
Area of Effect / Target: Colossal
Duration: Instant or 1 round / 2 levels
Save: None
Spell Resistance: Yes

A wave of divine or negative energy blasts all enemy creatures within the area
of effect. All enemies suffer the following effects based on its hit dice  and
alignment compaired to the level of the caster. And all enemy summoned creatures
are returned to their home plane if they fail a will save.
Any creature with more hit dice than the caster are not effected.

Word of Chaos effects all non chaotic creatures.
Word of Evil effects all non evil creatures.
Word of Good effects all non good creatures.
Word of Law effects all non lawful creatures.

HitDice equal to the casters level are deafened, no save.
HitDice 1 less than the casters level are stunned and deafened no save.
HitDice 5 less than the casters level confused and deafened no save.
HitDice 10 less than the casters level are killed no save.
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
    Spell.iAreaShape = SHAPE_SPHERE;
    Spell.fAreaSize = 30.0f;
    Spell.iLineOfSight = TRUE;
    Spell.iObjectFilter = OBJECT_TYPE_CREATURE;
    Spell.iTargetType = TARGET_TYPE_ENEMIES;
    Spell.iDurationType = DURATION_TYPE_ROUNDS;
    Spell.iDuration = 1;
    Spell.iDurPerLvl = 2;
    Spell.iSpellResistance = TRUE;
    // Get the spell cast.
    int nLawChaos, nGoodEvil;
    int iSpellID = GetSpellId ();
    if (iSpellID == 939/*SPELL_WORD_OF_GOOD*/)
    {
        Spell.iDescriptor = DESC_GOOD;
        Spell.iImpact = VFX_IMP_SONIC;
        nLawChaos = ALIGNMENT_ALL;
        nGoodEvil = ALIGNMENT_GOOD;
    }
    else if (iSpellID == 938/*SPELL_WORD_OF_EVIL*/)
    {
        Spell.iDescriptor = DESC_EVIL;
        Spell.iImpact = VFX_IMP_SONIC;
        nLawChaos = ALIGNMENT_ALL;
        nGoodEvil = ALIGNMENT_EVIL;
    }
    else if (iSpellID == 937/*SPELL_WORD_OF_CHAOS*/)
    {
        Spell.iDescriptor = DESC_CHAOTIC;
        Spell.iImpact = VFX_IMP_SONIC;
        nLawChaos = ALIGNMENT_CHAOTIC;
        nGoodEvil = ALIGNMENT_ALL;
    }
    else if (iSpellID == 940/*SPELL_WORD_OF_LAW*/)
    {
        Spell.iDescriptor = DESC_LAWFUL;
        Spell.iImpact = VFX_IMP_SONIC;
        nLawChaos = ALIGNMENT_LAWFUL;
        nGoodEvil = ALIGNMENT_ALL;
    }
    // Setup the spell.
    Spell = SetSpell (Spell);
    // Check to see if we should still fire off the spell.
    if (Spell.iSpellID == STOP_SPELL) return;
    // Get the duration of the spell, sets Spell.fDuration.
    Spell = GetDuration (Spell);
    // *******************************************************************
    // ********************** Spell effects ******************************
    // *******************************************************************
    // Define variables.
    int iHitDice;
    effect eKill;
    // Create effects.
    effect eDeaf = EffectStunned();
    eDeaf = VersusAlignmentEffect (eDeaf, nLawChaos, nGoodEvil);
    effect eStun = EffectSlow ();
    eStun = VersusAlignmentEffect (eDeaf, nLawChaos, nGoodEvil);
    effect eConfused = EffectFrightened ();
    eConfused = VersusAlignmentEffect (eDeaf, nLawChaos, nGoodEvil);
    effect eDeath = EffectDeath ();
    eDeath = VersusAlignmentEffect (eDeaf, nLawChaos, nGoodEvil);
    // Create visual effects.
    effect eImpact = EffectVisualEffect (Spell.iImpact);
    effect eVisual = EffectVisualEffect (VFX_IMP_DEATH);
    effect eCenter = EffectVisualEffect (VFX_FNF_WORD);
    effect eUnsummon = EffectVisualEffect (VFX_IMP_UNSUMMON);
    effect eDuration = EffectVisualEffect(VFX_DUR_CESSATE_NEGATIVE);
    // Link effects.
    effect eLink = EffectLinkEffects (eDeaf, eDuration);
    eLink = SetEffectCasterLevel(eLink, Spell.iCasterLevel);
    // Apply the center vfx effect.
    ApplyEffectAtLocation (DURATION_TYPE_INSTANT, eCenter, Spell.lTarget);
    //Get the spells target(s).
    Spell = GetSpellTarget (Spell);
    while (GetIsObjectValid(Spell.oAreaTarget))
    {
        //Signal spell cast at event
        SignalEvent(Spell.oAreaTarget, EventSpellCastAt (Spell.oCaster, Spell.iSpellID));
        // Make resistance and save check.
        Spell = ResistAndSave (Spell);
        if (!Spell.iSaveResult)
        {
            // Check for summoned creature and remove them.
            if (GetIsObjectValid (GetMaster (Spell.oAreaTarget)))
            {
                if (GetAssociateType (Spell.oAreaTarget) == ASSOCIATE_TYPE_SUMMONED ||
                    GetLocalInt (Spell.oAreaTarget, "0_Summon_ID"))
                {
                    // Make will save.
                    Spell = GetSaveDC (Spell);
                    if (!WillSave (Spell.oAreaTarget, Spell.iSaveDC))
                    {
                        DelayCommand (Spell.fDelay, ApplyEffectToObject (DURATION_TYPE_INSTANT, eUnsummon, Spell.oAreaTarget));
                        if (!GetIsImmune (Spell.oAreaTarget, IMMUNITY_TYPE_DEATH))
                        {
                            DelayCommand (Spell.fDelay, ApplyEffectToObject (DURATION_TYPE_INSTANT, eDeath, Spell.oAreaTarget));
                        }
                        else
                        {
                            eKill = EffectDamage (GetCurrentHitPoints (Spell.oAreaTarget) + 10);
                            DelayCommand (Spell.fDelay, ApplyEffectToObject (DURATION_TYPE_INSTANT, eKill, Spell.oAreaTarget));
                        }
                    }
                }
            }
            else
            {
                //Check the HD of the creature
                iHitDice = GetHitDice (Spell.oAreaTarget);
                // Apply impact visual effect.
                DelayCommand (Spell.fDelay, ApplyEffectToObject (Spell.iDurationType, eImpact, Spell.oAreaTarget, Spell.fDuration));
                //Apply the appropriate effects based on HD
                if (iHitDice <= Spell.iCasterLevel - 10)
                {
                    // Now select the effect based off of the casters alignment.
                    if (!GetIsImmune (Spell.oAreaTarget, IMMUNITY_TYPE_DEATH))
                    {
                        DelayCommand (Spell.fDelay, ApplyEffectToObject (DURATION_TYPE_INSTANT, eDeath, Spell.oAreaTarget));
                    }
                    else
                    {
                        eKill = EffectDamage (GetCurrentHitPoints (Spell.oAreaTarget) + 10);
                        DelayCommand (Spell.fDelay, ApplyEffectToObject (DURATION_TYPE_INSTANT, eKill, Spell.oAreaTarget));
                    }
                }
                else if (iHitDice <= Spell.iCasterLevel - 5)
                {
                    eLink = EffectLinkEffects (eLink, eConfused);
                    DelayCommand (Spell.fDelay, ApplyEffectToObject (Spell.iDurationType, eLink, Spell.oAreaTarget, Spell.fDuration));
                }
                else if (iHitDice <= Spell.iCasterLevel - 1)
                {
                    eLink = EffectLinkEffects (eLink, eStun);
                    DelayCommand (Spell.fDelay, ApplyEffectToObject (Spell.iDurationType, eLink, Spell.oAreaTarget, Spell.fDuration));
                }
                else if (iHitDice == Spell.iCasterLevel)
                {
                    DelayCommand (Spell.fDelay, ApplyEffectToObject (Spell.iDurationType, eLink, Spell.oAreaTarget, Spell.fDuration));
                }
            }
        }
        //Get the spells target(s).
        Spell = GetSpellTarget (Spell);
    }
    CleanUpSpell (Spell);
}
