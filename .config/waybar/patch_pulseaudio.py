import json

with open("modules/pulseaudio.jsonc", "r") as f:
    text = f.read()

# Replace the drawer section
text = text.replace("""\t\t"drawer": {
\t\t\t// "transition-duration":
\t\t\t"transition-left-to-right": false
\t\t\t// "children-class":
\t\t\t// "click-to-reveal":
\t\t}""", "")
text = text.replace(',\n\n\t},', '\n\t},')

with open("modules/pulseaudio.jsonc.new", "w") as f:
    f.write(text)
