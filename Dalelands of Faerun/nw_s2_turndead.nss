//::///////////////////////////////////////////////
//:: Turn Undead
//:: NW_S2_TurnDead
//:: Copyright (c) 2001 Bioware Corp.
//:://////////////////////////////////////////////
/*
    Players and henchman must have a Holy Symbol.
    Checks domain powers and class to determine the proper turning abilities of
    the casting character based on alignment and feats.
*/
//:://////////////////////////////////////////////
//:: Created By: Preston Watamaniuk
//:: Created On: Nov 2, 2001
//:: Updated On: Jul 15, 2003 - Georg Zoeller
//:://////////////////////////////////////////////
//:: MODIFIED MARCH 5 2003 for Blackguards
//:: MODIFIED JULY 24 2003 for Planar Turning to include turn resistance hd
#include "0i_spells"
#include "0i_master"
#include "0i_s_message"
#include "0i_specialevents"
void TakeControl(object oCaster, object oCreature, int nClassLevel);
void DoEvilTurnUndead(object oCreature, object oTarget, object oMaster, int nHD, int nTurnHD, int nHDCount, int nClassLevel, effect eLink);
void main()
{
    object oCreature = OBJECT_SELF;
    object oMaster = GetPlayerMaster(oCreature);
    // Characters and henchman have to have a holy symbol. Monsters do not.
    if(oMaster != OBJECT_INVALID)
    {
        object oHolySymbol = GetCreatureHasItem(oCreature, CLERIC_HOLY_SYMBOL);
        if(oHolySymbol == OBJECT_INVALID)
        {
            string sText;
            if(oMaster == oCreature) sText = "You do";
            else sText = GetName(oCreature) + " does";
            SendMessages(sText + " not have a holy symbol to Turn Undead!", COLOR_RED, oMaster);
            return;
        }
    }
    int nClericAlignment = GetAlignmentGoodEvil(oCreature);
    int nTotalLevel = GetHitDice(oCreature);
    int nClassLevel = GetTotalUndeadControlledHitDice(oCreature);
    int nTurnLevel = nClassLevel;
    // Flags for bonus turning types
    int nElemental = GetHasFeat(FEAT_AIR_DOMAIN_POWER) + GetHasFeat(FEAT_EARTH_DOMAIN_POWER) + GetHasFeat(FEAT_FIRE_DOMAIN_POWER) + GetHasFeat(FEAT_WATER_DOMAIN_POWER);
    int nVermin = GetHasFeat(FEAT_PLANT_DOMAIN_POWER);
    int nConstructs = GetHasFeat(FEAT_DESTRUCTION_DOMAIN_POWER);
    int nGoodOrEvilDomain =  GetHasFeat(FEAT_GOOD_DOMAIN_POWER) + GetHasFeat(FEAT_EVIL_DOMAIN_POWER);
    int nPlanar = GetHasFeat(854);
    // Make a turning check roll, modify if have the Sun Domain
    int nChrMod = GetAbilityModifier(ABILITY_CHARISMA);
    // The roll to apply to the max HD of undead that can be turned --> nTurnLevel
    int nTurnCheck = d20() + nChrMod;
    // The number of HD of undead that can be turned.
    int nTurnHD = d6(2) + nChrMod + nClassLevel;
    // Check for turning ability changes.
    if(GetHasFeat(FEAT_EMPOWER_TURNING))
    {
        nTurnCheck -= 2;
        nTurnHD += d6(2);
    }
    if(GetHasFeat(FEAT_HEIGHTEN_TURNING))
    {
        int nAdjustment = nClassLevel;
        nTurnCheck += nAdjustment;
        nTurnHD -= nAdjustment / 2;
        if(nTurnHD < 2) nTurnHD = 2;
    }
    int bDeityDomain;
    if(GetHasFeat(FEAT_SUN_DOMAIN_POWER))
    {
        if(GetDeity(oCreature) == "Lathander") bDeityDomain = TRUE;
        nTurnCheck += d4();
        nTurnHD += d6();
    }
    //Determine the maximum HD of the undead that can be turned.
    if(nTurnCheck <= 0) nTurnLevel -= 4;
    else if(nTurnCheck <= 3) nTurnLevel -= 3;
    else if(nTurnCheck <= 6) nTurnLevel -= 2;
    else if(nTurnCheck <= 9) nTurnLevel -= 1;
    else if(nTurnCheck <= 12) { /* Stays the same */ }
    else if(nTurnCheck <= 15) nTurnLevel += 1;
    else if(nTurnCheck <= 18) nTurnLevel += 2;
    else if(nTurnCheck <= 21) nTurnLevel += 3;
    else if(nTurnCheck >= 22) nTurnLevel += 4;
    if(oMaster != OBJECT_INVALID)
    {
        string sText;
        if(oMaster == oCreature) sText = "You";
        else sText = GetName(oCreature);
        SendMessages(sText + " can turn up to a " + IntToString(nTurnLevel) + " Hit Dice undead.", COLOR_YELLOW, oMaster);
    }
    //Gets all creatures in a 20m radius around the caster and turns them or not.
    // If the creatures HD are 1/2 or less of the nClassLevel then the creature is destroyed/controlled.
    int nCnt = 1;
    int nHD, nRacial, bValid, nDamage, nBolsteredHD;
    int nHDCount = 0;
    float fDelay;
    effect eImpact;
    effect eCenterVisual;
    if(nClericAlignment == ALIGNMENT_EVIL)
    {
        eImpact = EffectVisualEffect(VFX_IMP_HARM);
        eCenterVisual = EffectVisualEffect(VFX_FNF_LOS_EVIL_30);
    }
    else
    {
        eImpact = EffectVisualEffect(VFX_IMP_SUNSTRIKE);
        eCenterVisual = EffectVisualEffect(VFX_FNF_LOS_HOLY_30);
    }
    effect ePlane, eDamage, eVisual = EffectVisualEffect(VFX_DUR_MIND_AFFECTING_FEAR);
    effect eFrightened = EffectAttackDecrease(6);
    eFrightened = EffectLinkEffects(EffectSavingThrowDecrease (SAVING_THROW_ALL, 6), eFrightened);
    eFrightened = EffectLinkEffects(EffectSkillDecrease(SKILL_ALL_SKILLS, 6), eFrightened);
    effect eDuration = EffectVisualEffect(VFX_DUR_CESSATE_NEGATIVE);
    eFrightened = EffectLinkEffects(eVisual, eFrightened);
    eFrightened = EffectLinkEffects(eFrightened, eDuration);
    eFrightened = TagEffect(eFrightened, "TURNED");
    effect eDeath = SupernaturalEffect(EffectDeath(TRUE));
    ApplyEffectAtLocation(DURATION_TYPE_INSTANT, eCenterVisual, GetLocation(oCreature));
    //Get nearest enemy within 20m (60ft)
    //Why are you using GetNearest instead of GetFirstObjectInShape - We want closest undead first!
    object oTarget = GetNearestCreature(CREATURE_TYPE_IS_ALIVE, TRUE , oCreature, nCnt,CREATURE_TYPE_PERCEPTION , PERCEPTION_SEEN);
    while(GetIsObjectValid(oTarget) && nHDCount < nTurnHD && GetDistanceToObject(oTarget) <= 20.0)
    {
        SendMessageToPC(oCreature, "GetIsFriend: " + IntToString(GetIsFriend(oTarget, oCreature)));
        if(!GetIsFriend(oTarget, oCreature))
        {
            nRacial = GetRacialType(oTarget);
            if(nRacial == RACIAL_TYPE_OUTSIDER)
            {
                if(nPlanar) // Planar turning decreases spell resistance against turning by 1/2
                {
                     nHD = GetHitDice(oTarget) + (GetSpellResistance(oTarget) / 2) + GetTurnResistanceHD(oTarget);
                }
                else
                {
                    nHD = GetHitDice(oTarget) + (GetSpellResistance(oTarget) + GetTurnResistanceHD(oTarget) );
                }
            }
            // Get an Undead turn resistance while checking if Bolstered!
            else
            {
                nBolsteredHD = GetLocalInt(oTarget, "BOLSTER_UNDEAD");
                if(nBolsteredHD > 0) nHD = nBolsteredHD;
                else nHD = GetHitDice(oTarget) + GetTurnResistanceHD(oTarget);
            }
            if(nHD <= nTurnLevel && nHD <= (nTurnHD - nHDCount))
            {
                // Check the various domain turning types
                if(nRacial == RACIAL_TYPE_UNDEAD) bValid = TRUE;
                else if (nRacial == RACIAL_TYPE_VERMIN && nVermin > 0) bValid = TRUE;
                else if (nRacial == RACIAL_TYPE_ELEMENTAL && nElemental > 0) bValid = TRUE;
                else if (nRacial == RACIAL_TYPE_CONSTRUCT && nConstructs > 0)
                {
                    SignalEvent(oTarget, EventSpellCastAt(oCreature, SPELLABILITY_TURN_UNDEAD));
                    nDamage = d3(nTurnLevel);
                    eDamage = EffectDamage(nDamage, DAMAGE_TYPE_MAGICAL);
                    ApplyEffectToObject(DURATION_TYPE_INSTANT, eImpact, oTarget);
                    DelayCommand(fDelay, ApplyEffectToObject(DURATION_TYPE_INSTANT, eDamage, oTarget));
                    nHDCount += nHD;
                }
                else if (nRacial == RACIAL_TYPE_OUTSIDER && (nGoodOrEvilDomain+nPlanar > 0))
                {
                    bValid = TRUE;
                }
                // If wearing gauntlets of the lich,then can be turned
                else if(GetIsObjectValid(GetItemPossessedBy(oTarget, "x2_gauntletlich")) ||
                        GetTag(GetItemInSlot(INVENTORY_SLOT_ARMS)) == "x2_gauntletlich")
                {
                    bValid = TRUE;
                }
                // Check to see if they are already Turned. We ignore already turned creatures.
                if(HasEffectWithTag(oTarget, "TURNED")) bValid = FALSE;
                // Apply results of the turn
                if(bValid == TRUE)
                {
                    nHDCount = nHDCount + nHD;
                    ApplyEffectToObject(DURATION_TYPE_INSTANT, eImpact, oTarget);
                    // If a cleric has the Sun domain and the deity Lathander.
                    // Destroy the undead target up to the cleric's level.
                    if(bDeityDomain && nClassLevel >= nHD && nRacial == RACIAL_TYPE_UNDEAD)
                    {
                        ePlane = EffectVisualEffect(VFX_IMP_DIVINE_STRIKE_HOLY);
                        ApplyEffectToObject(DURATION_TYPE_INSTANT, ePlane, oTarget);
                        DelayCommand(fDelay, ApplyEffectToObject(DURATION_TYPE_INSTANT, eDeath, oTarget));
                        if(oMaster != OBJECT_INVALID)
                        {
                            DelayCommand(fDelay, SendMessageToPC(oMaster, "With Lathander's power " + GetName(oCreature) + " has destroyed " +
                                GetName(oTarget) + " with " + IntToString(nHD) + " hitdice from a total of " + IntToString(nTurnHD - nHDCount) + " hitdice turning power left."));
                        }
                    }
                    // Normal clerics can destroy/control creatures up to 1/2 their level.
                    else if((nClassLevel/2) >= nHD)
                    {
                        if (nPlanar > 0 && nRacial == RACIAL_TYPE_OUTSIDER)
                        {
                            ePlane = EffectVisualEffect(VFX_IMP_UNSUMMON);
                            ApplyEffectToObject(DURATION_TYPE_INSTANT, ePlane, oTarget);
                            DelayCommand(fDelay, ApplyEffectToObject(DURATION_TYPE_INSTANT, eDeath, oTarget));
                            if(oMaster != OBJECT_INVALID)
                            {
                                DelayCommand(fDelay, SendMessageToPC(oMaster, GetName(oCreature) + " has dismissed " + GetName(oTarget) + " with " + IntToString(nHD) +
                                    " hitdice from a total of " + IntToString(nTurnHD - nHDCount) + " hitdice turning power left."));
                            }
                        }
                        else
                        {
                            // Evil alignments gain control.
                            if(nClericAlignment == ALIGNMENT_EVIL && nRacial == RACIAL_TYPE_UNDEAD)
                            {
                                DelayCommand(fDelay, DoEvilTurnUndead(oCreature, oTarget, oMaster, nHD, nTurnHD, nHDCount, nClassLevel, eFrightened));
                            }
                            else // Good and Neutral alignments destory undead.
                            {
                                ePlane = EffectVisualEffect(VFX_IMP_DIVINE_STRIKE_HOLY);
                                ApplyEffectToObject(DURATION_TYPE_INSTANT, ePlane, oTarget);
                                DelayCommand(fDelay, ApplyEffectToObject(DURATION_TYPE_INSTANT, eDeath, oTarget));
                                if(oMaster != OBJECT_INVALID)
                                {
                                    DelayCommand(fDelay, SendMessageToPC(oMaster, GetName(oCreature) + " has destroyed " + GetName(oTarget) + " with " + IntToString(nHD) +
                                        " hitdice from a total of " + IntToString(nTurnHD - nHDCount) + " hitdice turning power left."));
                                }
                            }
                        }
                    }
                    // We just turn the targets.
                    else
                    {
                        SignalEvent(oTarget, EventSpellCastAt(oCreature, SPELLABILITY_TURN_UNDEAD));
                        ApplyEffectToObject(DURATION_TYPE_TEMPORARY, eFrightened, oTarget, RoundsToSeconds(nClassLevel + 5));
                        if(oMaster != OBJECT_INVALID)
                        {
                            DelayCommand(fDelay, SendMessageToPC(oMaster, GetName(oCreature) + " has frightened " + GetName(oTarget) + " with " + IntToString(nHD) +
                                " Hit Dice from a total of " + IntToString(nTurnHD - nHDCount) + " hitdice turning power left."));
                        }
                    }
                    fDelay += 0.2;
                }
            }
            bValid = FALSE;
        }
        nCnt++;
        oTarget = GetNearestCreature(CREATURE_TYPE_IS_ALIVE,TRUE, oCreature, nCnt,CREATURE_TYPE_PERCEPTION , PERCEPTION_SEEN);
    }
}
void TakeControl(object oCaster, object oCreature, int nClassLevel)
{
    // Used to remove Turned Undead and Animate Dead controlling Hit Dice.
    string sSpellTag = GetLocalString(oCreature, "0_SUMMON_SPELL");
    if(sSpellTag == "ANIMATE_DEAD" || sSpellTag == "TURNED_UNDEAD")
    {
        // We need to make sure to remove them from anyone else who owns them.
        object oOldMaster = GetMaster(oCreature);
        RemoveHenchman(oOldMaster, oCreature);
        DecreaseUndeadControlledHitDice(oOldMaster, oCreature, sSpellTag);
    }
    AddHenchman(oCaster, oCreature);
    // Must mark them as a summons.
    SetLocalInt (oCreature, "0_Summon_ID", TRUE);
    SetLocalString(oCreature, "0_SUMMON_SPELL", "TURNED_UNDEAD");
    SetEventScript (oCreature, EVENT_SCRIPT_CREATURE_ON_BLOCKED_BY_DOOR, "nw_ch_ace");
    SetEventScript (oCreature, EVENT_SCRIPT_CREATURE_ON_END_COMBATROUND, "nw_ch_ac3");
    SetEventScript (oCreature, EVENT_SCRIPT_CREATURE_ON_DIALOGUE, "nw_ch_ac4");
    SetEventScript (oCreature, EVENT_SCRIPT_CREATURE_ON_DAMAGED, "nw_ch_ac5");
    SetEventScript (oCreature, EVENT_SCRIPT_CREATURE_ON_DEATH, "nw_ch_ac7");
    SetEventScript (oCreature, EVENT_SCRIPT_CREATURE_ON_DISTURBED, "nw_ch_ac8");
    SetEventScript (oCreature, EVENT_SCRIPT_CREATURE_ON_HEARTBEAT, "nw_ch_ac1");
    SetEventScript (oCreature, EVENT_SCRIPT_CREATURE_ON_NOTICE, "nw_ch_ac2");
    SetEventScript (oCreature, EVENT_SCRIPT_CREATURE_ON_MELEE_ATTACKED, "nw_ch_ac5");
    SetEventScript (oCreature, EVENT_SCRIPT_CREATURE_ON_RESTED, "nw_ch_ac9");
    SetEventScript (oCreature, EVENT_SCRIPT_CREATURE_ON_SPAWN_IN, "nw_ch_acani9");
    SetEventScript (oCreature, EVENT_SCRIPT_CREATURE_ON_SPELLCASTAT, "nw_ch_acb");
    NWNX_Object_SetDialogResref(oCreature, "co_henchmen");
    // Variable used by AI to keep track of creatures being attacked.
    // We need to clear factions and actions so they stop attacking the wrong creatures.
    object oAttacker = GetLocalObject(oCreature, "AI_ATTACKED_PHYSICAL");
    effect eEffect = EffectCutsceneParalyze();
    if(oAttacker != OBJECT_INVALID)
    {
        ClearPersonalReputation(oAttacker, oCreature);
        ClearAllActions(FALSE, oAttacker);
        ClearPersonalReputation(oCreature, oAttacker);
    }
    ClearAllActions(FALSE, oCreature);
    ApplyEffectToObject(DURATION_TYPE_TEMPORARY, eEffect, oCreature, 3.0f);
    MyrkulSetCheck(oCaster, oCreature);
}
void DoEvilTurnUndead(object oCaster, object oTarget, object oMaster, int nHD, int nTurnHD, int nHDCount, int nClassLevel, effect eFrightened)
{
    effect ePlane;
    if(IncreaseUndeadControlledHitDice(oCaster, oTarget, "TURNED_UNDEAD", nClassLevel))
    {
        ePlane = EffectVisualEffect(VFX_IMP_HEAD_EVIL);
        ApplyEffectToObject(DURATION_TYPE_INSTANT, ePlane, oTarget);
        if(oMaster != OBJECT_INVALID)
        {
            SendMessageToPC(oMaster, "With " + IntToString(nTurnHD - nHDCount) + " hitdice turning power left.");
        }
        TakeControl(oCaster, oTarget, nClassLevel);
    }
    else
    {
        ePlane = EffectVisualEffect(VFX_IMP_DIVINE_STRIKE_HOLY);
        ApplyEffectToObject(DURATION_TYPE_INSTANT, ePlane, oTarget);
        ApplyEffectToObject(DURATION_TYPE_TEMPORARY, eFrightened, oTarget, RoundsToSeconds(nClassLevel + 5));
        if(oMaster != OBJECT_INVALID)
        {
            SendMessageToPC(oMaster, GetName(oCaster) + " has frightened " + GetName(oTarget) + " with " + IntToString(nHD) +
                  " hitdice from a total of " + IntToString(nTurnHD - nHDCount) + " hitdice turning power left.");
        }
    }
}
