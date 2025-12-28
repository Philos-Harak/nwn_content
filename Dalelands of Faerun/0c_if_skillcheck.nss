/*//////////////////////////////////////////////////////////////////////////////
 Script: 0c_if_SkillCheck
 Programmer: Philos
////////////////////////////////////////////////////////////////////////////////
 Text Appears When script that checks to see if the PCSpeaker's Check
 is above or equal to the param value.
 This saves the roll result on OBJECT_SELF of the conversation in variable
 "0_Check_*PCNAME*".
 Param:
 nSkill - the skill number for the skill rolled for. See skills.2da.
 nBonus - any bonus to the roll.
 bTake20 - 1(TRUE) 0(FALSE) if true then will always roll a 20.
 nMessage - 1 show roll and DC or 2 show just the roll.
 nDC - DC needed to show this text, if not set then just does a skill roll.
*///////////////////////////////////////////////////////////////////////////////
#include "0i_master"
#include "0i_checks"
int StartingConditional()
{
    int nRoll, nSkill, nBonus, nMessage, bTake20, bArmorPenalty;
    string sResult, sColor;
    object oPC = GetPCSpeaker ();
    string sSkill = GetScriptParam ("nSkill");
    if (sSkill != "")
    {
        nRoll = GetLocalInt (OBJECT_SELF, "0_Check_" + RemoveIllegalCharacters  (GetName (oPC)));
        if (nRoll == 0)
        {
            nSkill = StringToInt (sSkill);
            nBonus = StringToInt (GetScriptParam ("nBonus"));
            nMessage = StringToInt (GetScriptParam ("nMessage"));
            bTake20 = StringToInt (GetScriptParam ("bTake20"));
            bArmorPenalty = StringToInt (Get2DAString ("skills", "ArmorCheckPenalty", nSkill));
            nRoll = GetSkillCheck (oPC, nSkill, bArmorPenalty, nBonus, 0, nMessage, bTake20);
            SetLocalInt (OBJECT_SELF, "0_Check_" + RemoveIllegalCharacters  (GetName (oPC)), nRoll);
        }
        if (nSkill == SKILL_PERSUADE)
        {
            if (nRoll < 5) { sResult = "hateful"; sColor = COLOR_RED; }
            else if (nRoll < 10) { sResult = "cautious"; sColor = COLOR_RED; }
            else if (nRoll < 15) { sResult = "normal"; sColor = COLOR_GREEN; }
            else if (nRoll < 20) { sResult = "relaxed"; sColor = COLOR_GREEN; }
            else { sResult = "friendly"; sColor = COLOR_GREEN; }
            SendMessages (GetName (OBJECT_SELF) + " seems " + sResult + " towards you.", sColor, oPC, FALSE, FALSE);
        }
    }
    string sDC = GetScriptParam ("nDC");
    if (sDC != "")
    {
        nRoll = GetLocalInt (OBJECT_SELF, "0_Check_" + RemoveIllegalCharacters  (GetName (oPC)));
        if (nRoll >= StringToInt (sDC)) return TRUE;
    }
    return FALSE;
}
