/*//////////////////////////////////////////////////////////////////////////////
// Script Name: 0e_th_mon_events
////////////////////////////////////////////////////////////////////////////////
    Tortured Hearts monster event handler.
*///////////////////////////////////////////////////////////////////////////////
#include "0i_actions"
// Monster Tortured Heart heartbeat script.
void ai_th_mon_heart(object oCreature);
// Monster Tortured Heart conversation script.
void ai_th_mon_convo(object oCreature);
// Monster Tortured Heart Melee Attacked script.
void ai_th_mon_attacked(object oCreature);
// Monster Tortured Heart Damaged script.
void ai_th_mon_damaged(object oCreature);
// Monster Tortured Heart perception script.
void ai_th_mon_percept(object oCreature);
void main()
{
    object oCreature = OBJECT_SELF;
    int nEvent = GetCurrentlyRunningEvent();
    //WriteTimestampedLogEntry("0e_th_mon_events [24] " + GetName(oCreature) + " nEvent: " + IntToString(nEvent));
    switch (nEvent)
    {
        case EVENT_SCRIPT_CREATURE_ON_HEARTBEAT:
        {
            ai_th_mon_heart(oCreature);
            ExecuteScript("nw_c2_default1", oCreature);
            if(GetLocalInt(GetModule(), "AI_USING_PRC")) ExecuteScript("prc_npc_hb", oCreature);
            break;
        }
        case EVENT_SCRIPT_CREATURE_ON_NOTICE:
        {
            ExecuteScript("nw_c2_default2", oCreature);
            if(GetLocalInt(GetModule(), "AI_USING_PRC")) ExecuteScript("prc_npc_percep", oCreature);
            break;
        }
        case EVENT_SCRIPT_CREATURE_ON_END_COMBATROUND:
        {
            ExecuteScript("nw_c2_default3", oCreature);
            if(GetLocalInt(GetModule(), "AI_USING_PRC")) ExecuteScript("prc_npc_combat", oCreature);
            break;
        }
        case EVENT_SCRIPT_CREATURE_ON_DIALOGUE:
        {
            ai_th_mon_convo(oCreature);
            ExecuteScript("nw_c2_default4", oCreature);
            if(GetLocalInt(GetModule(), "AI_USING_PRC")) ExecuteScript("prc_npc_conv", oCreature);
            break;
        }
        case EVENT_SCRIPT_CREATURE_ON_MELEE_ATTACKED:
        {
            ai_th_mon_attacked(oCreature);
            ExecuteScript("nw_c2_default5", oCreature);
            if(GetLocalInt(GetModule(), "AI_USING_PRC")) ExecuteScript("prc_npc_physatt", oCreature);
            break;
        }
        case EVENT_SCRIPT_CREATURE_ON_DAMAGED:
        {
            ai_th_mon_damaged(oCreature);
            ExecuteScript("nw_c2_default6", oCreature);
            if(GetLocalInt(GetModule(), "AI_USING_PRC")) ExecuteScript("prc_npc_damaged", oCreature);
            break;
        }
        case EVENT_SCRIPT_CREATURE_ON_SPELLCASTAT:
        {
            ExecuteScript("nw_c2_defaultb", oCreature);
            if(GetLocalInt(GetModule(), "AI_USING_PRC")) ExecuteScript("prc_npc_spellat", oCreature);
            break;
        }
        case EVENT_SCRIPT_CREATURE_ON_BLOCKED_BY_DOOR:
        {
            ExecuteScript("nw_c2_defaulte", oCreature);
            if(GetLocalInt(GetModule(), "AI_USING_PRC")) ExecuteScript("prc_npc_blocked", oCreature);
            break;
        }
        case EVENT_SCRIPT_CREATURE_ON_RESTED:
        {
            if(GetLocalInt(GetModule(), "AI_USING_PRC")) ExecuteScript("prc_npc_rested", oCreature);
            break;
        }
        case EVENT_SCRIPT_CREATURE_ON_DISTURBED:
        {
            ExecuteScript("nw_c2_default8", oCreature);
            if(GetLocalInt(GetModule(), "AI_USING_PRC")) ExecuteScript("prc_npc_disturb", oCreature);
            break;
        }
        case EVENT_SCRIPT_CREATURE_ON_DEATH:
        {
            ExecuteScript("nw_c2_default7", oCreature);
            break;
        }
    }
}

