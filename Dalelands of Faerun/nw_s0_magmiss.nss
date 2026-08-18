/*////////////////////////////////////////////////
 Script: nw_s0_magmiss
 Programmer: Preston Watamaniuk
////////////////////////////////////////////////
Evocation [Force]
Level:  Sor/Wiz 1
Components: V, S
Casting Time:   1 standard action
Range:  Medium (100 ft. + 10 ft./level)
Targets:    Up to five creaturs
Duration:   Instantaneous
Saving Throw:   None
Spell Resistance:   Yes
A missile of magical energy darts forth from your fingertip and strikes its
target, dealing 1d4+1 points of force damage.

The missile strikes unerringly, even if the target is in melee combat or has
less than total cover or total concealment. Specific parts of a creature can�t
be singled out. Inanimate objects are not damaged by the spell.

For every two caster levels beyond 1st, you gain an additional missile � two at
3rd level, three at 5th, four at 7th, and the maximum of five missiles at
9th level or higher.
/*///////////////////////////////////////////////
#include "0i_spells"

void main()
{
    // ***********************************************************
    // *************** Set Spell Structure ***********************
    // ***********************************************************
    // Setup the spell in the structured variables, then pass through the SetSpell function.
    Spell.iSubType = SUBTYPE_MAGICAL;
    Spell.iDescriptor = DESC_FORCE;
    Spell.iAreaShape = SHAPE_RANGE_TARGET;
    Spell.iTargetType = TARGET_TYPE_ENEMIES;
    Spell.iObjectFilter = OBJECT_TYPE_CREATURE;
    Spell.iDurationType = DURATION_TYPE_INSTANT;
    Spell.iSpellResistance = TRUE;
    Spell.iDamageType = DAMAGE_TYPE_MAGICAL;
    Spell.iModNumOfDice = 1;
    Spell.iModifierDie = 4;
    Spell.iModifier = 1;
    Spell.iImpact = VFX_IMP_MAGBLUE;
    // Setup the spell.
    Spell = SetSpell (Spell);
    // Check to see if we should still fire off the spell.
    if (Spell.iSpellID == STOP_SPELL) return;
    // *******************************************************************
    // ********************** Spell effects ******************************
    // *******************************************************************
    int nCounter, bCalculateBonus = TRUE;
    float fDistance, fDelay, fDelay2, fTime;
    effect eDmg;
    effect eMissile = EffectVisualEffect (VFX_IMP_MIRV);
    effect eImpact = EffectVisualEffect (Spell.iImpact);
    // Get the number of missles to fire by using the iModDicePerLvl.
    int nMissiles = (Spell.iCasterLevel + 1) / 2;
    // Minimum number of missles to launch is one.
    if (nMissiles < 1) nMissiles = 1;
    // Do not go over maximum spell level.
    if (nMissiles > 5) nMissiles = 5;
    // Check for enhancing components.
    if(GetLocalInt(Spell.oCaster, "0_Use_Enhancing_Component"))
    {
        // Do a special check for enhancing components in one inventory pass.
        int nEnhancedDmg, nEnhancedMissles, nStack;
        int nBoakharDust, nJargoonDust;
        object oItem = GetFirstItemInInventory(Spell.oCaster);
        while(oItem != OBJECT_INVALID)
        {
            if(!nBoakharDust && GetTag(oItem) == "boakhar_dust")
            {
                nStack = GetItemStackSize(oItem);
                if(nStack == 1) DestroyObject (oItem);
                else SetItemStackSize(oItem, nStack - 1);
                nBoakharDust = TRUE;
                nEnhancedDmg += 1;
            }
            else if(!nJargoonDust && GetTag(oItem) == "jargoon_dust")
            {
                nStack = GetItemStackSize(oItem);
                if(nStack > 1)
                {
                    if(nStack > 2) SetItemStackSize(oItem, nStack - 2);
                    else DestroyObject (oItem);
                    nJargoonDust = TRUE;
                    nEnhancedMissles += 1;
                }
            }
            else if(nJargoonDust && nBoakharDust) break;
            oItem = GetNextItemInInventory(Spell.oCaster);
        }
        object oObject;
        if(nBoakharDust)
        {
            string sSpellName = GetStringByStrRef(StringToInt(Get2DAString("Spells", "Name", Spell.iSpellID)));
            if(GetIsCharacter(Spell.oCaster)) oObject = Spell.oCaster;
            else oObject = GetMaster(Spell.oCaster);
            SendMessages(sSpellName + " has been enhanced to increase the damage per missle by +" + IntToString(nEnhancedDmg) + "!", COLOR_GREEN, oObject);
            Spell.iModifier += nEnhancedDmg;
        }
        if(nJargoonDust)
        {
            string sSpellName = GetStringByStrRef(StringToInt(Get2DAString("Spells", "Name", Spell.iSpellID)));
            if(GetIsCharacter(Spell.oCaster)) oObject = Spell.oCaster;
            else oObject = GetMaster(Spell.oCaster);
            SendMessages(sSpellName + " has been enhanced to fire +" + IntToString(nEnhancedMissles) + " additional missles!", COLOR_GREEN, oObject);
            nMissiles += nEnhancedMissles;
        }
    }
    // Now set the Spell.iModDicePerLvl to 0 so we can roll damage per missle.
    // This makes the dice roll not use the casters level.
    Spell.iModDicePerLvl = 0;
    Spell.iModPerLvl = 0;
    //Get the spells target(s).
    Spell = GetSpellTarget (Spell);
    while(GetIsObjectValid(Spell.oAreaTarget))
    {
        // Get distance and delay per target.
        fDistance = GetDistanceBetween (Spell.oCaster, Spell.oAreaTarget);
        fDelay = fDistance / (3.0 * log (fDistance) + 2.0);
        //Fire cast spell at event for the specified target
        SignalEvent (Spell.oAreaTarget, EventSpellCastAt (Spell.oCaster, Spell.iSpellID));
        // Make resistance check.
        Spell = ResistAndSave(Spell, TRUE, FALSE);
        if(!Spell.iSaveResult)
        {
            //Apply a single damage hit for each missile instead of as a single mass
            for (nCounter = 1; nCounter <= nMissiles; nCounter ++)
            {
                //Roll damage
                Spell = GetModifier(Spell, bCalculateBonus);
                bCalculateBonus = FALSE;
                fTime = fDelay;
                fDelay2 += 0.1;
                fTime += fDelay2;
                //Set damage effect
                eDmg = EffectDamage(Spell.iResult, Spell.iDamageType);
                eDmg = SetEffectCasterLevel(eDmg, Spell.iCasterLevel);
                //Apply the MIRV and damage effect
                DelayCommand(fTime, ApplyEffectToObject (Spell.iDurationType, eDmg, Spell.oAreaTarget));
                DelayCommand(fTime, ApplyEffectToObject (DURATION_TYPE_TEMPORARY, eImpact, Spell.oAreaTarget));
                DelayCommand(fDelay2, ApplyEffectToObject (DURATION_TYPE_INSTANT, eMissile, Spell.oAreaTarget));
            }
        }
        // Show the missle go to the target but they do no damage as they are spell resistant.
        else
        {
            for (nCounter = 1; nCounter <= nMissiles; nCounter ++)
            {
                ApplyEffectToObject (DURATION_TYPE_INSTANT, eMissile, Spell.oAreaTarget);
            }
        }
        bCalculateBonus = TRUE;
        //Get the spells target(s).
        Spell = GetSpellTarget (Spell);
    }
    CleanUpSpell (Spell);
}
