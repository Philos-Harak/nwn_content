/*////////////////////////////////////////////////////////////////////
 Script: 0s_true_resurrec
 Programmer: Preston Watamaniuk
//////////////////////////////////////////////////////////////////////
True Ressurection
Conjuration (Healing)
Level:  Clr 9
Components: V, S, DF
Casting Time:   1 minute
Range:  Touch
Target: Dead creature touched
Duration:   Instantaneous
Saving Throw:   None; see text
Spell Resistance:   Yes (harmless)

You restore a deceased creature to life with full hitpoints.
/*////////////////////////////////////////////////////////////////////
#include "0i_spells"
#include "0i_henchmen"
#include "0i_npc"
#include "0i_quest"
void SetupAssociateWithTrueResurrect(object oPC, object oCreature,int nAssociateType)
{
    SetIsDestroyable(FALSE, TRUE, FALSE, oCreature);
    effect eRaise = EffectResurrection();
    ApplyEffectToObject(DURATION_TYPE_INSTANT, eRaise, oCreature);
    // Setup the henchman/NPC.
    NWNX_Creature_OverrideDamageLevel(oCreature, -1);
    DelayCommand(1.0f, NWNX_Object_SetCurrentHitPoints(oCreature, GetMaxHitPoints(oCreature)));
    // Remove the droppable flag on an associates items.
    SetDroppableFlagAllInventory(oCreature, TRUE, TRUE);
    object oMaster = GetLocalObject(oCreature, "0_Master");
    if(oMaster == OBJECT_INVALID) oMaster = oPC;
    // Set them up based on if they are a henchman or a NPC.
    if(nAssociateType == ASSOCIATE_TYPE_HENCHMAN)
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
        string sQuestID = GetQuestIDByNPC(oCreature, oMaster, "npc");
        SetQuestState(oMaster, sQuestID, 9, 0);
        SetUpNPC(oCreature, FALSE);
        AddHenchman(oMaster, oCreature);
        // Setup basic henchman/NPC variables.
        SetLocalObject(oCreature, "0_Master", oMaster);
    }
    // Give them back any gold they had.
    int nGold = GetLocalInt(oCreature, "0_Gold");
    GiveGoldToCreature(oCreature, nGold);
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
    Spell.iCompAmount = 5; // 25,000gp worth of diamonds.
    Spell.iDivineFocus = TRUE;
    Spell.iAreaShape = SHAPE_RANGE_TARGET;
    Spell.iLineOfSight = TRUE;
    Spell.iObjectFilter = OBJECT_TYPE_CREATURE;
    Spell.iTargetType = TARGET_TYPE_ALLIES;
    Spell.iDurationType = DURATION_TYPE_INSTANT;
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
    if(Spell.iSpellID == STOP_SPELL) return;
    // Get the duration of the spell, sets Spell.fDuration.
    Spell = GetDuration(Spell);
    // *******************************************************************
    // ********************** Spell effects ******************************
    // *******************************************************************
    int iHeal, nGold, nAssociateType, bResurrect;
    string sQuestID;
    object oMaster;
    // Create effect.
    effect eRaise = EffectResurrection();
    eRaise = SetEffectCasterLevel(eRaise, Spell.iCasterLevel);
    // Create visual effect.
    effect eImpact = EffectVisualEffect(Spell.iImpact);
    //Get the spells target(s).
    Spell = GetSpellTarget(Spell);
    while(GetIsObjectValid(Spell.oAreaTarget))
    {
        // Ressurect spells look for this variable and if set will require specific spell
        // based upon the value: 1 Raise Dead, 2 Resurrection, 3 True Resurrection.
        if(GetLocalInt(Spell.oAreaTarget, "0_Raise") <= 3)
        {
            nAssociateType = GetLocalInt(Spell.oAreaTarget, PC_ASSOCIATE_TYPE);
            if(GetObjectType(Spell.oAreaTarget) == OBJECT_TYPE_ITEM &&
               GetTag(Spell.oAreaTarget) == "0_corpse")
            {
                object oCreature;
                string sArray = GetLocalString(Spell.oAreaTarget, "0_Array");
                if(sArray != "")
                {
                    // Get location to safely create creatures and objects.
                    location lLocation = GetLocation(GetWaypointByTag(WP_CREATURE_SPAWN));
                    oCreature = CreateNPC(GetLocation(Spell.oCaster), sArray);
                    NWNX_Object_SetCurrentHitPoints(oCreature, 0);
                }
                else
                {
                    json jCreature = GetLocalJson(Spell.oAreaTarget, "0_Stats");
                    oCreature = JsonToObject(jCreature, GetLocation(Spell.oCaster), OBJECT_INVALID, TRUE);
                }
                DelayCommand(2.0f, ApplyEffectToObject(DURATION_TYPE_INSTANT, eImpact, oCreature));
                DelayCommand(2.0, SetupAssociateWithTrueResurrect(Spell.oCaster, oCreature, nAssociateType));
                // Remove the corpse.
                DestroyObject(Spell.oAreaTarget);
            }
            else
            {
                //Signal spell cast at event to fire.
                SignalEvent(Spell.oAreaTarget, EventSpellCastAt (Spell.oCaster, Spell.iSpellID, FALSE));
                if(GetIsDead(Spell.oAreaTarget))
                {
                    if(nAssociateType == ASSOCIATE_TYPE_HENCHMAN || nAssociateType == ASSOCIATE_TYPE_NPC)
                    {
                        ApplyEffectAtLocation(DURATION_TYPE_INSTANT, eImpact, GetLocation (Spell.oAreaTarget));
                        SetupAssociateWithTrueResurrect(Spell.oCaster, Spell.oAreaTarget, nAssociateType);    
                    }
                    else if(GetIsCharacter(Spell.oAreaTarget))
                    {
                        //Apply raise dead effect and VFX impact
                        DelayCommand(Spell.fDelay, ApplyEffectAtLocation (DURATION_TYPE_INSTANT, eImpact, GetLocation (Spell.oAreaTarget)));
                        DelayCommand(Spell.fDelay, ApplyEffectToObject(Spell.iDurationType, eRaise, Spell.oAreaTarget));
                        // Now set the hitpoints to full.
                        iHeal = GetMaxHitPoints(Spell.oAreaTarget);
                        DelayCommand(Spell.fDelay, NWNX_Object_SetCurrentHitPoints(Spell.oAreaTarget, iHeal));
                        int nToken = NuiFindWindow(Spell.oAreaTarget, "pldeathpanel");
                        NuiDestroy(Spell.oAreaTarget, nToken);
                    }
                }
            }
        }
        else SendMessages("This spell is not strong enough to bring " + GetName(Spell.oAreaTarget) + " back to life!", COLOR_RED, Spell.oCaster);
        //Get the spells target(s).
        Spell = GetSpellTarget(Spell);
    }
    CleanUpSpell(Spell);
}
