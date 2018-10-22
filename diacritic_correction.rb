module DiacriticCorrection
  DIACRITICS = {
    "ā " => "ā",
    "ṭ " => "ṭ",
    "ī " => "ī",
    "ṇ " => "ṇ",
    "ñ " => "ñ",
    "ḥ " => "ḥ",
    "ṣ " => "ṣ",
    "ṃ " => "ṃ",
    "ṅ " => "ṅ",
    "ṛ́ " => "ṛ́",
    "ū " => "ū"
  }
end

# TODO: could change this so it is just an array of the diacritics. then use regex (or something) in the code to avoid false positives like where the diacritic is simply at the end of the word.
