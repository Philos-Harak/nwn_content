/*////////////////////////////////////////////////
 Script Name: NW_S0_RaisDead.nss
 Programmer: Preston Watamaniuk
////////////////////////////////////////////////
Raise Dead
Conjuration (Healing)
Level:  Clr 7
Components: V, S, DF
Casting Time:   1 minute
Range:  Touch
Target: Dead creature touched
Duration:   Instantaneous
Saving Throw:   None; see text
Spell Resistance:   Yes (harmless)

You restore a deceased creature to life with 1 hitpoint.
Raised creatures have a -2 to Strength, Dexterity and Constitution for 24 hours.
/*///////////////////////////////////////////////////////////////////
#include "0i_spells"
#include "0i_henchmen"
#include "0i_npc"
#include "0i_quest"
void SetupAssociateWithRaiseDead (object oPC, int nAssociateType)
{
    SetIsDestroyable(FALSE, TRUE, FALSE);
    effect eRaise = EffectResurrection ();
    ApplyEffectToObject(DURATION_TYPE_INSTANT, eRaise, OBJECT_SELF);
    // Setup the henchman/NPC.
    NWNX_Creature_OverrideDamageLevel (OBJECT_SELF, -1);
    // Set them up based on if they are a henchman or a NPC.
    if (nAssociateType == ASSOCIATE_TYPE_HENCHMAN)
    {
        SetUpHenchman(oPC, OBJECT_SELF);
        DelayCommand(3.0f, LevelUpCurrentHenchman(oPC));
    }
    else
    {
       string sQuestID = GetQuestIDByNPC (OBJECT_SELF, oPC, "npc");
       SetQuestState (oPC, sQuestID, 9, 0);
       SetUpNPC(OBJECT_SELF);
    }
    AddHenchman (oPC);
    // Give them back any gold they had.
    int nGold = GetLocalInt (OBJECT_SELF, "0_Gold");
    GiveGoldToCreature (OBJECT_SELF, nGold);
    // Setup basic henchman/NPC variables.
    SetLocalObject (OBJECT_SELF, "0_Master", oPC);
}
void main()
{
    // ***********************************************************
    // *************** Set Spell Structure ***********************
    // ***********************************************************
    // Setup the spell in the structured variables, then pass through the SetSpell function.
    Spell.iSubType = SUBTYPE_MAGICAL;
    Spell.iSubSchool = SUBSCHOOL_HEALING;
    Spell.sDivineComponent = "diamond";
    Spell.iCompAmount = 5000;
    Spell.iDivineFocus = TRUE;
    Spell.iAreaShape = SHAPE_RANGE_TARGET;
    Spell.iLineOfSight = TRUE;
    Spell.iObjectFilter = OBJECT_TYPE_CREATURE;
    Spell.iTargetType = TARGET_TYPE_ALLIES;
    Spell.iDurationType = DURATION_TYPE_HOURS;
    Spell.iDuration = 24;
    Spell.iImpact = VFX_IMP_RAISE_DEAD;
    // Setup the spell.
    Spell = SetSpell (Spell);
    // Check to see if we should still fire off the spell.
    if (Spell.iSpellID == STOP_SPELL) return;
    // Get the duration of the spell, sets Spell.fDuration.
    Spell = GetDuration (Spell);
    // *******************************************************************
    // ********************** Spell effects ******************************
    // *******************************************************************
    int nGold, nAssociateType, bResurrect;
    string sQuestID;
    object oMaster;
    // Create effect.
    effect eRaise = EffectResurrection ();
    effect eStr = EffectAbilityDecrease (ABILITY_STRENGTH, 2);
    effect eDex = EffectAbilityDecrease (ABILITY_DEXTERITY, 2);
    //effect eCon = EffectAbilityDecrease (ABILITY_CONSTITUTION, 2);
    // Create visual effect.
    effect eImpact = EffectVisualEffect (Spell.iImpact);
    effect eDuration = EffectVisualEffect(VFX_DUR_CESSATE_NEGATIVE);
    // Link effects.
    effect eLink = EffectLinkEffects(eStr, eDex);
    //eLink = EffectLinkEffects(eLink, eCon);
    eLink = EffectLinkEffects(eLink, eDuration);
    //Get the spells target(s).
    Spell = GetSpellTarget (Spell);
    while(GetIsObjectValid (Spell.oAreaTarget))
    {
        // Ressurect spells look for this variable and if set will require specific spell
        // based upon the value: 1 Raise Dead, 2 Resurrection, 3 True Resurrection.
        if (GetLocalInt (Spell.oAreaTarget, "0_Raise") <= 1)
        {
            nAssociateType = GetLocalInt(Spell.oAreaTarget, PC_ASSOCIATE_TYPE);
            if (GetObjectType (Spell.oAreaTarget) == OBJECT_TYPE_ITEM &&
                GetTag (Spell.oAreaTarget) == "0_corpse")
            {
                // Check for what type of corpse this is. Henchman or NPC?
                int bResurrect = FALSE;
                if(nAssociateType == ASSOCIATE_TYPE_HENCHMAN)
                {
                    if(HasMaxNumberOfHenchman(Spell.oCaster))
                    {
                        SendMessages("You already have a henchman! Raising a dead body makes them your henchmen.", COLOR_RED, Spell.oCaster);
                    }
                    else bResurrect = TRUE;
                }
                else bResurrect = TRUE;
                if(bResurrect)
                {
                    object oCreature;
                    string sArray = GetLocalString (Spell.oAreaTarget, "0_Array");
                    if (sArray != "")
                    {
                        oCreature = CreateNPC(GetLocation (Spell.oCaster), sArray);
                        NWNX_Object_SetCurrentHitPoints (oCreature, 0);
                    }
                    else
                    {
                        json jCreature = GetLocalJson (Spell.oAreaTarget, "0_Stats");
                        oCreature = JsonToObject (jCreature, GetLocation (Spell.oCaster), OBJECT_INVALID, TRUE);
                    }
                    DelayCommand(2.0f, ApplyEffectToObject (DURATION_TYPE_INSTANT, eImpact, oCreature));
                    AssignCommand(oCreature, DelayCommand (2.0, SetupAssociateWithRaiseDead (Spell.oCaster, nAssociateType)));
                    // Remove the corpse.
                    DestroyObject (Spell.oAreaTarget);
                }
            }
            else
            {
                //Signal spell cast at event to fire.
                SignalEvent (Spell.oAreaTarget, EventSpellCastAt (Spell.oCaster, Spell.iSpellID, FALSE));
                if (GetIsDead (Spell.oAreaTarget))
                {
                    //Apply raise dead effect and VFX impact
                    DelayCommand (Spell.fDelay, ApplyEffectAtLocation (DURATION_TYPE_INSTANT, eImpact, GetLocation (Spell.oAreaTarget)));
                    DelayCommand (Spell.fDelay, ApplyEffectToObject (DURATION_TYPE_INSTANT, eRaise, Spell.oAreaTarget));
                    DelayCommand (Spell.fDelay, ApplyEffectToObject (Spell.iDurationType, eLink, Spell.oAreaTarget, Spell.fDuration));
                    if (nAssociateType == ASSOCIATE_TYPE_HENCHMAN || nAssociateType == ASSOCIATE_TYPE_NPC)
                    {
                        // Remove the droppable flag on an associates items.
                        SetDroppableFlagAllInventory(Spell.oAreaTarget, TRUE, TRUE);
                        // Give them back any gold they had.
                        nGold = GetLocalInt(Spell.oAreaTarget, "0_Gold");
                        GiveGoldToCreature(Spell.oAreaTarget, nGold);
                        // Reset dying to normal status.
                        NWNX_Creature_OverrideDamageLevel(Spell.oAreaTarget, -1);
                        SetAssociateMode(MODE_DYING, FALSE, Spell.oAreaTarget);
                        oMaster = GetLocalObject(Spell.oAreaTarget, "0_Master");
                        if(nAssociateType == ASSOCIATE_TYPE_NPC)
                        {
                            sQuestID = GetQuestIDByNPC(Spell.oAreaTarget, oMaster, "npc");
                            SetQuestState(oMaster, sQuestID, 9, 0);
                        }
                        else ActionSaveAssociateToDatabase(oMaster, Spell.oAreaTarget);
                        AddHenchman(oMaster, Spell.oAreaTarget);
                    }
                    else if(GetIsCharacter(Spell.oAreaTarget))
                    {
                        int nToken = NuiFindWindow(Spell.oAreaTarget, "pldeathpanel");
                        NuiDestroy(Spell.oAreaTarget, nToken);
                    }
                }
            }
        }
        else SendMessages ("This spell is not strong enough to resurrect " + GetName (Spell.oAreaTarget) + "!", COLOR_RED, Spell.oCaster);
        //Get the spells target(s).
        Spell = GetSpellTarget (Spell);
    }
    CleanUpSpell (Spell);
}

