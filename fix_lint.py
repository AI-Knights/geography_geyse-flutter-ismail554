import os
import re

modified_files = 0
for root, _, files in os.walk('lib'):
    for file in files:
        if file.endswith('.dart'):
            path = os.path.join(root, file)
            with open(path, 'r', encoding='utf-8') as f:
                content = f.read()
            
            # Replace .withOpacity(X) -> .withValues(alpha: X)
            new_content = re.sub(r'\.withOpacity\(([^)]+)\)', r'.withValues(alpha: \1)', content)
            
            # Replace print( -> debugPrint( but ignore already commented ones
            new_content = re.sub(r'(?<!// )\bprint\(', 'debugPrint(', new_content)
            
            if new_content != content:
                if 'debugPrint' in new_content and 'package:flutter/' not in new_content:
                    new_content = "import 'package:flutter/foundation.dart';\n" + new_content
                with open(path, 'w', encoding='utf-8') as f:
                    f.write(new_content)
                modified_files += 1

print(f"Modified {modified_files} files.")
