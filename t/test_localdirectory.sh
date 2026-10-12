#!/bin/bash
# Test for #!CreateArchive support in 20-files-present-and-referenced

set -e

# Path to the script to test
VALIDATOR="./20-files-present-and-referenced"
TEST_DATA_DIR="t/data/localdirectory_test"

# Create test data directory if it doesn't exist
rm -rf "$TEST_DATA_DIR"
mkdir -p "$TEST_DATA_DIR"

# Create a dummy spec file
cat > "$TEST_DATA_DIR/test.spec" <<EOF
Name: test
Version: 1.0
Release: 0
Summary: test
License: MIT
#!CreateArchive
Source1:       node_modules.tar.xz
#!CreateArchive: second_dir
Source2:       second_dir-0.42.tar.gz
%description
test
%prep
%setup -q
%build
%install
%files
EOF

# A git repository may provide a directory. This can be tar'd up at build time
# without that need to re-do the tar on each commit.
mkdir "$TEST_DATA_DIR/node_modules"
touch "$TEST_DATA_DIR/node_modules/some_file"
mkdir "$TEST_DATA_DIR/second_dir"
touch "$TEST_DATA_DIR/second_dir/another_file"

echo "Running validator on $TEST_DATA_DIR..."
./20-files-present-and-referenced --batchmode "$TEST_DATA_DIR" || exit 1

rm -rf "$TEST_DATA_DIR/second_dir"

TOUT=$(mktemp)
set +e
./20-files-present-and-referenced --batchmode "$TEST_DATA_DIR" 2>/dev/null > $TOUT && exit 1
set -e

grep -q "ERROR: second_dir-0.42.tar.gz mentioned in spec file (or the directory second_dir/) is not tracked" $TOUT || { echo "FAIL"; cat $TOUT; exit 1; }

rm -f $TOUT

exit 0


