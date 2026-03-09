import re

file_path = "Runner.xcodeproj/project.pbxproj"
with open(file_path, "r") as f:
    content = f.read()

# Remove all keys that might conflict
keys_to_remove = [
    r'\s*"CODE_SIGN_IDENTITY.*?;\n',
    r'\s+CODE_SIGN_IDENTITY.*?;\n',
    r'\s*"DEVELOPMENT_TEAM.*?;\n',
    r'\s+DEVELOPMENT_TEAM.*?;\n',
    r'\s*"PROVISIONING_PROFILE.*?;\n',
    r'\s+PROVISIONING_PROFILE.*?;\n',
    r'\s+CODE_SIGN_STYLE.*?;\n'
]

for key in keys_to_remove:
    content = re.sub(key, "\n", content)

# Inject the standard settings into all build configurations
# We search for INFOPLIST_FILE as a landmark to insert our settings
injection = """
				CODE_SIGN_IDENTITY = "Apple Distribution";
				"CODE_SIGN_IDENTITY[sdk=iphoneos*]" = "iPhone Distribution";
				CODE_SIGN_STYLE = Manual;
				DEVELOPMENT_TEAM = G53HL97CQW;
				PROVISIONING_PROFILE_SPECIFIER = Geo_App_Store;
				INFOPLIST_FILE"""

content = re.sub(r'(\s+)INFOPLIST_FILE', lambda m: m.group(1).replace('\t', '') + injection, content)

# Runner tests does not have INFOPLIST_FILE but GENERATE_INFOPLIST_FILE
injection2 = """
				CODE_SIGN_IDENTITY = "Apple Distribution";
				"CODE_SIGN_IDENTITY[sdk=iphoneos*]" = "iPhone Distribution";
				CODE_SIGN_STYLE = Manual;
				DEVELOPMENT_TEAM = G53HL97CQW;
				PROVISIONING_PROFILE_SPECIFIER = Geo_App_Store;
				GENERATE_INFOPLIST_FILE"""
content = re.sub(r'(\s+)GENERATE_INFOPLIST_FILE', lambda m: m.group(1).replace('\t', '') + injection2, content)


with open(file_path, "w") as f:
    f.write(content)
