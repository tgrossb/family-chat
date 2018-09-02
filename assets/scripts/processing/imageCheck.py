import os
import json

input = "jsons/codeToName.json"
dialIn = "jsons/codeToPhone.json"
dir = "../flags/borderless_16x10/00_cctld"
output = "missing"

def jsonToMap(path):
	out = {}
	with open(path, "r") as file:
		out = json.load(file)
	return out


def main():
	names = jsonToMap(input)
	dial = jsonToMap(dialIn)
	with open(output, "w") as outFile:
		for key in names.keys():
			name = key.lower()
			path = os.path.join(dir, name) + ".png"
			if not os.path.exists(path):
				outFile.write(name + " " + dial[key]  + " " + path + "\n")


if __name__ == "__main__":
	main()
