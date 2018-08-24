import csv
import json
import sys

csvIn = "csvs/countries.csv"
#csvOut = "codesAndCountry.csv"
jsonOut = "jsons/codeToPhone.json"
keep = ["ISO3166-1-Alpha-3", "ISO3166-1-Alpha-2", "official_name_en"]
toMap = ["ISO3166-1-Alpha-2", "Dial"]
key = "ISO3166-1-Alpha-2"

def arrayToCsv(arr, exportPath):
	with open(exportPath, "w") as out:
		writer = csv.writer(out, delimiter = ",", quoting = csv.QUOTE_MINIMAL)
		for row in arr:
			writer.writerow(row)

def arrayToJson(arr, keyIndex, exportPath):
	jsonMap = {}
	for row in arr:
		jsonMap[row[keyIndex]] = row[(keyIndex + 1) % 2]
	with open(exportPath, "w") as out:
		json.dump(jsonMap, out, sort_keys=True, indent=4, separators=(",", ":"))


def csvToArray(path):
	arr = []
	with open(path, "r") as file:
		reader = csv.reader(file, delimiter = ",")
		for row in reader:
			arr.append(row)

	# Splice out the ids
	ids = arr[0]
	arr = arr[1:]
	return (ids, arr)


def jsonPick():
	ids, arr = csvToArray(csvIn)
	keepIndices = [c for c in range(len(ids)) if ids[c] in toMap]
	if not len(keepIndices) == 2:
		print("Problem selecting exactly 2 parts of the csv")
		print("Keep indices: " + str(keepIndices))
		print("Variables to map: " + str(toMap))
		print("Key: " + key)
	newArr = []
	for row in arr:
		newRow = []
		skip = False
		for col in range(len(row)):
			if col in keepIndices:
				data = row[col].strip()
				if len(data) == 0:
					skip = True
				elif "-" in data:
#					print("Removed '-' from " + data + " in " + str([row[c] for c in range(len(row)) if c in keepIndices]))
					data = data[:data.index("-")]
				if "," in data:
					each = data.split(",")
					if all([el.strip() == each[0].strip() for el in each]):
						data = each[0].strip()
					else:
						print("Big problem with " + data + " in " + str([row[c] for c in range(len(row)) if c in keepIndices]))
						sys.exit(1)
				newRow.append(data)
		if skip:
			print("Skipping " + str(newRow))
		else:
			newArr.append(newRow)
	ki = keepIndices.index(ids.index(key))
	arrayToJson(newArr, ki, jsonOut)



def csvPick():
	ids, arr = csvToArray(csvIn)
	keepIndices = [c for c in range(len(ids)) if ids[c] in keep]
	newArr = [[id for id in ids if id in keep]]
	for row in arr:
		newRow = []
		for col in range(len(row)):
			if col in keepIndices:
				newRow.append(row[col])
		newArr.append(newRow)
	arrayToJson(newArr, csvOut)


def main():
	jsonPick()


if __name__ == "__main__":
	main()