void ai_th_mon_heart(object oCreature)
{
    if (GetTag(oCreature) == "GLYTHE")
    {
        string sGlytheArea = GetTag(GetArea(oCreature));
        string sArea1 = "GlytheroadStinkycave";
        string sArea2 = "PikedaleplainsGlytheroad";
        if ((sGlytheArea == sArea1) || (sGlytheArea == sArea2)) return;
        else
        {
            AssignCommand(oCreature,ClearAllActions());
            DelayCommand(5.0,AssignCommand(oCreature,ActionSpeakString("No adventuring, friend!")));
            SetLocalInt(oCreature, "speech11",0);
            SetLocalInt(oCreature,"nGNBLagMeth",0);
            SetLocalString(oCreature,"sCRSPHB","gennpc_heartbeat");
        }
    }
}
void ai_th_mon_convo(object oCreature)
{
    int nMatch = GetListenPatternNumber();
    if(nMatch == -1)
    {
        if(ai_GetIsBusy(oCreature) || ai_Disabled(oCreature) ||
        GetLocalInt(oCreature, AI_AM_I_SEARCHING) ||
        GetLocalInt(OBJECT_SELF,"BUSY") == 1) return;
        ai_ClearCreatureActions();
        string sName = GetLocalString(OBJECT_SELF,"FuckingFirstName");
        SetCustomToken(5007,sName);
        if (OBJECT_SELF==GetObjectByTag("brawler2"))
        {
            object brawler = GetObjectByTag("brawler1");
            if (GetIsObjectValid(brawler))
            {
                AssignCommand(brawler,ClearAllActions());
                SetLocalString(brawler,"sCRSPHB","nw_c2_default1");
            }
        }
        string sConversation = GetLocalString(oCreature, "sConversation");
        if(sConversation != "") BeginConversation(sConversation);
        else BeginConversation();
    }
}
void ai_th_mon_attacked(object oCreature)
{
    object oSelf = OBJECT_SELF;
    object oAttacker = GetLastAttacker(oSelf);
    if (oAttacker == GetFirstPC())
        {

        if((oSelf == GetObjectByTag("PiousMonk1")) ||
        (oSelf == GetObjectByTag("PiousMonk2")) ||
        (oSelf == GetObjectByTag("PiousMonk3")) ||
        (oSelf == GetObjectByTag("PiousMonk4")) ||
        (oSelf == GetObjectByTag("PiousMonk5")))
        {
            int nRevealed = GetLocalInt(OBJECT_SELF,"nRevealed");
            if(!nRevealed)
            {
                object oMonk1 = GetObjectByTag("PiousMonk1");
                object oMonk2 = GetObjectByTag("PiousMonk2");
                object oMonk3 = GetObjectByTag("PiousMonk3");
                object oMonk4 = GetObjectByTag("PiousMonk4");
                object oMonk5 = GetObjectByTag("PiousMonk5");
                SetName(oMonk1,"Monk of Cyric");
                SetName(oMonk2,"Monk of Cyric");
                SetName(oMonk3,"Monk of Cyric");
                SetName(oMonk4,"Monk of Cyric");
                SetName(oMonk5,"Head Monk of Cyric");
                AssignCommand(oMonk1,SpeakString("Cyric help us!"));
                AssignCommand(oMonk2,SpeakString("In the name of Cyric!"));
                AssignCommand(oMonk3,SpeakString("Great Cyric give me your help!"));
                AssignCommand(oMonk4,SpeakString("Cyric will protect me!"));
                AssignCommand(oMonk5,SpeakString("Let's call Cyric's power!"));
                SetLocalInt(OBJECT_SELF,"nRevealed",1);
            }
        }
        if(oSelf==GetObjectByTag("ShiftyGuy"))
        {
            int nStory = GetLocalInt(OBJECT_SELF,"BehindTower") ;
            if(!nStory)
            {
                float fScaler =4.0;
                int nAction = GetLocalInt(OBJECT_SELF,"Action_OK");
                if (nAction==0)
                {
                    object oWP = GetObjectByTag("FakeFugueJump");
                    object oShifty = GetObjectByTag("ShiftyGuy");
                    object oChar1 = GetObjectByTag("BuyingHalfling");
                    object oChar2 = GetObjectByTag("MerchantGuard");
                    object oChar3 = GetObjectByTag("SudnarRhek");
                    object oChar4 = GetObjectByTag("OldWomanAtWell");
                    SetLocalInt(OBJECT_SELF,"Action_OK",1);
                    // hack but i don't care :)
                    DelayCommand(fScaler+0.5,SetCutsceneMode(GetFirstPC(),1));
                    DelayCommand(fScaler+0.8,AssignCommand(GetFirstPC(),ClearAllActions(TRUE)));
                    DelayCommand(fScaler+1.0,ClearAssociateActions(GetFirstPC(),TRUE));
                    DelayCommand(fScaler+1.5,ExecuteScript("disband_party",GetFirstPC()));
                    DelayCommand(fScaler+1.8,AssignCommand(oShifty,ClearAllActions(TRUE)));
                    DelayCommand(fScaler+1.0,MusicBattleStop(GetArea(GetFirstPC())));
                   DelayCommand(fScaler+1.5,AssignCommand(GetFirstPC(),PlayVoiceChat(VOICE_CHAT_BADIDEA,GetFirstPC())));
                    DelayCommand(fScaler+2.0,AssignCommand(GetFirstPC(),ClearAllActions(TRUE)));
                    DelayCommand(fScaler+3.0,BlackScreen(GetFirstPC()));
                    DelayCommand(fScaler+5.0,AssignCommand(GetFirstPC(),ClearAllActions(TRUE)));
                    DelayCommand(fScaler+5.2,AssignCommand(oChar1,ClearAllActions(TRUE)));
                    DelayCommand(fScaler+5.4,AssignCommand(oChar2,ClearAllActions(TRUE)));
                    DelayCommand(fScaler+5.6,AssignCommand(oChar3,ClearAllActions(TRUE)));
                    DelayCommand(fScaler+5.7,AssignCommand(oChar4,ClearAllActions(TRUE)));
                    DelayCommand(fScaler+5.8,AssignCommand(oShifty,ClearAllActions(TRUE)));
                    DelayCommand(fScaler+6.0,AssignCommand(oShifty,ClearAllActions(TRUE)));
                    DelayCommand(fScaler+5.6,AssignCommand(GetFirstPC(),ClearAllActions(TRUE)));
                    DelayCommand(fScaler+6.2,AssignCommand(GetFirstPC(),ActionJumpToObject(oWP,0)));
                    DelayCommand(fScaler+10.0,SetCutsceneMode(GetFirstPC(),0));
                    DelayCommand(fScaler+11.0,FadeFromBlack(GetFirstPC(),FADE_SPEED_FASTEST));
                    DelayCommand(fScaler+12.5,AssignCommand(GetFirstPC(),SpeakString("For my bold action, I was arrested soon and put in jail...")));
                    DelayCommand(fScaler+15.0,AssignCommand(GetFirstPC(),SpeakString("...that's why I could not solve the mystery of my Pikedale adventures...")));
                }
            }
        }
        if((oSelf==GetObjectByTag("Glytheancaptain")) ||
           (oSelf==GetObjectByTag("GUARD_Nather")) ||
           (oSelf==GetObjectByTag("Governor")))
        {
            ExecuteScript("leave_lamyr",GetModule());
            ExecuteScript("leave_klarie",GetModule());
            ExecuteScript("leave_fenor",GetModule());
        }
        if((oSelf==GetObjectByTag("HS_KLARIE")) ||
           (oSelf==GetObjectByTag("HS_DRANO")) ||
           (oSelf==GetObjectByTag("HS_JENN")) ||
           (oSelf==GetObjectByTag("HS_ZACHO")) ||
           (oSelf==GetObjectByTag("HS_CALD")) ||
           (oSelf==GetObjectByTag("HS_DARENCE")) ||
           (oSelf==GetObjectByTag("HS_PACKPONY")) ||
           (oSelf==GetObjectByTag("HS_DOG")) ||
           (oSelf==GetObjectByTag("HS_ELRINIA")) ||
           (oSelf==GetObjectByTag("HS_FENIEL")) ||
           (oSelf==GetObjectByTag("HS_MABUR")) ||
           (oSelf==GetObjectByTag("HS_NEBRIN")) ||
           (oSelf==GetObjectByTag("HS_SAGO")))
        {
            ChangeToStandardFaction(oSelf,STANDARD_FACTION_HOSTILE);
        }
        if((oSelf==GetObjectByTag("HS_FENOR")) ||
           (oSelf==GetObjectByTag("HS_LAMYR")))
            {
                object oGirl  = GetObjectByTag("PDDefenderFaction");
                ChangeFaction(oSelf,oGirl);
            }
        if((oSelf==GetObjectByTag("HS_JENN")) ||
           (oSelf==GetObjectByTag("HS_HIRAG")) ||
           (oSelf==GetObjectByTag("HS_DUPPI")))
        {
            object oBoy  = GetObjectByTag("CrestGuardFaction");
            ChangeFaction(oSelf,oBoy);
        }
    }
    // Darence
    if(oSelf==GetObjectByTag("DARENCE_TO_HIRE"))
    {
        int nStory = GetLocalInt(GetModule(),"SignetRingGiven") ;
        if (!nStory)
        {
            object oRing = CreateItemOnObject("darencesignet",OBJECT_SELF);
            SetDroppableFlag(oRing,1);
            SetLocalInt(GetModule(),"SignetRingGiven",1) ;
        }
    }
    if(oSelf==GetObjectByTag("CarraliaDaranaver"))
    {
        int nStatus = GetLocalInt(OBJECT_SELF,"Battle_on");
        if(nStatus==0)
        {
            object oDrowboy = GetObjectByTag("DrowFakeBoy");
            object oBodyGuard = GetObjectByTag("TheMatronsbodyguard");
            int nStory = GetLocalInt(oBodyGuard,"speech5");
            if(nStory==TRUE)
            {
                ChangeToStandardFaction(oBodyGuard,STANDARD_FACTION_DEFENDER);
                SetLocalInt(oBodyGuard,"speech7",TRUE) ;
                AdjustReputation(oAttacker,oDrowboy,-50);
                AssignCommand(oBodyGuard,ClearAllActions(TRUE));
                DelayCommand(0.5,ClearPersonalReputation(oBodyGuard,oAttacker));
                DelayCommand(1.5,AssignCommand(oBodyGuard,ActionAttack(GetObjectByTag("CarraliaDaranaver"))));
                DelayCommand(1.0,AssignCommand(GetObjectByTag("CarraliaDaranaver"),SpeakString("You also, o damsel...")));
                SetLocalInt(GetModule(),"Drow_Form_Finished",1);
                SetLocalInt(OBJECT_SELF,"Battle_on",1);
            }
        }
    }
    if(oSelf==GetObjectByTag("CarraliaDaranaver2"))
    {
        int nStatus = GetLocalInt(OBJECT_SELF,"Battle_on");
        if(nStatus==0)
        {
            object oDrowboy = GetObjectByTag("DrowFakeBoy");
            object oBodyGuard = GetObjectByTag("TheMatronsbodyguard");
            int nStory = GetLocalInt(oBodyGuard,"speech5");
            if (nStory==TRUE)
            {
                ChangeToStandardFaction(oBodyGuard,STANDARD_FACTION_DEFENDER);
                SetLocalInt(oBodyGuard,"speech7",TRUE) ;
                AdjustReputation(oAttacker,oDrowboy,-50);
                AssignCommand(oBodyGuard,ClearAllActions(TRUE));
                DelayCommand(0.5,ClearPersonalReputation(oBodyGuard,oAttacker));
                DelayCommand(1.5,AssignCommand(oBodyGuard,ActionAttack(GetObjectByTag("CarraliaDaranaver2"))));
                DelayCommand(1.0,AssignCommand(GetObjectByTag("CarraliaDaranaver2"),SpeakString("You also, o damsel...")));
                SetLocalInt(GetModule(),"Drow_Form_Finished",1);
                SetLocalInt(OBJECT_SELF,"Battle_on",1);
            }
        }
    }
    object oTargett = GetFirstFactionMember(oSelf,FALSE);
    while(oTargett != OBJECT_INVALID)
    {
        float fDist = GetDistanceBetween(oSelf,oTargett);
        if ((oTargett == oSelf) || (fDist>30.0))
        {
            oTargett = GetNextFactionMember(oSelf,FALSE);
        }
        else
        {
            AssignCommand(oTargett,ActionAttack(oAttacker));
            oTargett = GetNextFactionMember(oSelf,FALSE);
        }
    }
    if(OBJECT_SELF==GetObjectByTag("ZOLTAN2"))
    {
        SetLocalInt(OBJECT_SELF,"nGNBDisabled",1);
    }
    if(OBJECT_SELF==GetObjectByTag("Chris"))
    {
        SetLocalInt(OBJECT_SELF,"nGNBDisabled",1);
    }
    if(OBJECT_SELF==GetObjectByTag("Chris2"))
    {
        SetLocalInt(OBJECT_SELF,"nGNBDisabled",1);
    }
    if((OBJECT_SELF==GetObjectByTag("CityHallGuard5")) ||
       (OBJECT_SELF==GetObjectByTag("GUARD_CityHallUpperGuard")))
    {
        object oTrigger = GetObjectByTag("StoryManagerTriggerCityHall");
        DestroyObject(oTrigger);
        object oDoor = GetObjectByTag("EXC_FancyDoorToCorridors");
        SetLocked(oDoor,0);
    }
    if(OBJECT_SELF==GetObjectByTag("DrowSpy"))
    {
        object dwarfadventurer = GetObjectByTag("TeamDwarf");
        SetLocalInt(dwarfadventurer,"speech2",TRUE) ;
    }
    if(OBJECT_SELF==GetObjectByTag("Thanyr"))
    {
        SetLocalInt(GetModule(),"No_Ceremony",1);
    }
    if(OBJECT_SELF==GetObjectByTag("Toman"))
    {
        SetLocalInt(GetModule(),"No_Ceremony",1);
    }
    if(OBJECT_SELF==GetObjectByTag("Thiefling"))
    {
        DestroyObject(GetObjectByTag("THIEF_SPAWNER"));
        SetLocalInt(GetModule(),"THIEF_ATTACKED",1);
    }
    if(OBJECT_SELF==GetObjectByTag("Noili"))
    {
        object nHand = GetItemInSlot(INVENTORY_SLOT_RIGHTHAND);
        if(nHand==OBJECT_INVALID)
        {
            ActionEquipMostDamagingMelee();
        }
    }
}
void ai_th_mon_damaged(object oCreature)
    {
        object oDamager = GetLastDamager();
        // Greatest Damage Dealt
        int nDam = GetTotalDamageDealt();
        int nCurr = GetLocalInt(oDamager,"nGREATEST_DAMAGE");
        if(nDam > nCurr)
        {
            SetLocalInt(oDamager,"nGREATEST_DAMAGE",nDam);
        }
        // Toman Winblood
        if(oCreature==GetObjectByTag("Toman"))
        {
            int maxHP = GetMaxHitPoints();
            int curHP =GetCurrentHitPoints();
            effect eff1 = EffectVisualEffect(VFX_FNF_SUMMON_GATE);
            object thanyr = GetObjectByTag("Thanyr");
            if(curHP<=(15))
            {
                SetPlotFlag(oCreature,TRUE);
                AssignCommand(oCreature,ClearAllActions(TRUE));
                SurrenderToEnemies();
                ClearAllActions(TRUE);
                    if (GetCurrentHitPoints(thanyr)>0)
                        {
                        AssignCommand(oCreature,ActionSpeakString("FAREWELL, THANYR! I'LL LET YOU DEAL WITH THIS ZEALOT!",TALKVOLUME_SHOUT));
                        }
                    if (GetCurrentHitPoints(thanyr)<1)
                        {
                        AssignCommand(oCreature,ActionSpeakString("FAREWELL, FOOL! WE'LL MEET LATER!",TALKVOLUME_SHOUT));
                        }

                if (GetCurrentHitPoints(GetFirstPC())>0)
                        {
                        ExecuteScript("exec_suspendmus",GetModule());
                AddJournalQuestEntry("Start",18,GetFirstPC(),TRUE,FALSE,TRUE);
                        }

                        if (GetCurrentHitPoints(thanyr)>0)
                        {
                AssignCommand(thanyr,ClearAllActions());
                AssignCommand(thanyr,SetFacingPoint(GetPosition(oCreature)));
                AssignCommand(thanyr,ActionSpeakString("YOU TRAITOR! YOU TRAITOR!",TALKVOLUME_SHOUT));
                        }
                DelayCommand(2.8,SetPlotFlag(oCreature,FALSE));
                ApplyEffectAtLocation(DURATION_TYPE_INSTANT,eff1,GetLocation(oCreature),4.0);
                DelayCommand(3.0,DestroyObject(oCreature));
                }
        }
        // Pikedalean prostitute
        if(oCreature==GetObjectByTag("PikedaleProsti"))
        {
            int story =  GetLocalInt(GetModule(),"nEricaLyndtalk1");
            object right = GetItemInSlot(INVENTORY_SLOT_RIGHTHAND,GetLastDamager());
            if(story)
            {
                if(GetIsObjectValid(right)==FALSE)
                {
                    object oWayP  = GetObjectByTag("GuardStandshere_Harlot");
                    object oGate = GetObjectByTag("Residential06_Nothing") ;
                    object oWhore = GetObjectByTag("PikedaleProsti");
                    SetLocalInt(oWhore,"nGNBDisabled",1);
                    SetLocalInt(oWhore,"FINISHED",1);
                    SetLocalInt(GetModule(),"nWhoreIdea3",1);
                    SetLocalInt(oWhore,"Must_move",1);
                    DestroyObject(oWayP,0.0);
                    AssignCommand(oWhore,ClearAllActions(TRUE));
                    SurrenderToEnemies();
                    AssignCommand(oWhore,ActionSpeakString("PLEASE! Don't hurt me! I'll leave immediately!",TALKVOLUME_SHOUT));
                    AssignCommand(GetLastDamager(),ClearAllActions(TRUE));
                    AssignCommand(oWhore,ActionForceMoveToObject(oGate,TRUE));
                    ExecuteScript("exec_suspendmus",GetModule());
                    AddJournalQuestEntry("Prostitute",6,GetLastDamager(),TRUE,FALSE,FALSE);
                    SetLocalInt(GetModule(),"nProstiANDElf1",TRUE);
                    GiveXPToCreature(GetLastDamager(),250);
                    DelayCommand(3.0,DestroyObject(oCreature));
                }
            }
        }
        // Surrendering Gnoll
        if(oCreature==GetObjectByTag("SurrenderingGnoll"))
        {
            int maxHP = GetMaxHitPoints();
            int curHP =GetCurrentHitPoints();
            object wp = GetObjectByTag("GnollWP");
            int nStory = GetLocalInt(GetModule(),"Gnoll_Surrendered");
            if((nStory==0) && (curHP<=(maxHP/2)))
            {
                ClearPersonalReputationWithFaction(GetFirstPC(),oCreature);
                ChangeFaction(oCreature,GetObjectByTag("SewerGnoll"));
                ClearNearbyFriendActions(GetFirstPC(),TRUE);
                ClearAssociateActions(GetFirstPC(),TRUE);
                ClearAllActions(TRUE);
                AssignCommand(oCreature,ActionSpeakString("PLEASE! Kill me not! Kill me not!",TALKVOLUME_SHOUT));
                AssignCommand(oCreature,ActionForceMoveToObject(wp,TRUE,0.0,100.0));
                SetLocalInt(GetModule(),"Gnoll_Surrendered",TRUE);
            }
        }
        // PERAGO THE ADVENTURER IN THE DREAMY LADY INN
        if(oCreature==GetObjectByTag("GUARD_Perago")){
        int help = GetLocalInt(oCreature,"help");
        if(help==0)
        {
            object wp = GetObjectByTag("PatronsComeHere");
            object patron1 = GetObjectByTag("DreamLadypatron1");
            object patron2 = GetObjectByTag("DreamLadypatron2");
            object patron3 = GetObjectByTag("DreamLadypatron3");
            object boss = GetObjectByTag("BigBoss");
            SetLocalInt(boss,"speech9",1);
            AssignCommand(oCreature,SpeakString("Help! Help!"));
            SetLocalInt(patron1,"FINISHED",1);
            SetLocalInt(patron1,"nGNBDisabled",1);
            ChangeToStandardFaction(patron1,STANDARD_FACTION_HOSTILE);
            SetLocalInt(patron2,"FINISHED",1);
            SetLocalInt(patron2,"nGNBDisabled",1);
            ChangeToStandardFaction(patron2,STANDARD_FACTION_HOSTILE);
            SetLocalInt(patron3,"FINISHED",1);
            SetLocalInt(patron3,"nGNBDisabled",1);
            ChangeToStandardFaction(patron3,STANDARD_FACTION_HOSTILE);
            AssignCommand(patron1,ClearAllActions());
            AssignCommand(patron1,ActionJumpToObject(wp,FALSE));
            AssignCommand(patron2,ClearAllActions());
            AssignCommand(patron2,ActionJumpToObject(wp,FALSE));
            AssignCommand(patron3,ClearAllActions());
            AssignCommand(patron3,ActionJumpToObject(wp,FALSE));
            SetLocalInt(oCreature,"help",1);
        }
    }
    // END
    //RAKSHASA
    if((GetTag(oCreature)=="RAKSHASA_MINION") ||
       (GetTag(oCreature)=="NW_RAKSHASA"))
    {
        object damager = GetLastDamager();
        object bolt =  GetItemInSlot(INVENTORY_SLOT_BOLTS,damager);
        if (GetTag(bolt)=="Blessedcrossbowquarrel")
        {
            effect eff1 = EffectDamage(GetMaxHitPoints(oCreature));
            ApplyEffectToObject(DURATION_TYPE_INSTANT,eff1,oCreature,1.0);
            AssignCommand(damager,SendMessageToPC(damager,"The blessed crossbow quarrel has killed the Rakshasa!"));
        }
    }
}