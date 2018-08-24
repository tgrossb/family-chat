import csv
import json
import sys

def jsonToMap(path):
	out = {}
	with open(path, "r") as file:
		out = json.load(file)
	return out


def mapToJson(jsonMap, path):
	with open(path, "w") as file:
		json.dump(jsonMap, file, sort_keys=True, indent=4, separators=(",", ":"))



def main():
	inFile = input("Path to file to edit: ")
	jsonState = jsonToMap(inFile)
	print("========== Editing " + inFile + " ==========")
	print("Enter a key, value pair to append to the json.")
	print("All data is understood to be strings, and input need not be quoted.")
	print("Use ctrl-c to finish and write changes to the json.")
	print("")
	changes = 0
	try:
		while True:
			keyValPair = input("Enter a comma or colon separated key, value pair: ")
			if "," in keyValPair:
				separator = ","
			elif ":" in keyValPair:
				separator = ":"
			else:
				separator = ""
				print("No separator found.")

			if len(separator) > 0:
				key, value = keyValPair.split(separator)
				key = key.strip()
				value = value.strip()
				jsonState[key] = value
				print('Queued writing "' + key + '": "' + value + '" to ' + inFile)
				changes++;
	except KeyboardInterrupt:
		mapToJson(jsonState, inFile)
		print("========== Wrote " + changes + " change" + " " if changes == 1 else "s " + "to " + inFile + " ==========")
		sys.exit(0)


if __name__ == "__main__":
	main()

