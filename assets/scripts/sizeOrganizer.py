from PIL import Image
import os
import shutil
from statistics import mode

dir = "../flags"
output = "filtered"

if os.path.exists(output):
	shutil.rmtree(output)
os.mkdir(output)

files = [file for file in os.listdir(dir) if os.path.isfile(os.path.join(dir, file))]
ratios = []
for file in files:
	im = Image.open(os.path.join(dir, file))
	w, h = im.size
	ratio = w/h
	ratios.append(ratio)
	im.close()
	path = os.path.join(output, str(ratio))
	if not os.path.exists(path):
		os.mkdir(path)
	shutil.copyfile(os.path.join(dir, file), os.path.join(path, file))

modeRatio = mode(ratios)
print("Mode ratio: " + str(modeRatio))

wrongRatios = [ratio for ratio in ratios if not ratio == modeRatio]
print("Number to truncate: " + str(len(wrongRatios)))

ratioCounts = {}
for ratio in ratios:
	if ratio in ratioCounts.keys():
		ratioCounts[ratio] = ratioCounts[ratio] + 1
	else:
		ratioCounts[ratio] = 1

print("Ratio counts: ")
for ratio, count in ratioCounts.items():
	print("  " + str(ratio) + ": " + str(count))
