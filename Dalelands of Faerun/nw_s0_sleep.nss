/*////////////////////////////////////////////////
 Script: NW_S0_Sleep
 Programmer: Preston Watamaniuk
////////////////////////////////////////////////
Sleep
Enchantment (Compulsion) [Mind-Affecting]
Level:  Brd 1, Sor/Wiz 1
Components: V, S, M
Casting Time:   1 round
Range:  Medium (100 ft. + 10 ft./level)
Area:   One or more living creatures within a 10-ft.-radius burst
Duration: 3 rounds + 1 round / level
Saving Throw:   Will negates
Spell Resistance:   Yes

A sleep spell causes a magical slumber to come upon 4 Hit Dice of creatures.
Creatures with the fewest HD are affected first. Among creatures with equal HD,
those who are closest to the spell's point of origin are affected first.
Hit Dice that are not sufficient to affect a creature are wasted.
Sleeping creatures are helpless. Slapping or wounding awakens an affected creature,
but normal noise does not.

Material Component: A pinch of fine sand, rose petals, or a live cricket.

 Goes through the area and sleeps the lowest 4 HD of creatures first.
/*///////////////////////////////////////////////
#include "0i_spells"

void main()
{
    // ***********************************************************
    // *************** Set Spell Structure ***********************
    // ***********************************************************
    // Setup the spell in the structured variables, then pass through the SetSpell function.
    Spell.iSubType = SUBTYPE_MAGICAL;
    Spell.iSubSchool = SUBSCHOOL_COMPULSION;
    Spell.iDescriptor = DESC_MIND;
    Spell.sArcaneComponent = COMPONENT_POUCH;
    Spell.iAreaShape = SHAPE_SPHERE;
    Spell.fAreaSize = 10.0;
    Spell.iLineOfSight = FALSE;
    Spell.iObjectFilter = OBJECT_TYPE_CREATURE;
    Spell.iTargetType = TARGET_TYPE_ALL;
    Spell.iDurationType = DURATION_TYPE_ROUNDS;
    Spell.iDurNumOfDice = 3;
    Spell.iDurationDie = 1;
    Spell.iDuration = 1;
    Spell.iDurPerLvl = 1;
    Spell.iSave = SAVING_THROW_WILL;
    Spell.iSaveType = SAVING_THROW_TYPE_MIND_SPELLS;
    Spell.iSpellResistance = TRUE;
    Spell.iImpact = VFX_FNF_LOS_NORMAL_20;
    // Setup the spell.
    Spell = SetSpell (Spell);
    // Check to see if we should still fire off the spell.
    if (Spell.iSpellID == STOP_SPELL) return;
    // Get the duration of the spell.
    Spell = GetDuration (Spell);
    // *******************************************************************
    // ********************** Spell effects ******************************
    // *******************************************************************
    int nCreatureHD, nHD = 4, nRacialType;
    if (Spell.iSpellID == 165) nHD = 4;
    else if (Spell.iSpellID == 975) nHD = 10;
    if(GetLocalInt(Spell.oCaster, "0_Use_Enhancing_Component"))
    {
        // Do a special check for enhancing components in one inventory pass.
        int nEnhancedHD, nStack;
        int nBandedAgateDust, nFrostAgateDust;
        float fEnhancedAOE;
        object oItem = GetFirstItemInInventory(Spell.oCaster);
        while(oItem != OBJECT_INVALID)
        {
            if(!nBandedAgateDust && GetTag(oItem) == "banded_agate_dust")
            {
                nStack = GetItemStackSize(oItem);
                if(nStack == 1) DestroyObject (oItem);
                else SetItemStackSize(oItem, nStack - 1);
                nBandedAgateDust = TRUE;
                nEnhancedHD += 5;    
            }
            else if(!nFrostAgateDust && GetTag(oItem) == "frost_agate_dust")
            {
                nStack = GetItemStackSize(oItem);
                if(nStack == 1) DestroyObject (oItem);
                else SetItemStackSize(oItem, nStack - 1);
                nFrostAgateDust = TRUE;
                nEnhancedHD += 5;    
            }
            oItem = GetNextItemInInventory(Spell.oCaster);
        }
        if(nEnhancedHD)
        {
            string sSpellName = GetStringByStrRef(StringToInt(Get2DAString("Spells", "Name", Spell.iSpellID)));
            SendMessages(sSpellName + " has been enhanced to increase the HitDice affected by +" + IntToString(nEnhancedHD) + "!", COLOR_GREEN, Spell.oCaster);
            nHD += nEnhancedHD;
        }
    }
    int nLowest = nHD + 1;
    object oLowest;
    effect eImpact = EffectVisualEffect (Spell.iImpact);
    effect eSleep =  EffectSleep ();
    effect eMind = EffectVisualEffect (VFX_DUR_MIND_AFFECTING_NEGATIVE);
    effect eDur = EffectVisualEffect (VFX_DUR_CESSATE_NEGATIVE);
    effect eLink = EffectLinkEffects (eSleep, eMind);
    eLink = EffectLinkEffects(eLink, eDur);
    effect eVis = EffectVisualEffect (VFX_IMP_SLEEP);
    effect eLink2 = EffectLinkEffects(eLink, eVis);
    // Used to tell the script we have hit this creature already.
    string sSpellLocal = "BIOWARE_SPELL_LOCAL_SLEEP_" + GetName (Spell.oCaster);
    ApplyEffectAtLocation (DURATION_TYPE_INSTANT, eImpact, Spell.lTarget);
    //Get the spells target(s).
    Spell = GetSpellTarget (Spell);
    while(GetIsObjectValid (Spell.oAreaTarget) && nHD > 0)
    {
        nRacialType = GetRacialType (Spell.oAreaTarget);
        //Make check to ignore specific creatures.
        if (nRacialType != RACIAL_TYPE_CONSTRUCT && nRacialType != RACIAL_TYPE_UNDEAD)
        {
            // Has this creature already been hit by the spell, check SpellLocal variable.
            if (!GetLocalInt (Spell.oAreaTarget, sSpellLocal))
            {
                //Get the current HD of the target creature
                nCreatureHD = GetHitDice(Spell.oAreaTarget);
                //Check to see if the HD are lower than the current Lowest HD stored and that the
                //HD of the monster are lower than the number of HD left to use up.
                if(nCreatureHD < nLowest && nCreatureHD <= nHD)
                {
                    nLowest = nCreatureHD;
                    oLowest = Spell.oAreaTarget;
                }
            }
        }
        //Get the spells target(s).
        Spell = GetSpellTarget (Spell);
        //Check to see if we are done searching for creatures.
        if (!GetIsObjectValid(Spell.oAreaTarget))
        {
            // Check to see if we have a lowest target.
            if (GetIsObjectValid (oLowest))
            {
                //Fire cast spell at event for the specified target
                SignalEvent (oLowest, EventSpellCastAt (Spell.oCaster, Spell.iSpellID));
                // Make resistance and save check.
                Spell = ResistAndSave (Spell);
                if (!Spell.iSaveResult)
                {
                    // Check to see if they are immune to sleep;
                    if (!GetIsImmune (oLowest, IMMUNITY_TYPE_SLEEP)) DelayCommand (Spell.fDelay, ApplyEffectToObject (Spell.iDurationType, eLink2, oLowest, Spell.fDuration));
                    // * even though I am immune apply just the sleep effect for the immunity message
                    else DelayCommand (Spell.fDelay, ApplyEffectToObject (Spell.iDurationType, eLink, oLowest, Spell.fDuration));
                }
                // Set a local int to make sure the creature is not used twice in the pass.  Destroy that variable in
                // 1.0f seconds to remove it from the creature
                SetLocalInt (oLowest, sSpellLocal, TRUE);
                DelayCommand (1.0, DeleteLocalInt(oLowest, sSpellLocal));
                //Remove the HD of the creature from the total
                nHD = nHD - GetHitDice (oLowest);
                oLowest = OBJECT_INVALID;
                nLowest = nHD + 1;
                // Check the area again for the next lowest.
                // Do this by clearing the spells target to start over.
                Spell.oAreaTarget = OBJECT_INVALID;
                //Get the spells target(s).
                Spell = GetSpellTarget (Spell);
            }
        }
    }
    CleanUpSpell (Spell);
}
