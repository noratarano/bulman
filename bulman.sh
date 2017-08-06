#! /usr/bin/env bash
# /*
# Exit on failure; treat any failure in a pipe as the failure of the whole pipe
set -eo pipefail

## Initial plan
# 1. read STDIN somehow
input="$(< "${1:-/dev/stdin}")"
safe_input="$(echo "${input}" | sed 's/&/\&amp;/g; s/</\&lt;/g; s/>/\&gt;/g; s/"/\&quot;/g; s/'"'"'/\&#39;/g')"

# 2. Create a .html file by combining a template with STDIN data
path_to_bulman="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/$(basename "${BASH_SOURCE[0]}")"
formatted_input='
<!DOCTYPE html>
<html>
<head>
  <link rel="stylesheet" href="file://'"${path_to_bulman}"'" />
</head>
<body>

<section class="section">
  <div class="container">
    <div class="box">
      <div class="content">
        <pre>'"${safe_input}"'</pre>
      </div>
    </div>
  </div>
</section>

</body>
</html>
'
tmpdir="$(mktemp -dt bulman)"
html_file="${tmpdir}/index.html"
echo -n "${formatted_input}" > "${html_file}"

# 3. call `open -a ...` to open the user's browser to view the file
open "${html_file}"

## Advanced Plan
# 1. read STDIN somehow
# 2. Create a .html file by combining a template with STDIN data
# 3. Open a standalone Electron process to view the HTML file.
# 4. Wait for electron to finish before exiting

exit 0

# */
