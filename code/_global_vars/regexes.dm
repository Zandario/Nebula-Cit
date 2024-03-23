//# These are a bunch of regex datums for use /((any|every|no|some|head|foot)where(wolf)?\sand\s)+(\.[\.\s]+\s?where\?)?/i

var/global/regex/angular_brackets = regex(@"[<>]"                                        , "g") //! All < and > characters
var/global/regex/is_alphanumeric  = regex(@"[a-z0-9]+"                                   , "i") //! Checks for alphanumeric characters
var/global/regex/is_color         = regex(@"^#[0-9a-fA-F]{6}$"                                ) //! Checks for a hex color code
var/global/regex/is_email         = regex(@"[a-z0-9_-]+@[a-z0-9_-]+.[a-z0-9_-]+"         , "i") //! Checks for a basic email address
var/global/regex/is_http_protocol = regex(@"^https?://"                                       ) //! Checks for http:// or https://
var/global/regex/is_punctuation   = regex(@"[.!?]+"                                      , "i") //! Simple check for punctuation
var/global/regex/is_website       = regex(@"http|www.|[a-z0-9_-]+.(com|org|net|mil|edu)+", "i") //! This is a very basic check for a website, it's not perfect.

/// All characters forbidden by filenames: ", \, \n, \t, /, ?, %, *, :, |, <, >, ..
GLOBAL_PROTECTED(filename_forbidden_chars, /regex, regex(@{""|[\\\n\t/?%*:|<>]|\.\."}, "g"))
// had to use the OR operator for quotes instead of putting them in the character class because it breaks the syntax highlighting otherwise.

/// Used to santize text and
/// codes from https://www.compart.com/en/unicode/category/
///            https://en.wikipedia.org/wiki/Whitespace_character#Unicode
GLOBAL_PROTECTED(unicode_control_chars, /regex, regex(@"[\u0001-\u0009\u000B\u000C\u000E-\u001F\u007F\u0080-\u009F\u00A0\u1680\u180E\u2000-\u200D\u2028\u2029\u202F\u205F\u2060\u3000\uFEFF]", "g"))
