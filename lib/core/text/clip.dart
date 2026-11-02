/// The longest text of somebody else's post that is laid out on screen. Mialuna
/// itself never writes more than 2200 characters of caption; a post that is
/// many times longer is somebody trying to make the phone stall while it
/// measures the text.
const maxDisplayedChars = 5000;

/// [text] cut to [max] UTF-16 units with an ellipsis, never in the middle of
/// an emoji (a surrogate pair). Short texts are returned as they are.
String clipForDisplay(String text, {int max = maxDisplayedChars}) {
  if (text.length <= max) return text;
  var end = max;
  final last = text.codeUnitAt(end - 1);
  final cutsPair = last >= 0xD800 && last <= 0xDBFF;
  if (cutsPair) end--;
  return '${text.substring(0, end)}…';
}
