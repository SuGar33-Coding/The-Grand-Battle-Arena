extends Resource

class_name EncounterStats

enum EncounterSize {
	SMALL,
	MEDIUM,
	LARGE
}

export(EncounterSize) var encounterSize = EncounterSize.SMALL
# List of filepaths to scenes of the common units in this encounter
export(Array, String) var gruntFilepaths
# List of filepaths to the scenes of more unique/uncommon units in this encounter
export(Array, String) var specialFilepaths
# List of possible big bads in this encounter
export(Array, String) var commanderFilepaths

export(int) var difficultyLevel = 1

export(bool) var guaranteeBoss = false

