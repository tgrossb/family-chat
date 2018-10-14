import 'dart:collection' show Queue;
import 'package:flutter/material.dart' show required;
import 'package:flutter/services.dart';

class MaskedTextInputFormatter extends TextInputFormatter {
  static int reverseSearch(List<String> l, String find, int from){
    for (int c= from?? l.length-1; c>=0; c--)
      if (l[c] == find)
        return c;
    return -1;
  }

  String mask, masker, placeHolder;
  List<String> maskList;
  Map<int, int> forwardInputToMaskIndex, backwardInputToMaskIndex;
  int staticCounter, maskerCount;
  RegExp maskedValueMatcher;

  // String mask: The representative mask of this input (ex. "(xxx) xxx - xxxx")
  // String masker: The character representing a masked input (ex. "x")
  // String placeHolder: The character to replace unused masked inputs (ex. " ")
  // RegExp maskedValueMatcher: The regex that strips all maskable characters from a string (ex. RegExp(r'[0-9]'))
  // maskedValueMatcher should match exactly one character and not use ^ or $
  MaskedTextInputFormatter({@required this.mask, @required this.masker, @required this.maskedValueMatcher, this.placeHolder: " "}){
    maskList = mask.split("");
//    print(maskList);

    forwardInputToMaskIndex = {};
    backwardInputToMaskIndex = {};

    // I honestly have no idea how this works, but it does
    // Please, just don't fucking touch it
    int lastIndex = -1;
    maskerCount = masker.allMatches(mask).length;
    for (int c=0; c<maskerCount; c++) {
      lastIndex = maskList.indexOf(masker, lastIndex+1);
      forwardInputToMaskIndex[c] = lastIndex;
    }

    // Add the last by hand to be right after the last masker
    forwardInputToMaskIndex[maskerCount] = forwardInputToMaskIndex[maskerCount-1]+1;

    // This is just the previous fuckery reversed pretty much
    lastIndex = maskList.length;
    for (int c=maskerCount; c>0; c--){
      lastIndex = reverseSearch(maskList, masker, lastIndex-1);
      backwardInputToMaskIndex[c] = lastIndex + 1;
    }

    // Add the first by hand to be right before the first masker
    backwardInputToMaskIndex[0] = backwardInputToMaskIndex[1]-1;

//    print("Forward  : $forwardInputToMaskIndex");
//    print("Backgward: $backwardInputToMaskIndex");
  }

  Queue<String> stripMaskable(String s){
    return Queue.of(maskedValueMatcher.allMatches(s).map((Match match) => match.group(0)));
  }

  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    // Lop off the end of newValue if its more than the number of maskable inputs
    String newText = newValue.text.length > maskerCount ? newValue.text.substring(0, maskerCount) : newValue.text;

    Queue<String> oldMaskables = stripMaskable(oldValue.text);
    Queue<String> newMaskables = stripMaskable(newText);
    int inputSelectionIndex = newValue.selection.baseOffset;

    // 3 static movements in a row is a sign that something is being ignored
    if (oldMaskables.length == newMaskables.length) {
      staticCounter++;
    } else
      staticCounter = 0;

    // If there are 3 or more statics in a row, remove the last character from newValue if there are any
    // Also, set deleting to true and adding to false if phoneNums is not 0 after this
    if (staticCounter > 2){
      print("3 statics");

      staticCounter = 0;
      int selectionIndex = 0;

      if (newMaskables.length > 0) {
        // Remove the inputSelectionIndex-th number and roll back inputSelectionIndex to match
        newMaskables.removeWhere((String test) => ++selectionIndex == inputSelectionIndex);
        inputSelectionIndex -= 1;
      }
    }

    // If this is still static after the triple static has been handled, skip this method
    if (oldMaskables.length == newMaskables.length) {
      print("Useless static, skipping");
      return oldValue;
    }

    // Compute the boolean checking if this is an addition
    // Make sure this is after the triple static delete shit
    bool adding = oldMaskables.length < newMaskables.length;

    StringBuffer output = StringBuffer();

    print(adding ? "Adding" : "Deleting");
    print("\nold: '${oldValue.text}' new: '$newText' (${newValue.selection.baseOffset}");

    // Stream through the mask, placing numbers in order at mask characters
    // When out of numbers, place placeHolder at that mask
    for (String maskCharacter in maskList){
      if (maskCharacter == masker && newMaskables.isNotEmpty)
        // If this is a mask character and there is a phone number, add the number
        output.write(newMaskables.removeFirst());
      else if (maskCharacter == masker && newMaskables.isEmpty)
        // If this is a masker character but there are no more numbers, add a place holder
        output.write(placeHolder);
      else
        // If this is not a masker character, copy from the mask
        output.write(maskCharacter);
    }

    int maskSelectionIndex = adding ? forwardInputToMaskIndex[inputSelectionIndex] : backwardInputToMaskIndex[inputSelectionIndex];
    print("Selection index: $maskSelectionIndex  (from $inputSelectionIndex)");

    return new TextEditingValue(
      text: output.toString(),
      selection: new TextSelection.collapsed(offset: maskSelectionIndex),
    );
  }
}