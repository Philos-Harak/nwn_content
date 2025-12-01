/*//////////////////////////////////////////////////////////////////////////////
 Script: m1q6module_2
////////////////////////////////////////////////////////////////////////////////
    OnClientEnter script for end of chapters.
    Spawns in one henchman, fixed to spawn in all henchman they have.
*///////////////////////////////////////////////////////////////////////////////
#include "NW_I0_Henchman"
#include "0i_main"
void ai_SpawnHenchman()
{
    object oPC = GetEnteringObject();
    string sLevel = "03";
    // * override level of henchman for chapters 2e and 4
    if (GetTag(GetModule()) == "ENDMODULE2") sLevel = "07";
    if (GetTag(GetModule()) == "ENDMODULE3") sLevel = "10";
    if (GetLocalInt(oPC, "NW_L_SPAWNCHAPTERENDHENCHMENONCE") == 0)
    if (GetIsPC(oPC) == TRUE)
    {
        json jRules = ai_GetCampaignDbJson("rules");
        int nMaxHenchman = JsonGetInt(JsonObjectGet(jRules, AI_RULE_MAX_HENCHMAN));
        if(nMaxHenchman != 0) SetMaxHenchmen(nMaxHenchman);
        string sTestHench = "";
        location lLocation = GetLocation(GetObjectByTag("NW_HENCHMAN_BAR"));
        // * May 28 2002: Testing to see if the henchman already exists
        // * there can only be one in the world at a time
        object oItem = GetItemPossessedBy(oPC, "NW_HEN_DAEPERS");
        object oHen = OBJECT_INVALID;
        if (GetIsObjectValid(oItem) == TRUE)
        {
            sTestHench = "NW_HEN_DAE";
            if(!GetIsObjectValid(GetObjectByTag(sTestHench)))
            {
                oHen = CreateObject(OBJECT_TYPE_CREATURE, sTestHench  + "_" + sLevel, lLocation);
                AssignCommand(oHen, SetWorkingForPlayer(oPC));
                SetLocalInt(oPC, "NW_L_SPAWNCHAPTERENDHENCHMENONCE", 1);
                AddHenchman(oPC, oHen);
            }
        }
        oItem = GetItemPossessedBy(oPC, "NW_HEN_SHAPERS");
        if (GetIsObjectValid(oItem) == TRUE)
        {
            sTestHench = "NW_HEN_SHA" ;
            if (GetIsObjectValid(GetObjectByTag(sTestHench)) == FALSE)
            {
                oHen = CreateObject(OBJECT_TYPE_CREATURE, sTestHench  + "_" + sLevel, lLocation);
                AssignCommand(oHen, SetWorkingForPlayer(oPC));
                SetLocalInt(oPC, "NW_L_SPAWNCHAPTERENDHENCHMENONCE", 1);
                AddHenchman(oPC, oHen);
            }
        }
        oItem = GetItemPossessedBy(oPC, "NW_HEN_GALPERS");
        if (GetIsObjectValid(oItem) == TRUE)
        {
            sTestHench = "NW_HEN_GAL" ;
            if (GetIsObjectValid(GetObjectByTag(sTestHench)) == FALSE)
            {
                oHen = CreateObject(OBJECT_TYPE_CREATURE, sTestHench  + "_" + sLevel, lLocation);
                AssignCommand(oHen, SetWorkingForPlayer(oPC));
                SetLocalInt(oPC, "NW_L_SPAWNCHAPTERENDHENCHMENONCE", 1);
                AddHenchman(oPC, oHen);
            }
        }
        oItem = GetItemPossessedBy(oPC, "NW_HEN_GRIPERS");
        if (GetIsObjectValid(oItem) == TRUE)
        {
            sTestHench = "NW_HEN_GRI" ;
            if (GetIsObjectValid(GetObjectByTag(sTestHench)) == FALSE)
            {
                oHen = CreateObject(OBJECT_TYPE_CREATURE, sTestHench  + "_" + sLevel, lLocation);
                AssignCommand(oHen, SetWorkingForPlayer(oPC));
                SetLocalInt(oPC, "NW_L_SPAWNCHAPTERENDHENCHMENONCE", 1);
                AddHenchman(oPC, oHen);
            }
        }
        oItem = GetItemPossessedBy(oPC, "NW_HEN_BODPERS");
        if (GetIsObjectValid(oItem) == TRUE)
        {
            sTestHench = "NW_HEN_BOD" ;
            if (GetIsObjectValid(GetObjectByTag(sTestHench)) == FALSE)
            {
                oHen = CreateObject(OBJECT_TYPE_CREATURE,sTestHench  + "_" + sLevel, lLocation);
                AssignCommand(oHen, SetWorkingForPlayer(oPC));
                SetLocalInt(oPC, "NW_L_SPAWNCHAPTERENDHENCHMENONCE", 1);
                AddHenchman(oPC, oHen);
            }
        }
        oItem = GetItemPossessedBy(oPC, "NW_HEN_LINPERS");
        if (GetIsObjectValid(oItem) == TRUE)
        {
            sTestHench = "NW_HEN_LIN" ;
            if (GetIsObjectValid(GetObjectByTag(sTestHench)) == FALSE)
            {
                oHen = CreateObject(OBJECT_TYPE_CREATURE,sTestHench  + "_" + sLevel, lLocation);
                AssignCommand(oHen, SetWorkingForPlayer(oPC));
                SetLocalInt(oPC, "NW_L_SPAWNCHAPTERENDHENCHMENONCE", 1);
                AddHenchman(oPC, oHen);
            }
        }
    }
}
void StripItems(string sTag)
{
    if(GetIsPC(GetEnteringObject()))
    {
        object oPC = GetEnteringObject();
        object oItem = GetItemPossessedBy(oPC,sTag);
        if (GetIsObjectValid(oItem))
        {
            DestroyObject(oItem);
            DelayCommand(0.03,StripItems(sTag));
        }
    }
}
void main()
{
    object oTarget = GetEnteringObject();
    if(GetIsPC(oTarget))
    {
        ai_SpawnHenchman();
        StripItems("M1Q04ILocket");
        StripItems("M1S2Broach");
        StripItems("M1Q5Signet1");
        StripItems("M1Q1_LetterCult");
        StripItems("M1Q1_LetterConspiracy");
        StripItems("M1Q1_LetterSpy");
        StripItems("M1Q04IAUCTION");
        StripItems("M1Q5ENote");
        StripItems("M1Q5DPassStone");
        StripItems("M1S04IFIGHTPASS");
        StripItems("M1Q3ILoxarHead");
        StripItems("m1q04INoteCallik");
        StripItems("M1S1Letter");
        StripItems("M1S2Letter1");
        StripItems("M1Q3A00TOOTH");
        StripItems("M1S2Letter4");
        StripItems("M1S2Note1");
        StripItems("M1S2Note2");
        StripItems("M1S2Note3");
        StripItems("M1S2Pass");
        StripItems("M1Q1A8Ward");
        StripItems("M1Q04ISMUGCOIN");
        StripItems("M1S3Scroll");
        StripItems("M1S2Letter2");
        StripItems("M1Q2PlotReagent");
        StripItems("M1Q3PlotReagent");
        StripItems("M1Q4PlotReagent");
        StripItems("M1Q5PlotReagent");
        StripItems("M1S1Book2");
        StripItems("M1S1Tyr");
        StripItems("M1S03IFLASK");
        StripItems("M1S2Statue");
        StripItems("M1S2Urn");
        StripItems("M1S1Armor");
        StripItems("M1S1Quill");
        StripItems("M1S03IKINDLING");
        StripItems("M1S2Portrait");
        StripItems("M1S03IFOG");
        StripItems("M1S03ICLAY");
        StripItems("M1S3Fetish");
        StripItems("M1Q5EKey");
        StripItems("M1S2Key2");
        StripItems("M1S1Key1");
        StripItems("M1S3Key1");
        StripItems("M1S04IFIGHTKEY");
        StripItems("M1S1FKey");
        StripItems("M1S2F01Key");
        StripItems("M1S2EKey");
        StripItems("M1Q3AKey1");
        StripItems("M1Q3BKey2");
        StripItems("M1Q3BKey1");
        StripItems("M1Q3A00MELDKEY");
        StripItems("M1Q3AMillyKey");
        StripItems("M1S2Key1");
        StripItems("m1q2_PrisonFloor2");
        StripItems("m1q2_PrisonKey");
        StripItems("m1q2B_Storeroom");
        StripItems("m1q2_KeyTangle");
        StripItems("M1Q04ITAVERNKEY");
        StripItems("M1S3Key1");
        StripItems("M1Q5Book3");
        StripItems("M1Q5Book1");
        StripItems("M1S1Book");
        StripItems("M1Q5Book2");
        StripItems("M1Q5Book4");
        StripItems("M1Q5MarcNote");
        StripItems("M1Q3AMELDJOURNAL");
        StripItems("M1Q02IJournTangl");
        StripItems("M1Q02IPrisonLog");
        StripItems("M1Q02IJournPriso");
        StripItems("m1q1_marrokbook");
        StripItems("M1Q02IJournHGaol");
        StripItems("M1S1Arrow");
        StripItems("M1S1Shield");
        StripItems("M1S1Sword");
        StripItems("M1S2DKey1");
        StripItems("M1S1Key1");
        StripItems("M1S2BrileyKey");
        StripItems("M1Q2CKey");
        StripItems("NW_HEN_DAE1QT");
        StripItems("NW_HEN_BOD1QT");
        StripItems("NW_HEN_LIN1QT");
        StripItems("NW_HEN_GRI1QT");
        StripItems("NW_HEN_GAL1QT");
        StripItems("NW_HEN_SHA1QT");
    }
}


