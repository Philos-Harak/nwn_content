/*////////////////////////////////////////////////
 Script Name: NW_S0_RaisDead.nss
 Programmer: Preston Watamaniuk
////////////////////////////////////////////////
Raise Dead
Conjuration (Healing)
Level:  Clr 7
Components: V, S, DF
Casting Time: 1 minute
Range: Touch
Target: Dead creature touched
Duration: Instantaneous
Saving Throw: None; see text
Spell Resistance: Yes (harmless)

You restore a deceased creature to life with 1 hitpoint.
Raised creatures gain a negative level permanently.
/*///////////////////////////////////////////////////////////////////
#include "0i_spells"
#include "0i_henchmen"
#include "0i_npc"
#include "0i_quest"
void SetupAssociateWithRaiseDead(object oPC, object oCreature, int nAssociateType, effect eLink)
{
    SetIsDestroyable(FALSE, TRUE, FALSE, oCreature);
    effect eRaise = EffectResurrection();
    ApplyEffectToObject(DURATION_TYPE_INSTANT, eRaise, oCreature);
    DelayCommand (1.0f, ApplyEffectToObject(DURATION_TYPE_PERMANENT, eLink, oCreature));
    // Setup the henchman/NPC.
    NWNX_Creature_OverrideDamageLevel (oCreature, -1);
    // Remove the droppable flag on an associates items.
    SetDroppableFlagAllInventory(oCreature, TRUE, TRUE);
    object oMaster = GetLocalObject(oCreature, "0_Master");
    if(oMaster == OBJECT_INVALID) oMaster = oPC;
    // Set them up based on if they are a henchman or a NPC.
    if (nAssociateType == ASSOCIATE_TYPE_HENCHMAN)
    {
        NWNX_Object_SetDialogResref (oCreature, "co_henchmen");
        if(!HasMaxNumberOfHenchman(oMaster, TRUE))
        {
            SetUpHenchman(oMaster, oCreature, FALSE);
            AddHenchman(oMaster, oCreature);
            // Setup basic henchman/NPC variables.
            SetLocalObject(oCreature, "0_Master", oMaster);
            SaveAssociateToDatabase(oMaster, oCreature);
        }
    }
    else
    {
        string sQuestID = GetQuestIDByNPC (oCreature, oMaster, "npc");
        SetQuestState (oMaster, sQuestID, 9, 0);
        SetUpNPC(oCreature);
        AddHenchman(oMaster, oCreature);
        // Setup basic henchman/NPC variables.
        SetLocalObject (oCreature, "0_Master", oMaster);
    }
    // Give them back any gold they had.
    int nGold = GetLocalInt (oCreature, "0_Gold");
    GiveGoldToCreature (oCreature, nGold);
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
    Spell.iCompAmount = 1; // 5000gp worth of diamond.
    Spell.iDivineFocus = TRUE;
    Spell.iAreaShape = SHAPE_RANGE_TARGET;
    Spell.iLineOfSight = TRUE;
    Spell.iObjectFilter = OBJECT_TYPE_CREATURE;
    Spell.iTargetType = TARGET_TYPE_ALLIES;
    Spell.iDurationType = DURATION_TYPE_HOURS;
    Spell.iDuration = 24;
    Spell.iImpact = VFX_IMP_RAISE_DEAD;
    // If NPC_SPELL is set then the spell is being cast by an NPC and not the player.
    // Remoe the divine component requirement for NPCs.
    if(GetLocalInt(OBJECT_SELF, "NPC_SPELL")) 
    {
        Spell.sDivineComponent = "";
        Spell.iCompAmount = 0;
        DeleteLocalInt(OBJECT_SELF, "NPC_SPELL");
    }
    // Setup the spell.
    Spell = SetSpell(Spell);
    // Check to see if we should still fire off the spell.
    if (Spell.iSpellID == STOP_SPELL) return;
    // Get the duration of the spell, sets Spell.fDuration.
    Spell = GetDuration(Spell);
    // *******************************************************************
    // ********************** Spell effects ******************************
    // *******************************************************************
    int nGold, nAssociateType;
    string sQuestID;
    object oMaster;
    // Create effect.
    effect eRaise = EffectResurrection();
    effect eDrain = EffectNegativeLevel(1);
    // Create visual effect.
    effect eImpact = EffectVisualEffect(Spell.iImpact);
    effect eDuration = EffectVisualEffect(VFX_DUR_CESSATE_NEGATIVE);
    // Link effects.
    effect eLink = EffectLinkEffects(eDrain, eDuration);
    eLink = SupernaturalEffect(eLink);
    //Get the spells target(s).
    Spell = GetSpellTarget(Spell);
    while(GetIsObjectValid(Spell.oAreaTarget))
    {
        // Raise Dead spell looks for this variable and if set will require specific spell
        // based upon the value: 1 Raise Dead, 2 Resurrection, 3 True Resurrection.
        if(GetLocalInt(Spell.oAreaTarget, "0_Raise") <= 1)
        {
            if(GetObjectType(Spell.oAreaTarget) == OBJECT_TYPE_ITEM &&
               GetTag(Spell.oAreaTarget) == "0_corpse")
            {
                object oCreature;
                string sArray = GetLocalString(Spell.oAreaTarget, "0_Array");
                if(sArray != "")
                {
                    oCreature = CreateNPC(GetLocation(Spell.oCaster), sArray);
                    NWNX_Object_SetCurrentHitPoints(oCreature, 0);
                }
                else
                {
                    json jCreature = GetLocalJson(Spell.oAreaTarget, "0_Stats");
                    oCreature = JsonToObject(jCreature, GetLocation(Spell.oCaster), OBJECT_INVALID, TRUE);
                }
                DelayCommand(2.0f, ApplyEffectToObject(DURATION_TYPE_INSTANT, eImpact, oCreature));
                DelayCommand(2.0, SetupAssociateWithRaiseDead(Spell.oCaster, oCreature, nAssociateType, eLink));
                // Remove the corpse.
                DestroyObject (Spell.oAreaTarget);
            }
            else
            {
                //Signal spell cast at event to fire.
                SignalEvent(Spell.oAreaTarget, EventSpellCastAt (Spell.oCaster, Spell.iSpellID, FALSE));
                if(GetIsDead(Spell.oAreaTarget))
                {
                    nAssociateType = GetLocalInt(Spell.oAreaTarget, PC_ASSOCIATE_TYPE);
                    if(nAssociateType == ASSOCIATE_TYPE_HENCHMAN || nAssociateType == ASSOCIATE_TYPE_NPC)
                    {
                        ApplyEffectAtLocation(DURATION_TYPE_INSTANT, eImpact, GetLocation (Spell.oAreaTarget));
                        SetupAssociateWithRaiseDead(Spell.oCaster, Spell.oAreaTarget, nAssociateType, eLink);    
                    }
                    else if(GetIsCharacter(Spell.oAreaTarget))
                    {
                        //Apply raise dead effect and VFX impact
                        DelayCommand (Spell.fDelay, ApplyEffectAtLocation(DURATION_TYPE_INSTANT, eImpact, GetLocation (Spell.oAreaTarget)));
                        DelayCommand (Spell.fDelay, ApplyEffectToObject(DURATION_TYPE_PERMANENT, eLink, Spell.oAreaTarget));
                        int nToken = NuiFindWindow(Spell.oAreaTarget, "pldeathpanel");
                        NuiDestroy(Spell.oAreaTarget, nToken);
                    }
                }
            }
        }
        else SendMessages ("This spell is not strong enough to bring " + GetName (Spell.oAreaTarget) + " back to life!", COLOR_RED, Spell.oCaster);
        //Get the spells target(s).
        Spell = GetSpellTarget (Spell);
    }
    CleanUpSpell (Spell);
}

