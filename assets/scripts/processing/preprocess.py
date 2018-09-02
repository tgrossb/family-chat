import csv
import os.path

input = "countries.csv"
output = "../flags/map.csv"
flagsDir = "../flags"
keep = ["Dial", "ISO3166-1-Alpha-2", "official_name_en", "CLDR display name"]

def arrayToCsv(arr, exportPath):
	with open(exportPath, "w") as out:
		writer = csv.writer(out, delimiter = ",", quoting = csv.QUOTE_MINIMAL)
		for row in arr:
			writer.writerow(row)


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


def findExtraneousFlags(isos):
	for file in os.listdir(flagsDir):
		if os.path.isfile(os.path.join(flagsDir, file)) and os.path.basename(file[0:file.index(".")]) not in isos:
			print("File " + os.path.join(flagsDir, file) + " can be deleted")


def main():
	ids, csv = csvToArray(input)
	keepIndices = [c for c in range(len(ids)) if ids[c] in keep]
	if not len(keepIndices) == len(keep):
		print("Probably an error")
		print(keep)
		print("from")
		print(ids)
		print("yields")
		print(keepIndices)

	keepCsv = []

	# Remove extraneous information
	for row in csv:
		keepRow = []
		for colNum in range(len(row)):
			if colNum in keepIndices:
				data = row[colNum].strip()
				# Special for Dial, take only the substring to the '-' if there is one
				if ids[colNum] == "Dial" and "-" in data:
					data = data[:data.index("-")]
				keepRow.append(data.lower())
		skip = False
		for el in keepRow:
			if len(el) == 0:
				print("Row " + str(keepRow) + " missing parameter, skipping")
				skip = True
		if not skip:
			keepCsv.append(keepRow)

	# Check for any missing flags
	rawIsoIndex = keepIndices[keep.index("ISO3166-1-Alpha-2")]
	keepIndices.sort()
	isoIndex = keepIndices.index(rawIsoIndex)
	isos = []
	for row in keepCsv:
		if not os.path.exists(os.path.join(flagsDir, row[isoIndex] + ".png")):
			print("Missing flag for " + row[isoIndex])
		isos.append(row[isoIndex])

	findExtraneousFlags(isos)

	arrayToCsv(keepCsv, output)


if __name__ == "__main__":
	main()
