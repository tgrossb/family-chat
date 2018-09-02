import csv
import json

in1 = ("jsons/codeToName.json", "keys")
in2 = ("jsons/codeToPhone.json", "keys")

def jsonToMap(path):
	out = {}
	with open(path, "r") as file:
		out = json.load(file)
	return out


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


def formCsv(csvIn, col):
	# Process the csv to keep only the ISO3166-1-Alpha-2 column
	ids, fullCin = csvToArray(csvIn)
	keepCol = ids.index(col)
	cinCol = []
	for row in fullCin:
		cinCol.append(row[keepCol].upper())
	return cinCol


def handleInput(input, extract):
	if input[input.index("."):] == ".json":
		if extract == "keys":
			return jsonToMap(input).keys()
		else:
			return jsonToMap(input).values()
	else:
		return formCsv(input, extract)


def crossCheck(l1, l2):
	nothing = True
	for el in l1:
		if el not in l2:
			print("Input 1 exclusive: " + el)
			nothing = False
	for el in l2:
		if el not in l1:
			print("Input 2 exclusive: " + el)
			nothing = False
	if nothing:
		print("No differences")


def main():
	l1 = handleInput(*in1)
	l2 = handleInput(*in2)
	crossCheck(l1, l2)


if __name__ == "__main__":
	main()
