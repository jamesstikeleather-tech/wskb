import '../models/razor.dart';

String prettyRazorType(RazorType t) {
  switch (t) {
    case RazorType.safety:   return 'Safety';
    case RazorType.straight: return 'Straight';
    case RazorType.shavette: return 'Shavette';
    case RazorType.kamisori: return 'Kamisori';
    case RazorType.other:    return 'Other';
  }
}

String prettyRazorForm(RazorForm f) {
  switch (f) {
    case RazorForm.de:                   return 'DE (Double Edge)';
    case RazorForm.seGem:                return 'SE (GEM)';
    case RazorForm.seInjector:           return 'SE (Injector)';
    case RazorForm.seAc:                 return 'SE (Artist Club)';
    case RazorForm.seFhs10:              return 'SE (FHS-10)';
    case RazorForm.cartridgeMulti:       return 'Cartridge (Multi-blade)';
    case RazorForm.straightFolding:      return 'Straight (Folding)';
    case RazorForm.straightFixed:        return 'Straight (Fixed)';
    case RazorForm.kamisoriTraditional:  return 'Kamisori (Traditional)';
    case RazorForm.shavetteFolding:      return 'Shavette (Folding)';
    case RazorForm.shavetteFixed:        return 'Shavette (Fixed)';
    case RazorForm.other:                return 'Other';
  }
}

// Optional: expand bar/guard abbreviations for display
String prettyBarType(String raw) {
  switch (raw) {
    case 'SB':   return 'Safety Bar (SB)';
    case 'OC':   return 'Open Comb (OC)';
    case 'ScB':  return 'Scalloped Bar (ScB)';
    case 'None': return 'No Safety Bar';
    default:     return raw;
  }
}
