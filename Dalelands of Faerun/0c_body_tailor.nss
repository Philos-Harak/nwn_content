/*//////////////////////////////////////////////////////////////////////////////
 Script Name: 0c_body_tailor
 Programmer: Philos
 Based on the mil tailor by Jake E. Fitch (Milambus Mandragon)
 and modded by bloodsong.
////////////////////////////////////////////////////////////////////////////////
 Text Appears When script that contains all options for the body tailor.
 Param:
 sInput - the input to select what option to do.
 nValue - the value for some Inputs.
    SetGlowingEyes - the eye color to apply 0 - 9
    SetDemonLegs - 0 none, 116 Leg w/Claw, 117 Leg w/hoof, 118 leg w/split hoof
    SetDemonClaws - 1 none, 203 Claw, 221 brown, 222 white
    IncrementModel/DecrementModel/SetModel 1 head, 2 torso, 3 biceptright,
        4 biceptleft, 5 forarmright, 6 forarmleft, 7 thighright, 8 thighleft,
        9 shinright 10 shinleft, 11 wing, 12 tail, 13 pheno
*///////////////////////////////////////////////////////////////////////////////
#include "0i_effects"
void AdjustColor (int nColorChannel, int nAdjustment)
{
    int nValue = GetColor (OBJECT_SELF, nColorChannel) + nAdjustment;
    if (nAdjustment > 0 && nValue > 175) nValue = 0;
    else if (nAdjustment < 0 && nValue < 0) nValue = 175;
    SetColor (OBJECT_SELF, nColorChannel, nValue);
}

