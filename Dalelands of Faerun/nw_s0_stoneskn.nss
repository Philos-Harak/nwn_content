/*////////////////////////////////////////////////
 Script: NW_S0_Stoneskin
 Programmer: Preston Watamaniuk
////////////////////////////////////////////////
Abjuration
Level:  Drd 5, Earth 6, Sor/Wiz 4, Strength 6
Components: V, S, M
Casting Time:   1 standard action
Range:  Touch
Target: Creature touched
Duration:   10 min./level or until discharged
Saving Throw:   Will negates (harmless)
Spell Resistance:   Yes (harmless)

The warded creature gains resistance to blows, cuts, stabs, and slashes.
The subject gains damage reduction 10/+5. (It ignores the first
10 points of damage each time it takes damage from a weapon, though an
+5 weapon bypasses the reduction.) Once the spell has prevented a total
of 10 points of damage per caster level (maximum 150 points), it is discharged.

Material Component: Granite and 250 gp worth of diamond dust sprinkled on the
target's skin.
/*///////////////////////////////////////////////
#include "0i_spells"
void main()
{
    // ***********************************************************
    // *************** Set Spell Structure ***********************
    // ***********************************************************
    // Setup the spell in the structured variables, then pass through the SetSpell function.
    Spell.iSubType = SUBTYPE_MAGICAL;
    Spell.sArcaneComponent = "diamond_dust";
    Spell.sDivineComponent = "diamond_dust";
    Spell.iCompAmount = 10; // 250 gp worth of diamond dust
    Spell.iAreaShape = SHAPE_TOUCH_TARGET;
    Spell.iLineOfSight = TRUE;
    Spell.iObjectFilter = OBJECT_TYPE_CREATURE;
    Spell.iTargetType = TARGET_TYPE_ALLIES;
    Spell.iDurationType = DURATION_TYPE_MINUTES;
    Spell.iDuration = 10;
    Spell.iDurPerLvl = 1;
    Spell.iModifier = 10;
    Spell.iModPerLvl = 1;
    Spell.iMaxModifier = 15;
    Spell.iImpact = VFX_IMP_SUPER_HEROISM;
    // Setup the spell.
    Spell = SetSpell(Spell);
    // Check to see if we should still fire off the spell.
    if(Spell.iSpellID == STOP_SPELL) return;
    // Get the duration of the spell, sets Spell.fDuration.
    Spell = GetDuration(Spell);
    // Get the result for the effect, sets Spell.iResult.
    Spell = GetModifier(Spell);
    // *******************************************************************
    // ********************** Spell effects ******************************
    // *******************************************************************
    if(GetLocalInt(Spell.oCaster, "0_Use_Enhancing_Component"))
    {
        // Do a special check for enhancing components in one inventory pass.
        int nEnhancedAbsorb, nStack;
        int nLaeralTearsDust;
        object oItem = GetFirstItemInInventory(Spell.oCaster);
        while(oItem != OBJECT_INVALID)
        {
            // Laeral's Tears Dust enhances the spell to absorb an additional 20 points of damage.
            if(GetTag(oItem) == "laeral_tears_dust" && !nLaeralTearsDust)
            {
                nStack = GetItemStackSize(oItem);
                if(nStack > 3)
                {
                    if(nStack > 4) SetItemStackSize(oItem, nStack - 4);
                    else DestroyObject(oItem);
                    nLaeralTearsDust = TRUE;
                    nEnhancedAbsorb += 20;
                }
            }
            else if(nLaeralTearsDust) break;
            oItem = GetNextItemInInventory(Spell.oCaster);
        }
        object oObject;
        if(nEnhancedAbsorb)
        {
            string sSpellName = GetStringByStrRef(StringToInt(Get2DAString("Spells", "Name", Spell.iSpellID)));
            if(GetIsCharacter(Spell.oCaster)) oObject = Spell.oCaster;
            else oObject = GetMaster(Spell.oCaster);
            SendMessages(sSpellName + " has been enhanced to absorb +" + IntToString(nEnhancedAbsorb) + " additional damage!", COLOR_GREEN, oObject);
            Spell.iResult = Spell.iResult + nEnhancedAbsorb;
        }
    }
    // Create visual effects
    effect eVisual = EffectVisualEffect(VFX_DUR_PROT_STONESKIN);
    effect eImpact = EffectVisualEffect(Spell.iImpact);
    effect eDuration = EffectVisualEffect(VFX_DUR_CESSATE_POSITIVE);
    // Create effect
    effect eStone = EffectDamageReduction(10, DAMAGE_POWER_PLUS_FIVE, Spell.iResult);
    // Link effects
    effect eLink = EffectLinkEffects(eStone, eVisual);
    eLink = EffectLinkEffects(eLink, eDuration);
    eLink = SetEffectCasterLevel(eLink, Spell.iCasterLevel);
    //Get the spells target(s).
    Spell = GetSpellTarget(Spell);
    while(GetIsObjectValid(Spell.oAreaTarget))
    {
        //Fire cast spell at event for the specified target
        SignalEvent(Spell.oAreaTarget, EventSpellCastAt(Spell.oCaster, Spell.iSpellID, FALSE));
        // Remove any previously cast spell on this target.
        RemoveSpellEffects(Spell.iSpellID, Spell.oAreaTarget);
        // Apply effects
        DelayCommand(Spell.fDelay, ApplyEffectToObject(DURATION_TYPE_INSTANT, eImpact, Spell.oAreaTarget));
        DelayCommand(Spell.fDelay, ApplyEffectToObject(Spell.iDurationType, eLink, Spell.oAreaTarget, Spell.fDuration));
        //Get the spells target(s).
        Spell = GetSpellTarget(Spell);
    }
    CleanUpSpell(Spell);
}
