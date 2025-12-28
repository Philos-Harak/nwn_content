/*//////////////////////////////////////////////////////////////////////////////
 Script Name: 0s_planarportal
 Programmer: Philos
////////////////////////////////////////////////////////////////////////////////
Conjuration (Calling) [see text]
Level: Cleric, Sorerer/Wizard (5th, 6th, 8th)
Components: V, S, DF
Range: Short
Target: One elemental or outsider
Duration: 1 day
Saving Throw: Will negates
Spell Resistance: Yes

Casting this spell attempts a dangerous act: to lure a creature from another plane.
The kind of creature to be bound will be of your alignment unless stated.
If you wish to call a specific type or individual, you must have a rune stone of
that individual in casting the spell (and set it in the players handbook).
The target creature is allowed a Will saving throw. If the saving throw succeeds,
the creature resists the spell and does not appear. If the saving throw fails,
the creature is immediately summoned.
The creature can escape by successfully pitting its spell resistance against
your caster level check. If it breaks loose, it can flee or attack you.
/*//////////////////////////////////////////////////////////////////////////////
#include "0i_spells"
void main()
{
    Spell.iSubType = SUBTYPE_MAGICAL;
    Spell.iSubSchool = SUBSCHOOL_CALLING;
    Spell.iDivineFocus = TRUE;
    Spell.iAreaShape = SHAPE_RANGE_TARGET;
    Spell.iDurationType = DURATION_TYPE_HOURS;
    Spell.iDuration = 24;
    Spell.iSpellResistance = TRUE;
    Spell = SetSpell (Spell);
    if (Spell.iSpellID == STOP_SPELL) return;
    // GetDuration sets Spell.fDuration.
    Spell = GetDuration (Spell);
    // When making seperate saves vs Spell Resist make sure to get the SaveDC!
    Spell = GetSaveDC (Spell);
    // *******************************************************************
    // ********************** Spell effects ******************************
    // *******************************************************************
    string sSummons, sSummonArray;
    if(GetIsCharacter(Spell.oCaster))
    {
        sSummonArray = GetObjectDatabaseString(Spell.oCaster, CHARACTER_TABLE, "summons");
    }
    object oCreature, oWaypoint = GetObjectByTag ("WP_Creature_Spawn");
    location lTempSpawnLocation = GetLocation (oWaypoint);
    effect eSummons, eVisual;
    int iAlign = GetAlignmentGoodEvil (Spell.oCaster);
    float fDelayCreature, fDelayEffect;
    if (Spell.iSpellID == SPELL_LESSER_PLANAR_BINDING)
    {
        sSummons = GetStringArray (sSummonArray, 12);
        if (sSummons == "")
        {
            switch (iAlign)
            {
                case ALIGNMENT_EVIL: sSummons = "NW_S_IMP"; break;
                case ALIGNMENT_GOOD: sSummons = "NW_S_CLANTERN"; break;
                case ALIGNMENT_NEUTRAL: sSummons = "NW_S_SLAADRED"; break;
            }
        }
    }
    if (Spell.iSpellID == SPELL_PLANAR_BINDING)
    {
        sSummons = GetStringArray (sSummonArray, 13);
        if (sSummons == "")
        {
            switch (iAlign)
            {
                case ALIGNMENT_EVIL: sSummons = "NW_S_SUCCUBUS"; break;
                case ALIGNMENT_GOOD: sSummons = "NW_S_CHOUND"; break;
                case ALIGNMENT_NEUTRAL: sSummons = "NW_S_SLAADGRN"; break;
            }
        }
    }
    if (Spell.iSpellID == SPELL_GREATER_PLANAR_BINDING)
    {
        sSummons = GetStringArray (sSummonArray, 14);
        if (sSummons == "")
        {
            switch (iAlign)
            {
                case ALIGNMENT_EVIL: sSummons = "NW_S_VROCK"; break;
                case ALIGNMENT_GOOD: sSummons = "NW_S_CTRUMPET"; break;
                case ALIGNMENT_NEUTRAL: sSummons = "NW_S_SLAADDETH"; break;
            }
        }
    }
    if (Spell.iSpellID == SPELL_GATE)
    {
        sSummons = GetStringArray (sSummonArray, 15);
        if (sSummons == "") sSummons = "s_balor";
    }
    switch (iAlign)
    {
        case ALIGNMENT_EVIL:
        {
            eVisual = EffectVisualEffect (VFX_FNF_SUMMON_GATE);
            fDelayCreature = 3.0f;
            break;
        }
        case ALIGNMENT_GOOD:
        {
            eVisual = EffectVisualEffect (VFX_FNF_SUMMON_CELESTIAL);
            fDelayCreature = 3.0f;
            break;
        }
        case ALIGNMENT_NEUTRAL:
        {
            eVisual = EffectVisualEffect (VFX_FNF_SUMMON_MONSTER_3);
            fDelayCreature = 2.0f;
            break;
        }
    }
    // Make sure they only have one planar creature per spell.
    int bCanSummon = TRUE;
    int nSpell, nCount = 1;
    object oSummons = GetAssociate (ASSOCIATE_TYPE_HENCHMAN, Spell.oCaster, nCount);
    while (oSummons != OBJECT_INVALID)
    {
        nSpell = GetLocalInt (oSummons, "0_Summon_ID");
        if (nSpell == Spell.iSpellID) bCanSummon = FALSE;
        nCount ++;
        oSummons = GetAssociate (ASSOCIATE_TYPE_HENCHMAN, Spell.oCaster, nCount);
    }
    if (bCanSummon)
    {
        oCreature = CreateObject (OBJECT_TYPE_CREATURE, sSummons, lTempSpawnLocation);
        if (!SavingThrowWithEffects (SAVING_THROW_WILL, oCreature, Spell.iSaveDC, SAVING_THROW_TYPE_NONE, Spell.oCaster))
        {
            SendMessages (GetName (oCreature) + " has heard your call!", COLOR_GREEN, Spell.oCaster);
            DelayCommand (Spell.fDelay + fDelayCreature, AssignCommand (oCreature, JumpToLocation (Spell.lTarget)));
            DelayCommand (Spell.fDelay, ApplyEffectAtLocation (DURATION_TYPE_INSTANT, eVisual, Spell.lTarget));
            // Make resistance check.
            if (!ResistSpell (Spell.oCaster, oCreature))
            {
                AddHenchman (Spell.oCaster, oCreature);
                // Mark the summons with the variable "0_Summon_ID" linked with the spell ID.
                SetLocalInt (oCreature, "0_Summon_ID", Spell.iSpellID);
            }
            else
            {
                object oNeutralFaction = GetObjectByTag ("neutral_faction");
                iAlign = GetAlignmentGoodEvil (oCreature);
                // Evil will attack the caster's party or just leave.
                float fDelay = IntToFloat (6 * d20() + 5);
                if (iAlign ==  ALIGNMENT_EVIL)
                {
                    if (d2()) ChangeToStandardFaction (oCreature, STANDARD_FACTION_HOSTILE);
                    else fDelay = 1.0f;
                }
                // Neutral will attack the caster's party, ignore them all, or leave.
                else if (iAlign == ALIGNMENT_NEUTRAL)
                {
                    int nRoll = d3();
                    if (nRoll == 1) ChangeFaction (oCreature, oNeutralFaction);
                    else if (nRoll == 2) ChangeToStandardFaction (oCreature, STANDARD_FACTION_HOSTILE);
                    else fDelay = 1.0f;
                }
                // Good will help, ignore them all or just leave.
                else if (iAlign == ALIGNMENT_GOOD)
                {
                    int nRoll = d3();
                    if (nRoll == 1) ChangeFaction (oCreature, oNeutralFaction);
                    else if (nRoll == 2) fDelay = 1.0f;
                }
                DestroyObject (oCreature, fDelay);
            }
        }
        else
        {
            DestroyObject (oCreature);
            SendMessages (GetName (oCreature) + " has ignored your call!", COLOR_RED, Spell.oCaster);
        }
    }
    else
    {
        string sSpellName = GetStringByStrRef (StringToInt (Get2DAString ("spells", "Name", Spell.iSpellID)));
        SendMessages ("You can only command one creature at a time with " + sSpellName + ".", COLOR_RED, Spell.oCaster);
    }
    CleanUpSpell (Spell);
}