void AdjustModel (object oCreature, int nModel, int nAdjustment)
{
    int bFound, nMaxBodyPart = 2, nMaxHead = 200, nFailSafe, nValue;
    int nGender = GetGender(OBJECT_SELF);
    int nRaceType = GetRacialType (oCreature);
    int nAppearanceType = GetAppearanceType (OBJECT_SELF);
    string s2DAFile, sNewApp, sAppearanceArray;
    // HEADS
    if (nModel == 1)
    {
        //Debug ("0c_body_tailor", "452", "Appearance Type:" + IntToString (nAppearanceType) + " Gender:" + IntToString (nGender));
        // Setup changing the head to the default if the PC wishes.
        if (nAdjustment == 0)
        {
            nValue = 0;
            nAdjustment = 1;
        }
        else nValue = GetCreatureBodyPart (CREATURE_PART_HEAD, OBJECT_SELF);
        // Get the maximum number of heads for this appearance type.
        if (nGender == GENDER_FEMALE)
        {
            // Set max female heads.
            switch (nAppearanceType)
            {
                 case APPEARANCE_TYPE_DWARF : nMaxHead = DFHEADMAX; break;
                 case APPEARANCE_TYPE_ELF : nMaxHead = EFHEADMAX; break;
                 case APPEARANCE_TYPE_GNOME : nMaxHead = GFHEADMAX; break;
                 case APPEARANCE_TYPE_HUMAN :
                 case APPEARANCE_TYPE_HALF_ELF : nMaxHead = HFHEADMAX; break;
                 case APPEARANCE_TYPE_HALFLING : nMaxHead = AFHEADMAX; break;
                 case APPEARANCE_TYPE_HALF_ORC : nMaxHead = OFHEADMAX; break;
             }
        }
        else
        {
            // Set max male heads.
            switch (nAppearanceType)
            {
                 case APPEARANCE_TYPE_DWARF : nMaxHead = DMHEADMAX; break;
                 case APPEARANCE_TYPE_ELF : nMaxHead = EMHEADMAX; break;
                 case APPEARANCE_TYPE_GNOME : nMaxHead = GMHEADMAX; break;
                 case APPEARANCE_TYPE_HUMAN :
                 case APPEARANCE_TYPE_HALF_ELF : nMaxHead = HMHEADMAX; break;
                 case APPEARANCE_TYPE_HALFLING : nMaxHead = AMHEADMAX; break;
                 case APPEARANCE_TYPE_HALF_ORC : nMaxHead = OMHEADMAX; break;
            }
        }
        //Debug ("0c_body_tailor", "486", "MaxHead:" + IntToString (nMaxHead));
        nFailSafe = 0;
        // Cycle to get the next valid head in the list.
        while (!bFound && nFailSafe < nMaxHead * 2)
        {
            // Increment the head.
            nValue += nAdjustment;
            // Check to see if we have hit the top or bottom of the 2da file.
            if (nValue > nMaxHead) nValue = 1;
            else if (nValue < 1) nValue = nMaxHead;
            // Check the Female heads.
            if(nGender == GENDER_FEMALE)
            {
                // Humans, Half-elves, and Aasimar can only use these heads.
                if (nRaceType > 29 && nRaceType < 36 || nRaceType > 50 && nRaceType < 56 ||
                    nRaceType == 60 || nRaceType == 6 || nRaceType == 4)
                {
                    if (nValue > 0 && nValue < 120 || nValue == 140 || nValue == 142 || nValue == 155) bFound = TRUE;
                }
                // Tieflings use all but Genasi heads.
                if (nRaceType == 61) if (nValue != 135 && nValue != 136) bFound = TRUE;
                // Genasi can use all but tiefling heads.
                if (nRaceType > 61 && nRaceType < 66)
                {
                    if (nValue > 0 && nValue < 120 || nValue == 140 || nValue == 142) bFound = TRUE;
                    else if (nValue == 135 || nValue == 136 || nValue == 155) bFound = TRUE;
                }
                // All heads are open for Dwarves, Elves, Gnomes.
                if (nRaceType > 35 && nRaceType < 47) bFound = TRUE;
                // Halflings can use all but goblin heads.
                if (nRaceType > 47 && nRaceType < 51) bFound = TRUE;
                // All heads are open for Orcs & Kobolds.
                if (nRaceType > 55 && nRaceType < 60 || nRaceType == 5) bFound = TRUE;
                // DM's can use any heads.
                if (GetIsDungeonMaster (oCreature)) bFound = TRUE;
            }
            // Check male heads.
            else
            {
                // Humans, Half-elves, and Aasimar can only use these heads.
                if (nRaceType > 29 && nRaceType < 36 || nRaceType > 50 && nRaceType < 56 ||nRaceType == 60 || nRaceType == 6 || nRaceType == 4)
                {
                   if (nValue < 115 || nValue == 142 || nValue == 155) bFound = TRUE;
                }
                // Tieflings use all but Genasi heads.
                if (nRaceType == 61) if (nValue != 115 && nValue != 116 && nValue != 122) bFound = TRUE;
                // Genasi can use all but tiefling heads.
                if (nRaceType > 61 && nRaceType < 66)
                {
                    if (nValue < 115 || nValue == 142 || nValue == 155) bFound = TRUE;
                    else if (nValue == 115 || nValue == 116 || nValue == 122) bFound = TRUE;
                }
                // All heads are open for Dwarves, Elves, Gnomes.
                if (nRaceType > 35 && nRaceType < 47) bFound = TRUE;
                // Halflings can use all heads.
                if (nRaceType > 47 && nRaceType < 51) if (nValue < 20) bFound = TRUE;
                // Goblins can only use goblin heads.
                if (nRaceType == 47) if (nValue > 19) bFound = TRUE;
                // All heads are open for Orcs & Kobolds.
                if (nRaceType > 55 && nRaceType < 60 || nRaceType == 5) bFound = TRUE;
                // DM's can use any heads.
                if (GetIsDungeonMaster (oCreature)) bFound = TRUE;
            }
            // Make sure we can get out of an infinite loop!
            nFailSafe ++;
        }
        SetCreatureBodyPart (CREATURE_PART_HEAD, nValue);
    }
    //  TORSO PART
    else if (nModel == 2)
    {
        if (nAdjustment == 0)
        {
            nValue = 1;
            nAdjustment = 1;
        }
        else nValue = GetCreatureBodyPart (CREATURE_PART_TORSO) + nAdjustment;
        // Male humans can have 3 tattoos.
        if (nAppearanceType = APPEARANCE_TYPE_HUMAN && nGender == GENDER_MALE) nMaxBodyPart = 4;
        // For all other races and females they get 1 tattoo.
        else nMaxBodyPart = 2;
        // Make sure we stay within the list.
        if (nValue > nMaxBodyPart) nValue = 1;
        else if (nValue < 1) nValue = nMaxBodyPart;
        SetCreatureBodyPart(CREATURE_PART_TORSO, nValue);
    }
    //  RIGHT BICEP PART
    else if (nModel == 3)
    {
        if (nAdjustment == 0)
        {
            nValue = 1;
            nAdjustment = 1;
        }
        else nValue = GetCreatureBodyPart(CREATURE_PART_RIGHT_BICEP) + nAdjustment;
        nMaxBodyPart = 2;
        // Make sure we stay within the list.
        if (nValue > nMaxBodyPart) nValue = 1;
        else if (nValue < 1) nValue = nMaxBodyPart;
        SetCreatureBodyPart(CREATURE_PART_RIGHT_BICEP, nValue);
    }
    //  LEFT BICEP PART
    else if (nModel == 4)
    {
        if (nAdjustment == 0)
        {
            nValue = 1;
            nAdjustment = 1;
        }
        else nValue = GetCreatureBodyPart(CREATURE_PART_LEFT_BICEP) + nAdjustment;
        nMaxBodyPart = 2;
        // Make sure we stay within the list.
        if (nValue > nMaxBodyPart) nValue = 1;
        else if (nValue < 1) nValue = nMaxBodyPart;
        SetCreatureBodyPart(CREATURE_PART_LEFT_BICEP, nValue);
    }
    //  RIGHT FOREARM PART
    else if (nModel == 5)
    {
        if (nAdjustment == 0)
        {
            nValue = 1;
            nAdjustment = 1;
        }
        else nValue = GetCreatureBodyPart(CREATURE_PART_RIGHT_FOREARM) + nAdjustment;
        nMaxBodyPart = 2;
        // Make sure we stay within the list.
        if (nValue > nMaxBodyPart) nValue = 1;
        else if (nValue < 1) nValue = nMaxBodyPart;
        SetCreatureBodyPart(CREATURE_PART_RIGHT_FOREARM, nValue);
    }
    //  LEFT FOREARM PART
    else if (nModel == 6)
    {
        if (nAdjustment == 0)
        {
            nValue = 1;
            nAdjustment = 1;
        }
        else nValue = GetCreatureBodyPart(CREATURE_PART_LEFT_FOREARM) + nAdjustment;
        nMaxBodyPart = 2;
        // Make sure we stay within the list.
        if (nValue > nMaxBodyPart) nValue = 1;
        else if (nValue < 1) nValue = nMaxBodyPart;
        SetCreatureBodyPart(CREATURE_PART_LEFT_FOREARM, nValue);
    }
    //  RIGHT THIGH PART
    else if (nModel == 7)
    {
        if (nAdjustment == 0)
        {
            nValue = 1;
            nAdjustment = 1;
        }
        else nValue = GetCreatureBodyPart(CREATURE_PART_RIGHT_THIGH) + nAdjustment;
        nMaxBodyPart = 2;
        // Make sure we stay within the list.
        if (nValue > nMaxBodyPart) nValue = 1;
        else if (nValue < 1) nValue = nMaxBodyPart;
        SetCreatureBodyPart(CREATURE_PART_RIGHT_THIGH, nValue);
    }
    //  LEFT THIGH PART
    else if (nModel == 8)
    {
        if (nAdjustment == 0)
        {
            nValue = 1;
            nAdjustment = 1;
        }
        else nValue = GetCreatureBodyPart(CREATURE_PART_LEFT_THIGH) + nAdjustment;
        nMaxBodyPart = 2;
        // Make sure we stay within the list.
        if (nValue > nMaxBodyPart) nValue = 1;
        else if (nValue < 1) nValue = nMaxBodyPart;
        SetCreatureBodyPart(CREATURE_PART_LEFT_THIGH, nValue);
    }
    //  RIGHT SHIN PART
    else if (nModel == 9)
    {
        if (nAdjustment == 0)
        {
            nValue = 1;
            nAdjustment = 1;
        }
        else nValue = GetCreatureBodyPart(CREATURE_PART_RIGHT_SHIN) + nAdjustment;
        nMaxBodyPart = 2;
        // Make sure we stay within the list.
        if (nValue > nMaxBodyPart) nValue = 1;
        else if (nValue < 1) nValue = nMaxBodyPart;
        SetCreatureBodyPart(CREATURE_PART_RIGHT_SHIN, nValue);
    }
    //  LEFT SHIN PART
    else if (nModel == 10)
    {
        if (nAdjustment == 0)
        {
            nValue = 1;
            nAdjustment = 1;
        }
        else nValue = GetCreatureBodyPart(CREATURE_PART_LEFT_SHIN) + nAdjustment;
        nMaxBodyPart = 2;
        // Make sure we stay within the list.
        if (nValue > nMaxBodyPart) nValue = 1;
        else if (nValue < 1) nValue = nMaxBodyPart;
        SetCreatureBodyPart(CREATURE_PART_LEFT_SHIN, nValue);
    }
    // WING SECTION
    else if (nModel == 11)
    {
      // Change to the default wing.
      if (nAdjustment == 0)
      {
          nValue = -1;
          nAdjustment = 1;
      }
      // Get the current wing.
      else nValue = GetCreatureWingType();
      nFailSafe = 0;
      // Skip past all the restricted wings.
      // Our fail safe is twice the wingmodel.2da size.
      while (!bFound && nFailSafe < WINGMAX * 2)
      {
          nValue = nValue + nAdjustment;
          // Make sure we stay within the list.
          if (nValue > WINGMAX) nValue = 0;
          else if (nValue < 0) nValue = WINGMAX;
          // Back items can be used by everyone.
          if (nValue >= 79 && nValue <= 89) bFound = TRUE;
          // Restrict Tieflings && Sorcerers with Abysal or Infernal, to only demon wings.
          else if (GetRacialType (oCreature) == 61 ||
                   GetHasFeat (1316/*FEAT_ABYSSAL_BLOODLINE*/, oCreature) ||
                   GetHasFeat (1346/*FEAT_INFERNAL_BLOODLINE*/, oCreature))
          {
            if (nValue >= 200 && nValue <= 208) bFound = TRUE;
          }
          // Restrict Assamars to only angel wings.
          else if (GetRacialType (oCreature) == 60 ||
                   GetHasFeat (1326/*FEAT_CELESTIAL_BLOODLINE*/, oCreature))

          {
            if (nValue >= 217 && nValue <= 229) bFound = TRUE;
          }
          // Everyone can have no wings!
          else if (nValue == 0) bFound = TRUE;
          // DM's can use anything.
          else if (GetIsDungeonMaster (oCreature))
          {
            if ((nValue >= 1 && nValue <= 6) ||
                (nValue >= 59 && nValue <= 89) ||
                (nValue >= 198 && nValue <= 230)) bFound = TRUE;
          }
          nFailSafe++;
      }
      // Put on the wings.
      SetCreatureWingType (nValue);
      sNewApp = Get2DAString (s2DAFile, "LABEL", nValue);
    }
    // TAIL SECTION
    else if(nModel == 12)
    {
        if (nAdjustment == 0)
        {
            nValue = -1;
            nAdjustment = 1;
        }
        else nValue = GetCreatureTailType();
        nFailSafe = 0;
        // Skip past all the restricted tails.
        // Our fail safe is twice the tailmodel.2da size.
        while (!bFound && nFailSafe < TAILMAX *2)
        {
            nValue = nValue + nAdjustment;
            // Make sure we stay within the list.
            if (nValue > TAILMAX) nValue = 0;
            if (nValue < 0) nValue = TAILMAX;
            // Restrict Tieflings to only demon tails.
            if (GetRacialType (oCreature) == 61)
            {
                if (nValue >= 2 && nValue <= 3) bFound = TRUE;
            }
            // Everyone can have no tail!
            else if (nValue == 0) bFound = TRUE;
            // DM's can use anything.
            else if (GetIsDungeonMaster (oCreature))
            {
                if (nValue >= 1 && nValue <= 13) bFound = TRUE;
            }
            nFailSafe++;
        }
        // Put on tail.
        SetCreatureTailType (nValue);
        sNewApp = Get2DAString (s2DAFile, "LABEL", nValue);
    }
    // PHENO PART
    else if(nModel == 13)
    {
        if (nAdjustment == 0)
        {
            nValue = 1;
            nAdjustment = 1;
        }
        else nValue = GetPhenoType(OBJECT_SELF) + nAdjustment;
        // Make sure we stay within the list.
        if (nValue > 2) nValue = 1;
        if (nValue < 1) nValue = 2;
        SetPhenoType (nValue);
    }
    if (nAdjustment != 0) SendMessageToPC (oCreature, "New Appearance: " + IntToString (nValue) + "  " + sNewApp);
}

