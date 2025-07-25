//Modified version of X0_CH_HEN_HEART
//OnHeartbeat event handler for henchmen/associates.
//Customized for Zarala
#include "X0_INC_HENAI"
#include "x2_inc_itemprop"
//levels up the henchman assigned to oPC
//modified version of Bioware's LevelUpXP1Henchman function
void LevelUpMyHenchman(object oPC)
{
    if(!GetIsObjectValid(oPC)) return;
    int i = 1;
    object oAssociate;
    for (i=1; i<= GetMaxHenchmen(); i++)
    {
        oAssociate = GetAssociate(ASSOCIATE_TYPE_HENCHMAN, oPC, i);
        if ( GetIsObjectValid(oAssociate) )
        {
            // * Followers do not level up
            if (GetLocalInt(oAssociate, "X2_JUST_A_FOLLOWER") == FALSE)
            {
                int nResult;
                int nLevel = GetHitDice(oPC);
                string sTag = GetStringLowerCase(GetTag(oAssociate));
                //arrange for the Henchman to lag one level behind the player
                if (nLevel > 1) nLevel=nLevel-1;
                if (sTag == "zarala001")
                {
                 object oZhide=GetItemPossessedBy(oAssociate,"airgenhide001");
                 object oZgarb=GetItemPossessedBy(oAssociate,"zararm001");
                 object oZcloak=GetItemPossessedBy(oAssociate,"zarcloak001");
                 int nAddpol=X2_IP_ADDPROP_POLICY_REPLACE_EXISTING;
                 LevelHenchmanUpTo(oAssociate, nLevel, CLASS_TYPE_INVALID,0, PACKAGE_NPC_BARD);
                 if (nLevel >= 5 && nLevel < 10 && GetLocalInt(oAssociate,"ITEMLEVEL") < 5)
                  {
                   IPSafeAddItemProperty(oZhide,ItemPropertyBonusSavingThrowVsX(IP_CONST_SAVEVS_ELECTRICAL,2),0.0,nAddpol,FALSE,TRUE);
                   IPSafeAddItemProperty(oZhide,ItemPropertyBonusSavingThrowVsX(IP_CONST_SAVEVS_SONIC,2),0.0,nAddpol,FALSE,TRUE);
                   IPSafeAddItemProperty(oZgarb,ItemPropertyACBonus(2));
                   IPSafeAddItemProperty(oZgarb,ItemPropertyAbilityBonus(IP_CONST_ABILITY_CHA,2),0.0,nAddpol,FALSE,TRUE);
                   IPSafeAddItemProperty(oZgarb,ItemPropertyBonusSavingThrow(IP_CONST_SAVEBASETYPE_FORTITUDE,2),0.0,nAddpol,FALSE,TRUE);
                   IPSafeAddItemProperty(oZgarb,ItemPropertySkillBonus(SKILL_CONCENTRATION,2),0.0,nAddpol,FALSE,TRUE);
                   IPSafeAddItemProperty(oZgarb,ItemPropertyDamageReduction(IP_CONST_DAMAGEREDUCTION_2,IP_CONST_DAMAGESOAK_5_HP),0.0,nAddpol,FALSE,TRUE);
                   IPSafeAddItemProperty(oZcloak,ItemPropertyBonusSpellResistance(IP_CONST_SPELLRESISTANCEBONUS_12));
                   SetLocalInt(oAssociate,"ITEMLEVEL",5);
                  }
                 else if (nLevel >= 10 && nLevel < 15 && GetLocalInt(oAssociate,"ITEMLEVEL") < 10)
                  {
                   IPSafeAddItemProperty(oZhide,ItemPropertyBonusSavingThrowVsX(IP_CONST_SAVEVS_ELECTRICAL,3),0.0,nAddpol,FALSE,TRUE);
                   IPSafeAddItemProperty(oZhide,ItemPropertyBonusSavingThrowVsX(IP_CONST_SAVEVS_SONIC,3),0.0,nAddpol,FALSE,TRUE);
                   IPSafeAddItemProperty(oZgarb,ItemPropertyACBonus(3));
                   IPSafeAddItemProperty(oZgarb,ItemPropertyAbilityBonus(IP_CONST_ABILITY_CHA,3),0.0,nAddpol,FALSE,TRUE);
                   IPSafeAddItemProperty(oZgarb,ItemPropertyBonusSavingThrow(IP_CONST_SAVEBASETYPE_FORTITUDE,3),0.0,nAddpol,FALSE,TRUE);
                   IPSafeAddItemProperty(oZgarb,ItemPropertySkillBonus(SKILL_CONCENTRATION,3),0.0,nAddpol,FALSE,TRUE);
                   IPSafeAddItemProperty(oZgarb,ItemPropertyDamageReduction(IP_CONST_DAMAGEREDUCTION_3,IP_CONST_DAMAGESOAK_5_HP),0.0,nAddpol,FALSE,TRUE);
                   IPSafeAddItemProperty(oZcloak,ItemPropertyBonusSpellResistance(IP_CONST_SPELLRESISTANCEBONUS_16));
                   SetLocalInt(oAssociate,"ITEMLEVEL",10);
                  }
                 else if (nLevel >= 15 && nLevel < 20 && GetLocalInt(oAssociate,"ITEMLEVEL") < 15)
                  {
                   IPSafeAddItemProperty(oZhide,ItemPropertyBonusSavingThrowVsX(IP_CONST_SAVEVS_ELECTRICAL,4),0.0,nAddpol,FALSE,TRUE);
                   IPSafeAddItemProperty(oZhide,ItemPropertyBonusSavingThrowVsX(IP_CONST_SAVEVS_SONIC,4),0.0,nAddpol,FALSE,TRUE);
                   IPSafeAddItemProperty(oZgarb,ItemPropertyACBonus(4));
                   IPSafeAddItemProperty(oZgarb,ItemPropertyAbilityBonus(IP_CONST_ABILITY_CHA,4),0.0,nAddpol,FALSE,TRUE);
                   IPSafeAddItemProperty(oZgarb,ItemPropertyBonusSavingThrow(IP_CONST_SAVEBASETYPE_FORTITUDE,4),0.0,nAddpol,FALSE,TRUE);
                   IPSafeAddItemProperty(oZgarb,ItemPropertySkillBonus(SKILL_CONCENTRATION,4),0.0,nAddpol,FALSE,TRUE);
                   IPSafeAddItemProperty(oZgarb,ItemPropertyDamageReduction(IP_CONST_DAMAGEREDUCTION_4,IP_CONST_DAMAGESOAK_5_HP),0.0,nAddpol,FALSE,TRUE);
                   IPSafeAddItemProperty(oZcloak,ItemPropertyBonusSpellResistance(IP_CONST_SPELLRESISTANCEBONUS_18));
                   SetLocalInt(oAssociate,"ITEMLEVEL",15);
                  }
                 else if (nLevel >= 20 && nLevel < 25 && GetLocalInt(oAssociate,"ITEMLEVEL") < 20)
                  {
                   IPSafeAddItemProperty(oZhide,ItemPropertyBonusSavingThrowVsX(IP_CONST_SAVEVS_ELECTRICAL,5),0.0,nAddpol,FALSE,TRUE);
                   IPSafeAddItemProperty(oZhide,ItemPropertyBonusSavingThrowVsX(IP_CONST_SAVEVS_SONIC,5),0.0,nAddpol,FALSE,TRUE);
                   IPSafeAddItemProperty(oZgarb,ItemPropertyACBonus(5));
                   IPSafeAddItemProperty(oZgarb,ItemPropertyAbilityBonus(IP_CONST_ABILITY_CHA,5),0.0,nAddpol,FALSE,TRUE);
                   IPSafeAddItemProperty(oZgarb,ItemPropertyBonusSavingThrow(IP_CONST_SAVEBASETYPE_FORTITUDE,5),0.0,nAddpol,FALSE,TRUE);
                   IPSafeAddItemProperty(oZgarb,ItemPropertySkillBonus(SKILL_CONCENTRATION,5),0.0,nAddpol,FALSE,TRUE);
                   IPSafeAddItemProperty(oZgarb,ItemPropertyDamageReduction(IP_CONST_DAMAGEREDUCTION_5,IP_CONST_DAMAGESOAK_5_HP),0.0,nAddpol,FALSE,TRUE);
                   IPSafeAddItemProperty(oZcloak,ItemPropertyBonusSpellResistance(IP_CONST_SPELLRESISTANCEBONUS_22));
                   SetLocalInt(oAssociate,"ITEMLEVEL",20);
                  }
                 else if (nLevel >= 25 && nLevel < 30 && GetLocalInt(oAssociate,"ITEMLEVEL") < 25)
                  {
                   IPSafeAddItemProperty(oZhide,ItemPropertyBonusSavingThrowVsX(IP_CONST_SAVEVS_ELECTRICAL,6),0.0,nAddpol,FALSE,TRUE);
                   IPSafeAddItemProperty(oZhide,ItemPropertyBonusSavingThrowVsX(IP_CONST_SAVEVS_SONIC,6),0.0,nAddpol,FALSE,TRUE);
                   IPSafeAddItemProperty(oZgarb,ItemPropertyACBonus(6));
                   IPSafeAddItemProperty(oZgarb,ItemPropertyAbilityBonus(IP_CONST_ABILITY_CHA,6),0.0,nAddpol,FALSE,TRUE);
                   IPSafeAddItemProperty(oZgarb,ItemPropertyBonusSavingThrow(IP_CONST_SAVEBASETYPE_FORTITUDE,6),0.0,nAddpol,FALSE,TRUE);
                   IPSafeAddItemProperty(oZgarb,ItemPropertySkillBonus(SKILL_CONCENTRATION,6),0.0,nAddpol,FALSE,TRUE);
                   IPSafeAddItemProperty(oZgarb,ItemPropertyDamageReduction(IP_CONST_DAMAGEREDUCTION_6,IP_CONST_DAMAGESOAK_5_HP),0.0,nAddpol,FALSE,TRUE);
                   IPSafeAddItemProperty(oZcloak,ItemPropertyBonusSpellResistance(IP_CONST_SPELLRESISTANCEBONUS_24));
                   SetLocalInt(oAssociate,"ITEMLEVEL",25);
                  }
                 else if (nLevel >= 30 && nLevel < 35 && GetLocalInt(oAssociate,"ITEMLEVEL") < 30)
                  {
                   IPSafeAddItemProperty(oZhide,ItemPropertyBonusSavingThrowVsX(IP_CONST_SAVEVS_ELECTRICAL,7),0.0,nAddpol,FALSE,TRUE);
                   IPSafeAddItemProperty(oZhide,ItemPropertyBonusSavingThrowVsX(IP_CONST_SAVEVS_SONIC,7),0.0,nAddpol,FALSE,TRUE);
                   IPSafeAddItemProperty(oZgarb,ItemPropertyACBonus(7));
                   IPSafeAddItemProperty(oZgarb,ItemPropertyAbilityBonus(IP_CONST_ABILITY_CHA,7),0.0,nAddpol,FALSE,TRUE);
                   IPSafeAddItemProperty(oZgarb,ItemPropertyBonusSavingThrow(IP_CONST_SAVEBASETYPE_FORTITUDE,7),0.0,nAddpol,FALSE,TRUE);
                   IPSafeAddItemProperty(oZgarb,ItemPropertySkillBonus(SKILL_CONCENTRATION,7),0.0,nAddpol,FALSE,TRUE);
                   IPSafeAddItemProperty(oZgarb,ItemPropertyDamageReduction(IP_CONST_DAMAGEREDUCTION_7,IP_CONST_DAMAGESOAK_5_HP),0.0,nAddpol,FALSE,TRUE);
                   IPSafeAddItemProperty(oZcloak,ItemPropertyBonusSpellResistance(IP_CONST_SPELLRESISTANCEBONUS_28));
                   SetLocalInt(oAssociate,"ITEMLEVEL",30);
                  }
                 else if (nLevel >= 35 && nLevel < 40 && GetLocalInt(oAssociate,"ITEMLEVEL") < 35)
                  {
                   IPSafeAddItemProperty(oZhide,ItemPropertyBonusSavingThrowVsX(IP_CONST_SAVEVS_ELECTRICAL,8),0.0,nAddpol,FALSE,TRUE);
                   IPSafeAddItemProperty(oZhide,ItemPropertyBonusSavingThrowVsX(IP_CONST_SAVEVS_SONIC,8),0.0,nAddpol,FALSE,TRUE);
                   IPSafeAddItemProperty(oZgarb,ItemPropertyACBonus(8));
                   IPSafeAddItemProperty(oZgarb,ItemPropertyAbilityBonus(IP_CONST_ABILITY_CHA,8),0.0,nAddpol,FALSE,TRUE);
                   IPSafeAddItemProperty(oZgarb,ItemPropertyBonusSavingThrow(IP_CONST_SAVEBASETYPE_FORTITUDE,8),0.0,nAddpol,FALSE,TRUE);
                   IPSafeAddItemProperty(oZgarb,ItemPropertySkillBonus(SKILL_CONCENTRATION,8),0.0,nAddpol,FALSE,TRUE);
                   IPSafeAddItemProperty(oZgarb,ItemPropertyDamageReduction(IP_CONST_DAMAGEREDUCTION_8,IP_CONST_DAMAGESOAK_5_HP),0.0,nAddpol,FALSE,TRUE);
                   IPSafeAddItemProperty(oZcloak,ItemPropertyBonusSpellResistance(IP_CONST_SPELLRESISTANCEBONUS_30));
                   SetLocalInt(oAssociate,"ITEMLEVEL",35);
                  }
                 }
                else LevelHenchmanUpTo(oAssociate, nLevel);
            }
        }
    }
}
//modified version of Bioware's HireHenchman function
void HireHench(object oPC, object oHench=OBJECT_SELF, int bAdd=TRUE)
{
    if(!GetIsObjectValid(oPC) || !GetIsObjectValid(oHench)) return;
    // Fire the PC's former henchman if necessary
    int nCountHenchmen = X2_GetNumberOfHenchmen(oPC);
    int nNumberOfFollowers = X2_GetNumberOfHenchmen(oPC, TRUE);
    int nMaxHenchmen = GetMaxHenchmen();
    // Adding this henchman would exceed the module imposed henchman limit.
    // Fire the first henchman The last slot is reserved for the follower
    if((nCountHenchmen  >= nMaxHenchmen) && bAdd == TRUE) X2_FireFirstHenchman(oPC);
    // Mark the henchman as working for the given player
    if (!GetPlayerHasHired(oPC, oHench))
    {
        // This keeps track if the player has EVER hired this henchman
        // Floodgate only (XP1). Should never store info to a database as game runs, only between modules or in Persistent setting
        if (GetLocalInt(GetModule(), "X2_L_XP2") !=  1) SetPlayerHasHiredInCampaign(oPC, oHench);
        SetPlayerHasHired(oPC, oHench);
    }
    SetLastMaster(oPC, oHench);
    // Clear the 'quit' setting in case we just persuaded
    // the henchman to rejoin us.
    SetDidQuit(oPC, oHench, FALSE);
    // If we're hooking back up with the henchman after s/he
    //  died, clear that.
    SetDidDie(FALSE, oHench);
    SetKilled(oPC, oHench, FALSE);
    SetResurrected(oPC, oHench, FALSE);
    // Turn on standard henchman listening patterns
    SetAssociateListenPatterns(oHench);
    // By default, companions come in with Attack Nearest and Follow
    // modes enabled.
    SetLocalInt(oHench, "NW_COM_MODE_COMBAT", ASSOCIATE_COMMAND_ATTACKNEAREST);
    SetLocalInt(oHench, "NW_COM_MODE_MOVEMENT", ASSOCIATE_COMMAND_FOLLOWMASTER);
    // Add the henchman
    if (bAdd == TRUE)
    {
        AddHenchman(oPC, oHench);
        DelayCommand(1.0, AssignCommand(oHench, LevelUpMyHenchman(oPC)));
        SetModuleXPScale(6);
        SendMessageToPC(GetPCSpeaker(),"XP Scale Adjusted for Added Henchman");
    }
}
void main()
{
    // If the henchman is in dying mode, make sure they are non commandable.
    // Sometimes they seem to 'slip' out of this mode
    int bDying = GetIsHenchmanDying();
    if (bDying == TRUE)
    {
        int bCommandable = GetCommandable();
        if (bCommandable == TRUE)
        {
            // lie down again
            ActionPlayAnimation(ANIMATION_LOOPING_DEAD_FRONT, 1.0, 65.0);
            SetCommandable(FALSE);
        }
    }
    // If we're dying or busy, we return
    // (without sending the user-defined event)
    if(GetAssociateState(NW_ASC_IS_BUSY) || bDying) return;
    //Custom stuff begins here.
    object oMast = GetFirstPC();
    if (!GetIsDead(OBJECT_SELF) && !IsInConversation(OBJECT_SELF)
        && GetAssociateType(OBJECT_SELF) == ASSOCIATE_TYPE_NONE
        && GetLocalInt(GetModule(),"ZARALA") == 1
        && !GetHasEffect(EFFECT_TYPE_PETRIFY,OBJECT_SELF))
     {
      AssignCommand(OBJECT_SELF,JumpToLocation(GetLocation(oMast)));
      HireHench(oMast,OBJECT_SELF);
      SpeakString("От менї так легко не избавитьсї!");
     }
    if (GetHasEffect(EFFECT_TYPE_PETRIFY,OBJECT_SELF))
     {
      FloatingTextStringOnCreature("Zarala has been petrified. You have no more than one or two hours to restore her to life.",oMast);
      DelayCommand(540.0,ExecuteScript("s_zardeath_001",GetModule()));
     }
    if (GetItemInSlot(INVENTORY_SLOT_HEAD) != OBJECT_INVALID
        && !GetIsDead(OBJECT_SELF) && !IsInConversation(OBJECT_SELF)
        && GetAssociateType(OBJECT_SELF) == ASSOCIATE_TYPE_HENCHMAN
        && !GetHasEffect(EFFECT_TYPE_PETRIFY,OBJECT_SELF))
     {
      AssignCommand(OBJECT_SELF,ActionUnequipItem(GetItemInSlot(INVENTORY_SLOT_HEAD)));
      AssignCommand(OBJECT_SELF,ActionSpeakString("I don't like wearing helmets, they mess up my hair. I'm taking this off."));
     }
     //Custom stuff ends here.
     ExecuteScript("nw_ch_ac1", OBJECT_SELF);
}
