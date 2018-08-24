import csv
import json

input = "jsons/codeToName.json"
output = "jsons/nameToCode.json"

def jsonToMap(path):
	out = {}
	with open(path, "r") as file:
		out = json.load(file)
	return out


def mapToJson(jsonMap, path):
	with open(path, "w") as file:
		json.dump(jsonMap, file, sort_keys=True, indent=4, separators=(",", ":"))



def main():
	jsonIn = jsonToMap(input)
	flipped = {}
	for key in jsonIn.keys():
		flipped[jsonIn[key]] = key
	mapToJson(flipped, output)


if __name__ == "__main__":
	main()

