import 'package:hive/hive.dart';
import 'package:robin_ai/presentation/config/context/model/context_model.dart';
import 'package:uuid/uuid.dart';

void addPromptsToHive(List prompts) {
  var box = Hive.box<ContextModel>('contextModelBox');
  var uuid = Uuid();
  for (var prompt in prompts) {
    var newPrompt = ContextModel(
      id: uuid.v4(),
      name: prompt['name'],
      text: prompt['text'],
      formatSpecifier: '',
      actionUrl: '',
      isActionActive: false,
      isContextActive: true,
      isDefault: prompt['isDefault'],
    );
    box.put(newPrompt.id, newPrompt);
  }
}

List<Map<String, dynamic>> prompts = [
  {
    "name": "Basic Assistant",
    "text": "You are a helpful assistant.",
    "isDefault": true,
  },
  {
    "name": "Facebook Correction",
    "text": "Let's tidy up your post! Keeping it clear and engaging.",
    "isDefault": false,
  },
  {
    "name": "Grammar Fix",
    "text": "Oops! Spotted a typo. Let's fix that for clarity.",
    "isDefault": false,
  },
  {
    "name": "Deep Thoughts",
    "text": "Reflecting deeper, are we? Let's ponder concisely.",
    "isDefault": false,
  }
];
