#!/bin/bash

# EXIT CODES
# ==============================
# 0     success
# 1     no test files found
# 2     no args
# 3     not a .ts or .js file
# 4     not in an Ember app/ directory
# 5     unknown file type
# 6     cannot find project root
# 7     missing app or tests directory

file_path="$1"

if [ -z "$file_path" ]; then
    exit 2
fi

# Check if file is .ts or .js
if [[ "$file_path" != *.ts ]] && [[ "$file_path" != *.js ]]; then
    exit 3
fi

# Check if file is in an app/ directory
if [[ "$file_path" != */app/* ]]; then
    exit 4
fi

# Find project root by looking for app/ directory
current_dir=$(dirname "$file_path")
project_root=""

while [ "$current_dir" != "/" ]; do
    if [ -d "$current_dir/app" ] && [ -d "$current_dir/tests" ]; then
        project_root="$current_dir"
        break
    fi
    current_dir=$(dirname "$current_dir")
done

# If we didn't find a project root with both app/ and tests/
if [ -z "$project_root" ]; then
    # Try one more time from the app directory itself
    if [[ "$file_path" == */app/* ]]; then
        potential_root="${file_path%/app/*}"
        if [ -d "$potential_root/app" ] && [ -d "$potential_root/tests" ]; then
            project_root="$potential_root"
        elif [ -d "$potential_root/app" ] && [ ! -d "$potential_root/tests" ]; then
            exit 7  # Missing tests directory
        elif [ ! -d "$potential_root/app" ] && [ -d "$potential_root/tests" ]; then
            exit 7  # Missing app directory
        else
            exit 6  # Cannot find project root
        fi
    else
        exit 6
    fi
fi

# Get relative path from app directory
app_dir="$project_root/app"
tests_dir="$project_root/tests"

# Make sure the file is actually in the app directory we found
if [[ "$file_path" != $app_dir/* ]]; then
    exit 4
fi

relative_path="${file_path#$app_dir/}"
filename=$(basename "$relative_path")
filename_without_ext="${filename%.*}"
dir_path=$(dirname "$relative_path")

test_paths=()

# Components can have both integration and unit tests
if [[ "$relative_path" == components/* ]]; then
    # Integration test (default for components)
    test_path="${tests_dir}/integration/${relative_path%.*}-test.ts"
    test_paths+=("$test_path")
    test_path="${tests_dir}/integration/${relative_path%.*}-test.js"
    test_paths+=("$test_path")
    
    # Unit test (less common for components)
    test_path="${tests_dir}/unit/${relative_path%.*}-test.ts"
    test_paths+=("$test_path")
    test_path="${tests_dir}/unit/${relative_path%.*}-test.js"
    test_paths+=("$test_path")

# Helpers typically have integration tests
elif [[ "$relative_path" == helpers/* ]]; then
    test_path="${tests_dir}/integration/${relative_path%.*}-test.ts"
    test_paths+=("$test_path")
    test_path="${tests_dir}/integration/${relative_path%.*}-test.js"
    test_paths+=("$test_path")
    
    # Some projects might have unit tests for helpers too
    test_path="${tests_dir}/unit/${relative_path%.*}-test.ts"
    test_paths+=("$test_path")
    test_path="${tests_dir}/unit/${relative_path%.*}-test.js"
    test_paths+=("$test_path")

# These typically have unit tests
elif [[ "$relative_path" == models/* ]] || 
     [[ "$relative_path" == services/* ]] || 
     [[ "$relative_path" == routes/* ]] || 
     [[ "$relative_path" == controllers/* ]] ||
     [[ "$relative_path" == adapters/* ]] || 
     [[ "$relative_path" == serializers/* ]] || 
     [[ "$relative_path" == mixins/* ]] || 
     [[ "$relative_path" == initializers/* ]] || 
     [[ "$relative_path" == instance-initializers/* ]] || 
     [[ "$relative_path" == utils/* ]] ||
     [[ "$relative_path" == transforms/* ]]; then
    test_path="${tests_dir}/unit/${relative_path%.*}-test.ts"
    test_paths+=("$test_path")
    test_path="${tests_dir}/unit/${relative_path%.*}-test.js"
    test_paths+=("$test_path")

# Templates might have integration tests
elif [[ "$relative_path" == templates/* ]]; then
    # Templates usually don't have direct tests, but their components do
    # Try to find a corresponding component test
    component_path="${relative_path#templates/}"
    test_path="${tests_dir}/integration/components/${component_path%.*}-test.ts"
    test_paths+=("$test_path")
    test_path="${tests_dir}/integration/components/${component_path%.*}-test.js"
    test_paths+=("$test_path")

# Modifiers typically have integration tests
elif [[ "$relative_path" == modifiers/* ]]; then
    test_path="${tests_dir}/integration/${relative_path%.*}-test.ts"
    test_paths+=("$test_path")
    test_path="${tests_dir}/integration/${relative_path%.*}-test.js"
    test_paths+=("$test_path")
    
    # Some might have unit tests
    test_path="${tests_dir}/unit/${relative_path%.*}-test.ts"
    test_paths+=("$test_path")
    test_path="${tests_dir}/unit/${relative_path%.*}-test.js"
    test_paths+=("$test_path")

# Any other files in lib/ or other directories
else
    # Try both unit and integration
    test_path="${tests_dir}/unit/${relative_path%.*}-test.ts"
    test_paths+=("$test_path")
    test_path="${tests_dir}/unit/${relative_path%.*}-test.js"
    test_paths+=("$test_path")
    
    test_path="${tests_dir}/integration/${relative_path%.*}-test.ts"
    test_paths+=("$test_path")
    test_path="${tests_dir}/integration/${relative_path%.*}-test.js"
    test_paths+=("$test_path")
fi

# Check which test files actually exist
existing_tests=()
for test_path in "${test_paths[@]}"; do
    if [ -f "$test_path" ]; then
        existing_tests+=("$test_path")
    fi
done

if [ ${#existing_tests[@]} -eq 0 ]; then
    exit 1
else
    output=""
    for i in "${!existing_tests[@]}"; do
        if [ $i -eq 0 ]; then
            output="${existing_tests[$i]}"
        else
            output="${output},${existing_tests[$i]}"
        fi
    done
    echo "$output"
    exit 0
fi