/*//////////////////////////////////////////////////////////////////////////////
 Script: 0c_if_learn_lang
 Programmer: Philos
////////////////////////////////////////////////////////////////////////////////
 Text Appears When script that checks to see if they can learn a language.
 Checks the number of Speak Language points vs the number of language tokens the
 character owns.
*///////////////////////////////////////////////////////////////////////////////
#include "0i_character"

int StartingConditional()
{
    object oPC = GetPCSpeaker ();
    int nSpeakLanguagePoints = GetLanguagesToLearn (oPC);
    int nKnownLanguages = GetLanguagesKnown (oPC);
    int nUnknownLanguages = nSpeakLanguagePoints - nKnownLanguages;
    if (nUnknownLanguages > 0 )
    {
        SetCustomToken (700, IntToString (nUnknownLanguages));
        return TRUE;
    }
    else return FALSE;
}
