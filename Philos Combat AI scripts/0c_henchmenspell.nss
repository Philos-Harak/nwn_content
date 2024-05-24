/*///////////////////////////////////////////////////////////////////////////////
 Script: 0c_henchmenspell
 Programmer: Philos
////////////////////////////////////////////////////////////////////////////////
 Action script to cast a specific spell for a henchman.

 Script Param
 nTarget (INT) : 0 = ALL, 1-4 = Other Henchman, 5 = Caster, 6 = PC's Familiar
                 7 = PC's Animal Companion, 8 = PC.
 nBuffType = 1 short 2 long 3 all, 4 healing, 5 lay on hands.
 If nBuffType is 0 then it will cast a specific spell from
 Variable "0_SPELL_TO_CAST". Use script: 0c_h_spell_cast spell to set the spell.
*///////////////////////////////////////////////////////////////////////////////
#include "0i_associates"
float ai_UseLayOnHands(object oTarget, object oPC, float fDelay, object oCaster);
void main()
{
    object oTarget, oPC = GetPCSpeaker();
    object oCreature = OBJECT_SELF;
    float fDelay;
    int nTarget = StringToInt(GetScriptParam("nTarget"));
    int nBuffType = StringToInt(GetScriptParam("nBuffType"));
    ai_SetupBuffTargets(oCreature, oPC);
    // Cast a group of buff spells based on nBuffType and nTarget or a single spell.
    if(nBuffType < 4)
    {
        // Cast a specific spell.
        if(nBuffType == 0)
        {
            int nSpell = GetLocalInt(oCreature, "0_SPELL_TO_CAST");
            // These are buff spells so Acid fog (index 0) is not a valid spell.
            if(nSpell > 0)
            {
                ai_ClearCreatureActions(oCreature);
                object oTarget = GetLocalObject(oCreature, "AI_BUFF_TARGET_" + IntToString(nTarget));
                if(oTarget != OBJECT_INVALID && ai_CheckAndCastSpell(oCreature, nSpell, 0, 0.0f, oTarget, oPC))
                {
                    DeleteLocalInt(oCreature, "0_SPELL_TO_CAST");
                }
                else
                {
                    if(!ai_GetAssociateMode(oCreature, AI_MODE_DO_NOT_SPEAK)) PlayVoiceChat(VOICE_CHAT_CANTDO, oCreature);
                    string sSpellName = GetStringByStrRef(StringToInt(Get2DAString("spells", "Name", nSpell)));
                    ai_SendMessages("I cannot cast " + sSpellName + ".", COLOR_RED, oPC);
                }
            }
        }
        // Cast a creatures buff spells on nTarget.
        else ai_CastBuffs(oCreature, nBuffType, nTarget, oPC);
    }
    // Cast Healing spells.
    else if(nBuffType == 4)
    {
        // Target of 0 means cast it on all allies.
        if(nTarget == 0)
        {
            int nCntr, nIndex;
            while(nIndex < 9)
            {
                oTarget = GetLocalObject(oCreature, "AI_BUFF_TARGET_" + IntToString(++nIndex));
                //ai_Debug("0c_henchmanspell", "66", "oTarget: " + GetName(oTarget) +
                //         " nIndex: " + IntToString(nIndex));
                if(oTarget != OBJECT_INVALID && ai_GetPercHPLoss(oTarget) < 100)
                {
                    if(ai_UseHealing(oCreature, oTarget, oPC, fDelay, ++nCntr)) fDelay += AI_HENCHMAN_BUFF_DELAY;
                    else DelayCommand(fDelay, ai_SendMessages("I cannot heal " + GetName(oTarget) + ".", COLOR_RED, oPC));


                }
            }
            while (nCntr > 0)
            {
                DeleteLocalString(oCreature, "AI_CASTING_SPELL_" + IntToString(nCntr--));
            }
        }
        else
        {
            oTarget = GetLocalObject(oCreature, "AI_BUFF_TARGET_" + IntToString(nTarget));
            if(oTarget != OBJECT_INVALID)
            {
                if(!ai_UseHealing(oCreature, oTarget, oPC, 0.0f))
                {
                    DelayCommand(fDelay, ai_SendMessages("I cannot heal " + GetName(oTarget) + ".", COLOR_RED, oPC));
                }
            }
        }
    }
    // Use lay on hands.
    else if(nBuffType == 5)
    {
        oTarget = GetLocalObject(oCreature, "AI_BUFF_TARGET_" + IntToString(nTarget));
        ai_UseLayOnHands(oTarget, oPC, 0.0f, oCreature);
    }
    else if(!ai_GetAssociateMode(oCreature, AI_MODE_DO_NOT_SPEAK)) PlayVoiceChat(VOICE_CHAT_CUSS, oCreature);
    ai_ClearBuffTargets(oCreature);
}
float ai_UseLayOnHands(object oTarget, object oPC, float fDelay, object oCreature)
{
    int nHpLost = GetMaxHitPoints(oTarget) - GetCurrentHitPoints(oTarget);
    if(!nHpLost)
    {
        if(!ai_GetAssociateMode(oCreature, AI_MODE_DO_NOT_SPEAK)) PlayVoiceChat(VOICE_CHAT_CANTDO, oCreature);
        ai_SendMessages(GetName(oTarget) + " does not need healed.", COLOR_RED, oPC);
    }
    else
    {
        ai_SendMessages(GetName(oCreature) + " is laying hands on " + GetName(oTarget), COLOR_GREEN, oPC);
        ActionUseFeat(FEAT_LAY_ON_HANDS, oTarget);
        fDelay += 6.0f;
    }
    return fDelay;
}
