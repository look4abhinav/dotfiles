import re

with open("config.jsonc", "r") as f:
    text = f.read()

# remove lines containing div
text = re.sub(r'\s*"custom/(left|right)_(div|inv)#[0-9]+",?', '', text)

# fix trailing commas before ]
text = re.sub(r',\s*//.*?\s*\]', lambda m: m.group(0).replace(',', '', 1), text)
text = re.sub(r',\s*\]', '\n\t]', text)

with open("config.jsonc.new", "w") as f:
    f.write(text)
