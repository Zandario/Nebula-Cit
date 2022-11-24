/decl/language/teshari
	name = "Schechi"
	desc = "A trilling language spoken by the diminutive Tesharii."
	speech_verb = "chirps"
	ask_verb = "chirrups"
	exclaim_verb = "trills"
	colour = "alien"
	key = "i"
	flags = LANG_FLAG_WHITELISTED
	space_chance = 50
	syllables = list(
			"ca", "ra", "ma", "sa", "na", "ta", "la", "sha", "scha", "a", "a",
			"ce", "re", "me", "se", "ne", "te", "le", "she", "sche", "e", "e",
			"ci", "ri", "mi", "si", "ni", "ti", "li", "shi", "schi", "i", "i"
		)

/decl/language/teshari/get_random_name(gender)
	return ..(gender, 2, 4, 1.5)

/decl/cultural_info/culture/teshari
	name = "Neo-Avian Milieu"
	description = "Tesharii form a loose coalition of family and flock groupings, and are usually in an extreme minority in human settlements. \
	They tend to cope poorly with confined, crowded spaces like human habs, and often make their homes in hab domes or other spacious facilities."
	language = /decl/language/teshari
	secondary_langs = list(
		/decl/language/teshari,
		/decl/language/sign
	)

/decl/cultural_info/culture/teshari/saurian
	name = "Saurian Revivalism"
	description = "A minority of Tesharii, particularly those subject to genetic modification during the initial uplift of their species, \
	embrace the dinosaur heritage shared by all avians in the form of scales, sharp teeth, slender tails, and other clear visible features of \
	their long-extinct forebears. Many Tesharii consider them a fringe of self-important wannabes, but the movement is still going strong."
