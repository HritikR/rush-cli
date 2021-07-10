#!/bin/sh

# Exit immediately if any command exits with non-zero exit status.
set -e

if ! command -v unzip >/dev/null; then
	echo "err: unzip is required to install Rush. Please install it and try again."
	exit 1
fi

# Check if Rush is already installed; if it is, use the old
# path for storing Rush executable
if ! command -v rush >/dev/null; then
  binDir="$HOME/.rush/bin"
  if [ ! -d "$binDir" ]; then
    mkdir -p "$binDir"
  fi
else
  binDir="$(dirname $(which rush))"
fi

# Set the target
if [ "$OSTYPE" = "msys" ] || [ "$OSTYPE" = "cygwin" ]; then
  target="win"
  dataDir="$APPDATA/rush"
elif [ "$OSTYPE" = "darwin"* ]; then
  target="mac"
  dataDir="$HOME/Library/Application Support/rush"
else
  target="linux"
  dataDir="$HOME/rush"
fi

zipUrl="https://github.com/shreyashsaitwal/rush-cli/releases/latest/download/rush-$target.zip"

# Download and unzip rush-$target.zip
curl --location --progress-bar -o "$binDir/rush-$target.zip" "$zipUrl"
unzip -oq "$binDir/rush-$target.zip" -d $binDir/
rm "$binDir/rush-$target.zip"

# Delete dataDir if it already exists
if [ -d "$dataDir" ]; then
  rm -rf "$dataDir"
fi

# Then (re-)create it
mkdir "$dataDir"

# Move the EXEs under the binDir
mv "$binDir/exe/$target"/* "$binDir"
rm -r "$binDir/exe/"

# Move all the directories that were unzipped
mv $(ls -d "$binDir"/*/) "$dataDir"

# Give all the necessary scripts execution permission
chmod +x "$binDir/rush"
chmod +x "$dataDir/tools/kotlinc/bin/kotlinc"
chmod +x "$dataDir/tools/kotlinc/bin/kapt"
chmod +x "$dataDir/tools/jetifier-standalone/bin/jetifier-standalone"

cyan='\033[0;36m'
green='\033[0;32m'
reset='\033[0m'

echo
echo "${green}Success!${reset} Installed Rush at $binDir/rush"
if ! command -v rush >/dev/null; then
  if [ "$OS" = "Windows_NT" ]; then
    echo
    echo "Now, add the following entry to your 'PATH' environment variable:"
    echo "${cyan}$binDir${reset}"
  else
    case $SHELL in
      /bin/zsh) shell_profile=".zshrc" ;;
      *) shell_profile=".bash_profile" ;;
    esac

    exp=" export PATH=\"\$PATH:$binDir\" "
    edge=$(echo " $exp " | sed 's/./-/g')

    echo
    echo "Now, manually add Rush's bin directory to your \$HOME/$shell_profile (or similar):"
    echo $edge
    echo "|${cyan}${exp}${reset}|"
    echo $edge
  fi
fi
echo
echo "Run ${cyan}rush --help${reset} to get started."