void main()
{
    int iToModify;
    int nAdjustment = 0, nPart;
    string sAppearanceArray;
    object oItem;
    object oPC = GetPCSpeaker();
    float fNewFace;
    string sInput = GetScriptParam ("sInput");
    int nValue = StringToInt (GetScriptParam ("nValue"));
    if (sInput == "NextHairColor") AdjustColor (COLOR_CHANNEL_HAIR, 1);
    else if (sInput == "PreviousHairColor") AdjustColor (COLOR_CHANNEL_HAIR, -1);
    else if (sInput == "NextSkinColor") AdjustColor (COLOR_CHANNEL_SKIN, 1);
    else if (sInput == "PreviousSkinColor") AdjustColor (COLOR_CHANNEL_SKIN, -1);
    else if (sInput == "NextTattoo1Color") AdjustColor (COLOR_CHANNEL_TATTOO_1, 1);
    else if (sInput == "PreviousTattoo1Color") AdjustColor (COLOR_CHANNEL_TATTOO_1, -1);
    else if (sInput == "NextTattoo2Color") AdjustColor (COLOR_CHANNEL_TATTOO_2, -1);
    else if (sInput == "PreviousTattoo2Color") AdjustColor (COLOR_CHANNEL_TATTOO_2, -1);
    else if (sInput == "ResetModelColor")
    {
        SetColor (OBJECT_SELF, COLOR_CHANNEL_HAIR, 1);
        SetColor (OBJECT_SELF, COLOR_CHANNEL_SKIN, 1);
        SetColor (OBJECT_SELF, COLOR_CHANNEL_TATTOO_1, 1);
        SetColor (OBJECT_SELF, COLOR_CHANNEL_TATTOO_2, 1);
    }
    else if (sInput == "CopyPCToModelColor")
    {
        SetColor (oPC, COLOR_CHANNEL_HAIR, GetColor (OBJECT_SELF, COLOR_CHANNEL_HAIR));
        SetColor (oPC, COLOR_CHANNEL_SKIN, GetColor (OBJECT_SELF, COLOR_CHANNEL_SKIN));
        SetColor (oPC, COLOR_CHANNEL_TATTOO_1, GetColor (OBJECT_SELF, COLOR_CHANNEL_TATTOO_1));
        SetColor (oPC, COLOR_CHANNEL_TATTOO_2, GetColor (OBJECT_SELF, COLOR_CHANNEL_TATTOO_2));
    }
    else if (sInput == "RotateClockwise")
    {
            fNewFace = GetFacing (OBJECT_SELF) - 30.0;
            if (fNewFace < 0.0) fNewFace += 360.0;
            AssignCommand (OBJECT_SELF, SetFacing (fNewFace));
    }
    else if (sInput == "RotateCounterClockwise")
    {
        fNewFace = GetFacing (OBJECT_SELF) + 30.0;
        if (fNewFace > 360.0) fNewFace -= 360.0;
        AssignCommand (OBJECT_SELF, SetFacing (fNewFace));
    }
    else if (sInput == "ApplyGlowingEyes")
    {
        int iEye = GetLocalInt(OBJECT_SELF, "EYES");
        // Don't apply the eyes to a monk.
        if(GetLevelByClass (CLASS_TYPE_MONK) == 0)
        {
            sAppearanceArray = GetObjectDatabaseString (oPC, CHARACTER_TABLE, "appearance");
            sAppearanceArray = SetStringArray (sAppearanceArray, 0, IntToString (iEye));
            SetObjectDatabaseString (oPC, CHARACTER_TABLE, "appearance", sAppearanceArray);
            ApplyGlowingEyes(iEye, oPC);
        }
        else SendMessages ("Monks cannot change thier eyes.", COLOR_RED, oPC);
    }
    else if (sInput == "SetGlowingEyes")
    {
        SetLocalInt (OBJECT_SELF, "EYES", nValue);
        ApplyGlowingEyes (nValue, OBJECT_SELF);
    }
    else if (sInput == "SetDemonLegs")
    {
        // Appearance Array is :Eyes:Legs:Claws:"
        sAppearanceArray = GetObjectDatabaseString (oPC, CHARACTER_TABLE, "appearance");
        // Destroy any previous demonic body they may have.
        oItem = GetCreatureHasItem (oPC, "0_demonic_body", TRUE);
        if (GetIsObjectValid (oItem)) DestroyObject (oItem);
        if (nValue > 0) CreateItemOnObject ("0_demonic_body", oPC);
        sAppearanceArray = SetStringArray (sAppearanceArray, 1, IntToString (nValue));
    }
    else if (sInput == "SetDemonClaws")
    {
        string sClawValue;
        SetCreatureBodyPart(CREATURE_PART_LEFT_HAND, nValue, oPC);
        SetCreatureBodyPart(CREATURE_PART_RIGHT_HAND, nValue, oPC);
        if (nValue == 1) sClawValue = "1";
        else sClawValue = "0";
        sAppearanceArray = SetStringArray (sAppearanceArray, 2, sClawValue);
        SetObjectDatabaseString (oPC, CHARACTER_TABLE, "appearance", sAppearanceArray);
    }
    else if (sInput == "NextModel") AdjustModel (oPC, nValue, 1);
    else if (sInput == "PreviousModel") AdjustModel (oPC, nValue, -1);
    else if (sInput == "ResetModel") AdjustModel (oPC, nValue, 0);
    // Copy specific part from Model to PC.
    else if (sInput == "SetModel")
    {
        // HEAD:
        if (nValue == 1)
        {
            nPart = GetCreatureBodyPart(CREATURE_PART_HEAD);
            SetCreatureBodyPart(CREATURE_PART_HEAD, nPart, oPC);
        }
        // Torso part.
        if (nValue == 2)
        {
            nPart = GetCreatureBodyPart(CREATURE_PART_TORSO);
            SetCreatureBodyPart(CREATURE_PART_TORSO, nPart, oPC);
        }
        // BODYPARTS:
        if (nValue == 3)
        {
            nPart = GetCreatureBodyPart(CREATURE_PART_RIGHT_BICEP);
            SetCreatureBodyPart(CREATURE_PART_RIGHT_BICEP, nPart, oPC);
        }
        if (nValue == 4)
        {
            nPart = GetCreatureBodyPart(CREATURE_PART_LEFT_BICEP);
            SetCreatureBodyPart(CREATURE_PART_LEFT_BICEP, nPart, oPC);
        }
        if (nValue == 5)
        {
            nPart = GetCreatureBodyPart(CREATURE_PART_RIGHT_FOREARM);
            SetCreatureBodyPart(CREATURE_PART_RIGHT_FOREARM, nPart, oPC);
        }
        if (nValue == 6)
        {
            nPart = GetCreatureBodyPart(CREATURE_PART_LEFT_FOREARM);
            SetCreatureBodyPart(CREATURE_PART_LEFT_FOREARM, nPart, oPC);
        }
        if (nValue == 7)
        {
            nValue = GetCreatureBodyPart(CREATURE_PART_RIGHT_THIGH);
            SetCreatureBodyPart(CREATURE_PART_RIGHT_THIGH, nValue, oPC);
        }
        if (nValue == 8)
        {
            nPart = GetCreatureBodyPart(CREATURE_PART_LEFT_THIGH);
            SetCreatureBodyPart(CREATURE_PART_LEFT_THIGH, nPart, oPC);
        }
        if (nValue == 9)
        {
            nPart = GetCreatureBodyPart(CREATURE_PART_RIGHT_SHIN);
            SetCreatureBodyPart(CREATURE_PART_RIGHT_SHIN, nPart, oPC);
        }
        if (nValue == 10)
        {
            nPart = GetCreatureBodyPart(CREATURE_PART_LEFT_SHIN);
            SetCreatureBodyPart(CREATURE_PART_LEFT_SHIN, nPart, oPC);
        }
        // WINGS:
        if (nValue == 11)
        {
            nPart = GetCreatureWingType();
            SetCreatureWingType(nPart, oPC);
        }
        // TAIL:
        if (nValue == 12)
        {
            nPart = GetCreatureTailType();
            SetCreatureTailType(nPart, oPC);
        }
        // PHENOTYPE
        if (nValue == 13)
        {
            SetPhenoType (GetPhenoType (OBJECT_SELF), oPC);
        }
        return;
    }
    // Copy PC to the Model.
    else if (sInput == "CopyPCToModel")
    {
        // WINGS:
        nPart = GetCreatureWingType(oPC);
        SetCreatureWingType(nPart, OBJECT_SELF);
        // TAIL:
        nPart = GetCreatureTailType(oPC);
        SetCreatureTailType(nPart, OBJECT_SELF);
        // HEAD:
        nPart = GetCreatureBodyPart(CREATURE_PART_HEAD, oPC);
        SetCreatureBodyPart(CREATURE_PART_HEAD, nPart, OBJECT_SELF);
        // BODYPARTS:
        nPart = GetCreatureBodyPart(CREATURE_PART_LEFT_BICEP, oPC);
        SetCreatureBodyPart(CREATURE_PART_LEFT_BICEP, nPart, OBJECT_SELF);
        nPart = GetCreatureBodyPart(CREATURE_PART_LEFT_FOREARM, oPC);
        SetCreatureBodyPart(CREATURE_PART_LEFT_FOREARM, nPart, OBJECT_SELF);
        nPart = GetCreatureBodyPart(CREATURE_PART_LEFT_SHIN, oPC);
        SetCreatureBodyPart(CREATURE_PART_LEFT_SHIN, nPart, OBJECT_SELF);
        nPart = GetCreatureBodyPart(CREATURE_PART_LEFT_THIGH, oPC);
        SetCreatureBodyPart(CREATURE_PART_LEFT_THIGH, nPart, OBJECT_SELF);
        nPart = GetCreatureBodyPart(CREATURE_PART_RIGHT_BICEP, oPC);
        SetCreatureBodyPart(CREATURE_PART_RIGHT_BICEP, nPart, OBJECT_SELF);
        nPart = GetCreatureBodyPart(CREATURE_PART_RIGHT_FOREARM, oPC);
        SetCreatureBodyPart(CREATURE_PART_RIGHT_FOREARM, nPart, OBJECT_SELF);
        nPart = GetCreatureBodyPart(CREATURE_PART_RIGHT_SHIN, oPC);
        SetCreatureBodyPart(CREATURE_PART_RIGHT_SHIN, nPart, OBJECT_SELF);
        nPart = GetCreatureBodyPart(CREATURE_PART_RIGHT_THIGH, oPC);
        SetCreatureBodyPart(CREATURE_PART_RIGHT_THIGH, nPart, OBJECT_SELF);
        nPart = GetCreatureBodyPart(CREATURE_PART_TORSO, oPC);
        SetCreatureBodyPart(CREATURE_PART_TORSO, nPart, OBJECT_SELF);
        // EYES
        // this can't be done from pc to npc. (easily). live with it.
        // PHENOTYPE
        SetPhenoType (GetPhenoType(oPC), OBJECT_SELF);
        // COLORS
        SetColor (OBJECT_SELF, COLOR_CHANNEL_HAIR, GetColor (oPC, COLOR_CHANNEL_HAIR));
        SetColor (OBJECT_SELF, COLOR_CHANNEL_SKIN, GetColor (oPC, COLOR_CHANNEL_SKIN));
        SetColor (OBJECT_SELF, COLOR_CHANNEL_TATTOO_1, GetColor (oPC, COLOR_CHANNEL_TATTOO_1));
        SetColor (OBJECT_SELF, COLOR_CHANNEL_TATTOO_2, GetColor (oPC, COLOR_CHANNEL_TATTOO_2));
        return;
    }
    // Copy the model to the PC.
    else if (sInput == "CopyModelToPC")
    {
        // WINGS:
        nPart = GetCreatureWingType();
        SetCreatureWingType(nPart, oPC);
        // TAIL:
        nPart = GetCreatureTailType();
        SetCreatureTailType(nPart, oPC);
        // HEAD:
        nPart = GetCreatureBodyPart(CREATURE_PART_HEAD);
        SetCreatureBodyPart(CREATURE_PART_HEAD, nPart, oPC);
        // BODYPARTS:
        // Left arm parts.
        nPart = GetCreatureBodyPart(CREATURE_PART_LEFT_BICEP);
        SetCreatureBodyPart(CREATURE_PART_LEFT_BICEP, nPart, oPC);
        nPart = GetCreatureBodyPart(CREATURE_PART_LEFT_FOREARM);
        SetCreatureBodyPart(CREATURE_PART_LEFT_FOREARM, nPart, oPC);
        nPart = GetCreatureBodyPart(CREATURE_PART_LEFT_HAND);
        SetCreatureBodyPart(CREATURE_PART_LEFT_HAND, nPart, oPC);
        // Left leg parts.
        nPart = GetCreatureBodyPart(CREATURE_PART_LEFT_THIGH);
        SetCreatureBodyPart(CREATURE_PART_LEFT_THIGH, nPart, oPC);
        nPart = GetCreatureBodyPart(CREATURE_PART_LEFT_SHIN);
        SetCreatureBodyPart(CREATURE_PART_LEFT_SHIN, nPart, oPC);
        nPart = GetCreatureBodyPart(CREATURE_PART_LEFT_FOOT);
        SetCreatureBodyPart(CREATURE_PART_LEFT_FOOT, nPart, oPC);
        // Right arm parts.
        nPart = GetCreatureBodyPart(CREATURE_PART_RIGHT_BICEP);
        SetCreatureBodyPart(CREATURE_PART_RIGHT_BICEP, nPart, oPC);
        nPart = GetCreatureBodyPart(CREATURE_PART_RIGHT_FOREARM);
        SetCreatureBodyPart(CREATURE_PART_RIGHT_FOREARM, nPart, oPC);
        nPart = GetCreatureBodyPart(CREATURE_PART_RIGHT_HAND);
        SetCreatureBodyPart(CREATURE_PART_RIGHT_HAND, nPart, oPC);
        // Right leg parts.
        nPart = GetCreatureBodyPart(CREATURE_PART_RIGHT_THIGH);
        SetCreatureBodyPart(CREATURE_PART_RIGHT_THIGH, nPart, oPC);
        nPart = GetCreatureBodyPart(CREATURE_PART_RIGHT_SHIN);
        SetCreatureBodyPart(CREATURE_PART_RIGHT_SHIN, nPart, oPC);
        nPart = GetCreatureBodyPart(CREATURE_PART_RIGHT_FOOT);
        SetCreatureBodyPart(CREATURE_PART_RIGHT_FOOT, nPart, oPC);
        // Torso part.
        nPart = GetCreatureBodyPart(CREATURE_PART_TORSO);
        SetCreatureBodyPart(CREATURE_PART_TORSO, nPart, oPC);
        // EYES
        ApplyGlowingEyes (GetLocalInt (OBJECT_SELF, "EYES"), oPC);
        // PHENOTYPE
        SetPhenoType (GetPhenoType(OBJECT_SELF), oPC);
        // COLOR
        SetColor (oPC, COLOR_CHANNEL_HAIR, GetColor (OBJECT_SELF, COLOR_CHANNEL_HAIR));
        SetColor (oPC, COLOR_CHANNEL_SKIN, GetColor (OBJECT_SELF, COLOR_CHANNEL_SKIN));
        SetColor (oPC, COLOR_CHANNEL_TATTOO_1, GetColor (OBJECT_SELF, COLOR_CHANNEL_TATTOO_1));
        SetColor (oPC, COLOR_CHANNEL_TATTOO_2, GetColor (OBJECT_SELF, COLOR_CHANNEL_TATTOO_2));
        return;
    }
    // Reset the model to the default.
    else if (sInput == "ResetModelToDefault")
    {
        nPart = 0;
        // WINGS:
        SetCreatureWingType(nPart, OBJECT_SELF);
        // TAIL:
        SetCreatureTailType(nPart, OBJECT_SELF);
        nValue = 1;
        // HEAD:
        SetCreatureBodyPart(CREATURE_PART_HEAD, nPart, OBJECT_SELF);
        //BODYPARTS:
        SetCreatureBodyPart(CREATURE_PART_LEFT_BICEP, nPart, OBJECT_SELF);
        SetCreatureBodyPart(CREATURE_PART_LEFT_FOOT, nPart, OBJECT_SELF);
        SetCreatureBodyPart(CREATURE_PART_LEFT_FOREARM, nPart, OBJECT_SELF);
        SetCreatureBodyPart(CREATURE_PART_LEFT_HAND, nPart, OBJECT_SELF);
        SetCreatureBodyPart(CREATURE_PART_LEFT_SHIN, nPart, OBJECT_SELF);
        SetCreatureBodyPart(CREATURE_PART_LEFT_THIGH, nPart, OBJECT_SELF);
        SetCreatureBodyPart(CREATURE_PART_RIGHT_BICEP, nPart, OBJECT_SELF);
        SetCreatureBodyPart(CREATURE_PART_RIGHT_FOOT, nPart, OBJECT_SELF);
        SetCreatureBodyPart(CREATURE_PART_RIGHT_FOREARM, nPart, OBJECT_SELF);
        SetCreatureBodyPart(CREATURE_PART_RIGHT_HAND, nPart, OBJECT_SELF);
        SetCreatureBodyPart(CREATURE_PART_RIGHT_SHIN, nPart, OBJECT_SELF);
        SetCreatureBodyPart(CREATURE_PART_RIGHT_THIGH, nPart, OBJECT_SELF);
        SetCreatureBodyPart(CREATURE_PART_NECK, nPart, OBJECT_SELF);
        SetCreatureBodyPart(CREATURE_PART_PELVIS, nPart, OBJECT_SELF);
        SetCreatureBodyPart(CREATURE_PART_TORSO, nPart, OBJECT_SELF);
        // EYES
        ApplyGlowingEyes (0, OBJECT_SELF);
        // PHENO
        SetPhenoType (PHENOTYPE_NORMAL);
        // COLOR
        SetColor (OBJECT_SELF, COLOR_CHANNEL_HAIR, 1);
        SetColor (OBJECT_SELF, COLOR_CHANNEL_SKIN, 1);
        SetColor (OBJECT_SELF, COLOR_CHANNEL_TATTOO_1, 1);
        SetColor (OBJECT_SELF, COLOR_CHANNEL_TATTOO_2, 1);
        return;
    }
}
