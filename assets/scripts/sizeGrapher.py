import matplotlib
import matplotlib.pyplot as plt
import os


from PIL import Image
import os
import shutil
from statistics import mode

dir = "../flags"
output = "filtered"
topModes = 3

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

ratiosCp = ratios
topModeRatios = []
for c in range(0, topModes):
	if len(ratiosCp) == 0:
		print("Aborting early (0 length) on mode " + str(c))
		break
	modeRatio = mode(ratiosCp)
	print("Mode ratio " + str(c+1) + ": " + str(modeRatio))
	ratiosCp = [ratio for ratio in ratiosCp if not ratio == modeRatio]
	topModeRatios.append(modeRatio)

wrongRatios = [ratio for ratio in ratios if not ratio in topModeRatios]
print("Number to keep: " + str(len(ratios) - len(wrongRatios)))
print("Number to eidt: " + str(len(wrongRatios)))

ratioCounts = {}
for ratio in ratios:
	if ratio in ratioCounts.keys():
		ratioCounts[ratio] = ratioCounts[ratio] + 1
	else:
		ratioCounts[ratio] = 1

# Order the keys
orderedKeys = list(ratioCounts.keys())
orderedKeys.sort()

# Add the counts by key order
orderedCounts = []
for key in orderedKeys:
	orderedCounts.append(ratioCounts[key])

fig, ax = plt.subplots()
ax.plot(orderedKeys, orderedCounts, "go-")

for topModeRatio in topModeRatios:
	ax.plot(topModeRatio, ratioCounts[topModeRatio], "ro")

#ax.plot("US", ys[np.where(xs == "US")[0]], "go")

#mean = np.mean(ys)
#median = np.median(ys)
#std = np.std(ys)

#ax.axhline(y=mean, color="r")
#ax.axhline(y=mean-std, color="y")
#ax.axhline(y=mean+std, color="y")
#ax.axhline(y=median, color="g")
#print("Mean: %f    +/-1 std: %f, %f    median: %f" % (mean, mean-std, mean+std, median))

#aboveIndices = np.where(ys > mean+std)[0]
#aboveIsos = [xs[country] for country in aboveIndices]
#print("Count above +1 std: %d" % len(aboveIsos))
#print("Would loose: " + ", ".join(aboveIsos))
#maxLength = math.floor(mean+std)
#for aboveIso in aboveIsos:
#	aboveName = inMap[aboveIso]
#	print("'" + aboveName + "' (" + str(len(aboveName)) + ") => '" + aboveName[:maxLength+1] + "'")

ax.set(xlabel = "ratio", ylabel = "count")

ax.grid()
plt.xticks(rotation=90)
plt.show()
