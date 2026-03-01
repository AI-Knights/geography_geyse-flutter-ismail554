import os
import re

def fix_general_settings():
    path = "lib/views/profile/settings/general_settings.dart"
    with open(path, 'r', encoding='utf-8') as f:
        content = f.read()

    # Fix mounted checks to context.mounted explicitly
    content = content.replace("if (mounted) {", "if (context.mounted) {")
    content = content.replace("if (mounted) setState", "if (context.mounted) setState")
    
    # Fix the missing context.mounted in catch block
    catch_block = """    } catch (e) {
      debugPrint("Profile update error: $e");
      String msg = e.toString();
      if (msg.startsWith('Exception: ')) {
        msg = msg.substring(11); // Remove "Exception: " prefix
      }
      if (!context.mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(msg), backgroundColor: Colors.red));
    } finally {"""
    content = re.sub(r'    } catch \(e\) \{.*?} finally \{', catch_block, content, flags=re.DOTALL)
    
    with open(path, 'w', encoding='utf-8') as f:
        f.write(content)


def main():
    fix_general_settings()
    
if __name__ == "__main__":
    main()
